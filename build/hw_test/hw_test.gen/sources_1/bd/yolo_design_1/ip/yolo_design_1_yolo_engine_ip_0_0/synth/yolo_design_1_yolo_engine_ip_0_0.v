// (c) Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// (c) Copyright 2022-2024 Advanced Micro Devices, Inc. All rights reserved.
// 
// This file contains confidential and proprietary information
// of AMD and is protected under U.S. and international copyright
// and other intellectual property laws.
// 
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// AMD, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND AMD HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) AMD shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or AMD had been advised of the
// possibility of the same.
// 
// CRITICAL APPLICATIONS
// AMD products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of AMD products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
// 
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
// 
// DO NOT MODIFY THIS FILE.


// IP VLNV: xilinx.com:user:yolo_engine_ip:1.0
// IP Revision: 2

(* X_CORE_INFO = "yolo_engine_ip,Vivado 2023.2" *)
(* CHECK_LICENSE_TYPE = "yolo_design_1_yolo_engine_ip_0_0,yolo_engine_ip,{}" *)
(* CORE_GENERATION_INFO = "yolo_design_1_yolo_engine_ip_0_0,yolo_engine_ip,{x_ipProduct=Vivado 2023.2,x_ipVendor=xilinx.com,x_ipLibrary=user,x_ipName=yolo_engine_ip,x_ipVersion=1.0,x_ipCoreRevision=2,x_ipLanguage=VERILOG,x_ipSimLanguage=MIXED,MEM_ADDRW=22,MEM_DW=16,A=32,D=32,I=4,L=8,M=4,AXI_WIDTH_AD=32,AXI_WIDTH_ID=4,AXI_WIDTH_DA=32,AXI_WIDTH_DS=4,C_S00_AXI_DATA_WIDTH=32,C_S00_AXI_ADDR_WIDTH=4}" *)
(* IP_DEFINITION_SOURCE = "package_project" *)
(* DowngradeIPIdentifiedWarnings = "yes" *)
module yolo_design_1_yolo_engine_ip_0_0 (
  M_ARVALID,
  M_ARREADY,
  M_ARADDR,
  M_ARID,
  M_ARLEN,
  M_ARSIZE,
  M_ARBURST,
  M_ARLOCK,
  M_ARCACHE,
  M_ARPROT,
  M_ARQOS,
  M_ARREGION,
  M_ARUSER,
  M_RVALID,
  M_RREADY,
  M_RDATA,
  M_RLAST,
  M_RID,
  M_RUSER,
  M_RRESP,
  M_AWVALID,
  M_AWREADY,
  M_AWADDR,
  M_AWID,
  M_AWLEN,
  M_AWSIZE,
  M_AWBURST,
  M_AWLOCK,
  M_AWCACHE,
  M_AWPROT,
  M_AWQOS,
  M_AWREGION,
  M_AWUSER,
  M_WVALID,
  M_WREADY,
  M_WDATA,
  M_WSTRB,
  M_WLAST,
  M_WID,
  M_WUSER,
  M_BVALID,
  M_BREADY,
  M_BRESP,
  M_BID,
  M_BUSER,
  s00_axi_aclk,
  s00_axi_aresetn,
  s00_axi_awaddr,
  s00_axi_awprot,
  s00_axi_awvalid,
  s00_axi_awready,
  s00_axi_wdata,
  s00_axi_wstrb,
  s00_axi_wvalid,
  s00_axi_wready,
  s00_axi_bresp,
  s00_axi_bvalid,
  s00_axi_bready,
  s00_axi_araddr,
  s00_axi_arprot,
  s00_axi_arvalid,
  s00_axi_arready,
  s00_axi_rdata,
  s00_axi_rresp,
  s00_axi_rvalid,
  s00_axi_rready
);

