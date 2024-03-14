`timescale 1ns/1ps

module mac_kern_tb;
parameter WI = 8;
parameter mac_num= 9;
parameter max_in_ch = 256;
parameter N = 16;
parameter Y4_DELAY = 4;
parameter WO = 2*(WI + 4) + 16;

// Input
reg                             clk;
reg                             rstn;
reg [$clog2(max_in_ch)-1:0]     in_ch;
reg                             is_conv3x3;
reg                             vld_i;
reg [mac_num*N*WI-1:0]          win;
reg [mac_num*N*WI-1:0]          din;
// Output
wire [WO-1:0]                   acc_o;
wire vld_o;

// DUT
mac_kern u_mac_kern(
    // Input
    .clk(clk),
    .rstn(rstn),
    .in_ch(in_ch),
    .is_conv3x3(is_conv3x3),
    .vld_i(vld_i),
    .win(win),
    .din(din),
    // Output
    .acc_o(acc_o),
    .vld_o(vld_o)
);

// Clock
parameter CLK_PERIOD = 10;	//100MHz
initial begin
	clk = 1'b0;
    forever #(CLK_PERIOD/2) clk = ~clk;
end

// Test cases
initial begin
    rstn = 1'b0;            // Reset, low active
    vld_i = 1'b0;
    win = 0;
    din = 0;
    is_conv3x3 = 1'b0;

    #(4*CLK_PERIOD) rstn = 1'b1;
    // Test case 1: test conv3x3
    is_conv3x3 = 1'b1;
    in_ch = 8'd16;

    @(posedge clk)
        vld_i =  1'b1;
        win = {mac_num*N {8'd1} };
        din = {mac_num*N {-8'd1} };
    @(posedge clk)
        vld_i =  1'b1;
        win = {mac_num*N {8'd0} };
        din = {mac_num*N {8'd2} };
    @(posedge clk)
        vld_i =  1'b1;
        win = {mac_num*N {8'd0} };
        din = {mac_num*N {8'd3} };
    @(posedge clk)
        vld_i =  1'b1;
        win = {mac_num*N {8'd0} };
        din = {mac_num*N {8'd4} };
    @(posedge clk)
        vld_i = 1'b0;
    #(16*CLK_PERIOD);
    

    // Test case 2: test conv3x3
    is_conv3x3 = 1'b1;
    in_ch = 8'd64;

    @(posedge clk)
        vld_i =  1'b1;
        win = {mac_num*N {8'd0} };
        din = {mac_num*N {8'd1} };
    @(posedge clk)
        vld_i =  1'b1;
        win = {mac_num*N {8'd0} };
        din = {mac_num*N {8'd2} };
    @(posedge clk)
        vld_i =  1'b1;
        win = {mac_num*N {8'd0} };
        din = {mac_num*N {8'd3} };
    @(posedge clk)
        vld_i =  1'b1;
        win = {mac_num*N {8'd0} };
        din = {mac_num*N {8'd4} };
    @(posedge clk)
        vld_i = 1'b0;
    #(16*CLK_PERIOD);

    // Test case 1: test conv3x3
    is_conv3x3 = 1'b1;
    in_ch = 8'd3;
    @(posedge clk)
        vld_i =  1'b1;
        win = {{mac_num*3 {8'd0}}, {mac_num*13 {8'd0}}};
        din = {{mac_num*3 {8'd1}}, {mac_num*13 {8'd0}}};
    @(posedge clk)
        vld_i = 1'b0;

end

endmodule