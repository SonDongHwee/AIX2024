`timescale 1ns/1ps
`include "yolov4_fsm_h.v"

module yolov4_fsm_tb;

reg clk;
reg rstn;
reg [3:0]   state;
wire [3:0]  nstate;

// DUT
yolov4_fsm u_yolov4_fsm(
    // Input
    .rstn(rstn),
    .state(state),
    // Output
    .nstate(nstate)
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
    state = `IDLE;

    #(4*CLK_PERIOD) rstn = 1'b1;
    
    @(posedge clk)
        state = nstate;
    @(posedge clk)
        state = nstate;
    @(posedge clk)
        state = nstate;
    @(posedge clk)
        state = nstate;
    @(posedge clk)
        state = nstate;
    @(posedge clk)
        state = nstate;
    @(posedge clk)
        state = nstate;
    @(posedge clk)
        state = nstate;
    @(posedge clk)
        state = nstate;
    @(posedge clk)
        state = nstate;
    @(posedge clk)
        state = nstate;

end

endmodule