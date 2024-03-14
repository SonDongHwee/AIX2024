`timescale 1ns/1ps

module bias_scale_act_tb;
parameter PARAM_BITS    = 16;
parameter WEIGHT_BITS   = 8;
parameter ACT_BITS      = 8;
parameter MAC_OUT_BITS  = 24; // mac output 24 bit
parameter N_DELAY       = 4;

// Input
reg                   clk;
reg                   rstn;
reg                   is_last_layer;
reg [PARAM_BITS-1:0]  scale;
reg [PARAM_BITS-1:0]  bias;
reg [5:0]             scale_shift;
reg [MAC_OUT_BITS-1:0]accum_in;
reg                   accum_vld_in;

//output
wire [ACT_BITS-1:0]   accum_out;
wire                  accum_vld_out;

// DUT
bias_scale_act u_bias_scale_act(
./*input                   */clk(clk),
./*input                   */rstn(rstn),
./*input                   */is_last_layer(is_last_layer),
./*input [PARAM_BITS-1:0]  */scale(scale),
./*input [PARAM_BITS-1:0]  */bias(bias),
./*input [5:0]             */scale_shift(scale_shift),
./*input [MAC_OUT_BITS-1:0]*/accum_in(accum_in),
./*input                   */accum_vld_in(accum_vld_in),
./*output [ACT_BITS-1:0]   */accum_out(accum_out),
./*output                  */accum_vld_out(accum_vld_out)
);

// Clock
parameter CLK_PERIOD = 10;	//100MHz
initial begin
	clk = 1'b0;
	forever #(CLK_PERIOD/2) clk = ~clk;
end

// Test cases
initial begin
    rstn = 1'b0;
    is_last_layer = 0;
    accum_vld_in = 0;
    accum_in = 0;
    
    // Test case 1
    bias = 1111;
    scale = 2000;
    scale_shift = 24;
    
    #(4*CLK_PERIOD) rstn = 1'b1;
    @(posedge clk) //14
        accum_in = 123456;
        accum_vld_in = 1;
    @(posedge clk) //23
        accum_in = 200000;
        accum_vld_in = 1;
    @(posedge clk) //127
        accum_in = 1234567;
        accum_vld_in = 1;
    @(posedge clk) //-5
        accum_in = -200000;
        accum_vld_in = 1;
    @(posedge clk) //-30
        accum_in = -1234567;
        accum_vld_in = 1;
    @(posedge clk) //-1
        scale_shift = 23;
        accum_in = -25000;
        accum_vld_in = 1;
    @(posedge clk) //-1
        bias = 16'h0040;
        scale = 16'd17409;
        scale_shift = 22;
        accum_in = 236552;
        accum_vld_in = 1;

end


endmodule