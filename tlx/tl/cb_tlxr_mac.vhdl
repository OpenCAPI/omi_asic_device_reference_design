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
    USE ibm.std_ulogic_support.all;            -- Tconv
    USE ibm.std_ulogic_unsigned.all;           -- + - on std_ulogic_vector
    USE ibm.std_ulogic_function_support.all;   -- GATE _REDUCE
    USE ibm.synthesis_support.all;             -- attr BTR_NAME PIN_DATA etc
    USE ieee.std_logic_1164.all;
    USE support.logic_support_pkg.all;         -- attr BLOCK_TYPE & power
    USE support.power_logic_pkg.ALL;
LIBRARY work;
USE work.cb_func.ALL;
USE work.cb_tlxr_pkg.ALL;

entity  cb_tlxr_mac is

  port (
    dlx_tlxr_fast_act_info          : in std_ulogic_vector(34 downto 0);
    dlx_tlxr_idle_transition        : in std_ulogic;
    dlx_tlxr_fast_act_info_a        : in std_ulogic_vector(34 downto 0);
    dlx_tlxr_idle_transition_a      : in std_ulogic;
    dlx_tlxr_fast_act_info_b        : in std_ulogic_vector(34 downto 0);
    dlx_tlxr_idle_transition_b      : in std_ulogic;
    gckn                            : in std_ulogic;
    gnd                             : inout power_logic;
    vdd                             : inout power_logic;
    syncr                           : in std_ulogic;  -- synchronous reset
    cfg_half_dimm_mode              : in std_ulogic;  -- reserve wrbuf number 63 for pad pattern
    trc_master_clock_enable         : in std_ulogic;  -- clock gating for the debug output

    dlx_tlxr_flit_vld               : in std_ulogic;  -- Valid flit data and parity this cycle
    dlx_tlxr_flit_error             : in std_ulogic;  -- This Ctrl flit and prev data flits are to be discarded.
    dlx_tlxr_flit_data              : in std_ulogic_vector(127 downto 0);  -- Partial Flit data
    dlx_tlxr_flit_pty               : in std_ulogic_vector(15 downto 0);  -- parity
    dlx_tlxr_link_up                : in std_ulogic;
    tlxt_tlxr_wr_resp_full          : in std_ulogic;
    tlxt_tlxr_early_wdone_disable   : in std_ulogic_vector(1 downto 0);  -- high to use srq. low to send good completion ASAP
    tlxt_tlxr_control               : in std_ulogic_vector(15 downto 0);
    tlxt_tlxr_low_lat_mode          : in std_ulogic;

    tlxr_srq_memcntl_req            : out std_ulogic; -- pulse for mem_cntl command received  flag below
    tlxr_srq_memcntl_cmd_flag       : out std_ulogic_vector(0 to 3);
    tlxr_srq_cmd_val                : out std_ulogic;  -- Read or Write CMD is valid for this cycle
    tlxr_srq_cmd                    : out std_ulogic_vector(0 to 63);  -- Formatted new cmd fifo command

    tlxr_srq_fast_act_val           : out std_ulogic;  -- Fast Activate addr is valid for this cycle
    tlxr_srq_fast_addr              : out std_ulogic_vector(0 to 26);
    tlxr_srq_fast_dimm              : out std_ulogic;

    tlxr_srq_fast_act_val_a         : out std_ulogic;  -- Fast Activate addr is valid for this cycle
    tlxr_srq_fast_addr_a            : out std_ulogic_vector(0 to 26);
    tlxr_srq_fast_dimm_a            : out std_ulogic;

    tlxr_srq_fast_act_val_b         : out std_ulogic;  -- Fast Activate addr is valid for this cycle
    tlxr_srq_fast_addr_b            : out std_ulogic_vector(0 to 26);
    tlxr_srq_fast_dimm_b            : out std_ulogic;

    tlxr_srq_wrbuf_crcval_vec       : out std_ulogic_vector(0 to 63);  -- tlxr_srq_wrbuf_crcval_vec_p

    srq_tlxr_wdone_val              : in std_ulogic;
    srq_tlxr_wdone_last             : in std_ulogic;
    srq_tlxr_wdone_tag              : in std_ulogic_vector(0 to 5);
    srq_tlxr_wdone_p                : in std_ulogic;
    srq_tlxr_epow                   : in std_ulogic;

    tlxr_wdf_wrbuf_wr               : out std_ulogic;  -- indicates that write data is valid this cycle
    tlxr_wdf_wrbuf_wptr             : out std_ulogic_vector(0 to 5);
    tlxr_wdf_wrbuf_woffset          : out std_ulogic_vector(0 to 1);
    tlxr_wdf_wrbuf_wr_p             : out std_ulogic;           --  EVEN parity over wrbuf_wr & wrbuf_wptr & wrbuf_woffset
    tlxr_wdf_wrbuf_dat              : out std_ulogic_vector(0 to 145);
    tlxr_wdf_wrbuf_bad              : out std_ulogic_vector(0 to 64); -- poisoned sort of bad. bit 64 is E parity
    tlxr_wdf_be_wr                  : out std_ulogic;                  -- !! Writing BEs this cycle
    tlxr_wdf_be_wptr                : out std_ulogic_vector(0 to 5);   -- !!Write Buffer number BEs go with
    tlxr_wdf_be_wr_p                : out std_ulogic;                  -- !!EVEN parity over be_wr & be_wptr
    tlxr_wdf_be                     : out std_ulogic_vector(0 to 71);  -- !!0:63 BE, 64:71 ecc (Note: RMW never 128 byte op)

    tlxr_tlxt_write_resp            : out std_ulogic_vector(21 downto 0);  -- 21:6 = tag, 5:2 = response code 1:0 = DL
    tlxr_tlxt_write_resp_p          : out std_ulogic_vector(2 downto 0);   -- even byte parity on (val & resp) (right justified)
    tlxr_tlxt_write_resp_val        : out std_ulogic;                      -- write done valid on this cycle

    tlxr_tlxt_consume_vc0           : out std_ulogic;                      -- intrpt_resp or mem_cntl received
    tlxr_tlxt_consume_vc1           : out std_ulogic;                      -- most commands use 1 vc1 (!! check)
    tlxr_tlxt_consume_dcp1          : out std_ulogic_vector(2 downto 0);   -- 28th June

    tlxr_tlxt_dcp1_release          : out std_ulogic_vector(2 downto 0);   -- write buffer release (no strobe)
    tlxr_tlxt_vc1_release           : out std_ulogic;                      -- credit return for set_pad_pattern
    tlxr_tlxt_vc0_release           : out std_ulogic_vector(1 downto 0);   -- credit return for mem_cntl and int_resp

    tlxr_tlxt_return_val            : out std_ulogic;                      -- return_tlx_credits cmd
    tlxr_tlxt_return_vc0            : out std_ulogic_vector(3 downto 0);   -- return_tlx_credits cmd
    tlxr_tlxt_return_vc3            : out std_ulogic_vector(3 downto 0);   -- return_tlx_credits cmd
    tlxr_tlxt_return_dcp0           : out std_ulogic_vector(5 downto 0);   -- return_tlx_credits cmd
    tlxr_tlxt_return_dcp3           : out std_ulogic_vector(5 downto 0);   -- return_tlx_credits cmd
    tlxr_tlxt_errors                : out std_ulogic_vector(63 downto 0);  --
    tlxr_tlxt_signature_dat         : out std_ulogic_vector(63 downto 0);
    tlxr_tlxt_signature_strobe      : out std_ulogic;

    tlxr_tlxt_intrp_resp            : out std_ulogic_vector(7 downto 0);   -- 1:0 is for tag 1 .... 7:6 is for tag 4

    mmio_tlxr_wr_buf_free           : in  std_ulogic;
    mmio_tlxr_wr_buf_tag            : in  std_ulogic_vector(5 downto 0);
    mmio_tlxr_wr_buf_par            : in  std_ulogic;
    mmio_tlxr_resp_code             : in  std_ulogic_vector(3 downto 0); -- free tag resp_code
    cfg_f1_csh_memory_space         : in  std_ulogic;
    cfg_f1_csh_p                    : in  std_ulogic;            -- even parity on bar0 and memory checked every clock
    cfg_f1_csh_mmio_bar0            : in  std_ulogic_vector(63 downto 35);
    cfg_f1_octrl00_metadata_enabled : std_ulogic;
    cfg_otl0_long_backoff_timer     : in  std_ulogic_vector(3 downto 0); -- 100ns * 2**(2xthis number)
    tlxr_tp_fir_trace_err           : out std_ulogic;

-- Configuration for the address translators from MCB
    mcb_tlxr_xlt_slot0_valid             : in   std_ulogic;
    mcb_tlxr_xlt_slot1_valid             : in   std_ulogic;
    mcb_tlxr_xlt_slot0_d_value           : in   std_ulogic;
    mcb_tlxr_xlt_slot1_d_value           : in   std_ulogic;
    mcb_tlxr_xlt_slot0_m0_valid          : in   std_ulogic;
    mcb_tlxr_xlt_slot0_m1_valid          : in   std_ulogic;
    mcb_tlxr_xlt_slot0_s0_valid          : in   std_ulogic;
    mcb_tlxr_xlt_slot0_s1_valid          : in   std_ulogic;
    mcb_tlxr_xlt_slot0_s2_valid          : in   std_ulogic;
    mcb_tlxr_xlt_slot0_r15_valid         : in   std_ulogic;
    mcb_tlxr_xlt_slot0_r16_valid         : in   std_ulogic;
    mcb_tlxr_xlt_slot0_r17_valid         : in   std_ulogic;
    mcb_tlxr_xlt_slot1_m0_valid          : in   std_ulogic;
    mcb_tlxr_xlt_slot1_m1_valid          : in   std_ulogic;
    mcb_tlxr_xlt_slot1_s0_valid          : in   std_ulogic;
    mcb_tlxr_xlt_slot1_s1_valid          : in   std_ulogic;
    mcb_tlxr_xlt_slot1_s2_valid          : in   std_ulogic;
    mcb_tlxr_xlt_slot1_r15_valid         : in   std_ulogic;
    mcb_tlxr_xlt_slot1_r16_valid         : in   std_ulogic;
    mcb_tlxr_xlt_slot1_r17_valid         : in   std_ulogic;
    mcb_tlxr_xlt_d_bit_map               : in   std_ulogic_vector(0 to  4);
    mcb_tlxr_xlt_m0_bit_map              : in   std_ulogic_vector(0 to  4);
    mcb_tlxr_xlt_m1_bit_map              : in   std_ulogic_vector(0 to  4);
    mcb_tlxr_xlt_s0_bit_map              : in   std_ulogic_vector(0 to  4);
    mcb_tlxr_xlt_s1_bit_map              : in   std_ulogic_vector(0 to  4);
    mcb_tlxr_xlt_s2_bit_map              : in   std_ulogic_vector(0 to  4);
    mcb_tlxr_xlt_r17_bit_map             : in   std_ulogic_vector(0 to  4);
    mcb_tlxr_xlt_r16_bit_map             : in   std_ulogic_vector(0 to  4);
    mcb_tlxr_xlt_r15_bit_map             : in   std_ulogic_vector(0 to  4);
    mcb_tlxr_xlt_c3_bit_map              : in   std_ulogic_vector(0 to  4);
    mcb_tlxr_xlt_c4_bit_map              : in   std_ulogic_vector(0 to  4);
    mcb_tlxr_xlt_c5_bit_map              : in   std_ulogic_vector(0 to  4);
    mcb_tlxr_xlt_c6_bit_map              : in   std_ulogic_vector(0 to  4);
    mcb_tlxr_xlt_c7_bit_map              : in   std_ulogic_vector(0 to  4);
    mcb_tlxr_xlt_c8_bit_map              : in   std_ulogic_vector(0 to  4);
    mcb_tlxr_xlt_c9_bit_map              : in   std_ulogic_vector(0 to  4);
    mcb_tlxr_xlt_b0_bit_map              : in   std_ulogic_vector(0 to  4);
    mcb_tlxr_xlt_b1_bit_map              : in   std_ulogic_vector(0 to  4);
    mcb_tlxr_xlt_bg0_bit_map             : in   std_ulogic_vector(0 to  4);
    mcb_tlxr_xlt_bg1_bit_map             : in   std_ulogic_vector(0 to  4);
    mcb_tlxr_enab_row_addr_hash          : in    std_ulogic;
    tlxr_dbg_debug_bus                   : out std_ulogic_vector(0 to 87);

-- Fast act FIFO
    --srq/tlxr
    srq_tlxr_fast_act_fifo_next         : in std_ulogic;  -- pulse; shift fast act fifo; will only occur at most every other cycle; can mean either current address has been taken or not able to go out / undesireable
    srq_tlxr_fast_act_fifo_drain        : in std_ulogic;  -- level; drain & don't fill fast act fifo (doing writes, rrq has activates)
    tlxr_srq_fast_act_fifo_val_a          : out std_ulogic;
    tlxr_srq_fast_act_fifo_addr_a         : out std_ulogic_vector(0 to 26);
    tlxr_srq_fast_act_fifo_dimm_a         : out std_ulogic;
    tlxr_srq_fast_act_fifo_row_bank_par_a : out std_ulogic;
    tlxr_srq_fast_act_fifo_rank_par_a     : out std_ulogic;
    tlxr_srq_fast_act_fifo_val_b          : out std_ulogic;
    tlxr_srq_fast_act_fifo_addr_b         : out std_ulogic_vector(0 to 26);
    tlxr_srq_fast_act_fifo_dimm_b         : out std_ulogic;
    tlxr_srq_fast_act_fifo_row_bank_par_b : out std_ulogic;
    tlxr_srq_fast_act_fifo_rank_par_b     : out std_ulogic;
    tlxr_srq_fast_act_fifo_val          : out std_ulogic;
    tlxr_srq_fast_act_fifo_addr         : out std_ulogic_vector(0 to 26);
    tlxr_srq_fast_act_fifo_dimm         : out std_ulogic;
    tlxr_srq_fast_act_fifo_row_bank_par : out std_ulogic;
    tlxr_srq_fast_act_fifo_rank_par     : out std_ulogic
);

  attribute BLOCK_TYPE of cb_tlxr_mac : entity is SUPERRLM;
  attribute BTR_NAME of cb_tlxr_mac : entity is "CB_TLXR_MAC";
  attribute PIN_DEFAULT_GROUND_DOMAIN of cb_tlxr_mac : entity is "GND";
  attribute PIN_DEFAULT_POWER_DOMAIN of cb_tlxr_mac : entity is "VDD";
  attribute RECURSIVE_SYNTHESIS of cb_tlxr_mac : entity is 0;
  attribute PIN_DATA of gckn : signal is "PIN_FUNCTION=/G_CLK/";
  attribute GROUND_PIN of gnd : signal is 1;
  attribute POWER_PIN of vdd : signal is 1;
end cb_tlxr_mac;

architecture cb_tlxr_mac of cb_tlxr_mac is
  SIGNAL act                               : std_ulogic;
  SIGNAL buf_state_d                       : std_ulogic_vector(511 downto 0);
  SIGNAL data_flit_num_d                   : std_ulogic_vector(2 downto 0);
  SIGNAL data_flits_owed_d                 : std_ulogic_vector(3 downto 0);
  SIGNAL dataflow_perr_d                   : std_ulogic;
  SIGNAL dbg_bus_d                         : std_ulogic_vector(0 to 87);
  SIGNAL dbuf_list_d                       : std_ulogic_vector(63 downto 0);
  SIGNAL dbuf_wp_d                         : std_ulogic_vector(3 downto 0);
  SIGNAL dbuf_wp_held_d                    : std_ulogic_vector(3 downto 0);
  SIGNAL decode_ctl_cycle_d                : std_ulogic_vector(4 downto 0);
  SIGNAL decode_data_cycle_d               : std_ulogic_vector(4 downto 0);
  SIGNAL decoding_data_d                   : std_ulogic;
  SIGNAL dflow_pe_held_d                   : std_ulogic;
  SIGNAL early_wr_done_bf_d                : std_ulogic_vector(63 downto 0);
  SIGNAL ecc_par_in_d                      : std_ulogic_vector(1 downto 0);
  SIGNAL fast_act_partial_count_q          : std_ulogic_vector(1 downto 0);
  SIGNAL first_tag_d                       : std_ulogic_vector(5 downto 0);
  SIGNAL flit_8bp_d                        : std_ulogic_vector(7 downto 0);
  SIGNAL flit_d                            : std_ulogic_vector(511 downto 0);
  SIGNAL flit_held_d                       : std_ulogic_vector(127 downto 80);
  SIGNAL hundred_ns1_d                     : std_ulogic;
  SIGNAL hundred_ns2_d                     : std_ulogic;
  SIGNAL hundred_ns3_d                     : std_ulogic;
  SIGNAL hundred_ns4_d                     : std_ulogic;
  SIGNAL int_rdy_pending_d                 : std_ulogic_vector(4 downto 1);
  SIGNAL last_good_dfo_d                   : std_ulogic_vector(3 downto 0);
  SIGNAL lbt_1_d                           : std_ulogic_vector(30 downto 0);
  SIGNAL lbt_2_d                           : std_ulogic_vector(30 downto 0);
  SIGNAL lbt_3_d                           : std_ulogic_vector(30 downto 0);
  SIGNAL lbt_4_d                           : std_ulogic_vector(30 downto 0);
  SIGNAL lbt_prescale_d                    : std_ulogic_vector(7 downto 0);
  SIGNAL memcntl_busy_d                    : std_ulogic_vector(3 downto 0);
  SIGNAL memcntl_fail_d                    : std_ulogic_vector(3 downto 0);
  SIGNAL meta_store_d                      : std_ulogic_vector(55 downto 0);
  SIGNAL metadata_d                        : std_ulogic_vector(5 downto 0);
  SIGNAL op_held_d                         : std_ulogic_vector(43 downto 0);
  SIGNAL partial_flit_count_d              : std_ulogic_vector(1 downto 0);
  SIGNAL raw_dlx_delay_d                   : std_ulogic_vector(146 downto 0);
  SIGNAL shutdown_d                        : std_ulogic_vector(2 downto 0); -- use 0 for epow
  SIGNAL srq_cmd_d                         : std_ulogic_vector(0 to 62);
  SIGNAL t7_bad_d,tA_bad_d                 : std_ulogic;
  SIGNAL tag_return_candidates_d           : std_ulogic_vector(67 downto 0);
  SIGNAL tag_store_raddr_d                 : std_ulogic_vector(6 downto 0);
  SIGNAL template_0_d,template_4_d         : std_ulogic;
  SIGNAL template_7_d,template_A_d         : std_ulogic;
  SIGNAL tlxr_srq_cmd_val_d                : std_ulogic;
  SIGNAL tlxr_tlxt_consume_dcp1_d          : std_ulogic_vector(2 downto 0);
  SIGNAL tlxr_tlxt_errors_d                : std_ulogic_vector(58 downto 0);
  SIGNAL tlxr_tlxt_intrp_resp_d            : std_ulogic_vector(7 downto 0);
  SIGNAL tlxr_tlxt_signature_dat_d         : std_ulogic_vector(63 downto 0);
  SIGNAL tlxr_tlxt_signature_strobe_d      : std_ulogic;
  SIGNAL tlxr_tlxt_write_resp_d            : std_ulogic_vector(21 downto 0);
  SIGNAL tlxr_tlxt_write_resp_p_d          : std_ulogic_vector(2 downto 0);
  SIGNAL tlxr_wdf_be_d                     : std_ulogic_vector(0 to 71);
  SIGNAL tlxr_wdf_be_wr_d                  : std_ulogic;
  SIGNAL tlxr_wdf_be_wr_p_d                : std_ulogic;
  SIGNAL tlxr_wdf_wrbuf_bad63_d            : std_ulogic;
  SIGNAL tlxr_wdf_wrbuf_dat_d              : std_ulogic_vector(145 downto 0);
  SIGNAL turn_taken_d                      : std_ulogic_vector(67 downto 0);
  SIGNAL twwp_d                            : std_ulogic_vector(0 to 5);
  SIGNAL vc0_rls_memctl_d                  : std_ulogic_vector(1 downto 0);

  SIGNAL bpv_d,bpv_q                       : std_ulogic_vector(2 downto 1);
  SIGNAL buf_state_q                       : std_ulogic_vector(511 downto 0);
  SIGNAL data_flit_num_q                   : std_ulogic_vector(2 downto 0);
  SIGNAL data_flits_owed_q                 : std_ulogic_vector(3 downto 0);
  SIGNAL dataflow_perr_q                   : std_ulogic;
  SIGNAL dbg_bus_q                         : std_ulogic_vector(0 to 87);
  SIGNAL dbuf_list_q                       : std_ulogic_vector(63 downto 0);
  SIGNAL dbuf_wp_held_q                    : std_ulogic_vector(3 downto 0);
  SIGNAL dbuf_wp_q                         : std_ulogic_vector(3 downto 0);
  SIGNAL decode_ctl_cycle_q                : std_ulogic_vector(4 downto 0);
  SIGNAL decode_data_cycle_q               : std_ulogic_vector(4 downto 0);
  SIGNAL decoding_data_q                   : std_ulogic;
  SIGNAL dflow_pe_held_q                   : std_ulogic;
  SIGNAL ire_rtag_d,ire_rtag_q             : std_ulogic_vector(21 downto 0);
  SIGNAL ire_pending_d, ire_pending_q      : std_ulogic;
  SIGNAL early_wr_done_bf_q                : std_ulogic_vector(63 downto 0);
  SIGNAL ecc_par_in_q                      : std_ulogic_vector(1 downto 0);
  SIGNAL fast_act_partial_count_d          : std_ulogic_vector(1 downto 0);
  SIGNAL first_tag_q                       : std_ulogic_vector(5 downto 0);
  SIGNAL flit_8bp_q                        : std_ulogic_vector(7 downto 0);
  SIGNAL flit_held_q                       : std_ulogic_vector(127 downto 80);
  SIGNAL flit_q                            : std_ulogic_vector(511 downto 0);
  SIGNAL flit_p_q,flit_p_d                 : std_ulogic_vector(63 downto 0);
  SIGNAL ft_d,ft_q,st_d,st_q               : std_ulogic_vector(5 downto 0);    --
  SIGNAL hundred_ns1_q                     : std_ulogic;
  SIGNAL hundred_ns2_q                     : std_ulogic;
  SIGNAL hundred_ns3_q                     : std_ulogic;
  SIGNAL hundred_ns4_q                     : std_ulogic;
  SIGNAL idle_flit                         : std_ulogic;
  SIGNAL int_rdy_pending_q                 : std_ulogic_vector(4 downto 1);
  SIGNAL lbt_1_q                           : std_ulogic_vector(30 downto 0);
  SIGNAL lbt_2_q                           : std_ulogic_vector(30 downto 0);
  SIGNAL lbt_3_q                           : std_ulogic_vector(30 downto 0);
  SIGNAL lbt_4_q                           : std_ulogic_vector(30 downto 0);
  SIGNAL lbt_prescale_q                    : std_ulogic_vector(7 downto 0);
  SIGNAL lilii_nt                          : std_ulogic_vector(1 downto 0);
  SIGNAL lilii_t                           : std_ulogic_vector(1 downto 0);
  SIGNAL memcntl_busy_q                    : std_ulogic_vector(3 downto 0);
  SIGNAL memcntl_fail_q                    : std_ulogic_vector(3 downto 0);
  SIGNAL meta_store_q                      : std_ulogic_vector(55 downto 0);
  SIGNAL metadata_q                        : std_ulogic_vector(5 downto 0);
  SIGNAL op_held_q                         : std_ulogic_vector(43 downto 0);
  SIGNAL partial_flit_count_q              : std_ulogic_vector(1 downto 0);
  SIGNAL raw_dlx_delay_q                   : std_ulogic_vector(146 downto 0);
  SIGNAL resp_cnt_d,resp_cnt_q             : std_ulogic;
  SIGNAL resp_err_code_d,resp_err_code_q   : std_ulogic_vector(7 downto 0);
  SIGNAL resp_tmg_q,resp_tmg_d             : std_ulogic_vector(23 downto 0);
  SIGNAL resp_val_q,resp_val_d             : std_ulogic_vector(2 downto 0);
  SIGNAL shutdown_q                        : std_ulogic_vector(2 downto 0); -- use 0 for epow
  SIGNAL srq_cmd_q                         : std_ulogic_vector(0 to 62);
  SIGNAL t7_bad_q,tA_bad_q                 : std_ulogic;
  SIGNAL tag_return_candidates_q           : std_ulogic_vector(67 downto 0);
  SIGNAL tag_store_raddr_q                 : std_ulogic_vector(6 downto 0);
  SIGNAL template_0_q,template_4_q         : std_ulogic;
  SIGNAL template_7_q,template_A_q         : std_ulogic;
  SIGNAL tlxr_srq_cmd_val_q                : std_ulogic;
  SIGNAL tlxr_tlxt_consume_dcp1_q          : std_ulogic_vector(2 downto 0);
  SIGNAL tlxr_tlxt_errors_q                : std_ulogic_vector(58 downto 0);
  SIGNAL tlxr_tlxt_intrp_resp_q            : std_ulogic_vector(7 downto 0);
  SIGNAL tlxr_tlxt_signature_dat_q         : std_ulogic_vector(63 downto 0);
  SIGNAL tlxr_tlxt_signature_strobe_q      : std_ulogic;
  SIGNAL tlxr_tlxt_write_resp_p_q          : std_ulogic_vector(2 downto 0);
  SIGNAL tlxr_tlxt_write_resp_q            : std_ulogic_vector(21 downto 0);
  SIGNAL tlxr_wdf_be_q                     : std_ulogic_vector(0 to 71);
  SIGNAL tlxr_wdf_be_wr_p_q                : std_ulogic;
  SIGNAL tlxr_wdf_be_wr_q                  : std_ulogic;
  SIGNAL tlxr_wdf_wrbuf_bad63_q            : std_ulogic;
  SIGNAL tlxr_wdf_wrbuf_dat_q              : std_ulogic_vector(145 downto 0);
  SIGNAL turn_taken_q                      : std_ulogic_vector(67 downto 0);
  SIGNAL twwp_q                            : std_ulogic_vector(0 to 5);
  SIGNAL uc_d,uc_q                         : std_ulogic_vector(8 downto 0);
  SIGNAL vc0_rls_memctl_q                  : std_ulogic_vector(1 downto 0);
  SIGNAL resp_cnt2_d,resp_cnt2_q           : std_ulogic;

  SIGNAL advance_crc                       : std_ulogic_vector(63 downto 0);
  SIGNAL b2_val                            : std_ulogic;
  SIGNAL b_enabs                           : std_ulogic_vector(0 to 63);
  SIGNAL b_nos_4_srq                       : std_ulogic_vector(0 to 15);
  SIGNAL bad_intrp_tag                     : std_ulogic;
  SIGNAL bad_intrp_tagv                    : std_ulogic_vector(4 downto 1);
  SIGNAL bar_minus_1                       : std_ulogic_vector(63 downto 35);
  SIGNAL bc_format                         : std_ulogic_vector(3 downto 0);
  SIGNAL bc_wr_gate                        : std_ulogic;
  SIGNAL be_ecc_out                        : std_ulogic_vector(0 to 72);
  SIGNAL bi_flit_buffer                    : std_ulogic;
  SIGNAL bttg                              : std_ulogic_vector(67 downto 0);
  SIGNAL buf_idl_0,buf_idl_2               : std_ulogic;
  SIGNAL buf_state_pe                      : std_ulogic_vector(63 downto 0);
  SIGNAL buff_epow_halt                    : std_ulogic;
  SIGNAL buffctl_empty                     : std_ulogic;
  SIGNAL buffctl_error                     : std_ulogic_vector(5 downto 0);
  SIGNAL buffer_busy                       : std_ulogic_vector(63 downto 0);
  SIGNAL buffers_idle                      : std_ulogic;
  SIGNAL buffer_shortage                   : std_ulogic_vector(3 downto 0);
  SIGNAL cfg_op,c2_as_a5                   : std_ulogic;
  SIGNAL cmd_xlat_error                    : std_ulogic;
  SIGNAL coded_cmd                         : std_ulogic_vector(3 downto 0);
  SIGNAL coded_tplate                      : std_ulogic_vector(2 downto 0);
  SIGNAL col_addr                          : std_ulogic_vector(27 to 34);
  SIGNAL col_bank_par,other_xlate_par      : std_ulogic;
  SIGNAL control_flit                      : std_ulogic;
  SIGNAL credit_return_by_slot             : std_ulogic_vector(3 downto 0);
  SIGNAL data_is_patt                      : std_ulogic_vector(0 to 63);
  SIGNAL data_xfer                         : std_ulogic;
  SIGNAL dbg_clk_en                        : std_ulogic;
  SIGNAL dcp1_rls_earlies                  : std_ulogic;
  SIGNAL dcp1_rls_lates                    : std_ulogic;
  SIGNAL dcp1_rls_notag                    : std_ulogic;
  SIGNAL dcp1_rls_xtra                     : std_ulogic;
  SIGNAL debug_sel                         : std_ulogic_vector(7 downto 0);
  SIGNAL debug_set_0,debug_set_1           : std_ulogic_vector(43 downto 0);
  SIGNAL debug_set_2,debug_set_3           : std_ulogic_vector(43 downto 0);
  SIGNAL debug_set_4,debug_set_5           : std_ulogic_vector(43 downto 0);
  SIGNAL debug_set_6,debug_set_7           : std_ulogic_vector(43 downto 0);
  SIGNAL dec_ctl0                          : std_ulogic;
  SIGNAL dec_ctl_flt                       : std_ulogic;
  SIGNAL dec_dat0                          : std_ulogic;
  SIGNAL dfo                               : std_ulogic_vector(3 downto 0);
  SIGNAL dimm                              : std_ulogic;
  SIGNAL disable_credit_update             : std_ulogic;
  SIGNAL dl_slot0,dl_slot4,dl_slot8,dl_slot12 : std_ulogic_vector(1 downto 0);
  SIGNAL ire_strobe,ire                    : std_ulogic;
  SIGNAL ire_fmt                           : std_ulogic_vector(63 downto 0);
  SIGNAL ecc_data_in                       : std_ulogic_vector(129 downto 0);
  SIGNAL ecc_data_out                      : std_ulogic_vector(145 downto 0);
  SIGNAL errors_always_shutdown            : std_ulogic;
  SIGNAL errors_maybe_shutdown             : std_ulogic;
  SIGNAL fast_act_fifo_addr                : std_ulogic_vector(0 to  34);
  SIGNAL fast_act_fifo_wr                  : std_ulogic;
  SIGNAL first_buf,second_buf              : std_ulogic_vector(5 downto 0);
  SIGNAL first_dec                         : std_ulogic_vector(63 downto 0);
  SIGNAL first_second_dec                  : std_ulogic_vector(63 downto 0);
  SIGNAL first_tag,second_tag              : std_ulogic_vector(5 downto 0);
  SIGNAL flag                              : std_ulogic_vector(3 downto 0); 
  SIGNAL flit8par                          : std_ulogic_vector(1 downto 0);
  SIGNAL flit_30,flit_74,flit_B8,flit_FC   : std_ulogic_vector(111 downto 0);
  SIGNAL flit_dat_bad                      : std_ulogic_vector(63 downto 0);
  SIGNAL flit_perr                         : std_ulogic_vector(63 downto 0);
  SIGNAL fmt0_error                        : std_ulogic;
  SIGNAL force_64                          : std_ulogic;
  SIGNAL force_buf_63                      : std_ulogic;
  SIGNAL ft0,ft1                           : std_ulogic_vector(5 downto 0);   
  SIGNAL spoofed_cmd                       : std_ulogic_vector(3 downto 0);   
  SIGNAL int_rdy                           : std_ulogic_vector(4 downto 0);
  SIGNAL int_resp                          : std_ulogic_vector(4 downto 0);
  SIGNAL intrp_resp_fail                   : std_ulogic;
  SIGNAL invalid_opcode_slot               : std_ulogic_vector(4 downto 0);
  SIGNAL last_good_dfo_q                   : std_ulogic_vector(3 downto 0);
  SIGNAL last_wdf_phase_7a                 : std_ulogic;
  SIGNAL last_wdf_phase_df                 : std_ulogic;
  SIGNAL lbt_enab                          : std_ulogic_vector(4 downto 1);
  SIGNAL lbt_finished                      : std_ulogic_vector(4 downto 1);
  SIGNAL lbt_icount                        : std_ulogic_vector(30 downto 0);
  SIGNAL lbt_prescale_enab                 : std_ulogic;
  SIGNAL lbt_start                         : std_ulogic_vector(4 downto 1);
  SIGNAL length_format_2                   : std_ulogic_vector(2 downto 0);
  SIGNAL length_format_3                   : std_ulogic_vector(2 downto 0);
  SIGNAL mask_a5                           : std_ulogic;
  SIGNAL mem_cntl,mem_pfch                 : std_ulogic;
  SIGNAL mem_cntl_resp                     : std_ulogic_vector(3 downto 0);
  SIGNAL memcntl_tag                       : std_ulogic_vector(3 downto 0);
  SIGNAL memctl_unknown_flag               : std_ulogic;
  SIGNAL meta_corr                         : std_ulogic_vector(49 downto 0);
  SIGNAL meta_corrected                    : std_ulogic_vector(47 downto 0);
  SIGNAL meta_data_from_flit               : std_ulogic_vector(47 downto 0);
  SIGNAL meta_syndrome                     : std_ulogic_vector(7 downto 0);
  SIGNAL meta_unc                          : std_ulogic;
  SIGNAL metadata                          : std_ulogic_vector(5 downto 0);
  SIGNAL mmio_addr                         : std_ulogic_vector(3 downto 0);
  SIGNAL mmio_idle_wdone                   : std_ulogic;
  SIGNAL mmio_wdone_tag_dec                : std_ulogic_vector(63 downto 0);
  SIGNAL mux_mem_cntl                      : std_ulogic;
  SIGNAL no_return_candidates              : std_ulogic;
  SIGNAL oc_addr                           : std_ulogic_vector(39 downto 0);
  SIGNAL oc_oob                            : std_ulogic;
  SIGNAL oc_rd_err                         : std_ulogic;
  SIGNAL oc_rd_resp                        : std_ulogic_vector(2 downto 0);
  SIGNAL oc_rd_resp_p                      : std_ulogic;
  SIGNAL oc_tag_dl_ecc                     : std_ulogic_vector(23 downto 0);
  SIGNAL oc_wr_err                         : std_ulogic;
  SIGNAL oc_wr_resp                        : std_ulogic_vector(2 downto 0);
  SIGNAL op_held_perr                      : std_ulogic;
  SIGNAL pad_mem_unsupp_len                : std_ulogic;
  SIGNAL pad_mem_unsupp_op                 : std_ulogic;
  SIGNAL pad_mem_err                       : std_ulogic;
  SIGNAL pad_patt_write                    : std_ulogic;
  SIGNAL part_op                           : std_ulogic_vector(43 downto 0);
  SIGNAL partial_flit_count_0              : std_ulogic;
  SIGNAL partial_flit_count_0_ne           : std_ulogic;
  SIGNAL partial_flit_count_1              : std_ulogic;
  SIGNAL partial_flit_count_1_ne           : std_ulogic;
  SIGNAL partial_flit_count_2              : std_ulogic;
  SIGNAL partial_flit_count_2_ne           : std_ulogic;
  SIGNAL partial_flit_count_3              : std_ulogic;
  SIGNAL partial_flit_count_3_ne           : std_ulogic;
  SIGNAL patt_addr                         : std_ulogic_vector(3 downto 0);
  SIGNAL phys_addr                         : std_ulogic_vector(0 to 34);
  SIGNAL pop                               : std_ulogic_vector(43 downto 0);
  SIGNAL pr_rd_dram                        : std_ulogic;
  SIGNAL pr_rd_mem                         : std_ulogic;
  SIGNAL pr_rd_misalign                    : std_ulogic;
  SIGNAL pr_wr_dram                        : std_ulogic;
  SIGNAL pr_wr_mem                         : std_ulogic;
  SIGNAL rd_err_len_64                     : std_ulogic;
  SIGNAL rd_mem                            : std_ulogic;
  SIGNAL read_32b,read_64b,read_48b        : std_ulogic;
  SIGNAL release_4_dcp1                    : std_ulogic;
  SIGNAL reserved_intrp_code               : std_ulogic;
  SIGNAL reset_tag_return                  : std_ulogic_vector(67 downto 0);
  SIGNAL resp_cnt                          : std_ulogic_vector(3 downto 0);
  SIGNAL resp_or_rdy                       : std_ulogic_vector(4 downto 0);
  SIGNAL reset_err_return                  : std_ulogic_vector(67 downto 0);
  SIGNAL second_dec                        : std_ulogic_vector(63 downto 0);
  SIGNAL set_memcntl_busy                  : std_ulogic_vector(3 downto 0);
  SIGNAL shutdown                          : std_ulogic;
  SIGNAL sig_fmt_0                         : std_ulogic_vector(63 downto 3);
  SIGNAL sig_fmt_1                         : std_ulogic_vector(63 downto 3);
  SIGNAL sig_fmt_2                         : std_ulogic_vector(63 downto 3);
  SIGNAL sig_fmt_3                         : std_ulogic_vector(63 downto 3);
  SIGNAL sig_fmt_4                         : std_ulogic_vector(63 downto 3);
  SIGNAL srq_idle_wdone                    : std_ulogic;
  SIGNAL srq_wdone_tag_dec                 : std_ulogic_vector(63 downto 0);
  SIGNAL t,row_bank_par                    : std_ulogic;
  SIGNAL t7_immed_meta                     : std_ulogic_vector(2 downto 0);
  SIGNAL tag_rls_256s                      : std_ulogic_vector(63 downto 0);
  SIGNAL tag_rls_earlies                   : std_ulogic_vector(63 downto 0);
  SIGNAL tag_rls_lates                     : std_ulogic_vector(63 downto 0);
  SIGNAL tag_rls_xtra                      : std_ulogic_vector(63 downto 0);
  SIGNAL tag_store_corr                    : std_ulogic_vector(19 downto 0);
  SIGNAL tag_store_corrected               : std_ulogic_vector(17 downto 0);
  SIGNAL tag_store_out                     : std_ulogic_vector(23 downto 0);
  SIGNAL tag_store_waddr                   : std_ulogic_vector(67 downto 0);
  SIGNAL tag_store_we                      : std_ulogic;
  SIGNAL template_0,template_4             : std_ulogic;
  SIGNAL template_A,template_7             : std_ulogic;
  SIGNAL tlxr_flit_data                    : std_ulogic_vector(127 downto 0);
  SIGNAL tlxr_flit_error                   : std_ulogic;
  SIGNAL tlxr_flit_pty                     : std_ulogic_vector(15  downto 0);
  SIGNAL tlxr_flit_vld                     : std_ulogic;
  SIGNAL tlxr_link_up                      : std_ulogic;
  SIGNAL tlxr_srq_cmd_i                    : std_ulogic_vector(0 to 63);
  SIGNAL tlxr_srq_cmd_used                 : std_ulogic;
  SIGNAL tlxr_srq_cmd_val_i                : std_ulogic;
  SIGNAL tlxr_srq_fast_addr_i              : std_ulogic_vector(0 to 26);
  SIGNAL tlxr_srq_fast_addr_i_a            : std_ulogic_vector(0 to 26);
  SIGNAL tlxr_srq_fast_addr_i_b            : std_ulogic_vector(0 to 26);
  SIGNAL tlxr_tlxt_consume_vc0_i           : std_ulogic;
  SIGNAL tlxr_tlxt_dcp1_release_i          : std_ulogic_vector(2 downto 0);
  SIGNAL tlxr_tlxt_return_val_i            : std_ulogic;
  SIGNAL tlxr_tlxt_vc0_release_i           : std_ulogic_vector(1 downto 0);
  SIGNAL tlxr_tp_fir_trace_err_i           : std_ulogic;
  SIGNAL tlxr_wdf_wrbuf_bad_i              : std_ulogic_vector(0 to 63);
  SIGNAL tlxr_wdf_wrbuf_pointer            : std_ulogic_vector(0 to 5);
  SIGNAL tlxr_wdf_wrbuf_wr_i               : std_ulogic;
  SIGNAL tlxr_wdf_wrbuf_wr_par             : std_ulogic; 
  SIGNAL trace_mmio_addr                   : std_ulogic;
  SIGNAL translating                       : std_ulogic;
  SIGNAL ts_syndrome                       : std_ulogic_vector(5 downto 0);
  SIGNAL turn_taken_new                    : std_ulogic_vector(67 downto 0); 
  SIGNAL twwp_dec                          : std_ulogic_vector(63 downto 0);
  SIGNAL unknown_opcode_slot               : std_ulogic_vector(4 downto 0);
  SIGNAL unknown_template                  : std_ulogic;
  SIGNAL use_buf,use_2_buf,use_1_buf       : std_ulogic;
  SIGNAL using_cmd                         : std_ulogic_vector(3 downto 0);
  SIGNAL using_cmd_ne                      : std_ulogic_vector(3 downto 0);
  SIGNAL vc0_rls_intrp                     : std_ulogic; 
  SIGNAL vc1_rls_patt                      : std_ulogic;
  SIGNAL write_mem                         : std_ulogic;
  SIGNAL write_membe                       : std_ulogic;
  SIGNAL wrmembes                          : std_ulogic_vector(0 to 64);
  SIGNAL xlat_addr_in                      : std_ulogic_vector(39 downto 4);
  SIGNAL xlat_drop                         : std_ulogic;
  SIGNAL xlat_hole,X,Y0,Y2                 : std_ulogic;
  SIGNAL prev_beat0,prev_beat1,prev_beat2  : std_ulogic_vector(127 downto 0);
  signal fa_slot0_enab_d,fa_slot0_enab_q   : std_ulogic;
  signal control_flit_next                 : std_ulogic;
  signal cfg_half_dimm_mode_d              : std_ulogic;
  signal cfg_half_dimm_mode_q              : std_ulogic;
