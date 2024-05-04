//`define PRELOAD
//`define DEBUG
`define NUM_BRAMS   16
`define BRAM_WIDTH  128
`define BRAM_DELAY  3

// -------------------------------------------------------------
// Working with FPGA
//	1. Uncomment this line
//  2. Generate IPs 
//		+ DSP for multipliers(check mul.v)
//		+ Single-port RAM (spram_wrapper.v)
//		+ Double-port RAM (dpram_wrapper.v)
// -------------------------------------------------------------

`define FPGA	1

// -------------------------------------------------------------
// For debuging 
// -------------------------------------------------------------
// IMPORTANT NOTE**: 
//      1. Correct the directories with your path
//      2. Use directories without blank space
//{{{

/* ################################# CONV 00 ################################# */
// CONV module consumes Tr x Tc x Ti IFM pixels and produces Tr x Tc x To pixels every cycle
parameter is_CONV00 = 1;
parameter Tr = 2, Tc = 2; // row-wise and col-wise factor
parameter Ti = 4, To = 4; // input-channel-wise and output-channel-wise factor
parameter SCALE_FACTOR = 10;
parameter NEXT_LAYER_INPUT_M = 3;


// IFM
parameter IFM_WIDTH         = 256;
parameter IFM_HEIGHT        = 256;
parameter IFM_DATA_SIZE     = IFM_HEIGHT*IFM_WIDTH*Ni;	
parameter IFM_WORD_SIZE     = 32;

// Weight
parameter Fx = 3, Fy = 3;
parameter Ni = 4, No = 16; 
parameter WGT_DATA_SIZE   = Fx*Fy*Ni*No;
parameter WGT_WORD_SIZE   = 32;

// Bias
parameter BIAS_DATA_SIZE = No;
parameter BIAS_WORD_SIZE = 32;

// File directory
parameter IFM_FILE   		 = "../../inout_data_sw/log_feamap/CONV00_input_32b.hex"; 
parameter WGT_FILE   		 = "../../inout_data_sw/log_param/CONV00_param_weight_32b.hex";
parameter BIAS_FILE          = "../../inout_data_sw/log_param/CONV00_param_biases_32b.hex";
/* ########################################################################### */

/* ################################# CONV 02 ################################# */
// // CONV module consumes Tr x Tc x Ti IFM pixels and produces Tr x Tc x To pixels every cycle
// parameter is_CONV00 = 0;
// parameter Tr = 2,  Tc = 2; // row-wise and col-wise factor
// parameter Ti = 16, To = 1; // input-channel-wise and output-channel-wise factor
// parameter SCALE_FACTOR = 10;
// parameter NEXT_LAYER_INPUT_M = 3;

// // IFM
// parameter IFM_WIDTH         = 128;
// parameter IFM_HEIGHT        = 128;
// parameter IFM_DATA_SIZE     = IFM_HEIGHT*IFM_WIDTH*Ni;	
// parameter IFM_WORD_SIZE     = 32;

// // Weight
// parameter Fx = 3, Fy = 3;
// parameter Ni = 16, No = 32; 
// parameter WGT_DATA_SIZE   = Fx*Fy*Ni*No;
// parameter WGT_WORD_SIZE   = 32;

// // Bias
// parameter BIAS_DATA_SIZE = No;
// parameter BIAS_WORD_SIZE = 32;

// // File directory
// parameter IFM_FILE   		 = "../../inout_data_sw/log_feamap/CONV02_input_32b.hex"; 
// parameter WGT_FILE   		 = "../../inout_data_sw/log_param/CONV02_param_weight_32b.hex";
// parameter BIAS_FILE          = "../../inout_data_sw/log_param/CONV02_param_biases_32b.hex";
/* ########################################################################### */

/* ################################# CONV 04 ################################# */
// CONV module consumes Tr x Tc x Ti IFM pixels and produces Tr x Tc x To pixels every cycle
// parameter is_CONV00 = 0;
// parameter Tr = 2,  Tc = 2; // row-wise and col-wise factor
// parameter Ti = 16, To = 1; // input-channel-wise and output-channel-wise factor
// parameter SCALE_FACTOR = 10;
// parameter NEXT_LAYER_INPUT_M = 3;

// // IFM
// parameter IFM_WIDTH         = 64;
// parameter IFM_HEIGHT        = 64;
// parameter IFM_DATA_SIZE     = IFM_HEIGHT*IFM_WIDTH*Ni;	
// parameter IFM_WORD_SIZE     = 32;

// // Weight
// parameter Fx = 3, Fy = 3;
// parameter Ni = 32, No = 64; 
// parameter WGT_DATA_SIZE   = Fx*Fy*Ni*No;
// parameter WGT_WORD_SIZE   = 32;

