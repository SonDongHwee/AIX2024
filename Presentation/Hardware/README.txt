README(Hardware)
 
-----------Calculation part-------------------
 We can use only 240 DSP slices, so we decided to calculate 3x3x16 (3x3 is kernel size) numbers at one time. In other words, 16 channels at a time. Most of the layers have multiple number of 16. And 16 is 2 to the 4th power, so it's easy to handle.
----------------------------------------------
[mul.v]
 multipy two 8-bits inputs

[mac.v]
 Multiplicate and accumulate two 16 signed numbers

[mac_kern.v]
 3x3 mac applied by in_channel wise count 

[bias_scale_act.v]
 Do bias, scale, activation on weight x input's sum(mac_kern.v's output)
 accum_in(24bit), bias(int16), scale(fixed-point16), scale_shift(int6), output(int8)
 bias addition → descaling(descale multiplication + fixed point shifting) → 
 activation(LeakyReLU)

[conv_kern.v]
 Calculate one output feature completely 
 (No simulation result by compile error)

[convolution.v]
 Calculate one output layer fit as convolution layer's config
 (On working now)


----------Data processing part----------------
 Two main points
 1. Reorder widthwise input feature map into channelwise input feature map
    First input feature map in DRAM and output feature map that is output of convolution.v are stored in widthwise manner. Reordering procedure makes easier to calculate one output feature by using conv_kern.v
 2. Use two Buffers(input feature map buffer and output feature map buffer) alternately
    We discovered that we can store one layer's input feature map and output feature map both in our fast block RAM(Attached excel file shows that block RAM can afford it including MicroBlaze). It means we don't need to store one layer's output feature map in DRAM. Using fast block RAM is much faster than sending entire output feature map by DMA in each layer. So we can use two feature map buffers, one is input feature map and the other one is output feature map buffer. On the next layer, former output feature map buffer works as input feature map buffer and former input feature map buffer works as output feature map buffer. We will use other 3 buffers to store output feature maps to be used in route layers.
----------------------------------------------
[DMA.v]
 Receive bias at the first time, weights, scale numbers, first input feature map
 Send final output

[input_line_loader.v]
 Reorder data widthwise into channel wise and send it to input_feature_module.v from input feature map buffer

[input_feature_module.v]
 Send 9x9x16 input features and weights to convolution.v at a time.
 Use 15(3x5) block RAMs for input feature map
 3x3 : each block RAM sends one line(1x1x16) to convolution.v. 3 block RAMs have same data, so that can send 3 lines(1x3x16) in a row at the same time.
 2x3 : during the waiting time(3x3 block RAMs send data to convolution.v), receive next row's features. Max stride value is 2 that's why we use 2x3 block RAMs.

 Use 2 block RAMs for weights
 1 : send one line(1x1x16) to convolution.v
 1 : receive next kernel's weights during waiting time(the other block RAM sends data to convolution.v)  
 

[output_feature_module.v]
 Receive the results of convolution.v in its registers.
 Send the results by 4 to the output feature map buffer at that time.