attribute ANALYSIS_NOT_REFERENCED of flit_30,flit_74,flit_B8,flit_FC:signal is "<26:24>TRUE";
attribute ANALYSIS_NOT_REFERENCED of BE_ECC_OUT:signal is "<0:64>TRUE";
attribute ANALYSIS_NOT_REFERENCED of TLXR_SRQ_CMD_I:signal is "<59>TRUE";
attribute ANALYSIS_NOT_REFERENCED of prev_beat0:signal is "<127:120>TRUE,<115>TRUE,<111:8>TRUE";
attribute ANALYSIS_NOT_REFERENCED of prev_beat1:signal is "<127:104>TRUE,<99>TRUE,<95:0>TRUE";
attribute ANALYSIS_NOT_REFERENCED of prev_beat2:signal is "<112:88>TRUE,<83>TRUE,<79:0>TRUE";
attribute ANALYSIS_NOT_REFERENCED of reset_err_return:signal is "<67:64>TRUE";

function NBITS(inp : std_ulogic_vector) return integer is
variable result:integer range 0 to inp'length;
begin
result:=0;
for i in inp'low to inp'high loop
  if inp(i)/='0' then --  and inp(i)/='L' then
    result   := result + 1;
  end if;
end loop;
return result;
end NBITS;

begin  -- cb_tlxr_mac

      -- latch everything from dlx
       raw_dlx_delay_d(127 downto 0)   <=   DLX_TLXR_FLIT_DATA;
       raw_dlx_delay_d(143 downto 128) <=   DLX_TLXR_FLIT_PTY;
       raw_dlx_delay_d(144)            <=   DLX_TLXR_LINK_UP;
       raw_dlx_delay_d(145)            <=   DLX_TLXR_FLIT_VLD;
       raw_dlx_delay_d(146)            <=   DLX_TLXR_FLIT_ERROR;

       tlxr_flit_data                  <=   raw_dlx_delay_q(127 downto 0);
       tlxr_flit_pty                   <=   raw_dlx_delay_q(143 downto 128);
       tlxr_link_up                    <=   raw_dlx_delay_q(144);
       tlxr_flit_vld                   <=   raw_dlx_delay_q(145);
       tlxr_flit_error                 <=   raw_dlx_delay_q(146);

                                  ---------------------------------------
                                  -- Control strobes and opcode decode --
                                  ---------------------------------------
--
--
-- bit 0      high when valid and currently low              bit 1 high when valid
--            high when valid and error
--            low for reset
--            low if error and not valid
--            low when valid and currently high
--            low if not valid and currently low
--

    partial_flit_count_d(0) <=  (tlxr_link_up  and tlxr_flit_vld and (tlxr_flit_error or not partial_flit_count_q(0)) ) or        -- MR_ADD INIT => "00"
                                (tlxr_link_up  and not tlxr_flit_vld and partial_flit_count_q(0) and not tlxr_flit_error );

    partial_flit_count_d(1) <=  (tlxr_link_up and tlxr_flit_vld and partial_flit_count_q(0) and not partial_flit_count_q(1) and
                                                           not tlxr_flit_error) or
                                (tlxr_link_up  and (not tlxr_flit_vld or not partial_flit_count_q(0)) and partial_flit_count_q(1) and not tlxr_flit_error );


    fast_act_partial_count_d(0) <= (dlx_tlxr_link_up  and dlx_tlxr_flit_vld and (dlx_tlxr_flit_error or not fast_act_partial_count_q(0)) ) or    -- MR_ADD INIT => "00"
                                   (dlx_tlxr_link_up  and not dlx_tlxr_flit_vld and fast_act_partial_count_q(0) and not dlx_tlxr_flit_error );

    fast_act_partial_count_d(1) <= (dlx_tlxr_link_up and dlx_tlxr_flit_vld and fast_act_partial_count_q(0) and not fast_act_partial_count_q(1) and
                                                              not dlx_tlxr_flit_error) or
                                   (dlx_tlxr_link_up  and (not dlx_tlxr_flit_vld or not fast_act_partial_count_q(0)) and fast_act_partial_count_q(1) and not dlx_tlxr_flit_error );

    dec_ctl_flt <= partial_flit_count_3 and not decoding_data_q and tlxr_flit_vld and not idle_flit;

    decode_ctl_cycle_d(4 downto 0) <= decode_ctl_cycle_q(3 downto 1) & dec_ctl0 & dec_ctl_flt;

    decode_data_cycle_d(4 downto 0) <= GATE( (decode_data_cycle_q(3 downto 0) & (partial_flit_count_3 and decoding_data_q and tlxr_flit_vld)) ,tlxr_link_up and not tlxr_flit_error );
    uc_d(8)  <=  decode_ctl_cycle_d(0) and not DLX_TLXR_FLIT_ERROR;
    dec_ctl0 <= uc_q(8);
    dec_dat0 <= decode_data_cycle_q(0) and not tlxr_flit_error;


    partial_flit_count_0_ne <=  not fast_act_partial_count_q(1) and not fast_act_partial_count_q(0);
    partial_flit_count_1_ne <=  not fast_act_partial_count_q(1) and     fast_act_partial_count_q(0);
    partial_flit_count_2_ne <=      fast_act_partial_count_q(1) and not fast_act_partial_count_q(0);
    partial_flit_count_3_ne <=      fast_act_partial_count_q(1) and     fast_act_partial_count_q(0);

    partial_flit_count_0    <=  (not partial_flit_count_q(1) and not partial_flit_count_q(0)) or tlxr_flit_error;
    partial_flit_count_1    <=   not partial_flit_count_q(1) and     partial_flit_count_q(0) and not tlxr_flit_error;
    partial_flit_count_2    <=       partial_flit_count_q(1) and not partial_flit_count_q(0) and not tlxr_flit_error;
    partial_flit_count_3    <=       partial_flit_count_q(1) and     partial_flit_count_q(0) and not tlxr_flit_error;

    control_flit  <= '1' when data_flits_owed_q = "0000" or
                              (tlxr_flit_error = '1' and last_good_dfo_q = "0000") else '0';

    idle_flit <= '1' when tlxr_flit_data(67 downto 64) > "1000" else '0';       -- idle flits, power management and possibly others

    last_good_dfo_d <= data_flits_owed_q when dec_ctl0 = '1' else last_good_dfo_q;

    dfo <= last_good_dfo_q when tlxr_flit_error = '1' else -- restore this in the case of a backup
           GATE(tlxr_flit_data(67 downto 64),not (tlxr_flit_data(67) and or_reduce(tlxr_flit_data(66 downto 64))))       -- load zero on idle cycles
                                 when (control_flit and partial_flit_count_3 and tlxr_flit_vld) = '1' else               -- loaded on control flit
           data_flits_owed_q(3 downto 0)  - "0001" when (not control_flit and partial_flit_count_3 and tlxr_flit_vld) = '1' else  -- decremented if data flit
           data_flits_owed_q;

    data_flits_owed_d <= GATE(dfo,tlxr_link_up);

    decoding_data_d <= OR_REDUCE(data_flits_owed_q);


    control_flit_next <= not (DLX_TLXR_FLIT_DATA(67) xor or_reduce(DLX_TLXR_FLIT_DATA(66 downto 64)) );          -- 0 or 9-F load 0 into data_flits_owed

    fa_slot0_enab_d <= (control_flit_next and not OR_REDUCE(data_flits_owed_q)) or (data_flits_owed_q(3 downto 0) = "0001")      -- control flit only during partial_flit_count_1_ne
                                            when ( partial_flit_count_3_ne and DLX_TLXR_FLIT_VLD ) = '1'   else
               fa_slot0_enab_q;


-- latch the flit data.
    flit_d(127 downto 0)   <=  tlxr_flit_data when  (partial_flit_count_0 and tlxr_flit_vld) = '1' else flit_q(127 downto 0);
    flit_d(255 downto 128) <=  tlxr_flit_data when  (partial_flit_count_1 and tlxr_flit_vld) = '1' else flit_q(255 downto 128);
    flit_d(383 downto 256) <=  tlxr_flit_data when  (partial_flit_count_2 and tlxr_flit_vld) = '1' else flit_q(383 downto 256);
    flit_d(511 downto 384) <=  tlxr_flit_data when  (partial_flit_count_3 and tlxr_flit_vld) = '1' else flit_q(511 downto 384);

    flit_p_d(15 downto 0)  <=  tlxr_flit_pty  when  (partial_flit_count_0 and tlxr_flit_vld) = '1' else  flit_p_q(15 downto 0);
    flit_p_d(31 downto 16) <=  tlxr_flit_pty  when  (partial_flit_count_1 and tlxr_flit_vld) = '1' else  flit_p_q(31 downto 16);
    flit_p_d(47 downto 32) <=  tlxr_flit_pty  when  (partial_flit_count_2 and tlxr_flit_vld) = '1' else  flit_p_q(47 downto 32);
    flit_p_d(63 downto 48) <=  tlxr_flit_pty  when  (partial_flit_count_3 and tlxr_flit_vld) = '1' else  flit_p_q(63 downto 48);

-- latch some extra address bits for timing
-- ocad_d(23 downto 20) <=  flit_q(255 downto 252) when (partial_flit_count_3 and tlxr_flit_vld) = '1' else ocad_q(23 downto 20);
-- ocad_d(19 downto  0) <=  flit_q(383 downto 364) when (partial_flit_count_3 and tlxr_flit_vld) = '1' else ocad_q(19 downto 0);

-- latch the 8 byte parity for checking
    flit8par(1 downto 0) <=  XOR_REDUCE(tlxr_flit_pty(15 downto 8)) & XOR_REDUCE(tlxr_flit_pty(7 downto 0));

    flit_8bp_d(1 downto 0) <=  flit8par when  (partial_flit_count_0 and tlxr_flit_vld) = '1' else flit_8bp_q(1 downto 0);
    flit_8bp_d(3 downto 2) <=  flit8par when  (partial_flit_count_1 and tlxr_flit_vld) = '1' else flit_8bp_q(3 downto 2);
    flit_8bp_d(5 downto 4) <=  flit8par when  (partial_flit_count_2 and tlxr_flit_vld) = '1' else flit_8bp_q(5 downto 4);
    flit_8bp_d(7 downto 6) <=  flit8par when  (partial_flit_count_3 and tlxr_flit_vld) = '1' else flit_8bp_q(7 downto 6);

flit_par_gen: for i in 0 to 63 generate   -- even parity check
   begin
    flit_perr(i) <= '1' when XOR_REDUCE(flit_q(i*8+7 downto i*8)) /= flit_p_q(i) else '0';
end generate flit_par_gen;

-- Since we receive in 16-byte chunks, but decode commands in 14-byte chunks, there is a hazard of overwriting slots before we use them.
-- So stash up to 6 bytes away, so we can present 14-byte chunks that remain valid.

    flit_held_d <= flit_q(127 downto 112) & flit_held_q(111 downto 80) when decode_ctl_cycle_q(0) = '1' -- 15 nov dec_ctl0 = '1'
              else flit_q(255 downto 224) & flit_held_q( 95 downto 80) when decode_ctl_cycle_q(1) = '1'
              else flit_q(383 downto 336)                              when decode_ctl_cycle_q(2) = '1'
              else flit_held_q;

    flit_30 <= flit_q(111 downto 0);                                                              -- valid cycle 0 only
    flit_74 <= flit_q(223 downto 128) & flit_held_q(127 downto 112) when decode_ctl_cycle_q(1) = '1' -- valid cycles 0 and 1
          else flit_q(223 downto 112);
    flit_B8 <= flit_q(335 downto 256) & flit_held_q(127 downto  96) when decode_ctl_cycle_q(2)  ='1' -- valid cycles 0,1 and 2
          else flit_q(335 downto 224);
    flit_FC <= flit_q(447 downto 384) & flit_held_q(127 downto  80) when decode_ctl_cycle_q(3)  ='1' -- valid cycles 0,1,2 and 3
          else flit_q(447 downto 336);

    bar_minus_1 <= CFG_F1_CSH_MMIO_BAR0(63 downto 35)-(x"0000000"&'1');

opcode_gen: for i in 0 to 3 generate
    signal a63_35 : std_ulogic_vector(63 downto 35);
    signal a34_5  : std_ulogic_vector(34 downto 5);
    begin

    -- When i=3, only flit_q(383:0) are valid. So compare against incoming flit.
    -- If this won't time, we may need to consider delaying the i=3 addr compare to the next cycle,
    -- and do using_command(3) at the earliest in the 2nd clock cycle (even if all earlier slots are empty).
    a63_35 <= tlxr_flit_data(43 downto 15) when i=3 else flit_q(i*112+91 downto i*112+63);
    a34_5  <= tlxr_flit_data(14 downto 0) & flit_q(383 downto 369) when i=3 else flit_q(i*112+62 downto i*112+33);

    patt_addr(i) <= '1' when a63_35 = bar_minus_1 and a34_5=(34 downto 5=>'1') and cfg_half_dimm_mode_q = '1' else '0';

    mmio_addr(i) <= '1' when (a63_35 = CFG_F1_CSH_MMIO_BAR0(63 downto 35)) and CFG_F1_CSH_MEMORY_SPACE = '1' else '0';
           --       8       1 = length format is 2 bits, 0 length format is three bits (or missing).
           -- partop7 means it's a valid 4-slot command
           --       6 means it needs byte enables sent to WDF
           --       5 means it's +physaddr/-(mmio/config) (no xlate) ie 1 for xlate
           --       4 means it's +read/-write [+no_buffer_needed/-buffer_needed] [+tag_to_srq/-bufnos_to_srq]
--   9 is NO A5 from OC for something going to DDR
                --                             BeToWDF
                --                             :XlateToPhysAddr
                --                     CmdValid:|NoWriteData
                --                  ContainsDL|:||RequestType(use codes C-F for commands not actually sent to sequencer)
                --             no A5 ........||:||::::
                --                         P9876543210
         pop(i*11+10 downto i*11) <= GATE("11011100010",(flit_q(i*112+7 downto i*112) = x"82") and not shutdown)                        or
                                     GATE("10011101111",(flit_q(i*112+7 downto i*112) = x"86") and patt_addr(i) = '1' and not shutdown) or
                                     GATE("10010000101",(flit_q(i*112+7 downto i*112) = x"86") and mmio_addr(i) = '1' and not shutdown) or -- be
                                     GATE("00011100010",(flit_q(i*112+7 downto i*112) = x"86") and mmio_addr(i) = '0' and not shutdown) or
                                     GATE("11110100001",(flit_q(i*112+7 downto i*112) = x"81") and not shutdown)                        or
                                     GATE("00110110000",(flit_q(i*112+7 downto i*112) = x"20") and not shutdown)                        or
                                     GATE("10010110000",(flit_q(i*112+7 downto i*112) = x"28") and mmio_addr(i) = '0' and not shutdown) or
                                     GATE("10010010100",(flit_q(i*112+7 downto i*112) = x"28") and mmio_addr(i) = '1' and not shutdown) or
                                     GATE("10010011000",(flit_q(i*112+7 downto i*112) = x"E0") and not shutdown) or
                                     GATE("10010001001",(flit_q(i*112+7 downto i*112) = x"E1") and not shutdown) or
                                     GATE("00110110011",(flit_q(i*112+7 downto i*112) = x"80") and not shutdown) or
                                     GATE("00010011100",(flit_q(i*112+7 downto i*112) = x"EF") and not shutdown) or
                                     GATE("10010011110",(flit_q(i*112+7 downto i*112) = x"22") and not shutdown) ;    -- mem_pfch

end generate opcode_gen;

-- need to disable any control flits in templates 7 and 10 slots 0/4/8 and template 0 slots 8/12
    part_op(43 downto 33) <= pop(43 downto 33) when template_0 = '0' else (pop(43) xor pop(40)) & pop(42 downto 41) & '0' & pop(39 downto 33);
    part_op(32 downto 22) <= pop(32 downto 22) when (template_0 or template_7 or template_A) = '0' else (pop(32) xor pop(29)) & pop(31 downto 30) & '0' & pop(28 downto 22);  -- templates do not allow these
    part_op(21 downto 11) <= pop(21 downto 11) when template_7 = '0' and template_A = '0' else (pop(21) xor pop(18)) & pop(20 downto 19) & '0' & pop(17 downto  11);           --  "
    part_op(10 downto  0) <= pop(10 downto  0) when template_7 = '0' and template_A = '0' else (pop(10) xor pop(7)) & pop(9 downto 8)  & '0' & pop( 6 downto  0);              --  "


    op_held_d <= part_op when dec_ctl_flt = '1' else op_held_q;

    op_held_perr <= XOR_REDUCE(op_held_q(43 downto 33) ) or  XOR_REDUCE(op_held_q(32 downto 22) ) or
                    XOR_REDUCE(op_held_q(21 downto 11) ) or  XOR_REDUCE(op_held_q(10 downto  0) );

    template_0  <= tlxr_link_up when tlxr_flit_data(81 downto 76) = "000000" and control_flit  = '1' else  '0';
    template_4  <= tlxr_link_up when tlxr_flit_data(81 downto 76) = "000100" and control_flit  = '1' else  '0';
    template_7  <= tlxr_link_up when tlxr_flit_data(81 downto 76) = "000111" and control_flit  = '1' else  '0';
    template_A  <= tlxr_link_up when tlxr_flit_data(81 downto 76) = "001010" and control_flit  = '1' else  '0';

    template_7_d <= (template_7 and partial_flit_count_3 and tlxr_flit_vld) or ((not partial_flit_count_3 or not tlxr_flit_vld) and template_7_q);
    template_4_d <= (template_4 and partial_flit_count_3 and tlxr_flit_vld) or ((not partial_flit_count_3 or not tlxr_flit_vld) and template_4_q);
    template_0_d <= (template_0 and partial_flit_count_3 and tlxr_flit_vld) or ((not partial_flit_count_3 or not tlxr_flit_vld) and template_0_q);
    template_A_d <= (template_A and partial_flit_count_3 and tlxr_flit_vld) or ((not partial_flit_count_3 or not tlxr_flit_vld) and template_A_q);

    unknown_template <=  dec_ctl0 and
                           not (
                                 not  OR_REDUCE(flit_q(465 downto 461))                 or                -- zero or one
                                 not  OR_REDUCE(flit_q(465 downto 460) xor "000100")    or                -- four
                                 not  OR_REDUCE(flit_q(465 downto 460) xor "000111")    or                -- seven
                                (not OR_REDUCE(flit_q(465 downto 460) xor "001010") ) -- A in non half dimm mode now ok
                               );

                                  -------------------
                                  -- FAST ACTIVATE --

