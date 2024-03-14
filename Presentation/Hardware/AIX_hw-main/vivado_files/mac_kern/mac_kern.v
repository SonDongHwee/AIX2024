module mac_kern #(
    parameter WI = 8,
    parameter mac_num = 9,
    parameter max_in_ch = 256,
    parameter N = 16,
    parameter Y4_DELAY = 3,
    parameter WO = 2*WI + 4 + $clog2(16),
    parameter mac_WO = 2*WI + $clog2(N)
)(
    //input
    input                           clk,
    input                           rstn,
    input [$clog2(max_in_ch)-1:0]   in_ch,
    input                           is_conv3x3,
    input                           vld_i,
    input [mac_num*N*WI-1:0]        win,
    input [mac_num*N*WI-1:0]        din,
    //output
    output [WO-1:0]                 acc_o,
    output reg                      vld_o
);
    integer i;

    
    reg [$clog2(max_in_ch) - $clog2(N):0]      din_total;
    always@(*) begin
        if(is_conv3x3) begin
            din_total = (in_ch != 3)    ? (in_ch >> $clog2(N)) : 1;
        end
        else begin
            din_total = (in_ch > 128)   ? 2:1;
        end
    end
    
    
    reg [N*WI-1:0]                 mac_win [mac_num-1:0];
    reg [N*WI-1:0]                 mac_din [mac_num-1:0];
    always @(*) begin
        for (i=0; i < mac_num; i=i+1)begin
            mac_win[i] = win[i*(N*WI)+:(N*WI)];
            mac_din[i] = din[i*(N*WI)+:(N*WI)];
        end
    end

    // Incoming signals from MACs
    wire [mac_WO-1:0]               mac_acc_o [mac_num-1:0];      // mac accumulation result
    wire                        mac_vld_o [mac_num-1:0];      // vld_o signal of mac

    reg [2*mac_WO+1:0] y1 [4:0];    // 5 outputs of adders (level1)
    reg [2*mac_WO+2:0] y2 [2:0];    // 3 outputs of adders (level2)
    reg [2*mac_WO+3:0] y3 [1:0];    // 2 output of adders (level3)
    reg [2*mac_WO+4:0] y4;          // 1 output of adders (level3)


    // Delay signals
    reg [Y4_DELAY:0]                    y4_vld_d;
    wire                                y4_vld;  
    reg [$clog2(max_in_ch) - $clog2(N):0] in_ch_cnt;    
    
    reg [WO-1:0]  psum;           // temporary register to sum the accumulated value of 3x3 kernel

    //----------------------------
    // Component: MAC
    //----------------------------
    genvar m;
    generate
        for (m=0; m <mac_num; m=m+1) begin
            mac u_mac(
                .clk(clk),
                .rstn(rstn),
                .vld_i(vld_i),
                .win(mac_win[m]),
                .din(mac_din[m]),
                .acc_o(mac_acc_o[m]),
                .vld_o(mac_vld_o[m])
            );
        end
    endgenerate

    //---------------------------
    // Accumulation
    //---------------------------
    always@(posedge clk, negedge rstn) begin
        if(~rstn) begin
            for (i=0; i<5; i=i+1) y1[i] <=0;    // level1
            for (i=0; i<3; i=i+1) y2[i] <=0;    // level2
            for (i=0; i<2; i=i+1) y3[i] <=0;    // level3
            y4 <=0;                             // level4
            psum <=0;
        end
        else begin
            // level 1
            for (i=0; i < 4; i=i+1) y1[i] <= $signed(mac_acc_o[2*i]) + $signed(mac_acc_o[2*i+1]);
            y1[4] <= $signed(mac_acc_o[8]);
            // level 2
            for (i=0; i < 2; i=i+1) y2[i] <= $signed(y1[2*i]) + $signed(y1[2*i+1]);
            y2[2] <= $signed(y1[4]);
            // level 3
            y3[0] <= $signed(y2[0]) + $signed(y2[1]);
            y3[1] <= $signed(y2[2]);
            // level 4
            y4 <= $signed(y3[0]) + $signed(y3[1]);
            
            if (y4_vld) begin 
                if (in_ch_cnt==0)   psum <= $signed(y4);
                else                psum <= $signed(psum) + $signed(y4);
            end
        end
    end

    //--------------------------
    // Output and Delay signals
    //--------------------------
    always@(posedge clk, negedge rstn) begin
        if(~rstn) begin
            y4_vld_d <= 0;
        end
        else begin
            y4_vld_d <= {y4_vld_d[Y4_DELAY-1:0], mac_vld_o[0]};
        end
    end
    assign y4_vld = y4_vld_d[Y4_DELAY];

    always@(posedge clk, negedge rstn) begin
        if(~rstn) begin
            in_ch_cnt   <= 0;
            vld_o       <=0;
        end
        else begin
            if(y4_vld)begin
                if (in_ch_cnt == din_total -1) begin
                    in_ch_cnt   <= 0;
                    vld_o       <= 1'b1;
                end
                else begin
                    in_ch_cnt   <= in_ch_cnt+1;
                    vld_o       <= 1'b0;
                end
            end
            else vld_o <= 1'b0;
        end
    end

    assign acc_o = $signed(psum);
endmodule