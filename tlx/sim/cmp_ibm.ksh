#!/bin/ksh

. ./xrun_env.ksh

SRC_PATH="./ibm"

SRC="\
$SRC_PATH/synthesis_support.vhdl \
$SRC_PATH/std_ulogic_support.vhdl \
$SRC_PATH/texsim_attributes.vhdl \
$SRC_PATH/std_ulogic_function_support.vhdl \
$SRC_PATH/std_ulogic_asic_function_support.vhdl \
$SRC_PATH/std_ulogic_mux_support.vhdl \
$SRC_PATH/std_ulogic_unsigned.vhdl \
$SRC_PATH/std_ulogic_ao_support.vhdl"


OUTPUT=./libs

xrun -v93 -64bit -compile -makelib $OUTPUT/ibm:ibm $SRC -endlib