XLAT_FAST_a: entity work.cb_tlxr_xlat
 GENERIC MAP( fast => true)
 PORT MAP(
      vdd                            =>  vdd,                                     --   : inout power_logic
      gnd                            =>  gnd,                                     --   : inout power_logic
      addr                           =>  dlx_tlxr_fast_act_info_a,                --   : IN   std_ulogic_vector(34 downto 0)
      addr4                          =>  '0',                                     --
      HALF_DIMM_MODE                 =>  cfg_half_dimm_mode_q,
      cfg_xlt_slot0_valid            =>  MCB_TLXR_xlt_slot0_valid,
      cfg_xlt_slot1_valid            =>  MCB_TLXR_xlt_slot1_valid,
      cfg_xlt_slot0_d_value          =>  MCB_TLXR_xlt_slot0_d_value,
      cfg_xlt_slot1_d_value          =>  MCB_TLXR_xlt_slot1_d_value,
      cfg_xlt_slot0_m0_valid         =>  MCB_TLXR_xlt_slot0_m0_valid,             --   : IN   std_ulogic    1
      cfg_xlt_slot0_m1_valid         =>  MCB_TLXR_xlt_slot0_m1_valid,             --   : IN   std_ulogic    1
      cfg_xlt_slot0_s0_valid         =>  MCB_TLXR_xlt_slot0_s0_valid,             --   : IN   std_ulogic    0
      cfg_xlt_slot0_s1_valid         =>  MCB_TLXR_xlt_slot0_s1_valid,             --   : IN   std_ulogic    0
      cfg_xlt_slot0_s2_valid         =>  MCB_TLXR_xlt_slot0_s2_valid,             --   : IN   std_ulogic    0
      cfg_xlt_slot0_r15_valid        =>  MCB_TLXR_xlt_slot0_r15_valid,            --   : IN   std_ulogic    0
      cfg_xlt_slot0_r16_valid        =>  MCB_TLXR_xlt_slot0_r16_valid,            --   : IN   std_ulogic    0
      cfg_xlt_slot0_r17_valid        =>  MCB_TLXR_xlt_slot0_r17_valid,            --   : IN   std_ulogic    0
      cfg_xlt_slot1_m0_valid         =>  MCB_TLXR_xlt_slot1_m0_valid,
      cfg_xlt_slot1_m1_valid         =>  MCB_TLXR_xlt_slot1_m1_valid,
      cfg_xlt_slot1_s0_valid         =>  MCB_TLXR_xlt_slot1_s0_valid,
      cfg_xlt_slot1_s1_valid         =>  MCB_TLXR_xlt_slot1_s1_valid,
      cfg_xlt_slot1_s2_valid         =>  MCB_TLXR_xlt_slot1_s2_valid,
      cfg_xlt_slot1_r15_valid        =>  MCB_TLXR_xlt_slot1_r15_valid,
      cfg_xlt_slot1_r16_valid        =>  MCB_TLXR_xlt_slot1_r16_valid,
      cfg_xlt_slot1_r17_valid        =>  MCB_TLXR_xlt_slot1_r17_valid,
      cfg_xlt_d_bit_map              =>  MCB_TLXR_xlt_d_bit_map,
      cfg_xlt_m0_bit_map             =>  MCB_TLXR_xlt_m0_bit_map,                 --   : IN   std_ulogic_vector(0 to  2)    111       37
      cfg_xlt_m1_bit_map             =>  MCB_TLXR_xlt_m1_bit_map,                 --   : IN   std_ulogic_vector(0 to  4)     0011 0    master rank 1 =a6
      cfg_xlt_s0_bit_map             =>  MCB_TLXR_xlt_s0_bit_map,                 --   : IN   std_ulogic_vector(0 to  4)    111 11
      cfg_xlt_s1_bit_map             =>  MCB_TLXR_xlt_s1_bit_map,                 --   : IN   std_ulogic_vector(0 to  4)    11 111
      cfg_xlt_s2_bit_map             =>  MCB_TLXR_xlt_s2_bit_map,                 --   : IN   std_ulogic_vector(0 to  4)    1 1111    37FFF
      cfg_xlt_r17_bit_map            =>  MCB_TLXR_xlt_r17_bit_map,                --   : IN   std_ulogic_vector(0 to  2)    111
      cfg_xlt_r16_bit_map            =>  MCB_TLXR_xlt_r16_bit_map,                --   : IN   std_ulogic_vector(0 to  2)    1 11
      cfg_xlt_r15_bit_map            =>  MCB_TLXR_xlt_r15_bit_map,                --   : IN   std_ulogic_vector(0 to  2)    11 1
      cfg_xlt_c3_bit_map             =>  MCB_TLXR_xlt_c3_bit_map,                 --   : IN   std_ulogic_vector(0 to  4)     001 11 col4 = a27 = oc12
      cfg_xlt_c4_bit_map             =>  MCB_TLXR_xlt_c4_bit_map,                 --   : IN   std_ulogic_vector(0 to  4)     001 11 col4 = a27 = oc12
      cfg_xlt_c5_bit_map             =>  MCB_TLXR_xlt_c5_bit_map,                 --   : IN   std_ulogic_vector(0 to  4)     00 111 col5 = a26 = oc13
      cfg_xlt_c6_bit_map             =>  MCB_TLXR_xlt_c6_bit_map,                 --   : IN   std_ulogic_vector(0 to  4)     0 0111 col6 = a25 = oc14   ff9ce7
      cfg_xlt_c7_bit_map             =>  MCB_TLXR_xlt_c7_bit_map,                 --   : IN   std_ulogic_vector(0 to  4)     0011 1 col7 = a24 = oc15
      cfg_xlt_c8_bit_map             =>  MCB_TLXR_xlt_c8_bit_map,                 --   : IN   std_ulogic_vector(0 to  4)     001 11 col8 = a23 =oc16
      cfg_xlt_c9_bit_map             =>  MCB_TLXR_xlt_c9_bit_map,                 --   : IN   std_ulogic_vector(0 to  4)     00 111 col9 = a7 = oc32
      cfg_xlt_b0_bit_map             =>  MCB_TLXR_xlt_b0_bit_map,                 --   : IN   std_ulogic_vector(0 to  4)      0 0101 bank0 = 29 10      39ce5
      cfg_xlt_b1_bit_map             =>  MCB_TLXR_xlt_b1_bit_map,                 --   : IN   std_ulogic_vector(0 to  4)      0010 1 bank1 = 30 = oc 9
      cfg_xlt_bg0_bit_map            =>  MCB_TLXR_xlt_bg0_bit_map,                --   : IN   std_ulogic_vector(0 to  4)      000 11 bg0= 31 = oc 8
      cfg_xlt_bg1_bit_map            =>  MCB_TLXR_xlt_bg1_bit_map,                --   : IN   std_ulogic_vector(0 to  4)      00 010 bg1= 32 = oc7
      enable_row_addr_hash           =>  mcb_tlxr_enab_row_addr_hash,             --   : IN   std_ulogic
-- outputs                                                                        --
      dimm                           =>  tlxr_srq_fast_dimm_a,
      addr_error                     =>  open,
      mrank                          =>  tlxr_srq_fast_addr_i_a(4 to 5),            --   : OUT  std_ulogic_vector(0 to 1)
      srank                          =>  tlxr_srq_fast_addr_i_a(6 to 8),            --   : OUT  std_ulogic_vector(0 to 2)
      bank                           =>  tlxr_srq_fast_addr_i_a(2 to 3),            --   : OUT  std_ulogic_vector(0 to 1)
      bank_group                     =>  tlxr_srq_fast_addr_i_a(0 to 1),            --   : OUT  std_ulogic_vector(0 to 1)
      row                            =>  tlxr_srq_fast_addr_i_a(9 to 26),           --   : OUT  std_ulogic_vector(0 to 17)
      fast_decode                    =>  open,                           --   : output from cb_tlxr_xlat
      col                            =>  open                                     --   : OUT  std_ulogic_vector(2 to  9)
);                                 -------------------                                                        --             unlatched bits available

XLAT_FAST_b: entity work.cb_tlxr_xlat
 GENERIC MAP( fast => true)
 PORT MAP(
      vdd                            =>  vdd,                                     --   : inout power_logic
      gnd                            =>  gnd,                                     --   : inout power_logic
      addr                           =>  dlx_tlxr_fast_act_info_b,                  --   : IN   std_ulogic_vector(34 downto 0)
      addr4                          =>  '0',                                     --
      HALF_DIMM_MODE                 =>  cfg_half_dimm_mode_q,
      cfg_xlt_slot0_valid            =>  MCB_TLXR_xlt_slot0_valid,
      cfg_xlt_slot1_valid            =>  MCB_TLXR_xlt_slot1_valid,
      cfg_xlt_slot0_d_value          =>  MCB_TLXR_xlt_slot0_d_value,
      cfg_xlt_slot1_d_value          =>  MCB_TLXR_xlt_slot1_d_value,
      cfg_xlt_slot0_m0_valid         =>  MCB_TLXR_xlt_slot0_m0_valid,             --   : IN   std_ulogic    1
      cfg_xlt_slot0_m1_valid         =>  MCB_TLXR_xlt_slot0_m1_valid,             --   : IN   std_ulogic    1
      cfg_xlt_slot0_s0_valid         =>  MCB_TLXR_xlt_slot0_s0_valid,             --   : IN   std_ulogic    0
      cfg_xlt_slot0_s1_valid         =>  MCB_TLXR_xlt_slot0_s1_valid,             --   : IN   std_ulogic    0
      cfg_xlt_slot0_s2_valid         =>  MCB_TLXR_xlt_slot0_s2_valid,             --   : IN   std_ulogic    0
      cfg_xlt_slot0_r15_valid        =>  MCB_TLXR_xlt_slot0_r15_valid,            --   : IN   std_ulogic    0
      cfg_xlt_slot0_r16_valid        =>  MCB_TLXR_xlt_slot0_r16_valid,            --   : IN   std_ulogic    0
      cfg_xlt_slot0_r17_valid        =>  MCB_TLXR_xlt_slot0_r17_valid,            --   : IN   std_ulogic    0
      cfg_xlt_slot1_m0_valid         =>  MCB_TLXR_xlt_slot1_m0_valid,
      cfg_xlt_slot1_m1_valid         =>  MCB_TLXR_xlt_slot1_m1_valid,
      cfg_xlt_slot1_s0_valid         =>  MCB_TLXR_xlt_slot1_s0_valid,
      cfg_xlt_slot1_s1_valid         =>  MCB_TLXR_xlt_slot1_s1_valid,
      cfg_xlt_slot1_s2_valid         =>  MCB_TLXR_xlt_slot1_s2_valid,
      cfg_xlt_slot1_r15_valid        =>  MCB_TLXR_xlt_slot1_r15_valid,
      cfg_xlt_slot1_r16_valid        =>  MCB_TLXR_xlt_slot1_r16_valid,
      cfg_xlt_slot1_r17_valid        =>  MCB_TLXR_xlt_slot1_r17_valid,
      cfg_xlt_d_bit_map              =>  MCB_TLXR_xlt_d_bit_map,
      cfg_xlt_m0_bit_map             =>  MCB_TLXR_xlt_m0_bit_map,                 --   : IN   std_ulogic_vector(0 to  2)    111       37
      cfg_xlt_m1_bit_map             =>  MCB_TLXR_xlt_m1_bit_map,                 --   : IN   std_ulogic_vector(0 to  4)     0011 0    master rank 1 =a6
      cfg_xlt_s0_bit_map             =>  MCB_TLXR_xlt_s0_bit_map,                 --   : IN   std_ulogic_vector(0 to  4)    111 11
      cfg_xlt_s1_bit_map             =>  MCB_TLXR_xlt_s1_bit_map,                 --   : IN   std_ulogic_vector(0 to  4)    11 111
      cfg_xlt_s2_bit_map             =>  MCB_TLXR_xlt_s2_bit_map,                 --   : IN   std_ulogic_vector(0 to  4)    1 1111    37FFF
      cfg_xlt_r17_bit_map            =>  MCB_TLXR_xlt_r17_bit_map,                --   : IN   std_ulogic_vector(0 to  2)    111
      cfg_xlt_r16_bit_map            =>  MCB_TLXR_xlt_r16_bit_map,                --   : IN   std_ulogic_vector(0 to  2)    1 11
      cfg_xlt_r15_bit_map            =>  MCB_TLXR_xlt_r15_bit_map,                --   : IN   std_ulogic_vector(0 to  2)    11 1
      cfg_xlt_c3_bit_map             =>  MCB_TLXR_xlt_c3_bit_map,                 --   : IN   std_ulogic_vector(0 to  4)     001 11 col4 = a27 = oc12
      cfg_xlt_c4_bit_map             =>  MCB_TLXR_xlt_c4_bit_map,                 --   : IN   std_ulogic_vector(0 to  4)     001 11 col4 = a27 = oc12
      cfg_xlt_c5_bit_map             =>  MCB_TLXR_xlt_c5_bit_map,                 --   : IN   std_ulogic_vector(0 to  4)     00 111 col5 = a26 = oc13
      cfg_xlt_c6_bit_map             =>  MCB_TLXR_xlt_c6_bit_map,                 --   : IN   std_ulogic_vector(0 to  4)     0 0111 col6 = a25 = oc14   ff9ce7
      cfg_xlt_c7_bit_map             =>  MCB_TLXR_xlt_c7_bit_map,                 --   : IN   std_ulogic_vector(0 to  4)     0011 1 col7 = a24 = oc15
      cfg_xlt_c8_bit_map             =>  MCB_TLXR_xlt_c8_bit_map,                 --   : IN   std_ulogic_vector(0 to  4)     001 11 col8 = a23 =oc16
      cfg_xlt_c9_bit_map             =>  MCB_TLXR_xlt_c9_bit_map,                 --   : IN   std_ulogic_vector(0 to  4)     00 111 col9 = a7 = oc32
      cfg_xlt_b0_bit_map             =>  MCB_TLXR_xlt_b0_bit_map,                 --   : IN   std_ulogic_vector(0 to  4)      0 0101 bank0 = 29 10      39ce5
      cfg_xlt_b1_bit_map             =>  MCB_TLXR_xlt_b1_bit_map,                 --   : IN   std_ulogic_vector(0 to  4)      0010 1 bank1 = 30 = oc 9
      cfg_xlt_bg0_bit_map            =>  MCB_TLXR_xlt_bg0_bit_map,                --   : IN   std_ulogic_vector(0 to  4)      000 11 bg0= 31 = oc 8
      cfg_xlt_bg1_bit_map            =>  MCB_TLXR_xlt_bg1_bit_map,                --   : IN   std_ulogic_vector(0 to  4)      00 010 bg1= 32 = oc7
      enable_row_addr_hash           =>  mcb_tlxr_enab_row_addr_hash,             --   : IN   std_ulogic
-- outputs                                                                        --
      dimm                           =>  tlxr_srq_fast_dimm_b,
      addr_error                     =>  open,
      mrank                          =>  tlxr_srq_fast_addr_i_b(4 to 5),            --   : OUT  std_ulogic_vector(0 to 1)
      srank                          =>  tlxr_srq_fast_addr_i_b(6 to 8),            --   : OUT  std_ulogic_vector(0 to 2)
      bank                           =>  tlxr_srq_fast_addr_i_b(2 to 3),            --   : OUT  std_ulogic_vector(0 to 1)
      bank_group                     =>  tlxr_srq_fast_addr_i_b(0 to 1),            --   : OUT  std_ulogic_vector(0 to 1)
      row                            =>  tlxr_srq_fast_addr_i_b(9 to 26),           --   : OUT  std_ulogic_vector(0 to 17)
      fast_decode                    =>  open,                           --   : output from cb_tlxr_xlat
      col                            =>  open                                     --   : OUT  std_ulogic_vector(2 to  9)
);                                 -------------------                                                        --             unlatched bits available

XLAT_FAST: entity work.cb_tlxr_xlat
 GENERIC MAP( fast => true)
 PORT MAP(
      vdd                            =>  vdd,                                     --   : inout power_logic
      gnd                            =>  gnd,                                     --   : inout power_logic
      addr                           =>  dlx_tlxr_fast_act_info,                  --   : IN   std_ulogic_vector(34 downto 0)
      addr4                          =>  '0',                                     --
      HALF_DIMM_MODE                 =>  cfg_half_dimm_mode_q,
      cfg_xlt_slot0_valid            =>  MCB_TLXR_xlt_slot0_valid,
      cfg_xlt_slot1_valid            =>  MCB_TLXR_xlt_slot1_valid,
      cfg_xlt_slot0_d_value          =>  MCB_TLXR_xlt_slot0_d_value,
      cfg_xlt_slot1_d_value          =>  MCB_TLXR_xlt_slot1_d_value,
      cfg_xlt_slot0_m0_valid         =>  MCB_TLXR_xlt_slot0_m0_valid,             --   : IN   std_ulogic    1
      cfg_xlt_slot0_m1_valid         =>  MCB_TLXR_xlt_slot0_m1_valid,             --   : IN   std_ulogic    1
      cfg_xlt_slot0_s0_valid         =>  MCB_TLXR_xlt_slot0_s0_valid,             --   : IN   std_ulogic    0
      cfg_xlt_slot0_s1_valid         =>  MCB_TLXR_xlt_slot0_s1_valid,             --   : IN   std_ulogic    0
      cfg_xlt_slot0_s2_valid         =>  MCB_TLXR_xlt_slot0_s2_valid,             --   : IN   std_ulogic    0
      cfg_xlt_slot0_r15_valid        =>  MCB_TLXR_xlt_slot0_r15_valid,            --   : IN   std_ulogic    0
      cfg_xlt_slot0_r16_valid        =>  MCB_TLXR_xlt_slot0_r16_valid,            --   : IN   std_ulogic    0
      cfg_xlt_slot0_r17_valid        =>  MCB_TLXR_xlt_slot0_r17_valid,            --   : IN   std_ulogic    0
      cfg_xlt_slot1_m0_valid         =>  MCB_TLXR_xlt_slot1_m0_valid,
      cfg_xlt_slot1_m1_valid         =>  MCB_TLXR_xlt_slot1_m1_valid,
      cfg_xlt_slot1_s0_valid         =>  MCB_TLXR_xlt_slot1_s0_valid,
      cfg_xlt_slot1_s1_valid         =>  MCB_TLXR_xlt_slot1_s1_valid,
      cfg_xlt_slot1_s2_valid         =>  MCB_TLXR_xlt_slot1_s2_valid,
      cfg_xlt_slot1_r15_valid        =>  MCB_TLXR_xlt_slot1_r15_valid,
      cfg_xlt_slot1_r16_valid        =>  MCB_TLXR_xlt_slot1_r16_valid,
      cfg_xlt_slot1_r17_valid        =>  MCB_TLXR_xlt_slot1_r17_valid,
      cfg_xlt_d_bit_map              =>  MCB_TLXR_xlt_d_bit_map,
      cfg_xlt_m0_bit_map             =>  MCB_TLXR_xlt_m0_bit_map,                 --   : IN   std_ulogic_vector(0 to  2)    111       37
      cfg_xlt_m1_bit_map             =>  MCB_TLXR_xlt_m1_bit_map,                 --   : IN   std_ulogic_vector(0 to  4)     0011 0    master rank 1 =a6
      cfg_xlt_s0_bit_map             =>  MCB_TLXR_xlt_s0_bit_map,                 --   : IN   std_ulogic_vector(0 to  4)    111 11
      cfg_xlt_s1_bit_map             =>  MCB_TLXR_xlt_s1_bit_map,                 --   : IN   std_ulogic_vector(0 to  4)    11 111
      cfg_xlt_s2_bit_map             =>  MCB_TLXR_xlt_s2_bit_map,                 --   : IN   std_ulogic_vector(0 to  4)    1 1111    37FFF
      cfg_xlt_r17_bit_map            =>  MCB_TLXR_xlt_r17_bit_map,                --   : IN   std_ulogic_vector(0 to  2)    111
      cfg_xlt_r16_bit_map            =>  MCB_TLXR_xlt_r16_bit_map,                --   : IN   std_ulogic_vector(0 to  2)    1 11
      cfg_xlt_r15_bit_map            =>  MCB_TLXR_xlt_r15_bit_map,                --   : IN   std_ulogic_vector(0 to  2)    11 1
      cfg_xlt_c3_bit_map             =>  MCB_TLXR_xlt_c3_bit_map,                 --   : IN   std_ulogic_vector(0 to  4)     001 11 col4 = a27 = oc12
      cfg_xlt_c4_bit_map             =>  MCB_TLXR_xlt_c4_bit_map,                 --   : IN   std_ulogic_vector(0 to  4)     001 11 col4 = a27 = oc12
      cfg_xlt_c5_bit_map             =>  MCB_TLXR_xlt_c5_bit_map,                 --   : IN   std_ulogic_vector(0 to  4)     00 111 col5 = a26 = oc13
      cfg_xlt_c6_bit_map             =>  MCB_TLXR_xlt_c6_bit_map,                 --   : IN   std_ulogic_vector(0 to  4)     0 0111 col6 = a25 = oc14   ff9ce7
      cfg_xlt_c7_bit_map             =>  MCB_TLXR_xlt_c7_bit_map,                 --   : IN   std_ulogic_vector(0 to  4)     0011 1 col7 = a24 = oc15
      cfg_xlt_c8_bit_map             =>  MCB_TLXR_xlt_c8_bit_map,                 --   : IN   std_ulogic_vector(0 to  4)     001 11 col8 = a23 =oc16
      cfg_xlt_c9_bit_map             =>  MCB_TLXR_xlt_c9_bit_map,                 --   : IN   std_ulogic_vector(0 to  4)     00 111 col9 = a7 = oc32
      cfg_xlt_b0_bit_map             =>  MCB_TLXR_xlt_b0_bit_map,                 --   : IN   std_ulogic_vector(0 to  4)      0 0101 bank0 = 29 10      39ce5
      cfg_xlt_b1_bit_map             =>  MCB_TLXR_xlt_b1_bit_map,                 --   : IN   std_ulogic_vector(0 to  4)      0010 1 bank1 = 30 = oc 9
      cfg_xlt_bg0_bit_map            =>  MCB_TLXR_xlt_bg0_bit_map,                --   : IN   std_ulogic_vector(0 to  4)      000 11 bg0= 31 = oc 8
      cfg_xlt_bg1_bit_map            =>  MCB_TLXR_xlt_bg1_bit_map,                --   : IN   std_ulogic_vector(0 to  4)      00 010 bg1= 32 = oc7
      enable_row_addr_hash           =>  mcb_tlxr_enab_row_addr_hash,             --   : IN   std_ulogic
-- outputs                                                                        --
      dimm                           =>  tlxr_srq_fast_dimm,
      addr_error                     =>  open,
      mrank                          =>  tlxr_srq_fast_addr_i(4 to 5),            --   : OUT  std_ulogic_vector(0 to 1)
      srank                          =>  tlxr_srq_fast_addr_i(6 to 8),            --   : OUT  std_ulogic_vector(0 to 2)
      bank                           =>  tlxr_srq_fast_addr_i(2 to 3),            --   : OUT  std_ulogic_vector(0 to 1)
      bank_group                     =>  tlxr_srq_fast_addr_i(0 to 1),            --   : OUT  std_ulogic_vector(0 to 1)
      row                            =>  tlxr_srq_fast_addr_i(9 to 26),           --   : OUT  std_ulogic_vector(0 to 17)
      fast_decode                    =>  open,                                    --   : output from cb_tlxr_xlat
      col                            =>  open                                     --   : OUT  std_ulogic_vector(2 to  9)
);


    --TLXR_SRQ_FAST_ACT_VAL   <= fast_decode_q and DLX_TLXR_IDLE_TRANSITION;
    TLXR_SRQ_FAST_ACT_VAL   <= DLX_TLXR_IDLE_TRANSITION;
    TLXR_SRQ_FAST_ADDR      <= tlxr_srq_fast_addr_i;

    --TLXR_SRQ_FAST_ACT_VAL_a   <= fast_decode_a_q and DLX_TLXR_IDLE_TRANSITION_a;
    TLXR_SRQ_FAST_ACT_VAL_a   <=  DLX_TLXR_IDLE_TRANSITION_a;
    TLXR_SRQ_FAST_ADDR_a      <= tlxr_srq_fast_addr_i_a;

    --TLXR_SRQ_FAST_ACT_VAL_b   <= fast_decode_b_q and DLX_TLXR_IDLE_TRANSITION_b;
    TLXR_SRQ_FAST_ACT_VAL_b   <=  DLX_TLXR_IDLE_TRANSITION_b;
    TLXR_SRQ_FAST_ADDR_b      <= tlxr_srq_fast_addr_i_b;

                                  ------------------------
                                  -- FAST ACTIVATE FIFO --
                                  ------------------------
-- This structure will queue row activate commands for memory reads to offset the time it takes for the command to propagate to the RRQ
    --     Command bits 27:13 are "reserved" and should be zero in a valid read (are we allowed to check?)
    --     Rd in slot0 only possible if valid opcode in slot4.
    --     Rd in slot4 only possible if valid opcode in slot0.
    --     Rd in slot8 only possible if valid opcodes in slots 0,4,12 (and slot4 is not write_membe)
    --     Rd in slot12 only possible if template is not 0.

    prev_beat0 <= tlxr_flit_data(127 downto 0) when tlxr_flit_vld='1' else flit_q(127 downto   0);
    prev_beat1 <= tlxr_flit_data(127 downto 0) when tlxr_flit_vld='1' else flit_q(255 downto 128);
    prev_beat2 <= tlxr_flit_data(127 downto 0) when tlxr_flit_vld='1' else flit_q(383 downto 256);

    fast_act_fifo_wr                   <= '1' when
                                       ((DLX_TLXR_FLIT_VLD and partial_flit_count_0_ne) = '1' and fa_slot0_enab_q = '1'  and    -- first beat of a flit  (slot 0)
                                        DLX_TLXR_FLIT_DATA(7 downto 4) = "0010"      and DLX_TLXR_FLIT_DATA(2 downto 0) = "000" and                   -- check slot 4
                                        ( DLX_TLXR_FLIT_DATA(119 downto 112) = x"00" or DLX_TLXR_FLIT_DATA(119 downto 112) = x"0C" or
                                          DLX_TLXR_FLIT_DATA(119 downto 112) = x"E0" or DLX_TLXR_FLIT_DATA(119 downto 112) = x"E1" or
                                          DLX_TLXR_FLIT_DATA(119 downto 112) = x"28" or DLX_TLXR_FLIT_DATA(119 downto 112) = x"20" or
                                          DLX_TLXR_FLIT_DATA(119 downto 112) = x"80" or DLX_TLXR_FLIT_DATA(119 downto 112) = x"EF" or
                                          DLX_TLXR_FLIT_DATA(119 downto 112) = x"81" or DLX_TLXR_FLIT_DATA(119 downto 112) = x"86" or
                                          DLX_TLXR_FLIT_DATA(119 downto 112) = x"1A" ) and
                                        (
                                          DLX_TLXR_FLIT_DATA(91 downto 63) /= CFG_F1_CSH_MMIO_BAR0(63 downto 35) or
                                          CFG_F1_CSH_MEMORY_SPACE = '0' )
                                       )                         or
                                       ((DLX_TLXR_FLIT_VLD and partial_flit_count_1_ne)  = '1' and data_flits_owed_q = "0000" and         -- second beat of a flit (slot 4)
                                         prev_beat0    (119 downto 116) = "0010" and prev_beat0    (114 downto 112) = "000" and           -- check slots 0 and 8
                                         (prev_beat0    (7 downto 0) = x"00" or prev_beat0    (7 downto 0) = x"0C" or
                                          prev_beat0    (7 downto 0) = x"E0" or prev_beat0    (7 downto 0) = x"E1" or
                                          prev_beat0    (7 downto 0) = x"28" or prev_beat0    (7 downto 0) = x"20" or
                                          prev_beat0    (7 downto 0) = x"80" or prev_beat0    (7 downto 0) = x"EF" or
                                          prev_beat0    (7 downto 0) = x"81" or prev_beat0    (7 downto 0) = x"86" or
                                          prev_beat0    (7 downto 0) = x"01" or prev_beat0    (7 downto 0) = x"1A" ) and
                                        ( DLX_TLXR_FLIT_DATA(103 downto 96) = x"00" or DLX_TLXR_FLIT_DATA(103 downto 96) = x"0C" or
                                          DLX_TLXR_FLIT_DATA(103 downto 96) = x"E0" or DLX_TLXR_FLIT_DATA(103 downto 96) = x"E1" or
                                          DLX_TLXR_FLIT_DATA(103 downto 96) = x"28" or DLX_TLXR_FLIT_DATA(103 downto 96) = x"20" or
                                          DLX_TLXR_FLIT_DATA(103 downto 96) = x"80" or DLX_TLXR_FLIT_DATA(103 downto 96) = x"EF" or
                                          DLX_TLXR_FLIT_DATA(103 downto 96) = x"81" or DLX_TLXR_FLIT_DATA(103 downto 96) = x"86" or
                                          DLX_TLXR_FLIT_DATA(103 downto 96) = x"1A") and
                                        (
                                             DLX_TLXR_FLIT_DATA(75 downto 47) /= CFG_F1_CSH_MMIO_BAR0(63 downto 35) or
                                             CFG_F1_CSH_MEMORY_SPACE = '0')
                                       )                          or
                                       ((DLX_TLXR_FLIT_VLD and partial_flit_count_2_ne) = '1' and data_flits_owed_q = "0000" and
                                         flit_q(119 downto 112) /= x"82"                                    and -- avoid write_membe BEs
                                         prev_beat1    (103 downto 100) = "0010" and prev_beat1    (98 downto 96) = "000" and                         -- third beat of a flit (slot 8)
                                         (flit_q(7 downto 0) = x"00" or flit_q(7 downto 0) = x"0C"   or                                 -- check slots 0 and 4
                                          flit_q(7 downto 0) = x"E0" or flit_q(7 downto 0) = x"E1"   or
                                          flit_q(7 downto 0) = x"28" or flit_q(7 downto 0) = x"20"   or
                                          flit_q(7 downto 0) = x"80" or flit_q(7 downto 0) = x"EF"   or
                                          flit_q(7 downto 0) = x"81" or flit_q(7 downto 0) = x"86"   or
                                          flit_q(7 downto 0) = x"01" or flit_q(7 downto 0) = x"1A" ) and
                                         (flit_q(119 downto 112) = x"00" or flit_q(119 downto 112) = x"0C"   or
                                          flit_q(119 downto 112) = x"E0" or flit_q(119 downto 112) = x"E1"   or
                                          flit_q(119 downto 112) = x"28" or flit_q(119 downto 112) = x"20"   or
                                          flit_q(119 downto 112) = x"80" or flit_q(119 downto 112) = x"EF"   or
                                          flit_q(119 downto 112) = x"81" or flit_q(119 downto 112) = x"86"   or
                                          flit_q(119 downto 112) = x"1A") and
                                         (
                                             DLX_TLXR_FLIT_DATA(59 downto 31) /= CFG_F1_CSH_MMIO_BAR0(63 downto 35) or
                                             CFG_F1_CSH_MEMORY_SPACE = '0')
                                       )
                                                                 or
                                       -- we check that the template is not 0 but the problem with this is that in a cycle where
                                       -- error and valid are both on, we probably drop the fast activate on this cycle. (Depends on
                                       -- unused high address bits for the read, which are probably zero).
                                       ((DLX_TLXR_FLIT_VLD and partial_flit_count_3_ne) = '1' and data_flits_owed_q = "0000" and
                                         DLX_TLXR_FLIT_DATA(81 downto 76) /= "000000"                       and -- Template not 0
                                         prev_beat2    (87 downto 84) = "0010" and prev_beat2    (82 downto 80) = "000" and
                                        (
                                          DLX_TLXR_FLIT_DATA(43 downto 15) /= CFG_F1_CSH_MMIO_BAR0(63 downto 35) or
                                          CFG_F1_CSH_MEMORY_SPACE = '0' )
                                       )
                                     else '0';

                                                                                                             --           bits available
                                                                                                             -- dlx
                                                                                                             --flit_q                      1         2        3       4
    fast_act_fifo_addr(0 to 34) <=  DLX_TLXR_FLIT_DATA(67 downto 33)  when partial_flit_count_0_ne = '1' else              --  67  33    127-0
                                    DLX_TLXR_FLIT_DATA(51 downto 17)  when partial_flit_count_1_ne = '1' else              -- 179 145            255-128
                                    DLX_TLXR_FLIT_DATA(35 downto 1)   when partial_flit_count_2_ne = '1' else              -- 291 257                    383-256
                                    DLX_TLXR_FLIT_DATA(19 downto 0) & prev_beat2    (127 downto 113);                      -- 403 369                            511-384

