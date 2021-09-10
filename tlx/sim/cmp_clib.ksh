#!/bin/ksh

. ./xrun_env.ksh

CLIB=./clib

SRC="\
$CLIB/c_direct_err_rpt.vhdl \
$CLIB/c_direct_err_rpt_errin.vhdl \
$CLIB/c_err_rpt_wolcb.vhdl \
$CLIB/c_local_fir_wolcb.vhdl \
$CLIB/c_local_fir_comp.vhdl \
$CLIB/c_local_fir_parco.vhdl
$CLIB/c_local_scomfir_wolcb.vhdl \
$CLIB/c_serial_scom_comp.vhdl \
$CLIB/c_serial_scom_wolcb.vhdl \
$CLIB/c_utilities_pkg.vhdl \
"

OUTPUT=./libs

xrun -v200x -64bit -compile -smartorder -reflib $OUTPUT/ibm:ibm -reflib $OUTPUT/support:support -reflib $OUTPUT/latches:latches -makelib $OUTPUT/clib:clib $SRC -endlib

