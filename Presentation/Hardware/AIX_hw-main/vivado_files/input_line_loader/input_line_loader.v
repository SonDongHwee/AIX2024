//! title: input_line_loader.v
//! @author CHA (chamj61047@snu.ac.kr), JUN(junsung3737@snu.ac.kr)
//! @date 2023.03.05
//! @version 1.0
//! @copyright spadeA
//! @brief
module input_line_loader #(
    parameter  IFM_DATA_NUM = 4,
    parameter  W_BRAM_DATA_W = 16,
    localparam WI = 8,
    localparam WO = 8,
    localparam R_DATA_W = WI * IFM_DATA_NUM,
    localparam W_DATA_W = WO * W_BRAM_DATA_W,
    localparam MAX_IFM_DATA = 128*128*16,
    localparam MAX_IFM_DEPTH = $clog2(MAX_IFM_DATA/IFM_DATA_NUM),
    localparam MAX_IFM_LINE_DATA = 64*64,
    localparam MAX_IFM_LINE_DEPTH = $clog2(MAX_IFM_LINE_DATA/W_BRAM_DATA_W),
    localparam IFM_DATA_NUM_LOG = $clog2(IFM_DATA_NUM),
    localparam W_BRAM_DATA_W_LOG = $clog2(W_BRAM_DATA_W)
)(
    input                               clk,
    input                               rstn,
    input [8:0]                         ifm_w,      //! input FeatureMap width
    input [8:0]                         ich,        //! input FeatureMap channel
    input [7:0]                         line_idx,   //! line index to load
    input                               ap_start,   //! start the loading process
    input [R_DATA_W-1:0]                r_data,     //! input from the input RAM
    output reg [MAX_IFM_DEPTH-1:0]      r_addr, //! input RAM read address
    output reg [MAX_IFM_LINE_DEPTH-1:0] w_addr, //! output RAM address
    output reg [W_DATA_W-1:0]           w_data, //!write data for the output RAM
    output reg                          w_en, //! write enable for the output RAM
    output reg                          ap_done //!done signal
);

reg [1:0] state;
reg [1:0] nstate;

localparam IDLE = 0;
localparam READ = 1;
localparam READY = 2;
localparam WRITE = 3;

//counter declarations
reg [4:0] ch_cnt;           //! MAX count to W_BRAM_DATA_W-1
reg [4:0] ch_cnt_dd;        //! ch_cnt 2 delay
reg [5:0] ch_slice_cnt;         //! MAX count to ich/W_BRAM_DATA_W
reg [6:0] w_cnt;             //! MAX count to 256/IFM_DATA_NUM
reg [IFM_DATA_NUM_LOG-1:0] o_count;


always@(posedge clk or negedge rstn) begin
    if(~rstn) begin
        state <= IDLE;
    end
    else begin
        state <= nstate;
    end
end

always@(*) begin
    case (state)
        IDLE: begin
            if(ap_start) nstate = READ;
        end
        READ: begin
            if(ch_cnt+1==W_BRAM_DATA_W) nstate = READY;
        end
        READY: begin
            if(ch_cnt_dd+1 ==W_BRAM_DATA_W) nstate = WRITE;
        end
        WRITE: begin
            if(o_count == IFM_DATA_NUM-1) begin
                if(w_cnt==(ifm_w>>IFM_DATA_NUM_LOG)) nstate = IDLE;
                else nstate = READ;
            end
        end
        default:begin
            nstate = IDLE;
        end
    endcase
end

wire [MAX_IFM_LINE_DEPTH-1:0] w_start_addr_temp;
reg [MAX_IFM_LINE_DEPTH-1:0] w_start_addr;
assign w_start_addr_temp = w_cnt*IFM_DATA_NUM*(ich >>W_BRAM_DATA_W_LOG) + ch_slice_cnt;

