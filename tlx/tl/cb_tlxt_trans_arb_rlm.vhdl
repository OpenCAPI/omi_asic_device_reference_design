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

LIBRARY ieee,ibm,latches,stdcell,support;
    USE ibm.std_ulogic_asic_function_support.all;
    USE ibm.std_ulogic_support.all;
    USE ibm.std_ulogic_unsigned.all;
    USE ibm.std_ulogic_function_support.all;
    USE ibm.synthesis_support.all;
    USE ieee.std_logic_1164.all;
    USE ieee.numeric_std.ALL;
    USE ibm.std_ulogic_ao_support.ALL;
    USE support.logic_support_pkg.all;
    USE support.power_logic_pkg.ALL;
    USE support.design_util_functions_pkg.all;
    USE support.signal_resolution_pkg.all;
    use ibm.texsim_attributes.all;
LIBRARY work;
USE work.cb_func.ALL;
USE work.cb_tlxt_pkg.INCP;

entity cb_tlxt_trans_arb_rlm is

  port (
    gckn                           : in std_ulogic;
    syncr                          : in std_ulogic;

    flit_part                      : in std_ulogic_vector(127 downto 0);  -- 16B flit partial
    flit_part_p                    : in std_ulogic_vector(15 downto 0);   -- Bytewise EVEN parity on flit_part
    flit_part_vld                  : in std_ulogic;  --16Bflit partial is valid this cycle
    flit_part_last_vld             : in std_ulogic;
    flit_part_last                 : in std_ulogic_vector(63 downto 0); --lbip data
    flit_part_last_p               : in std_ulogic_vector(7 downto 0);  -- Bytewise EVEN parity on flit_part_last

    dl_cont_tl_tmpl                : in std_ulogic_vector(5 downto 0);
    dl_cont_tl_tmpl_p              : in std_ulogic;
    dl_cont_data_run_len           : in std_ulogic_vector(3 downto 0);
    dl_cont_bdi_vec                : in std_ulogic_vector(7 downto 0);
    dl_cont_bdi_vec_p              : in std_ulogic_vector(1 downto 0); -- 1 covers 7:4, 0 covers 3:0

    flit_xmit_done                 : out std_ulogic;
    flit_xmit_early_done           : out std_ulogic;
    data_xmit                      : out std_ulogic;  --used for data beat counter
    data_flit_xmit                 : out std_ulogic;  -- used to gate flit transmission
    data_pending                   : in std_ulogic;
    data_valid                     : out std_ulogic;

    tmpl9_data_val                 : in std_ulogic;  --tmpllate 9 data feild empty is true
    tmplB_data_val                 : in std_ulogic;  --on for 4 clocks
    mmio_data_val                  : in std_ulogic;
    mmio_data_flit                 : in std_ulogic;
    mmio_data_flit_early                 : in std_ulogic;
    dlx_tlxr_link_up               : in std_ulogic;
    link_up_pulse                  : in std_ulogic;
    dlx_tlxt_flit_credit           : in std_ulogic;  --dl2tl flit_credit.
    flit_credit_avail              : out std_ulogic;
    flit_credit_overflow           : out std_ulogic;
    flit_credit_underflow          : out std_ulogic;
    --data_flits_avail               : out std_ulogic_vector(3 downto 0);
    flit_xmit_start                : in std_ulogic;  --start flit transmit.
    flit_xmit_start_early          : in std_ulogic;

    rd_resp_len32_flit             : in std_ulogic;
    rd_resp_len32_flit_early       : in std_ulogic;

    rdf_tlxt_data                  : in std_ulogic_vector(127 downto 0);  -- data from read dataflow
    rdf_tlxt_data_ecc              : in std_ulogic_vector(15 downto 0);
    rdf_tlxt_data_valid            : in std_ulogic;
    tlxt_rdf_data_taken            : out std_ulogic;
    tlxt_srq_rdbuf_pop             : out std_ulogic;

    tlxt_dlx_flit_vld              : out std_ulogic;
    tlxt_dlx_flit_early_vld_a        : out std_ulogic;
    tlxt_dlx_flit_early_vld_b        : out std_ulogic;
    tlxt_dlx_flit_data             : out std_ulogic_vector(127 downto 0);
    tlxt_dlx_flit_ecc              : out std_ulogic_vector(15 downto 0);
    tlxt_dlx_flit_lbip_data        : out std_ulogic_vector(81 downto 0);
    tlxt_dlx_flit_lbip_vld         : out std_ulogic;

    trans_arb_perrors              : out std_ulogic_vector(0 to 4);

    low_lat_mode                   : in std_ulogic;  --for clock gating
    half_dimm_mode                 : in std_ulogic;
    tlxt_clk_gate_dis              : in std_ulogic;

    cfei_enab                      : in std_ulogic;
    cfei_persist                   : in std_ulogic;
    cfei_bit0                      : in std_ulogic;
    cfei_bit1                      : in std_ulogic;

    gnd                            : inout power_logic;
    vdd                            : inout power_logic);



  attribute BLOCK_TYPE of cb_tlxt_trans_arb_rlm : entity is LEAF;
  attribute BTR_NAME of cb_tlxt_trans_arb_rlm : entity is "CB_TLXT_TRANS_ARB_RLM";
  attribute PIN_DEFAULT_GROUND_DOMAIN of cb_tlxt_trans_arb_rlm : entity is "GND";
  attribute PIN_DEFAULT_POWER_DOMAIN of cb_tlxt_trans_arb_rlm : entity is "VDD";
  attribute RECURSIVE_SYNTHESIS of cb_tlxt_trans_arb_rlm : entity is 2;
  attribute PIN_DATA of gckn : signal is "PIN_FUNCTION=/G_CLK/";
  attribute GROUND_PIN of gnd : signal is 1;
  attribute POWER_PIN of vdd : signal is 1;
end cb_tlxt_trans_arb_rlm;

