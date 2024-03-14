module mac #(
    parameter WI = 8,
    parameter N = 16,
    parameter WN = $clog2(N),
    parameter WO = 2*WI + WN
)(
    input clk,
    input rstn,
    input vld_i,
    input [N*WI-1:0] win,
    input [N*WI-1:0] din,
    output [WO+1:0] acc_o,
    output reg vld_o
);

    reg [WN:0] vld_d;
    wire[2*WI+1:0] y0 [0:N-1];      // 16 outputs of multipliers
    reg [2*WI+2:0] y1 [0:N/2-1];    // 8 outputs of adders (level 1)
    reg [2*WI+3:0] y2 [0:N/4-1];    // 4 outputs of adders (level 2)
    reg [2*WI+4:0] y3 [0:N/8-1];    // 2 outputs of adders (level 3)
    reg [2*WI+5:0] y4;              // 1 output of adders (level 4)
    reg [N*(WI+1)-1:0] weight;
    reg [N*(WI+1)-1:0] activation;


    integer i;
    always@(posedge clk, negedge rstn) begin
        if (~rstn) begin
            // initialize
            weight <=0;
            activation <=0;
        end
        else begin
            for (i=0; i < N; i=i+1) begin
                weight[i*WI+:WI]        <= $signed(win[i*WI+:WI]);
                activation[i*WI+:WI]    <= $signed(din[i*WI+:WI]);
            end
        end
    end
    mul u_mul_01(.w(weight[ 1*WI+:WI]),.x(activation[ 1*WI+:WI]),.y(y0[ 1]));
    mul u_mul_02(.w(weight[ 2*WI+:WI]),.x(activation[ 2*WI+:WI]),.y(y0[ 2]));
    mul u_mul_03(.w(weight[ 3*WI+:WI]),.x(activation[ 3*WI+:WI]),.y(y0[ 3]));
    mul u_mul_00(.w(weight[ 0*WI+:WI]),.x(activation[ 0*WI+:WI]),.y(y0[ 0]));
    mul u_mul_04(.w(weight[ 4*WI+:WI]),.x(activation[ 4*WI+:WI]),.y(y0[ 4]));
    mul u_mul_05(.w(weight[ 5*WI+:WI]),.x(activation[ 5*WI+:WI]),.y(y0[ 5]));
    mul u_mul_06(.w(weight[ 6*WI+:WI]),.x(activation[ 6*WI+:WI]),.y(y0[ 6]));
    mul u_mul_07(.w(weight[ 7*WI+:WI]),.x(activation[ 7*WI+:WI]),.y(y0[ 7]));
    mul u_mul_08(.w(weight[ 8*WI+:WI]),.x(activation[ 8*WI+:WI]),.y(y0[ 8]));
    mul u_mul_09(.w(weight[ 9*WI+:WI]),.x(activation[ 9*WI+:WI]),.y(y0[ 9]));
    mul u_mul_10(.w(weight[10*WI+:WI]),.x(activation[10*WI+:WI]),.y(y0[10]));
    mul u_mul_11(.w(weight[11*WI+:WI]),.x(activation[11*WI+:WI]),.y(y0[11]));
    mul u_mul_12(.w(weight[12*WI+:WI]),.x(activation[12*WI+:WI]),.y(y0[12]));
    mul u_mul_13(.w(weight[13*WI+:WI]),.x(activation[13*WI+:WI]),.y(y0[13]));
    mul u_mul_14(.w(weight[14*WI+:WI]),.x(activation[14*WI+:WI]),.y(y0[14]));
    mul u_mul_15(.w(weight[15*WI+:WI]),.x(activation[15*WI+:WI]),.y(y0[15]));

    //--------------------------------
    // Adder tree
    //--------------------------------
    always@(posedge clk, negedge rstn) begin
        if(~rstn) begin
            // initialize level 1, 2, 3, 4
            for (i=0; i < N/2; i=i+1) y1[i] <=0;
            for (i=0; i < N/4; i=i+1) y2[i] <=0;
            for (i=0; i < N/8; i=i+1) y3[i] <=0;
            y4 <=0;
        end
        else begin
            // level 1
            for (i=0; i < N/2; i=i+1) y1[i] <= $signed(y0[2*i]) + $signed(y0[2*i+1]);
            // level 2
            for (i=0; i < N/4; i=i+1) y2[i] <= $signed(y1[2*i]) + $signed(y1[2*i+1]);
            // level 3
            for (i=0; i < N/8; i=i+1) y3[i] <= $signed(y2[2*i]) + $signed(y2[2*i+1]);
            // level 4
            y4 <= $signed(y3[0]) + $signed(y3[1]);
        end
    end

    //--------------------------------
    // Output and Delay signals
    //--------------------------------
    always@(posedge clk, negedge rstn) begin
        if(~rstn) begin
            vld_d <= 0;
        end
        else begin
            vld_d <= {vld_d[WN-1:0], vld_i};
        end
    end

    assign vld_o = vld_d[WN];
    assign acc_o = $signed(y4);
endmodule