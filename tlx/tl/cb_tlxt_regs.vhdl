-- *!***************************************************************************
-- *! Copyright 2019 International Business Machines
-- *!
-- *! Licensed under the Apache License, Version 2.0 (the "License");
-- *! you may not use this file except in compliance with the License.
-- *! You may obtain a copy of the License at
-- *! http://www.apache.org/licenses/LICENSE-2.0 
-- *!
-- *! The patent license granted to you in Section 3 of the License, as applied
-- *! to the "Work," hereby includes implementations of the Work in physical form.  
-- *!
-- *! Unless required by applicable law or agreed to in writing, the reference design
-- *! distributed under the License is distributed on an "AS IS" BASIS,
-- *! WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- *! See the License for the specific language governing permissions and
-- *! limitations under the License.
-- *! 
-- *! The background Specification upon which this is based is managed by and available from
-- *! the OpenCAPI Consortium.  More information can be found at https://opencapi.org. 
-- *!***************************************************************************

LIBRARY ieee, ibm, latches, stdcell, support, clib;
USE ibm.std_ulogic_asic_function_support.ALL;
USE ibm.std_ulogic_support.ALL;
USE ibm.std_ulogic_unsigned.ALL;
USE ibm.std_ulogic_function_support.ALL;
USE ibm.synthesis_support.ALL;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ibm.std_ulogic_ao_support.ALL;
USE support.logic_support_pkg.ALL;
USE support.power_logic_pkg.ALL;
USE support.design_util_functions_pkg.ALL;
USE support.signal_resolution_pkg.ALL;
USE ibm.texsim_attributes.ALL;

LIBRARY work;
USE work.cb_func.cb_term;

ENTITY cb_tlxt_regs IS
  PORT (
    gckn                           : in STD_ULOGIC;
    syncr                          : in STD_ULOGIC := '0';

    scom_tlx_sat_id                : in std_ulogic_vector(0 to 1) := "00";  -- Satellite id

    tcm_tlxt_scom_cch              : in STD_ULOGIC;  -- SCOM address port to tlxt
    tlxt_tcm_scom_cch              : out STD_ULOGIC;  -- SCOM address port from tlxt

    tcm_tlxt_scom_dch              : in STD_ULOGIC;  -- SCOM data port to tlxt
    tlxt_tcm_scom_dch              : out STD_ULOGIC;  -- SCOM data port from tlxt

    tlx_xstop_err                  : out std_ulogic;                          -- checkstop   output to Global FIR
    tlx_recov_err                  : out std_ulogic;                          -- recoverable output to Global FIR
    tlx_recov_int                  : out std_ulogic;                          -- recoverable interrupt output to Global FIR
    tlx_mchk_out                   : out std_ulogic;                          -- used only if implement_mchk=true    tlx_trace_error       : OUT std_ulogic;                          -- error to connect to error_input of closest trdata macro
    tlx_fir_out                    : out std_ulogic_vector(0 to 27);          -- output of current FIR state if needed
    tlx_trace_error                : out std_ulogic;
    tlxc_crd_cfg_reg               : out STD_ULOGIC_VECTOR(0 to 63);
    tlxc_wat_en_reg                : out STD_ULOGIC_VECTOR(0 to 23);
    tlxc_crd_status_reg            : in STD_ULOGIC_VECTOR(0 to 127);

    tlxt_tlxr_early_wdone_disable  : out STD_ULOGIC_VECTOR(0 TO 1);
    tlxt_tlxr_ctrl                 : out STD_ULOGIC_VECTOR(0 TO 15);
    tlxt_dbg_mode                  : out std_ulogic_vector(0 to 15);
    tlxc_tlxt_ctrl                 : out STD_ULOGIC_VECTOR(0 TO 15);
    xstop_rd_gate_dis              : out STD_ULOGIC;

    tlxt_intrp_cmdflag_0           : out STD_ULOGIC_VECTOR(0 to 3);
    tlxt_intrp_cmdflag_1           : out STD_ULOGIC_VECTOR(0 to 3);
    tlxt_intrp_cmdflag_2           : out STD_ULOGIC_VECTOR(0 to 3);
    tlxt_intrp_cmdflag_3           : out STD_ULOGIC_VECTOR(0 to 3);
    tlxt_intrp_handle_0            : out STD_ULOGIC_VECTOR(0 to 63);
    tlxt_intrp_handle_1            : out STD_ULOGIC_VECTOR(0 to 63);
    tlxt_intrp_handle_2            : out STD_ULOGIC_VECTOR(0 to 63);
    tlxt_intrp_handle_3            : out STD_ULOGIC_VECTOR(0 to 63);

    tlxt_debug_bus                 : in std_ulogic_vector(0 to 87);
    tlxc_errors                    : in STD_ULOGIC_VECTOR(0 to 15);
    tlxc_perrors                   : in STD_ULOGIC_VECTOR(0 to 7);
    tlxr_tlxt_errors               : in std_ulogic_vector(0 to 63);  --
    tlxt_perrors                    : in std_ulogic_vector(0 to 32);  --
    tlxt_errors                    : in std_ulogic_vector(0 to 32);  --
    intrp_req_sm_perr               : in std_ulogic_vector(0 to 3);

    tlxr_tlxt_signature_dat        : IN std_ulogic_vector(0 TO 63);
    tlxr_tlxt_signature_strobe     : IN std_ulogic;

    gnd                            : inout power_logic;
    vdd                            : inout power_logic
    );

  ATTRIBUTE BLOCK_TYPE OF cb_tlxt_regs                : ENTITY IS LEAF;
  ATTRIBUTE BTR_NAME OF cb_tlxt_regs                  : ENTITY IS "CB_TLXT_REGS";
  ATTRIBUTE PIN_DEFAULT_GROUND_DOMAIN OF cb_tlxt_regs : ENTITY IS "GND";
  ATTRIBUTE PIN_DEFAULT_POWER_DOMAIN OF cb_tlxt_regs  : ENTITY IS "VDD";
  ATTRIBUTE RECURSIVE_SYNTHESIS OF cb_tlxt_regs       : ENTITY IS 2;
  ATTRIBUTE GROUND_PIN OF gnd                         : SIGNAL IS 1;
  ATTRIBUTE POWER_PIN OF vdd                          : SIGNAL IS 1;
  ATTRIBUTE PIN_DATA OF gckn                          : SIGNAL IS "PIN_FUNCTION=/G_CLK/";
END cb_tlxt_regs;

