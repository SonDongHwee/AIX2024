`timescale 1ns / 1ns

module conv_kern_tb;
// `include "../src/define.v"
`include "../../../sources_1/imports/src/define.v"

// Clock
parameter CLK_PERIOD = 10;   //100MHz
reg clk;
reg rstn;

// MACs, Conv kernels
reg         ctrl_data_run;
reg         vld_i;
reg [127:0] win[0:2]; // changed
reg [127:0] din[0:2]; // changed
wire[ 19:0] acc_o[0:2]; // changed
wire[  2:0] vld_o; // changed

initial begin
   clk = 1'b1;
   forever #(CLK_PERIOD/2) clk = ~clk;
end
//--------------------------------------------------------------------
// Load input feature maps and parameters
//--------------------------------------------------------------------
// reg  [IFM_WORD_SIZE_32-1:0] in_img[0:IFM_DATA_SIZE_32-1];  // Infmap
// reg  [IFM_WORD_SIZE_32-1:0] filter[0:WGT_DATA_SIZE   -1];	// Filter
reg  [IFM_WORD_SIZE-1:0] in_img[0:IFM_DATA_SIZE-1];  // Infmap
reg  [WGT_WORD_SIZE-1:0] filter[0:WGT_DATA_SIZE-1];	// Filter
reg  preload;


// Load memory from file
integer i;	
initial begin: PROC_SimmemLoad
	
	// Inputs
	// for (i = 0; i< IFM_DATA_SIZE_32; i=i+1) begin
	for (i = 0; i< IFM_DATA_SIZE; i=i+1) begin
		in_img[i] = 0;
	end
	// $display ("Loading input feature maps from file: %s", IFM_FILE_32);
	// $readmemh(IFM_FILE_32, in_img);
	$display ("Loading input feature maps from file: %s", IFM_FILE);
	$readmemh(IFM_FILE, in_img);
	
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
integer iter;
initial begin
	// Initialization
   rstn = 1'b0;         // Reset, low active   
   preload = 1'b0;
   ctrl_data_run  = 1'b0;	
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
        // for(row = 0; row < IFM_HEIGHT; row = row + 1)	begin
		// 	@(posedge clk)
		// 		ctrl_data_run  = 0;
   		// 	#(100*CLK_PERIOD) 			
		// 	for (col = 0; col < IFM_WIDTH; col = col + 1) begin 
		// 		@(posedge clk)
		// 			ctrl_data_run  = 1;
		// 	end 
		// end
		row = 0;
		col = 0;
		@(posedge clk)
			ctrl_data_run = 1;
		for(iter = 0; iter < IFM_HEIGHT * IFM_WIDTH; iter = iter + 1)	begin		
			@(posedge clk) begin
				if (col == IFM_WIDTH-1) begin
					row = row + 1;
					col = 0;
				end else begin
					col = col + 1;
				end
			end
		end
		ctrl_data_run = 0;
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

integer fil_num;
initial begin
	fil_num = 0;
end

always@(*) begin
	vld_i = 0;
    din[0] = 128'd0;
	din[1] = 128'd0;
	din[2] = 128'd0;

    win[0] = 0;
	win[1] = 0;
	win[2] = 0;

    if(ctrl_data_run) begin
		vld_i = 1;
		// Tiled IFM data
        // din[ 7: 0] = (is_first_row || is_first_col) ? 8'd0 : in_img[(row-1) * IFM_WIDTH + (col-1)];
        // din[15: 8] = (is_first_row                ) ? 8'd0 : in_img[(row-1) * IFM_WIDTH +  col   ];
        // din[23:16] = (is_first_row || is_last_col ) ? 8'd0 : in_img[(row-1) * IFM_WIDTH + (col+1)];
        // din[31:24] = (                is_first_col) ? 8'd0 : in_img[ row    * IFM_WIDTH + (col-1)];
        // din[39:32] =                                         in_img[ row    * IFM_WIDTH +  col   ];
        // din[47:40] = (                is_last_col ) ? 8'd0 : in_img[ row    * IFM_WIDTH + (col+1)];
        // din[55:48] = (is_last_row ||  is_first_col) ? 8'd0 : in_img[(row+1) * IFM_WIDTH + (col-1)];
        // din[63:56] = (is_last_row                 ) ? 8'd0 : in_img[(row+1) * IFM_WIDTH +  col   ];
        // din[71:64] = (is_last_row ||  is_last_col ) ? 8'd0 : in_img[(row+1) * IFM_WIDTH + (col+1)];
		din[0][ 7: 0] = (is_first_row || is_first_col) ? 8'd0 : in_img[(row-1) * IFM_WIDTH + (col-1)][0+:8];
        din[0][15: 8] = (is_first_row                ) ? 8'd0 : in_img[(row-1) * IFM_WIDTH +  col   ][0+:8];
        din[0][23:16] = (is_first_row || is_last_col ) ? 8'd0 : in_img[(row-1) * IFM_WIDTH + (col+1)][0+:8];
        din[0][31:24] = (                is_first_col) ? 8'd0 : in_img[ row    * IFM_WIDTH + (col-1)][0+:8];
        din[0][39:32] =                                         in_img[ row    * IFM_WIDTH +  col   ][0+:8];
        din[0][47:40] = (                is_last_col ) ? 8'd0 : in_img[ row    * IFM_WIDTH + (col+1)][0+:8];
        din[0][55:48] = (is_last_row ||  is_first_col) ? 8'd0 : in_img[(row+1) * IFM_WIDTH + (col-1)][0+:8];
        din[0][63:56] = (is_last_row                 ) ? 8'd0 : in_img[(row+1) * IFM_WIDTH +  col   ][0+:8];
        din[0][71:64] = (is_last_row ||  is_last_col ) ? 8'd0 : in_img[(row+1) * IFM_WIDTH + (col+1)][0+:8];

		din[1][ 7: 0] = (is_first_row || is_first_col) ? 8'd0 : in_img[(row-1) * IFM_WIDTH + (col-1)][8+:8];
        din[1][15: 8] = (is_first_row                ) ? 8'd0 : in_img[(row-1) * IFM_WIDTH +  col   ][8+:8];
        din[1][23:16] = (is_first_row || is_last_col ) ? 8'd0 : in_img[(row-1) * IFM_WIDTH + (col+1)][8+:8];
        din[1][31:24] = (                is_first_col) ? 8'd0 : in_img[ row    * IFM_WIDTH + (col-1)][8+:8];
        din[1][39:32] =                                         in_img[ row    * IFM_WIDTH +  col   ][8+:8];
        din[1][47:40] = (                is_last_col ) ? 8'd0 : in_img[ row    * IFM_WIDTH + (col+1)][8+:8];
        din[1][55:48] = (is_last_row ||  is_first_col) ? 8'd0 : in_img[(row+1) * IFM_WIDTH + (col-1)][8+:8];
        din[1][63:56] = (is_last_row                 ) ? 8'd0 : in_img[(row+1) * IFM_WIDTH +  col   ][8+:8];
        din[1][71:64] = (is_last_row ||  is_last_col ) ? 8'd0 : in_img[(row+1) * IFM_WIDTH + (col+1)][8+:8];

		din[2][ 7: 0] = (is_first_row || is_first_col) ? 8'd0 : in_img[(row-1) * IFM_WIDTH + (col-1)][16+:8];
        din[2][15: 8] = (is_first_row                ) ? 8'd0 : in_img[(row-1) * IFM_WIDTH +  col   ][16+:8];
        din[2][23:16] = (is_first_row || is_last_col ) ? 8'd0 : in_img[(row-1) * IFM_WIDTH + (col+1)][16+:8];
        din[2][31:24] = (                is_first_col) ? 8'd0 : in_img[ row    * IFM_WIDTH + (col-1)][16+:8];
        din[2][39:32] =                                         in_img[ row    * IFM_WIDTH +  col   ][16+:8];
        din[2][47:40] = (                is_last_col ) ? 8'd0 : in_img[ row    * IFM_WIDTH + (col+1)][16+:8];
        din[2][55:48] = (is_last_row ||  is_first_col) ? 8'd0 : in_img[(row+1) * IFM_WIDTH + (col-1)][16+:8];
        din[2][63:56] = (is_last_row                 ) ? 8'd0 : in_img[(row+1) * IFM_WIDTH +  col   ][16+:8];
        din[2][71:64] = (is_last_row ||  is_last_col ) ? 8'd0 : in_img[(row+1) * IFM_WIDTH + (col+1)][16+:8];
		// Tiled Filters
		// for(j = 0; j < 3; j=j+1) begin 	// Four sets <=> Four output channels
		// 	win[j][ 7: 0] = filter[(j*Fx*Fy*Ni)    ][7:0];
		// 	win[j][15: 8] = filter[(j*Fx*Fy*Ni) + 1][7:0];
		// 	win[j][23:16] = filter[(j*Fx*Fy*Ni) + 2][7:0];
		// 	win[j][31:24] = filter[(j*Fx*Fy*Ni) + 3][7:0];
		// 	win[j][39:32] = filter[(j*Fx*Fy*Ni) + 4][7:0];
		// 	win[j][47:40] = filter[(j*Fx*Fy*Ni) + 5][7:0];
		// 	win[j][55:48] = filter[(j*Fx*Fy*Ni) + 6][7:0];
		// 	win[j][63:56] = filter[(j*Fx*Fy*Ni) + 7][7:0];
		// 	win[j][71:64] = filter[(j*Fx*Fy*Ni) + 8][7:0];
		// end 
		win[0][ 7: 0] = filter[(fil_num*Fx*Fy*Ni)    ][7:0];
		win[0][15: 8] = filter[(fil_num*Fx*Fy*Ni) + 1][7:0];
		win[0][23:16] = filter[(fil_num*Fx*Fy*Ni) + 2][7:0];
		win[0][31:24] = filter[(fil_num*Fx*Fy*Ni) + 3][7:0];
		win[0][39:32] = filter[(fil_num*Fx*Fy*Ni) + 4][7:0];
		win[0][47:40] = filter[(fil_num*Fx*Fy*Ni) + 5][7:0];
		win[0][55:48] = filter[(fil_num*Fx*Fy*Ni) + 6][7:0];
		win[0][63:56] = filter[(fil_num*Fx*Fy*Ni) + 7][7:0];
		win[0][71:64] = filter[(fil_num*Fx*Fy*Ni) + 8][7:0];

		win[1][ 7: 0] = filter[(fil_num*Fx*Fy*Ni) + 9][7:0];
		win[1][15: 8] = filter[(fil_num*Fx*Fy*Ni) +10][7:0];
		win[1][23:16] = filter[(fil_num*Fx*Fy*Ni) +11][7:0];
		win[1][31:24] = filter[(fil_num*Fx*Fy*Ni) +12][7:0];
		win[1][39:32] = filter[(fil_num*Fx*Fy*Ni) +13][7:0];
		win[1][47:40] = filter[(fil_num*Fx*Fy*Ni) +14][7:0];
		win[1][55:48] = filter[(fil_num*Fx*Fy*Ni) +15][7:0];
		win[1][63:56] = filter[(fil_num*Fx*Fy*Ni) +16][7:0];
		win[1][71:64] = filter[(fil_num*Fx*Fy*Ni) +17][7:0];

		win[2][ 7: 0] = filter[(fil_num*Fx*Fy*Ni) +18][7:0];
		win[2][15: 8] = filter[(fil_num*Fx*Fy*Ni) +19][7:0];
		win[2][23:16] = filter[(fil_num*Fx*Fy*Ni) +20][7:0];
		win[2][31:24] = filter[(fil_num*Fx*Fy*Ni) +21][7:0];
		win[2][39:32] = filter[(fil_num*Fx*Fy*Ni) +22][7:0];
		win[2][47:40] = filter[(fil_num*Fx*Fy*Ni) +23][7:0];
		win[2][55:48] = filter[(fil_num*Fx*Fy*Ni) +24][7:0];
		win[2][63:56] = filter[(fil_num*Fx*Fy*Ni) +25][7:0];
		win[2][71:64] = filter[(fil_num*Fx*Fy*Ni) +26][7:0];
    end    
end 

//-------------------------------------------
// CONV result
//-------------------------------------------
wire [19:0] psum_r, psum_g, psum_b;
assign psum_r = acc_o[0];
assign psum_g = acc_o[1];
assign psum_b = acc_o[2];

wire [21:0] pixel_out;
assign pixel_out = $signed(psum_r) + $signed(psum_g) + $signed(psum_b) + 353; // hard-coded bias for the ch00

localparam SCALE_FACTOR = 10;
localparam NEXT_LAYER_INPUT_M = 3;

wire [21:0] pixel_out_act;
assign pixel_out_act = pixel_out[21] ? 22'd0 : pixel_out; // apply ReLU

reg [7:0] quant_pixel_out;

always @ (posedge clk) begin
	if (!rstn) begin
		quant_pixel_out <= 8'd0;
	end else if (&vld_o) begin
		quant_pixel_out <= pixel_out_act[(SCALE_FACTOR - NEXT_LAYER_INPUT_M)+:8];
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
./*input [127:0] */din	(din[0]  ),
./*output[ 19:0] */acc_o(acc_o[0]), 
./*output        */vld_o(vld_o[0])
);
mac u_mac_01(
./*input 		 */clk	(clk	 ), 
./*input 		 */rstn	(rstn	 ), 
./*input 		 */vld_i(vld_i	 ), 
./*input [127:0] */win	(win[1]	 ), 
./*input [127:0] */din	(din[1]  ),
./*output[ 19:0] */acc_o(acc_o[1]), 
./*output        */vld_o(vld_o[1])
);
mac u_mac_02(
./*input 		 */clk	(clk     ), 
./*input 		 */rstn	(rstn    ), 
./*input 		 */vld_i(vld_i   ), 
./*input [127:0] */win	(win[2]  ), 
./*input [127:0] */din	(din[2]  ),
./*output[ 19:0] */acc_o(acc_o[2]), 
./*output        */vld_o(vld_o[2])
);
// mac u_mac_03(
// ./*input 		 */clk	(clk     ), 
// ./*input 		 */rstn (rstn    ), 
// ./*input 		 */vld_i(vld_i   ), 
// ./*input [127:0] */win  (win[3]  ), 
// ./*input [127:0] */din  (din     ),
// ./*output[ 19:0] */acc_o(acc_o[3]), 
// ./*output        */vld_o(vld_o[3])
// );
// mac u_mac_04(
// ./*input 		 */clk	(clk	 ), 
// ./*input 		 */rstn	(rstn	 ), 
// ./*input 		 */vld_i(vld_i	 ), 
// ./*input [127:0] */win	(win[4]	 ), 
// ./*input [127:0] */din	(din	 ),
// ./*output[ 19:0] */acc_o(acc_o[4]), 
// ./*output        */vld_o(vld_o[4])
// );
// mac u_mac_05(
// ./*input 		 */clk	(clk	 ), 
// ./*input 		 */rstn	(rstn	 ), 
// ./*input 		 */vld_i(vld_i	 ), 
// ./*input [127:0] */win	(win[5]	 ), 
// ./*input [127:0] */din	(din	 ),
// ./*output[ 19:0] */acc_o(acc_o[5]), 
// ./*output        */vld_o(vld_o[5])
// );
// mac u_mac_06(
// ./*input 		 */clk	(clk     ), 
// ./*input 		 */rstn	(rstn    ), 
// ./*input 		 */vld_i(vld_i   ), 
// ./*input [127:0] */win	(win[6]  ), 
// ./*input [127:0] */din	(din     ),
// ./*output[ 19:0] */acc_o(acc_o[6]), 
// ./*output        */vld_o(vld_o[6])
// );
// mac u_mac_07(
// ./*input 		 */clk	(clk     ), 
// ./*input 		 */rstn (rstn    ), 
// ./*input 		 */vld_i(vld_i   ), 
// ./*input [127:0] */win  (win[7]  ), 
// ./*input [127:0] */din  (din     ),
// ./*output[ 19:0] */acc_o(acc_o[7]), 
// ./*output        */vld_o(vld_o[7])
// );
// mac u_mac_08(
// ./*input 		 */clk	(clk	 ), 
// ./*input 		 */rstn	(rstn	 ), 
// ./*input 		 */vld_i(vld_i	 ), 
// ./*input [127:0] */win	(win[8]	 ), 
// ./*input [127:0] */din	(din	 ),
// ./*output[ 19:0] */acc_o(acc_o[8]), 
// ./*output        */vld_o(vld_o[8])
// );
// mac u_mac_09(
// ./*input 		 */clk	(clk	 ), 
// ./*input 		 */rstn	(rstn	 ), 
// ./*input 		 */vld_i(vld_i	 ), 
// ./*input [127:0] */win	(win[9]	 ), 
// ./*input [127:0] */din	(din	 ),
// ./*output[ 19:0] */acc_o(acc_o[9]), 
// ./*output        */vld_o(vld_o[9])
// );
// mac u_mac_10(
// ./*input 		 */clk	(clk     ), 
// ./*input 		 */rstn	(rstn    ), 
// ./*input 		 */vld_i(vld_i   ), 
// ./*input [127:0] */win	(win[10] ), 
// ./*input [127:0] */din	(din     ),
// ./*output[ 19:0] */acc_o(acc_o[10]), 
// ./*output        */vld_o(vld_o[10])
// );
// mac u_mac_11(
// ./*input 		 */clk	(clk     ), 
// ./*input 		 */rstn (rstn    ), 
// ./*input 		 */vld_i(vld_i   ), 
// ./*input [127:0] */win  (win[11] ), 
// ./*input [127:0] */din  (din     ),
// ./*output[ 19:0] */acc_o(acc_o[11]), 
// ./*output        */vld_o(vld_o[11])
// );
// mac u_mac_12(
// ./*input 		 */clk	(clk	 ), 
// ./*input 		 */rstn	(rstn	 ), 
// ./*input 		 */vld_i(vld_i	 ), 
// ./*input [127:0] */win	(win[12] ), 
// ./*input [127:0] */din	(din	 ),
// ./*output[ 19:0] */acc_o(acc_o[12]), 
// ./*output        */vld_o(vld_o[12])
// );
// mac u_mac_13(
// ./*input 		 */clk	(clk	 ), 
// ./*input 		 */rstn	(rstn	 ), 
// ./*input 		 */vld_i(vld_i	 ), 
// ./*input [127:0] */win	(win[13] ), 
// ./*input [127:0] */din	(din	 ),
// ./*output[ 19:0] */acc_o(acc_o[13]), 
// ./*output        */vld_o(vld_o[13])
// );
// mac u_mac_14(
// ./*input 		 */clk	(clk     ), 
// ./*input 		 */rstn	(rstn    ), 
// ./*input 		 */vld_i(vld_i   ), 
// ./*input [127:0] */win	(win[14] ), 
// ./*input [127:0] */din	(din     ),
// ./*output[ 19:0] */acc_o(acc_o[14]), 
// ./*output        */vld_o(vld_o[14])
// );
// mac u_mac_15(
// ./*input 		 */clk	(clk     ), 
// ./*input 		 */rstn (rstn    ), 
// ./*input 		 */vld_i(vld_i   ), 
// ./*input [127:0] */win  (win[15] ), 
// ./*input [127:0] */din  (din     ),
// ./*output[ 19:0] */acc_o(acc_o[15]), 
// ./*output        */vld_o(vld_o[15])
// );

//--------------------------------------------------------------------
// For debugging: INPUTs/Outputs
//--------------------------------------------------------------------
// Output feature maps
//{{{

// ADDED: Quantization
// wire [19:0] tmp_ch00, tmp_ch01, tmp_ch02, tmp_ch03;
// wire [19:0] conv_out_ch00, conv_out_ch01, conv_out_ch02, conv_out_ch03,
// 			conv_out_ch04, conv_out_ch05, conv_out_ch06, conv_out_ch07,
// 		   	conv_out_ch08, conv_out_ch09, conv_out_ch10, conv_out_ch11,
// 		   	conv_out_ch12, conv_out_ch13, conv_out_ch14, conv_out_ch15;

// localparam SCALE_FACTOR = 10;

// assign conv_out_ch00 = acc_o[0] >>> SCALE_FACTOR; // Descaling
// assign conv_out_ch01 = acc_o[1] >>> SCALE_FACTOR; // Descaling
// assign conv_out_ch02 = acc_o[2] >>> SCALE_FACTOR; // Descaling
// assign conv_out_ch03 = acc_o[3] >>> SCALE_FACTOR; // Descaling
// assign conv_out_ch04 = acc_o[4] >>> SCALE_FACTOR; // Descaling
// assign conv_out_ch05 = acc_o[5] >>> SCALE_FACTOR; // Descaling
// assign conv_out_ch06 = acc_o[6] >>> SCALE_FACTOR; // Descaling
// assign conv_out_ch07 = acc_o[7] >>> SCALE_FACTOR; // Descaling
// assign conv_out_ch08 = acc_o[8] >>> SCALE_FACTOR; // Descaling
// assign conv_out_ch09 = acc_o[9] >>> SCALE_FACTOR; // Descaling
// assign conv_out_ch10 = acc_o[10] >>> SCALE_FACTOR; // Descaling
// assign conv_out_ch11 = acc_o[11] >>> SCALE_FACTOR; // Descaling
// assign conv_out_ch12 = acc_o[12] >>> SCALE_FACTOR; // Descaling
// assign conv_out_ch13 = acc_o[13] >>> SCALE_FACTOR; // Descaling
// assign conv_out_ch14 = acc_o[14] >>> SCALE_FACTOR; // Descaling
// assign conv_out_ch15 = acc_o[15] >>> SCALE_FACTOR; // Descaling

// wire [7:0] conv_out_ch00 = acc_o[0][19:10];	// Descaling	
// wire [7:0] conv_out_ch01 = acc_o[1][19:10]; // Descaling	
// wire [7:0] conv_out_ch02 = acc_o[2][19:10]; // Descaling	
// wire [7:0] conv_out_ch03 = acc_o[3][19:10]; // Descaling	

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
//}}}	
//**********************************************************************
//{{{
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

//}}}
endmodule