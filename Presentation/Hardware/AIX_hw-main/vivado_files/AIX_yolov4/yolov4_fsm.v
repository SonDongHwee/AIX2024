`include "yolov4_fsm_h.v"

module yolov4_fsm(
    input               rstn,
    input [3:0]         state,
    output reg [3:0]    nstate
);


always@(*) begin
    if(~rstn) begin
        nstate <= `IDLE;
    end
    else begin
        case(state)
            `IDLE: begin
                nstate = `RECEIVE_SCALE;
            end
            `RECEIVE_SCALE: begin
                nstate = `RECEIVE_WEIGHT;
            end
            `RECEIVE_WEIGHT: begin
                nstate = `RECEIVE_BIAS;
            end
            `RECEIVE_BIAS: begin
                nstate = `CONV_STATE;
            end
            `CONV_STATE: begin
                nstate = `MAX_POOL_STATE;
            end
            `MAX_POOL_STATE: begin
                nstate = `UPSAMPLE_STATE;
            end
            `UPSAMPLE_STATE: begin
                nstate = `ROUTE_STATE;
            end
            `ROUTE_STATE: begin
                nstate = `IDLE;
            end
        endcase
    end
end

endmodule