ARCHITECTURE cb_tlxt_regs OF cb_tlxt_regs IS

  SIGNAL act : STD_ULOGIC;
  SIGNAL tcm_tlxt_scom_cch_d : STD_ULOGIC;
  SIGNAL tcm_tlxt_scom_dch_d : STD_ULOGIC;
  SIGNAL tlxt_tcm_scom_dch_d : STD_ULOGIC;
  SIGNAL scom_dch_out : STD_ULOGIC;
  SIGNAL tlxt_tcm_scom_cch_d : STD_ULOGIC;
  SIGNAL scom_cch_out : STD_ULOGIC;
  SIGNAL tlxt_tcm_scom_cch_q : STD_ULOGIC;
  SIGNAL tlxt_tcm_scom_dch_q : STD_ULOGIC;
  SIGNAL sat_id : STD_ULOGIC_VECTOR(0 to 1);
  SIGNAL sc_req_d : STD_ULOGIC;
  SIGNAL sc_req : STD_ULOGIC;
  SIGNAL rdy_ack : STD_ULOGIC;
  SIGNAL rdy_q : STD_ULOGIC;
  SIGNAL ack_rdy : STD_ULOGIC;
  SIGNAL ack_q : STD_ULOGIC;
  SIGNAL rdy_d : STD_ULOGIC;
  SIGNAL ack_d : STD_ULOGIC;
  SIGNAL sc_ack : STD_ULOGIC;
  SIGNAL sc_wr_d : STD_ULOGIC;
  SIGNAL sc_req_q : STD_ULOGIC;
  SIGNAL sc_r_nw : STD_ULOGIC;
  SIGNAL sc_wr : STD_ULOGIC;
  SIGNAL sc_wr_q : STD_ULOGIC;
  SIGNAL sc_rdata_d : STD_ULOGIC_VECTOR(0 to 63);
  SIGNAL sc_addr_v : STD_ULOGIC_VECTOR(0 to 53);
  SIGNAL sc_rdata : STD_ULOGIC_VECTOR(0 to 63);
  SIGNAL sc_rdata_q : STD_ULOGIC_VECTOR(0 to 63);
  SIGNAL error_in : STD_ULOGIC_VECTOR(0 to 27);
  SIGNAL fir_out_int : STD_ULOGIC_VECTOR(0 to 27);
  SIGNAL fir_mask_out : STD_ULOGIC_VECTOR(0 to 27);
  SIGNAL tcm_tlxt_scom_dch_q : STD_ULOGIC;
  SIGNAL tcm_tlxt_scom_cch_q : STD_ULOGIC;
  SIGNAL sc_wdata : STD_ULOGIC_VECTOR(0 to 63);
  SIGNAL sc_wparity : STD_ULOGIC;


  ----------------------------------------------------------------------------------------------------------------------------------------
  SIGNAL trap0_reg_perr : STD_ULOGIC;
  SIGNAL trap1_reg_perr : STD_ULOGIC;
  SIGNAL trap2_reg_perr : STD_ULOGIC;
  SIGNAL trap3_reg_perr : STD_ULOGIC;
  SIGNAL trap4_reg_perr : STD_ULOGIC;
  SIGNAL cfg_0_reg_perr : STD_ULOGIC;
  SIGNAL cfg_1_reg_perr : STD_ULOGIC;
  SIGNAL cfg_2_reg_perr : STD_ULOGIC;

  SIGNAL inthld_0_reg_perr : STD_ULOGIC;
  SIGNAL inthld_1_reg_perr : STD_ULOGIC;
  SIGNAL inthld_2_reg_perr : STD_ULOGIC;
  SIGNAL inthld_3_reg_perr : STD_ULOGIC;
  SIGNAL inthld_reg_perr   : STD_ULOGIC;

  SIGNAL trap0_input_bus : STD_ULOGIC_VECTOR(0 to 63);
  SIGNAL trap1_input_bus : STD_ULOGIC_VECTOR(0 to 63);
  SIGNAL trap2_input_bus : STD_ULOGIC_VECTOR(0 to 63);
  SIGNAL trap3_input_bus : STD_ULOGIC_VECTOR(0 to 63);
  SIGNAL trap4_input_bus : STD_ULOGIC_VECTOR(0 to 63);
  SIGNAL trap0_update : STD_ULOGIC;
  SIGNAL trap1_update : STD_ULOGIC;
  SIGNAL trap2_update : STD_ULOGIC;
  SIGNAL trap3_update : STD_ULOGIC;
  SIGNAL trap4_update : STD_ULOGIC;
  SIGNAL clear : STD_ULOGIC;
  SIGNAL trap_update : STD_ULOGIC;


  SIGNAL cfg_0_reg : STD_ULOGIC_VECTOR(0 to 63);
  SIGNAL cfg_1_reg : STD_ULOGIC_VECTOR(0 to 63);
  SIGNAL cfg_2_reg : STD_ULOGIC_VECTOR(0 to 63);

  SIGNAL inthld_0_reg: STD_ULOGIC_VECTOR(0 TO 63);
  SIGNAL inthld_1_reg: STD_ULOGIC_VECTOR(0 TO 63);
  SIGNAL inthld_2_reg: STD_ULOGIC_VECTOR(0 TO 63);
  SIGNAL inthld_3_reg: STD_ULOGIC_VECTOR(0 TO 63);

  SIGNAL err_stop : STD_ULOGIC;
  SIGNAL hold_acum : STD_ULOGIC;
  SIGNAL err0_mask_perr : STD_ULOGIC;
  SIGNAL err0_acum_perr : STD_ULOGIC;
  SIGNAL err1_mask_perr : STD_ULOGIC;
  SIGNAL err1_acum_perr : STD_ULOGIC;
  SIGNAL err2_mask_perr : STD_ULOGIC;
  SIGNAL err2_acum_perr : STD_ULOGIC;
  SIGNAL err0_mask  : STD_ULOGIC_VECTOR(0 to 63);
  SIGNAL err0_acum : STD_ULOGIC_VECTOR(0 to 63);
  SIGNAL err1_mask  : STD_ULOGIC_VECTOR(0 to 63);
  SIGNAL err1_acum : STD_ULOGIC_VECTOR(0 to 63);
  SIGNAL err2_mask  : STD_ULOGIC_VECTOR(0 to 31);
  SIGNAL err2_acum : STD_ULOGIC_VECTOR(0 to 31);
  SIGNAL errtrap0_input_bus : std_ulogic_vector(0 to 63);
  SIGNAL errtrap0_output_bus : std_ulogic_vector(0 to 63);
  SIGNAL errtrap1_input_bus : std_ulogic_vector(0 to 63);
  SIGNAL errtrap1_output_bus : std_ulogic_vector(0 to 63);
  SIGNAL errtrap2_input_bus : std_ulogic_vector(0 to 31);
  SIGNAL errtrap2_output_bus : std_ulogic_vector(0 to 31);

  SIGNAL trap_0_reg : STD_ULOGIC_VECTOR(0 to 63);
  SIGNAL trap_1_reg : STD_ULOGIC_VECTOR(0 to 63);
  SIGNAL trap_2_reg : STD_ULOGIC_VECTOR(0 to 63);
  SIGNAL trap_3_reg : STD_ULOGIC_VECTOR(0 to 63);
  SIGNAL trap_4_reg : STD_ULOGIC_VECTOR(0 to 63);

  SIGNAL ctrl_reg_perr : STD_ULOGIC;
  SIGNAL info_reg_perr : STD_ULOGIC;
  SIGNAL tlxt_perr : STD_ULOGIC;
  SIGNAL tlxt_info_perr : STD_ULOGIC;
  SIGNAL tlxt_rec_err : STD_ULOGIC;
  SIGNAL tlxt_cfg_err : STD_ULOGIC;
  SIGNAL tlxt_unrec_err : STD_ULOGIC;
  SIGNAL tlxc_perr : STD_ULOGIC;
  SIGNAL tlxc_err : STD_ULOGIC;
  SIGNAL tlx_vc0_max_crd_error: std_ulogic;
  SIGNAL tlx_vc1_max_crd_error: std_ulogic;
  SIGNAL tlx_dcp0_max_crd_error: std_ulogic;
  SIGNAL tlx_dcp3_max_crd_error: std_ulogic;

  signal TLXR_Shutdown                   : STD_ULOGIC;
  signal TLXR_BAR0_or_MMIO_nf            : STD_ULOGIC;
  signal TLXR_OC_Malformed               : STD_ULOGIC;
  signal TLXR_OC_Protocol_Error          : STD_ULOGIC;
  signal TLXR_Addr_Xlat                  : STD_ULOGIC;
  signal TLXR_Metadata_unc_dperr         : STD_ULOGIC;
  signal TLXR_OC_Unsupported             : STD_ULOGIC;
  signal TLXR_OC_Fatal                   : STD_ULOGIC;
  signal TLXR_Control_error              : STD_ULOGIC;
  signal TLXR_Internal_Error             : STD_ULOGIC;
  signal TLXR_Informational              : STD_ULOGIC;
  signal TLXR_Trace_Stop                 : STD_ULOGIC;