//counting process
always@(posedge clk or negedge rstn)begin
    if(~rstn)begin
        ch_cnt <= 0;
        ch_slice_cnt <= 0;
        w_cnt <= 0;
        w_start_addr <= 0;
    end
    else begin
        case(state)
            IDLE: begin
                ch_cnt <= 0;
                ch_slice_cnt <= 0;
                w_cnt <=0;
            end    
            READ: begin
                if(ch_cnt+1==W_BRAM_DATA_W) begin
                    ch_cnt <= 0;
                    w_start_addr <= w_start_addr_temp;
                    if(ch_slice_cnt+1 == (ich>>W_BRAM_DATA_W_LOG) )begin
                        ch_slice_cnt <= 0;
                        w_cnt <= w_cnt +1;
                    end 
                    else ch_slice_cnt <= ch_slice_cnt +1; 
                end
                else begin
                    ch_cnt <= ch_cnt + 1;
                end
            end
        endcase     
    end
end

reg r_data_valid_f;
reg r_data_valid; //r_data valid signal
wire [MAX_IFM_DEPTH-1:0] read_start_address;
wire [MAX_IFM_DEPTH-1:0] ifm_w_squared;
assign ifm_w_squared = ifm_w*ifm_w;
assign read_start_address = line_idx*(ifm_w>>IFM_DATA_NUM_LOG)+w_cnt+ch_slice_cnt*(ifm_w_squared<<(W_BRAM_DATA_W_LOG-IFM_DATA_NUM_LOG));


//input RAM read address
always@(posedge clk or negedge rstn)begin
    if(~rstn)begin
        r_addr <= 0;
        r_data_valid_f <= 0;
    end
    else if(state==READ)begin
        r_addr <= read_start_address + ch_cnt*(ifm_w_squared>>IFM_DATA_NUM_LOG);
        r_data_valid_f <= 1'b1;
    end
    else begin
        r_addr <= 0;
        r_data_valid_f <= 1'b0;
    end
end

//input RAM data valid signal delay
always@(posedge clk or negedge rstn)begin
    if(~rstn)begin
        r_data_valid <= 0;
    end
    else begin 
        r_data_valid <= r_data_valid_f;
    end
end

reg [W_DATA_W-1:0] w_data_buf [IFM_DATA_NUM-1:0];
//data for output RAM address
integer i;
always@(posedge clk or negedge rstn)begin
    if(~rstn)begin
        for(i=0; i<IFM_DATA_NUM; i=i+1) w_data_buf[i] <= 0;
        ch_cnt_dd <= 0;        
    end
    else if(r_data_valid)begin
        for(i=0; i<IFM_DATA_NUM; i=i+1)begin
            w_data_buf[i][WO*ch_cnt_dd+:WO] <= r_data[WI*i+:WI];
        end
        if(ch_cnt_dd+1 == W_BRAM_DATA_W) ch_cnt_dd <= 0;
        else ch_cnt_dd <= ch_cnt_dd + 1;
    end else if(state!=WRITE) begin
        for(i=0; i<IFM_DATA_NUM; i=i+1) w_data_buf[i] <= 0; 
    end
end

always@(posedge clk or negedge rstn) begin
    if(~rstn) begin
        o_count <= 0;
        w_en <= 0;
        w_addr <= 0;    
        ap_done <= 0;
        w_data <= 0;
    end
    else begin
        if (state == WRITE) begin
            o_count <= o_count +1;
            w_en <= 1;
            w_addr <= w_start_addr + o_count* (ich >> W_BRAM_DATA_W_LOG);
            w_data <= w_data_buf[o_count];
            if(o_count==IFM_DATA_NUM-1 && w_cnt==(ifm_w>>IFM_DATA_NUM_LOG)) ap_done <= 1'b1;
        end else begin
            o_count <= 0;
            w_en <= 0;
            w_addr <= 0;
            ap_done <= 0;
            w_data <= 0;
        end
    end
end

endmodule