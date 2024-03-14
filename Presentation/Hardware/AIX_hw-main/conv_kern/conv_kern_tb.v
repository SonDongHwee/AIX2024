`timescale 1ns/1ps

module conv_kern_tb;

parameter WI = 8;
parameter N = 16;
parameter PARAM_BITS = 16;
parameter MAC_OUT_BITS = 24;
parameter ACT_BITS = 8;
parameter MAC_NUM = 9;

reg                         clk;
reg                         rstn;
reg [7:0]                   in_ch; // 최대 256
reg                         is_conv3x3;
reg                         vld_i;
reg [MAC_NUM*N*WI-1:0]      win;
reg [MAC_NUM*N*WI-1:0]      din;
reg                         is_last_layer;
reg [PARAM_BITS-1:0]        scale;
reg [PARAM_BITS-1:0]        bias;
reg [5:0]                   scale_shift;
wire [ACT_BITS-1:0]         acc_o;
wire                        vld_o;


// DUT
conv_kern u_conv_kern(
./*input                   */clk(clk),
./*input                   */rstn(rstn),
./*input [7:0]             */in_ch(in_ch), // 최대 256
./*input                   */is_conv3x3(is_conv3x3),
./*input                   */vld_i(vld_i),
./*input [N*WI-1:0]        */win(win),
./*input [N*WI-1:0]        */din(din),
./*input                   */is_last_layer(is_last_layer),
./*input [PARAM_BITS-1:0]  */scale(scale),
./*input [PARAM_BITS-1:0]  */bias(bias),
./*input [5:0]             */scale_shift(scale_shift),
./*output [ACT_BITS-1:0]   */acc_o(acc_o),
./*output                  */vld_o(vld_o)
);

// Clock
parameter CLK_PERIOD = 10;	//100MHz
initial begin
	clk = 1'b0;
    forever #(CLK_PERIOD/2) clk = ~clk;
end

// Test cases
initial begin
    rstn = 1'b0;			// Reset, low active
	vld_i = 1'b0;
	win = 0;
	din = 0;

    in_ch = 3;
    is_conv3x3 = 1'b1;
    is_last_layer = 1'b0;
    scale = 16'd17409;
	bias = 16'h0040;
	scale_shift = 22;

    #(4*CLK_PERIOD) rstn = 1'b1;
    win[0*(N*WI)+:(N*WI)] = {{13{8'b0}},{8'hff}, {8'h0d}, {8'hfd}};
	win[1*(N*WI)+:(N*WI)] = {{13{8'b0}},{8'h4b}, {8'h50}, {8'h3b}};
	win[2*(N*WI)+:(N*WI)] = {{13{8'b0}},{8'hfa}, {8'hf3}, {8'hf2}};
	win[3*(N*WI)+:(N*WI)] = {{13{8'b0}},{8'hfe}, {8'h0b}, {8'h0a}};
	win[4*(N*WI)+:(N*WI)] = {{13{8'b0}},{8'he8}, {8'hed}, {8'hee}};
	win[5*(N*WI)+:(N*WI)] = {{13{8'b0}},{8'hcb}, {8'hc6}, {8'hd4}};
	win[6*(N*WI)+:(N*WI)] = {{13{8'b0}},{8'hf5}, {8'hf8}, {8'hf7}};
	win[7*(N*WI)+:(N*WI)] = {{13{8'b0}},{8'hf6}, {8'hf2}, {8'hf6}};
	win[8*(N*WI)+:(N*WI)] = {{13{8'b0}},{8'h1d}, {8'h13}, {8'h17}};

    @(posedge clk) 
        vld_i = 1'b1;
        din[0*(N*WI)+:(N*WI)] = {{13{8'b0}},{8'h00}, {8'h00}, {8'h00}};
	    din[1*(N*WI)+:(N*WI)] = {{13{8'b0}},{8'h00}, {8'h00}, {8'h00}};
	    din[2*(N*WI)+:(N*WI)] = {{13{8'b0}},{8'h00}, {8'h00}, {8'h00}};
	    din[3*(N*WI)+:(N*WI)] = {{13{8'b0}},{8'h00}, {8'h00}, {8'h00}};
	    din[4*(N*WI)+:(N*WI)] = {{13{8'b0}},{8'h66}, {8'h75}, {8'h76}};
	    din[5*(N*WI)+:(N*WI)] = {{13{8'b0}},{8'h64}, {8'h72}, {8'h71}};
	    din[6*(N*WI)+:(N*WI)] = {{13{8'b0}},{8'h00}, {8'h00}, {8'h00}};
	    din[7*(N*WI)+:(N*WI)] = {{13{8'b0}},{8'h66}, {8'h76}, {8'h76}};
	    din[8*(N*WI)+:(N*WI)] = {{13{8'b0}},{8'h63}, {8'h71}, {8'h6f}};
        //-8

    @(posedge clk)
        vld_i = 1'b1;
		din[0*(N*WI)+:(N*WI)] = {{13{8'b0}},{8'h00}, {8'h00}, {8'h00}};
	    din[1*(N*WI)+:(N*WI)] = {{13{8'b0}},{8'h00}, {8'h00}, {8'h00}};
	    din[2*(N*WI)+:(N*WI)] = {{13{8'b0}},{8'h00}, {8'h00}, {8'h00}};
	    din[3*(N*WI)+:(N*WI)] = {{13{8'b0}},{8'h64}, {8'h72}, {8'h71}};
	    din[4*(N*WI)+:(N*WI)] = {{13{8'b0}},{8'h61}, {8'h6c}, {8'h6a}};
	    din[5*(N*WI)+:(N*WI)] = {{13{8'b0}},{8'h5b}, {8'h65}, {8'h63}};
	    din[6*(N*WI)+:(N*WI)] = {{13{8'b0}},{8'h63}, {8'h71}, {8'h6f}};
	    din[7*(N*WI)+:(N*WI)] = {{13{8'b0}},{8'h5d}, {8'h68}, {8'h66}};
	    din[8*(N*WI)+:(N*WI)] = {{13{8'b0}},{8'h5a}, {8'h65}, {8'h62}};
		//-7

	@(posedge clk)
        vld_i = 1'b1;
		din[0*(N*WI)+:(N*WI)] = {{13{8'b0}},{8'h00}, {8'h00}, {8'h00}};
	    din[1*(N*WI)+:(N*WI)] = {{13{8'b0}},{8'h00}, {8'h00}, {8'h00}};
	    din[2*(N*WI)+:(N*WI)] = {{13{8'b0}},{8'h00}, {8'h00}, {8'h00}};
	    din[3*(N*WI)+:(N*WI)] = {{13{8'b0}},{8'h56}, {8'h5e}, {8'h5d}};
	    din[4*(N*WI)+:(N*WI)] = {{13{8'b0}},{8'h52}, {8'h5a}, {8'h58}};
	    din[5*(N*WI)+:(N*WI)] = {{13{8'b0}},{8'h54}, {8'h5c}, {8'h5a}};
	    din[6*(N*WI)+:(N*WI)] = {{13{8'b0}},{8'h55}, {8'h5d}, {8'h5b}};
	    din[7*(N*WI)+:(N*WI)] = {{13{8'b0}},{8'h53}, {8'h5b}, {8'h59}};
	    din[8*(N*WI)+:(N*WI)] = {{13{8'b0}},{8'h52}, {8'h5a}, {8'h59}};
		//-6
	@(posedge clk)
		vld_i = 1'b0;
end

endmodule