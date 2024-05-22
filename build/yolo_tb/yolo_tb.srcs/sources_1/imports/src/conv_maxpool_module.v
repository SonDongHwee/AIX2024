`timescale 1ns / 1ps

module conv_maxpool_module(
  /* Input ports */
  // layer configuration
  input       [15:0] IFM_WIDTH,
  input       [15:0] IFM_HEIGHT,
  input       [ 3:0] Tr,
  input       [ 3:0] Tc,
  input       [ 4:0] Ti,
  input       [ 3:0] To,
  input       [15:0] Ni,
  input       [15:0] No,
  input       [15:0] SCALE_FACTOR,
  input       [15:0] NEXT_LAYER_INPUT_M,
  input              is_CONV00,
  input              is_1x1,
  input              is_relu,
  // input              is_maxpool,

  // basic signals
  input              clk,
  input              rstn,
  input              conv_start,

  // weight-related signals
  input              valid_w,
  input      [127:0] data_in_w0,
  input      [127:0] data_in_w1,
  input      [127:0] data_in_w2,
  input      [127:0] data_in_w3,
  input      [127:0] data_in_w4,
  input      [127:0] data_in_w5,
  input      [127:0] data_in_w6,
  input      [127:0] data_in_w7,
  input      [127:0] data_in_w8,

  // bias-related signals
  input              valid_b,
  input      [ 31:0] data_in_b,

  // ifm-related signals
  input              valid_f,
  input     [1023:0] data_in_f,
  
  /* Output ports */
  // done signals
  output reg         conv_done,

  // ready signals
  output reg         ready_w,
  output reg         ready_b,
  output reg         ready_f,

  // ofm related signals
  output reg         is_first_row,
  output reg         is_first_col,
  output reg         is_last_row,
  output reg         is_last_col,
  output reg         valid_o0,
  output reg         valid_o1,
  output reg [255:0] data_out0,
  output reg [255:0] data_out1
  // additional ports...
);
// --------------------------------------------
// FSM states
// --------------------------------------------
reg [3:0] state;
localparam STATE_IDLE     = 4'b0000;
localparam STATE_GET_B    = 4'b0001;
localparam STATE_GET_F    = 4'b0010;
localparam STATE_RUN      = 4'b0011;
localparam STATE_DONE     = 4'b0100;

// --------------------------------------------
// Registers or BRAMs
// --------------------------------------------
reg [31:0] in_img [0:2048]; // 4x4xNi (maximum value of 512) 8-bit = 32-bit x 2048
reg [31:0] weight [0:36];   // 3x3x16 8-bit = 32-bit x 36
reg [31:0]   bias [0:256];  // No (maximum value of 512) 16-bit = 32-bit x 256

// ifm tiling related variables
localparam tile_a = 2'b00;
localparam tile_b = 2'b01;
localparam tile_c = 2'b10;
localparam tile_d = 2'b11;
reg [ 1:0] tile;
reg [31:0] feamap_offset;
reg [31:0] chan_set_f;

wire [31:0] tile_separator;
assign tile_separator = Ni >> 5;

reg         wait_get_f;
wire [31:0] frame_mask;
wire        frame_done;
assign frame_mask = (No >> 5) - 1;
assign frame_done = is_CONV00 ? 1'b0 : ( // Not implemented yet
                    is_1x1    ? 1'b0 : ( // Not implemented yet
                                !send_done && valid_pool && ((send_counter & frame_mask) == frame_mask) && (bias_counter[4:0] == 31)));

integer ff, ww;
// buffer controller
reg [31:0] debug_getAddr [0:31];
always @ (*) begin
  if (ena_b) begin
    bias[addr_b] = din_b;
  end

  if (ena_f) begin
    if      (addr_f <     tile_separator) tile = tile_a;
    else if (addr_f < 2 * tile_separator) tile = tile_b;
    else if (addr_f < 3 * tile_separator) tile = tile_c;
    else                                  tile = tile_d;
    case (tile)
      tile_a : feamap_offset = 1'b0;
      tile_b : feamap_offset =  8 << Ni_BITSHIFT;
      tile_c : feamap_offset =  2 << Ni_BITSHIFT;
      tile_d : feamap_offset = 10 << Ni_BITSHIFT;
    endcase
    for(ff = 0; ff < 1024; ff = ff + 32) begin
      in_img[getAddr(ff)] = din_f[ff+:32];
      // debug_getAddr[ff>>5] = getAddr(ff);
    end
  end

  if (ready_w && valid_w) begin
    for (ww = 0; ww < 4; ww = ww + 1) begin
      weight[ww     ] = data_in_w0[32*ww+:32];
      weight[ww +  4] = data_in_w1[32*ww+:32];
      weight[ww +  8] = data_in_w2[32*ww+:32];
      weight[ww + 12] = data_in_w3[32*ww+:32];
      weight[ww + 16] = data_in_w4[32*ww+:32];
      weight[ww + 20] = data_in_w5[32*ww+:32];
      weight[ww + 24] = data_in_w6[32*ww+:32];
      weight[ww + 28] = data_in_w7[32*ww+:32];
      weight[ww + 32] = data_in_w8[32*ww+:32];
    end
  end
end

// --------------------------------------------
// Local variables
// --------------------------------------------
// fixed values for each layer
wire [31:0] IFM_DATA_SIZE;
wire [31:0] WGT_DATA_SIZE;
wire [31:0] BIAS_DATA_SIZE;
wire [31:0] OUTPUT_SIZE;
wire [ 3:0] IFM_BITSHIFT;
wire [ 3:0] Ni_BITSHIFT;
wire [31:0] FRAME_DELAY;
assign IFM_DATA_SIZE = IFM_WIDTH * IFM_HEIGHT * Ni;
assign WGT_DATA_SIZE = is_1x1 ? (Ni * No) : (9 * Ni * No);
assign BIAS_DATA_SIZE = No;
assign OUTPUT_SIZE = is_1x1 ? (IFM_HEIGHT * IFM_WIDTH) : (IFM_HEIGHT * IFM_WIDTH) >> 2; // max-pooling reduces the size by 1/4
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
assign FRAME_DELAY = is_1x1 ? (Ni * No) >> 7 : (Ni * No) >> 4; // equals to Ni * No / (Ti * To); we fix (Ti * To) as 128 or 16.

// buffer indices
reg     [31:0] b_counter;
reg            ena_b;
reg     [31:0] addr_b;
reg     [31:0] din_b;
reg            initial_get_f;
reg     [31:0] chan_counter;
reg     [31:0] f_counter;
reg            ena_f;
reg     [31:0] addr_f;
reg   [1023:0] din_f;

// counters for indexing
reg     [31:0] counter;
reg     [31:0] mac_counter;
reg     [31:0] bias_counter;
reg     [31:0] pool_counter;
reg     [31:0] send_counter;
reg     [15:0] filter_set;
reg     [15:0] chan_set;
reg     [31:0] delay;
reg     [31:0] pool_delay;

// row, col for controlling 4 MAC arrays
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

// MAC array-related variables
// inputs for MAC array; [0:8] for 9 MAC16 modules per each array
// reg         mac_vld_i;
wire   mac_vld_i;
assign mac_vld_i = ready_w && valid_w;
reg [127:0] din_mac_array_0 [0:8];
reg [127:0] din_mac_array_1 [0:8];
reg [127:0] din_mac_array_2 [0:8];
reg [127:0] din_mac_array_3 [0:8];
reg [127:0] win             [0:8];
// outputs from MAC array; [0:3] for each array
reg  [28:0] partial_sum [0:3][0:7];
wire [28:0] mac_out     [0:3][0:7];
wire        m_mac_vld_o      [0:3];
wire        valid_mac;
assign valid_mac = m_mac_vld_o[0] && m_mac_vld_o[1] && m_mac_vld_o[2] && m_mac_vld_o[3];

// max-pool controlling variables
reg         valid_pool;

// variables notifying whether each unit is done
reg         get_bias_done;
reg         get_feature_done;
reg         mac_done;
reg         pool_done;
reg         send_done;

// --------------------------------------------
// Functions
// --------------------------------------------
function automatic [31:0] getAddr(
  input [31:0] _bitPosition
);
begin : getaddr
  reg [31:0] tmp_offset;
  if      (_bitPosition >= 768) tmp_offset = 5 << Ni_BITSHIFT;
  else if (_bitPosition >= 512) tmp_offset = 4 << Ni_BITSHIFT;
  else if (_bitPosition >= 256) tmp_offset = 1 << Ni_BITSHIFT;
  else                         tmp_offset = 1'b0;
  getAddr = (feamap_offset + tmp_offset + chan_set_f + _bitPosition[7:3]) >> 2;
end  
endfunction
function automatic [31:0] get_IFM_index(
  input [ 1:0] _wbuf_row,
  input [ 1:0] _wbuf_col,
  input [15:0] _channel
); 
begin : getIFMIndex
  reg [15:0] row_offset;
  reg [15:0] col_offset;
  reg [ 3:0] multiplicand;
  row_offset = {4'd12, 4'd8, 4'd4, 4'd0};
  col_offset = {4'd3, 4'd2, 4'd1, 4'd0};
  multiplicand = row_offset[(4*_wbuf_row)+:4] + col_offset[(4*_wbuf_col)+:4];
  get_IFM_index = ((multiplicand << Ni_BITSHIFT) + _channel) >> 2;
end
endfunction
function automatic [ 4:0] get_IFM_offset(
  input [15:0] _channel
); 
	get_IFM_offset = _channel[1:0] << 3; // '<< 3', since each datum is 8-bit
endfunction
function automatic [31:0] get_WGT_index(
  // input [15:0] _fil_num,
  input [15:0] _element
);
begin : getWGTIndex
  get_WGT_index = (_element - 144 * (_element / 144)) >> 2;
end
endfunction
function automatic [ 4:0] get_WGT_offset(
  input [15:0] _element
); 
	get_WGT_offset = _element[1:0] << 3; // '<< 3', since each datum is 8-bit
endfunction
function automatic [31:0] get_BIAS_index(
  input [31:0] _bias_counter
);
  get_BIAS_index= _bias_counter >> 1;
endfunction
function automatic [ 4:0] get_BIAS_offset(
  input [31:0] _bias_counter
); 
  get_BIAS_offset = _bias_counter[0] << 4;
endfunction
function automatic [ 7:0] find_max(
  input [ 7:0] ina,
  input [ 7:0] inb,
  input [ 7:0] inc,
  input [ 7:0] ind
);
begin : findmax
  reg [ 7:0] tmp_1, tmp_2;
  tmp_1 = ($signed(ina) > $signed(inb)) ? ina : inb;
  tmp_2 = ($signed(inc) > $signed(ind)) ? inc : ind;
  find_max = ($signed(tmp_1) > $signed(tmp_2)) ? tmp_1 : tmp_2;
end
endfunction

// --------------------------------------------
// Adding Bias & Quantization & ReLU & Max-pool
// --------------------------------------------
// declare variables
reg  [28:0] mac_array_0_out [0:3];
reg  [28:0] mac_array_1_out [0:3];
reg  [28:0] mac_array_2_out [0:3];
reg  [28:0] mac_array_3_out [0:3];
wire [15:0] bias_to_add_0, bias_to_add_1, bias_to_add_2, bias_to_add_3; 
wire [28:0] mac_array_0_out_add_bias [0:3];
wire [28:0] mac_array_1_out_add_bias [0:3];
wire [28:0] mac_array_2_out_add_bias [0:3];
wire [28:0] mac_array_3_out_add_bias [0:3];
wire [ 7:0] mac_array_0_out_quant [0:3];
wire [ 7:0] mac_array_1_out_quant [0:3];
wire [ 7:0] mac_array_2_out_quant [0:3];
wire [ 7:0] mac_array_3_out_quant [0:3];
wire [ 7:0] result_0_max, result_1_max, result_2_max, result_3_max;
wire [31:0] result_buffer;

// fetch biases from BRAMs or registers
// if the layer is not CONV00, only the [0] port of each MAC array is valid
// see mac_array.v
wire [31:0] bias_mask;
assign bias_mask = No - 1;
assign bias_to_add_0 = (is_CONV00) ? (bias[get_BIAS_index({bias_counter[1:0], 2'b00})][get_BIAS_offset({bias_counter[1:0], 2'b00})+:16])
                                   : (bias[get_BIAS_index(bias_counter & bias_mask)][get_BIAS_offset(bias_counter & bias_mask)+:16]);
assign bias_to_add_1 = bias[get_BIAS_index({bias_counter[1:0], 2'b01})][get_BIAS_offset({bias_counter[1:0], 2'b01})+:16];
assign bias_to_add_2 = bias[get_BIAS_index({bias_counter[1:0], 2'b10})][get_BIAS_offset({bias_counter[1:0], 2'b10})+:16];
assign bias_to_add_3 = bias[get_BIAS_index({bias_counter[1:0], 2'b11})][get_BIAS_offset({bias_counter[1:0], 2'b11})+:16];

// add biases to the outputs of each MAC array
assign mac_array_0_out_add_bias[0] = mac_array_0_out[0] + {{13{bias_to_add_0[15]}}, bias_to_add_0};
assign mac_array_0_out_add_bias[1] = mac_array_0_out[1] + {{13{bias_to_add_1[15]}}, bias_to_add_1};
assign mac_array_0_out_add_bias[2] = mac_array_0_out[2] + {{13{bias_to_add_2[15]}}, bias_to_add_2};
assign mac_array_0_out_add_bias[3] = mac_array_0_out[3] + {{13{bias_to_add_3[15]}}, bias_to_add_3};

assign mac_array_1_out_add_bias[0] = mac_array_1_out[0] + {{13{bias_to_add_0[15]}}, bias_to_add_0};
assign mac_array_1_out_add_bias[1] = mac_array_1_out[1] + {{13{bias_to_add_1[15]}}, bias_to_add_1};
assign mac_array_1_out_add_bias[2] = mac_array_1_out[2] + {{13{bias_to_add_2[15]}}, bias_to_add_2};
assign mac_array_1_out_add_bias[3] = mac_array_1_out[3] + {{13{bias_to_add_3[15]}}, bias_to_add_3};

assign mac_array_2_out_add_bias[0] = mac_array_2_out[0] + {{13{bias_to_add_0[15]}}, bias_to_add_0};
assign mac_array_2_out_add_bias[1] = mac_array_2_out[1] + {{13{bias_to_add_1[15]}}, bias_to_add_1};
assign mac_array_2_out_add_bias[2] = mac_array_2_out[2] + {{13{bias_to_add_2[15]}}, bias_to_add_2};
assign mac_array_2_out_add_bias[3] = mac_array_2_out[3] + {{13{bias_to_add_3[15]}}, bias_to_add_3};

assign mac_array_3_out_add_bias[0] = mac_array_3_out[0] + {{13{bias_to_add_0[15]}}, bias_to_add_0};
assign mac_array_3_out_add_bias[1] = mac_array_3_out[1] + {{13{bias_to_add_1[15]}}, bias_to_add_1};
assign mac_array_3_out_add_bias[2] = mac_array_3_out[2] + {{13{bias_to_add_2[15]}}, bias_to_add_2};
assign mac_array_3_out_add_bias[3] = mac_array_3_out[3] + {{13{bias_to_add_3[15]}}, bias_to_add_3};                                                                               

// apply ReLU and quantize
genvar g;
generate
  for (g = 0; g < 4; g = g + 1) begin : gen_quant_ReLU
    assign mac_array_0_out_quant[g] = mac_array_0_out_add_bias[g][28] ? 1'b0
                                    : mac_array_0_out_add_bias[g][(SCALE_FACTOR - NEXT_LAYER_INPUT_M)+:8];
    assign mac_array_1_out_quant[g] = mac_array_1_out_add_bias[g][28] ? 1'b0
                                    : mac_array_1_out_add_bias[g][(SCALE_FACTOR - NEXT_LAYER_INPUT_M)+:8];
    assign mac_array_2_out_quant[g] = mac_array_2_out_add_bias[g][28] ? 1'b0
                                    : mac_array_2_out_add_bias[g][(SCALE_FACTOR - NEXT_LAYER_INPUT_M)+:8];
    assign mac_array_3_out_quant[g] = mac_array_3_out_add_bias[g][28] ? 1'b0
                                    : mac_array_3_out_add_bias[g][(SCALE_FACTOR - NEXT_LAYER_INPUT_M)+:8];
  end
endgenerate

// max pool
assign result_0_max = find_max(mac_array_0_out_quant[0], mac_array_1_out_quant[0], mac_array_2_out_quant[0], mac_array_3_out_quant[0]);
assign result_1_max = find_max(mac_array_0_out_quant[1], mac_array_1_out_quant[1], mac_array_2_out_quant[1], mac_array_3_out_quant[1]);
assign result_2_max = find_max(mac_array_0_out_quant[2], mac_array_1_out_quant[2], mac_array_2_out_quant[2], mac_array_3_out_quant[2]);
assign result_3_max = find_max(mac_array_0_out_quant[3], mac_array_1_out_quant[3], mac_array_2_out_quant[3], mac_array_3_out_quant[3]);

// result
assign result_buffer = {result_3_max, result_2_max, result_1_max, result_0_max};


// --------------------------------------------
// 1x1, Adding Bias & Quantization & ReLU
// --------------------------------------------
reg  [28:0] final_sum [0:3][0:7];
wire [15:0] bias_1x1 [0:7];
wire [28:0] mac_1x1_add_bias [0:3][0:7];
wire [ 7:0] mac_1x1_quant [0:3][0:7];

wire [63:0] result_1x1_0; // these are results in output channel dim.
wire [63:0] result_1x1_1; // these are results in output channel dim.
wire [63:0] result_1x1_2; // these are results in output channel dim.
wire [63:0] result_1x1_3; // these are results in output channel dim.

genvar b;
wire [31:0] bias_mask_1x1;
assign bias_mask_1x1 = (No >> 3) - 1;
generate
  for(b = 0; b < 8; b = b + 1) begin : gen_bias_1x1 // To is 8 in 1x1
    assign bias_1x1[b] = bias[(((bias_counter & bias_mask_1x1) << 3) + b) >> 1][get_BIAS_offset(((bias_counter & bias_mask_1x1) << 3) + b) +:16];
  end
endgenerate

genvar c;
generate
  for(c = 0; c < 8; c = c + 1) begin: add_bias_1x1
    assign mac_1x1_add_bias[0][c] = final_sum[0][c] + {{13{bias_1x1[c][15]}}, bias_1x1[c]};
    assign mac_1x1_add_bias[1][c] = final_sum[1][c] + {{13{bias_1x1[c][15]}}, bias_1x1[c]};
    assign mac_1x1_add_bias[2][c] = final_sum[2][c] + {{13{bias_1x1[c][15]}}, bias_1x1[c]};
    assign mac_1x1_add_bias[3][c] = final_sum[3][c] + {{13{bias_1x1[c][15]}}, bias_1x1[c]};
  end
endgenerate

genvar d;
generate
  for (d = 0; d < 8; d = d + 1) begin : quant_ReLU_1x1
    assign mac_1x1_quant[0][d] = mac_1x1_add_bias[0][d][28] ? (is_relu ? 1'b0 : mac_1x1_add_bias[0][d][(SCALE_FACTOR - NEXT_LAYER_INPUT_M)+:8] + 1)
                                                            : mac_1x1_add_bias[0][d][(SCALE_FACTOR - NEXT_LAYER_INPUT_M)+:8];
    assign mac_1x1_quant[1][d] = mac_1x1_add_bias[1][d][28] ? (is_relu ? 1'b0 : mac_1x1_add_bias[1][d][(SCALE_FACTOR - NEXT_LAYER_INPUT_M)+:8] + 1)
                                                            : mac_1x1_add_bias[1][d][(SCALE_FACTOR - NEXT_LAYER_INPUT_M)+:8];                                                        
    assign mac_1x1_quant[2][d] = mac_1x1_add_bias[2][d][28] ? (is_relu ? 1'b0 : mac_1x1_add_bias[2][d][(SCALE_FACTOR - NEXT_LAYER_INPUT_M)+:8] + 1)
                                                            : mac_1x1_add_bias[2][d][(SCALE_FACTOR - NEXT_LAYER_INPUT_M)+:8];
    assign mac_1x1_quant[3][d] = mac_1x1_add_bias[3][d][28] ? (is_relu ? 1'b0 : mac_1x1_add_bias[3][d][(SCALE_FACTOR - NEXT_LAYER_INPUT_M)+:8] + 1)
                                                            : mac_1x1_add_bias[3][d][(SCALE_FACTOR - NEXT_LAYER_INPUT_M)+:8];                                                        
  end
endgenerate

assign result_1x1_0 = {mac_1x1_quant[0][7], mac_1x1_quant[0][6], mac_1x1_quant[0][5], mac_1x1_quant[0][4], 
                        mac_1x1_quant[0][3], mac_1x1_quant[0][2], mac_1x1_quant[0][1], mac_1x1_quant[0][0]};
                
assign result_1x1_1 = {mac_1x1_quant[1][7], mac_1x1_quant[1][6], mac_1x1_quant[1][5], mac_1x1_quant[1][4], 
                        mac_1x1_quant[1][3], mac_1x1_quant[1][2], mac_1x1_quant[1][1], mac_1x1_quant[1][0]};

assign result_1x1_2 = {mac_1x1_quant[2][7], mac_1x1_quant[2][6], mac_1x1_quant[2][5], mac_1x1_quant[2][4], 
                        mac_1x1_quant[2][3], mac_1x1_quant[2][2], mac_1x1_quant[2][1], mac_1x1_quant[2][0]};

assign result_1x1_3 = {mac_1x1_quant[3][7], mac_1x1_quant[3][6], mac_1x1_quant[3][5], mac_1x1_quant[3][4], 
                        mac_1x1_quant[3][3], mac_1x1_quant[3][2], mac_1x1_quant[3][1], mac_1x1_quant[3][0]};

// --------------------------------------------
// MAC input controller
// --------------------------------------------
integer mac_iter;
integer fil_i, fil_j;
always @ (*) begin // assign din and win for 4 MAC arrays
  if (is_CONV00) begin
  /*
    // --------------------------------------------
    // MAC array 0-3 : Weight
    // --------------------------------------------
    for (fil_i = 0; fil_i < 8; fil_i = fil_i + 2) begin
      win[fil_i  ][  0+:8] = weight[get_WGT_index(filter_set + (fil_i>>1),  0)][get_WGT_offset( 0)+:8];
      win[fil_i  ][  8+:8] = weight[get_WGT_index(filter_set + (fil_i>>1), 12)][get_WGT_offset(12)+:8];
      win[fil_i  ][ 16+:8] = weight[get_WGT_index(filter_set + (fil_i>>1), 24)][get_WGT_offset(24)+:8];
      win[fil_i  ][ 24+:8] = weight[get_WGT_index(filter_set + (fil_i>>1),  1)][get_WGT_offset( 1)+:8];
      win[fil_i  ][ 32+:8] = weight[get_WGT_index(filter_set + (fil_i>>1), 13)][get_WGT_offset(13)+:8];
      win[fil_i  ][ 40+:8] = weight[get_WGT_index(filter_set + (fil_i>>1), 25)][get_WGT_offset(25)+:8];
      win[fil_i  ][ 48+:8] = weight[get_WGT_index(filter_set + (fil_i>>1),  2)][get_WGT_offset( 2)+:8];
      win[fil_i  ][ 56+:8] = weight[get_WGT_index(filter_set + (fil_i>>1), 14)][get_WGT_offset(14)+:8];
      win[fil_i  ][ 64+:8] = weight[get_WGT_index(filter_set + (fil_i>>1), 26)][get_WGT_offset(26)+:8];
      win[fil_i  ][ 72+:8] = weight[get_WGT_index(filter_set + (fil_i>>1),  4)][get_WGT_offset( 4)+:8];
      win[fil_i  ][ 80+:8] = weight[get_WGT_index(filter_set + (fil_i>>1), 16)][get_WGT_offset(16)+:8];
      win[fil_i  ][ 88+:8] = weight[get_WGT_index(filter_set + (fil_i>>1), 28)][get_WGT_offset(28)+:8];
      win[fil_i  ][ 96+:8] = weight[get_WGT_index(filter_set + (fil_i>>1),  5)][get_WGT_offset( 5)+:8];
      win[fil_i  ][104+:8] = weight[get_WGT_index(filter_set + (fil_i>>1), 17)][get_WGT_offset(17)+:8];
      win[fil_i  ][112+:8] = weight[get_WGT_index(filter_set + (fil_i>>1), 29)][get_WGT_offset(29)+:8];
      win[fil_i  ][120+:8] = 1'b0;
      win[fil_i+1][  0+:8] = weight[get_WGT_index(filter_set + (fil_i>>1),  6)][get_WGT_offset( 6)+:8];
      win[fil_i+1][  8+:8] = weight[get_WGT_index(filter_set + (fil_i>>1), 18)][get_WGT_offset(18)+:8];
      win[fil_i+1][ 16+:8] = weight[get_WGT_index(filter_set + (fil_i>>1), 30)][get_WGT_offset(30)+:8];
      win[fil_i+1][ 24+:8] = weight[get_WGT_index(filter_set + (fil_i>>1),  8)][get_WGT_offset( 8)+:8];
      win[fil_i+1][ 32+:8] = weight[get_WGT_index(filter_set + (fil_i>>1), 20)][get_WGT_offset(20)+:8];
      win[fil_i+1][ 40+:8] = weight[get_WGT_index(filter_set + (fil_i>>1), 32)][get_WGT_offset(32)+:8];
      win[fil_i+1][ 48+:8] = weight[get_WGT_index(filter_set + (fil_i>>1),  9)][get_WGT_offset( 9)+:8];
      win[fil_i+1][ 56+:8] = weight[get_WGT_index(filter_set + (fil_i>>1), 21)][get_WGT_offset(21)+:8];
      win[fil_i+1][ 64+:8] = weight[get_WGT_index(filter_set + (fil_i>>1), 33)][get_WGT_offset(33)+:8];
      win[fil_i+1][ 72+:8] = weight[get_WGT_index(filter_set + (fil_i>>1), 10)][get_WGT_offset(10)+:8];
      win[fil_i+1][ 80+:8] = weight[get_WGT_index(filter_set + (fil_i>>1), 22)][get_WGT_offset(22)+:8];
      win[fil_i+1][ 88+:8] = weight[get_WGT_index(filter_set + (fil_i>>1), 34)][get_WGT_offset(34)+:8];
      win[fil_i+1][ 96+:8] = 1'b0;
      win[fil_i+1][104+:8] = 1'b0;
      win[fil_i+1][112+:8] = 1'b0;
      win[fil_i+1][120+:8] = 1'b0;
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
  */


  end else if (is_1x1) begin // 1x1 conv
  /*
    // --------------------------------------------
    // win assignment
    // --------------------------------------------
    for (fil_i = 0; fil_i < 8; fil_i = fil_i + 1) begin
      for (fil_j = 0; fil_j < 16; fil_j = fil_j + 1) begin
        win[fil_i][(fil_j << 3) +:8] = weight[(Ni * (filter_set + fil_i) + chan_set + fil_j) >> 2][get_WGT_offset(Ni * (filter_set + fil_i) + chan_set + fil_j) +:8];
        //win[fil_i][(fil_j << 3) +:8] = weight[(filter_set + fil_i + No * (chan_set + fil_j)) >> 2][get_WGT_offset(filter_set + fil_i + No * (chan_set + fil_j)) +:8];
      end
    end

    // --------------------------------------------
    // MAC array 0: IFM
    // --------------------------------------------
    for (mac_iter = 0; mac_iter < 16; mac_iter = mac_iter + 1) begin
      din_mac_array_0[0][(mac_iter << 3) +:8] = in_img[get_IFM_index(row_array_0, col_array_0, chan_set + mac_iter)][get_IFM_offset(chan_set + mac_iter)+:8];
      din_mac_array_0[1][(mac_iter << 3) +:8] = in_img[get_IFM_index(row_array_0, col_array_0, chan_set + mac_iter)][get_IFM_offset(chan_set + mac_iter)+:8];
      din_mac_array_0[2][(mac_iter << 3) +:8] = in_img[get_IFM_index(row_array_0, col_array_0, chan_set + mac_iter)][get_IFM_offset(chan_set + mac_iter)+:8];
      din_mac_array_0[3][(mac_iter << 3) +:8] = in_img[get_IFM_index(row_array_0, col_array_0, chan_set + mac_iter)][get_IFM_offset(chan_set + mac_iter)+:8];
      din_mac_array_0[4][(mac_iter << 3) +:8] = in_img[get_IFM_index(row_array_0, col_array_0, chan_set + mac_iter)][get_IFM_offset(chan_set + mac_iter)+:8];
      din_mac_array_0[5][(mac_iter << 3) +:8] = in_img[get_IFM_index(row_array_0, col_array_0, chan_set + mac_iter)][get_IFM_offset(chan_set + mac_iter)+:8];
      din_mac_array_0[6][(mac_iter << 3) +:8] = in_img[get_IFM_index(row_array_0, col_array_0, chan_set + mac_iter)][get_IFM_offset(chan_set + mac_iter)+:8];
      din_mac_array_0[7][(mac_iter << 3) +:8] = in_img[get_IFM_index(row_array_0, col_array_0, chan_set + mac_iter)][get_IFM_offset(chan_set + mac_iter)+:8];
    end

    // --------------------------------------------
    // MAC array 1: IFM
    // --------------------------------------------
    for (mac_iter = 0; mac_iter < 16; mac_iter = mac_iter + 1) begin
      din_mac_array_1[0][(mac_iter << 3) +:8] = in_img[get_IFM_index(row_array_1, col_array_1, chan_set + mac_iter)][get_IFM_offset(chan_set + mac_iter)+:8];
      din_mac_array_1[1][(mac_iter << 3) +:8] = in_img[get_IFM_index(row_array_1, col_array_1, chan_set + mac_iter)][get_IFM_offset(chan_set + mac_iter)+:8];
      din_mac_array_1[2][(mac_iter << 3) +:8] = in_img[get_IFM_index(row_array_1, col_array_1, chan_set + mac_iter)][get_IFM_offset(chan_set + mac_iter)+:8];
      din_mac_array_1[3][(mac_iter << 3) +:8] = in_img[get_IFM_index(row_array_1, col_array_1, chan_set + mac_iter)][get_IFM_offset(chan_set + mac_iter)+:8];
      din_mac_array_1[4][(mac_iter << 3) +:8] = in_img[get_IFM_index(row_array_1, col_array_1, chan_set + mac_iter)][get_IFM_offset(chan_set + mac_iter)+:8];
      din_mac_array_1[5][(mac_iter << 3) +:8] = in_img[get_IFM_index(row_array_1, col_array_1, chan_set + mac_iter)][get_IFM_offset(chan_set + mac_iter)+:8];
      din_mac_array_1[6][(mac_iter << 3) +:8] = in_img[get_IFM_index(row_array_1, col_array_1, chan_set + mac_iter)][get_IFM_offset(chan_set + mac_iter)+:8];
      din_mac_array_1[7][(mac_iter << 3) +:8] = in_img[get_IFM_index(row_array_1, col_array_1, chan_set + mac_iter)][get_IFM_offset(chan_set + mac_iter)+:8];
    end

    // --------------------------------------------
    // MAC array 2: IFM
    // --------------------------------------------
    for (mac_iter = 0; mac_iter < 16; mac_iter = mac_iter + 1) begin
      din_mac_array_2[0][(mac_iter << 3) +:8] = in_img[get_IFM_index(row_array_2, col_array_2, chan_set + mac_iter)][get_IFM_offset(chan_set + mac_iter)+:8];
      din_mac_array_2[1][(mac_iter << 3) +:8] = in_img[get_IFM_index(row_array_2, col_array_2, chan_set + mac_iter)][get_IFM_offset(chan_set + mac_iter)+:8];
      din_mac_array_2[2][(mac_iter << 3) +:8] = in_img[get_IFM_index(row_array_2, col_array_2, chan_set + mac_iter)][get_IFM_offset(chan_set + mac_iter)+:8];
      din_mac_array_2[3][(mac_iter << 3) +:8] = in_img[get_IFM_index(row_array_2, col_array_2, chan_set + mac_iter)][get_IFM_offset(chan_set + mac_iter)+:8];
      din_mac_array_2[4][(mac_iter << 3) +:8] = in_img[get_IFM_index(row_array_2, col_array_2, chan_set + mac_iter)][get_IFM_offset(chan_set + mac_iter)+:8];
      din_mac_array_2[5][(mac_iter << 3) +:8] = in_img[get_IFM_index(row_array_2, col_array_2, chan_set + mac_iter)][get_IFM_offset(chan_set + mac_iter)+:8];
      din_mac_array_2[6][(mac_iter << 3) +:8] = in_img[get_IFM_index(row_array_2, col_array_2, chan_set + mac_iter)][get_IFM_offset(chan_set + mac_iter)+:8];
      din_mac_array_2[7][(mac_iter << 3) +:8] = in_img[get_IFM_index(row_array_2, col_array_2, chan_set + mac_iter)][get_IFM_offset(chan_set + mac_iter)+:8];
    end

    // --------------------------------------------
    // MAC array 3: IFM
    // --------------------------------------------
    for (mac_iter = 0; mac_iter < 16; mac_iter = mac_iter + 1) begin
      din_mac_array_3[0][(mac_iter << 3) +:8] = in_img[get_IFM_index(row_array_3, col_array_3, chan_set + mac_iter)][get_IFM_offset(chan_set + mac_iter)+:8];
      din_mac_array_3[1][(mac_iter << 3) +:8] = in_img[get_IFM_index(row_array_3, col_array_3, chan_set + mac_iter)][get_IFM_offset(chan_set + mac_iter)+:8];
      din_mac_array_3[2][(mac_iter << 3) +:8] = in_img[get_IFM_index(row_array_3, col_array_3, chan_set + mac_iter)][get_IFM_offset(chan_set + mac_iter)+:8];
      din_mac_array_3[3][(mac_iter << 3) +:8] = in_img[get_IFM_index(row_array_3, col_array_3, chan_set + mac_iter)][get_IFM_offset(chan_set + mac_iter)+:8];
      din_mac_array_3[4][(mac_iter << 3) +:8] = in_img[get_IFM_index(row_array_3, col_array_3, chan_set + mac_iter)][get_IFM_offset(chan_set + mac_iter)+:8];
      din_mac_array_3[5][(mac_iter << 3) +:8] = in_img[get_IFM_index(row_array_3, col_array_3, chan_set + mac_iter)][get_IFM_offset(chan_set + mac_iter)+:8];
      din_mac_array_3[6][(mac_iter << 3) +:8] = in_img[get_IFM_index(row_array_3, col_array_3, chan_set + mac_iter)][get_IFM_offset(chan_set + mac_iter)+:8];
      din_mac_array_3[7][(mac_iter << 3) +:8] = in_img[get_IFM_index(row_array_3, col_array_3, chan_set + mac_iter)][get_IFM_offset(chan_set + mac_iter)+:8];
    end
  */

  end else begin // general 3x3
    // --------------------------------------------
    // MAC array 0-3 : Weight
    // --------------------------------------------
    for (fil_i = 0; fil_i < 9; fil_i = fil_i + 1) begin     // iterates 9 MAC16 modules
      for (fil_j = 0; fil_j < 16; fil_j = fil_j + 1) begin  // iterates the ports in each MAC module
        win[fil_i][(fil_j << 3)+:8] = weight[get_WGT_index(9*(chan_set + fil_j) + fil_i)][get_WGT_offset(9*(chan_set + fil_j) + fil_i)+:8];
      end
    end


    // --------------------------------------------
    // MAC array 0 : IFM
    // --------------------------------------------
    for (mac_iter = 0; mac_iter < 16; mac_iter = mac_iter + 1) begin
      din_mac_array_0[0][(mac_iter<<3)+:8] = in_img[get_IFM_index(0, 0, chan_set + mac_iter)][get_IFM_offset(chan_set + mac_iter)+:8];
      din_mac_array_0[1][(mac_iter<<3)+:8] = in_img[get_IFM_index(0, 1, chan_set + mac_iter)][get_IFM_offset(chan_set + mac_iter)+:8];
      din_mac_array_0[2][(mac_iter<<3)+:8] = in_img[get_IFM_index(0, 2, chan_set + mac_iter)][get_IFM_offset(chan_set + mac_iter)+:8];
      din_mac_array_0[3][(mac_iter<<3)+:8] = in_img[get_IFM_index(1, 0, chan_set + mac_iter)][get_IFM_offset(chan_set + mac_iter)+:8];
      din_mac_array_0[4][(mac_iter<<3)+:8] = in_img[get_IFM_index(1, 1, chan_set + mac_iter)][get_IFM_offset(chan_set + mac_iter)+:8];
      din_mac_array_0[5][(mac_iter<<3)+:8] = in_img[get_IFM_index(1, 2, chan_set + mac_iter)][get_IFM_offset(chan_set + mac_iter)+:8];
      din_mac_array_0[6][(mac_iter<<3)+:8] = in_img[get_IFM_index(2, 0, chan_set + mac_iter)][get_IFM_offset(chan_set + mac_iter)+:8];
      din_mac_array_0[7][(mac_iter<<3)+:8] = in_img[get_IFM_index(2, 1, chan_set + mac_iter)][get_IFM_offset(chan_set + mac_iter)+:8];
      din_mac_array_0[8][(mac_iter<<3)+:8] = in_img[get_IFM_index(2, 2, chan_set + mac_iter)][get_IFM_offset(chan_set + mac_iter)+:8];
    end


    // --------------------------------------------
    // MAC array 1 : IFM
    // --------------------------------------------
    for (mac_iter = 0; mac_iter < 16; mac_iter = mac_iter + 1) begin
      din_mac_array_1[0][(mac_iter<<3)+:8] = in_img[get_IFM_index(0, 1, chan_set + mac_iter)][get_IFM_offset(chan_set + mac_iter)+:8];
      din_mac_array_1[1][(mac_iter<<3)+:8] = in_img[get_IFM_index(0, 2, chan_set + mac_iter)][get_IFM_offset(chan_set + mac_iter)+:8];
      din_mac_array_1[2][(mac_iter<<3)+:8] = in_img[get_IFM_index(0, 3, chan_set + mac_iter)][get_IFM_offset(chan_set + mac_iter)+:8];
      din_mac_array_1[3][(mac_iter<<3)+:8] = in_img[get_IFM_index(1, 1, chan_set + mac_iter)][get_IFM_offset(chan_set + mac_iter)+:8];
      din_mac_array_1[4][(mac_iter<<3)+:8] = in_img[get_IFM_index(1, 2, chan_set + mac_iter)][get_IFM_offset(chan_set + mac_iter)+:8];
      din_mac_array_1[5][(mac_iter<<3)+:8] = in_img[get_IFM_index(1, 3, chan_set + mac_iter)][get_IFM_offset(chan_set + mac_iter)+:8];
      din_mac_array_1[6][(mac_iter<<3)+:8] = in_img[get_IFM_index(2, 1, chan_set + mac_iter)][get_IFM_offset(chan_set + mac_iter)+:8];
      din_mac_array_1[7][(mac_iter<<3)+:8] = in_img[get_IFM_index(2, 2, chan_set + mac_iter)][get_IFM_offset(chan_set + mac_iter)+:8];
      din_mac_array_1[8][(mac_iter<<3)+:8] = in_img[get_IFM_index(2, 3, chan_set + mac_iter)][get_IFM_offset(chan_set + mac_iter)+:8];
    end


    // --------------------------------------------
    // MAC array 2 : IFM
    // --------------------------------------------
    for (mac_iter = 0; mac_iter < 16; mac_iter = mac_iter + 1) begin
      din_mac_array_2[0][(mac_iter<<3)+:8] = in_img[get_IFM_index(1, 0, chan_set + mac_iter)][get_IFM_offset(chan_set + mac_iter)+:8];
      din_mac_array_2[1][(mac_iter<<3)+:8] = in_img[get_IFM_index(1, 1, chan_set + mac_iter)][get_IFM_offset(chan_set + mac_iter)+:8];
      din_mac_array_2[2][(mac_iter<<3)+:8] = in_img[get_IFM_index(1, 2, chan_set + mac_iter)][get_IFM_offset(chan_set + mac_iter)+:8];
      din_mac_array_2[3][(mac_iter<<3)+:8] = in_img[get_IFM_index(2, 0, chan_set + mac_iter)][get_IFM_offset(chan_set + mac_iter)+:8];
      din_mac_array_2[4][(mac_iter<<3)+:8] = in_img[get_IFM_index(2, 1, chan_set + mac_iter)][get_IFM_offset(chan_set + mac_iter)+:8];
      din_mac_array_2[5][(mac_iter<<3)+:8] = in_img[get_IFM_index(2, 2, chan_set + mac_iter)][get_IFM_offset(chan_set + mac_iter)+:8];
      din_mac_array_2[6][(mac_iter<<3)+:8] = in_img[get_IFM_index(3, 0, chan_set + mac_iter)][get_IFM_offset(chan_set + mac_iter)+:8];
      din_mac_array_2[7][(mac_iter<<3)+:8] = in_img[get_IFM_index(3, 1, chan_set + mac_iter)][get_IFM_offset(chan_set + mac_iter)+:8];
      din_mac_array_2[8][(mac_iter<<3)+:8] = in_img[get_IFM_index(3, 2, chan_set + mac_iter)][get_IFM_offset(chan_set + mac_iter)+:8];   
    end


    // --------------------------------------------
    // MAC array 3 : IFM
    // --------------------------------------------
    for (mac_iter = 0; mac_iter < 16; mac_iter = mac_iter + 1) begin
      din_mac_array_3[0][(mac_iter<<3)+:8] = in_img[get_IFM_index(1, 1, chan_set + mac_iter)][get_IFM_offset(chan_set + mac_iter)+:8];
      din_mac_array_3[1][(mac_iter<<3)+:8] = in_img[get_IFM_index(1, 2, chan_set + mac_iter)][get_IFM_offset(chan_set + mac_iter)+:8];
      din_mac_array_3[2][(mac_iter<<3)+:8] = in_img[get_IFM_index(1, 3, chan_set + mac_iter)][get_IFM_offset(chan_set + mac_iter)+:8];
      din_mac_array_3[3][(mac_iter<<3)+:8] = in_img[get_IFM_index(2, 1, chan_set + mac_iter)][get_IFM_offset(chan_set + mac_iter)+:8];
      din_mac_array_3[4][(mac_iter<<3)+:8] = in_img[get_IFM_index(2, 2, chan_set + mac_iter)][get_IFM_offset(chan_set + mac_iter)+:8];
      din_mac_array_3[5][(mac_iter<<3)+:8] = in_img[get_IFM_index(2, 3, chan_set + mac_iter)][get_IFM_offset(chan_set + mac_iter)+:8];
      din_mac_array_3[6][(mac_iter<<3)+:8] = in_img[get_IFM_index(3, 1, chan_set + mac_iter)][get_IFM_offset(chan_set + mac_iter)+:8];
      din_mac_array_3[7][(mac_iter<<3)+:8] = in_img[get_IFM_index(3, 2, chan_set + mac_iter)][get_IFM_offset(chan_set + mac_iter)+:8];
      din_mac_array_3[8][(mac_iter<<3)+:8] = in_img[get_IFM_index(3, 3, chan_set + mac_iter)][get_IFM_offset(chan_set + mac_iter)+:8];
    end
  end
end

// --------------------------------------------
// Module starts from here
// --------------------------------------------
integer i;
always @ (posedge clk) begin
	if (!rstn || conv_done) begin // initialize registers
    if (conv_done) conv_done <= 1'b1;
    else           conv_done <= 1'b0;
    ready_b <= 1'b0;
    ready_f <= 1'b0;
    ready_w <= 1'b0;
    is_first_row <= 1'b0;
    is_first_col <= 1'b0;
    is_last_row <= 1'b0;
    is_last_col <= 1'b0;
    valid_o0 <= 1'b0;
    valid_o1 <= 1'b0;
    data_out0 <= 1'b0;
    data_out1 <= 1'b0;
    state <= 1'b0;
    for (i=0; i<2048; i=i+1)
      in_img[i] = 1'b0;
    for (i=0; i<36; i=i+1)
      weight[i] = 1'b0;
    for (i=0; i<256; i=i+1)
      bias[i] = 1'b0;
    b_counter <= 1'b0;
    ena_b <= 1'b0;
    addr_b <= 1'b0;
    din_b <= 1'b0;
    tile <= 1'b0;
    feamap_offset <= 1'b0;
    chan_set_f <= 1'b0;
    initial_get_f <= 1'b1; // initialized as 1
    chan_counter <= 1'b0;
    f_counter <= 1'b0;
    ena_f <= 1'b0;
    addr_f <= 1'b0;
    din_f <= 1'b0;
    counter <= 1'b0;
    wait_get_f <= 1'b0;
    mac_counter <= 1'b0;
    pool_counter <= 1'b0;
    send_counter <= 1'b0;
    bias_counter <= 1'b0;
    filter_set <= 1'b0;
    chan_set <= 1'b0;
    delay <= 1'b0;
    pool_delay <= 1'b0;
    row <= 1'b0;
    col <= 1'b0;
    // mac_vld_i <= 1'b0;
    for (i=0; i<9; i=i+1) begin
      din_mac_array_0[i] = 1'b0;
      din_mac_array_1[i] = 1'b0;
      din_mac_array_2[i] = 1'b0;
      din_mac_array_3[i] = 1'b0;
      win            [i] = 1'b0;
    end
    valid_pool <= 1'b0;
    for (i=0; i<4; i=i+1) begin
      mac_array_0_out[i] <= 1'b0;
      mac_array_1_out[i] <= 1'b0;
      mac_array_2_out[i] <= 1'b0;
      mac_array_3_out[i] <= 1'b0;

      partial_sum[i][0] <= 1'b0;
      partial_sum[i][1] <= 1'b0;
      partial_sum[i][2] <= 1'b0;
      partial_sum[i][3] <= 1'b0;
      partial_sum[i][4] <= 1'b0;
      partial_sum[i][5] <= 1'b0;
      partial_sum[i][6] <= 1'b0;
      partial_sum[i][7] <= 1'b0;

      final_sum[i][0] <= 1'b0;
      final_sum[i][1] <= 1'b0;
      final_sum[i][2] <= 1'b0;
      final_sum[i][3] <= 1'b0;
      final_sum[i][4] <= 1'b0;
      final_sum[i][5] <= 1'b0;
      final_sum[i][6] <= 1'b0;
      final_sum[i][7] <= 1'b0;
    end
    get_bias_done <= 1'b0;
    get_feature_done <= 1'b0;
    mac_done <= 1'b0;
    pool_done <= 1'b0;
    send_done <= 1'b0;
	end else begin
    // state transition
    case (state)
      STATE_IDLE: begin
        if (!conv_done) begin
          state <= STATE_GET_B;
        end else begin
          state <= state;
        end
      end
      STATE_GET_B: begin
        if (get_bias_done) begin
          state <= STATE_GET_F;
        end else begin
          state <= state;
        end
      end
      STATE_GET_F: begin
        if (get_feature_done) begin
          state <= STATE_RUN;
        end else begin
          // valid signal is asserted for only 1 cycle
          if (valid_o0) valid_o0 <= 1'b0;
          if (valid_o1) valid_o1 <= 1'b0;
          state <= state;
        end
      end
      STATE_RUN: begin
        if (mac_done && pool_done && send_done) begin
          state <= STATE_DONE;
        end else if (frame_done) begin
          state <= STATE_GET_F;
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
          get_bias_done <= 1'b0;
          get_feature_done <= 1'b0;
          counter <= 1'b0;
          valid_o0 <= 1'b0;
          valid_o1 <= 1'b0;
          row <= 1'b0;
          col <= 1'b0;
          delay <= 1'b0;
          pool_delay <= 1'b0;
          // mac_vld_i <= 1'b0;
        end
      end
      STATE_GET_B: begin
        if (get_bias_done) begin
          get_bias_done <= 1'b0;
          ready_b <= 1'b0;
          b_counter <= 1'b0;
          ena_b <= 1'b0;
          addr_b <= 1'b0;
          din_b <= 1'b0;
        end else if (!ready_b) begin
          ready_b <= 1'b1;
          b_counter <= 1'b0;
          ena_b <= 1'b0;
          addr_b <= 1'b0;
          din_b <= 1'b0;
        end else if (valid_b) begin
          b_counter <= b_counter + 1;
          ena_b <= 1'b1;
          addr_b <= b_counter;
          din_b <= data_in_b;
          if (b_counter == (BIAS_DATA_SIZE >> 1) - 1) begin // 2 biases per address
            get_bias_done <= 1'b1;
            ready_b <= 1'b0;
          end else begin
            get_bias_done <= 1'b0;
            ready_b <= 1'b1;
          end
        end else begin
          ready_b <= 1'b1;
          ena_b <= 1'b0;
          addr_b <= 1'b0;
          din_b <= 1'b0;
        end
      end
      STATE_GET_F: begin
        if (get_feature_done) begin
          get_feature_done <= 1'b0;
          ready_f <= 1'b0;
          f_counter <= 1'b0;
          ena_f <= 1'b0;
          addr_f <= 1'b0;
          din_f <= 1'b0;
          chan_counter <= 1'b0;
          chan_set_f <= 1'b0;
          wait_get_f <= 1'b0;
        end else if (!ready_f) begin
          ready_f <= 1'b1;
          ena_f <= 1'b0;
          addr_f <= 1'b0;
          din_f <= 1'b0;
          chan_counter <= 1'b0;
          chan_set_f <= 1'b0;
          // --------------------------------------------
          // Row, Col and tile indexing
          // --------------------------------------------
          if (initial_get_f) begin
            f_counter <= 1'b0; // starts from tile_a
            row <= 1'b0;
            col <= 1'b0;
            initial_get_f <= 1'b0;
          end else begin
            if (col == IFM_WIDTH - Tc) begin
              f_counter <= 1'b0; // starts from tile_a
              col <= 1'b0;
              row <= row + Tr;
            end else begin
              // copy tile_c and tile_d to tile_a and tile_b, respectively
              // just copy the data in address A to address (A-Ni/2) for all A >= Ni/2
              for(ff = (Ni >> 1); ff < 2048; ff = ff + 1) begin
                in_img[ff - (Ni >> 1)] = in_img[ff];
              end
              f_counter <= 2 * tile_separator; // starts from tile_c
              col <= col + Tc;
            end
          end
        end else if (valid_f) begin
          if (chan_counter == Ni - 32) begin
            chan_counter <= 1'b0;
          end else begin
            chan_counter <= chan_counter + 32;
          end
          f_counter <= f_counter + 1;
          ena_f <= 1'b1;
          addr_f <= f_counter;
          din_f <= data_in_f;
          chan_set_f <= chan_counter;
          if (f_counter == (Ni >> 3) - 1) begin // 2x2x32=128 data per cycle, total 4x4xNi data
            get_feature_done <= 1'b1;
            ready_f <= 1'b0;
          end else begin
            get_feature_done <= 1'b0;
            ready_f <= 1'b1;
          end
        end else begin
          ready_f <= 1'b1;
          ena_f <= 1'b0;
          addr_f <= 1'b0;
          din_f <= 1'b0;
        end
      end
      STATE_RUN: begin
        if (wait_get_f) begin
          ready_w <= 1'b0;
        end else if (!ready_w) begin
          ready_w <= 1'b1;
        end else if (valid_w) begin
          // --------------------------------------------
          // Convolution via MAC
          // --------------------------------------------
          if (!mac_done) begin
            if ((filter_set == No - To) && (chan_set == Ni - Ti)) begin
              mac_counter <= mac_counter + 1;
              filter_set <= 1'b0;
              chan_set <= 1'b0;
              ready_w <= 1'b0;
              wait_get_f <= 1'b1;
            end else begin
              if (chan_set == Ni - Ti) begin
                mac_counter <= mac_counter + 1;
                chan_set <= 1'b0;
                filter_set <= filter_set + To;
              end else begin
                mac_counter <= mac_counter + 1;
                chan_set <= chan_set + Ti;
              end
            end

            if (is_CONV00) begin
            /*
              if (mac_counter == IFM_DATA_SIZE - 1) begin // processing the last data
                mac_done <= 1'b1;
                mac_vld_i <= 1'b0;
              end
            */
            end else if (is_1x1) begin
            /*
              if (mac_counter == (Ni >> 4) * (OUTPUT_SIZE >> 2) * (No >> 3) - 1) begin // needs verification. 4 is Ti = 16, 2 is 2x2 ofmap, 3 is To = 8
                mac_done <= 1'b1;
                mac_vld_i <= 1'b0;
              end
            */
            end else begin
              if (mac_counter == (Ni >> 4) * OUTPUT_SIZE * No - 1) begin // processing the last data
                mac_done <= 1'b1;
                // mac_vld_i <= 1'b0;
              end
            end
          end
        end
        // --------------------------------------------
        // Accumulation and Max-pooling
        // --------------------------------------------
        if (!pool_done) begin
          if (valid_mac || (pool_delay > 0)) begin // either when the MAC result is valid or pooling is continuing
            if (is_CONV00) begin
              valid_pool <= 1'b1;
              for (i = 0; i < 4; i = i + 1) begin
                mac_array_0_out[i] = mac_out[0][i];
                mac_array_1_out[i] = mac_out[1][i];
                mac_array_2_out[i] = mac_out[2][i];
                mac_array_3_out[i] = mac_out[3][i];
              end
              bias_counter <= pool_counter;
              pool_counter <= pool_counter + 1;

              if (pool_counter == ((OUTPUT_SIZE * No) >> 2) - 1) begin // processing the last data; '>> 2' means dividing by To
                pool_done <= 1'b1;
              end

            end else if (is_1x1) begin
              if (pool_delay == (Ni >> 4) - 1) begin
                valid_pool <= 1'b1;
                pool_delay <= 1'b0;

                bias_counter <= pool_counter;
                pool_counter <= pool_counter + 1;

                final_sum[0][0] <= partial_sum[0][0] + mac_out[0][0];
                final_sum[0][1] <= partial_sum[0][1] + mac_out[0][1];
                final_sum[0][2] <= partial_sum[0][2] + mac_out[0][2];
                final_sum[0][3] <= partial_sum[0][3] + mac_out[0][3];
                final_sum[0][4] <= partial_sum[0][4] + mac_out[0][4];
                final_sum[0][5] <= partial_sum[0][5] + mac_out[0][5];
                final_sum[0][6] <= partial_sum[0][6] + mac_out[0][6];
                final_sum[0][7] <= partial_sum[0][7] + mac_out[0][7];

                final_sum[1][0] <= partial_sum[1][0] + mac_out[1][0];
                final_sum[1][1] <= partial_sum[1][1] + mac_out[1][1];
                final_sum[1][2] <= partial_sum[1][2] + mac_out[1][2];
                final_sum[1][3] <= partial_sum[1][3] + mac_out[1][3];
                final_sum[1][4] <= partial_sum[1][4] + mac_out[1][4];
                final_sum[1][5] <= partial_sum[1][5] + mac_out[1][5];
                final_sum[1][6] <= partial_sum[1][6] + mac_out[1][6];
                final_sum[1][7] <= partial_sum[1][7] + mac_out[1][7];

                final_sum[2][0] <= partial_sum[2][0] + mac_out[2][0];
                final_sum[2][1] <= partial_sum[2][1] + mac_out[2][1];
                final_sum[2][2] <= partial_sum[2][2] + mac_out[2][2];
                final_sum[2][3] <= partial_sum[2][3] + mac_out[2][3];
                final_sum[2][4] <= partial_sum[2][4] + mac_out[2][4];
                final_sum[2][5] <= partial_sum[2][5] + mac_out[2][5];
                final_sum[2][6] <= partial_sum[2][6] + mac_out[2][6];
                final_sum[2][7] <= partial_sum[2][7] + mac_out[2][7];

                final_sum[3][0] <= partial_sum[3][0] + mac_out[3][0];
                final_sum[3][1] <= partial_sum[3][1] + mac_out[3][1];
                final_sum[3][2] <= partial_sum[3][2] + mac_out[3][2];
                final_sum[3][3] <= partial_sum[3][3] + mac_out[3][3];
                final_sum[3][4] <= partial_sum[3][4] + mac_out[3][4];
                final_sum[3][5] <= partial_sum[3][5] + mac_out[3][5];
                final_sum[3][6] <= partial_sum[3][6] + mac_out[3][6];
                final_sum[3][7] <= partial_sum[3][7] + mac_out[3][7];

                partial_sum[0][0] <= 1'b0;
                partial_sum[0][1] <= 1'b0;
                partial_sum[0][2] <= 1'b0;
                partial_sum[0][3] <= 1'b0;
                partial_sum[0][4] <= 1'b0;
                partial_sum[0][5] <= 1'b0;
                partial_sum[0][6] <= 1'b0;
                partial_sum[0][7] <= 1'b0;

                partial_sum[1][0] <= 1'b0;
                partial_sum[1][1] <= 1'b0;
                partial_sum[1][2] <= 1'b0;
                partial_sum[1][3] <= 1'b0;
                partial_sum[1][4] <= 1'b0;
                partial_sum[1][5] <= 1'b0;
                partial_sum[1][6] <= 1'b0;
                partial_sum[1][7] <= 1'b0;

                partial_sum[2][0] <= 1'b0;
                partial_sum[2][1] <= 1'b0;
                partial_sum[2][2] <= 1'b0;
                partial_sum[2][3] <= 1'b0;
                partial_sum[2][4] <= 1'b0;
                partial_sum[2][5] <= 1'b0;
                partial_sum[2][6] <= 1'b0;
                partial_sum[2][7] <= 1'b0;

                partial_sum[3][0] <= 1'b0;
                partial_sum[3][1] <= 1'b0;
                partial_sum[3][2] <= 1'b0;
                partial_sum[3][3] <= 1'b0;
                partial_sum[3][4] <= 1'b0;
                partial_sum[3][5] <= 1'b0;
                partial_sum[3][6] <= 1'b0;
                partial_sum[3][7] <= 1'b0;

              end
              else begin
                valid_pool <= 1'b0;
                pool_delay <= pool_delay + 1;

                partial_sum[0][0] <= partial_sum[0][0] + mac_out[0][0];
                partial_sum[0][1] <= partial_sum[0][1] + mac_out[0][1];
                partial_sum[0][2] <= partial_sum[0][2] + mac_out[0][2];
                partial_sum[0][3] <= partial_sum[0][3] + mac_out[0][3];
                partial_sum[0][4] <= partial_sum[0][4] + mac_out[0][4];
                partial_sum[0][5] <= partial_sum[0][5] + mac_out[0][5];
                partial_sum[0][6] <= partial_sum[0][6] + mac_out[0][6];
                partial_sum[0][7] <= partial_sum[0][7] + mac_out[0][7];

                partial_sum[1][0] <= partial_sum[1][0] + mac_out[1][0];
                partial_sum[1][1] <= partial_sum[1][1] + mac_out[1][1];
                partial_sum[1][2] <= partial_sum[1][2] + mac_out[1][2];
                partial_sum[1][3] <= partial_sum[1][3] + mac_out[1][3];
                partial_sum[1][4] <= partial_sum[1][4] + mac_out[1][4];
                partial_sum[1][5] <= partial_sum[1][5] + mac_out[1][5];
                partial_sum[1][6] <= partial_sum[1][6] + mac_out[1][6];
                partial_sum[1][7] <= partial_sum[1][7] + mac_out[1][7];

                partial_sum[2][0] <= partial_sum[2][0] + mac_out[2][0];
                partial_sum[2][1] <= partial_sum[2][1] + mac_out[2][1];
                partial_sum[2][2] <= partial_sum[2][2] + mac_out[2][2];
                partial_sum[2][3] <= partial_sum[2][3] + mac_out[2][3];
                partial_sum[2][4] <= partial_sum[2][4] + mac_out[2][4];
                partial_sum[2][5] <= partial_sum[2][5] + mac_out[2][5];
                partial_sum[2][6] <= partial_sum[2][6] + mac_out[2][6];
                partial_sum[2][7] <= partial_sum[2][7] + mac_out[2][7];

                partial_sum[3][0] <= partial_sum[3][0] + mac_out[3][0];
                partial_sum[3][1] <= partial_sum[3][1] + mac_out[3][1];
                partial_sum[3][2] <= partial_sum[3][2] + mac_out[3][2];
                partial_sum[3][3] <= partial_sum[3][3] + mac_out[3][3];
                partial_sum[3][4] <= partial_sum[3][4] + mac_out[3][4];
                partial_sum[3][5] <= partial_sum[3][5] + mac_out[3][5];
                partial_sum[3][6] <= partial_sum[3][6] + mac_out[3][6];
                partial_sum[3][7] <= partial_sum[3][7] + mac_out[3][7];

                bias_counter <= pool_counter;
                pool_counter <= pool_counter;
              end

              if (pool_counter == (OUTPUT_SIZE * No) >> 5 - 1) begin // processing the last data, needs verification, 5 is 2x2x8 ofmap (32)
                pool_done <= 1'b1;
              end

            end else begin
              // only [0] port is used for each MAC array
              if (pool_delay == (Ni >> 4) - 1) begin // '>> 4' means dividing by Ti, need generalization!
                valid_pool <= 1'b1;
                pool_delay <= 1'b0;

                mac_array_0_out[0] <= partial_sum[0][0] + mac_out[0][0];
                mac_array_1_out[0] <= partial_sum[1][0] + mac_out[1][0];
                mac_array_2_out[0] <= partial_sum[2][0] + mac_out[2][0];
                mac_array_3_out[0] <= partial_sum[3][0] + mac_out[3][0];

                partial_sum[0][0] <= 1'b0;
                partial_sum[1][0] <= 1'b0;
                partial_sum[2][0] <= 1'b0;
                partial_sum[3][0] <= 1'b0;

                bias_counter <= pool_counter;
                pool_counter <= pool_counter + 1;
                if (pool_counter == (OUTPUT_SIZE * No - 1)) begin // processing the last data
                  pool_done <= 1'b1;
                end
              end else begin
                valid_pool <= 1'b0;
                pool_delay <= pool_delay + 1;

                mac_array_0_out[0] <= 1'b0;
                mac_array_1_out[0] <= 1'b0;
                mac_array_2_out[0] <= 1'b0;
                mac_array_3_out[0] <= 1'b0;

                partial_sum[0][0] <= partial_sum[0][0] + mac_out[0][0];
                partial_sum[1][0] <= partial_sum[1][0] + mac_out[1][0];
                partial_sum[2][0] <= partial_sum[2][0] + mac_out[2][0];
                partial_sum[3][0] <= partial_sum[3][0] + mac_out[3][0];

                bias_counter <= pool_counter;
                pool_counter <= pool_counter;
              end

              // if (pool_counter == (OUTPUT_SIZE * No - 1)) begin // processing the last data
              //   pool_done <= 1'b1;
              // end
            end
          end else begin
            valid_pool <= 1'b0;
          end
        end

        // --------------------------------------------
        // Data send
        // --------------------------------------------
        if (!send_done) begin
          if (valid_pool) begin // start data sending only when the max-pool result is valid
            if (is_CONV00) begin
              if (send_counter == OUTPUT_SIZE) begin
                send_done <= 1'b1;
                valid_o0 <= 1'b0;
                valid_o1 <= 1'b0;
                data_out0 <= 1'b0;
              end else if (bias_counter[1:0] == 2'b11) begin
                send_done <= 1'b0;
                valid_o0 <= 1'b1;
                valid_o1 <= 1'b0;
                data_out0[{bias_counter[1:0], {5{1'b0}}}+:32] <= result_buffer;
                send_counter <= send_counter + 1;
              end else begin
                send_done <= 1'b0;
                valid_o0 <= 1'b0;
                valid_o1 <= 1'b0;
                data_out0[{bias_counter[1:0], {5{1'b0}}}+:32] <= result_buffer;
                send_counter <= send_counter;
              end
            end else if (is_1x1) begin
              if (send_counter == (OUTPUT_SIZE * No) >> 5) begin // each output is 2x2x8, thus 32.
                send_done <= 1'b1;
                valid_o0 <= 1'b0;
                valid_o1 <= 1'b0;
                data_out0 <= 1'b0;
                data_out1 <= 1'b0;
              end else begin // this is already valid_pool == 1
                send_done <= 1'b0;
                valid_o0 <= 1'b1;
                valid_o1 <= 1'b1;
                send_counter <= send_counter + 1;
                data_out0 <= {result_1x1_1, result_1x1_0};
                data_out1 <= {result_1x1_3, result_1x1_2};
              end
            end else begin
              if (send_counter == OUTPUT_SIZE * (No >> 5)) begin // since the output bandwidth is 32*8-bit
                send_done <= 1'b1;
                valid_o0 <= 1'b0;
                valid_o1 <= 1'b0;
                data_out0 <= 1'b0;
              end else if (bias_counter[4:0] == 31) begin        // since the output bandwidth is 32*8-bit
                send_done <= 1'b0;
                valid_o0 <= 1'b1;
                valid_o1 <= 1'b0;
                data_out0[{bias_counter[4:0], {3{1'b0}}}+:8] <= result_buffer[7:0];
                send_counter <= send_counter + 1;
              end else begin
                send_done <= 1'b0;
                valid_o0 <= 1'b0;
                valid_o1 <= 1'b0;
                data_out0[{bias_counter[4:0], {3{1'b0}}}+:8] <= result_buffer[7:0];
                send_counter <= send_counter;
              end
            end
          end else begin
            valid_o0 <= 1'b0;
            valid_o1 <= 1'b0;
          end
        end
        
      end
      STATE_DONE: begin
        conv_done <= 1'b1;
      end
      default: ;
    endcase
	end
end

// --------------------------------------------
// MAC Arrays
// --------------------------------------------
mac_array m_mac_array_0(
  // inputs
  .clk        (clk), 
  .rstn       (rstn), 
  .vld_i      (mac_vld_i),
  .is_CONV00  (is_CONV00),
  .is_1x1     (is_1x1),

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
  .acc_o_4    (mac_out[0][4]), 
  .acc_o_5    (mac_out[0][5]), 
  .acc_o_6    (mac_out[0][6]), 
  .acc_o_7    (mac_out[0][7]), 
  .vld_o      (m_mac_vld_o[0])
);
mac_array m_mac_array_1(
  // inputs
  .clk        (clk), 
  .rstn       (rstn), 
  .vld_i      (mac_vld_i),
  .is_CONV00  (is_CONV00),
  .is_1x1     (is_1x1),

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
  .acc_o_4    (mac_out[1][4]), 
  .acc_o_5    (mac_out[1][5]), 
  .acc_o_6    (mac_out[1][6]), 
  .acc_o_7    (mac_out[1][7]), 
  .vld_o      (m_mac_vld_o[1])
);
mac_array m_mac_array_2(
  // inputs
  .clk        (clk), 
  .rstn       (rstn), 
  .vld_i      (mac_vld_i),
  .is_CONV00  (is_CONV00),
  .is_1x1     (is_1x1),

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
  .acc_o_4    (mac_out[2][4]), 
  .acc_o_5    (mac_out[2][5]), 
  .acc_o_6    (mac_out[2][6]), 
  .acc_o_7    (mac_out[2][7]), 
  .vld_o      (m_mac_vld_o[2])
);
mac_array m_mac_array_3(
  // inputs
  .clk        (clk), 
  .rstn       (rstn), 
  .vld_i      (mac_vld_i),
  .is_CONV00  (is_CONV00),
  .is_1x1     (is_1x1),

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
  .acc_o_4    (mac_out[3][4]), 
  .acc_o_5    (mac_out[3][5]), 
  .acc_o_6    (mac_out[3][6]), 
  .acc_o_7    (mac_out[3][7]), 
  .vld_o      (m_mac_vld_o[3])
);

endmodule