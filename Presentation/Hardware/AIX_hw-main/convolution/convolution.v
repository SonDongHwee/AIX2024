

module convolution #(
    localparam BIT_TRANS = 18,
    localparam AXI_WIDTH_AD = 32,
    localparam AXI_WIDTH_DA = 32,

    localparam PARAM_BITS    = 16,
    localparam WEIGHT_BITS   = 8,
    localparam ACT_BITS      = 8,
    localparam MAC_OUT_BITS  = 24,               //! mac output 24 bit
    localparam N_DELAY       = 4

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
    // bias 시작 위치
    // weight 시작 위치
    // input feature 시작 위치
    // output feature 저장 시작 위치
    input [PARAM_BITS-1:0]                  scale,
    input [5:0]                             scale_shift,
    input [8:0]                             ifm_w,
    input [8:0]                             in_ch,
    input [8:0]                             out_ch,
    input                                   is_conv3x3,
    //----------------------------------------------------
    //---------feature bram ports-------------------------
    // reading bram
    input [R_DATA_W-1:0]                    r_data,
    output reg [MAX_IFM_DEPTH-1:0]          r_addr,
    // writing bram
    output reg [MAX_IFM_LINE_DEPTH-1:0]     w_addr,
    output reg [W_DATA_W-1:0]               w_data,
    output reg                              w_en,
    //----------------------------------------------------
    //---------dma axi signals----------------------------
    input [AXI_WIDTH_DA-1:0]                data_o,
    input                                   data_vld_o,
    input                                   data_cnt_o,
    output reg                              start_dma,
    output reg [BITS_TRANS-1:0]             num_trans,
    output reg [AXI_WIDTH_AD-1:0]           start_addr,
    //----------------------------------------------------
    output reg                              ap_done
);

//-------------------------------------------------
// Component: Control signals
//-------------------------------------------------
reg bias_read_done; //BIAS_READ state 종료
reg first_weight_read_done; //FIRST_WEIGTH_READ state 종료
reg conv_done; //IN_PROCESSING state 종료 (convonlutioon layer 종료)

//-------------------------------------------------
// FSM: convolution FSM
//-------------------------------------------------

//-------------- hoseung --------------------------
//-------------- TODO -----------------------------
reg [1:0]   state;
localparam IDLE = 0;
localparam BIAS_READ = 1;
localparam FIRST_WEIGHT_READ = 2;
localparam IN_PROCESSING = 3;

always @(posedge clk or negedge rstn) begin
    if(~rstn) begin
        state <= IDLE;
    end
    else begin
        case (state)
            IDLE: begin
                if(ap_start) state <= BIAS_READ;
            end
            BIAS_READ: begin
                if(bias_read_done) state <= IN_PROCESSING;
            end
            FIRST_WEIGHT_READ: begin
                
            end
            IN_PROCESSING: begin
                if(conv_done) state <= IDLE;
            end
        endcase
    end
end



//-------------------------------------------------
// Component: CONV KERN
//-------------------------------------------------
conv_kern u_conv_kern(
./*input                   */clk(clk),
./*input                   */rstn(rstn),
./*input [7:0]             */in_ch(in_ch), // 최대 256
./*input [7:0]             */in_row(in_row), // 최대 256
./*input                   */is_conv3x3(is_conv3x3),
./*input                   */vld_i(vld_i),
./*input [MAC_NUM*N*WI-1:0]*/win(win),
./*input [MAC_NUM*N*WI-1:0]*/din(din),
./*input                   */is_last_layer(is_last_layer),
./*input [PARAM_BITS-1:0]  */scale(scale),
./*input [PARAM_BITS-1:0]  */bias(bias),
./*input [5:0]             */scale_shift(scale_shift),
./*output                  */change_bias(change_bias),
./*output [ACT_BITS-1:0]   */acc_o(acc_o),
./*output                  */vld_o(vld_o)
);



//-------------------------------------------------
// Component: Bias read 
//-------------------------------------------------

//-------------------------------------------------
// Component: Input Module
//-------------------------------------------------

//-------------------------------------------------
// Component: Weight Module
//-------------------------------------------------

//-------------------------------------------------
// Component: Output Module
//-------------------------------------------------


endmodule