FAST_ACT_FIFO: entity work.cb_tlxr_fastact_fifo_wrap PORT MAP(
      vdd                            =>  vdd,                                     --   : inout power_logic
      gnd                            =>  gnd,                                     --   : inout power_logic
      gckn                           =>  gckn,
      syncr                          =>  syncr,
      fast_act_fifo_wr               =>  fast_act_fifo_wr,
      fast_act_fifo_addr             =>  fast_act_fifo_addr,
      HALF_DIMM_MODE                 =>  cfg_half_dimm_mode_q,
      MCB_TLXR_xlt_slot0_valid       =>  MCB_TLXR_xlt_slot0_valid,
      MCB_TLXR_xlt_slot1_valid       =>  MCB_TLXR_xlt_slot1_valid,
      MCB_TLXR_xlt_slot0_d_value     =>  MCB_TLXR_xlt_slot0_d_value,
      MCB_TLXR_xlt_slot1_d_value     =>  MCB_TLXR_xlt_slot1_d_value,
      MCB_TLXR_xlt_slot0_m0_valid    =>  MCB_TLXR_xlt_slot0_m0_valid,             --   : IN   std_ulogic    1
      MCB_TLXR_xlt_slot0_m1_valid    =>  MCB_TLXR_xlt_slot0_m1_valid,             --   : IN   std_ulogic    1
      MCB_TLXR_xlt_slot0_s0_valid    =>  MCB_TLXR_xlt_slot0_s0_valid,             --   : IN   std_ulogic    0
      MCB_TLXR_xlt_slot0_s1_valid    =>  MCB_TLXR_xlt_slot0_s1_valid,             --   : IN   std_ulogic    0
      MCB_TLXR_xlt_slot0_s2_valid    =>  MCB_TLXR_xlt_slot0_s2_valid,             --   : IN   std_ulogic    0
      MCB_TLXR_xlt_slot0_r15_valid   =>  MCB_TLXR_xlt_slot0_r15_valid,            --   : IN   std_ulogic    0
      MCB_TLXR_xlt_slot0_r16_valid   =>  MCB_TLXR_xlt_slot0_r16_valid,            --   : IN   std_ulogic    0
      MCB_TLXR_xlt_slot0_r17_valid   =>  MCB_TLXR_xlt_slot0_r17_valid,            --   : IN   std_ulogic    0
      MCB_TLXR_xlt_slot1_m0_valid    =>  MCB_TLXR_xlt_slot1_m0_valid,
      MCB_TLXR_xlt_slot1_m1_valid    =>  MCB_TLXR_xlt_slot1_m1_valid,
      MCB_TLXR_xlt_slot1_s0_valid    =>  MCB_TLXR_xlt_slot1_s0_valid,
      MCB_TLXR_xlt_slot1_s1_valid    =>  MCB_TLXR_xlt_slot1_s1_valid,
      MCB_TLXR_xlt_slot1_s2_valid    =>  MCB_TLXR_xlt_slot1_s2_valid,
      MCB_TLXR_xlt_slot1_r15_valid   =>  MCB_TLXR_xlt_slot1_r15_valid,
      MCB_TLXR_xlt_slot1_r16_valid   =>  MCB_TLXR_xlt_slot1_r16_valid,
      MCB_TLXR_xlt_slot1_r17_valid   =>  MCB_TLXR_xlt_slot1_r17_valid,
      MCB_TLXR_xlt_d_bit_map         =>  MCB_TLXR_xlt_d_bit_map,
      MCB_TLXR_xlt_m0_bit_map        =>  MCB_TLXR_xlt_m0_bit_map,                 --   : IN   std_ulogic_vector(0 to  2)    111       37
      MCB_TLXR_xlt_m1_bit_map        =>  MCB_TLXR_xlt_m1_bit_map,                 --   : IN   std_ulogic_vector(0 to  4)     0011 0    master rank 1 =a6
      MCB_TLXR_xlt_s0_bit_map        =>  MCB_TLXR_xlt_s0_bit_map,                 --   : IN   std_ulogic_vector(0 to  4)    111 11
      MCB_TLXR_xlt_s1_bit_map        =>  MCB_TLXR_xlt_s1_bit_map,                 --   : IN   std_ulogic_vector(0 to  4)    11 111
      MCB_TLXR_xlt_s2_bit_map        =>  MCB_TLXR_xlt_s2_bit_map,                 --   : IN   std_ulogic_vector(0 to  4)    1 1111    37FFF
      MCB_TLXR_xlt_r17_bit_map       =>  MCB_TLXR_xlt_r17_bit_map,                --   : IN   std_ulogic_vector(0 to  2)    111
      MCB_TLXR_xlt_r16_bit_map       =>  MCB_TLXR_xlt_r16_bit_map,                --   : IN   std_ulogic_vector(0 to  2)    1 11
      MCB_TLXR_xlt_r15_bit_map       =>  MCB_TLXR_xlt_r15_bit_map,                --   : IN   std_ulogic_vector(0 to  2)    11 1
      MCB_TLXR_xlt_c3_bit_map        =>  MCB_TLXR_xlt_c3_bit_map,                 --   : IN   std_ulogic_vector(0 to  4)     001 11 col4 = a27 = oc12
      MCB_TLXR_xlt_c4_bit_map        =>  MCB_TLXR_xlt_c4_bit_map,                 --   : IN   std_ulogic_vector(0 to  4)     001 11 col4 = a27 = oc12
      MCB_TLXR_xlt_c5_bit_map        =>  MCB_TLXR_xlt_c5_bit_map,                 --   : IN   std_ulogic_vector(0 to  4)     00 111 col5 = a26 = oc13
      MCB_TLXR_xlt_c6_bit_map        =>  MCB_TLXR_xlt_c6_bit_map,                 --   : IN   std_ulogic_vector(0 to  4)     0 0111 col6 = a25 = oc14   ff9ce7
      MCB_TLXR_xlt_c7_bit_map        =>  MCB_TLXR_xlt_c7_bit_map,                 --   : IN   std_ulogic_vector(0 to  4)     0011 1 col7 = a24 = oc15
      MCB_TLXR_xlt_c8_bit_map        =>  MCB_TLXR_xlt_c8_bit_map,                 --   : IN   std_ulogic_vector(0 to  4)     001 11 col8 = a23 =oc16
      MCB_TLXR_xlt_c9_bit_map        =>  MCB_TLXR_xlt_c9_bit_map,                 --   : IN   std_ulogic_vector(0 to  4)     00 111 col9 = a7 = oc32
      MCB_TLXR_xlt_b0_bit_map        =>  MCB_TLXR_xlt_b0_bit_map,                 --   : IN   std_ulogic_vector(0 to  4)      0 0101 bank0 = 29 10      39ce5
      MCB_TLXR_xlt_b1_bit_map        =>  MCB_TLXR_xlt_b1_bit_map,                 --   : IN   std_ulogic_vector(0 to  4)      0010 1 bank1 = 30 = oc 9
      MCB_TLXR_xlt_bg0_bit_map       =>  MCB_TLXR_xlt_bg0_bit_map,                --   : IN   std_ulogic_vector(0 to  4)      000 11 bg0= 31 = oc 8
      MCB_TLXR_xlt_bg1_bit_map       =>  MCB_TLXR_xlt_bg1_bit_map,                --   : IN   std_ulogic_vector(0 to  4)      00 010 bg1= 32 = oc7
      mcb_tlxr_enab_row_addr_hash    =>  mcb_tlxr_enab_row_addr_hash,             --   : IN   std_ulogic

      srq_tlxr_fast_act_fifo_next    =>  srq_tlxr_fast_act_fifo_next,
      srq_tlxr_fast_act_fifo_drain   =>  srq_tlxr_fast_act_fifo_drain,
-- outputs
      tlxr_srq_fast_act_fifo_val          => tlxr_srq_fast_act_fifo_val,
      tlxr_srq_fast_act_fifo_addr         => tlxr_srq_fast_act_fifo_addr,
      tlxr_srq_fast_act_fifo_dimm         => tlxr_srq_fast_act_fifo_dimm,
      tlxr_srq_fast_act_fifo_row_bank_par => tlxr_srq_fast_act_fifo_row_bank_par,
      tlxr_srq_fast_act_fifo_rank_par     => tlxr_srq_fast_act_fifo_rank_par,

      tlxr_srq_fast_act_fifo_val_a          => tlxr_srq_fast_act_fifo_val_a,
      tlxr_srq_fast_act_fifo_addr_a         => tlxr_srq_fast_act_fifo_addr_a,
      tlxr_srq_fast_act_fifo_dimm_a         => tlxr_srq_fast_act_fifo_dimm_a,
      tlxr_srq_fast_act_fifo_row_bank_par_a => tlxr_srq_fast_act_fifo_row_bank_par_a,
      tlxr_srq_fast_act_fifo_rank_par_a     => tlxr_srq_fast_act_fifo_rank_par_a,

      tlxr_srq_fast_act_fifo_val_b          => tlxr_srq_fast_act_fifo_val_b,
      tlxr_srq_fast_act_fifo_addr_b         => tlxr_srq_fast_act_fifo_addr_b,
      tlxr_srq_fast_act_fifo_dimm_b         => tlxr_srq_fast_act_fifo_dimm_b,
      tlxr_srq_fast_act_fifo_row_bank_par_b => tlxr_srq_fast_act_fifo_row_bank_par_b,
      tlxr_srq_fast_act_fifo_rank_par_b     => tlxr_srq_fast_act_fifo_rank_par_b
);

                                  ---------------------------------------------------
                                  -- ADDRESS TRANSLATE FOR MEMORY READS AND WRITES --
                                  ---------------------------------------------------

      oc_addr  <= GATE(flit_30(67 downto 28),using_cmd_ne(0)) or
                   GATE(flit_74(67 downto 28),using_cmd_ne(1)) or
                   GATE(flit_B8(67 downto 28),using_cmd_ne(2)) or
                   GATE(flit_FC(67 downto 28),using_cmd_ne(3));

      oc_oob <= OR_REDUCE(flit_30(91 downto 68)) when using_cmd_ne(0) = '1'   else
                OR_REDUCE(flit_74(91 downto 68)) when using_cmd_ne(1) = '1'   else
                OR_REDUCE(flit_B8(91 downto 68)) when using_cmd_ne(2) = '1'   else
                OR_REDUCE(flit_FC(91 downto 68));

      xlat_addr_in(39 downto 6) <= oc_addr(39 downto 6);
      xlat_addr_in(5)           <= oc_addr(5) and not mask_a5;                            -- A5 forced zero for any write going to dram
      xlat_addr_in(4)           <= oc_addr(4);                                            -- A4 forced zero for any write going to dram

      -- Unless dL appears in command, we are required to return response with dL=01 ("64")
      -- Special case of "00" in length is used to signal response needs to be mem_cntl_done.
      dl_slot0 <= "00" when op_held_q( 3 downto  0)="1100" else flit_30(111 downto 110) when op_held_q( 8)='1' else "01";
      dl_slot4 <= "00" when op_held_q(14 downto 11)="1100" else flit_74(111 downto 110) when op_held_q(19)='1' else "01";
      dl_slot8 <= "00" when op_held_q(25 downto 22)="1100" else flit_B8(111 downto 110) when op_held_q(30)='1' else "01";
      dl_slot12<= "00" when op_held_q(36 downto 33)="1100" else flit_FC(111 downto 110) when op_held_q(41)='1' else "01";
      oc_tag_dl_ecc(23 downto 0) <= ECCGEN(flit_30(107 downto 92) & dl_slot0) & flit_30(107 downto 92) & dl_slot0
                                                           when using_cmd(0) = '1'   else
                                    ECCGEN(flit_74(107 downto 92) & dl_slot4) & flit_74(107 downto 92) & dl_slot4
                                                           when using_cmd(1) = '1'   else
                                    ECCGEN(flit_B8(107 downto 92) & dl_slot8) & flit_B8(107 downto 92) & dl_slot8
                                                           when using_cmd(2) = '1'   else
                                    ECCGEN(flit_FC(107 downto 92) & dl_slot12) & flit_FC(107 downto 92) & dl_slot12;

XLAT_SEQ_CMD: entity work.cb_tlxr_xlat
 GENERIC MAP( fast => false)
 PORT MAP(
      vdd                            =>  vdd,                                    --   : inout power_logic
      gnd                            =>  gnd,                                    --   : inout power_logic
      addr                           =>  xlat_addr_in(39 downto 5),              --   : IN   std_ulogic_vector(0 to 34)
      addr4                          =>  xlat_addr_in(4),                        --
      HALF_DIMM_MODE                 =>  cfg_half_dimm_mode_q,
      cfg_xlt_slot0_valid            =>  MCB_TLXR_xlt_slot0_valid,
      cfg_xlt_slot1_valid            =>  MCB_TLXR_xlt_slot1_valid,
      cfg_xlt_slot0_d_value          =>  MCB_TLXR_xlt_slot0_d_value,
      cfg_xlt_slot1_d_value          =>  MCB_TLXR_xlt_slot1_d_value,

      cfg_xlt_slot0_m0_valid         =>  MCB_TLXR_xlt_slot0_m0_valid,            --
      cfg_xlt_slot0_m1_valid         =>  MCB_TLXR_xlt_slot0_m1_valid,            --   : IN   std_ulogic
      cfg_xlt_slot0_s0_valid         =>  MCB_TLXR_xlt_slot0_s0_valid,            --   : IN   std_ulogic
      cfg_xlt_slot0_s1_valid         =>  MCB_TLXR_xlt_slot0_s1_valid,            --   : IN   std_ulogic
      cfg_xlt_slot0_s2_valid         =>  MCB_TLXR_xlt_slot0_s2_valid,            --   : IN   std_ulogic
      cfg_xlt_slot0_r15_valid        =>  MCB_TLXR_xlt_slot0_r15_valid,           --   : IN   std_ulogic
      cfg_xlt_slot0_r16_valid        =>  MCB_TLXR_xlt_slot0_r16_valid,           --   : IN   std_ulogic
      cfg_xlt_slot0_r17_valid        =>  MCB_TLXR_xlt_slot0_r17_valid,           --   : IN   std_ulogic
      cfg_xlt_slot1_m0_valid         =>  MCB_TLXR_xlt_slot1_m0_valid,            --
      cfg_xlt_slot1_m1_valid         =>  MCB_TLXR_xlt_slot1_m1_valid,            --   : IN   std_ulogic
      cfg_xlt_slot1_s0_valid         =>  MCB_TLXR_xlt_slot1_s0_valid,            --   : IN   std_ulogic
      cfg_xlt_slot1_s1_valid         =>  MCB_TLXR_xlt_slot1_s1_valid,            --   : IN   std_ulogic
      cfg_xlt_slot1_s2_valid         =>  MCB_TLXR_xlt_slot1_s2_valid,            --   : IN   std_ulogic
      cfg_xlt_slot1_r15_valid        =>  MCB_TLXR_xlt_slot1_r15_valid,           --   : IN   std_ulogic
      cfg_xlt_slot1_r16_valid        =>  MCB_TLXR_xlt_slot1_r16_valid,           --   : IN   std_ulogic
      cfg_xlt_slot1_r17_valid        =>  MCB_TLXR_xlt_slot1_r17_valid,           --   : IN   std_ulogic
      cfg_xlt_d_bit_map              =>  MCB_TLXR_xlt_d_bit_map,
      cfg_xlt_m0_bit_map             =>  MCB_TLXR_xlt_m0_bit_map,                --
      cfg_xlt_m1_bit_map             =>  MCB_TLXR_xlt_m1_bit_map,                --   : IN   std_ulogic_vector(0 to  4)
      cfg_xlt_s0_bit_map             =>  MCB_TLXR_xlt_s0_bit_map,                --   : IN   std_ulogic_vector(0 to  2)
      cfg_xlt_s1_bit_map             =>  MCB_TLXR_xlt_s1_bit_map,                --   : IN   std_ulogic_vector(0 to  4)
      cfg_xlt_s2_bit_map             =>  MCB_TLXR_xlt_s2_bit_map,                --   : IN   std_ulogic_vector(0 to  4)
      cfg_xlt_r17_bit_map            =>  MCB_TLXR_xlt_r17_bit_map,               --   : IN   std_ulogic_vector(0 to  4)
      cfg_xlt_r16_bit_map            =>  MCB_TLXR_xlt_r16_bit_map,               --   : IN   std_ulogic_vector(0 to  4)
      cfg_xlt_r15_bit_map            =>  MCB_TLXR_xlt_r15_bit_map,               --   : IN   std_ulogic_vector(0 to  2)
      cfg_xlt_c3_bit_map             =>  MCB_TLXR_xlt_c3_bit_map,                --   : IN   std_ulogic_vector(0 to  2)
      cfg_xlt_c4_bit_map             =>  MCB_TLXR_xlt_c4_bit_map,                --   : IN   std_ulogic_vector(0 to  2)
      cfg_xlt_c5_bit_map             =>  MCB_TLXR_xlt_c5_bit_map,                --   : IN   std_ulogic_vector(0 to  2)
      cfg_xlt_c6_bit_map             =>  MCB_TLXR_xlt_c6_bit_map,                --   : IN   std_ulogic_vector(0 to  4)
      cfg_xlt_c7_bit_map             =>  MCB_TLXR_xlt_c7_bit_map,                --   : IN   std_ulogic_vector(0 to  4)
      cfg_xlt_c8_bit_map             =>  MCB_TLXR_xlt_c8_bit_map,                --   : IN   std_ulogic_vector(0 to  4)
      cfg_xlt_c9_bit_map             =>  MCB_TLXR_xlt_c9_bit_map,                --   : IN   std_ulogic_vector(0 to  4)
      cfg_xlt_b0_bit_map             =>  MCB_TLXR_xlt_b0_bit_map,                --   : IN   std_ulogic_vector(0 to  4)
      cfg_xlt_b1_bit_map             =>  MCB_TLXR_xlt_b1_bit_map,                --   : IN   std_ulogic_vector(0 to  4)
      cfg_xlt_bg0_bit_map            =>  MCB_TLXR_xlt_bg0_bit_map,               --   : IN   std_ulogic_vector(0 to  4)
      cfg_xlt_bg1_bit_map            =>  MCB_TLXR_xlt_bg1_bit_map,               --   : IN   std_ulogic_vector(0 to  4)
      enable_row_addr_hash           =>  mcb_tlxr_enab_row_addr_hash,            --   : IN   std_ulogic
-- outputs
      xlat_hole                      =>  xlat_hole,
      xlat_drop                      =>  xlat_drop,
      dimm                           =>  dimm,
      addr_error                     =>  cmd_xlat_error,
      mrank                          =>  phys_addr( 4 to 5),                     --   : OUT  std_ulogic_vector(0 to 1)
      srank                          =>  phys_addr( 6 to 8),                     --   : OUT  std_ulogic_vector(0 to 2)
      bank                           =>  phys_addr( 2 to 3),                     --   : OUT  std_ulogic_vector(0 to 1)
      bank_group                     =>  phys_addr( 0 to 1),                     --   : OUT  std_ulogic_vector(0 to 1)
      row                            =>  phys_addr( 9 to 26),                    --   : OUT  std_ulogic_vector(0 to 17)
      col                            =>  col_addr(27 to 34)                      --   : OUT  std_ulogic_vector(2 to  9)
      );

