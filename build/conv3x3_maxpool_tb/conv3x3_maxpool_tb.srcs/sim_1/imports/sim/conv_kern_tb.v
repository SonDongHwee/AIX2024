`timescale 1ns / 1ns

module conv_kern_tb;
// `include "../src/define.v"
`include "../../../sources_1/imports/src/define.v"

// Clock
parameter CLK_PERIOD = 10;   //100MHz
reg clk;
reg rstn;
initial begin
   clk = 1'b1;
   forever #(CLK_PERIOD/2) clk = ~clk;
end

// MACs, Conv kernels
reg  ctrl_data_run;
reg  vld_i;
reg  [127:0] 	  win [0:(Tr*Tc-1)];
reg  [127:0] 	  din [0:(Tr*Tc-1)];
// wire 			vld_o [0:(Tr*Tc-1)];

// Preloaded data
reg  preload;
reg  [IFM_WORD_SIZE-1:0] 	in_img [0:IFM_DATA_SIZE-1];  // Infmap
reg  [WGT_WORD_SIZE-1:0] 	filter [0:WGT_DATA_SIZE-1];	 // Filter
reg	 [BIAS_WORD_SIZE-1:0] 	  bias [0:BIAS_DATA_SIZE-1];  // Bias


//--------------------------------------------------------------------
// Test vector
//--------------------------------------------------------------------
integer i;
reg [31:0] delay;
reg [ 3:0] COMMAND;
reg [31:0] RECEIVE_SIZE;
reg		   conv3x3_start;
initial begin
	// Initialization
    rstn = 1'b0;         // Reset, low active
	COMMAND = 1'b0;
    preload = 1'b0;
    ctrl_data_run  = 1'b0;
	RECEIVE_SIZE = 1'b0;
	delay = 1'b0;
	vld_i = 1'b0;
	conv3x3_start = 1'b0;

	// Load memory from file
	repeat(100) 
        @(posedge clk);
    preload = 1'b1;
	// Inputs
	for (i = 0; i < IFM_DATA_SIZE; i=i+1) begin
		in_img[i] = 0;
	end
	$display ("Loading input feature maps from file: %s", IFM_FILE);
	$readmemh(IFM_FILE, in_img);

	repeat(100) 
        @(posedge clk);
	
	// Filters
	for (i = 0; i < WGT_DATA_SIZE; i=i+1) begin
		filter[i] = 0;
	end
	$display ("Loading weights from file: %s", WGT_FILE);
	$readmemh(WGT_FILE, filter);

	repeat(100) 
        @(posedge clk);

	// Biases
	for (i = 0; i < BIAS_DATA_SIZE; i=i+1) begin
		bias[i] = 0;
	end
	$display ("Loading biases from file: %s", BIAS_FILE);
	$readmemh(BIAS_FILE, bias);

	$display ("Preload data done.\n");

	repeat(100) 
        @(posedge clk);
    preload = 1'b0;	

	// Start test vector
	repeat(4)
		@(posedge clk);
    rstn = 1'b1;
	repeat(4)
		@(posedge clk);
	
	vld_i = 1'b1;
	tick = 1'b0;
	COMMAND = 4'b0001;
	RECEIVE_SIZE = IFM_DATA_SIZE;
	conv3x3_start = 1'b1;

	repeat(100)
		@(posedge clk);
	
	$display ("Conv module starts to read feature");
	wait(F_writedone);
	$display("Conv module finishes reading feature\n");

	repeat(100)
		@(posedge clk);

	tick = 1'b0;
	COMMAND = 4'b0010;
	RECEIVE_SIZE = WGT_DATA_SIZE;

	repeat(100)
		@(posedge clk);

	$display ("Conv module starts to read weight");
	wait(W_writedone);
	$display("Conv module finishes reading weight\n");
	
	repeat(100)
		@(posedge clk);
	
	tick = 1'b0;
	COMMAND = 4'b0100;
	RECEIVE_SIZE = BIAS_DATA_SIZE;

	repeat(100)
		@(posedge clk);

	$display ("Conv module starts to read bias");
	wait(B_writedone);
	$display("Conv module finishes reading bias\n");

	repeat(100)
		@(posedge clk);

	COMMAND = 4'b1000;

	$display ("Conv module starts to compute");
	wait(conv3x3_done);
	$display ("Conv module finishes computing\n");

	repeat(100)
		@(posedge clk);

	$display ("OFM pixels out");
	wait(pixel_out_done);
    	
	// End test vector
    #(100*CLK_PERIOD) 
        @(posedge clk) $stop;

		
end

//-------------------------------------------
// CONV3x3_MAXPOOL Module
//-------------------------------------------
wire F_writedone, W_writedone, B_writedone;
wire conv3x3_ready, conv3x3_valid;
wire [127:0] conv3x3_dout;
wire [127:0] conv3x3_dout_2;
wire conv3x3_done;
conv3x3_maxpool_module m_conv3x3_maxpool_module (
	// inputs
	.IFM_WIDTH			(IFM_WIDTH),
	.IFM_HEIGHT			(IFM_HEIGHT),
	.Tr					(Tr),
	.Tc					(Tc),
	.Ti					(Ti),
	.To					(To),
	.Ni					(Ni),
	.No					(No),
	.SCALE_FACTOR		(SCALE_FACTOR),
	.NEXT_LAYER_INPUT_M (NEXT_LAYER_INPUT_M),

	.clk				(clk),
	.rstn				(rstn),
	.is_CONV00			(is_CONV00),
	.is_1x1				(is_1x1),
	.COMMAND			(COMMAND),
	.RECEIVE_SIZE		(RECEIVE_SIZE),
	.conv_start			(conv3x3_start),
	.valid_i			(vld_i),
	.data_in			(data),

	// outputs
	.F_writedone		(F_writedone),
	.W_writedone		(W_writedone),
	.B_writedone		(B_writedone),
	.ready_o			(conv3x3_ready),
	.valid_o			(conv3x3_valid),
	.data_out			(conv3x3_dout),
	.data_out_2			(conv3x3_dout_2),
	.conv_done			(conv3x3_done)
);

//-------------------------------------------
// Data Feeding
//-------------------------------------------
reg [31:0] tick;
wire [31:0] data;
assign data = COMMAND[0] ? in_img[tick]
						 : (COMMAND[1] ? filter[tick]
						 			   : (COMMAND[2] ? bias[tick] : 1'b0));
always @ (posedge clk) begin
	if (!rstn) begin
		tick <= 32'd0;
	end else begin
		case (COMMAND)
			4'b0001: begin
				if (vld_i && conv3x3_ready)
					tick <= tick + 1;
				else
					tick <= tick;
			end
			4'b0010: begin
				if (vld_i && conv3x3_ready)
					tick <= tick + 1;
				else
					tick <= tick;
			end
			4'b0100: begin
				if (vld_i && conv3x3_ready)
					tick <= tick + 1;
				else
					tick <= tick;
			end
			default: begin
				tick <= 1'b0;
			end
		endcase
	end
end

//-------------------------------------------
// CONV result
//-------------------------------------------
// Note @ `24.04.08 17:43
// This part does not work...:<
// Need to be modified...
reg [7:0] OFM [0:IFM_HEIGHT/2*IFM_WIDTH/2*No-1]; // Output Feature Map (row x col x chan)
reg [31:0] out_counter;
reg [31:0] pixel_counter;
reg [7:0] pixel_out [0:No-1];
reg pixel_out_done;
integer iter;
always @ (posedge clk) begin
	if (!rstn) begin
		for (iter = 0; iter < IFM_HEIGHT/2*IFM_WIDTH/2*No; iter=iter+1)
			OFM[iter] = 8'd0;
		for (iter = 0; iter < No; iter=iter+1)
			pixel_out[iter] = 8'd0;
		out_counter <= 1'b0;
		pixel_counter <= 1'b0;
		pixel_out_done <= 1'b0;
	end else if (conv3x3_done) begin
		if (pixel_counter == IFM_HEIGHT/2*IFM_WIDTH/2) begin
			pixel_out_done <= 1'b1;
		end else begin
			pixel_out_done <= 1'b0;
			for (iter = 0; iter < No; iter=iter+1) begin
				pixel_out[iter] <= OFM[No*pixel_counter+iter];
			end
			pixel_counter <= pixel_counter + 1;
		end
	end else begin
		if (conv3x3_start) begin
			if (conv3x3_valid) begin
				for (iter = 0; iter < 16; iter=iter+1) begin
					OFM[16*out_counter + iter] = conv3x3_dout[8*iter+:8];
				end
				out_counter <= out_counter + 1;
			end
		end else begin
			vld_i <= 1'b0;
		end
	end
