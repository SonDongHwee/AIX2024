module mac #(
    parameter WI = 8,
    parameter N = 16, //number of mul calculated at once
    parameter WN = $clog2(N)+4,
    parameter WO = 2*WI + WN
)(
    input clk,
    input rstn,
    input vld_i,
    input [N*WI-1:0] win,
    input [N*WI-1:0] din,
    output [WO+1:0] acc_o,
    output vld_o
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

    genvar k;
    generate
        for(k=0; k<N; k=k+1)begin
            dsp_macro_0 u_mul_01(.CLK(clk),.A({{10{weight[WI*(k+1)-1]}},weight[ k*WI+:WI]}),.B({{10{activation[(k+1)*WI-1]}},activation[ k*WI+:WI]}),.C(48'b0),.P(y0[k]));
        end
    endgenerate 

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