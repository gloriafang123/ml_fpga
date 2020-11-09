#!/bin/bash -f
# ****************************************************************************
# Vivado (TM) v2019.2 (64-bit)
#
# Filename    : elaborate.sh
# Simulator   : Xilinx Vivado Simulator
# Description : Script for elaborating the compiled design
#
# Generated by Vivado on Mon Nov 09 00:18:17 EST 2020
# SW Build 2708876 on Wed Nov  6 21:39:14 MST 2019
#
# Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
#
# usage: elaborate.sh
#
# ****************************************************************************
set -Eeuo pipefail
echo "xelab -wto eeeb5cd8cddd4a52a1066384a93aec1b --incr --debug typical --relax --mt 8 -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip --snapshot neural_network_tb_behav xil_defaultlib.neural_network_tb xil_defaultlib.glbl -log elaborate.log"
xelab -wto eeeb5cd8cddd4a52a1066384a93aec1b --incr --debug typical --relax --mt 8 -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip --snapshot neural_network_tb_behav xil_defaultlib.neural_network_tb xil_defaultlib.glbl -log elaborate.log

