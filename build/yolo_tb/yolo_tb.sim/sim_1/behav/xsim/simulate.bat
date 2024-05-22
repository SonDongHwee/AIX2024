@echo off
REM ****************************************************************************
REM Vivado (TM) v2023.2 (64-bit)
REM
REM Filename    : simulate.bat
REM Simulator   : AMD Vivado Simulator
REM Description : Script for simulating the design by launching the simulator
REM
REM Generated by Vivado on Wed May 22 22:49:22 +0900 2024
REM SW Build 4029153 on Fri Oct 13 20:14:34 MDT 2023
REM
REM Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
REM Copyright 2022-2023 Advanced Micro Devices, Inc. All Rights Reserved.
REM
REM usage: simulate.bat
REM
REM ****************************************************************************
REM simulate design
echo "xsim conv_maxpool_module_tb_behav -key {Behavioral:sim_1:Functional:conv_maxpool_module_tb} -tclbatch conv_maxpool_module_tb.tcl -view C:/Users/leewo/Documents/GitHub/AIX2024/build/yolo_tb/conv_kern_tb_behav1.wcfg -log simulate.log"
call xsim  conv_maxpool_module_tb_behav -key {Behavioral:sim_1:Functional:conv_maxpool_module_tb} -tclbatch conv_maxpool_module_tb.tcl -view C:/Users/leewo/Documents/GitHub/AIX2024/build/yolo_tb/conv_kern_tb_behav1.wcfg -log simulate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
