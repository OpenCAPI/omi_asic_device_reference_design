#!/bin/ksh

. ./xrun_env.ksh

LPATH="./latches"
MPATH="./morph"

SRC="\
$LPATH/c_latch_init_pkg.vhdl \
$MPATH/c_morph_dff_core.vhdl \
$MPATH/c_morph_dff.vhdl"

OUTPUT=./libs

xrun -v93 -64bit -compile -smartorder -reflib $OUTPUT/ibm:ibm -reflib $OUTPUT/clib:clib -reflib $OUTPUT/support:support -reflib $OUTPUT/stdcell:stdcell -makelib $OUTPUT/latches:latches $SRC -endlib

