vlib questa_lib/work
vlib questa_lib/msim

vlib questa_lib/msim/xbip_dsp48_wrapper_v3_0_5
vlib questa_lib/msim/xbip_utils_v3_0_11
vlib questa_lib/msim/xbip_pipe_v3_0_7
vlib questa_lib/msim/dsp_macro_v1_0_4
vlib questa_lib/msim/xil_defaultlib

vmap xbip_dsp48_wrapper_v3_0_5 questa_lib/msim/xbip_dsp48_wrapper_v3_0_5
vmap xbip_utils_v3_0_11 questa_lib/msim/xbip_utils_v3_0_11
vmap xbip_pipe_v3_0_7 questa_lib/msim/xbip_pipe_v3_0_7
vmap dsp_macro_v1_0_4 questa_lib/msim/dsp_macro_v1_0_4
vmap xil_defaultlib questa_lib/msim/xil_defaultlib

vcom -work xbip_dsp48_wrapper_v3_0_5  -93  \
"../../../ipstatic/hdl/xbip_dsp48_wrapper_v3_0_vh_rfs.vhd" \

vcom -work xbip_utils_v3_0_11  -93  \
"../../../ipstatic/hdl/xbip_utils_v3_0_vh_rfs.vhd" \

vcom -work xbip_pipe_v3_0_7  -93  \
"../../../ipstatic/hdl/xbip_pipe_v3_0_vh_rfs.vhd" \

vcom -work dsp_macro_v1_0_4  -93  \
"../../../ipstatic/hdl/dsp_macro_v1_0_rfs.vhd" \

vcom -work xil_defaultlib  -93  \
"../../../../07_SIC.gen/sources_1/ip/dsp_macro_0/sim/dsp_macro_0.vhd" \