(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M ARVALID" *)
output wire M_ARVALID;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M ARREADY" *)
input wire M_ARREADY;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M ARADDR" *)
output wire [31 : 0] M_ARADDR;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M ARID" *)
output wire [3 : 0] M_ARID;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M ARLEN" *)
output wire [7 : 0] M_ARLEN;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M ARSIZE" *)
output wire [2 : 0] M_ARSIZE;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M ARBURST" *)
output wire [1 : 0] M_ARBURST;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M ARLOCK" *)
output wire [1 : 0] M_ARLOCK;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M ARCACHE" *)
output wire [3 : 0] M_ARCACHE;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M ARPROT" *)
output wire [2 : 0] M_ARPROT;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M ARQOS" *)
output wire [3 : 0] M_ARQOS;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M ARREGION" *)
output wire [3 : 0] M_ARREGION;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M ARUSER" *)
output wire [3 : 0] M_ARUSER;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M RVALID" *)
input wire M_RVALID;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M RREADY" *)
output wire M_RREADY;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M RDATA" *)
input wire [31 : 0] M_RDATA;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M RLAST" *)
input wire M_RLAST;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M RID" *)
input wire [3 : 0] M_RID;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M RUSER" *)
input wire [3 : 0] M_RUSER;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M RRESP" *)
input wire [1 : 0] M_RRESP;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M AWVALID" *)
output wire M_AWVALID;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M AWREADY" *)
input wire M_AWREADY;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M AWADDR" *)
output wire [31 : 0] M_AWADDR;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M AWID" *)
output wire [3 : 0] M_AWID;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M AWLEN" *)
output wire [7 : 0] M_AWLEN;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M AWSIZE" *)
output wire [2 : 0] M_AWSIZE;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M AWBURST" *)
output wire [1 : 0] M_AWBURST;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M AWLOCK" *)
output wire [1 : 0] M_AWLOCK;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M AWCACHE" *)
output wire [3 : 0] M_AWCACHE;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M AWPROT" *)
output wire [2 : 0] M_AWPROT;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M AWQOS" *)
output wire [3 : 0] M_AWQOS;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M AWREGION" *)
output wire [3 : 0] M_AWREGION;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M AWUSER" *)
output wire [3 : 0] M_AWUSER;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M WVALID" *)
output wire M_WVALID;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M WREADY" *)
input wire M_WREADY;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M WDATA" *)
output wire [31 : 0] M_WDATA;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M WSTRB" *)
output wire [3 : 0] M_WSTRB;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M WLAST" *)
output wire M_WLAST;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M WID" *)
output wire [3 : 0] M_WID;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M WUSER" *)
output wire [3 : 0] M_WUSER;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M BVALID" *)
input wire M_BVALID;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M BREADY" *)
output wire M_BREADY;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M BRESP" *)
input wire [1 : 0] M_BRESP;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M BID" *)
input wire [3 : 0] M_BID;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME M, DATA_WIDTH 32, PROTOCOL AXI4, FREQ_HZ 100000000, ID_WIDTH 4, ADDR_WIDTH 32, AWUSER_WIDTH 4, ARUSER_WIDTH 4, WUSER_WIDTH 4, RUSER_WIDTH 4, BUSER_WIDTH 1, READ_WRITE_MODE READ_WRITE, HAS_BURST 1, HAS_LOCK 1, HAS_PROT 1, HAS_CACHE 1, HAS_QOS 1, HAS_REGION 1, HAS_WSTRB 1, HAS_BRESP 1, HAS_RRESP 1, SUPPORTS_NARROW_BURST 1, NUM_READ_OUTSTANDING 2, NUM_WRITE_OUTSTANDING 2, MAX_BURST_LENGTH 256, PHASE 0.0, NUM_READ_THREADS 1, NUM_WRITE_THREADS 1, RUSER_BITS_PER_BYTE 0, WUSER_BITS_PE\
R_BYTE 0, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M BUSER" *)
input wire M_BUSER;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME s00_axi_aclk, ASSOCIATED_BUSIF s00_axi, ASSOCIATED_RESET s00_axi_aresetn, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, CLK_DOMAIN /clk_wiz_0_clk_out1, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 s00_axi_aclk CLK" *)
input wire s00_axi_aclk;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME s00_axi_aresetn, POLARITY ACTIVE_LOW, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 s00_axi_aresetn RST" *)
input wire s00_axi_aresetn;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s00_axi AWADDR" *)
input wire [3 : 0] s00_axi_awaddr;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s00_axi AWPROT" *)
input wire [2 : 0] s00_axi_awprot;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s00_axi AWVALID" *)
input wire s00_axi_awvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s00_axi AWREADY" *)
output wire s00_axi_awready;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s00_axi WDATA" *)
input wire [31 : 0] s00_axi_wdata;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s00_axi WSTRB" *)
input wire [3 : 0] s00_axi_wstrb;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s00_axi WVALID" *)
input wire s00_axi_wvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s00_axi WREADY" *)
output wire s00_axi_wready;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s00_axi BRESP" *)
output wire [1 : 0] s00_axi_bresp;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s00_axi BVALID" *)
output wire s00_axi_bvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s00_axi BREADY" *)
input wire s00_axi_bready;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s00_axi ARADDR" *)
input wire [3 : 0] s00_axi_araddr;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s00_axi ARPROT" *)
input wire [2 : 0] s00_axi_arprot;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s00_axi ARVALID" *)
input wire s00_axi_arvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s00_axi ARREADY" *)
output wire s00_axi_arready;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s00_axi RDATA" *)
output wire [31 : 0] s00_axi_rdata;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s00_axi RRESP" *)
output wire [1 : 0] s00_axi_rresp;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s00_axi RVALID" *)
output wire s00_axi_rvalid;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME s00_axi, DATA_WIDTH 32, PROTOCOL AXI4LITE, FREQ_HZ 100000000, ID_WIDTH 0, ADDR_WIDTH 4, AWUSER_WIDTH 0, ARUSER_WIDTH 0, WUSER_WIDTH 0, RUSER_WIDTH 0, BUSER_WIDTH 0, READ_WRITE_MODE READ_WRITE, HAS_BURST 0, HAS_LOCK 0, HAS_PROT 1, HAS_CACHE 0, HAS_QOS 0, HAS_REGION 0, HAS_WSTRB 1, HAS_BRESP 1, HAS_RRESP 1, SUPPORTS_NARROW_BURST 0, NUM_READ_OUTSTANDING 1, NUM_WRITE_OUTSTANDING 1, MAX_BURST_LENGTH 1, PHASE 0.0, CLK_DOMAIN /clk_wiz_0_clk_out1, NUM_READ_THREADS 1, NUM_WRITE_THREADS \
1, RUSER_BITS_PER_BYTE 0, WUSER_BITS_PER_BYTE 0, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s00_axi RREADY" *)
input wire s00_axi_rready;

  yolo_engine_ip #(
    .MEM_ADDRW(22),
    .MEM_DW(16),
    .A(32),
    .D(32),
    .I(4),
    .L(8),
    .M(4),
    .AXI_WIDTH_AD(32),
    .AXI_WIDTH_ID(4),
    .AXI_WIDTH_DA(32),
    .AXI_WIDTH_DS(4),
    .C_S00_AXI_DATA_WIDTH(32),
    .C_S00_AXI_ADDR_WIDTH(4)
  ) inst (
    .M_ARVALID(M_ARVALID),
    .M_ARREADY(M_ARREADY),
    .M_ARADDR(M_ARADDR),
    .M_ARID(M_ARID),
    .M_ARLEN(M_ARLEN),
    .M_ARSIZE(M_ARSIZE),
    .M_ARBURST(M_ARBURST),
    .M_ARLOCK(M_ARLOCK),
    .M_ARCACHE(M_ARCACHE),
    .M_ARPROT(M_ARPROT),
    .M_ARQOS(M_ARQOS),
    .M_ARREGION(M_ARREGION),
    .M_ARUSER(M_ARUSER),
    .M_RVALID(M_RVALID),
    .M_RREADY(M_RREADY),
    .M_RDATA(M_RDATA),
    .M_RLAST(M_RLAST),
    .M_RID(M_RID),
    .M_RUSER(M_RUSER),
    .M_RRESP(M_RRESP),
    .M_AWVALID(M_AWVALID),
    .M_AWREADY(M_AWREADY),
    .M_AWADDR(M_AWADDR),
    .M_AWID(M_AWID),
    .M_AWLEN(M_AWLEN),
    .M_AWSIZE(M_AWSIZE),
    .M_AWBURST(M_AWBURST),
    .M_AWLOCK(M_AWLOCK),
    .M_AWCACHE(M_AWCACHE),
    .M_AWPROT(M_AWPROT),
    .M_AWQOS(M_AWQOS),
    .M_AWREGION(M_AWREGION),
    .M_AWUSER(M_AWUSER),
    .M_WVALID(M_WVALID),
    .M_WREADY(M_WREADY),
    .M_WDATA(M_WDATA),
    .M_WSTRB(M_WSTRB),
    .M_WLAST(M_WLAST),
    .M_WID(M_WID),
    .M_WUSER(M_WUSER),
    .M_BVALID(M_BVALID),
    .M_BREADY(M_BREADY),
    .M_BRESP(M_BRESP),
    .M_BID(M_BID),
    .M_BUSER(M_BUSER),
    .s00_axi_aclk(s00_axi_aclk),
    .s00_axi_aresetn(s00_axi_aresetn),
    .s00_axi_awaddr(s00_axi_awaddr),
    .s00_axi_awprot(s00_axi_awprot),
    .s00_axi_awvalid(s00_axi_awvalid),
    .s00_axi_awready(s00_axi_awready),
    .s00_axi_wdata(s00_axi_wdata),
    .s00_axi_wstrb(s00_axi_wstrb),
    .s00_axi_wvalid(s00_axi_wvalid),
    .s00_axi_wready(s00_axi_wready),
    .s00_axi_bresp(s00_axi_bresp),
    .s00_axi_bvalid(s00_axi_bvalid),
    .s00_axi_bready(s00_axi_bready),
    .s00_axi_araddr(s00_axi_araddr),
    .s00_axi_arprot(s00_axi_arprot),
    .s00_axi_arvalid(s00_axi_arvalid),
    .s00_axi_arready(s00_axi_arready),
    .s00_axi_rdata(s00_axi_rdata),
    .s00_axi_rresp(s00_axi_rresp),
    .s00_axi_rvalid(s00_axi_rvalid),
    .s00_axi_rready(s00_axi_rready)
  );
endmodule
