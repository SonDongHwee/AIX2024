// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2023 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2023.2 (win64) Build 4029153 Fri Oct 13 20:14:34 MDT 2023
// Date        : Thu Mar 28 09:16:40 2024
// Host        : DESKTOP-5IEP7NP running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim
//               c:/Users/leewo/Documents/GitHub/AIX2024/build/07_SIC/07_SIC.gen/sources_1/ip/dpram_512x72/dpram_512x72_sim_netlist.v
// Design      : dpram_512x72
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7a100tcsg324-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "dpram_512x72,blk_mem_gen_v8_4_7,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "blk_mem_gen_v8_4_7,Vivado 2023.2" *) 
(* NotValidForBitStream *)
module dpram_512x72
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
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA ADDR" *) input [8:0]addra;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA DIN" *) input [71:0]dina;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME BRAM_PORTB, MEM_SIZE 8192, MEM_WIDTH 32, MEM_ECC NONE, MASTER_TYPE OTHER, READ_LATENCY 1" *) input clkb;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB EN" *) input enb;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB ADDR" *) input [8:0]addrb;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB DOUT" *) output [71:0]doutb;

  wire [8:0]addra;
  wire [8:0]addrb;
  wire clka;
  wire clkb;
  wire [71:0]dina;
  wire [71:0]doutb;
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
  wire [71:0]NLW_U0_douta_UNCONNECTED;
  wire [8:0]NLW_U0_rdaddrecc_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_bid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_bresp_UNCONNECTED;
  wire [8:0]NLW_U0_s_axi_rdaddrecc_UNCONNECTED;
  wire [71:0]NLW_U0_s_axi_rdata_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_rid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_rresp_UNCONNECTED;

  (* C_ADDRA_WIDTH = "9" *) 
  (* C_ADDRB_WIDTH = "9" *) 
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
  (* C_EST_POWER_SUMMARY = "Estimated Power for IP     :     7.2477 mW" *) 
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
  (* C_INIT_FILE = "dpram_512x72.mem" *) 
  (* C_INIT_FILE_NAME = "no_coe_file_loaded" *) 
  (* C_INTERFACE_TYPE = "0" *) 
  (* C_LOAD_INIT_FILE = "0" *) 
  (* C_MEM_TYPE = "1" *) 
  (* C_MUX_PIPELINE_STAGES = "0" *) 
  (* C_PRIM_TYPE = "1" *) 
  (* C_READ_DEPTH_A = "512" *) 
  (* C_READ_DEPTH_B = "512" *) 
  (* C_READ_LATENCY_A = "1" *) 
  (* C_READ_LATENCY_B = "1" *) 
  (* C_READ_WIDTH_A = "72" *) 
  (* C_READ_WIDTH_B = "72" *) 
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
  (* C_WRITE_DEPTH_A = "512" *) 
  (* C_WRITE_DEPTH_B = "512" *) 
  (* C_WRITE_MODE_A = "NO_CHANGE" *) 
  (* C_WRITE_MODE_B = "WRITE_FIRST" *) 
  (* C_WRITE_WIDTH_A = "72" *) 
  (* C_WRITE_WIDTH_B = "72" *) 
  (* C_XDEVICEFAMILY = "artix7" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  (* is_du_within_envelope = "true" *) 
  dpram_512x72_blk_mem_gen_v8_4_7 U0
       (.addra(addra),
        .addrb(addrb),
        .clka(clka),
        .clkb(clkb),
        .dbiterr(NLW_U0_dbiterr_UNCONNECTED),
        .deepsleep(1'b0),
        .dina(dina),
        .dinb({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .douta(NLW_U0_douta_UNCONNECTED[71:0]),
        .doutb(doutb),
        .eccpipece(1'b0),
        .ena(ena),
        .enb(enb),
        .injectdbiterr(1'b0),
        .injectsbiterr(1'b0),
        .rdaddrecc(NLW_U0_rdaddrecc_UNCONNECTED[8:0]),
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
        .s_axi_rdaddrecc(NLW_U0_s_axi_rdaddrecc_UNCONNECTED[8:0]),
        .s_axi_rdata(NLW_U0_s_axi_rdata_UNCONNECTED[71:0]),
        .s_axi_rid(NLW_U0_s_axi_rid_UNCONNECTED[3:0]),
        .s_axi_rlast(NLW_U0_s_axi_rlast_UNCONNECTED),
        .s_axi_rready(1'b0),
        .s_axi_rresp(NLW_U0_s_axi_rresp_UNCONNECTED[1:0]),
        .s_axi_rvalid(NLW_U0_s_axi_rvalid_UNCONNECTED),
        .s_axi_sbiterr(NLW_U0_s_axi_sbiterr_UNCONNECTED),
        .s_axi_wdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
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
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 31056)
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
