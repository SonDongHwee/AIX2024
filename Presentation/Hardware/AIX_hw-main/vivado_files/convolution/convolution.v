module convolution #(
    localparam BIT_TRANS = 18,
    localparam AXI_WIDTH_AD = 32,
    localparam AXI_WIDTH_DA = 32,

    localparam PARAM_BITS    = 16,
    localparam WEIGHT_BITS   = 8,
    localparam ACT_BITS      = 8,
    localparam MAC_OUT_BITS  = 24,               //! mac output 24 bit
    localparam N_DELAY       = 4,

    localparam WI = 8,
    localparam WO = 8,
    localparam W_BRAM_DATA_W = 16,
    localparam R_DATA_W = WI * IFM_DATA_NUM,
    localparam W_DATA_W = WO * W_BRAM_DATA_W,
    localparam MAX_IFM_DATA = 128*128*16, //262144
    localparam MAX_IFM_DEPTH = $clog2(MAX_IFM_DATA/IFM_DATA_NUM),
    localparam MAX_IFM_LINE_DATA = 64*64, // 4096
    localparam MAX_IFM_LINE_DEPTH = $clog2(MAX_IFM_LINE_DATA/W_BRAM_DATA_W),

    localparam IFM_BITS = 8,
    localparam IFM_NUM = 16,
    localparam MAC_NUM = 9,
    localparam SRAM_NUM = 12,
    localparam SRAM_WIDTH = IFM_BITS * IFM_NUM, // 16*8 = 128
    localparam SRAM_MAX_DEPTH = 256,
    localparam SRAM_ADDRESS = $clog2(SRAM_MAX_DEPTH), //8
    localparam DOUT_WIDTH = MAC_NUM * SRAM_WIDTH, // 9 * (16 * 8)
    localparam SRAM_ROW_NUM = 5
)(
    input                                   clk,
    input                                   rstn,
    input                                   ap_start,
    //---------layer config------------------------------
    // bias ?��?�� ?���?
    // weight ?��?�� ?���?
    // input feature ?��?�� ?���?
    // output feature ???�� ?��?�� ?���?
    input [PARAM_BITS-1:0]                  scale,
    input [5:0]                             scale_shift,
    input [8:0]                             ifm_w,
    input [8:0]                             in_ch,
    input [8:0]                             out_ch,
    input                                   is_conv3x3,
    input [1:0]                             stride,
    input [8:0]                             ofm_w,
    input [AXI_WIDTH_AD-1:0]                bias_start_addr,
    input [AXI_WIDTH_AD-1:0]                weight_start_addr,
    input                                   is_last_layer,
    //----------------------------------------------------
    //---------feature bram ports-------------------------
    // reading bram
    input                                   r_data_vld,
    input [R_DATA_W-1:0]                    r_data,
    output reg [MAX_IFM_DEPTH-1:0]          r_addr,

    // writing bram
    output reg [MAX_IFM_LINE_DEPTH-1:0]     w_addr,
    output reg [W_DATA_W-1:0]               w_data,
    output reg                              w_en,
    //----------------------------------------------------
    //---------dma axi signals----------------------------
    input                                   done_o,
    input [AXI_WIDTH_DA-1:0]                data_o,
    input                                   data_vld_o,
    input                                   data_cnt_o,
    output reg                              start_dma,
    output reg [BITS_TRANS-1:0]             num_trans,
    output reg [AXI_WIDTH_AD-1:0]           start_addr,
    //----------------------------------------------------
    output reg                              ap_done
);



//----------------------------------------------------------------------------------------------------------------------------
// Component: internel wires
//----------------------------------------------------------------------------------------------------------------------------
//conv_kern related
wire [PARAM_BITS-1:0] input_bias; //bias in current  cannel
wire [WI-1:0] conv_kern_o;
reg conv_kern_vld_o;


//bias realted 
wire bias_load_start; //start reading the bias
wire bias_load_done; //loaded all bias
wire bias_request; //request one bias
wire [BIAS_BITS-1:0] bias_o; //output of the bias module
wire bias_vld_o; //valid signal of bias_o
wire calc_start;
wire channel_finished; //need to add in input feature module
wire dma_bias;

//dma connection
assign start_dma = dma_bias ? bias_start_dma : ifm_start_dma;
assign num_trans = dma_bias ? bias_dma_num_trans : ifm_dma_num_trans;
assign start_addr = dma_bias ? bias_dma_start_addr : ifm_dma_start_addr;

//data connections
wire data_vld;
wire [MAC_NUM*N*WI-1:0] win;
wire [MAC_NUM*N*WI-1:0] din;

//----------------------------------------------------------------------------------------------------------------------------
// Component: control unit
//----------------------------------------------------------------------------------------------------------------------------
conv_control_unit u_conv_control_unit(
    ./*input                       */clk(clk),
    ./*input                       */rstn(rstn),
    ./*input                       */ap_start(ap_start),
    ./*output reg                  */bias_load_start(bias_load_start),
    ./*input                       */bias_load_done(bias_load_done),
    ./*output                      */bias_request(bias_request),
    ./*input [BIAS_BITS-1:0]       */bias_o(bias_o),
    ./*input                       */bias_vld_o(bias_vld_o),
    ./*output reg [BIAS_BITS-1:0]  */input_bias(input_bias),
    ./*output                      */dma_bias(dma_bias),
    ./*output                      */calc_start(calc_start),
    ./*input                       */channel_finished(channel_finished),
    ./*input [8:0]                 */out_ch(out_ch)
);