architecture cb_tlxt_trans_arb_rlm of cb_tlxt_trans_arb_rlm is
  SIGNAL act : std_ulogic;
  SIGNAL tidn : std_ulogic_vector(127 downto 0);
  SIGNAL tmpl0 : std_ulogic;
  SIGNAL tmpl1 : std_ulogic;
  SIGNAL tmpl5 : std_ulogic;
  SIGNAL tmpl9 : std_ulogic;
  SIGNAL mstr_cnt_reset : std_ulogic;
  SIGNAL mstr_cnt_q : std_ulogic_vector(5 downto 0);
  SIGNAL mstr_cnt_start : std_ulogic;
  SIGNAL mstr_cnt_inc : std_ulogic;
  SIGNAL mstr_cnt_hold : std_ulogic;
  SIGNAL mstr_cnt_d : std_ulogic_vector(5 downto 0);
  SIGNAL mstr_cnt_p_d : std_ulogic;
  SIGNAL mstr_cnt_p_q : std_ulogic;
  SIGNAL data_flit : std_ulogic;
  SIGNAL tmpl9_data : std_ulogic;
  SIGNAL ctrl : std_ulogic;
  SIGNAL tlxt_dlx_flit_data_egen : std_ulogic_vector(143 downto 0);
  SIGNAL tlxt_dlx_flit_data_perror : std_ulogic_vector(15 downto 0);
  SIGNAL tlxt_dlx_flit_ecc_egen : std_ulogic_vector(15 downto 0);
  SIGNAL tlxt_dlx_flit_data_d : std_ulogic_vector(127 downto 0);
  SIGNAL tlxt_dlx_flit_vld_d : std_ulogic;
  SIGNAL tlxt_dlx_flit_ecc_d : std_ulogic_vector(15 downto 0);
  SIGNAL tlxt_dlx_flit_par_d : std_ulogic_vector(15 downto 0);
  SIGNAL tlxt_dlx_flit_par_vld_d : std_ulogic_vector(1 downto 0);
  SIGNAL tlxt_dlx_flit_lbip_vld_d : std_ulogic;
  SIGNAL tlxt_dlx_flit_lbip_data_d : std_ulogic_vector(81 downto 0);
  SIGNAL tlxt_dlx_flit_lbip_data_p_d : std_ulogic_vector(10 downto 0);
  SIGNAL tlxt_dlx_flit_data_q : std_ulogic_vector(127 downto 0);
  SIGNAL tlxt_dlx_flit_ecc_q : std_ulogic_vector(15 downto 0);
  SIGNAL tlxt_dlx_flit_par_q : std_ulogic_vector(15 downto 0);
  SIGNAL tlxt_dlx_flit_par_vld_q : std_ulogic_vector(1 downto 0);
  SIGNAL tlxt_dlx_flit_vld_q : std_ulogic;
  SIGNAL tlxt_dlx_flit_lbip_data_q : std_ulogic_vector(81 downto 0);
  SIGNAL tlxt_dlx_flit_lbip_data_p_q : std_ulogic_vector(10 downto 0);
  SIGNAL tlxt_dlx_flit_lbip_vld_q : std_ulogic;
  SIGNAL ctrl_last : std_ulogic;
  SIGNAL flit_part_last_full : std_ulogic_vector(127 downto 0);
  SIGNAL flit_part_last_full_p : std_ulogic_vector(15 downto 0);
  SIGNAL dlx_flit_credit_inc : std_ulogic;
  SIGNAL str_rdf_data : std_ulogic;
  SIGNAL buf_data0_a_d : std_ulogic_vector(63 downto 0);
  SIGNAL buf_data0_a_q : std_ulogic_vector(63 downto 0);
  SIGNAL buf_data0_ecc_a_d : std_ulogic_vector(7 downto 0);
  SIGNAL buf_data0_ecc_a_q : std_ulogic_vector(7 downto 0);
  SIGNAL buf_data0_b_d : std_ulogic_vector(63 downto 0);
  SIGNAL buf_data0_b_q : std_ulogic_vector(63 downto 0);
  SIGNAL buf_data0_ecc_b_d : std_ulogic_vector(7 downto 0);
  SIGNAL buf_data0_ecc_b_q : std_ulogic_vector(7 downto 0);
  SIGNAL buf_data1_a_d : std_ulogic_vector(63 downto 0);
  SIGNAL buf_data1_a_q : std_ulogic_vector(63 downto 0);
  SIGNAL buf_data1_ecc_a_d : std_ulogic_vector(7 downto 0);
  SIGNAL buf_data1_ecc_a_q : std_ulogic_vector(7 downto 0);
  SIGNAL buf_data1_b_d : std_ulogic_vector(63 downto 0);
  SIGNAL buf_data1_b_q : std_ulogic_vector(63 downto 0);
  SIGNAL buf_data1_ecc_b_d : std_ulogic_vector(7 downto 0);
  SIGNAL buf_data1_ecc_b_q : std_ulogic_vector(7 downto 0);
  SIGNAL buf_data_taken_d : std_ulogic;
  SIGNAL buf_data_taken_q : std_ulogic;
  SIGNAL tmpl_valid : std_ulogic;
  SIGNAL flit_credit_str_max : std_ulogic;
  SIGNAL flit_credit_str_q : std_ulogic_vector(6 downto 0);
  SIGNAL flit_credit_str_d : std_ulogic_vector(6 downto 0);
  SIGNAL flit_credit_str_p_d : std_ulogic;
  SIGNAL flit_credit_str_p_q : std_ulogic;
  SIGNAL data_bts_sent_inc : std_ulogic;
  SIGNAL data_bts_sent_q : std_ulogic_vector(1 downto 0);
  SIGNAL data_bts_sent_d : std_ulogic_vector(1 downto 0);
  SIGNAL mstr_cnt_max_d : std_ulogic_vector(5 downto 0);
  SIGNAL mstr_cnt_max_q : std_ulogic_vector(5 downto 0);
  SIGNAL mstr_cnt_data_run_len : std_ulogic_vector(3 downto 0);
  SIGNAL tlxt_rdf_data_taken_int : std_ulogic;
  SIGNAL eccgen_pchk : std_ulogic_vector(1 downto 0);
  SIGNAL lbip_top_p : std_ulogic_vector(10 downto 8);
  signal act_hi_lat_mode : std_ulogic;
  signal act_low_lat_mode : std_ulogic;
  SIGNAL flit_credit_avail_flit_arb_d : std_ulogic;
  SIGNAL flit_credit_avail_flit_arb_q : std_ulogic;
  SIGNAL flit_credit_avail_ctrl_d : std_ulogic;
  SIGNAL flit_credit_avail_ctrl_q : std_ulogic;
  SIGNAL flit_credit_avail_ctrl_a_d : std_ulogic;
  SIGNAL flit_credit_avail_ctrl_a_q : std_ulogic;
  SIGNAL flit_credit_avail_ctrl_b_d : std_ulogic;
  SIGNAL flit_credit_avail_ctrl_b_q : std_ulogic;
  SIGNAL flit_credit_avail_flit_vld_d : std_ulogic;
  SIGNAL flit_credit_avail_flit_vld_q : std_ulogic;
  SIGNAL tlxt_srq_rdbuf_pop_d : std_ulogic;
  SIGNAL tlxt_srq_rdbuf_pop_q : std_ulogic;
  SIGNAL tlxt_dlx_flit_early_vld_a_d : std_ulogic;
  SIGNAL tlxt_dlx_flit_early_vld_a_q : std_ulogic;
  SIGNAL tlxt_dlx_flit_early_vld_b_d : std_ulogic;
  SIGNAL tlxt_dlx_flit_early_vld_b_q : std_ulogic;
  SIGNAL flit_xmit_done_int : std_ulogic;
  signal mstr_cnt_update : std_ulogic;
  SIGNAL tmplB : std_ulogic;
  SIGNAL tmplB_data : std_ulogic;
  SIGNAL err_inj0 : std_ulogic;
  SIGNAL err_inj1 : std_ulogic;
  SIGNAL cfei_bit0_d : std_ulogic;
  SIGNAL cfei_bit0_q : std_ulogic;
  SIGNAL cfei_bit1_q : std_ulogic;
  SIGNAL cfei_bit1_d : std_ulogic;
  SIGNAL cfei_bit0_single_rdy_d : std_ulogic;
  SIGNAL cfei_bit0_single_rdy_q : std_ulogic;
  SIGNAL cfei_bit1_single_rdy_q : std_ulogic;
  SIGNAL cfei_bit1_single_rdy_d : std_ulogic;
  SIGNAL cfei_bit0_single_inj : std_ulogic;
  SIGNAL cfei_bit1_single_inj : std_ulogic;
  SIGNAL cfei_bit0_edge : std_ulogic;
  SIGNAL cfei_bit1_edge : std_ulogic;
  SIGNAL use_rdf_data_a_d : std_ulogic;
  SIGNAL use_rdf_data_a_q : std_ulogic;
  SIGNAL use_tlxt_egen_a_d : std_ulogic;
  SIGNAL use_tlxt_egen_a_q : std_ulogic;
  SIGNAL use_buf_data0_a_d : std_ulogic;
  SIGNAL use_buf_data0_a_q : std_ulogic;
  SIGNAL use_buf_data1_a_d : std_ulogic;
  SIGNAL use_buf_data1_a_q : std_ulogic;
  SIGNAL use_rdf_data_b_d : std_ulogic;
  SIGNAL use_rdf_data_b_q : std_ulogic;
  SIGNAL use_tlxt_egen_b_d : std_ulogic;
  SIGNAL use_tlxt_egen_b_q : std_ulogic;
  SIGNAL use_buf_data0_b_d : std_ulogic;
  SIGNAL use_buf_data0_b_q : std_ulogic;
  SIGNAL use_buf_data1_b_d : std_ulogic;
  SIGNAL use_buf_data1_b_q : std_ulogic;
  SIGNAL tlxt_dlx_flit_data_a : std_ulogic_vector(63 downto 0);
  SIGNAL tlxt_dlx_flit_data_b : std_ulogic_vector(63 downto 0);
  SIGNAL tlxt_dlx_flit_ecc_a : std_ulogic_vector(7 downto 0);
  SIGNAL tlxt_dlx_flit_ecc_b : std_ulogic_vector(7 downto 0);
  SIGNAL pull_buf_data0_d : std_ulogic;
  SIGNAL pull_buf_data0_q : std_ulogic;
  SIGNAL pull_buf_data1_d : std_ulogic;
  SIGNAL pull_buf_data1_q : std_ulogic;
  SIGNAL pull_buf_data0_a_d : std_ulogic;
  SIGNAL pull_buf_data0_a_q : std_ulogic;
  SIGNAL pull_buf_data1_a_d : std_ulogic;
  SIGNAL pull_buf_data1_a_q : std_ulogic;
  SIGNAL pull_buf_data0_b_d : std_ulogic;
  SIGNAL pull_buf_data0_b_q : std_ulogic;
  SIGNAL pull_buf_data1_b_d : std_ulogic;
  SIGNAL pull_buf_data1_b_q : std_ulogic;
  SIGNAL tlxt_dlx_pchk_d : std_ulogic_vector(1 downto 0);
  SIGNAL tlxt_dlx_pchk_q : std_ulogic_vector(1 downto 0);
  SIGNAL tlxt_dlx_flit_data_egen_out : std_ulogic_vector(127 downto 0);
  SIGNAL buf_data0_valid_q : std_ulogic;
  SIGNAL buf_data0_valid_d : std_ulogic;
  SIGNAL buf_data1_valid_d : std_ulogic;
  SIGNAL buf_data1_valid_q : std_ulogic;
  SIGNAL buf_data0_valid_a_q : std_ulogic;
  SIGNAL buf_data0_valid_a_d : std_ulogic;
  SIGNAL buf_data1_valid_a_d : std_ulogic;
  SIGNAL buf_data1_valid_a_q : std_ulogic;
  SIGNAL buf_data0_valid_b_q : std_ulogic;
  SIGNAL buf_data0_valid_b_d : std_ulogic;
  SIGNAL buf_data1_valid_b_d : std_ulogic;
  SIGNAL buf_data1_valid_b_q : std_ulogic;
  SIGNAL load_buf_data0_d : std_ulogic;
  SIGNAL load_buf_data0_q : std_ulogic;
  SIGNAL load_buf_data1_d : std_ulogic;
  SIGNAL load_buf_data1_q : std_ulogic;
  SIGNAL load_buf_data0_a_d : std_ulogic;
  SIGNAL load_buf_data0_a_q : std_ulogic;
  SIGNAL load_buf_data1_a_d : std_ulogic;
  SIGNAL load_buf_data1_a_q : std_ulogic;
  SIGNAL load_buf_data0_b_d : std_ulogic;
  SIGNAL load_buf_data0_b_q : std_ulogic;
  SIGNAL load_buf_data1_b_d : std_ulogic;
  SIGNAL load_buf_data1_b_q : std_ulogic;
  SIGNAL hi_lat_mode : std_ulogic;
  SIGNAL drl_valid : std_ulogic;
  SIGNAL use_rdf_data_ctrl_d : std_ulogic;
  SIGNAL use_rdf_data_ctrl_q : std_ulogic;
  SIGNAL flit_credit_underflow_d : std_ulogic;
  SIGNAL flit_credit_underflow_q : std_ulogic;
  SIGNAL flit_credit_overflow_q : std_ulogic;
  SIGNAL flit_credit_overflow_d : std_ulogic;


