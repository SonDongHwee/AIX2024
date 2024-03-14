module bias_loader #(
    parameter BIAS_BITS = 16,
    parameter MAX_KERNEL_NUM = $clog2(256),
    parameter BITS_TRANS = 18,
    parameter AXI_WIDTH_AD   = 32,
	parameter AXI_WIDTH_DA   = 32,
    parameter WL_ADDR    = 32'd8,
    parameter WL_DATA    = 32'd32,
    parameter SRAM_WIDTH = BIAS_BITS*2,
    parameter SRAM_MAX_DEPTH = 256,
    parameter SRAM_ADDRESS = $clog2(SRAM_MAX_DEPTH),
    parameter DELAY_NUM = 1
)(
    input                                       clk,
    input                                       rstn,

    //Loading
    input                                       ap_start,
    input       [8:0]                           och,
    input       [AXI_WIDTH_AD-1:0]              bias_start_addr,
    output reg                                  write_done, //?ïú layer?ùò bias ?†ÑÎ∂? SRAM ???û• ?Åù

    //Sending
    input                                       bias_request, 
    output      [BIAS_BITS-1:0]                 bias_o, //send bias
    output                                      bias_vld_o, //send bias valid

    //DMA function ports
    output reg                                  start_dma,
    output reg  [BITS_TRANS-1:0]                dma_num_trans,  //Î∞õÎäî Í∞úÏàò 32bit Í∏∞Ï?
    output reg  [AXI_WIDTH_AD-1:0]              dma_start_addr, //start address ?ïú address ?óê 32bit
    input       [AXI_WIDTH_DA-1:0]              dma_din,
    input                                       dma_din_vld,
    input       [BITS_TRANS-1:0]                dma_data_cnt, //?ãú?ûë?ù¥ 0
    input                                       dma_done
);
  
    //////////////////internal ports/////////////////////
    //Loading
    reg [BITS_TRANS-1:0]                        bias_in_cnt; //?ïú layer ?Ç¥?óê?Ñú Î™áÎ≤àÏß? kernel
    reg [BITS_TRANS-1:0]                        bias_out_cnt;
    reg                                         load_done;  //?ïú layer load ?ã§ ?Åù?Ç®

    //SRAM
    reg [WL_ADDR-1:0]                           sram_addr;
    reg [WL_DATA-1:0]                           sram_din;
    wire [WL_DATA-1:0]                          sram_dout;
    reg                                         sram_we;

    reg [DELAY_NUM:0]                           bias_vld_d;

    assign bias_o = (bias_out_cnt[0]) ? sram_dout[0+:BIAS_BITS] : sram_dout[BIAS_BITS+:BIAS_BITS];
    assign bias_vld_o = bias_vld_d[DELAY_NUM];

    //FSM
    reg [1:0] state;
    localparam IDLE = 0;
    localparam REQ_DMA = 1;
    localparam WRITING = 2;
    localparam SENDING = 3;

    always @(posedge clk, negedge rstn) begin
        if(~rstn) begin
            state <= IDLE;
            write_done <= 0;
        end
        else begin
            case(state)
                IDLE: begin
                    if(ap_start) state <= REQ_DMA;
                end
                REQ_DMA: begin
                    state <= WRITING;
                end
                WRITING: begin
                    if(dma_done) begin
                        state <= SENDING;
                        write_done <= 1;
                    end
                end
                SENDING: begin
                    write_done <= 0;
                    if(bias_out_cnt == och && bias_vld_d[DELAY_NUM] == 1) begin
                        state <= IDLE;
                    end
                end
            endcase
        end
    end

    //DMA(loading)
    always @(posedge clk, negedge rstn) begin
        if(~rstn) begin
            load_done       <= 0;
            start_dma       <= 0;
            dma_num_trans   <= 0;
            dma_start_addr  <= 0;
            bias_in_cnt     <= 0;
            bias_out_cnt    <= 0;
            bias_vld_d      <= 0;
            sram_din        <= 0;
            sram_we         <= 0;
            sram_addr       <= 0;
        end
        else begin
            case (state)
                IDLE: begin
                    load_done       <= 0;
                    start_dma       <= 0;
                    dma_num_trans   <= 0;
                    dma_start_addr  <= 0;
                    bias_in_cnt     <= 0;
                    bias_out_cnt    <= 0;
                    bias_vld_d      <= 0;
                    sram_din        <= 0;
                    sram_we         <= 0;
                    sram_addr       <= 0;
                end
                REQ_DMA: begin
                    start_dma   <= 1;
                    dma_num_trans   <= (och + 1) >> 1; // ???àò?ù∏ Í≤ΩÏö∞Î•? ?úÑ?ï¥ 1 ?çî?ïòÍ∏?
                    dma_start_addr  <= bias_start_addr;
                end
                WRITING: begin
                    start_dma   <= 0;
                    if (dma_din_vld) begin
                        sram_we     <= 1;
                        sram_din    <= dma_din;
                        sram_addr   <= dma_data_cnt;
                    end
                    else begin
                        sram_we     <= 0;
                    end
                end
                SENDING: begin
                    sram_we <= 0;
                    if(bias_request) begin
                        sram_addr <= bias_out_cnt >> 1;
                        bias_out_cnt <= bias_out_cnt + 1;
                        bias_vld_d <= {bias_vld_d[DELAY_NUM-1:0], 1'b1};
                    end
                    else begin
                        bias_vld_d <= {bias_vld_d[DELAY_NUM-1:0], 1'b0};
                    end
                end
            endcase
        end
    end


    //-------------------------------------------------
    // Component: bias ram
    //-------------------------------------------------
    bias_bram_32x256 bias_sram(
        ./*input                */clka(clk),
        ./*input [WL_ADDR-1:0]  */addra(sram_addr),
        ./*input [WL_DATA-1:0]  */dina(sram_din),
        ./*output [WL_DATA-1:0] */douta(sram_dout),
        ./*input                */wea(sram_we)
    );
endmodule