//----------------------------------------------------------------------------------------------------------------------------
// Component: conv kern
//----------------------------------------------------------------------------------------------------------------------------
conv_kern u_conv_kern(
    ./*input                   */clk(clk),
    ./*input                   */rstn(rstn),
    ./*input [7:0]             */in_ch(in_ch), // 최�? 256
    ./*input                   */is_conv3x3(is_conv3x3),
    ./*input                   */vld_i(data_vld),
    ./*input [MAC_NUM*N*WI-1:0]*/win(win),
    ./*input [MAC_NUM*N*WI-1:0]*/din(din),
    ./*input                   */is_last_layer(is_last_layer),
    ./*input [PARAM_BITS-1:0]  */scale(scale),
    ./*input [PARAM_BITS-1:0]  */bias(input_bias),
    ./*input [5:0]             */scale_shift(scale_shift),
    ./*output [ACT_BITS-1:0]   */acc_o(conv_kern_o),
    ./*output                  */vld_o(conv_kern_vld_o)
);


//----------------------------------------------------------------------------------------------------------------------------
// Component: Bias read 
//----------------------------------------------------------------------------------------------------------------------------
bias_loader u_bias_loader(
    ./*input                                       */clk(clk),
    ./*input                                       */rstn(rstn),
    ./*input                                       */ap_start(bias_load_start),
    ./*input       [8:0]                           */och(out_ch),
    ./*input       [AXI_WIDTH_AD-1:0]              */bias_start_addr(bias_start_addr),
    ./*output reg                                  */write_done(bias_load_done), //한 layer의 bias 전부 SRAM 저장 끝
    ./*input                                       */bias_request(bias_request), 
    ./*output      [BIAS_BITS-1:0]                 */bias_o(bias_o), //send bias
    ./*output                                      */bias_vld_o(bias_vld_o), //send bias valid
    ./*output reg                                  */start_dma(bias_start_dma),
    ./*output reg  [BITS_TRANS-1:0]                */dma_num_trans(bias_dma_num_trans),  //받는 개수 32bit 기준
    ./*output reg  [AXI_WIDTH_AD-1:0]              */dma_start_addr(bias_dma_start_addr), //start address 한 address 에 32bit
    ./*input       [AXI_WIDTH_DA-1:0]              */dma_din(data_o),
    ./*input                                       */dma_din_vld(data_vld_o),
    ./*input       [BITS_TRANS-1:0]                */dma_data_cnt(data_cnt_o), //시작이 0
    ./*input                                       */dma_done(done)
);


//----------------------------------------------------------------------------------------------------------------------------
// Component: Input and weight Module
//----------------------------------------------------------------------------------------------------------------------------
input_feature_module u_input_feature_module(
    ./*input                                       */clk(clk),
    ./*input                                       */rstn(rstn),
    ./*input                                       */i_vld(r_data_vld),
    ./*input [R_DATA_W-1:0]                        */r_data(r_data),
    ./*output [MAX_IFM_DEPTH-1:0]                  */r_addr(r_addr),
    ./*input [8:0]                                 */ifm_w(ifm_w),
    ./*input [8:0]                                 */ich(in_ch),
    ./*input [1:0]                                 */stride(stride),
    ./*input                                       */is_conv3x3(is_conv3x3),
    ./*input [8:0]                                 */och(out_ch),
    ./*input [AXI_WIDTH_AD-1:0]                    */weight_start_addr(weight_start_addr),
    ./*input                                       */ap_start(calc_start),
    ./*output [DOUT_WIDTH-1:0]                     */ifm_dout(din),
    ./*output [CALC_WEIGHT_NUM*DOUT_WIDTH-1:0]     */weight_dout(win),
    ./*output                                      */o_vld(data_vld),
    ./*output reg                                  */ap_done(),
    ./*input [AXI_WIDTH_DA-1:0]                    */dma_din(data_o),
    ./*input                                       */dma_din_vld(data_vld_o),
    ./*input [BITS_TRANS-1:0]                      */dma_data_cnt(data_cnt_o),
    ./*input                                       */dma_done(done_o),
    ./*output                                      */start_dma(ifm_start_dma),
    ./*output [BITS_TRANS-1:0]                     */dma_num_trans(ifm_dma_num_trans),
    ./*output [AXI_WIDTH_AD-1:0]                   */dma_start_addr(ifm_dma_start_addr)

);


//----------------------------------------------------------------------------------------------------------------------------
// Component: Output Module
//----------------------------------------------------------------------------------------------------------------------------
output_feature_module u_output_feature_module(
    ./*input                                       */clk(clk),
    ./*input                                       */rstn(rstn),
    ./*input reg                                   */ap_start(calc_start),
    ./*input [WI-1:0]                              */conv_kern_o(conv_kern_o),
    ./*input                                       */conv_kern_vld_o(conv_kern_vld_o),
    ./*input [8:0]                                 */ofm_w(ofm_w),
    ./*input [8:0]                                 */out_ch(out_ch),
    ./*output reg [BRAM_ADDRESS_WIDTH-1:0]         */bram_addr(w_addr),
    ./*output reg [BRAM_DATA_WIDTH-1:0]            */bram_data(w_data),
    ./*output reg                                  */bram_we(w_en),
    ./*output reg                                  */ap_done(ap_done)
);

endmodule