begin -- cb_tlxt_trans_arb

  --clock gates
  act <= '1';
  act_hi_lat_mode <= not low_lat_mode or tlxt_clk_gate_dis;
  act_low_lat_mode <= low_lat_mode or tlxt_clk_gate_dis;
  tidn(127 downto 0) <= (others =>  '0');

  ---------------------------------------------------------------------------
  -- template information
  ---------------------------------------------------------------------------
  tmpl0 <= (dl_cont_tl_tmpl="000000");
  tmpl1 <= (dl_cont_tl_tmpl="000001");
  tmpl5 <= (dl_cont_tl_tmpl="000101");
  tmpl9 <= (dl_cont_tl_tmpl="001001");
  tmplB <= (dl_cont_tl_tmpl="001011");

  tmpl_valid <= tmpl0 or tmpl1 or tmpl5 or tmpl9 or tmplB;

  hi_lat_mode <= NOT low_lat_mode AND NOT half_dimm_mode;

  ---------------------------------------------------------------------------
  -- Flit credit
  ---------------------------------------------------------------------------
  --Store multiple flit credits to generate valid
  dlx_flit_credit_inc                 <= dlx_tlxt_flit_credit and dlx_tlxr_link_up;
  flit_credit_str_max                 <= (flit_credit_str_q(6 downto 0)="1111111");
  flit_credit_str_d(6 downto 0)       <= gate(flit_credit_str_q(6 downto 0) + "0000001",                 dlx_flit_credit_inc and not mstr_cnt_inc and not flit_credit_str_max) OR
                                         gate(flit_credit_str_q(6 downto 0) - "0000001",             not dlx_flit_credit_inc and mstr_cnt_inc) OR
                                         gate(flit_credit_str_q(6 downto 0),                             dlx_flit_credit_inc  =  mstr_cnt_inc);
  flit_credit_str_p_d                 <= ((INCP(flit_credit_str_q(6 downto 0)) xor flit_credit_str_p_q    ) and     dlx_flit_credit_inc and not mstr_cnt_inc and not flit_credit_str_max)
                                         or ((INCP(not flit_credit_str_q(6 downto 0)) xor flit_credit_str_p_q) and not dlx_flit_credit_inc and mstr_cnt_inc)
                                         or (flit_credit_str_p_q                                               and     dlx_flit_credit_inc  =  mstr_cnt_inc);

  flit_credit_avail_flit_vld_d                 <=     ('1'                                        AND             dlx_flit_credit_inc and not mstr_cnt_inc and not flit_credit_str_max) OR
                                                      ((flit_credit_str_q(6 downto 0)>"0000001")  AND         not dlx_flit_credit_inc and mstr_cnt_inc) OR
                                                      ((flit_credit_str_q(6 downto 0)>"0000000")  AND             dlx_flit_credit_inc  =  mstr_cnt_inc);
  flit_credit_avail_ctrl_d                 <=     ('1'                                        AND             dlx_flit_credit_inc and not mstr_cnt_inc and not flit_credit_str_max) OR
                                                  ((flit_credit_str_q(6 downto 0)>"0000001")  AND         not dlx_flit_credit_inc and mstr_cnt_inc) OR
                                                  ((flit_credit_str_q(6 downto 0)>"0000000")  AND             dlx_flit_credit_inc  =  mstr_cnt_inc);

  flit_credit_avail_ctrl_a_d                 <=     ('1'                                        AND             dlx_flit_credit_inc and not mstr_cnt_inc and not flit_credit_str_max) OR
                                                    ((flit_credit_str_q(6 downto 0)>"0000001")  AND         not dlx_flit_credit_inc and mstr_cnt_inc) OR
                                                    ((flit_credit_str_q(6 downto 0)>"0000000")  AND             dlx_flit_credit_inc  =  mstr_cnt_inc);

  flit_credit_avail_ctrl_b_d                 <=     ('1'                                        AND             dlx_flit_credit_inc and not mstr_cnt_inc and not flit_credit_str_max) OR
                                                    ((flit_credit_str_q(6 downto 0)>"0000001")  AND         not dlx_flit_credit_inc and mstr_cnt_inc) OR
                                                    ((flit_credit_str_q(6 downto 0)>"0000000")  AND             dlx_flit_credit_inc  =  mstr_cnt_inc);

  flit_credit_avail_flit_arb_d                 <=     ('1'                                        AND             dlx_flit_credit_inc and not mstr_cnt_inc and not flit_credit_str_max) OR
                                                       ((flit_credit_str_q(6 downto 0)>"0000001")  AND         not dlx_flit_credit_inc and mstr_cnt_inc) OR
                                                       ((flit_credit_str_q(6 downto 0)>"0000000")  AND             dlx_flit_credit_inc  =  mstr_cnt_inc);
  trans_arb_perrors(1) <= XOR_REDUCE( flit_credit_str_q & flit_credit_str_p_q );

  --use returned credit on same cycle.
  flit_credit_avail           <= flit_credit_avail_flit_arb_q;
  --flit credit store errors
  flit_credit_underflow_d <= (flit_credit_str_q="0000000") and (flit_credit_str_d="1111111");
  flit_credit_underflow <= flit_credit_underflow_q;

  flit_credit_overflow_d <= (flit_credit_str_q="1111111") and (flit_credit_str_d="0000000");
  flit_credit_overflow <= flit_credit_overflow_q;
  ---------------------------------------------------------------------------
  -- master counter
  ---------------------------------------------------------------------------
  --hold the max value if the state machine is active, reset when the count is 0
  mstr_cnt_max_d(5 downto 0) <= gate("000011",                                          link_up_pulse or mstr_cnt_start) or
                                gate("000011" + (dl_cont_data_run_len &"00"),           mstr_cnt_update) or
                                gate(mstr_cnt_max_q(5 downto 0),                        not (mstr_cnt_start or mstr_cnt_update));


  mstr_cnt_data_run_len(3 downto 0) <= mstr_cnt_max_q(5 downto 2);

  mstr_cnt_reset <= (mstr_cnt_q=mstr_cnt_max_q) and flit_credit_avail_flit_vld_q;
  mstr_cnt_start <= (mstr_cnt_q(5 downto 0)="000000") and flit_xmit_start;
  mstr_cnt_update <= flit_part_last_vld;
  mstr_cnt_inc   <= flit_credit_avail_flit_vld_q and (mstr_cnt_start or (mstr_cnt_q/="000000"));
  mstr_cnt_hold  <= not flit_credit_avail_flit_vld_q;
  mstr_cnt_d(5 downto 0) <= gate("000000",                    mstr_cnt_reset) or --MR_ADD init => "00000"
                            gate((mstr_cnt_q + "000001"),     not mstr_cnt_reset and mstr_cnt_inc) OR
                            gate(mstr_cnt_q,                  not mstr_cnt_reset and mstr_cnt_hold);
  mstr_cnt_p_d           <= ('0'                                 and  mstr_cnt_reset)    --MR_ADD init => "0"
                            or ((INCP(mstr_cnt_q) xor mstr_cnt_p_q) and  not mstr_cnt_reset and mstr_cnt_inc)
                            or (mstr_cnt_p_q                        and  not mstr_cnt_reset and mstr_cnt_hold);

  trans_arb_perrors(2) <= XOR_REDUCE( mstr_cnt_q & mstr_cnt_p_q );

  ---------------------------------------------------------------------------
  -- output control
  ---------------------------------------------------------------------------
  --first two beats for tmpl9 data. Anything past control flit for tmpl 0,1,5
  tmpl9_data     <= flit_credit_avail_ctrl_q and (tmpl9 and (tmpl9_data_val and not mmio_data_val) and (mstr_cnt_start or (mstr_cnt_q = "000001")));

  -- tmplB_data is for 3 beats.
  tmplB_data     <= flit_credit_avail_ctrl_q and (tmplB and (tmplB_data_val and not mmio_data_val) and (mstr_cnt_start or (mstr_cnt_q = "000001" or mstr_cnt_q="000010")));

  data_flit      <= flit_credit_avail_ctrl_q and (mstr_cnt_q>"000011");

  --Control state when flit part is valid from
  ctrl           <= flit_credit_avail_ctrl_q and flit_part_vld and
                    (
                      ((tmpl0 or tmpl1 or tmpl5 or ((tmpl9 or tmplB) and mmio_data_val)) and (mstr_cnt_start or (mstr_cnt_q = "000001"))) OR
                      (tmpl_valid and (mstr_cnt_q = "000010") and flit_part_last_vld)
                    );
  --control flit last beat always count 3
  ctrl_last      <= flit_credit_avail_ctrl_q and (mstr_cnt_q = "000011");

  -- ECC gen on flit_part/flit_part_last, which don't arrive with ECC already attached
  -- 143:128 are parity.
  -- For timing reasons, use simple mux control here, and qualify output of ECC gen later. Note that flit_part_last_full is a latch.

  tlxt_dlx_flit_data_egen(143 downto 0) <= gate(flit_part_p           & flit_part,           (mstr_cnt_q /= "000011")    )
                                           or gate(flit_part_last_full_p & flit_part_last_full, (mstr_cnt_q  = "000011") );

  G_EGEN: for i in 1 downto 0 generate
    signal d_m_unused : std_ulogic;
    attribute ANALYSIS_NOT_REFERENCED of d_m_unused:signal is "TRUE";
  begin

    EGEN: entity work.mc_8beccg_comp port map (
      data_in(0 to 63)   => tlxt_dlx_flit_data_egen(i*64+63 downto i*64)
      , data_in(64)        => '0'
      , err_inj0           => err_inj0
      , err_inj1           => err_inj1
      , derr_in            => '0'
      , data_out(0 to 63)  => tlxt_dlx_flit_data_egen_out(i*64+63 downto i*64)
      , data_out(64)       => d_m_unused
      , data_out(65 to 72) => tlxt_dlx_flit_ecc_egen(i*8+7 downto i*8)
      , vdd                => vdd
      , gnd                => gnd );

  end generate G_EGEN;

  tlxt_dlx_flit_par_d(15 downto 0)      <= tlxt_dlx_flit_data_egen(143 downto 128);

  tlxt_dlx_flit_par_vld_d(1 downto 0)   <= use_tlxt_egen_a_q & use_tlxt_egen_b_q; 

  -- Parity check on flit_part/flit_part_last, which don't arrive with ECC already attached
  -- Moved to after the latching, for timing reasons

  tlxt_dlx_flit_data_perror <= tlxt_dlx_flit_par_q(15 downto 0) xor not GENPARITY(tlxt_dlx_flit_data_q(127 downto 0));
  tlxt_dlx_pchk_d      <= (OR_REDUCE(tlxt_dlx_flit_data_perror(15 downto 8)) and tlxt_dlx_flit_par_vld_q(1))
                       &  (OR_REDUCE(tlxt_dlx_flit_data_perror( 7 downto 0)) and tlxt_dlx_flit_par_vld_q(0));
  trans_arb_perrors(4) <= OR_REDUCE(tlxt_dlx_pchk_q);

  -- Checker provides coverage over ECC generation logic, and detects some incoming parity errors.
  -- (Note: this works because each data bit feeds into an odd number of check bits, by ecc code design)

  G_ECHK: for i in 1 downto 0 generate
    eccgen_pchk(i) <= XOR_REDUCE(tlxt_dlx_flit_ecc_q(i*8+7 downto i*8))   -- Parity of ECC bits
                  xor XOR_REDUCE(tlxt_dlx_flit_par_q(i*8+7 downto i*8));  -- Should match parity of data
  end generate G_ECHK;

  trans_arb_perrors(0) <= OR_REDUCE(eccgen_pchk and tlxt_dlx_flit_par_vld_q);

  flit_part_last_full(127 downto 0) <= tidn(127 downto 82) & tlxt_dlx_flit_lbip_data_q;
  flit_part_last_full_p(15 downto 0)<= "00000" & tlxt_dlx_flit_lbip_data_p_q;
  tlxt_dlx_flit_vld_d               <= mstr_cnt_inc;

  tlxt_dlx_flit_early_vld_a_d <= ((flit_xmit_start_early or mstr_cnt_start or ((mstr_cnt_q<=(mstr_cnt_max_q)) and or_reduce(mstr_cnt_d))) and flit_credit_avail_flit_vld_d) or (tlxt_dlx_flit_early_vld_a_q and not flit_credit_avail_flit_vld_q);

  tlxt_dlx_flit_early_vld_b_d <= ((flit_xmit_start_early or mstr_cnt_start or ((mstr_cnt_q<=(mstr_cnt_max_q)) and or_reduce(mstr_cnt_d))) and flit_credit_avail_flit_vld_d) or (tlxt_dlx_flit_early_vld_b_q and not flit_credit_avail_flit_vld_q);

  tlxt_dlx_flit_lbip_vld_d <= (mstr_cnt_q="000010") and flit_credit_avail_flit_vld_q;

  lbip_top_p <= XOR_REDUCE( dl_cont_tl_tmpl_p & dl_cont_tl_tmpl(3 downto 0)                        )  -- 10 even over 81:80
                & XOR_REDUCE( dl_cont_tl_tmpl_p & dl_cont_tl_tmpl(5 downto 4) & dl_cont_bdi_vec_p(1) )  --  9 even over 79:72
                & XOR_REDUCE( dl_cont_bdi_vec_p(0)        & dl_cont_data_run_len(3 downto 0)        ); --  8 even over 71:64

  tlxt_dlx_flit_lbip_data_d(81 downto 0) <= gate(dl_cont_tl_tmpl & dl_cont_bdi_vec & dl_cont_data_run_len & flit_part_last,   ctrl) OR
                                            gate(tlxt_dlx_flit_lbip_data_q,                                                   not flit_credit_avail_flit_vld_q);
  tlxt_dlx_flit_lbip_data_p_d(10 downto 0)<=gate(lbip_top_p & flit_part_last_p(7 downto 0),                                   ctrl) OR
                                             gate(tlxt_dlx_flit_lbip_data_p_q,                                                 not flit_credit_avail_flit_vld_q);

  tlxt_dlx_flit_data      <= tlxt_dlx_flit_data_q(127 downto 0);
  tlxt_dlx_flit_ecc       <= tlxt_dlx_flit_ecc_q(15 downto 0);
  tlxt_dlx_flit_vld       <= tlxt_dlx_flit_vld_q;
  tlxt_dlx_flit_early_vld_a <= tlxt_dlx_flit_early_vld_a_q;
  tlxt_dlx_flit_early_vld_b <= tlxt_dlx_flit_early_vld_b_q;
  tlxt_dlx_flit_lbip_data <= tlxt_dlx_flit_lbip_data_q(81 downto 0);
  tlxt_dlx_flit_lbip_vld  <= tlxt_dlx_flit_lbip_vld_q;


  tlxt_rdf_data_taken_int <= use_rdf_data_ctrl_q or str_rdf_data or (hi_lat_mode and (pull_buf_data0_q or pull_buf_data1_q));
  tlxt_rdf_data_taken <= tlxt_rdf_data_taken_int;

  data_xmit <= data_flit or tmpl9_data or tmplB_data;
  data_flit_xmit <= (mstr_cnt_q>"000010") AND (mstr_cnt_q<mstr_cnt_max_q) and or_reduce(mstr_cnt_data_run_len);

  flit_xmit_done_int <= (mstr_cnt_q(1 downto 0)="11") and flit_credit_avail_flit_arb_q;
  flit_xmit_done <= flit_xmit_done_int;
  flit_xmit_early_done <= (mstr_cnt_q(1 downto 0)="10") and flit_credit_avail_flit_arb_q;

  data_valid <= rdf_tlxt_data_valid or buf_data1_valid_q OR buf_data0_valid_q;

  --latch prevent invalid gating when mmio data val is on
  use_rdf_data_ctrl_d <= flit_credit_avail_ctrl_d and
                         (
                           ((mstr_cnt_d="000000") and flit_credit_avail_ctrl_d and flit_xmit_start_early and (tmpl9_data_val or tmplB_data_val) and not buf_data0_valid_q) or
                           ((mstr_cnt_d="000001") and (tmpl9_data_val or tmplB_data_val) and not buf_data1_valid_q) or
                           ((mstr_cnt_d="000010") and tmplB_data_val) or
                           ((mstr_cnt_d>"000011") and NOT (mmio_data_flit_early or (rd_resp_len32_flit_early and buf_data1_valid_q)))
                         );

  ------------------------------------------------------------------------------------------------
  -- Generate tlxt_srq_rd_buf_pop
  ------------------------------------------------------------------------------------------------
  data_bts_sent_inc   <= (
                           tlxt_rdf_data_taken_int OR
                           (ctrl_last AND or_reduce(data_bts_sent_q) AND half_dimm_mode)
                         );
  data_bts_sent_d(1 downto 0) <= gate(data_bts_sent_q(1 downto 0) + "01",        data_bts_sent_inc) OR
                                 gate(data_bts_sent_q(1 downto 0),           not data_bts_sent_inc);


  tlxt_srq_rdbuf_pop_d <= (data_bts_sent_q(1 downto 0)="11") and data_bts_sent_inc;
  tlxt_srq_rdbuf_pop <= tlxt_srq_rdbuf_pop_q;

  ---------------------------------------------------------------------------
  -- 2 16B data buffers in series for single template 9 reads and steady state temp9 reads
  ---------------------------------------------------------------------------
  buf_data_taken_d <= (not buf_data_taken_q and pull_buf_data0_q) OR
                      (    buf_data_taken_q and (mstr_cnt_q<"000011"));

  drl_valid <= or_reduce(mstr_cnt_data_run_len) OR or_reduce(dl_cont_data_run_len);
  --------------------------------------------------------------------------------------------------
  -- Might need a/b duplication for timing
  --------------------------------------------------------------------------------------------------
  --control internal logic and source signal to RDF
  load_buf_data0_d <= flit_credit_avail_ctrl_d AND
                        (
                          (low_lat_mode AND( mstr_cnt_d="000010") AND drl_valid AND NOT buf_data_taken_q AND or_reduce(data_bts_sent_d)) OR
                          (hi_lat_mode AND (mstr_cnt_d="000010")  AND tmpl9_data_val)or
                          (hi_lat_mode and rd_resp_len32_flit_early and not buf_data0_valid_q and not buf_data1_valid_q)
                        );

  load_buf_data1_d <= flit_credit_avail_ctrl_d AND
                        (
                          (low_lat_mode AND(mstr_cnt_d="000011") AND drl_valid AND NOT buf_data_taken_q AND or_reduce(data_bts_sent_d)) OR
                          (hi_lat_mode AND (mstr_cnt_d="000011") AND or_reduce(data_bts_sent_d)) or
                          (hi_lat_mode and rd_resp_len32_flit_early and buf_data0_valid_q and not buf_data1_valid_q)
                        );

