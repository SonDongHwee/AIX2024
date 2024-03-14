`timescale 1ns / 1ps

module input_line_loader_tb;

parameter INFILE_ORIGIN     = "C:/Users/USER/Desktop/hello/AIX_hw/test_data/input1_original4.txt"; 

reg clk;
reg rstn;

// Clock 
parameter CLK_PERIOD = 10;	//100MHz
initial begin
	clk = 1'b0;
	forever #(CLK_PERIOD/2) clk = ~clk;
end

//input_line_loader I/O
localparam IFM_DATA_NUM = 4;
localparam WI = 8;
localparam WO = 8;
localparam W_BRAM_DATA_W = 16;
localparam R_DATA_W = WI * IFM_DATA_NUM;
localparam W_DATA_W = WO * W_BRAM_DATA_W;
localparam MAX_IFM_DATA = 128*128*16; //262144
localparam MAX_IFM_DEPTH = $clog2(MAX_IFM_DATA/IFM_DATA_NUM);
localparam MAX_IFM_LINE_DATA = 64*64; // 4096
localparam MAX_IFM_LINE_DEPTH = $clog2(MAX_IFM_LINE_DATA/W_BRAM_DATA_W);


//simulation inputs
reg [7:0]     ifm_w;
reg [7:0]     ich;
reg [7:0]     line_idx;
reg ap_start;
reg running;
reg [MAX_IFM_LINE_DEPTH-1:0] check_addr;


wire [MAX_IFM_LINE_DEPTH-1:0] out_r_addr;
wire ena_out;
wire [R_DATA_W-1:0]    r_data;
wire [MAX_IFM_DEPTH-1:0]  r_addr;
wire [MAX_IFM_LINE_DEPTH-1:0] w_addr;
wire [W_DATA_W-1:0] w_data;
wire w_en;
wire ap_done;
wire [W_DATA_W-1:0] check_data; //simulation result to read

//input bram
sram #(
   .FILE_NAME(INFILE_ORIGIN),
   .SIZE(2**MAX_IFM_DEPTH),
   .WL_ADDR(MAX_IFM_DEPTH),
   .WL_DATA(R_DATA_W))
u_input_sram (
   .clk   (clk),
   .rst   (rstn),
   .addr  (r_addr),
   .wdata (),
   .rdata (r_data),
   .ena   (1'b0)
   );

input_line_loader #(
    .IFM_DATA_NUM(IFM_DATA_NUM))
u_input_line_loader (
    .clk(clk),
    .rstn(rstn),
    .ifm_w(ifm_w), 
    .ich(ich), 
    .line_idx(line_idx), 
    .ap_start(ap_start), 
    .r_data(r_data), 
    .r_addr(r_addr), 
    .w_addr(w_addr), 
    .w_data(w_data), 
    .w_en(w_en), 
    .ap_done(ap_done)
);

assign ena_out = running ? w_en:1'b0;
assign out_r_addr = running ? w_addr:check_addr;

sram #(
   .SIZE(2**MAX_IFM_LINE_DEPTH),
   .WL_ADDR(MAX_IFM_LINE_DEPTH),
   .WL_DATA(W_DATA_W))
u_output_sram (
   .clk   (clk),
   .rst   (rstn),
   .addr  (out_r_addr),
   .wdata (w_data),
   .rdata (check_data),
   .ena   (ena_out)
   );



//simulation
initial begin

    rstn = 0;
    ifm_w = 0;
    ich = 0;
    line_idx = 0;
    ap_start = 0;
    running = 0;
    check_addr = 0;

    #(4*CLK_PERIOD) rstn = 1;

    @(posedge clk)
        ifm_w = 8'd128;
        ich = 8'd16;
        line_idx = 8'd0;
        ap_start = 1'b1;
        running = 1'b1;
    @(posedge clk)
        ap_start = 1'b0;

    @(ap_done)
        running = 1'b0;
    
    @(posedge clk)
        ifm_w = 8'd128;
        ich = 8'd16;
        line_idx = 8'd99;
        ap_start = 1'b1;
        running = 1'b1;
    @(posedge clk)
        ap_start = 1'b0;

    @(ap_done)
        running = 1'b0;


end
endmodule