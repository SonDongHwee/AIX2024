README(Software)

[yolov2_forward_network_quantized.c]

Our goal is to find a good scale numbers for each layer's input and weight.

The main idea is finding the biggest absolute number(=N) in a layer's input(or weight) except some outliers and defining a scale as '127/N' for the layer's input(or weight).

Then we can get 8-bits 2's complement scale numbers for each layer's input(or weight).

We combined two adjent layers' scaling numbers except the first layer so we can descaling output and scaling input for next quantization at one time. By multiplying (next layer's input scale number) / (now layer's input scale number * this layer's weight scale number) to the output of now layer.



[AIX_quant-checkpoint.ipynb] (/bin/check_data/.ipynb_checkpoints)

The number of outliers to be excluded from scale defining for each convolution layer is [1,1,2,5,5,5,6,6,6,6,6,6,6,6,5,2,1,1] for 18 convolution layers.

We thought middle layers' outputs are abstract so there will be more outliers than other layers.

We find the heuristic numbers of the 'to be excluded outliers' for each layer.



[Conculusion]
Now our mAP is 74.59% 


[Problems]
1. Descaling and scaling at one time
 Our process aimed the continuous convolution layers by combining two adjent scale numbers. 
 If there is max pooling layer after one convolution layer, it is fine because max pooling compares 4 components in the same layer. 
 But when the output of the convolution layer is used in route layer later, then our algorithm has a huge depect.
 Two convolution outputs(or half of one convolution output) are scaled by its next layer's scale number. 
 This is not the exact convolution output. 
 Even more two convolution outputs are erroneously scaled by different scaled nubmer. 

2. Detail standard to deciding the number of excluding outliers for each layer
 We found that excluding a few outliers makes mAP better.
 So we tried to find some papers dealing with this issue, but we couldn't.
 We decided the numbers of the 'to be excluded outliers' for each layer by heuristic.
 We have to set a right standard to get right numbers.

3. The method to store and utilize the scale numbers in DRAM
 After deciding all the scale numbers for all layers, we have to find the way to store and utilize these numbers in DRAM.
 In C code we use 32-bit floating point but in FPGA we have to simplify these bits.