--control a/b data buffers
  load_buf_data0_a_d <= flit_credit_avail_ctrl_a_d AND
                        (
                          (low_lat_mode AND( mstr_cnt_d="000010") AND drl_valid AND NOT buf_data_taken_q AND or_reduce(data_bts_sent_d)) OR
                          (hi_lat_mode AND (mstr_cnt_d="000010")  AND tmpl9_data_val) or
                          (hi_lat_mode and rd_resp_len32_flit_early and not buf_data0_valid_a_q and not buf_data1_valid_a_q)
                        );

  load_buf_data1_a_d <= flit_credit_avail_ctrl_a_d AND
                        (
                          (low_lat_mode AND(mstr_cnt_d="000011") AND drl_valid AND NOT buf_data_taken_q AND or_reduce(data_bts_sent_d)) OR
                          (hi_lat_mode AND (mstr_cnt_d="000011") AND or_reduce(data_bts_sent_d)) or
                          (hi_lat_mode and rd_resp_len32_flit_early and buf_data0_valid_a_q and not buf_data1_valid_a_q)
                        );

  load_buf_data0_b_d <= flit_credit_avail_ctrl_b_d AND
                        (
                          (low_lat_mode AND( mstr_cnt_d="000010") AND drl_valid AND NOT buf_data_taken_q AND or_reduce(data_bts_sent_d)) OR
                          (hi_lat_mode AND (mstr_cnt_d="000010")  AND tmpl9_data_val) or
                          (hi_lat_mode and rd_resp_len32_flit_early and not buf_data0_valid_b_q and not buf_data1_valid_b_q)
                        );

  load_buf_data1_b_d <= flit_credit_avail_ctrl_b_d AND
                        (
                          (low_lat_mode AND(mstr_cnt_d="000011") AND drl_valid AND NOT buf_data_taken_q AND or_reduce(data_bts_sent_d)) OR
                          (hi_lat_mode AND (mstr_cnt_d="000011") and or_reduce(data_bts_sent_d)) or
                          (hi_lat_mode and rd_resp_len32_flit_early and buf_data0_valid_b_q and not buf_data1_valid_b_q)
                        );
  --control internal logic
  buf_data0_valid_d <= (load_buf_data0_d and not (hi_lat_mode and not rd_resp_len32_flit_early)) OR
                       (buf_data0_valid_q and NOT pull_buf_data0_d);
  buf_data1_valid_d <= (load_buf_data1_d  and not (hi_lat_mode and not rd_resp_len32_flit_early)) OR
                       (buf_data1_valid_q and NOT pull_buf_data1_d);

  --control a/b side dataflow
  buf_data0_valid_a_d <= (load_buf_data0_a_d and not (hi_lat_mode and not rd_resp_len32_flit_early)) OR
                         (buf_data0_valid_a_q and NOT pull_buf_data0_a_d);
  buf_data1_valid_a_d <= (load_buf_data1_a_d and not (hi_lat_mode and not rd_resp_len32_flit_early)) OR
                         (buf_data1_valid_a_q and NOT pull_buf_data1_a_d);

  buf_data0_valid_b_d <= (load_buf_data0_b_d and not (hi_lat_mode and not rd_resp_len32_flit_early)) OR
                         (buf_data0_valid_b_q and NOT pull_buf_data0_b_d);
  buf_data1_valid_b_d <= (load_buf_data1_b_d and not (hi_lat_mode and not rd_resp_len32_flit_early)) OR
                         (buf_data1_valid_b_q and NOT pull_buf_data1_b_d);

  str_rdf_data <= load_buf_data1_q OR load_buf_data0_q;

  --------------------------------------------------------------------------------------------------
  --control internal logic
  pull_buf_data0_d <= flit_credit_avail_ctrl_d AND buf_data0_valid_q AND
                      (
                        (low_lat_mode AND (mstr_cnt_d="000000") and tmpl9_data_val) OR
                        (hi_lat_mode and rd_resp_len32_flit_early and buf_data0_valid_q and buf_data1_valid_q)
                      );

  pull_buf_data1_d <= flit_credit_avail_ctrl_d AND buf_data1_valid_q AND
                      (
                        (low_lat_mode AND (mstr_cnt_d="000001") and  tmpl9_data_val) OR
                        (hi_lat_mode and rd_resp_len32_flit_early and not buf_data0_valid_q and buf_data1_valid_q)
                      );

