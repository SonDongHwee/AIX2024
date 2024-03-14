module input_feature_module #(
    parameter CALC_CH_W = 16,
    parameter CALC_WEIGHT_NUM = 1,
    
    localparam IFM_BITS = 8,
    localparam OFM_BITS = 8,
    localparam MAC_NUM = 9,
    localparam IFM_SRAM_WIDTH = IFM_BITS * CALC_CH_W, // 8* CALC_CH_W
    localparam IFM_SRAM_MAX_DEPTH = 256,
    localparam IFM_SRAM_ADDRESS = $clog2(IFM_SRAM_MAX_DEPTH), //8
    localparam DOUT_WIDTH = MAC_NUM * IFM_SRAM_WIDTH, // 9 * (16 * 8) = 1152
    localparam IFM_SRAM_ROW_NUM = 5,
    localparam IFM_DATA_NUM = 4,
    localparam W_BRAM_DATA_W = 16,
    localparam R_DATA_W = IFM_BITS * IFM_DATA_NUM,
    localparam W_DATA_W = OFM_BITS * W_BRAM_DATA_W,
    localparam MAX_IFM_DATA = 128*128*16,
    localparam MAX_IFM_DEPTH = $clog2(MAX_IFM_DATA/IFM_DATA_NUM),
    localparam MAX_IFM_LINE_DATA = 64*64,
    localparam MAX_IFM_LINE_DEPTH = $clog2(MAX_IFM_LINE_DATA/W_BRAM_DATA_W),
    localparam DELAY_NUM = 2,
    // WEIGHT parameters
    localparam WEIGHT_SRAM_MAX_DEPTH = 32,
    localparam WEIGHT_SRAM_ADDRESS = $clog2(WEIGHT_SRAM_MAX_DEPTH), // 5
    // DMA parameters
    localparam BITS_TRANS = 18,
    localparam AXI_WIDTH_AD = 32,
    localparam AXI_WIDTH_DA = 32
)(
    input                                       clk,
    input                                       rstn,

    // line loader ports
    input                                       i_vld,
    input [R_DATA_W-1:0]                        r_data,
    output [MAX_IFM_DEPTH-1:0]                  r_addr,

    // configuration params
    input [8:0]                                 ifm_w,
    input [8:0]                                 ich,
    input [1:0]                                 stride,
    input                                       is_conv3x3,
    input [8:0]                                 och,
    input [AXI_WIDTH_AD-1:0]                    weight_start_addr,


    // ap ports
    input                                       ap_start,
    output [DOUT_WIDTH-1:0]                     ifm_dout,
    output [CALC_WEIGHT_NUM*DOUT_WIDTH-1:0]     weight_dout,
    output                                      o_vld,
    output reg                                  ap_done,

    //DMA Functional Ports
    input [AXI_WIDTH_DA-1:0]                    dma_din,
    input                                       dma_din_vld,
    input [BITS_TRANS-1:0]                      dma_data_cnt,
    input                                       dma_done,
    output                                      start_dma,
    output [BITS_TRANS-1:0]                     dma_num_trans,
    output [AXI_WIDTH_AD-1:0]                   dma_start_addr
    
);
integer i, j;
genvar x, y;

reg [IFM_SRAM_ADDRESS-1:0]  ifm_sram_addr   [4:0][2:0];
reg [IFM_SRAM_WIDTH-1:0]    ifm_sram_din    [4:0];
reg                         ifm_sram_we     [4:0];
wire [IFM_SRAM_WIDTH-1:0]   ifm_sram_dout   [4:0][2:0];

reg [IFM_SRAM_WIDTH-1:0]    ifm_sram_dout_r [MAC_NUM-1:0];
for (x=0; x < MAC_NUM; x=x+1) begin
    assign ifm_dout[x*IFM_SRAM_WIDTH+:IFM_SRAM_WIDTH] = ifm_sram_dout_r[x];
end


reg [WEIGHT_SRAM_ADDRESS-1:0]   weight_sram_addr    [CALC_WEIGHT_NUM*2-1:0];
reg [DOUT_WIDTH-1:0]            weight_sram_din     [CALC_WEIGHT_NUM*2-1:0];
reg                             weight_sram_we      [CALC_WEIGHT_NUM*2-1:0];
wire [DOUT_WIDTH-1:0]           weight_sram_dout    [CALC_WEIGHT_NUM*2-1:0];


