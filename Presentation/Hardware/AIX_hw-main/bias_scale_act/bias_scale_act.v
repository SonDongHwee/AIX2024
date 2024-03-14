//! @title: bias_scale_act
//! @author CHA (chamj61047@snu.ac.kr), JUN(junsung3737@snu.ac.kr)
//! @date 2023.03.05
//! @version
//! @copyright
//! @brief
module bias_scale_act#(
    parameter PARAM_BITS    = 16,
    parameter WEIGHT_BITS   = 8,
    parameter ACT_BITS      = 8,
    parameter MAC_OUT_BITS  = 24,               //! mac output 24 bit
    parameter N_DELAY       = 4
)(
    input                   clk,
    input                   rstn,
    input                   is_last_layer,
    input [PARAM_BITS-1:0]  scale,
    input [PARAM_BITS-1:0]  bias,
    input [5:0]             scale_shift,
    input [MAC_OUT_BITS-1:0]accum_in,
    input                   accum_vld_in,
    //output
    output [ACT_BITS-1:0]   accum_out,
    output                  accum_vld_out
);
    // Internal port declarations
    reg [PARAM_BITS-1:0]                scale_r;
    reg [5:0]                           scale_shift_r;
    reg [MAC_OUT_BITS-1:0]              accum_in_r;
    reg [PARAM_BITS-1:0]                bias_r;

    reg [MAC_OUT_BITS:0]                accum_bias_added;
    reg [MAC_OUT_BITS+PARAM_BITS:0]     accum_descaled;
    
    wire [MAC_OUT_BITS+PARAM_BITS:0]    accum_shifted;
    wire [MAC_OUT_BITS+PARAM_BITS:0]    accum_relu;
    wire [MAC_OUT_BITS+PARAM_BITS:0]    accum_quant;
    
    reg [ACT_BITS-1:0]                  accum_final;
    reg [N_DELAY-1:0]                   accum_vld;

    //-----------------------------------------
    // Add Bias
    //-----------------------------------------
    always @(posedge clk or negedge rstn) begin
        if(~rstn)begin
            scale_r         <= 0;
            scale_shift_r   <= 0;
            accum_in_r      <= 0;
            bias_r          <= 0;
        end
        else begin            
            scale_r         <= scale;
            scale_shift_r   <= scale_shift;
            accum_in_r      <= accum_in;
            bias_r          <= bias;
        end
    end

    always@ (posedge clk) begin
        accum_bias_added <= $signed(accum_in_r) + $signed(bias_r);
    end

    //-----------------------------------------
    // Descaling
    //-----------------------------------------
    always@ (posedge clk) begin
        accum_descaled <= $signed(accum_bias_added) * $signed(scale_r);
    end

    //-----------------------------------------
    // Shift (using shifter)
    //-----------------------------------------
    shifter #(
        .DATA_BITS(MAC_OUT_BITS + 1 + PARAM_BITS), // 16bit 더하기, PARAM_BIT 곱하기()
        .SHIFT_W(6)
    ) u_shifter(
        .d_in(accum_descaled),
        .n_shift(scale_shift_r),
        .d_out(accum_shifted)
    );

    // LEAKY RELU
    // assign accum_relu = $signed(~accum_shifted[MAC_OUT_BITS + PARAM_BITS] ? accum_shifted : 0);
    assign accum_relu = $signed(~accum_shifted[MAC_OUT_BITS + PARAM_BITS] ? accum_shifted : $signed(accum_shifted)*0.09375 );
    assign accum_quant = (~is_last_layer) ? accum_relu: accum_shifted;

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            accum_final <= 'h0;
        end
        else begin
            accum_final <= ($signed(accum_quant) > $signed(127)) ? $signed(127): (($signed(accum_quant) < $signed(-127)) ? $signed(-127) : accum_quant[ACT_BITS-1:0]);
        end
    end
    assign accum_out = accum_final;
    
    //-------------------------------------------------
    // Delays and valid signals	
    //-------------------------------------------------  
    always @(posedge clk or negedge rstn)
    begin
        if(~rstn) accum_vld <= 'h0;
        else        accum_vld <= {accum_vld[N_DELAY-2:0], accum_vld_in};
    end 
    assign accum_vld_out = accum_vld[N_DELAY-1];


endmodule