BEGIN

  act <= '1';

  -----------------------------------------------------------------------------------
  -- SCOM satellite
  -----------------------------------------------------------------------------------

  -----------------------------------------------------------------------------------------------------------------------------------------------------------
  --00<->03 RW CONFIG REGs
  -----------------------------------------------------------------------------------------------------------------------------------------------------------
  -- 00 TLXCFG0 RW  TLX Configuration Register 0
  -- 01 TLXCFG1 RW  TLX Configuration Register 1
  -- 02 TLXCFG2 RW  TLX Configuration Register 2

  -----------------------------------------------------------------------------------------------------------------------------------------------------------
  --04<->07 RW TLXT Interrupt Handle
  -----------------------------------------------------------------------------------------------------------------------------------------------------------
  -- 04 INTHDL0 RW  TLXT Interrupt Handle Register 0
  -- 05 INTHDL0 RW  TLXT Interrupt Handle Register 1
  -- 06 INTHDL0 RW  TLXT Interrupt Handle Register 2
  -- 07 INTHDL0 RW  TLXT Interrupt Handle Register 3

  -----------------------------------------------------------------------------------------------------------------------------------------------------------
  --08<->15 RW  Error  Mask Reg
  -----------------------------------------------------------------------------------------------------------------------------------------------------------
  -- 08 TLXERR  RW   TLX Error Mask Reg 0
  -- 09 TLXERR  RW   TLX Error Mask Reg 1
  -- 10 TLXERR  RW   TLX Error Mask Reg 2

  -----------------------------------------------------------------------------------------------------------------------------------------------------------
  --16<->23 RO  Error Report REGs
  -----------------------------------------------------------------------------------------------------------------------------------------------------------
  -- 16 TLXETR0 ROH TLX Error Report 0
  -- 17 TLXETR0 ROH TLX Error Report 1
  -- 18 TLXETR0 ROH TLX Error Report 1

  -----------------------------------------------------------------------------------------------------------------------------------------------------------
  --24<->53 RO  Status/Trap REGs
  -----------------------------------------------------------------------------------------------------------------------------------------------------------
  -- 24 TLXTR1  R   TLX Trap Register 0
  -- 25 TLXTR0  R   TLX Trap Register 1

  -----------------------------------------------------------------------------------------------------------------------------------------------------------
  --32<->53 TBD
  -----------------------------------------------------------------------------------------------------------------------------------------------------------


  -- latch scom control/data signals
  tcm_tlxt_scom_cch_d <= tcm_tlxt_scom_cch;
  tcm_tlxt_scom_dch_d <= tcm_tlxt_scom_dch;
  tlxt_tcm_scom_dch_d <= scom_dch_out;
  tlxt_tcm_scom_cch_d <= scom_cch_out;
  tlxt_tcm_scom_cch   <= tlxt_tcm_scom_cch_q;
  tlxt_tcm_scom_dch   <= tlxt_tcm_scom_dch_q;

  tlx_fir_out <= fir_out_int;

  sat_id(0 TO 1) <= scom_tlx_sat_id;

  sc_req_d <= sc_req;


  rdy_ack <= rdy_q AND sc_req;
  ack_rdy <= ack_q AND NOT sc_req;

  rdy_d <= NOT vor(rdy_q & ack_q) OR (rdy_q AND NOT rdy_ack) OR ack_rdy;  

  ack_d <= (ack_q AND NOT ack_rdy) OR rdy_ack;

  sc_ack <= ack_q;

  sc_wr_d <= sc_req AND NOT sc_req_q AND NOT sc_r_nw;
  sc_wr   <= sc_wr_q;

  -----------------------------------------------------------------------------------------------------------------------------------------------------------
  --CFG0 REG
  -----------------------------------------------------------------------------------------------------------------------------------------------------------
  clear                                <= cfg_0_reg(0);
  tlxt_tlxr_early_wdone_disable        <= cfg_0_reg(1 TO 2);
  trap_update                         <= cfg_0_reg(3);
  hold_acum                           <= cfg_0_reg(4);
  tlxc_crd_cfg_reg                     <= (0 TO 9 => '0') & cfg_0_reg(10 TO 63);

  -----------------------------------------------------------------------------------------------------------------------------------------------------------
  --CFG1 REG
  -----------------------------------------------------------------------------------------------------------------------------------------------------------
  tlxt_tlxr_ctrl(0 TO 15) <= cfg_1_reg(0 TO 15);

  tlxt_dbg_mode(0 TO 15)  <= cfg_1_reg(16 TO 31);

  tlxc_tlxt_ctrl(0 TO 15) <= cfg_1_reg(32 TO 47);

  tlxt_intrp_cmdflag_0    <= cfg_1_reg(48 TO 51);
  tlxt_intrp_cmdflag_1    <= cfg_1_reg(52 TO 55);
  tlxt_intrp_cmdflag_2    <= cfg_1_reg(56 TO 59);
  tlxt_intrp_cmdflag_3    <= cfg_1_reg(60 TO 63);

  -----------------------------------------------------------------------------------------------------------------------------------------------------------
  --CFG2 REG
  -----------------------------------------------------------------------------------------------------------------------------------------------------------
  tlxc_wat_en_reg(0 TO 23) <= cfg_2_reg(0 TO 23);

  xstop_rd_gate_dis <= cfg_2_reg(24);


  -----------------------------------------------------------------------------------------------------------------------------------------------------------
  --TLXT interrupt Handle REG
  -----------------------------------------------------------------------------------------------------------------------------------------------------------
  tlxt_intrp_handle_0 <= inthld_0_reg;
  tlxt_intrp_handle_1 <= inthld_1_reg;
  tlxt_intrp_handle_2 <= inthld_2_reg;
  tlxt_intrp_handle_3 <= inthld_3_reg;

  -----------------------------------------------------------------------------------------------------------------------------------------------------------
  --SCOM FIR
  -----------------------------------------------------------------------------------------------------------------------------------------------------------
  error_in(0)            <= info_reg_perr;
  error_in(1)            <= ctrl_reg_perr;
  error_in(2)            <= tlx_vc0_max_crd_error;
  error_in(3)            <= tlx_vc1_max_crd_error;
  error_in(4)            <= tlx_dcp0_max_crd_error;
  error_in(5)            <= tlx_dcp3_max_crd_error;
  error_in(6)            <= tlxc_err;
  error_in(7)            <= tlxc_perr;
  error_in(8)            <= tlxt_perr;
  error_in(9)            <= tlxt_rec_err;
  error_in(10)           <= tlxt_cfg_err;
  error_in(11)           <= tlxt_unrec_err;
  error_in(12)           <= tlxt_info_perr;
  error_in(13  TO 15)    <= (OTHERS => '0');
  error_in(16)           <= TLXR_Shutdown;
  error_in(17)           <= TLXR_BAR0_or_MMIO_nf;
  error_in(18)           <= TLXR_OC_Malformed;
  error_in(19)           <= TLXR_OC_Protocol_Error;
  error_in(20)           <= TLXR_Addr_Xlat;
  error_in(21)           <= TLXR_Metadata_unc_dperr;
  error_in(22)           <= TLXR_OC_Unsupported;
  error_in(23)           <= TLXR_OC_Fatal;
  error_in(24)           <= TLXR_Control_error;
  error_in(25)           <= TLXR_Internal_Error;
  error_in(26)           <= TLXR_Informational;
  error_in(27)           <= TLXR_Trace_Stop;

  -----------------------------------------------------------------------------------------------------------------------------------------------------------
  --error trap  REG
  -----------------------------------------------------------------------------------------------------------------------------------------------------------
  errtrap0_input_bus(0 TO 63) <= tlxr_tlxt_errors(0 TO 63);                          --bit00:43

  errtrap1_input_bus(0 TO 63) <= tlxt_perrors(0 TO 31)                         --bit00:31
                               & tlxt_errors(0 TO 31);                         --bit32:63

  errtrap2_input_bus(0 TO 31) <=
                                 tlxc_perrors(0 TO 7)                          --bit00:07
                               & tlxc_errors(4 TO 9)                           --bit08:13
                               & inthld_0_reg_perr                             --bit14:14
                               & inthld_1_reg_perr                             --bit15:15
                               & inthld_2_reg_perr                             --bit16:16
                               & inthld_3_reg_perr                             --bit17:17
                               & tlxt_errors(32)                               --bit18:18
                               & intrp_req_sm_perr(0 to 3)                        --bit19:22
                               & tlxt_perrors(32)                               --bit23:23
                               & (24 TO 31 => '0')
                            ;

  cb_term(tlxc_errors(10 TO 15));       --bit 0 to 3 is tlx credit return overflow; routed to FIR directly


  ctrl_reg_perr   <=  or_reduce(
                              cfg_0_reg_perr
                            & cfg_1_reg_perr
                            & cfg_2_reg_perr
                            & inthld_reg_perr
                            & err0_mask_perr
                            & err1_mask_perr
                            & err2_mask_perr
                            & err0_acum_perr
                            & err1_acum_perr
                            & err2_acum_perr);
  info_reg_perr   <=  or_reduce(
                              trap0_reg_perr
                            & trap1_reg_perr
                            & trap2_reg_perr
                            & trap3_reg_perr
                            & trap4_reg_perr);


  TLXR_Shutdown                    <= or_reduce(errtrap0_output_bus(5 to 6));           --   16  58:57
  TLXR_BAR0_or_MMIO_nf             <= or_reduce(errtrap0_output_bus(7 to 8));           --   17  56:55
  TLXR_OC_Malformed                <= or_reduce(errtrap0_output_bus(9 to 14));          --   18  54:49
  TLXR_OC_Protocol_Error           <= or_reduce(errtrap0_output_bus(15 to 20));         --   19  48:43
  TLXR_Addr_Xlat                   <= or_reduce(errtrap0_output_bus(21 to 25));         --   20  42:38
  TLXR_Metadata_unc_dperr          <= or_reduce(errtrap0_output_bus(26 to 28));         --   21  37:35
  TLXR_OC_Unsupported              <= or_reduce(errtrap0_output_bus(29 to 36));         --   22  34:27
  TLXR_OC_Fatal                    <= or_reduce(errtrap0_output_bus(37 to 39));         --   23  26:24
  TLXR_Control_error               <= or_reduce(errtrap0_output_bus(40 to 49));         --   24  23:14
  TLXR_Internal_Error              <= or_reduce(errtrap0_output_bus(50 to 56));         --   25  13:7
  TLXR_Informational               <= or_reduce(errtrap0_output_bus(57 to 62));         --   26   6:1
  TLXR_Trace_Stop                  <= errtrap0_output_bus(63);                          --   27   0

  tlxt_perr                        <=  or_reduce(errtrap1_output_bus(1 TO 21)) OR
                                       or_reduce(errtrap1_output_bus(23 to 24)) OR
                                       or_reduce(errtrap1_output_bus(26 to 36)) OR
                                       or_reduce(errtrap2_output_bus(19 to 22));
  tlxt_rec_err                     <=  or_reduce(errtrap1_output_bus(37 TO 41));
  tlxt_cfg_err                     <=  or_reduce(errtrap1_output_bus(42 TO 43)) or errtrap1_output_bus(63);
  tlxt_unrec_err                   <=  or_reduce(errtrap1_output_bus(44 TO 62)) or errtrap2_output_bus(18);
  tlxt_info_perr                   <=  errtrap1_output_bus(0) or
                                       errtrap1_output_bus(22) or
                                       errtrap1_output_bus(25);

  tlxc_perr                        <=  or_reduce(errtrap2_output_bus(0 TO 7));

  tlx_vc0_max_crd_error            <= tlxc_errors(0);
  tlx_vc1_max_crd_error            <= tlxc_errors(1);
  tlx_dcp0_max_crd_error           <= tlxc_errors(2);
  tlx_dcp3_max_crd_error           <= tlxc_errors(3);

  tlxc_err                         <=  or_reduce(errtrap2_output_bus(8 TO 13));
  inthld_reg_perr                  <=  or_reduce(errtrap2_output_bus(14 TO 17));
  cb_term(errtrap2_output_bus(18 TO 31));

  err_stop <= or_reduce(fir_out_int AND NOT fir_mask_out) AND NOT hold_acum;



  -----------------------------------------------------------------------------------------------------------------------------------------------------------
  --trap  REG
  -----------------------------------------------------------------------------------------------------------------------------------------------------------
  trap0_input_bus <= tlxc_crd_status_reg(0 TO 63);
  trap1_input_bus <= tlxc_crd_status_reg(64 TO 127);
  trap2_input_bus <= tlxt_debug_bus(0 TO 63);
  trap3_input_bus <= tlxt_debug_bus(64 TO 87) & (88 TO 127 => '0') ;
  trap4_input_bus <= tlxr_tlxt_signature_dat(0 TO 63);

  trap0_update  <= NOT or_reduce(fir_out_int AND NOT fir_mask_out) OR trap_update;
  trap1_update  <= NOT or_reduce(fir_out_int AND NOT fir_mask_out) OR trap_update;
  trap2_update  <= NOT or_reduce(fir_out_int AND NOT fir_mask_out) OR trap_update;
  trap3_update  <= NOT or_reduce(fir_out_int AND NOT fir_mask_out) OR trap_update;
  trap4_update  <= (NOT or_reduce(fir_out_int AND NOT fir_mask_out) OR trap_update) AND tlxr_tlxt_signature_strobe;

  -----------------------------------------------------------------------------------------------------------------------------------------------------------

  sc_rdata_d(0 TO 63) <= gate(cfg_0_reg(0 TO 63),  (sc_req AND sc_r_nw AND sc_addr_v(0))) OR
                         gate(cfg_1_reg(0 TO 63),  (sc_req AND sc_r_nw AND sc_addr_v(1))) OR
                         gate(cfg_2_reg(0 TO 63),  (sc_req AND sc_r_nw AND sc_addr_v(2))) OR
                         gate(inthld_0_reg(0 TO 63),  (sc_req AND sc_r_nw AND sc_addr_v(4))) OR
                         gate(inthld_1_reg(0 TO 63),  (sc_req AND sc_r_nw AND sc_addr_v(5))) OR
                         gate(inthld_2_reg(0 TO 63),  (sc_req AND sc_r_nw AND sc_addr_v(6))) OR
                         gate(inthld_3_reg(0 TO 63),  (sc_req AND sc_r_nw AND sc_addr_v(7))) OR
                         gate(err0_mask(0 TO 63),   (sc_req AND sc_r_nw AND sc_addr_v(8))) OR
                         gate(err1_mask(0 TO 63),   (sc_req AND sc_r_nw AND sc_addr_v(9))) OR
                         gate(err2_mask(0 TO 31) & x"00000000",   (sc_req AND sc_r_nw AND sc_addr_v(10))) OR
                         gate(err0_acum(0 TO 63),   (sc_req AND sc_r_nw AND sc_addr_v(16))) OR
                         gate(err1_acum(0 TO 63),   (sc_req AND sc_r_nw AND sc_addr_v(17))) OR
                         gate(err2_acum(0 TO 31) & x"00000000",   (sc_req AND sc_r_nw AND sc_addr_v(18))) OR
                         gate(trap_0_reg(0 TO 63), (sc_req AND sc_r_nw AND sc_addr_v(24))) OR
                         gate(trap_1_reg(0 TO 63), (sc_req AND sc_r_nw AND sc_addr_v(25))) OR
                         gate(trap_2_reg(0 TO 63), (sc_req AND sc_r_nw AND sc_addr_v(26))) OR
                         gate(trap_3_reg(0 TO 63), (sc_req AND sc_r_nw AND sc_addr_v(27))) OR
                         gate(trap_4_reg(0 TO 63), (sc_req AND sc_r_nw AND sc_addr_v(28)));

  sc_rdata(0 TO 63) <= sc_rdata_q(0 TO 63);

