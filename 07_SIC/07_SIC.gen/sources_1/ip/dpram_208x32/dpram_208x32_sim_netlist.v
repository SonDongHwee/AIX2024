// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2023 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2023.2 (win64) Build 4029153 Fri Oct 13 20:14:34 MDT 2023
// Date        : Thu Mar 28 09:22:21 2024
// Host        : DESKTOP-5IEP7NP running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim
//               c:/Users/leewo/Documents/GitHub/AIX2024/build/07_SIC/07_SIC.gen/sources_1/ip/dpram_208x32/dpram_208x32_sim_netlist.v
// Design      : dpram_208x32
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7a100tcsg324-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "dpram_208x32,blk_mem_gen_v8_4_7,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "blk_mem_gen_v8_4_7,Vivado 2023.2" *) 
(* NotValidForBitStream *)
module dpram_208x32
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
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA ADDR" *) input [7:0]addra;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA DIN" *) input [31:0]dina;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME BRAM_PORTB, MEM_SIZE 8192, MEM_WIDTH 32, MEM_ECC NONE, MASTER_TYPE OTHER, READ_LATENCY 1" *) input clkb;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB EN" *) input enb;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB ADDR" *) input [7:0]addrb;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB DOUT" *) output [31:0]doutb;

  wire [7:0]addra;
  wire [7:0]addrb;
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
  wire [7:0]NLW_U0_rdaddrecc_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_bid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_bresp_UNCONNECTED;
  wire [7:0]NLW_U0_s_axi_rdaddrecc_UNCONNECTED;
  wire [31:0]NLW_U0_s_axi_rdata_UNCONNECTED;
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
  (* C_INIT_FILE = "dpram_208x32.mem" *) 
  (* C_INIT_FILE_NAME = "no_coe_file_loaded" *) 
  (* C_INTERFACE_TYPE = "0" *) 
  (* C_LOAD_INIT_FILE = "0" *) 
  (* C_MEM_TYPE = "1" *) 
  (* C_MUX_PIPELINE_STAGES = "0" *) 
  (* C_PRIM_TYPE = "1" *) 
  (* C_READ_DEPTH_A = "208" *) 
  (* C_READ_DEPTH_B = "208" *) 
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
  (* C_WRITE_DEPTH_A = "208" *) 
  (* C_WRITE_DEPTH_B = "208" *) 
  (* C_WRITE_MODE_A = "NO_CHANGE" *) 
  (* C_WRITE_MODE_B = "WRITE_FIRST" *) 
  (* C_WRITE_WIDTH_A = "32" *) 
  (* C_WRITE_WIDTH_B = "32" *) 
  (* C_XDEVICEFAMILY = "artix7" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  (* is_du_within_envelope = "true" *) 
  dpram_208x32_blk_mem_gen_v8_4_7 U0
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
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 20688)
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