--                                               zero when cfg_half dimm_mode or not a read
     phys_addr(27 to 34)  <= (col_addr(27) and (                             c2_as_a5)) & col_addr(28 to 34);

      other_xlate_par <= xor_reduce(phys_addr(4 to 8) & dimm);
      row_bank_par    <= xor_reduce(phys_addr(0 to 3) & phys_addr(9 to 26));
      col_bank_par    <= xor_reduce(phys_addr(0 to 3) & phys_addr(27 to 34));
                                       ----------------------------------
                                       -- Generation of Outputs to SRQ --
                                       ----------------------------------


      uc_d(0) <=  decode_ctl_cycle_d(0) and op_held_d(7) and not DLX_TLXR_FLIT_ERROR;
      using_cmd(0)   <=  uc_q(0);
      uc_d(1)        <=  (uc_d(8) and not op_held_d(7) and op_held_d(18)) or
                         (decode_ctl_cycle_d(1)  and     op_held_d(7) and op_held_d(18));
      using_cmd(1)   <=  uc_q(1);
      uc_d(2)        <=   (uc_d(8)               and not op_held_d(7) and not op_held_d(18) and op_held_d(29)) or
                          (decode_ctl_cycle_d(1) and     op_held_d(7) and not op_held_d(18) and op_held_d(29)) or
                          (decode_ctl_cycle_d(1) and not op_held_d(7) and     op_held_d(18) and op_held_d(29)) or
                          (decode_ctl_cycle_d(2) and     op_held_d(7) and     op_held_d(18) and op_held_d(29));
      using_cmd(2)   <=   uc_q(2);
      uc_d(3)        <=   (uc_d(8)               and not op_held_d(7) and not op_held_d(18) and not op_held_d(29) and op_held_d(40)) or
                          (decode_ctl_cycle_d(1) and     op_held_d(7) and not op_held_d(18) and not op_held_d(29) and op_held_d(40)) or
                          (decode_ctl_cycle_d(1) and not op_held_d(7) and     op_held_d(18) and not op_held_d(29) and op_held_d(40)) or
                          (decode_ctl_cycle_d(1) and not op_held_d(7) and not op_held_d(18) and     op_held_d(29) and op_held_d(40)) or
                          (decode_ctl_cycle_d(2) and     op_held_d(7) and     op_held_d(18) and not op_held_d(29) and op_held_d(40)) or
                          (decode_ctl_cycle_d(2) and     op_held_d(7) and not op_held_d(18) and     op_held_d(29) and op_held_d(40)) or
                          (decode_ctl_cycle_d(2) and not op_held_d(7) and     op_held_d(18) and     op_held_d(29) and op_held_d(40)) or
                          (decode_ctl_cycle_d(3) and     op_held_d(7) and     op_held_d(18) and     op_held_d(29) and op_held_d(40));

      using_cmd(3)   <=   uc_q(3);
      uc_d(4)           <=   decode_ctl_cycle_d(0)   and op_held_d(7);                           --  work out which decode we are pulling
      using_cmd_ne(0)   <=   uc_q(4);
      uc_d(5)           <=  (decode_ctl_cycle_d(0) and not op_held_d(7) and op_held_d(18)) or
                            (decode_ctl_cycle_d(1)  and    op_held_d(7) and op_held_d(18));
      using_cmd_ne(1)   <=  uc_q(5);
      uc_d(6)           <=  (decode_ctl_cycle_d(0) and not op_held_d(7) and not op_held_d(18) and op_held_d(29)) or
                            (decode_ctl_cycle_d(1) and     op_held_d(7) and not op_held_d(18) and op_held_d(29)) or
                            (decode_ctl_cycle_d(1) and not op_held_d(7) and     op_held_d(18) and op_held_d(29)) or
                            (decode_ctl_cycle_d(2) and     op_held_d(7) and     op_held_d(18) and op_held_d(29));

      using_cmd_ne(2)   <=   uc_q(6);
      uc_d(7)           <= ( (decode_ctl_cycle_d(0) and not op_held_d(7) and not op_held_d(18) and not op_held_d(29) and op_held_d(40)) or
                          (decode_ctl_cycle_d(1) and     op_held_d(7) and not op_held_d(18) and not op_held_d(29) and op_held_d(40)) or
                          (decode_ctl_cycle_d(1) and not op_held_d(7) and     op_held_d(18) and not op_held_d(29) and op_held_d(40)) or
                          (decode_ctl_cycle_d(1) and not op_held_d(7) and not op_held_d(18) and     op_held_d(29) and op_held_d(40)) or
                          (decode_ctl_cycle_d(2) and     op_held_d(7) and     op_held_d(18) and not op_held_d(29) and op_held_d(40)) or
                          (decode_ctl_cycle_d(2) and     op_held_d(7) and not op_held_d(18) and     op_held_d(29) and op_held_d(40)) or
                          (decode_ctl_cycle_d(2) and not op_held_d(7) and     op_held_d(18) and     op_held_d(29) and op_held_d(40)) or
                          (decode_ctl_cycle_d(3) and     op_held_d(7) and     op_held_d(18) and     op_held_d(29) and op_held_d(40))
                        );
      using_cmd_ne(3)   <=   uc_q(7);
      --synopsys translate_off
      assert not (NBITS(using_cmd_ne) > 1 and GCKN'event and GCKN='0') report "MULTIPLE using_cmd_ne s" severity error;
      --synopsys translate_on

      pad_patt_write <= '1' when (op_held_q( 3 downto  0)="1111" and using_cmd(0)='1')  -- 1111 means pad pattern write (not sent to SRQ)
                              or (op_held_q(14 downto 11)="1111" and using_cmd(1)='1')
                              or (op_held_q(25 downto 22)="1111" and using_cmd(2)='1')
                              or (op_held_q(36 downto 33)="1111" and using_cmd(3)='1')
                   else '0';

      mem_cntl       <= '1' when (op_held_q( 3 downto  0)="1100" and using_cmd(0)='1')  -- 1100 means mem_cntl (not sent to SRQ)
                              or (op_held_q(14 downto 11)="1100" and using_cmd(1)='1')
                              or (op_held_q(25 downto 22)="1100" and using_cmd(2)='1')
                              or (op_held_q(36 downto 33)="1100" and using_cmd(3)='1')
                   else '0';

      mem_pfch       <= '1' when (op_held_q( 3 downto  0)="1110" and using_cmd(0)='1')  -- 1110 means mem_pfch (not sent to SRQ)
                              or (op_held_q(14 downto 11)="1110" and using_cmd(1)='1')
                              or (op_held_q(25 downto 22)="1110" and using_cmd(2)='1')
                              or (op_held_q(36 downto 33)="1110" and using_cmd(3)='1')
                   else '0';

      flag           <= GATE(flit_30(11 downto 8),using_cmd(0)) or
                        GATE(flit_74(11 downto 8),using_cmd(1)) or
                        GATE(flit_B8(11 downto 8),using_cmd(2)) or
                        GATE(flit_FC(11 downto 8),using_cmd(3)) ;
      tlxr_srq_cmd_used    <= or_reduce(using_cmd); -- This also triggers buffer state 0->1 and consume_vc0/vc1
      tlxr_srq_cmd_val_i   <= tlxr_srq_cmd_used and not pad_patt_write and not mem_cntl and not mem_pfch and not oc_wr_err; 
      tlxr_srq_cmd_val_d   <= tlxr_srq_cmd_val_i;
      TLXR_SRQ_CMD_VAL     <= tlxr_srq_cmd_val_q;

      TLXR_SRQ_MEMCNTL_REQ      <= mem_cntl;                    -- Identify as SYNC subcommand
      tlxr_tp_fir_trace_err_i   <= mem_cntl and flag="0001";    -- Identify as trace stop command
      TLXR_TP_FIR_TRACE_ERR     <= tlxr_tp_fir_trace_err_i;
      TLXR_SRQ_MEMCNTL_CMD_FLAG <= flag;

      memctl_unknown_flag      <= '1' when tlxr_srq_cmd_used = '1' and mem_cntl = '1' and flag > "1011" else '0';  

--      -- list of flags
--   0000  sync all (qualified by synccntl reg in sequencer which defaults to sync all)
--   0001 tracestop
--   0010 checkstop
--   0011 perfmon start with reset
--   0100 perfmon start with no reset
--   0101 perfmon stop
--   0110 emergency throttle
--   0111 occ_touch
--   1000 fluch NCF
--   1xxx Reserved

      ---
      tlxr_srq_cmd_i(0 to 15)  <= flit_30(107 downto  92) when (using_cmd(0) and op_held_q(4)) = '1' else    -- tag for a read/pad_mem
                                  flit_74(107 downto  92) when (using_cmd(1) and op_held_q(15)) = '1' else
                                  flit_B8(107 downto  92) when (using_cmd(2) and op_held_q(26)) = '1' else
                                  flit_FC(107 downto  92) when (using_cmd(3) and op_held_q(37)) = '1' else
                                  b_nos_4_srq;                                                                -- for a write it's the buffer numbers

      buffer_shortage(0) <= (not bpv_q(2) and flit_30(0) and not flit_30(5) and flit_30(111)) or not bpv_q(1);
      buffer_shortage(1) <= (not bpv_q(2) and flit_74(0) and not flit_74(5) and flit_74(111)) or not bpv_q(1);
      buffer_shortage(2) <= (not bpv_q(2) and flit_B8(0) and not flit_B8(5) and flit_B8(111)) or not bpv_q(1);
      buffer_shortage(3) <= (not bpv_q(2) and flit_FC(0) and not flit_FC(5) and flit_FC(111)) or not bpv_q(1);

      --synopsys translate_off
      assert not (buffer_shortage(0) /= '1' and buffer_shortage(0) /= '0' and using_cmd(0) /= '0' and  GCKN'event and GCKN='1') report "buffer_shortage0 X when being used" severity error;
      assert not (buffer_shortage(1) /= '1' and buffer_shortage(1) /= '0' and using_cmd(1) /= '0' and  GCKN'event and GCKN='1') report "buffer_shortage1 X when being used" severity error;
      assert not (buffer_shortage(2) /= '1' and buffer_shortage(2) /= '0' and using_cmd(2) /= '0' and  GCKN'event and GCKN='1') report "buffer_shortage2 X when being used" severity error;
      assert not (buffer_shortage(3) /= '1' and buffer_shortage(3) /= '0' and using_cmd(3) /= '0' and  GCKN'event and GCKN='1') report "buffer_shortage3 X when being used" severity error;
      --synopsys translate_on

            -- not (4) means pr_wr_mem/wr_mem.be/write_mem or config_write
      tag_store_we      <= (using_cmd(0) and (mem_cntl or (not op_held_q( 4) and not buffer_shortage(0))))
                        or (using_cmd(1) and (mem_cntl or (not op_held_q(15) and not buffer_shortage(1))))
                        or (using_cmd(2) and (mem_cntl or (not op_held_q(26) and not buffer_shortage(2))))
                        or (using_cmd(3) and (mem_cntl or (not op_held_q(37) and not buffer_shortage(3))));

      t      <=  flit_30(108)   when using_cmd(0) = '1'   else                                                -- config type
                 flit_74(108)   when using_cmd(1) = '1'   else
                 flit_B8(108)   when using_cmd(2) = '1'   else
                 flit_FC(108)   when using_cmd(3) = '1' else CFG_F1_CSH_P; -- !!! sinkless bodge

      translating <=  (using_cmd(0) and op_held_q(5)) or  (using_cmd(1) and op_held_q(16)) or
                      (using_cmd(2) and op_held_q(27)) or  (using_cmd(3) and op_held_q(38));

      data_xfer   <=  (using_cmd(0) and not op_held_q(4))  or  (using_cmd(1) and not op_held_q(15)) or
                      (using_cmd(2) and not op_held_q(26)) or  (using_cmd(3) and not op_held_q(37));


      tlxr_srq_cmd_i(16 to 50) <= '1' & oc_rd_resp & pad_mem_err & x"0000000" & "00" when oc_rd_err = '1' else  -- oc_rd_resp now includes pad_mem_err
                                  phys_addr(0 to 34) when translating = '1'                               else  -- physical address has been translated
                                  oc_addr(34 downto 0);                                                         -- not translated

      length_format_2 <= GATE(op_held_q(8)  & flit_30(111 downto 110),using_cmd(0)) or
                         GATE(op_held_q(19) & flit_74(111 downto 110),using_cmd(1)) or
                         GATE(op_held_q(30) & flit_B8(111 downto 110),using_cmd(2)) or
                         GATE(op_held_q(41) & flit_FC(111 downto 110),using_cmd(3)) ;

      mask_a5         <= (op_held_q(9)  and using_cmd(0)) or
                         (op_held_q(20) and using_cmd(1)) or
                         (op_held_q(31) and using_cmd(2)) or
                         (op_held_q(42) and using_cmd(3));

      c2_as_a5        <= (op_held_q(5)  and op_held_q(4)  and not op_held_q( 0) and using_cmd(0)) or 
                         (op_held_q(16) and op_held_q(15) and not op_held_q(11) and using_cmd(1)) or 
                         (op_held_q(27) and op_held_q(26) and not op_held_q(22) and using_cmd(2)) or 
                         (op_held_q(38) and op_held_q(37) and not op_held_q(33) and using_cmd(3));  

      write_mem       <= (op_held_q(8)  and not op_held_q(4)  and using_cmd(0)) or       -- we use this mask for the data steering and the one
                         (op_held_q(19) and not op_held_q(15) and using_cmd(1)) or       -- above for sending to SRQ
                         (op_held_q(30) and not op_held_q(26) and using_cmd(2)) or
                         (op_held_q(41) and not op_held_q(37) and using_cmd(3)) ;

      rd_mem          <= (op_held_q(8)  and op_held_q(4)  and not op_held_q(0)  and using_cmd(0)) or       -- we use this mask for the data steering and the one
                         (op_held_q(19) and op_held_q(15) and not op_held_q(11) and using_cmd(1)) or       -- above for sending to SRQ
                         (op_held_q(30) and op_held_q(26) and not op_held_q(22) and using_cmd(2)) or
                         (op_held_q(41) and op_held_q(37) and not op_held_q(33) and using_cmd(3)) ;

      pr_wr_mem       <= (not op_held_q(9)   and not op_held_q(4)  and (op_held_q(2)  or op_held_q(1))  and using_cmd(0)) or
                         (not op_held_q(20)  and not op_held_q(15) and (op_held_q(13) or op_held_q(12)) and using_cmd(1)) or
                         (not op_held_q(31)  and not op_held_q(26) and (op_held_q(24) or op_held_q(23)) and using_cmd(2)) or
                         (not op_held_q(42)  and not op_held_q(37) and (op_held_q(35) or op_held_q(34)) and using_cmd(3));

      pr_rd_mem       <= (not op_held_q(8)  and op_held_q(4)  and not op_held_q(3)  and using_cmd(0)) or
                         (not op_held_q(19) and op_held_q(15) and not op_held_q(14) and using_cmd(1)) or
                         (not op_held_q(30) and op_held_q(26) and not op_held_q(25) and using_cmd(2)) or
                         (not op_held_q(41) and op_held_q(37) and not op_held_q(36) and  using_cmd(3));

      cfg_op          <= (op_held_q(3)  and not op_held_q(2)  and using_cmd(0)) or     -- config read or write
                         (op_held_q(14) and not op_held_q(13) and using_cmd(1)) or
                         (op_held_q(25) and not op_held_q(24) and using_cmd(2)) or
                         (op_held_q(36) and not op_held_q(35) and  using_cmd(3));


      write_membe     <= using_cmd(1) and not OR_REDUCE(flit_74(7 downto 0) xor x"82") and template_0_q ;

      pad_mem_unsupp_op   <= ( (op_held_q(4)  and op_held_q(0)  and using_cmd(0)) or
                               (op_held_q(15) and op_held_q(11) and using_cmd(1)) or
                               (op_held_q(26) and op_held_q(22) and using_cmd(2)) or
                               (op_held_q(37) and op_held_q(33) and using_cmd(3))
                             ) and not cfg_half_dimm_mode_q;

      pad_mem_unsupp_len  <= ( (op_held_q(4)  and op_held_q(0)  and (flit_30(111) or flit_30(110)) and using_cmd(0)) or
                               (op_held_q(15) and op_held_q(11) and (flit_74(111) or flit_74(110)) and using_cmd(1)) or
                               (op_held_q(26) and op_held_q(22) and (flit_B8(111) or flit_B8(110)) and using_cmd(2)) or
                               (op_held_q(37) and op_held_q(33) and (flit_FC(111) or flit_FC(110)) and using_cmd(3))
                             ) and cfg_half_dimm_mode_q;

      length_format_3 <= GATE(flit_30(111 downto 109),using_cmd(0)) or
                         GATE(flit_74(111 downto 109),using_cmd(1)) or
                         GATE(flit_B8(111 downto 109),using_cmd(2)) or
                         GATE(flit_FC(111 downto 109),using_cmd(3)) ;

      pr_wr_dram      <= '1' when  (using_cmd(0) = '1' and op_held_q(3  downto 0)  = "0010")  or
                                   (using_cmd(1) = '1' and op_held_q(14 downto 11) = "0010")  or
                                   (using_cmd(2) = '1' and op_held_q(25 downto 22) = "0010")  or
                                   (using_cmd(3) = '1' and op_held_q(36 downto 33) = "0010")  else
                         '0';

      pr_rd_dram      <= (using_cmd(0) and (op_held_q(4 downto 2)   = "100") and not op_held_q(8))  or
                         (using_cmd(1) and (op_held_q(15 downto 13) = "100") and not op_held_q(19)) or
                         (using_cmd(2) and (op_held_q(26 downto 24) = "100") and not op_held_q(30)) or
                         (using_cmd(3) and (op_held_q(37 downto 35) = "100") and not op_held_q(41));


      tlxr_srq_cmd_i(51 to 52) <= "01"   when (using_cmd(1) = '1' and flit_74(7 downto 0) = x"82") or rd_err_len_64='1'   else    -- write_mem.be forced to size of 64
                                  length_format_2(1 downto 0) when length_format_2(2) = '1'                  else    -- 64 or 128 in dL field 
                                  length_format_3(2 downto 1) when translating = '0'                         else    -- cfg or mmio
                                  "00";                                                                              -- no dL, dram pL=1..32, say 32

             --      memory                      config/mmio/
             --  00 = 32 or less            pl 0 - 5 ==> 1 - 32
             --  01 = 64
             --  10 = 128
             --  11 = reserved
             --

      bc_format(3) <= pad_patt_write;


      force_64 <=  using_cmd(1) and flit_74(7 downto 0) = x"82";

      bc_format(2 downto 0) <= GATE("010",bc_wr_gate and force_64)                                                                  or
                               GATE("11" & oc_addr(5), not force_64 and bc_wr_gate and not length_format_2(2) and not translating ) or
                               GATE(oc_addr(5) & "01", not force_64 and bc_wr_gate and not length_format_2(2) and     translating ) or
                               GATE("010",not force_64 and bc_wr_gate and length_format_2 = "101" )                                 or
                               GATE("011",not force_64 and bc_wr_gate and length_format_2 = "110" )                                 or
                               GATE("100",not force_64 and bc_wr_gate and length_format_2 = "111" );

      tlxr_srq_cmd_i(53 )      <= row_bank_par when translating = '1' else                      -- bg bank row p when xlated
                                  length_format_3(0);

      tlxr_srq_cmd_i(54 )      <= col_bank_par when translating = '1' else                    -- bg bank col parity when xlated
                                  t ;

      lilii_nt <= "01" when (using_cmd(1) = '1' and flit_74(7 downto 0) = x"82") or rd_err_len_64='1'   else    -- write_mem.be forced to size of 64
                  length_format_2(1 downto 0) when length_format_2(2) = '1'                             else    -- 64 or 128 in dL field 
                  length_format_3(2 downto 1);

      lilii_t  <= GATE("01",(using_cmd(1) = '1' and flit_74(7 downto 0) = x"82") or rd_err_len_64='1') or    -- write_mem.be forced to size of 64
                  GATE(length_format_2(1 downto 0),length_format_2(2));

      tlxr_srq_cmd_i(55 )      <=  (other_Xlate_par and translating) or
                                   (xor_reduce(tlxr_srq_cmd_i(0 to 15) & oc_addr(34 downto 0) &  LILII_nt & length_format_3(0) & t & tlxr_srq_cmd_i(60 to 63)) and not translating);

      tlxr_srq_cmd_i(56 )      <=  (xor_reduce(tlxr_srq_cmd_i(0 to 15) & lilii_t & tlxr_srq_cmd_i(60 to 63) & oc_rd_resp_p))
                                   and (translating or oc_rd_err);                                 -- translating is on for pad mem

--   if rd_err is on then                                                       parity contribution of the four
--                     error                     resp(+1000)     parity base    error bits (+ bit 20 if on)
--   oc_rd_err <= tlxr_tlxt_errors_d(27) or     001          1110 1001                    0
--                tlxr_tlxt_errors_d(40) or     110          1110 1110                    1
--                tlxr_tlxt_errors_d(39) or     110          1110 1110                    1
--                tlxr_tlxt_errors_d(33) or     001          1110 1001                    0
--                tlxr_tlxt_errors_d(34) or     001          1110 1001                    0
--                tlxr_tlxt_errors_d(48);       011          1110 1011                    1
--                pad_mem_unsupp_len            001          1110 1001 + bit 20           1
--                pad_mem_unsupp_op             110          1110 1110 + bit 20           0
--

      spoofed_cmd(0) <= (  (op_held_q( 0) or (op_held_q(3  downto  0) = "0010" and cfg_half_dimm_mode_q)) and  using_cmd(0)) or
                        (  (op_held_q(11) or (op_held_q(14 downto 11) = "0010" and cfg_half_dimm_mode_q)) and  using_cmd(1)) or
                        (  (op_held_q(22) or (op_held_q(25 downto 22) = "0010" and cfg_half_dimm_mode_q)) and  using_cmd(2)) or
                        (  (op_held_q(33) or (op_held_q(36 downto 33) = "0010" and cfg_half_dimm_mode_q)) and  using_cmd(3));

      spoofed_cmd(1) <= (  op_held_q( 1) and not (op_held_q(3  downto  0) = "0010" and cfg_half_dimm_mode_q) and  using_cmd(0)) or
                        (  op_held_q(12) and not (op_held_q(14 downto 11) = "0010" and cfg_half_dimm_mode_q) and  using_cmd(1)) or
                        (  op_held_q(23) and not (op_held_q(25 downto 22) = "0010" and cfg_half_dimm_mode_q) and  using_cmd(2)) or
                        (  op_held_q(34) and not (op_held_q(36 downto 33) = "0010" and cfg_half_dimm_mode_q) and  using_cmd(3));

      spoofed_cmd(3 downto 2) <= GATE(op_held_q(3 downto 2)  , using_cmd(0)) or
                                 GATE(op_held_q(14 downto 13), using_cmd(1)) or
                                 GATE(op_held_q(25 downto 24), using_cmd(2)) or
                                 GATE(op_held_q(36 downto 35), using_cmd(3));

      tlxr_srq_cmd_i(57 to 63) <= "0001110"                                  when (oc_rd_err or pad_mem_err)    = '1' else
                                  '0' & (dimm and translating) & '0' & spoofed_cmd;

     srq_cmd_d <= tlxr_srq_cmd_i(0 to 58) & tlxr_srq_cmd_i(60 to 63);

     TLXR_SRQ_CMD <= srq_cmd_q(0 to 58) & '0' & srq_cmd_q(59 to 62);  

                            ----------------------
                            -- Buffer selection --
                            ----------------------

      buf_idl_0  <= AND_REDUCE(buffer_busy or GATE(DEC_6_64(first_tag),bpv_q(1)) or GATE(DEC_6_64(second_tag),bpv_q(2))); -- everything busy, no idle buffers
      buf_idl_2  <= not buf_idl_0 and or_reduce(first_buf xor second_buf);                  -- 2 or more buffers idle
      use_buf    <= (bc_format(2 downto 0) /= "000");                                       -- using 1 or 2 buffers
      use_2_buf  <= (bc_format(2 downto 0) = "011");                                        -- using 2 buffers
      use_1_buf  <= bc_format(2) or (bc_format(1) xor bc_format(0));                        -- using 1 buffer

      --synopsys translate_off
      assert not (bpv_d="01" and bpv_q="11" and use_1_buf='1' and GCKN'event and GCKN='1') report "seen 3-1 transition." severity note;
      assert not (bpv_q="10") report "bpv_q has invalid state" severity error;
      --synopsys translate_on

      bpv_d(1) <= NOT ( buf_idl_0 and X );                      -- MR_ADD INIT => "11"
         X <= (not bpv_q(1) and not use_buf)                    -- none full after use before we do refilling
           OR (bpv_q(1) and not bpv_q(2) and use_1_buf)
           OR (bpv_q(2) and use_2_buf);

      bpv_d(2) <= NOT ( (buf_idl_0 and Y0) or (not buf_idl_2 and Y2) );

         Y0 <= (bpv_q(1) and not bpv_q(2) and not use_buf)     -- one full after use before we do refilling
              OR (bpv_q(2) and use_1_buf);

         Y2 <= (not bpv_q(1) and not use_buf)                    -- none full after use before we do refilling [Y2 = X ]
              OR (bpv_q(1) and not bpv_q(2) and use_1_buf)
              OR (bpv_q(2) and use_2_buf);


-- now we do the latching to produce first/second _tag from a latch
      first_buf  <= find_first_0(buffer_busy or GATE(DEC_6_64(first_tag),bpv_q(1)) or GATE(DEC_6_64(second_tag),bpv_q(2)));
      second_buf <= find_last_0(buffer_busy or GATE(DEC_6_64(first_tag),bpv_q(1)) or GATE(DEC_6_64(second_tag),bpv_q(2)));

      ft0 <=  GATE(first_buf,use_buf or  not bpv_q(1)) or
              GATE(ft_q, not use_buf and bpv_q(1));

      ft1 <=  GATE(st_q, use_1_buf and bpv_q(2)) or
              GATE(ft_q, not use_buf and bpv_q(1));


      ft_d <= GATE(ft0, not buf_idl_0) or GATE(ft1,buf_idl_0);    -- MR_ADD INIT => "000000"

      first_tag  <= ft_q;

      st_d <=  GATE(second_buf,use_2_buf or not bpv_q(2)) or      -- MR_ADD INIT => "100000"
               GATE(st_q,not use_2_buf and bpv_q(2));

      second_tag <= st_q;

      first_dec   <= DEC_6_64(first_tag);
      second_dec  <= DEC_6_64(second_tag);

      memcntl_tag <= "0001" when memcntl_busy_q(0)='0'  -- four outstanding memcntl's possible
                else "0010" when memcntl_busy_q(1)='0'
                else "0100" when memcntl_busy_q(2)='0'
                else "1000";

      b2_val <= '1' when length_format_2 = "110"          else '0';
      b_nos_4_srq <= "0000"      &      -- 0 to 15 in place of tag.
                     second_tag  &
                     first_tag;         -- latched into command at end of translating

      mux_mem_cntl <= '1' when (op_held_q( 3 downto  0)="1100" and using_cmd_ne(0)='1')  
                            or (op_held_q(14 downto 11)="1100" and using_cmd_ne(1)='1')
                            or (op_held_q(25 downto 22)="1100" and using_cmd_ne(2)='1')
                            or (op_held_q(36 downto 33)="1100" and using_cmd_ne(3)='1')
                       else '0';

      tag_store_waddr   <= memcntl_tag & (63 downto 0 => '0') when mux_mem_cntl = '1'
                        else ("0000" & second_dec)     when b2_val = '1'
                        else ("0000" & first_dec);

                            ------------------------------
                            -- Buffer state and vectors --
                            ------------------------------

   -- Storage state for mem_cntl command tag storage (tag store x"40" to x"43")

   memcntl_busy_gen: for i in 3 downto 0 generate

     set_memcntl_busy(i) <= '1' when mem_cntl='1' and memcntl_tag(i)= '1' else '0';

     memcntl_busy_d(i)   <= set_memcntl_busy(i) or (memcntl_busy_q(i) and tag_return_candidates_q(64+i)); -- CLR when candidate actioned

     memcntl_fail_d(i)   <= (set_memcntl_busy(i) and flag > "1011") or (memcntl_fail_q(i) and tag_return_candidates_q(64+i));

   end generate memcntl_busy_gen;
  -- states are idle 000: filling 001: filled 010: CRC+NOT_BAD 011: CRC+BAD 111: DONE 100:
  -- bottom 4 bits are error code when state = done
  --

   first_second_dec    <= first_dec or GATE(second_dec,b2_val);
   srq_wdone_tag_dec   <= dec_6_64(SRQ_TLXR_WDONE_TAG);
   mmio_wdone_tag_dec  <= dec_6_64(MMIO_TLXR_WR_BUF_TAG);
   twwp_dec            <= dec_6_64(twwp_q(0 to 5));



   buffer_state_gen: for i in 63 downto 0 generate     --     state is 6 downto 4, resp code is 3 downto 0

        buf_state_d(i*8+7 downto i*8) <=  GATE(XOR_REDUCE(oc_wr_resp) & "0011" & oc_wr_resp, buf_state_q(i*8+6 downto i*8+4) = "000" and first_dec(i)  and oc_wr_err and not b2_val) or
                                          GATE(XOR_REDUCE(oc_wr_resp) & "0011" & oc_wr_resp, buf_state_q(i*8+6 downto i*8+4) = "000" and second_dec(i) and oc_wr_err and     b2_val) or
                                          GATE("10010011"                                  , buf_state_q(i*8+6 downto i*8+4) = "000" and first_dec(i) and oc_wr_err and      b2_val) or -- special code of 3 to junk first half of 128B write if error
                                          GATE("10010000",buf_state_q(i*8+6 downto i*8+4) = "000" and first_second_dec(i) and data_xfer and tlxr_srq_cmd_used and not pad_patt_write and not  oc_wr_err) or
                                          GATE("00010001",buf_state_q(i*8+6 downto i*8+4) = "000" and first_second_dec(i) and data_xfer and tlxr_srq_cmd_used and     pad_patt_write and not  oc_wr_err) or
                                          GATE("00000000",buf_state_q(i*8+6 downto i*8+4) = "000" and ( not first_dec(i) or not  oc_wr_err) and (not first_second_dec(i) or not data_xfer or not tlxr_srq_cmd_used)) or
                                                    -- state 1 - remember to go to state 3 if we can
                                          GATE(XOR_REDUCE((flit_dat_bad(i) or t7_bad_q or tA_bad_q) & buf_state_q(i*8+3 downto i*8)) & (flit_dat_bad(i) or t7_bad_q or tA_bad_q) & "11" & buf_state_q(i*8+3 downto i*8), buf_state_q(i*8+6 downto i*8+4) = "001" and dec_ctl0 and twwp_dec(i) and last_wdf_phase_df) or -- advance_crc 2
                                          GATE(XOR_REDUCE((flit_dat_bad(i) or t7_bad_q or tA_bad_q) & buf_state_q(i*8+3 downto i*8)) & (flit_dat_bad(i) or t7_bad_q or tA_bad_q) & "11" & buf_state_q(i*8+3 downto i*8), buf_state_q(i*8+6 downto i*8+4) = "001" and twwp_dec(i) and last_wdf_phase_7A) or --  advance_crc 3
                                          GATE(buf_state_q(i*8+7) & "010" & buf_state_q(i*8+3 downto i*8),                             buf_state_q(i*8+6 downto i*8+4) = "001" and not dec_ctl0 and twwp_dec(i) and last_wdf_phase_df ) or
                                          GATE(buf_state_q(i*8+7 downto  i*8),                                                         buf_state_q(i*8+6 downto i*8+4) = "001" and not (twwp_dec(i) and (last_wdf_phase_df or last_wdf_phase_7A)) and not (tlxr_tlxt_errors_d(49) or tlxr_tlxt_errors_d(24))) or
                                          GATE("01001110",                                                                             buf_state_q(i*8+6 downto i*8+4) = "001" and twwp_dec(i) and (tlxr_tlxt_errors_d(49) or tlxr_tlxt_errors_d(24))) or
                                                    -- state 2
                                          GATE(XOR_REDUCE(flit_dat_bad(i) & buf_state_q(i*8+3 downto i*8)) & flit_dat_bad(i) & "11" & buf_state_q(i*8+3 downto i*8),buf_state_q(i*8+6 downto i*8+4) = "010" and dec_ctl0) or --- advance_crc 1
                                          GATE(buf_state_q(i*8+7 downto  i*8),buf_state_q(i*8+6 downto i*8+4) = "010" and not dec_ctl0) or
                                                    -- state 3
                                          GATE("11000000",                                                                                               buf_state_q(i*8+6 downto i*8+0) = "0110001") or    -- write_pad_pattern
                                          GATE(XOR_REDUCE('1' & buf_state_q(i*8+3 downto i*8)) & "100" & buf_state_q(i*8+3 downto i*8),                  buf_state_q(i*8+6 downto i*8+3) = "0111") or -- fail non srq/mmio/pad_mem



                                          GATE("11000000",                                                                                               buf_state_q(i*8+6 downto i*8+3) = "0110" and not buf_state_q(i*8) and srq_wdone_tag_dec(i) and SRQ_TLXR_WDONE_VAL and SRQ_TLXR_WDONE_LAST ) or   -- no problem
                                          GATE(XOR_REDUCE('1' & buf_state_q(i*8+3 downto i*8)) & "100" & buf_state_q(i*8+3 downto i*8),                  buf_state_q(i*8+6 downto i*8+3) = "0111") or -- fail non srq/mmio/pad_mem

                              -- go to zero if            buf_state_q(i*8+6 downto i*8+3) = "0110" and not buf_state_q(i*8) and srq_wdone_tag_dec(i) and SRQ_TLXR_WDONE_VAL and not SRQ_TLXR_WDONE_LAST
                                          GATE(XOR_REDUCE('1' & mmio_tlxr_resp_code) & "100" & mmio_tlxr_resp_code,                                      buf_state_q(i*8+6 downto i*8+3) = "0110" and not buf_state_q(i*8) and mmio_wdone_tag_dec(i) and MMIO_TLXR_WR_BUF_FREE) or
                                          GATE(buf_state_q(i*8+7) & "011" & buf_state_q(i*8+3 downto i*8),                                               buf_state_q(i*8+6 downto i*8+3) = "0110" and  not (buf_state_q(i*8+2 downto i*8) = "001" or  buf_state_q(i*8+2 downto i*8) = "011" or (not buf_state_q(i*8) and srq_wdone_tag_dec(i) and SRQ_TLXR_WDONE_VAL) or (not buf_state_q(i*8) and mmio_wdone_tag_dec(i) and MMIO_TLXR_WR_BUF_FREE))) or
                                                    -- state 4 (only the hold state - else -> 000000)
                                          GATE(buf_state_q(i*8+7) & "100" & buf_state_q(i*8+3 downto i*8),                                               buf_state_q(i*8+6 downto i*8+4) = "100" and tag_return_candidates_q(i)) or
                                                    -- state 7
                                          GATE("01001000",                                                                                               buf_state_q(i*8+6 downto i*8+0) = "1110001") or    -- write_pad_pattern with BAD bit
                                          GATE(XOR_REDUCE('1' & buf_state_q(i*8+3 downto i*8)) & "100" & buf_state_q(i*8+3 downto i*8),                  buf_state_q(i*8+6 downto i*8+3) = "1111") or -- fail non srq/mmio/pad_mem


                                          GATE("11000000",                                                                                               buf_state_q(i*8+6 downto i*8+3) = "1110" and not buf_state_q(i*8) and srq_wdone_tag_dec(i) and SRQ_TLXR_WDONE_VAL and SRQ_TLXR_WDONE_LAST ) or
                                          -- go to zero if                                                                                               buf_state_q(i*8+6 downto i*8+3) = "1110" and not buf_state_q(i*8) and srq_wdone_tag_dec(i) and SRQ_TLXR_WDONE_VAL and not SRQ_TLXR_WDONE_LAST
                                          GATE(XOR_REDUCE('1' & mmio_tlxr_resp_code) & "100" & mmio_tlxr_resp_code,                                      buf_state_q(i*8+6 downto i*8+3) = "1110" and not buf_state_q(i*8) and mmio_wdone_tag_dec(i) and MMIO_TLXR_WR_BUF_FREE) or
                                          GATE(buf_state_q(i*8+7) & "111" & buf_state_q(i*8+3 downto i*8),                                               buf_state_q(i*8+6 downto i*8+3) = "1110" and not (buf_state_q(i*8+2 downto i*8) = "001" or  buf_state_q(i*8+2 downto i*8) = "011" or (not buf_state_q(i*8) and srq_wdone_tag_dec(i) and SRQ_TLXR_WDONE_VAL) or (not buf_state_q(i*8) and mmio_wdone_tag_dec(i) and MMIO_TLXR_WR_BUF_FREE)));

        buffer_busy(i) <= '1' when buf_state_q(i*8+6 downto i*8+4) /= "000" or (i=63 and cfg_half_dimm_mode_q = '1') else '0';
        TLXR_SRQ_WRBUF_CRCVAL_VEC(i)   <= '1' when buf_state_q(i*8+5 downto i*8+4) = "11" or (i=63 and cfg_half_dimm_mode_q='1') else '0';
        tlxr_wdf_wrbuf_bad_i(i)        <= '1' when buf_state_q(i*8+6 downto i*8+4) = "111" else '0';

             -- this one is always at ctl0 time and covers immediate bad bits in T7 or TA and the previous data flits signalled bad in the current control flit
        advance_crc(i) <= '1' when (buf_state_q(i*8+6 downto i*8+4) = "010" and dec_ctl0 = '1') or    -- this includes not failed
                                   (buf_state_q(i*8+6 downto i*8+4) = "001" and (dec_ctl0 and twwp_dec(i) and last_wdf_phase_df)='1') or  -- corner case last_wdf-ph can be as late as dec_ctl0
                                   (             last_wdf_phase_7A                  and twwp_dec(i)) = '1'
                             else '0';

        data_is_patt(i) <= '1' when buf_state_q(i*8+3 downto i*8+0)="0001" and buf_state_q(i*8+6 downto i*8+4)/="100"     -- data bound for buffer 63
                                    else '0'; -- Cmd associated with buffer is for wr_pad_pattern

                    -- this is early_w_done case where the sequencer says wdone after the tag has been accepted by tlxt
        tag_rls_earlies(i)  <= '1' when buf_state_q(i*8+5 downto i*8+4) = "11" and (tag_return_candidates_q(i) = '0' or reset_tag_return(i) = '1')
                                   and early_wr_done_bf_q(i) = '1' and (srq_wdone_tag_dec(i) and SRQ_TLXR_WDONE_VAL and SRQ_TLXR_WDONE_LAST)  = '1'
                         else '0';

        tag_rls_lates(i)    <= '1' when buf_state_q(i*8+6 downto i*8+4) = "100" and buf_state_q(i*8+3 downto i*8) /= "1101" and reset_tag_return(i) = '1' else '0';  -- late mode or early mode and sequencer says wdone before tag accepted

        tag_rls_256s(i)     <= '1' when buf_state_q(i*8+6 downto i*8)   = "1001101" and reset_err_return(i) = '1' else '0'; -- write errors

        tag_rls_xtra(i)     <= '1' when buf_state_q(i*8+6 downto i*8+3)   = "1001" and buf_state_q(i*8+2 downto i*8) /= "101" and reset_err_return(i) = '1' and tag_store_corrected(1 downto 0) = "10" else '0';

        buf_state_pe(i)     <= XOR_REDUCE(buf_state_q(i*8+7 downto i*8));


  end generate buffer_state_gen;

      twwp_d  <= tlxr_wdf_wrbuf_pointer; -- latch for timing

      --synopsys translate_off
      assert not (NBITS(tag_rls_earlies) > 1 and GCKN'event and GCKN='0' and syncr = '0') report "BAM!" severity error;
      assert not ((tlxr_tlxt_errors_d(49) or tlxr_tlxt_errors_d(24)) = '1' and (last_wdf_phase_df or last_wdf_phase_7a) = '1' and GCKN'event and GCKN = '0' and  syncr = '0') report "collision between delivery error and last phase)." severity error;
      --synopsys translate_on

      t7_bad_d  <= ( dec_ctl0 and template_7_q and flit_q(263) and flit_q(264) )                            or -- 263 = bad 264 = valid data
                   ( (decode_ctl_cycle_q(1) or decode_ctl_cycle_q(2)) and template_7_q and dataflow_perr_q) or
                   ( t7_bad_q and not (last_wdf_phase_7a and (template_7_q or template_A_q)));

      tA_bad_d  <= ( dec_ctl0 and template_A_q and flit_q(328) and flit_q(329) )                     or -- 328 = bad 329 = valid data
                   ( OR_REDUCE(decode_ctl_cycle_q(3 downto 1)) and template_7_q and dataflow_perr_q) or
                   ( tA_bad_q and not (last_wdf_phase_7a and (template_A_q or template_7_q)));

      TLXR_WDF_WRBUF_BAD(0 to 63)  <= tlxr_wdf_wrbuf_bad_i(0 to 63);
      TLXR_WDF_WRBUF_BAD(64)       <= XOR_REDUCE(tlxr_wdf_wrbuf_bad_i(0 to 63)); -- ! need sensible approach
      mmio_idle_wdone              <= OR_REDUCE(  (mmio_wdone_tag_dec(62 downto 0) and not buffer_busy(62 downto 0)) &
                                                  (mmio_wdone_tag_dec(63) and not cfg_half_dimm_mode_q and not buffer_busy(63))
                                               ) and MMIO_TLXR_WR_BUF_FREE;     -- error
      srq_idle_wdone               <= SRQ_TLXR_WDONE_VAL and (
                                      OR_REDUCE(srq_wdone_tag_dec(62 downto 0) and not buffer_busy(62 downto 0))  or
                                      (srq_wdone_tag_dec(63) and not buffer_busy(63) and not cfg_half_dimm_mode_q));

      dcp1_rls_notag                 <= SRQ_TLXR_WDONE_VAL and NOT SRQ_TLXR_WDONE_LAST; -- release first half of 128B transfer
      dcp1_rls_earlies               <= or_reduce(tag_rls_earlies);
      dcp1_rls_xtra                  <= or_reduce(tag_rls_xtra);
      dcp1_rls_lates                 <= or_reduce(tag_rls_lates);
      vc1_rls_patt                   <= tlxr_srq_cmd_used and pad_patt_write; -- Release instead of sending cmd to SRQ.
      vc0_rls_memctl_d(1 downto 0)   <= vc0_rls_memctl_q(0) & OR_REDUCE(reset_tag_return(67 downto 64)); -- Tag delivered for a mem_cntl;

      buffers_idle <= not OR_REDUCE(buffer_busy(62 downto 0) & (buffer_busy(63) and not cfg_half_dimm_mode_q));
                            --------------
                            -- BAD Bits --
                            --------------

--     we have a list of up to eight buffer numbers which we clear when we see a good control flit. each bit also has a valid as the msb

       dbuf_wp_d <= "0000" when decode_ctl_cycle_q(1) = '1' or tlxr_flit_error = '1' else     -- required to be top for template 7
                    dbuf_wp_q + "0001" when decode_data_cycle_q(1) = '1' else
                    dbuf_wp_q;

       dbuf_wp_held_d <= dbuf_wp_q when decode_data_cycle_q(1) = '1' else dbuf_wp_held_q;
       dflow_pe_held_d <= ((dataflow_perr_q and tlxr_wdf_wrbuf_wr_i) or dflow_pe_held_q) and not last_wdf_phase_df ;

dbl_gen: for i in 0 to 7 generate  -- one clock after read_64b the buffer number will be valid and we store it in the list
          dbuf_list_d(i*8+5 downto i*8) <= tlxr_wdf_wrbuf_pointer when To_std_ulogic_vector(i,4) = dbuf_wp_q and decode_data_cycle_q(1) = '1' else
                                           dbuf_list_q(i*8+5 downto i*8);

          dbuf_list_d(i*8+7)            <= '0' when dec_ctl0 = '1'  else                                  -- the valid bit
                                           '1' when To_std_ulogic_vector(i,4) = dbuf_wp_q and dec_dat0 = '1' else
                                           dbuf_list_q(i*8+7);

          dbuf_list_d(i*8+6)            <= (dataflow_perr_q or dflow_pe_held_q) when last_wdf_phase_df = '1' and To_std_ulogic_vector(i,4) = dbuf_wp_held_q  else
                                           dbuf_list_q(i*8+6);
         end generate dbl_gen;

fdb_gen: for i in 0 to 63 generate 
          flit_dat_bad(i) <= ((dbuf_list_q(7)  and (dbuf_list_q(5 downto 0)   = To_std_ulogic_vector(i,6)) and (flit_q(452) or dbuf_list_q(6 ))) or
                              (dbuf_list_q(15) and (dbuf_list_q(13 downto 8)  = To_std_ulogic_vector(i,6)) and (flit_q(453) or dbuf_list_q(14))) or
                              (dbuf_list_q(23) and (dbuf_list_q(21 downto 16) = To_std_ulogic_vector(i,6)) and (flit_q(454) or dbuf_list_q(22))) or
                              (dbuf_list_q(31) and (dbuf_list_q(29 downto 24) = To_std_ulogic_vector(i,6)) and (flit_q(455) or dbuf_list_q(30))) or
                              (dbuf_list_q(39) and (dbuf_list_q(37 downto 32) = To_std_ulogic_vector(i,6)) and (flit_q(456) or dbuf_list_q(38))) or
                              (dbuf_list_q(47) and (dbuf_list_q(45 downto 40) = To_std_ulogic_vector(i,6)) and (flit_q(457) or dbuf_list_q(46))) or
                              (dbuf_list_q(55) and (dbuf_list_q(53 downto 48) = To_std_ulogic_vector(i,6)) and (flit_q(458) or dbuf_list_q(54))) or
                              (dbuf_list_q(63) and (dbuf_list_q(61 downto 56) = To_std_ulogic_vector(i,6)) and (flit_q(459) or dbuf_list_q(62)))
                              ) and dec_ctl0;
         end generate fdb_gen;

                            -----------------
                            -- Tag Release --
                            -----------------

TAG_ARRAY: ENTITY work.cb_tlxr_array
    GENERIC MAP (
      width      => 24,          -- the opencapi tag
      depth      => 68,          -- one entry per buffer number
      addr_width => 7)           --- read width. write width = 68
    PORT MAP (
      GCKN   => GCKN,
      din    => oc_tag_dl_ecc,   -- 16 tag, 2 length, 6 ecc
      wr     => tag_store_we,
      wr_ptr => tag_store_waddr,
      rd     => resp_cnt(1),
      rd_ptr => tag_store_raddr_q,
      GND    => GND,
      VDD    => VDD,
      dout   => tag_store_out);

      no_return_candidates <= not OR_REDUCE(tag_return_candidates_q);

      PP_FAIRNESS(tag_return_candidates_q,turn_taken_q,bttg,turn_taken_new);

      turn_taken_d <= turn_taken_new when resp_cnt(1) ='1' else turn_taken_q;

      tag_store_raddr_d <=  enc_68_7(bttg) when resp_cnt(0) = '1' else
                            tag_store_raddr_q;

      reset_tag_return <= GATE(dec_7_68(tag_store_raddr_q(6 downto 0)), resp_cnt(2));

      resp_cnt2_d <=  resp_cnt(2);

      reset_err_return <=  GATE(dec_7_68(tag_store_raddr_q(6 downto 0)), resp_cnt2_q);

      mem_cntl_resp <= GATE("1110",(tag_store_raddr_q(5 downto 0) = "000000") and memcntl_fail_q(0)) or
                       GATE("1110",(tag_store_raddr_q(5 downto 0) = "000001") and memcntl_fail_q(1)) or
                       GATE("1110",(tag_store_raddr_q(5 downto 0) = "000010") and memcntl_fail_q(2)) or
                       GATE("1110",(tag_store_raddr_q(5 downto 0) = "000011") and memcntl_fail_q(3));

      resp_err_code_d(3 downto 0) <=
                       GATE(errcode_extract(tag_store_raddr_q(5 downto 0),buf_state_q), not tag_store_raddr_q(6) and resp_cnt(1)) or
                       GATE(mem_cntl_resp, tag_store_raddr_q(6) and resp_cnt(1))                                                  or
                       GATE(resp_err_code_q(3 downto 0), not resp_cnt(1));

      resp_err_code_d(7 downto 4) <= resp_err_code_q(3 downto 0) when resp_cnt(2) = '1' else resp_err_code_q(7 downto 4);

      resp_tmg_d <=  tag_store_out when resp_cnt(2) = '1' else resp_tmg_q;   -- additional stage for timing

                                                                                                                           
      ts_syndrome <= ECCGEN(resp_tmg_q(17 downto 0)) xor resp_tmg_q(23 downto 18);

      tag_store_corr <= ECCCORR_MAX('1',ts_syndrome,18); -- 19 is corrected, 18 is uncorrectable 17:0 is data correction


      tag_store_corrected <= resp_tmg_q(17 downto 0) xor tag_store_corr(17 downto 0);

      tlxr_tlxt_write_resp_d  <= GATE(tag_store_corrected(17 downto 2) & resp_err_code_q(7 downto 4) & tag_store_corrected(1 downto 0),resp_cnt(3)) or
                                 GATE(tlxr_tlxt_write_resp_q, not resp_cnt(3));

      TLXR_TLXT_WRITE_RESP     <= tlxr_tlxt_write_resp_q;

      tlxr_tlxt_write_resp_p_d   <= XOR_REDUCE(tlxr_tlxt_write_resp_d(21 downto 14)) &
                                    XOR_REDUCE(tlxr_tlxt_write_resp_d(13 downto 6))  &
                                    XOR_REDUCE(tlxr_tlxt_write_resp_d(5 downto 0)    &  resp_val_d(2));  

      TLXR_TLXT_WRITE_RESP_P   <= tlxr_tlxt_write_resp_p_q;

      TLXR_TLXT_WRITE_RESP_VAL <= resp_val_q(2);


      resp_cnt(0) <= OR_REDUCE(tag_return_candidates_q) and not resp_cnt(1) and not resp_val_q(0);-- latch a bttg/ttaken/reset that candidate
      resp_cnt_d  <= resp_cnt(0);
      resp_cnt(1) <=  resp_cnt_q;                                                             -- latch read address within array
      resp_cnt(2) <= resp_val_q(0) and (not resp_val_q(1) or not resp_val_q(2) or not TLXT_TLXR_WR_RESP_FULL);   -- latch timing latch
      resp_cnt(3) <= resp_val_q(1) and (not TLXT_TLXR_WR_RESP_FULL or not resp_val_q(2));                        -- latch output

      resp_val_d(0) <=  resp_cnt(1) or (resp_val_q(0) and not resp_cnt(2));                   -- array output valid
      resp_val_d(1) <=  resp_cnt(2) or (resp_val_q(1) and not resp_cnt(3));                   -- timing latch output valid
      resp_val_d(2) <=  (resp_cnt(3) and not tag_store_corr(18)) or (resp_val_q(2) and TLXT_TLXR_WR_RESP_FULL);     -- output latch valid

      release_4_dcp1 <=   or_reduce(tag_rls_256s);

                            -------------------------------------------
                            -- Buffer control and address generation --
                            -------------------------------------------

      bc_wr_gate <= (not op_held_q(4)  and using_cmd(0)) or          --
                    (not op_held_q(15) and using_cmd(1)) or          -- bc_wr_gate is 1 for a cmd with write data (excl pad_mem)
                    (not op_held_q(26) and using_cmd(2)) or
                    (not op_held_q(37) and using_cmd(3));

      buff_epow_halt <= buffctl_empty and shutdown_q(1);

      read_32b <= template_7_q and dec_ctl0 and flit_q(264) and not shutdown_q(2) and not buff_epow_halt;
      read_48b <= template_A_q and dec_ctl0 and flit_q(329) and not shutdown_q(2) and not buff_epow_halt;
      read_64b <= dec_dat0 and not shutdown_q(2) and not buff_epow_halt;

 BUFF_CTL: entity work.cb_tlxr_buff_ctl PORT MAP(
      GCKN                           => GCKN,                    --   in std_ulogic;
      GND                            => GND,                     --   inout power_logic;
      VDD                            => VDD,                     --   inout power_logic;
      SYNCR                          => syncr,
      LINK_UP                        => tlxr_link_up,        --   in std_ulogic;         -- aka reset_n
      HALF_DIMM_MODE                 => cfg_half_dimm_mode_q,
            -- write side signals                                --
      FIRST_TAG                      => first_tag,               --   in std_ulogic_vector(5 downto 0);
      SECOND_TAG                     => second_tag,              --   in std_ulogic_vector(5 downto 0);
      FORMAT                         => bc_format,               --   in std_ulogic_vector(3 downto 0);
            -- read side signals                                 --
      READ_32B                       => read_32b,                --   in std_ulogic  -- 32 bytes of template 7 data is about to be transferred
      READ_48B                       => read_48b,                --   in std_ulogic  -- 40 bytes of template A and eight bytes of junk is about to be transferred
      READ_64B                       => read_64b,                --   in std_ulogic  -- 64 bytes of data flit  is about to be transferred
      GOOD_CONTROL_FLIT              => dec_ctl0,                --   in std_ulogic; -- templates 7+a handled separately inside buff_ctl
      BACKUP                         => tlxr_flit_error,     --   latched and delayed before use
           -- outputs                                            --
      BI_FLIT_BUFFER                 => bi_flit_buffer,          --  out std_ulogic (1 for second half of buffer delivered in 2 t7's)
      LAST_WDF_PHASE_7A              => last_wdf_phase_7a,
      LAST_WDF_PHASE_DF              => last_wdf_phase_df,
      FORCE_BUF_63                   => force_buf_63,            --  eponymous
      TLXR_WDF_WRBUF_WR              => tlxr_wdf_wrbuf_wr_i,
      TLXR_WDF_WRBUF_POINTER         => tlxr_wdf_wrbuf_pointer,  --  out std_ulogic_vector(0 to 5);
      TLXR_WDF_WRBUF_WOFFSET         => TLXR_WDF_WRBUF_WOFFSET,  --  out std_ulogic_vector(0 to 1);
      TLXR_WDF_WRBUF_WR_PAR          => tlxr_wdf_wrbuf_wr_par,   --  out std_ulogic  --    !!!
      EMPTY                          => buffctl_empty,
      INSANE                         => buffctl_error
  );

     TLXR_WDF_WRBUF_WPTR          <= "111111" when force_buf_63='1'
                                else tlxr_wdf_wrbuf_pointer(0 to 5);

     TLXR_WDF_WRBUF_WR_P          <= tlxr_wdf_wrbuf_wr_par xor XOR_REDUCE(tlxr_wdf_wrbuf_pointer(0 to 5)) when force_buf_63='1'
                                else tlxr_wdf_wrbuf_wr_par;

     TLXR_WDF_WRBUF_WR        <= tlxr_wdf_wrbuf_wr_i;

                            --------------
                            -- METADATA --
                            --------------

               -- first capture the metadata

    t7_immed_meta <= GATE(flit_q(258 downto 256),template_7_q and not bi_flit_buffer) or
                     GATE(flit_q(261 downto 259),template_7_q and     bi_flit_buffer);


    meta_data_from_flit <= GATE(flit_q(110 downto 105) & flit_q(103 downto 98) & flit_q(96 downto 91) & flit_q(89 downto 84) &
                           flit_q(82  downto  77) & flit_q( 75 downto 70) & flit_q(68 downto 63) & flit_q(61 downto 56),template_4_q)  or
                           GATE((47 downto 12 => '0') & flit_q(278 downto 273) & flit_q(271 downto 266),template_7_q); -- only used for template 7


    meta_store_d  <= ECCGEN_48(meta_data_from_flit) & meta_data_from_flit when ((template_4_q or template_7_q) and dec_ctl0) = '1' else  -- 48 data 8 ecc
                     (others => '0')                                      when (not (template_4_q or template_7_q) and dec_ctl0) = '1' else
                     meta_store_q;

               -- now regenerate and prepare for use
    data_flit_num_d <= "000" when ((control_flit and partial_flit_count_3 and tlxr_flit_vld) or tlxr_flit_error) = '1' else
                       data_flit_num_q + "001"  when decode_data_cycle_q(3) = '1'                     else
                       data_flit_num_q;

    meta_syndrome <= ECCGEN_48(meta_store_q(47 downto 0)) xor meta_store_q(55 downto 48);

    meta_corr     <= ECCCORR_48('1',meta_syndrome); -- 49 is corrected 48 is uncorrectable 47:0 is data correction

    meta_unc       <= meta_corr(48); -- uncorrectable tag_store corruption


    meta_corrected <= meta_store_q(47 downto 0) xor meta_corr(47 downto 0);

    metadata_d(5 downto 0) <= meta_corrected(47 downto 42) when data_flit_num_d = "111" else
                              meta_corrected(41 downto 36) when data_flit_num_d = "110" else
                              meta_corrected(35 downto 30) when data_flit_num_d = "101" else
                              meta_corrected(29 downto 24) when data_flit_num_d = "100" else
                              meta_corrected(23 downto 18) when data_flit_num_d = "011" else
                              meta_corrected(17 downto 12) when data_flit_num_d = "010" else
                              meta_corrected(11 downto  6) when data_flit_num_d = "001" else
                              meta_corrected( 5 downto  0);

    metadata <=  (others => '0') when cfg_f1_octrl00_metadata_enabled = '0' else
                 "000" & t7_immed_meta when (template_7_q or template_A_q) = '1' else metadata_q;

                            --------------
                            -- DATA ECC --
                            --------------
                      -- parity of input data should = parity of ecc byte (for this ecc)
                                                                            -- recode as gate and remove flit_error ????
    ecc_data_in(129 downto 0) <= flit_q(127 downto 64)  & '0'         & flit_q(63 downto 0)    & metadata(0) when  (decode_data_cycle_q(0) or (decode_ctl_cycle_q(0) and (template_A_q or template_7_q))) = '1' else
                                 flit_q(255 downto 192) & metadata(1) & flit_q(191 downto 128) & metadata(2) when  (decode_data_cycle_q(1) or (decode_ctl_cycle_q(1) and (template_A_q or template_7_q))) = '1' else
                                 flit_q(383 downto 320) & '0'         & flit_q(319 downto 256) & metadata(3) when   decode_data_cycle_q(2) = '1' else
                                 (129 downto 65 => '0')               & flit_q(319 downto 256) & metadata(3) when  (decode_ctl_cycle_q(2) and template_A_q) = '1' else
                                 flit_q(511 downto 448) & metadata(4) & flit_q(447 downto 384) & metadata(5) when   decode_data_cycle_q(3) = '1' else
                                 (others => '0');

DATA_ECC: for i in 0 to 1 GENERATE

EIGHT_B_ECC: entity work.cb_8beccg_comp PORT MAP(
      gnd             =>  GND,                                      --  : inout power_logic
      vdd             =>  VDD,                                      --  : inout power_logic
    --inputs                                                        --
      data_in         =>  ecc_data_in(i*65+64 downto i*65),         --  : in std_ulogic_vector(flit_q4)   --  (0:63) = data, (64) = tag
      err_inj0        =>  '0',                                      --  : in std_ulogic                   --  invert data(0)
      err_inj1        =>  '0',                                      --  : in std_ulogic                   --  invert data(1)
      derr_in         =>  meta_unc,                                 --  : in std_ulogic                   --  generate SUE code
    --outputs                                                       --
      data_out        =>  ecc_data_out(i*73+72 downto i*73) --  : out std_ulogic_vector(0 to 72)   --
  );
end GENERATE;


      ecc_par_in_d(1 downto 0)  <= GATE(flit_8bp_q(1)                   & (flit_8bp_q(0) xor metadata(0)), dec_dat0 or (dec_ctl0 and (template_A_q or template_7_q))) or
                                   GATE((flit_8bp_q(3) xor metadata(1)) & (flit_8bp_q(2) xor metadata(2)), decode_data_cycle_q(1) or (decode_ctl_cycle_q(1) and (template_A_q or template_7_q))) or
                                   GATE(flit_8bp_q(5)                   & (flit_8bp_q(4) xor metadata(3)), decode_data_cycle_q(2)) or
                                   GATE( '0'                            & (flit_8bp_q(4) xor metadata(3)), decode_ctl_cycle_q(2) and template_A_q) or
                                   GATE((flit_8bp_q(7) xor metadata(4)) & (flit_8bp_q(6) xor metadata(5)), decode_data_cycle_q(3));
      --synopsys translate_off
      assert not (XOR_REDUCE(ecc_data_in(64 downto 0)) /= XOR_REDUCE(ecc_data_out(7 downto 0)) and GCKN'event and GCKN='0' and syncr = '0')   report "ls parity error" severity error;
      assert not (XOR_REDUCE(ecc_data_in(65+64 downto 65)) /= XOR_REDUCE(ecc_data_out(80 downto 73)) and GCKN'event and GCKN='0' and syncr = '0') report "ms parity error" severity error;
      --synopsys translate_on

      dataflow_perr_d <= ((ecc_par_in_q(1) /= XOR_REDUCE(tlxr_wdf_wrbuf_dat_q(15 downto 8))) or
                          (ecc_par_in_q(0) /= XOR_REDUCE(tlxr_wdf_wrbuf_dat_q( 7 downto 0)))
                         ) and (
                                     or_reduce(decode_data_cycle_q(4 downto 1)) or ( or_reduce(decode_ctl_cycle_q(4 downto 1)) and (template_A_q or template_7_q))
                               );

      tlxr_wdf_wrbuf_dat_d(145 downto 0) <= ecc_data_out(145 downto 82) & ecc_data_out(72 downto 9) &  -- the data        ms ..... ls
                                        ecc_data_out(81) & ecc_data_out(8)                          &  -- the meta bits   ms ..... ls
                                        ecc_data_out(80 downto 73) & ecc_data_out(7 downto 0);         -- the ecc         ms ..... ls

      TLXR_WDF_WRBUF_DAT <= tlxr_wdf_wrbuf_dat_q;               -- little ended to big ended !


                            ------------------
                            -- BYTE ENABLES --
                            ------------------

      wrmembes <=  flit_q(279 downto 220) & flit_q(143 downto 140) & '0';

      b_enabs <= wrmembes(0 to 63)      when using_cmd_ne(1) = '1' and flit_74(7 downto 0) = x"82"    else --   write_mem_be
                 make_bes(flit_30(33 downto 28) & flit_30(111 downto 109)) when using_cmd_ne(0) = '1'        else --   pr_wr_mem
                 make_bes(flit_74(33 downto 28) & flit_74(111 downto 109)) when using_cmd_ne(1) = '1'        else --   (86)
                 make_bes(flit_B8(33 downto 28) & flit_B8(111 downto 109)) when using_cmd_ne(2) = '1'        else
                 make_bes(flit_FC(33 downto 28) & flit_FC(111 downto 109));


BE_ECC_GEN: entity work.cb_8beccg_comp PORT MAP(
      gnd                 =>  GND,                      --  : inout power_logic
      vdd                 =>  VDD,                      --  : inout power_logic
    --inputs                                            --
      data_in             =>  wrmembes,                 --  : in std_ulogic_vector(flit_q4)   --  (0:63) = data, (64) = tag
      err_inj0            =>  '0',                      --  : in std_ulogic                   --  invert data(0)
      err_inj1            =>  '0',                      --  : in std_ulogic                   --  invert data(1)
      derr_in             =>  '0',                      --  : in std_ulogic                   --  generate SUE code
    --outputs                                           --
      data_out(0 to 72) => be_ecc_out
  );

      tlxr_wdf_be_d(0  to 63) <= b_enabs(0 to 63);
      tlxr_wdf_be_d(64 to 71) <= GATE(be_ecc_out(65 to 72), using_cmd_ne(1) and flit_74(7 downto 0) = x"82") or
                                 GATE(make_ecc(flit_30(33 downto 28) & flit_30(111 downto 109)), using_cmd_ne(0))        or
                                 GATE(make_ecc(flit_74(33 downto 28) & flit_74(111 downto 109)), using_cmd_ne(1) and flit_74(7 downto 0) /= x"82")  or
                                 GATE(make_ecc(flit_B8(33 downto 28) & flit_B8(111 downto 109)), using_cmd_ne(2))        or
                                 GATE(make_ecc(flit_FC(33 downto 28) & flit_FC(111 downto 109)), using_cmd_ne(3));

      TLXR_WDF_BE             <= tlxr_wdf_be_q;
      tlxr_wdf_be_wr_d        <= ((using_cmd(0) and op_held_q(6) ) or (using_cmd(1) and op_held_q(17)) or
                                  (using_cmd(2) and op_held_q(28) ) or (using_cmd(3) and op_held_q(39)))
                                  and not cfg_half_dimm_mode_q;

      tlxr_wdf_be_wr_p_d      <=  XOR_REDUCE(tlxr_wdf_be_wr_d & first_tag);
      first_tag_d             <= first_tag;

      TLXR_WDF_BE_WR          <= tlxr_wdf_be_wr_q;
      TLXR_WDF_BE_WPTR        <= first_tag_q;
      TLXR_WDF_BE_WR_P        <= tlxr_wdf_be_wr_p_q;

                         -------------------
                         -- credit return --
                         -------------------

      credit_return_by_slot(0) <=  (flit_q(119 downto 112) = x"01"); -- slot 4
      credit_return_by_slot(1) <=  (flit_q(231 downto 224) = x"01"); -- slot 8
      credit_return_by_slot(2) <=  (flit_q(343 downto 336) = x"01"); -- slot 12
      credit_return_by_slot(3) <=  (flit_q(287 downto 280) = x"01"); -- slot 10

      tlxr_tlxt_return_val_i  <= not disable_credit_update and dec_ctl0 and not template_7_q and not template_A_q and (flit_q(7 downto 0) = x"01");
      TLXR_TLXT_RETURN_VAL    <= tlxr_tlxt_return_val_i;
      TLXR_TLXT_RETURN_VC0    <= flit_q(11 downto 8);
      TLXR_TLXT_RETURN_VC3    <= flit_q(23 downto 20);             -- these five from return_tlx_credits OC cmd
      TLXR_TLXT_RETURN_DCP0   <= flit_q(37 downto 32);
      TLXR_TLXT_RETURN_DCP3   <= flit_q(55 downto 50);


      tlxr_tlxt_consume_dcp1_d  <= "000" when bc_format(2 downto 0) = "000" else
                                   "010" when bc_format(2 downto 0) = "011" else
                                   "100" when bc_format(2 downto 0) = "100" else  -- we consume 4 for 256 bytes
                                   "001";

      TLXR_TLXT_CONSUME_DCP1    <=  tlxr_tlxt_consume_dcp1_q;

      TLXR_TLXT_CONSUME_VC1     <= tlxr_srq_cmd_used and not mem_cntl; -- mem_cntl is a TL.vc.0 command

      -- release buffer when tag goes to tlxt and we already had the done

      -- we can never have a 256 and a late in the same cycle because they both depend on release_tag_return which is one hot

      tlxr_tlxt_dcp1_release_i  <=  (release_4_dcp1 & '0' & dcp1_rls_xtra) + ("00" & dcp1_rls_notag) + ("00" & dcp1_rls_lates) + ("00" & dcp1_rls_earlies);

      TLXR_TLXT_DCP1_RELEASE    <= tlxr_tlxt_dcp1_release_i;

      TLXR_TLXT_VC1_RELEASE     <= vc1_rls_patt or oc_wr_err or mem_pfch; -- For set_pad_pattern or errors (which don't go to SRQ)

      tlxr_tlxt_vc0_release_i   <= ('0' & vc0_rls_memctl_q(1)) + ('0' & vc0_rls_intrp);  -- For mem_ctl/intrp_resp (which doesn't go to SRQ either)
      TLXR_TLXT_VC0_RELEASE     <= tlxr_tlxt_vc0_release_i;

      -- Commands intrp_resp and mem_cntl are TL.vc.0 commands. Maximum of one consume delivered per clock cycle.
      -- and intrp_rdy


      resp_or_rdy(0) <=  (flit_30(7 downto 0) = x"0C") or (flit_30(7 downto 0) = x"1A");
      resp_or_rdy(1) <=  (flit_74(7 downto 0) = x"0C") or (flit_74(7 downto 0) = x"1A");
      resp_or_rdy(2) <=  (flit_B8(7 downto 0) = x"0C") or (flit_B8(7 downto 0) = x"1A");
      resp_or_rdy(3) <=  (flit_FC(7 downto 0) = x"0C") or (flit_FC(7 downto 0) = x"1A");
      resp_or_rdy(4) <=  (flit_q(287 downto 280) = x"0C") or (flit_q(287 downto 280) = x"1A");

      tlxr_tlxt_consume_vc0_i <= '1' when ( resp_or_rdy(0) = '1'      and (template_7_q or template_A_q) = '0' and dec_ctl0 = '1')                              or
                                        ( flit_30(7 downto 0) = x"EF" and (template_7_q or template_0_q or template_A_q) = '0' and dec_ctl0 = '1')              or
                                        ( resp_or_rdy(1) = '1'        and (template_7_q or template_A_q) = '0' and decode_ctl_cycle_q(1) = '1')                 or
                                        ( flit_74(7 downto 0) = x"EF" and (template_7_q or template_A_q) = '0' and decode_ctl_cycle_q(1) = '1')                 or
                                        ( resp_or_rdy(2) = '1'        and (template_7_q or template_0_q or template_A_q) = '0' and decode_ctl_cycle_q(2) = '1') or
                                        ( flit_B8(7 downto 0) = x"EF" and (template_7_q or template_0_q or template_A_q) = '0' and decode_ctl_cycle_q(2) = '1') or
                                        ( resp_or_rdy(3) = '1'        and template_0_q = '0'                   and decode_ctl_cycle_q(3) = '1')                 or
                                        ( flit_FC(7 downto 0) = x"EF" and template_0_q = '0'                   and decode_ctl_cycle_q(3) = '1')                 or
                                        ( resp_or_rdy(4) = '1'        and template_7_q = '1'                and decode_ctl_cycle_q(2) = '1') else '0';  -- don't need flit_b8 for these bits

      TLXR_TLXT_CONSUME_VC0   <= tlxr_tlxt_consume_vc0_i;


      vc0_rls_intrp <= '1' when ( resp_or_rdy(0) = '1' and (template_7_q or template_A_q) = '0' and dec_ctl0 = '1')                              or
                                ( resp_or_rdy(1) = '1' and (template_7_q or template_A_q) = '0' and decode_ctl_cycle_q(1) = '1')                 or
                                ( resp_or_rdy(2) = '1' and (template_7_q or template_0_q or template_A_q) = '0' and decode_ctl_cycle_q(2) = '1') or
                                ( resp_or_rdy(3) = '1' and template_0_q = '0'                   and decode_ctl_cycle_q(3) = '1')                 or
                                ( resp_or_rdy(4) = '1' and template_7_q = '1'                   and decode_ctl_cycle_q(2) = '1') else '0';  -- don't need flit_b8 for these bits


      act                       <= '1';

                            ----------------------
                            -- EARLY WRITE DONE --
                            ----------------------



EWD_GEN: for i in 0 to 63 GENERATE
--                                                 bit 0     bit 1
--
--            write_mem               110100001      X
--            pr_wr_mem dram          011100010               x
--            wr_meme.be              011100010               x
--
--            pr_wr_mem mmio          011000101          0         always late
--            config                       1001          0         always late
--            mem_ctl                      1100          0         uses new 67-64 bits handled separately
--            pad_mem                      0011          0         srq sends earlyish
--            pr_wr_mem to pad_mem buffer  1111          0         doesn't use _bf_thing
--




     early_wr_done_bf_d(i)  <= not tlxt_tlxr_early_wdone_disable(0) when bc_wr_gate = '1' and ((first_dec(i)='1' and length_format_2 = "101") or  -- 64 to dram write_mem
                                                                                               (second_dec(i)='1' and length_format_2 = "110"))   -- 128 to dram write_mem
                                                                                                                                                       else
                               not tlxt_tlxr_early_wdone_disable(1) when bc_wr_gate = '1' and pr_wr_dram = '1' and first_dec(i)='1'                -- pr_wr_mem/wr_mem.be
                                                                                                                                                       else
                                '0'                                 when bc_wr_gate = '1' and first_dec(i)='1'                                         else

                               early_wr_done_bf_q(i);


      tag_return_candidates_d(i) <= '1' when ( buf_state_q(i*8+5 downto i*8+4) = "11" and (not early_wr_done_bf_q(i) and
                                               srq_wdone_tag_dec(i) and SRQ_TLXR_WDONE_VAL and SRQ_TLXR_WDONE_LAST) = '1'
                                             ) or (
                                               buf_state_q(i*8+5 downto i*8  ) =  "110001" -- pad_pattern_write case
                                             ) or (
                                               buf_state_q(i*8+6 downto i*8+4) = "001" and (twwp_dec(i) and (tlxr_tlxt_errors_d(49) or tlxr_tlxt_errors_d(24))) = '1'  -- bad template used for data delivery
                                             ) or (
                                               buf_state_q(i*8+5 downto i*8+4) = "11" and (mmio_wdone_tag_dec(i) and MMIO_TLXR_WR_BUF_FREE) = '1'
                                             ) or (
                                               (advance_crc(i) and early_wr_done_bf_q(i)) = '1'
                                             ) or (
                                               buf_state_q(i*8+5 downto i*8+3) =  "111"           -- write failure
                                             )      else

                                    '0' when reset_tag_return(i) = '1' else
                                    tag_return_candidates_q(i);

end GENERATE EWD_GEN;


      tag_return_candidates_d(67 downto 64) <= set_memcntl_busy(3 downto 0)  or
                                               (tag_return_candidates_q(67 downto 64) and not reset_tag_return(67 downto 64));


                            ---------------
                            -- INTR_RESP --
                            ---------------

     int_resp <= GATE('1' & flit_30(55 downto 52),(flit_30(7 downto 0) = x"0C") and not (template_7_q or template_A_q) and dec_ctl0 and not shutdown)                               or
                 GATE('1' & flit_74(55 downto 52), (flit_74(7 downto 0) = x"0C") and not (template_7_q or template_A_q) and decode_ctl_cycle_q(1) and not shutdown)                 or
                 GATE('1' & flit_B8(55 downto 52), (flit_B8(7 downto 0) = x"0C") and not (template_7_q or template_0_q or template_A_q) and decode_ctl_cycle_q(2) and not shutdown) or
                 GATE('1' & flit_FC(55 downto 52), (flit_FC(7 downto 0) = x"0C") and not template_0_q and decode_ctl_cycle_q(3) and not shutdown)                                   or
                 GATE('1' & flit_q(335 downto 332),(flit_q(287 downto 280) = x"0C") and template_7_q and decode_ctl_cycle_q(2) and not shutdown);

     int_rdy  <= GATE('1' & flit_30(55 downto 52),(flit_30(7 downto 0) = x"1A") and not (template_7_q or template_A_q) and dec_ctl0 and not shutdown)                               or
                 GATE('1' & flit_74(55 downto 52), (flit_74(7 downto 0) = x"1A") and not (template_7_q or template_A_q) and decode_ctl_cycle_q(1) and not shutdown)                 or
                 GATE('1' & flit_B8(55 downto 52), (flit_B8(7 downto 0) = x"1A") and not (template_7_q or template_0_q or template_A_q) and decode_ctl_cycle_q(2) and not shutdown) or
                 GATE('1' & flit_FC(55 downto 52), (flit_FC(7 downto 0) = x"1A") and not template_0_q and decode_ctl_cycle_q(3) and not shutdown)                                   or
                 GATE('1' & flit_q(335 downto 332),(flit_q(287 downto 280) = x"1A") and template_7_q and decode_ctl_cycle_q(2) and not shutdown);

     reserved_intrp_code <= (int_rdy(4) and (int_rdy(3 downto 0)  /= "0000") and (int_rdy(3 downto 0) /= "0010") and (int_rdy(3 downto 0) /= "1110")
                                                      ) or (
                            int_resp(4) and (int_resp(3 downto 0) /= "0000") and (int_resp(3 downto 0) /= "0010") and (int_resp(3 downto 0) /= "0100") and
                            (int_resp(3 downto 0) /= "1001") and (int_resp(3 downto 0) /= "1011") and (int_resp(3 downto 0) /= "1110"));

     intrp_resp_fail <= (int_resp(3 downto 0) = "1110") or (int_resp(3 downto 0) = "1011") or (int_resp(3 downto 0) = "1001");


intrp_resp_gen: for i in 1 to 4 generate   -- use the tag number
     signal      tag         : std_ulogic_vector(15 downto 0);
     signal fail_after_rdy   : std_ulogic;
     signal rty_after_dly    : std_ulogic;
     signal tag_valid        : std_ulogic;
     begin

     tag <= x"0001" when i = 1 else x"0002" when i = 2 else x"0003" when i = 3 else x"0004";

     tag_valid <= ( not (template_7_q or template_A_q) and dec_ctl0 and (flit_30(23 downto 8) = tag))                              or
                  ( not (template_7_q or template_A_q) and decode_ctl_cycle_q(1) and (flit_74(23 downto 8) = tag))                 or
                  ( not (template_7_q or template_0_q or template_A_q) and decode_ctl_cycle_q(2) and (flit_B8(23 downto 8) = tag)) or
                  ( not template_0_q and decode_ctl_cycle_q(3) and (flit_FC(23 downto 8) = tag))                                   or
                  (     template_7_q and decode_ctl_cycle_q(2) and (flit_q(303 downto 288) = tag));

     int_rdy_pending_d(i) <= ((int_resp = "10100") and tag_valid) = '1' or (int_rdy_pending_q(i) and not(int_rdy(4) and tag_valid) );                  -- code 4 means wait for intrp_rdy to come along

     fail_after_rdy  <= int_rdy(4) and (int_rdy(3 downto 0) /= "0000") and (int_rdy(3 downto 0) /= "0010") and  tag_valid;

     lbt_start(i) <= ((int_rdy = "10010") or (int_resp = "10010"))  and tag_valid;

     rty_after_dly <= lbt_finished(i) or ((int_rdy = "10000") and tag_valid);


     tlxr_tlxt_intrp_resp_d(i*2-1 downto i*2-2) <= "01" when int_resp = "10000" and tag_valid = '1'                                     else  -- good completion
                                                   "10" when rty_after_dly = '1'                                                        else  -- retry
                                                   "11" when ((int_resp(4) and intrp_resp_fail and tag_valid) = '1') or
                                                        fail_after_rdy = '1'                                                            else  -- fail
                                                   "00";                                                                                -- inactive

     bad_intrp_tagv(i) <= (not tag_valid) and int_resp(4);

end generate intrp_resp_gen;

   bad_intrp_tag <= AND_REDUCE(bad_intrp_tagv);

   tlxr_tlxt_intrp_resp <=  tlxr_tlxt_intrp_resp_q;


------------------------------------------------------
-- INTRP_RDY  and long timers
-------------------------------------------------------
                                            -- 1600MHz                            1333 MHZ
      lbt_prescale_d <= (others => '1') when lbt_prescale_q = x"60" or (tlxt_tlxr_control(15) = '1' and lbt_prescale_q = x"7B") else
                                   lbt_prescale_q - "00000001";

      hundred_ns1_d <= (lbt_prescale_q = x"8D") and OR_REDUCE(lbt_1_q);
      hundred_ns2_d <= (lbt_prescale_q = x"AE") and OR_REDUCE(lbt_2_q);
      hundred_ns3_d <= (lbt_prescale_q = x"CF") and OR_REDUCE(lbt_3_q);
      hundred_ns4_d <= (lbt_prescale_q = x"F0") and OR_REDUCE(lbt_4_q);


      lbt_1_d   <= lbt_icount when lbt_start(1) = '1' else
                   lbt_1_q  - (x"0000000" & "001");

      lbt_2_d   <= lbt_icount when lbt_start(2) = '1' else
                   lbt_2_q  - (x"0000000" & "001");
      lbt_3_d   <= lbt_icount when lbt_start(3) = '1' else
                   lbt_3_q  - (x"0000000" & "001");
      lbt_4_d   <= lbt_icount when lbt_start(4) = '1' else
                   lbt_4_q  - (x"0000000" & "001");

      lbt_finished(1)    <= (lbt_1_q = x"0000000" & "001") and hundred_ns1_q;
      lbt_finished(2)    <= (lbt_2_q = x"0000000" & "001") and hundred_ns2_q;
      lbt_finished(3)    <= (lbt_3_q = x"0000000" & "001") and hundred_ns3_q;
      lbt_finished(4)    <= (lbt_4_q = x"0000000" & "001") and hundred_ns4_q;

      lbt_icount      <= GATE("000" & x"0000001" ,(cfg_otl0_long_backoff_timer(3 downto 0) = "0000")) or
                         GATE("000" & x"0000004" ,(cfg_otl0_long_backoff_timer(3 downto 0) = "0001")) or
                         GATE("000" & x"0000010" ,(cfg_otl0_long_backoff_timer(3 downto 0) = "0010")) or
                         GATE("000" & x"0000040" ,(cfg_otl0_long_backoff_timer(3 downto 0) = "0011")) or
                         GATE("000" & x"0000100" ,(cfg_otl0_long_backoff_timer(3 downto 0) = "0100")) or
                         GATE("000" & x"0000400" ,(cfg_otl0_long_backoff_timer(3 downto 0) = "0101")) or
                         GATE("000" & x"0001000" ,(cfg_otl0_long_backoff_timer(3 downto 0) = "0110")) or
                         GATE("000" & x"0004000" ,(cfg_otl0_long_backoff_timer(3 downto 0) = "0111")) or
                         GATE("000" & x"0010000" ,(cfg_otl0_long_backoff_timer(3 downto 0) = "1000")) or
                         GATE("000" & x"0040000" ,(cfg_otl0_long_backoff_timer(3 downto 0) = "1001")) or
                         GATE("000" & x"0100000" ,(cfg_otl0_long_backoff_timer(3 downto 0) = "1010")) or
                         GATE("000" & x"0400000" ,(cfg_otl0_long_backoff_timer(3 downto 0) = "1011")) or
                         GATE("000" & x"1000000" ,(cfg_otl0_long_backoff_timer(3 downto 0) = "1100")) or
                         GATE("000" & x"4000000" ,(cfg_otl0_long_backoff_timer(3 downto 0) = "1101")) or
                         GATE("001" & x"0000000" ,(cfg_otl0_long_backoff_timer(3 downto 0) = "1110")) or
                         GATE("100" & x"0000000" ,(cfg_otl0_long_backoff_timer(3 downto 0) = "1111"));

       lbt_enab(4 downto 1)          <= lbt_start or ( hundred_ns4_q & hundred_ns3_q & hundred_ns2_q & hundred_ns1_q) ;
       lbt_prescale_enab <= OR_REDUCE(lbt_start & lbt_prescale_q & lbt_1_q & lbt_2_q & lbt_3_q & lbt_4_q);

-------------------------------------------------------------------------------
-- Errors, Fir bits etc
-------------------------------------------------------------------------------
     oc_wr_err <= (tlxr_tlxt_errors_d(40) and data_xfer) or tlxr_tlxt_errors_d(38) or  tlxr_tlxt_errors_d(32) or tlxr_tlxt_errors_d(31) or
                  tlxr_tlxt_errors_d(28) or tlxr_tlxt_errors_d(47);

     pad_mem_err <= pad_mem_unsupp_len or  pad_mem_unsupp_op;

     oc_rd_err <= tlxr_tlxt_errors_d(27) or
                  tlxr_tlxt_errors_d(39) or
                  tlxr_tlxt_errors_d(33) or
                  tlxr_tlxt_errors_d(34) or
                  tlxr_tlxt_errors_d(48) or
                  (tlxr_tlxt_errors_d(40) and not data_xfer) or
                  pad_mem_err;


     oc_wr_resp <= GATE("011",tlxr_tlxt_errors_d(47))                                 or                                                                  --   B
                   GATE("101",tlxr_tlxt_errors_d(28) and not tlxr_tlxt_errors_d(47) ) or                                                                  --   D -> 9 after credit of 4 returned
                   GATE("001",tlxr_tlxt_errors_d(32) or tlxr_tlxt_errors_d(31) )      or                                                                  --   9
                   GATE("110",(tlxr_tlxt_errors_d(40)  or tlxr_tlxt_errors_d(38)) and                                                                     --   E
                                not ( tlxr_tlxt_errors_d(47) or tlxr_tlxt_errors_d(28) or tlxr_tlxt_errors_d(32) or tlxr_tlxt_errors_d(31)) );            --
                   -- 000 is data error response                                                                                                          --   8

     oc_rd_resp <=  "011" when  (tlxr_tlxt_errors_d(48)) = '1'                                                                           else
                    "001" when  (tlxr_tlxt_errors_d(27) or tlxr_tlxt_errors_d(34) or tlxr_tlxt_errors_d(33) or pad_mem_unsupp_len) = '1' else
                    "110" when  (tlxr_tlxt_errors_d(39) or  tlxr_tlxt_errors_d(40) or pad_mem_unsupp_op) = '1'                           else
                    "000";

     -- parity bit as above. inverted for pad_mem things as bit 20 will be on too

     oc_rd_resp_p <= not pad_mem_err  when  (tlxr_tlxt_errors_d(39) or  tlxr_tlxt_errors_d(40) or pad_mem_unsupp_op) = '1'                           else
                         pad_mem_err  when  (tlxr_tlxt_errors_d(27) or tlxr_tlxt_errors_d(34) or tlxr_tlxt_errors_d(33) or pad_mem_unsupp_len) = '1' else
                    tlxr_tlxt_errors_d(48);

                            ----------------
                            -- ERROR BITS --
                            ----------------
     tlxr_tlxt_errors_d(0)  <= tlxr_tp_fir_trace_err_i; -- trace stop - not an error at all
     tlxr_tlxt_errors_d(1)  <= not shutdown_q(0) and SRQ_TLXR_EPOW;     -- not affected b
     tlxr_tlxt_errors_d(2)  <= buffctl_error(4);                        -- d_list correctable
     tlxr_tlxt_errors_d(3)  <= tag_store_corr(19) and resp_cnt(3);      -- correctable ecc error in tag store
     tlxr_tlxt_errors_d(4)  <= meta_corr(49);
     tlxr_tlxt_errors_d(5)  <= or_reduce(t7_bad_q & tA_bad_q & (flit_dat_bad and advance_crc));
     tlxr_tlxt_errors_d(6)  <= xlat_hole and translating; --address setup inconsistent (hole in address use)  INFORMATIONAL
     tlxr_tlxt_errors_d(7)  <= not bpv_q(2) and length_format_2(1) and write_mem;
     tlxr_tlxt_errors_d(8)  <= not bpv_q(1) and bc_wr_gate;
     tlxr_tlxt_errors_d(9)  <= (XOR_REDUCE(CFG_F1_CSH_MMIO_BAR0(63 downto 35) & CFG_F1_CSH_P & CFG_F1_CSH_MEMORY_SPACE)) and tlxt_tlxr_control(9); -- fatal
     tlxr_tlxt_errors_d(10) <= MMIO_TLXR_WR_BUF_FREE and  OR_REDUCE(mmio_tlxr_resp_code) and tlxt_tlxr_control(11);    -- mmio gave non-zero response code (fatal version)
     tlxr_tlxt_errors_d(11) <= buffctl_error(2);                           -- buffer control overflow
     tlxr_tlxt_errors_d(12) <= dataflow_perr_q and tlxt_tlxr_control(10);  -- fatal
     tlxr_tlxt_errors_d(13) <= buffctl_error(1);                           -- buffer control underflow
     tlxr_tlxt_errors_d(14) <= srq_idle_wdone;                             -- mmio wdone for idle buffer
     tlxr_tlxt_errors_d(15) <= XOR_REDUCE(SRQ_TLXR_WDONE_P & SRQ_TLXR_WDONE_LAST & SRQ_TLXR_WDONE_TAG) and SRQ_TLXR_WDONE_VAL;
     tlxr_tlxt_errors_d(16) <= mmio_idle_wdone;                            -- mmio wdone for idle buffer
     tlxr_tlxt_errors_d(17) <= XOR_REDUCE(mmio_tlxr_wr_buf_tag & mmio_tlxr_wr_buf_free & mmio_tlxr_resp_code & mmio_tlxr_wr_buf_par);
     tlxr_tlxt_errors_d(18)  <= OR_REDUCE(flit_perr) and tlxr_link_up;
     tlxr_tlxt_errors_d(19) <= '0';
     tlxr_tlxt_errors_d(20) <= op_held_perr;
     tlxr_tlxt_errors_d(21) <= tag_store_corr(18) and resp_cnt(3);
     tlxr_tlxt_errors_d(22) <= buffctl_error(3);   -- uncorrectable buffer control array corruption
     tlxr_tlxt_errors_d(23) <= OR_REDUCE(buf_state_pe);
     tlxr_tlxt_errors_d(24) <= buffctl_error(5) and cfg_half_dimm_mode_q; -- DDR data with T7 or data flit
     tlxr_tlxt_errors_d(25) <= unknown_template;
     tlxr_tlxt_errors_d(26) <= or_reduce(unknown_opcode_slot) and dec_ctl0;
     tlxr_tlxt_errors_d(27) <= rd_mem and not XOR_REDUCE(length_format_2(1 downto 0));
     tlxr_tlxt_errors_d(28) <= write_mem and length_format_2(1) and length_format_2(0);
     tlxr_tlxt_errors_d(29) <= pad_mem_unsupp_len;
     tlxr_tlxt_errors_d(30) <= pad_mem_unsupp_op;
     tlxr_tlxt_errors_d(31) <= pr_wr_mem and translating and cfg_half_dimm_mode_q and (length_format_3 /= "101");
     tlxr_tlxt_errors_d(32) <= (write_mem or write_membe) and cfg_half_dimm_mode_q;
     tlxr_tlxt_errors_d(33) <= rd_mem and cfg_half_dimm_mode_q;
     tlxr_tlxt_errors_d(34) <= tlxt_tlxr_low_lat_mode and not cfg_half_dimm_mode_q and translating and pr_rd_mem;
     tlxr_tlxt_errors_d(35) <= meta_corr(48);      -- uncorrectable corruption of stored metadata
     tlxr_tlxt_errors_d(36) <= dataflow_perr_q and not tlxt_tlxr_control(10);  -- non-fatal
         tlxr_wdf_wrbuf_bad63_d <= or_reduce(tlxr_wdf_wrbuf_bad_i and data_is_patt);
     tlxr_tlxt_errors_d(37) <= tlxr_wdf_wrbuf_bad63_d and not tlxr_wdf_wrbuf_bad63_q;  -- corrupted pad pattern
     tlxr_tlxt_errors_d(38) <= cmd_xlat_error and translating and data_xfer;
     tlxr_tlxt_errors_d(39) <= cmd_xlat_error and translating and not data_xfer;   -- fast_xlat_error not included after consideration
     tlxr_tlxt_errors_d(40) <= (xlat_drop or oc_oob) and translating and not pad_patt_write; -- address too big  bits dropped (an opencapi '1' address bit is dropped on translation FATAL
     tlxr_tlxt_errors_d(41) <= '0'; -- reserved; --address setup inconsistent (hole in address use)  FATAL
     tlxr_tlxt_errors_d(42) <= '0'; -- reserved
     tlxr_tlxt_errors_d(43) <= '0'; -- reserved
     tlxr_tlxt_errors_d(44) <= memctl_unknown_flag; -- not 0 or 1
     tlxr_tlxt_errors_d(45) <= bad_intrp_tag  ; -- bad interrupt tag - (not 1-4)
     tlxr_tlxt_errors_d(46) <= '0'; -- reserved
     tlxr_tlxt_errors_d(47) <= ( write_mem and (          -- don't think this can happen with rd_mem because of critical ow first
                      ((tlxr_srq_cmd_i(51 to 52) = "10") and oc_addr(6)                    )  or -- 128 byte write misaligned
                      ((tlxr_srq_cmd_i(51 to 52) = "11") and or_reduce(oc_addr(7 downto 6)))     -- 256 misaligned
                      )) or
                              ( pr_wr_mem and (
                    ((length_format_3 = "001") and oc_addr(0) )                       or      -- 2  byte write
                    ((length_format_3 = "010") and (oc_addr(1 downto 0) /= "00")    ) or      -- 4  byte write
                    ((length_format_3 = "011") and (oc_addr(2 downto 0) /= "000")   ) or      -- 8  byte write
                    ((length_format_3 = "100") and (oc_addr(3 downto 0) /= "0000")  ) or      -- 16 byte write
                    ((length_format_3 = "101") and (oc_addr(4 downto 0) /= "00000") ))        -- 32 byte write
                    );
     tlxr_tlxt_errors_d(48) <=  pr_rd_misalign; -- rd_mem case cannot occur.

     tlxr_tlxt_errors_d(49) <= buffctl_error(0); -- expected template_7 but didn't get one
     tlxr_tlxt_errors_d(50) <= ((pr_rd_mem or pr_wr_mem or cfg_op ) and (length_format_3(2 downto 1) = "11")) or
                               ((rd_mem or write_mem) and not length_format_2(1) and not length_format_2(0))  or
                               reserved_intrp_code;

     tlxr_tlxt_errors_d(51) <= template_0_q and dec_ctl0 and (flit_q(7 downto 1) /= "0000000");-- valid template 0 slot 0 not nop or credit
     tlxr_tlxt_errors_d(52) <= dec_ctl0 and (
                                        (template_0_q and credit_return_by_slot(0)) or                 -- template 0 slot 4
                                        (((flit_q(465 downto 460) = "000001") or template_4_q) and
                                            or_reduce( credit_return_by_slot(2 downto 0))              -- templates 1 and 4 slots 4 8 12
                                        )            or
                                        (template_7_q and (credit_return_by_slot(2) or credit_return_by_slot(3)))
                                                     or
                                        (template_a_q and  credit_return_by_slot(2)));

     tlxr_tlxt_errors_d(53) <= '0'; -- reserved


     tlxr_tlxt_errors_d(54) <= OR_REDUCE(invalid_opcode_slot) and dec_ctl0;
     tlxr_tlxt_errors_d(55) <= (XOR_REDUCE(CFG_F1_CSH_MMIO_BAR0(63 downto 35) & CFG_F1_CSH_P & CFG_F1_CSH_MEMORY_SPACE)) and not tlxt_tlxr_control(9); --  nonfatal

     tlxr_tlxt_errors_d(56) <= MMIO_TLXR_WR_BUF_FREE and  OR_REDUCE(mmio_tlxr_resp_code) and not tlxt_tlxr_control(11);    -- mmio gave non-zero response code (non-fatal version)
     tlxr_tlxt_errors_d(57) <= shutdown;
     tlxr_tlxt_errors_d(58) <= '0'; -- reserved

     TLXR_TLXT_ERRORS(58 downto 0) <=  tlxr_tlxt_errors_q(58 downto 0);
     TLXR_TLXT_ERRORS(63 downto 59) <= "00000";

     pr_rd_misalign <= pr_rd_mem and (
                         ((length_format_3 = "001") and oc_addr(0) )                                 or      -- 2  byte write
                         ((length_format_3 = "010") and (oc_addr(1 downto 0) /= "00"))               or      -- 4  byte write
                         ((length_format_3 = "011") and (oc_addr(2 downto 0) /= "000"))              or      -- 8  byte write
                         ((length_format_3(2 downto 1) = "10") and (oc_addr(3 downto 0) /= "0000"))  or      -- 16/32 byte write
                         ((length_format_3 = "101") and  not tlxt_tlxr_control(8) and oc_addr(4)) );         -- 32 byte write unless disabled

     rd_err_len_64 <= pr_rd_misalign or tlxr_tlxt_errors_d(34);

     fmt0_error <=  OR_REDUCE( tlxr_tlxt_errors_d(54) & tlxr_tlxt_errors_d(52) & tlxr_tlxt_errors_d(51) & tlxr_tlxt_errors_d(26) & tlxr_tlxt_errors_d(25));

     tlxr_tlxt_signature_strobe_d <= fmt0_error or tlxr_tlxt_errors_d(50) or tlxr_tlxt_errors_d(48) or tlxr_tlxt_errors_d(47) or ire_strobe
                              or   tlxr_tlxt_errors_d(44) or tlxr_tlxt_errors_d(40) or tlxr_tlxt_errors_d(31);

     tlxr_tlxt_signature_dat_d    <= gate(sig_fmt_0 & "001",     fmt0_error) or  -- five opcodes six template , bit 64
                                     gate(sig_fmt_1 & "100", not fmt0_error and using_cmd_ne(0) ) or
                                     gate(sig_fmt_2 & "101", not fmt0_error and using_cmd_ne(1) ) or
                                     gate(sig_fmt_3 & "110", not fmt0_error and using_cmd_ne(2) ) or
                                     gate(sig_fmt_4 & "111",(not fmt0_error and using_cmd_ne(3)) or (decode_ctl_cycle_q(3) and ire and not ire_pending_q) ) or
                                     gate(ire_fmt          , not fmt0_error and decode_ctl_cycle_q(3) and  ire_pending_q );

     ire <=  bad_intrp_tag or reserved_intrp_code ; -- intrp_resp:  bad tag or bad response code

     ire_strobe <=  decode_ctl_cycle_q(3) and (ire or ire_pending_q);

     ire_pending_d <= (ire_pending_q or ire) and not partial_flit_count_3;

     ire_rtag_d    <= GATE(flit_30(55 downto 52) & flit_30(23 downto 8) & "00" , decode_ctl_cycle_q(0) and ire and not ire_pending_q) or
                      GATE(flit_74(55 downto 52) & flit_74(23 downto 8) & "01", decode_ctl_cycle_q(1) and ire and not ire_pending_q) or
                      GATE(flit_B8(55 downto 52) & flit_B8(23 downto 8) & "10", not template_7_q and decode_ctl_cycle_q(2) and ire and not ire_pending_q) or      -- slot 12
                      GATE(flit_q(335 downto 332) & flit_q(303 downto 288) & "10",   template_7_q and decode_ctl_cycle_q(2) and ire and not ire_pending_q) or     -- slot 10
                      GATE(ire_rtag_q, ire_pending_q);

     ire_fmt       <= x"0C000" & ire_rtag_q(21 downto 18) & '0' & ire_rtag_q(17 downto 2) & x"00000" & '1' & ire_rtag_q(1 downto 0); -- used only in decode_ctl_cyc(3) and ire_pending_q

     tlxr_tlxt_signature_strobe   <= tlxr_tlxt_signature_strobe_q;
     tlxr_tlxt_signature_dat      <= tlxr_tlxt_signature_dat_q;

     errors_always_shutdown <= or_reduce( tlxr_tlxt_errors_q(54 downto 49) &
                                          tlxr_tlxt_errors_q(26 downto 7));

     errors_maybe_shutdown  <= or_reduce(tlxr_tlxt_errors_q(48 downto 38));

     shutdown_d(0) <= SRQ_TLXR_EPOW and tlxr_link_up;            -- MR_ADD INIT => "000"

     shutdown_d(1) <= ((not shutdown_q(0) and SRQ_TLXR_EPOW) or shutdown_q(1))
                       and (not tlxt_tlxr_control(13) or not tlxt_tlxr_control(14)) -- epow shutdown 14:13 == "11" disables all shutdowns
                       and tlxr_link_up  ;

     shutdown_d(2) <= ( errors_always_shutdown                               or
                         ( errors_maybe_shutdown  and tlxt_tlxr_control(12)) or       -- mmio bad_wr_resp (error component above)
                         shutdown_q(2)
                      )    and not tlxt_tlxr_control(14) and tlxr_link_up;

     shutdown      <=  shutdown_q(1) or shutdown_q(2);               -- epow and errors

     disable_credit_update <= shutdown_q(2) and not tlxt_tlxr_control(14) and tlxt_tlxr_control(13);

                           ---------------------
                           -- signature things --
                           ---------------------


                                    -- for invalid opcode, template0 has its own rules and is deliberately omitted here
      invalid_opcode_slot(0) <=  (invalid_opcode(flit_q(7 downto 0),0) and flit_q(465 downto 460) = "000001")  or
                                 (invalid_opcode(flit_q(7 downto 0),1) and template_4_q);
      invalid_opcode_slot(1) <=  invalid_opcode(flit_q(119 downto 112),0) and (flit_q(465 downto 460) = "000001" or template_4_q);
      invalid_opcode_slot(2) <=  invalid_opcode(flit_q(231 downto 224),0) and (flit_q(465 downto 460) = "000001" or template_4_q);
      invalid_opcode_slot(3) <=  invalid_opcode(flit_q(343 downto 336),0) and
                                  (template_A_q or template_7_q or flit_q(465 downto 460) = "000001" or template_4_q);
      invalid_opcode_slot(4) <=  template_7_q and invalid_opcode(flit_q(287 downto 280),1);

      unknown_opcode_slot(0) <=  unknown_opcode(flit_q(7 downto 0))    and (flit_q(465 downto 461) = "00000" or template_4_q);  
      unknown_opcode_slot(1) <=  unknown_opcode(flit_q(119 downto 112)) and (flit_q(465 downto 461) = "00000" or template_4_q); 
      unknown_opcode_slot(2) <=  unknown_opcode(flit_q(231 downto 224)) and (flit_q(465 downto 460) = "000001" or template_4_q);
      unknown_opcode_slot(3) <=  unknown_opcode(flit_q(343 downto 336)) and
                                  (template_A_q or template_7_q or flit_q(465 downto 460) = "000001" or template_4_q);
      unknown_opcode_slot(4) <=  template_7_q and unknown_opcode(flit_q(287 downto 280));

      sig_fmt_0 <= flit_q(343 downto 336) & flit_q(287 downto 280) & flit_q(231 downto 224) & flit_q(119 downto 112) & flit_q(7 downto 0)      -- 40
                   & "00" & flit_q(329) & flit_q(328) & flit_q(264) & flit_q(263) & flit_q(465 downto 460) & "000000000";                                                                                                                    -- 21

--                     opcode                    length                   address                      intrp code             intrp tag
      sig_fmt_1 <= GATE(flit_30(7 downto 0) & '0' & flit_30(111 downto 109) & flit_30(35 downto 28) & flit_30(55 downto 52) & flit_30(23 downto 8) & flit_30(107 downto 92) & "00000",not tlxr_tlxt_errors_d(40)) or
                   GATE(flit_30(91 downto 39) & flit_30(7 downto 0),tlxr_tlxt_errors_d(40));
      sig_fmt_2 <= GATE(flit_74(7 downto 0) & '0' & flit_74(111 downto 109) & flit_74(35 downto 28) & flit_74(55 downto 52) & flit_74(23 downto 8) & flit_74(107 downto 92) & "00000", not tlxr_tlxt_errors_d(40)) or
                   GATE(flit_74(91 downto 39) & flit_74(7 downto 0),tlxr_tlxt_errors_d(40));
      sig_fmt_3 <= GATE(flit_B8(7 downto 0) & '0' & flit_B8(111 downto 109) & flit_B8(35 downto 28) & flit_B8(55 downto 52) & flit_B8(23 downto 8) & flit_B8(107 downto 92) & "00000", flit_q(465 downto 460) /= "000111" and not tlxr_tlxt_errors_d(40)) or
                   GATE(flit_B8(91 downto 39) & flit_B8(7 downto 0),flit_q(465 downto 460) /= "000111" and tlxr_tlxt_errors_d(40)) or
         -- slot 10 if template_7 - can only be a 2 slot command intrp_rdy intrp_resp we need only 55-52 and 23-8
                   GATE(flit_B8(63 downto 56) & x"000" & flit_B8(111 downto 108) & '0' & flit_B8(79 downto 64) & x"0000F", flit_q(465 downto 460) = "000111");
      sig_fmt_4 <= GATE(flit_FC(7 downto 0) & '0' & flit_FC(111 downto 109) & flit_FC(35 downto 28) & flit_FC(55 downto 52) & flit_FC(23 downto 8) & flit_B8(107 downto 92) & "00000", not tlxr_tlxt_errors_d(40)) or
                   GATE(flit_FC(91 downto 39) & flit_FC(7 downto 0),tlxr_tlxt_errors_d(40));

                            ---------------
                            -- CHICKEN SWITCHES --
                            ---------------
     --- control 7 downto 0 are the debug selects
     ---         8  disables a4 check on partial read
     ---         9  enable shutdown mode for bar0 parity error
     ---         10 enable shutdown mode for dataflow parity error (maybe Z use this ?)
     ---         11 enable shutdown mode for mmio_bad_wr_resp
     ---         12 enable shutdown mode for errors 38-46 fir 19/20
     ---      14:13 00 shutdown mode always honours credit updates
     ---            01 if we shut down because of error, do not process credit updates
     ---            10 do not shutdown for any errors - only for epow (and process credit updates)
     ---            11 do not shut down for any reason (debug only !)
     ---         15 1333MHz not 1600
                            ---------------
                            -- DEBUG BUS --
                            ---------------                                                                                                     ``
--

    tlxr_dbg_debug_bus <= dbg_bus_q;

    coded_cmd <= recode_opcode( gate(flit_30(7 downto 0),using_cmd_ne(0)) or
                                gate(flit_74(7 downto 0),using_cmd_ne(1)) or
                                gate(flit_B8(7 downto 0),using_cmd_ne(2) and not template_7_q) or
                                gate(flit_B8(63 downto 56),using_cmd_ne(2) and template_7_q) or
                                gate(flit_FC(7 downto 0),using_cmd_ne(3))
                              );

    coded_tplate <= gate("001",flit_q(465 downto 460) = "000000") or
                    gate("010",flit_q(465 downto 460) = "000001") or
                    gate("011",flit_q(465 downto 460) = "000100") or
                    gate("100",flit_q(465 downto 460) = "000111") or
                    gate("101",flit_q(465 downto 460) = "001010") ;

    trace_mmio_addr <= (mmio_addr(0) and using_cmd_ne(0)) or  (mmio_addr(1) and using_cmd_ne(1)) or
                       (mmio_addr(2) and using_cmd_ne(2)) or  (mmio_addr(3) and using_cmd_ne(3));

    dbg_clk_en <= '1' when trc_master_clock_enable = '1' and debug_sel /= "11111111" else '0';

    debug_sel <= tlxt_tlxr_control(7 downto 0);
    dbg_bus_d(0 to 43)  <= GATE(debug_set_0, not OR_REDUCE(debug_sel(3 downto 0)           )) or  -- this is the default set. "1111" turns to clock off
                           GATE(debug_set_1, not OR_REDUCE(debug_sel(3 downto 0) xor "0001")) or
                           GATE(debug_set_2, not OR_REDUCE(debug_sel(3 downto 0) xor "0010")) or
                           GATE(debug_set_3, not OR_REDUCE(debug_sel(3 downto 0) xor "0011")) or
                           GATE(debug_set_4, not OR_REDUCE(debug_sel(3 downto 0) xor "0100")) or
                           GATE(debug_set_5, not OR_REDUCE(debug_sel(3 downto 0) xor "0101")) or
                           GATE(debug_set_6, not OR_REDUCE(debug_sel(3 downto 0) xor "0110")) or
                           GATE(debug_set_6, not OR_REDUCE(debug_sel(3 downto 0) xor "0111"));

    dbg_bus_d(44 to 87) <= GATE(debug_set_0, not OR_REDUCE(debug_sel(7 downto 4)           )) or
                           GATE(debug_set_1, not OR_REDUCE(debug_sel(7 downto 4) xor "0001")) or
                           GATE(debug_set_2, not OR_REDUCE(debug_sel(7 downto 4) xor "0010")) or
                           GATE(debug_set_3, not OR_REDUCE(debug_sel(7 downto 4) xor "0011")) or
                           GATE(debug_set_4, not OR_REDUCE(debug_sel(7 downto 4) xor "0100")) or
                           GATE(debug_set_5, not OR_REDUCE(debug_sel(7 downto 4) xor "0101")) or
                           GATE(debug_set_6, not OR_REDUCE(debug_sel(7 downto 4) xor "0110")) or
                           GATE(debug_set_7, not OR_REDUCE(debug_sel(7 downto 4) xor "0111"));

-- 1  partial_flit_count_0_ne this is a timing strobe so i know where we are
-- 5  new 4 bit command bus  13 commands decoded - at most 4 in 4 clocks
-- 8  new template bus  what template we have (0,1,4,7,A, anything else)
-- 9  mmio_addr does address match mmio or not in this cycle
-- 10  tlxr_flit_vld
-- 11  tlxr_flit_error
-- 15  data_flits_owed_q data run length values 0-8
-- 16  tlxt_tlxr_wr_resp_full stalls write tag release
-- 17  tlxr_tlxt_wr_resp_val_q
-- 18  bufctl_empty write buffer list for outstanding data is empty
-- 24  bufctl_error write buffer list madness of (6) types
-- 28  bc_format info' for writes' alignment and destination (4 bits)
-- 29  no buffers busy
-- 30  no return candidates
-- 32  shutdown_q(2 downto 1) tlxr has shutdown for epow or error (bit 0 not worth it)
-- 33  MMIO_TLXR_WR_BUF_FREE mmio finished with a buffer this cycle
-- 2 more - data delivery ?


-- the master default bits are 0 to 34 the debug_set's are 44 bits each



    debug_set_0 <= partial_flit_count_0_ne       &       -- | 1
                   coded_cmd                     &       -- | +4 5
                   coded_tplate                  &       -- | +3 8
                   trace_mmio_addr               &       -- | +1 9
                   tlxr_flit_vld                 &       -- |    10
                   tlxr_flit_error               &       -- |    11
                   data_flits_owed_q             &       -- | +4 15
                   tlxt_tlxr_wr_resp_full        &       -- |    16
                   buffctl_empty                 &       -- |    17
                   buffctl_error                 &       -- | +6 23
                   bc_format(3 downto 0)         &       -- | +4 27
                   buffers_idle                  &       -- |    28
                   no_return_candidates          &       -- |    29
                   MMIO_TLXR_WR_BUF_FREE         &       -- | +2 31
                   shutdown_q(2 downto 1)        &       -- |    33
                   tlxr_wdf_wrbuf_wr_i           &       -- |    34
                   tlxt_tlxr_low_lat_mode        &       -- |    35
                   tlxr_tlxt_intrp_resp_q        &       --      42
                   srq_tlxr_epow                 &       --      43
                   tlxr_link_up;                         --      44

    debug_set_1 <= partial_flit_count_q(1 downto 0) &
                   tlxr_flit_error                  &
                   tlxr_flit_vld                    &
                   flit_q(7 downto 0)               &
                   flit_q(119 downto 112)           &
                   flit_q(231 downto 224)           &
                   flit_q(287 downto 280)           &
                   flit_q(343 downto 336);

    debug_set_2 <= partial_flit_count_q(1 downto 0)      &    -- 2
                   tlxr_srq_cmd_val_i                    &    -- 3
                   b_nos_4_srq(4 to 15)                  &    -- 15
                   length_format_2(2 downto 0)           &    -- 18
                   length_format_3(2 downto 0)           &    -- 21
                   mask_a5                               &    -- 22
                   write_mem                             &    -- 23
                   pr_rd_dram                            &    -- 24
                   data_xfer                             &    -- 25
                   flit_q(459 downto 448)                &    -- 37
                   flit_q(264)                           &    -- 38
                   t7_bad_q                              &    -- 39
                   flit_q(329)                           &    -- 40
                   tA_bad_q                              &    -- 41
                   "000";                                     -- 44

    debug_set_3 <= oc_addr(39 downto 0)             &    -- 40
                   translating                      &    -- 41
                   xlat_hole                        &    -- 42
                   tlxr_srq_cmd_val_i               &    -- 43
                   idle_flit ;


    debug_set_4 <= TLXT_TLXR_WR_RESP_FULL               &    --  1
                   dcp1_rls_notag                       &    --  2
                   dcp1_rls_earlies                     &    --  3
                   dcp1_rls_lates                       &    --  4
                   or_reduce(tag_rls_earlies)           &    --  5
                   or_reduce(tag_rls_lates)             &    --  6
                   vc1_rls_patt                         &    --  7     -- aka tlxr_tlxt_vc1_release
                   vc0_rls_memctl_q(1 downto 0)         &    --  9
                   vc0_rls_intrp                        &    --  10
                   tlxr_tlxt_return_val_i               &    --  11
                   flit_q(11 downto 8)                  &    --  15    -- TLXR_TLXT_RETURN_VC0
                   flit_q(23 downto 20)                 &    --  19    -- TLXR_TLXT_RETURN_VC3
                   flit_q(37 downto 32)                 &    --  25    -- TLXR_TLXT_RETURN_DCP0
                   flit_q(55 downto 50)                 &    --  31    -- TLXR_TLXT_RETURN_DCP3
                   dec_dat0                             &    --  32
                   cfg_half_dimm_mode_q                 &    --  33
                   tlxr_tlxt_vc0_release_i(1 downto 0)  &    --  35
                   tlxr_tlxt_consume_vc0_i              &    --  36
                   mmio_tlxr_wr_buf_free                &    --  37
                   mmio_tlxr_wr_buf_tag(5 downto 0)     &    --  43
                   partial_flit_count_3  ;

    debug_set_5 <= oc_tag_dl_ecc(23 downto 0)                      &  -- 24
                   tlxr_tlxt_consume_dcp1_q(2 downto 0)            &  -- 27
                   tlxr_tlxt_dcp1_release_i(2 downto 0)            &  -- 30
                   tlxr_tlxt_intrp_resp_q(7 downto 0)              &  -- 38
                   '0'                                             &  -- 39
                   int_rdy_pending_q                               &  -- 43
                   '0';

    debug_set_6 <= partial_flit_count_q(1 downto 0)     &    -- 2
                   first_tag(5 downto 0)                &    -- 8
                   second_tag(5 downto 0)               &    -- 14
                   memcntl_busy_q(3 downto 0)           &    -- 18
                   x"000000" & "00";                         -- 26 bits

    debug_set_7 <= op_held_q(43 downto 0);

    cfg_half_dimm_mode_d <= cfg_half_dimm_mode;

flitq: entity latches.c_morph_dff
  generic map (width => 512, offset => 0)
  port map(gckn                 => gckn,
           syncr                => syncr,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => flit_d(511 downto 0),
           q                    => flit_q(511 downto 0));

buf_stateq: entity latches.c_morph_dff
  generic map (width => 512, offset => 0)
  port map(gckn                 => gckn,
           syncr                => syncr,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => buf_state_d(511 downto 0),
           q                    => buf_state_q(511 downto 0));


raw_dlx_delayq: entity latches.c_morph_dff
  generic map (width => 147, offset => 0)
  port map(gckn                 => gckn,
           syncr                => syncr,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => raw_dlx_delay_d(146 downto 0),



           q                    => raw_dlx_delay_q(146 downto 0));

tlxr_wdf_wrbuf_datq: entity latches.c_morph_dff
  generic map (width => 146, offset => 0)
  port map(gckn                 => gckn,
           syncr                => syncr,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => tlxr_wdf_wrbuf_dat_d(145 downto 0),
           q                    => tlxr_wdf_wrbuf_dat_q(145 downto 0));

dbg_busq: entity latches.c_morph_dff                        -- data
  generic map (width => 88, offset => 0)
  port map(gckn                 => gckn,
           syncr                => syncr,
           e                    => dbg_clk_en,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => dbg_bus_d(0 to 87),
           q                    => dbg_bus_q(0 to 87));

tlxr_wdf_beq: entity latches.c_morph_dff
  generic map (width => 72, offset => 0)
  port map(gckn                 => gckn,
           syncr                => syncr,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => tlxr_wdf_be_d(0 to 71),
           q                    => tlxr_wdf_be_q(0 to 71));


turn_takenq: entity latches.c_morph_dff
  generic map (width => 68, offset => 0)
  port map(gckn                 => gckn,
           syncr                => syncr,
          e                    => act,
          vdd                  => vdd,
          vss                  => gnd,
          d                    => turn_taken_d(67 downto 0),
          q                    => turn_taken_q(67 downto 0));


tag_return_candidatesq: entity latches.c_morph_dff
  generic map (width => 68, offset => 0)
  port map(gckn                 => gckn,
           syncr                => syncr,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => tag_return_candidates_d(67 downto 0),
           q                    => tag_return_candidates_q(67 downto 0));

early_wr_done_bfq: entity latches.c_morph_dff
  generic map (width => 64, offset => 0)
  port map(gckn                 => gckn,
           syncr                => syncr,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => early_wr_done_bf_d(63 downto 0),
           q                    => early_wr_done_bf_q(63 downto 0));

srq_cmdq: entity latches.c_morph_dff
  generic map (width => 63, offset => 0)
  port map(gckn                 => gckn,
           syncr                => syncr,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => srq_cmd_d(0 to 62),
           q                    => srq_cmd_q(0 to 62));

tlxr_tlxt_signature_datq: entity latches.c_morph_dff
  generic map (width => 64, offset => 0)
  port map(gckn                 => gckn,
           syncr                => syncr,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => tlxr_tlxt_signature_dat_d(63 downto 0),
           q                    => tlxr_tlxt_signature_dat_q(63 downto 0));


flit_pq: entity latches.c_morph_dff
  generic map (width => 64, offset => 0)
  port map(gckn                 => gckn,
           syncr                => syncr,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => flit_p_d(63 downto 0),
           q                    => flit_p_q(63 downto 0));

dbuf_listq: entity latches.c_morph_dff
  generic map (width => 64, offset => 0)
  port map(gckn                 => gckn,
           syncr                => syncr,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => dbuf_list_d(63 downto 0),
           q                    => dbuf_list_q(63 downto 0));

tlxr_tlxt_errorsq: entity latches.c_morph_dff
  generic map (width => 59, offset => 0)
  port map(gckn                 => gckn,
           syncr                => syncr,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => tlxr_tlxt_errors_d(58 downto 0),
           q                    => tlxr_tlxt_errors_q(58 downto 0));

meta_storeq: entity latches.c_morph_dff
  generic map (width => 56, offset => 0)
  port map(gckn                 => gckn,
           syncr                => syncr,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => meta_store_d(55 downto 0),
           q                    => meta_store_q(55 downto 0));

flit_heldq: entity latches.c_morph_dff
  generic map (width => 48, offset => 80)
  port map(gckn                 => gckn,
           syncr                => syncr,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => flit_held_d(127 downto 80),
           q                    => flit_held_q(127 downto 80));

op_heldq: entity latches.c_morph_dff
  generic map (width => 44, offset => 0)
  port map(gckn                 => gckn,
           syncr                => syncr,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => op_held_d(43 downto 0),
           q                    => op_held_q(43 downto 0));

lbt_1q: entity latches.c_morph_dff
  generic map (width => 31, offset => 0)
  port map(gckn                 => gckn,
           syncr                => syncr,
           e                    => lbt_enab(1),
           vdd                  => vdd,
           vss                  => gnd,
           d                    => lbt_1_d(30 downto 0),
           q                    => lbt_1_q(30 downto 0));

lbt_2q: entity latches.c_morph_dff
  generic map (width => 31, offset => 0)
  port map(gckn                 => gckn,
           syncr                => syncr,
           e                    => lbt_enab(2),
           vdd                  => vdd,
           vss                  => gnd,
           d                    => lbt_2_d(30 downto 0),
           q                    => lbt_2_q(30 downto 0));

lbt_3q: entity latches.c_morph_dff
  generic map (width => 31, offset => 0)
  port map(gckn                 => gckn,
           syncr                => syncr,
           e                    => lbt_enab(3),
           vdd                  => vdd,
           vss                  => gnd,
           d                    => lbt_3_d(30 downto 0),
           q                    => lbt_3_q(30 downto 0));

lbt_4q: entity latches.c_morph_dff
  generic map (width => 31, offset => 0)
  port map(gckn                 => gckn,
           syncr                => syncr,
           e                    => lbt_enab(4),
           vdd                  => vdd,
           vss                  => gnd,
           d                    => lbt_4_d(30 downto 0),
           q                    => lbt_4_q(30 downto 0));

resp_tmgq: entity latches.c_morph_dff    -- just for timing
  generic map (width => 24, offset => 0 )
  port map(gckn                 => gckn,
           syncr                => syncr,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => resp_tmg_d(23 downto 0),
           q                    => resp_tmg_q(23 downto 0));


tlxr_tlxt_write_respq: entity latches.c_morph_dff
  generic map (width => 22, offset => 0)
  port map(gckn                 => gckn,
           syncr                => syncr,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => tlxr_tlxt_write_resp_d(21 downto 0),
           q                    => tlxr_tlxt_write_resp_q(21 downto 0));

ire_rtagq: entity latches.c_morph_dff
  generic map (width => 22, offset => 0)
  port map(gckn                 => gckn,
           syncr                => syncr,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => ire_rtag_d(21 downto 0),
           q                    => ire_rtag_q(21 downto 0));

flit_8bpq: entity latches.c_morph_dff
  generic map (width => 8, offset => 0)
  port map(gckn                 => gckn,
           syncr                => syncr,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => flit_8bp_d(7 downto 0),
           q                    => flit_8bp_q(7 downto 0));

ucq: entity latches.c_morph_dff
  generic map (width => 9, offset => 0)
  port map(gckn                 => gckn,
           syncr                => syncr,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => uc_d(8 downto 0),
           q                    => uc_q(8 downto 0));

lbt_prescaleq: entity latches.c_morph_dff
  generic map (width => 8, offset => 0)
  port map(gckn                 => gckn,
           syncr                => syncr,
           e                    => lbt_prescale_enab,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => lbt_prescale_d(7 downto 0),
           q                    => lbt_prescale_q(7 downto 0));

resp_err_codeq: entity latches.c_morph_dff    -- just for timing
  generic map (width => 8, offset => 0 )
  port map(gckn                 => gckn,
           syncr                => syncr,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => resp_err_code_d(7 downto 0),
           q                    => resp_err_code_q(7 downto 0));

tlxr_tlxt_intrp_respq: entity latches.c_morph_dff
  generic map (width => 8, offset => 0)
  port map(gckn                 => gckn,
           syncr                => syncr,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => tlxr_tlxt_intrp_resp_d(7 downto 0),
           q                    => tlxr_tlxt_intrp_resp_q(7 downto 0));

tag_store_raddrq: entity latches.c_morph_dff
  generic map (width => 7, offset => 0)
  port map(gckn                 => gckn,
           syncr                => syncr,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => tag_store_raddr_d(6 downto 0),
           q                    => tag_store_raddr_q(6 downto 0));

twwpq: entity latches.c_morph_dff
  generic map (width => 6, offset => 0)
  port map(gckn                 => gckn,
           syncr                => syncr,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => twwp_d(0 to 5),
           q                    => twwp_q(0 to 5));

ftq: entity latches.c_morph_dff    -- just for timing
  generic map (width => 6, offset => 0, init => "000000")
  port map(gckn                 => gckn,
           syncr                => syncr,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => ft_d(5 downto 0),
           q                    => ft_q(5 downto 0));

stq: entity latches.c_morph_dff    -- just for timing
    generic map (width => 6, offset => 0, init => "100000" )
  port map(gckn                 => gckn,
           syncr                => syncr,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => st_d(5 downto 0),
           q                    => st_q(5 downto 0));

first_tagq: entity latches.c_morph_dff
  generic map (width => 6, offset => 0)
  port map(gckn                 => gckn,
           syncr                => syncr,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => first_tag_d(5 downto 0),
           q                    => first_tag_q(5 downto 0));

metadataq: entity latches.c_morph_dff
  generic map (width => 6, offset => 0)
  port map(gckn                 => gckn,
           syncr                => syncr,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => metadata_d(5 downto 0),
           q                    => metadata_q(5 downto 0));

decode_data_cycleq: entity latches.c_morph_dff
  generic map (width => 5, offset => 0)
  port map(gckn                 => gckn,
           syncr                => syncr,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => decode_data_cycle_d(4 downto 0),
           q                    => decode_data_cycle_q(4 downto 0));


decode_ctl_cycleq: entity latches.c_morph_dff
  generic map (width => 5, offset => 0)
  port map(gckn                 => gckn,
           syncr                => syncr,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => decode_ctl_cycle_d(4 downto 0),
           q                    => decode_ctl_cycle_q(4 downto 0));

data_flits_owedq: entity latches.c_morph_dff
  generic map (width => 4, offset => 0)
  port map(gckn                 => gckn,
           syncr                => syncr,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => data_flits_owed_d(3 downto 0),
           q                    => data_flits_owed_q(3 downto 0));

dbuf_wp_heldq: entity latches.c_morph_dff
  generic map (width => 4, offset => 0)
  port map(gckn                 => gckn,
           syncr                => syncr,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => dbuf_wp_held_d(3 downto 0),
           q                    => dbuf_wp_held_q(3 downto 0));

int_rdy_pendingq: entity latches.c_morph_dff
  generic map (width => 4, offset => 0)
  port map(gckn                 => gckn,
           syncr                => syncr,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => int_rdy_pending_d(4 downto 1),
           q                    => int_rdy_pending_q(4 downto 1));

memcntl_failq: entity latches.c_morph_dff
  generic map (width => 4, offset => 0)
  port map(gckn                 => gckn,
           syncr                => syncr,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => memcntl_fail_d(3 downto 0),
           q                    => memcntl_fail_q(3 downto 0));

dbuf_wpq: entity latches.c_morph_dff
  generic map (width => 4, offset => 0)
  port map(gckn                 => gckn,
           syncr                => syncr,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => dbuf_wp_d(3 downto 0),
           q                    => dbuf_wp_q(3 downto 0));

last_good_dfoq: entity latches.c_morph_dff
  generic map (width => 4, offset => 0)
  port map(gckn                 => gckn,
           syncr                => syncr,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => last_good_dfo_d(3 downto 0),
           q                    => last_good_dfo_q(3 downto 0));

memcntl_busyq: entity latches.c_morph_dff
  generic map (width => 4, offset => 0)
  port map(gckn                 => gckn,
           syncr                => syncr,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => memcntl_busy_d(3 downto 0),
           q                    => memcntl_busy_q(3 downto 0));

data_flit_numq: entity latches.c_morph_dff
  generic map (width => 3, offset => 0)
  port map(gckn                 => gckn,
           syncr                => syncr,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => data_flit_num_d(2 downto 0),
           q                    => data_flit_num_q(2 downto 0));

tlxr_tlxt_consume_dcp1q: entity latches.c_morph_dff
  generic map (width => 3, offset => 0)
  port map(gckn                 => gckn,
           syncr                => syncr,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => tlxr_tlxt_consume_dcp1_d(2 downto 0),
           q                    => tlxr_tlxt_consume_dcp1_q(2 downto 0));


tlxr_tlxt_write_resp_pq: entity latches.c_morph_dff
  generic map (width => 3, offset => 0)
  port map(gckn                 => gckn,
           syncr                => syncr,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => tlxr_tlxt_write_resp_p_d(2 downto 0),
           q                    => tlxr_tlxt_write_resp_p_q(2 downto 0));

resp_valq: entity latches.c_morph_dff    -- just for timing
  generic map (width => 3, offset => 0 )
  port map(gckn                 => gckn,
           syncr                => syncr,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => resp_val_d(2 downto 0),
           q                    => resp_val_q(2 downto 0));


shutdownq: entity latches.c_morph_dff
  generic map (width => 3, offset => 0, init => "000")
  port map(gckn                 => gckn,
           syncr                => syncr,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => shutdown_d(2 downto 0),
           q                    => shutdown_q(2 downto 0));

partial_flit_countq: entity latches.c_morph_dff
  generic map (width => 2, offset => 0, init => "00")
  port map(gckn                 => gckn,
           syncr                => syncr,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => partial_flit_count_d(1 downto 0),
           q                    => partial_flit_count_q(1 downto 0));

fast_act_partial_countq: entity latches.c_morph_dff
  generic map (width => 2, offset => 0, init => "00")
  port map(gckn                 => gckn,
           syncr                => syncr,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => fast_act_partial_count_d(1 downto 0),
           q                    => fast_act_partial_count_q(1 downto 0));

ecc_par_inq: entity latches.c_morph_dff
  generic map (width => 2, offset => 0)
  port map(gckn                 => gckn,
           syncr                => syncr,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => ecc_par_in_d(1 downto 0),
           q                    => ecc_par_in_q(1 downto 0));

bpvq: entity latches.c_morph_dff    -- just for timing
  generic map (width => 2, offset => 0, init => "11")
  port map(gckn                 => gckn,
           syncr                => syncr,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => bpv_d(2 downto 1),
           q                    => bpv_q(2 downto 1));


vc0_rls_memctlq: entity latches.c_morph_dff
  generic map (width => 2, offset => 0)
  port map(gckn                 => gckn,
           syncr                => syncr,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => vc0_rls_memctl_d(1 downto 0),
           q                    => vc0_rls_memctl_q(1 downto 0));

tlxr_srq_cmd_valq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           syncr                => syncr,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(tlxr_srq_cmd_val_d),
           Tconv(q)             => tlxr_srq_cmd_val_q);

tlxr_wdf_be_wrq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           syncr                => syncr,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(tlxr_wdf_be_wr_d),
           Tconv(q)             => tlxr_wdf_be_wr_q);

dataflow_perrq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           syncr                => syncr,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(dataflow_perr_d),
           Tconv(q)             => dataflow_perr_q);

tlxr_wdf_wrbuf_bad63q: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           syncr                => syncr,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(tlxr_wdf_wrbuf_bad63_d),
           Tconv(q)             => tlxr_wdf_wrbuf_bad63_q);

dflow_pe_heldq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           syncr                => syncr,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(dflow_pe_held_d),
           Tconv(q)             => dflow_pe_held_q);

hundred_ns1q: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           syncr                => syncr,
           e                    => lbt_prescale_enab,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(hundred_ns1_d),
           Tconv(q)             => hundred_ns1_q);

hundred_ns2q: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           syncr                => syncr,
           e                    => lbt_prescale_enab,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(hundred_ns2_d),
           Tconv(q)             => hundred_ns2_q);

hundred_ns3q: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           syncr                => syncr,
           e                    => lbt_prescale_enab,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(hundred_ns3_d),
           Tconv(q)             => hundred_ns3_q);

hundred_ns4q: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           syncr                => syncr,
           e                    => lbt_prescale_enab,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(hundred_ns4_d),
           Tconv(q)             => hundred_ns4_q);

tlxr_wdf_be_pq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           syncr                => syncr,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(tlxr_wdf_be_wr_p_d),
           Tconv(q)             => tlxr_wdf_be_wr_p_q);

tlxr_tlxt_signature_strobeq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           syncr                => syncr,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(tlxr_tlxt_signature_strobe_d),
           Tconv(q)             => tlxr_tlxt_signature_strobe_q);

resp_cntq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           syncr                => syncr,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(resp_cnt_d),
           Tconv(q)             => resp_cnt_q);

template_7q: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           syncr                => syncr,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(template_7_d),
           Tconv(q)             => template_7_q);

template_Aq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           syncr                => syncr,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(template_A_d),
           Tconv(q)             => template_A_q);

template_4q: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           syncr                => syncr,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(template_4_d),
           Tconv(q)             => template_4_q);

template_0q: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           syncr                => syncr,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(template_0_d),
           Tconv(q)             => template_0_q);

decoding_dataq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           syncr                => syncr,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(decoding_data_d),
           Tconv(q)             => decoding_data_q);

t7_badq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           syncr                => syncr,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(t7_bad_d),
           Tconv(q)             => t7_bad_q);

tA_badq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           syncr                => syncr,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(tA_bad_d),
           Tconv(q)             => tA_bad_q);

cfg_half_dimm_modeq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(cfg_half_dimm_mode_d),
           Tconv(q)             => cfg_half_dimm_mode_q);

ire_pendingq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(ire_pending_d),
           Tconv(q)             => ire_pending_q);

resp_cnt2q: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(resp_cnt2_d),
           Tconv(q)             => resp_cnt2_q);

fa_slot0_enabq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0, init => "1")
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(fa_slot0_enab_d),
           Tconv(q)             => fa_slot0_enab_q);
End cb_tlxr_mac;
