`timescale 1ns / 1ps

module bias_loader_tb;

//parameters
parameter BIAS_BITS = 16;
parameter MAX_KERNEL_NUM = $clog2(256);
parameter BITS_TRANS = 18;
parameter AXI_WIDTH_AD   = 32;
parameter AXI_WIDTH_DA   = 32;
parameter WL_ADDR    = 32'd8;
parameter WL_DATA    = 32'd32;
parameter SRAM_WIDTH = BIAS_BITS;
parameter SRAM_MAX_DEPTH = 256;
parameter SRAM_ADDRESS = $clog2(SRAM_MAX_DEPTH);
parameter INFILE = "C:/Users/USER/Desktop/src/5.rtl/AIX/bias_loader/input_data/bias_in_dram.txt"; // DRAM file

//inputs
reg                                 clk;
reg                                 rstn;

//Loading
reg                                 ap_start;
reg [8:0]                           och;
reg [AXI_WIDTH_AD-1:0]              bias_start_addr;

//Sending
reg [MAX_KERNEL_NUM-1:0]            current_kernel_num;
reg                                 bias_request; 

//DMA function ports
wire [AXI_WIDTH_DA-1:0]              dma_din;
wire                                 dma_din_vld;
wire [BITS_TRANS-1:0]                dma_data_cnt; //시작이 0
wire                                 dma_done;


//outputs
//Loading
wire                                write_done; //한 layer의 bias 전부 SRAM 저장 끝

//Sending
wire [BIAS_BITS-1:0]                bias_o; //send bias
wire                                bias_vld_o; //send bias valid

//DMA function ports                  
wire                                start_dma;
wire [BITS_TRANS-1:0]               dma_num_trans;  //받는 개수 32bit 기준
wire [AXI_WIDTH_AD-1:0]             dma_start_addr; //start address 한 address 에 32bit

//axi_sram_if//
localparam MEM_ADDRW = 22;
localparam MEM_DW = 16;
localparam A = 32;
localparam D = 32;
localparam I = 4;
localparam L = 8;
localparam M = D/8;
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
//AXI Slave External Memory: Input
//--------------------------------------------------------------------------------
axi_sram_if #(  //New
   .MEM_ADDRW(MEM_ADDRW), .MEM_DW(MEM_DW),
   .A(A), .I(I), .L(L), .D(D), .M(M))
u_axi_ext_mem_if_input(
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

   //Interface to SRAM 
   .mem_addr   (mem_addr),
   .mem_we     (mem_we),
   .mem_di     (mem_di),
   .mem_do     (mem_do)
);

//sram
sram #(
   .FILE_NAME(INFILE),
   .SIZE(2**MEM_ADDRW),
   .WL_ADDR(MEM_ADDRW),
   .WL_DATA(16))
u_ext_mem_input (
   .clk   (clk),
   .rst   (rstn),
   .addr  (mem_addr),
   .wdata (mem_di),
   .rdata (mem_do),
   .ena   (1'b0)     // Read only
);


parameter AXI_WIDTH_ID = 4;
parameter AXI_WIDTH_DS = AXI_WIDTH_DA/8;


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
    .start_dma(start_dma),
    .num_trans(dma_num_trans), //Number of 32-bit words transferred
    .start_addr(dma_start_addr),
    .data_o(dma_din),
    .data_vld_o(dma_din_vld),
    .data_cnt_o(dma_data_cnt),
    .done_o(dma_done),

    //Global signals
    .clk(clk),
    .rstn(rstn)
);





//DUT
bias_loader#() bias_loader_test(
    ./*input                            */clk(clk),
    ./*input                            */rstn(rstn),
    ./*input                            */ap_start(ap_start),
    ./*input       [8:0]                */och(och),
    ./*input       [AXI_WIDTH_AD-1:0]   */bias_start_addr(bias_start_addr),
    ./*output reg                       */write_done(write_done),
    
    ./*input                            */bias_request(bias_request),
    ./*output reg  [BIAS_BITS-1:0]      */bias_o(bias_o),
    ./*output reg                       */bias_vld_o(bias_vld_o),

    ./*output reg                       */start_dma(start_dma),
    ./*output reg  [BITS_TRANS-1:0]     */dma_num_trans(dma_num_trans),
    ./*output reg  [AXI_WIDTH_AD-1:0]   */dma_start_addr(dma_start_addr),
    ./*input       [AXI_WIDTH_DA-1:0]   */dma_din(dma_din),
    ./*input                            */dma_din_vld(dma_din_vld),
    ./*input       [BITS_TRANS-1:0]     */dma_data_cnt(dma_data_cnt),
    ./*input                            */dma_done(dma_done)
);

//clk
parameter CLK_PERIOD = 10;	//100MHz
initial begin
	clk = 1'b0;
	forever #(CLK_PERIOD/2) clk = ~clk;
end

integer i;
//testcase
initial begin
    rstn = 0;
    ap_start = 0;
    och = 0;
    bias_start_addr = 0;
    bias_request = 0;
    
    #(4*CLK_PERIOD) rstn = 1;

    @(posedge clk)
        och = 256;
        ap_start = 1;
        bias_start_addr = 0;
        
    @(posedge clk)    
        ap_start = 0;
    
    @(write_done)
        for (i=0; i < och; i = i+1) begin
            @(posedge clk)
                bias_request = 1;
            @(posedge clk)
                bias_request = 0;
        end
end

endmodule