end


//--------------------------------------------------------------------
// For debugging: INPUTs/Outputs
//--------------------------------------------------------------------
// Output feature maps
// bmp_image_writer #(.OUTFILE(CONV_OUTPUT_IMG00),.WIDTH(IFM_WIDTH),.HEIGHT(IFM_HEIGHT))
// u_acc_img_ch0(
// 	./*input 			*/clk		(clk		  ),
// 	./*input 			*/rstn		(rstn		  ),
// 	./*input [WI-1:0] 	*/din		(conv_out_ch00),
// 	./*input 			*/vld		(vld_o[0]	  ),
// 	./*output reg 		*/frame_done(		      )
// );
// bmp_image_writer #(.OUTFILE(CONV_OUTPUT_IMG01),.WIDTH(IFM_WIDTH),.HEIGHT(IFM_HEIGHT))
// u_acc_img_ch1(
// 	./*input 			*/clk		(clk		  ),
// 	./*input 			*/rstn		(rstn		  ),
// 	./*input [WI-1:0] 	*/din		(conv_out_ch01),
// 	./*input 			*/vld		(vld_o[0]	  ),
// 	./*output reg 		*/frame_done(		      )
// );
// bmp_image_writer #(.OUTFILE(CONV_OUTPUT_IMG02),.WIDTH(IFM_WIDTH),.HEIGHT(IFM_HEIGHT))
// u_acc_img_ch2(
// 	./*input 			*/clk		(clk		  ),
// 	./*input 			*/rstn		(rstn		  ),
// 	./*input [WI-1:0] 	*/din		(conv_out_ch02),
// 	./*input 			*/vld		(vld_o[0]	  ),
// 	./*output reg 		*/frame_done(		      )
// );
// bmp_image_writer #(.OUTFILE(CONV_OUTPUT_IMG03),.WIDTH(IFM_WIDTH),.HEIGHT(IFM_HEIGHT))
// u_acc_img_ch3(
// 	./*input 			*/clk		(clk		  ),
// 	./*input 			*/rstn		(rstn		  ),
// 	./*input [WI-1:0] 	*/din		(conv_out_ch03),
// 	./*input 			*/vld		(vld_o[0]	  ),
// 	./*output reg 		*/frame_done(		      )
// );	
	