// // Bias
// parameter BIAS_DATA_SIZE = No;
// parameter BIAS_WORD_SIZE = 32;

// // File directory
// parameter IFM_FILE   		 = "../../inout_data_sw/log_feamap/CONV04_input_32b.hex"; 
// parameter WGT_FILE   		 = "../../inout_data_sw/log_param/CONV04_param_weight_32b.hex";
// parameter BIAS_FILE          = "../../inout_data_sw/log_param/CONV04_param_biases_32b.hex";
/* ########################################################################### */

/* ################################# CONV 06 ################################# */
// CONV module consumes Tr x Tc x Ti IFM pixels and produces Tr x Tc x To pixels every cycle
// parameter is_CONV00 = 0;
// parameter Tr = 2,  Tc = 2; // row-wise and col-wise factor
// parameter Ti = 16, To = 1; // input-channel-wise and output-channel-wise factor
// parameter SCALE_FACTOR = 10;
// parameter NEXT_LAYER_INPUT_M = 3;

// // IFM
// parameter IFM_WIDTH         = 32;
// parameter IFM_HEIGHT        = 32;
// parameter IFM_DATA_SIZE     = IFM_HEIGHT*IFM_WIDTH*Ni;	
// parameter IFM_WORD_SIZE     = 32;

// // Weight
// parameter Fx = 3, Fy = 3;
// parameter Ni = 64, No = 128; 
// parameter WGT_DATA_SIZE   = Fx*Fy*Ni*No;
// parameter WGT_WORD_SIZE   = 32;

// // Bias
// parameter BIAS_DATA_SIZE = No;
// parameter BIAS_WORD_SIZE = 32;

// // File directory
// parameter IFM_FILE   		 = "../../inout_data_sw/log_feamap/CONV06_input_32b.hex"; 
// parameter WGT_FILE   		 = "../../inout_data_sw/log_param/CONV06_param_weight_32b.hex";
// parameter BIAS_FILE          = "../../inout_data_sw/log_param/CONV06_param_biases_32b.hex";
/* ########################################################################### */

/* ################################# CONV 08 ################################# */
// CONV module consumes Tr x Tc x Ti IFM pixels and produces Tr x Tc x To pixels every cycle
// parameter is_CONV00 = 0;
// parameter Tr = 2,  Tc = 2; // row-wise and col-wise factor
// parameter Ti = 16, To = 1; // input-channel-wise and output-channel-wise factor
// parameter SCALE_FACTOR = 9;
// parameter NEXT_LAYER_INPUT_M = 3;

// // IFM
// parameter IFM_WIDTH         = 16;
// parameter IFM_HEIGHT        = 16;
// parameter IFM_DATA_SIZE     = IFM_HEIGHT*IFM_WIDTH*Ni;	
// parameter IFM_WORD_SIZE     = 32;

// // Weight
// parameter Fx = 3, Fy = 3;
// parameter Ni = 128, No = 256; 
// parameter WGT_DATA_SIZE   = Fx*Fy*Ni*No;
// parameter WGT_WORD_SIZE   = 32;

// // Bias
// parameter BIAS_DATA_SIZE = No;
// parameter BIAS_WORD_SIZE = 32;

// // File directory
// parameter IFM_FILE   		 = "../../inout_data_sw/log_feamap/CONV08_input_32b.hex"; 
// parameter WGT_FILE   		 = "../../inout_data_sw/log_param/CONV08_param_weight_32b.hex";
// parameter BIAS_FILE          = "../../inout_data_sw/log_param/CONV08_param_biases_32b.hex";
/* ########################################################################### */

/* ################################# CONV 10 ################################# */
// CONV module consumes Tr x Tc x Ti IFM pixels and produces Tr x Tc x To pixels every cycle
// parameter is_CONV00 = 0;
// parameter Tr = 2,  Tc = 2; // row-wise and col-wise factor
// parameter Ti = 16, To = 1; // input-channel-wise and output-channel-wise factor
// parameter SCALE_FACTOR = 14;
// parameter NEXT_LAYER_INPUT_M = 3;

// // IFM
// parameter IFM_WIDTH         = 8;
// parameter IFM_HEIGHT        = 8;
// parameter IFM_DATA_SIZE     = IFM_HEIGHT*IFM_WIDTH*Ni;	
// parameter IFM_WORD_SIZE     = 32;

// // Weight
// parameter Fx = 3, Fy = 3;
// parameter Ni = 256, No = 512; 
// parameter WGT_DATA_SIZE   = Fx*Fy*Ni*No;
// parameter WGT_WORD_SIZE   = 32;

