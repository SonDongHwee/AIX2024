module maxpool #(
    parameter WI = 8,
    parameter WO = 8
)(
    input clk,
    input rstn
    input [8:0]     ifm_w,
    input [8:0]     ich,
    input din,
    input i_vld,
    output dout,
    output o_vld,
);

endmodule