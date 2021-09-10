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
use work.cb_tlxr_pkg.all;
use work.cb_tlxt_pkg.all;

entity cb_tlxt_flit_arb_rlm is

  port (
    gckn                           : in std_ulogic;
    syncr                          : in std_ulogic;

    ---------------------------------------------------------------------------
    -- Response and meta bit input
    ---------------------------------------------------------------------------
    wr_resp                        : in std_ulogic_vector(20 downto 0);
    wr_resp_val                    : in std_ulogic;
    rd_resp                        : in std_ulogic_vector(17 downto 0);
    rd_resp_val                    : in std_ulogic;
    rd_resp_exit0                  : in std_ulogic;

    meta                           : in std_ulogic_vector(5 downto 0);
    meta_p                         : in std_ulogic;
    meta_val                       : in std_ulogic_vector(1 downto 0);

    bad_data_valid                 : in std_ulogic;
    bad_data                       : in std_ulogic;
    bad_data_1st32B                : in std_ulogic;

    rdf_tlxt_data_err              : in std_ulogic;

    ---------------------------------------------------------------------------
    -- Pull in MMIO Response directly to flit arb
    ---------------------------------------------------------------------------
    mmio_resp_val                  : in std_ulogic;
    mmio_tlxt_resp                 : in std_ulogic_vector(17 downto 0);
    mmio_resp_ack                  : out std_ulogic;
    mmio_tlxt_rdata_offset         : in std_ulogic;
    mmio_tlxt_rdata_bus            : in std_ulogic_vector(287 downto 0); -- 287:256 are parity
    mmio_tlxt_rdata_bdi            : in std_ulogic;

    dl_cont_tl_tmpl                : out std_ulogic_vector(5 downto 0);
    dl_cont_tl_tmpl_p              : out std_ulogic; -- Even parity over 5:0
    dl_cont_data_run_len           : out std_ulogic_vector(3 downto 0);
    dl_cont_bdi_vec                : out std_ulogic_vector(7 downto 0);
    dl_cont_bdi_vec_p              : out std_ulogic_vector(1 downto 0); --  1 covers 7:4, 0 covers 3:0
    tlxt_tlxr_wr_resp_full         : out std_ulogic;
    flit_part_vld                  : out std_ulogic;
    flit_part_last_vld             : out std_ulogic;
    flit_xmit_start                : out std_ulogic;
    flit_xmit_start_early          : out std_ulogic;

    flit_xmit_done                 : in std_ulogic;
    flit_xmit_early_done           : in std_ulogic;
    data_xmit                      : in std_ulogic;  --for data tracker
    data_flit_xmit                 : in std_ulogic;  --for gating flit xmit
    flit_credit_avail              : in std_ulogic;
    data_valid                     : in std_ulogic;

    dlx_tlxt_lane_width_status     : in std_ulogic_vector(1 downto 0);  --00 training/retraining,
                                                                        --10 quarter width,
                                                                        --01 half width,
                                                                        --11 full width, 

    data_pending                   : out std_ulogic;
    flit_part                      : out std_ulogic_vector(127 downto 0);
    flit_part_p                    : out std_ulogic_vector(15 downto 0);
    flit_part_last                 : out std_ulogic_vector(63 downto 0);
    flit_part_last_p               : out std_ulogic_vector(7 downto 0);
    tmpl9_data_val                 : out std_ulogic;
    tmplB_data_val                 : out std_ulogic;
    mmio_data_val                  : out std_ulogic;
    mmio_data_flit                 : out std_ulogic;
    mmio_data_flit_early           : out std_ulogic;
    rd_resp_len32_flit             : out std_ulogic;
    rd_resp_len32_flit_early       : out std_ulogic;

    ------------------------------------------------------------------------------------------------
    -- Interrupt handling
    ------------------------------------------------------------------------------------------------
    intrp_resp                     : in std_ulogic_vector(7 downto 0);

    tlxt_intrp_handle_0            : IN std_ulogic_vector(63 DOWNTO 0);
    tlxt_intrp_handle_1            : IN std_ulogic_vector(63 DOWNTO 0);
    tlxt_intrp_handle_2            : IN std_ulogic_vector(63 DOWNTO 0);
    tlxt_intrp_handle_3            : IN std_ulogic_vector(63 DOWNTO 0);

    cmd_flag_0                     : in std_ulogic_vector(3 downto 0);
    cmd_flag_1                     : in std_ulogic_vector(3 downto 0);
    cmd_flag_2                     : in std_ulogic_vector(3 downto 0);
    cmd_flag_3                     : in std_ulogic_vector(3 downto 0);
    ---------------------------------------------------------------------------
    -- credit interface
    ---------------------------------------------------------------------------
    -- tlxt uses credits
    tlxt_tlxc_consume_val          : out std_ulogic;
    tlxt_tlxc_consume_vc0          : out std_ulogic_vector(3 downto 0);
    tlxt_tlxc_consume_vc3          : out std_ulogic_vector(3 downto 0);
    tlxt_tlxc_consume_dcp0         : out std_ulogic_vector(3 downto 0);
    tlxt_tlxc_consume_dcp3         : out std_ulogic_vector(3 downto 0);
    -- tlxt credit available       :
    tlxc_tlxt_avail_vc0            : in std_ulogic_vector(3 downto 0);
    tlxc_tlxt_avail_vc3            : in std_ulogic_vector(3 downto 0);
    tlxc_tlxt_avail_dcp0           : in std_ulogic_vector(3 downto 0);
    tlxc_tlxt_avail_dcp3           : in std_ulogic_vector(3 downto 0);

                                                                        --
    tlxc_tlxt_crd_ret_val          : in std_ulogic;
    tlxc_tlxt_vc0_credits          : in std_ulogic_vector(3 downto 0);
    tlxc_tlxt_vc1_credits          : in std_ulogic_vector(3 downto 0);
    tlxc_tlxt_dcp1_credits         : in std_ulogic_vector(5 downto 0);
    tlxc_tlxt_vc0_credits_p        : in std_ulogic;
    tlxc_tlxt_vc1_credits_p        : in std_ulogic;
    tlxc_tlxt_dcp1_credits_p       : in std_ulogic;
    tlxt_tlxc_crd_ret_taken        : out std_ulogic;

    ------------------------------------------------------------------------------------------------
    -- Config Inputs/Outputs
    ------------------------------------------------------------------------------------------------
    tmpl_config                    : in std_ulogic_vector(11 downto 0);
    xmit_rate_config               : in std_ulogic_vector(47 downto 0);
    metadata_enabled               : in std_ulogic;

    actag_base                     : in std_ulogic_vector(12 downto 0); -- 12 is parity
    actag_len_enab                 : in std_ulogic_vector(11 downto 0);
    actag_err                      : IN std_ulogic;
    pasid_length_enabled           : in std_ulogic_vector(4 downto 0);
    pasid_base                     : in std_ulogic_vector(20 downto 0); -- 20 is parity
    busnum                         : in std_ulogic_vector(8 downto 0); -- 8 is parity

    hi_bw_threshold                : in std_ulogic_vector(2 downto 0);
    mid_bw_threshold               : in std_ulogic_vector(2 downto 0);  --Meta fifo count to trigger
                                                                        --mid bandwidth mode. Used
                                                                        --for read response trigger
                                                                        --to high bansdwidth

    hi_bw_dis                      : in std_ulogic;  --Disables high bandwidth mode if on
    hi_bw_enab_rd_thresh           : in std_ulogic;  --Enables the use of a read threshold in
                                                     --addition to metabit threshold to switch into
                                                     --high bandwidth mode
    mid_bw_enab                    : in std_ulogic;  --mid bw disabled by default

    low_lat_mode                   : in std_ulogic;  --Disable template 9 (or A) only read response.
                                                     --also turns off speculative read response
    low_lat_degrade_dis           : in std_ulogic;
    half_dimm_mode                 : in std_ulogic;

     tlxt_clk_gate_dis              : in std_ulogic;

    ------------------------------------------------------------------------------------------------
    -- Failure response queue input
    ------------------------------------------------------------------------------------------------
    fail_resp_input                : in std_ulogic_vector(31 downto 0);
    fail_resp_val                  : in std_ulogic;
    fail_resp_full                 : out std_ulogic;
    ---------------------------------------------------------------------------
    -- Pull in link up
    ---------------------------------------------------------------------------
    link_up                        : in std_ulogic;  --need for error check on template selection.
    link_up_pulse                  : in std_ulogic;

    ------------------------------------------------------------------------------------------------
    -- Interrupt Request Triggers
    ------------------------------------------------------------------------------------------------
    intrp_chan_xstop               : in std_ulogic;
    intrp_rec_attn                 : in std_ulogic;
    intrp_sp_attn                  : in std_ulogic;
    intrp_app_intrp                : in std_ulogic;

    xstop_rd_gate                  : in std_ulogic;
    ------------------------------------------------------------------------------------------------
    -- rd_buf_pop
    ------------------------------------------------------------------------------------------------
    tlxt_srq_rdbuf_pop             : in std_ulogic;

    ------------------------------------------------------------------------------------------------
    -- Error Outputs
    ------------------------------------------------------------------------------------------------
    tlxt_err_bdi_poisoned               : out std_ulogic;
    tlxt_err_fifo_CE                        : out std_ulogic;
    tlxt_err_fifo_UE                        : out std_ulogic_vector(0 to 4);
    flit_arb_perrors               : out std_ulogic_vector(0 to 8);

    tlxt_err_invalid_crd_ret       : out std_ulogic;
    tlxt_err_dropped_crd_ret       : out std_ulogic;
    tlxt_err_invalid_cfg           : out std_ulogic;
    tlxt_err_invalid_meta_cfg      : out std_ulogic;
    tlxt_err_invalid_tmpl_cfg      : out std_ulogic;

    tlxt_fifo_overflow          : OUT std_ulogic_vector(0 to 4);

    tlxt_fifo_underflow         : OUT std_ulogic_vector(0 to 4);

    tlxt_fifo_ptr_perr              : OUT std_ulogic_vector(0 to 4);

    intrp_req_failed               : out std_ulogic;
    unexp_intrp_resp               : out std_ulogic;

    intrp_req_sm_perr                 : out std_ulogic_vector(0 to 3);

    flit_arb_debug_bus             : out std_ulogic_vector(0 to 87);
    flit_arb_debug_fedc            : out std_ulogic_vector(0 to 27);

    gnd                            : inout power_logic;
    vdd                            : inout power_logic);

  attribute BLOCK_TYPE of cb_tlxt_flit_arb_rlm : entity is LEAF;
  attribute BTR_NAME of cb_tlxt_flit_arb_rlm : entity is "CB_TLXT_FLIT_ARB_RLM";
  attribute PIN_DEFAULT_GROUND_DOMAIN of cb_tlxt_flit_arb_rlm : entity is "GND";
  attribute PIN_DEFAULT_POWER_DOMAIN of cb_tlxt_flit_arb_rlm : entity is "VDD";
  attribute RECURSIVE_SYNTHESIS of cb_tlxt_flit_arb_rlm : entity is 2;
  attribute PIN_DATA of gckn : signal is "PIN_FUNCTION=/G_CLK/";
  attribute GROUND_PIN of gnd : signal is 1;
  attribute POWER_PIN of vdd : signal is 1;
  attribute ANALYSIS_NOT_REFERENCED of tmpl_config : signal is "<11:10>TRUE,<8:6>TRUE,<4:2>TRUE";
  attribute ANALYSIS_NOT_REFERENCED of mmio_tlxt_rdata_offset : signal is "TRUE";
  attribute ANALYSIS_NOT_REFERENCED of tlxc_tlxt_avail_dcp3 : signal is "TRUE";
  attribute ANALYSIS_NOT_REFERENCED of tlxt_srq_rdbuf_pop : signal is "TRUE";
end cb_tlxt_flit_arb_rlm;

architecture cb_tlxt_flit_arb_rlm of cb_tlxt_flit_arb_rlm is
SIGNAL pkt_vld_1sl : std_ulogic_vector(11 downto 0);
SIGNAL pkt_vld_4sl : std_ulogic_vector(3 downto 0);
SIGNAL act : std_ulogic;
SIGNAL tmpl0 : std_ulogic;
SIGNAL tmpl1 : std_ulogic;
SIGNAL tmpl5 : std_ulogic;
SIGNAL tmpl9 : std_ulogic;
SIGNAL tmpl0_dbg : std_ulogic;
SIGNAL tmpl1_dbg : std_ulogic;
SIGNAL tmpl5_dbg : std_ulogic;
SIGNAL tmpl9_dbg : std_ulogic;
SIGNAL tmpl0_mux : std_ulogic;
SIGNAL tmpl1_mux : std_ulogic;
SIGNAL tmpl5_mux : std_ulogic;
SIGNAL tmpl9_mux : std_ulogic;
SIGNAL tmplB_mux : std_ulogic;
SIGNAL tmplB_dbg : std_ulogic;
SIGNAL tl_2sl_pkt_d : std_ulogic_vector(55 downto 0);
SIGNAL tl_2sl_pkt_p_d : std_ulogic_vector(6 downto 0);
SIGNAL sl_15 : std_ulogic_vector(27 downto 0);
SIGNAL sl_14 : std_ulogic_vector(27 downto 0);
SIGNAL sl_13 : std_ulogic_vector(27 downto 0);
SIGNAL sl_12 : std_ulogic_vector(27 downto 0);
SIGNAL sl_11 : std_ulogic_vector(27 downto 0);
SIGNAL tl_2sl_pkt_q : std_ulogic_vector(55 downto 0);
SIGNAL tl_2sl_pkt_p_q : std_ulogic_vector(6 downto 0);
SIGNAL sl_10 : std_ulogic_vector(27 downto 0);
SIGNAL sl_9 : std_ulogic_vector(27 downto 0);
SIGNAL sp_meta : std_ulogic_vector(23 downto 0);
SIGNAL sp_meta_p : std_ulogic_vector(2 downto 0);
SIGNAL sl_8 : std_ulogic_vector(27 downto 0);
SIGNAL sl_7 : std_ulogic_vector(27 downto 0);
SIGNAL sl_6 : std_ulogic_vector(27 downto 0);
SIGNAL sl_5 : std_ulogic_vector(27 downto 0);
SIGNAL sl_4 : std_ulogic_vector(27 downto 0);
SIGNAL sl_3 : std_ulogic_vector(27 downto 0);
SIGNAL sl_2 : std_ulogic_vector(27 downto 0);
SIGNAL sl_1 : std_ulogic_vector(27 downto 0);
SIGNAL sl_0 : std_ulogic_vector(27 downto 0);
SIGNAL sl_1514_p : std_ulogic_vector(6 downto 0);
SIGNAL sl_1312_p : std_ulogic_vector(6 downto 0);
SIGNAL sl_1110_p : std_ulogic_vector(6 downto 0);
SIGNAL sl_98_p : std_ulogic_vector(6 downto 0);
SIGNAL sl_76_p : std_ulogic_vector(6 downto 0);
SIGNAL sl_54_p : std_ulogic_vector(6 downto 0);
SIGNAL sl_32_p : std_ulogic_vector(6 downto 0);
SIGNAL sl_10_p : std_ulogic_vector(6 downto 0);
SIGNAL sl_1514_1sl_p : std_ulogic_vector(6 downto 0);
SIGNAL sl_1312_1sl_p : std_ulogic_vector(6 downto 0);
SIGNAL sl_1110_1sl_p : std_ulogic_vector(6 downto 0);
SIGNAL sl_98_1sl_p : std_ulogic_vector(6 downto 0);
SIGNAL sl_76_1sl_p : std_ulogic_vector(6 downto 0);
SIGNAL sl_54_1sl_p : std_ulogic_vector(6 downto 0);
SIGNAL sl_98_flitbuff_p : std_ulogic_vector(6 downto 0);
SIGNAL sl_98_1sl_enables : std_ulogic_vector(1 downto 0);
SIGNAL sl_98_4sl_enables : std_ulogic_vector(1 downto 0);
SIGNAL sl_98_4sl_p : std_ulogic_vector(6 downto 0);
SIGNAL flit_buffer_1st_half_d : std_ulogic_vector(255 downto 0);
SIGNAL flit_buffer_1st_half_q : std_ulogic_vector(255 downto 0);
SIGNAL flit_buffer_1st_half_p_d : std_ulogic_vector(31 downto 0);
SIGNAL flit_buffer_1st_half_p_q : std_ulogic_vector(31 downto 0);
SIGNAL flit_buffer_2nd_half_d : std_ulogic_vector(191 downto 0);
SIGNAL flit_buffer_2nd_half_q : std_ulogic_vector(191 downto 0);
SIGNAL flit_buffer_2nd_half_p_d : std_ulogic_vector(23 downto 0);
SIGNAL flit_buffer_2nd_half_p_q : std_ulogic_vector(23 downto 0);
SIGNAL rd_resp_out : std_ulogic_vector(23 downto 0);
SIGNAL wr_resp_out : std_ulogic_vector(26 downto 0);
SIGNAL ow_meta_data : std_ulogic_vector(6 downto 0);
SIGNAL ow_meta_data_p : std_ulogic;
SIGNAL wr_resp_pop : std_ulogic;
SIGNAL rd_resp_pop : std_ulogic;
SIGNAL rd_resp_input : std_ulogic_vector(23 downto 0);
SIGNAL rd_resp_push : std_ulogic;
SIGNAL wr_resp_input : std_ulogic_vector(26 downto 0);
SIGNAL wr_resp_push : std_ulogic;
SIGNAL mmio_resp_push : std_ulogic;
SIGNAL mmio_resp_pop : std_ulogic;
SIGNAL mmio_resp_input : std_ulogic_vector(23 downto 0);
SIGNAL mmio_resp_out : std_ulogic_vector(23 downto 0);
SIGNAL tl_1sl_pkt : std_ulogic_vector(27 downto 0);
SIGNAL tl_1sl_pkt_p : std_ulogic_vector(7 downto 0);
SIGNAL data_pending_int : std_ulogic;
SIGNAL tmpl9_data_valid : std_ulogic;
SIGNAL flit_xmit_start_t2_q : std_ulogic;
SIGNAL flit_xmit_start_t1_q : std_ulogic;
SIGNAL flit_xmit_start_t1_d : std_ulogic;
SIGNAL flit_xmit_start_t2_d : std_ulogic;
SIGNAL flit_xmit_start_int : std_ulogic;
SIGNAL flit_hold : std_ulogic;
SIGNAL flit_hold_1st : std_ulogic;
SIGNAL flit_hold_2nd : std_ulogic;
SIGNAL tl_2sl_pkt : std_ulogic_vector(55 downto 0);
SIGNAL tl_2sl_pkt_p : std_ulogic_vector(6 downto 0);
SIGNAL next_credit_return : std_ulogic_vector(55 downto 0);
SIGNAL next_credit_return_p : std_ulogic_vector(6 downto 0);
SIGNAL tlxt_tlxc_crd_ret_taken_int : std_ulogic;
SIGNAL data_run_length_q : std_ulogic_vector(3 downto 0);
SIGNAL data_run_length_p_q : std_ulogic;
SIGNAL data_run_length_d : std_ulogic_vector(3 downto 0);
SIGNAL data_run_length_p_d : std_ulogic;
SIGNAL flit_xmit_start_t3_q : std_ulogic;
SIGNAL flit_xmit_start_t3_d : std_ulogic;
SIGNAL mmio_data_buffer_d : std_ulogic_vector(255 downto 0);
SIGNAL mmio_data_buffer_q : std_ulogic_vector(255 downto 0);
SIGNAL mmio_data_buffer_p_d : std_ulogic_vector(31 downto 0);
SIGNAL mmio_data_buffer_p_q : std_ulogic_vector(31 downto 0);
SIGNAL rd_resp_empty : std_ulogic;
SIGNAL rd_resp_fifo_full : std_ulogic;
SIGNAL rd_resp_fifo_err : std_ulogic_vector(1 downto 0);
SIGNAL rd_resp_count : std_ulogic_vector(5 downto 0);
SIGNAL wr_resp_empty : std_ulogic;
SIGNAL wr_resp_fifo_full : std_ulogic;
SIGNAL wr_resp_fifo_err : std_ulogic_vector(1 downto 0);
SIGNAL wr_resp_count : std_ulogic_vector(3 downto 0);
SIGNAL mmio_resp_empty : std_ulogic;

----------------------------------------------------------------------------------------------------
-- Signals from Flit Control Block
----------------------------------------------------------------------------------------------------
  SIGNAL tmpl_current_d : std_ulogic_vector(4 downto 0);
  SIGNAL tmpl_current_q : std_ulogic_vector(4 downto 0);
  SIGNAL tmpl_current_dbg_d : std_ulogic_vector(4 downto 0);
  SIGNAL tmpl_current_dbg_q : std_ulogic_vector(4 downto 0);
  SIGNAL tmpl_current_mux_d : std_ulogic_vector(4 downto 0);
  SIGNAL tmpl_current_mux_q : std_ulogic_vector(4 downto 0);
  SIGNAL flit_pkt_cnt_reset : std_ulogic;
  SIGNAL flit_pkt_cnt_inc : std_ulogic;
  SIGNAL flit_pkt_cnt_hold : std_ulogic;
  SIGNAL flit_pkt_cnt_d : std_ulogic_vector(3 downto 0);
  SIGNAL flit_pkt_cnt_p_d : std_ulogic;
  SIGNAL flit_pkt_cnt_q : std_ulogic_vector(3 downto 0);
  SIGNAL flit_pkt_cnt_p_q : std_ulogic;
  SIGNAL tl_1sl_vld_reset : std_ulogic;
  SIGNAL tl_1sl_vld_inc : std_ulogic;
  SIGNAL tl_1sl_vld_hold : std_ulogic;
  SIGNAL tl_1sl_vld_d : std_ulogic_vector(3 downto 0);
  SIGNAL tl_1sl_vld_p_d : std_ulogic;
  SIGNAL tl_1sl_vld_q : std_ulogic_vector(3 downto 0);
  SIGNAL tl_1sl_vld_p_q : std_ulogic;
  SIGNAL dat_bts_pend_dec : std_ulogic;
  SIGNAL dat_bts_pend_q : std_ulogic_vector(6 downto 0);
  SIGNAL dat_bts_pend_d : std_ulogic_vector(6 downto 0);
  SIGNAL tmplB_data_valid : std_ulogic;--_vector(1 downto 0);
  SIGNAL tmplB_next : std_ulogic;
  SIGNAL tmpl9_next : std_ulogic;
  SIGNAL tmpl5_next : std_ulogic;
  SIGNAL tmpl1_next : std_ulogic;
  SIGNAL tmpl0_next : std_ulogic;

  SIGNAL tmpl0_chosen : std_ulogic;
  SIGNAL tmpl1_chosen : std_ulogic;
  SIGNAL tmpl5_chosen : std_ulogic;
  SIGNAL tmpl9_chosen : std_ulogic;
  SIGNAL init_complete_d : std_ulogic;
SIGNAL init_complete_q : std_ulogic;
  SIGNAL init_cred_ret_complete_d : std_ulogic_vector(1 downto 0);
  SIGNAL init_cred_ret_complete_q : std_ulogic_vector(1 downto 0);
  SIGNAL flit_full_d : std_ulogic;
SIGNAL flit_full_q : std_ulogic;
  SIGNAL init_cred_ret_complete_0_1 : std_ulogic;
  SIGNAL init_cred_ret_complete_1_2 : std_ulogic;
  SIGNAL init_cred_ret_complete_2_3 : std_ulogic;
  SIGNAL init_cred_ret_complete_hold : std_ulogic;
  SIGNAL cred_ret_done : std_ulogic;
  SIGNAL init_flit_start : std_ulogic;
  SIGNAL tmpl_next : std_ulogic_vector(4 downto 0);
  SIGNAL tmpl_next_onehot : std_ulogic_vector(4 downto 0);
  SIGNAL tmpl_next_p : std_ulogic;
  SIGNAL flit_ip : std_ulogic;
  SIGNAL flit_xmit_start_t4_d : std_ulogic;
  SIGNAL flit_xmit_start_t4_q : std_ulogic;
SIGNAL idle_crd_ret : std_ulogic;
SIGNAL rsvd_1sl : std_ulogic_vector(27 downto 0);
SIGNAL rsvd_2sl : std_ulogic_vector(55 downto 0);
SIGNAL rsvd_4sl : std_ulogic_vector(111 downto 0);
SIGNAL rd_resp_ow_pop : std_ulogic;
SIGNAL rd_resp_ow_pend_q : std_ulogic;
SIGNAL meta_fifo_input : std_ulogic_vector(5 downto 0);
SIGNAL meta_fifo_push : std_ulogic;
SIGNAL meta_fifo_pop : std_ulogic;
SIGNAL meta_fifo_output : std_ulogic_vector(10 downto 0);
SIGNAL meta_fifo_empty : std_ulogic;
SIGNAL meta_fifo_full : std_ulogic;
SIGNAL meta_fifo_err : std_ulogic_vector(1 downto 0);
SIGNAL meta_fifo_count : std_ulogic_vector(5 downto 0);
SIGNAL mf_0 : std_ulogic_vector(6 downto 0);
SIGNAL mf_1 : std_ulogic_vector(6 downto 0);
SIGNAL mf_2 : std_ulogic_vector(6 downto 0);
SIGNAL mf_3 : std_ulogic_vector(6 downto 0);
SIGNAL mf_4 : std_ulogic_vector(6 downto 0);
SIGNAL mf_5 : std_ulogic_vector(6 downto 0);
SIGNAL mf_6 : std_ulogic_vector(6 downto 0);
SIGNAL mf_7 : std_ulogic_vector(6 downto 0);
SIGNAL meta_vec_d : std_ulogic_vector(55 downto 0);
SIGNAL meta_vec_p_d : std_ulogic_vector(6 downto 0);
SIGNAL flit_rd_resp_d : std_ulogic_vector(3 downto 0);
SIGNAL flit_rd_resp_p_d : std_ulogic;
SIGNAL flit_rd_resp_q : std_ulogic_vector(3 downto 0);
SIGNAL flit_rd_resp_p_q : std_ulogic;
SIGNAL flit_wr_resp_d : std_ulogic_vector(3 downto 0);
SIGNAL flit_wr_resp_p_d : std_ulogic;
SIGNAL flit_wr_resp_q : std_ulogic_vector(3 downto 0);
SIGNAL flit_wr_resp_p_q : std_ulogic;
SIGNAL tl_4sl_vld_reset : std_ulogic;
SIGNAL tl_4sl_vld_inc : std_ulogic;
SIGNAL tl_4sl_vld_hold : std_ulogic;
SIGNAL tl_4sl_vld_d : std_ulogic_vector(1 downto 0);
SIGNAL tl_4sl_vld_p_d : std_ulogic;
SIGNAL tl_4sl_vld_q : std_ulogic_vector(1 downto 0);
SIGNAL tl_4sl_vld_p_q : std_ulogic;
SIGNAL tl_4sl_pkt : std_ulogic_vector(111 downto 0);
SIGNAL tl_4sl_pkt_p : std_ulogic_vector(13 downto 0);
SIGNAL rd_resp_fst_ow : std_ulogic_vector(27 downto 0);
SIGNAL rd_resp_fst_ow_p : std_ulogic_vector(7 downto 0);
SIGNAL rd_resp_sec_ow : std_ulogic_vector(27 downto 0);
SIGNAL rd_resp_sec_ow_p : std_ulogic_vector(7 downto 0);
SIGNAL rd_resp_pkt : std_ulogic_vector(27 downto 0);
SIGNAL rd_resp_pkt_p : std_ulogic_vector(7 downto 0);
SIGNAL rd_resp_full : std_ulogic_vector(27 downto 0);
SIGNAL rd_resp_full_p : std_ulogic_vector(7 downto 0);
SIGNAL rd_resp_ow_buf_q : std_ulogic_vector(27 downto 0);
SIGNAL rd_resp_ow_buf_p_q : std_ulogic_vector(7 downto 0);
SIGNAL rd_resp_ow_pend_d : std_ulogic;
SIGNAL rd_resp_ow_buf_d : std_ulogic_vector(27 downto 0);
SIGNAL rd_resp_ow_buf_p_d : std_ulogic_vector(7 downto 0);
SIGNAL meta_vec_q : std_ulogic_vector(55 downto 0);
SIGNAL meta_vec_p_q : std_ulogic_vector(6 downto 0);
SIGNAL data_run_length_max : std_ulogic_vector(3 downto 0);
SIGNAL tl_2sl_pkt_full_q : std_ulogic;
SIGNAL tl_2sl_pkt_full_d : std_ulogic;
SIGNAL mf_0_vld : std_ulogic;
SIGNAL mf_1_vld : std_ulogic;
SIGNAL mf_2_vld : std_ulogic;
SIGNAL mf_3_vld : std_ulogic;
SIGNAL mf_4_vld : std_ulogic;
SIGNAL mf_5_vld : std_ulogic;
SIGNAL mf_6_vld : std_ulogic;
SIGNAL mf_7_vld : std_ulogic;
SIGNAL mf_vld_reset : std_ulogic;
SIGNAL mf_vld_inc : std_ulogic;
SIGNAL mf_vld_hold : std_ulogic;
SIGNAL mf_vld_d : std_ulogic_vector(2 downto 0);
SIGNAL mf_vld_p_d : std_ulogic;
SIGNAL mf_vld_q : std_ulogic_vector(2 downto 0);
SIGNAL mf_vld_p_q : std_ulogic;
SIGNAL flit_mmio_resp_q : std_ulogic_vector(3 downto 0);
SIGNAL flit_mmio_resp_p_q : std_ulogic;
SIGNAL flit_mmio_resp_d : std_ulogic_vector(3 downto 0);
SIGNAL flit_mmio_resp_p_d : std_ulogic;
SIGNAL ow_data_pend : std_ulogic;
SIGNAL meta_fifo_ow_pop : std_ulogic;
SIGNAL ow_meta_packed_q : std_ulogic;
SIGNAL ow_meta_bypass_taken_d : std_ulogic;
SIGNAL ow_meta_bypass_taken_q : std_ulogic;
SIGNAL ow_meta_pend_q : std_ulogic;
SIGNAL ow_meta_buffer_q : std_ulogic_vector(5 downto 0);
SIGNAL ow_meta_buffer_p_q : std_ulogic;
SIGNAL ow_meta_buffer_d : std_ulogic_vector(5 downto 0);
SIGNAL ow_meta_buffer_p_d : std_ulogic;
SIGNAL ow_meta_pend_d : std_ulogic;
SIGNAL ow_meta_packed_d : std_ulogic;
SIGNAL data_flit_xmit_q : std_ulogic;
SIGNAL data_flit_xmit_d : std_ulogic;
SIGNAL idle_crd_ret_del_q : std_ulogic;
SIGNAL idle_crd_ret_del_d : std_ulogic;
SIGNAL dl_cont_tl_tmpl_d : std_ulogic_vector(5 downto 0);
SIGNAL dl_cont_tl_tmpl_p_d : std_ulogic;
SIGNAL dl_cont_tl_tmpl_q : std_ulogic_vector(5 downto 0);
SIGNAL dl_cont_tl_tmpl_p_q : std_ulogic;
SIGNAL sl_15_ow : std_ulogic;
SIGNAL sl_14_ow : std_ulogic;
SIGNAL sl_13_ow : std_ulogic;
SIGNAL sl_12_ow : std_ulogic;
SIGNAL resp_pop_vld : std_ulogic;
SIGNAL resp_pend : std_ulogic_vector(4 downto 0);
SIGNAL wr_resp_flush_d : std_ulogic;
SIGNAL wr_resp_flush_q : std_ulogic;
SIGNAL fail_resp_pop : std_ulogic;
SIGNAL fail_resp_empty : std_ulogic;
SIGNAL fail_resp_fifo_err : std_ulogic_vector(1 downto 0);
SIGNAL fail_resp_count : std_ulogic_vector(3 downto 0);
SIGNAL tl_4sl_pkt_full_q : std_ulogic;
SIGNAL fail_resp : std_ulogic_vector(55 downto 0);
SIGNAL fail_resp_p : std_ulogic_vector(6 downto 0);
SIGNAL fail_resp_out : std_ulogic_vector(39 downto 0);
SIGNAL bdi_input : std_ulogic_vector(1 downto 0);
SIGNAL bdi_push : std_ulogic;
SIGNAL bdi_pop : std_ulogic;
SIGNAL bdi_output : std_ulogic_vector(1 downto 0);
SIGNAL bdi_empty : std_ulogic;
SIGNAL bdi_full : std_ulogic;
SIGNAL bdi_err : std_ulogic_vector(1 downto 0);
SIGNAL bdi_count : std_ulogic_vector(5 downto 0);
SIGNAL bdi_vld_inc : std_ulogic;
SIGNAL bdi_max_d : std_ulogic_vector(3 downto 0);
SIGNAL bdi_max_q : std_ulogic_vector(3 downto 0);
SIGNAL bdi_vld_q : std_ulogic_vector(3 downto 0);
SIGNAL bdi_vld_p_q : std_ulogic;
SIGNAL bdi_vld_d : std_ulogic_vector(3 downto 0);
SIGNAL bdi_vld_p_d : std_ulogic;
SIGNAL bdi_0_vld : std_ulogic;
SIGNAL bdi_1_vld : std_ulogic;
SIGNAL bdi_2_vld : std_ulogic;
SIGNAL bdi_3_vld : std_ulogic;
SIGNAL bdi_4_vld : std_ulogic;
SIGNAL bdi_5_vld : std_ulogic;
SIGNAL bdi_6_vld : std_ulogic;
SIGNAL bdi_7_vld : std_ulogic;
SIGNAL bdi_vec_d : std_ulogic_vector(7 downto 0);
SIGNAL bdi_vec_p_d : std_ulogic_vector(1 downto 0);
SIGNAL bdi_7 : std_ulogic;
SIGNAL bdi_6 : std_ulogic;
SIGNAL bdi_5 : std_ulogic;
SIGNAL bdi_4 : std_ulogic;
SIGNAL bdi_3 : std_ulogic;
SIGNAL bdi_2 : std_ulogic;
SIGNAL bdi_1 : std_ulogic;
SIGNAL bdi_0 : std_ulogic;
SIGNAL bdi_vec_q : std_ulogic_vector(7 downto 0);
SIGNAL bdi_vec_p_q : std_ulogic_vector(1 downto 0);
SIGNAL tl_4sl_pkt_full_d : std_ulogic;
SIGNAL drl_current : std_ulogic_vector(3 downto 0);
SIGNAL drl_current_p : std_ulogic;
SIGNAL drl_sub0_q : std_ulogic_vector(3 downto 0);
SIGNAL drl_sub0_d : std_ulogic_vector(3 downto 0);
SIGNAL drl_sub1_q : std_ulogic_vector(3 downto 0);
SIGNAL drl_sub1_d : std_ulogic_vector(3 downto 0);
SIGNAL drl_sub2_q : std_ulogic_vector(3 downto 0);
SIGNAL drl_sub2_d : std_ulogic_vector(3 downto 0);
SIGNAL drl_sub3_q : std_ulogic_vector(3 downto 0);
SIGNAL drl_sub3_d : std_ulogic_vector(3 downto 0);
SIGNAL drl_sub0_p_q : std_ulogic;
SIGNAL drl_sub1_p_q : std_ulogic;
SIGNAL drl_sub2_p_q : std_ulogic;
SIGNAL drl_sub3_p_q : std_ulogic;
SIGNAL drl_sub0_p_d : std_ulogic;
SIGNAL drl_sub1_p_d : std_ulogic;
SIGNAL drl_sub2_p_d : std_ulogic;
SIGNAL drl_sub3_p_d : std_ulogic;
SIGNAL tmpl9_drl_inc : std_ulogic;
SIGNAL mmio_data_current : std_ulogic;
SIGNAL mmio_data_sub1_q : std_ulogic;
SIGNAL mmio_data_sub1_d : std_ulogic;
SIGNAL mmio_data_sub0_q : std_ulogic;
SIGNAL mmio_data_sub0_d : std_ulogic;
SIGNAL mmio_data_sub2_q : std_ulogic;
SIGNAL mmio_data_sub3_d : std_ulogic;
SIGNAL mmio_data_sub3_q : std_ulogic;
SIGNAL triplet_999_d : std_ulogic;
SIGNAL triplet_9d9_d : std_ulogic;
SIGNAL triplet_9dd_d : std_ulogic;
SIGNAL triplet_999_q : std_ulogic;
SIGNAL triplet_9d9_q : std_ulogic;
SIGNAL triplet_9dd_q : std_ulogic;
SIGNAL triplet_999 : std_ulogic;
SIGNAL triplet_9d9 : std_ulogic;
SIGNAL triplet_9dd : std_ulogic;
SIGNAL mmio_data_sub2_d : std_ulogic;
SIGNAL ow_in_flit : std_ulogic;
SIGNAL ow_in_flit_hi_lat : std_ulogic;
SIGNAL rdf_data_current : std_ulogic;
SIGNAL rdf_1st_32B_sub1_q : std_ulogic;
SIGNAL rdf_1st_32B_sub1_d : std_ulogic;
SIGNAL rdf_1st_32B_sub0_q : std_ulogic;
SIGNAL rdf_1st_32B_sub0_d : std_ulogic;
SIGNAL rdf_1st_32B_sub2_d : std_ulogic;
SIGNAL rdf_1st_32B_sub2_q : std_ulogic;
SIGNAL rdf_1st_32B_sub3_d : std_ulogic;
SIGNAL rdf_1st_32B_sub3_q : std_ulogic;
SIGNAL rdf_2nd_32B_sub1_q : std_ulogic;
SIGNAL rdf_2nd_32B_sub1_d : std_ulogic;
SIGNAL rdf_2nd_32B_sub0_q : std_ulogic;
SIGNAL rdf_2nd_32B_sub0_d : std_ulogic;
SIGNAL rdf_2nd_32B_sub2_d : std_ulogic;
SIGNAL rdf_2nd_32B_sub2_q : std_ulogic;
SIGNAL rdf_2nd_32B_sub3_d : std_ulogic;
SIGNAL rdf_2nd_32B_sub3_q : std_ulogic;

SIGNAL data_valid_int : std_ulogic;
SIGNAL mmio_data_pending : std_ulogic;
SIGNAL rdf_data_pending : std_ulogic;
SIGNAL metadata_avail : std_ulogic;

SIGNAL ow_bdi_pend_d : std_ulogic;
SIGNAL ow_bdi_pend_q : std_ulogic;
SIGNAL ow_bdi_packed_d : std_ulogic;
SIGNAL ow_bdi_packed_q : std_ulogic;
SIGNAL bdi_ow_pop : std_ulogic;
SIGNAL ow_bdi_buffer_d : std_ulogic;
SIGNAL ow_bdi_buffer_q : std_ulogic;
SIGNAL ow_bdi : std_ulogic;
SIGNAL bdi_bypass_taken_d : std_ulogic;
SIGNAL bdi_bypass_taken_q : std_ulogic;
SIGNAL del_for_drl : std_ulogic;
SIGNAL wr_resp_full : std_ulogic_vector(27 downto 0);
SIGNAL wr_resp_full_p : std_ulogic_vector(7 downto 0);
SIGNAL mmio_resp_full : std_ulogic_vector(27 downto 0);
SIGNAL mmio_resp_full_p : std_ulogic_vector(7 downto 0);
SIGNAL mem_cntl_resp : std_ulogic_vector(27 downto 0);
SIGNAL mem_cntl_resp_p : std_ulogic_vector(7 downto 0);
SIGNAL mem_cntl_resp_opcode : std_ulogic_vector(8 downto 0);
SIGNAL rd_resp_opcode : std_ulogic_vector(8 downto 0);
SIGNAL rd_resp_ow_opcode : std_ulogic_vector(8 downto 0);
SIGNAL wr_resp_opcode : std_ulogic_vector(8 downto 0);
SIGNAL mmio_resp_opcode : std_ulogic_vector(8 downto 0);
SIGNAL mmio_resp_dat_part : std_ulogic_vector(4 downto 0);
SIGNAL wr_resp_pkt : std_ulogic_vector(27 downto 0);
SIGNAL wr_resp_pkt_p : std_ulogic_vector(7 downto 0);
SIGNAL intrp_req_chan_xstop_d : std_ulogic_vector(2 downto 0);
SIGNAL intrp_req_chan_xstop_reset : std_ulogic;
SIGNAL intrp_req_chan_xstop_pend : std_ulogic;
SIGNAL intrp_req_chan_xstop_pack : std_ulogic;
SIGNAL intrp_req_chan_xstop_sent : std_ulogic;
SIGNAL intrp_req_chan_xstop_2nd : std_ulogic;
SIGNAL intrp_req_rec_attn_d : std_ulogic_vector(2 downto 0);
SIGNAL intrp_req_rec_attn_reset : std_ulogic;
SIGNAL intrp_req_rec_attn_pend : std_ulogic;
SIGNAL intrp_req_rec_attn_pack : std_ulogic;
SIGNAL intrp_req_rec_attn_sent : std_ulogic;
SIGNAL intrp_req_rec_attn_2nd : std_ulogic;
SIGNAL intrp_req_sp_attn_d : std_ulogic_vector(2 downto 0);
SIGNAL intrp_req_sp_attn_reset : std_ulogic;
SIGNAL intrp_req_sp_attn_pend : std_ulogic;
SIGNAL intrp_req_sp_attn_pack : std_ulogic;
SIGNAL intrp_req_sp_attn_sent : std_ulogic;
SIGNAL intrp_req_sp_attn_2nd : std_ulogic;
SIGNAL intrp_req_app_intrp_d : std_ulogic_vector(2 downto 0);
SIGNAL intrp_req_app_intrp_reset : std_ulogic;
SIGNAL intrp_req_app_intrp_pend : std_ulogic;
SIGNAL intrp_req_app_intrp_pack : std_ulogic;
SIGNAL intrp_req_app_intrp_sent : std_ulogic;
SIGNAL intrp_req_app_intrp_2nd : std_ulogic;
SIGNAL intrp_req_chan_xstop_q : std_ulogic_vector(2 downto 0);
SIGNAL intrp_req_rec_attn_q : std_ulogic_vector(2 downto 0);
SIGNAL intrp_req_sp_attn_q : std_ulogic_vector(2 downto 0);
SIGNAL intrp_req_app_intrp_q : std_ulogic_vector(2 downto 0);
SIGNAL intrp_req_pop : std_ulogic;
SIGNAL intrp_req_pend : std_ulogic;
SIGNAL intrp_req_p_tag : std_ulogic_vector(4 downto 0);
SIGNAL intrp_req_cmd_flag : std_ulogic_vector(3 downto 0);
SIGNAL intrp_req_cmd_flag_p : std_ulogic;
SIGNAL intrp_req_opcode : std_ulogic_vector(8 downto 0);
SIGNAL afu_tag : std_ulogic_vector(15 downto 0);
SIGNAL afu_tag_p : std_ulogic;
SIGNAL handle_0_p : std_ulogic_vector(8 downto 0);
SIGNAL handle_1_p : std_ulogic_vector(8 downto 0);
SIGNAL handle_2_p : std_ulogic_vector(8 downto 0);
SIGNAL handle_3_p : std_ulogic_vector(8 downto 0);
SIGNAL obj_handle_withp : std_ulogic_vector(72 downto 0);
SIGNAL stream_id : std_ulogic_vector(3 downto 0);
SIGNAL intrp_req : std_ulogic_vector(111 downto 0);
SIGNAL intrp_req_p : std_ulogic_vector(13 downto 0);
SIGNAL intrp_req_packed : std_ulogic;
SIGNAL meta_fifo_pop_int : std_ulogic;
SIGNAL bdi_pop_int : std_ulogic;
SIGNAL flit_xmit_start_t5_q : std_ulogic;
SIGNAL flit_xmit_start_t6_q : std_ulogic;
SIGNAL flit_xmit_start_t7_q : std_ulogic;
SIGNAL flit_xmit_start_t5_d : std_ulogic;
SIGNAL flit_xmit_start_t6_d : std_ulogic;
SIGNAL flit_xmit_start_t7_d : std_ulogic;
SIGNAL mmio_data_flit_d : std_ulogic;
SIGNAL mmio_data_flit_q : std_ulogic;
SIGNAL mmio_data_flit_del_d : std_ulogic;
SIGNAL mmio_data_flit_del_q : std_ulogic; 
SIGNAL xmit_rate_stall_dec : std_ulogic;
SIGNAL tmpl0_xmit_rate : std_ulogic_vector(5 downto 0);
SIGNAL tmpl1_xmit_rate : std_ulogic_vector(5 downto 0);
SIGNAL tmpl2_xmit_rate : std_ulogic_vector(5 downto 0);
SIGNAL tmpl3_xmit_rate : std_ulogic_vector(5 downto 0);
SIGNAL tmpl4_xmit_rate : std_ulogic_vector(5 downto 0);
SIGNAL tmpl5_xmit_rate : std_ulogic_vector(5 downto 0);
SIGNAL tmpl6_xmit_rate : std_ulogic_vector(5 downto 0);
SIGNAL tmpl7_xmit_rate : std_ulogic_vector(5 downto 0);
SIGNAL tmpl8_xmit_rate : std_ulogic_vector(5 downto 0);
SIGNAL tmpl9_xmit_rate : std_ulogic_vector(5 downto 0);
SIGNAL tmpla_xmit_rate : std_ulogic_vector(5 downto 0);
SIGNAL tmplb_xmit_rate : std_ulogic_vector(5 downto 0);
SIGNAL xmit_rate_stall_max : std_ulogic_vector(5 downto 0);
SIGNAL xmit_rate_stall_q : std_ulogic_vector(5 downto 0);
SIGNAL xmit_rate_stall_d : std_ulogic_vector(5 downto 0);
SIGNAL assign_actag_packed : std_ulogic;
SIGNAL assign_actag_sent : std_ulogic;
SIGNAL assign_actag_sent_d : std_ulogic;
SIGNAL assign_actag_sent_q : std_ulogic;
SIGNAL assign_actag_pend : std_ulogic;
SIGNAL actag_sent_q : std_ulogic_vector(1 downto 0);
SIGNAL actag_sent_d : std_ulogic_vector(1 downto 0);
SIGNAL actag_d : std_ulogic_vector(11 downto 0);
SIGNAL actag_p_d : std_ulogic_vector(3 downto 0);
SIGNAL bdf : std_ulogic_vector(15 downto 0);
SIGNAL bdf_p : std_ulogic_vector(2 downto 0);
SIGNAL pasid : std_ulogic_vector(19 downto 0);
SIGNAL pasid_p : std_ulogic_vector(2 downto 0);
SIGNAL assign_actag : std_ulogic_vector(55 downto 0);
SIGNAL assign_actag_p : std_ulogic_vector(6 downto 0);
SIGNAL actag_q : std_ulogic_vector(11 downto 0);
SIGNAL actag_p_q : std_ulogic_vector(3 downto 0);
SIGNAL mmio_drl_q : std_ulogic_vector(3 downto 0);
SIGNAL mmio_drl_p_q : std_ulogic;
SIGNAL mmio_drl_d : std_ulogic_vector(3 downto 0);
SIGNAL mmio_drl_p_d : std_ulogic;
SIGNAL rd_resp_syndrome : std_ulogic_vector(5 downto 0);
SIGNAL rd_resp_out_corr : std_ulogic_vector(19 downto 0);
SIGNAL rd_resp_corrected : std_ulogic_vector(17 downto 0);
SIGNAL rd_resp_corrected_17_12_p : std_ulogic;
SIGNAL rd_resp_corrected_11_4_p : std_ulogic;
SIGNAL rd_resp_corrected_3_0_p : std_ulogic;
SIGNAL rd_resp_corrected_17_16_p : std_ulogic;
SIGNAL rd_resp_corrected_15_8_p : std_ulogic;
SIGNAL rd_resp_corrected_7_0_p : std_ulogic;
SIGNAL mmio_resp_syndrome : std_ulogic_vector(5 downto 0);
SIGNAL mmio_resp_out_corr : std_ulogic_vector(19 downto 0);
SIGNAL mmio_resp_corrected : std_ulogic_vector(17 downto 0);
SIGNAL mmio_resp_corrected_16_9_p : std_ulogic;
SIGNAL mmio_resp_corrected_16_13_p : std_ulogic;
SIGNAL mmio_resp_corrected_12_5_p : std_ulogic;
SIGNAL mmio_resp_corrected_8_1_p : std_ulogic;
SIGNAL mmio_resp_corrected_4_1_p : std_ulogic;
SIGNAL triplet_state_change_valid : std_ulogic;
SIGNAL triplet_state_advance : std_ulogic;
SIGNAL triplet_state_1_1 : std_ulogic;
SIGNAL triplet_state_q : std_ulogic_vector(2 downto 0);
SIGNAL triplet_state_2_2 : std_ulogic;
SIGNAL triplet_state_d : std_ulogic_vector(2 downto 0);
SIGNAL drl_1_in_pipe_d : std_ulogic;
SIGNAL drl_2_in_pipe_d : std_ulogic;
SIGNAL drl_1_in_pipe_q : std_ulogic;
SIGNAL drl_2_in_pipe_q : std_ulogic;
SIGNAL drl_in_pipe : std_ulogic;
SIGNAL triplet_9dd_rd_pop_vld : std_ulogic;
SIGNAL triplet_9d9_rd_pop_vld : std_ulogic;
SIGNAL triplet_ow_rd_pop_vld : std_ulogic;
SIGNAL triplet_state_3_2 : std_ulogic;
SIGNAL triplet_state_3_3 : std_ulogic;
SIGNAL triplet_state_2_1 : std_ulogic;
SIGNAL triplet_state_1_0 : std_ulogic;
SIGNAL triplet_state_0_0 : std_ulogic;
SIGNAL triplet_state_0_2 : std_ulogic;
SIGNAL triplet_state_0_3 : std_ulogic;
SIGNAL rd_idle : std_ulogic;
SIGNAL triplet_9dd_valid_flit : std_ulogic;
SIGNAL idle_crd_ret_tmr_d : std_ulogic_vector(5 downto 0);
SIGNAL idle_crd_ret_tmr_p_d : std_ulogic;
SIGNAL idle_crd_ret_tmr_q : std_ulogic_vector(5 downto 0);
SIGNAL idle_crd_ret_tmr_p_q : std_ulogic;
SIGNAL flit_full_start : std_ulogic;
SIGNAL idle_start : std_ulogic;
SIGNAL data_flit_crc_start : std_ulogic;
SIGNAL triplet_flow_start : std_ulogic;
SIGNAL triplet_wait_for_data_start : std_ulogic;
SIGNAL triplet_data_valid_start : std_ulogic;
SIGNAL triplet_mmio_start : std_ulogic;
SIGNAL write_flush_start : std_ulogic;
SIGNAL force_tmpl_switch_start : std_ulogic;
SIGNAL intrp_req_start : std_ulogic;
SIGNAL all_meta_packed : std_ulogic;
SIGNAL meta_max_not_reached : std_ulogic;
SIGNAL max_bw_ip : std_ulogic;
SIGNAL triplet_advance_start : std_ulogic;
SIGNAL rdf_data_pending_max_bw : std_ulogic;
SIGNAL ow_bdi_valid_flit : std_ulogic;
SIGNAL metadata_disabled : std_ulogic;
SIGNAL flit_buffer_reset : std_ulogic;
SIGNAL meta_fifo_data_flit_pop_vld : std_ulogic;
SIGNAL rdf_1st_32B_current : std_ulogic;
SIGNAL rdf_2nd_32B_current : std_ulogic;
SIGNAL hi_bw_threshold_int : std_ulogic_vector(5 downto 0);
SIGNAL mid_bw_threshold_int : std_ulogic_vector(5 downto 0);
SIGNAL hi_bw_rd_threshold : std_ulogic_vector(5 downto 0);
SIGNAL hi_bw_enab_rd_thresh_int : std_ulogic;
SIGNAL tlx_vc0_avail : std_ulogic;
SIGNAL tlx_dcp0_avail : std_ulogic;
SIGNAL tlx_vc3_avail : std_ulogic;
SIGNAL mmio_resp_pop_tmpl9 : std_ulogic;
SIGNAL mmio_resp_pop_tmpl9_low_lat : std_ulogic;
SIGNAL mmio_resp_pop_64B : std_ulogic;
SIGNAL mmio_resp_pop_common : std_ulogic;
SIGNAL meta_thresh_val : std_ulogic;
SIGNAL triplet_bypass_start : std_ulogic;
SIGNAL rd_resp_pop_hi_lat : std_ulogic;
SIGNAL rd_resp_pop_tmpl9 : std_ulogic;
SIGNAL rd_resp_pop_int : std_ulogic;
SIGNAL bdi_avail : std_ulogic;
SIGNAL drl_high_lat_q : std_ulogic_vector(3 downto 0);
SIGNAL drl_high_lat_p_q : std_ulogic;
SIGNAL drl_high_lat_inc : std_ulogic;
SIGNAL drl_high_lat_d : std_ulogic_vector(3 downto 0);
SIGNAL drl_high_lat_p_d : std_ulogic;
SIGNAL rd_resp_half_full : std_ulogic;
SIGNAL rd_resp_qt_full : std_ulogic;
SIGNAL wr_resp_half_full : std_ulogic;
SIGNAL fail_resp_half_full : std_ulogic;
SIGNAL tmpl0_1_5_9_B_dis : std_ulogic;
SIGNAL tmpl0_init_cred : std_ulogic;
SIGNAL tmpl0_intrp_req : std_ulogic;
SIGNAL tmpl0_half_dimm_intrp : std_ulogic;
SIGNAL tmpl1_tmpl5_tmpl9_dis : std_ulogic;
SIGNAL tmpl1_fail_flush : std_ulogic;
SIGNAL tmpl1_intrp : std_ulogic;
SIGNAL tmpl5_tmpl9_dis : std_ulogic;
SIGNAL tmpl5_wr_flush : std_ulogic;
SIGNAL tmpl5_intrp : std_ulogic;
SIGNAL tmpl5_hi_lat_def : std_ulogic;
SIGNAL tmpl9_idle : std_ulogic;
SIGNAL tmpl9_low_lat_def : std_ulogic;
SIGNAL tmpl9_hi_lat_def : std_ulogic;
SIGNAL tmpl9_hi_lat_mmio : std_ulogic;
SIGNAL tmpl9_ow_pend : std_ulogic;
SIGNAL tmpl9_low_lat_dat_pend : std_ulogic;
SIGNAL tmpl9_low_lat_mmio_pend : std_ulogic;
SIGNAL tmpl9_triplet_dat : std_ulogic;
SIGNAL tmpl9_wr_flush_ow_mmio_pend : std_ulogic;
SIGNAL hi_lat_read_start : std_ulogic;
SIGNAL hi_lat_start_del_q : std_ulogic;
SIGNAL hi_lat_start_del_d : std_ulogic;
SIGNAL mmio_data_flit_pend_d : std_ulogic;
SIGNAL mmio_data_flit_pend_q : std_ulogic;
SIGNAL wr_resp_syndrome : std_ulogic_vector(5 downto 0);
SIGNAL wr_resp_out_corr : std_ulogic_vector(22 downto 0);
SIGNAL wr_resp_corrected : std_ulogic_vector(20 downto 0);
SIGNAL wr_resp_corrected_20_13_p : std_ulogic;
SIGNAL wr_resp_corrected_18_17_p : std_ulogic;
SIGNAL wr_resp_corrected_18_13_p : std_ulogic;
SIGNAL wr_resp_corrected_12_5_p : std_ulogic;
SIGNAL wr_resp_corrected_4_1_p : std_ulogic;
SIGNAL wr_resp_corrected_20_17_p : std_ulogic;
SIGNAL wr_resp_corrected_16_9_p : std_ulogic;
SIGNAL wr_resp_corrected_8_1_p : std_ulogic;
SIGNAL fail_resp_syndrome : std_ulogic_vector(7 downto 0);
SIGNAL fail_resp_out_corr : std_ulogic_vector(33 downto 0);
SIGNAL fail_resp_corrected : std_ulogic_vector(31 downto 0);
SIGNAL fail_resp_corrected_31_28_p : std_ulogic;
SIGNAL fail_resp_corrected_27_24_p : std_ulogic;
SIGNAL fail_resp_corrected_23_0_p : std_ulogic_vector(2 downto 0);
SIGNAL meta_fifo_input_ecc : std_ulogic_vector(10 downto 0);
SIGNAL meta_fifo_syndrome : std_ulogic_vector(4 downto 0);
SIGNAL meta_fifo_out_corr : std_ulogic_vector(7 downto 0);
SIGNAL meta_fifo_corrected : std_ulogic_vector(5 downto 0);
SIGNAL meta_fifo_corrected_p : std_ulogic;
SIGNAL meta_fifo_corr_p_54 : std_ulogic;
SIGNAL meta_fifo_corr_p_40 : std_ulogic;
SIGNAL meta_fifo_corr_p_53 : std_ulogic;
SIGNAL meta_fifo_corr_p_30 : std_ulogic;
SIGNAL meta_fifo_corr_p_52 : std_ulogic;
SIGNAL meta_fifo_corr_p_20 : std_ulogic;
SIGNAL meta_fifo_corr_p_51 : std_ulogic;
SIGNAL meta_fifo_corr_p_10 : std_ulogic;
SIGNAL fail_resp_input_ecc : std_ulogic_vector(39 downto 0);
SIGNAL bdi_par_err : std_ulogic;
SIGNAL bdi_out : std_ulogic;
SIGNAL rd_resp_ce : std_ulogic;
SIGNAL rd_resp_ue : std_ulogic;
SIGNAL wr_resp_ce : std_ulogic;
SIGNAL wr_resp_ue : std_ulogic;
SIGNAL mmio_resp_ce : std_ulogic;
SIGNAL mmio_resp_ue : std_ulogic;
SIGNAL fail_resp_ce : std_ulogic;
SIGNAL fail_resp_ue : std_ulogic;
SIGNAL meta_fifo_ce : std_ulogic;
SIGNAL meta_fifo_ue : std_ulogic;
SIGNAL mq_55_49 : std_ulogic;
SIGNAL mq_48_48 : std_ulogic;
SIGNAL mq_47_42 : std_ulogic;
SIGNAL mq_41_40 : std_ulogic;
SIGNAL mq_39_35 : std_ulogic;
SIGNAL mq_34_32 : std_ulogic;
SIGNAL mq_31_28 : std_ulogic;
SIGNAL mq_27_24 : std_ulogic;
SIGNAL mq_23_21 : std_ulogic;
SIGNAL mq_20_16 : std_ulogic;
SIGNAL mq_15_14 : std_ulogic;
SIGNAL mq_13_8 : std_ulogic;
SIGNAL mq_7_7 : std_ulogic;
SIGNAL mq_6_0 : std_ulogic;
SIGNAL mfp_48_48 : std_ulogic;
SIGNAL mfp_55_49 : std_ulogic;
SIGNAL mfp_41_40 : std_ulogic;
SIGNAL mfp_47_42 : std_ulogic;
SIGNAL mfp_34_32 : std_ulogic;
SIGNAL mfp_39_35 : std_ulogic;
SIGNAL mfp_27_24 : std_ulogic;
SIGNAL mfp_31_28 : std_ulogic;
SIGNAL mfp_20_16 : std_ulogic;
SIGNAL mfp_23_21 : std_ulogic;
SIGNAL mfp_13_8 : std_ulogic;
SIGNAL mfp_15_14 : std_ulogic;
SIGNAL mfp_6_0 : std_ulogic;
SIGNAL mfp_7_7 : std_ulogic;
SIGNAL mbp_13_8 : std_ulogic;
SIGNAL mbp_6_0 : std_ulogic;
SIGNAL mbp_7_7 : std_ulogic;
SIGNAL act_hi_lat_mode : std_ulogic;
SIGNAL hi_lat_mode : std_ulogic;
SIGNAL act_mmio_buf : std_ulogic;
SIGNAL act_flit_buf_1st_half : std_ulogic;
SIGNAL intrp_req_chan_xstop_retry : std_ulogic;
SIGNAL intrp_req_rec_attn_retry : std_ulogic;
SIGNAL intrp_req_sp_attn_retry : std_ulogic;
SIGNAL intrp_req_app_intrp_retry : std_ulogic;
SIGNAL flit_buffer_2nd_half_6_0_p : std_ulogic;
SIGNAL act_low_lat_mode : std_ulogic;
SIGNAL act_init_cred_ret : std_ulogic;
SIGNAL cred_ret_4sl : std_ulogic;
SIGNAL mmio_bdi_d : std_ulogic_vector(1 downto 0);
SIGNAL mmio_bdi_q : std_ulogic_vector(1 downto 0);
SIGNAL mmio_bdi_poisoned : std_ulogic;
SIGNAL mmio_bdi : std_ulogic;
SIGNAL mmio_ow_bdi_d : std_ulogic_vector(1 downto 0);
SIGNAL mmio_ow_bdi_q : std_ulogic_vector(1 downto 0);
SIGNAL mmio_ow_bdi_poisoned : std_ulogic;
SIGNAL mmio_ow_bdi : std_ulogic;
signal rd_resp_unrec_stall_d : std_ulogic;
signal rd_resp_unrec_stall_q : std_ulogic;
signal crd_ret_packed_d : std_ulogic;
signal crd_ret_packed_q : std_ulogic;
signal crd_ret_sent_sl_12 : std_ulogic;
signal crd_ret_sent_sl_10 : std_ulogic;
signal crd_ret_sent_sl_0 : std_ulogic;
SIGNAL sp_meta_load : std_ulogic;
SIGNAL sp_meta_keep : std_ulogic;
SIGNAL mm_data_load : std_ulogic;
SIGNAL mm_data_keep : std_ulogic;
signal intrp_req_chan_xstop_failed : std_ulogic;
signal intrp_req_rec_attn_failed  :std_ulogic;
signal intrp_req_sp_attn_failed   :std_ulogic;
signal intrp_req_app_intrp_failed : std_ulogic;
signal unexp_chan_xstop_resp : std_ulogic;
signal unexp_rec_attn_resp : std_ulogic;
signal unexp_sp_attn_resp :std_ulogic;
signal unexp_app_intrp_resp :std_ulogic;
SIGNAL fail_resp_flush_d : std_ulogic;
SIGNAL fail_resp_flush_q : std_ulogic;
signal rd_resp_low_lat_stall_d : std_ulogic;
signal rd_resp_low_lat_stall_q : std_ulogic;
signal tmpl9_hi_lat_32B_rd : std_ulogic;
signal rd_resp_ow_pop_low_lat : std_ulogic;
signal rd_resp_ow_pop_hi_lat : std_ulogic;
SIGNAL null_flit_next_d : std_ulogic;
SIGNAL null_flit_next_q : std_ulogic;
SIGNAL drl_less_than_xmit_rate : std_ulogic;
SIGNAL xmit_rate_current : std_ulogic_vector(3 DOWNTO 0);
signal wr_resp_unrec_stall_d : std_ulogic;
signal wr_resp_unrec_stall_q : std_ulogic;
signal fail_resp_unrec_stall_d : std_ulogic;
signal fail_resp_unrec_stall_q : std_ulogic;
SIGNAL null_flit_next_start : std_ulogic;
SIGNAL mux_1st_qw : std_ulogic;
SIGNAL fail_resp_flush_start : std_ulogic;
signal crd_ret_taken_d : std_ulogic;
signal crd_ret_taken_q : std_ulogic;
SIGNAL triplet_rd_resp_stall_start : std_ulogic;
SIGNAL triplet_9dd_drop_q : std_ulogic;
SIGNAL triplet_9dd_drop_d : std_ulogic;
SIGNAL flit_xmit_start_d : std_ulogic;
SIGNAL flit_xmit_start_q : std_ulogic;
SIGNAL data_flit_xmit_int : std_ulogic;
SIGNAL flit_xmit_start_pulse : std_ulogic;
SIGNAL idle_start_block : std_ulogic;
SIGNAL idle_start_gated : std_ulogic;
SIGNAL flit_cyc_cnt_d : std_ulogic_vector(4 downto 0);
SIGNAL flit_cyc_cnt_q : std_ulogic_vector(4 downto 0);
SIGNAL drl_current_1 : std_ulogic;
SIGNAL drl_current_2 : std_ulogic;
SIGNAL drl_last_non_zero : std_ulogic;
SIGNAL data_flit_cnt_d : std_ulogic_vector(7 downto 0);
SIGNAL data_flit_cnt_q : std_ulogic_vector(7 downto 0);
SIGNAL tmplB_chosen : std_ulogic;
SIGNAL tmplB : std_ulogic;
SIGNAL mmio_resp_d : std_ulogic_vector(23 downto 0);
SIGNAL mmio_resp_q : std_ulogic_vector(23 downto 0);
SIGNAL mmio_resp_pend_d : std_ulogic;
SIGNAL mmio_resp_pend_q : std_ulogic;
SIGNAL tmpl_chosen_multi : std_ulogic;
SIGNAL tmpl_chosen_no_new : std_ulogic;
SIGNAL bdi_fifo_unrec_d : std_ulogic;
SIGNAL meta_fifo_unrec_d : std_ulogic;
SIGNAL bdi_fifo_unrec_q : std_ulogic;
SIGNAL meta_fifo_unrec_q : std_ulogic;
SIGNAL meta_ue_poison_next_d : std_ulogic_vector(7 downto 0);
SIGNAL meta_ue_poison_next_q : std_ulogic_vector(7 downto 0);
SIGNAL meta_ue_poison_curr_d : std_ulogic_vector(7 downto 0);
SIGNAL meta_ue_poison_curr_q : std_ulogic_vector(7 downto 0);
SIGNAL tlxt_err_invalid_cfg_d : std_ulogic;
SIGNAL tlxt_err_invalid_cfg_q : std_ulogic;
SIGNAL tlxt_err_invalid_meta_cfg_d : std_ulogic;
SIGNAL tlxt_err_invalid_meta_cfg_q : std_ulogic;
SIGNAL bdi_poisoned : std_ulogic;
SIGNAL flit_cyc_gate : std_ulogic;
SIGNAL bypass_meta_fifo : std_ulogic;
SIGNAL rd_resp_exit0_block_dec : std_ulogic;
SIGNAL rd_resp_exit0_block_d : std_ulogic_vector(2 downto 0);
SIGNAL rd_resp_exit0_block_q : std_ulogic_vector(2 downto 0);
SIGNAL rd_resp_exit0_gate_d : std_ulogic;
SIGNAL rd_resp_exit0_gate_q : std_ulogic;
SIGNAL rd_resp_exit0_gate : std_ulogic;
SIGNAL drl_sub2_val_d : std_ulogic;
SIGNAL drl_sub2_val_q : std_ulogic;
SIGNAL drl_sub1_val_q : std_ulogic;
SIGNAL drl_sub1_val_d : std_ulogic;
SIGNAL meta_fifo_empty_d : std_ulogic;
SIGNAL meta_fifo_empty_q : std_ulogic;
SIGNAL bdi_fifo_empty_d : std_ulogic;
SIGNAL bdi_fifo_empty_q : std_ulogic;
SIGNAL rd_resp_empty_d : std_ulogic;
SIGNAL rd_resp_empty_q : std_ulogic;
SIGNAL wr_resp_empty_d : std_ulogic;
SIGNAL wr_resp_empty_q : std_ulogic;
SIGNAL fail_resp_empty_d : std_ulogic;
SIGNAL fail_resp_empty_q : std_ulogic;
SIGNAL drl_prev_val_q : std_ulogic;
SIGNAL drl_prev_val_d : std_ulogic;
SIGNAL enable_asserts : std_ulogic;
SIGNAL tmpl5_flit_sub1_q : std_ulogic;
SIGNAL tmpl5_flit_sub1_d : std_ulogic;
SIGNAL tmpl5_flit_sub0_q : std_ulogic;
SIGNAL tmpl5_flit_sub0_d : std_ulogic;
SIGNAL tmpl5_flit_sub2_q : std_ulogic;
SIGNAL tmpl5_flit_sub2_d : std_ulogic;
SIGNAL tmpl5_flit_pend : std_ulogic;
SIGNAL tmpl5_low_lat : std_ulogic;
SIGNAL tmpl5_flit_rd_gate : std_ulogic;
SIGNAL tmpl0_assign_actag : std_ulogic;
SIGNAL assign_actag_pop : std_ulogic;
SIGNAL rdf_tlxt_data_err_d : std_ulogic;
SIGNAL rdf_tlxt_data_err_q : std_ulogic;
SIGNAL flit_xmit_done_d : std_ulogic;
SIGNAL flit_xmit_done_q : std_ulogic;
SIGNAL data_err_late : std_ulogic;
SIGNAL data_err_late_p : std_ulogic;
SIGNAL triplet_state_val_d : std_ulogic;
SIGNAL triplet_state_val_q : std_ulogic;
SIGNAL fail_resp_pop_d : std_ulogic;
SIGNAL fail_resp_pop_q : std_ulogic;
SIGNAL intrp_req_pop_q : std_ulogic;
SIGNAL intrp_req_pop_d : std_ulogic;
SIGNAL assign_actag_pop_q : std_ulogic;
SIGNAL assign_actag_pop_d : std_ulogic;
SIGNAL non_main_gate_q : std_ulogic;
signal non_main_gate_d : std_ulogic;
SIGNAL rd_pend_gate_q : std_ulogic;
signal rd_pend_gate_d : std_ulogic;
SIGNAL act_tmpl5_enab : std_ulogic;
SIGNAL rd_resp_len32 : std_ulogic;
SIGNAL drl_max_hit : std_ulogic;
SIGNAL drl_max_start : std_ulogic;
SIGNAL rdf_40B_start : std_ulogic;
SIGNAL mmio_40B_start : std_ulogic;
SIGNAL rdf_40B_current : std_ulogic;
SIGNAL rdf_40B_sub1_q : std_ulogic;
SIGNAL rdf_40B_sub1_d : std_ulogic;
SIGNAL rdf_40B_sub0_q : std_ulogic;
SIGNAL rdf_40B_sub0_d : std_ulogic;
SIGNAL rdf_40B_sub2_d : std_ulogic;
SIGNAL rdf_40B_sub2_q : std_ulogic;
SIGNAL mmio_40B_sub1_q : std_ulogic;
SIGNAL mmio_40B_sub1_d : std_ulogic;
SIGNAL mmio_40B_sub0_q : std_ulogic;
SIGNAL mmio_40B_sub0_d : std_ulogic;
SIGNAL mmio_40B_sub2_d : std_ulogic;
SIGNAL mmio_40B_sub2_q : std_ulogic;
SIGNAL act_half_dimm : std_ulogic;
SIGNAL ow_in_flit_half_dimm : std_ulogic;
SIGNAL half_dimm_state_advance : std_ulogic;
SIGNAL rd_resp_pop_half_dimm : std_ulogic;
SIGNAL mmio_resp_pop_half_dimm : std_ulogic;
signal rd_resp_half_dimm_stall_d : std_ulogic_vector(3 downto 0);
SIGNAL rd_resp_half_dimm_stall_q : std_ulogic_vector(3 downto 0);
signal rd_resp_half_dimm_stall_one_d : std_ulogic;
SIGNAL rd_resp_half_dimm_stall_one_q : std_ulogic;
SIGNAL rd_resp_half_dimm_stall_dec : std_ulogic;
SIGNAL tmpl5_intrp_opt_val_d : std_ulogic;
SIGNAL tmpl5_intrp_opt_val_q : std_ulogic;
SIGNAL half_dimm_meta : std_ulogic_vector(27 downto 0);
SIGNAL half_dimm_meta_p : std_ulogic_vector(6 downto 0);
SIGNAL bdi_tmplB_pop : std_ulogic;
SIGNAL tl_1sl_packed_d : std_ulogic_vector(11 downto 0);
SIGNAL tl_1sl_packed_q : std_ulogic_vector(11 downto 0);
SIGNAL flit_xmit_start_t2_del_pulse_d : std_ulogic;
SIGNAL flit_xmit_start_t2_del_pulse_q : std_ulogic;
SIGNAL tmpl0_flit_sub1_q : std_ulogic;
SIGNAL tmpl0_flit_sub1_d : std_ulogic;
SIGNAL tmpl0_flit_sub0_q : std_ulogic;
SIGNAL tmpl0_flit_sub0_d : std_ulogic;
SIGNAL tmpl0_flit_pend : std_ulogic;
SIGNAL half_dimm_start : std_ulogic;
SIGNAL actag_start : std_ulogic;
SIGNAL crd_ret_tmpl0 : std_ulogic;
SIGNAL crd_ret_tmpl1 : std_ulogic;
SIGNAL crd_ret_tmpl5 : std_ulogic;
SIGNAL crd_ret_tmpl9 : std_ulogic;
SIGNAL crd_ret_tmplB : std_ulogic;
SIGNAL assign_actag_gate_d : std_ulogic;
SIGNAL assign_actag_gate_q : std_ulogic;
SIGNAL mmio_resp_pop_load : std_ulogic;
SIGNAL mmio_resp_pop_int : std_ulogic;
SIGNAL tlxt_err_invalid_tmpl_cfg_d : std_ulogic;
SIGNAL tlxt_err_invalid_tmpl_cfg_q : std_ulogic;
SIGNAL rd_stall_ll_or_hd : std_ulogic;
SIGNAL multiple_intrp_pend : std_ulogic;
SIGNAL tmpl_no_longer_valid : std_ulogic;
SIGNAL all_fifo_empty : std_ulogic;
SIGNAL all_1sl_fifo_empty : std_ulogic;
SIGNAL all_fifo_empty_start : std_ulogic;
SIGNAL non_crit_start_d : std_ulogic;
SIGNAL non_crit_start_q : std_ulogic;
SIGNAL rdf_tlxt_data_err_ow_q : std_ulogic;
SIGNAL rdf_tlxt_data_err_ow_d : std_ulogic;
SIGNAL tmpl5_flit_add_cyc : std_ulogic;
SIGNAL rd_resp_len32_flit_d : std_ulogic;
SIGNAL rd_resp_len32_flit_q : std_ulogic;
SIGNAL lane_width_d : std_ulogic_vector(1 downto 0);
SIGNAL lane_width_q : std_ulogic_vector(1 downto 0);
SIGNAL low_lat_degrade_d : std_ulogic;
SIGNAL low_lat_degrade_q : std_ulogic;
SIGNAL lane_width_transition : std_ulogic;
signal rd_resp_degrade_stall_d : std_ulogic_vector(3 downto 0);
SIGNAL rd_resp_degrade_stall_q : std_ulogic_vector(3 downto 0);
signal rd_resp_degrade_stall_one_d : std_ulogic;
SIGNAL rd_resp_degrade_stall_one_q : std_ulogic;
SIGNAL rd_resp_degrade_stall_dec : std_ulogic;
SIGNAL act_low_lat_deg_mode : std_ulogic;
SIGNAL rd_resp_len32_flit_del_d : std_ulogic;  
SIGNAL rd_resp_len32_flit_del_q : std_ulogic;   
SIGNAL rd_resp_len32_flit_pend_d : std_ulogic;  
SIGNAL rd_resp_len32_flit_pend_q : std_ulogic;  
SIGNAL intrp_req_app_intrp_missed_edge_d : std_ulogic;
SIGNAL intrp_req_app_intrp_missed_edge_q : std_ulogic;
SIGNAL intrp_req_chan_xstop_missed_edge_d : std_ulogic;
SIGNAL intrp_req_chan_xstop_missed_edge_q : std_ulogic;
SIGNAL intrp_req_rec_attn_missed_edge_d : std_ulogic;
SIGNAL intrp_req_rec_attn_missed_edge_q : std_ulogic;
SIGNAL intrp_req_sp_attn_missed_edge_d : std_ulogic;
SIGNAL intrp_req_sp_attn_missed_edge_q : std_ulogic;
SIGNAL tmpl9_opt_val_d : std_ulogic;
SIGNAL tmpl9_opt_val_q : std_ulogic;
SIGNAL intrp_req_app_intrp_p_d : std_ulogic;
SIGNAL intrp_req_app_intrp_p_q : std_ulogic;
SIGNAL intrp_req_chan_xstop_p_d : std_ulogic;
SIGNAL intrp_req_chan_xstop_p_q : std_ulogic;
SIGNAL intrp_req_rec_attn_p_d : std_ulogic;
SIGNAL intrp_req_rec_attn_p_q : std_ulogic;
SIGNAL intrp_req_sp_attn_p_d : std_ulogic;
SIGNAL intrp_req_sp_attn_p_q : std_ulogic;
SIGNAL intrp_req_sp_attn_perr : std_ulogic;
signal intrp_req_app_intrp_perr : std_ulogic;
SIGNAL intrp_req_rec_attn_perr : std_ulogic;
SIGNAL intrp_req_chan_xstop_perr : std_ulogic;
SIGNAL opencapi_link_shutdown_d : std_ulogic;
SIGNAL opencapi_link_shutdown_q : std_ulogic;
SIGNAL force_tmpl0 : std_ulogic;
SIGNAL tl_2sl_4sl_pkt_full_p_d : std_ulogic;
SIGNAL tl_2sl_4sl_pkt_full_p_q : std_ulogic;
SIGNAL tl_2sl_4sl_pkt_full_perr : std_ulogic;



  -- Create 7 byte parity bits, from 3.5 byte 1sl, flit buffer parity, and two awkward middle flit buffer nibbles
  -- tl_1sl_pkt_p 7:4 is P over 1sl_pkt 27:20, 19:12, 11:4, 3:0
  -- tl_1sl_pkt_p 3:0 is P over 1sl_pkt 27:24, 23:16, 15:8, 7:0
  function MERGE_1SL_P(tl_1sl_pkt_p  : std_ulogic_vector(7 downto 0);       -- Byte parity on 1slot packet, in two flavours
                       flit_buffer_p : std_ulogic_vector(6 downto 0);       -- Buffer byte parity, covering odd and even slots
                       flit_buffer   : std_ulogic_vector(31 downto 24);     -- Buffer data, for the annoying middle byte, for byte parity adjustment
                       pkt_vld_1sl   : std_ulogic_vector(1 downto 0))       -- Which half to put 1slot packet in (or neither)
           return std_ulogic_vector is
  variable pleft,pright,result : std_ulogic_vector(6 downto 0);
  begin
  pleft  := tl_1sl_pkt_p(7 downto 5)  & XOR_REDUCE(tl_1sl_pkt_p(4) & flit_buffer_p(3) & flit_buffer(31 downto 28)) & flit_buffer_p(2 downto 0);
  pright := flit_buffer_p(6 downto 4) & XOR_REDUCE(flit_buffer_p(3) & flit_buffer(27 downto 24) & tl_1sl_pkt_p(3)) & tl_1sl_pkt_p(2 downto 0);
  result := GATE( pleft,         pkt_vld_1sl(1)                         )
         or GATE( pright,        pkt_vld_1sl(0)                         )   -- Note that the two are mutually exclusive
         or GATE( flit_buffer_p, not (pkt_vld_1sl(1) or pkt_vld_1sl(0)) );
  return result;
  end function MERGE_1SL_P;

  -- Create 7 byte parity bits, from 2sl_pkt parity, its two awkward middle nibbles, flit buffer parity, and two awkward middle flit buffer nibbles
  function MERGE_2SL_P(tl_2sl_pkt_p  : std_ulogic_vector(6 downto 0);       -- Byte parity on 2slot packet [Note: actually fragment of 4sl packet]
                       tl_2sl_pkt    : std_ulogic_vector(31 downto 24);     -- Packet data, for the annoying middle byte, for byte parity adjustment
                       flit_buffer_p : std_ulogic_vector(6 downto 0);       -- Buffer byte parity, covering odd and even slots
                       flit_buffer   : std_ulogic_vector(31 downto 24);     -- Buffer data, for the annoying middle byte, for byte parity adjustment
                       enables       : std_ulogic_vector(1 downto 0))       -- Which halves to update (or neither) includes "both" case this time
           return std_ulogic_vector is
  variable pleft,pright,result : std_ulogic_vector(6 downto 0);
  begin
  pleft  := tl_2sl_pkt_p(6 downto 4)  & XOR_REDUCE(tl_2sl_pkt_p(3)  & tl_2sl_pkt(27 downto 24)  & flit_buffer(31 downto 28) & flit_buffer_p(3)) & flit_buffer_p(2 downto 0);
  pright := flit_buffer_p(6 downto 4) & XOR_REDUCE(flit_buffer_p(3) & flit_buffer(27 downto 24) & tl_2sl_pkt(31 downto 28)  & tl_2sl_pkt_p(3) ) & tl_2sl_pkt_p(2 downto 0);
  result := GATE( pleft,             enables(1) and not enables(0)          )
         or GATE( pright,        not enables(1) and     enables(0)          )
         or GATE( tl_2sl_pkt_p,      enables(1) and     enables(0)          )
         or GATE( flit_buffer_p, not enables(1) and not enables(0)          );
  return result;
  end function MERGE_2SL_P;

----------------------------------------------------------------------------------------------------
-- End signals from Flit CTRL
----------------------------------------------------------------------------------------------------


begin  -- cb_tlxt_flit_arb

  --config and clock gating
  act <= '1';
  metadata_disabled <= not metadata_enabled;
  act_low_lat_mode <= low_lat_mode or tlxt_clk_gate_dis;
  act_low_lat_deg_mode <= (low_lat_mode and not low_lat_degrade_dis) or tlxt_clk_gate_dis; 
  hi_lat_mode <= not low_lat_mode and not half_dimm_mode;
  act_hi_lat_mode <= hi_lat_mode or tlxt_clk_gate_dis;
  act_tmpl5_enab <= (tmpl_config(5) and not half_dimm_mode) or tlxt_clk_gate_dis;
  --dynamic clock gating
  act_mmio_buf <= mmio_resp_val or
                  not mmio_resp_empty or
                  mmio_data_flit_q or  tlxt_clk_gate_dis;

  act_flit_buf_1st_half <=  not tmpl9_mux or
                            tlxt_clk_gate_dis or
                           (tmpl9_mux and  (mmio_data_pending or mmio_resp_pop_load or flit_buffer_reset or mmio_data_current));

  act_init_cred_ret <= not init_complete_q or tlxt_clk_gate_dis;

  act_half_dimm <= half_dimm_mode or tlxt_clk_gate_dis;

  -----------------------------------------------------------------------------
  -- generate valid for current template. Sourced from current template
  -- selection in the flit control block.
  -----------------------------------------------------------------------------
  --gate control logic template control
  tmpl0 <= tmpl_current_q(0);
  tmpl1 <= tmpl_current_q(1);
  tmpl5 <= tmpl_current_q(2);
  tmpl9 <= tmpl_current_q(3);
  tmplB <= tmpl_current_q(4);

  tmpl0_mux <= tmpl_current_mux_q(0);
  tmpl1_mux <= tmpl_current_mux_q(1);
  tmpl5_mux <= tmpl_current_mux_q(2);
  tmpl9_mux <= tmpl_current_mux_q(3);
  tmplB_mux <= tmpl_current_mux_q(4);

  tmpl0_dbg <= tmpl_current_dbg_q(0);
  tmpl1_dbg <= tmpl_current_dbg_q(1);
  tmpl5_dbg <= tmpl_current_dbg_q(2);
  tmpl9_dbg <= tmpl_current_dbg_q(3);
  tmplB_dbg <= tmpl_current_dbg_q(4);

-------------------------------------------------------------------------------
-- sourceless fix
-------------------------------------------------------------------------------
  rsvd_1sl(27 downto 0) <= (others => '0');
  rsvd_2sl(55 downto 0) <= (others => '0');
  rsvd_4sl(111 downto 0) <= (others => '0');

  -----------------------------------------------------------------------------
  -- tl packet slot input muxing. Each slot is fed by a mux with the matching
  -- 3.5 bytes for each template. 1 slot and 4 slot packets are paired with a
  -- valid which
  -----------------------------------------------------------------------------



  sl_15(27 downto 0) <= gate(rsvd_1sl,                                              flit_buffer_reset or (not flit_hold_2nd and tmpl0_mux)) OR
                        gate(tl_4sl_pkt(111 downto 84),                         not flit_buffer_reset and not flit_hold_2nd and ((tmpl1_mux and pkt_vld_4sl(3)) or tmpl5_mux)) OR
                        gate(tl_1sl_pkt(27 downto 0),                           not flit_buffer_reset and not flit_hold_2nd and (tmpl9_mux or tmplB_mux) and pkt_vld_1sl(11)) OR
                        gate(flit_buffer_2nd_half_q(191 downto 164),                     not flit_buffer_reset and (tl_1sl_packed_q(11) or flit_hold_2nd or (tmpl1_mux and not pkt_vld_4sl(3)))) ;

  sl_14(27 downto 0) <= gate(rsvd_1sl,                                              flit_buffer_reset or (not flit_hold_2nd and tmpl0_mux)) OR
                        gate(tl_4sl_pkt(83 downto 56),                          not flit_buffer_reset and not flit_hold_2nd and ((tmpl1_mux and pkt_vld_4sl(3)) or tmpl5_mux)) OR
                        gate(tl_1sl_pkt(27 downto 0),                           not flit_buffer_reset and not flit_hold_2nd and (tmpl9_mux or tmplB_mux) and pkt_vld_1sl(10)) OR
                        gate(flit_buffer_2nd_half_q(163 downto 136),                     not flit_buffer_reset and (tl_1sl_packed_q(10) or flit_hold_2nd or (tmpl1_mux and not pkt_vld_4sl(3))));

--sl_1514_p          <= not GENPARITY( sl_15 & sl_14 );
  sl_1514_1sl_p      <= MERGE_1SL_P(tl_1sl_pkt_p, flit_buffer_2nd_half_p_q(23 downto 17), flit_buffer_2nd_half_q(167 downto 160), pkt_vld_1sl(11 downto 10));
  sl_1514_p          <= gate(rsvd_1sl(6 downto 0),                                  flit_buffer_reset or (not flit_hold_2nd and tmpl0_mux)) OR
                        gate(tl_4sl_pkt_p(13 downto 7),                         not flit_buffer_reset and not flit_hold_2nd and ((tmpl1_mux and pkt_vld_4sl(3)) or tmpl5_mux)) OR
                        gate(sl_1514_1sl_p,                                     not flit_buffer_reset and not flit_hold_2nd and (tmpl9_mux or tmplB_mux)) OR
                        gate(flit_buffer_2nd_half_p_q(23 downto 17),                     not flit_buffer_reset and (flit_hold_2nd or (tmpl1_mux and not pkt_vld_4sl(3))));

  sl_13(27 downto 0) <= gate(rsvd_1sl,                                              flit_buffer_reset or (not flit_hold_2nd and tmpl0_mux)) OR
                        gate(tl_4sl_pkt(55 downto 28),                          not flit_buffer_reset and not flit_hold_2nd and ((tmpl1_mux and pkt_vld_4sl(3)) or tmpl5_mux)) OR
                        gate(tl_2sl_pkt(55 downto 28),                          not flit_buffer_reset and not flit_hold_2nd and tmplB_mux) OR
                        gate(tl_1sl_pkt(27 downto 0),                           not flit_buffer_reset and not flit_hold_2nd and tmpl9_mux and pkt_vld_1sl(9)) OR
                        gate(flit_buffer_2nd_half_q(135 downto 108),                     not flit_buffer_reset and (tl_1sl_packed_q(9) or flit_hold_2nd or (tmpl1_mux and not pkt_vld_4sl(3))));

  sl_12(27 downto 0) <= gate(rsvd_1sl,                                              flit_buffer_reset or (not flit_hold_2nd and tmpl0_mux)) OR
                        gate(tl_4sl_pkt(27 downto 0),                           not flit_buffer_reset and not flit_hold_2nd and ((tmpl1_mux and pkt_vld_4sl(3)) or tmpl5_mux)) OR
                        gate(tl_2sl_pkt(27 downto 0),                           not flit_buffer_reset and not flit_hold_2nd and tmplB_mux) OR
                        gate(tl_1sl_pkt(27 downto 0),                           not flit_buffer_reset and not flit_hold_2nd and tmpl9_mux and pkt_vld_1sl(8)) OR
                        gate(flit_buffer_2nd_half_q(107 downto 80),                      not flit_buffer_reset and (tl_1sl_packed_q(8) or  flit_hold_2nd  or (tmpl1_mux and not pkt_vld_4sl(3))));

--sl_1312_p          <= not GENPARITY( sl_13 & sl_12);
  sl_1312_1sl_p      <= MERGE_1SL_P(tl_1sl_pkt_p, flit_buffer_2nd_half_p_q(16 downto 10), flit_buffer_2nd_half_q(111 downto 104), pkt_vld_1sl(9 downto 8));
  sl_1312_p          <= gate(rsvd_1sl(6 downto 0),                                  flit_buffer_reset or (not flit_hold_2nd and tmpl0_mux)) OR
                        gate(tl_4sl_pkt_p(6 downto 0),                          not flit_buffer_reset and not flit_hold_2nd and ((tmpl1_mux and pkt_vld_4sl(3)) or tmpl5_mux)) OR
                        gate(sl_1312_1sl_p,                                     not flit_buffer_reset and not flit_hold_2nd and tmpl9_mux) OR
                        gate(tl_2sl_pkt_p(6 downto 0),                          not flit_buffer_reset and not flit_hold_2nd and tmplB_mux) OR
                        gate(flit_buffer_2nd_half_p_q(16 downto 10),                     not flit_buffer_reset and (flit_hold_2nd or (tmpl1_mux and not pkt_vld_4sl(3))));

  sl_11(27 downto 0) <= gate(rsvd_1sl,                                              flit_buffer_reset or (not flit_hold_2nd and tmpl0_mux)) OR
                        gate(half_dimm_meta,                                    not flit_buffer_reset and not flit_hold_2nd and tmplB_mux) OR
                        gate(tl_4sl_pkt(111 downto 84),                         not flit_buffer_reset and not flit_hold_2nd and tmpl1_mux and pkt_vld_4sl(2)) OR
                        gate(tl_1sl_pkt,                                        not flit_buffer_reset and not flit_hold_2nd and tmpl5_mux and pkt_vld_1sl(7)) OR
                        gate(tl_2sl_pkt(55 downto 28),                          not flit_buffer_reset and not flit_hold_2nd and tmpl9_mux) OR
                        gate(flit_buffer_2nd_half_q(79 downto 52),                     not flit_buffer_reset and (tl_1sl_packed_q(7) or flit_hold_2nd  or (tmpl1_mux and not pkt_vld_4sl(2))));--

  sl_10(27 downto 0) <= gate(rsvd_1sl,                                              flit_buffer_reset or (not flit_hold_2nd and tmpl0_mux) or tmplB_mux) OR
                        gate(tl_4sl_pkt(83 downto 56),                          not flit_buffer_reset and not flit_hold_2nd and tmpl1_mux and pkt_vld_4sl(2)) OR
                        gate(tl_1sl_pkt,                                        not flit_buffer_reset and not flit_hold_2nd and tmpl5_mux and pkt_vld_1sl(6)) OR
                        gate(tl_2sl_pkt(27 downto 0),                           not flit_buffer_reset and not flit_hold_2nd and tmpl9_mux) OR
                        gate(flit_buffer_2nd_half_q(51 downto 24),                     not flit_buffer_reset and (tl_1sl_packed_q(6) or flit_hold_2nd  or (tmpl1_mux and not pkt_vld_4sl(2))));

--sl_1110_p          <= not GENPARITY( sl_11 & sl_10);
  sl_1110_1sl_p      <= MERGE_1SL_P(tl_1sl_pkt_p, flit_buffer_2nd_half_p_q(9 downto 3), flit_buffer_2nd_half_q(55 downto 48), pkt_vld_1sl(7 downto 6));
  sl_1110_p          <= gate(rsvd_1sl(6 downto 0),                                  flit_buffer_reset or (not flit_hold_2nd and tmpl0_mux)) OR
                        gate(half_dimm_meta_p,                                  not flit_buffer_reset and not flit_hold_2nd and tmplB_mux) OR
                        gate(tl_4sl_pkt_p(13 downto 7),                         not flit_buffer_reset and not flit_hold_2nd and tmpl1_mux and pkt_vld_4sl(2)) OR
                        gate(sl_1110_1sl_p,                                     not flit_buffer_reset and not flit_hold_2nd and tmpl5_mux) OR
                        gate(tl_2sl_pkt_p(6 downto 0),                          not flit_buffer_reset and not flit_hold_2nd and tmpl9_mux) OR
                        gate(flit_buffer_2nd_half_p_q(9 downto 3),                     not flit_buffer_reset and (flit_hold_2nd or (tmpl1_mux and not pkt_vld_4sl(2))));

  sp_meta_load <= not (flit_hold_2nd and flit_credit_avail) and not flit_buffer_reset;
  sp_meta_keep <= (flit_hold_2nd and flit_credit_avail) and not flit_buffer_reset;
  mm_data_load <= mmio_resp_pop_load; -- Note cannot happen if hold_1st or hold_2nd or mmio_data_pending or mmio_data_sub0_d;
  mm_data_keep <= flit_hold_1st or mmio_data_pending; -- Note mmio_data_sub0_d=1 can only happen if mmio_data_pending=1

  sl_9(27 downto 0) <= gate(rsvd_1sl,                                           flit_buffer_reset) OR
                       gate(rsvd_1sl,                                           not flit_buffer_reset and not (flit_hold_2nd or flit_hold_1st) and tmpl0_mux) OR
                       gate(tl_4sl_pkt(55 downto 28),                           not flit_buffer_reset and not (flit_hold_2nd or flit_hold_1st) and tmpl1_mux and pkt_vld_4sl(2)) OR
                       gate(tl_1sl_pkt(27 downto 0),                            not flit_buffer_reset and not (flit_hold_2nd or flit_hold_1st) and tmpl5_mux and pkt_vld_1sl(5)) OR
                       gate(sp_meta & mmio_data_buffer_q(255 downto 252),       tmpl9_mux and sp_meta_load and mm_data_load) OR
                       gate(sp_meta & flit_buffer_1st_half_q(255 downto 252),   tmpl9_mux and sp_meta_load and mm_data_keep) OR
                       gate(sp_meta & "0000",                                   tmpl9_mux and sp_meta_load and not(mm_data_load or mm_data_keep)) OR
                       gate(flit_buffer_2nd_half_q(23 downto 0)&"0000",         tmpl9_mux and sp_meta_keep and not(mm_data_load or mm_data_keep)) OR
                       gate(x"000000"&flit_buffer_1st_half_q(255 downto 252),   tmpl9_mux and not(sp_meta_load or sp_meta_keep) and mm_data_keep) OR
                       gate(flit_buffer_2nd_half_q(23 downto 0)
                          & flit_buffer_1st_half_q(255 downto 252),             tmpl9_mux and sp_meta_keep and mm_data_keep) OR
                       gate(x"000000"&mmio_data_buffer_q(255 downto 252),       tmplB_mux and mm_data_load) OR
                       gate(x"000000"&flit_buffer_1st_half_q(255 downto 252),   tmplB_mux and mm_data_keep) OR
                       gate(flit_buffer_2nd_half_q(23 downto 0) & flit_buffer_1st_half_q(255 downto 252),                      not flit_buffer_reset and (tl_1sl_packed_q(5) or (not (tmpl9_mux or tmplB_mux) and (flit_hold_1st or flit_hold_2nd)) or (tmpl1_mux and not pkt_vld_4sl(2))));

  sl_8(27 downto 0) <= gate(rsvd_1sl,                                           not flit_buffer_reset and not flit_hold_1st and tmpl0_mux) OR
                       gate(tl_4sl_pkt(27 downto 0),                            not flit_buffer_reset and not flit_hold_1st and tmpl1_mux and pkt_vld_4sl(2)) OR
                       gate(tl_1sl_pkt,                                         not flit_buffer_reset and not flit_hold_1st and tmpl5_mux and pkt_vld_1sl(4)) OR
                       gate(rsvd_1sl,                                               flit_buffer_reset or (not flit_hold_1st and (tmpl9_mux or tmplB_mux))) OR
                       gate(mmio_data_buffer_q(251 downto 224),                 (tmpl9_mux or tmplB_mux) and mm_data_load) OR
                       gate(flit_buffer_1st_half_q(251 downto 224),                      (tl_1sl_packed_q(4) and not flit_buffer_reset) or (not (tmpl9_mux or tmplB_mux) and flit_hold_1st) or ((tmpl9_mux or tmplB_mux) and mm_data_keep) or (tmpl1_mux and not pkt_vld_4sl(2) and not flit_buffer_reset));

--sl_98_p           <= not GENPARITY( sl_9 & sl_8);
  sl_98_flitbuff_p  <= flit_buffer_2nd_half_p_q(2 downto 0)&flit_buffer_1st_half_p_q(31 downto 28); -- Flit buffer parity, straddling the crack
  sl_98_1sl_enables <= (not (flit_hold_2nd or flit_hold_1st) and pkt_vld_1sl(5))            -- Update slot9 with 1sl pkt
                     & (not                   flit_hold_1st  and pkt_vld_1sl(4));           -- Update slot8 with 1sl pkt
  sl_98_4sl_enables <= (not (flit_hold_2nd or flit_hold_1st) and tmpl1_mux and pkt_vld_4sl(2))  -- Update slot9 with left part of 4sl packet
                     & (not                   flit_hold_1st  and tmpl1_mux and pkt_vld_4sl(2)); -- Update slot8 with right part of 4sl packet
  sl_98_1sl_p       <= MERGE_1SL_P(tl_1sl_pkt_p, sl_98_flitbuff_p, flit_buffer_1st_half_q(255 downto 248), sl_98_1sl_enables);
  sl_98_4sl_p       <= MERGE_2SL_P(tl_4sl_pkt_p(6 downto 0), tl_4sl_pkt(31 downto 24), sl_98_flitbuff_p, flit_buffer_1st_half_q(255 downto 248), sl_98_4sl_enables);
  sl_98_p           <= gate("0000000",                                          not flit_buffer_reset and tmpl0_mux) OR  -- Cheat, no real 6-slot responses so always zero
                       gate(sl_98_4sl_p,                                        not flit_buffer_reset and tmpl1_mux) OR  -- Includes holding flit buffer contents
                       gate(sl_98_1sl_p,                                        not flit_buffer_reset and tmpl5_mux) OR  -- Includes holding flit buffer contents
                       gate(sp_meta_p & mmio_data_buffer_p_q(31 downto 28),     tmpl9_mux and mmio_resp_pop_load ) OR -- pop => 1st,2nd off anyway
                       gate(sp_meta_p & flit_buffer_1st_half_p_q(31 downto 28), tmpl9_mux and sp_meta_load and mm_data_keep) OR
                       gate(sp_meta_p & "0000",                                 tmpl9_mux and sp_meta_load and not (mm_data_load or mm_data_keep)) OR
                       gate("000" & flit_buffer_1st_half_p_q(31 downto 28),     tmpl9_mux and not (sp_meta_load or sp_meta_keep) and mm_data_keep) OR
                       gate(flit_buffer_2nd_half_p_q(2 downto 0)&"0000",        tmpl9_mux and sp_meta_keep and not mm_data_load and not mm_data_keep) OR
                       gate(sl_98_flitbuff_p,                                   tmpl9_mux and sp_meta_keep and mm_data_keep) OR
                       gate("000" & mmio_data_buffer_p_q(31 downto 28),         tmplB_mux and mmio_resp_pop_load ) OR -- pop => 1st,2nd off anyway
                       gate(sl_98_flitbuff_p,                                   tmplB_mux and mm_data_keep);

  sl_7(27 downto 0) <= --gate(tl_6sl_pkt(111 downto 84),                          not flit_buffer_reset and not flit_hold_1st and tmpl0_mux) OR
                       gate(tl_4sl_pkt(111 downto 84),                          not flit_buffer_reset and not flit_hold_1st and ((tmpl1_mux and pkt_vld_4sl(1)) or tmpl0_mux)) OR
                       gate(tl_1sl_pkt,                                         not flit_buffer_reset and not flit_hold_1st and tmpl5_mux and pkt_vld_1sl(3)) OR
                       gate(rsvd_1sl,                                               flit_buffer_reset or (not flit_hold_1st and (tmpl9_mux or tmplB_mux))) OR
                       gate(mmio_data_buffer_q(223 downto 196),                 not flit_hold_1st and (tmpl9_mux or tmplB_mux) and mmio_resp_pop_load) OR
                       gate(flit_buffer_1st_half_q(223 downto 196),                      (tl_1sl_packed_q(3) and not flit_buffer_reset) or flit_hold_1st or (mmio_data_pending and (tmpl9_mux or tmplB_mux)) or (tmpl1_mux and not pkt_vld_4sl(1) and not flit_buffer_reset));

  sl_6(27 downto 0) <= --gate(tl_6sl_pkt(83 downto 56),                           not flit_buffer_reset and not flit_hold_1st and tmpl0_mux) OR
                       gate(tl_4sl_pkt(83 downto 56),                           not flit_buffer_reset and not flit_hold_1st and ((tmpl1_mux and pkt_vld_4sl(1)) or tmpl0_mux)) OR
                       gate(tl_1sl_pkt,                                         not flit_buffer_reset and not flit_hold_1st and tmpl5_mux and pkt_vld_1sl(2)) OR
                       gate(rsvd_1sl,                                               flit_buffer_reset or (not flit_hold_1st and (tmpl9_mux or tmplB_mux))) OR
                       gate(mmio_data_buffer_q(195 downto 168),                 not flit_hold_1st and (tmpl9_mux or tmplB_mux) and mmio_resp_pop_load) OR
                       gate(flit_buffer_1st_half_q(195 downto 168),                      (tl_1sl_packed_q(2) and not flit_buffer_reset) or flit_hold_1st or (mmio_data_pending and (tmpl9_mux or tmplB_mux))  or (tmpl1_mux and not pkt_vld_4sl(1) and not flit_buffer_reset));

--sl_76_p           <= not GENPARITY( sl_7 & sl_6);
  sl_76_1sl_p       <= MERGE_1SL_P(tl_1sl_pkt_p, flit_buffer_1st_half_p_q(27 downto 21), flit_buffer_1st_half_q(199 downto 192), pkt_vld_1sl(3 downto 2));
  sl_76_p           <= --gate(tl_6sl_pkt_p(13 downto 7),                          not flit_buffer_reset and not flit_hold_1st and tmpl0_mux) OR
                       gate(tl_4sl_pkt_p(13 downto 7),                          not flit_buffer_reset and not flit_hold_1st and ((tmpl1_mux and pkt_vld_4sl(1)) or tmpl0_mux)) OR
                       gate(sl_76_1sl_p,                                        not flit_buffer_reset and not flit_hold_1st and tmpl5_mux) OR
                       gate(rsvd_1sl(6 downto 0),                                   flit_buffer_reset or (not flit_hold_1st and (tmpl9_mux or tmplB_mux))) OR
                       gate(mmio_data_buffer_p_q(27 downto 21),                 not flit_hold_1st and (tmpl9_mux or tmplB_mux) and mmio_resp_pop_load) OR
                       gate(flit_buffer_1st_half_p_q(27 downto 21),                      (flit_hold_1st or (mmio_data_pending and (tmpl9_mux or tmplB_mux))  or (tmpl1_mux and not pkt_vld_4sl(1) and not flit_buffer_reset)));

  sl_5(27 downto 0) <= --gate(tl_6sl_pkt(55 downto 28),                           not flit_buffer_reset and not flit_hold_1st and tmpl0_mux) OR
                       gate(tl_4sl_pkt(55 downto 28),                           not flit_buffer_reset and not flit_hold_1st and ((tmpl1_mux and pkt_vld_4sl(1)) or tmpl0_mux)) OR
                       gate(tl_1sl_pkt,                                         not flit_buffer_reset and not flit_hold_1st and tmpl5_mux and pkt_vld_1sl(1)) OR
                       gate(rsvd_1sl,                                               flit_buffer_reset or (not flit_hold_1st and (tmpl9_mux or tmplB_mux))) OR
                       gate(mmio_data_buffer_q(167 downto 140),                 not flit_hold_1st and (tmpl9_mux or tmplB_mux) and mmio_resp_pop_load) OR
                       gate(flit_buffer_1st_half_q(167 downto 140),                      (tl_1sl_packed_q(1) and not flit_buffer_reset) or flit_hold_1st or ( mmio_data_pending and (tmpl9_mux or tmplB_mux))  or (tmpl1_mux and not pkt_vld_4sl(1) and not flit_buffer_reset));

  sl_4(27 downto 0) <= --gate(tl_6sl_pkt(27 downto 0),                            not flit_buffer_reset and not flit_hold_1st and tmpl0_mux) OR
                       gate(tl_4sl_pkt(27 downto 0),                            not flit_buffer_reset and not flit_hold_1st and ((tmpl1_mux and pkt_vld_4sl(1)) or tmpl0_mux)) OR
                       gate(tl_1sl_pkt,                                         not flit_buffer_reset and not flit_hold_1st and tmpl5_mux and pkt_vld_1sl(0)) OR
                       gate(rsvd_1sl,                                               flit_buffer_reset or (not flit_hold_1st and (tmpl9_mux or tmplB_mux))) OR
                       gate(mmio_data_buffer_q(139 downto 112),                 not flit_hold_1st and (tmpl9_mux or tmplB_mux) and mmio_resp_pop_load) OR
                       gate(flit_buffer_1st_half_q(139 downto 112),                      (tl_1sl_packed_q(0) and not flit_buffer_reset) or flit_hold_1st or (mmio_data_pending and (tmpl9_mux or tmplB_mux))  or (tmpl1_mux and not pkt_vld_4sl(1) and not flit_buffer_reset));

--sl_54_p           <= not GENPARITY( sl_5 & sl_4);

  sl_54_1sl_p       <= MERGE_1SL_P(tl_1sl_pkt_p, flit_buffer_1st_half_p_q(20 downto 14), flit_buffer_1st_half_q(143 downto 136), pkt_vld_1sl(1 downto 0));
  sl_54_p           <= --gate(tl_6sl_pkt_p(6 downto 0),                           not flit_buffer_reset and not flit_hold_1st and tmpl0_mux) OR
                       gate(tl_4sl_pkt_p(6 downto 0),                           not flit_buffer_reset and not flit_hold_1st and ((tmpl1_mux and pkt_vld_4sl(1)) or tmpl0_mux)) OR
                       gate(sl_54_1sl_p,                                        not flit_buffer_reset and not flit_hold_1st and tmpl5_mux) OR
                       gate(rsvd_1sl(6 downto 0),                                   flit_buffer_reset or (not flit_hold_1st and (tmpl9_mux or tmplB_mux))) OR
                       gate(mmio_data_buffer_p_q(20 downto 14),                 not flit_hold_1st and (tmpl9_mux or tmplB_mux) and mmio_resp_pop_load) OR
                       gate(flit_buffer_1st_half_p_q(20 downto 14),                      (flit_hold_1st or (mmio_data_pending and (tmpl9_mux or tmplB_mux))  or (tmpl1_mux and not pkt_vld_4sl(1) and not flit_buffer_reset)));

  sl_3(27 downto 0) <= gate(rsvd_1sl,                                               flit_buffer_reset or (not flit_hold_1st and (tmpl0_mux or tmpl9_mux))) OR
                       gate(tl_4sl_pkt(111 downto 84),                          not flit_buffer_reset and not flit_hold_1st and tmpl1_mux and pkt_vld_4sl(0)) OR
                       gate(meta_vec_d(55 downto 28),                           not flit_buffer_reset and not flit_hold_1st and tmpl5_mux) OR
                       gate(mmio_data_buffer_q(111 downto 84),                  not flit_hold_1st and (tmpl9_mux or tmplB_mux) and mmio_resp_pop_load) OR
                       gate(flit_buffer_1st_half_q(111 downto 84),                       flit_hold_1st or (mmio_data_pending and (tmpl9_mux or tmplB_mux))  or (tmpl1_mux and not pkt_vld_4sl(0) and not flit_buffer_reset));

  sl_2(27 downto 0) <= gate(rsvd_1sl,                                               flit_buffer_reset or (not flit_hold_1st and (tmpl0_mux or tmpl9_mux))) OR
                       gate(tl_4sl_pkt(83 downto 56),                           not flit_buffer_reset and not flit_hold_1st and tmpl1_mux and pkt_vld_4sl(0)) OR
                       gate(meta_vec_d(27 downto 0),                            not flit_buffer_reset and not flit_hold_1st and tmpl5_mux) OR
                       gate(mmio_data_buffer_q(83 downto 56),                   not flit_hold_1st and (tmpl9_mux or tmplB_mux) and mmio_resp_pop_load) OR
                       gate(flit_buffer_1st_half_q(83 downto 56),                        flit_hold_1st or (mmio_data_pending and (tmpl9_mux or tmplB_mux))  or (tmpl1_mux and not pkt_vld_4sl(0) and not flit_buffer_reset));

--sl_32_p           <= not GENPARITY( sl_3 & sl_2);
  sl_32_p           <= gate(rsvd_1sl(6 downto 0),                                   flit_buffer_reset or (not flit_hold_1st and (tmpl0_mux or tmpl9_mux))) OR
                       gate(tl_4sl_pkt_p(13 downto 7),                          not flit_buffer_reset and not flit_hold_1st and tmpl1_mux and pkt_vld_4sl(0)) OR
                       gate(meta_vec_p_d(6 downto 0),                           not flit_buffer_reset and not flit_hold_1st and tmpl5_mux) OR
                       gate(mmio_data_buffer_p_q(13 downto 7),                  not flit_hold_1st and (tmpl9_mux or tmplB_mux) and mmio_resp_pop_load) OR
                       gate(flit_buffer_1st_half_p_q(13 downto 7),                       flit_hold_1st or (mmio_data_pending and (tmpl9_mux or tmplB_mux))  or (tmpl1_mux and not pkt_vld_4sl(0) and not flit_buffer_reset));

  sl_1(27 downto 0) <= gate(tl_4sl_pkt(55 downto 28),                           not flit_buffer_reset and not flit_hold_1st and tmpl1_mux and pkt_vld_4sl(0)) OR
                       gate(tl_2sl_pkt(55 downto 28),                           not flit_buffer_reset and not flit_hold_1st and (tmpl0_mux or tmpl5_mux) and not flit_buffer_reset) OR
                       gate(rsvd_1sl,                                               flit_buffer_reset or (not flit_hold_1st and (tmpl9_mux or tmplB_mux))) OR
                       gate(mmio_data_buffer_q(55 downto 28),                   not flit_hold_1st and (tmpl9_mux or tmplB_mux) and mmio_resp_pop_load) OR
                       gate(flit_buffer_1st_half_q(55 downto 28),                        flit_hold_1st or (mmio_data_pending and (tmpl9_mux or tmplB_mux))  or (tmpl1_mux and not pkt_vld_4sl(0) and not flit_buffer_reset));

  sl_0(27 downto 0) <= gate(tl_4sl_pkt(27 downto 0),                            not flit_buffer_reset and not flit_hold_1st and tmpl1_mux and pkt_vld_4sl(0)) OR
                       gate(tl_2sl_pkt(27 downto 0),                            not flit_buffer_reset and not flit_hold_1st and (tmpl0_mux or tmpl5_mux) and not flit_buffer_reset) OR
                       gate(rsvd_1sl,                                               flit_buffer_reset or (not flit_hold_1st and (tmpl9_mux or tmplB_mux))) OR
                       gate(mmio_data_buffer_q(27 downto 0),                    not flit_hold_1st and (tmpl9_mux or tmplB_mux) and mmio_resp_pop_load) OR
                       gate(flit_buffer_1st_half_q(27 downto 0),                         flit_hold_1st or (mmio_data_pending and (tmpl9_mux or tmplB_mux))  or (tmpl1_mux and not pkt_vld_4sl(0) and not flit_buffer_reset));

--sl_10_p           <= not GENPARITY( sl_1 & sl_0);
  sl_10_p           <= gate(tl_4sl_pkt_p(6 downto 0),                           not flit_buffer_reset and not flit_hold_1st and tmpl1_mux and pkt_vld_4sl(0)) OR
                       gate(tl_2sl_pkt_p,                                       not flit_buffer_reset and not flit_hold_1st and (tmpl0_mux or tmpl5_mux) and not flit_buffer_reset) OR
                       gate(rsvd_1sl(6 downto 0),                                   flit_buffer_reset or (not flit_hold_1st and (tmpl9_mux or tmplB_mux))) OR
                       gate(mmio_data_buffer_p_q(6 downto 0),                   not flit_hold_1st and (tmpl9_mux or tmplB_mux) and mmio_resp_pop_load) OR
                       gate(flit_buffer_1st_half_p_q(6 downto 0),                        flit_hold_1st or (mmio_data_pending and (tmpl9_mux or tmplB_mux))  or (tmpl1_mux and not pkt_vld_4sl(0) and not flit_buffer_reset));

  enable_asserts <= '1'; -- Sim can force to '0' when doing parity error injection testing
  -- synopsys translate_off
  assert not (gckn'event and gckn='0' and enable_asserts='1') or sl_10_p   = not GENPARITY( sl_1  & sl_0  ) report "sl_10p_wrong";
  assert not (gckn'event and gckn='0' and enable_asserts='1') or sl_32_p   = not GENPARITY( sl_3  & sl_2  ) report "sl_32p_wrong";
  assert not (gckn'event and gckn='0' and enable_asserts='1') or sl_54_p   = not GENPARITY( sl_5  & sl_4  ) report "sl_54p_wrong";
  assert not (gckn'event and gckn='0' and enable_asserts='1') or sl_76_p   = not GENPARITY( sl_7  & sl_6  ) report "sl 76p_wrong";
  assert not (gckn'event and gckn='0' and enable_asserts='1') or sl_98_p   = not GENPARITY( sl_9  & sl_8  ) report "sl_98p_wrong";
  assert not (gckn'event and gckn='0' and enable_asserts='1') or sl_1110_p = not GENPARITY( sl_11 & sl_10 ) report "sl_1110p_wrong";
  assert not (gckn'event and gckn='0' and enable_asserts='1') or sl_1312_p = not GENPARITY( sl_13 & sl_12 ) report "sl_1312p_wrong";
  assert not (gckn'event and gckn='0' and enable_asserts='1') or sl_1514_p = not GENPARITY( sl_15 & sl_14 ) report "sl_15140p_wrong";
  -- synopsys translate_on

  flit_buffer_2nd_half_d(191 downto 0) <= sl_15 &
                                          sl_14 &
                                          sl_13 &
                                          sl_12 &
                                          sl_11 &
                                          sl_10 &
                                          sl_9(27 downto 4);


  flit_buffer_1st_half_d(255 downto 0) <= sl_9(3 downto 0) &
                                          sl_8 &
                                          sl_7 &
                                          sl_6 &
                                          sl_5 &
                                          sl_4 &
                                          sl_3 &
                                          sl_2 &
                                          sl_1 &
                                          sl_0;

  -- Per byte parity is stored here
  flit_buffer_2nd_half_p_d(23 downto 0) <= sl_1514_p & sl_1312_p & sl_1110_p & sl_98_p(6 downto 4);
  flit_buffer_1st_half_p_d(31 downto 0) <= sl_98_p(3 downto 0) & sl_76_p & sl_54_p & sl_32_p & sl_10_p;

  flit_buffer_reset <= flit_xmit_early_done and not data_flit_xmit_int;

  -------------------------------------------------------------------------------
  --DL content and flit part valids
  -------------------------------------------------------------------------------

  -----------------------------------------------------------------------------
  -- Flit buffer output muxing.
  --
  -- Once flit buffer starts to transmit flit, no way of holding and stopping.
  -------------------------------------------------------------------------------

  mux_1st_qw <= not (flit_xmit_start_t1_q or flit_xmit_start_t2_q or data_flit_xmit_int);

  data_err_late <= (flit_buffer_2nd_half_q(7) and (not rdf_tlxt_data_err_q or not tmpl9 or not flit_xmit_start_t2_q)) or
                   (rdf_tlxt_data_err_q and flit_xmit_start_t2_q and tmpl9) OR
                   (bad_data AND bad_data_valid AND NOT ow_bdi_packed_q AND flit_xmit_start_t2_q AND tmpl9 and rdf_data_current AND bdi_fifo_empty_q);
  data_err_late_p <= XOR_REDUCE(data_err_late&flit_buffer_2nd_half_q(7)&flit_buffer_2nd_half_p_q(0)); 

  flit_part <= gate(flit_buffer_2nd_half_q(127 downto 8)&data_err_late&flit_buffer_2nd_half_q(6 downto 0),                                              flit_xmit_start_t2_q) OR
               gate(flit_buffer_1st_half_q(255 downto 128),                                                                  flit_xmit_start_t1_q) OR
               gate(flit_buffer_1st_half_q(127 downto 0),                                                                    mux_1st_qw) OR
               gate(mmio_data_buffer_q(127 downto 0),           mmio_data_flit_del_q and data_flit_xmit_int and (flit_xmit_start_t4_q or flit_xmit_start_t6_q)) OR
               gate(mmio_data_buffer_q(255 downto 128),         mmio_data_flit_del_q and data_flit_xmit_int and (flit_xmit_start_t5_q or flit_xmit_start_t7_q));

  flit_part_p<=gate(flit_buffer_2nd_half_p_q(15 downto 1)&data_err_late_p,                                             flit_xmit_start_t2_q ) OR
               gate(flit_buffer_1st_half_p_q(31 downto 16),                                                                  flit_xmit_start_t1_q) OR
               gate(flit_buffer_1st_half_p_q(15 downto 0),                                                                   mux_1st_qw) OR
               gate(mmio_data_buffer_p_q(15 downto 0),          mmio_data_flit_del_q and data_flit_xmit_int and (flit_xmit_start_t4_q or flit_xmit_start_t6_q)) OR
               gate(mmio_data_buffer_p_q(31 downto 16),         mmio_data_flit_del_q and data_flit_xmit_int and (flit_xmit_start_t5_q or flit_xmit_start_t7_q));

  flit_part_last   <= flit_buffer_2nd_half_q(191 downto 128);

  flit_part_last_p <= flit_buffer_2nd_half_p_q(23 downto 16);

  flit_part_vld <= flit_credit_avail and
                   (
                     ((flit_xmit_start_q or flit_xmit_start_t1_q) and (tmpl0 or tmpl1 or tmpl5 or mmio_data_current)) OR
                     ((flit_xmit_start_t2_q) and (tmpl9 or tmplB or tmpl0 or tmpl1 or tmpl5)) OR
                     ((flit_xmit_start_t4_q or flit_xmit_start_t5_q or flit_xmit_start_t6_q or flit_xmit_start_t7_q) and mmio_data_flit_del_q and data_xmit)
                   );
  flit_part_last_vld <= flit_xmit_start_t2_q and flit_credit_avail;

  flit_xmit_start_early <= flit_xmit_start_d;

  flit_xmit_start <= flit_xmit_start_q AND flit_credit_avail;
  flit_xmit_start_t1_d <= flit_xmit_start_pulse or (flit_xmit_start_t1_q and not flit_credit_avail);
  flit_xmit_start_t2_d <= (flit_xmit_start_t1_q and flit_credit_avail) or (flit_xmit_start_t2_q and not flit_credit_avail);
  flit_xmit_start_t3_d <= (flit_xmit_start_t2_q and flit_credit_avail) or (flit_xmit_start_t3_q and not flit_credit_avail);
  flit_xmit_start_t4_d <= (flit_xmit_start_t3_q and flit_credit_avail) or (flit_xmit_start_t4_q and not flit_credit_avail);
  flit_xmit_start_t5_d <= (flit_xmit_start_t4_q and flit_credit_avail) or (flit_xmit_start_t5_q and not flit_credit_avail);
  flit_xmit_start_t6_d <= (flit_xmit_start_t5_q and flit_credit_avail) or (flit_xmit_start_t6_q and not flit_credit_avail);
  flit_xmit_start_t7_d <= (flit_xmit_start_t6_q and flit_credit_avail) or (flit_xmit_start_t7_q and not flit_credit_avail);


  flit_hold_1st <= ((flit_xmit_start_t1_q or flit_xmit_start_pulse) and not (tmpl9 or tmplB)) OR
                   ((tmpl9 or tmplB) and mmio_data_current and not flit_xmit_start_t2_q);
  flit_hold_2nd <= (flit_xmit_start_t2_q) and ((flit_credit_avail and (tmpl9 or tmplB)) or not (tmpl9 or tmplB));

  flit_hold <= (flit_hold_1st  and not (tmpl9 or tmplB) )or flit_hold_2nd;

  flit_xmit_start_t2_del_pulse_d <= flit_xmit_start_t2_q AND flit_credit_avail;

  -----------------------------------------------------------------------------
  -- Packing 1 slot commands
  -----------------------------------------------------------------------------

  -----------------------------------------------------------------------------
  -- Credit Return Packing
  -----------------------------------------------------------------------------

  --constantly update credit return. Take credit return every flit
  next_credit_return(55 downto 0) <= "000000" &  --reserved value
                                     "000000" &  --reserved value
                                     tlxc_tlxt_dcp1_credits &
                                     "000000" &  --DCP0 cred. fix?
                                     "0000" &
                                     "0000" &
                                     "0000" &
                                     "0000" &
                                     tlxc_tlxt_vc1_credits &
                                     tlxc_tlxt_vc0_credits &
                                     "00001000";  --opcode

  next_credit_return_p(6 downto 0)<=
      '0'                                                                        -- over 55:48
    & XOR_REDUCE(tlxc_tlxt_dcp1_credits_p & tlxc_tlxt_dcp1_credits(1 downto 0))  -- over 47:40
    & XOR_REDUCE(tlxc_tlxt_dcp1_credits_p & tlxc_tlxt_dcp1_credits(5 downto 2))  -- over 39:32
    & "00"                                                                       -- over 31:16
    & (tlxc_tlxt_vc1_credits_p xor tlxc_tlxt_vc0_credits_p)                      -- over 15:8
    & '1';                                                                       -- over 7:0

  --Mark the return as taken when a flit transmit is started.Need to figure out a way not to gate
  --failure responses on response packets that need credit return in
  tlxt_tlxc_crd_ret_taken_int <= tlxc_tlxt_crd_ret_val and 
                                 (
                                   crd_ret_tmpl0 or
                                   crd_ret_tmpl1 or
                                   crd_ret_tmpl5 or
                                   crd_ret_tmpl9 or
                                   crd_ret_tmplB
                                 );
  crd_ret_tmpl0 <= tmpl0 and not tl_2sl_pkt_full_q and not (flit_xmit_start_q or flit_ip);
  crd_ret_tmpl1 <= tmpl1 and pkt_vld_4sl(0) and non_main_gate_q and not intrp_req_pend and not fail_resp_pop_q and not (flit_xmit_start_q or flit_ip) and not assign_actag_gate_q;
  crd_ret_tmpl5 <= tmpl5 and fail_resp_empty_q and not tl_2sl_pkt_full_q and not (flit_xmit_start_q or flit_ip) and not assign_actag_gate_q;
  crd_ret_tmpl9 <= tmpl9 and fail_resp_empty_q and not tl_2sl_pkt_full_q and not flit_hold and not assign_actag_gate_q;
  crd_ret_tmplB <= tmplB and fail_resp_empty_q and not tl_2sl_pkt_full_q and not flit_hold and not assign_actag_gate_q;

  tlxt_tlxc_crd_ret_taken <= tlxt_tlxc_crd_ret_taken_int;
  cred_ret_4sl <= tlxt_tlxc_crd_ret_taken_int and tmpl1;

  --------------------------------------------------------------------------------------------------
  -- Generate signals needed for low latency in CAPI link degrade
  --------------------------------------------------------------------------------------------------

  lane_width_d(1 downto 0) <= gate(dlx_tlxt_lane_width_status(1 downto 0), not (lane_width_transition and (rdf_data_pending or mmio_data_pending or mmio_data_current or drl_in_pipe or drl_prev_val_q or or_reduce(drl_current)))) or
                              gate(lane_width_q,                               (lane_width_transition and (rdf_data_pending or mmio_data_pending or mmio_data_current or drl_in_pipe or drl_prev_val_q or or_reduce(drl_current))));

  --gating term for read responses in queue. 
  lane_width_transition <= (dlx_tlxt_lane_width_status(1 downto 0)/=lane_width_q(1 downto 0)) and not low_lat_degrade_dis;
  
  low_lat_degrade_d <= low_lat_mode and not low_lat_degrade_dis and (lane_width_d(1) xor lane_width_d(0));

  --mechanism for stalling first read
  rd_resp_degrade_stall_dec <= or_reduce(rd_resp_degrade_stall_q);
  rd_resp_degrade_stall_d (3 downto 0) <= gate("1000",                          rd_resp_push and not rd_resp_degrade_stall_dec and (rd_resp_count<=1)) OR
                                          gate(rd_resp_degrade_stall_q-1,       rd_resp_degrade_stall_dec) OR
                                          gate(rd_resp_degrade_stall_q,     not (rd_resp_push or rd_resp_degrade_stall_dec));

  rd_resp_degrade_stall_one_d <= (rd_resp_degrade_stall_dec and (triplet_advance_start or flit_xmit_start_pulse or ((flit_xmit_start_q or flit_xmit_start_t1_q or (flit_xmit_start_t2_q and not flit_credit_avail)) and tmpl9))) or
                                 (rd_resp_degrade_stall_one_q and not flit_buffer_reset);
  
  -----------------------------------------------------------------------------
  -- response pop common logic
  -----------------------------------------------------------------------------
  resp_pop_vld <= init_complete_q and not flit_hold and not flit_full_q and not non_main_gate_q and not fail_resp_flush_q AND NOT null_flit_next_q and not tmpl_no_longer_valid;

  tmpl_no_longer_valid <= (tmpl0 and not tmpl_config(0)) or
                          (tmpl1 and not tmpl_config(1)) or
                          (tmpl5 and not tmpl_config(5)) or
                          (tmpl9 and not tmpl_config(9)) or
                          (tmplB and not tmpl_config(11));

  non_main_gate_d <= ((intrp_req_pop_d or assign_actag_pop_d or fail_resp_pop_d) and (tmpl0 or tmpl1 or tmpl5)) or
                     (fail_resp_pop_d and rd_resp_empty_q and mmio_resp_empty and (tmpl9 or tmplB)) or
                     (fail_resp_pop_d and not rd_pend_gate_q) OR
                     (tlxc_tlxt_crd_ret_val and (tl_4sl_vld_d="00") and tmpl1) OR
                     (hi_lat_mode and not fail_resp_empty_q and tmpl1) or
                     (intrp_req_pend and assign_actag_sent_q and low_lat_mode and not tmpl5_intrp_opt_val_q);

  tlx_vc0_avail <= or_reduce(tlxc_tlxt_avail_vc0);
  tlx_dcp0_avail <= or_reduce(tlxc_tlxt_avail_dcp0);
  tlx_vc3_avail <= or_reduce(tlxc_tlxt_avail_vc3);

  --------------------------------------------------------------------------------------------------
  -- Read Response Pop
  --------------------------------------------------------------------------------------------------

  rd_resp_pop <= (rd_resp_pop_hi_lat or rd_resp_pop_tmpl9 or rd_resp_pop_half_dimm) and not rd_resp_unrec_stall_q;

  rd_resp_pop_int <= rd_resp_pop;

  rd_resp_pop_hi_lat <= resp_pop_vld and
                        tlx_vc0_avail and
                        tlx_dcp0_avail and
                        hi_lat_mode and
                        not (mmio_resp_pend_q and not or_reduce(flit_rd_resp_q)) and                                                                                      
                        not wr_resp_flush_q and
                        not rd_resp_empty_q and
                        not (rd_resp_len32 and mmio_data_flit_pend_q and not tmpl_config(9)) and
                        not (rd_resp_len32 and not tmpl_config(9) and or_reduce(drl_current)) and
                        not (rdf_1st_32B_sub1_q or mmio_data_sub1_q) and
                        not (rdf_1st_32B_current and not ow_meta_packed_q and not rd_resp_len32) and
                        (drl_current<data_run_length_max) and
                        (
                          (metadata_avail and (tmpl9 or tmpl5) and metadata_enabled) OR
                          (bdi_avail and not metadata_enabled)
                        );

  rd_resp_pop_tmpl9 <= resp_pop_vld AND
                       tlx_vc0_avail AND
                       tlx_dcp0_avail AND
                       (low_lat_mode and not lane_width_transition) and 
                       (tmpl9 or tmpl5) and
                       not rd_resp_low_lat_stall_q and
                       not wr_resp_flush_q AND
                       not rd_resp_exit0_gate and
                       not rd_stall_ll_or_hd and
                       not rd_resp_empty_q AND
                       (
                         (triplet_9dd_q and triplet_9dd_rd_pop_vld) OR
                         (triplet_9d9_q and triplet_9d9_rd_pop_vld) OR
                         (triplet_ow_rd_pop_vld)
                       );

  --stall for data alignment in stack
  rd_resp_low_lat_stall_d <= (not rd_resp_low_lat_stall_q and rd_resp_push and (rd_resp_count<=1) AND  (dat_bts_pend_q<=6) AND (flit_xmit_done OR flit_xmit_start_int or flit_xmit_start_q OR flit_xmit_start_t1_q OR rdf_data_current or (flit_xmit_start_t2_q and not flit_credit_avail))) or
                             (not rd_resp_low_lat_stall_q and rd_resp_push and ((rd_resp_count<=1) or ((rd_resp_count<=2) and not ow_in_flit)) and flit_cyc_gate and not flit_buffer_reset and data_pending_int) OR
                             (not rd_resp_low_lat_stall_q and rd_resp_exit0_gate and flit_xmit_start_pulse and tmpl5_flit_sub0_q) or
                             (rd_resp_low_lat_stall_q and not flit_buffer_reset);

  flit_cyc_gate <= (((flit_cyc_cnt_q+"01100")<16) and not tmpl5_flit_add_cyc and     rd_resp_exit0) or
                   (((flit_cyc_cnt_q+"01100")<14) and not tmpl5_flit_add_cyc and not rd_resp_exit0) or
                   (((flit_cyc_cnt_q+"01100")<14) and     tmpl5_flit_add_cyc);

  --Add additional cycles if a template 5 flit is pending (flit will be held for 2 additional cycles
  --in either exit0 or
  tmpl5_flit_add_cyc <= (drl_current_2 and     drl_prev_val_q and (tmpl5_flit_sub1_q or tmpl5_flit_sub0_q)) or
                        (drl_current_2 and not drl_prev_val_q and tmpl5_flit_sub0_q);

  idle_start_block <= (not rd_resp_empty_q and tlx_vc0_avail and low_lat_mode) or
                      (half_dimm_mode and not rd_resp_empty_q and rd_resp_half_dimm_stall_dec ) ;  --or future signal

  rd_resp_exit0_block_dec <= or_reduce(rd_resp_exit0_block_q);
  rd_resp_exit0_block_d(2 downto 0) <= gate("011",                          rd_resp_push and rd_resp_exit0 and not tmpl5_flit_sub1_q) OR
                                       gate("101",                          rd_resp_push and rd_resp_exit0 and     tmpl5_flit_sub1_q) OR
                                       gate(rd_resp_exit0_block_q - 1,  not rd_resp_push and rd_resp_exit0_block_dec) or
                                       gate(rd_resp_exit0_block_q,      not rd_resp_push and not rd_resp_exit0_block_dec);

  rd_resp_exit0_gate_d <= (rd_resp_push and rd_resp_exit0) or
                          (or_reduce(rd_resp_exit0_block_q));
  rd_resp_exit0_gate <= rd_resp_exit0_gate_q and (rd_resp_count=1) and ow_in_flit and not drl_prev_val_q;

  --Deterine if it is a valid cycle for a read response given set triplet
  triplet_ow_rd_pop_vld <= not ow_in_flit and not rd_resp_ow_pend_q and (mmio_resp_empty or mmio_data_pending or mmio_data_current or (mmio_resp_pend_q and tmpl5 and triplet_state_val_q)) and not mmio_data_flit_pend_q and not tmpl5_flit_rd_gate and
                           (
                             (triplet_999_q and not drl_sub2_val_q and (drl_sub1_q<2)  and not or_reduce(drl_sub3_q) and not low_lat_degrade_q) or --
                             (triplet_9dd_q and triplet_9dd_valid_flit and meta_thresh_val) or
                             (max_bw_ip and meta_thresh_val) or
                             (triplet_999_q and low_lat_degrade_q and not (rd_resp_degrade_stall_one_q or rd_resp_degrade_stall_dec)and not tmpl5_flit_sub0_q)
                           );

  triplet_9d9_rd_pop_vld <= (ow_in_flit and (drl_sub3_q<1) and not drl_sub2_val_q and not drl_sub1_val_q and drl_prev_val_q and mid_bw_enab); --OR

  triplet_9dd_rd_pop_vld <= ow_in_flit and
                            ((not (max_bw_ip or or_reduce(drl_current)) and (drl_sub3_q<2) and not drl_in_pipe) or ((max_bw_ip or or_reduce(drl_current)) and drl_sub3_q<2));--


  meta_thresh_val <= hi_bw_enab_rd_thresh_int or
                        not meta_fifo_empty_q;

  rd_pend_gate_d <= low_lat_mode and
                    (
                      (triplet_999_q and not ow_in_flit and (not rd_resp_empty_q or mmio_resp_pend_q)) OR
                      (triplet_9d9_q and (not ow_in_flit or triplet_9d9_rd_pop_vld)) OR
                      (triplet_9dd_q and (not ow_in_flit or triplet_9dd_rd_pop_vld))
                    );


  tmpl5_flit_rd_gate <= tmpl_config(5) and
                        (
                          (max_bw_ip and tmpl5_flit_pend) or
                          (not max_bw_ip and tmpl5_flit_sub2_d) or
                          (drl_current_2 and tmpl5_flit_sub0_q) or
                          (drl_current_1 and tmpl5_flit_sub1_q) or
                          ((drl_sub1_q=1) and tmpl5_flit_sub1_q)
                        );

  triplet_9dd_valid_flit <=  not (not max_bw_ip and drl_in_pipe) or
                             max_bw_ip or or_reduce(drl_current);

  rd_resp_ow_pop <= (rd_resp_ow_pop_low_lat or rd_resp_ow_pop_hi_lat) and not half_dimm_mode;

  rd_resp_ow_pop_low_lat <= resp_pop_vld AND
                            tlx_vc0_avail and
                            tlx_dcp0_avail and
                            not wr_resp_flush_q and
                            (low_lat_mode and not lane_width_transition) and 
                            rd_resp_ow_pend_q and
                            not ow_in_flit and
                            not tmpl5_flit_rd_gate and
                            (
                              (triplet_999_q and not drl_sub2_val_q and (drl_sub1_q<2) and not or_reduce(drl_sub3_q) and not low_lat_degrade_q) or
                              (triplet_9dd_q and triplet_9dd_valid_flit) or
                              (max_bw_ip) or
                              (triplet_999_q and low_lat_degrade_q and not tmpl5_flit_sub0_q)
                            );

  rd_resp_ow_pop_hi_lat <= resp_pop_vld and
                           tlx_vc0_avail and
                           tlx_dcp0_avail and
                           tmpl_config(9) and
                           not (flit_xmit_start_q or flit_xmit_start_t1_q) and
                           not ow_in_flit_hi_lat and
                           not (rdf_1st_32B_sub0_q or mmio_data_sub1_q) and
                           hi_lat_mode and
                           rd_resp_ow_pend_q;


  rd_stall_ll_or_hd <= (flit_xmit_start_q or flit_xmit_start_t1_q) and not data_pending_int;

  --------------------------------------------------------------------------------------------------
  -- Write Response Pop
  --------------------------------------------------------------------------------------------------
  wr_resp_pop <= resp_pop_vld and
                 not wr_resp_empty_q AND
                 NOT wr_resp_unrec_stall_q AND
                 not (tmpl0 and intrp_req_pend and tlx_vc3_avail) and
                 tlx_vc0_avail and
                 (
                   (not rd_resp_pop_int and
                   not rd_resp_ow_pop and
                   not mmio_resp_pop_int and
                    not fail_resp_pop) or
                   (wr_resp_flush_q and (tmpl5 or (tmpl9 and triplet_999_q)))
                 );

  --------------------------------------------------------------------------------------------------
  -- MMIO Response pop
  --------------------------------------------------------------------------------------------------
  mmio_resp_pop <=  mmio_resp_pop_64B;

  mmio_resp_pop_load <= mmio_resp_pop_tmpl9 or mmio_resp_pop_half_dimm;
  mmio_resp_pop_int <= mmio_resp_pop_load or mmio_resp_pop_64B;

  mmio_resp_pop_common <= resp_pop_vld and mmio_resp_pend_q and tlx_vc0_avail and tlx_dcp0_avail and not wr_resp_flush_q;

  mmio_resp_pop_tmpl9 <= mmio_resp_pop_common and
                         not (hi_lat_mode and rdf_1st_32B_sub1_q) and
                         not rd_resp_ow_pend_q and
                         (tmpl9 and tmpl9_opt_val_q) and 
                         not (mmio_data_pending or mmio_data_current) and
                         not (tmpl5_flit_rd_gate or tmpl5_flit_pend) and
                         (
                           mmio_resp_pop_tmpl9_low_lat or
                           (hi_lat_mode and not ow_in_flit_hi_lat and not tmpl5_intrp_opt_val_q and not or_reduce(flit_rd_resp_q))
                         );

  mmio_resp_pop_tmpl9_low_lat <= low_lat_mode and not lane_width_transition and not ow_in_flit and
                                (
                                  (not drl_sub2_val_q and triplet_9d9_q and not triplet_9dd_q) OR
                                  (triplet_999_q and not drl_sub2_val_q and (drl_sub1_q<2) and not or_reduce(drl_sub3_q) and not low_lat_degrade_q) or
                                  (triplet_9dd_q and triplet_9dd_valid_flit) or
                                  (triplet_999_q and low_lat_degrade_q and not tmpl5_flit_sub0_q)
                                );

  mmio_resp_pop_64B <= mmio_resp_pop_common and not or_reduce(flit_rd_resp_q) and not (low_lat_mode and (triplet_state_val_q or lane_width_transition)) and 
                       not (half_dimm_mode and (intrp_req_pend or tmpl_config(11))) AND 
                       (
                         ((tmpl0) and not tl_4sl_pkt_full_q and not (tmpl9_opt_val_q and not half_dimm_mode)) OR
                         (tmpl1 and hi_lat_mode and not tmpl9_opt_val_q) OR
                         (tmpl5 and not wr_resp_flush_q and not tmpl9_opt_val_q) OR
                         (tmpl9 and or_reduce(tmpl9_xmit_rate))
                       );

  tlxt_tlxc_consume_val   <= rd_resp_pop_int OR wr_resp_pop or mmio_resp_pop_int or rd_resp_ow_pop or fail_resp_pop or intrp_req_pop or assign_actag_pop;
  tlxt_tlxc_consume_vc0   <= gate("0001", rd_resp_pop_int OR wr_resp_pop or mmio_resp_pop_int or rd_resp_ow_pop or fail_resp_pop);
  tlxt_tlxc_consume_vc3   <= gate("0001", intrp_req_pop or assign_actag_pop);
  tlxt_tlxc_consume_dcp0  <= gate("0001", rd_resp_pop_int or rd_resp_ow_pop or mmio_resp_pop_int ) OR
                             gate("0000", not (rd_resp_pop_int or rd_resp_ow_pop or mmio_resp_pop_int) );
  tlxt_tlxc_consume_dcp3  <= "0000";

  all_1sl_fifo_empty <= not mmio_resp_pend_q and rd_resp_empty_q and wr_resp_empty_q;
  all_fifo_empty <= all_1sl_fifo_empty and fail_resp_empty_q;
-------------------------------------------------------------------------------
-- rd resp control
-------------------------------------------------------------------------------

  rd_resp_input(23 downto 0)      <= ECCGEN(rd_resp) & rd_resp;
  rd_resp_push                    <= rd_resp_val;

   rd_resp_fifo : entity work.cb_gp_fifo
    generic map (
      width      => 24,
      depth      => 32,
      addr_width => 5)
    port map (
      gckn     => gckn,
      din      => rd_resp_input,
      wr       => rd_resp_push,
      rd       => rd_resp_pop,
      dout     => rd_resp_out,
      empty    => rd_resp_empty,
      full     => rd_resp_fifo_full,
      gnd      => gnd,
      vdd      => vdd,
      syncr    => syncr,
      fifo_err => rd_resp_fifo_err(1 downto 0),
      count    => rd_resp_count(5 downto 0));


  --Generate ECC on ingoing response. (Using 18B ECC Gen function function)
  rd_resp_syndrome(5 downto 0) <= ECCGEN(rd_resp_out(17 downto 0)) xor rd_resp_out(23 downto 18);

  rd_resp_out_corr(19 downto 0) <= ECCCORR_MAX('1', rd_resp_syndrome, 18);

  rd_resp_corrected(17 downto 0) <= '0' & (rd_resp_out(16 downto 0) xor rd_resp_out_corr(16 downto 0));

  rd_resp_corrected_17_12_p <= XOR_REDUCE(rd_resp_out(16 downto 12)) xor OR_REDUCE(rd_resp_out_corr(16 downto 12));
  rd_resp_corrected_11_4_p  <= XOR_REDUCE(rd_resp_out(11 downto  4)) xor OR_REDUCE(rd_resp_out_corr(11 downto  4));
  rd_resp_corrected_3_0_p   <= XOR_REDUCE(rd_resp_out( 3 downto  0)) xor OR_REDUCE(rd_resp_out_corr( 3 downto  0));
  rd_resp_corrected_17_16_p <= XOR_REDUCE('0'&rd_resp_out(16)) xor OR_REDUCE('0'&rd_resp_out_corr(16));
  rd_resp_corrected_15_8_p  <= XOR_REDUCE(rd_resp_out(15 downto  8)) xor OR_REDUCE(rd_resp_out_corr(15 downto  8));
  rd_resp_corrected_7_0_p   <= XOR_REDUCE(rd_resp_out( 7 downto  0)) xor OR_REDUCE(rd_resp_out_corr( 7 downto  0));

  rd_resp_CE <= rd_resp_out_corr(19);
  rd_resp_UE <= rd_resp_out_corr(18);
  rd_resp_len32 <= hi_lat_mode and (rd_resp_out(17) xor rd_resp_out_corr(17)) and not rd_resp_empty_q;


  --copy of mmio data flit mechanism
  rd_resp_len32_flit_pend_d <= (rd_resp_pop_int and rd_resp_len32  and not tmpl_config(9) and hi_lat_mode) OR
                               (rd_resp_len32_flit_pend_q and not (flit_xmit_early_done and not data_flit_xmit_int));
  rd_resp_len32_flit_d <= (rd_resp_len32_flit_pend_q and (flit_xmit_early_done and not data_flit_xmit_int)) OR
                          (rd_resp_len32_flit_q and not (data_flit_xmit_int and flit_xmit_early_done));

  rd_resp_len32_flit_del_d <= (rd_resp_len32_flit_q and flit_credit_avail) or (rd_resp_len32_flit_del_q and not flit_credit_avail); 
  rd_resp_len32_flit_early <= rd_resp_len32_flit_del_d;
  rd_resp_len32_flit <= rd_resp_len32_flit_del_q;

  --1/2 and 1/4 full indicators for template optimiazation in high lat mode
  rd_resp_half_full <= (rd_resp_count>=16);
  rd_resp_qt_full <= (rd_resp_count>=8);

  rd_resp_empty_d <= (rd_resp_empty and not rd_resp_push) or
                     ((rd_resp_count=1) and rd_resp_pop_int and not rd_resp_push);


-------------------------------------------------------------------------------
-- wr resp control
-------------------------------------------------------------------------------
  --add ECC generation on response and feed into FIFO.
  wr_resp_input(26 downto 0)      <= ECCGEN_21(wr_resp) & wr_resp;
  wr_resp_push                    <= wr_resp_val;

  tlxt_tlxr_wr_resp_full <= wr_resp_fifo_full;
  wr_resp_fifo : entity work.cb_gp_fifo
    generic map (
      width      => 27,
      depth      => 8,
      addr_width => 3)
    port map (
      gckn     => gckn,
      din      => wr_resp_input,
      wr       => wr_resp_push,
      rd       => wr_resp_pop,
      dout     => wr_resp_out,
      empty    => wr_resp_empty,
      full     => wr_resp_fifo_full,
      gnd      => gnd,
      vdd      => vdd,
      syncr    => syncr,
      fifo_err => wr_resp_fifo_err(1 downto 0),
      count    => wr_resp_count(3 downto 0));

  --ECC correct/gen
  wr_resp_syndrome(5 downto 0) <= ECCGEN_21(wr_resp_out(20 downto 0)) xor wr_resp_out(26 downto 21);

  wr_resp_out_corr(22 downto 0) <= ECCCORR_21('1', wr_resp_syndrome(5 downto 0));

  wr_resp_corrected(20 downto 0) <= wr_resp_out(20 downto 0) xor wr_resp_out_corr(20 downto 0);
  wr_resp_corrected_20_13_p      <= XOR_REDUCE(wr_resp_out(20 downto 13)) xor OR_REDUCE(wr_resp_out_corr(20 downto 13));
  wr_resp_corrected_18_17_p      <= XOR_REDUCE(wr_resp_out(18 downto 17)) xor OR_REDUCE(wr_resp_out_corr(18 downto 17));
  wr_resp_corrected_18_13_p      <= XOR_REDUCE(wr_resp_out(18 downto 13)) xor OR_REDUCE(wr_resp_out_corr(18 downto 13));
  wr_resp_corrected_12_5_p       <= XOR_REDUCE(wr_resp_out(12 downto  5)) xor OR_REDUCE(wr_resp_out_corr(12 downto  5));
  wr_resp_corrected_4_1_p        <= XOR_REDUCE(wr_resp_out( 4 downto  1)) xor OR_REDUCE(wr_resp_out_corr( 4 downto  1));
  wr_resp_corrected_20_17_p      <= XOR_REDUCE(wr_resp_out(20 downto 17)) xor OR_REDUCE(wr_resp_out_corr(20 downto 17));
  wr_resp_corrected_16_9_p       <= XOR_REDUCE(wr_resp_out(16 downto  9)) xor OR_REDUCE(wr_resp_out_corr(16 downto  9));
  wr_resp_corrected_8_1_p        <= XOR_REDUCE(wr_resp_out( 8 downto  1)) xor OR_REDUCE(wr_resp_out_corr( 8 downto  1));

  wr_resp_CE <= wr_resp_out_corr(22);
  wr_resp_UE <= wr_resp_out_corr(21);

  --wr_response formatting
  wr_resp_opcode       <= '1' & "00000100";
  mem_cntl_resp_opcode <= '1' & "00001011";

  wr_resp_full <= gate(wr_resp_corrected(18 downto 17) &
                       "00" &
                       wr_resp_corrected(16 downto 1) &
                       wr_resp_opcode(7 downto 0),              NOT wr_resp_UE);

  wr_resp_full_p  <= wr_resp_corrected_18_13_p                -- Parity over 27:20
                   & wr_resp_corrected_12_5_p                 -- Parity over 19:12
                   & (wr_resp_corrected_4_1_p xor '0')        -- Parity over 11:4
                   & wr_resp_opcode(8)                        -- Parity over 3:0
                  &  wr_resp_corrected_18_17_p                -- Parity over 27:24
                   & wr_resp_corrected_16_9_p                 -- Parity over 23:16
                   & wr_resp_corrected_8_1_p                  -- Parity over 15:8
                   & wr_resp_opcode(8);                       -- Parity over 7:0

  mem_cntl_resp <= gate(wr_resp_corrected(20 downto 17) &  -- 27:24
                        wr_resp_corrected(16 downto 1) &    -- 23:8
                        mem_cntl_resp_opcode(7 downto 0),      NOT wr_resp_UE);  -- 7:0

  mem_cntl_resp_p <= wr_resp_corrected_20_13_p                -- Parity over 27:20
                   & wr_resp_corrected_12_5_p                 -- Parity over 19:12
                   & (wr_resp_corrected_4_1_p xor '0')        -- Parity over 11:4
                   & mem_cntl_resp_opcode(8)                  -- Parity over 3:0
                  &  wr_resp_corrected_20_17_p                -- Parity over 27:24
                   & wr_resp_corrected_16_9_p                 -- Parity over 23:16
                   & wr_resp_corrected_8_1_p                  -- Parity over 15:8
                   & mem_cntl_resp_opcode(8);                 -- Parity over 7:0

  wr_resp_pkt <= gate(wr_resp_full,             wr_resp_pop and not wr_resp_corrected(0)) OR
                 gate(mem_cntl_resp,            wr_resp_pop and     wr_resp_corrected(0));

  wr_resp_pkt_p<=gate(wr_resp_full_p,           wr_resp_pop and not wr_resp_corrected(0)) OR
                 gate(mem_cntl_resp_p,          wr_resp_pop and     wr_resp_corrected(0));

  wr_resp_flush_d <= (flit_xmit_start_q and wr_resp_fifo_full and not fail_resp_flush_q and tlx_vc0_avail and not (low_lat_mode or half_dimm_mode)) or (wr_resp_flush_q and not flit_xmit_start_q);

  --1/2 full indicator for template optimization
  wr_resp_half_full <= (wr_resp_count>=4);

  wr_resp_empty_d <= (wr_resp_empty and not wr_resp_push) or
                     ((wr_resp_count=1) and wr_resp_pop and not wr_resp_push);

-------------------------------------------------------------------------------
-- MMIO Resp in
-------------------------------------------------------------------------------
  mmio_resp_push <= mmio_resp_val and not (mmio_resp_pend_q or mmio_data_flit_q or mmio_data_flit_del_q or mmio_data_flit_pend_q);
  mmio_resp_input(23 downto 0) <=  ECCGEN(mmio_tlxt_resp) & mmio_tlxt_resp;
  mmio_resp_ack <= mmio_resp_push;

  mmio_resp_d(23 downto 0) <= gate(mmio_resp_input, mmio_resp_push) OR
                              gate(mmio_resp_q, not mmio_resp_push);

  mmio_resp_out <= gate(mmio_resp_q,    mmio_resp_pop_int);

  mmio_resp_pend_d <= (not mmio_resp_pend_q and mmio_resp_push) OR
                      (mmio_resp_pend_q and not mmio_resp_pop_int);

  mmio_resp_empty <= not mmio_resp_pend_q;

  mmio_resp_syndrome(5 downto 0) <= ECCGEN(mmio_resp_out(17 downto 0)) xor mmio_resp_out(23 downto 18);

  mmio_resp_out_corr(19 downto 0) <= ECCCORR_MAX('1', mmio_resp_syndrome, 18);

  mmio_resp_corrected(17 downto 0) <= mmio_resp_out(17 downto 0) xor mmio_resp_out_corr(17 downto 0);
  mmio_resp_corrected_16_9_p  <= XOR_REDUCE(mmio_resp_out(16 downto  9)) xor OR_REDUCE(mmio_resp_out_corr(16 downto  9));
  mmio_resp_corrected_16_13_p <= XOR_REDUCE(mmio_resp_out(16 downto 13)) xor OR_REDUCE(mmio_resp_out_corr(16 downto 13));
  mmio_resp_corrected_12_5_p  <= XOR_REDUCE(mmio_resp_out(12 downto  5)) xor OR_REDUCE(mmio_resp_out_corr(12 downto  5));
  mmio_resp_corrected_8_1_p   <= XOR_REDUCE(mmio_resp_out( 8 downto  1)) xor OR_REDUCE(mmio_resp_out_corr( 8 downto  1));
  mmio_resp_corrected_4_1_p   <= XOR_REDUCE(mmio_resp_out( 4 downto  1)) xor OR_REDUCE(mmio_resp_out_corr( 4 downto  1));

  mmio_resp_CE <= mmio_resp_out_corr(19);
  mmio_resp_UE <= mmio_resp_out_corr(18);

  --mmio_resp_formatting
  mmio_resp_full <=  gate(mmio_resp_dat_part(3 downto 0) &     -- 27:24
                          mmio_resp_corrected(16 downto 1) &   -- 23:8
                          mmio_resp_opcode(7 downto 0),         NOT mmio_resp_UE);        -- 7:0

  mmio_resp_full_p<= (mmio_resp_dat_part(4) xor mmio_resp_corrected_16_13_p) -- Parity over 27:20
                   & mmio_resp_corrected_12_5_p                              -- Parity over 19:12
                   & (mmio_resp_corrected_4_1_p xor '0')                     -- Parity over 11:4
                   & mmio_resp_opcode(8)                                     -- Parity over 3:0
                  &  mmio_resp_dat_part(4)                                   -- Parity over 27:24
                   & mmio_resp_corrected_16_9_p                              -- Parity over 23:16
                   & mmio_resp_corrected_8_1_p                               -- Parity over 15:8
                   & mmio_resp_opcode(8);                                    -- Parity over 7:0

  mmio_resp_opcode <= gate('0' & "00000011",          mmio_resp_pop_load) OR  -- Bit 8 is parity
                      gate('1' & "00000001",          mmio_resp_pop);

  mmio_resp_dat_part(4 downto 0) <= gate('0' & "0000", mmio_resp_pop_load) OR -- Bit 4 is parity over 3:0
                                    gate('1' & "0100", mmio_resp_pop);

  -----------------------------------------------------------------------------
  -- MMIO Data Buffer
  -----------------------------------------------------------------------------
  mmio_data_buffer_d(255 downto 0) <= gate(mmio_tlxt_rdata_bus(255 downto 0),   mmio_resp_push) OR
                                      gate(mmio_data_buffer_q(255 downto 0),    not mmio_resp_push);
  mmio_data_buffer_p_d(31 downto 0)<=gate(mmio_tlxt_rdata_bus(287 downto 256),  mmio_resp_push) OR   -- Bytewise even parity
                                     gate(mmio_data_buffer_p_q(31 downto 0),    not mmio_resp_push);

  mmio_data_val <= ((tmpl9 or tmplB) and mmio_data_current);

  mmio_data_flit_pend_d <= (mmio_resp_pop  and not triplet_state_val_q) OR
                           (mmio_data_flit_pend_q and not (flit_xmit_early_done and not data_flit_xmit_int));
  mmio_data_flit_d <= (mmio_data_flit_pend_q and (flit_xmit_early_done and not data_flit_xmit_int)) OR
                      (mmio_data_flit_q and not (data_flit_xmit_int and flit_xmit_early_done));

  mmio_data_flit_del_d <= (mmio_data_flit_q and flit_credit_avail) or (mmio_data_flit_del_q and not flit_credit_avail); 
  mmio_data_flit_early <= mmio_data_flit_del_d;
  mmio_data_flit <= mmio_data_flit_del_q;
  --bad data
  mmio_bdi_d(1 downto 0) <= gate(mmio_tlxt_rdata_bdi & mmio_tlxt_rdata_bdi,             mmio_resp_push) or
                            gate(mmio_bdi_q(1 downto 0),                                not mmio_resp_push);

  mmio_bdi_poisoned <= (mmio_bdi_q(1) xor mmio_bdi_q(0)) and bdi_pop and bdi_0_vld and mmio_data_flit_q;
  mmio_bdi <= mmio_bdi_q(0) or mmio_bdi_poisoned;

  mmio_ow_bdi_d(1 downto 0) <= gate(mmio_bdi_q(1 downto 0),             mmio_resp_pop_int and low_lat_mode) or
                               gate(mmio_ow_bdi_q(1 downto 0),          not (mmio_resp_pop_int and low_lat_mode));

  mmio_ow_bdi_poisoned <= (mmio_ow_bdi_q(1) xor mmio_ow_bdi_q(0)) and mmio_data_current and flit_xmit_start_q;
  mmio_ow_bdi <= mmio_ow_bdi_q(0) or mmio_ow_bdi_poisoned;

  --------------------------------------------------------------------------------------------------
  -- Failure Response Queue
  --------------------------------------------------------------------------------------------------
  fail_resp_input_ecc(39 downto 0) <= ECCGEN_32(fail_resp_input) & fail_resp_input;
  fail_resp_fifo : entity work.cb_gp_fifo
    generic map (
      width      => 40,
      depth      => 8,
      addr_width => 3)
    port map (
      gckn     => gckn,
      din      => fail_resp_input_ecc(39 downto 0),
      wr       => fail_resp_val,
      rd       => fail_resp_pop,
      dout     => fail_resp_out,
      empty    => fail_resp_empty,
      full     => fail_resp_full,
      gnd      => gnd,
      vdd      => vdd,
      syncr    => syncr,
      fifo_err => fail_resp_fifo_err(1 downto 0),
      count    => fail_resp_count(3 downto 0));

  --Generate/check ECC
  fail_resp_syndrome(7 downto 0) <= ECCGEN_32(fail_resp_out(31 downto 0)) xor fail_resp_out(39 downto 32);

  fail_resp_out_corr(33 downto 0) <= ECCCORR_32('1', fail_resp_syndrome(7 downto 0));

  fail_resp_corrected(31 downto 0) <= fail_resp_out(31 downto 0) xor fail_resp_out_corr(31 downto 0);
  fail_resp_corrected_31_28_p      <= XOR_REDUCE(fail_resp_out(31 downto 28)) xor OR_REDUCE(fail_resp_out_corr(31 downto 28));
  fail_resp_corrected_27_24_p      <= XOR_REDUCE(fail_resp_out(27 downto 24)) xor OR_REDUCE(fail_resp_out_corr(27 downto 24));
  fail_resp_corrected_23_0_p       <= (not GENPARITY(fail_resp_out(23 downto 0)))
                                  xor (OR_REDUCE(fail_resp_out_corr(23 downto 16)) & OR_REDUCE(fail_resp_out_corr(15 downto 8)) & OR_REDUCE(fail_resp_out_corr(7 downto 0)) );

  fail_resp_CE <= fail_resp_out_corr(33);
  fail_resp_UE <= fail_resp_out_corr(32);

  fail_resp_pop_d <= not fail_resp_pop_q and
                     NOT fail_resp_unrec_stall_q AND
                     not fail_resp_empty_q and
                     not flit_buffer_reset and
                     not rd_resp_ow_pend_q and
                     not assign_actag_pend and
                     not rd_pend_gate_q and
                     not (rd_resp_push and not data_pending_int and rd_resp_empty_q) and
                     not (mmio_resp_pop_tmpl9_low_lat and (mmio_resp_pend_q or mmio_resp_pend_d) and not fail_resp_flush_q) and
                     (
                       ((tmplB or tmpl9 or tmpl5) and not tl_2sl_pkt_full_q) OR
                       (tmpl1 and not flit_full_q and not intrp_req_pend and not (pkt_vld_4sl(0) and tlxc_tlxt_crd_ret_val)) or
                       ((tmpl5 or tmpl0) and not tl_4sl_pkt_full_q and not intrp_req_pend)
                     );

  fail_resp_pop <= fail_resp_pop_q and tlx_vc0_avail and not rd_pend_gate_q and not (flit_hold or flit_full_q or (tl_2sl_pkt_full_q and not (tmpl0 or tmpl1)) or tl_4sl_pkt_full_q);

  fail_resp(55 downto 0) <= gate(fail_resp_corrected(31 downto 28) & x"000000" & fail_resp_corrected(27 downto 0),      NOT fail_resp_UE);
  fail_resp_p(6 downto 0)<= fail_resp_corrected_31_28_p       &   "00"    & fail_resp_corrected_27_24_p & fail_resp_corrected_23_0_p;

  --half full indicator for template optimization
  fail_resp_half_full <= (fail_resp_count>=4);

  fail_resp_flush_d <= (flit_xmit_start_q and fail_resp_half_full and tmpl_config(1) and not ((low_lat_mode and (triplet_state_val_q or not rd_resp_empty_q or mmio_resp_pend_q)) or half_dimm_mode)) or
                       (fail_resp_flush_q and not rd_pend_gate_q and not (flit_xmit_start_q));

  fail_resp_empty_d <= (fail_resp_empty and not fail_resp_val) or
                     ((fail_resp_count=1) and fail_resp_pop and not fail_resp_val);

  --------------------------------------------------------------------------------------------------
  -- Meta Bit Field Packing
  --------------------------------------------------------------------------------------------------
  meta_fifo_input_ecc(10 downto 0) <= ECCGEN_6(meta_fifo_input) & meta_fifo_input;
  meta_fifo: entity work.cb_gp_fifo
    generic map (
      width           => 11,
      depth           => 32,
      addr_width      => 5)
    port map (
      gckn     => gckn,
      din      => meta_fifo_input_ecc,
      wr       => meta_fifo_push,
      rd       => meta_fifo_pop_int,
      dout     => meta_fifo_output,
      empty    => meta_fifo_empty,
      full     => meta_fifo_full,
      gnd      => gnd,
      vdd      => vdd,
      syncr    => syncr,
      fifo_err => meta_fifo_err( 1 downto 0),
      count    => meta_fifo_count(5 downto 0));

  meta_fifo_empty_d <= (meta_fifo_empty and not meta_fifo_push) or
                       ((meta_fifo_count=1) and meta_fifo_pop_int and not meta_fifo_push);

--Generate/Check/correct ECC
  meta_fifo_syndrome(4 downto 0) <= ECCGEN_6(meta_fifo_output(5 downto 0)) xor meta_fifo_output(10 downto 6);

  meta_fifo_out_corr( 7 downto 0) <= ECCCORR_6('1', meta_fifo_syndrome); -- CE UE dcorr(5:0)

  meta_fifo_corrected(5 downto 0) <= meta_fifo_output(5 downto 0) xor meta_fifo_out_corr(5 downto 0);
  meta_fifo_corrected_p           <= XOR_REDUCE(meta_fifo_output(5 downto 0)) xor OR_REDUCE(meta_fifo_out_corr(5 downto 0));
  meta_fifo_corr_p_54             <= XOR_REDUCE(meta_fifo_output(5 downto 4)) xor OR_REDUCE(meta_fifo_out_corr(5 downto 4));
  meta_fifo_corr_p_40             <= XOR_REDUCE(meta_fifo_output(4 downto 0)) xor OR_REDUCE(meta_fifo_out_corr(4 downto 0));
  meta_fifo_corr_p_53             <= XOR_REDUCE(meta_fifo_output(5 downto 3)) xor OR_REDUCE(meta_fifo_out_corr(5 downto 3));
  meta_fifo_corr_p_30             <= XOR_REDUCE(meta_fifo_output(3 downto 0)) xor OR_REDUCE(meta_fifo_out_corr(3 downto 0));
  meta_fifo_corr_p_52             <= XOR_REDUCE(meta_fifo_output(5 downto 2)) xor OR_REDUCE(meta_fifo_out_corr(5 downto 2));
  meta_fifo_corr_p_20             <= XOR_REDUCE(meta_fifo_output(2 downto 0)) xor OR_REDUCE(meta_fifo_out_corr(2 downto 0));
  meta_fifo_corr_p_51             <= XOR_REDUCE(meta_fifo_output(5 downto 1)) xor OR_REDUCE(meta_fifo_out_corr(5 downto 1));
  meta_fifo_corr_p_10             <= XOR_REDUCE(meta_fifo_output(1 downto 0)) xor OR_REDUCE(meta_fifo_out_corr(1 downto 0));

  meta_fifo_CE <= meta_fifo_out_corr(7);
  meta_fifo_UE <= meta_fifo_out_corr(6);

  --mux for each meta data field.
  mf_0(6 downto 0) <= gate("0000000",                           flit_buffer_reset) OR
                      gate('0' & meta_fifo_corrected,           not flit_buffer_reset and meta_fifo_pop and mf_0_vld) OR
                      gate('0' & meta_fifo_input,               not flit_buffer_reset and bypass_meta_fifo and (ow_meta_packed_q or mmio_data_current or tmpl5) and mf_0_vld) OR
                      gate(meta_vec_q(6 downto 0),              not (((meta_fifo_pop or bypass_meta_fifo) and mf_0_vld) or (flit_buffer_reset)));

  mf_1(6 downto 0) <= gate("0000000",                           flit_buffer_reset) OR
                      gate('0' & meta_fifo_corrected,           not flit_buffer_reset and meta_fifo_pop and mf_1_vld) OR
                      gate('0' & meta_fifo_input,               not flit_buffer_reset and bypass_meta_fifo and (ow_meta_packed_q or mmio_data_current or tmpl5) and mf_1_vld) OR
                      gate(meta_vec_q(13 downto 7),             not (((meta_fifo_pop or bypass_meta_fifo) and mf_1_vld) or (flit_buffer_reset)));

  mf_2(6 downto 0) <= gate("0000000",                           flit_buffer_reset) OR
                      gate('0' & meta_fifo_corrected,           not flit_buffer_reset and  meta_fifo_pop and mf_2_vld) OR
                      gate(meta_vec_q(20 downto 14),            not ((meta_fifo_pop and mf_2_vld) or (flit_buffer_reset)));

  mf_3(6 downto 0) <= gate("0000000",                           flit_buffer_reset) OR
                      gate('0' & meta_fifo_corrected,           not flit_buffer_reset and meta_fifo_pop and mf_3_vld) OR
                      gate(meta_vec_q(27 downto 21),            not ((meta_fifo_pop and mf_3_vld) or (flit_buffer_reset)));

  mf_4(6 downto 0) <= gate("0000000",                           flit_buffer_reset) OR
                      gate('0' & meta_fifo_corrected,           not flit_buffer_reset and  meta_fifo_pop and mf_4_vld) OR
                      gate(meta_vec_q(34 downto 28),            not ((meta_fifo_pop and mf_4_vld) or (flit_buffer_reset)));

  mf_5(6 downto 0) <= gate("0000000",                          flit_buffer_reset) OR
                      gate('0' & meta_fifo_corrected,           not flit_buffer_reset and meta_fifo_pop and mf_5_vld) OR
                      gate(meta_vec_q(41 downto 35),            not ((meta_fifo_pop and mf_5_vld) or (flit_buffer_reset)));

  mf_6(6 downto 0) <= gate("0000000",                           flit_buffer_reset) OR
                      gate('0' & meta_fifo_corrected,           not flit_buffer_reset and meta_fifo_pop and mf_6_vld) OR
                      gate(meta_vec_q(48 downto 42),            not ((meta_fifo_pop and mf_6_vld) or (flit_buffer_reset)));

  mf_7(6 downto 0) <= gate("0000000",                           flit_buffer_reset) OR
                      gate('0' & meta_fifo_corrected,           not flit_buffer_reset and meta_fifo_pop and mf_7_vld) OR
                      gate(meta_vec_q(55 downto 49),            not ((meta_fifo_pop and mf_7_vld) or (flit_buffer_reset)));

  mq_55_49 <= XOR_REDUCE(meta_vec_p_q(6) & meta_vec_q(48));           mfp_48_48 <= '0'; -- bit 48 is '0'
  mq_48_48 <= XOR_REDUCE(meta_vec_p_q(6) & meta_vec_q(55 downto 49)); mfp_55_49 <= meta_fifo_corrected_p; -- bit 55 is '0'
  mq_47_42 <= XOR_REDUCE(meta_vec_p_q(5) & meta_vec_q(41 downto 40)); mfp_41_40 <= meta_fifo_corrected(5);-- bit 41 is '0'
  mq_41_40 <= XOR_REDUCE(meta_vec_p_q(5) & meta_vec_q(47 downto 42)); mfp_47_42 <= meta_fifo_corrected_p;
  mq_39_35 <= XOR_REDUCE(meta_vec_p_q(4) & meta_vec_q(34 downto 32)); mfp_34_32 <= meta_fifo_corr_p_54;   -- bit 34 is '0'
  mq_34_32 <= XOR_REDUCE(meta_vec_p_q(4) & meta_vec_q(39 downto 35)); mfp_39_35 <= meta_fifo_corr_p_40;
  mq_31_28 <= XOR_REDUCE(meta_vec_p_q(3) & meta_vec_q(27 downto 24)); mfp_27_24 <= meta_fifo_corr_p_53;   -- bit 27 is '0'
  mq_27_24 <= XOR_REDUCE(meta_vec_p_q(3) & meta_vec_q(31 downto 28)); mfp_31_28 <= meta_fifo_corr_p_30;
  mq_23_21 <= XOR_REDUCE(meta_vec_p_q(2) & meta_vec_q(20 downto 16)); mfp_20_16 <= meta_fifo_corr_p_52;   -- bit 20 is '0'
  mq_20_16 <= XOR_REDUCE(meta_vec_p_q(2) & meta_vec_q(23 downto 21)); mfp_23_21 <= meta_fifo_corr_p_20;
  mq_15_14 <= XOR_REDUCE(meta_vec_p_q(1) & meta_vec_q(13 downto  8)); mfp_13_8  <= meta_fifo_corr_p_51;    mbp_13_8 <= meta_p xor meta(0); -- bit 13 is '0'
  mq_13_8  <= XOR_REDUCE(meta_vec_p_q(1) & meta_vec_q(15 downto 14)); mfp_15_14 <= meta_fifo_corr_p_10;
  mq_7_7   <= XOR_REDUCE(meta_vec_p_q(0) & meta_vec_q( 6 downto  0)); mfp_6_0   <= meta_fifo_corrected_p;  mbp_6_0  <= meta_p; -- bit 6 is '0'
  mq_6_0   <= XOR_REDUCE(meta_vec_p_q(0) & meta_vec_q(7));            mfp_7_7   <= meta_fifo_corrected(0); mbp_7_7  <= meta(0);
  -- Bytewise parity
  meta_vec_p_d     <= gate("0000000",                                                                                                          flit_buffer_reset) OR
                      gate(meta_vec_p_q(6 downto 1) & (mq_7_7   xor mfp_6_0)                                                        , meta_fifo_pop and mf_0_vld) OR
                      gate(meta_vec_p_q(6 downto 1) & (mq_7_7   xor mbp_6_0)                                                        , bypass_meta_fifo and (ow_meta_packed_q or mmio_data_current or tmpl5) and mf_0_vld) OR
                      gate(meta_vec_p_q(6 downto 2) & (mq_15_14 xor mfp_13_8 ) & (mfp_7_7   xor mq_6_0  )                           , meta_fifo_pop and mf_1_vld) OR
                      gate(meta_vec_p_q(6 downto 2) & (mq_15_14 xor mbp_13_8 ) & (mbp_7_7   xor mq_6_0  )                           , bypass_meta_fifo and (ow_meta_packed_q or mmio_data_current or tmpl5) and mf_1_vld) OR
                      gate(meta_vec_p_q(6 downto 3) & (mq_23_21 xor mfp_20_16) & (mfp_15_14 xor mq_13_8 ) & meta_vec_p_q(0)         , meta_fifo_pop and mf_2_vld) OR
                      gate(meta_vec_p_q(6 downto 4) & (mq_31_28 xor mfp_27_24) & (mfp_23_21 xor mq_20_16) & meta_vec_p_q(1 downto 0), meta_fifo_pop and mf_3_vld) OR
                      gate(meta_vec_p_q(6 downto 5) & (mq_39_35 xor mfp_34_32) & (mfp_31_28 xor mq_27_24) & meta_vec_p_q(2 downto 0), meta_fifo_pop and mf_4_vld) OR
                      gate(meta_vec_p_q(6 downto 6) & (mq_47_42 xor mfp_41_40) & (mfp_39_35 xor mq_34_32) & meta_vec_p_q(3 downto 0), meta_fifo_pop and mf_5_vld) OR
                      gate(                           (mq_55_49 xor mfp_48_48) & (mfp_47_42 xor mq_41_40) & meta_vec_p_q(4 downto 0), meta_fifo_pop and mf_6_vld) OR
                      gate(                                                      (mfp_55_49 xor mq_48_48) & meta_vec_p_q(5 downto 0), meta_fifo_pop and mf_7_vld) OR
                      gate(meta_vec_p_q(6 downto 0),            not ((meta_fifo_pop or bypass_meta_fifo) or (flit_buffer_reset))                                );

  meta_vec_d(55 downto 0) <= mf_7 & mf_6 & mf_5 & mf_4 & mf_3 & mf_2 & mf_1 & mf_0;

  meta_fifo_input  <= meta;
  meta_fifo_pop    <= meta_max_not_reached and not meta_fifo_empty_q and not meta_fifo_ow_pop and not flit_buffer_reset and
                      (
                         (not all_meta_packed and ((ow_meta_packed_q or ow_meta_pend_q) and rdf_data_current) and low_lat_mode) OR
                         (not all_meta_packed and not rdf_data_current and low_lat_mode and not flit_xmit_start_t2_del_pulse_q) OR
                         (not all_meta_packed and mmio_data_current and low_lat_mode) OR
                         (rd_resp_pop_int and not (rd_resp_len32 and tmpl_config(9)) and hi_lat_mode) OR
                         (not all_meta_packed and tmpl5 and low_lat_mode)
                      );

  meta_fifo_pop_int <= not meta_fifo_empty_q and metadata_enabled and (('0'&mf_vld_q)<data_run_length_max) and (meta_fifo_pop or meta_fifo_ow_pop);
  meta_fifo_push   <= meta_val(1) and meta_val(0) and metadata_enabled and not bypass_meta_fifo and
                      (ow_meta_packed_q or not
                       meta_fifo_empty_q or
                       ow_meta_pend_q or
                       flit_ip or
                       mmio_data_current or
                       (not flit_ip and not flit_xmit_start_q and data_valid) or
                       (flit_xmit_start_q and data_valid and not tmpl9_data_valid));


  all_meta_packed <= ((('0'&mf_vld_q)=drl_current));

  --Bypass meta fifo in low latency mode where metadata comes later than expected
  bypass_meta_fifo <= (low_lat_mode and not all_meta_packed and and_reduce(meta_val) and meta_fifo_empty_q and (ow_meta_packed_q or mmio_data_current) and (flit_xmit_start_t1_q or flit_xmit_start_q)) OR
                      (low_lat_mode and not all_meta_packed and and_reduce(meta_val) and meta_fifo_empty_q and tmpl5 and drl_prev_val_q) OR
                      ( rdf_1st_32B_current and not mmio_data_current and tmpl9 and not ow_meta_packed_q and not ow_meta_pend_q and (meta_val(1) and     meta_val(0) and meta_fifo_empty_q) and not flit_buffer_reset);
  -- synopsys translate_off
  assert not (gckn'event and gckn='0' and bypass_meta_fifo='1' and flit_buffer_reset='1') report "TLXT: flit_arb: flit_buffer_reset collides with bypass_meta_fifo";
  -- synopsys translate_on

  meta_max_not_reached <= (('0'&mf_vld_q)<data_run_length_max);


  meta_fifo_ow_pop <= (rdf_data_current and not ow_meta_pend_q  and tmpl9 and not ow_meta_packed_q and not meta_fifo_empty_q and not mmio_data_current and (flit_xmit_start_pulse or (('0' & mf_vld_q)/=drl_current))) OR
                      (meta_fifo_data_flit_pop_vld and not mmio_data_current and data_flit_xmit_int and not ow_meta_pend_q  and tmpl9 and not ow_meta_packed_q and not meta_fifo_empty_q and low_lat_mode);

  meta_fifo_data_flit_pop_vld <= ((rdf_1st_32B_sub1_q or rdf_2nd_32B_sub1_q) and (data_run_length_q=2)) OR
                                 ((rdf_1st_32B_sub2_q or rdf_2nd_32B_sub2_q) and (data_run_length_q=2));

  mf_vld_reset <= flit_buffer_reset;
  mf_vld_inc <= (meta_fifo_pop and not meta_fifo_empty_q and (('0'&mf_vld_q)<data_run_length_max) and low_lat_mode) OR
                (mmio_resp_pop_64B AND low_lat_mode) OR
                (bypass_meta_fifo and (ow_meta_packed_q or tmpl5 or mmio_data_current)) OR
                ((rd_resp_pop_int or mmio_resp_pop_64B) and hi_lat_mode);
  mf_vld_hold <= not mf_vld_inc;
  mf_vld_d(2 downto 0) <=  gate("000",                           mf_vld_reset) OR
                           gate(mf_vld_q(2 downto 0) + 1,        not mf_vld_reset and mf_vld_inc) OR
                           gate(mf_vld_q(2 downto 0),            not mf_vld_reset and mf_vld_hold);

  mf_vld_p_d <= ('0'                                         AND mf_vld_reset) OR
                ((mf_vld_p_q xor INCP(mf_vld_q(2 downto 0))) AND not mf_vld_reset and mf_vld_inc) OR
                (mf_vld_p_q                                  AND not mf_vld_reset and mf_vld_hold);

  mf_0_vld <= (mf_vld_q(2 downto 0)="000");
  mf_1_vld <= (mf_vld_q(2 downto 0)="001");
  mf_2_vld <= (mf_vld_q(2 downto 0)="010");
  mf_3_vld <= (mf_vld_q(2 downto 0)="011");
  mf_4_vld <= (mf_vld_q(2 downto 0)="100");
  mf_5_vld <= (mf_vld_q(2 downto 0)="101");
  mf_6_vld <= (mf_vld_q(2 downto 0)="110");
  mf_7_vld <= (mf_vld_q(2 downto 0)="111");

  --choose meta data

  ow_meta_data(6 downto 0) <= gate("0000000",                              (tmpl9 and (flit_buffer_reset)) or mmio_data_current) or --
                              gate('0' & ow_meta_buffer_q(5 downto 0),     (not flit_xmit_early_done or data_flit_xmit_int)  and rdf_data_current and not mmio_data_current and tmpl9 and not ow_meta_packed_q and     ow_meta_pend_q and flit_xmit_start_pulse ) OR
                              gate('0' & meta_fifo_corrected,                 meta_fifo_ow_pop ) OR
                              gate('0' & meta,                             (not flit_xmit_early_done or data_flit_xmit_int) and rdf_data_current and not mmio_data_current and tmpl9 and not ow_meta_packed_q and not ow_meta_pend_q and (meta_val(1) and not meta_val(0) and meta_fifo_empty_q) and not (drl_prev_val_q and or_reduce(drl_current) and not (flit_xmit_start_q or flit_xmit_start_t1_q))) OR
                              gate('0' & meta,                             (not flit_xmit_early_done or data_flit_xmit_int) and rdf_data_current and not mmio_data_current and tmpl9 and not ow_meta_packed_q and not ow_meta_pend_q and (meta_val(1) and     meta_val(0) and meta_fifo_empty_q)) OR
                              gate(flit_buffer_2nd_half_q(6 downto 0),          (not flit_xmit_early_done or data_flit_xmit_int) and tmpl9 and    (ow_meta_packed_q));

  ow_meta_data_p           <= ('0'                            AND         ((tmpl9 and (flit_buffer_reset)) or mmio_data_current)) or --
                              (ow_meta_buffer_p_q             AND          (not flit_xmit_early_done or data_flit_xmit_int)  and rdf_data_current and not mmio_data_current and tmpl9 and not ow_meta_packed_q and     ow_meta_pend_q and flit_xmit_start_pulse ) OR
                              (meta_fifo_corrected_p          AND          meta_fifo_ow_pop ) OR
                              (meta_p                         AND          (not flit_xmit_early_done or data_flit_xmit_int) and rdf_data_current and not mmio_data_current and tmpl9 and not ow_meta_packed_q and not ow_meta_pend_q and (meta_val(1) and not meta_val(0) and meta_fifo_empty_q) and not (drl_prev_val_q and or_reduce(drl_current) and not (flit_xmit_start_q or flit_xmit_start_t1_q))) OR
                              (meta_p                         AND          (not flit_xmit_early_done or data_flit_xmit_int) and rdf_data_current and not mmio_data_current and tmpl9 and not ow_meta_packed_q and not ow_meta_pend_q and (meta_val(1) and     meta_val(0) and meta_fifo_empty_q)) OR
                              (flit_buffer_2nd_half_6_0_p     AND               (not flit_xmit_early_done or data_flit_xmit_int) and tmpl9 and    (ow_meta_packed_q));

  flit_buffer_2nd_half_6_0_p <= flit_buffer_2nd_half_q(7) xor flit_buffer_2nd_half_p_q(0);

  --store meta data for second octword if meta data was pulled from the queue
  ow_meta_buffer_d(5 downto 0) <= gate(meta_fifo_corrected,                    meta_fifo_ow_pop and not ow_meta_bypass_taken_q) OR
                                  gate(meta,                            not meta_fifo_ow_pop and rdf_1st_32B_current and not ow_meta_bypass_taken_q and not ow_meta_pend_q and meta_val(1) and meta_val(0) and meta_fifo_empty_q) OR
                                  gate(ow_meta_buffer_q(5 downto 0),    (not meta_fifo_ow_pop and not (not ow_meta_pend_q  and meta_val(1) and meta_val(0) and meta_fifo_empty_q)) or ow_meta_bypass_taken_q);

  ow_meta_buffer_p_d           <= (meta_fifo_corrected_p      AND              meta_fifo_ow_pop and not ow_meta_bypass_taken_q) OR
                                  (meta_p                     AND       not meta_fifo_ow_pop and rdf_1st_32B_current and not ow_meta_bypass_taken_q and not ow_meta_pend_q and meta_val(1) and meta_val(0) and meta_fifo_empty_q) OR
                                  (ow_meta_buffer_p_q         AND      ((not meta_fifo_ow_pop and not (not ow_meta_pend_q  and meta_val(1) and meta_val(0) and meta_fifo_empty_q)) or ow_meta_bypass_taken_q));

  --meta data in ow_data_buffer
  ow_meta_pend_d <= (rdf_1st_32B_current and not mmio_data_current and tmpl9 and not ow_meta_bypass_taken_q and meta_fifo_ow_pop and not hi_lat_mode) OR
                    (drl_prev_val_q and meta_fifo_ow_pop and not ow_meta_bypass_taken_q and not hi_lat_mode) OR
                    ( rdf_1st_32B_current and not mmio_data_current and tmpl9 and not ow_meta_packed_q and not ow_meta_pend_q and (meta_val(1) and     meta_val(0) and meta_fifo_empty_q) and not hi_lat_mode) OR
                    ( not (tmpl9 and flit_xmit_start_pulse and tmpl9_data_valid and not mmio_data_current) and ow_meta_pend_q) OR
                    ( ow_meta_packed_q and ow_meta_pend_q);
  --pack on flitxmit start if meta data in buffer

  ow_meta_packed_d <= (meta_fifo_ow_pop) OR
                      (rdf_data_current and not mmio_data_current and tmpl9 and not ow_meta_packed_q and     ow_meta_pend_q and flit_xmit_start_pulse) OR
                      (rdf_data_current and not mmio_data_current and not ow_meta_bypass_taken_q and tmpl9 and not ow_meta_packed_q and not ow_meta_pend_q and (meta_val(1) and not meta_val(0) and meta_fifo_empty_q) and not (drl_prev_val_q and or_reduce(drl_current) and not (flit_xmit_start_q or flit_xmit_start_t1_q))) OR
                      (rdf_data_current and not mmio_data_current and tmpl9 and not ow_meta_bypass_taken_q and not ow_meta_packed_q and not ow_meta_pend_q and (meta_val(1) and     meta_val(0) and meta_fifo_empty_q)) OR
                      (not (flit_xmit_start_t2_q and flit_credit_avail and tmpl9) and ow_meta_packed_q);

  ow_meta_bypass_taken_d <=(not ow_meta_bypass_taken_q and rdf_data_current and not mmio_data_current and tmpl9 and not ow_meta_packed_q and not ow_meta_pend_q and (meta_val(1) and not meta_val(0) and meta_fifo_empty_q) and not (drl_prev_val_q and or_reduce(drl_current) and not (flit_xmit_start_q or flit_xmit_start_t1_q))) OR
                           (ow_meta_bypass_taken_q and ((not meta_fifo_ow_pop) or ow_meta_packed_q));

  metadata_avail <= ((not meta_fifo_empty_q or or_reduce(meta_val) or ow_meta_pend_q or (ow_meta_packed_q and ow_meta_bypass_taken_q)) and not metadata_disabled and low_lat_mode) OR
                    (not meta_fifo_empty_q and not (rdf_data_current and not ow_meta_packed_q) and not low_lat_mode) OR
                    (metadata_disabled or half_dimm_mode);

  --------------------------------------------------------------------------------------------------
  -- Poison Bad data bit on Meta FIFO UE
  --------------------------------------------------------------------------------------------------
  meta_ue_poison_next_d(7 downto 0)<= gate("00000000",        flit_buffer_reset) OR
                                      gate("00000001",    not flit_buffer_reset and meta_fifo_ue  and mf_0_vld and meta_fifo_pop) OR
                                      gate("00000010",    not flit_buffer_reset and meta_fifo_ue and mf_1_vld and meta_fifo_pop) OR
                                      gate("00000100",    not flit_buffer_reset and meta_fifo_ue and mf_2_vld and meta_fifo_pop) OR
                                      gate("00001000",    not flit_buffer_reset and meta_fifo_ue and mf_3_vld and meta_fifo_pop) OR
                                      gate("00010000",    not flit_buffer_reset and meta_fifo_ue and mf_4_vld and meta_fifo_pop) OR
                                      gate("00100000",    not flit_buffer_reset and meta_fifo_ue and mf_5_vld and meta_fifo_pop) OR
                                      gate("01000000",    not flit_buffer_reset and meta_fifo_ue and mf_6_vld and meta_fifo_pop) OR
                                      gate("10000000",    not flit_buffer_reset and meta_fifo_ue and mf_7_vld and meta_fifo_pop) OR
                                      gate(meta_ue_poison_next_q,       not flit_buffer_reset and not meta_fifo_pop);

  meta_ue_poison_curr_d(7 downto 0) <= gate(meta_ue_poison_next_q,      flit_buffer_reset) or
                                       gate(meta_ue_poison_curr_q,      not flit_buffer_reset);


  --special meta field
  sp_meta(23 downto 0) <= meta_vec_d(13 downto 7) &  --mdf(1)
                          meta_vec_d(6 downto 0) &  --mdf(0)
                          '0' &  --shortened R feild. 1 too many bits
                          (tmpl9_data_valid or mmio_data_current) &
                          ow_bdi &
                          ow_meta_data(6 downto 0);

  sp_meta_p(2 downto 0)<= XOR_REDUCE(meta_vec_d(15 downto 14) & meta_vec_p_d(1) & meta_vec_d(5 downto 0) & meta_vec_p_d(0))  -- 23:16 from meta_vec_d(13:6)
                        & XOR_REDUCE(meta_vec_d( 7 downto  6) & meta_vec_p_d(0) & '0' & (tmpl9_data_valid or mmio_data_current))  -- 15:8 from meta_vec_d(5:0) 0 tmpl9_data_valid
                        & XOR_REDUCE(ow_bdi & ow_meta_data_p                                                              ); -- 7:0 from ow_bdi and ow_meta_data

  half_dimm_meta(27 downto 0) <= (others => '0');

  half_dimm_meta_p <= (others => '0');

  tmpl9_data_val <= tmpl9_data_valid;

 --------------------------------------------------------------------------------------------------
  -- Bad Data Bit FIFO
  --------------------------------------------------------------------------------------------------
  bdi_fifo: entity work.cb_gp_fifo
    generic map (
      width           => 2,
      depth           => 32,
      addr_width      => 5)
    port map (
      gckn     => gckn,
      din      => bdi_input(1 downto 0),
      wr       => bdi_push,
      rd       => bdi_pop_int,
      dout     => bdi_output(1 downto 0),
      empty    => bdi_empty,
      full     => bdi_full,
      gnd      => gnd,
      vdd      => vdd,
      syncr    => syncr,
      fifo_err => bdi_err( 1 downto 0),
      count    => bdi_count(5 downto 0));

  bdi_fifo_empty_d <= (bdi_empty and not bdi_push) or
                      ((bdi_count=1) and bdi_pop_int and not bdi_push);

  bdi_pop <= bdi_vld_inc and not flit_hold_2nd and not (mmio_data_flit_q and bdi_0_vld) and not bdi_fifo_empty_q;

  bdi_ow_pop <= ow_bdi_valid_flit and not bdi_fifo_empty_q and not ow_bdi_packed_q and not ow_bdi_pend_q and not (bdi_pop or (mmio_data_flit_q and bdi_0_vld));

  bdi_tmplB_pop <= tmplB_data_valid and not bdi_fifo_empty_q and not ow_bdi_packed_q;

  bdi_push <= bad_data_valid and not bad_data_1st32B and not bdi_full and
              ((hi_lat_mode and not (bdi_fifo_empty_q and ow_bdi_valid_flit and not ow_bdi_packed_q and (flit_xmit_start_q or flit_xmit_start_t1_q or (flit_xmit_start_t2_q and not flit_credit_avail)))) or
               (low_lat_mode AND NOT (bdi_bypass_taken_q and not ow_bdi_packed_q and rdf_2nd_32B_current) and
                (
                  ow_bdi_pend_q OR
                  rdf_1st_32B_current or
                  ow_bdi_packed_q OR
                  data_flit_xmit_int or
                  not bdi_fifo_empty_q OR
                  NOT ow_bdi_valid_flit
                )
               ) OR
               (half_dimm_mode)
              );


  bdi_pop_int <= (bdi_pop or bdi_ow_pop) and not bdi_fifo_empty_q;
  --Need to add the ECC stuff here. Currently just duplicating
  bdi_input(1 downto 0) <= bad_data & bad_data;

  --check bdi parity. poison on failure
  bdi_par_err <= (bdi_output(1) xor bdi_output(0));
  bdi_poisoned <=  (bdi_par_err and bdi_pop_int) or meta_fifo_unrec_q or bdi_fifo_unrec_q or tlxt_err_invalid_meta_cfg_q;
  bdi_out <= (bdi_output(0) and bdi_pop_int) or bdi_poisoned ;

  tlxt_err_bdi_poisoned <= bdi_pop_int and bdi_par_err;

  bdi_max_d(3 downto 0) <= gate(data_run_length_q,      flit_xmit_start_pulse) OR
                           gate(bdi_max_q(3 downto 0),  not flit_xmit_start_pulse);

  bdi_vld_inc <= (bdi_vld_q/=data_run_length_q) and (not bdi_fifo_empty_q or mmio_data_flit_q) ;

  bdi_vld_d(3 downto 0) <= gate("0000",                          flit_buffer_reset) OR
                           gate(bdi_vld_q(3 downto 0)+1,         not (flit_buffer_reset) and bdi_vld_inc) OR
                           gate(bdi_vld_q(3 downto 0),           not (flit_buffer_reset) and not bdi_vld_inc);

  bdi_vld_p_d <= ('0'                                        AND flit_buffer_reset) OR
              ((bdi_vld_p_q xor INCP(bdi_vld_q(3 downto 0))) AND not (flit_buffer_reset) and bdi_vld_inc) OR
              (bdi_vld_p_q                                   AND not (flit_buffer_reset) and not bdi_vld_inc);

  bdi_0_vld <= (bdi_vld_q(3 downto 0)="0000");
  bdi_1_vld <= (bdi_vld_q(3 downto 0)="0001");
  bdi_2_vld <= (bdi_vld_q(3 downto 0)="0010");
  bdi_3_vld <= (bdi_vld_q(3 downto 0)="0011");
  bdi_4_vld <= (bdi_vld_q(3 downto 0)="0100");
  bdi_5_vld <= (bdi_vld_q(3 downto 0)="0101");
  bdi_6_vld <= (bdi_vld_q(3 downto 0)="0110");
  bdi_7_vld <= (bdi_vld_q(3 downto 0)="0111");

  bdi_vec_d(7 downto 0) <= bdi_7 & bdi_6 & bdi_5 & bdi_4 & bdi_3 & bdi_2 & bdi_1 & bdi_0;
  bdi_vec_p_d(1 downto 0) <= XOR_REDUCE(bdi_7 & bdi_6 & bdi_5 & bdi_4) & XOR_REDUCE(bdi_3 & bdi_2 & bdi_1 & bdi_0);

  dl_cont_bdi_vec <= bdi_vec_q;
  dl_cont_bdi_vec_p <= bdi_vec_p_q;

  rdf_tlxt_data_err_d <= rdf_tlxt_data_err and not (hi_lat_mode and (flit_xmit_start_t2_q or flit_xmit_start_t3_q));

  rdf_tlxt_data_err_ow_d <= (rdf_tlxt_data_err and ow_bdi_valid_flit and not data_flit_xmit_int) OR
                            (rdf_tlxt_data_err_ow_q and not flit_buffer_reset);

  bdi_7 <= (bdi_out and bdi_pop and bdi_7_vld) or (bdi_vec_q(7) and not ((flit_buffer_reset) or (bdi_pop and bdi_7_vld))) or (data_flit_cnt_q(7) and rdf_tlxt_data_err_q) or meta_ue_poison_curr_q(7);
  bdi_6 <= (bdi_out and bdi_pop and bdi_6_vld) or (bdi_vec_q(6) and not ((flit_buffer_reset) or (bdi_pop and bdi_6_vld))) or (data_flit_cnt_q(6) and rdf_tlxt_data_err_q) or meta_ue_poison_curr_q(6);
  bdi_5 <= (bdi_out and bdi_pop and bdi_5_vld) or (bdi_vec_q(5) and not ((flit_buffer_reset) or (bdi_pop and bdi_5_vld))) or (data_flit_cnt_q(5) and rdf_tlxt_data_err_q) or meta_ue_poison_curr_q(5);
  bdi_4 <= (bdi_out and bdi_pop and bdi_4_vld) or (bdi_vec_q(4) and not ((flit_buffer_reset) or (bdi_pop and bdi_4_vld))) or (data_flit_cnt_q(4) and rdf_tlxt_data_err_q) or meta_ue_poison_curr_q(4);
  bdi_3 <= (bdi_out and bdi_pop and bdi_3_vld) or (bdi_vec_q(3) and not ((flit_buffer_reset) or (bdi_pop and bdi_3_vld))) or (data_flit_cnt_q(3) and rdf_tlxt_data_err_q) or meta_ue_poison_curr_q(3);
  bdi_2 <= (bdi_out and bdi_pop and bdi_2_vld) or (bdi_vec_q(2) and not ((flit_buffer_reset) or (bdi_pop and bdi_2_vld))) or (data_flit_cnt_q(2) and rdf_tlxt_data_err_q) or meta_ue_poison_curr_q(2);
  bdi_1 <= (bdi_out and bdi_pop and bdi_1_vld) or (bdi_vec_q(1) and not ((flit_buffer_reset) or (bdi_pop and bdi_1_vld))) or (data_flit_cnt_q(1) and rdf_tlxt_data_err_q) or meta_ue_poison_curr_q(1);
  bdi_0 <= (mmio_bdi and bdi_vld_inc and not flit_hold_2nd and bdi_0_vld) or
           (bdi_out and bdi_pop and bdi_0_vld) or (bdi_vec_q(0) and not ((flit_buffer_reset) or (bdi_pop and bdi_0_vld))) or
           (data_flit_cnt_q(0) and rdf_tlxt_data_err_q) or meta_ue_poison_curr_q(0);

  ow_bdi <= not flit_buffer_reset and ow_bdi_valid_flit and
            (
              (ow_bdi_buffer_q and                not ow_bdi_packed_q and     ow_bdi_pend_q and flit_xmit_start_q) OR
              (mmio_ow_bdi and                    not ow_bdi_packed_q and mmio_data_current and flit_xmit_start_q) OR
              (bdi_out and                        not ow_bdi_packed_q and ((not ow_bdi_pend_q and bdi_ow_pop) or bdi_tmplB_pop)) OR
              (bad_data and                       not ow_bdi_packed_q and not ow_bdi_pend_q and bad_data_valid and bdi_fifo_empty_q) OR
              (flit_buffer_2nd_half_q(7) and                 (ow_bdi_packed_q or rdf_tlxt_data_err_ow_q)) or
              (rdf_tlxt_data_err_q and (rdf_data_current or rdf_40B_sub0_q) and not or_reduce(data_flit_cnt_q)) or
              (bdi_poisoned) or  --unrecoverable error in bdi or meta fifo
              (meta_fifo_UE and meta_fifo_ow_pop)  --UE on ow_metadata
            );

  ow_bdi_valid_flit <= rdf_data_current and not mmio_data_current and tmpl9 and not flit_buffer_reset;

  --store bdi data for second octword if bdi data was pulled from the queue
  ow_bdi_buffer_d <= (ow_bdi          and       (bdi_ow_pop or (bdi_bypass_taken_d and not rdf_tlxt_data_err_q))) OR
                     (meta_fifo_UE    and       meta_fifo_ow_pop) or  --meta_fifo_UE poison
                     (bad_data        and    not ow_bdi_pend_q  and not ow_bdi_packed_q and bad_data_valid and bdi_fifo_empty_q AND ow_bdi_valid_flit and not (drl_prev_val_q and (bdi_vld_q/=data_run_length_q))) OR
                     (ow_bdi_buffer_q and    not (not ow_bdi_pend_q and ow_bdi_packed_q)) or
                     (rdf_tlxt_data_err_q and ow_bdi_pend_q and (flit_xmit_start_t3_q or flit_xmit_start_t4_q));

  --bdi data in ow_data_buffer
  ow_bdi_pend_d <= (ow_bdi_valid_flit and not bdi_bypass_taken_q and not rdf_2nd_32B_sub0_q and not ow_bdi_packed_q and bdi_ow_pop and not hi_lat_mode) OR
                   (meta_fifo_UE and meta_fifo_ow_pop) or  --meta_fifo_UE case
                   (ow_bdi_pend_q and not (ow_bdi_packed_d and not ow_bdi_packed_q));

  bdi_bypass_taken_d <= --(not bdi_bypass_taken_q and not mmio_data_current and rdf_data_current and (flit_xmit_start_pulse or flit_xmit_start_t1_q) and not ow_bdi_packed_q and not ow_bdi_pend_q and bad_data_valid and bdi_fifo_empty_q) OR
                        (not bdi_bypass_taken_q and ow_bdi_valid_flit and not ow_bdi_packed_q and not ow_bdi_pend_q and bad_data_valid and bad_data_1st32B and bdi_fifo_empty_q) OR
                        (rdf_1st_32B_current and not mmio_data_current and tmpl9 and (not ow_bdi_packed_q or (rdf_tlxt_data_err_ow_q and ow_bdi_packed_q)) and not ow_bdi_pend_q and flit_buffer_reset and bdi_fifo_empty_q) OR
                        (bdi_bypass_taken_q and not flit_buffer_reset);--(flit_xmit_start_pulse and tmpl9 and rdf_data_current));

  --pack on flitxmit start if bdi data in buffer
  ow_bdi_packed_d <= (ow_bdi_valid_flit and not ow_bdi_packed_q and     ow_bdi_pend_q and flit_xmit_start_pulse) OR
                     (ow_bdi_valid_flit and not ow_bdi_packed_q and not ow_bdi_pend_q and bdi_ow_pop) OR
                     (ow_bdi_valid_flit and not ow_bdi_packed_q and not ow_bdi_pend_q and bad_data_valid  and not (data_flit_xmit_int or drl_prev_val_q) and bdi_fifo_empty_q and not (hi_lat_mode and not (flit_xmit_start_q or flit_xmit_start_t1_q or (flit_xmit_start_t2_q and not flit_credit_avail)))) OR
                     (mmio_data_current and not ow_bdi_packed_q and flit_xmit_start_pulse) OR
                     (meta_fifo_UE and meta_fifo_ow_pop) OR
                     (ow_bdi_packed_q and not (flit_buffer_reset));

  --bad data count >= rd_resp_count. Tell how much data is ready in high latency mode

  bdi_avail <= not bdi_fifo_empty_q and (("00"&drl_current)<bdi_count) and  (("00"&data_run_length_q)<bdi_count) and not (hi_lat_mode and rdf_data_current and not ow_bdi_packed_q);

  --Poison BDI on read buffer ECC Error
  data_flit_cnt_d(7 downto 0) <= gate("00000000",       flit_xmit_start_pulse) or
                                 gate("00000001",       not or_reduce(data_flit_cnt_q) and flit_xmit_done_q and drl_last_non_zero) or
                                 gate("00000010",       data_flit_cnt_q(0) and flit_xmit_done_q and data_flit_xmit_int) or
                                 gate("00000100",       data_flit_cnt_q(1) and flit_xmit_done_q and data_flit_xmit_int) or
                                 gate("00001000",       data_flit_cnt_q(2) and flit_xmit_done_q and data_flit_xmit_int) or
                                 gate("00010000",       data_flit_cnt_q(3) and flit_xmit_done_q and data_flit_xmit_int) or
                                 gate("00100000",       data_flit_cnt_q(4) and flit_xmit_done_q and data_flit_xmit_int) or
                                 gate("01000000",       data_flit_cnt_q(5) and flit_xmit_done_q and data_flit_xmit_int) or
                                 gate("10000000",       data_flit_cnt_q(6) and flit_xmit_done_q and data_flit_xmit_int) or
                                 gate(data_flit_cnt_q,  not (flit_xmit_start_pulse or flit_xmit_done_q));

  flit_xmit_done_d <= flit_xmit_done;

-----------------------------------------------------------------------------
  --packet counter. How full is the flit?
  -----------------------------------------------------------------------------
  --total flit packet count
  flit_pkt_cnt_reset         <= flit_buffer_reset;--(flit_xmit_start_t2_d and not flit_hold) or (flit_xmit_start_t2_q and flit_hold);
  flit_pkt_cnt_inc           <= tl_1sl_vld_inc or tl_4sl_vld_inc;
  flit_pkt_cnt_hold          <= not flit_pkt_cnt_inc and not flit_pkt_cnt_reset;

  flit_pkt_cnt_d(3 downto 0) <= gate("0000", flit_pkt_cnt_reset) OR
                                gate(flit_pkt_cnt_q(3 downto 0)+"0001", flit_pkt_cnt_inc) OR
                                gate(flit_pkt_cnt_q, flit_pkt_cnt_hold);
  flit_pkt_cnt_p_d           <= ('0'                                                     AND flit_pkt_cnt_reset) OR
                                ((flit_pkt_cnt_p_q xor INCP(flit_pkt_cnt_q(3 downto 0))) AND flit_pkt_cnt_inc) OR
                                (flit_pkt_cnt_p_q                                        AND flit_pkt_cnt_hold);

  flit_full_d <= (not flit_full_q and (flit_pkt_cnt_q="0011") and (tmpl1 or tmpl9) and (tl_1sl_vld_inc or tl_4sl_vld_inc)) OR
                 (not flit_full_q and (flit_pkt_cnt_q="0111") and tmpl5 and tl_1sl_vld_inc) OR
                 (not flit_full_q and (flit_pkt_cnt_q="0001") and tmplB and tl_1sl_vld_inc) OR
                 (not flit_full_q and tl_4sl_pkt_full_d and tmpl0) OR
                 (flit_full_q and not flit_buffer_reset);

  --rd responses in current flit
  flit_rd_resp_d(3 downto 0) <= gate("0000",                                    flit_buffer_reset) OR
                                gate(flit_rd_resp_q(3 downto 0) + 1,            not flit_buffer_reset and (rd_resp_pop_int or rd_resp_ow_pop)) OR
                                gate(flit_rd_resp_q(3 downto 0),                not flit_buffer_reset and not (rd_resp_pop_int or rd_resp_ow_pop));

  flit_rd_resp_p_d <=('0'                                                   AND flit_buffer_reset) OR
                   ((INCP(flit_rd_resp_q(3 downto 0)) xor flit_rd_resp_p_q) AND not flit_buffer_reset and (rd_resp_pop_int or rd_resp_ow_pop)) OR
                   (flit_rd_resp_p_q                                        AND not flit_buffer_reset and not (rd_resp_pop_int or rd_resp_ow_pop));

  flit_wr_resp_d(3 downto 0) <= gate("0000",                                    flit_buffer_reset) OR
                                gate(flit_wr_resp_q(3 downto 0) + 1,            not flit_buffer_reset and wr_resp_pop) OR
                                gate(flit_wr_resp_q(3 downto 0),                not flit_buffer_reset and not wr_resp_pop);

  flit_wr_resp_p_d <= ('0'                                                  AND  flit_buffer_reset) OR
                   ((flit_wr_resp_p_q xor INCP(flit_wr_resp_q(3 downto 0))) AND  not flit_buffer_reset and wr_resp_pop) OR
                   (flit_wr_resp_p_q                                        AND  not flit_buffer_reset and not wr_resp_pop);

  flit_mmio_resp_d(3 downto 0) <= gate("0000",                                  flit_buffer_reset) OR
                                 gate(flit_mmio_resp_q(3 downto 0) + 1,         not flit_buffer_reset and mmio_resp_pop_int) OR
                                 gate(flit_mmio_resp_q(3 downto 0),             not flit_buffer_reset and not mmio_resp_pop_int);

  flit_mmio_resp_p_d          <= ('0'                                       AND flit_buffer_reset) OR
               ((flit_mmio_resp_p_q xor INCP(flit_mmio_resp_q(3 downto 0))) AND not flit_buffer_reset and mmio_resp_pop_int) OR
               (flit_mmio_resp_p_q                                          AND not flit_buffer_reset and not mmio_resp_pop_int);

  -----------------------------------------------------------------------------
  --Current 1 slot packet valid"
  -----------------------------------------------------------------------------

  tl_1sl_vld_reset         <= flit_buffer_reset; 
  tl_1sl_vld_inc           <= (wr_resp_pop or rd_resp_pop_int or mmio_resp_pop_int or rd_resp_ow_pop) and (tl_1sl_vld_q<="1011");
  tl_1sl_vld_hold          <= not tl_1sl_vld_inc or (tl_1sl_vld_q>"1011");
  tl_1sl_vld_d(3 downto 0) <= gate("1000",                              tl_1sl_vld_reset and tmpl9_next) or  --always tmpl
                              gate("0000",                              tl_1sl_vld_reset and tmpl5_next) or
                              gate("1010",                              tl_1sl_vld_reset and tmplB_next) or
                              gate(tl_1sl_vld_q(3 downto 0) +"0001",    not tl_1sl_vld_reset and tl_1sl_vld_inc) or
                              gate(tl_1sl_vld_q(3 downto 0),            not tl_1sl_vld_reset and tl_1sl_vld_hold);

  tl_1sl_vld_p_d <= ('1'                                            AND tl_1sl_vld_reset and tmpl9_next) or  --always tmpl
               ('0'                                                 AND tl_1sl_vld_reset and tmpl5_next) or
                    ('0'                                            and tl_1sl_vld_reset and tmplB_next) or
               ((tl_1sl_vld_p_q xor INCP(tl_1sl_vld_q(3 downto 0))) AND not tl_1sl_vld_reset and tl_1sl_vld_inc) or
               (tl_1sl_vld_p_q                                      AND not tl_1sl_vld_reset and tl_1sl_vld_hold);

  tl_1sl_pkt(27 downto 0)  <= gate(rd_resp_pkt(27 downto 0),              (rd_resp_ow_pop or rd_resp_pop_int) and not wr_resp_pop and not mmio_resp_pop_int) OR
                              gate(wr_resp_pkt(27 downto 0),          not (rd_resp_ow_pop or rd_resp_pop_int) and     wr_resp_pop and not mmio_resp_pop_int) OR
                              gate(mmio_resp_full(27 downto 0),       not (rd_resp_ow_pop or rd_resp_pop_int) and not wr_resp_pop and     mmio_resp_pop_int) OR
                              gate(rsvd_1sl,                          not (rd_resp_ow_pop or rd_resp_pop_int) and not wr_resp_pop and not mmio_resp_pop_int);

  -- tl_1sl_pkt_p 7:4 is P over tl_1sl_pkt 27:20, 19:12, 11:4, 3:0
  -- tl_1sl_pkt_p 3:0 is P over tl_1sl_pkt 27:24, 23:16, 15:8, 7:0
  tl_1sl_pkt_p(7 downto 0) <= gate(rd_resp_pkt_p(7 downto 0),             (rd_resp_ow_pop or rd_resp_pop_int) and not wr_resp_pop and not mmio_resp_pop_int) OR
                              gate(wr_resp_pkt_p(7 downto 0),         not (rd_resp_ow_pop or rd_resp_pop_int) and     wr_resp_pop and not mmio_resp_pop_int) OR
                              gate(mmio_resp_full_p(7 downto 0),      not (rd_resp_ow_pop or rd_resp_pop_int) and not wr_resp_pop and     mmio_resp_pop_int) OR
                              gate("00000000",                        not (rd_resp_ow_pop or rd_resp_pop_int) and not wr_resp_pop and not mmio_resp_pop_int);

  tl_1sl_packed_d(11 downto 0) <= gate((tl_1sl_packed_q(11) or (tl_1sl_vld_inc and pkt_vld_1sl(11))) &
                                       (tl_1sl_packed_q(10) or (tl_1sl_vld_inc and pkt_vld_1sl(10))) &
                                       (tl_1sl_packed_q(9)  or (tl_1sl_vld_inc and pkt_vld_1sl(9) )) &
                                       (tl_1sl_packed_q(8)  or (tl_1sl_vld_inc and pkt_vld_1sl(8) )) &
                                       (tl_1sl_packed_q(7)  or (tl_1sl_vld_inc and pkt_vld_1sl(7) )) &
                                       (tl_1sl_packed_q(6)  or (tl_1sl_vld_inc and pkt_vld_1sl(6) )) &
                                       (tl_1sl_packed_q(5)  or (tl_1sl_vld_inc and pkt_vld_1sl(5) )) &
                                       (tl_1sl_packed_q(4)  or (tl_1sl_vld_inc and pkt_vld_1sl(4) )) &
                                       (tl_1sl_packed_q(3)  or (tl_1sl_vld_inc and pkt_vld_1sl(3) )) &
                                       (tl_1sl_packed_q(2)  or (tl_1sl_vld_inc and pkt_vld_1sl(2) )) &
                                       (tl_1sl_packed_q(1)  or (tl_1sl_vld_inc and pkt_vld_1sl(1) )) &
                                       (tl_1sl_packed_q(0)  or (tl_1sl_vld_inc and pkt_vld_1sl(0) )),           not flit_buffer_reset);



  ----------------------------------------------------------------------------------------------------
  -- 2 slot packing
  ----------------------------------------------------------------------------------------------------


  tl_2sl_pkt(55 downto 0) <= gate(next_credit_return,                   not tl_2sl_pkt_full_q and (tlxt_tlxc_crd_ret_taken_int or not init_complete_q)) OR
                             gate(fail_resp(55 downto 0),               not tl_2sl_pkt_full_q and fail_resp_pop and not tmpl0) OR
                             gate(assign_actag,                         not tl_2sl_pkt_full_q and assign_actag_pop and not (tmpl0)) OR
                             gate(tl_2sl_pkt_q,                         tl_2sl_pkt_full_q);

  tl_2sl_pkt_p(6 downto 0)<= gate(next_credit_return_p,                 not tl_2sl_pkt_full_q and (tlxt_tlxc_crd_ret_taken_int or not init_complete_q)) OR
                             gate(fail_resp_p(6 downto 0),              not tl_2sl_pkt_full_q and fail_resp_pop and not tmpl0) OR
                             gate(assign_actag_p,                       not tl_2sl_pkt_full_q and assign_actag_pop and not (tmpl0)) OR
                             gate(tl_2sl_pkt_p_q,                       tl_2sl_pkt_full_q);

  tl_2sl_pkt_d(55 DOWNTO 0) <= gate(rsvd_2sl,                           flit_buffer_reset) OR
                               gate(tl_2sl_pkt,                         not flit_buffer_reset and not tl_2sl_pkt_full_q) OR
                               gate(tl_2sl_pkt_q(55 DOWNTO 0),          not flit_buffer_reset and     tl_2sl_pkt_full_q);

  tl_2sl_pkt_p_d(6 DOWNTO 0)<= gate(rsvd_2sl(6 downto 0),               flit_buffer_reset) OR
                               gate(tl_2sl_pkt_p,                       not flit_buffer_reset and not tl_2sl_pkt_full_q) OR
                               gate(tl_2sl_pkt_p_q(6 DOWNTO 0),         not flit_buffer_reset and     tl_2sl_pkt_full_q);

  tl_2sl_pkt_full_d <= NOT tmpl1 AND
                       (
                         (not tl_2sl_pkt_full_q and tlxt_tlxc_crd_ret_taken_int and not flit_buffer_reset) OR
                         (not tl_2sl_pkt_full_q and fail_resp_pop               and not flit_buffer_reset AND NOT tmpl0) OR
                         (not tl_2sl_pkt_full_q and assign_actag_pop            and not flit_buffer_reset AND NOT tmpl0) OR
                         (tl_2sl_pkt_full_q     and                                 not flit_buffer_reset)
                       );

  --------------------------------------------------------------------------------------------------
  -- Current 4 slot packet valid
  --------------------------------------------------------------------------------------------------

  tl_4sl_vld_reset         <= flit_buffer_reset;
  tl_4sl_vld_inc           <= tmpl1 and (wr_resp_pop or rd_resp_pop_int or mmio_resp_pop_int or fail_resp_pop or cred_ret_4sl or intrp_req_pop or assign_actag_pop);
  tl_4sl_vld_hold          <= not tl_4sl_vld_inc;
  tl_4sl_vld_d(1 downto 0) <= gate("00",                                tl_4sl_vld_reset) or
                              gate(tl_4sl_vld_q(1 downto 0) + 1,        not tl_4sl_vld_reset and tl_4sl_vld_inc) or
                              gate(tl_4sl_vld_q(1 downto 0),            not tl_4sl_vld_reset and tl_4sl_vld_hold);

  tl_4sl_vld_p_d <= ('0'                                            AND tl_4sl_vld_reset) or
               ((tl_4sl_vld_p_q xor INCP(tl_4sl_vld_q(1 downto 0))) AND not tl_4sl_vld_reset and tl_4sl_vld_inc) or
               (tl_4sl_vld_p_q                                      AND not tl_4sl_vld_reset and tl_4sl_vld_hold);

  tl_4sl_pkt(111 downto 0)      <= gate(rsvd_4sl(111 downto 28) & rd_resp_pkt,                          ((not (tl_1sl_vld_q<"1000") and tmpl5 and not tl_4sl_pkt_full_q) or tmpl1 or tmpl0) and (rd_resp_pop or rd_resp_ow_pop) and not low_lat_mode and not ((flit_pkt_cnt_q=8) and tmpl5)) OR
                                   gate(rsvd_4sl(111 downto 28) & tl_1sl_pkt,                           ((not (tl_1sl_vld_q<"1000") and tmpl5 and not tl_4sl_pkt_full_q) or tmpl1 or tmpl0) and (wr_resp_pop or mmio_resp_pop_int)) OR
                                   gate(rsvd_4sl(111 downto 56) & fail_resp,                            ((tmpl5 and not tl_4sl_pkt_full_q and tl_2sl_pkt_full_q) or tmpl1 or tmpl0) and fail_resp_pop) OR
                                   gate(rsvd_4sl(111 downto 56) & assign_actag,                         ((tmpl5 and not tl_4sl_pkt_full_q and tl_2sl_pkt_full_q) or tmpl1 or tmpl0) and assign_actag_pop) OR
                                   gate(intrp_req(111 downto 0),                                        ((tmpl5 and not tl_4sl_pkt_full_q) or tmpl1 or tmpl0) and intrp_req_pop) OR
                                   gate(rsvd_4sl(111 downto 56) & tl_2sl_pkt,                           cred_ret_4sl) OR
                                   gate(flit_buffer_2nd_half_q(191 downto 80),                          tmpl5 and tl_4sl_pkt_full_q) OR
                                   gate(flit_buffer_1st_half_q(223 downto 112),                             tmpl0 and tl_4sl_pkt_full_q) OR
                                   gate(rsvd_4sl,                                                       not (rd_resp_pop or wr_resp_pop or mmio_resp_pop_int) and tmpl1);

  tl_4sl_pkt_p(13 downto 0)     <= gate("0000000000" & rd_resp_pkt_p(3 downto 0),                       ((not (tl_1sl_vld_q<"1000") and tmpl5 and not tl_4sl_pkt_full_q) or tmpl1 or tmpl0 ) and (rd_resp_pop or rd_resp_ow_pop) and not low_lat_mode and not ((flit_pkt_cnt_q=8) and tmpl5) ) OR
                                   gate("0000000000" & tl_1sl_pkt_p(3 downto 0),                        ((not (tl_1sl_vld_q<"1000") and tmpl5 and not tl_4sl_pkt_full_q) or tmpl1 or tmpl0 ) and (wr_resp_pop or mmio_resp_pop_int)) OR
                                   gate("0000000"    & fail_resp_p,                                     ((tmpl5 and not tl_4sl_pkt_full_q and tl_2sl_pkt_full_q) or tmpl1 or tmpl0) and fail_resp_pop) OR
                                   gate("0000000"    & assign_actag_p,                                  ((tmpl5 and not tl_4sl_pkt_full_q and tl_2sl_pkt_full_q) or tmpl1 or tmpl0) and assign_actag_pop) OR
                                   gate(intrp_req_p,                                                    ((tmpl5 and not tl_4sl_pkt_full_q) or tmpl1 or tmpl0) and intrp_req_pop) OR
                                   gate("0000000"    & tl_2sl_pkt_p,                                    cred_ret_4sl) OR
                                   gate(flit_buffer_2nd_half_p_q(23 downto 10),                         tmpl5 and tl_4sl_pkt_full_q) OR
                                   gate(flit_buffer_1st_half_p_q(27 downto 14),                         tmpl0 and tl_4sl_pkt_full_q) OR
                                   gate("00000000000000",                                               not (rd_resp_pop or wr_resp_pop or mmio_resp_pop_int) and tmpl1);

  tl_4sl_pkt_full_d <= --not flit_buffer_reset and
                       (
                         (not flit_buffer_reset and tmpl5 and not tl_4sl_pkt_full_q and (fail_resp_pop or intrp_req_pop or assign_actag_pop or ((wr_resp_pop or mmio_resp_pop_int or rd_resp_pop) and not (tl_1sl_vld_q<"1000")))) OR
                         (not flit_buffer_reset and tmpl0 and not tl_4sl_pkt_full_q and (fail_resp_pop or intrp_req_pop or assign_actag_pop or wr_resp_pop or mmio_resp_pop_int or (rd_resp_pop and not low_lat_mode))) OR
                         (not flit_buffer_reset and tl_4sl_pkt_full_q) or
                         (flit_buffer_reset and null_flit_next_q)
                       );

  tl_2sl_4sl_pkt_full_p_d <= ('1' and     tl_2sl_pkt_full_d and not tl_4sl_pkt_full_d) or
                             ('1' and not tl_2sl_pkt_full_d and     tl_4sl_pkt_full_d) or
                             ('0' and not tl_2sl_pkt_full_d and not tl_4sl_pkt_full_d) or
                             ('0' and     tl_2sl_pkt_full_d and     tl_4sl_pkt_full_d);

  tl_2sl_4sl_pkt_full_perr <= xor_reduce(tl_4sl_pkt_full_q & tl_2sl_pkt_full_q & tl_2sl_4sl_pkt_full_p_q);

  flit_arb_perrors(8) <= tl_2sl_4sl_pkt_full_perr;

  --------------------------------------------------------------------------------------------------
  --Read Response Splitting
  --------------------------------------------------------------------------------------------------
  --Statemachine to determine which step in the triplet cycle we are in
  --kicks off after first .0w response is sent to the host. (mmio reads included as long as DRAM
  --reads are also in flight. advances on data flits from template 9 and template 9 control flits.
  --one hot.
  --State 3: IDLE
  --State 2: First Flit in triplet Cycle. advance drl sub3
  --State 1: Second Flit in Triplet Cycle, advance drl sub2
  --State 0: Third FLit in Triplet cycle. Advance drl sub1

  triplet_state_change_valid <= (rdf_data_pending or mmio_data_pending or not rd_resp_empty_q or rd_resp_ow_pend_q or mmio_resp_pend_q or data_pending_int or tmpl5_flit_pend or tmpl5_flit_sub2_q) and low_lat_mode;
  triplet_state_advance <= low_lat_mode and (tmpl5 or tmpl9) and ((flit_buffer_reset) or (flit_xmit_done and data_flit_xmit_int and not flit_xmit_start_t3_q));

  triplet_state_3_2 <= (rd_resp_pop_int or rd_resp_ow_pop or (mmio_resp_pop_load and tmpl9)) and not ow_in_flit and (triplet_state_q="000") and low_lat_mode;
  triplet_state_3_3 <= not triplet_state_change_valid;
  triplet_state_2_2 <= (triplet_state_q(2 downto 0)="100") and not triplet_state_advance;
  triplet_state_2_1 <= (triplet_state_q(2 downto 0)="100") and     triplet_state_advance;
  triplet_state_1_1 <= (triplet_state_q(2 downto 0)="010") and not triplet_state_advance;
  triplet_state_1_0 <= (triplet_state_q(2 downto 0)="010") and     triplet_state_advance;
  triplet_state_0_0 <= (triplet_state_q(2 downto 0)="001") and not triplet_state_advance;
  triplet_state_0_2 <= triplet_state_change_valid and (triplet_state_q(2 downto 0)="001") and     triplet_state_advance;
  triplet_state_0_3 <= not triplet_state_change_valid and (triplet_state_q(2 downto 0)="001") and triplet_state_advance;

  triplet_state_d(2 downto 0) <= gate("000",                    triplet_state_3_3 or triplet_state_0_3) OR
                                 gate("100",                    triplet_state_3_2 or triplet_state_2_2 or triplet_state_0_2) OR
                                 gate("010",                    triplet_state_2_1 or triplet_state_1_1) OR
                                 gate("001",                    triplet_state_1_0 or triplet_state_0_0);

  triplet_state_val_d <= or_reduce(triplet_state_d);

  --data run length look ahead
  drl_current(3 downto 0) <=    gate(drl_sub0_q(3 downto 0),            low_lat_mode) OR
                                gate(drl_sub1_q(3 downto 0),            (flit_xmit_start_t3_q or data_flit_xmit_int) and (drl_prev_val_q and not mmio_data_flit_del_q) and low_lat_mode) or
                                gate(drl_sub2_q(3 downto 0),            (flit_xmit_start_t3_q or data_flit_xmit_int) and (data_run_length_q=2) and low_lat_mode) or
                                gate(mmio_drl_q(3 downto 0),            not tmpl9 and low_lat_mode and not triplet_state_val_q) or
                                gate(mmio_drl_q(3 downto 0),            not tmplB and half_dimm_mode) or
                                gate(drl_high_lat_q(3 downto 0),        hi_lat_mode);

  drl_current_p           <=    (drl_sub0_p_q                       and low_lat_mode) OR
                                (drl_sub1_p_q                       and (flit_xmit_start_t3_q or data_flit_xmit_int) and (drl_prev_val_q and not mmio_data_flit_del_q) and low_lat_mode) or
                                (drl_sub2_p_q                       and (flit_xmit_start_t3_q or data_flit_xmit_int) and (data_run_length_q=2) and low_lat_mode) or
                                (mmio_drl_p_q                       AND not tmpl9 and low_lat_mode and not triplet_state_val_q) or
                                (mmio_drl_p_q                       and not tmplB and half_dimm_mode) or
                                (drl_high_lat_p_q                   AND hi_lat_mode);

  drl_sub0_d(3 downto 0) <=     gate(drl_sub1_q(3 downto 0),                    triplet_state_advance) OR
                                gate(drl_sub0_q(3 downto 0),                    not  triplet_state_advance );

  drl_sub0_p_d           <=     (drl_sub1_p_q                               AND triplet_state_advance) OR
                                (drl_sub0_p_q                               AND not  triplet_state_advance );

  drl_sub1_d(3 downto 0) <=     gate(drl_sub2_q(3 downto 0),                    triplet_state_advance) OR
                                gate(drl_sub1_q(3 downto 0),                    not triplet_state_advance);

  drl_sub1_val_d <= or_reduce(drl_sub1_d);

  drl_sub1_p_d           <=     (drl_sub2_p_q                               AND triplet_state_advance) OR
                                (drl_sub1_p_q                               AND not triplet_state_advance);

  drl_sub2_d(3 downto 0) <=     gate(drl_sub3_q(3 downto 0),                    triplet_state_advance and not data_flit_xmit_int) OR
                                gate(drl_sub2_q(3 downto 0),                    not triplet_state_advance);

  drl_sub2_val_d <= or_reduce(drl_sub2_d);

  drl_sub2_p_d           <=     (drl_sub3_p_q                               AND triplet_state_advance and not data_flit_xmit_int) OR
                                (drl_sub2_p_q                               AND not triplet_state_advance);

  drl_sub3_d(3 downto 0) <=     gate("0000",                                    triplet_state_advance) OR
                                gate(drl_sub3_q(3 downto 0) + 1,                tmpl9_drl_inc) OR
                                gate(drl_sub3_q(3 downto 0),                    not tmpl9_drl_inc and ((not (triplet_state_advance and not data_flit_xmit_int))));

  drl_sub3_p_d           <=     ('0'                                        AND triplet_state_advance) OR
                           ((drl_sub3_p_q xor INCP(drl_sub3_q(3 downto 0))) AND tmpl9_drl_inc) OR
                                (drl_sub3_p_q                               AND not tmpl9_drl_inc and ((not (triplet_state_advance and not data_flit_xmit_int))));

  drl_1_in_pipe_d <= (drl_sub2_d="0001") or (drl_sub1_d="0001");
  drl_2_in_pipe_d <= (drl_sub2_d="0010") or (drl_sub1_d="0010");
  drl_in_pipe <= drl_1_in_pipe_q or drl_2_in_pipe_q;


  mmio_drl_d(3 downto 0) <=     gate("0000",                            flit_buffer_reset) OR
                                gate(mmio_drl_q(3 downto 0) + 1,        mmio_resp_pop) OR
                                gate(mmio_drl_q(3 downto 0),            not (flit_buffer_reset or (mmio_resp_pop)));

  mmio_drl_p_d           <=     ('0'                                AND flit_buffer_reset) OR
                                ((mmio_drl_p_q xor INCP(mmio_drl_q(3 downto 0))) AND mmio_resp_pop) OR
                                (mmio_drl_p_q                       AND not (flit_buffer_reset or (mmio_resp_pop)));

  mmio_data_current <=        mmio_data_sub0_q OR
                              mmio_40B_sub0_q OR
                              (low_lat_mode and not low_lat_degrade_q and drl_prev_val_q and (flit_xmit_start_t3_q OR data_flit_xmit_int) and mmio_data_sub1_q) OR
                              (low_lat_mode and not low_lat_degrade_q and (data_run_length_q=2) and (flit_xmit_start_t3_q OR data_flit_xmit_int) and mmio_data_sub2_q);

  mmio_data_sub0_d <=           (mmio_data_sub1_q and low_lat_mode and (triplet_state_advance and not (data_flit_xmit_int and low_lat_degrade_q))) or
                                (mmio_data_sub0_q and low_lat_mode and not triplet_state_advance) or
                                (mmio_data_sub1_q and hi_lat_mode and flit_buffer_reset) or
                                (mmio_data_sub0_q and hi_lat_mode and not flit_buffer_reset);


  mmio_data_sub1_d <=           (mmio_data_sub2_q and low_lat_mode and triplet_state_advance) or
                                (mmio_data_sub1_q and low_lat_mode and not (triplet_state_advance and not (data_flit_xmit_int and low_lat_degrade_q))) or
                                (mmio_resp_pop_load and low_lat_degrade_q and tmpl9) or
                                (mmio_resp_pop_load and hi_lat_mode and tmpl9) or
                                (mmio_data_sub1_q and hi_lat_mode and not flit_buffer_reset);

  mmio_data_sub2_d <=           (mmio_data_sub3_q and triplet_state_advance and not data_flit_xmit_int) or
                                (mmio_data_sub2_q and (not triplet_state_advance));

  mmio_data_sub3_d <=           (mmio_resp_pop_load and tmpl9 and low_lat_mode and not low_lat_degrade_q) or
                                (mmio_data_sub3_q and (not (triplet_state_advance and not data_flit_xmit_int)));

  mmio_data_pending <=  mmio_data_sub3_q or mmio_data_sub2_q or mmio_data_sub1_q or mmio_40B_sub1_q or mmio_40B_sub2_q;

  rdf_data_current <= rdf_1st_32B_current or rdf_2nd_32B_current or rdf_40B_current;


  rdf_1st_32B_current <= (rdf_1st_32B_sub0_q) OR
                         (low_lat_mode and not low_lat_degrade_q and drl_prev_val_q and (flit_xmit_start_t3_q OR data_flit_xmit_int) and (rdf_1st_32B_sub1_q)) OR
                         (low_lat_mode and not low_lat_degrade_q and (data_run_length_q=2) and (flit_xmit_start_t3_q OR data_flit_xmit_int) and (rdf_1st_32B_sub2_q));

  rdf_2nd_32B_current<= (rdf_2nd_32B_sub0_q) OR
                        (low_lat_mode and not low_lat_degrade_q and drl_prev_val_q and (flit_xmit_start_t3_q OR data_flit_xmit_int) and ( rdf_2nd_32B_sub1_q)) OR
                        (low_lat_mode and not low_lat_degrade_q and (data_run_length_q=2) and (flit_xmit_start_t3_q OR data_flit_xmit_int) and (rdf_2nd_32B_sub2_q));

  rdf_data_pending <= rdf_1st_32B_sub0_q or rdf_1st_32B_sub1_q or rdf_1st_32B_sub2_q or rdf_1st_32B_sub3_q or
                      rdf_2nd_32B_sub0_q or rdf_2nd_32B_sub1_q or rdf_2nd_32B_sub2_q or rdf_2nd_32B_sub3_q or
                      rdf_40B_sub0_q     or rdf_40B_sub1_q     or rdf_40B_sub2_q;
  rdf_data_pending_max_bw <= rdf_1st_32B_sub0_q or rdf_1st_32B_sub1_q or rdf_1st_32B_sub2_q or rdf_2nd_32B_sub0_q or rdf_2nd_32B_sub1_q or rdf_2nd_32B_sub2_q;

  rdf_1st_32B_sub0_d <=           (rdf_1st_32B_sub1_q and low_lat_mode and (triplet_state_advance and not (data_flit_xmit_int and low_lat_degrade_q))) or
                                  (rdf_1st_32B_sub0_q and low_lat_mode and (not triplet_state_advance)) OR
                                  (rdf_1st_32B_sub1_q AND hi_lat_mode AND (flit_buffer_reset and not null_flit_next_q)) or
                                  (rdf_1st_32B_sub0_q and hi_lat_mode and not flit_buffer_reset);

  rdf_1st_32B_sub1_d <=           (rdf_1st_32B_sub2_q and low_lat_mode and triplet_state_advance) or
                                  (rdf_1st_32B_sub1_q and low_lat_mode and not (triplet_state_advance and not (data_flit_xmit_int and low_lat_degrade_q))) OR
                                  (rd_resp_pop_int and low_lat_degrade_q and not ow_in_flit) or
                                  (rd_resp_pop_int and rd_resp_len32 AND hi_lat_mode AND tmpl_config(9)) OR
                                  (rdf_1st_32B_sub1_q AND hi_lat_mode AND NOT (flit_buffer_reset and not null_flit_next_q));

  rdf_1st_32B_sub2_d <=           (rdf_1st_32B_sub3_q and triplet_state_advance and not data_flit_xmit_int) or
                                  (rdf_1st_32B_sub2_q and (not triplet_state_advance));

  rdf_1st_32B_sub3_d <=           (rd_resp_pop_int and not ow_in_flit and not (half_dimm_mode or low_lat_degrade_q))  or
                                  (rdf_1st_32B_sub3_q and (not (triplet_state_advance and not data_flit_xmit_int)));

----------------------------------------------------------------------------------------------------

  rdf_2nd_32B_sub0_d <=           (rdf_2nd_32B_sub1_q and (triplet_state_advance and not (data_flit_xmit_int and low_lat_degrade_q))) or
                                  (rdf_2nd_32B_sub0_q and (not triplet_state_advance));

  rdf_2nd_32B_sub1_d <=           (rdf_2nd_32B_sub2_q and not low_lat_degrade_q and triplet_state_advance) or
                                  (rd_resp_ow_pop     and     low_lat_degrade_q) or
                                  (rdf_2nd_32B_sub1_q and not (triplet_state_advance and not (data_flit_xmit_int and low_lat_degrade_q)));

  rdf_2nd_32B_sub2_d <=           (rdf_2nd_32B_sub3_q and triplet_state_advance and not data_flit_xmit_int) or
                                  (rdf_2nd_32B_sub2_q and (not triplet_state_advance));

  rdf_2nd_32B_sub3_d <=           (rd_resp_ow_pop and not (half_dimm_mode or low_lat_degrade_q)) or
                                  (rdf_2nd_32B_sub3_q and (not (triplet_state_advance and not data_flit_xmit_int)));



  -- indicators (may need to latch this for each flit current/next) need to come up with the
  --rest of this stuff
 
  triplet_999_d <= (triplet_999 or triplet_999_q) and not (triplet_9d9_d or triplet_9dd_d);

  triplet_9d9_d <= (triplet_9d9 and triplet_state_advance and triplet_state_q(0) and not max_bw_ip and not tlxt_err_invalid_cfg_q) or
                   (triplet_9d9_q and (triplet_9d9  or not  (triplet_state_advance and triplet_state_q(0))));

  triplet_9dd_d <= (triplet_9dd and (triplet_state_advance and not data_flit_xmit_int) and not triplet_9dd_drop_q AND ((triplet_9d9_q and mid_bw_enab) or not mid_bw_enab) and not tlxt_err_invalid_cfg_q) or
                   (triplet_9dd_q AND NOT (triplet_9dd_drop_q or (rd_resp_empty_q and (triplet_state_advance and not data_flit_xmit_int))));

  triplet_999 <= low_lat_mode and not triplet_9d9_d and init_complete_q; 
  triplet_9d9 <= (meta_fifo_count>=mid_bw_threshold_int) and (rdf_data_pending or mmio_data_pending)  and not drl_2_in_pipe_q and not triplet_9dd_d and mid_bw_enab and not (triplet_999_q and drl_prev_val_q) and not low_lat_degrade_q;
  triplet_9dd <= (data_pending_int or mmio_data_pending) and not hi_bw_dis and not half_dimm_mode and not (triplet_999_q and (drl_1_in_pipe_q or drl_current_1)) and not low_lat_degrade_q and 
                 (
                   (meta_fifo_count>=hi_bw_threshold_int) OR
                   ((rd_resp_count>=hi_bw_rd_threshold) and hi_bw_enab_rd_thresh_int)
                 );

  max_bw_ip <= (data_run_length_q=2) and drl_current_2;

  triplet_9dd_drop_d <= (((drl_current=1) or drl_1_in_pipe_q) and triplet_9dd_q) or
                        lane_width_transition or
                        rd_resp_unrec_stall_q or
                        (data_flit_xmit_int and not (mmio_data_pending or rdf_data_pending or data_pending_int)) or
                        ((data_run_length_q=2) and not or_reduce(drl_current)) or
                        (intrp_req_pend and not tmpl5_intrp_opt_val_q) or
                        (triplet_9dd_q and flit_buffer_reset and (drl_sub3_q/=2) and max_bw_ip);

  --default value is 2 meta fifo entries. Add additional based on
  hi_bw_threshold_int(5 downto 0) <= "000100" + ("000"&hi_bw_threshold(2 downto 0));
  mid_bw_threshold_int(5 downto 0) <= "000001" + ("000"&mid_bw_threshold(2 downto 0));
  hi_bw_enab_rd_thresh_int <= (or_reduce(mid_bw_threshold) and hi_bw_enab_rd_thresh) or
                              (metadata_disabled);
  hi_bw_rd_threshold(5 downto 0) <= gate("000"&mid_bw_threshold,        metadata_enabled) or
                                    gate(hi_bw_threshold_int,           metadata_disabled);



  --delay the start of a flit by one or 2 cycles to inert a data run length into the pipeline
  del_for_drl <= (('0' & mf_vld_q)<drl_current) and hi_lat_mode;
  tmpl9_drl_inc <= rd_resp_pop_int and ow_in_flit and low_lat_mode;

  drl_high_lat_inc <= (rd_resp_pop_int and not (rd_resp_len32 and tmpl_config(9)) and not half_dimm_mode) OR
                      (mmio_resp_pop and hi_lat_mode);

  --Octword split for responses recieved in order.
  --First Octword Response
  rd_resp_fst_ow(27 downto 0) <= gate('0' &  -- reserved bit
                                      rd_resp_corrected(17 downto 16) & '0' &  --Regular response
                                      rd_resp_corrected(15 downto 0) &  --capptag
                                      rd_resp_ow_opcode(7 downto 0),    NOT rd_resp_UE);

  rd_resp_fst_ow_p(7 downto 0)<= rd_resp_corrected_17_12_p               -- Parity over 27:20
                               & rd_resp_corrected_11_4_p                -- Parity over 19:12
                               & (rd_resp_corrected_3_0_p xor '0')       -- Parity over 11:4
                               & rd_resp_ow_opcode(8)                    -- Parity over 3:0
                              &  rd_resp_corrected_17_16_p               -- Parity over 27:24
                               & rd_resp_corrected_15_8_p                -- Parity over 23:16
                               & rd_resp_corrected_7_0_p                 -- Parity over 15:8
                               & rd_resp_ow_opcode(8);                   -- Parity over 7:0

  --Second Octword Response
  rd_resp_sec_ow(27 downto 0) <= '0' &
                                 rd_resp_corrected(17 downto 16) & '1' &  --32B offset response
                                 rd_resp_corrected(15 downto 0) &
                                 rd_resp_ow_opcode(7 downto 0);

  rd_resp_sec_ow_p(7 downto 0)<= (rd_resp_corrected_17_12_p xor '1')     -- Parity over 27:20
                               & rd_resp_corrected_11_4_p                -- Parity over 19:12
                               & (rd_resp_corrected_3_0_p xor '0')       -- Parity over 11:4
                               & rd_resp_ow_opcode(8)                    -- Parity over 3:0
                              &  (rd_resp_corrected_17_16_p xor '1')     -- Parity over 27:24
                               & rd_resp_corrected_15_8_p                -- Parity over 23:16
                               & rd_resp_corrected_7_0_p                 -- Parity over 15:8
                               & rd_resp_ow_opcode(8);                   -- Parity over 7:0

  rd_resp_full(27 downto 0) <= gate("01" &
                                    rd_resp_corrected(17 downto 16) &
                                    rd_resp_corrected(15 downto 0) &
                                    rd_resp_opcode(7 downto 0),                 NOT rd_resp_UE);

  rd_resp_full_p(7 downto 0)<= ('1' xor rd_resp_corrected_17_12_p)     -- Parity over 27:20
                             & rd_resp_corrected_11_4_p                -- Parity over 19:12
                             & (rd_resp_corrected_3_0_p xor '0')       -- Parity over 11:4
                             & rd_resp_opcode(8)                       -- Parity over 3:0
                            &  (rd_resp_corrected_17_16_p xor '1')     -- Parity over 27:24
                             & rd_resp_corrected_15_8_p                -- Parity over 23:16
                             & rd_resp_corrected_7_0_p                 -- Parity over 15:8
                             & rd_resp_opcode(8);                      -- Parity over 7:0


  --special opcode. Check opcode then immediately pack another response.
  rd_resp_opcode    <= '1' & "00000001";
  rd_resp_ow_opcode <= '0' & "00000011";

  rd_resp_pkt(27 downto 0) <= gate(rd_resp_full(27 downto 0),                   (hi_lat_mode                     and not (rd_resp_len32 and tmpl_config(9)))
                                                                             or (low_lat_mode and     ow_in_flit                          )) OR
                              gate(rd_resp_fst_ow(27 downto 0),                 (low_lat_mode and not ow_in_flit and not rd_resp_ow_pend_q)
                                                                             or (hi_lat_mode  and                        (rd_resp_len32 and tmpl_config(9)))
                                                                             or (                                           half_dimm_mode)) OR
                              gate(rd_resp_ow_buf_q(27 downto 0),               (low_lat_mode and not ow_in_flit and     rd_resp_ow_pend_q));

  rd_resp_pkt_p(7 downto 0)<= gate(rd_resp_full_p(7 downto 0),                  (hi_lat_mode                     and not (rd_resp_len32 and tmpl_config(9)))
                                                                             or (low_lat_mode and  ow_in_flit                             )) OR
                              gate(rd_resp_fst_ow_p(7 downto 0),                (low_lat_mode and not ow_in_flit and not rd_resp_ow_pend_q)
                                                                             or (hi_lat_mode  and                        (rd_resp_len32 and tmpl_config(9)))
                                                                             or (                                           half_dimm_mode)) OR
                              gate(rd_resp_ow_buf_p_q(7 downto 0),              (low_lat_mode and not ow_in_flit and     rd_resp_ow_pend_q));

  rd_resp_ow_pend_d <= (not ow_in_flit and rd_resp_pop_int and not rd_resp_ow_pend_q and low_lat_mode) OR
                       (rd_resp_ow_pend_q and not rd_resp_ow_pop);


  --Store Second Octword Response
  rd_resp_ow_buf_d(27 downto 0) <= gate(rd_resp_sec_ow(27 downto 0),         low_lat_mode and not rd_resp_ow_pend_q and rd_resp_pop_int) OR
                                   gate(rd_resp_ow_buf_q(27 downto 0),       rd_resp_ow_pend_q);
  rd_resp_ow_buf_p_d(7 downto 0)<= gate(rd_resp_sec_ow_p(7 downto 0),        low_lat_mode and not rd_resp_ow_pend_q and rd_resp_pop_int) OR
                                   gate(rd_resp_ow_buf_p_q(7 downto 0),      rd_resp_ow_pend_q);

  --slot has ow
  sl_15_ow <= (flit_buffer_2nd_half_q(171 downto 164)="00000011");
  sl_14_ow <= (flit_buffer_2nd_half_q(143 downto 136)="00000011");
  sl_13_ow <= (flit_buffer_2nd_half_q(115 downto 108)="00000011");
  sl_12_ow <= (flit_buffer_2nd_half_q(87 downto 80)="00000011");


   --ow response already in flit. Will never have 2
  ow_in_flit <= (not low_lat_degrade_q and (rdf_1st_32B_sub3_q or rdf_2nd_32B_sub3_q or mmio_data_sub3_q or tmpl5_flit_rd_gate)) OR
                (    low_lat_degrade_q and (rdf_1st_32B_sub1_q or rdf_2nd_32B_sub1_q or mmio_data_sub1_q or tmpl5_flit_sub0_q)) or
                hi_lat_mode;

  ow_in_flit_hi_lat <= (mmio_data_sub1_q or rdf_1st_32B_sub1_q) and hi_lat_mode;

  --------------------------------------------------------------------------------------------------
  -- Half-Dimm Mode read scheduling logic
  --------------------------------------------------------------------------------------------------
  --half-dimm state advance
  half_dimm_state_advance <= flit_buffer_reset;
  --never a need for data flits in half-dimm mode (after template B is enabled) so reset transitions
  --valids on flit buffer reset.

  rdf_40B_sub0_d <= (rdf_40B_sub1_q and half_dimm_state_advance) Or
                    (rdf_40B_sub0_q and not half_dimm_state_advance);

  rdf_40B_sub1_d <= (rdf_40B_sub2_q and half_dimm_state_advance) or
                    (rdf_40B_sub1_q and not half_dimm_state_advance);

  rdf_40B_sub2_d <= (half_dimm_mode and rd_resp_pop_half_dimm) or
                    (rdf_40B_sub2_q and not half_dimm_state_advance);

  rdf_40B_current <= rdf_40B_sub0_q; 

  rdf_40B_start   <= (rdf_data_current or rdf_40B_sub1_q or rdf_40B_sub2_q) and half_dimm_mode; 

  --mmio
  mmio_40B_sub0_d <= (mmio_40B_sub1_q and half_dimm_state_advance) Or
                     (mmio_40B_sub0_q and not half_dimm_state_advance);

  mmio_40B_sub1_d <= (mmio_40B_sub2_q and half_dimm_state_advance) or
                     (mmio_40B_sub1_q and not half_dimm_state_advance);

  mmio_40B_sub2_d <= (half_dimm_mode and mmio_resp_pop_half_dimm) or
                     (mmio_40B_sub2_q and not half_dimm_state_advance);

  mmio_40B_start   <= (mmio_40B_sub0_q or mmio_40B_sub1_q or mmio_40B_sub2_q or mmio_resp_pend_q) and half_dimm_mode and not (intrp_req_pend and tmpl0);


  ow_in_flit_half_dimm <= mmio_data_sub2_q or rdf_40B_sub2_q;

  rd_resp_pop_half_dimm <= tlx_vc0_avail and
                           tlx_dcp0_avail and
                           resp_pop_vld and 
                           tmplB and
                           half_dimm_mode and
                           not rd_resp_unrec_stall_q and 
                           not intrp_req_pend and
                           not (mmio_resp_pend_q or mmio_40B_sub2_q or rdf_40B_sub2_q) and
                           not rd_resp_empty_q and
                           not ow_in_flit_half_dimm and
                           not rd_stall_ll_or_hd and
                           not rd_resp_half_dimm_stall_dec and
                           not rd_resp_half_dimm_stall_one_q;

  mmio_resp_pop_half_dimm <= tlx_vc0_avail and
                             tlx_dcp0_avail and
                              resp_pop_vld and 
                             tmplB and
                             half_dimm_mode and
                             mmio_resp_pend_q and
                             not (mmio_40B_sub2_q or rdf_40B_sub2_q) and
                             not intrp_req_pend and
                             not (mmio_data_pending or mmio_data_current) and 
                             not ow_in_flit_half_dimm and
                             not rd_resp_half_dimm_stall_dec;

  --Read stall for optimal timing upstream.
  rd_resp_half_dimm_stall_dec <= or_reduce(rd_resp_half_dimm_stall_q);
  rd_resp_half_dimm_stall_d (3 downto 0) <= gate("0100",                        rd_resp_push and not rd_resp_half_dimm_stall_dec and (rd_resp_count<=1)) OR
                                            gate(rd_resp_half_dimm_stall_q-1,   rd_resp_half_dimm_stall_dec) OR
                                            gate(rd_resp_half_dimm_stall_q,     not (rd_resp_push or rd_resp_half_dimm_stall_dec));


  rd_resp_half_dimm_stall_one_d <= (rd_resp_half_dimm_stall_dec and (half_dimm_start or ((flit_xmit_start_q or flit_xmit_start_t1_q or (flit_xmit_start_t2_q and not flit_credit_avail)) and tmplB))) or
                                   (rd_resp_half_dimm_stall_one_q and not flit_buffer_reset);



  -----------------------------------------------------------------------------
  -- generate 1&4 slot packet valid signals
  -----------------------------------------------------------------------------

  pkt_vld_1sl(11)    <= (tl_1sl_vld_q = "1011");  -- tmpl9/tmplB
  pkt_vld_1sl(10)    <= (tl_1sl_vld_q = "1010");  -- tmpl9/tmplB
  pkt_vld_1sl(9)     <= (tl_1sl_vld_q = "1001");  -- tmpl9
  pkt_vld_1sl(8)     <= (tl_1sl_vld_q = "1000");  -- tmpl9
  pkt_vld_1sl(7)     <= (tl_1sl_vld_q = "0111");  -- tmpl5
  pkt_vld_1sl(6)     <= (tl_1sl_vld_q = "0110");  -- tmpl5
  pkt_vld_1sl(5)     <= (tl_1sl_vld_q = "0101");  -- tmpl5
  pkt_vld_1sl(4)     <= (tl_1sl_vld_q = "0100");  -- tmpl5
  pkt_vld_1sl(3)     <= (tl_1sl_vld_q = "0011");  -- tmpl5
  pkt_vld_1sl(2)     <= (tl_1sl_vld_q = "0010");  -- tmpl5
  pkt_vld_1sl(1)     <= (tl_1sl_vld_q = "0001");  -- tmpl5
  pkt_vld_1sl(0)     <= (tl_1sl_vld_q = "0000");  -- tmpl5

  pkt_vld_4sl(3)     <= (tl_4sl_vld_q = "11") and not flit_full_q;  -- tmpl1 and tmpl5
  pkt_vld_4sl(2)     <= (tl_4sl_vld_q = "10") and not flit_full_q;  -- tmpl1
  pkt_vld_4sl(1)     <= (tl_4sl_vld_q = "01") and not flit_full_q;  -- tmpl1
  pkt_vld_4sl(0)     <= (tl_4sl_vld_q = "00") and not flit_full_q;  -- tmpl1

  -----------------------------------------------------------------------------
  -- template 9/B data valid signal
  -----------------------------------------------------------------------------
  tmpl9_data_valid <= (data_valid_int) and tmpl9;
  data_valid_int <= (rdf_data_current);

  tmplB_data_valid <= (data_valid_int) and tmplB;
  tmplB_data_val <= tmplB_data_valid;

  -----------------------------------------------------------------------------
  -- Outstanding 16B data remaining
  -----------------------------------------------------------------------------
  dat_bts_pend_dec <= data_xmit and flit_credit_avail and data_pending_int and not mmio_data_flit_q;

  --May not need anymore
  dat_bts_pend_d(6 downto 0) <= gate(dat_bts_pend_q + 3,     half_dimm_mode and rd_resp_pop_int                                               and not dat_bts_pend_dec) OR
                                gate(dat_bts_pend_q + 2, not half_dimm_mode and rd_resp_pop_int and (not ow_in_flit or      rd_resp_len32)    and not dat_bts_pend_dec) OR
                                gate(dat_bts_pend_q + 4,                        rd_resp_pop_int and (    ow_in_flit and not rd_resp_len32)    and not dat_bts_pend_dec) OR
                                gate(dat_bts_pend_q + 2,                        rd_resp_ow_pop                                                and not dat_bts_pend_dec) OR
                                gate(dat_bts_pend_q + 3,                        rd_resp_pop_int and (    ow_in_flit and not rd_resp_len32)    and     dat_bts_pend_dec) OR
                                gate(dat_bts_pend_q + 2,     half_dimm_mode and rd_resp_pop_int                                               and     dat_bts_pend_dec) OR
                                gate(dat_bts_pend_q + 1, not half_dimm_mode and rd_resp_pop_int and (not ow_in_flit or      rd_resp_len32)    and     dat_bts_pend_dec) OR
                                gate(dat_bts_pend_q + 1,                        rd_resp_ow_pop                                                and     dat_bts_pend_dec) OR
                                gate(dat_bts_pend_q - 1,                    not rd_resp_pop_int and not rd_resp_ow_pop and     dat_bts_pend_dec) OR
                                gate(dat_bts_pend_q,                        not rd_resp_pop_int and not rd_resp_ow_pop and not dat_bts_pend_dec);

  data_pending_int <= or_reduce(dat_bts_pend_q);
  data_pending <= data_pending_int;
  resp_pend(4 downto 0) <= dat_bts_pend_q(6 downto 2);
  ow_data_pend <= (dat_bts_pend_q(1 downto 0)="10");


  --debug signals
  rd_idle <= rd_resp_empty_q and not data_valid and not data_pending_int;


  -----------------------------------------------------------------------------
  -- FLit Transmit Start. Controls flit transmission from flit arb and kicks
  -- off master counter in transmit arbiter.
  -----------------------------------------------------------------------------
  flit_xmit_start_pulse <= (flit_xmit_start_q AND flit_credit_avail);
  flit_xmit_start_d     <= (flit_xmit_start_int OR data_flit_crc_start) OR (flit_xmit_start_q AND NOT flit_credit_avail);
  flit_xmit_start_int   <= flit_credit_avail and NOT flit_ip and not (data_flit_xmit_int or data_flit_xmit) and NOT flit_xmit_start_q AND NOT (flit_xmit_done AND drl_prev_val_q) and not opencapi_link_shutdown_q and 
                           (not xmit_rate_stall_dec and
                            (           --flit full conditions
                              flit_full_start OR
                              triplet_flow_start OR
                              triplet_wait_for_data_start OR
                              triplet_data_valid_start OR
                              triplet_bypass_start or
                              triplet_mmio_start OR
                              rdf_40B_start OR 
                              mmio_40B_start OR 
                              triplet_advance_start OR
                              triplet_rd_resp_stall_start OR
                              (hi_lat_read_start ) or
                              half_dimm_start OR
                              non_crit_start_q
                            )
                           );

  non_crit_start_d <= idle_start_gated or
                      intrp_req_start or
                      write_flush_start or
                      force_tmpl_switch_start or
                      fail_resp_flush_start or
                      drl_max_start or
                      actag_start or
                      init_flit_start or
                      all_fifo_empty_start;

  all_fifo_empty_start <= (not triplet_state_val_q and (or_reduce(flit_pkt_cnt_q) or tl_2sl_pkt_full_q or tl_4sl_pkt_full_q) and  all_1sl_fifo_empty and (tl_2sl_pkt_full_q or tlxc_tlxt_crd_ret_val)) or
                          (not triplet_state_val_q and (or_reduce(flit_pkt_cnt_q) or tl_2sl_pkt_full_q or tl_4sl_pkt_full_q) and all_fifo_empty);

  actag_start <=  (assign_actag_pend and not assign_actag_packed) and
                  (
                    (tmpl0 and tl_4sl_pkt_full_q) or
                    (tmpl1 and flit_full_q) or
                    (tmpl5 and (tl_2sl_pkt_full_q or tl_4sl_pkt_full_q)) or
                    ((tmpl9 or tmplB) and tl_2sl_pkt_full_q)
                  );

  flit_full_start <= (flit_full_q and (tmpl9 or tmplB) and (rdf_data_current and metadata_avail)) OR
                     (flit_full_q and (tmpl9 or tmplB) and not (rdf_data_pending or mmio_data_pending)) OR
                     (flit_full_q and (tmpl0 or tmpl1 or tmpl5));

  idle_start_gated <= idle_start and not idle_start_block;
  idle_start <= (or_reduce(flit_mmio_resp_q) and not data_pending_int) OR
                ((or_reduce(flit_pkt_cnt_q) or tl_2sl_pkt_full_q or tl_4sl_pkt_full_q) and (not tlx_vc0_avail or (non_main_gate_q and tmpl9) or not data_pending_int)) OR
                (or_reduce(flit_wr_resp_q) and not wr_resp_empty_q and not tlx_vc0_avail and not (data_pending_int and not wr_resp_flush_q)) OR
                (wr_resp_empty_q and rd_resp_empty_q and mmio_resp_empty and (or_reduce(flit_pkt_cnt_q) or tl_2sl_pkt_full_q) and not data_pending_int) OR
                (idle_crd_ret and (tmpl9 or tmplB) and not (rdf_data_current and not metadata_avail)) OR
                (idle_crd_ret_del_q and (tmpl0 or tmpl1 or tmpl5));

  data_flit_crc_start         <= (data_flit_xmit_q and not data_flit_xmit_d);
  triplet_flow_start          <= (half_dimm_mode or low_lat_mode) and rd_resp_pop_int;--(triplet_999_q and not wr_resp_flush_q and (data_pending_int or mmio_data_pending) and not rdf_data_current and low_lat_mode);
  triplet_wait_for_data_start <= ((mmio_data_pending or rdf_data_pending) and not wr_resp_flush_q AND not rdf_data_current and tmpl9);

  triplet_bypass_start <= rdf_1st_32B_current and tmpl9 and flit_xmit_done;

  triplet_rd_resp_stall_start <= rd_resp_low_lat_stall_q;

  triplet_data_valid_start <= (not half_dimm_mode and low_lat_mode and data_valid and rdf_data_current) OR
                              (not half_dimm_mode and low_lat_mode and data_valid and (data_pending_int or rdf_data_pending));
  triplet_mmio_start <= (mmio_data_pending and not data_pending_int and tmpl9) OR
                        (mmio_data_sub0_q and tmpl9);
  triplet_advance_start <= (not data_pending_int and (not rd_resp_empty_q or not meta_fifo_empty_q) and triplet_state_val_q and (tmpl9 or tmpl5)) OR
                           (triplet_state_val_q and flit_xmit_done and not drl_prev_val_q and (tmpl9 or tmpl5));

  write_flush_start <=  (wr_resp_flush_q and (flit_full_q or (not tlx_vc0_avail) or wr_resp_empty_q));

  force_tmpl_switch_start <= (((tmpl_current_q/=tmpl_next) and not mmio_data_pending and (mmio_resp_pend_q or not rd_resp_empty_q OR rd_resp_ow_pend_q or intrp_req_pend))) or
                             tmpl_no_longer_valid;

  intrp_req_start <= 
                     ((intrp_req_packed or assign_actag_packed) and (tmpl1 and or_reduce(flit_pkt_cnt_q))) OR
                     ((intrp_req_packed or assign_actag_packed) and (tmpl5 or tmpl0) and tl_4sl_pkt_full_q) OR
                     (intrp_req_pop and half_dimm_mode and tmpl0);

  hi_lat_read_start <=  hi_lat_mode and
                        (
                          (or_reduce(flit_rd_resp_q) and (rd_resp_empty_q or not (tlx_vc0_avail and tlx_dcp0_avail) or meta_fifo_empty_q)) or
                          (rdf_1st_32B_sub1_q or mmio_data_sub1_q or mmio_data_current or rdf_1st_32B_current) or
                          (rd_resp_len32 and not tmpl_config(9) and (rd_resp_len32_flit_pend_q or mmio_data_flit_pend_q or or_reduce(drl_current)))
                        );

  drl_max_start <= (drl_max_hit and not low_lat_mode and (wr_resp_empty_q or flit_full_q));

  half_dimm_start <= (half_dimm_mode and flit_xmit_done and (rdf_data_pending or mmio_data_pending or rdf_data_current or mmio_data_current)) or
                     (half_dimm_mode and tmpl0_flit_pend);


  data_flit_xmit_d <= data_flit_xmit or (not data_flit_xmit and data_flit_xmit_q and not flit_credit_avail);
  data_flit_xmit_int <= data_flit_xmit_q;

  flit_ip <= flit_xmit_start_t1_q OR flit_xmit_start_t2_q;

  fail_resp_flush_start <= fail_resp_flush_q AND
                           (
                             (tmpl0 AND tl_4sl_pkt_full_q) OR
                             (tmpl1 AND (flit_full_q OR fail_resp_empty_q OR (NOT tlx_vc0_avail))) OR
                             (tmpl5 AND tl_4sl_pkt_full_q AND tl_2sl_pkt_full_q) OR
                             ((tmpl9 or tmplB) AND tl_2sl_pkt_full_q)
                           );


  --room to add more. needed for metadata
  hi_lat_start_del_d <= (hi_lat_read_start) or
                        (hi_lat_start_del_q and not flit_xmit_start_int);

  flit_cyc_cnt_d <= gate("01000",                flit_buffer_reset and drl_current_2) OR
                    gate("00100",                flit_buffer_reset and drl_current_1) OR
                    gate(flit_cyc_cnt_q-1,      or_reduce(flit_cyc_cnt_q));

  ---------------------------------------------------------------------------------------------------
  -- Flit Transmit Rate Counter
  ---------------------------------------------------------------------------------------------------
  --pull out template configurations
  tmpl0_xmit_rate(5 downto 0) <= xmit_rate_config(3 downto 0)&"00";
  tmpl1_xmit_rate(5 downto 0) <= xmit_rate_config(7 downto 4)&"00";
  tmpl2_xmit_rate(5 downto 0) <= xmit_rate_config(11 downto 8)&"00";
  tmpl3_xmit_rate(5 downto 0) <= xmit_rate_config(15 downto 12)&"00";
  tmpl4_xmit_rate(5 downto 0) <= xmit_rate_config(19 downto 16)&"00";
  tmpl5_xmit_rate(5 downto 0) <= xmit_rate_config(23 downto 20)&"00";
  tmpl6_xmit_rate(5 downto 0) <= xmit_rate_config(27 downto 24)&"00";
  tmpl7_xmit_rate(5 downto 0) <= xmit_rate_config(31 downto 28)&"00";
  tmpl8_xmit_rate(5 downto 0) <= xmit_rate_config(35 downto 32)&"00";
  tmpl9_xmit_rate(5 downto 0) <= xmit_rate_config(39 downto 36)&"00";
  tmplA_xmit_rate(5 downto 0) <= xmit_rate_config(43 downto 40)&"00";
  tmplB_xmit_rate(5 downto 0) <= xmit_rate_config(47 downto 44)&"00";

  --tie off unused tempalte configs
  cb_term(tmpl2_xmit_rate);
  cb_term(tmpl3_xmit_rate);
  cb_term(tmpl4_xmit_rate);
  cb_term(tmpl6_xmit_rate);
  cb_term(tmpl7_xmit_rate);
  cb_term(tmpl8_xmit_rate);
  cb_term(tmplA_xmit_rate);

  --calculate set value
  xmit_rate_stall_max(5 downto 0) <= gate((tmpl0_xmit_rate),     tmpl0) OR
                                     gate((tmpl1_xmit_rate),     tmpl1) OR
                                     gate((tmpl5_xmit_rate),     tmpl5) OR
                                     gate((tmpl9_xmit_rate),     tmpl9) OR
                                     gate(tmplB_xmit_rate,     tmplB);
  --Temporarily removing the template B max value until it is otherwise implemented
  xmit_rate_stall_dec <= or_reduce(xmit_rate_stall_q(5 downto 0));

  xmit_rate_stall_d(5 downto 0) <= gate(xmit_rate_stall_max,                    flit_xmit_early_done and not data_flit_xmit_int) OR
                                   gate(xmit_rate_stall_q(5 downto 0)-1,        xmit_rate_stall_dec) OR
                                   gate(xmit_rate_stall_q(5 downto 0),          not ((flit_xmit_early_done and not data_flit_xmit_int) or xmit_rate_stall_dec));

  --set next flit to null to support all values off xmit rate when drl less than rate
  xmit_rate_current(3 DOWNTO 0) <= gate(tmpl0_xmit_rate(5 downto 2),        tmpl0) OR
                                   gate(tmpl1_xmit_rate(5 downto 2),        tmpl1) OR
                                   gate(tmpl5_xmit_rate(5 downto 2),        tmpl5) OR
                                   gate(tmpl9_xmit_rate(5 downto 2),        tmpl9);

  drl_less_than_xmit_rate <= or_reduce(drl_current) AND (drl_current<xmit_rate_current);

  null_flit_next_d <= (((flit_buffer_reset and tmpl9) or (flit_xmit_start_pulse and not tmpl9)) AND drl_less_than_xmit_rate) OR
                      (null_flit_next_q AND NOT flit_xmit_start_pulse);

  null_flit_next_start <= null_flit_next_q AND (data_flit_xmit_q and not data_flit_xmit_d);
  -----------------------------------------------------------------------------
  -- Calculate Data Run Length
  -----------------------------------------------------------------------------
  --increment data run length when there are meta bits in queue, at least one expired timer, at
  --least 4 data bts pending (could cause issues when running with a data run length/=0), and more
  --timers expired than the current data run length.

  data_run_length_max(3 downto 0) <= gate("0000",           not tmpl9 and     tmplB) OR
                                     gate("0010",               tmpl9 and not tmplB) OR
                                     gate("1000",           not tmpl9 and not tmplB);

  drl_max_hit <= (drl_current=data_run_length_max) and or_reduce(data_run_length_max);

  drl_high_lat_d(3 downto 0) <= gate("0000",                            flit_buffer_reset) OR
                                gate(drl_high_lat_q(3 downto 0) + 1,     drl_high_lat_inc) OR
                                gate(drl_high_lat_q(3 downto 0),        not flit_buffer_reset and not drl_high_lat_inc);

  drl_high_lat_p_d <=           ('0'                                AND flit_buffer_reset) OR
           ((drl_high_lat_p_q xor INCP(drl_high_lat_q(3 downto 0))) AND  drl_high_lat_inc) OR
           (drl_high_lat_p_q                                        AND not flit_buffer_reset and not drl_high_lat_inc);

  --Previous Data run length
  data_run_length_d <= gate(drl_current,                    flit_buffer_reset) OR
                       gate(data_run_length_q,          not flit_buffer_reset);

  data_run_length_p_d <= (drl_current_p             AND      flit_buffer_reset) OR
                         (data_run_length_p_q       AND   not flit_buffer_reset );

  drl_prev_val_d <= or_reduce(data_run_length_d);

  --allow for change of data run length up the the last cycle

  dl_cont_data_run_len <= gate(drl_current,     flit_xmit_start_pulse or flit_ip);

  drl_current_1 <= (drl_current="0001");
  drl_current_2 <= (drl_current="0010");
  drl_last_non_zero <= or_reduce(data_run_length_q);
  -----------------------------------------------------------------------------
  -- template selection
  -----------------------------------------------------------------------------

  dl_cont_tl_tmpl_d(5 DOWNTO 0) <= gate("001011",                 tmpl_current_q(4) and flit_xmit_start_d) OR
                                   gate("001001",                 tmpl_current_q(3) and flit_xmit_start_d) OR
                                   gate("000101",                 tmpl_current_q(2) and flit_xmit_start_d) OR
                                   gate("000001",                 tmpl_current_q(1) and flit_xmit_start_d) OR
                                   gate("000000",                 tmpl_current_q(0) and flit_xmit_start_d) OR
                                   gate(dl_cont_tl_tmpl_q(5 DOWNTO 0),        not flit_xmit_start_d);

  dl_cont_tl_tmpl_p_d           <= ('1' and tmpl_current_q(4) and flit_xmit_start_d) or
                                   ('0' and tmpl_current_q(3) and flit_xmit_start_d) or
                                   ('0' and tmpl_current_q(2) and flit_xmit_start_d) or
                                   ('1' and tmpl_current_q(1) and flit_xmit_start_d) or
                                   ('0' and tmpl_current_q(0) and flit_xmit_start_d) or
                                   (dl_cont_tl_tmpl_p_q AND not flit_xmit_start_d);

  dl_cont_tl_tmpl(5 DOWNTO 0) <= gate("001011",                 tmpl_current_q(4) and flit_xmit_start_d) OR
                                 gate("001001",                 tmpl_current_q(3) and flit_xmit_start_d) OR
                                 gate("000101",                 tmpl_current_q(2) and flit_xmit_start_d) OR
                                 gate("000001",                 tmpl_current_q(1) and flit_xmit_start_d) OR
                                 gate("000000",                 tmpl_current_q(0) and flit_xmit_start_d) OR
                                 gate(dl_cont_tl_tmpl_q(5 DOWNTO 0),        not flit_xmit_start_d);

  dl_cont_tl_tmpl_p           <= ('1' and tmpl_current_q(4) and flit_xmit_start_d) or
                                 ('0' and tmpl_current_q(3) and flit_xmit_start_d) or
                                 ('0' and tmpl_current_q(2) and flit_xmit_start_d) or
                                 ('1' and tmpl_current_q(1) and flit_xmit_start_d) or
                                 ('0' and tmpl_current_q(0) and flit_xmit_start_d) or
                                 (dl_cont_tl_tmpl_p_q AND not flit_xmit_start_d);

  tmpl_current_d(4 downto 0) <= gate("00001",                     link_up_pulse) or
                                gate(tmpl_next(4 downto 0),           flit_buffer_reset ) or
                                gate(tmpl_current_q(4 downto 0),  not flit_buffer_reset);

  tmpl_current_mux_d(4 downto 0) <= gate("00001",                     link_up_pulse) or
                                gate(tmpl_next(4 downto 0),           flit_buffer_reset ) or
                                gate(tmpl_current_q(4 downto 0),  not flit_buffer_reset);

  tmpl_current_dbg_d(4 downto 0) <= gate("00001",                     link_up_pulse) or
                                gate(tmpl_next(4 downto 0),           flit_buffer_reset ) or
                                gate(tmpl_current_q(4 downto 0),  not flit_buffer_reset);

  --Generate Valid template signales for currnt and next templates
  tmplB_next <= tmpl_next_onehot(4);
  tmpl9_next <= tmpl_next_onehot(3);
  tmpl5_next <= tmpl_next_onehot(2);
  tmpl1_next <= tmpl_next_onehot(1);
  tmpl0_next <= tmpl_next_onehot(0);

  --next template
  tmpl_next_onehot       <= gate("00001",                   tmpl0_chosen and not tmpl1_chosen and not tmpl5_chosen and not tmpl9_chosen and not tmplB_chosen) or
                            gate("00010",               not tmpl0_chosen and     tmpl1_chosen and not tmpl5_chosen and not tmpl9_chosen and not tmplB_chosen) or
                            gate("00100",               not tmpl0_chosen and not tmpl1_chosen and     tmpl5_chosen and not tmpl9_chosen and not tmplB_chosen) or
                            gate("01000",               not tmpl0_chosen and not tmpl1_chosen and not tmpl5_chosen and     tmpl9_chosen and not tmplB_chosen) or
                            gate("10000",               not tmpl0_chosen and not tmpl1_chosen and not tmpl5_chosen and not tmpl9_chosen and     tmplB_chosen) or
                            gate(tmpl_current_q,        tmpl_chosen_multi or tmpl_chosen_no_new);

  tmpl_next(4 downto 0) <= tmpl_next_onehot(4 downto 0);
  tmpl_next_p           <= '0';--tmpl_next_withp(6);

  tmpl_chosen_multi <= (tmpl0_chosen and tmpl1_chosen) or
                       (tmpl0_chosen and tmpl5_chosen) or
                       (tmpl0_chosen and tmpl9_chosen) or
                       (tmpl0_chosen and tmplB_chosen) or
                       (tmpl1_chosen and tmpl5_chosen) or
                       (tmpl1_chosen and tmpl9_chosen) or
                       (tmpl1_chosen and tmplB_chosen) or
                       (tmpl5_chosen and tmpl9_chosen) or
                       (tmpl5_chosen and tmplB_chosen) or
                       (tmpl9_chosen and tmplB_chosen);

  tmpl_chosen_no_new <= not (tmpl0_chosen or tmpl1_chosen or tmpl5_chosen or tmpl9_chosen or tmplB_chosen);

  --------------------------------------------------------------------------------------------------
  -- Template selection triggers
  --------------------------------------------------------------------------------------------------
  --Template 0 triggers
  tmpl0_chosen <= (force_tmpl0) or
                  (tmpl_config(0) and
                  (
                    tmpl0_1_5_9_B_dis or
                    tmpl0_init_cred or
                    tmpl0_intrp_req OR
                    tmpl0_half_dimm_intrp OR 
                    null_flit_next_q 
                  ));

  tmpl0_1_5_9_B_dis           <= not (tmpl_config(1) or tmpl_config(5) or tmpl_config(9) or (tmpl_config(11) and half_dimm_mode));
  tmpl0_init_cred             <= not init_complete_q;
  tmpl0_intrp_req             <= (not half_dimm_mode and not triplet_state_val_q and not (tmpl_config(5) or tmpl_config(1)) and intrp_req_pend and not (mmio_data_pending or mmio_data_current OR rdf_1st_32B_sub1_q)) OR
                                 (triplet_state_val_q and intrp_req_pend and not tmpl5_intrp_opt_val_q and not (mmio_data_pending or rdf_data_pending) and not drl_in_pipe);
  tmpl0_assign_actag          <= not triplet_state_val_q and assign_actag_pend;
  tmpl0_half_dimm_intrp       <= intrp_req_pend and half_dimm_mode AND tmpl0_flit_sub0_q AND not mmio_data_pending;  --modify term to abide by
                                                                     --needed performance
                                                                     --optimization.

  force_tmpl0 <= not (tmpl_config(0) or tmpl_config(1) or tmpl_config(5)) and intrp_req_pend and not (mmio_data_pending or mmio_data_current);

  --Template 1 triggers
  tmpl1_chosen <= init_complete_q and tmpl_config(1) AND NOT null_flit_next_q and not half_dimm_mode AND
                   (
                     tmpl1_tmpl5_tmpl9_dis or
                     tmpl1_fail_flush or
                     tmpl1_intrp
                   );

  tmpl1_tmpl5_tmpl9_dis <= not (tmpl_config(5) or tmpl_config(9) or (tmpl_config(11) and half_dimm_mode)) and not tmpl0_chosen;
  tmpl1_fail_flush      <= fail_resp_flush_q and not  (mmio_data_pending or mmio_data_current) and not (rdf_data_pending);
  tmpl1_intrp           <= not triplet_state_val_q and intrp_req_pend and not (mmio_data_pending or mmio_data_current OR rdf_1st_32B_sub1_q) and (not tmpl_config(5) or ((fail_resp_half_full or multiple_intrp_pend) and not mmio_data_pending));

  --Template 5 triggers
  tmpl5_chosen <= init_complete_q and tmpl_config(5) and  NOT null_flit_next_q and not half_dimm_mode AND --'0' and --uncom for forced 9
                  (
                    tmpl5_tmpl9_dis or
                    tmpl5_wr_flush or
                    tmpl5_intrp or
                    tmpl5_low_lat or
                    tmpl5_hi_lat_def
                  );

  tmpl5_tmpl9_dis    <= not (tmpl_config(9) or (tmpl_config(11) and half_dimm_mode)) and not (tmpl1_chosen or tmpl0_chosen);
  tmpl5_wr_flush     <= (wr_resp_flush_q and not (mmio_data_pending or mmio_data_current or rdf_data_pending));
  tmpl5_intrp        <= intrp_req_pend AND not (mmio_data_pending or mmio_data_current OR rdf_1st_32B_sub1_q) and
                        ((not triplet_state_val_q OR NOT low_lat_mode) AND NOT ((fail_resp_half_full or multiple_intrp_pend) AND tmpl_config(1)));
  tmpl5_low_lat      <= low_lat_mode and triplet_state_val_q and (tmpl5_flit_sub0_q and not tmpl5);
  tmpl5_hi_lat_def   <= hi_lat_mode and not (rdf_1st_32B_sub1_q or mmio_data_sub1_q or rd_resp_len32 or (mmio_resp_pend_q and tmpl9_opt_val_q)) and not ((fail_resp_half_full or multiple_intrp_pend) and not mmio_data_pending);

  --Template 9 Triggers
  tmpl9_chosen <= init_complete_q and tmpl_config(9) and not tmpl5_chosen AND NOT tmpl1_fail_flush and not tmpl0_intrp_req and NOT null_flit_next_q AND not half_dimm_mode AND not force_tmpl0 and --'1' and --uncom for forced 9
                  (
                    tmpl9_idle or
                    tmpl9_low_lat_def or
                    tmpl9_hi_lat_def or
                    tmpl9_hi_lat_mmio or
                    tmpl9_ow_pend or
                    tmpl9_low_lat_dat_pend OR
                    tmpl9_low_lat_mmio_pend OR
                    tmpl9_triplet_dat or
                    tmpl9_hi_lat_32B_rd or
                    tmpl9_wr_flush_ow_mmio_pend
                  );

  tmpl9_idle                  <= (rd_resp_empty_q and wr_resp_empty_q and mmio_resp_empty and not intrp_req_pend and low_lat_mode);
  tmpl9_low_lat_def           <= low_lat_mode and
                                 not (tmpl5_flit_sub0_q and not tmpl5) and
                                 --not (non_main_gate_q and not (flit_ip or data_flit_xmit_int)) AND
                                 NOT (NOT triplet_state_val_q AND intrp_req_pend and (((fail_resp_half_full or multiple_intrp_pend or not tmpl_config(5)) and tmpl_config(1)) or tmpl_config(5)));
  tmpl9_hi_lat_def            <= hi_lat_mode and not tmpl_config(5) and not (half_dimm_mode or ((fail_resp_half_full or multiple_intrp_pend or intrp_req_pend) and tmpl_config(1)));
  tmpl9_hi_lat_mmio           <= hi_lat_mode and (mmio_data_sub1_q or (mmio_resp_pend_q and tmpl9_opt_val_q));
  tmpl9_hi_lat_32B_rd         <= hi_lat_mode and (rdf_1st_32B_sub1_q or rd_resp_len32);
  tmpl9_ow_pend               <= not (tmpl5_flit_sub0_q and not tmpl5) and (ow_data_pend or rd_resp_ow_pend_q);
  tmpl9_low_lat_dat_pend      <= not (tmpl5_flit_sub0_q and not tmpl5)and (data_pending_int and low_lat_mode);
  tmpl9_triplet_dat           <= (rdf_data_pending or rdf_data_current);
  tmpl9_low_lat_mmio_pend     <= (mmio_data_pending OR mmio_data_current) and low_lat_mode;
  tmpl9_wr_flush_ow_mmio_pend <= (wr_resp_flush_q and (not tmpl_config(5) or mmio_data_pending));

  tmplB_chosen <= init_complete_q and tmpl_config(11) and not tmpl0_half_dimm_intrp and not force_tmpl0 and 
                  (
                    half_dimm_mode or
                    (not half_dimm_mode and not (tmpl_config(0) or tmpl_config(1) or tmpl_config(5) or tmpl_config(9)))
                  );
                  
  -----------------------------------------------------------------------------
  -- Initial Credit return to host complete?
  -- currently designed to allow for initial transmission of 32 VC1 credits and
  -- 64 DCP1 credits. This can be accomplished by 2 transfers of template 0
  -- with a return tl credits command.
  --
  -- Will need to update if we want the ability to add more credits.
  -----------------------------------------------------------------------------
  init_cred_ret_complete_d(1 downto 0) <= gate("00",                            link_up_pulse) OR
                                          gate("01",                            init_cred_ret_complete_0_1) OR
                                          gate("10",                            init_cred_ret_complete_1_2) OR
                                          gate("11",                            init_cred_ret_complete_2_3) OR
                                          gate(init_cred_ret_complete_q,        init_cred_ret_complete_hold);

  init_cred_ret_complete_0_1 <= (init_cred_ret_complete_q="00") and link_up_pulse;
  init_cred_ret_complete_1_2 <= (init_cred_ret_complete_q="01") and cred_ret_done;
  init_cred_ret_complete_2_3 <= (init_cred_ret_complete_q="10") and cred_ret_done;
  init_cred_ret_complete_hold <= not (init_cred_ret_complete_0_1 or init_cred_ret_complete_1_2 or init_cred_ret_complete_2_3) OR
                                 (init_cred_ret_complete_q="11");

  init_complete_d <= (init_cred_ret_complete_d(1 downto 0)="11");
  init_flit_start <= ((init_cred_ret_complete_d="01") OR (init_cred_ret_complete_d="10")) and tl_2sl_pkt_full_q;

  cred_ret_done <= flit_xmit_early_done and not init_complete_q and tmpl0;      --Need to add return valid signal back
                                        --from return packing.

  idle_crd_ret <= tlxc_tlxt_crd_ret_val and init_complete_q and
                  (
                    (rd_resp_empty_q and wr_resp_empty_q and mmio_resp_empty AND NOT rd_resp_ow_pend_q and not intrp_req_pend and fail_resp_empty_q  and not (rdf_data_current or data_pending_int)) OR
                    (not tlx_vc0_avail  and not (rdf_data_current or data_pending_int) )OR
                    (not tlx_dcp0_avail and wr_resp_empty_q  and not (rdf_data_current or data_pending_int))  OR
                    (not or_reduce(idle_crd_ret_tmr_q) and not (rdf_data_current and not metadata_avail))
                  );

  --idle credit return timer
  crd_ret_taken_d <= tlxt_tlxc_crd_ret_taken_int; -- Latch for timing reasons

  idle_crd_ret_tmr_d(5 downto 0) <= gate("111111",                              crd_ret_taken_q) OR
                                    gate(idle_crd_ret_tmr_q(5 downto 0)-1,      not crd_ret_taken_q and     flit_credit_avail) OR
                                    gate(idle_crd_ret_tmr_q(5 downto 0),        not crd_ret_taken_q and not flit_credit_avail);

  idle_crd_ret_tmr_p_d <= ('0'                                              AND crd_ret_taken_q) OR
       ((idle_crd_ret_tmr_p_q xor INCP(not idle_crd_ret_tmr_q(5 downto 0))) AND not crd_ret_taken_q and     flit_credit_avail) OR
           (idle_crd_ret_tmr_p_q                                            AND not crd_ret_taken_q and not flit_credit_avail);

  idle_crd_ret_del_d <= idle_crd_ret;

  --------------------------------------------------------------------------------------------------
  -- Interrupt Request
  --------------------------------------------------------------------------------------------------

  intrp_req_chan_xstop_d (2 downto 0) <= gate("000",               intrp_req_chan_xstop_reset) or
                                         gate("001",               intrp_req_chan_xstop_pend or intrp_req_chan_xstop_retry) OR
                                         gate("010",               intrp_req_chan_xstop_pack) OR
                                         gate("011",               intrp_req_chan_xstop_sent) OR
                                         gate("100",               intrp_req_chan_xstop_2nd);

  intrp_req_chan_xstop_p_d            <= ('0' and                intrp_req_chan_xstop_reset) or
                                         ('1' and                (intrp_req_chan_xstop_pend or intrp_req_chan_xstop_retry)) OR
                                         ('1' and                intrp_req_chan_xstop_pack) OR
                                         ('0' and                intrp_req_chan_xstop_sent) OR
                                         ('1' and                intrp_req_chan_xstop_2nd);

  intrp_req_rec_attn_d (2 downto 0) <= gate("000",               intrp_req_rec_attn_reset) or
                                       gate("001",               intrp_req_rec_attn_pend or intrp_req_rec_attn_retry) OR
                                       gate("010",               intrp_req_rec_attn_pack) OR
                                       gate("011",               intrp_req_rec_attn_sent) or
                                       gate("100",               intrp_req_rec_attn_2nd);

  intrp_req_rec_attn_p_d            <= ('0' and                intrp_req_rec_attn_reset) or
                                       ('1' and                (intrp_req_rec_attn_pend or intrp_req_rec_attn_retry)) OR
                                       ('1' and                intrp_req_rec_attn_pack) OR
                                       ('0' and               intrp_req_rec_attn_sent) or
                                       ('1' and               intrp_req_rec_attn_2nd);

  intrp_req_sp_attn_d (2 downto 0) <= gate("000",               intrp_req_sp_attn_reset) or
                                      gate("001",               intrp_req_sp_attn_pend or intrp_req_sp_attn_retry) OR
                                      gate("010",               intrp_req_sp_attn_pack) OR
                                      gate("011",               intrp_req_sp_attn_sent) or
                                      gate("100",               intrp_req_sp_attn_2nd);

  intrp_req_sp_attn_p_d            <= ('0' and               intrp_req_sp_attn_reset) or
                                      ('1' and               (intrp_req_sp_attn_pend or intrp_req_sp_attn_retry)) OR
                                      ('1' and               intrp_req_sp_attn_pack) OR
                                      ('0' and               intrp_req_sp_attn_sent) or
                                      ('1' and               intrp_req_sp_attn_2nd);

  intrp_req_app_intrp_d (2 downto 0) <= gate("000",               intrp_req_app_intrp_reset) or
                                        gate("001",               intrp_req_app_intrp_pend or intrp_req_app_intrp_retry) OR
                                        gate("010",               intrp_req_app_intrp_pack) OR
                                        gate("011",               intrp_req_app_intrp_sent) or
                                        gate("100",               intrp_req_app_intrp_2nd);

  intrp_req_app_intrp_p_d            <= ('0' and               intrp_req_app_intrp_reset) or
                                        ('1' and               (intrp_req_app_intrp_pend or intrp_req_app_intrp_retry)) OR
                                        ('1' and               intrp_req_app_intrp_pack) OR
                                        ('0' and               intrp_req_app_intrp_sent) or
                                        ('1' and                intrp_req_app_intrp_2nd);

  intrp_req_chan_xstop_perr <= xor_reduce(intrp_req_chan_xstop_q & intrp_req_chan_xstop_p_q);
  intrp_req_rec_attn_perr <= xor_reduce(intrp_req_rec_attn_q & intrp_req_rec_attn_p_q);
  intrp_req_sp_attn_perr <= xor_reduce(intrp_req_sp_attn_q & intrp_req_sp_attn_p_q);
  intrp_req_app_intrp_perr <= xor_reduce(intrp_req_app_intrp_q & intrp_req_app_intrp_p_q);

  intrp_req_sm_perr(0 to 3) <= intrp_req_chan_xstop_perr &
                               intrp_req_rec_attn_perr &
                               intrp_req_sp_attn_perr &
                               intrp_req_app_intrp_perr;

  opencapi_link_shutdown_d <= intrp_req_chan_xstop_perr or
                              opencapi_link_shutdown_q;
                                   
  
  --Interrupt State reset signals
  intrp_req_chan_xstop_reset  <= (intrp_req_chan_xstop_q(2 downto 0) = "011") and ((intrp_resp(1 downto 0)="01") or (intrp_resp(1 downto 0)="11"));
  intrp_req_rec_attn_reset  <= (intrp_req_rec_attn_q(2 downto 0) = "011") and ((intrp_resp(3 downto 2)="01") or(intrp_resp(3 downto 2)="11"));
  intrp_req_sp_attn_reset   <= (intrp_req_sp_attn_q(2 downto 0) = "011") and ((intrp_resp(5 downto 4)="01") or (intrp_resp(5 downto 4)="11"));
  intrp_req_app_intrp_reset <= (intrp_req_app_intrp_q(2 downto 0) = "011") and ((intrp_resp(7 downto 6)="01") or (intrp_resp(7 downto 6)="11"));

  --Interrupt state accept
  intrp_req_chan_xstop_pend  <= ((intrp_req_chan_xstop_q(2 downto 0) = "000") and intrp_chan_xstop) or
                                ((intrp_req_chan_xstop_q(2 downto 0) = "001") and not intrp_req_chan_xstop_pack);
  intrp_req_rec_attn_pend  <= ((intrp_req_rec_attn_q(2 downto 0) = "000") and intrp_rec_attn) or
                              ((intrp_req_rec_attn_q(2 downto 0) = "001") and not intrp_req_rec_attn_pack);
  intrp_req_sp_attn_pend   <= ((intrp_req_sp_attn_q(2 downto 0) = "000") and intrp_sp_attn) or
                              ((intrp_req_sp_attn_q(2 downto 0) = "001") and not intrp_req_sp_attn_pack);
    intrp_req_app_intrp_pend <= ((intrp_req_app_intrp_q(2 downto 0) = "000") and intrp_app_intrp) or
                                ((intrp_req_app_intrp_q(2 downto 0) = "001") and not intrp_req_app_intrp_pack);

  --Interrupt state move to response packed but not sent
  intrp_req_chan_xstop_pack  <=     ((intrp_req_chan_xstop_q(2 downto 0) = "001") and intrp_req_pop) or
                                    ((intrp_req_chan_xstop_q(2 downto 0) = "010") and not intrp_req_chan_xstop_sent);
  intrp_req_rec_attn_pack  <= (not (intrp_req_chan_xstop_q(2 downto 0) = "001") and     (intrp_req_rec_attn_q(2 downto 0) = "001") and intrp_req_pop) or
                              ((intrp_req_rec_attn_q(2 downto 0) = "010") and not intrp_req_rec_attn_sent);
  intrp_req_sp_attn_pack   <= (not (intrp_req_chan_xstop_q(2 downto 0) = "001") and not (intrp_req_rec_attn_q(2 downto 0) = "001") and     (intrp_req_sp_attn_q(2 downto 0) = "001") and intrp_req_pop) or
                              ((intrp_req_sp_attn_q(2 downto 0) = "010") and not intrp_req_sp_attn_sent);
  intrp_req_app_intrp_pack <= (not (intrp_req_chan_xstop_q(2 downto 0) = "001") and not (intrp_req_rec_attn_q(2 downto 0) = "001") and not (intrp_req_sp_attn_q(2 downto 0) = "001") and (intrp_req_app_intrp_q(2 downto 0) = "001") and intrp_req_pop)  or
                              ((intrp_req_app_intrp_q(2 downto 0) = "010") and not intrp_req_app_intrp_sent);

  --Interrupt request sent state transition.
  intrp_req_chan_xstop_sent  <= ((intrp_req_chan_xstop_q(2 downto 0) = "010") and flit_buffer_reset)  or
                                ((intrp_req_chan_xstop_q(2 downto 0) = "011") and (intrp_resp(1 downto 0)="00") and not (intrp_chan_xstop or intrp_req_chan_xstop_missed_edge_q));
  intrp_req_rec_attn_sent  <= ((intrp_req_rec_attn_q(2 downto 0) = "010") and flit_buffer_reset) or
                              ((intrp_req_rec_attn_q(2 downto 0) = "011") and (intrp_resp(3 downto 2)="00") and not (intrp_rec_attn or intrp_req_rec_attn_missed_edge_q));
  intrp_req_sp_attn_sent   <= ((intrp_req_sp_attn_q(2 downto 0) = "010") and flit_buffer_reset) or
                              ((intrp_req_sp_attn_q(2 downto 0) = "011") and (intrp_resp(5 downto 4)="00") and not (intrp_sp_attn or intrp_req_sp_attn_missed_edge_q));
  intrp_req_app_intrp_sent <= ((intrp_req_app_intrp_q(2 downto 0) = "010") and flit_buffer_reset) or
                              ((intrp_req_app_intrp_q(2 downto 0) = "011") and (intrp_resp(7 downto 6)="00") and not (intrp_app_intrp or intrp_req_app_intrp_missed_edge_q));

  intrp_req_chan_xstop_retry <= ((intrp_req_chan_xstop_q(2 downto 0) = "011") and (intrp_resp(1 downto 0) = "10")) or
                                ((intrp_req_chan_xstop_q(2 downto 0) = "011") and intrp_chan_xstop and or_reduce(intrp_resp(1 downto 0))) or
                                ((intrp_req_chan_xstop_q(2 downto 0) = "100") and or_reduce(intrp_resp(1 downto 0)));
  intrp_req_rec_attn_retry   <= ((intrp_req_rec_attn_q(2 downto 0) = "011") and (intrp_resp(3 downto 2) = "10")) or
                                ((intrp_req_rec_attn_q(2 downto 0) = "011") and intrp_rec_attn and or_reduce(intrp_resp(3 downto 2))) or
                                ((intrp_req_rec_attn_q(2 downto 0) = "100") and or_reduce(intrp_resp(3 downto 2)));
  intrp_req_sp_attn_retry    <= ((intrp_req_sp_attn_q(2 downto 0) = "011") and (intrp_resp(5 downto 4) = "10")) or
                                ((intrp_req_sp_attn_q(2 downto 0) = "011") and intrp_sp_attn and or_reduce(intrp_resp(5 downto 4))) or
                                ((intrp_req_sp_attn_q(2 downto 0) = "100") and or_reduce(intrp_resp(5 downto 4)));
  intrp_req_app_intrp_retry <= ((intrp_req_app_intrp_q(2 downto 0) = "011") and (intrp_resp(7 downto 6) = "10")) or
                               ((intrp_req_app_intrp_q(2 downto 0) = "011") and intrp_app_intrp and or_reduce(intrp_resp(7 downto 6))) or
                               ((intrp_req_app_intrp_q(2 downto 0) = "100") and or_reduce(intrp_resp(7 downto 6)));

  intrp_req_chan_xstop_2nd <= ((intrp_req_chan_xstop_q(2 downto 0) = "011") and (intrp_chan_xstop or intrp_req_chan_xstop_missed_edge_q) and  not or_reduce(intrp_resp(1 downto 0))) or
                              ((intrp_req_chan_xstop_q(2 downto 0) = "100") and (intrp_resp(1 downto 0) = "00"));
  intrp_req_rec_attn_2nd   <= ((intrp_req_rec_attn_q(2 downto 0) = "011") and (intrp_rec_attn or intrp_req_rec_attn_missed_edge_q) and not or_reduce(intrp_resp(3 downto 2))) or
                              ((intrp_req_rec_attn_q(2 downto 0) = "100") and (intrp_resp(3 downto 2)="00"));
  intrp_req_sp_attn_2nd    <= ((intrp_req_sp_attn_q(2 downto 0) = "011") and (intrp_sp_attn or intrp_req_sp_attn_missed_edge_q) and not or_reduce(intrp_resp(5 downto 4))) or
                              ((intrp_req_sp_attn_q(2 downto 0) = "100") and (intrp_resp(5 downto 4)="00"));
  intrp_req_app_intrp_2nd  <= ((intrp_req_app_intrp_q(2 downto 0) = "011") and (intrp_app_intrp or intrp_req_app_intrp_missed_edge_q) and not or_reduce(intrp_resp(7 downto 6))) or
                              ((intrp_req_app_intrp_q(2 downto 0) = "100") and (intrp_resp(7 downto 6)="00"));

  intrp_req_app_intrp_missed_edge_d <=  (not intrp_req_app_intrp_missed_edge_q and ((intrp_req_app_intrp_q="001") or intrp_req_app_intrp_pack) and intrp_app_intrp) OR
                                        (    intrp_req_app_intrp_missed_edge_q and not intrp_req_app_intrp_2nd);

  intrp_req_chan_xstop_missed_edge_d <=  (not intrp_req_chan_xstop_missed_edge_q and ((intrp_req_chan_xstop_q="001") or intrp_req_chan_xstop_pack) and intrp_chan_xstop) OR
                                         (    intrp_req_chan_xstop_missed_edge_q and not intrp_req_chan_xstop_2nd);

  intrp_req_rec_attn_missed_edge_d <=  (not intrp_req_rec_attn_missed_edge_q and ((intrp_req_rec_attn_q="001") or intrp_req_rec_attn_pack) and intrp_rec_attn) OR
                                       (    intrp_req_rec_attn_missed_edge_q and not intrp_req_rec_attn_2nd);

  intrp_req_sp_attn_missed_edge_d <=  (not intrp_req_sp_attn_missed_edge_q and ((intrp_req_sp_attn_q="001") or intrp_req_sp_attn_pack) and intrp_sp_attn) OR
                                      (    intrp_req_sp_attn_missed_edge_q and not intrp_req_sp_attn_2nd);

  --Interrupt response "pop"
  intrp_req_pop_d <= not intrp_req_pop_q and intrp_req_pend and not flit_xmit_start_pulse and (assign_actag_sent_q or assign_actag_packed) and
                     (
                       (tmpl1 and not flit_full_q and not flit_hold) or
                       ((tmpl5 or tmpl0) and not tl_4sl_pkt_full_q and not flit_hold) or
                       (half_dimm_mode and tmpl0_flit_sub0_q and tmpl0_next and flit_xmit_early_done)
                     );

  intrp_req_pop <= intrp_req_pop_q and tlx_vc3_avail and not ((flit_hold and (tmpl0 or tmpl1)) or flit_full_q or tl_4sl_pkt_full_q);

  intrp_req_pend <= (assign_actag_sent_q) and tlx_vc3_avail and (tmpl_config(0) or tmpl_config(1) or tmpl_config(5)) and
                    (
                      (intrp_req_app_intrp_q="001") or
                      (intrp_req_sp_attn_q="001") or
                      (intrp_req_rec_attn_q="001") or
                      (intrp_req_chan_xstop_q="001")
                    );

  multiple_intrp_pend <= (assign_actag_packed or assign_actag_sent_q) and tlx_vc3_avail and (tmpl_config(0) or tmpl_config(1) or tmpl_config(5)) and
                         (
                           ((intrp_req_app_intrp_q="001") and (intrp_req_sp_attn_q="001")) or
                           ((intrp_req_app_intrp_q="001") and (intrp_req_rec_attn_q="001")) or
                           ((intrp_req_app_intrp_q="001") and (intrp_req_app_intrp_q="001")) or
                           ((intrp_req_sp_attn_q="001") and (intrp_req_rec_attn_q="001"))or
                           ((intrp_req_sp_attn_q="001") and (intrp_req_app_intrp_q="001"))or
                           ((intrp_req_rec_attn_q="001") and (intrp_req_app_intrp_q="001"))
                         );



  intrp_req_packed <=(intrp_req_app_intrp_q="010") or
                     (intrp_req_sp_attn_q="010") or
                     (intrp_req_rec_attn_q="010") or
                     (intrp_req_chan_xstop_q="010");

                                       --  P   flag     P  afutag
  intrp_req_p_tag          <= gate('1'&"0001" , intrp_req_chan_xstop_pack and intrp_req_chan_xstop_q(2 downto 0)="001") OR
                              gate('1'&"0010" , intrp_req_rec_attn_pack   and intrp_req_rec_attn_q  (2 downto 0)="001") OR
                              gate('0'&"0011" , intrp_req_sp_attn_pack    and intrp_req_sp_attn_q   (2 downto 0)="001") OR
                              gate('1'&"0100" , intrp_req_app_intrp_pack  and intrp_req_app_intrp_q (2 downto 0)="001");

  intrp_req_cmd_flag (3 downto 0) <= gate(cmd_flag_0 , intrp_req_chan_xstop_pack and intrp_req_chan_xstop_q(2 downto 0)="001") OR
                                     gate(cmd_flag_1 , intrp_req_rec_attn_pack   and intrp_req_rec_attn_q  (2 downto 0)="001") OR
                                     gate(cmd_flag_2 , intrp_req_sp_attn_pack    and intrp_req_sp_attn_q   (2 downto 0)="001") OR
                                     gate(cmd_flag_3 , intrp_req_app_intrp_pack  and intrp_req_app_intrp_q (2 downto 0)="001");
  intrp_req_cmd_flag_p            <= xor_reduce(intrp_req_cmd_flag);
  afu_tag (15 downto 0)           <= rsvd_1sl(15 downto 4) & intrp_req_p_tag(3 downto 0);
  afu_tag_p                       <= intrp_req_p_tag(4);

  intrp_req_opcode(8 downto 0) <= '1' & "01011000";

  -- Parity bits over 63:60, 59:52, ... , 11:4, 3:0
  handle_0_p <= XOR_REDUCE(tlxt_intrp_handle_0(63 downto 60)) & not GENPARITY(tlxt_intrp_handle_0(59 downto 4)) & XOR_REDUCE(tlxt_intrp_handle_0(3 downto 0));
  handle_1_p <= XOR_REDUCE(tlxt_intrp_handle_1(63 downto 60)) & not GENPARITY(tlxt_intrp_handle_1(59 downto 4)) & XOR_REDUCE(tlxt_intrp_handle_1(3 downto 0));
  handle_2_p <= XOR_REDUCE(tlxt_intrp_handle_2(63 downto 60)) & not GENPARITY(tlxt_intrp_handle_2(59 downto 4)) & XOR_REDUCE(tlxt_intrp_handle_2(3 downto 0));
  handle_3_p <= XOR_REDUCE(tlxt_intrp_handle_3(63 downto 60)) & not GENPARITY(tlxt_intrp_handle_3(59 downto 4)) & XOR_REDUCE(tlxt_intrp_handle_3(3 downto 0));

  obj_handle_withp <= gate(handle_0_p & tlxt_intrp_handle_0 , intrp_req_chan_xstop_pack and intrp_req_chan_xstop_q(2 downto 0)="001") OR
                      gate(handle_1_p & tlxt_intrp_handle_1 , intrp_req_rec_attn_pack   and intrp_req_rec_attn_q  (2 downto 0)="001") OR
                      gate(handle_2_p & tlxt_intrp_handle_2 , intrp_req_sp_attn_pack    and intrp_req_sp_attn_q   (2 downto 0)="001") OR
                      gate(handle_3_p & tlxt_intrp_handle_3 , intrp_req_app_intrp_pack  and intrp_req_app_intrp_q (2 downto 0)="001");

  stream_id(3 downto 0) <= "0000";

  intrp_req(111 downto 0) <= "0000" &                       --111:108
                             afu_tag &                      --107:92 (only 95:92 used)
                             obj_handle_withp(63 downto 0) &-- 91:28
                             stream_id &                    -- 27:24
                             actag_q &                      -- 23:12
                             intrp_req_cmd_flag &           -- 11:8
                             intrp_req_opcode(7 downto 0);  --  7:0

  intrp_req_p(13 downto 0)<= "00"                                    -- Over 111:96
                           & (afu_tag_p xor obj_handle_withp(72))    -- Over 95:88
                           & obj_handle_withp(71 downto 65)          -- Over 87:32
                           & obj_handle_withp(64)                    -- Over 31:24 (27:24 are zero)
                           & actag_p_q(3)                            -- Over 23:16
                           & (actag_p_q(2) xor intrp_req_cmd_flag_p) -- Over 15:8
                           & intrp_req_opcode(8);                    -- Over 7:0

  --------------------------------------------------------------------------------------------------
  -- BLock octword responses, "predict" template 5 for interrupt response.
  --------------------------------------------------------------------------------------------------
  tmpl5_flit_sub0_d <= (tmpl5_flit_sub1_q and triplet_state_advance and not (data_flit_xmit_int and low_lat_degrade_q)) OR
                       (tmpl5_flit_sub0_q and not (flit_buffer_reset and (tmpl5_next or not intrp_req_pend)));

  tmpl5_flit_sub1_d <= (tmpl5_flit_sub2_q and triplet_state_advance and not data_flit_xmit_int) OR
                       (tmpl5_intrp_opt_val_q and triplet_state_val_q and not tmpl5_flit_pend and intrp_req_pend and not lane_width_transition and not rd_resp_ow_pend_q and low_lat_degrade_q) or
                       (tmpl5_flit_sub1_q and not triplet_state_advance and not (data_flit_xmit_int and low_lat_degrade_q));

  tmpl5_flit_sub2_d <= (tmpl5_intrp_opt_val_q and
                        intrp_req_pend and
                        triplet_state_val_q and
                        not tmpl5_flit_pend and
                        not (low_lat_degrade_q or lane_width_transition) and 
                        not flit_buffer_reset and
                        not tmpl5 and
                        not (triplet_9dd_q and (NOT drl_prev_val_q OR triplet_9dd_drop_d OR triplet_9dd_drop_q or not (triplet_999_q and drl_1_in_pipe_q))) and
                        not (drl_2_in_pipe_q and not drl_prev_val_q) and
                        not rd_resp_ow_pend_q and
                        not (rdf_1st_32B_sub3_q or mmio_data_sub3_q or rdf_2nd_32B_sub3_q)) OR
                       (tmpl5_flit_sub2_q and not (triplet_state_advance and not data_flit_xmit_int));

  tmpl5_flit_pend <= tmpl5_flit_sub1_q or tmpl5_flit_sub0_q;

  tmpl5_intrp_opt_val_d <= tmpl_config(5) and not or_reduce(tmpl5_xmit_rate) and low_lat_mode;

  --optimized template 9 latch
  tmpl9_opt_val_d <= tmpl_config(9) and not or_reduce(tmpl9_xmit_rate);
  --------------------------------------------------------------------------------------------------
  --------------------------------------------------------------------------------------------------
  -- Optimize half-dimm mode interrupt requests.
  --------------------------------------------------------------------------------------------------
  tmpl0_flit_sub0_d <= (tmpl0_flit_sub1_q and flit_buffer_reset) OR
                       (tmpl0_flit_sub0_q and not (flit_buffer_reset and tmpl0_next));

  tmpl0_flit_sub1_d <= (not tmpl0_flit_sub1_q and intrp_req_pend and half_dimm_mode and not tmpl0 and not (rdf_40B_sub2_q or mmio_40B_sub2_q or tmpl0_flit_sub0_q)) OR
                       (tmpl0_flit_sub1_q and not flit_buffer_reset);

  tmpl0_flit_pend <= tmpl0_flit_sub1_q or tmpl0_flit_sub0_q;


  --------------------------------------------------------------------------------------------------
  --Interrupt Errors

  --fail response
  intrp_req_chan_xstop_failed <= ((intrp_req_chan_xstop_q = "011") or (intrp_req_chan_xstop_q = "100")) and (intrp_resp(1 downto 0) = "11");
  intrp_req_rec_attn_failed   <= ((intrp_req_rec_attn_q = "011") or (intrp_req_rec_attn_q = "100")) and (intrp_resp(3 downto 2) = "11");
  intrp_req_sp_attn_failed    <= ((intrp_req_sp_attn_q = "011") or (intrp_req_sp_attn_q = "100")) and (intrp_resp(5 downto 4) = "11");
  intrp_req_app_intrp_failed  <= ((intrp_req_app_intrp_q = "011") or (intrp_req_app_intrp_q = "100")) and (intrp_resp(7 downto 6) = "11");

  intrp_req_failed <= intrp_req_chan_xstop_failed or intrp_req_rec_attn_failed or intrp_req_sp_attn_failed or intrp_req_app_intrp_failed;

  --unexpected interrupt response
  unexp_chan_xstop_resp <= (intrp_req_chan_xstop_q < "011") and or_reduce(intrp_resp(1 downto 0));
  unexp_rec_attn_resp   <= (intrp_req_rec_attn_q < "011") and or_reduce(intrp_resp(3 downto 2));
  unexp_sp_attn_resp    <= (intrp_req_sp_attn_q < "011") and or_reduce(intrp_resp(5 downto 4));
  unexp_app_intrp_resp  <= (intrp_req_app_intrp_q < "011") and or_reduce(intrp_resp(7 downto 6));

  unexp_intrp_resp <= unexp_chan_xstop_resp or unexp_rec_attn_resp or unexp_sp_attn_resp or unexp_app_intrp_resp;
  --------------------------------------------------------------------------------------------------
  -- Assign acTag State Machine
  --Need a VC3 credit to send this. Hopefully send this credit after the correct registers have been
  --written
  --------------------------------------------------------------------------------------------------
  assign_actag_pend <=  ((actag_sent_q="01") or ((actag_sent_q="00") and or_reduce(actag_len_enab))) and tlx_vc3_avail;
  assign_actag_packed <= (actag_sent_q="10") or ((actag_sent_q="01") and assign_actag_pop);
  assign_actag_pop_d <= not assign_actag_pop_q and (actag_sent_q="01") and not (flit_xmit_start_pulse or flit_hold) and
                        (
                          ((tmplB or tmpl9 or tmpl5) and not tl_2sl_pkt_full_q) or
                          (tmpl1 and not flit_full_q) or
                          ((tmpl5 or tmpl0) and not tl_4sl_pkt_full_q)
                        );

  assign_actag_pop <= assign_actag_pop_q and tlx_vc3_avail and not (flit_hold or flit_full_q or (tl_2sl_pkt_full_q and not tmpl0) or tl_4sl_pkt_full_q);

  assign_actag_sent <= ((flit_buffer_reset and assign_actag_packed) or (actag_sent_q(1 downto 0)="11"));

  actag_sent_d(1 downto 0) <= gate("00",                not (assign_actag_pend or assign_actag_packed or assign_actag_sent)) OR
                              gate("01",                assign_actag_pend and not (assign_actag_packed or assign_actag_sent)) OR
                              gate("10",                assign_actag_packed and not assign_actag_sent) OR
                              gate("11",                assign_actag_sent);

  assign_actag_sent_d <= (not assign_actag_sent_q and (actag_sent_q="01") and assign_actag_pop) or
                         (assign_actag_sent_q);

  assign_actag_gate_d <= (not assign_actag_gate_q and not assign_actag_sent_q and or_reduce(actag_len_enab)) or
                         (assign_actag_gate_q and not assign_actag_sent_d);

  --just use the actag base
  actag_d(11 downto 0) <= actag_base(11 downto 0);
  -- 3:2 is parity when left aligned, 1:0 when right aligned within bytes
  actag_p_d(3 downto 0)<= XOR_REDUCE(actag_base(12) & actag_base(3 downto  0))  -- P over 11:4
                        & XOR_REDUCE(actag_base(12) & actag_base(11 downto 4))  -- P over 3:0
                        & XOR_REDUCE(actag_base(12) & actag_base(7 downto 0))   -- P over 11:8
                        & XOR_REDUCE(actag_base(12) & actag_base(11 downto 8)); -- P over 7:0

  --BDF(15 downto 0) Bus Num & DeviceNum & Device Function
  bdf(15 downto 0) <= busnum(7 downto 0) &
                      "00000" &                      --device
                      "001";                         -- function
  bdf_p            <= XOR_REDUCE(busnum(8)&busnum(3 downto 0))          -- over 15:12
                    & XOR_REDUCE(busnum(8)&busnum(7 downto 4)&"0000")   -- over 11:4
                    & '1';                                              -- over 3:0

  --use pasid base.
  pasid(19 downto 0) <= pasid_base(19 downto 0);
  pasid_p            <= XOR_REDUCE(pasid_base(20)&pasid_base(11 downto  0))                        -- over 19:12
                      & XOR_REDUCE(pasid_base(20)&pasid_base(19 downto 12)&pasid_base(3 downto 0)) -- over 11:4
                      & XOR_REDUCE(pasid_base(20)&pasid_base(19 downto  4));                       -- over 3:0

  assign_actag(55 downto 0) <= pasid(19 downto 0) &
                               bdf(15 downto 0) &
                               actag_q(11 downto 0) &
                               "01010000";

  assign_actag_p            <= pasid_p(2)                  -- pasid(19:12)
                             & pasid_p(1)                  -- pasid(11:4)
                             & (pasid_p(0) xor bdf_p(2))   -- pasid(3:0) bdf(15:12)
                             & bdf_p(1)                    -- bdf(11:4)
                             & (bdf_p(0) xor actag_p_q(1)) -- bdf(3:0) actag(11:8)
                             & actag_p_q(0)                -- actag(7:0)
                             & '0';                        -- opcode

  ------------------------------------------------------------------------------------------------
  -- Debug
  ------------------------------------------------------------------------------------------------

  flit_arb_debug_bus(0 to 87) <= flit_xmit_done                  --  0      -- from trans_arb
                               & data_xmit                       --  1      -- from trans_arb
                               & data_flit_xmit                  --  2      -- from trans_arb
                               & data_valid                      --  3      -- from trans_arb
                               & wr_resp_count(3 downto 0)       --  4:7
                               & mmio_resp_pend_q  --8
                               & intrp_req_pend
                               & (mmio_data_sub3_q or mmio_data_sub1_q or mmio_40B_sub2_q or mmio_data_flit_pend_q) --
                                 --able to determine which sets the bit given mode, degrade, template
                               & tmpl_current_dbg_q(4 downto 0)      -- 11:15   -- 5:4 not useful?
                               & rd_resp_count(5 downto 0)       -- 16:21
                               & data_run_length_q(3 downto 0)   -- 22:25   -- Max 2 actually used? (3:0)

                               & flit_pkt_cnt_q(3 downto 0)      -- 26:29   -- packing counts
                               & flit_rd_resp_q(3 downto 0)      -- 30:33   -- packing counts
                               & flit_wr_resp_q(3 downto 0)      -- 34:37   -- packing counts
                               & flit_mmio_resp_q(3 downto 0)    -- 38:41   -- packing counts
                               & flit_xmit_start_q             -- 42
                               & tl_2sl_pkt_full_q               -- 43
                               & tl_4sl_vld_q(1 downto 0)        -- 44:45

                               & drl_current(3 downto 0)         -- 46:49
                               & mmio_data_current               -- 50
                               & rdf_1st_32B_current             -- 51
                               & rdf_2nd_32B_current             -- 52
                               & rdf_data_current                -- 53
                               & bdi_vld_q(3 downto 0)           -- 54:57
                               & mmio_data_flit_del_q                -- 58
                               & rd_resp_len32_flit_del_q                 -- 59
                               & tmpl9_data_valid              -- 60
                               & data_flit_xmit_q                -- 61
                               & triplet_999_q                   -- 62
                               & triplet_9d9_q                   -- 63
                               & triplet_9dd_q                   -- 64
                               & triplet_9dd_drop_q  -- 65
                               & triplet_state_q(2 downto 0)     -- 66:68

                               & rd_resp_ow_pend_q               -- 69
                               & flit_credit_avail               -- 70      -- from trans_arb
                               & bypass_meta_fifo                -- 71
                               & ow_meta_pend_q                  -- 72
                               & ow_meta_packed_q                -- 73
                               & ow_meta_bypass_taken_q          -- 74
                               & ow_bdi_pend_q                   -- 75
                               & ow_bdi_packed_q                 -- 76
                               & bdi_bypass_taken_q              -- 77
                               & wr_resp_flush_q                 -- 78
                               & tl_4sl_pkt_full_q               -- 79
                               & low_lat_mode                     -- 80
                               & low_lat_degrade_q              -- 81
                               & half_dimm_mode                 --82
                               & init_complete_q                --83
                               & link_up                        --84
                               & rdf_1st_32B_sub3_q             --85
                               & rdf_2nd_32B_sub3_q             -- 86
                               & rdf_40B_sub2_q;                 --87

  flit_arb_debug_fedc(0 to 27)<= rd_idle                         --  0
                               & wr_resp_empty                   --  1
                               & wr_resp_pop                     --  2
                               & rd_resp_pop                     --  3
                               & rd_resp_ow_pop                  --  4
                               & mmio_resp_pop_int                   --  5
                               & fail_resp_pop                   --  6
                               & meta_fifo_pop                   --  7
                               & (tmpl5_dbg or tmpl9_dbg) & (tmpl1_dbg or tmpl9_dbg)     -- 8:9  00=0 01=1 10=5
                                                                                         -- 11=9 NO
                                                                                         -- TMPLB
                               & tl_4sl_pkt_full_q              --10
                               & tl_2sl_pkt_full_q              --11
                               & flit_credit_avail               -- 12
                               & flit_hold_1st                   -- 13
                               & flit_hold_2nd                   -- 14
                               & mmio_data_pending               -- 15
                               & tl_1sl_vld_q(3 downto 0)        -- 16:19
                               & tl_4sl_vld_q(1 downto 0)        -- 20:21
                               & flit_buffer_reset               -- 22
                               & flit_xmit_start_q             -- 23
                               & tlx_vc0_avail                   -- 24
                               & tlx_dcp0_avail                  -- 25
                               & wr_resp_flush_q                 -- 26
                               & data_valid;                     -- 27

  --------------------------------------------------------------------------------------------------
  -- ERROR
  --------------------------------------------------------------------------------------------------
  tlxt_err_fifo_CE <= rd_resp_CE or wr_resp_CE or mmio_resp_CE or fail_resp_CE or meta_fifo_CE;
  tlxt_err_fifo_UE(0) <= meta_fifo_UE;
  tlxt_err_fifo_UE(1) <= rd_resp_UE;
  tlxt_err_fifo_UE(2) <= wr_resp_UE;
  tlxt_err_fifo_UE(3) <= mmio_resp_UE;
  tlxt_err_fifo_UE(4) <= fail_resp_UE;

  tlxt_fifo_overflow(0) <= (rd_resp_fifo_err="10");
  tlxt_fifo_overflow(1) <= (wr_resp_fifo_err="10");
  tlxt_fifo_overflow(2) <= (meta_fifo_err="10");
  tlxt_fifo_overflow(3) <= (fail_resp_fifo_err="10");
  tlxt_fifo_overflow(4) <= (bdi_err="10");

  tlxt_fifo_underflow(0) <= (rd_resp_fifo_err="01");
  tlxt_fifo_underflow(1) <= (wr_resp_fifo_err="01");
  tlxt_fifo_underflow(2) <= (meta_fifo_err="01");
  tlxt_fifo_underflow(3) <= (fail_resp_fifo_err="01");
  tlxt_fifo_underflow(4) <= (bdi_err="01");

  tlxt_fifo_ptr_perr(0) <= and_reduce(rd_resp_fifo_err);
  tlxt_fifo_ptr_perr(1) <= and_reduce(wr_resp_fifo_err);
  tlxt_fifo_ptr_perr(2) <= and_reduce(meta_fifo_err);
  tlxt_fifo_ptr_perr(3) <= and_reduce(fail_resp_fifo_err);
  tlxt_fifo_ptr_perr(4) <= and_reduce(bdi_err);

  -- Every cycle parity checking on counters

  flit_arb_perrors(0) <= XOR_REDUCE(flit_rd_resp_p_q     & flit_rd_resp_q(3 downto 0)    )
                      or XOR_REDUCE(flit_wr_resp_p_q     & flit_wr_resp_q(3 downto 0)    )
                      or XOR_REDUCE(flit_mmio_resp_p_q   & flit_mmio_resp_q(3 downto 0)  );
  flit_arb_perrors(1) <= XOR_REDUCE(tl_1sl_vld_p_q       & tl_1sl_vld_q                  )
                      or XOR_REDUCE(tl_4sl_vld_p_q       & tl_4sl_vld_q                  );
  flit_arb_perrors(2) <= XOR_REDUCE(bdi_vld_p_q          & bdi_vld_q(3 downto 0)         )
                      or XOR_REDUCE(mf_vld_p_q           & mf_vld_q(2 downto 0)          );
  flit_arb_perrors(3) <= XOR_REDUCE(drl_high_lat_p_q     & drl_high_lat_q(3 downto 0)    )
                      or XOR_REDUCE(data_run_length_p_q  & data_run_length_q             )
                      or XOR_REDUCE(drl_sub0_p_q         & drl_sub0_q(3 downto 0)        )
                      or XOR_REDUCE(drl_sub1_p_q         & drl_sub1_q(3 downto 0)        )
                      or XOR_REDUCE(drl_sub2_p_q         & drl_sub2_q(3 downto 0)        )
                      or XOR_REDUCE(drl_sub3_p_q         & drl_sub3_q(3 downto 0)        )
                      or XOR_REDUCE(mmio_drl_p_q         & mmio_drl_q(3 downto 0)        );
  flit_arb_perrors(4) <= XOR_REDUCE(flit_pkt_cnt_p_q     & flit_pkt_cnt_q(3 downto 0)    );
  flit_arb_perrors(5) <= (tmpl_current_q(0) and tmpl_current_q(1)) or
                         (tmpl_current_q(0) and tmpl_current_q(2)) or
                         (tmpl_current_q(0) and tmpl_current_q(3)) or
                         (tmpl_current_q(0) and tmpl_current_q(4)) or
                         (tmpl_current_q(1) and tmpl_current_q(2)) or
                         (tmpl_current_q(1) and tmpl_current_q(3)) or
                         (tmpl_current_q(1) and tmpl_current_q(4)) or
                         (tmpl_current_q(2) and tmpl_current_q(3)) or
                         (tmpl_current_q(2) and tmpl_current_q(4)) or
                         (tmpl_current_q(3) and tmpl_current_q(4)) or
                         (not or_reduce(tmpl_current_q) and link_up) or
                         (or_reduce(tmpl_current_q) and not link_up);
  flit_arb_perrors(6) <= XOR_REDUCE(idle_crd_ret_tmr_p_q & idle_crd_ret_tmr_q(5 downto 0));

  flit_arb_perrors(7) <= (triplet_state_q(2) and triplet_state_q(1)) -- 0-hot or 1-hot FSM
                      or (triplet_state_q(2) and triplet_state_q(0))
                      or (triplet_state_q(1) and triplet_state_q(0));

  --Credit Loss Error
  crd_ret_sent_sl_12 <= tmplB and flit_xmit_start_t2_q and flit_credit_avail and (flit_buffer_2nd_half_q(87 downto 80)="00001000");
  crd_ret_sent_sl_10 <= tmpl9 and flit_xmit_start_t2_q and flit_credit_avail and (flit_buffer_2nd_half_q(31 downto 24)="00001000");
  crd_ret_sent_sl_0 <= not (tmpl9 or tmplB) and flit_xmit_start_q and flit_credit_avail and (flit_buffer_1st_half_q(7 downto 0)="00001000");

  crd_ret_packed_d <= (not crd_ret_packed_q and tlxt_tlxc_crd_ret_taken_int) or
                      (crd_ret_packed_q and not flit_buffer_reset);

  tlxt_err_invalid_crd_ret <= not crd_ret_packed_q and (crd_ret_sent_sl_12 or crd_ret_sent_sl_10 or crd_ret_sent_sl_0);
  tlxt_err_dropped_crd_ret <= crd_ret_packed_d and not crd_ret_packed_q and flit_xmit_start_t2_q and flit_credit_avail;

  --Invalid Config Error
  tlxt_err_invalid_cfg_d <= (mid_bw_enab and hi_bw_enab_rd_thresh) and not rd_resp_empty_q;
  tlxt_err_invalid_cfg <= tlxt_err_invalid_cfg_q;

  --invalid template configuration
  tlxt_err_invalid_tmpl_cfg_d <= intrp_req_pend and not (tmpl_config(0) or tmpl_config(1) or tmpl_config(5));
  tlxt_err_invalid_tmpl_cfg <= tlxt_err_invalid_tmpl_cfg_q;
  --Invalid Metadata Config
  tlxt_err_invalid_meta_cfg_d <= metadata_enabled and not (tmpl_config(5) or tmpl_config(9)) and not rd_resp_empty_q;
  tlxt_err_invalid_meta_cfg <= tlxt_err_invalid_meta_cfg_q;

  --Read Error Stall
  rd_resp_unrec_stall_d <= (not rd_resp_unrec_stall_q and rd_resp_UE) OR
                           (NOT rd_resp_unrec_stall_q AND or_reduce(rd_resp_fifo_err)) or
                           (NOT rd_resp_unrec_stall_q and xstop_rd_gate) or 
                           (rd_resp_unrec_stall_q);

  wr_resp_unrec_stall_d <= (NOT wr_resp_unrec_stall_q AND or_reduce(wr_resp_fifo_err)) OR
                           (wr_resp_unrec_stall_q);

  fail_resp_unrec_stall_d <= (NOT fail_resp_unrec_stall_q AND or_reduce(fail_resp_fifo_err)) OR
                             (fail_resp_unrec_stall_q);

  meta_fifo_unrec_d <= (or_reduce(meta_fifo_err)) or
                       meta_fifo_unrec_q;

  bdi_fifo_unrec_d <= or_reduce(bdi_err) or
                      bdi_fifo_unrec_q;






actagq: entity latches.c_morph_dff
  generic map (width => 12, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => actag_d(11 downto 0),
           syncr                => syncr,
           q                    => actag_q(11 downto 0));

actag_pq: entity latches.c_morph_dff
  generic map (width => 4, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => actag_p_d(3 downto 0),
           syncr                => syncr,
           q                    => actag_p_q(3 downto 0));

actag_sentq: entity latches.c_morph_dff
  generic map (width => 2, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => actag_sent_d(1 downto 0),
           syncr                => syncr,
           q                    => actag_sent_q(1 downto 0));

assign_actag_popq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(assign_actag_pop_d),
           syncr                => syncr,
           Tconv(q)             => assign_actag_pop_q);

assign_actag_sentq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(assign_actag_sent_d),
           syncr                => syncr,
           Tconv(q)             => assign_actag_sent_q);

assign_actag_gateq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(assign_actag_gate_d),
           syncr                => syncr,
           Tconv(q)             => assign_actag_gate_q);

bdi_bypass_takenq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act_low_lat_mode,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(bdi_bypass_taken_d),
           syncr                => syncr,
           Tconv(q)             => bdi_bypass_taken_q);

bdi_maxq: entity latches.c_morph_dff
  generic map (width => 4, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => bdi_max_d(3 downto 0),
           syncr                => syncr,
           q                    => bdi_max_q(3 downto 0));

bdi_fifo_emptyq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(bdi_fifo_empty_d),
           syncr                => syncr,
           Tconv(q)             => bdi_fifo_empty_q);

bdi_fifo_unrecq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(bdi_fifo_unrec_d),
           syncr                => syncr,
           Tconv(q)             => bdi_fifo_unrec_q);

bdi_vecq: entity latches.c_morph_dff
  generic map (width => 8, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => bdi_vec_d(7 downto 0),
           syncr                => syncr,
           q                    => bdi_vec_q(7 downto 0));

bdi_vec_pq: entity latches.c_morph_dff
  generic map (width => 2, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => bdi_vec_p_d(1 downto 0),
           syncr                => syncr,
           q                    => bdi_vec_p_q(1 downto 0));

bdi_vldq: entity latches.c_morph_dff
  generic map (width => 4, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => bdi_vld_d(3 downto 0),
           syncr                => syncr,
           q                    => bdi_vld_q(3 downto 0));

bdi_vld_pq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(bdi_vld_p_d),
           syncr                => syncr,
           Tconv(q)             => bdi_vld_p_q);

crd_ret_packedq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(crd_ret_packed_d),
           syncr                => syncr,
           Tconv(q)             => crd_ret_packed_q);

crd_ret_takenq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(crd_ret_taken_d),
           syncr                => syncr,
           Tconv(q)             => crd_ret_taken_q);

dat_bts_pendq: entity latches.c_morph_dff
  generic map (width => 7, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => dat_bts_pend_d(6 downto 0),
           syncr                => syncr,
           q                    => dat_bts_pend_q(6 downto 0));

data_flit_xmitq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(data_flit_xmit_d),
           syncr                => syncr,
           Tconv(q)             => data_flit_xmit_q);

data_flit_cntq: entity latches.c_morph_dff
  generic map (width => 8, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => data_flit_cnt_d(7 downto 0),
           syncr                => syncr,
           q                    => data_flit_cnt_q(7 downto 0));

data_run_lengthq: entity latches.c_morph_dff
  generic map (width => 4, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => data_run_length_d(3 downto 0),
           syncr                => syncr,
           q                    => data_run_length_q(3 downto 0));

data_run_length_pq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(data_run_length_p_d),
           syncr                => syncr,
           Tconv(q)             => data_run_length_p_q);

dl_cont_tl_tmplq: entity latches.c_morph_dff
  generic map (width => 6, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => dl_cont_tl_tmpl_d(5 downto 0),
           syncr                => syncr,
           q                    => dl_cont_tl_tmpl_q(5 downto 0));

dl_cont_tl_tmpl_pq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(dl_cont_tl_tmpl_p_d),
           syncr                => syncr,
           Tconv(q)             => dl_cont_tl_tmpl_p_q);

drl_1_in_pipeq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act_low_lat_mode,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(drl_1_in_pipe_d),
           syncr                => syncr,
           Tconv(q)             => drl_1_in_pipe_q);

drl_2_in_pipeq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act_low_lat_mode,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(drl_2_in_pipe_d),
           syncr                => syncr,
           Tconv(q)             => drl_2_in_pipe_q);

drl_high_latq: entity latches.c_morph_dff
  generic map (width => 4, offset => 0)
  port map(gckn                 => gckn,
           e                    => act_hi_lat_mode,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => drl_high_lat_d(3 downto 0),
           syncr                => syncr,
           q                    => drl_high_lat_q(3 downto 0));

drl_high_lat_pq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act_hi_lat_mode,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(drl_high_lat_p_d),
           syncr                => syncr,
           Tconv(q)             => drl_high_lat_p_q);

drl_prev_valq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act_low_lat_mode,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(drl_prev_val_d),
           syncr                => syncr,
           Tconv(q)             => drl_prev_val_q);

drl_sub0q: entity latches.c_morph_dff
  generic map (width => 4, offset => 0)
  port map(gckn                 => gckn,
           e                    => act_low_lat_mode,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => drl_sub0_d(3 downto 0),
           syncr                => syncr,
           q                    => drl_sub0_q(3 downto 0));

drl_sub0_pq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act_low_lat_mode,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(drl_sub0_p_d),
           syncr                => syncr,
           Tconv(q)             => drl_sub0_p_q);

drl_sub1q: entity latches.c_morph_dff
  generic map (width => 4, offset => 0)
  port map(gckn                 => gckn,
           e                    => act_low_lat_mode,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => drl_sub1_d(3 downto 0),
           syncr                => syncr,
           q                    => drl_sub1_q(3 downto 0));

drl_sub1_pq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act_low_lat_mode,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(drl_sub1_p_d),
           syncr                => syncr,
           Tconv(q)             => drl_sub1_p_q);

drl_sub1_valq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act_low_lat_mode,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(drl_sub1_val_d),
           syncr                => syncr,
           Tconv(q)             => drl_sub1_val_q);

drl_sub2q: entity latches.c_morph_dff
  generic map (width => 4, offset => 0)
  port map(gckn                 => gckn,
           e                    => act_low_lat_mode,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => drl_sub2_d(3 downto 0),
           syncr                => syncr,
           q                    => drl_sub2_q(3 downto 0));

drl_sub2_pq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act_low_lat_mode,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(drl_sub2_p_d),
           syncr                => syncr,
           Tconv(q)             => drl_sub2_p_q);

drl_sub2_valq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act_low_lat_mode,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(drl_sub2_val_d),
           syncr                => syncr,
           Tconv(q)             => drl_sub2_val_q);

drl_sub3q: entity latches.c_morph_dff
  generic map (width => 4, offset => 0)
  port map(gckn                 => gckn,
           e                    => act_low_lat_mode,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => drl_sub3_d(3 downto 0),
           syncr                => syncr,
           q                    => drl_sub3_q(3 downto 0));

drl_sub3_pq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act_low_lat_mode,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(drl_sub3_p_d),
           syncr                => syncr,
           Tconv(q)             => drl_sub3_p_q);

fail_resp_emptyq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(fail_resp_empty_d),
           syncr                => syncr,
           Tconv(q)             => fail_resp_empty_q);

fail_resp_popq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(fail_resp_pop_d),
           syncr                => syncr,
           Tconv(q)             => fail_resp_pop_q);

fail_resp_flushq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(fail_resp_flush_d),
           syncr                => syncr,
           Tconv(q)             => fail_resp_flush_q);

fail_resp_unrec_stallq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act_low_lat_mode,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(fail_resp_unrec_stall_d),
           syncr                => syncr,
           Tconv(q)             => fail_resp_unrec_stall_q);

flit_buffer_1st_halfq: entity latches.c_morph_dff
  generic map (width => 256, offset => 0)
  port map(gckn                 => gckn,
           e                    => act_flit_buf_1st_half,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => flit_buffer_1st_half_d(255 downto 0),
           syncr                => syncr,
           q                    => flit_buffer_1st_half_q(255 downto 0));

flit_buffer_1st_half_pq: entity latches.c_morph_dff
  generic map (width => 32, offset => 0)
  port map(gckn                 => gckn,
           e                    => act_flit_buf_1st_half,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => flit_buffer_1st_half_p_d(31 downto 0),
           syncr                => syncr,
           q                    => flit_buffer_1st_half_p_q(31 downto 0));

flit_buffer_2nd_halfq: entity latches.c_morph_dff
  generic map (width => 192, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => flit_buffer_2nd_half_d(191 downto 0),
           syncr                => syncr,
           q                    => flit_buffer_2nd_half_q(191 downto 0));

flit_buffer_2nd_half_pq: entity latches.c_morph_dff
  generic map (width => 24, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => flit_buffer_2nd_half_p_d(23 downto 0),
           syncr                => syncr,
           q                    => flit_buffer_2nd_half_p_q(23 downto 0));

flit_fullq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(flit_full_d),
           syncr                => syncr,
           Tconv(q)             => flit_full_q);

flit_mmio_respq: entity latches.c_morph_dff
  generic map (width => 4, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => flit_mmio_resp_d(3 downto 0),
           syncr                => syncr,
           q                    => flit_mmio_resp_q(3 downto 0));

flit_mmio_resp_pq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(flit_mmio_resp_p_d),
           syncr                => syncr,
           Tconv(q)             => flit_mmio_resp_p_q);

flit_pkt_cntq: entity latches.c_morph_dff
  generic map (width => 4, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => flit_pkt_cnt_d(3 downto 0),
           syncr                => syncr,
           q                    => flit_pkt_cnt_q(3 downto 0));

flit_pkt_cnt_pq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(flit_pkt_cnt_p_d),
           syncr                => syncr,
           Tconv(q)             => flit_pkt_cnt_p_q);

flit_rd_respq: entity latches.c_morph_dff
  generic map (width => 4, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => flit_rd_resp_d(3 downto 0),
           syncr                => syncr,
           q                    => flit_rd_resp_q(3 downto 0));

flit_rd_resp_pq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(flit_rd_resp_p_d),
           syncr                => syncr,
           Tconv(q)             => flit_rd_resp_p_q);

flit_wr_respq: entity latches.c_morph_dff
  generic map (width => 4, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => flit_wr_resp_d(3 downto 0),
           syncr                => syncr,
           q                    => flit_wr_resp_q(3 downto 0));

flit_wr_resp_pq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(flit_wr_resp_p_d),
           syncr                => syncr,
           Tconv(q)             => flit_wr_resp_p_q);

flit_xmit_doneq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(flit_xmit_done_d),
           syncr                => syncr,
           Tconv(q)             => flit_xmit_done_q);

flit_xmit_startq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(flit_xmit_start_d),
           syncr                => syncr,
           Tconv(q)             => flit_xmit_start_q);

flit_xmit_start_t1q: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(flit_xmit_start_t1_d),
           syncr                => syncr,
           Tconv(q)             => flit_xmit_start_t1_q);

flit_xmit_start_t2q: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(flit_xmit_start_t2_d),
           syncr                => syncr,
           Tconv(q)             => flit_xmit_start_t2_q);

flit_xmit_start_t2_del_pulseq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(flit_xmit_start_t2_del_pulse_d),
           syncr                => syncr,
           Tconv(q)             => flit_xmit_start_t2_del_pulse_q);

flit_xmit_start_t3q: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(flit_xmit_start_t3_d),
           syncr                => syncr,
           Tconv(q)             => flit_xmit_start_t3_q);

flit_xmit_start_t4q: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(flit_xmit_start_t4_d),
           syncr                => syncr,
           Tconv(q)             => flit_xmit_start_t4_q);

flit_xmit_start_t5q: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(flit_xmit_start_t5_d),
           syncr                => syncr,
           Tconv(q)             => flit_xmit_start_t5_q);

flit_xmit_start_t6q: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(flit_xmit_start_t6_d),
           syncr                => syncr,
           Tconv(q)             => flit_xmit_start_t6_q);

flit_xmit_start_t7q: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(flit_xmit_start_t7_d),
           syncr                => syncr,
           Tconv(q)             => flit_xmit_start_t7_q);

hi_lat_start_delq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act_hi_lat_mode,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(hi_lat_start_del_d),
           syncr                => syncr,
           Tconv(q)             => hi_lat_start_del_q);

idle_crd_ret_delq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(idle_crd_ret_del_d),
           syncr                => syncr,
           Tconv(q)             => idle_crd_ret_del_q);

idle_crd_ret_tmrq: entity latches.c_morph_dff
  generic map (width => 6, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => idle_crd_ret_tmr_d(5 downto 0),
           syncr                => syncr,
           q                    => idle_crd_ret_tmr_q(5 downto 0));

idle_crd_ret_tmr_pq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(idle_crd_ret_tmr_p_d),
           syncr                => syncr,
           Tconv(q)             => idle_crd_ret_tmr_p_q);

init_completeq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act_init_cred_ret,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(init_complete_d),
           syncr                => syncr,
           Tconv(q)                    => init_complete_q);

init_cred_ret_completeq: entity latches.c_morph_dff
  generic map (width => 2, offset => 0)
  port map(gckn                 => gckn,
           e                    => act_init_cred_ret,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => init_cred_ret_complete_d(1 downto 0),
           syncr                => syncr,
           q                    => init_cred_ret_complete_q(1 downto 0));

intrp_req_popq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(intrp_req_pop_d),
           syncr                => syncr,
           Tconv(q)             => intrp_req_pop_q);

intrp_req_app_intrp_missed_edgeq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(intrp_req_app_intrp_missed_edge_d),
           syncr                => syncr,
           Tconv(q)             => intrp_req_app_intrp_missed_edge_q);

intrp_req_chan_xstop_missed_edgeq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(intrp_req_chan_xstop_missed_edge_d),
           syncr                => syncr,
           Tconv(q)             => intrp_req_chan_xstop_missed_edge_q);

intrp_req_rec_attn_missed_edgeq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(intrp_req_rec_attn_missed_edge_d),
           syncr                => syncr,
           Tconv(q)             => intrp_req_rec_attn_missed_edge_q);

intrp_req_sp_attn_missed_edgeq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(intrp_req_sp_attn_missed_edge_d),
           syncr                => syncr,
           Tconv(q)             => intrp_req_sp_attn_missed_edge_q);

intrp_req_app_intrp_pq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(intrp_req_app_intrp_p_d),
           syncr                => syncr,
           Tconv(q)             => intrp_req_app_intrp_p_q);

intrp_req_chan_xstop_pq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(intrp_req_chan_xstop_p_d),
           syncr                => syncr,
           Tconv(q)             => intrp_req_chan_xstop_p_q);

intrp_req_rec_attn_pq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(intrp_req_rec_attn_p_d),
           syncr                => syncr,
           Tconv(q)             => intrp_req_rec_attn_p_q);

intrp_req_sp_attn_pq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(intrp_req_sp_attn_p_d),
           syncr                => syncr,
           Tconv(q)             => intrp_req_sp_attn_p_q);

intrp_req_app_intrpq: entity latches.c_morph_dff
  generic map (width => 3, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => intrp_req_app_intrp_d(2 downto 0),
           syncr                => syncr,
           q                    => intrp_req_app_intrp_q(2 downto 0));

intrp_req_chan_xstopq: entity latches.c_morph_dff
  generic map (width => 3, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => intrp_req_chan_xstop_d(2 downto 0),
           syncr                => syncr,
           q                    => intrp_req_chan_xstop_q(2 downto 0));

intrp_req_rec_attnq: entity latches.c_morph_dff
  generic map (width => 3, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => intrp_req_rec_attn_d(2 downto 0),
           syncr                => syncr,
           q                    => intrp_req_rec_attn_q(2 downto 0));

intrp_req_sp_attnq: entity latches.c_morph_dff
  generic map (width => 3, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => intrp_req_sp_attn_d(2 downto 0),
           syncr                => syncr,
           q                    => intrp_req_sp_attn_q(2 downto 0));

meta_fifo_emptyq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(meta_fifo_empty_d),
           syncr                => syncr,
           Tconv(q)             => meta_fifo_empty_q);

meta_fifo_unrecq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(meta_fifo_unrec_d),
           syncr                => syncr,
           Tconv(q)             => meta_fifo_unrec_q);

meta_ue_poison_nextq: entity latches.c_morph_dff
  generic map (width => 8, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => meta_ue_poison_next_d(7 downto 0),
           syncr                => syncr,
           q                    => meta_ue_poison_next_q(7 downto 0));

meta_ue_poison_currq: entity latches.c_morph_dff
  generic map (width => 8, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => meta_ue_poison_curr_d(7 downto 0),
           syncr                => syncr,
           q                    => meta_ue_poison_curr_q(7 downto 0));

meta_vecq: entity latches.c_morph_dff
  generic map (width => 56, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => meta_vec_d(55 downto 0),
           syncr                => syncr,
           q                    => meta_vec_q(55 downto 0));

meta_vec_pq: entity latches.c_morph_dff
  generic map (width => 7, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => meta_vec_p_d(6 downto 0),
           syncr                => syncr,
           q                    => meta_vec_p_q(6 downto 0));

mf_vldq: entity latches.c_morph_dff
  generic map (width => 3, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => mf_vld_d(2 downto 0),
           syncr                => syncr,
           q                    => mf_vld_q(2 downto 0));

mf_vld_pq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(mf_vld_p_d),
           syncr                => syncr,
           Tconv(q)             => mf_vld_p_q);

mmio_bdiq: entity latches.c_morph_dff
  generic map (width => 2, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => mmio_bdi_d(1 downto 0),
           syncr                => syncr,
           q                    => mmio_bdi_q(1 downto 0));

mmio_data_bufferq: entity latches.c_morph_dff
  generic map (width => 256, offset => 0)
  port map(gckn                 => gckn,
           e                    => act_mmio_buf,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => mmio_data_buffer_d(255 downto 0),
           syncr                => syncr,
           q                    => mmio_data_buffer_q(255 downto 0));

mmio_data_buffer_pq: entity latches.c_morph_dff
  generic map (width => 32, offset => 0)
  port map(gckn                 => gckn,
           e                    => act_mmio_buf,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => mmio_data_buffer_p_d(31 downto 0),
           syncr                => syncr,
           q                    => mmio_data_buffer_p_q(31 downto 0));

mmio_data_flitq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(mmio_data_flit_d),
           syncr                => syncr,
           Tconv(q)             => mmio_data_flit_q);

mmio_data_flit_delq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(mmio_data_flit_del_d),
           syncr                => syncr,
           Tconv(q)             => mmio_data_flit_del_q);

mmio_data_flit_pendq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(mmio_data_flit_pend_d),
           syncr                => syncr,
           Tconv(q)             => mmio_data_flit_pend_q);

mmio_40B_sub0q: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(mmio_40B_sub0_d),
           syncr                => syncr,
           Tconv(q)             => mmio_40B_sub0_q);

mmio_40B_sub1q: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act_half_dimm,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(mmio_40B_sub1_d),
           syncr                => syncr,
           Tconv(q)             => mmio_40B_sub1_q);

mmio_40B_sub2q: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act_half_dimm,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(mmio_40B_sub2_d),
           syncr                => syncr,
           Tconv(q)             => mmio_40B_sub2_q);

mmio_data_sub0q: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(mmio_data_sub0_d),
           syncr                => syncr,
           Tconv(q)             => mmio_data_sub0_q);

mmio_data_sub1q: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(mmio_data_sub1_d),
           syncr                => syncr,
           Tconv(q)             => mmio_data_sub1_q);

mmio_data_sub2q: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act_low_lat_mode,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(mmio_data_sub2_d),
           syncr                => syncr,
           Tconv(q)             => mmio_data_sub2_q);

mmio_data_sub3q: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act_low_lat_mode,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(mmio_data_sub3_d),
           syncr                => syncr,
           Tconv(q)             => mmio_data_sub3_q);

--mmio_data_valq: entity latches.c_morph_dff
--  generic map (width => 1, offset => 0)
--  port map(gckn                 => gckn,
--           e                    => act,
--           vdd                  => vdd,
--           vss                  => gnd,
--           d                    => Tconv(mmio_data_val_d),
--           syncr                => syncr,
--           Tconv(q)             => mmio_data_val_q);

mmio_drlq: entity latches.c_morph_dff
  generic map (width => 4, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => mmio_drl_d(3 downto 0),
           syncr                => syncr,
           q                    => mmio_drl_q(3 downto 0));

mmio_drl_pq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(mmio_drl_p_d),
           syncr                => syncr,
           Tconv(q)             => mmio_drl_p_q);

mmio_ow_bdiq: entity latches.c_morph_dff
  generic map (width => 2, offset => 0)
  port map(gckn                 => gckn,
           e                    => act_low_lat_mode,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => mmio_ow_bdi_d(1 downto 0),
           syncr                => syncr,
           q                    => mmio_ow_bdi_q(1 downto 0));

mmio_resp_pendq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(mmio_resp_pend_d),
           syncr                => syncr,
           Tconv(q)             => mmio_resp_pend_q);

mmio_respq: entity latches.c_morph_dff
  generic map (width => 24, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => mmio_resp_d(23 downto 0),
           syncr                => syncr,
           q                    => mmio_resp_q(23 downto 0));

flit_cyc_cntq: entity latches.c_morph_dff
  generic map (width => 5, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => flit_cyc_cnt_d(4 downto 0),
           syncr                => syncr,
           q                    => flit_cyc_cnt_q(4 downto 0));

null_flit_nextq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(null_flit_next_d),
           syncr                => syncr,
           Tconv(q)             => null_flit_next_q);

non_main_gateq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(non_main_gate_d),
           syncr                => syncr,
           Tconv(q)             => non_main_gate_q);

non_crit_startq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(non_crit_start_d),
           syncr                => syncr,
           Tconv(q)             => non_crit_start_q);

ow_bdi_bufferq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act_low_lat_mode,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(ow_bdi_buffer_d),
           syncr                => syncr,
           Tconv(q)             => ow_bdi_buffer_q);

ow_bdi_packedq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(ow_bdi_packed_d),
           syncr                => syncr,
           Tconv(q)             => ow_bdi_packed_q);

ow_bdi_pendq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act_low_lat_mode,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(ow_bdi_pend_d),
           syncr                => syncr,
           Tconv(q)             => ow_bdi_pend_q);

ow_meta_bufferq: entity latches.c_morph_dff
  generic map (width => 6, offset => 0)
  port map(gckn                 => gckn,
           e                    => act_low_lat_mode,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => ow_meta_buffer_d(5 downto 0),
           syncr                => syncr,
           q                    => ow_meta_buffer_q(5 downto 0));

ow_meta_buffer_pq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act_low_lat_mode,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(ow_meta_buffer_p_d),
           syncr                => syncr,
           Tconv(q)             => ow_meta_buffer_p_q);

ow_meta_bypass_takenq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act_low_lat_mode,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(ow_meta_bypass_taken_d),
           syncr                => syncr,
           Tconv(q)             => ow_meta_bypass_taken_q);

ow_meta_packedq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(ow_meta_packed_d),
           syncr                => syncr,
           Tconv(q)             => ow_meta_packed_q);

ow_meta_pendq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act_low_lat_mode,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(ow_meta_pend_d),
           syncr                => syncr,
           Tconv(q)             => ow_meta_pend_q);

rd_pend_gateq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act_low_lat_mode,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(rd_pend_gate_d),
           syncr                => syncr,
           Tconv(q)             => rd_pend_gate_q);

rd_resp_len32_flitq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(rd_resp_len32_flit_d),
           syncr                => syncr,
           Tconv(q)             => rd_resp_len32_flit_q);

rd_resp_len32_flit_delq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(rd_resp_len32_flit_del_d),
           syncr                => syncr,
           Tconv(q)             => rd_resp_len32_flit_del_q);

rd_resp_len32_flit_pendq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(rd_resp_len32_flit_pend_d),
           syncr                => syncr,
           Tconv(q)             => rd_resp_len32_flit_pend_q);

rd_resp_exit0_gateq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act_low_lat_mode,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(rd_resp_exit0_gate_d),
           syncr                => syncr,
           Tconv(q)             => rd_resp_exit0_gate_q);

rd_resp_emptyq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(rd_resp_empty_d),
           syncr                => syncr,
           Tconv(q)             => rd_resp_empty_q);

rd_resp_exit0_blockq: entity latches.c_morph_dff
  generic map (width => 3, offset => 0)
  port map(gckn                 => gckn,
           e                    => act_low_lat_mode,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => rd_resp_exit0_block_d(2 downto 0),
           syncr                => syncr,
           q                    => rd_resp_exit0_block_q(2 downto 0));

rd_resp_half_dimm_stallq: entity latches.c_morph_dff
  generic map (width => 4, offset => 0)
  port map(gckn                 => gckn,
           e                    => act_half_dimm,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => rd_resp_half_dimm_stall_d(3 downto 0),
           syncr                => syncr,
           q                    => rd_resp_half_dimm_stall_q(3 downto 0));

rd_resp_half_dimm_stall_oneq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act_half_dimm,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(rd_resp_half_dimm_stall_one_d),
           syncr                => syncr,
           Tconv(q)             => rd_resp_half_dimm_stall_one_q);

rd_resp_low_lat_stallq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act_low_lat_mode,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(rd_resp_low_lat_stall_d),
           syncr                => syncr,
           Tconv(q)             => rd_resp_low_lat_stall_q);

rd_resp_ow_bufq: entity latches.c_morph_dff
  generic map (width => 28, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => rd_resp_ow_buf_d(27 downto 0),
           syncr                => syncr,
           q                    => rd_resp_ow_buf_q(27 downto 0));

rd_resp_ow_buf_pq: entity latches.c_morph_dff
  generic map (width => 8, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => rd_resp_ow_buf_p_d(7 downto 0),
           syncr                => syncr,
           q                    => rd_resp_ow_buf_p_q(7 downto 0));

rd_resp_ow_pendq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(rd_resp_ow_pend_d),
           syncr                => syncr,
           Tconv(q)             => rd_resp_ow_pend_q);

rd_resp_unrec_stallq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(rd_resp_unrec_stall_d),
           syncr                => syncr,
           Tconv(q)             => rd_resp_unrec_stall_q);

rdf_1st_32B_sub0q: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(rdf_1st_32B_sub0_d),
           syncr                => syncr,
           Tconv(q)             => rdf_1st_32B_sub0_q);

rdf_1st_32B_sub1q: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(rdf_1st_32B_sub1_d),
           syncr                => syncr,
           Tconv(q)             => rdf_1st_32B_sub1_q);

rdf_1st_32B_sub2q: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act_low_lat_mode,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(rdf_1st_32B_sub2_d),
           syncr                => syncr,
           Tconv(q)             => rdf_1st_32B_sub2_q);

rdf_1st_32B_sub3q: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act_low_lat_mode,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(rdf_1st_32B_sub3_d),
           syncr                => syncr,
           Tconv(q)             => rdf_1st_32B_sub3_q);

rdf_2nd_32B_sub0q: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act_low_lat_mode,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(rdf_2nd_32B_sub0_d),
           syncr                => syncr,
           Tconv(q)             => rdf_2nd_32B_sub0_q);

rdf_2nd_32B_sub1q: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act_low_lat_mode,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(rdf_2nd_32B_sub1_d),
           syncr                => syncr,
           Tconv(q)             => rdf_2nd_32B_sub1_q);

rdf_2nd_32B_sub2q: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act_low_lat_mode,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(rdf_2nd_32B_sub2_d),
           syncr                => syncr,
           Tconv(q)             => rdf_2nd_32B_sub2_q);

rdf_2nd_32B_sub3q: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act_low_lat_mode,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(rdf_2nd_32B_sub3_d),
           syncr                => syncr,
           Tconv(q)             => rdf_2nd_32B_sub3_q);

rdf_40B_sub0q: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act_half_dimm,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(rdf_40B_sub0_d),
           syncr                => syncr,
           Tconv(q)             => rdf_40B_sub0_q);

rdf_40B_sub1q: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act_half_dimm,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(rdf_40B_sub1_d),
           syncr                => syncr,
           Tconv(q)             => rdf_40B_sub1_q);

rdf_40B_sub2q: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act_half_dimm,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(rdf_40B_sub2_d),
           syncr                => syncr,
           Tconv(q)             => rdf_40B_sub2_q);

rdf_tlxt_data_errq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(rdf_tlxt_data_err_d),
           syncr                => syncr,
           Tconv(q)             => rdf_tlxt_data_err_q);

rdf_tlxt_data_err_owq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(rdf_tlxt_data_err_ow_d),
           syncr                => syncr,
           Tconv(q)             => rdf_tlxt_data_err_ow_q);


tl_1sl_vldq: entity latches.c_morph_dff
  generic map (width => 4, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => tl_1sl_vld_d(3 downto 0),
           syncr                => syncr,
           q                    => tl_1sl_vld_q(3 downto 0));

tl_1sl_packedq: entity latches.c_morph_dff
  generic map (width => 12, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => tl_1sl_packed_d(11 downto 0),
           syncr                => syncr,
           q                    => tl_1sl_packed_q(11 downto 0));

tl_1sl_vld_pq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(tl_1sl_vld_p_d),
           syncr                => syncr,
           Tconv(q)             => tl_1sl_vld_p_q);

tl_2sl_pktq: entity latches.c_morph_dff
  generic map (width => 56, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => tl_2sl_pkt_d(55 downto 0),
           syncr                => syncr,
           q                    => tl_2sl_pkt_q(55 downto 0));

tl_2sl_pkt_fullq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(tl_2sl_pkt_full_d),
           syncr                => syncr,
           Tconv(q)             => tl_2sl_pkt_full_q);

tl_2sl_4sl_pkt_full_pq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(tl_2sl_4sl_pkt_full_p_d),
           syncr                => syncr,
           Tconv(q)             => tl_2sl_4sl_pkt_full_p_q);

tl_2sl_pkt_pq: entity latches.c_morph_dff
  generic map (width => 7, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => tl_2sl_pkt_p_d(6 downto 0),
           syncr                => syncr,
           q                    => tl_2sl_pkt_p_q(6 downto 0));

tl_4sl_vldq: entity latches.c_morph_dff
  generic map (width => 2, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => tl_4sl_vld_d(1 downto 0),
           syncr                => syncr,
           q                    => tl_4sl_vld_q(1 downto 0));

tl_4sl_vld_pq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(tl_4sl_vld_p_d),
           syncr                => syncr,
           Tconv(q)             => tl_4sl_vld_p_q);

tl_4sl_pkt_fullq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(tl_4sl_pkt_full_d),
           syncr                => syncr,
           Tconv(q)             => tl_4sl_pkt_full_q);

tlxt_err_invalid_cfgq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(tlxt_err_invalid_cfg_d),
           syncr                => syncr,
           Tconv(q)             => tlxt_err_invalid_cfg_q);

tlxt_err_invalid_meta_cfgq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(tlxt_err_invalid_meta_cfg_d),
           syncr                => syncr,
           Tconv(q)             => tlxt_err_invalid_meta_cfg_q);

tlxt_err_invalid_tmpl_cfgq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(tlxt_err_invalid_tmpl_cfg_d),
           syncr                => syncr,
           Tconv(q)             => tlxt_err_invalid_tmpl_cfg_q);

tmpl_currentq: entity latches.c_morph_dff
  generic map (width => 5, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => tmpl_current_d(4 downto 0),
           syncr                => syncr,
           q                    => tmpl_current_q(4 downto 0));

tmpl_current_dbgq: entity latches.c_morph_dff
  generic map (width => 5, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => tmpl_current_dbg_d(4 downto 0),
           syncr                => syncr,
           q                    => tmpl_current_dbg_q(4 downto 0));

tmpl_current_muxq: entity latches.c_morph_dff
  generic map (width => 5, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => tmpl_current_mux_d(4 downto 0),
           syncr                => syncr,
           q                    => tmpl_current_mux_q(4 downto 0));

tmpl5_intrp_opt_valq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act_tmpl5_enab,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(tmpl5_intrp_opt_val_d),
           syncr                => syncr,
           Tconv(q)             => tmpl5_intrp_opt_val_q);

tmpl9_opt_valq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(tmpl9_opt_val_d),
           syncr                => syncr,
           Tconv(q)             => tmpl9_opt_val_q);

tmpl0_flit_sub0q: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act_half_dimm,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(tmpl0_flit_sub0_d),
           syncr                => syncr,
           Tconv(q)             => tmpl0_flit_sub0_q);

tmpl0_flit_sub1q: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act_half_dimm,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(tmpl0_flit_sub1_d),
           syncr                => syncr,
           Tconv(q)             => tmpl0_flit_sub1_q);

tmpl5_flit_sub0q: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act_tmpl5_enab,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(tmpl5_flit_sub0_d),
           syncr                => syncr,
           Tconv(q)             => tmpl5_flit_sub0_q);

tmpl5_flit_sub1q: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act_tmpl5_enab,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(tmpl5_flit_sub1_d),
           syncr                => syncr,
           Tconv(q)             => tmpl5_flit_sub1_q);

tmpl5_flit_sub2q: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act_tmpl5_enab,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(tmpl5_flit_sub2_d),
           syncr                => syncr,
           Tconv(q)             => tmpl5_flit_sub2_q);

triplet_999q: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act_low_lat_mode,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(triplet_999_d),
           syncr                => syncr,
           Tconv(q)             => triplet_999_q);

triplet_9d9q: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act_low_lat_mode,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(triplet_9d9_d),
           syncr                => syncr,
           Tconv(q)             => triplet_9d9_q);

triplet_9ddq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act_low_lat_mode,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(triplet_9dd_d),
           syncr                => syncr,
           Tconv(q)             => triplet_9dd_q);

triplet_9dd_dropq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act_low_lat_mode,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(triplet_9dd_drop_d),
           syncr                => syncr,
           Tconv(q)             => triplet_9dd_drop_q);

triplet_stateq: entity latches.c_morph_dff
  generic map (width => 3, offset => 0)
  port map(gckn                 => gckn,
           e                    => act_low_lat_mode,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => triplet_state_d(2 downto 0),
           syncr                => syncr,
           q                    => triplet_state_q(2 downto 0));

triplet_state_valq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(triplet_state_val_d),
           syncr                => syncr,
           Tconv(q)             => triplet_state_val_q);

wr_resp_emptyq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(wr_resp_empty_d),
           syncr                => syncr,
           Tconv(q)             => wr_resp_empty_q);

wr_resp_flushq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(wr_resp_flush_d),
           syncr                => syncr,
           Tconv(q)             => wr_resp_flush_q);

wr_resp_unrec_stallq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act_low_lat_mode,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(wr_resp_unrec_stall_d),
           syncr                => syncr,
           Tconv(q)             => wr_resp_unrec_stall_q);

xmit_rate_stallq: entity latches.c_morph_dff
  generic map (width => 6, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => xmit_rate_stall_d(5 downto 0),
           syncr                => syncr,
           q                    => xmit_rate_stall_q(5 downto 0));

opencapi_link_shutdownq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(opencapi_link_shutdown_d),
           syncr                => syncr,
           Tconv(q)             => opencapi_link_shutdown_q);

  --------------------------------------------------------------------------------------------------
  -- degrade changes
  --------------------------------------------------------------------------------------------------
low_lat_degradeq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act_low_lat_deg_mode,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(low_lat_degrade_d),
           syncr                => syncr,
           Tconv(q)             => low_lat_degrade_q);

lane_widthq: entity latches.c_morph_dff
  generic map (width => 2, offset => 0)
  port map(gckn                 => gckn,
           e                    => act_low_lat_deg_mode,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => lane_width_d(1 downto 0),
           syncr                => syncr,
           q                    => lane_width_q(1 downto 0));

rd_resp_degrade_stallq: entity latches.c_morph_dff
  generic map (width => 4, offset => 0)
  port map(gckn                 => gckn,
           e                    => act_low_lat_deg_mode,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => rd_resp_degrade_stall_d(3 downto 0),
           syncr                => syncr,
           q                    => rd_resp_degrade_stall_q(3 downto 0));

rd_resp_degrade_stall_oneq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act_low_lat_deg_mode,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(rd_resp_degrade_stall_one_d),
           syncr                => syncr,
           Tconv(q)             => rd_resp_degrade_stall_one_q);

end cb_tlxt_flit_arb_rlm;