-----------------------------------------------------------------------------------------------------------------------------------------------------------
-- Access Error
-----------------------------------------------------------------------------------------------------------------------------------------------------------

  scomfir : ENTITY clib.c_local_scomfir_wolcb
    GENERIC MAP
    (scom_width             => 64
, fir_width                 => 28
, satid_nobits         => 2
, fir_action0_init          => "0000000000000000000000000000"
, fir_action0_par_init      => "0"
, fir_action1_init          => "0000000000000000000000000000"
, fir_action1_par_init      => "0"
, fir_mask_init             => "1111111111111111111111111111"
, fir_mask_par_init         => "0"
, no_wof_mode               => FALSE
, implement_mchk            => TRUE  -- :boolean := false   -- no choice here
, ratio                     => '0'  -- :std_ulogic := '0' -- '0' for 1:1, '1' for 2:1 timing
, apply_scom_reg_phase_hold => FALSE    -- :boolean  := false
, fir_divide2               => FALSE  -- :boolean  := false -- run fir 2x slower than scom   ( really just div2 for fir func latches )
, use_recov_reset           => TRUE
     --                                     0         1         2         3         4         5         6
     --                                     0123456789012345678901234567890123456789012345678901234567890123
, use_addr                  =>             "111011111110000011100000111110000000000000000000000000"
, addr_is_rdable            =>             "111011111110000011100000111110000000000000000000000000"
, addr_is_wrable            =>             "111011111110000000000000000000000000000000000000000000"
, pipeline_addr_v           => "000000000000000000000000000000000000000000000000000000000000000000"
     )
    PORT MAP (
      func2_lckn    => gckn
, func_lckn         => gckn
, func_out_lckn     => gckn
, scom_lckn         => gckn
, gen_lckn          => gckn
, vdd               => vdd
, gnd               => gnd
, syncr             => syncr
, error_in(0 TO 27) => error_in(0 TO 27)
, xstop_err         => tlx_xstop_err
, recov_err         => tlx_recov_err
, recov_int         => tlx_recov_int
, mchk_out          => tlx_mchk_out
, trace_error       => tlx_trace_error
, fir_out           => fir_out_int(0 TO 27)
, fir_mask_out      => fir_mask_out(0 TO 27)
, sat_id            => sat_id(0 TO 1)-- & "00"
, scom_dch_in       => tcm_tlxt_scom_dch_q
, scom_cch_in       => tcm_tlxt_scom_cch_q
, scom_dch_out      => scom_dch_out
, scom_cch_out      => scom_cch_out
, sc_req            => sc_req
, sc_r_nw           => sc_r_nw
, sc_ack            => sc_ack
, sc_addr_v         => sc_addr_v(0 TO 53)
, sc_rdata          => sc_rdata(0 TO 63)
, sc_wdata          => sc_wdata(0 TO 63)
, sc_wparity        => sc_wparity
      );

  --CFG REG
  cfg0 : ENTITY work.cb_cfg_reg
    GENERIC MAP (
      addr_bit_index  => 0,                    -- [natural] address index of the register
      reg_reset_value => x"0000000000000000")  -- [std_ulogic_vector(0 to 63)]
    PORT MAP (
      gckn => gckn,                            -- [in  std_ulogic]
      gnd  => gnd,                             -- [inout power_logic]
      vdd  => vdd,                             -- [inout power_logic]
      syncr  => syncr,           -- [in  STD_ULOGIC := '0']
      sc_addr_v  => sc_addr_v,          -- [in  std_ulogic_vector(0 to (num_addr_bits - 1))]
      sc_wdata   => sc_wdata,           -- [in  std_ulogic_vector(0 to ((reg_width * 8) - 1))] Write data delivered from SCOM satellite for a write request
      sc_wparity => sc_wparity,         -- [in  std_ulogic] Write data parity bit over sc_wdata
      sc_wr      => sc_wr,              -- [in  std_ulogic] write pulse
      cfg_reg      => cfg_0_reg(0 TO 63),  -- [out std_ulogic_vector(0 to ((reg_width * 8) - 1))] configuration register output value
      cfg_reg_perr => cfg_0_reg_perr);       -- [out std_ulogic] internal parity error reporting for this register instantiation

  cfg1 : ENTITY work.cb_cfg_reg
    GENERIC MAP (
      addr_bit_index  => 1,                    -- [natural] address index of the register
      reg_reset_value => x"0000000010800000")  -- [std_ulogic_vector(0 to 63)]
    PORT MAP (
      --CLOCKS
      gckn => gckn,                            -- [in  std_ulogic]
      gnd  => gnd,                             -- [inout power_logic]
      vdd  => vdd,                             -- [inout power_logic]
      syncr  => syncr,           -- [in  STD_ULOGIC := '0']
      sc_addr_v  => sc_addr_v,          -- [in  std_ulogic_vector(0 to (num_addr_bits - 1))]
      sc_wdata   => sc_wdata,           -- [in  std_ulogic_vector(0 to ((reg_width * 8) - 1))] Write data delivered from SCOM satellite for a write request
      sc_wparity => sc_wparity,         -- [in  std_ulogic] Write data parity bit over sc_wdata
      sc_wr      => sc_wr,              -- [in  std_ulogic] write pulse
      cfg_reg      => cfg_1_reg(0 TO 63),  -- [out std_ulogic_vector(0 to ((reg_width * 8) - 1))] configuration register output value
      cfg_reg_perr => cfg_1_reg_perr);       -- [out std_ulogic] internal parity error reporting for this register instantiation

  cfg2 : ENTITY work.cb_cfg_reg
    GENERIC MAP (
      addr_bit_index  => 2,                    -- [natural] address index of the register
      reg_reset_value => x"0000000000000000")  -- [std_ulogic_vector(0 to 63)]
    PORT MAP (
      --CLOCKS
      gckn => gckn,                            -- [in  std_ulogic]
      gnd  => gnd,                             -- [inout power_logic]
      vdd  => vdd,                             -- [inout power_logic]
      syncr  => syncr,           -- [in  STD_ULOGIC := '0']
      sc_addr_v  => sc_addr_v,          -- [in  std_ulogic_vector(0 to (num_addr_bits - 1))]
      sc_wdata   => sc_wdata,           -- [in  std_ulogic_vector(0 to ((reg_width * 8) - 1))] Write data delivered from SCOM satellite for a write request
      sc_wparity => sc_wparity,         -- [in  std_ulogic] Write data parity bit over sc_wdata
      sc_wr      => sc_wr,              -- [in  std_ulogic] write pulse
      cfg_reg      => cfg_2_reg(0 TO 63),  -- [out std_ulogic_vector(0 to ((reg_width * 8) - 1))] configuration register output value
      cfg_reg_perr => cfg_2_reg_perr);       -- [out std_ulogic] internal parity error report


  inthld0 : ENTITY work.cb_cfg_reg
    GENERIC MAP (
      addr_bit_index  => 4,                    -- [natural] address index of the register
      reg_reset_value => x"0000000000000000")  -- [std_ulogic_vector(0 to 63)]
    PORT MAP (
      --CLOCKS
      gckn => gckn,                            -- [in  std_ulogic]
      gnd  => gnd,                             -- [inout power_logic]
      vdd  => vdd,                             -- [inout power_logic]
      syncr  => syncr,           -- [in  STD_ULOGIC := '0']
      sc_addr_v  => sc_addr_v,          -- [in  std_ulogic_vector(0 to (num_addr_bits - 1))]
      sc_wdata   => sc_wdata,           -- [in  std_ulogic_vector(0 to ((reg_width * 8) - 1))] Write data delivered from SCOM satellite for a write request
      sc_wparity => sc_wparity,         -- [in  std_ulogic] Write data parity bit over sc_wdata
      sc_wr      => sc_wr,              -- [in  std_ulogic] write pulse
      cfg_reg      => inthld_0_reg(0 TO 63),  -- [out std_ulogic_vector(0 to ((reg_width * 8) - 1))] configuration register output value
      cfg_reg_perr => inthld_0_reg_perr);       -- [out std_ulogic] internal parity error report

  inthld1 : ENTITY work.cb_cfg_reg
    GENERIC MAP (
      addr_bit_index  => 5,                    -- [natural] address index of the register
      reg_reset_value => x"0000000000000000")  -- [std_ulogic_vector(0 to 63)]
    PORT MAP (
      --CLOCKS
      gckn => gckn,                            -- [in  std_ulogic]
      gnd  => gnd,                             -- [inout power_logic]
      vdd  => vdd,                             -- [inout power_logic]
      syncr  => syncr,           -- [in  STD_ULOGIC := '0']
      sc_addr_v  => sc_addr_v,          -- [in  std_ulogic_vector(0 to (num_addr_bits - 1))]
      sc_wdata   => sc_wdata,           -- [in  std_ulogic_vector(0 to ((reg_width * 8) - 1))] Write data delivered from SCOM satellite for a write request
      sc_wparity => sc_wparity,         -- [in  std_ulogic] Write data parity bit over sc_wdata
      sc_wr      => sc_wr,              -- [in  std_ulogic] write pulse
      cfg_reg      => inthld_1_reg(0 TO 63),  -- [out std_ulogic_vector(0 to ((reg_width * 8) - 1))] configuration register output value
      cfg_reg_perr => inthld_1_reg_perr);       -- [out std_ulogic] internal parity error report

   inthld2 : ENTITY work.cb_cfg_reg
    GENERIC MAP (
      addr_bit_index  => 6,                    -- [natural] address index of the register
      reg_reset_value => x"0000000000000000")  -- [std_ulogic_vector(0 to 63)]
    PORT MAP (
      --CLOCKS
      gckn => gckn,                            -- [in  std_ulogic]
      gnd  => gnd,                             -- [inout power_logic]
      vdd  => vdd,                             -- [inout power_logic]
      syncr  => syncr,           -- [in  STD_ULOGIC := '0']
      sc_addr_v  => sc_addr_v,          -- [in  std_ulogic_vector(0 to (num_addr_bits - 1))]
      sc_wdata   => sc_wdata,           -- [in  std_ulogic_vector(0 to ((reg_width * 8) - 1))] Write data delivered from SCOM satellite for a write request
      sc_wparity => sc_wparity,         -- [in  std_ulogic] Write data parity bit over sc_wdata
      sc_wr      => sc_wr,              -- [in  std_ulogic] write pulse
      cfg_reg      => inthld_2_reg(0 TO 63),  -- [out std_ulogic_vector(0 to ((reg_width * 8) - 1))] configuration register output value
      cfg_reg_perr => inthld_2_reg_perr);       -- [out std_ulogic] internal parity error report

  inthld3 : ENTITY work.cb_cfg_reg
    GENERIC MAP (
      addr_bit_index  => 7,                    -- [natural] address index of the register
      reg_reset_value => x"0000000000000000")  -- [std_ulogic_vector(0 to 63)]
    PORT MAP (
      --CLOCKS
      gckn => gckn,                            -- [in  std_ulogic]
      gnd  => gnd,                             -- [inout power_logic]
      vdd  => vdd,                             -- [inout power_logic]
      syncr  => syncr,           -- [in  STD_ULOGIC := '0']
      sc_addr_v  => sc_addr_v,          -- [in  std_ulogic_vector(0 to (num_addr_bits - 1))]
      sc_wdata   => sc_wdata,           -- [in  std_ulogic_vector(0 to ((reg_width * 8) - 1))] Write data delivered from SCOM satellite for a write request
      sc_wparity => sc_wparity,         -- [in  std_ulogic] Write data parity bit over sc_wdata
      sc_wr      => sc_wr,              -- [in  std_ulogic] write pulse
      cfg_reg      => inthld_3_reg(0 TO 63),  -- [out std_ulogic_vector(0 to ((reg_width * 8) - 1))] configuration register output value
      cfg_reg_perr => inthld_3_reg_perr);       -- [out std_ulogic] internal parity error report

  err0 : ENTITY work.cb_err_reg
    GENERIC MAP (
      addr_bit_index => 8)              -- [natural] address index of the Mask register
    PORT MAP (
      gckn          => gckn,            -- [in  std_ulogic]
      gnd           => gnd,             -- [inout power_logic]
      vdd           => vdd,             -- [inout power_logic]
      syncr         => syncr,           -- [in  STD_ULOGIC := '0']
      sc_addr_v     => sc_addr_v,       -- [in  std_ulogic_vector(0 to (num_addr_bits - 1))]
      sc_wdata      => sc_wdata,  -- [in  std_ulogic_vector(0 to ((err_mask_width * 8) - 1))] Write data delivered from SCOM satellite for a write request
      sc_wparity    => sc_wparity,      -- [in  std_ulogic] Write data parity bit over sc_wdata
      sc_wr         => sc_wr,           -- [in  std_ulogic] write pulse

      err_mask      => err0_mask,         -- [out std_ulogic_vector(0 to (err_mask_width - 1))] error mask  register output value
      err_mask_perr => err0_mask_perr,    -- [out std_ulogic] internal parity error reporting for this register instantiation

      err_in        => errtrap0_input_bus,           -- [in  std_ulogic_vector(0 to ((err_mask_width) - 1))]
      err_out       => errtrap0_output_bus,          -- [out std_ulogic_vector(0 to ((err_mask_width) - 1))]
      err_acum      => err0_acum,         -- [out std_ulogic_vector(0 to ((err_mask_width) - 1))]
      err_acum_perr => err0_acum_perr,    -- [out std_ulogic] internal parity error reporting for this register instantiation
      stop          => err_stop,                     -- [in  STD_ULOGIC := '0']
      clear         => clear);                   -- [in std_ulogic := '0']

  err1 : ENTITY work.cb_err_reg
    GENERIC MAP (
      addr_bit_index => 9)              -- [natural] address index of the Mask register
    PORT MAP (
      gckn          => gckn,            -- [in  std_ulogic]
      gnd           => gnd,             -- [inout power_logic]
      vdd           => vdd,             -- [inout power_logic]
      syncr         => syncr,           -- [in  STD_ULOGIC := '0']
      sc_addr_v     => sc_addr_v,       -- [in  std_ulogic_vector(0 to (num_addr_bits - 1))]
      sc_wdata      => sc_wdata,  -- [in  std_ulogic_vector(0 to ((err_mask_width * 8) - 1))] Write data delivered from SCOM satellite for a write request
      sc_wparity    => sc_wparity,      -- [in  std_ulogic] Write data parity bit over sc_wdata
      sc_wr         => sc_wr,           -- [in  std_ulogic] write pulse

      err_mask      => err1_mask,         -- [out std_ulogic_vector(0 to (err_mask_width - 1))] error mask  register output value
      err_mask_perr => err1_mask_perr,    -- [out std_ulogic] internal parity error reporting for this register instantiation

      err_in        => errtrap1_input_bus,           -- [in  std_ulogic_vector(0 to ((err_mask_width) - 1))]
      err_out       => errtrap1_output_bus,          -- [out std_ulogic_vector(0 to ((err_mask_width) - 1))]
      err_acum      => err1_acum,         -- [out std_ulogic_vector(0 to ((err_mask_width) - 1))]
      err_acum_perr => err1_acum_perr,    -- [out std_ulogic] internal parity error reporting for this register instantiation
      stop          => err_stop,                     -- [in  STD_ULOGIC := '0']
      clear         => clear);                   -- [in std_ulogic := '0']

  err2 : ENTITY work.cb_err_reg
    GENERIC MAP (
      addr_bit_index => 10,              -- [natural] address index of the Mask register
      err_mask_width => 32) --                     : natural := 64;    --Width of register in bits
    PORT MAP (
      gckn          => gckn,            -- [in  std_ulogic]
      gnd           => gnd,             -- [inout power_logic]
      vdd           => vdd,             -- [inout power_logic]
      syncr         => syncr,           -- [in  STD_ULOGIC := '0']
      sc_addr_v     => sc_addr_v,       -- [in  std_ulogic_vector(0 to (num_addr_bits - 1))]
      sc_wdata      => sc_wdata,  -- [in  std_ulogic_vector(0 to ((err_mask_width * 8) - 1))] Write data delivered from SCOM satellite for a write request
      sc_wparity    => sc_wparity,      -- [in  std_ulogic] Write data parity bit over sc_wdata
      sc_wr         => sc_wr,           -- [in  std_ulogic] write pulse

      err_mask      => err2_mask,         -- [out std_ulogic_vector(0 to (err_mask_width - 1))] error mask  register output value
      err_mask_perr => err2_mask_perr,    -- [out std_ulogic] internal parity error reporting for this register instantiation

      err_in        => errtrap2_input_bus,           -- [in  std_ulogic_vector(0 to ((err_mask_width) - 1))]
      err_out       => errtrap2_output_bus,          -- [out std_ulogic_vector(0 to ((err_mask_width) - 1))]
      err_acum      => err2_acum,         -- [out std_ulogic_vector(0 to ((err_mask_width) - 1))]
      err_acum_perr => err2_acum_perr,    -- [out std_ulogic] internal parity error reporting for this register instantiation
      stop          => err_stop,                     -- [in  STD_ULOGIC := '0']
      clear         => clear);                   -- [in std_ulogic := '0']

  --TRAP REGs
  trap0 : ENTITY work.cb_trap_reg
    PORT MAP (
      gckn           => gckn,                     -- [in  std_ulogic]
      gnd            => gnd,                      -- [inout power_logic]
      vdd            => vdd,                      -- [inout power_logic]
      syncr          => syncr,           -- [in  STD_ULOGIC := '0']
      trap_input_bus => trap0_input_bus,  -- [in  std_ulogic_vector(0 to 63)]
      trap_update    => trap0_update,   -- [in  std_ulogic]
      trap_clear     => clear,          -- [in  std_ulogic]
      trap_reg       => trap_0_reg,      -- [out std_ulogic_vector(0 to 63)] trap register output value
      trap_reg_perr  => trap0_reg_perr);  -- [out std_ulogic] internal parity error reporting for this register instantiation

  trap1 : ENTITY work.cb_trap_reg
    PORT MAP (
      gckn           => gckn,                     -- [in  std_ulogic]
      gnd            => gnd,                      -- [inout power_logic]
      vdd            => vdd,                      -- [inout power_logic]
      syncr          => syncr,           -- [in  STD_ULOGIC := '0']
      trap_input_bus => trap1_input_bus,  -- [in  std_ulogic_vector(0 to 63)]
      trap_update    => trap1_update,   -- [in  std_ulogic]
      trap_clear     => clear,          -- [in  std_ulogic]
      trap_reg       => trap_1_reg,      -- [out std_ulogic_vector(0 to 63)] trap register output value
      trap_reg_perr  => trap1_reg_perr);  -- [out std_ulogic] internal parity error reporting for this register instantiation

  trap2 : ENTITY work.cb_trap_reg
    PORT MAP (
      gckn           => gckn,                     -- [in  std_ulogic]
      gnd            => gnd,                      -- [inout power_logic]
      vdd            => vdd,                      -- [inout power_logic]
      syncr          => syncr,           -- [in  STD_ULOGIC := '0']
      trap_input_bus => trap2_input_bus,  -- [in  std_ulogic_vector(0 to 63)]
      trap_update    => trap2_update,   -- [in  std_ulogic]
      trap_clear     => clear,          -- [in  std_ulogic]
      trap_reg       => trap_2_reg,      -- [out std_ulogic_vector(0 to 63)] trap register output value
      trap_reg_perr  => trap2_reg_perr);  -- [out std_ulogic] internal parity error reporting for this register instantiation

  trap3 : ENTITY work.cb_trap_reg
    PORT MAP (
      gckn           => gckn,                     -- [in  std_ulogic]
      gnd            => gnd,                      -- [inout power_logic]
      vdd            => vdd,                      -- [inout power_logic]
      syncr          => syncr,           -- [in  STD_ULOGIC := '0']
      trap_input_bus => trap3_input_bus,  -- [in  std_ulogic_vector(0 to 63)]
      trap_update    => trap3_update,   -- [in  std_ulogic]
      trap_clear     => clear,          -- [in  std_ulogic]
      trap_reg       => trap_3_reg,      -- [out std_ulogic_vector(0 to 63)] trap register output value
      trap_reg_perr  => trap3_reg_perr);  -- [out std_ulogic] internal parity error reporting for this register instantiation

  trap4 : ENTITY work.cb_trap_reg
    PORT MAP (
      gckn           => gckn,                     -- [in  std_ulogic]
      gnd            => gnd,                      -- [inout power_logic]
      vdd            => vdd,                      -- [inout power_logic]
      syncr          => syncr,           -- [in  STD_ULOGIC := '0']
      trap_input_bus => trap4_input_bus,  -- [in  std_ulogic_vector(0 to 63)]
      trap_update    => trap4_update,   -- [in  std_ulogic]
      trap_clear     => clear,          -- [in  std_ulogic]
      trap_reg       => trap_4_reg,      -- [out std_ulogic_vector(0 to 63)] trap register output value
      trap_reg_perr  => trap4_reg_perr);  -- [out std_ulogic] internal parity error reporting for this register instantiation


