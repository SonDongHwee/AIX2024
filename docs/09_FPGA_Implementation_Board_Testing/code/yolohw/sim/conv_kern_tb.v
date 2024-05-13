`timescale 1ns / 1ns

module conv_kern_tb;
`include "../src/define.v"

// Clock
parameter CLK_PERIOD = 10;   //100MHz
reg clk;
reg rstn;

// MACs, Conv kernels
reg         ctrl_data_run;
reg         vld_i;
reg [127:0] win[0:3];
reg [127:0] din;
wire[ 19:0] acc_o[0:3];
wire        vld_o[0:3];

initial begin
   clk = 1'b1;
   forever #(CLK_PERIOD/2) clk = ~clk;
end
//--------------------------------------------------------------------
// Load input feature maps and parameters
//--------------------------------------------------------------------
reg  [IFM_WORD_SIZE_32-1:0] in_img[0:IFM_DATA_SIZE_32-1];  // Infmap
reg  [IFM_WORD_SIZE_32-1:0] filter[0:WGT_DATA_SIZE   -1];	// Filter
reg  preload;


// Load memory from file
integer i;	
initial begin: PROC_SimmemLoad
	
	// Inputs
	for (i = 0; i< IFM_DATA_SIZE_32; i=i+1) begin
		in_img[i] = 0;
	end
	$display ("Loading input feature maps from file: %s", IFM_FILE_32);
	$readmemh(IFM_FILE_32, in_img);
	
	// Filters
	for (i = 0; i< WGT_DATA_SIZE; i=i+1) begin
		filter[i] = 0;
	end
	$display ("Loading input feature maps from file: %s", WGT_FILE);
	$readmemh(WGT_FILE, filter);	
end

//--------------------------------------------------------------------
// Test vector
//--------------------------------------------------------------------
integer j;
integer row, col;
initial begin
	// Initialization
   rstn = 1'b0;         // Reset, low active   
   preload = 1'b0;
   ctrl_data_run  = 1'b0;	
   row = 0; col = 0;
	// Reset and check preloaded filters
   #(4*CLK_PERIOD) rstn = 1'b1; 
   #(100*CLK_PERIOD) 
        @(posedge clk)
            preload = 1'b1;
	// Show the filter			
   #(100*CLK_PERIOD) 
        @(posedge clk)
		for (j=0; j < No; j=j+1) begin
			$display("Filter och=%02d: \n",j);
			for(i = 0; i < 3; i = i + 1) begin
				$display("%d\t%d\t%d",
					$signed(filter[(j*Fx*Fy*Ni) + (3*i  )][7:0]),
					$signed(filter[(j*Fx*Fy*Ni) + (3*i+1)][7:0]),
					$signed(filter[(j*Fx*Fy*Ni) + (3*i+2)][7:0]));
			end
			$display("\n");						
		end
		
   #(100*CLK_PERIOD) 
        @(posedge clk)
            preload = 1'b0;		
			
	// *****************************************			
	// Loop for convolutions
	// *****************************************		
	//{{{
   #(100*CLK_PERIOD) 
        for(row = 0; row < IFM_HEIGHT; row = row + 1)	begin 
			@(posedge clk)
				ctrl_data_run  = 0;
			#(100*CLK_PERIOD) @(posedge clk);
				ctrl_data_run  = 1;	
			for (col = 0; col < IFM_WIDTH; col = col + 1) begin 				
				@(posedge clk) begin 
					if(col == IFM_WIDTH-1)
						ctrl_data_run = 0;
				end 				
			end 
		end
	@(posedge clk)
            ctrl_data_run = 1'b0;			
	//}}}
   #(100*CLK_PERIOD) 
         @(posedge clk) $stop;		
end

// Generate din, win
wire is_first_row = (row == 0) ? 1'b1: 1'b0;
wire is_last_row  = (row == IFM_HEIGHT-1) ? 1'b1: 1'b0;
wire is_first_col = (col == 0) ? 1'b1: 1'b0;
wire is_last_col  = (col == IFM_WIDTH-1) ? 1'b1 : 1'b0;

