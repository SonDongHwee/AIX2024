`timescale 1ns / 1ps

module conv3x3_maxpool_module(
  input       [15:0] IFM_WIDTH,
  input       [15:0] IFM_HEIGHT,
  input       [ 3:0] Tr,
  input       [ 3:0] Tc,
  input       [ 3:0] Ti,
  input       [ 3:0] To,
  input       [15:0] Ni,
  input       [15:0] No,
  input       [15:0] SCALE_FACTOR,
  input       [15:0] NEXT_LAYER_INPUT_M,

  input              clk,
  input              rstn,
  input              is_CONV00,
  input       [ 3:0] COMMAND,
  input       [31:0] RECEIVE_SIZE,
  input              conv_start,
  input              valid_i,
  input       [31:0] data_in,       
  
  output reg         F_writedone,
  output reg         W_writedone,
  output reg         B_writedone,
  output reg         ready_o,
  output reg         valid_o,
  output reg [127:0] data_out,
  output reg         conv_done
);
// FSM states
localparam     COMMAND_IDLE = 4'b0000;
localparam    COMMAND_GET_F = 4'b0001;
localparam    COMMAND_GET_W = 4'b0010;
localparam    COMMAND_GET_B = 4'b0100;
localparam  COMMAND_COMPUTE = 4'b1000;
reg [3:0] state;
localparam    STATE_IDLE = 4'b0000;
localparam     STATE_RUN = 4'b0001;
localparam    STATE_DONE = 4'b0010;

// registers or BRAMs
reg [31:0] in_img [0:65535];        // maximum value is 256*256=65536 at CONV00
reg [31:0] weight [0:3*3*32*64-1];  // maximum value is 3*3*512*256, but it's too large...
reg [31:0]   bias [0:512];          // maximum value is 512 at CONV10

// local variables
reg  [31:0] IFM_DATA_SIZE;
reg  [31:0] WGT_DATA_SIZE;
reg  [31:0] BIAS_DATA_SIZE;
reg  [31:0] OUTPUT_SIZE;
wire [ 3:0] IFM_BITSHIFT;
wire [ 3:0] Ni_BITSHIFT;
wire [31:0] FRAME_DELAY;
assign IFM_BITSHIFT = IFM_WIDTH[8] ? 4'd8 : ( // when IFM_WIDTH == 256
                      IFM_WIDTH[7] ? 4'd7 : ( // when IFM_WIDTH == 128
                      IFM_WIDTH[6] ? 4'd6 : ( // when IFM_WIDTH == 64
                      IFM_WIDTH[5] ? 4'd5 : ( // when IFM_WIDTH == 32
                      IFM_WIDTH[4] ? 4'd4 : ( // when IFM_WIDTH == 16
                      IFM_WIDTH[3] ? 4'd3 : ( // when IFM_WIDTH == 8
                      4'd0))))));
assign  Ni_BITSHIFT = Ni[9] ? 4'd9 : ( // when Ni == 512
                      Ni[8] ? 4'd8 : ( // when Ni == 256
                      Ni[7] ? 4'd7 : ( // when Ni == 128
                      Ni[6] ? 4'd6 : ( // when Ni == 64
                      Ni[5] ? 4'd5 : ( // when Ni == 32
                      Ni[4] ? 4'd4 : ( // when Ni == 16
                      Ni[2] ? 4'd2 : ( // when Ni == 4
                      4'd0)))))));
assign FRAME_DELAY = (Ni * No) >> 4; // equals to Ni * No / (Ti * To); we fix (Ti * To) as 16.

reg     [31:0] counter;
reg     [31:0] mac_counter;
reg     [31:0] pool_counter;
reg     [31:0] send_counter;
reg     [15:0] filter_set;
reg     [15:0] chan_set;
reg     [15:0] bias_num;
reg     [31:0] delay;

reg     [15:0] row, col;
wire    [15:0] row_array_0, row_array_1, row_array_2, row_array_3;
wire    [15:0] col_array_0, col_array_1, col_array_2, col_array_3;
assign row_array_0 = row;
assign row_array_1 = row;
assign row_array_2 = row + 1;
assign row_array_3 = row + 1;
assign col_array_0 = col;
assign col_array_1 = col + 1;
assign col_array_2 = col;
assign col_array_3 = col + 1;

reg         mac_vld_i;
reg [127:0] din_mac_array_0 [0:8];
reg [127:0] din_mac_array_1 [0:8];
reg [127:0] din_mac_array_2 [0:8];
reg [127:0] din_mac_array_3 [0:8];
reg [127:0] win             [0:8];

wire [23:0] mac_out   [0:3][0:3];
wire        m_mac_vld_o [0:3];

wire        valid_mac;
assign valid_mac = m_mac_vld_o[0] && m_mac_vld_o[1] && m_mac_vld_o[2] && m_mac_vld_o[3];
reg         valid_pool;
reg         mac_done;
reg         pool_done;
reg         send_done;

// functions
function automatic is_first_row(
  input [15:0] _row
); 
	is_first_row = (_row == 0) ? 1'b1 : 1'b0;
endfunction
function automatic is_last_row(
  input [15:0] _row
); 
	is_last_row = (_row == IFM_HEIGHT-1) ? 1'b1 : 1'b0;
endfunction
function automatic is_first_col(
  input [15:0] _col
); 
	is_first_col = (_col == 0) ? 1'b1 : 1'b0;
endfunction
function automatic is_last_col(
  input [15:0] _col
); 
	is_last_col = (_col == IFM_WIDTH-1) ? 1'b1 : 1'b0;
endfunction
function automatic [31:0] get_IFM_index(
  input [15:0] _row,
  input [15:0] _col,
  input [15:0] _channel
); 
	get_IFM_index = ((((_row << IFM_BITSHIFT) + _col) << Ni_BITSHIFT) + _channel) >> 2;
endfunction
function automatic [ 4:0] get_IFM_offset(
  input [15:0] _channel
); 
	get_IFM_offset = _channel[1:0] << 3;
endfunction
function automatic [31:0] get_WGT_index(
  input [15:0] _fil_num,
  input [15:0] _element
);
  get_WGT_index = ((9 << Ni_BITSHIFT) * _fil_num + _element) >> 2;
endfunction
function automatic [ 4:0] get_WGT_offset(
  input [15:0] _element
); 
	get_WGT_offset = _element[1:0] << 3;
endfunction
function automatic [31:0] get_BIAS_index(
  input [15:0] _bias_num
);
  get_BIAS_index= _bias_num >> 1;
endfunction
function automatic [ 4:0] get_BIAS_offset(
  input [15:0] _bias_num
); 
  get_BIAS_offset = _bias_num[0] << 4;
endfunction

function automatic [23:0] find_max(
  input [23:0] ina,
  input [23:0] inb,
  input [23:0] inc,
  input [23:0] ind
);
begin : findmax
  reg [23:0] tmp_1, tmp_2;
  tmp_1 = ($signed(ina) > $signed(inb)) ? ina : inb;
  tmp_2 = ($signed(inc) > $signed(ind)) ? inc : ind;
  find_max = ($signed(tmp_1) > $signed(tmp_2)) ? tmp_1 : tmp_2;
end
endfunction

// quantization with adding bias
reg  [23:0] result_0_exact, result_1_exact, result_2_exact, result_3_exact;
wire [15:0] bias_to_add_0, bias_to_add_1, bias_to_add_2, bias_to_add_3; 
wire [23:0] result_0_exact_add_bias, result_1_exact_add_bias, result_2_exact_add_bias, result_3_exact_add_bias;
wire [ 7:0] result_0_quant, result_1_quant, result_2_quant, result_3_quant;
wire [31:0] result_buffer;

assign bias_to_add_0 = bias[get_BIAS_index({bias_num[1:0], 2'b00})][get_BIAS_offset({bias_num[1:0], 2'b00})+:16];
assign bias_to_add_1 = bias[get_BIAS_index({bias_num[1:0], 2'b01})][get_BIAS_offset({bias_num[1:0], 2'b01})+:16];
assign bias_to_add_2 = bias[get_BIAS_index({bias_num[1:0], 2'b10})][get_BIAS_offset({bias_num[1:0], 2'b10})+:16];
assign bias_to_add_3 = bias[get_BIAS_index({bias_num[1:0], 2'b11})][get_BIAS_offset({bias_num[1:0], 2'b11})+:16];

assign result_0_exact_add_bias = (is_CONV00) ? (result_0_exact + {{8{bias_to_add_0[15]}}, bias_to_add_0})
                                             : (1'b0);
assign result_1_exact_add_bias = (is_CONV00) ? (result_1_exact + {{8{bias_to_add_1[15]}}, bias_to_add_1})
                                             : (1'b0);
assign result_2_exact_add_bias = (is_CONV00) ? (result_2_exact + {{8{bias_to_add_2[15]}}, bias_to_add_2})
                                             : (1'b0);
assign result_3_exact_add_bias = (is_CONV00) ? (result_3_exact + {{8{bias_to_add_3[15]}}, bias_to_add_3})
                                             : (1'b0);                                                                                          

// apply ReLU
assign result_0_quant = result_0_exact_add_bias[23] ? 1'b0 : result_0_exact_add_bias[(SCALE_FACTOR - NEXT_LAYER_INPUT_M)+:8];
assign result_1_quant = result_1_exact_add_bias[23] ? 1'b0 : result_1_exact_add_bias[(SCALE_FACTOR - NEXT_LAYER_INPUT_M)+:8];
assign result_2_quant = result_2_exact_add_bias[23] ? 1'b0 : result_2_exact_add_bias[(SCALE_FACTOR - NEXT_LAYER_INPUT_M)+:8];
assign result_3_quant = result_3_exact_add_bias[23] ? 1'b0 : result_3_exact_add_bias[(SCALE_FACTOR - NEXT_LAYER_INPUT_M)+:8];

assign result_buffer = {result_3_quant, result_2_quant, result_1_quant, result_0_quant};

// zero-padding detector
// wire is_first_row, is_last_row, is_first_col, is_last_col;
// assign is_first_row = (row == 0)            ? 1'b1 : 1'b0;
// assign is_last_row  = (row == IFM_HEIGHT-1) ? 1'b1 : 1'b0;
// assign is_first_col = (col == 0)            ? 1'b1 : 1'b0;
// assign is_last_col  = (col == IFM_WIDTH-1)  ? 1'b1 : 1'b0;
integer mac_iter;
integer fil_iter;
always @ (*) begin // assign din and win for 4 MAC arrays
  if (is_CONV00) begin
    // --------------------------------------------
    // MAC array 0-3 : Weight
    // --------------------------------------------
    for (fil_iter = 0; fil_iter < 8; fil_iter = fil_iter + 2) begin
      win[fil_iter  ][  0+:8] = weight[get_WGT_index(filter_set + (fil_iter>>1),  0)][get_WGT_offset( 0)+:8];
      win[fil_iter  ][  8+:8] = weight[get_WGT_index(filter_set + (fil_iter>>1),  1)][get_WGT_offset( 1)+:8];
      win[fil_iter  ][ 16+:8] = weight[get_WGT_index(filter_set + (fil_iter>>1),  2)][get_WGT_offset( 2)+:8];
      win[fil_iter  ][ 24+:8] = weight[get_WGT_index(filter_set + (fil_iter>>1),  4)][get_WGT_offset( 4)+:8];
      win[fil_iter  ][ 32+:8] = weight[get_WGT_index(filter_set + (fil_iter>>1),  5)][get_WGT_offset( 5)+:8];
      win[fil_iter  ][ 40+:8] = weight[get_WGT_index(filter_set + (fil_iter>>1),  6)][get_WGT_offset( 6)+:8];
      win[fil_iter  ][ 48+:8] = weight[get_WGT_index(filter_set + (fil_iter>>1),  8)][get_WGT_offset( 8)+:8];
      win[fil_iter  ][ 56+:8] = weight[get_WGT_index(filter_set + (fil_iter>>1),  9)][get_WGT_offset( 9)+:8];
      win[fil_iter  ][ 64+:8] = weight[get_WGT_index(filter_set + (fil_iter>>1), 10)][get_WGT_offset(10)+:8];
      win[fil_iter  ][ 72+:8] = weight[get_WGT_index(filter_set + (fil_iter>>1), 12)][get_WGT_offset(12)+:8];
      win[fil_iter  ][ 80+:8] = weight[get_WGT_index(filter_set + (fil_iter>>1), 13)][get_WGT_offset(13)+:8];
      win[fil_iter  ][ 88+:8] = weight[get_WGT_index(filter_set + (fil_iter>>1), 14)][get_WGT_offset(14)+:8];
      win[fil_iter  ][ 96+:8] = weight[get_WGT_index(filter_set + (fil_iter>>1), 16)][get_WGT_offset(16)+:8];
      win[fil_iter  ][104+:8] = weight[get_WGT_index(filter_set + (fil_iter>>1), 17)][get_WGT_offset(17)+:8];
      win[fil_iter  ][112+:8] = weight[get_WGT_index(filter_set + (fil_iter>>1), 18)][get_WGT_offset(18)+:8];
      win[fil_iter  ][120+:8] = 1'b0;
      win[fil_iter+1][  0+:8] = weight[get_WGT_index(filter_set + (fil_iter>>1), 20)][get_WGT_offset(20)+:8];
      win[fil_iter+1][  8+:8] = weight[get_WGT_index(filter_set + (fil_iter>>1), 21)][get_WGT_offset(21)+:8];
      win[fil_iter+1][ 16+:8] = weight[get_WGT_index(filter_set + (fil_iter>>1), 22)][get_WGT_offset(22)+:8];
      win[fil_iter+1][ 24+:8] = weight[get_WGT_index(filter_set + (fil_iter>>1), 24)][get_WGT_offset(24)+:8];
      win[fil_iter+1][ 32+:8] = weight[get_WGT_index(filter_set + (fil_iter>>1), 25)][get_WGT_offset(25)+:8];
      win[fil_iter+1][ 40+:8] = weight[get_WGT_index(filter_set + (fil_iter>>1), 26)][get_WGT_offset(26)+:8];
      win[fil_iter+1][ 48+:8] = weight[get_WGT_index(filter_set + (fil_iter>>1), 28)][get_WGT_offset(28)+:8];
      win[fil_iter+1][ 56+:8] = weight[get_WGT_index(filter_set + (fil_iter>>1), 29)][get_WGT_offset(29)+:8];
      win[fil_iter+1][ 64+:8] = weight[get_WGT_index(filter_set + (fil_iter>>1), 30)][get_WGT_offset(30)+:8];
      win[fil_iter+1][ 72+:8] = weight[get_WGT_index(filter_set + (fil_iter>>1), 32)][get_WGT_offset(32)+:8];
      win[fil_iter+1][ 80+:8] = weight[get_WGT_index(filter_set + (fil_iter>>1), 33)][get_WGT_offset(33)+:8];
      win[fil_iter+1][ 88+:8] = weight[get_WGT_index(filter_set + (fil_iter>>1), 34)][get_WGT_offset(34)+:8];
      win[fil_iter+1][ 96+:8] = 1'b0;
      win[fil_iter+1][104+:8] = 1'b0;
      win[fil_iter+1][112+:8] = 1'b0;
      win[fil_iter+1][120+:8] = 1'b0;
    end


    // --------------------------------------------
    // MAC array 0 : IFM
    // --------------------------------------------
    for (mac_iter = 0; mac_iter < 8; mac_iter = mac_iter + 2) begin
      // MAC16_0, MAC16_2, MAC16_4, MAC16_6
      din_mac_array_0[mac_iter][  0+:8] = ( is_first_row(row_array_0) || is_first_col(col_array_0) ) ? 8'd0 
                                        : in_img[get_IFM_index(row_array_0-1, col_array_0-1, 0)][get_IFM_offset(chan_set  )+:8];

      din_mac_array_0[mac_iter][  8+:8] = ( is_first_row(row_array_0) || is_first_col(col_array_0) ) ? 8'd0 
                                        : in_img[get_IFM_index(row_array_0-1, col_array_0-1, 0)][get_IFM_offset(chan_set+1)+:8];

      din_mac_array_0[mac_iter][ 16+:8] = ( is_first_row(row_array_0) || is_first_col(col_array_0) ) ? 8'd0 
                                        : in_img[get_IFM_index(row_array_0-1, col_array_0-1, 0)][get_IFM_offset(chan_set+2)+:8];

      din_mac_array_0[mac_iter][ 24+:8] = ( is_first_row(row_array_0)                              ) ? 8'd0 
                                        : in_img[get_IFM_index(row_array_0-1, col_array_0  , 0)][get_IFM_offset(chan_set  )+:8];

      din_mac_array_0[mac_iter][ 32+:8] = ( is_first_row(row_array_0)                              ) ? 8'd0 
                                        : in_img[get_IFM_index(row_array_0-1, col_array_0  , 0)][get_IFM_offset(chan_set+1)+:8];

      din_mac_array_0[mac_iter][ 40+:8] = ( is_first_row(row_array_0)                              ) ? 8'd0 
                                        : in_img[get_IFM_index(row_array_0-1, col_array_0  , 0)][get_IFM_offset(chan_set+2)+:8];

      din_mac_array_0[mac_iter][ 48+:8] = ( is_first_row(row_array_0) ||  is_last_col(col_array_0) ) ? 8'd0 
                                        : in_img[get_IFM_index(row_array_0-1, col_array_0+1, 0)][get_IFM_offset(chan_set  )+:8];

      din_mac_array_0[mac_iter][ 56+:8] = ( is_first_row(row_array_0) ||  is_last_col(col_array_0) ) ? 8'd0 
                                        : in_img[get_IFM_index(row_array_0-1, col_array_0+1, 0)][get_IFM_offset(chan_set+1)+:8];

      din_mac_array_0[mac_iter][ 64+:8] = ( is_first_row(row_array_0) ||  is_last_col(col_array_0) ) ? 8'd0 
                                        : in_img[get_IFM_index(row_array_0-1, col_array_0+1, 0)][get_IFM_offset(chan_set+2)+:8];

      din_mac_array_0[mac_iter][ 72+:8] = (                              is_first_col(col_array_0) ) ? 8'd0 
                                        : in_img[get_IFM_index(row_array_0  , col_array_0-1, 0)][get_IFM_offset(chan_set  )+:8];

      din_mac_array_0[mac_iter][ 80+:8] = (                              is_first_col(col_array_0) ) ? 8'd0 
                                        : in_img[get_IFM_index(row_array_0  , col_array_0-1, 0)][get_IFM_offset(chan_set+1)+:8];

      din_mac_array_0[mac_iter][ 88+:8] = (                              is_first_col(col_array_0) ) ? 8'd0 
                                        : in_img[get_IFM_index(row_array_0  , col_array_0-1, 0)][get_IFM_offset(chan_set+2)+:8];

      din_mac_array_0[mac_iter][ 96+:8] = in_img[get_IFM_index(row_array_0  , col_array_0  , 0)][get_IFM_offset(chan_set  )+:8];

      din_mac_array_0[mac_iter][104+:8] = in_img[get_IFM_index(row_array_0  , col_array_0  , 0)][get_IFM_offset(chan_set+1)+:8];

      din_mac_array_0[mac_iter][112+:8] = in_img[get_IFM_index(row_array_0  , col_array_0  , 0)][get_IFM_offset(chan_set+2)+:8];

      din_mac_array_0[mac_iter][120+:8] = 1'b0;

      // MAC16_1, MAC16_3, MAC16_5, MAC16_7
      din_mac_array_0[mac_iter+1][  0+:8] = (                               is_last_col(col_array_0) ) ? 8'd0 
                                          : in_img[get_IFM_index(row_array_0  , col_array_0+1, 0)][get_IFM_offset(chan_set  )+:8];

      din_mac_array_0[mac_iter+1][  8+:8] = (                               is_last_col(col_array_0) ) ? 8'd0 
                                          : in_img[get_IFM_index(row_array_0  , col_array_0+1, 0)][get_IFM_offset(chan_set+1)+:8];

      din_mac_array_0[mac_iter+1][ 16+:8] = (                               is_last_col(col_array_0) ) ? 8'd0 
                                          : in_img[get_IFM_index(row_array_0  , col_array_0+1, 0)][get_IFM_offset(chan_set+2)+:8];

      din_mac_array_0[mac_iter+1][ 24+:8] = (  is_last_row(row_array_0) || is_first_col(col_array_0) ) ? 8'd0 
                                          : in_img[get_IFM_index(row_array_0+1, col_array_0-1, 0)][get_IFM_offset(chan_set  )+:8];

      din_mac_array_0[mac_iter+1][ 32+:8] = (  is_last_row(row_array_0) || is_first_col(col_array_0) ) ? 8'd0 
                                          : in_img[get_IFM_index(row_array_0+1, col_array_0-1, 0)][get_IFM_offset(chan_set+1)+:8];

      din_mac_array_0[mac_iter+1][ 40+:8] = (  is_last_row(row_array_0) || is_first_col(col_array_0) ) ? 8'd0 
                                          : in_img[get_IFM_index(row_array_0+1, col_array_0-1, 0)][get_IFM_offset(chan_set+2)+:8];

      din_mac_array_0[mac_iter+1][ 48+:8] = (  is_last_row(row_array_0)                              ) ? 8'd0 
                                          : in_img[get_IFM_index(row_array_0+1, col_array_0  , 0)][get_IFM_offset(chan_set  )+:8];

      din_mac_array_0[mac_iter+1][ 56+:8] = (  is_last_row(row_array_0)                              ) ? 8'd0 
                                          : in_img[get_IFM_index(row_array_0+1, col_array_0  , 0)][get_IFM_offset(chan_set+1)+:8];

      din_mac_array_0[mac_iter+1][ 64+:8] = (  is_last_row(row_array_0)                              ) ? 8'd0 
                                          : in_img[get_IFM_index(row_array_0+1, col_array_0  , 0)][get_IFM_offset(chan_set+2)+:8];

      din_mac_array_0[mac_iter+1][ 72+:8] = (  is_last_row(row_array_0) ||  is_last_col(col_array_0) ) ? 8'd0 
                                          : in_img[get_IFM_index(row_array_0+1, col_array_0+1, 0)][get_IFM_offset(chan_set  )+:8];

      din_mac_array_0[mac_iter+1][ 80+:8] = (  is_last_row(row_array_0) ||  is_last_col(col_array_0) ) ? 8'd0 
                                          : in_img[get_IFM_index(row_array_0+1, col_array_0+1, 0)][get_IFM_offset(chan_set+1)+:8];

      din_mac_array_0[mac_iter+1][ 88+:8] = (  is_last_row(row_array_0) ||  is_last_col(col_array_0) ) ? 8'd0 
                                          : in_img[get_IFM_index(row_array_0+1, col_array_0+1, 0)][get_IFM_offset(chan_set+2)+:8];

      din_mac_array_0[mac_iter+1][ 96+:8] = 1'b0;

      din_mac_array_0[mac_iter+1][104+:8] = 1'b0;

      din_mac_array_0[mac_iter+1][112+:8] = 1'b0;

      din_mac_array_0[mac_iter+1][120+:8] = 1'b0;
    end
    // MAC16_8 is idle
    din_mac_array_0[8] = 1'b0;


    // --------------------------------------------
    // MAC array 1 : IFM
    // --------------------------------------------
    for (mac_iter = 0; mac_iter < 8; mac_iter = mac_iter + 2) begin
      // MAC16_0, MAC16_2, MAC16_4, MAC16_6
      din_mac_array_1[mac_iter][  0+:8] = ( is_first_row(row_array_1) || is_first_col(col_array_1) ) ? 8'd0 
                                        : in_img[get_IFM_index(row_array_1-1, col_array_1-1, 0)][get_IFM_offset(chan_set  )+:8];

      din_mac_array_1[mac_iter][  8+:8] = ( is_first_row(row_array_1) || is_first_col(col_array_1) ) ? 8'd0 
                                        : in_img[get_IFM_index(row_array_1-1, col_array_1-1, 0)][get_IFM_offset(chan_set+1)+:8];

      din_mac_array_1[mac_iter][ 16+:8] = ( is_first_row(row_array_1) || is_first_col(col_array_1) ) ? 8'd0 
                                        : in_img[get_IFM_index(row_array_1-1, col_array_1-1, 0)][get_IFM_offset(chan_set+2)+:8];

      din_mac_array_1[mac_iter][ 24+:8] = ( is_first_row(row_array_1)                              ) ? 8'd0 
                                        : in_img[get_IFM_index(row_array_1-1, col_array_1  , 0)][get_IFM_offset(chan_set  )+:8];

      din_mac_array_1[mac_iter][ 32+:8] = ( is_first_row(row_array_1)                              ) ? 8'd0 
                                        : in_img[get_IFM_index(row_array_1-1, col_array_1  , 0)][get_IFM_offset(chan_set+1)+:8];

      din_mac_array_1[mac_iter][ 40+:8] = ( is_first_row(row_array_1)                              ) ? 8'd0 
                                        : in_img[get_IFM_index(row_array_1-1, col_array_1  , 0)][get_IFM_offset(chan_set+2)+:8];

      din_mac_array_1[mac_iter][ 48+:8] = ( is_first_row(row_array_1) ||  is_last_col(col_array_1) ) ? 8'd0 
                                        : in_img[get_IFM_index(row_array_1-1, col_array_1+1, 0)][get_IFM_offset(chan_set  )+:8];

      din_mac_array_1[mac_iter][ 56+:8] = ( is_first_row(row_array_1) ||  is_last_col(col_array_1) ) ? 8'd0 
                                        : in_img[get_IFM_index(row_array_1-1, col_array_1+1, 0)][get_IFM_offset(chan_set+1)+:8];

      din_mac_array_1[mac_iter][ 64+:8] = ( is_first_row(row_array_1) ||  is_last_col(col_array_1) ) ? 8'd0 
                                        : in_img[get_IFM_index(row_array_1-1, col_array_1+1, 0)][get_IFM_offset(chan_set+2)+:8];

      din_mac_array_1[mac_iter][ 72+:8] = (                              is_first_col(col_array_1) ) ? 8'd0 
                                        : in_img[get_IFM_index(row_array_1  , col_array_1-1, 0)][get_IFM_offset(chan_set  )+:8];

      din_mac_array_1[mac_iter][ 80+:8] = (                              is_first_col(col_array_1) ) ? 8'd0 
                                        : in_img[get_IFM_index(row_array_1  , col_array_1-1, 0)][get_IFM_offset(chan_set+1)+:8];

      din_mac_array_1[mac_iter][ 88+:8] = (                              is_first_col(col_array_1) ) ? 8'd0 
                                        : in_img[get_IFM_index(row_array_1  , col_array_1-1, 0)][get_IFM_offset(chan_set+2)+:8];

      din_mac_array_1[mac_iter][ 96+:8] = in_img[get_IFM_index(row_array_1  , col_array_1  , 0)][get_IFM_offset(chan_set  )+:8];

      din_mac_array_1[mac_iter][104+:8] = in_img[get_IFM_index(row_array_1  , col_array_1  , 0)][get_IFM_offset(chan_set+1)+:8];

      din_mac_array_1[mac_iter][112+:8] = in_img[get_IFM_index(row_array_1  , col_array_1  , 0)][get_IFM_offset(chan_set+2)+:8];

      din_mac_array_1[mac_iter][120+:8] = 1'b0;

      // MAC16_1, MAC16_3, MAC16_5, MAC16_7
      din_mac_array_1[mac_iter+1][  0+:8] = (                               is_last_col(col_array_1) ) ? 8'd0 
                                          : in_img[get_IFM_index(row_array_1  , col_array_1+1, 0)][get_IFM_offset(chan_set  )+:8];

      din_mac_array_1[mac_iter+1][  8+:8] = (                               is_last_col(col_array_1) ) ? 8'd0 
                                          : in_img[get_IFM_index(row_array_1  , col_array_1+1, 0)][get_IFM_offset(chan_set+1)+:8];

      din_mac_array_1[mac_iter+1][ 16+:8] = (                               is_last_col(col_array_1) ) ? 8'd0 
                                          : in_img[get_IFM_index(row_array_1  , col_array_1+1, 0)][get_IFM_offset(chan_set+2)+:8];

      din_mac_array_1[mac_iter+1][ 24+:8] = (  is_last_row(row_array_1) || is_first_col(col_array_1) ) ? 8'd0 
                                          : in_img[get_IFM_index(row_array_1+1, col_array_1-1, 0)][get_IFM_offset(chan_set  )+:8];

      din_mac_array_1[mac_iter+1][ 32+:8] = (  is_last_row(row_array_1) || is_first_col(col_array_1) ) ? 8'd0 
                                          : in_img[get_IFM_index(row_array_1+1, col_array_1-1, 0)][get_IFM_offset(chan_set+1)+:8];

      din_mac_array_1[mac_iter+1][ 40+:8] = (  is_last_row(row_array_1) || is_first_col(col_array_1) ) ? 8'd0 
                                          : in_img[get_IFM_index(row_array_1+1, col_array_1-1, 0)][get_IFM_offset(chan_set+2)+:8];

      din_mac_array_1[mac_iter+1][ 48+:8] = (  is_last_row(row_array_1)                              ) ? 8'd0 
                                          : in_img[get_IFM_index(row_array_1+1, col_array_1  , 0)][get_IFM_offset(chan_set  )+:8];

      din_mac_array_1[mac_iter+1][ 56+:8] = (  is_last_row(row_array_1)                              ) ? 8'd0 
                                          : in_img[get_IFM_index(row_array_1+1, col_array_1  , 0)][get_IFM_offset(chan_set+1)+:8];

      din_mac_array_1[mac_iter+1][ 64+:8] = (  is_last_row(row_array_1)                              ) ? 8'd0 
                                          : in_img[get_IFM_index(row_array_1+1, col_array_1  , 0)][get_IFM_offset(chan_set+2)+:8];

      din_mac_array_1[mac_iter+1][ 72+:8] = (  is_last_row(row_array_1) ||  is_last_col(col_array_1) ) ? 8'd0 
                                          : in_img[get_IFM_index(row_array_1+1, col_array_1+1, 0)][get_IFM_offset(chan_set  )+:8];

      din_mac_array_1[mac_iter+1][ 80+:8] = (  is_last_row(row_array_1) ||  is_last_col(col_array_1) ) ? 8'd0 
                                          : in_img[get_IFM_index(row_array_1+1, col_array_1+1, 0)][get_IFM_offset(chan_set+1)+:8];

      din_mac_array_1[mac_iter+1][ 88+:8] = (  is_last_row(row_array_1) ||  is_last_col(col_array_1) ) ? 8'd0 
                                          : in_img[get_IFM_index(row_array_1+1, col_array_1+1, 0)][get_IFM_offset(chan_set+2)+:8];

      din_mac_array_1[mac_iter+1][ 96+:8] = 1'b0;

      din_mac_array_1[mac_iter+1][104+:8] = 1'b0;

      din_mac_array_1[mac_iter+1][112+:8] = 1'b0;

      din_mac_array_1[mac_iter+1][120+:8] = 1'b0;
    end
    // MAC16_8 is idle
    din_mac_array_1[8] = 1'b0;


    // --------------------------------------------
    // MAC array 2 : IFM
    // --------------------------------------------
    for (mac_iter = 0; mac_iter < 8; mac_iter = mac_iter + 2) begin
      // MAC16_0, MAC16_2, MAC16_4, MAC16_6
      din_mac_array_2[mac_iter][  0+:8] = ( is_first_row(row_array_2) || is_first_col(col_array_2) ) ? 8'd0 
                                        : in_img[get_IFM_index(row_array_2-1, col_array_2-1, 0)][get_IFM_offset(chan_set  )+:8];

      din_mac_array_2[mac_iter][  8+:8] = ( is_first_row(row_array_2) || is_first_col(col_array_2) ) ? 8'd0 
                                        : in_img[get_IFM_index(row_array_2-1, col_array_2-1, 0)][get_IFM_offset(chan_set+1)+:8];

      din_mac_array_2[mac_iter][ 16+:8] = ( is_first_row(row_array_2) || is_first_col(col_array_2) ) ? 8'd0 
                                        : in_img[get_IFM_index(row_array_2-1, col_array_2-1, 0)][get_IFM_offset(chan_set+2)+:8];

      din_mac_array_2[mac_iter][ 24+:8] = ( is_first_row(row_array_2)                              ) ? 8'd0 
                                        : in_img[get_IFM_index(row_array_2-1, col_array_2  , 0)][get_IFM_offset(chan_set  )+:8];

      din_mac_array_2[mac_iter][ 32+:8] = ( is_first_row(row_array_2)                              ) ? 8'd0 
                                        : in_img[get_IFM_index(row_array_2-1, col_array_2  , 0)][get_IFM_offset(chan_set+1)+:8];

      din_mac_array_2[mac_iter][ 40+:8] = ( is_first_row(row_array_2)                              ) ? 8'd0 
                                        : in_img[get_IFM_index(row_array_2-1, col_array_2  , 0)][get_IFM_offset(chan_set+2)+:8];

      din_mac_array_2[mac_iter][ 48+:8] = ( is_first_row(row_array_2) ||  is_last_col(col_array_2) ) ? 8'd0 
                                        : in_img[get_IFM_index(row_array_2-1, col_array_2+1, 0)][get_IFM_offset(chan_set  )+:8];

      din_mac_array_2[mac_iter][ 56+:8] = ( is_first_row(row_array_2) ||  is_last_col(col_array_2) ) ? 8'd0 
                                        : in_img[get_IFM_index(row_array_2-1, col_array_2+1, 0)][get_IFM_offset(chan_set+1)+:8];

      din_mac_array_2[mac_iter][ 64+:8] = ( is_first_row(row_array_2) ||  is_last_col(col_array_2) ) ? 8'd0 
                                        : in_img[get_IFM_index(row_array_2-1, col_array_2+1, 0)][get_IFM_offset(chan_set+2)+:8];

      din_mac_array_2[mac_iter][ 72+:8] = (                              is_first_col(col_array_2) ) ? 8'd0 
                                        : in_img[get_IFM_index(row_array_2  , col_array_2-1, 0)][get_IFM_offset(chan_set  )+:8];

      din_mac_array_2[mac_iter][ 80+:8] = (                              is_first_col(col_array_2) ) ? 8'd0 
                                        : in_img[get_IFM_index(row_array_2  , col_array_2-1, 0)][get_IFM_offset(chan_set+1)+:8];

      din_mac_array_2[mac_iter][ 88+:8] = (                              is_first_col(col_array_2) ) ? 8'd0 
                                        : in_img[get_IFM_index(row_array_2  , col_array_2-1, 0)][get_IFM_offset(chan_set+2)+:8];

      din_mac_array_2[mac_iter][ 96+:8] = in_img[get_IFM_index(row_array_2  , col_array_2  , 0)][get_IFM_offset(chan_set  )+:8];

      din_mac_array_2[mac_iter][104+:8] = in_img[get_IFM_index(row_array_2  , col_array_2  , 0)][get_IFM_offset(chan_set+1)+:8];

      din_mac_array_2[mac_iter][112+:8] = in_img[get_IFM_index(row_array_2  , col_array_2  , 0)][get_IFM_offset(chan_set+2)+:8];

      din_mac_array_2[mac_iter][120+:8] = 1'b0;

      // MAC16_1, MAC16_3, MAC16_5, MAC16_7
      din_mac_array_2[mac_iter+1][  0+:8] = (                               is_last_col(col_array_2) ) ? 8'd0 
                                          : in_img[get_IFM_index(row_array_2  , col_array_2+1, 0)][get_IFM_offset(chan_set  )+:8];

      din_mac_array_2[mac_iter+1][  8+:8] = (                               is_last_col(col_array_2) ) ? 8'd0 
                                          : in_img[get_IFM_index(row_array_2  , col_array_2+1, 0)][get_IFM_offset(chan_set+1)+:8];

      din_mac_array_2[mac_iter+1][ 16+:8] = (                               is_last_col(col_array_2) ) ? 8'd0 
                                          : in_img[get_IFM_index(row_array_2  , col_array_2+1, 0)][get_IFM_offset(chan_set+2)+:8];

      din_mac_array_2[mac_iter+1][ 24+:8] = (  is_last_row(row_array_2) || is_first_col(col_array_2) ) ? 8'd0 
                                          : in_img[get_IFM_index(row_array_2+1, col_array_2-1, 0)][get_IFM_offset(chan_set  )+:8];

      din_mac_array_2[mac_iter+1][ 32+:8] = (  is_last_row(row_array_2) || is_first_col(col_array_2) ) ? 8'd0 
                                          : in_img[get_IFM_index(row_array_2+1, col_array_2-1, 0)][get_IFM_offset(chan_set+1)+:8];

      din_mac_array_2[mac_iter+1][ 40+:8] = (  is_last_row(row_array_2) || is_first_col(col_array_2) ) ? 8'd0 
                                          : in_img[get_IFM_index(row_array_2+1, col_array_2-1, 0)][get_IFM_offset(chan_set+2)+:8];

      din_mac_array_2[mac_iter+1][ 48+:8] = (  is_last_row(row_array_2)                              ) ? 8'd0 
                                          : in_img[get_IFM_index(row_array_2+1, col_array_2  , 0)][get_IFM_offset(chan_set  )+:8];

      din_mac_array_2[mac_iter+1][ 56+:8] = (  is_last_row(row_array_2)                              ) ? 8'd0 
                                          : in_img[get_IFM_index(row_array_2+1, col_array_2  , 0)][get_IFM_offset(chan_set+1)+:8];

      din_mac_array_2[mac_iter+1][ 64+:8] = (  is_last_row(row_array_2)                              ) ? 8'd0 
                                          : in_img[get_IFM_index(row_array_2+1, col_array_2  , 0)][get_IFM_offset(chan_set+2)+:8];

      din_mac_array_2[mac_iter+1][ 72+:8] = (  is_last_row(row_array_2) ||  is_last_col(col_array_2) ) ? 8'd0 
                                          : in_img[get_IFM_index(row_array_2+1, col_array_2+1, 0)][get_IFM_offset(chan_set  )+:8];

      din_mac_array_2[mac_iter+1][ 80+:8] = (  is_last_row(row_array_2) ||  is_last_col(col_array_2) ) ? 8'd0 
                                          : in_img[get_IFM_index(row_array_2+1, col_array_2+1, 0)][get_IFM_offset(chan_set+1)+:8];

      din_mac_array_2[mac_iter+1][ 88+:8] = (  is_last_row(row_array_2) ||  is_last_col(col_array_2) ) ? 8'd0 
                                          : in_img[get_IFM_index(row_array_2+1, col_array_2+1, 0)][get_IFM_offset(chan_set+2)+:8];

      din_mac_array_2[mac_iter+1][ 96+:8] = 1'b0;

      din_mac_array_2[mac_iter+1][104+:8] = 1'b0;

      din_mac_array_2[mac_iter+1][112+:8] = 1'b0;

      din_mac_array_2[mac_iter+1][120+:8] = 1'b0;
    end
    // MAC16_8 is idle
    din_mac_array_2[8] = 1'b0;


    // --------------------------------------------
    // MAC array 3 : IFM
    // --------------------------------------------
    for (mac_iter = 0; mac_iter < 8; mac_iter = mac_iter + 2) begin
      // MAC16_0, MAC16_2, MAC16_4, MAC16_6
      din_mac_array_3[mac_iter][  0+:8] = ( is_first_row(row_array_3) || is_first_col(col_array_3) ) ? 8'd0 
                                        : in_img[get_IFM_index(row_array_3-1, col_array_3-1, 0)][get_IFM_offset(chan_set  )+:8];

      din_mac_array_3[mac_iter][  8+:8] = ( is_first_row(row_array_3) || is_first_col(col_array_3) ) ? 8'd0 
                                        : in_img[get_IFM_index(row_array_3-1, col_array_3-1, 0)][get_IFM_offset(chan_set+1)+:8];

      din_mac_array_3[mac_iter][ 16+:8] = ( is_first_row(row_array_3) || is_first_col(col_array_3) ) ? 8'd0 
                                        : in_img[get_IFM_index(row_array_3-1, col_array_3-1, 0)][get_IFM_offset(chan_set+2)+:8];

      din_mac_array_3[mac_iter][ 24+:8] = ( is_first_row(row_array_3)                              ) ? 8'd0 
                                        : in_img[get_IFM_index(row_array_3-1, col_array_3  , 0)][get_IFM_offset(chan_set  )+:8];

      din_mac_array_3[mac_iter][ 32+:8] = ( is_first_row(row_array_3)                              ) ? 8'd0 
                                        : in_img[get_IFM_index(row_array_3-1, col_array_3  , 0)][get_IFM_offset(chan_set+1)+:8];

      din_mac_array_3[mac_iter][ 40+:8] = ( is_first_row(row_array_3)                              ) ? 8'd0 
                                        : in_img[get_IFM_index(row_array_3-1, col_array_3  , 0)][get_IFM_offset(chan_set+2)+:8];

      din_mac_array_3[mac_iter][ 48+:8] = ( is_first_row(row_array_3) ||  is_last_col(col_array_3) ) ? 8'd0 
                                        : in_img[get_IFM_index(row_array_3-1, col_array_3+1, 0)][get_IFM_offset(chan_set  )+:8];

      din_mac_array_3[mac_iter][ 56+:8] = ( is_first_row(row_array_3) ||  is_last_col(col_array_3) ) ? 8'd0 
                                        : in_img[get_IFM_index(row_array_3-1, col_array_3+1, 0)][get_IFM_offset(chan_set+1)+:8];

      din_mac_array_3[mac_iter][ 64+:8] = ( is_first_row(row_array_3) ||  is_last_col(col_array_3) ) ? 8'd0 
                                        : in_img[get_IFM_index(row_array_3-1, col_array_3+1, 0)][get_IFM_offset(chan_set+2)+:8];

      din_mac_array_3[mac_iter][ 72+:8] = (                              is_first_col(col_array_3) ) ? 8'd0 
                                        : in_img[get_IFM_index(row_array_3  , col_array_3-1, 0)][get_IFM_offset(chan_set  )+:8];

      din_mac_array_3[mac_iter][ 80+:8] = (                              is_first_col(col_array_3) ) ? 8'd0 
                                        : in_img[get_IFM_index(row_array_3  , col_array_3-1, 0)][get_IFM_offset(chan_set+1)+:8];

      din_mac_array_3[mac_iter][ 88+:8] = (                              is_first_col(col_array_3) ) ? 8'd0 
                                        : in_img[get_IFM_index(row_array_3  , col_array_3-1, 0)][get_IFM_offset(chan_set+2)+:8];

      din_mac_array_3[mac_iter][ 96+:8] = in_img[get_IFM_index(row_array_3  , col_array_3  , 0)][get_IFM_offset(chan_set  )+:8];

      din_mac_array_3[mac_iter][104+:8] = in_img[get_IFM_index(row_array_3  , col_array_3  , 0)][get_IFM_offset(chan_set+1)+:8];

      din_mac_array_3[mac_iter][112+:8] = in_img[get_IFM_index(row_array_3  , col_array_3  , 0)][get_IFM_offset(chan_set+2)+:8];

      din_mac_array_3[mac_iter][120+:8] = 1'b0;

      // MAC16_1, MAC16_3, MAC16_5, MAC16_7
      din_mac_array_3[mac_iter+1][  0+:8] = (                               is_last_col(col_array_3) ) ? 8'd0 
                                          : in_img[get_IFM_index(row_array_3  , col_array_3+1, 0)][get_IFM_offset(chan_set  )+:8];

      din_mac_array_3[mac_iter+1][  8+:8] = (                               is_last_col(col_array_3) ) ? 8'd0 
                                          : in_img[get_IFM_index(row_array_3  , col_array_3+1, 0)][get_IFM_offset(chan_set+1)+:8];

      din_mac_array_3[mac_iter+1][ 16+:8] = (                               is_last_col(col_array_3) ) ? 8'd0 
                                          : in_img[get_IFM_index(row_array_3  , col_array_3+1, 0)][get_IFM_offset(chan_set+2)+:8];

      din_mac_array_3[mac_iter+1][ 24+:8] = (  is_last_row(row_array_3) || is_first_col(col_array_3) ) ? 8'd0 
                                          : in_img[get_IFM_index(row_array_3+1, col_array_3-1, 0)][get_IFM_offset(chan_set  )+:8];

      din_mac_array_3[mac_iter+1][ 32+:8] = (  is_last_row(row_array_3) || is_first_col(col_array_3) ) ? 8'd0 
                                          : in_img[get_IFM_index(row_array_3+1, col_array_3-1, 0)][get_IFM_offset(chan_set+1)+:8];

      din_mac_array_3[mac_iter+1][ 40+:8] = (  is_last_row(row_array_3) || is_first_col(col_array_3) ) ? 8'd0 
                                          : in_img[get_IFM_index(row_array_3+1, col_array_3-1, 0)][get_IFM_offset(chan_set+2)+:8];

      din_mac_array_3[mac_iter+1][ 48+:8] = (  is_last_row(row_array_3)                              ) ? 8'd0 
                                          : in_img[get_IFM_index(row_array_3+1, col_array_3  , 0)][get_IFM_offset(chan_set  )+:8];

      din_mac_array_3[mac_iter+1][ 56+:8] = (  is_last_row(row_array_3)                              ) ? 8'd0 
                                          : in_img[get_IFM_index(row_array_3+1, col_array_3  , 0)][get_IFM_offset(chan_set+1)+:8];

      din_mac_array_3[mac_iter+1][ 64+:8] = (  is_last_row(row_array_3)                              ) ? 8'd0 
                                          : in_img[get_IFM_index(row_array_3+1, col_array_3  , 0)][get_IFM_offset(chan_set+2)+:8];

      din_mac_array_3[mac_iter+1][ 72+:8] = (  is_last_row(row_array_3) ||  is_last_col(col_array_3) ) ? 8'd0 
                                          : in_img[get_IFM_index(row_array_3+1, col_array_3+1, 0)][get_IFM_offset(chan_set  )+:8];

      din_mac_array_3[mac_iter+1][ 80+:8] = (  is_last_row(row_array_3) ||  is_last_col(col_array_3) ) ? 8'd0 
                                          : in_img[get_IFM_index(row_array_3+1, col_array_3+1, 0)][get_IFM_offset(chan_set+1)+:8];

      din_mac_array_3[mac_iter+1][ 88+:8] = (  is_last_row(row_array_3) ||  is_last_col(col_array_3) ) ? 8'd0 
                                          : in_img[get_IFM_index(row_array_3+1, col_array_3+1, 0)][get_IFM_offset(chan_set+2)+:8];

      din_mac_array_3[mac_iter+1][ 96+:8] = 1'b0;

      din_mac_array_3[mac_iter+1][104+:8] = 1'b0;

      din_mac_array_3[mac_iter+1][112+:8] = 1'b0;

      din_mac_array_3[mac_iter+1][120+:8] = 1'b0;
    end
    // MAC16_8 is idle
    din_mac_array_3[8] = 1'b0;
  end else begin
    
  end
end

integer i;
always @ (posedge clk) begin
	if (!rstn || conv_done) begin
    F_writedone <= 1'b0;
    W_writedone <= 1'b0;
    B_writedone <= 1'b0;
    ready_o <= 1'b0;
    valid_o <= 1'b0;
    data_out <= 1'b0;
    if (conv_done) conv_done <= 1'b1;
    else           conv_done <= 1'b0;
    state <= 1'b0;
    for (i=0; i<65535; i=i+1)
      in_img[i] = 1'b0;
    for (i=0; i<3*3*32*64; i=i+1)
      weight[i] = 1'b0;
    for (i=0; i<512; i=i+1)
      bias[i] = 1'b0;
    counter <= 1'b0;
    mac_counter <= 1'b0;
    pool_counter <= 1'b0;
    send_counter <= 1'b0;
    bias_num <= 1'b0;
    filter_set <= 1'b0;
    chan_set <= 1'b0;
    IFM_DATA_SIZE <= 1'b0;
    WGT_DATA_SIZE <= 1'b0;
    BIAS_DATA_SIZE <= 1'b0;
    OUTPUT_SIZE <= 1'b0;
    delay <= 1'b0;
    row <= 1'b0;
    col <= 1'b0;
    mac_vld_i <= 1'b0;
    for (i=0; i<9; i=i+1) begin
      din_mac_array_0[i] = 1'b0;
      din_mac_array_1[i] = 1'b0;
      din_mac_array_2[i] = 1'b0;
      din_mac_array_3[i] = 1'b0;
      win            [i] = 1'b0;
    end
    valid_pool <= 1'b0;
    result_0_exact <= 1'b0;
    result_1_exact <= 1'b0;
    result_2_exact <= 1'b0;
    result_3_exact <= 1'b0;
    mac_done <= 1'b0;
    pool_done <= 1'b0;
    send_done <= 1'b0;
	end else begin
		case (COMMAND)
      COMMAND_IDLE: begin
        counter <= 1'b0;
        ready_o <= 1'b0;
      end
      COMMAND_GET_F: begin
        if (F_writedone) begin
          counter <= 1'b0;
          ready_o <= 1'b0;
        end else if (!ready_o) begin
          IFM_DATA_SIZE <= RECEIVE_SIZE;
          counter <= 1'b0;
          ready_o <= 1'b1;
        end else if (counter == IFM_DATA_SIZE - 1) begin // last data
          in_img[counter] <= data_in;
          F_writedone <= 1'b1;
          counter <= 1'b0;
          ready_o <= 1'b0;
        end else begin
          in_img[counter] <= data_in;
          F_writedone <= 1'b0;
          counter <= counter + 1;
          ready_o <= 1'b1;
        end
      end
      COMMAND_GET_W: begin
        if (W_writedone) begin
          counter <= 1'b0;
          ready_o <= 1'b0;
        end else if (!ready_o) begin
          WGT_DATA_SIZE <= RECEIVE_SIZE;
          counter <= 1'b0;
          ready_o <= 1'b1;
        end else if (counter == WGT_DATA_SIZE - 1) begin // last data
          weight[counter] <= data_in;
          W_writedone <= 1'b1;
          counter <= 1'b0;
          ready_o <= 1'b0;
        end else begin
          weight[counter] <= data_in;
          W_writedone <= 1'b0;
          counter <= counter + 1;
          ready_o <= 1'b1;
        end
      end
      COMMAND_GET_B: begin
        if (B_writedone) begin
          counter <= 1'b0;
          ready_o <= 1'b0;
        end else if (!ready_o) begin
          BIAS_DATA_SIZE <= RECEIVE_SIZE;
          counter <= 1'b0;
          ready_o <= 1'b1;
        end else if (counter == BIAS_DATA_SIZE - 1) begin // last data
          bias[counter] <= data_in;
          B_writedone <= 1'b1;
          counter <= 1'b0;
          ready_o <= 1'b0;
        end else begin
          bias[counter] <= data_in;
          B_writedone <= 1'b0;
          counter <= counter + 1;
          ready_o <= 1'b1;
        end
      end
      COMMAND_COMPUTE: begin
        // state transition
        case (state)
          STATE_IDLE: begin
            if (!conv_done) begin
              state <= STATE_RUN;
            end else begin
              state <= STATE_IDLE;
            end
          end
          STATE_RUN: begin
            if (mac_done && pool_done && send_done) begin
              state <= STATE_DONE;
            end else begin
              state <= STATE_RUN;
            end
          end 
          STATE_DONE: begin
            state <= STATE_DONE;
          end
          default: ;
        endcase

        // control
        case (state)
          STATE_IDLE: begin
            if (!conv_done) begin
              OUTPUT_SIZE <= IFM_DATA_SIZE >> 2; // max-pooling reduces the size by 1/4
              counter <= 1'b0;
              valid_o <= 1'b0;
              row <= 1'b0;
              col <= 1'b0;
              delay <= 1'b0;
              mac_vld_i <= 1'b1;
            end
          end
          STATE_RUN: begin // Do MAC, max-pool, and data send in parallel
            // --------------------------------------------
            // convolution via MAC
            // --------------------------------------------
            if (!mac_done) begin
              if (filter_set == No - To) begin
                mac_counter <= mac_counter + 1;
                filter_set <= 1'b0;
                chan_set <= 1'b0;
              end else begin
                if (chan_set == Ni - Ti) begin
                  chan_set <= 1'b0;
                  filter_set <= filter_set + To;
                end else begin
                  chan_set <= chan_set + Ti;
                end
              end

              if (mac_counter == IFM_DATA_SIZE - 1) begin
                mac_done <= 1'b1;
              end
            end

            // --------------------------------------------
            // max-pooling
            // --------------------------------------------
            if (!pool_done) begin
              if (valid_mac) begin // start pooling
                if (is_CONV00) begin
                  valid_pool <= 1'b1;
                  result_0_exact <= find_max(mac_out[0][0], mac_out[1][0], mac_out[2][0], mac_out[3][0]);
                  result_1_exact <= find_max(mac_out[0][1], mac_out[1][1], mac_out[2][1], mac_out[3][1]);
                  result_2_exact <= find_max(mac_out[0][2], mac_out[1][2], mac_out[2][2], mac_out[3][2]);
                  result_3_exact <= find_max(mac_out[0][3], mac_out[1][3], mac_out[2][3], mac_out[3][3]);
                  bias_num <= pool_counter;
                  pool_counter <= pool_counter + 1;

                  if (pool_counter == ((OUTPUT_SIZE * No) >> 2) - 1) begin // To == 4 at CONV00; o.w., To == 1
                    pool_done <= 1'b1;
                  end
                end
              end else begin
                valid_pool <= 1'b0;
              end
            end

            // --------------------------------------------
            // data send
            // --------------------------------------------
            if (!send_done) begin
              if (valid_pool) begin
                if (is_CONV00) begin
                  if (bias_num[1:0] == 2'b11) begin
                    valid_o <= 1'b1;
                    data_out[{bias_num[1:0], {5{1'b0}}}+:32] <= result_buffer;
                    send_counter <= send_counter + 1;

                    if (send_counter == OUTPUT_SIZE - 1) begin
                      send_done <= 1'b1;
                    end
                  end else begin
                    valid_o <= 1'b0;
                    data_out[{bias_num[1:0], {5{1'b0}}}+:32] <= result_buffer;
                    send_counter <= send_counter;
                  end               
                end
              end else begin
                valid_o <= 1'b0;
              end
            end

            // --------------------------------------------
            // row, col indexing
            // --------------------------------------------
            if (delay == FRAME_DELAY - 1) begin
              if (col == IFM_WIDTH - Tc) begin
                col <= 1'b0;
                row <= row + Tr;
                delay <= 1'b0;
              end else begin
                col <= col + Tc;
                delay <= 1'b0;
              end
            end else begin
              col <= col;
              row <= row;
              delay <= delay + 1;
            end
          end
          STATE_DONE: begin
            conv_done <= 1'b1;
          end
          default: ;
        endcase
      end
      default: ;
    endcase
	end
end

// MAC Arrays
mac_array m_mac_array_0(
  // inputs
  .clk        (clk), 
  .rstn       (rstn), 
  .vld_i      (mac_vld_i),
  .is_CONV00  (is_CONV00),

  .win_0      (win[0]), 
  .win_1      (win[1]),
  .win_2      (win[2]), 
  .win_3      (win[3]),
  .win_4      (win[4]), 
  .win_5      (win[5]),
  .win_6      (win[6]), 
  .win_7      (win[7]),
  .win_8      (win[8]),

  .din_0      (din_mac_array_0[0]), 
  .din_1      (din_mac_array_0[1]),
  .din_2      (din_mac_array_0[2]), 
  .din_3      (din_mac_array_0[3]),
  .din_4      (din_mac_array_0[4]), 
  .din_5      (din_mac_array_0[5]),
  .din_6      (din_mac_array_0[6]), 
  .din_7      (din_mac_array_0[7]),
  .din_8      (din_mac_array_0[8]),
  
  // outputs
  .acc_o_0    (mac_out[0][0]), 
  .acc_o_1    (mac_out[0][1]), 
  .acc_o_2    (mac_out[0][2]), 
  .acc_o_3    (mac_out[0][3]), 
  .vld_o      (m_mac_vld_o[0])
);
mac_array m_mac_array_1(
  // inputs
  .clk        (clk), 
  .rstn       (rstn), 
  .vld_i      (mac_vld_i),
  .is_CONV00  (is_CONV00),

  .win_0      (win[0]), 
  .win_1      (win[1]),
  .win_2      (win[2]), 
  .win_3      (win[3]),
  .win_4      (win[4]), 
  .win_5      (win[5]),
  .win_6      (win[6]), 
  .win_7      (win[7]),
  .win_8      (win[8]),

  .din_0      (din_mac_array_1[0]), 
  .din_1      (din_mac_array_1[1]),
  .din_2      (din_mac_array_1[2]), 
  .din_3      (din_mac_array_1[3]),
  .din_4      (din_mac_array_1[4]), 
  .din_5      (din_mac_array_1[5]),
  .din_6      (din_mac_array_1[6]), 
  .din_7      (din_mac_array_1[7]),
  .din_8      (din_mac_array_1[8]),
  
  // outputs
  .acc_o_0    (mac_out[1][0]), 
  .acc_o_1    (mac_out[1][1]), 
  .acc_o_2    (mac_out[1][2]), 
  .acc_o_3    (mac_out[1][3]), 
  .vld_o      (m_mac_vld_o[1])
);
mac_array m_mac_array_2(
  // inputs
  .clk        (clk), 
  .rstn       (rstn), 
  .vld_i      (mac_vld_i),
  .is_CONV00  (is_CONV00),

  .win_0      (win[0]), 
  .win_1      (win[1]),
  .win_2      (win[2]), 
  .win_3      (win[3]),
  .win_4      (win[4]), 
  .win_5      (win[5]),
  .win_6      (win[6]), 
  .win_7      (win[7]),
  .win_8      (win[8]),

  .din_0      (din_mac_array_2[0]), 
  .din_1      (din_mac_array_2[1]),
  .din_2      (din_mac_array_2[2]), 
  .din_3      (din_mac_array_2[3]),
  .din_4      (din_mac_array_2[4]), 
  .din_5      (din_mac_array_2[5]),
  .din_6      (din_mac_array_2[6]), 
  .din_7      (din_mac_array_2[7]),
  .din_8      (din_mac_array_2[8]),
  
  // outputs
  .acc_o_0    (mac_out[2][0]), 
  .acc_o_1    (mac_out[2][1]), 
  .acc_o_2    (mac_out[2][2]), 
  .acc_o_3    (mac_out[2][3]), 
  .vld_o      (m_mac_vld_o[2])
);
mac_array m_mac_array_3(
  // inputs
  .clk        (clk), 
  .rstn       (rstn), 
  .vld_i      (mac_vld_i),
  .is_CONV00  (is_CONV00),

  .win_0      (win[0]), 
  .win_1      (win[1]),
  .win_2      (win[2]), 
  .win_3      (win[3]),
  .win_4      (win[4]), 
  .win_5      (win[5]),
  .win_6      (win[6]), 
  .win_7      (win[7]),
  .win_8      (win[8]),

  .din_0      (din_mac_array_3[0]), 
  .din_1      (din_mac_array_3[1]),
  .din_2      (din_mac_array_3[2]), 
  .din_3      (din_mac_array_3[3]),
  .din_4      (din_mac_array_3[4]), 
  .din_5      (din_mac_array_3[5]),
  .din_6      (din_mac_array_3[6]), 
  .din_7      (din_mac_array_3[7]),
  .din_8      (din_mac_array_3[8]),
  
  // outputs
  .acc_o_0    (mac_out[3][0]), 
  .acc_o_1    (mac_out[3][1]), 
  .acc_o_2    (mac_out[3][2]), 
  .acc_o_3    (mac_out[3][3]), 
  .vld_o      (m_mac_vld_o[3])
);

endmodule