--control a/b dataflow
  pull_buf_data0_a_d <= flit_credit_avail_ctrl_a_d AND buf_data0_valid_a_q AND
                      (
                        (low_lat_mode AND (mstr_cnt_d="000000") and tmpl9_data_val) OR
                        (hi_lat_mode and rd_resp_len32_flit_early and buf_data0_valid_a_q and buf_data1_valid_a_q)
                      );

  pull_buf_data1_a_d <= flit_credit_avail_ctrl_a_d AND buf_data1_valid_a_q AND
                      (
                        (low_lat_mode AND (mstr_cnt_d="000001") and  tmpl9_data_val) OR
                        (hi_lat_mode and rd_resp_len32_flit_early and not buf_data0_valid_a_q and buf_data1_valid_a_q)
                      );

  pull_buf_data0_b_d <= flit_credit_avail_ctrl_b_d AND buf_data0_valid_b_q AND
                      (
                        (low_lat_mode AND (mstr_cnt_d="000000") and tmpl9_data_val) OR
                        (hi_lat_mode and rd_resp_len32_flit_early and buf_data0_valid_b_q and buf_data1_valid_b_q)
                      );

  pull_buf_data1_b_d <= flit_credit_avail_ctrl_b_d AND buf_data1_valid_b_q AND
                      (
                        (low_lat_mode AND (mstr_cnt_d="000001") and  tmpl9_data_val) OR
                        (hi_lat_mode and rd_resp_len32_flit_early and not buf_data0_valid_b_q and buf_data1_valid_b_q)
                      );
  --a
  buf_data0_a_d(63 downto 0)   <= gate(rdf_tlxt_data(127 downto 64),         load_buf_data0_a_q) OR
                                  gate(buf_data0_a_q(63 DOWNTO 0),       not load_buf_data0_a_q);

  buf_data0_ecc_a_d(7 downto 0) <= gate(rdf_tlxt_data_ecc(15 downto 8),      load_buf_data0_a_q) OR
                                   gate(buf_data0_ecc_a_q(7 downto 0),   not load_buf_data0_a_q);

  buf_data1_a_d(63 downto 0)   <= gate(rdf_tlxt_data(127 downto 64),         load_buf_data1_a_q) OR
                                  gate(buf_data1_a_q(63 downto 0),       not load_buf_data1_a_q);

  buf_data1_ecc_a_d(7 downto 0) <= gate(rdf_tlxt_data_ecc(15 downto 8),      load_buf_data1_a_q) OR
                                   gate(buf_data1_ecc_a_q(7 downto 0),   not load_buf_data1_a_q);


  --b
  buf_data0_b_d(63 downto 0)   <= gate(rdf_tlxt_data(63 downto 0),          load_buf_data0_b_q) OR
                                  gate(buf_data0_b_q(63 downto 0),      not load_buf_data0_b_q);

  buf_data0_ecc_b_d(7 downto 0) <= gate(rdf_tlxt_data_ecc(7 downto 0),      load_buf_data0_b_q) OR
                                   gate(buf_data0_ecc_b_q(7 downto 0),  not load_buf_data0_b_q);

  buf_data1_b_d(63 downto 0)   <= gate(rdf_tlxt_data(63 downto 0),          load_buf_data1_b_q) OR
                                  gate(buf_data1_b_q(63 downto 0),      not load_buf_data1_b_q);

  buf_data1_ecc_b_d(7 downto 0) <= gate(rdf_tlxt_data_ecc(7 downto 0),      load_buf_data1_b_q) OR
                                   gate(buf_data1_ecc_b_q(7 downto 0),  not load_buf_data1_b_q);

  trans_arb_perrors(3) <= '0';
  
  --------------------------------------------------------------------------------------------------
  -- Timing Restructure of data path
  --------------------------------------------------------------------------------------------------

  --generate a side mux selects. tlxt data (127 downto 64)/ rdf data (0 to 63)
  use_tlxt_egen_a_d <= ((mstr_cnt_d="000000") and flit_credit_avail_ctrl_a_d and flit_xmit_start_early and ((mmio_data_val and (tmpl9 or tmplB)) or not (tmpl9 or tmplB))) or              --first beat dependent on data
                       ((mstr_cnt_d="000001") and ((mmio_data_val and (tmpl9 or tmplB)) or not (tmpl9 or tmplB))) or              --second beat dependent on data
                       (mstr_cnt_d="000010") or  --third beat always
                       (mstr_cnt_d="000011") or
                       ((mstr_cnt_d>"000011") and mmio_data_flit_early);

  use_rdf_data_a_d <= ((mstr_cnt_d="000000") and flit_credit_avail_ctrl_a_d and flit_xmit_start_early and (tmpl9_data_val or tmplB_data_val) and not buf_data0_valid_a_q) or
                      ((mstr_cnt_d="000001") and (tmpl9_data_val or tmplB_data_val) and not buf_data1_valid_a_q) or
                      ((mstr_cnt_d>"000011") and not (mmio_data_flit_early or (rd_resp_len32_flit_early and buf_data1_valid_a_q)));

  use_buf_data0_a_d <= (low_lat_mode AND buf_data0_valid_a_q AND (mstr_cnt_d="000000") and tmpl9_data_val) OR
                       (hi_lat_mode and rd_resp_len32_flit_early and buf_data0_valid_a_q and buf_data1_valid_a_q);

  use_buf_data1_a_d <= (low_lat_mode AND buf_data1_valid_a_q AND (mstr_cnt_d="000001") and tmpl9_data_val) or
                       (hi_lat_mode and rd_resp_len32_flit_early and not buf_data0_valid_a_q and buf_data1_valid_a_q);

  --Generate b side mux selects. tlxt data (63 downto 0)/rdf data (64 to 127)

  use_tlxt_egen_b_d <= ((mstr_cnt_d="000000") and flit_credit_avail_ctrl_b_d and flit_xmit_start_early and ((mmio_data_val and (tmpl9 or tmplB)) or not (tmpl9 or tmplB))) or              --first beat dependent on data
                       ((mstr_cnt_d="000001") and ((mmio_data_val and (tmpl9 or tmplB)) or not (tmpl9 or tmplB))) or              --second beat dependent on data
                       ((mstr_cnt_d="000010") and not tmplB_data_val) or  --third beat always
                       (mstr_cnt_d="000011") or
                       ((mstr_cnt_d>"000011") and     mmio_data_flit_early);  --fourth beat always 

  use_rdf_data_b_d <= ((mstr_cnt_d="000000") and flit_credit_avail_ctrl_b_d and flit_xmit_start_early and (tmpl9_data_val or tmplB_data_val) and not buf_data0_valid_b_q) or
                      ((mstr_cnt_d="000001") and (tmpl9_data_val or tmplB_data_val) and not buf_data1_valid_b_q) or
                      ((mstr_cnt_d="000010") and tmplB_data_val) or
                      ((mstr_cnt_d>"000011") and NOT (mmio_data_flit_early or (rd_resp_len32_flit_early and buf_data1_valid_b_q)));

  use_buf_data0_b_d <= (low_lat_mode AND buf_data0_valid_b_q AND (mstr_cnt_d="000000") and tmpl9_data_val) OR
                       (hi_lat_mode and rd_resp_len32_flit_early and buf_data0_valid_b_q and buf_data1_valid_b_q);

  use_buf_data1_b_d <= (low_lat_mode AND buf_data1_valid_b_q AND (mstr_cnt_d="000001") and tmpl9_data_val) OR
                       (hi_lat_mode and rd_resp_len32_flit_early and not buf_data0_valid_b_q and buf_data1_valid_b_q);

  --side a mux

  tlxt_dlx_flit_data_a <= gate(tlxt_dlx_flit_data_egen_out(127 downto 64),  use_tlxt_egen_a_q) or
                          gate(rdf_tlxt_data(127 downto 64),            use_rdf_data_a_q) or
                          gate(buf_data0_a_q(63 downto 0),              use_buf_data0_a_q) or
                          gate(buf_data1_a_q(63 downto 0),              use_buf_data1_a_q);

  tlxt_dlx_flit_ecc_a <= gate(tlxt_dlx_flit_ecc_egen(15 downto 8),  use_tlxt_egen_a_q) or
                         gate(rdf_tlxt_data_ecc(15 downto 8),            use_rdf_data_a_q) or
                         gate(buf_data0_ecc_a_q(7 downto 0),              use_buf_data0_a_q) or
                         gate(buf_data1_ecc_a_q(7 downto 0),              use_buf_data1_a_q);


  tlxt_dlx_flit_data_b <= gate(tlxt_dlx_flit_data_egen_out(63 downto 0),  use_tlxt_egen_b_q) or
                          gate(rdf_tlxt_data(63 downto 0),            use_rdf_data_b_q) or
                          gate(buf_data0_b_q(63 downto 0),              use_buf_data0_b_q) or
                          gate(buf_data1_b_q(63 downto 0),              use_buf_data1_b_q);

  tlxt_dlx_flit_ecc_b <= gate(tlxt_dlx_flit_ecc_egen(7 downto 0),  use_tlxt_egen_b_q) or
                         gate(rdf_tlxt_data_ecc(7 downto 0),            use_rdf_data_b_q) or
                         gate(buf_data0_ecc_b_q(7 downto 0),              use_buf_data0_b_q) or
                         gate(buf_data1_ecc_b_q(7 downto 0),              use_buf_data1_b_q);

  tlxt_dlx_flit_data_d(127 downto 0) <= tlxt_dlx_flit_data_a & tlxt_dlx_flit_data_b;

  tlxt_dlx_flit_ecc_d(15 downto 0) <= tlxt_dlx_flit_ecc_a & tlxt_dlx_flit_ecc_b;

  --------------------------------------------------------------------------------------------------
  -- ECC Error injection
  --------------------------------------------------------------------------------------------------
  err_inj0 <= cfei_enab and
              (
                (cfei_bit0 and cfei_persist) or
                (cfei_bit0_single_inj)
              );

  err_inj1 <= cfei_enab and
              (
                (cfei_bit1 and cfei_persist) or
                (cfei_bit1_single_inj)
              );



  cfei_bit0_d <= cfei_bit0;
  cfei_bit0_edge <= cfei_bit0_d and not cfei_bit0_q and not cfei_persist;
  cfei_bit0_single_rdy_d <= (not cfei_bit0_single_rdy_q and cfei_bit0_edge) or
                            (cfei_bit0_single_rdy_q and not ctrl);
  cfei_bit0_single_inj <= cfei_bit0_single_rdy_q and ctrl;

  cfei_bit1_d <= cfei_bit1;
  cfei_bit1_edge <= cfei_bit1_d and not cfei_bit1_q and not cfei_persist;
  cfei_bit1_single_rdy_d <= (not cfei_bit1_single_rdy_q and cfei_bit1_edge) or
                            (cfei_bit1_single_rdy_q and not ctrl);
  cfei_bit1_single_inj <= cfei_bit1_single_rdy_q and ctrl;


