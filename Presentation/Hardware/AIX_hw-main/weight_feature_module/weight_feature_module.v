module weight_feature_module #(
    localparam W_SRAM_MAX_DEPTH = 16,
    localparam W_SRAM_ADDRESS = $clog2(W_SRAM_MAX_DEPTH),
    localparam W_SRAM_WIDTH = DOUT_WIDTH,

)(

);

reg [W_SRAM_ADDRESS-1:0]  w_sram_addr   [1:0];
reg [W_SRAM_WIDTH-1:0]    w_sram_din    [1:0];
reg                     w_sram_we     [1:0];
wire [W_SRAM_WIDTH-1:0]   w_sram_dout   [1:0];
for (x=0; x < 2; x=x+1) begin
    assign wout[x] = w_sram_dout[x];
end

//-------------------------------------------------
// Control: weight feature laoding 
//-------------------------------------------------
always@(posedge clk or negedge rstn)begin
    if(~rstn)begin
        
    end
    else begin


        if(state!=IDLE && )begin
            
        end
    end
end
//-------------------------------------------------
// Control: weight feature output 
//-------------------------------------------------
always@(posedge clk or negedge rstn)begin
    if(~rstn)begin
        
    end
    else begin
        
    end
end

//-------------------------------------------------
// Component: 2 block rams for weight 
//-------------------------------------------------
generate
    for(x=0; x<2; x=x+1)begin
        sram #(
            .WL_DATA(W_SRAM_WIDTH),
            .SIZE(W_SRAM_MAX_DEPTH),
            .WL_ADDR(W_SRAM_ADDRESS)
        ) u_sram(
            ./*input                */clk(clk),   // main clock
            ./*input                */rst(rstn),   // reset, act.low by default
            ./*input  [WL_ADDR-1:0] */addr(w_sram_addr[x]),  // read/write address port 0
            ./*input  [WL_DATA-1:0] */wdata(w_sram_din[x]), // write data port 0
            ./*output [WL_DATA-1:0] */rdata(w_sram_dout[x]), // read data port 0
            ./*input                */ena(w_sram_we[x])    // write enable port 0
        );
    end
endgenerate


endmodule