module input_feature_module #(
    localparam IFM_BITS = 8,
    localparam IFM_NUM = 16,
    localparam MAC_NUM = 9,
    localparam SRAM_NUM = 12,
    localparam SRAM_WIDTH = IFM_BITS * IFM_NUM, // 16*8 = 128
    localparam SRAM_MAX_DEPTH = 256,
    localparam SRAM_ADDRESS = $clog2(SRAM_MAX_DEPTH), //8
    localparam DOUT_WIDTH = MAC_NUM * SRAM_WIDTH, // 9 * (16 * 8)
    localparam SRAM_ROW_NUM = 5,
    localparam IFM_DATA_NUM = 4,
    localparam WI = 8,
    localparam WO = 8,
    localparam W_BRAM_DATA_W = 16,
    localparam R_DATA_W = WI * IFM_DATA_NUM,
    localparam W_DATA_W = WO * W_BRAM_DATA_W,
    localparam MAX_IFM_DATA = 128*128*16,
    localparam MAX_IFM_DEPTH = $clog2(MAX_IFM_DATA/IFM_DATA_NUM),
    localparam MAX_IFM_LINE_DATA = 64*64,
    localparam MAX_IFM_LINE_DEPTH = $clog2(MAX_IFM_LINE_DATA/W_BRAM_DATA_W)
)(
    input                               clk,
    input                               rstn,
    input [SRAM_WIDTH-1:0]              din,
    input                               i_vld, 
    input [8:0]                         ifm_w,
    input [8:0]                         ich,
    input [1:0]                         stride,
    input                               is_conv3x3,
    input                               ap_start,
    input [R_DATA_W-1:0]                r_data,
    
    output [MAX_IFM_DEPTH-1:0]          r_addr,
    output [DOUT_WIDTH-1:0]             dout,
    output reg                          o_vld,
    output reg                          ap_done
);
integer i, j;
genvar x, y;

reg [SRAM_ADDRESS-1:0]  sram_addr   [4:0][2:0];
reg [SRAM_WIDTH-1:0]    sram_din    [4:0];
reg                     sram_we     [4:0];
wire [SRAM_WIDTH-1:0]   sram_dout   [4:0][2:0];

reg [SRAM_WIDTH-1:0]    sram_dout_r [MAC_NUM-1:0];
for (x=0; x < MAC_NUM; x=x+1) begin
    assign dout[x*SRAM_WIDTH+:SRAM_WIDTH] = sram_dout_r[x];
end

//-------------------------------------------------
// Counter signals
//-------------------------------------------------
wire [4:0] ch_16_cnt;       // channel을 16으로 나눈 값 최대 256/16 = 16
assign ch_16_cnt = (ich < 16)? 1: (ich >> 4);
// read counter
reg [7:0] rd_v_line_count;  // 0~256까지
reg [3:0] rd_linebuf_num;   // 0~4까지
reg [1:0] rd_line_num;      // stride 까지 증가
reg rd_done;                // 읽기가 완료됐다는 신호
reg doing_rd;               //input_line_loader가 동작하고 있다는 신호
reg line_loader_start;
wire [MAX_IFM_LINE_DEPTH-1:0] w_addr;
wire [W_DATA_W-1:0]           w_data;
wire w_en;
wire line_load_done;



// write counter
reg [3:0] wr_ch_count;      // 0~15까지 ch_16_cnt 최대가 16이기 때문
reg [8:0] wr_h_line_count;  // 0~256까지
reg [8:0] wr_v_line_count;  // 0~256까지
reg [3:0] calc_linebuf_num; // 0~4까지
reg line_calc_done;         // 한줄 전송이 완료됐다는 신호
wire [3:0] calc_line_idx [2:0];
assign calc_line_idx[0] = (calc_linebuf_num !=0 ) ? calc_linebuf_num - 1: 4;
assign calc_line_idx[1] = calc_linebuf_num; 
assign calc_line_idx[2] = (calc_linebuf_num !=4 ) ? calc_linebuf_num + 1: 0;
reg [8:0] is_padding;
reg [8:0] is_padding_d;
reg [3:0] calc_line_idx_d [2:0];
reg [3:0] calc_line_idx_dd [2:0];

//-------------------------------------------------
// FSM: input_feature_module FSM
//-------------------------------------------------
reg [1:0]   state;
localparam IDLE = 0;
localparam READ_2_LINES = 1;
localparam PROCESS_LINE = 2;

