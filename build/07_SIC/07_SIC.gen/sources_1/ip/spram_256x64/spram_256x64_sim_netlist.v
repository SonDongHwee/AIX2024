// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2023 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2023.2 (win64) Build 4029153 Fri Oct 13 20:14:34 MDT 2023
// Date        : Thu Mar 28 09:24:07 2024
// Host        : DESKTOP-5IEP7NP running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim
//               c:/Users/leewo/Documents/GitHub/AIX2024/build/07_SIC/07_SIC.gen/sources_1/ip/spram_256x64/spram_256x64_sim_netlist.v
// Design      : spram_256x64
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7a100tcsg324-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "spram_256x64,blk_mem_gen_v8_4_7,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "blk_mem_gen_v8_4_7,Vivado 2023.2" *) 
(* NotValidForBitStream *)
module spram_256x64
   (clka,
    ena,
    wea,
    addra,
    dina,
    douta);
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME BRAM_PORTA, MEM_SIZE 8192, MEM_WIDTH 32, MEM_ECC NONE, MASTER_TYPE OTHER, READ_LATENCY 1" *) input clka;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA EN" *) input ena;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA WE" *) input [0:0]wea;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA ADDR" *) input [7:0]addra;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA DIN" *) input [63:0]dina;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA DOUT" *) output [63:0]douta;

  wire [7:0]addra;
  wire clka;
  wire [63:0]dina;
  wire [63:0]douta;
  wire ena;
  wire [0:0]wea;
  wire NLW_U0_dbiterr_UNCONNECTED;
  wire NLW_U0_rsta_busy_UNCONNECTED;
  wire NLW_U0_rstb_busy_UNCONNECTED;
  wire NLW_U0_s_axi_arready_UNCONNECTED;
  wire NLW_U0_s_axi_awready_UNCONNECTED;
  wire NLW_U0_s_axi_bvalid_UNCONNECTED;
  wire NLW_U0_s_axi_dbiterr_UNCONNECTED;
  wire NLW_U0_s_axi_rlast_UNCONNECTED;
  wire NLW_U0_s_axi_rvalid_UNCONNECTED;
  wire NLW_U0_s_axi_sbiterr_UNCONNECTED;
  wire NLW_U0_s_axi_wready_UNCONNECTED;
  wire NLW_U0_sbiterr_UNCONNECTED;
  wire [63:0]NLW_U0_doutb_UNCONNECTED;
  wire [7:0]NLW_U0_rdaddrecc_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_bid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_bresp_UNCONNECTED;
  wire [7:0]NLW_U0_s_axi_rdaddrecc_UNCONNECTED;
  wire [63:0]NLW_U0_s_axi_rdata_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_rid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_rresp_UNCONNECTED;

  (* C_ADDRA_WIDTH = "8" *) 
  (* C_ADDRB_WIDTH = "8" *) 
  (* C_ALGORITHM = "1" *) 
  (* C_AXI_ID_WIDTH = "4" *) 
  (* C_AXI_SLAVE_TYPE = "0" *) 
  (* C_AXI_TYPE = "1" *) 
  (* C_BYTE_SIZE = "9" *) 
  (* C_COMMON_CLK = "0" *) 
  (* C_COUNT_18K_BRAM = "0" *) 
  (* C_COUNT_36K_BRAM = "1" *) 
  (* C_CTRL_ECC_ALGO = "NONE" *) 
  (* C_DEFAULT_DATA = "0" *) 
  (* C_DISABLE_WARN_BHV_COLL = "0" *) 
  (* C_DISABLE_WARN_BHV_RANGE = "0" *) 
  (* C_ELABORATION_DIR = "./" *) 
  (* C_ENABLE_32BIT_ADDRESS = "0" *) 
  (* C_EN_DEEPSLEEP_PIN = "0" *) 
  (* C_EN_ECC_PIPE = "0" *) 
  (* C_EN_RDADDRA_CHG = "0" *) 
  (* C_EN_RDADDRB_CHG = "0" *) 
  (* C_EN_SAFETY_CKT = "0" *) 
  (* C_EN_SHUTDOWN_PIN = "0" *) 
  (* C_EN_SLEEP_PIN = "0" *) 
  (* C_EST_POWER_SUMMARY = "Estimated Power for IP     :     6.371475 mW" *) 
  (* C_FAMILY = "artix7" *) 
  (* C_HAS_AXI_ID = "0" *) 
  (* C_HAS_ENA = "1" *) 
  (* C_HAS_ENB = "0" *) 
  (* C_HAS_INJECTERR = "0" *) 
  (* C_HAS_MEM_OUTPUT_REGS_A = "0" *) 
  (* C_HAS_MEM_OUTPUT_REGS_B = "0" *) 
  (* C_HAS_MUX_OUTPUT_REGS_A = "0" *) 
  (* C_HAS_MUX_OUTPUT_REGS_B = "0" *) 
  (* C_HAS_REGCEA = "0" *) 
  (* C_HAS_REGCEB = "0" *) 
  (* C_HAS_RSTA = "0" *) 
  (* C_HAS_RSTB = "0" *) 
  (* C_HAS_SOFTECC_INPUT_REGS_A = "0" *) 
  (* C_HAS_SOFTECC_OUTPUT_REGS_B = "0" *) 
  (* C_INITA_VAL = "0" *) 
  (* C_INITB_VAL = "0" *) 
  (* C_INIT_FILE = "spram_256x64.mem" *) 
  (* C_INIT_FILE_NAME = "no_coe_file_loaded" *) 
  (* C_INTERFACE_TYPE = "0" *) 
  (* C_LOAD_INIT_FILE = "0" *) 
  (* C_MEM_TYPE = "0" *) 
  (* C_MUX_PIPELINE_STAGES = "0" *) 
  (* C_PRIM_TYPE = "1" *) 
  (* C_READ_DEPTH_A = "256" *) 
  (* C_READ_DEPTH_B = "256" *) 
  (* C_READ_LATENCY_A = "1" *) 
  (* C_READ_LATENCY_B = "1" *) 
  (* C_READ_WIDTH_A = "64" *) 
  (* C_READ_WIDTH_B = "64" *) 
  (* C_RSTRAM_A = "0" *) 
  (* C_RSTRAM_B = "0" *) 
  (* C_RST_PRIORITY_A = "CE" *) 
  (* C_RST_PRIORITY_B = "CE" *) 
  (* C_SIM_COLLISION_CHECK = "ALL" *) 
  (* C_USE_BRAM_BLOCK = "0" *) 
  (* C_USE_BYTE_WEA = "0" *) 
  (* C_USE_BYTE_WEB = "0" *) 
  (* C_USE_DEFAULT_DATA = "0" *) 
  (* C_USE_ECC = "0" *) 
  (* C_USE_SOFTECC = "0" *) 
  (* C_USE_URAM = "0" *) 
  (* C_WEA_WIDTH = "1" *) 
  (* C_WEB_WIDTH = "1" *) 
  (* C_WRITE_DEPTH_A = "256" *) 
  (* C_WRITE_DEPTH_B = "256" *) 
  (* C_WRITE_MODE_A = "NO_CHANGE" *) 
  (* C_WRITE_MODE_B = "WRITE_FIRST" *) 
  (* C_WRITE_WIDTH_A = "64" *) 
  (* C_WRITE_WIDTH_B = "64" *) 
  (* C_XDEVICEFAMILY = "artix7" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  (* is_du_within_envelope = "true" *) 
  spram_256x64_blk_mem_gen_v8_4_7 U0
       (.addra(addra),
        .addrb({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .clka(clka),
        .clkb(1'b0),
        .dbiterr(NLW_U0_dbiterr_UNCONNECTED),
        .deepsleep(1'b0),
        .dina(dina),
        .dinb({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .douta(douta),
        .doutb(NLW_U0_doutb_UNCONNECTED[63:0]),
        .eccpipece(1'b0),
        .ena(ena),
        .enb(1'b0),
        .injectdbiterr(1'b0),
        .injectsbiterr(1'b0),
        .rdaddrecc(NLW_U0_rdaddrecc_UNCONNECTED[7:0]),
        .regcea(1'b0),
        .regceb(1'b0),
        .rsta(1'b0),
        .rsta_busy(NLW_U0_rsta_busy_UNCONNECTED),
        .rstb(1'b0),
        .rstb_busy(NLW_U0_rstb_busy_UNCONNECTED),
        .s_aclk(1'b0),
        .s_aresetn(1'b0),
        .s_axi_araddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arburst({1'b0,1'b0}),
        .s_axi_arid({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arlen({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arready(NLW_U0_s_axi_arready_UNCONNECTED),
        .s_axi_arsize({1'b0,1'b0,1'b0}),
        .s_axi_arvalid(1'b0),
        .s_axi_awaddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awburst({1'b0,1'b0}),
        .s_axi_awid({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awlen({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awready(NLW_U0_s_axi_awready_UNCONNECTED),
        .s_axi_awsize({1'b0,1'b0,1'b0}),
        .s_axi_awvalid(1'b0),
        .s_axi_bid(NLW_U0_s_axi_bid_UNCONNECTED[3:0]),
        .s_axi_bready(1'b0),
        .s_axi_bresp(NLW_U0_s_axi_bresp_UNCONNECTED[1:0]),
        .s_axi_bvalid(NLW_U0_s_axi_bvalid_UNCONNECTED),
        .s_axi_dbiterr(NLW_U0_s_axi_dbiterr_UNCONNECTED),
        .s_axi_injectdbiterr(1'b0),
        .s_axi_injectsbiterr(1'b0),
        .s_axi_rdaddrecc(NLW_U0_s_axi_rdaddrecc_UNCONNECTED[7:0]),
        .s_axi_rdata(NLW_U0_s_axi_rdata_UNCONNECTED[63:0]),
        .s_axi_rid(NLW_U0_s_axi_rid_UNCONNECTED[3:0]),
        .s_axi_rlast(NLW_U0_s_axi_rlast_UNCONNECTED),
        .s_axi_rready(1'b0),
        .s_axi_rresp(NLW_U0_s_axi_rresp_UNCONNECTED[1:0]),
        .s_axi_rvalid(NLW_U0_s_axi_rvalid_UNCONNECTED),
        .s_axi_sbiterr(NLW_U0_s_axi_sbiterr_UNCONNECTED),
        .s_axi_wdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_wlast(1'b0),
        .s_axi_wready(NLW_U0_s_axi_wready_UNCONNECTED),
        .s_axi_wstrb(1'b0),
        .s_axi_wvalid(1'b0),
        .sbiterr(NLW_U0_sbiterr_UNCONNECTED),
        .shutdown(1'b0),
        .sleep(1'b0),
        .wea(wea),
        .web(1'b0));
endmodule
`pragma protect begin_protected
`pragma protect version = 1
`pragma protect encrypt_agent = "XILINX"
`pragma protect encrypt_agent_info = "Xilinx Encryption Tool 2023.2"
`pragma protect key_keyowner="Synopsys", key_keyname="SNPS-VCS-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
jLV29U0rrfMIZhYJzdoUrPoqB9eHQ5NXmWyCdqnN3Wgm+GU4C3zthrN1m4QGiaj0thPCIynZbX+0
7yjtkv+T5ByJ6NhiofAwWseGLvPXlYu6ERAPvi4SAYpF2VUqQHtPAbPmnPubGdDRgIEpeobF7hsz
rEcpEru1pyiScUriyuo=

`pragma protect key_keyowner="Aldec", key_keyname="ALDEC15_001", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
vsoizVrOONWw/DhjRLEYrtRmtji+Ok63CbpSg/l9VnoKAi8tAzqRbQ57atGB2N6IGGbKHkbK2Uzh
EHgWvYZeyt4hE+bpQX91vc9PNxfjQMGzPoFD3jCWk30EmEk+AND39eWx+DhJ8xhFuucoOQ2GwyAk
B+Mjs15naPE7DvlHel8hnD4dfSdYhGKp96oozu8JeBto8aHG6poOuYkxSwaut7NCI+mabCkMxtMp
RrydgmRuTvhRTbJMyx5CxFSZTRDrS5aU1vaRlnMiqKCI7g2KY9pemYaJsFeVodBuo6IyKGynyEhs
wr+VtUhQDtaVhMkwB95WwmMoDk9F2L5Au1I+TQ==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VELOCE-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
W081dPMCWhKs5YlQD7n3zvf7+PTcnb8eFWxoVs8+zHLkxDMA1klITbsfztGYvJFce8Yao5XQLLqZ
oUE5Pq2arq+zwICFUcLjdMsmP1WmL82znHOPHm83zNwrxWMloHkySAqzFbgJeHa973uZqj0M8ydc
sYmzCYVlGVjt0QX0xqA=

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VERIF-SIM-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
Zpc3MmdLWaVOv+S4z2POuoyslYoAbWc+Npxq2UyQRtDwf566IId3uwAetolMAgfLo/G3ezuSOXMn
8NznS37h9XvmVrxA50SAux68P87WgkLtiUYqM3CMBKkxNlZ/TR8WzTuQyFdvzkOE9lp8HC7LXnk5
RDsnOM+su46FW7ysY01COslo9Xc7rhs6WFqx29+Xcqk8+ZMLSzaJfuwZdNmJFS3Q1vhlq3ZeYqMl
wMieB731KsPxjxp7VKNHpTbgFryC2isqc4ohBDOt52M/Bz4B/rIpFeHfZ7X3jWSiKtSuBsDN2NXf
EMjfAT248dlK7NxJ+NBNPhS5sLxTiGyQhta57A==

`pragma protect key_keyowner="Real Intent", key_keyname="RI-RSA-KEY-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
rPMYqnkKhJKV1wltOfDrKos9ZbucaoX3WGTuqsdLkGpcKObzslHBwlGrKtWV7bZYmS2SM+QuEMfa
CE+tCUdsSiprp+n5BuSQlJa6BJ8mlqccjoo/JLw2QEmUhyMXQ3TLGomGGoZdeTmMPXhUBAOyLPea
Ddc8mgtTN8Kpy117GOTXDKP+IKJqW01fLrPJpgEhFiJCbyElLgtCRWmI94gX+y4XNVS0Cd1YwNw6
4nHgnEdC7fXARDKcYO3VsWC/pdzPQgursXloNLrVYa6i2xr+8E1V0+nSWwNYQZP7XUIVqXKMU8Ea
bT4acXrRCF/5tJJ5B9JparYI0zxXSbaakn1dIw==

`pragma protect key_keyowner="Xilinx", key_keyname="xilinxt_2022_10", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
mfroTgL8g2pyIXQ/mGO9YHm19cd5mOlJ++qpusOYeVxGmkIhvF4aKx+AyIUz2yGGAeCtOzIasHty
pyqKgZhibSqxcpHgR0m6GOxXXOXJiHaK8NzxUzXeRJovcBI/WjtDhXeb1LRMI1J97jVBtJPJQH0Y
fGOD7jWvkvQwxnrZdyLp6kPWgSIcavHHDbO7iJv4gnyGp6W3/FCDo2RKWNLoW+SNjSdLZ6YRP8a+
ldaGU8TYvJ03KWlmik7repuN6AwxCjg2KeQ+x1sBAEXzROXomuSbvX3ZAo8UiIKAQY1SJumHLG3L
QI/S4Wbl1Hz6LDTsttMwP480gq6+tb6s1E4oWw==

`pragma protect key_keyowner="Metrics Technologies Inc.", key_keyname="DSim", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
QJIabgm8dx/gVHbOQFwt8maOKVHFgkpZTPR6dzD8fqoGo9M9oGPTqBqchtPZWgv2UYFF2KEUSlV4
L3SDXBKrLs+NsAVTcICaEMiEi6j82zj/C1LsPkQfS8RLrg0ab8lbDMb5YqJ7lkHs3iM65x2iN1Mf
66cTgCbkAdl3rDpab75btpTQt5ZKiq5CSY3RZfyIW0uWbTGTELm6liuRKM9+K8BQwTU7A+FFFQBA
/9eJwQYzNNA/iwoYJ2WTPd6pBlzXriNLu9M+/2bYicNBSuH1PBR9v2ESrTB6k7EiV1zvBXV9NuG/
sFt4MumWMuSNwP2W38bQATxxW/l0IrmaXGOC/w==

`pragma protect key_keyowner="Atrenta", key_keyname="ATR-SG-RSA-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=384)
`pragma protect key_block
lhKf/Vgj6pHpme1ji4HVe36BU8pMkam/2I9lFeyOiBnIbzgdEGfLJBcEvkL33A7s0hxa6LFbHnkT
upgMpPjmIghBz3xUQ13vpiY152thFec6qvlcdg1r+GTmnBOSFl6g/OfZ3eFUhfsve6ZjQHpXnKFo
a55hN2+eP1EG9+VxGeM7XkHaeFhEIry52qtnmg072KEFIwRiGs2d/TJ4AqupuIdIiP1kTN9k+oqa
2ta1vdtqPY0dDHqrf+5YSd0CejkhQeCqg/bauLP3755SwdOPRgooG5ANT8hUpTiFMFXtU+GC9NSp
evJtMHUy1NbgMmhFHO+w3URLEdjSaBxZPD7YLdWkF65jY526tJzoek+BzEKoBaGfCaY7O1nHKXm+
89k3rPUy0Xo4/0nHpno+N/Db09heJPbnGsCwN/l+KnR6Lz8kvWziBjZe0ijOkKI+T12y3T1VeOtY
H/aqtNlQt1mhFwrbw6ezaAiDPVbCQXnly6b4tbb8+nFsxWOGIGAfLozB

`pragma protect key_keyowner="Cadence Design Systems.", key_keyname="CDS_RSA_KEY_VER_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
PNsQ8uEcQYrl+GaDuBaq1tQ5br5aAdaqHnyrc0NVu/JnQUk53jaiLx8Oz5fNACvWelUUk2/C+P5I
b2rbU1bb/dC6TqC5J1N0yoMYRYw58u4Lrl8Kgqgt9Rlph5Qgzzfxp+oblXF/pO4mRyAXpZhpNkFT
0Ar9BUtPOTOtJ9/g53SRnZ6GjxzfeD+25J4fcXBNo2gCTgUkwiLSsJRwTB/cJmn+dZPwPdIOHEP9
TkfDK+OrbLYO3T+DFBTCMRNH2NB1J9sc5s+nPU8iYnjgPTo6HoGW+LIlCz6yNJMZzJzoeW708utc
0fJXkT7vLDVh7olvy3V9AAY8Do0YR1kiZlhVhQ==

`pragma protect key_keyowner="Synplicity", key_keyname="SYNP15_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
zAz8RnGHFebkJFAS+gjC+mXHW7m7We+JgSmIz15mS01u/4+9Ng0sJfkeXOClmVPTQ2Mp2Yuv6/6f
ehzUTcANilWsqLM6Q1FToCPNX/NTqodlcHirGM7b5R9yevouNT/aqH12nmbunBQmBHmehNutdCjG
r6Z7kZgeZ2ZE7MMOF0rTy1XHEPkqgMNTRoS8R/pPWPTW4/j+bn3aJj0Q/fTz4Gi3mbSUKWs2fREQ
UKiuolNJkN6DiDvhlVYHUyytXNJG44ikmBXehoQQRLapkYaxnQmMRT1ok9uY6pKoy71CtvJ3Mt2x
EQv1GU2i4qQyAOwa0mkEohWXduicU6tDz3zQwQ==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-PREC-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
TK3eE9V+v1z2P1KjG4GrjhA1n3qDOpNzLGXdtjnjhF0QBFPSuhC+nmNqTPOb3p2a9r5KD0miY3Cd
+KpjH6Ao09E2/LD2Go4aLQh6vP+9BldlSKEwCGfx2NjBQrXWVH21lQR7IRjOvyTOclpd7SgtUJLw
dvebETyLiKr9C6RfnIBeptuCA3iJlXfwkh6I0JfzD5WBizQkotioZmmrXv5105pCXQ4Ta1WThFsA
2ll9dZeSjEDHUxxhfyfjryv9m4VL89ZDU/rGITsdptwB1BC1jLqmPDymY05lyECnjA6NIR5GGfI4
K2y2f4GfikKoN5r9IOvFzw963Wm82ZZPtXOKGg==

`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 30000)
`pragma protect data_block
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
ExxGTMJE0gH2nKOLIyxuKRBm
`pragma protect end_protected
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;
    parameter GRES_WIDTH = 10000;
    parameter GRES_START = 10000;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    wire GRESTORE;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;
    wire FCSBO_GLBL;
    wire [3:0] DO_GLBL;
    wire [3:0] DI_GLBL;
   
    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;
    reg GRESTORE_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (strong1, weak0) GSR = GSR_int;
    assign (strong1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;
    assign (strong1, weak0) GRESTORE = GRESTORE_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

    initial begin 
	GRESTORE_int = 1'b0;
	#(GRES_START);
	GRESTORE_int = 1'b1;
	#(GRES_WIDTH);
	GRESTORE_int = 1'b0;
    end

endmodule
`endif