always@(*) begin
	vld_i = 0;
    din = 128'd0;
    win[0] = 0;
	win[1] = 0;
	win[2] = 0;
	win[3] = 0;
    if(ctrl_data_run) begin
		vld_i = 1;
		// Tiled IFM data
        din[ 7: 0] = (is_first_row || is_first_col) ? 8'd0 : in_img[(row-1) * IFM_WIDTH + (col-1)];
        din[15: 8] = (is_first_row                ) ? 8'd0 : in_img[(row-1) * IFM_WIDTH +  col   ];
        din[23:16] = (is_first_row || is_last_col ) ? 8'd0 : in_img[(row-1) * IFM_WIDTH + (col+1)];
        din[31:24] = (                is_first_col) ? 8'd0 : in_img[ row    * IFM_WIDTH + (col-1)];
        din[39:32] =                                         in_img[ row    * IFM_WIDTH +  col   ];
        din[47:40] = (                is_last_col ) ? 8'd0 : in_img[ row    * IFM_WIDTH + (col+1)];
        din[55:48] = (is_last_row ||  is_first_col) ? 8'd0 : in_img[(row+1) * IFM_WIDTH + (col-1)];
        din[63:56] = (is_last_row                 ) ? 8'd0 : in_img[(row+1) * IFM_WIDTH +  col   ];
        din[71:64] = (is_last_row ||  is_last_col ) ? 8'd0 : in_img[(row+1) * IFM_WIDTH + (col+1)];
		// Tiled Filters
		for(j = 0; j < 4; j=j+1) begin 	// Four sets <=> Four output channels
			win[j][ 7: 0] = filter[(j*Fx*Fy*Ni)    ][7:0];
			win[j][15: 8] = filter[(j*Fx*Fy*Ni) + 1][7:0];
			win[j][23:16] = filter[(j*Fx*Fy*Ni) + 2][7:0];
			win[j][31:24] = filter[(j*Fx*Fy*Ni) + 3][7:0];
			win[j][39:32] = filter[(j*Fx*Fy*Ni) + 4][7:0];
			win[j][47:40] = filter[(j*Fx*Fy*Ni) + 5][7:0];
			win[j][55:48] = filter[(j*Fx*Fy*Ni) + 6][7:0];
			win[j][63:56] = filter[(j*Fx*Fy*Ni) + 7][7:0];
			win[j][71:64] = filter[(j*Fx*Fy*Ni) + 8][7:0];			
		end 
    end    
end 
//-------------------------------------------
// DUT: MACs
//-------------------------------------------
mac u_mac_00(
./*input 		 */clk	(clk	 ), 
./*input 		 */rstn	(rstn	 ), 
./*input 		 */vld_i(vld_i	 ), 
./*input [127:0] */win	(win[0]	 ), 
./*input [127:0] */din	(din	 ),
./*output[ 19:0] */acc_o(acc_o[0]), 
./*output        */vld_o(vld_o[0])
);
mac u_mac_01(
./*input 		 */clk	(clk	 ), 
./*input 		 */rstn	(rstn	 ), 
./*input 		 */vld_i(vld_i	 ), 
./*input [127:0] */win	(win[1]	 ), 
./*input [127:0] */din	(din	 ),
./*output[ 19:0] */acc_o(acc_o[1]), 
./*output        */vld_o(vld_o[1])
);
mac u_mac_02(
./*input 		 */clk	(clk     ), 
./*input 		 */rstn	(rstn    ), 
./*input 		 */vld_i(vld_i   ), 
./*input [127:0] */win	(win[2]  ), 
./*input [127:0] */din	(din     ),
./*output[ 19:0] */acc_o(acc_o[2]), 
./*output        */vld_o(vld_o[2])
);
mac u_mac_03(
./*input 		 */clk	(clk     ), 
./*input 		 */rstn (rstn    ), 
./*input 		 */vld_i(vld_i   ), 
./*input [127:0] */win  (win[3]  ), 
./*input [127:0] */din  (din     ),
./*output[ 19:0] */acc_o(acc_o[3]), 
./*output        */vld_o(vld_o[3])
);

//--------------------------------------------------------------------
// For debugging: INPUTs/Outputs
//--------------------------------------------------------------------
// Output feature maps
//{{{
wire [7:0] conv_out_ch00 = acc_o[0][19:12];	// Descaling: * 1/2^11	
wire [7:0] conv_out_ch01 = acc_o[1][19:12]; // Descaling: * 1/2^11	
wire [7:0] conv_out_ch02 = acc_o[2][19:12]; // Descaling: * 1/2^11	
wire [7:0] conv_out_ch03 = acc_o[3][19:12]; // Descaling: * 1/2^11	

