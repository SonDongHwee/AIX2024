module conv_control_unit #(
    localparam BIAS_BITS = 16
)(
    input                       clk,
    input                       rstn,
    input                       ap_start,

    output reg                  bias_load_start,
    input                       bias_load_done,
    output                      bias_request,
    input [BIAS_BITS-1:0]       bias_o,
    input                       bias_vld_o,
    output reg [BIAS_BITS-1:0]  input_bias,
    output                      dma_bias,

    output                      calc_start,
    input                       calc_done,
    input                       channel_finished,
    input [8:0]                 out_ch
);
//----------------------------------------------------------------------------------------------------------------------------
// Internal wires and registors
//----------------------------------------------------------------------------------------------------------------------------
reg fetching_bias; //when fetching bias
reg calculating; //when conv_kern is working
reg [8:0] current_och; //current calculating channel

//----------------------------------------------------------------------------------------------------------------------------
// FSM
//----------------------------------------------------------------------------------------------------------------------------
reg [1:0] state;
localparam IDLE = 0;
localparam BIAS_LOAD = 1;
localparam BIAS_FETCH = 1;
localparam IN_PROCESSING = 3;

//state transition
always @(posedge clk or negedge rstn) begin
    if(!rstn) begin
        state <= IDLE;
    end
    else begin
        case (state)
            IDLE: begin
                if(ap_start) state <= BIAS_READ;
            end
            BIAS_LOAD: begin
                if(bias_load_done) state <= BIAS_FETCH;
            end
            BIAS_FETCH: begin
                if(bias_o) state <= IN_PROCESSING;
            end
            IN_PROCESSING: begin
                if(channel_finished)begin
                    if(current_och < out_ch) state <= BIAS_FETCH;
                    else state <= IDLE;
                end
            end
        endcase
    end
end


//----------------------------------------------------------------------------------------------------------------------------
// control signal
//----------------------------------------------------------------------------------------------------------------------------
always @(posedge clk or negedge rstn) begin
    if(!rstn) begin
        fetching_bias <= 1'b0;
        bias_request <= 1'b0;
        bias_load_start <= 1'b0;
        input_bias <= 0;
        current_och <= 0;
        calculating <= 1'b0;
        dma_bias <= 1'b0;
    end
    else begin
        case (state)
            IDLE: begin
                fetching_bias <= 1'b0;
                bias_request <= 1'b0;
                bias_load_start <= 1'b0;
                input_bias <= 0;
                current_och <= 0;
                calculating <= 1'b0;
                dma_bias <= 1'b0;
            end
            BIAS_LOAD: begin
                if(bias_load_done)begin
                    bias_load_start <= 1'b0;
                    dma_bias <= 1'b0;
                end
                else begin
                    dma_bias <= 1'b1;
                    bias_load_start <= 1'b1;
                end
            end
            BIAS_FETCH: begin
                if(!fetching_bias)begin
                    bias_request <= 1'b1;
                    fetching_bias <= 1'b1;
                end
                else begin
                    bias_request <= 1'b0;
                    if(bias_vld_o)begin
                        fetching_bias <= 1'b0;
                        input_bias <= bias_o;
                    end
                end
            end
            IN_PROCESSING: begin
                if(!calculating)begin
                    calc_start <= 1'b1;
                    calculating <= 1'b1;
                end
                else begin
                    calc_start <= 1'b0;
                    if(channel_finished)begin
                        calculating <= 1'b0;
                        current_och <= current_och + 1;
                    end
                end
            end
        endcase
    end
end
endmodule