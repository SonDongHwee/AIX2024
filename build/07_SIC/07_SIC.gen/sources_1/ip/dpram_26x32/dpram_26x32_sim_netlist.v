// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2023 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2023.2 (win64) Build 4029153 Fri Oct 13 20:14:34 MDT 2023
// Date        : Thu Mar 28 09:18:37 2024
// Host        : DESKTOP-5IEP7NP running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim
//               c:/Users/leewo/Documents/GitHub/AIX2024/build/07_SIC/07_SIC.gen/sources_1/ip/dpram_26x32/dpram_26x32_sim_netlist.v
// Design      : dpram_26x32
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7a100tcsg324-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "dpram_26x32,blk_mem_gen_v8_4_7,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "blk_mem_gen_v8_4_7,Vivado 2023.2" *) 
(* NotValidForBitStream *)
module dpram_26x32
   (clka,
    ena,
    wea,
    addra,
    dina,
    clkb,
    enb,
    addrb,
    doutb);
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME BRAM_PORTA, MEM_SIZE 8192, MEM_WIDTH 32, MEM_ECC NONE, MASTER_TYPE OTHER, READ_LATENCY 1" *) input clka;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA EN" *) input ena;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA WE" *) input [0:0]wea;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA ADDR" *) input [4:0]addra;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA DIN" *) input [31:0]dina;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME BRAM_PORTB, MEM_SIZE 8192, MEM_WIDTH 32, MEM_ECC NONE, MASTER_TYPE OTHER, READ_LATENCY 1" *) input clkb;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB EN" *) input enb;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB ADDR" *) input [4:0]addrb;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB DOUT" *) output [31:0]doutb;

  wire [4:0]addra;
  wire [4:0]addrb;
  wire clka;
  wire clkb;
  wire [31:0]dina;
  wire [31:0]doutb;
  wire ena;
  wire enb;
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
  wire [31:0]NLW_U0_douta_UNCONNECTED;
  wire [4:0]NLW_U0_rdaddrecc_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_bid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_bresp_UNCONNECTED;
  wire [4:0]NLW_U0_s_axi_rdaddrecc_UNCONNECTED;
  wire [31:0]NLW_U0_s_axi_rdata_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_rid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_rresp_UNCONNECTED;

  (* C_ADDRA_WIDTH = "5" *) 
  (* C_ADDRB_WIDTH = "5" *) 
  (* C_ALGORITHM = "1" *) 
  (* C_AXI_ID_WIDTH = "4" *) 
  (* C_AXI_SLAVE_TYPE = "0" *) 
  (* C_AXI_TYPE = "1" *) 
  (* C_BYTE_SIZE = "9" *) 
  (* C_COMMON_CLK = "0" *) 
  (* C_COUNT_18K_BRAM = "1" *) 
  (* C_COUNT_36K_BRAM = "0" *) 
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
  (* C_EST_POWER_SUMMARY = "Estimated Power for IP     :     3.68295 mW" *) 
  (* C_FAMILY = "artix7" *) 
  (* C_HAS_AXI_ID = "0" *) 
  (* C_HAS_ENA = "1" *) 
  (* C_HAS_ENB = "1" *) 
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
  (* C_INIT_FILE = "dpram_26x32.mem" *) 
  (* C_INIT_FILE_NAME = "no_coe_file_loaded" *) 
  (* C_INTERFACE_TYPE = "0" *) 
  (* C_LOAD_INIT_FILE = "0" *) 
  (* C_MEM_TYPE = "1" *) 
  (* C_MUX_PIPELINE_STAGES = "0" *) 
  (* C_PRIM_TYPE = "1" *) 
  (* C_READ_DEPTH_A = "26" *) 
  (* C_READ_DEPTH_B = "26" *) 
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
  (* C_WRITE_DEPTH_A = "26" *) 
  (* C_WRITE_DEPTH_B = "26" *) 
  (* C_WRITE_MODE_A = "NO_CHANGE" *) 
  (* C_WRITE_MODE_B = "WRITE_FIRST" *) 
  (* C_WRITE_WIDTH_A = "32" *) 
  (* C_WRITE_WIDTH_B = "32" *) 
  (* C_XDEVICEFAMILY = "artix7" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  (* is_du_within_envelope = "true" *) 
  dpram_26x32_blk_mem_gen_v8_4_7 U0
       (.addra(addra),
        .addrb(addrb),
        .clka(clka),
        .clkb(clkb),
        .dbiterr(NLW_U0_dbiterr_UNCONNECTED),
        .deepsleep(1'b0),
        .dina(dina),
        .dinb({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .douta(NLW_U0_douta_UNCONNECTED[31:0]),
        .doutb(doutb),
        .eccpipece(1'b0),
        .ena(ena),
        .enb(enb),
        .injectdbiterr(1'b0),
        .injectsbiterr(1'b0),
        .rdaddrecc(NLW_U0_rdaddrecc_UNCONNECTED[4:0]),
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
        .s_axi_rdaddrecc(NLW_U0_s_axi_rdaddrecc_UNCONNECTED[4:0]),
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
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 20464)
`pragma protect data_block
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
yw==
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
