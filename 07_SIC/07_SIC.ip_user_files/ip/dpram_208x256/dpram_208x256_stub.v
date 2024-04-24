// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2023 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2023.2 (win64) Build 4029153 Fri Oct 13 20:14:34 MDT 2023
// Date        : Thu Mar 28 09:21:18 2024
// Host        : DESKTOP-5IEP7NP running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               c:/Users/leewo/Documents/GitHub/AIX2024/build/07_SIC/07_SIC.gen/sources_1/ip/dpram_208x256/dpram_208x256_stub.v
// Design      : dpram_208x256
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a100tcsg324-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "blk_mem_gen_v8_4_7,Vivado 2023.2" *)
module dpram_208x256(clka, ena, wea, addra, dina, clkb, enb, addrb, doutb)
/* synthesis syn_black_box black_box_pad_pin="ena,wea[0:0],addra[7:0],dina[255:0],enb,addrb[7:0],doutb[255:0]" */
/* synthesis syn_force_seq_prim="clka" */
/* synthesis syn_force_seq_prim="clkb" */;
  input clka /* synthesis syn_isclock = 1 */;
  input ena;
  input [0:0]wea;
  input [7:0]addra;
  input [255:0]dina;
  input clkb /* synthesis syn_isclock = 1 */;
  input enb;
  input [7:0]addrb;
  output [255:0]doutb;
endmodule