buf_data0_aq: entity latches.c_morph_dff
  generic map (width => 64, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => buf_data0_a_d(63 downto 0),
           syncr                => syncr,
           q                    => buf_data0_a_q(63 downto 0));

buf_data0_ecc_aq: entity latches.c_morph_dff
  generic map (width => 8, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => buf_data0_ecc_a_d(7 downto 0),
           syncr                => syncr,
           q                    => buf_data0_ecc_a_q(7 downto 0));

buf_data1_aq: entity latches.c_morph_dff
  generic map (width => 64, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => buf_data1_a_d(63 downto 0),
           syncr                => syncr,
           q                    => buf_data1_a_q(63 downto 0));

buf_data1_ecc_aq: entity latches.c_morph_dff
  generic map (width => 8, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => buf_data1_ecc_a_d(7 downto 0),
           syncr                => syncr,
           q                    => buf_data1_ecc_a_q(7 downto 0));

buf_data0_bq: entity latches.c_morph_dff
  generic map (width => 64, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => buf_data0_b_d(63 downto 0),
           syncr                => syncr,
           q                    => buf_data0_b_q(63 downto 0));

buf_data0_ecc_bq: entity latches.c_morph_dff
  generic map (width => 8, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => buf_data0_ecc_b_d(7 downto 0),
           syncr                => syncr,
           q                    => buf_data0_ecc_b_q(7 downto 0));

