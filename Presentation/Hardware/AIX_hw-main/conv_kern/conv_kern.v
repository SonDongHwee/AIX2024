//! title: conv_kern
//! @author CHA (chamj61047@snu.ac.kr), JUN(junsung3737@snu.ac.kr)
//! @date 2023.03.05
//! @version
//! @copyright
//! @brief
module conv_kern#(
    parameter WI = 8,                       //! Input data width
    parameter N = 16,                       //! number of parallel computed channels
    parameter PARAM_BITS = 16,              //! scale, bias bit width
    parameter MAC_OUT_BITS = 24,            //! output bit width of MAC_KERN
    parameter ACT_BITS = 8,                 //! output bit width
    parameter MAC_NUM = 9                   //! number of mac used
)(
    input                   clk,
    input                   rstn,
    input [7:0]             in_ch,          //! max 256
    input [7:0]             in_row,         //! max 256
    input                   is_conv3x3,     //! 3x3 conv or 1x1 conv
    input                   vld_i,          //! valid input
    input [MAC_NUM*N*WI-1:0]win,            //! weight input
    input [MAC_NUM*N*WI-1:0]din,            //! data input
    input                   is_last_layer,  //! is last layer
    input [PARAM_BITS-1:0]  scale,          //! scale value
    input [PARAM_BITS-1:0]  bias,           //! bias value
    input [5:0]             scale_shift,    //! scale shift value
    output                  change_bias,    
    output [ACT_BITS-1:0]   acc_o,          //! accumulated output value
    output                  vld_o           //! valid output signal
);

// Incoming signals from MACs
wire[MAC_OUT_BITS-1:0]  mac_kern_acc_o;
wire  				    mac_kern_acc_vld_o;

reg [7:0] mac_kern_o_counter;

//-------------------------------------------------
// Component: MAC KERN
//-------------------------------------------------
mac_kern u_mac_kern(
./*input 			        */clk(clk),
./*input 			        */rstn(rstn),
./*input [7:0]              */in_ch(in_ch),
./*input 			        */is_conv3x3(is_conv3x3),
./*input 			        */vld_i(vld_i), 
./*input [MAC_NUM*N*WI-1:0] */win(win), 
./*input [MAC_NUM*N*WI-1:0] */din(din),
./*output[WO-1:0] 	        */acc_o(mac_kern_acc_o),
./*output reg 		        */vld_o(mac_kern_acc_vld_o)
);
//-------------------------------------------------
// Component: Bias, Scale, Activation
//-------------------------------------------------
bias_scale_act u_bias_scale_act(
./*input                   */clk(clk),
./*input                   */rstn(rstn),
./*input                   */is_last_layer(is_last_layer),
./*input [PARAM_BITS-1:0]  */scale(scale),
./*input [PARAM_BITS-1:0]  */bias(bias),
./*input [5:0]             */scale_shift(scale_shift),
./*input [MAC_OUT_BITS-1:0]*/accum_in(mac_kern_acc_o),
./*input                   */accum_vld_in(mac_kern_acc_vld_o),
./*output [ACT_BITS-1:0]   */accum_out(acc_o),
./*output                  */accum_vld_out(vld_o)
);

endmodule