//**********************************************************************

// reg 		dbg_write_image;
// reg 		dbg_write_image_done;
// reg [31:0]	dbg_pix_idx;
// always @(posedge clk, negedge rstn) begin
// 	if(!rstn) begin
// 		dbg_write_image 		<= 0;
// 		dbg_write_image_done 	<= 0;
// 		dbg_pix_idx 			<= 0;
// 	end 
// 	else begin 
// 		if(dbg_write_image) begin 
// 			// if(dbg_pix_idx < IFM_DATA_SIZE_32) begin 
// 			// 	if(dbg_pix_idx == IFM_DATA_SIZE_32 - 1) begin 
// 			if(dbg_pix_idx < IFM_DATA_SIZE) begin 
// 				if(dbg_pix_idx == IFM_DATA_SIZE - 1) begin 
// 					dbg_write_image 		<= 0;
// 					dbg_write_image_done 	<= 1;
// 					dbg_pix_idx 			<= 0;		
// 				end 
// 				else 
// 					dbg_pix_idx <= dbg_pix_idx + 1;
// 			end 
// 		end 
// 		else if(preload) begin
// 			dbg_write_image 		<= 1;
// 			dbg_write_image_done 	<= 0;
// 			dbg_pix_idx 			<= 0;			
// 		end
// 	end 
// end
// bmp_image_writer #(.OUTFILE(CONV_INPUT_IMG00),.WIDTH(IFM_WIDTH),.HEIGHT(IFM_HEIGHT))
// u_ifm_img_ch0(
// 	./*input 			*/clk		(clk					   ),
// 	./*input 			*/rstn		(rstn				       ),
// 	./*input [WI-1:0] 	*/din		(in_img[dbg_pix_idx][7:0]  ),
// 	./*input 			*/vld		(dbg_write_image		   ),
// 	./*output reg 		*/frame_done(						   )
// );
// bmp_image_writer #(.OUTFILE(CONV_INPUT_IMG01),.WIDTH(IFM_WIDTH),.HEIGHT(IFM_HEIGHT))
// u_ifm_img_ch1(
// 	./*input 			*/clk		(clk					   ),
// 	./*input 			*/rstn		(rstn				       ),
// 	./*input [WI-1:0] 	*/din		(in_img[dbg_pix_idx][15:8] ),
// 	./*input 			*/vld		(dbg_write_image		   ),
// 	./*output reg 		*/frame_done(						   )
// );
// bmp_image_writer #(.OUTFILE(CONV_INPUT_IMG02),.WIDTH(IFM_WIDTH),.HEIGHT(IFM_HEIGHT))
// u_ifm_img_ch2(
// 	./*input 			*/clk		(clk					   ),
// 	./*input 			*/rstn		(rstn				       ),
// 	./*input [WI-1:0] 	*/din		(in_img[dbg_pix_idx][23:16]),
// 	./*input 			*/vld		(dbg_write_image		   ),
// 	./*output reg 		*/frame_done(						   )
// );
// bmp_image_writer #(.OUTFILE(CONV_INPUT_IMG03),.WIDTH(IFM_WIDTH),.HEIGHT(IFM_HEIGHT))
// u_ifm_img_ch3(
// 	./*input 			*/clk		(clk					   ),
// 	./*input 			*/rstn		(rstn				       ),
// 	./*input [WI-1:0] 	*/din		(in_img[dbg_pix_idx][31:24]),
// 	./*input 			*/vld		(dbg_write_image		   ),
// 	./*output reg 		*/frame_done(						   )
// );


endmodule