module weight_module #(
    parameter WEIGHT_BITS = 8,
    parameter N = 16,
    parameter MAC_NUM = 9,
    parameter CALC_WEIGHT_NUM = 1,
    localparam DATA_WIDTH = N*MAC_NUM*WEIGHT_BITS,
    parameter BITS_TRANS = 18,
    parameter AXI_WIDTH_AD   = 32,
	parameter AXI_WIDTH_DA   = 32
)(
    input clk,
    input rstn,
    input ap_start,
    input request,
    input weight_start_addr,
    input out_ch,
    output ready,
    output dout,
    output o_vld,
    output ap_done,

    //DMA Functional Ports
    input                           start_dma;
    input [BITS_TRANS-1:0]          num_trans;
    input [AXI_WIDTH_AD-1:0]        start_addr;
    output reg [AXI_WIDTH_DA-1:0]   data_o;
    output reg                      data_vld_o;
    output reg [BITS_TRANS-1:0]     data_cnt_o;
    output reg                      done_o;
);

genvar x;
generate
    for (x = 0; x < CALC_WEIGHT_NUM*2; x = x+1) begin
        sram #(
            .WL_DATA (SRAM_WIDTH),
            .SIZE(SRAM_MAX_DEPTH),
            .WL_ADDR(SRAM_ADDRESS)
        ) u_sram(
            ./*input                */clk(clk),   // main clock
            ./*input                */rst(rstn),   // reset, act.low by default
            ./*input  [WL_ADDR-1:0] */addr(sram_addr[x]),  // read/write address port 0
            ./*input  [WL_DATA-1:0] */wdata(sram_din[x]), // write data port 0
            ./*output [WL_DATA-1:0] */rdata(sram_dout[x]), // read data port 0
            ./*input                */ena(sram_we[x])    // write enable port 0
        )
    end
endgenerate

endmodule