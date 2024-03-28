// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2023 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2023.2 (win64) Build 4029153 Fri Oct 13 20:14:34 MDT 2023
// Date        : Thu Mar 28 09:26:46 2024
// Host        : DESKTOP-5IEP7NP running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim
//               c:/Users/leewo/Documents/GitHub/AIX2024/build/07_SIC/07_SIC.gen/sources_1/ip/spram_832x32/spram_832x32_sim_netlist.v
// Design      : spram_832x32
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7a100tcsg324-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "spram_832x32,blk_mem_gen_v8_4_7,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "blk_mem_gen_v8_4_7,Vivado 2023.2" *) 
(* NotValidForBitStream *)
module spram_832x32
   (clka,
    ena,
    wea,
    addra,
    dina,
    douta);
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME BRAM_PORTA, MEM_SIZE 8192, MEM_WIDTH 32, MEM_ECC NONE, MASTER_TYPE OTHER, READ_LATENCY 1" *) input clka;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA EN" *) input ena;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA WE" *) input [0:0]wea;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA ADDR" *) input [9:0]addra;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA DIN" *) input [31:0]dina;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA DOUT" *) output [31:0]douta;

  wire [9:0]addra;
  wire clka;
  wire [31:0]dina;
  wire [31:0]douta;
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
  wire [31:0]NLW_U0_doutb_UNCONNECTED;
  wire [9:0]NLW_U0_rdaddrecc_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_bid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_bresp_UNCONNECTED;
  wire [9:0]NLW_U0_s_axi_rdaddrecc_UNCONNECTED;
  wire [31:0]NLW_U0_s_axi_rdata_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_rid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_rresp_UNCONNECTED;

  (* C_ADDRA_WIDTH = "10" *) 
  (* C_ADDRB_WIDTH = "10" *) 
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
  (* C_EST_POWER_SUMMARY = "Estimated Power for IP     :     2.632725 mW" *) 
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
  (* C_INIT_FILE = "spram_832x32.mem" *) 
  (* C_INIT_FILE_NAME = "no_coe_file_loaded" *) 
  (* C_INTERFACE_TYPE = "0" *) 
  (* C_LOAD_INIT_FILE = "0" *) 
  (* C_MEM_TYPE = "0" *) 
  (* C_MUX_PIPELINE_STAGES = "0" *) 
  (* C_PRIM_TYPE = "1" *) 
  (* C_READ_DEPTH_A = "832" *) 
  (* C_READ_DEPTH_B = "832" *) 
  (* C_READ_LATENCY_A = "1" *) 
  (* C_READ_LATENCY_B = "1" *) 
  (* C_READ_WIDTH_A = "32" *) 
  (* C_READ_WIDTH_B = "32" *) 
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
  (* C_WRITE_DEPTH_A = "832" *) 
  (* C_WRITE_DEPTH_B = "832" *) 
  (* C_WRITE_MODE_A = "NO_CHANGE" *) 
  (* C_WRITE_MODE_B = "WRITE_FIRST" *) 
  (* C_WRITE_WIDTH_A = "32" *) 
  (* C_WRITE_WIDTH_B = "32" *) 
  (* C_XDEVICEFAMILY = "artix7" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  (* is_du_within_envelope = "true" *) 
  spram_832x32_blk_mem_gen_v8_4_7 U0
       (.addra(addra),
        .addrb({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .clka(clka),
        .clkb(1'b0),
        .dbiterr(NLW_U0_dbiterr_UNCONNECTED),
        .deepsleep(1'b0),
        .dina(dina),
        .dinb({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .douta(douta),
        .doutb(NLW_U0_doutb_UNCONNECTED[31:0]),
        .eccpipece(1'b0),
        .ena(ena),
        .enb(1'b0),
        .injectdbiterr(1'b0),
        .injectsbiterr(1'b0),
        .rdaddrecc(NLW_U0_rdaddrecc_UNCONNECTED[9:0]),
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
        .s_axi_rdaddrecc(NLW_U0_s_axi_rdaddrecc_UNCONNECTED[9:0]),
        .s_axi_rdata(NLW_U0_s_axi_rdata_UNCONNECTED[31:0]),
        .s_axi_rid(NLW_U0_s_axi_rid_UNCONNECTED[3:0]),
        .s_axi_rlast(NLW_U0_s_axi_rlast_UNCONNECTED),
        .s_axi_rready(1'b0),
        .s_axi_rresp(NLW_U0_s_axi_rresp_UNCONNECTED[1:0]),
        .s_axi_rvalid(NLW_U0_s_axi_rvalid_UNCONNECTED),
        .s_axi_sbiterr(NLW_U0_s_axi_sbiterr_UNCONNECTED),
        .s_axi_wdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
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
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 27920)
`pragma protect data_block
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
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
