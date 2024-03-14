module weight_loader #(
    parameter AXI_WIDTH_AD      = 32,           
	parameter AXI_WIDTH_DA      = 32,    
    parameter BITS_TRANS        = 18,
    parameter WEIGHT_SRAM_ADDRESS = 5,
    parameter CALC_CH_W = 16,
    parameter DOUT_WIDTH        = 9*16*8,
    localparam DOUT_DATA_NUM = 9*CALC_CH_W
)(
    input                                   clk,
    input                                   rstn,
    input                                   ap_start,
    output reg                              ap_done,

    //weight ram write output
    output reg                              w_en,
    output reg [WEIGHT_SRAM_ADDRESS-1:0]     w_addr,
    output reg [DOUT_WIDTH-1:0]             w_data,

    //layer config & weight load config
    input [8:0]                             in_ch,
    input [8:0]                             weight_idx,
    input [AXI_WIDTH_DA-1:0]                weight_start_addr, //weight start address in DRAM

    //axi_dma_rd functional ports
    input [AXI_WIDTH_DA-1:0]                data_o,
    input                                   data_vld_o,
    input [BITS_TRANS-1:0]                  data_cnt_o,
    input                                   done_o,
    output reg                              start_dma,
    output reg [BITS_TRANS-1:0]             num_trans,
    output reg [AXI_WIDTH_AD-1:0]           start_addr
);

localparam IDLE     = 0;
localparam PROCESS  = 1;
reg state;
wire [10:0] weight_data4_num;
assign weight_data4_num = 9*(in_ch>>2); //(number of elements in one weight)/4

//counters and buffer for read/write
reg [8:0] r_data_cnt; //max count to DOUT_DATA_NUM/4
reg [WEIGHT_SRAM_ADDRESS-1:0] w_data_cnt; //max count to inch/CALC_CH_W 
reg [DOUT_WIDTH-AXI_WIDTH_DA-1:0] w_data_buf; //buffer to save past received data


//state transition and dma start signal input
always@(posedge clk or negedge rstn)begin
    if(~rstn)begin
        state <= IDLE;
        start_addr <= 0;
        start_dma <= 0;
        ap_done <= 0;
        num_trans <= 0;
    end
    else begin
        case(state)
            IDLE:begin
                if(ap_start==1'b1)begin
                    num_trans <= weight_data4_num;
                    start_addr <= weight_start_addr + 4*weight_data4_num*weight_idx; //needs to be checked
                    start_dma <= 1'b1;
                    state <= PROCESS;
                    ap_done <= 1'b0;
                end 
                else begin
                    num_trans <= 0;
                    start_addr <= 0;
                    start_dma <= 0;
                    ap_done <= 1'b0;
                end
            end
            PROCESS:begin
                start_dma <= 0;
                if(w_data_cnt == (in_ch>>$clog2(CALC_CH_W)))begin
                    ap_done <= 1'b1;
                    state <= IDLE;
                end
            end
        endcase
    end
end

 //read and write process
always@(posedge clk or negedge rstn)begin
    if(~rstn)begin
        r_data_cnt <= 0;
        w_data_cnt <= 0;
        w_data <= 0;
        w_addr <= 0;
        w_en <= 0;
        w_data_buf <= 0;
    end
    else begin
        case(state)
            IDLE:begin
                r_data_cnt <= 0;
                w_data <= 0;
                w_addr <= 0;
                w_en <= 0;
                w_data_buf <= 0;
                w_data_cnt <= 0;
            end
            PROCESS:begin
                if(data_vld_o)begin
                    if(r_data_cnt+1==(DOUT_DATA_NUM/4)) begin
                        r_data_cnt <= 0;
                        w_data <= {data_o,w_data_buf};
                        w_addr <= w_data_cnt;
                        w_data_cnt <= w_data_cnt + 1;
                        w_en <= 1'b1;
                    end 
                    else begin
                        w_en <= 1'b0;
                        w_data_buf[AXI_WIDTH_DA*r_data_cnt+:AXI_WIDTH_DA] <= data_o;
                        r_data_cnt <= r_data_cnt + 1;
                    end
                end 
                else begin
                    w_en <= 1'b0;
                    w_data <= 0;
                    w_addr <= 0;
                end
            end
        endcase
    end
end



endmodule