wire                            weight_loader_we;
wire [WEIGHT_SRAM_ADDRESS-1:0]  weight_loader_addr;
wire [DOUT_WIDTH-1:0]           weight_loader_data;
//-------------------------------------------------
// Counter signals
//-------------------------------------------------
wire [6:0] ch_slice_num;       // channel?ùÑ CLAC_CH_W?úºÎ°? ?Çò?àà Í∞? ÏµúÎ? 256/4 = 64
assign ch_slice_num = (ich < CALC_CH_W)? 1: (ich >> $clog2(CALC_CH_W));
// read counter
reg [7:0] rd_v_line_count;  // 0~256ÍπåÏ?
reg [3:0] rd_linebuf_num;   // 0~4ÍπåÏ?
reg [1:0] rd_line_num;      // stride ÍπåÏ? Ï¶ùÍ?
reg rd_done;                // ?ùΩÍ∏∞Í? ?ôÑÎ£åÎêê?ã§?äî ?ã†?ò∏
reg doing_rd;               //input_line_loaderÍ∞? ?èô?ûë?ïòÍ≥? ?ûà?ã§?äî ?ã†?ò∏
reg line_loader_start;
wire line_load_done;
wire [MAX_IFM_LINE_DEPTH-1:0] w_addr;
wire [W_DATA_W-1:0]           w_data;
wire w_en;



// write counter
reg [6:0] wr_ch_count;      // 0~15ÍπåÏ? ch_slice_num ÏµúÎ?Í∞? 16?ù¥Í∏? ?ïåÎ¨?
reg [8:0] wr_h_line_count;  // 0~256ÍπåÏ?
reg [8:0] wr_v_line_count;  // 0~256ÍπåÏ?
reg [3:0] calc_linebuf_num; // 0~4ÍπåÏ?
reg line_calc_done;         // ?ïúÏ§? ?†Ñ?Ü°?ù¥ ?ôÑÎ£åÎêê?ã§?äî ?ã†?ò∏
wire [3:0] calc_line_idx [2:0];
assign calc_line_idx[0] = (calc_linebuf_num !=0 ) ? calc_linebuf_num - 1: 4;
assign calc_line_idx[1] = calc_linebuf_num; 
assign calc_line_idx[2] = (calc_linebuf_num !=4 ) ? calc_linebuf_num + 1: 0;
reg last;
reg [6:0] wr_ch_count_d; //wr_ch_count delay 


// weight counter
reg weight_rd_done;     // finished DMA weight read
reg weight_select;      // indicates the current reading group
reg weight_ld_ap_start;
reg weight_ld_ap_running;
wire weight_ld_ap_done;
reg [2:0] weight_rd_block_count; // 0~CALC_WEIGHT_NUM-1 0~7
reg [8:0] weight_och_count; // 0~256ÍπåÏ?
wire [8:0] weight_idx;
assign weight_idx = weight_och_count + weight_rd_block_count;
for (x=0; x < CALC_WEIGHT_NUM; x = x +1) begin
    assign weight_dout[x*DOUT_WIDTH +: DOUT_WIDTH] = weight_sram_dout[(weight_select)*CALC_WEIGHT_NUM + x];
end

// delays
reg [8:0] is_padding;
reg [8:0] is_padding_d;
reg [3:0] calc_line_idx_d [2:0];
reg [3:0] calc_line_idx_dd [2:0];
reg [DELAY_NUM:0] o_vld_d;
assign o_vld = o_vld_d[DELAY_NUM];


//-------------------------------------------------
// FSM: input_feature_module FSM
//-------------------------------------------------
reg [2:0]   state;
localparam IDLE = 0;
localparam READ_2_LINES = 1;
localparam PROCESS_LINE = 2;
localparam ENDING_IFM = 3;
localparam FINISHED = 4;

