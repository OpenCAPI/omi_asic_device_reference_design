#!/bin/ksh

. ./xrun_env.ksh

OCMB=./tl

SRC="\
./omi.vhdl \
$OCMB/cb_8beccg_comp.vhdl \
$OCMB/cb_cfg_reg.vhdl \
$OCMB/cb_err_reg.vhdl \
$OCMB/cb_func.vhdl \
$OCMB/cb_gp_fifo.vhdl \
$OCMB/cb_tlxr_array.vhdl \
$OCMB/cb_tlxr_buff_ctl.vhdl \
$OCMB/cb_tlxr_fastact_fifo.vhdl \
$OCMB/cb_tlxr_fastact_fifo_wrap.vhdl \
$OCMB/cb_tlxr_mac.vhdl \
$OCMB/cb_tlxr_pkg.vhdl \
$OCMB/cb_tlxr_ra.vhdl \
$OCMB/cb_tlxr_xlat.vhdl \
$OCMB/cb_tlxt_crd_mgmt_rlm.vhdl \
$OCMB/cb_tlxt_dbg.vhdl \
$OCMB/cb_tlxt_flit_arb_rlm.vhdl \
$OCMB/cb_tlxt_mac.vhdl \
$OCMB/cb_tlxt_pkg.vhdl \
$OCMB/cb_tlxt_regs.vhdl \
$OCMB/cb_tlxt_trans_arb_rlm.vhdl \
$OCMB/cb_trap_reg.vhdl \
$OCMB/mc_8beccg_comp.vhdl \
"

OUTPUT=./libs

xrun -v93 -64bit -compile -smartorder \
-reflib libs/ibm:ibm \
-reflib libs/support:support \
-reflib libs/latches:latches \
-reflib libs/stdcell:stdcell \
-reflib libs/clib:clib \
-makelib $OUTPUT/work:work $SRC -endlib