buf_data1_bq: entity latches.c_morph_dff
  generic map (width => 64, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => buf_data1_b_d(63 downto 0),
           syncr                => syncr,
           q                    => buf_data1_b_q(63 downto 0));

buf_data1_ecc_bq: entity latches.c_morph_dff
  generic map (width => 8, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => buf_data1_ecc_b_d(7 downto 0),
           syncr                => syncr,
           q                    => buf_data1_ecc_b_q(7 downto 0));

buf_data_takenq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act_low_lat_mode,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(buf_data_taken_d),
           syncr                => syncr,
           Tconv(q)             => buf_data_taken_q);

cfei_bit0q: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(cfei_bit0_d),
           syncr                => syncr,
           Tconv(q)             => cfei_bit0_q);

cfei_bit1q: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(cfei_bit1_d),
           syncr                => syncr,
           Tconv(q)             => cfei_bit1_q);

cfei_bit0_single_rdyq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(cfei_bit0_single_rdy_d),
           syncr                => syncr,
           Tconv(q)             => cfei_bit0_single_rdy_q);

cfei_bit1_single_rdyq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(cfei_bit1_single_rdy_d),
           syncr                => syncr,
           Tconv(q)             => cfei_bit1_single_rdy_q);

data_bts_sentq: entity latches.c_morph_dff
  generic map (width => 2, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => data_bts_sent_d(1 downto 0),
           syncr                => syncr,
           q                    => data_bts_sent_q(1 downto 0));


buf_data0_validq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(buf_data0_valid_d),
           syncr                => syncr,
           Tconv(q)             => buf_data0_valid_q);

buf_data0_valid_aq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(buf_data0_valid_a_d),
           syncr                => syncr,
           Tconv(q)             => buf_data0_valid_a_q);

buf_data0_valid_bq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(buf_data0_valid_b_d),
           syncr                => syncr,
           Tconv(q)             => buf_data0_valid_b_q);

buf_data1_validq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(buf_data1_valid_d),
           syncr                => syncr,
           Tconv(q)             => buf_data1_valid_q);

buf_data1_valid_aq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(buf_data1_valid_a_d),
           syncr                => syncr,
           Tconv(q)             => buf_data1_valid_a_q);

buf_data1_valid_bq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(buf_data1_valid_b_d),
           syncr                => syncr,
           Tconv(q)             => buf_data1_valid_b_q);

flit_credit_avail_flit_arbq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(flit_credit_avail_flit_arb_d),
           syncr                => syncr,
           Tconv(q)             => flit_credit_avail_flit_arb_q);

 flit_credit_avail_ctrlq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(flit_credit_avail_ctrl_d),
           syncr                => syncr,
           Tconv(q)             => flit_credit_avail_ctrl_q);

