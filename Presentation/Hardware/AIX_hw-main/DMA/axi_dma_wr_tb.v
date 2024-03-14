`timescale 1ns / 1ps

module axi_dma_wr_tb;

parameter INFILE    = "C:/Users/USER/Desktop/src/5.rtl/AIX/DMA/input_data/butterfly_08bit.hex"; // check your file path


localparam MEM_ADDRW = 22;
localparam MEM_DW = 32; // 8은 안됨... 16이상이어야함
localparam A = 32;
localparam D = 32;
localparam I = 4;
localparam L = 8;
localparam M = D/8;


reg clk;
reg rstn;

//AXI Master IF0 for input/out access
wire  [I-1:0]     i_AWID;       // Address ID
wire  [A-1:0]     i_AWADDR;     // Address Write
wire  [L-1:0]     i_AWLEN;      // Transfer length
wire  [2:0]       i_AWSIZE;     // Transfer width
wire  [1:0]       i_AWBURST;    // Burst type
wire  [1:0]       i_AWLOCK;     // Atomic access information
wire  [3:0]       i_AWCACHE;    // Cachable/bufferable infor
wire  [2:0]       i_AWPROT;     // Protection info
wire              i_AWVALID;    // address/control valid handshake
wire              i_AWREADY;
wire  [I-1:0]     i_WID;        // Write ID
wire  [D-1:0]     i_WDATA;      // Write Data bus
wire  [M-1:0]     i_WSTRB;      // Write Data byte lane strobes
wire              i_WLAST;      // Last beat of a burst transfer
wire              i_WVALID;     // Write data valid
wire              i_WREADY;     // Write data ready
wire [I-1:0]      i_BID;        // buffered response ID
wire [1:0]        i_BRESP;      // Buffered write response
wire              i_BVALID;     // Response info valid
wire              i_BREADY;     // Response info ready (to slave)
wire  [I-1:0]     i_ARID;       // Read addr ID
wire  [A-1:0]     i_ARADDR;     // Address Read 
wire  [L-1:0]     i_ARLEN;      // Transfer length
wire  [2:0]       i_ARSIZE;     // Transfer width
wire  [1:0]       i_ARBURST;    // Burst type
wire  [1:0]       i_ARLOCK;     // Atomic access information
wire  [3:0]       i_ARCACHE;    // Cachable/bufferable infor
wire  [2:0]       i_ARPROT;     // Protection info
wire              i_ARVALID;    // address/control valid handshake
wire              i_ARREADY;
wire  [I-1:0]     i_RID;        // Read ID
wire  [D-1:0]     i_RDATA;      // Read data bus
wire  [1:0]       i_RRESP;      // Read response
wire              i_RLAST;      // Last beat of a burst transfer
wire              i_RVALID;     // Read data valid 
wire              i_RREADY;     // Read data ready (to Slave)

// Memory ports for input (activation)
wire [MEM_ADDRW-1:0]   mem_addr;
wire                   mem_we;
wire [MEM_DW-1:0]      mem_di;
wire [MEM_DW-1:0]      mem_do;

//--------------------------------------------------------------------------------
//AXI DMA sram if wr
//--------------------------------------------------------------------------------
axi_sram_if #(  //New
   .MEM_ADDRW(MEM_ADDRW), .MEM_DW(MEM_DW),
   .A(A), .I(I), .L(L), .D(D), .M(M))
u_axi_ext_mem_if_wr (
   .ACLK(clk), .ARESETn(rstn),

    //AXI Slave IF
   .ARID    (i_ARID),   // Read addr ID
   .ARADDR  (i_ARADDR),   // Address Read 
   .ARLEN   (i_ARLEN),   // Transfer length
   .ARSIZE  (i_ARSIZE),   // Transfer width
   .ARBURST (i_ARBURST),   // Burst type
   .ARLOCK  (i_ARLOCK),   // Atomic access information
   .ARCACHE (i_ARCACHE),   // Cachable/bufferable infor
   .ARPROT  (i_ARPROT),   // Protection info
   .ARVALID (i_ARVALID),   // address/control valid handshake
   .ARREADY (i_ARREADY),
   .RID     (i_RID),   // Read ID
   .RDATA   (i_RDATA),   // Read data bus
   .RRESP   (i_RRESP),   // Read response
   .RLAST   (i_RLAST),   // Last beat of a burst transfer
   .RVALID  (i_RVALID),   // Read data valid 
   .RREADY  (i_RREADY),   // Read data ready (to Slave)


   //AXI Slave IF
   .AWID    (i_AWID),       // Address ID
   .AWADDR  (i_AWADDR),     // Address Write
   .AWLEN   (i_AWLEN),      // Transfer length
   .AWSIZE  (i_AWSIZE),    // Transfer width
   .AWBURST (i_AWBURST),   // Burst type
   .AWLOCK  (i_AWLOCK),   // Atomic access information
   .AWCACHE (i_AWCACHE),   // Cachable/bufferable infor
   .AWPROT  (i_AWPROT),   // Protection info
   .AWVALID (i_AWVALID),   // address/control valid handshake
   .AWREADY (i_AWREADY),
   .WID     (i_WID),   // Write ID
   .WDATA   (i_WDATA),   // Write Data bus
   .WSTRB   (i_WSTRB),   // Write Data byte lane strobes
   .WLAST   (i_WLAST),   // Last beat of a burst transfer
   .WVALID  (i_WVALID),   // Write data valid
   .WREADY  (i_WREADY),    // Write data ready
   .BID     (i_BID),   // buffered response ID
   .BRESP   (i_BRESP),   // Buffered write response
   .BVALID  (i_BVALID),   // Response info valid
   .BREADY  (i_BREADY),   // Response info ready (to slave)

   //Interface to SRAM 
   .mem_addr   (mem_addr),
   .mem_we     (mem_we),
   .mem_di     (mem_di),
   .mem_do     (mem_do)
);


//------------------------------------------------------------------------------------
// Memory for read and write
//IMEM for SIM
sram #(
   .FILE_NAME(INFILE),
   .SIZE(2**MEM_ADDRW),
   .WL_ADDR(MEM_ADDRW),
   .WL_DATA(MEM_DW))
u_ext_mem_input (
   .clk   (clk),
   .rst   (rstn),
   .addr  (mem_addr),
   .wdata (mem_di),
   .rdata (mem_do),
   .ena   (mem_we)     // Read only
   );





parameter AXI_WIDTH_AD = 32;
parameter AXI_WIDTH_ID = 4;
parameter AXI_WIDTH_DA = 32;
parameter AXI_WIDTH_DS = AXI_WIDTH_DA/8;

//DMA Functional Ports declarations
reg dma_wr_start;
reg dma_rd_start;
reg [17:0] num_trans;
reg [AXI_WIDTH_AD-1:0] start_addr;

// dma_wr
wire dma_wr_done;
reg [AXI_WIDTH_DA-1:0] dma_wr_data_i;
wire dma_wr_indata_req_o;

// dma_rd
wire [AXI_WIDTH_DA-1:0] dma_rd_data_o;
wire data_vld_o;
wire [17:0] data_cnt_o;
wire dma_rd_done;

//-------------------------------------------------
// Component: axi_dma_wr
//-------------------------------------------------
axi_dma_wr #(
    .BITS_TRANS(18),
    .OUT_BITS_TRANS(13),
    .AXI_WIDTH_USER(1),
    .AXI_WIDTH_ID(AXI_WIDTH_ID),
    .AXI_WIDTH_AD(AXI_WIDTH_AD),
    .AXI_WIDTH_DA(AXI_WIDTH_DA),
    .AXI_WIDTH_DS(AXI_WIDTH_DS)
)
u_dma_wr (
    .M_AWVALID(i_AWVALID),    // address/control valid handshake
    .M_AWADDR(i_AWADDR),     // Address Write
    .M_AWREADY(i_AWREADY),
    .M_AWID(i_AWID),       // Address ID
    .M_AWLEN(i_AWLEN),      // Transfer length
    .M_AWSIZE(i_AWSIZE),     // Transfer width
    .M_AWBURST(i_AWBURST),    // Burst type
    .M_AWLOCK(i_AWLOCK),     // Atomic access information
    .M_AWCACHE(i_AWCACHE),    // Cachable/bufferable infor
    .M_AWPROT(i_AWPROT),     // Protection info
    .M_AWQOS(),
    .M_AWREGION(),
    .M_AWUSER(),

    //Write data channel
    .M_WVALID(i_WVALID),     // Write data valid
    .M_WREADY(i_WREADY),     // Write data ready
    .M_WDATA(i_WDATA),      // Write Data bus
    .M_WSTRB(i_WSTRB),      // Write Data byte lane strobes
    .M_WLAST(i_WLAST),      // Last beat of a burst transfer
    .M_WID(i_WID),        // Write ID
    .M_WUSER(),

    //Write response channel
    .M_BVALID(i_BVALID),     // Response info valid
    .M_BREADY(i_BREADY),     // Response info ready (to slave)
    .M_BRESP(i_BRESP),      // Buffered write response
    .M_BID(i_BID),        // buffered response ID
    .M_BUSER(),

    //User interface
    .ap_start(dma_wr_start),
    .ap_done(dma_wr_done),
    .num_trans(num_trans),
    .mem_start_addr(start_addr),
    //buff_start_addr,
    .indata(dma_wr_data_i),
    .indata_req_o(dma_wr_indata_req_o),
    .buff_valid(1'b1),
    .fail_check(dma_wr_failed),
    //User signals
    .clk(clk), 
    .rstn(rstn)
);

//-------------------------------------------------
// Component: axi_dma_rd
//-------------------------------------------------
axi_dma_rd #(
    .BITS_TRANS(18),
    .OUT_BITS_TRANS(13),
    .AXI_WIDTH_USER(1),
    .AXI_WIDTH_ID(AXI_WIDTH_ID),
    .AXI_WIDTH_AD(AXI_WIDTH_AD),
    .AXI_WIDTH_DA(AXI_WIDTH_DA),
    .AXI_WIDTH_DS(AXI_WIDTH_DS)
)
u_dma_rd (
    .M_ARVALID(i_ARVALID),     // address/control valid handshake
    .M_ARREADY(i_ARREADY),     // Read addr ready
    .M_ARADDR(i_ARADDR),     // Address Read 
    .M_ARID(i_ARID),     // Read addr ID
    .M_ARLEN(i_ARLEN),     // Transfer length
    .M_ARSIZE(i_ARSIZE),     // Transfer width
    .M_ARBURST(i_ARBURST),     // Burst type
    .M_ARLOCK(i_ARLOCK),     // Atomic access information
    .M_ARCACHE(i_ARCACHE),     // Cachable/bufferable infor
    .M_ARPROT(i_ARPROT),     // Protection info
    .M_ARQOS(),      // Quality of Service
    .M_ARREGION(),   // Region signaling
    .M_ARUSER(),     // User defined signal
 
    //Read data channel
    .M_RVALID(i_RVALID),     // Read data valid 
    .M_RREADY(i_RREADY),     // Read data ready
    .M_RDATA(i_RDATA),     // Read data bus
    .M_RLAST(i_RLAST),     // Last beat of a burst transfer
    .M_RID(i_RID),     // Read ID
    .M_RUSER(),     // User defined signal
    .M_RRESP(i_RRESP),     // Read response
     
    //Functional Ports
    .start_dma(dma_rd_start),
    .num_trans(num_trans), //Number of 32-bit words transferred
    .start_addr(start_addr),
    .data_o(dma_rd_data_o),
    .data_vld_o(data_vld_o),
    .data_cnt_o(data_cnt_o),
    .done_o(dma_rd_done),

    //Global signals
    .clk(clk),
    .rstn(rstn)
);



// Clock 
parameter CLK_PERIOD = 10;	//100MHz
initial begin
	clk = 1'b1;
	forever #(CLK_PERIOD/2) clk = ~clk;
end

//simulation
integer i=0;
initial begin

    rstn = 0;
    dma_wr_start = 1'b0;
    dma_rd_start = 1'b0;
    num_trans = 0;
    start_addr = 0;
    dma_wr_data_i <= 0;

    #(4*CLK_PERIOD) rstn = 1;


    @(posedge clk)
        dma_wr_start <= 1;
        num_trans <= 8;
        start_addr <= 0;
        
    @(posedge clk)
        dma_wr_start <= 0;

    while (i < 8) begin
        @(posedge clk)
            if (dma_wr_indata_req_o) begin
                dma_wr_data_i <= i;
                i = i+1;
            end
    end


    #(16*CLK_PERIOD);
    

    @(posedge clk)
        num_trans <= 64;
        dma_rd_start <= 1'b1;
    
    @(posedge clk)
       dma_rd_start <= 1'b0;


    
end
endmodule