ackq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(ack_d),
           syncr                => syncr,
           Tconv(q)             => ack_q);

rdyq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0, init => "1")
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(rdy_d),
           syncr                => syncr,
           Tconv(q)             => rdy_q);

sc_rdataq: entity latches.c_morph_dff
  generic map (width => 64, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(sc_rdata_d),
           syncr                => syncr,
           Tconv(q)             => sc_rdata_q);

sc_reqq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(sc_req_d),
           syncr                => syncr,
           Tconv(q)             => sc_req_q);

sc_wrq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(sc_wr_d),
           syncr                => syncr,
           Tconv(q)             => sc_wr_q);


tcm_tlxt_scom_cchq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(tcm_tlxt_scom_cch_d),
           syncr                => syncr,
           Tconv(q)             => tcm_tlxt_scom_cch_q);

tcm_tlxt_scom_dchq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(tcm_tlxt_scom_dch_d),
           syncr                => syncr,
           Tconv(q)             => tcm_tlxt_scom_dch_q);

tlxt_tcm_scom_cchq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(tlxt_tcm_scom_cch_d),
           syncr                => syncr,
           Tconv(q)             => tlxt_tcm_scom_cch_q);

tlxt_tcm_scom_dchq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(tlxt_tcm_scom_dch_d),
           syncr                => syncr,
           Tconv(q)             => tlxt_tcm_scom_dch_q);
END cb_tlxt_regs;