bmp_image_writer #(.OUTFILE(CONV_OUTPUT_IMG00),.WIDTH(IFM_WIDTH),.HEIGHT(IFM_HEIGHT))
u_acc_img_ch0(
	./*input 			*/clk		(clk		  ),
	./*input 			*/rstn		(rstn		  ),
	./*input [WI-1:0] 	*/din		(conv_out_ch00),
	./*input 			*/vld		(vld_o[0]	  ),
	./*output reg 		*/frame_done(		      )
);
bmp_image_writer #(.OUTFILE(CONV_OUTPUT_IMG01),.WIDTH(IFM_WIDTH),.HEIGHT(IFM_HEIGHT))
u_acc_img_ch1(
	./*input 			*/clk		(clk		  ),
	./*input 			*/rstn		(rstn		  ),
	./*input [WI-1:0] 	*/din		(conv_out_ch01),
	./*input 			*/vld		(vld_o[0]	  ),
	./*output reg 		*/frame_done(		      )
);
bmp_image_writer #(.OUTFILE(CONV_OUTPUT_IMG02),.WIDTH(IFM_WIDTH),.HEIGHT(IFM_HEIGHT))
u_acc_img_ch2(
	./*input 			*/clk		(clk		  ),
	./*input 			*/rstn		(rstn		  ),
	./*input [WI-1:0] 	*/din		(conv_out_ch02),
	./*input 			*/vld		(vld_o[0]	  ),
	./*output reg 		*/frame_done(		      )
);
bmp_image_writer #(.OUTFILE(CONV_OUTPUT_IMG03),.WIDTH(IFM_WIDTH),.HEIGHT(IFM_HEIGHT))
u_acc_img_ch3(
	./*input 			*/clk		(clk		  ),
	./*input 			*/rstn		(rstn		  ),
	./*input [WI-1:0] 	*/din		(conv_out_ch03),
	./*input 			*/vld		(vld_o[0]	  ),
	./*output reg 		*/frame_done(		      )
);	
//}}}	
//**********************************************************************
//{{{
reg 		dbg_write_image;
reg 		dbg_write_image_done;
reg [31:0]	dbg_pix_idx;
always @(posedge clk, negedge rstn) begin
	if(!rstn) begin
		dbg_write_image 		<= 0;
		dbg_write_image_done 	<= 0;
		dbg_pix_idx 			<= 0;
	end 
	else begin 
		if(dbg_write_image) begin 
			if(dbg_pix_idx < IFM_DATA_SIZE_32) begin 
				if(dbg_pix_idx == IFM_DATA_SIZE_32 - 1) begin 
					dbg_write_image 		<= 0;
					dbg_write_image_done 	<= 1;
					dbg_pix_idx 			<= 0;		
				end 
				else 
					dbg_pix_idx <= dbg_pix_idx + 1;
			end 
		end 
		else if(preload) begin
			dbg_write_image 		<= 1;
			dbg_write_image_done 	<= 0;
			dbg_pix_idx 			<= 0;			
		end
	end 
end
bmp_image_writer #(.OUTFILE(CONV_INPUT_IMG00),.WIDTH(IFM_WIDTH),.HEIGHT(IFM_HEIGHT))
u_ifm_img_ch0(
	./*input 			*/clk		(clk					   ),
	./*input 			*/rstn		(rstn				       ),
	./*input [WI-1:0] 	*/din		(in_img[dbg_pix_idx][7:0]  ),
	./*input 			*/vld		(dbg_write_image		   ),
	./*output reg 		*/frame_done(						   )
);
bmp_image_writer #(.OUTFILE(CONV_INPUT_IMG01),.WIDTH(IFM_WIDTH),.HEIGHT(IFM_HEIGHT))
u_ifm_img_ch1(
	./*input 			*/clk		(clk					   ),
	./*input 			*/rstn		(rstn				       ),
	./*input [WI-1:0] 	*/din		(in_img[dbg_pix_idx][15:8] ),
	./*input 			*/vld		(dbg_write_image		   ),
	./*output reg 		*/frame_done(						   )
);
bmp_image_writer #(.OUTFILE(CONV_INPUT_IMG02),.WIDTH(IFM_WIDTH),.HEIGHT(IFM_HEIGHT))
u_ifm_img_ch2(
	./*input 			*/clk		(clk					   ),
	./*input 			*/rstn		(rstn				       ),
	./*input [WI-1:0] 	*/din		(in_img[dbg_pix_idx][23:16]),
	./*input 			*/vld		(dbg_write_image		   ),
	./*output reg 		*/frame_done(						   )
);
bmp_image_writer #(.OUTFILE(CONV_INPUT_IMG03),.WIDTH(IFM_WIDTH),.HEIGHT(IFM_HEIGHT))
u_ifm_img_ch3(
	./*input 			*/clk		(clk					   ),
	./*input 			*/rstn		(rstn				       ),
	./*input [WI-1:0] 	*/din		(in_img[dbg_pix_idx][31:24]),
	./*input 			*/vld		(dbg_write_image		   ),
	./*output reg 		*/frame_done(						   )
);

//}}}
endmodule