always @(posedge clk or negedge rstn) begin
    if(~rstn) begin
        state       <= IDLE;
        ap_done     <= 0;
        weight_select <= 0;
        last <= 0;
    end
    else begin
        case (state)
            IDLE: begin
                if(ap_start) state <= READ_2_LINES;
                else state <= IDLE;
                ap_done <= 0;
                last <= 0;
            end
            READ_2_LINES: begin
                if(rd_done == 1 && rd_v_line_count == 2 && weight_och_count != 0) begin
                    state <= PROCESS_LINE;
                end
            end
            PROCESS_LINE: begin
                if(wr_v_line_count == (ifm_w) && line_calc_done) begin
                    // last line
                    // only calc needs to finish to end the whole input
                    state <= ENDING_IFM;
                end
            end
            ENDING_IFM: begin
                if(o_vld ==0) begin
                    if (last ==1'b1) begin
                        state <= FINISHED;
                    end
                    else begin
                        if(weight_och_count >= och)begin
                            last <= 1'b1;
                        end
                        weight_select <= ~weight_select;
                        state <= READ_2_LINES;
                    end
                end
            end
            FINISHED: begin
                state <= IDLE;
                ap_done <= 1;
            end
        endcase
    end
end

//-------------------------------------------------
// Counter: Read counter
//-------------------------------------------------
always@(posedge clk or negedge rstn) begin
    if(~rstn) begin
        rd_done             <= 0;
        doing_rd            <= 0;
        rd_v_line_count     <= 0;
        rd_linebuf_num      <= 0;
        rd_line_num         <= 0;
        line_loader_start   <= 0;
    end
    else begin
        case(state)
            IDLE:begin
                rd_done             <= 0;
                doing_rd            <= 0;
                rd_v_line_count     <= 0;
                rd_linebuf_num      <= 0;
                rd_line_num         <= 0;
                line_loader_start   <= 0;
            end
            READ_2_LINES, PROCESS_LINE: begin
                if(rd_done==0)begin
                    if (doing_rd==0)begin
                        line_loader_start <= 1'b1;
                        doing_rd <= 1'b1;
                    end
                    else begin
                        line_loader_start <= 1'b0;
                        if(line_load_done)begin
                            doing_rd <= 1'b0;
                            rd_v_line_count <= rd_v_line_count + 1;
                            if(rd_linebuf_num ==4) rd_linebuf_num <= 0;
                            else rd_linebuf_num <= rd_linebuf_num + 1;
                            // need to read 'stride' amount of lines
                            if(rd_line_num+1 == stride || rd_v_line_count == ifm_w-1)begin
                                rd_done <= 1'b1;
                                rd_line_num <= 0;
                            end else rd_line_num <= rd_line_num + 1;
                        end
                    end
                end
                else begin
                    if(rd_v_line_count < 3) begin
                        rd_done <= 0;
                    end
                    else if(line_calc_done == 1 && rd_v_line_count < ifm_w) begin
                        rd_done <= 0;
                    end
                end
            end
            ENDING_IFM: begin
                rd_done             <= 0;
                doing_rd            <= 0;
                rd_v_line_count     <= 0;
                rd_linebuf_num      <= 0;
                rd_line_num         <= 0;
                line_loader_start   <= 0;
            end
        endcase
    end
end

//-------------------------------------------------
// Counter: Calc counter
//-------------------------------------------------
always @(posedge clk or negedge rstn) begin
    if(~rstn) begin
        wr_ch_count         <= 0;
        wr_h_line_count     <= 0;
        wr_v_line_count     <= 0;
        line_calc_done      <= 0;
        calc_linebuf_num    <= 0;
    end
    else begin
        case(state)
            IDLE, READ_2_LINES: begin
                wr_ch_count         <= 0;
                wr_h_line_count     <= 0;
                wr_v_line_count     <= 0;
                line_calc_done      <= 0;
                calc_linebuf_num    <= 0;
                line_calc_done      <= 0;
            end
            PROCESS_LINE: begin
                if(line_calc_done ==0) begin
                    if(wr_ch_count == ch_slice_num -1) begin
                        // h_countÎ•? ?Ç§?õåÏ§òÏïº?ï®
                        wr_ch_count <= 0;                               // ch_count Ï¥àÍ∏∞?ôî
                        if(wr_h_line_count == ifm_w - stride) begin     // last element of line
                            line_calc_done <= 1;
                            wr_h_line_count <= 0;
                            wr_v_line_count <= wr_v_line_count + stride;
                            // calc_linebuf_num calculation ring buffer ?òï?Éú
                            if (calc_linebuf_num + stride >= IFM_SRAM_ROW_NUM) begin
                                calc_linebuf_num <= calc_linebuf_num + stride - IFM_SRAM_ROW_NUM;
                            end
                            else begin
                                calc_linebuf_num <= calc_linebuf_num + stride;
                            end
                        end
                        else begin
                            wr_h_line_count <= wr_h_line_count + stride;
                        end
                    end
                    else begin
                        // Í∞ôÏ? h_count?óê?Ñú ch_count Ï¶ùÍ?
                        wr_ch_count <= wr_ch_count + 1;
                    end
                end
                else begin
                    if(rd_done ==1 && wr_v_line_count < ifm_w) begin
                        line_calc_done <= 0;
                    end
                end
            end
        endcase
    end
end
//-------------------------------------------------
// Counter: Weight counter
//-------------------------------------------------
always@(posedge clk or negedge rstn) begin
    if (~rstn) begin
        weight_och_count <= 0;
        weight_rd_done <= 0;
        weight_rd_block_count <= 0;
        weight_ld_ap_start <= 0;
        weight_ld_ap_running <= 0;
    end
    else begin
        case(state)
            IDLE: begin
                weight_rd_done <= 0;
            end
            READ_2_LINES: begin
                // DMA writing very first group
                if(weight_rd_done ==0 && weight_och_count ==0) begin
                    if(weight_ld_ap_running ==0) begin
                        weight_ld_ap_start <= 1;
                        weight_ld_ap_running <= 1;
                    end
                    else begin
                        weight_ld_ap_start <= 0;
                        if (weight_ld_ap_done) begin
                            weight_ld_ap_running <= 0;
                            if(weight_rd_block_count+1 == CALC_WEIGHT_NUM) begin
                                weight_rd_done <= 1;
                                weight_rd_block_count <= 0;
                                weight_och_count <= weight_och_count + CALC_WEIGHT_NUM;
                            end
                            else begin
                                weight_rd_block_count <= weight_rd_block_count +1;
                            end
                        end
                    end
                end
                else begin
                    weight_rd_done<= 0;
                end
            end
            PROCESS_LINE: begin
                // DMA reading group
                if(weight_rd_done ==0) begin
                    if (weight_och_count < och) begin
                        if(weight_ld_ap_running ==0) begin
                            weight_ld_ap_start <= 1;
                            weight_ld_ap_running <= 1;
                        end
                        else begin
                            weight_ld_ap_start <= 0;
                            if (weight_ld_ap_done) begin
                                weight_ld_ap_running <= 0;
                                if(weight_rd_block_count+1 == CALC_WEIGHT_NUM) begin
                                    weight_rd_done <= 1;
                                    weight_och_count <= weight_och_count + CALC_WEIGHT_NUM;
                                end
                                else begin
                                    weight_rd_block_count <= weight_rd_block_count +1;
                                end
                            end
                        end
                    end
                    else begin
                        weight_rd_done <= 1;
                    end
                end
            end
            FINISHED: begin
                weight_rd_done <= 0;
            end
        endcase
    end
end

//-------------------------------------------------
// Counter: SRAM input, output
//-------------------------------------------------
always@(posedge clk or negedge rstn)begin
    if(~rstn)begin
        for(i=0; i < 5; i=i+1)begin
            for(j=0; j<3; j=j+1)begin
                ifm_sram_addr[i][j] <= 0;
            end
            ifm_sram_we[i] <= 0;
            ifm_sram_din[i] <= 0;
        end
        for(i=0; i<2*CALC_CH_W; i=i+1)begin
            weight_sram_addr[i] <= 0;
            weight_sram_we[i] <= 0;
            weight_sram_din[i] <= 0; 
         end
    end
    else begin
        case (state)
            IDLE: begin
                for(i=0; i < 5; i=i+1)begin
                    for(j=0; j<3; j=j+1)begin
                        ifm_sram_addr[i][j] <= 0;
                    end
                    ifm_sram_we[i] <= 0;
                    ifm_sram_din[i] <= 0;
                end
            end
            READ_2_LINES: begin
                if(rd_done ==0) begin
                    ifm_sram_we[rd_linebuf_num] <= w_en;
                    ifm_sram_din[rd_linebuf_num] <= w_data;
                    for (j=0; j < 3; j=j+1) ifm_sram_addr[rd_linebuf_num][j] <= w_addr;
                end

                // read only on first iteration
                if (weight_rd_done == 0 && weight_och_count ==0) begin
                    weight_sram_addr[(weight_select)*CALC_WEIGHT_NUM + weight_rd_block_count] <= weight_loader_addr;
                    weight_sram_din[(weight_select)*CALC_WEIGHT_NUM + weight_rd_block_count] <= weight_loader_data;
                    weight_sram_we[(weight_select)*CALC_WEIGHT_NUM + weight_rd_block_count] <= weight_loader_we;
                end
            end
            PROCESS_LINE: begin
                if(rd_done == 0) begin
                    ifm_sram_we[rd_linebuf_num] <= w_en;
                    ifm_sram_din[rd_linebuf_num] <= w_data;
                    for (j=0; j < 3; j=j+1) ifm_sram_addr[rd_linebuf_num][j] <= w_addr;
                end

                if (line_calc_done==0) begin
                    for (i= 0; i < 3; i = i+1) begin
                        ifm_sram_we[calc_line_idx[i]] <= 0;
                        for (j= 0; j < 3; j = j+1) begin
                            // data address?äî Í∞ÅÍ∞Å ?†Å?†à?ûà ?Ñ£?ñ¥Ï£ºÏñ¥?ïº ?ïú?ã§.
                            ifm_sram_addr[calc_line_idx[i]][j] <= (ch_slice_num * (wr_h_line_count + j - 1)) + wr_ch_count;
                        end
                    end
                end
                for (i=0; i < CALC_WEIGHT_NUM; i = i+1) begin
                    weight_sram_addr[(weight_select) * CALC_WEIGHT_NUM + i] <= wr_ch_count_d;
                    weight_sram_we[(weight_select) * CALC_WEIGHT_NUM + i] <= 0;
                end
                //should not write to weight ram on last iteration
                if (weight_ld_ap_running == 1 && weight_och_count < och) begin
                    weight_sram_addr[(!weight_select)*CALC_WEIGHT_NUM + weight_rd_block_count] <= weight_loader_addr;
                    weight_sram_din[(!weight_select)*CALC_WEIGHT_NUM + weight_rd_block_count] <= weight_loader_data;
                    for (i=0; i < CALC_WEIGHT_NUM; i = i+1) begin
                        if (i != weight_rd_block_count) begin
                            weight_sram_we[(!weight_select)*CALC_WEIGHT_NUM + i] <= 0;
                        end
                        else begin
                            weight_sram_we[(!weight_select)*CALC_WEIGHT_NUM + weight_rd_block_count] <= weight_loader_we;
                        end
                    end
                end
            end
        endcase
    end
end

//-------------------------------------------------
// Delays
//-------------------------------------------------
always@(posedge clk or negedge rstn)begin
    if(~rstn)begin
        for(i= 0; i < 3; i = i+1) begin
            for (j= 0; j < 3; j = j+1) begin
                is_padding[3*i+j] <= 0;
                is_padding_d[3*i+j] <= 0;
            end 
            calc_line_idx_d[i] <= 0;
            calc_line_idx_dd[i] <= 0;
        end
        for(i=0; i<MAC_NUM; i=i+1)begin
            ifm_sram_dout_r[i] <= 0; 
        end
        o_vld_d <= 0;
        wr_ch_count_d <= 0;
    end
    else begin
        wr_ch_count_d <= wr_ch_count;
        for (i= 0; i < 3; i = i+1) begin
            for (j= 0; j < 3; j = j+1) begin
                is_padding[3*i+j] <=  (wr_v_line_count + i <= 0)||(wr_v_line_count + i > ifm_w)||(wr_h_line_count + j <= 0)||(wr_h_line_count + j > ifm_w);
                is_padding_d[3*i+j] <= is_padding[3*i+j];
            end
            calc_line_idx_d[i] <= calc_line_idx[i];
            calc_line_idx_dd[i] <= calc_line_idx_d[i];
        end

        // o_vld delay
        if (state == PROCESS_LINE && line_calc_done == 0) begin
            o_vld_d <= {o_vld_d[DELAY_NUM-1:0],1'b1};
        end
        else begin
            o_vld_d <= {o_vld_d[DELAY_NUM-1:0],1'b0};
        end

        for (i= 0; i < 3; i = i+1) begin
            for (j= 0; j < 3; j = j+1) begin
                ifm_sram_dout_r[i*3+j]   <= (is_padding_d[i*3+j])? 0 : ifm_sram_dout[calc_line_idx_dd[i]][j];
            end
        end
    end
end        

//-------------------------------------------------
// Component: 15 block rams input feature
//-------------------------------------------------
generate
    for (x=0; x < 5; x=x+1) begin
        for (y=0; y < 3; y=y+1) begin
            ifm_bram_128x256
            u_sram(
                ./*input                */clka(clk),   // main clock
                ./*input  [WL_ADDR-1:0] */addra(ifm_sram_addr[x][y]),  // read/write address port 0
                ./*input  [WL_DATA-1:0] */dina(ifm_sram_din[x]), // write data port 0
                ./*output [WL_DATA-1:0] */douta(ifm_sram_dout[x][y]), // read data port 0
                ./*input                */wea(ifm_sram_we[x])    // write enable port 0
            );
        end
    end
endgenerate


//-------------------------------------------------
// Component: weight ram (CALC_WEIGHT_NUM*2)
//-------------------------------------------------
generate
    //first group starting with write
    for (x = 0; x < CALC_WEIGHT_NUM; x = x+1) begin
        weight_bram_1152x32
        weight_sram(
            ./*input                */clka(clk),   // main clock
            ./*input  [WL_ADDR-1:0] */addra(weight_sram_addr[0]),  // read/write address port 0
            ./*input  [WL_DATA-1:0] */dina(weight_sram_din[x]), // write data port 0
            ./*output [WL_DATA-1:0] */douta(weight_sram_dout[x]), // read data port 0
            ./*input                */wea(weight_sram_we[x])    // write enable port 0
        );
    end
    //second group starting with read
    for (x = 0; x < CALC_WEIGHT_NUM; x = x+1) begin
        weight_bram_1152x32
        weight_sram(
            ./*input                */clka(clk),   // main clock
            ./*input  [WL_ADDR-1:0] */addra(weight_sram_addr[1]),  // read/write address port 0
            ./*input  [WL_DATA-1:0] */dina(weight_sram_din[x + CALC_WEIGHT_NUM]), // write data port 0
            ./*output [WL_DATA-1:0] */douta(weight_sram_dout[x + CALC_WEIGHT_NUM]), // read data port 0
            ./*input                */wea(weight_sram_we[x + CALC_WEIGHT_NUM])    // write enable port 0
        );
    end
endgenerate


//-------------------------------------------------
// Component: input_line_loader
//-------------------------------------------------
input_line_loader #(
    .IFM_DATA_NUM(4)
) u_input_line_loader(
    ./*input                               */clk(clk),
    ./*input                               */rstn(rstn),
    ./*input [7:0]                         */ifm_w(ifm_w),
    ./*input [7:0]                         */ich(ich),
    ./*input [7:0]                         */line_idx(rd_v_line_count),
    ./*input                               */ap_start(line_loader_start),
    ./*input [R_DATA_W-1:0]                */r_data(r_data),
    ./*output reg [MAX_IFM_DEPTH-1:0]      */r_addr(r_addr),
    ./*output reg [MAX_IFM_LINE_DEPTH-1:0] */w_addr(w_addr),
    ./*output reg [W_DATA_W-1:0]           */w_data(w_data),
    ./*output reg                          */w_en(w_en),
    ./*output reg                          */ap_done(line_load_done)
);

//-------------------------------------------------
// Component: weight_loader
//-------------------------------------------------
weight_loader #(
    .AXI_WIDTH_AD(AXI_WIDTH_AD),
	.AXI_WIDTH_DA(AXI_WIDTH_DA),
    .BITS_TRANS(BITS_TRANS),
    .WEIGHT_SRAM_ADDRESS(WEIGHT_SRAM_ADDRESS),
    .CALC_CH_W(CALC_CH_W),
    .DOUT_WIDTH(DOUT_WIDTH)
) u_weight_loader(
    ./*input                                   */clk(clk),
    ./*input                                   */rstn(rstn),
    ./*input                                   */ap_start(weight_ld_ap_start),
    ./*output reg                              */ap_done(weight_ld_ap_done),
    
    //weight ram write output
    ./*output reg                              */w_en(weight_loader_we),
    ./*output reg [WEIGHT_SRAM_ADDRESS-1:0]    */w_addr(weight_loader_addr),
    ./*output reg [DOUT_WIDTH-1:0]             */w_data(weight_loader_data),
    
    //layer config & weight load config
    ./*input [8:0]                             */in_ch(ich),
    ./*input [8:0]                             */weight_idx(weight_idx),
    ./*input [AXI_WIDTH_DA-1:0]                */weight_start_addr(weight_start_addr), //weight start address in DRAM
    
    //axi_dma_rd functional ports
    ./*input [AXI_WIDTH_DA-1:0]                */data_o(dma_din),
    ./*input                                   */data_vld_o(dma_din_vld),
    ./*input [BITS_TRANS-1:0]                  */data_cnt_o(dma_data_cnt),
    ./*input                                   */done_o(dma_done),
    ./*output reg                              */start_dma(start_dma),
    ./*output reg [BITS_TRANS-1:0]             */num_trans(dma_num_trans),
    ./*output reg [AXI_WIDTH_AD-1:0]           */start_addr(dma_start_addr)
);


endmodule