always @(posedge clk or negedge rstn) begin
    if(~rstn) begin
        state       <= IDLE;
        ap_done     <= 0;
    end
    else begin
        case (state)
            IDLE: begin
                if(ap_start) state <= READ_2_LINES;
                else state <= IDLE;
            end
            READ_2_LINES: begin
                if(rd_done == 1) begin
                    if(rd_v_line_count == 2) begin
                        state <= PROCESS_LINE;
                    end
                end
            end
            PROCESS_LINE: begin
                if(wr_v_line_count == (ifm_w - stride)) begin
                    // only calc needs to finish to end the whole input
                    if (line_calc_done) begin
                        state <= IDLE;
                    end
                end
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
                rd_done <= 1'b0;
            end
            READ_2_LINES: begin
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
                            rd_linebuf_num  <= rd_linebuf_num + 1; 
                            if(rd_v_line_count==1) rd_done <= 1'b1;
                        end
                    end
                end 
                else begin
                    rd_done <= 1'b0;
                end 
                // sram input mapping
                for(j=0; j < 3; j = j+1) begin
                    sram_we [rd_linebuf_num] <= w_en;
                    sram_addr[rd_linebuf_num][j] <= w_addr;
                    sram_din[rd_linebuf_num] <= w_data;
                end
            end
            PROCESS_LINE: begin
                if(rd_done==1 && line_calc_done==1 && wr_v_line_count < (ifm_w - stride))begin
                    rd_done <= 0;
                end
                if(rd_done == 0) begin
                    if (!doing_rd)begin
                        line_loader_start <= 1'b1;
                        doing_rd <= 1'b1;
                    end
                    else begin
                        line_loader_start <= 1'b0;
                        if(line_load_done)begin
                            doing_rd <= 1'b0;
                            rd_v_line_count <= rd_v_line_count + 1;
                            if(rd_linebuf_num == 4) rd_linebuf_num <= 0;
                            else rd_linebuf_num <= rd_linebuf_num + 1;
                            if(rd_line_num+1 == stride)begin
                                rd_done <= 1'b1;
                                rd_line_num <= 0;
                            end else rd_line_num <= rd_line_num + 1;
                        end
                    end
                end

                // sram input mapping

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
        o_vld               <= 0;
        for (i=0; i < MAC_NUM; i = i +1) begin
            sram_dout_r[i]  <= 0;
        end
    end
    else begin
        case(state)
            PROCESS_LINE: begin
                if(rd_done==1 && line_calc_done==1)begin
                    line_calc_done <= 0;
                end
                if(line_calc_done ==0) begin
                    if(wr_ch_count == ch_16_cnt -1) begin
                        // h_count를 키워줘야함
                        wr_ch_count <= 0;                               // ch_count 초기화
                        if(wr_h_line_count == ifm_w - stride) begin     // last element of line
                            line_calc_done <= 1;
                            wr_h_line_count <= 0;
                            wr_v_line_count <= wr_v_line_count + stride;
                            // calc_linebuf_num calculation ring buffer 형태
                            if (calc_linebuf_num + stride >= SRAM_ROW_NUM) begin
                                calc_linebuf_num <= calc_linebuf_num + stride - SRAM_ROW_NUM;
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
                        // 같은 h_count에서 ch_count 증가
                        wr_ch_count <= wr_ch_count + 1;
                    end

                end
                // 9개의 sram과 dout mapping
            end
        endcase
    end
end

always@(posedge clk or negedge rstn)begin
    if(~rstn)begin
    end
    else begin
        for (j=0; j < 3; j=j+1) begin
            sram_we[rd_linebuf_num] <= w_en;
            sram_addr[rd_linebuf_num][j] <= w_addr;
            sram_din[rd_linebuf_num] <= w_data;
        end 
        if(state==PROCESS_LINE) begin
            if (line_calc_done==0) begin
                for (i= 0; i < 3; i = i+1) begin
                    for (j= 0; j < 3; j = j+1) begin
                        // data address는 각각 적절히 넣어주어야 한다.
                        sram_we[calc_line_idx[i]]            <= 0;
                        sram_addr[calc_line_idx[i]][j]       <=  (ch_16_cnt * (wr_h_line_count + j-1)) + wr_ch_count;
                    end
                end
            end
            for (i= 0; i < 3; i = i+1) begin
                for (j= 0; j < 3; j = j+1) begin
                    sram_dout_r[i*3+j]   <= (is_padding_d[i*3+j])?0:sram_dout[calc_line_idx_dd[i]][j];
                end
            end
        end

    end
end

always@(posedge clk)begin
    for (i= 0; i < 3; i = i+1) begin
        for (j= 0; j < 3; j = j+1) begin
            is_padding[3*i+j] <=  (wr_v_line_count + i <= 0)||(wr_v_line_count + i > ifm_w)||(wr_h_line_count + j <= 0)||(wr_h_line_count + j > ifm_w);
            is_padding_d[3*i+j] <= is_padding[3*i+j];
        end
        calc_line_idx_d[i] <= calc_line_idx[i];
        calc_line_idx_dd[i] <= calc_line_idx_d[i];
    end
end



//-------------------------------------------------
// Component: 15 block rams
//-------------------------------------------------
generate
    for (x=0; x < 5; x=x+1) begin
        for (y=0; y < 3; y=y+1) begin
            sram #(
                .WL_DATA(SRAM_WIDTH),
                .SIZE(SRAM_MAX_DEPTH),
                .WL_ADDR(SRAM_ADDRESS)
            ) u_sram(
                ./*input                */clk(clk),   // main clock
                ./*input                */rst(rstn),   // reset, act.low by default
                ./*input  [WL_ADDR-1:0] */addr(sram_addr[x][y]),  // read/write address port 0
                ./*input  [WL_DATA-1:0] */wdata(sram_din[x]), // write data port 0
                ./*output [WL_DATA-1:0] */rdata(sram_dout[x][y]), // read data port 0
                ./*input                */ena(sram_we[x])    // write enable port 0
            );
        end
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

endmodule