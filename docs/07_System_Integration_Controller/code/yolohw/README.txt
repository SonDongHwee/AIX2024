1. Code structure
+ Top level
    /src    Source code
    /sim    Testbench and data for simulation
    /arxiv  Screen-captured results
+ Simulation
    /sim/inout_data_sw/log_feamap       Feature maps from SW simulation (Hex format)
    /sim/inout_data_sw/log_param        Weight maps from SW simulation (Hex format)
    /sim/inout_data_hw                  Output for HW simulation


2. Test bench
    //--------------------------------------------------------------------
    // conv_kern_tb.v
    //--------------------------------------------------------------------
    sim/conv_kern_tb.v
        IMPORTANT NOTE**: Assume the HW code are in C:/yolohw

    a. Code flow        
        Step 1: 
            + in_img: Load images from  /sim/inout_data_sw/log_feamap
            + filter: Load filters  from  /sim/inout_data_sw/log_param
        
        Step 2: 
                // Show the filter			
            #(100*CLK_PERIOD) 
                    @(posedge clk)
                    for (j=0; j < No; j=j+1) begin
                        $display("Filter och=%02d: \n",j);
                        for(i = 0; i < 3; i = i + 1) begin
                            $display("%d\t%d\t%d",
                                $signed(filter[(j*Fx*Fy*Ni) + (3*i  )][7:0]),
                                $signed(filter[(j*Fx*Fy*Ni) + (3*i+1)][7:0]),
                                $signed(filter[(j*Fx*Fy*Ni) + (3*i+2)][7:0]));
                        end
                        $display("\n");						
                    end
                    
            #(100*CLK_PERIOD) 
                    @(posedge clk)
                        preload = 1'b0;	
        
        Step 3: 		
            // Loop for convolutions: It outputs row, col, and ctrl_data_run                        
            #(100*CLK_PERIOD) 
                    for(row = 0; row < IFM_HEIGHT; row = row + 1)	begin 
                        @(posedge clk)
                            ctrl_data_run  = 0;
                        #(100*CLK_PERIOD) 			
                        for (col = 0; col < IFM_WIDTH; col = col + 1) begin 
                            @(posedge clk)
                                ctrl_data_run  = 1;
                        end 
                    end
                @(posedge clk)
                        ctrl_data_run = 1'b0;			
            #(100*CLK_PERIOD) 
                    @(posedge clk) $stop;	        

        Step 4: 
            // Generate din, win
            wire is_first_row = (row == 0) ? 1'b1: 1'b0;
            wire is_last_row  = (row == IFM_HEIGHT-1) ? 1'b1: 1'b0;
            wire is_first_col = (col == 0) ? 1'b1: 1'b0;
            wire is_last_col  = (col == IFM_WIDTH-1) ? 1'b1 : 1'b0;

            always@(*) begin
                vld_i = 0;
                din = 128'd0;
                win[0] = 0;
                win[1] = 0;
                win[2] = 0;
                win[3] = 0;
                if(ctrl_data_run) begin
                    vld_i = 1;
                    // Tiled IFM data
                    din[ 7: 0] = (is_first_row || is_first_col) ? 8'd0 : in_img[(row-1) * IFM_WIDTH + (col-1)];
                    din[15: 8] = (is_first_row                ) ? 8'd0 : in_img[(row-1) * IFM_WIDTH +  col   ];
                    din[23:16] = (is_first_row || is_last_col ) ? 8'd0 : in_img[(row-1) * IFM_WIDTH + (col+1)];
                    din[31:24] = (                is_first_col) ? 8'd0 : in_img[ row    * IFM_WIDTH + (col-1)];
                    din[39:32] =                                         in_img[ row    * IFM_WIDTH +  col   ];
                    din[47:40] = (                is_last_col ) ? 8'd0 : in_img[ row    * IFM_WIDTH + (col+1)];
                    din[55:48] = (is_last_row ||  is_first_col) ? 8'd0 : in_img[(row+1) * IFM_WIDTH + (col-1)];
                    din[63:56] = (is_last_row                 ) ? 8'd0 : in_img[(row+1) * IFM_WIDTH + (col-1)];
                    din[71:64] = (is_last_row ||  is_last_col ) ? 8'd0 : in_img[(row+1) * IFM_WIDTH + (col+1)];
                    // Tiled Filters
                    for(j = 0; j < 4; j=j+1) begin 	// Four sets <=> Four output channels
                        win[j][ 7: 0] = filter[(j*Fx*Fy*Ni)    ][7:0];
                        win[j][15: 8] = filter[(j*Fx*Fy*Ni) + 1][7:0];
                        win[j][23:16] = filter[(j*Fx*Fy*Ni) + 2][7:0];
                        win[j][31:24] = filter[(j*Fx*Fy*Ni) + 3][7:0];
                        win[j][39:32] = filter[(j*Fx*Fy*Ni) + 4][7:0];
                        win[j][47:40] = filter[(j*Fx*Fy*Ni) + 5][7:0];
                        win[j][55:48] = filter[(j*Fx*Fy*Ni) + 6][7:0];
                        win[j][63:56] = filter[(j*Fx*Fy*Ni) + 7][7:0];
                        win[j][71:64] = filter[(j*Fx*Fy*Ni) + 8][7:0];			
                    end 
                end    
            end 


    b. Simulation and Outputs: 
        run 1ms
        # Loading input feature maps from file: C:/yolohw/sim/inout_data_sw/log_feamap/CONV00_input_32b.hex
        # Loading input feature maps from file: C:/yolohw/sim/inout_data_sw/log_param/CONV00_param_weight.hex
        # Filter och= 0: 
        # 
        #   19	 -11	  -6
        #   61	 -17	 -42
        #   23	  -2	 -21
        # 
        # 
        # Filter och= 1: 
        # 
        #   12	 -15	 -17
        #    5	   5	 -18
        #    6	   2	 -17
        # 
        # 
        # Filter och= 2: 
        # 
        #    3	   6	  14
        #   -8	   1	  21
        #    5	 -22	   9
        # 
        # 
        # Filter och= 3: 
        # 
        #   24	  17	  12
        #   11	  23	  24
        #   -4	   9	  -1
        # 
        # 
        # Filter och= 4: 
        # 
        #  -10	  -2	   4
        #   -9	  -8	  -9
        #    8	   0	  10
        # 
        # 
        # Filter och= 5: 
        # 
        #   25	 -10	  22
        #   -7	 -32	   9
        #   -6	 -21	  -8
        # 
        # 
        # Filter och= 6: 
        # 
        #  -70	 -35	 -12
        #   47	  28	   0
        #   48	  16	   4
        # 
        # 
        # Filter och= 7: 
        # 
        #   -8	   2	  15
        #  -27	  -5	  32
        #  -27	  16	   9
        # 
        # 
        # Filter och= 8: 
        # 
        #  -21	 -26	 -25
        #  -60	 -95	 -32
        #  -38	 -79	 -28
        # 
        # 
        # Filter och= 9: 
        # 
        #   -8	   4	   8
        #   12	   5	   8
        #    4	  18	  13
        # 
        # 
        # Filter och=10: 
        # 
        #  -76	  21	 -45
        #  -37	 -18	  33
        #   29	  23	  50
        # 
        # 
        # Filter och=11: 
        # 
        #   53	  29	  30
        #   25	  -5	  -1
        #  -62	 -56	  -9
        # 
        # 
        # Filter och=12: 
        # 
        #    6	  53	  26
        #   23	  70	  46
        #   -9	  31	  11
        # 
        # 
        # Filter och=13: 
        # 
        #   20	  45	 -11
        #   -7	 -32	 -25
        #    4	 -28	 -17
        # 
        # 
        # Filter och=14: 
        # 
        #    7	 -65	  10
        #  -10	   5	   3
        #    1	 -22	   2
        # 
        # 
        # Filter och=15: 
        # 
        #   -8	  -9	 -18
        #    0	   2	  -2
        #    6	  13	   0
        # 
        # 
        # Saving output images to file: C:/yolohw/sim/inout_data_hw/CONV00_input_ch03.bmp
        # Saving output images to file: C:/yolohw/sim/inout_data_hw/CONV00_input_ch02.bmp
        # Saving output images to file: C:/yolohw/sim/inout_data_hw/CONV00_input_ch01.bmp
        # Saving output images to file: C:/yolohw/sim/inout_data_hw/CONV00_input_ch00.bmp
        # Saving output images to file: C:/yolohw/sim/inout_data_hw/CONV00_output_ch03.bmp
        # Saving output images to file: C:/yolohw/sim/inout_data_hw/CONV00_output_ch02.bmp
        # Saving output images to file: C:/yolohw/sim/inout_data_hw/CONV00_output_ch01.bmp
        # Saving output images to file: C:/yolohw/sim/inout_data_hw/CONV00_output_ch00.bmp
        # ** Note: $stop    : C:/yolohw/sim/conv_kern_tb.v(101)
        #    Time: 916400 ns  Iteration: 1  Instance: /conv_kern_tb
        # Break in Module conv_kern_tb at C:/yolohw/sim/conv_kern_tb.v line 101

    //--------------------------------------------------------------------
    // cnn_ctrl_tb.v
    //--------------------------------------------------------------------
    a. Code flow
        Test cnn_ctrl
        //-------------------------------------------------
        // Controller (FSM)
        //-------------------------------------------------
        cnn_ctrl u_cnn_ctrl (
        .clk			(clk			),
        .rstn			(rstn			),
        // Inputs
        .q_width		(q_width		),
        .q_height		(q_height		),
        .q_vsync_delay	(q_vsync_delay	),
        .q_hsync_delay	(q_hsync_delay	),
        .q_frame_size	(q_frame_size	),
        .q_start		(q_start		),
        //output
        .o_ctrl_vsync_run(ctrl_vsync_run),
        .o_ctrl_vsync_cnt(ctrl_vsync_cnt),
        .o_ctrl_hsync_run(ctrl_hsync_run),
        .o_ctrl_hsync_cnt(ctrl_hsync_cnt),
        .o_ctrl_data_run(ctrl_data_run	),
        .o_row			(row			),
        .o_col			(col			),
        .o_data_count	(data_count		),
        .o_end_frame	(end_frame		)
        );    
    
    b. Simulation and outputs
        Generate (row, col, data_count) from given q_width, q_height, and delays (q_vsync_delay, q_hsync_delay)