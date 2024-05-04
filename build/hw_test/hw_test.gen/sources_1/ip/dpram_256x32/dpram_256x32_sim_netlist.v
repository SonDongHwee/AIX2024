// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2023 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2023.2 (win64) Build 4029153 Fri Oct 13 20:14:34 MDT 2023
// Date        : Sun Apr 28 15:26:22 2024
// Host        : DESKTOP-5IEP7NP running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim
//               c:/Users/leewo/Documents/GitHub/AIX2024/build/hw_test/hw_test.gen/sources_1/ip/dpram_256x32/dpram_256x32_sim_netlist.v
// Design      : dpram_256x32
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7a100tcsg324-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "dpram_256x32,blk_mem_gen_v8_4_7,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "blk_mem_gen_v8_4_7,Vivado 2023.2" *) 
(* NotValidForBitStream *)
module dpram_256x32
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
  (* C_INIT_FILE = "dpram_256x32.mem" *) 
  (* C_INIT_FILE_NAME = "no_coe_file_loaded" *) 
  (* C_INTERFACE_TYPE = "0" *) 
  (* C_LOAD_INIT_FILE = "0" *) 
  (* C_MEM_TYPE = "1" *) 
  (* C_MUX_PIPELINE_STAGES = "0" *) 
  (* C_PRIM_TYPE = "1" *) 
  (* C_READ_DEPTH_A = "256" *) 
  (* C_READ_DEPTH_B = "256" *) 
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
  (* C_WRITE_DEPTH_A = "256" *) 
  (* C_WRITE_DEPTH_B = "256" *) 
  (* C_WRITE_MODE_A = "NO_CHANGE" *) 
  (* C_WRITE_MODE_B = "WRITE_FIRST" *) 
  (* C_WRITE_WIDTH_A = "32" *) 
  (* C_WRITE_WIDTH_B = "32" *) 
  (* C_XDEVICEFAMILY = "artix7" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  (* is_du_within_envelope = "true" *) 
  dpram_256x32_blk_mem_gen_v8_4_7 U0
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