flit_credit_avail_ctrl_aq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(flit_credit_avail_ctrl_a_d),
           syncr                => syncr,
           Tconv(q)             => flit_credit_avail_ctrl_a_q);

flit_credit_avail_ctrl_bq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(flit_credit_avail_ctrl_b_d),
           syncr                => syncr,
           Tconv(q)             => flit_credit_avail_ctrl_b_q);

flit_credit_avail_flit_vldq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(flit_credit_avail_flit_vld_d),
           syncr                => syncr,
           Tconv(q)             => flit_credit_avail_flit_vld_q);

flit_credit_strq: entity latches.c_morph_dff
  generic map (width => 7, offset => 0)
  port map(gckn                 => gckn,
           e                    => dlx_tlxr_link_up,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => flit_credit_str_d(6 downto 0),
           syncr                => syncr,
           q                    => flit_credit_str_q(6 downto 0));

flit_credit_str_pq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => dlx_tlxr_link_up,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(flit_credit_str_p_d),
           syncr                => syncr,
           Tconv(q)             => flit_credit_str_p_q);

flit_credit_overflowq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(flit_credit_overflow_d),
           syncr                => syncr,
           Tconv(q)             => flit_credit_overflow_q);

flit_credit_underflowq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(flit_credit_underflow_d),
           syncr                => syncr,
           Tconv(q)             => flit_credit_underflow_q);

tlxt_dlx_flit_early_vld_aq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => dlx_tlxr_link_up,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(tlxt_dlx_flit_early_vld_a_d),
           syncr                => syncr,
           Tconv(q)             => tlxt_dlx_flit_early_vld_a_q);

tlxt_dlx_flit_early_vld_bq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => dlx_tlxr_link_up,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(tlxt_dlx_flit_early_vld_b_d),
           syncr                => syncr,
           Tconv(q)             => tlxt_dlx_flit_early_vld_b_q);

mstr_cntq: entity latches.c_morph_dff
  generic map (width => 6, offset => 0, init => "00000")
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => mstr_cnt_d(5 downto 0),
           syncr                => syncr,
           q                    => mstr_cnt_q(5 downto 0));

mstr_cnt_maxq: entity latches.c_morph_dff
  generic map (width => 6, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => mstr_cnt_max_d(5 downto 0),
           syncr                => syncr,
           q                    => mstr_cnt_max_q(5 downto 0));

mstr_cnt_pq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0, init => "0")
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(mstr_cnt_p_d),
           syncr                => syncr,
           Tconv(q)             => mstr_cnt_p_q);

tlxt_dlx_flit_dataq: entity latches.c_morph_dff
  generic map (width => 128, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => tlxt_dlx_flit_data_d(127 downto 0),
           syncr                => syncr,
           q                    => tlxt_dlx_flit_data_q(127 downto 0));

tlxt_dlx_flit_eccq: entity latches.c_morph_dff
  generic map (width => 16, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => tlxt_dlx_flit_ecc_d(15 downto 0),
           syncr                => syncr,
           q                    => tlxt_dlx_flit_ecc_q(15 downto 0));

tlxt_dlx_flit_lbip_dataq: entity latches.c_morph_dff
  generic map (width => 82, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => tlxt_dlx_flit_lbip_data_d(81 downto 0),
           syncr                => syncr,
           q                    => tlxt_dlx_flit_lbip_data_q(81 downto 0));

tlxt_dlx_flit_lbip_data_pq: entity latches.c_morph_dff
  generic map (width => 11, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => tlxt_dlx_flit_lbip_data_p_d(10 downto 0),
           syncr                => syncr,
           q                    => tlxt_dlx_flit_lbip_data_p_q(10 downto 0));

tlxt_dlx_flit_lbip_vldq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(tlxt_dlx_flit_lbip_vld_d),
           syncr                => syncr,
           Tconv(q)             => tlxt_dlx_flit_lbip_vld_q);

tlxt_dlx_flit_parq: entity latches.c_morph_dff
  generic map (width => 16, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => tlxt_dlx_flit_par_d(15 downto 0),
           syncr                => syncr,
           q                    => tlxt_dlx_flit_par_q(15 downto 0));

tlxt_dlx_flit_par_vldq: entity latches.c_morph_dff
  generic map (width => 2, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => tlxt_dlx_flit_par_vld_d(1 downto 0),
           syncr                => syncr,
           q                    => tlxt_dlx_flit_par_vld_q(1 downto 0));

tlxt_dlx_flit_vldq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(tlxt_dlx_flit_vld_d),
           syncr                => syncr,
           Tconv(q)             => tlxt_dlx_flit_vld_q);

tlxt_srq_rdbuf_popq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(tlxt_srq_rdbuf_pop_d),
           syncr                => syncr,
           Tconv(q)             => tlxt_srq_rdbuf_pop_q);

use_tlxt_egen_aq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(use_tlxt_egen_a_d),
           syncr                => syncr,
           Tconv(q)             => use_tlxt_egen_a_q);

use_rdf_data_aq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(use_rdf_data_a_d),
           syncr                => syncr,
           Tconv(q)             => use_rdf_data_a_q);

use_buf_data0_aq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(use_buf_data0_a_d),
           syncr                => syncr,
           Tconv(q)             => use_buf_data0_a_q);

use_buf_data1_aq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(use_buf_data1_a_d),
           syncr                => syncr,
           Tconv(q)             => use_buf_data1_a_q);

use_tlxt_egen_bq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(use_tlxt_egen_b_d),
           syncr                => syncr,
           Tconv(q)             => use_tlxt_egen_b_q);

use_rdf_data_bq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(use_rdf_data_b_d),
           syncr                => syncr,
           Tconv(q)             => use_rdf_data_b_q);

use_buf_data0_bq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(use_buf_data0_b_d),
           syncr                => syncr,
           Tconv(q)             => use_buf_data0_b_q);

use_buf_data1_bq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(use_buf_data1_b_d),
           syncr                => syncr,
           Tconv(q)             => use_buf_data1_b_q);

use_rdf_data_ctrlq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(use_rdf_data_ctrl_d),
           syncr                => syncr,
           Tconv(q)             => use_rdf_data_ctrl_q);

pull_buf_data0q: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(pull_buf_data0_d),
           syncr                => syncr,
           Tconv(q)             => pull_buf_data0_q);

pull_buf_data1q: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(pull_buf_data1_d),
           syncr                => syncr,
           Tconv(q)             => pull_buf_data1_q);

pull_buf_data0_aq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(pull_buf_data0_a_d),
           syncr                => syncr,
           Tconv(q)             => pull_buf_data0_a_q);

pull_buf_data1_aq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(pull_buf_data1_a_d),
           syncr                => syncr,
           Tconv(q)             => pull_buf_data1_a_q);

pull_buf_data0_bq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(pull_buf_data0_b_d),
           syncr                => syncr,
           Tconv(q)             => pull_buf_data0_b_q);

pull_buf_data1_bq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(pull_buf_data1_b_d),
           syncr                => syncr,
           Tconv(q)             => pull_buf_data1_b_q);

tlxt_dlx_pchkq: entity latches.c_morph_dff
  generic map (width => 2, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => tlxt_dlx_pchk_d(1 downto 0),
           syncr                => syncr,
           q                    => tlxt_dlx_pchk_q(1 downto 0));

load_buf_data0q: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(load_buf_data0_d),
           syncr                => syncr,
           Tconv(q)             => load_buf_data0_q);

load_buf_data1q: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(load_buf_data1_d),
           syncr                => syncr,
           Tconv(q)             => load_buf_data1_q);

load_buf_data0_aq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(load_buf_data0_a_d),
           syncr                => syncr,
           Tconv(q)             => load_buf_data0_a_q);

load_buf_data1_aq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(load_buf_data1_a_d),
           syncr                => syncr,
           Tconv(q)             => load_buf_data1_a_q);

load_buf_data0_bq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(load_buf_data0_b_d),
           syncr                => syncr,
           Tconv(q)             => load_buf_data0_b_q);

load_buf_data1_bq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(load_buf_data1_b_d),
           syncr                => syncr,
           Tconv(q)             => load_buf_data1_b_q);
----------------------------------------------------------------------------------------------------

end cb_tlxt_trans_arb_rlm;
