module output_feature_module #(
    parameter WI = 8,
    parameter BRAM_DATA_WIDTH = 32,
    parameter BRAM_DATA_DEPTH = 64*64*64/4,
    parameter BRAM_ADDRESS_WIDTH = $clog2(BRAM_DATA_DEPTH),
    parameter MAX_FEATURE_SIZE = 18 //2^18
)(
    input                                       clk,
    input                                       rstn,
    input reg                                   ap_start,
    input [WI-1:0]                              conv_kern_o,
    input                                       conv_kern_vld_o,
    input [8:0]                                 ofm_w,
    input [8:0]                                 out_ch,
    output reg [BRAM_ADDRESS_WIDTH-1:0]         bram_addr,
    output reg [BRAM_DATA_WIDTH-1:0]            bram_data,
    output reg                                  bram_we,
    output reg                                  ap_done
);

reg [1:0]   state;
localparam IDLE = 0;
localparam RUNNING = 1;
localparam DONE = 2;

wire [MAX_FEATURE_SIZE-1:0] ofm_num;
assign ofm_num = ofm_w*ofm_w*out_ch;
reg [MAX_FEATURE_SIZE-1:0] ofm_cnt;
reg [1:0] ofm_buff_num;


//manage data and send
always@(posedge clk or negedge rstn)begin
    if(~rstn)begin
        state <= IDLE;
        ap_done <= 0;
        ofm_cnt <= 0;
        bram_addr <= 0;
        bram_data <= 0;
        bram_we <= 0;
        ofm_buff_num <= 0;
    end
    else begin
        case (state)
            IDLE: begin
                if(ap_start) begin
                    state <= RUNNING;
                end
                ofm_cnt <= 0;
                ap_done <= 0;
            end
            RUNNING: begin
                if(conv_kern_vld_o) begin
                    if(ofm_buff_num ==3) begin
                        bram_addr   <= (ofm_cnt >>2);
                        bram_we     <= 1;
                    end
                    else begin
                        bram_we     <= 0;
                    end
                    ofm_buff_num                    <= ofm_buff_num +1;
                    bram_data[ofm_buff_num*WI+:WI]  <= conv_kern_o;
                    ofm_cnt                         <= ofm_cnt + 1 ;
                end
                else begin
                    bram_we         <= 0;
                end
                if(ofm_cnt +1 == ofm_num) begin
                    state           <= DONE;
                end
            end
            DONE: begin
                ap_done             <= 1;
                bram_we             <= 0;
                state               <= IDLE;
            end
        endcase
    end
end

endmodule