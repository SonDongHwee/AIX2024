`timescale 1ns / 1ns

module conv_kern_array_tb;
//`include "../../define.v"
`define NUM_BRAMS   16
`define BRAM_WIDTH  128
`define BRAM_DELAY  3

// Input Files
parameter IFM_WIDTH = 256;
parameter IFM_HEIGHT = 256;
parameter IFM_DATA_SIZE     = IFM_HEIGHT*IFM_WIDTH*2;		// Layer 00
parameter IFM_WORD_SIZE     = 32/2;
parameter IFM_DATA_SIZE_32  = IFM_HEIGHT*IFM_WIDTH;		// Layer 00
parameter IFM_WORD_SIZE_32  = 32;
parameter Fx = 3, Fy = 3;
parameter Ni = 3, No = 16; 
parameter WGT_DATA_SIZE   = Fx*Fy*Ni*No;	// Layer 00
parameter WGT_WORD_SIZE   = 32;


parameter IFM_FILE_32 		 = "../../inout_data_sw/log_feamap/CONV00_input_32b.hex"; 
parameter IFM_FILE   		 = "../../inout_data_sw/log_feamap/CONV00_input_16b.hex"; 
parameter WGT_FILE   		 = "../../inout_data_sw/log_param/CONV00_param_weight.hex";
parameter BIAS_FILE			 = "../../inout_data_sw/log_param/CONV00_param_biases.hex";

// Output Files
parameter CONV_INPUT_IMG00   = "../../inout_data_hw/CONV00_input_ch00.bmp"; 
parameter CONV_INPUT_IMG01   = "../../inout_data_hw/CONV00_input_ch01.bmp"; 
parameter CONV_INPUT_IMG02   = "../../inout_data_hw/CONV00_input_ch02.bmp"; 
parameter CONV_INPUT_IMG03   = "../../inout_data_hw/CONV00_input_ch03.bmp"; 

parameter CONV_OUTPUT_IMG00  = "../../inout_data_hw/CONV00_output_ch00.bmp"; 
parameter CONV_OUTPUT_IMG01  = "../../inout_data_hw/CONV00_output_ch01.bmp"; 
parameter CONV_OUTPUT_IMG02  = "../../inout_data_hw/CONV00_output_ch02.bmp"; 
parameter CONV_OUTPUT_IMG03  = "../../inout_data_hw/CONV00_output_ch03.bmp";
parameter CONV_OUTPUT_IMG04  = "../../inout_data_hw/CONV00_output_ch04.bmp"; 
parameter CONV_OUTPUT_IMG05  = "../../inout_data_hw/CONV00_output_ch05.bmp"; 
parameter CONV_OUTPUT_IMG06  = "../../inout_data_hw/CONV00_output_ch06.bmp"; 
parameter CONV_OUTPUT_IMG07  = "../../inout_data_hw/CONV00_output_ch07.bmp"; 
parameter CONV_OUTPUT_IMG08  = "../../inout_data_hw/CONV00_output_ch08.bmp"; 
parameter CONV_OUTPUT_IMG09  = "../../inout_data_hw/CONV00_output_ch09.bmp"; 
parameter CONV_OUTPUT_IMG10  = "../../inout_data_hw/CONV00_output_ch10.bmp"; 
parameter CONV_OUTPUT_IMG11  = "../../inout_data_hw/CONV00_output_ch11.bmp"; 
parameter CONV_OUTPUT_IMG12  = "../../inout_data_hw/CONV00_output_ch12.bmp"; 
parameter CONV_OUTPUT_IMG13  = "../../inout_data_hw/CONV00_output_ch13.bmp"; 
parameter CONV_OUTPUT_IMG14  = "../../inout_data_hw/CONV00_output_ch14.bmp"; 
parameter CONV_OUTPUT_IMG15  = "../../inout_data_hw/CONV00_output_ch15.bmp"; 

// Clock
parameter CLK_PERIOD = 10;   //100MHz
reg clk;
reg rstn;

// MACs, Conv kernels
reg         ctrl_data_run;
reg         vld_i;
reg [215:0] win[0:15]; // 3x3x3x16 weight
reg [215:0] din; // 
wire[ 19:0] acc_o[0:15];
wire[  3:0] vld_o; // 1 vld_o each for a mac_array

initial begin
   clk = 1'b1;
   forever #(CLK_PERIOD/2) clk = ~clk;
end
//--------------------------------------------------------------------
// Load input feature maps and parameters
//--------------------------------------------------------------------
reg  [IFM_WORD_SIZE_32-1:0] in_img[0:IFM_DATA_SIZE_32-1];  // Infmap
reg  [IFM_WORD_SIZE_32-1:0] filter[0:WGT_DATA_SIZE   -1];	// Filter
reg  [IFM_WORD_SIZE_32-1:0] bias[0:No -1]; // bias
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
	$display ("Loading weight from file: %s", WGT_FILE);
	$readmemh(WGT_FILE, filter);

    // Bias
    for (i = 0; i < No; i=i+1) begin
        bias[i] = 0;
    end
    $display ("Loading bias from file: %s", BIAS_FILE);
	$readmemh(BIAS_FILE, bias);
end

//--------------------------------------------------------------------
// Test vector
//--------------------------------------------------------------------
integer iter;
integer j;
integer row, col;
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
        row = 0;
        col = 0;
        @(posedge clk) ctrl_data_run = 1;
        for(iter = 0; iter < IFM_HEIGHT * IFM_WIDTH; iter = iter + 1) begin
            @(posedge clk) begin
                if(col == IFM_WIDTH - 1) begin
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

always@(*) begin
	vld_i = 0;
    din = 128'd0;
    win[0] = 0;
	win[1] = 0;
	win[2] = 0;
	win[3] = 0;
	win[4] = 0;
	win[5] = 0;
	win[6] = 0;
	win[7] = 0;
	win[8] = 0;
	win[9] = 0;
	win[10] = 0;
	win[11] = 0;
	win[12] = 0;
	win[13] = 0;
	win[14] = 0;
	win[15] = 0;
    if(ctrl_data_run) begin
		vld_i = 1;
		// Tiled IFM data
        din[ 7: 0] = (is_first_row || is_first_col) ? 8'd0 : in_img[(row-1) * IFM_WIDTH + (col-1)][7:0];
        din[15: 8] = (is_first_row                ) ? 8'd0 : in_img[(row-1) * IFM_WIDTH +  col   ][7:0];
        din[23:16] = (is_first_row || is_last_col ) ? 8'd0 : in_img[(row-1) * IFM_WIDTH + (col+1)][7:0];
        din[31:24] = (                is_first_col) ? 8'd0 : in_img[ row    * IFM_WIDTH + (col-1)][7:0];
        din[39:32] =                                         in_img[ row    * IFM_WIDTH +  col   ][7:0];
        din[47:40] = (                is_last_col ) ? 8'd0 : in_img[ row    * IFM_WIDTH + (col+1)][7:0];
        din[55:48] = (is_last_row ||  is_first_col) ? 8'd0 : in_img[(row+1) * IFM_WIDTH + (col-1)][7:0];
        din[63:56] = (is_last_row                 ) ? 8'd0 : in_img[(row+1) * IFM_WIDTH + (col  )][7:0];
        din[71:64] = (is_last_row ||  is_last_col ) ? 8'd0 : in_img[(row+1) * IFM_WIDTH + (col+1)][7:0]; // Red

        din[79:  72] = (is_first_row || is_first_col) ? 8'd0 : in_img[(row-1) * IFM_WIDTH + (col-1)][15:8];
        din[87:  80] = (is_first_row                ) ? 8'd0 : in_img[(row-1) * IFM_WIDTH +  col   ][15:8];
        din[95:  88] = (is_first_row || is_last_col ) ? 8'd0 : in_img[(row-1) * IFM_WIDTH + (col+1)][15:8];
        din[103: 96] = (                is_first_col) ? 8'd0 : in_img[ row    * IFM_WIDTH + (col-1)][15:8];
        din[111:104] =                                         in_img[ row    * IFM_WIDTH +  col   ][15:8];
        din[119:112] = (                is_last_col ) ? 8'd0 : in_img[ row    * IFM_WIDTH + (col+1)][15:8];
        din[127:120] = (is_last_row ||  is_first_col) ? 8'd0 : in_img[(row+1) * IFM_WIDTH + (col-1)][15:8];
        din[135:128] = (is_last_row                 ) ? 8'd0 : in_img[(row+1) * IFM_WIDTH + (col  )][15:8];
        din[143:136] = (is_last_row ||  is_last_col ) ? 8'd0 : in_img[(row+1) * IFM_WIDTH + (col+1)][15:8]; // Green

        din[151:144] = (is_first_row || is_first_col) ? 8'd0 : in_img[(row-1) * IFM_WIDTH + (col-1)][23:16];
        din[159:152] = (is_first_row                ) ? 8'd0 : in_img[(row-1) * IFM_WIDTH +  col   ][23:16];
        din[167:160] = (is_first_row || is_last_col ) ? 8'd0 : in_img[(row-1) * IFM_WIDTH + (col+1)][23:16];
        din[175:168] = (                is_first_col) ? 8'd0 : in_img[ row    * IFM_WIDTH + (col-1)][23:16];
        din[183:176] =                                         in_img[ row    * IFM_WIDTH +  col   ][23:16];
        din[191:184] = (                is_last_col ) ? 8'd0 : in_img[ row    * IFM_WIDTH + (col+1)][23:16];
        din[199:192] = (is_last_row ||  is_first_col) ? 8'd0 : in_img[(row+1) * IFM_WIDTH + (col-1)][23:16];
        din[207:200] = (is_last_row                 ) ? 8'd0 : in_img[(row+1) * IFM_WIDTH + (col  )][23:16];
        din[215:208] = (is_last_row ||  is_last_col ) ? 8'd0 : in_img[(row+1) * IFM_WIDTH + (col+1)][23:16]; // Blue

		// Tiled Filters
		for(j = 0; j < 16; j=j+1) begin 	// Four sets <=> Four output channels
            win[j][ 7: 0] = filter[(j*Fx*Fy*Ni)    ][7:0];
			win[j][15: 8] = filter[(j*Fx*Fy*Ni) + 1][7:0];
			win[j][23:16] = filter[(j*Fx*Fy*Ni) + 2][7:0];
			win[j][31:24] = filter[(j*Fx*Fy*Ni) + 3][7:0];
			win[j][39:32] = filter[(j*Fx*Fy*Ni) + 4][7:0];
			win[j][47:40] = filter[(j*Fx*Fy*Ni) + 5][7:0];
			win[j][55:48] = filter[(j*Fx*Fy*Ni) + 6][7:0];
			win[j][63:56] = filter[(j*Fx*Fy*Ni) + 7][7:0];
			win[j][71:64] = filter[(j*Fx*Fy*Ni) + 8][7:0];

            win[j][79:  72] = filter[(j*Fx*Fy*Ni) +  9][7:0];
			win[j][87:  80] = filter[(j*Fx*Fy*Ni) + 10][7:0];
			win[j][95:  88] = filter[(j*Fx*Fy*Ni) + 11][7:0];
			win[j][103: 96] = filter[(j*Fx*Fy*Ni) + 12][7:0];
			win[j][111:104] = filter[(j*Fx*Fy*Ni) + 13][7:0];
			win[j][119:112] = filter[(j*Fx*Fy*Ni) + 14][7:0];
			win[j][127:120] = filter[(j*Fx*Fy*Ni) + 15][7:0];
			win[j][135:128] = filter[(j*Fx*Fy*Ni) + 16][7:0];
			win[j][143:136] = filter[(j*Fx*Fy*Ni) + 17][7:0];

            win[j][151:144] = filter[(j*Fx*Fy*Ni) + 18][7:0];
			win[j][159:152] = filter[(j*Fx*Fy*Ni) + 19][7:0];
			win[j][167:160] = filter[(j*Fx*Fy*Ni) + 20][7:0];
			win[j][175:168] = filter[(j*Fx*Fy*Ni) + 21][7:0];
			win[j][183:176] = filter[(j*Fx*Fy*Ni) + 22][7:0];
			win[j][191:184] = filter[(j*Fx*Fy*Ni) + 23][7:0];
			win[j][199:192] = filter[(j*Fx*Fy*Ni) + 24][7:0];
			win[j][207:200] = filter[(j*Fx*Fy*Ni) + 25][7:0];
			win[j][215:208] = filter[(j*Fx*Fy*Ni) + 26][7:0];	
		end 
    end    
end 
//-------------------------------------------
// DUT: MACs
//-------------------------------------------
mac_array u_mac_array_0(
    .clk(clk), 
    .rstn(rstn), 
    .vld_i(vld_i), 

    .win_0(win[0][127:0]), 
    .win_1({40'b0, win[0][215:128]}),
    .win_2(win[1][127:0]), 
    .win_3({40'b0, win[1][215:128]}),
    .win_4(win[2][127:0]), 
    .win_5({40'b0, win[2][215:128]}),
    .win_6(win[3][127:0]), 
    .win_7({40'b0, win[3][215:128]}),

    .din_0(din[127:0]), 
    .din_1({40'b0, din[215:128]}),
    .din_2(din[127:0]), 
    .din_3({40'b0, din[215:128]}),
    .din_4(din[127:0]), 
    .din_5({40'b0, din[215:128]}),
    .din_6(din[127:0]), 
    .din_7({40'b0, din[215:128]}),

    .acc_o_0(acc_o[0]), 
    .acc_o_1(acc_o[1]), 
    .acc_o_2(acc_o[2]), 
    .acc_o_3(acc_o[3]), 

    .vld_o(vld_o[0])
);

mac_array u_mac_array_1(
    .clk(clk), 
    .rstn(rstn), 
    .vld_i(vld_i), 

    .win_0(win[4][127:0]), 
    .win_1({40'b0, win[4][215:128]}),
    .win_2(win[5][127:0]), 
    .win_3({40'b0, win[5][215:128]}),
    .win_4(win[6][127:0]), 
    .win_5({40'b0, win[6][215:128]}),
    .win_6(win[7][127:0]), 
    .win_7({40'b0, win[7][215:128]}),

    .din_0(din[127:0]), 
    .din_1({40'b0, din[215:128]}),
    .din_2(din[127:0]), 
    .din_3({40'b0, din[215:128]}),
    .din_4(din[127:0]), 
    .din_5({40'b0, din[215:128]}),
    .din_6(din[127:0]), 
    .din_7({40'b0, din[215:128]}),

    .acc_o_0(acc_o[4]), 
    .acc_o_1(acc_o[5]), 
    .acc_o_2(acc_o[6]), 
    .acc_o_3(acc_o[7]), 

    .vld_o(vld_o[1])
);

mac_array u_mac_array_2(
    .clk(clk), 
    .rstn(rstn), 
    .vld_i(vld_i), 

    .win_0(win[8][127:0]), 
    .win_1({40'b0, win[8][215:128]}),
    .win_2(win[9][127:0]), 
    .win_3({40'b0, win[9][215:128]}),
    .win_4(win[10][127:0]), 
    .win_5({40'b0, win[10][215:128]}),
    .win_6(win[11][127:0]), 
    .win_7({40'b0, win[11][215:128]}),

    .din_0(din[127:0]), 
    .din_1({40'b0, din[215:128]}),
    .din_2(din[127:0]), 
    .din_3({40'b0, din[215:128]}),
    .din_4(din[127:0]), 
    .din_5({40'b0, din[215:128]}),
    .din_6(din[127:0]), 
    .din_7({40'b0, din[215:128]}),

    .acc_o_0(acc_o[8]), 
    .acc_o_1(acc_o[9]), 
    .acc_o_2(acc_o[10]), 
    .acc_o_3(acc_o[11]), 

    .vld_o(vld_o[2])
);

mac_array u_mac_array_3(
    .clk(clk), 
    .rstn(rstn), 
    .vld_i(vld_i), 

    .win_0(win[12][127:0]), 
    .win_1({40'b0, win[12][215:128]}),
    .win_2(win[13][127:0]), 
    .win_3({40'b0, win[13][215:128]}),
    .win_4(win[14][127:0]), 
    .win_5({40'b0, win[14][215:128]}),
    .win_6(win[15][127:0]), 
    .win_7({40'b0, win[15][215:128]}),

    .din_0(din[127:0]), 
    .din_1({40'b0, din[215:128]}),
    .din_2(din[127:0]), 
    .din_3({40'b0, din[215:128]}),
    .din_4(din[127:0]), 
    .din_5({40'b0, din[215:128]}),
    .din_6(din[127:0]), 
    .din_7({40'b0, din[215:128]}),

    .acc_o_0(acc_o[12]), 
    .acc_o_1(acc_o[13]), 
    .acc_o_2(acc_o[14]), 
    .acc_o_3(acc_o[15]), 

    .vld_o(vld_o[3])
);

//--------------------------------------------------------------------
// For debugging: INPUTs/Outputs
//--------------------------------------------------------------------
// Output feature maps
//{{{
wire [20:0] temp_acc_bias [0:15];
wire [7:0] conv_out [0:15];
genvar l;
generate
	for (l = 0; l < 16; l = l + 1) begin : conv_out_wire
		//assign conv_out[l] = acc_o[l][19:12];
        assign temp_acc_bias[l] = $signed(acc_o[l]) + $signed(bias[l]); // bias adding
        assign conv_out[l] = temp_acc_bias[l][20] ? 8'b0 : temp_acc_bias[l][14:7]; // relu
	end
endgenerate

bmp_image_writer #(.OUTFILE(CONV_OUTPUT_IMG00),.WIDTH(IFM_WIDTH),.HEIGHT(IFM_HEIGHT))
u_acc_img_ch0(
   ./*input          */clk      (clk        ),
   ./*input          */rstn      (rstn        ),
   ./*input [WI-1:0]    */din      (conv_out[0]),
   ./*input          */vld      (vld_o[0]     ),
   ./*output reg       */frame_done(            )
);
bmp_image_writer #(.OUTFILE(CONV_OUTPUT_IMG01),.WIDTH(IFM_WIDTH),.HEIGHT(IFM_HEIGHT))
u_acc_img_ch1(
   ./*input          */clk      (clk        ),
   ./*input          */rstn      (rstn        ),
   ./*input [WI-1:0]    */din      (conv_out[1]),
   ./*input          */vld      (vld_o[0]     ),
   ./*output reg       */frame_done(            )
);
bmp_image_writer #(.OUTFILE(CONV_OUTPUT_IMG02),.WIDTH(IFM_WIDTH),.HEIGHT(IFM_HEIGHT))
u_acc_img_ch2(
   ./*input          */clk      (clk        ),
   ./*input          */rstn      (rstn        ),
   ./*input [WI-1:0]    */din      (conv_out[2]),
   ./*input          */vld      (vld_o[0]     ),
   ./*output reg       */frame_done(            )
);
bmp_image_writer #(.OUTFILE(CONV_OUTPUT_IMG03),.WIDTH(IFM_WIDTH),.HEIGHT(IFM_HEIGHT))
u_acc_img_ch3(
   ./*input          */clk      (clk        ),
   ./*input          */rstn      (rstn        ),
   ./*input [WI-1:0]    */din      (conv_out[3]),
   ./*input          */vld      (vld_o[0]     ),
   ./*output reg       */frame_done(            )
);   
bmp_image_writer #(.OUTFILE(CONV_OUTPUT_IMG04),.WIDTH(IFM_WIDTH),.HEIGHT(IFM_HEIGHT))
u_acc_img_ch4(
   ./*input          */clk      (clk        ),
   ./*input          */rstn      (rstn        ),
   ./*input [WI-1:0]    */din      (conv_out[4]),
   ./*input          */vld      (vld_o[1]     ),
   ./*output reg       */frame_done(            )
);   
bmp_image_writer #(.OUTFILE(CONV_OUTPUT_IMG05),.WIDTH(IFM_WIDTH),.HEIGHT(IFM_HEIGHT))
u_acc_img_ch5(
   ./*input          */clk      (clk        ),
   ./*input          */rstn      (rstn        ),
   ./*input [WI-1:0]    */din      (conv_out[5]),
   ./*input          */vld      (vld_o[1]     ),
   ./*output reg       */frame_done(            )
);   
bmp_image_writer #(.OUTFILE(CONV_OUTPUT_IMG06),.WIDTH(IFM_WIDTH),.HEIGHT(IFM_HEIGHT))
u_acc_img_ch6(
   ./*input          */clk      (clk        ),
   ./*input          */rstn      (rstn        ),
   ./*input [WI-1:0]    */din      (conv_out[6]),
   ./*input          */vld      (vld_o[1]     ),
   ./*output reg       */frame_done(            )
);   
bmp_image_writer #(.OUTFILE(CONV_OUTPUT_IMG07),.WIDTH(IFM_WIDTH),.HEIGHT(IFM_HEIGHT))
u_acc_img_ch7(
   ./*input          */clk      (clk        ),
   ./*input          */rstn      (rstn        ),
   ./*input [WI-1:0]    */din      (conv_out[7]),
   ./*input          */vld      (vld_o[1]     ),
   ./*output reg       */frame_done(            )
);   
bmp_image_writer #(.OUTFILE(CONV_OUTPUT_IMG08),.WIDTH(IFM_WIDTH),.HEIGHT(IFM_HEIGHT))
u_acc_img_ch8(
   ./*input          */clk      (clk        ),
   ./*input          */rstn      (rstn        ),
   ./*input [WI-1:0]    */din      (conv_out[8]),
   ./*input          */vld      (vld_o[2]     ),
   ./*output reg       */frame_done(            )
);   
bmp_image_writer #(.OUTFILE(CONV_OUTPUT_IMG09),.WIDTH(IFM_WIDTH),.HEIGHT(IFM_HEIGHT))
u_acc_img_ch9(
   ./*input          */clk      (clk        ),
   ./*input          */rstn      (rstn        ),
   ./*input [WI-1:0]    */din      (conv_out[9]),
   ./*input          */vld      (vld_o[2]     ),
   ./*output reg       */frame_done(            )
);   
bmp_image_writer #(.OUTFILE(CONV_OUTPUT_IMG10),.WIDTH(IFM_WIDTH),.HEIGHT(IFM_HEIGHT))
u_acc_img_ch10(
   ./*input          */clk      (clk        ),
   ./*input          */rstn      (rstn        ),
   ./*input [WI-1:0]    */din      (conv_out[10]),
   ./*input          */vld      (vld_o[2]     ),
   ./*output reg       */frame_done(            )
);   
bmp_image_writer #(.OUTFILE(CONV_OUTPUT_IMG11),.WIDTH(IFM_WIDTH),.HEIGHT(IFM_HEIGHT))
u_acc_img_ch11(
   ./*input          */clk      (clk        ),
   ./*input          */rstn      (rstn        ),
   ./*input [WI-1:0]    */din      (conv_out[11]),
   ./*input          */vld      (vld_o[2]     ),
   ./*output reg       */frame_done(            )
);   
bmp_image_writer #(.OUTFILE(CONV_OUTPUT_IMG12),.WIDTH(IFM_WIDTH),.HEIGHT(IFM_HEIGHT))
u_acc_img_ch12(
   ./*input          */clk      (clk        ),
   ./*input          */rstn      (rstn        ),
   ./*input [WI-1:0]    */din      (conv_out[12]),
   ./*input          */vld      (vld_o[3]     ),
   ./*output reg       */frame_done(            )
);   
bmp_image_writer #(.OUTFILE(CONV_OUTPUT_IMG13),.WIDTH(IFM_WIDTH),.HEIGHT(IFM_HEIGHT))
u_acc_img_ch13(
   ./*input          */clk      (clk        ),
   ./*input          */rstn      (rstn        ),
   ./*input [WI-1:0]    */din      (conv_out[13]),
   ./*input          */vld      (vld_o[3]     ),
   ./*output reg       */frame_done(            )
);   
bmp_image_writer #(.OUTFILE(CONV_OUTPUT_IMG14),.WIDTH(IFM_WIDTH),.HEIGHT(IFM_HEIGHT))
u_acc_img_ch14(
   ./*input          */clk      (clk        ),
   ./*input          */rstn      (rstn        ),
   ./*input [WI-1:0]    */din      (conv_out[14]),
   ./*input          */vld      (vld_o[3]     ),
   ./*output reg       */frame_done(            )
);   
bmp_image_writer #(.OUTFILE(CONV_OUTPUT_IMG15),.WIDTH(IFM_WIDTH),.HEIGHT(IFM_HEIGHT))
u_acc_img_ch15(
   ./*input          */clk      (clk        ),
   ./*input          */rstn      (rstn        ),
   ./*input [WI-1:0]    */din      (conv_out[15]),
   ./*input          */vld      (vld_o[3]     ),
   ./*output reg       */frame_done(            )
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