// // Bias
// parameter BIAS_DATA_SIZE = No;
// parameter BIAS_WORD_SIZE = 32;

// // File directory
// parameter IFM_FILE   		 = "../../inout_data_sw/log_feamap/CONV10_input_32b.hex"; 
// parameter WGT_FILE   		 = "../../inout_data_sw/log_param/CONV10_param_weight_32b.hex";
// parameter BIAS_FILE          = "../../inout_data_sw/log_param/CONV10_param_biases_32b.hex";
/* ########################################################################### */

/* ################################# CONV 12 ################################# */
// CONV module consumes Tr x Tc x Ti IFM pixels and produces Tr x Tc x To pixels every cycle
// parameter is_CONV00 = 0;
// parameter Tr = 2,  Tc = 2; // row-wise and col-wise factor
// parameter Ti = 16, To = 8; // input-channel-wise and output-channel-wise factor
// parameter SCALE_FACTOR = 11;
// parameter NEXT_LAYER_INPUT_M = 3;

// // IFM
// parameter IFM_WIDTH         = 8;
// parameter IFM_HEIGHT        = 8;
// parameter IFM_DATA_SIZE     = IFM_HEIGHT*IFM_WIDTH*Ni;	
// parameter IFM_WORD_SIZE     = 32;

// // Weight
// parameter Fx = 1, Fy = 1;
// parameter Ni = 512, No = 256; 
// parameter WGT_DATA_SIZE   = Fx*Fy*Ni*No;
// parameter WGT_WORD_SIZE   = 32;

// // Bias
// parameter BIAS_DATA_SIZE = No;
// parameter BIAS_WORD_SIZE = 32;

// // File directory
// parameter IFM_FILE   		 = "../../inout_data_sw/log_feamap/CONV12_input_32b.hex"; 
// parameter WGT_FILE   		 = "../../inout_data_sw/log_param/CONV12_param_weight_32b.hex";
// parameter BIAS_FILE          = "../../inout_data_sw/log_param/CONV12_param_biases_32b.hex";
/* ########################################################################### */

/* ################################# CONV 13 ################################# */
// CONV module consumes Tr x Tc x Ti IFM pixels and produces Tr x Tc x To pixels every cycle
// parameter is_CONV00 = 0;
// parameter Tr = 2,  Tc = 2; // row-wise and col-wise factor
// parameter Ti = 16, To = 1; // input-channel-wise and output-channel-wise factor
// parameter SCALE_FACTOR = 13;
// parameter NEXT_LAYER_INPUT_M = 3;

// // IFM
// parameter IFM_WIDTH         = 8;
// parameter IFM_HEIGHT        = 8;
// parameter IFM_DATA_SIZE     = IFM_HEIGHT*IFM_WIDTH*Ni;	
// parameter IFM_WORD_SIZE     = 32;

// // Weight
// parameter Fx = 3, Fy = 3;
// parameter Ni = 256, No = 512; 
// parameter WGT_DATA_SIZE   = Fx*Fy*Ni*No;
// parameter WGT_WORD_SIZE   = 32;

// // Bias
// parameter BIAS_DATA_SIZE = No;
// parameter BIAS_WORD_SIZE = 32;

// // File directory
// parameter IFM_FILE   		 = "../../inout_data_sw/log_feamap/CONV13_input_32b.hex"; 
// parameter WGT_FILE   		 = "../../inout_data_sw/log_param/CONV13_param_weight_32b.hex";
// parameter BIAS_FILE          = "../../inout_data_sw/log_param/CONV13_param_biases_32b.hex";
/* ########################################################################### */



// Output Files
// parameter CONV_INPUT_IMG00   = "../../inout_data_hw/CONV00_input_ch00.bmp"; 
// parameter CONV_INPUT_IMG01   = "../../inout_data_hw/CONV00_input_ch01.bmp"; 
// parameter CONV_INPUT_IMG02   = "../../inout_data_hw/CONV00_input_ch02.bmp"; 
// parameter CONV_INPUT_IMG03   = "../../inout_data_hw/CONV00_input_ch03.bmp"; 

// parameter CONV_OUTPUT_IMG00  = "../../inout_data_hw/CONV00_output_ch00.bmp"; 
// parameter CONV_OUTPUT_IMG01  = "../../inout_data_hw/CONV00_output_ch01.bmp"; 
// parameter CONV_OUTPUT_IMG02  = "../../inout_data_hw/CONV00_output_ch02.bmp"; 
// parameter CONV_OUTPUT_IMG03  = "../../inout_data_hw/CONV00_output_ch03.bmp"; 

// Uncomment to visualize the data from DMA write
// `define CHECK_DMA_WRITE 1

//}}}