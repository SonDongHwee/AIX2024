module AIX_yolov4#(

)(

);
reg [3:0]   state, nstate;
//-------------------------------------------------
// state machine
//-------------------------------------------------
always@(posedge clk or negedge rstn) begin
    if(~rstn) begin
        state <= IDLE;
    end
    else begin
        state <= nstate;
    end
end
yolov4_fsm u_yolov4_fsm(
    .clk(clk),
    .rstn(rstn),
    .state(state),
    .nstate(nstate)
);

//-------------------------------------------------
// Component: conv
//-------------------------------------------------
conv_kern u_conv_kern(
    .clk(clk),
    .rstn(rstn),
    .is_last_layer(is_last_layer),
    .scale(scale),

);

//-------------------------------------------------
// Component: max pool
//-------------------------------------------------


//-------------------------------------------------
// Component: upsample
//-------------------------------------------------


//-------------------------------------------------
// Component: route
//-------------------------------------------------

//-------------------------------------------------
// Component: DMA for loading the input image
//-------------------------------------------------

//-------------------------------------------------
// buffer: weight buffer (spram)
//-------------------------------------------------
spram #(.INIT_FILE("input_data/all_conv_weights.hex"),
		.EN_LOAD_INIT_FILE(EN_LOAD_INIT_FILE),
		.W_DATA(Ti*WI),.W_WORD(W_CELL),.N_WORD(N_CELL))
u_buf_weight(
    .clk (clk            ), 
    .en  (weight_buf_en  ), 
    .addr(weight_buf_addr), 
    .din (/*unused*/     ), 
    .we  (weight_buf_we  ), 
    .dout(weight_buf_dout)  
);
//-------------------------------------------------
// buffer: bias buffer (spram)
//-------------------------------------------------
spram #(.INIT_FILE("input_data/all_conv_biases.hex"),
		.EN_LOAD_INIT_FILE(EN_LOAD_INIT_FILE),
		.W_DATA(PARAM_BITS),.W_WORD(W_CELL_PARAM),.N_WORD(N_CELL_PARAM))
u_buf_bias(
    .clk (clk                ), 
    .en  (param_buf_en       ), 
    .addr(param_buf_addr     ), 
    .din (/*unused*/         ), 
    .we  (param_buf_we       ), 
    .dout(param_buf_dout_bias)  
);
//-------------------------------------------------
// buffer: scale buffer (spram)
//-------------------------------------------------
spram #(.INIT_FILE("input_data/all_conv_scales.hex"),
		.EN_LOAD_INIT_FILE(EN_LOAD_INIT_FILE),
		.W_DATA(PARAM_BITS),.W_WORD(W_CELL_PARAM),.N_WORD(N_CELL_PARAM))
u_buf_scale(
    .clk (clk                 ), 
    .en  (param_buf_en        ), 
    .addr(param_buf_addr      ), 
    .din (/*unused*/          ), 
    .we  (param_buf_we        ), 
    .dout(param_buf_dout_scale)  
);
//-------------------------------------------------
// buffer: output buffer (dpram)
//-------------------------------------------------
dpram #(.W_DATA(To*ACT_BITS), .W_WORD(FRAME_SIZE_W),.N_WORD(FRAME_SIZE))
u_fmap_buff_01(
   .clk   (clk   ),
   .ena   ((!out_buff_sel) & vld_o[0]), 
   .wea   ((!out_buff_sel) & vld_o[0]), 
   .addra (pixel_count   ), 
   .enb   (fmap_buf_enb01),	
   .addrb (fmap_buf_addrb), 
   .dia   (acc_o         ), 
   .dob   (fmap_buf_dob01)  
);

dpram #(.W_DATA(To*ACT_BITS), .W_WORD(FRAME_SIZE_W),.N_WORD(FRAME_SIZE))
u_fmap_buff_02(
   .clk   (clk   ),
   .ena   (out_buff_sel & vld_o[0]), 
   .wea   (out_buff_sel & vld_o[0]), 
   .addra (pixel_count   ), 
   .enb   (fmap_buf_enb02),	
   .addrb (fmap_buf_addrb), 
   .dia   (acc_o         ), 
   .dob   (fmap_buf_dob02)  
);


endmodule