#!/bin/ksh

. ./xrun_env.ksh

SRC_PATH="./support"

SRC="\
$SRC_PATH/design_util_functions_pkg.vhdl \
$SRC_PATH/logic_support_pkg.vhdl \
$SRC_PATH/signal_resolution_pkg.vhdl \
$SRC_PATH/power_logic_pkg.vhdl"

OUTPUT=./libs

xrun -v93 -64bit -compile -reflib $OUTPUT/ibm:ibm -makelib $OUTPUT/support:support $SRC -endlib

