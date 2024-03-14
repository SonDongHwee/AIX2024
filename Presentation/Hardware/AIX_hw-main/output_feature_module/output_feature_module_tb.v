`timescale 1ns / 1ps

module output_feature_module_tb;

reg clk;
reg rstn;

// Clock 
parameter CLK_PERIOD = 10;	//100MHz
initial begin
	clk = 1'b0;
	forever #(CLK_PERIOD/2) clk = ~clk;
end

parameter WI = 8;
parameter BRAM_DATA_WIDTH = 32;
parameter BRAM_DATA_DEPTH = 64*64*64/4;
parameter BRAM_ADDRESS_WIDTH = $clog2(BRAM_DATA_DEPTH);
parameter MAX_FEATURE_SIZE = 18; //2^18


//simulation inputs
reg                                       ap_start;
reg [WI-1:0]                              conv_kern_o;
reg                                       conv_kern_vld_o;
reg [8:0]                                 ofm_w;
reg [8:0]                                 out_ch;


wire [BRAM_ADDRESS_WIDTH-1:0]   bram_addr;
wire [BRAM_DATA_WIDTH-1:0]      bram_data;
wire                            bram_we;
wire                            ap_done;

output_feature_module #(
    
)u_output_feature_module (
    ./*input                                       */clk(clk),
    ./*input                                       */rstn(rstn),
    ./*input reg                                   */ap_start(ap_start),
    ./*input [WI-1:0]                              */conv_kern_o(conv_kern_o),
    ./*input                                       */conv_kern_vld_o(conv_kern_vld_o),
    ./*input [8:0]                                 */ofm_w(ofm_w),
    ./*input [8:0]                                 */out_ch(out_ch),
    ./*output reg [BRAM_ADDRESS_WIDTH-1:0]         */bram_addr(bram_addr),
    ./*output reg [BRAM_DATA_WIDTH-1:0]            */bram_data(bram_data),
    ./*output reg                                  */bram_we(bram_we),
    ./*output reg                                  */ap_done(ap_done)
);



integer i, j, k;
//simulation
initial begin

    rstn = 0;
    conv_kern_o = 0;
    conv_kern_vld_o = 0;
    ofm_w = 0;
    out_ch = 0;
    ap_start = 0;

    #(4*CLK_PERIOD) rstn = 1;

    @(posedge clk)
        ofm_w = 8;
        out_ch = 8;
        ap_start = 1;

    for (i=0; i < ofm_w*ofm_w*out_ch; i=i+1) begin
        @(posedge clk)
            conv_kern_o = i;
            conv_kern_vld_o = 1;
    end

end
endmodule