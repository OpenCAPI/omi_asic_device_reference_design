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

library ieee, ibm, latches, stdcell, support;
use ibm.std_ulogic_asic_function_support.all;
use ibm.std_ulogic_support.all;
use ibm.std_ulogic_unsigned.all;
use ibm.std_ulogic_function_support.all;
use ibm.synthesis_support.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ibm.std_ulogic_ao_support.all;
use support.logic_support_pkg.all;
use support.power_logic_pkg.all;
use support.design_util_functions_pkg.all;
use support.signal_resolution_pkg.all;
use ibm.texsim_attributes.all;
library work;
use work.cb_func.all;

entity cb_tlxt_mac is

  port (
    gckn                           : in std_ulogic;
    syncr                          : in std_ulogic;

    cfg_half_dimm_mode            : IN std_ulogic;

    tcm_tlxt_scom_cch              : in STD_ULOGIC;   --[IN]  SCOM address port to tlxt
    tlxt_tcm_scom_cch              : out STD_ULOGIC;   --[OUT] SCOM address port from tlxt

    tcm_tlxt_scom_dch              : in STD_ULOGIC;   --[IN]  SCOM data port to tlxt
    tlxt_tcm_scom_dch              : out STD_ULOGIC;  -- [OUT] SCOM data port from tlxt

    tlx_xstop_err                  : out std_ulogic;                          -- checkstop   output to Global FIR
    tlx_recov_err                  : out std_ulogic;                          -- recoverable output to Global FIR
    tlx_recov_int                  : out std_ulogic;                          -- recoverable interrupt output to Global FIR
    tlx_mchk_out                   : OUT std_ulogic;                          -- used only if implement_mchk=true
    tlx_trace_error                : OUT std_ulogic;                  -- [OUT] error to connect to error_input of closest trdata macro

    tlxt_dbg_debug_bus             : out std_ulogic_vector(0 to 87);

    tlxt_dlx_flit_vld              : out std_ulogic;
    tlxt_dlx_flit_early_vld_a      : out std_ulogic;
    tlxt_dlx_flit_early_vld_b      : out std_ulogic;
    tlxt_dlx_flit_data             : out std_ulogic_vector(127 downto 0);
    tlxt_dlx_flit_ecc              : out std_ulogic_vector(15 downto 0);
    tlxt_dlx_flit_lbip_vld         : out std_ulogic;
    tlxt_dlx_flit_lbip_data        : out std_ulogic_vector(81 downto 0);
    tlxt_dlx_tl_error              : out std_ulogic;
    tlxt_dlx_tl_event              : out std_ulogic;
    dlx_tlxt_flit_credit           : in std_ulogic;
    dlx_tlxr_link_up               : in std_ulogic;
    dlx_tlxt_lane_width_status     : in std_ulogic_vector(1 downto 0);  --00 training or retraining,
                                                                        --10 quarter width,
                                                                        --01 half width,
                                                                        --11 full width. (x4 in hd)

    srq_tlxt_padmem_done_val       : in std_ulogic;
    srq_tlxt_padmem_done_tag       : in std_ulogic_vector(0 TO 15);
    srq_tlxt_padmem_done_tag_p     : in std_ulogic_vector(0 TO 1);
    tlxt_srq_padmem_done_ack       : out std_ulogic;
    srq_tlxt_failresp_val          : in std_ulogic;
    srq_tlxt_failresp_type         : in std_ulogic;
    srq_tlxt_failresp_dlen         : in std_ulogic_vector(0 TO 1);
    srq_tlxt_failresp_code         : in std_ulogic_vector(0 to 3);

    srq_tlxt_cmdq_release          : in std_ulogic;
    tlxt_srq_rdbuf_pop             : out std_ulogic;
    rdf_tlxt_resp_valid            : in std_ulogic;
    rdf_tlxt_resp_dpart            : in std_ulogic_vector(0 to 1);
    rdf_tlxt_resp_otag             : in std_ulogic_vector(0 to 15);
    rdf_tlxt_resp_len32            : in std_ulogic;
    rdf_tlxt_resp_exit0            : in std_ulogic;
    rdf_tlxt_resp_p                : in std_ulogic;
    rdf_tlxt_data_valid            : in std_ulogic;
    tlxt_rdf_data_taken            : out std_ulogic;
    rdf_tlxt_data                  : in std_ulogic_vector(0 to 127);
    rdf_tlxt_data_ecc              : in std_ulogic_vector(0 to 15);
    rdf_tlxt_data_err              : in std_ulogic;
    rdf_tlxt_meta_valid            : in std_ulogic_vector(0 to 1);
    rdf_tlxt_meta                  : in std_ulogic_vector(0 to 5);
    rdf_tlxt_meta_p                : in std_ulogic;
    rdf_tlxt_bad_data_valid        : in std_ulogic;
    rdf_tlxt_bad_data_1st32B       : in std_ulogic;
    rdf_tlxt_bad_data              : in std_ulogic;
    rdf_tlxt_bad_data_p            : in std_ulogic;


     --Interface with TLXR

    tlxr_tlxt_write_resp           : in std_ulogic_vector(21 downto 0);   --21:6 = tag, 5:2 = response code 1:0 = DL
    tlxr_tlxt_write_resp_p         : in std_ulogic_vector(2 downto 0);   --even byte parity on (val & resp) (right justified)
    tlxr_tlxt_write_resp_val       : in std_ulogic;   --write done valid on this cycles
    tlxt_tlxr_wr_resp_full         : out std_ulogic;
    tlxt_tlxr_low_lat_mode         : out std_ulogic;
    tlxr_tlxt_intrp_resp           : in std_ulogic_vector(7 downto 0);

      --From return TLX Credit TL command
    tlxr_tlxt_return_val           : in std_ulogic;
    tlxr_tlxt_return_vc0           : in std_ulogic_vector(3 downto 0);
    tlxr_tlxt_return_vc3           : in std_ulogic_vector(3 downto 0);
    tlxr_tlxt_return_dcp0          : in std_ulogic_vector(5 downto 0);
    tlxr_tlxt_return_dcp3          : in std_ulogic_vector(5 downto 0);

    tlxr_tlxt_consume_vc0          : in std_ulogic;                     -- error checking
    tlxr_tlxt_consume_vc1          : in std_ulogic;                      --error checking
    tlxr_tlxt_consume_dcp1         : in std_ulogic_vector(2 downto 0);   --error checking

    tlxr_tlxt_dcp1_release         : in std_ulogic_vector(2 downto 0);   --                  dcp1 release pulse
    tlxr_tlxt_vc0_release          : in std_ulogic_vector(1 DOWNTO 0);  --vc0 release pulse memctrl and int_resp
    tlxr_tlxt_vc1_release          : in std_ulogic;                     --vc1 release pulse set pad mem
    tlxt_tlxr_early_wdone_disable  : out std_ulogic_vector(1 DOWNTO 0);
    tlxt_tlxr_ctrl                 : out STD_ULOGIC_VECTOR(15 downto 0);
    tlxr_tlxt_errors               : in std_ulogic_vector(63 downto 0);  --
    tlxr_tlxt_signature_dat        : IN std_ulogic_vector(63 downtO 0);
    tlxr_tlxt_signature_strobe     : IN std_ulogic;

    --Global FIR inputs for interrupt triggering
    global_fir_chan_xstop               : in std_ulogic;
    global_fir_rec_attn                 : in std_ulogic;
    global_fir_sp_attn                  : in std_ulogic;
    global_fir_mchk                     : in std_ulogic;


    -- Interface with MMIO/CFG

    mmio_tlxt_resp_valid           : in std_ulogic;
    mmio_tlxt_resp_opcode          : in std_ulogic_vector(7 downto 0);
    mmio_tlxt_resp_dl              : in std_ulogic_vector(1 downto 0);
    mmio_tlxt_resp_capptag         : in std_ulogic_vector(15 downto 0);
    mmio_tlxt_resp_dp              : in std_ulogic_vector(1 downto 0);
    mmio_tlxt_resp_code            : in std_ulogic_vector(3 downto 0);
    mmio_tlxt_resp_par             : in std_ulogic;
    tlxt_mmio_resp_ack             : out std_ulogic;
    mmio_tlxt_rdata_offset         : in std_ulogic;
    mmio_tlxt_rdata_bus            : in std_ulogic_vector(287 downto 0);
    mmio_tlxt_rdata_bdi            : in std_ulogic;
    mmio_tlxt_busnum               : in std_ulogic_vector(8 downto 0);

    --config inputs
    cfg_otl0_tl_minor_vers_config  : in std_ulogic;
    cfg_otl0_tl_minor_vers_config_p : in std_ulogic;
    cfg_otl0_tl_xmt_tmpl_config    : in std_ulogic_vector(12 downto 0);   --12=p
    cfg_otl0_tl_xmt_rate_tmpl_config : in std_ulogic_vector(48 downto 0);  -- 48=p
    cfg_f1_octrl00_enable_afu      : in std_ulogic;
    cfg_f1_octrl00_metadata_enabled : in std_ulogic;
    cfg_f1_octrl00_p               : in std_ulogic;
    cfg_f1_ofunc_func_actag_base   : in std_ulogic_vector(12 downto 0);   --12=p
    cfg_f1_ofunc_func_actag_len_enab : in std_ulogic_vector(12 downto 0);  -- 12=p
    cfg_f1_octrl00_afu_actag_base   : in std_ulogic_vector(12 downto 0);   --12=p
    cfg_f1_octrl00_afu_actag_len_enab : in std_ulogic_vector(12 downto 0);  -- 12=p
    cfg_f1_octrl00_pasid_length_enabled : in std_ulogic_vector(5 downto 0); ---   5=p
    cfg_f1_octrl00_pasid_base      : in std_ulogic_vector(20 downto 0);  -- 20=p

    --wat events
    dbg_tlxt_wat_event             : IN std_ulogic_vector(0 TO 3);


    gnd                            : inout power_logic;
    vdd                            : inout power_logic);


  attribute BLOCK_TYPE of cb_tlxt_mac                : entity is LEAF;
  attribute BTR_NAME of cb_tlxt_mac                  : entity is "CB_TLXT_MAC";
  attribute PIN_DEFAULT_GROUND_DOMAIN of cb_tlxt_mac : entity is "GND";
  attribute PIN_DEFAULT_POWER_DOMAIN of cb_tlxt_mac  : entity is "VDD";
  attribute RECURSIVE_SYNTHESIS of cb_tlxt_mac       : entity is 2;
  attribute PIN_DATA of gckn                         : signal is "PIN_FUNCTION=/G_CLK/";
  attribute GROUND_PIN of gnd                        : signal is 1;
  attribute POWER_PIN of vdd                         : signal is 1;
end cb_tlxt_mac;

architecture cb_tlxt_mac of cb_tlxt_mac is
  SIGNAL act : std_ulogic;
  SIGNAL data_valid : std_ulogic;
  SIGNAL rd_resp_val : std_ulogic;
  SIGNAL rdf_tlxt_meta_le : std_ulogic_vector(5 downto 0);
  SIGNAL rdf_tlxt_meta_valid_le : std_ulogic_vector(1 downto 0);
  SIGNAL rdf_tlxt_resp_dpart_le : std_ulogic_vector(1 downto 0);
  SIGNAL rdf_tlxt_resp_Otag_le : std_ulogic_vector(15 downto 0);
  SIGNAL rd_resp : std_ulogic_vector(17 downto 0);
  SIGNAL rdf_tlxt_data_le : std_ulogic_vector(127 downto 0);
  SIGNAL rdf_tlxt_data_ecc_le : std_ulogic_vector(15 downto 0);
  SIGNAL wr_resp_val : std_ulogic;
  SIGNAL wr_resp : std_ulogic_vector(20 downto 0);
  SIGNAL wr_resp_int : std_ulogic_vector(20 downto 0);
  SIGNAL dl_cont_data_run_len : std_ulogic_vector(3 downto 0);
  SIGNAL dl_cont_tl_tmpl : std_ulogic_vector(5 downto 0);
  SIGNAL dl_cont_tl_tmpl_p : std_ulogic;
  SIGNAL dl_cont_bdi_vec : std_ulogic_vector(7 downto 0);
  SIGNAL dl_cont_bdi_vec_p : std_ulogic_vector(1 downto 0);
  SIGNAL flit_part : std_ulogic_vector(127 downto 0);
  SIGNAL flit_part_p : std_ulogic_vector(15 downto 0);
  SIGNAL flit_part_last : std_ulogic_vector(63 downto 0);
  SIGNAL flit_part_last_p : std_ulogic_vector(7 downto 0);
  SIGNAL flit_part_last_vld : std_ulogic;
  SIGNAL flit_part_vld : std_ulogic;
  SIGNAL flit_xmit_start : std_ulogic;
  SIGNAL mmio_data_val : std_ulogic;
  SIGNAL data_xmit : std_ulogic;
  SIGNAL tlxc_tlxt_avail_dcp0 : std_ulogic_vector(3 downto 0);
  SIGNAL tlxc_tlxt_avail_dcp3 : std_ulogic_vector(3 downto 0);
  SIGNAL tlxc_tlxt_avail_vc0 : std_ulogic_vector(3 downto 0);
  SIGNAL tlxc_tlxt_avail_vc3 : std_ulogic_vector(3 downto 0);
  SIGNAL tlxc_tlxt_crd_ret_val : std_ulogic;
  SIGNAL tlxc_tlxt_dcp1_credits : std_ulogic_vector(5 downto 0);
  SIGNAL tlxc_tlxt_vc0_credits : std_ulogic_vector(3 downto 0);
  SIGNAL tlxc_tlxt_vc1_credits : std_ulogic_vector(3 downto 0);
  SIGNAL tlxc_tlxt_dcp1_credits_p : std_ulogic;
  SIGNAL tlxc_tlxt_vc0_credits_p : std_ulogic;
  SIGNAL tlxc_tlxt_vc1_credits_p : std_ulogic;

  SIGNAL tlxt_tlxc_consume_dcp0 : std_ulogic_vector(3 downto 0);
  SIGNAL tlxt_tlxc_consume_dcp3 : std_ulogic_vector(3 downto 0);
  SIGNAL tlxt_tlxc_consume_val : std_ulogic;
  SIGNAL tlxt_tlxc_consume_vc0 : std_ulogic_vector(3 downto 0);
  SIGNAL tlxt_tlxc_consume_vc3 : std_ulogic_vector(3 downto 0);
  SIGNAL tlxt_tlxc_crd_ret_taken : std_ulogic;
  SIGNAL tlxt_srq_rdbuf_pop_int : std_ulogic;
  SIGNAL data_pending : std_ulogic;
  SIGNAL flit_xmit_done : std_ulogic;
  SIGNAL flit_xmit_early_done : std_ulogic;
  SIGNAL flit_credit_avail : std_ulogic;
  SIGNAL tmpl9_data_val : std_ulogic;
  SIGNAL data_flit_xmit : std_ulogic;
  SIGNAL scom_tlx_sat_id : std_ulogic_vector(0 to 1);  -- [in]  Satellite id
  SIGNAL tlx_fir_out : std_ulogic_vector(0 to 27);  -- [OUT] output of current FIR state if needed

  SIGNAL tlxc_crd_cfg_reg : STD_ULOGIC_VECTOR(0 to 63);  -- [OUT]
  SIGNAL tlxc_wat_en_reg : STD_ULOGIC_VECTOR(0 to 23);  -- [OUT]
  SIGNAL tlxc_crd_status_reg : STD_ULOGIC_VECTOR(0 to 127);  -- [IN]

  SIGNAL tlxc_perrors : STD_ULOGIC_VECTOR(0 to 7);  -- [IN]
  SIGNAL tlxc_errors : STD_ULOGIC_VECTOR(0 to 15);  -- [IN]
  SIGNAL tlxt_perrors : STD_ULOGIC_VECTOR(0 to 32);  -- [IN]
  SIGNAL tlxt_errors : STD_ULOGIC_VECTOR(0 to 32);  -- [IN]
  SIGNAL trans_arb_perrors : std_ulogic_vector(0 to 4);
  SIGNAL flit_arb_perrors : std_ulogic_vector(0 to 8);

  SIGNAL wr_fail_resp : std_ulogic_vector(31 downto 0);
  SIGNAL mmio_resp_val : std_ulogic;
  SIGNAL mmio_resp_fail : std_ulogic;
  signal mmio_resp_ack : std_ulogic;
  SIGNAL mmio_fail_resp : std_ulogic_vector(31 downto 0);
  SIGNAL mmio_fail_ack : std_ulogic;
  SIGNAL fail_resp_val : std_ulogic;
  SIGNAL fail_resp_input : std_ulogic_vector(31 downto 0);
  SIGNAL wr_resp_fail : std_ulogic;
  SIGNAL mmio_tlxt_resp : std_ulogic_vector(17 downto 0);
  SIGNAL pad_mem_resp : std_ulogic_vector(20 downto 0);
  SIGNAL rd_fail_resp : std_ulogic_vector(31 downto 0);
   SIGNAL padmem_fail_resp : std_ulogic_vector(31 downto 0);
  SIGNAL wr_resp_fifo_full : std_ulogic;
  SIGNAL mem_cntl_val : std_ulogic;
  SIGNAL mem_cntl_resp : std_ulogic_vector(20 downto 0);

  SIGNAL flit_arb_debug_bus : std_ulogic_vector(0 to 87);
  SIGNAL flit_arb_debug_fedc : std_ulogic_vector(0 to 27);
  SIGNAL tlxt_debug_bus : std_ulogic_vector(0 to 87);  -- [out]

  SIGNAL tlxc_dbg_a_debug_bus : std_ulogic_vector(0 to 43);
  SIGNAL tlxc_dbg_b_debug_bus : std_ulogic_vector(0 to 87);
  SIGNAL tlxt_dbg_a_debug_bus : std_ulogic_vector(0 to 87);
  SIGNAL tlxt_dbg_b_debug_bus : std_ulogic_vector(0 to 87);
  SIGNAL tlxt_dbg_c_debug_bus : std_ulogic_vector(0 to 87);
  SIGNAL tlxt_dbg_d_debug_bus : std_ulogic_vector(0 to 87);
  SIGNAL tlxt_dbg_fedc : std_ulogic_vector(0 to 43);

  SIGNAL tlxt_dbg_mode : std_ulogic_vector(0 to 15);  -- [in]

  signal tlxt_intrp_cmdflag_0 : STD_ULOGIC_VECTOR(0 to 3);
  signal tlxt_intrp_cmdflag_1 : STD_ULOGIC_VECTOR(0 to 3);
  signal tlxt_intrp_cmdflag_2 : STD_ULOGIC_VECTOR(0 to 3);
  signal tlxt_intrp_cmdflag_3 : STD_ULOGIC_VECTOR(0 to 3);
  signal tlxt_intrp_handle_0  : STD_ULOGIC_VECTOR(0 to 63);
  signal tlxt_intrp_handle_1  : STD_ULOGIC_VECTOR(0 to 63);
  signal tlxt_intrp_handle_2  : STD_ULOGIC_VECTOR(0 to 63);
  signal tlxt_intrp_handle_3  : STD_ULOGIC_VECTOR(0 to 63);

  SIGNAL fail_resp_full : std_ulogic;
  SIGNAL fail_resp_ack : std_ulogic;

  signal tlxc_tlxt_ctrl : STD_ULOGIC_VECTOR(0 to 15);
  attribute ANALYSIS_NOT_REFERENCED of tlxc_tlxt_ctrl : signal is "<11:15>TRUE";
  SIGNAL hi_bw_threshold : STD_ULOGIC_VECTOR(2 downto 0);
  signal mid_bw_threshold : std_ulogic_vector(2 downto 0);
  signal hi_bw_dis : std_ulogic;
  signal mid_bw_enab : std_ulogic;
  signal hi_bw_enab_rd_thresh : std_ulogic;
  signal low_lat_rd_dis : std_ulogic;
  SIGNAL mmio_data_par_err : std_ulogic;
  signal mmio_data_par : std_ulogic_vector(31 downto 0);
  signal mmio_resp_code : std_ulogic_vector(3 downto 0);
  signal low_lat_mode : std_ulogic;
  signal tlxt_err_invalid_crd_ret : std_ulogic;
  signal tlxt_err_dropped_crd_ret : std_ulogic;
  signal tlxt_err_invalid_cfg     : std_ulogic;
  signal tlxt_err_invalid_meta_cfg : std_ulogic;
  signal tlxt_err_bdi_poisoned : std_ulogic;
  signal tlxt_err_fifo_CE : std_ulogic;
  signal tlxt_err_fifo_UE : std_ulogic_vector(0 to 4);
  signal tlxt_err_unexpected_val : std_ulogic;
  signal intrp_req_failed : std_ulogic;
  signal unexp_intrp_resp  : std_ulogic;
  signal rd_resp_dpart : std_ulogic_vector(1 downto 0);
  SIGNAL tlxt_fifo_overflow : std_ulogic_vector(0 to 4);
  SIGNAL tlxt_fifo_underflow : std_ulogic_vector(0 to 4);
  SIGNAL tlxt_fifo_ptr_perr : std_ulogic_vector(0 to 4);
  SIGNAL tlxt_srq_padmem_done_ack_d : std_ulogic;
  SIGNAL tlxt_srq_padmem_done_ack_q : std_ulogic;
  SIGNAL padmem_done_val_gated : std_ulogic;
  SIGNAL failresp_val_gated : std_ulogic;
  SIGNAL low_lat_mode_d : std_ulogic;
  SIGNAL low_lat_mode_q : std_ulogic;
  SIGNAL mmio_tlxt_resp_valid_d : std_ulogic;
  SIGNAL mmio_tlxt_resp_valid_q : std_ulogic;
  SIGNAL mmio_data_par_err_d : std_ulogic;
  SIGNAL mmio_data_par_err_q : std_ulogic;
  SIGNAL actag_invalid_cfg : std_ulogic;
  SIGNAL global_fir_chan_xstop_d : std_ulogic;
  SIGNAL global_fir_rec_attn_d : std_ulogic;
  SIGNAL global_fir_sp_attn_d : std_ulogic;
  SIGNAL global_fir_mchk_d :std_ulogic;
  SIGNAL global_fir_chan_xstop_q : std_ulogic;
  SIGNAL global_fir_rec_attn_q : std_ulogic;
  SIGNAL global_fir_sp_attn_q : std_ulogic;
  SIGNAL global_fir_mchk_q :std_ulogic;
  SIGNAL intrp_app_intrp : std_ulogic;
  SIGNAL intrp_chan_xstop : std_ulogic;
  SIGNAL intrp_rec_attn : std_ulogic;
  SIGNAL intrp_sp_attn : std_ulogic;
  SIGNAL link_up_d : std_ulogic;
  SIGNAL link_up_pulse : std_ulogic;
  SIGNAL link_up_q : std_ulogic;
  SIGNAL rdf_tlxt_data_err_int : std_ulogic;
  SIGNAL tlxt_rdf_data_taken_int : std_ulogic;
  signal flit_xmit_start_early : std_ulogic;
  signal tlxt_errors_d : std_ulogic_vector(0 to 32);
  signal tlxt_errors_q : std_ulogic_vector(0 to 32);
  signal cfg_half_dimm_mode_d            : std_ulogic;
  signal cfg_half_dimm_mode_q            : std_ulogic;
  signal tlxt_clk_gate_dis : std_ulogic;
  SIGNAL tmplB_data_val : std_ulogic;
  SIGNAL mmio_data_flit : std_ulogic;
  SIGNAL mmio_data_flit_early : std_ulogic;
  SIGNAL cfei_enab : std_ulogic;
  SIGNAL cfei_persist : std_ulogic;
  SIGNAL cfei_bit0 : std_ulogic;
  SIGNAL cfei_bit1 : std_ulogic;
  SIGNAL tlxt_err_invalid_tmpl_cfg : std_ulogic;
  signal flit_credit_underflow : std_ulogic;
  signal flit_credit_overflow : std_ulogic;
  SIGNAL rd_resp_len32_flit : std_ulogic;
  SIGNAL rd_resp_len32_flit_early : std_ulogic;
  SIGNAL low_lat_degrade_dis : std_ulogic;
  SIGNAL xstop_rd_gate_dis : std_ulogic;
  SIGNAL xstop_rd_gate : std_ulogic;
  SIGNAL intrp_req_sm_perr : std_ulogic_vector(0 to 3);

begin  -- cb_tlxt_mac

  act <= '1';
  -----------------------------------------------------------------------------
  -- sourceless fixes
  -----------------------------------------------------------------------------
  tlxt_dlx_tl_error <= '0';
  tlxt_dlx_tl_event <= '0';

  --------------------------------------------------------------------------------------------------
  -- terminate unused 
  --------------------------------------------------------------------------------------------------

  cb_term(cfg_otl0_tl_minor_vers_config);
  cb_term(cfg_otl0_tl_minor_vers_config_p);

  cb_term(cfg_f1_octrl00_enable_afu);

  cb_term(cfg_f1_octrl00_p);


  cfg_half_dimm_mode_d <= cfg_half_dimm_mode;
  scom_tlx_sat_id <= (OTHERS => '0');

  cb_term(tlx_fir_out);   
 
  --------------------------------------------------------------------------------------------------
  -- Map Config Bits
  --------------------------------------------------------------------------------------------------
  hi_bw_threshold(2 downto 0) <= tlxc_tlxt_ctrl(0 to 2);
  mid_bw_threshold(2 downto 0) <= tlxc_tlxt_ctrl(3 to 5);
  hi_bw_dis <= tlxc_tlxt_ctrl(6);
  mid_bw_enab <= tlxc_tlxt_ctrl(7);
  hi_bw_enab_rd_thresh <= tlxc_tlxt_ctrl(8);
  low_lat_rd_dis <= tlxc_tlxt_ctrl(9);
  tlxt_clk_gate_dis <= tlxc_tlxt_ctrl(10);
  cfei_enab <= tlxc_tlxt_ctrl(11);      --err_inj enable
  cfei_persist <= tlxc_tlxt_ctrl(12);   --err_inj every cycle
  cfei_bit0 <= tlxc_tlxt_ctrl(13);      --err_inj on bit 0
  cfei_bit1 <= tlxc_tlxt_ctrl(14);      --err_inj on bit 1
  low_lat_degrade_dis <= tlxc_tlxt_ctrl(15);


  low_lat_mode_d <= not low_lat_rd_dis and cfg_otl0_tl_xmt_tmpl_config(9) AND NOT or_reduce(cfg_otl0_tl_xmt_rate_tmpl_config(39 DOWNTO 36)) and not cfg_half_dimm_mode;
  low_lat_mode   <= low_lat_mode_q;
  tlxt_tlxr_low_lat_mode <= low_lat_mode_q;

  --------------------------------------------------------------------------------------------------
  -- linkup pulse generation
  --------------------------------------------------------------------------------------------------
  link_up_d <= dlx_tlxr_link_up;
  link_up_pulse <= not link_up_q and link_up_d;

  --------------------------------------------------------------------------------------------------
  -- rdf -> tlxt remapping
  --------------------------------------------------------------------------------------------------
  tlxt_rdf_data_taken <= tlxt_rdf_data_taken_int;

  rdf_tlxt_data_err_int <= rdf_tlxt_data_err and tlxt_rdf_data_taken_int;
  -----------------------------------------------------------------------------
  -- Read Response Queue Input
  -----------------------------------------------------------------------------
  rd_resp_val                        <= rdf_tlxt_resp_valid;
  rdf_tlxt_meta_le(5 downto 0)       <= reverse(rdf_tlxt_meta(0 to 5));
  rdf_tlxt_meta_valid_le(1 downto 0) <= switch_endian(rdf_tlxt_meta_valid(0 to 1));
  rdf_tlxt_resp_dpart_le(1 downto 0) <= switch_endian(rdf_tlxt_resp_dpart(0 to 1));
  rdf_tlxt_resp_Otag_le(15 downto 0) <= switch_endian(rdf_tlxt_resp_Otag(0 to 15));
  rd_resp(17 downto 0)               <= rd_resp_dpart(1 downto 0) &
                                        rdf_tlxt_resp_Otag_le;

  rd_resp_dpart(1 downto 0) <= (rdf_tlxt_resp_dpart_le(1) or rdf_tlxt_resp_len32) & rdf_tlxt_resp_dpart_le(0);


  rdf_tlxt_data_le(127 downto 0)    <= switch_endian(rdf_tlxt_data);
  rdf_tlxt_data_ecc_le(15 downto 0) <= switch_endian(rdf_tlxt_data_ecc);

  -----------------------------------------------------------------------------
  -- Write Response Queue Input
  -----------------------------------------------------------------------------
  padmem_done_val_gated <= srq_tlxt_padmem_done_val and not tlxt_srq_padmem_done_ack_q;
  failresp_val_gated    <= srq_tlxt_failresp_val    and not tlxt_srq_padmem_done_ack_q;

  wr_resp_val <= ((tlxr_tlxt_write_resp_val and not wr_resp_fail) or padmem_done_val_gated   ) and not wr_resp_fifo_full;

  wr_resp_fail <= or_reduce(tlxr_tlxt_write_resp(5 downto 2)) and not mem_cntl_val; -- 5:2=code. Excludes memcntl which goes down normal response path.

  wr_resp(20 downto 0) <= gate(wr_resp_int(20 downto 0),            tlxr_tlxt_write_resp_val and not mem_cntl_val and not padmem_done_val_gated    and not wr_resp_fifo_full) OR
                          gate(mem_cntl_resp(20 downto 0),          tlxr_tlxt_write_resp_val and     mem_cntl_val and not padmem_done_val_gated    and not wr_resp_fifo_full) OR
                          gate(pad_mem_resp(20 downto 0),                                                                 padmem_done_val_gated    and not wr_resp_fifo_full);

  mem_cntl_val <= not or_reduce(tlxr_tlxt_write_resp(1 downto 0));

  wr_resp_int(20 downto 0) <= "00" &
                              tlxr_tlxt_write_resp(1 downto 0) &
                              tlxr_tlxt_write_resp(21 downto 6) &
                              mem_cntl_val;

  mem_cntl_resp(20 downto 0) <= tlxr_tlxt_write_resp(5 downto 2) &  --  Note that failed mem cntl still goes down same path as a good one.
                                tlxr_tlxt_write_resp(21 downto 6) &
                                mem_cntl_val;

  wr_fail_resp(31 downto 0) <=  tlxr_tlxt_write_resp(5 downto 2) &
                                tlxr_tlxt_write_resp(1 downto 0) &
                                "00" &
                                tlxr_tlxt_write_resp(21 downto 6) &
                                "00000101";

  pad_mem_resp(20 downto 0) <= "0000" &  --may need o add a length feild here
                               srq_tlxt_padmem_done_tag &
                               '0';

  tlxt_tlxr_wr_resp_full <= (wr_resp_fifo_full and not wr_resp_fail)         -- Good wr response, but fifo full
                         or (padmem_done_val_gated    and not wr_resp_fail)  -- Good wr response, but padmem has priority
                         or (wr_resp_fail and failresp_val_gated   )         -- Bad wr response, but failresp has priority
                         or (wr_resp_fail and fail_resp_full);               -- Bad wr response, but fifo full

  tlxt_srq_padmem_done_ack_d <=  (not wr_resp_fifo_full and padmem_done_val_gated   ) or fail_resp_ack;

  tlxt_srq_padmem_done_ack <= tlxt_srq_padmem_done_ack_q;

  fail_resp_ack <= failresp_val_gated    and not fail_resp_full;

  tlxt_err_unexpected_val <= srq_tlxt_failresp_val and srq_tlxt_padmem_done_val;

  -----------------------------------------------------------------------------
  -- MMIO Response Queue Input
  -----------------------------------------------------------------------------

  -- Chop 1st cycle off mmio_tlxt_resp_valid, so we can latch up parity check on data (for timing)
  mmio_tlxt_resp_valid_d <= mmio_tlxt_resp_valid and not (mmio_resp_ack or mmio_fail_ack);
  mmio_data_par_err_d    <= mmio_data_par_err and not or_reduce(mmio_tlxt_resp_code) and mmio_tlxt_resp_valid;

  mmio_resp_val <= mmio_tlxt_resp_valid_q and not mmio_resp_fail;

  mmio_resp_fail <= or_reduce(mmio_tlxt_resp_code) or mmio_data_par_err_q;

  mmio_tlxt_resp(17 downto 0) <= mmio_tlxt_rdata_bdi &
                                 mmio_tlxt_resp_capptag &
                                 '0';


  mmio_fail_resp(31 downto 0) <=  mmio_resp_code &
                                  mmio_tlxt_resp_dl &
                                  mmio_tlxt_resp_dp &
                                  mmio_tlxt_resp_capptag &
                                  "00000010";


  mmio_fail_ack <= mmio_tlxt_resp_valid_q and mmio_resp_fail and not fail_resp_full and not ((tlxr_tlxt_write_resp_val and wr_resp_fail) or failresp_val_gated);

  tlxt_mmio_resp_ack <= mmio_resp_ack or mmio_fail_ack;

  mmio_resp_code <= gate(mmio_tlxt_resp_code,           or_reduce(mmio_tlxt_resp_code)                        ) OR -- Given code, use it
                    gate("1000",                    not or_reduce(mmio_tlxt_resp_code) and mmio_data_par_err_q);   -- 0000 but data parity error

  --------------------------------------------------------------------------------------------------
  -- Failure Response input
  --------------------------------------------------------------------------------------------------
  fail_resp_val <= (tlxr_tlxt_write_resp_val and wr_resp_fail and not fail_resp_full) or (mmio_fail_ack) or fail_resp_ack;

  rd_fail_resp(31 downto 0) <= srq_tlxt_failresp_code &
                               srq_tlxt_failresp_dlen & "00" &
                               srq_tlxt_padmem_done_tag &
                               "00000010";

  padmem_fail_resp(31 downto 0) <= srq_tlxt_failresp_code &
                               srq_tlxt_failresp_dlen & "00" &
                               srq_tlxt_padmem_done_tag &
                               "00000101";


  fail_resp_input(31 downto 0) <= gate(wr_fail_resp(31 downto 0),    tlxr_tlxt_write_resp_val and wr_resp_fail and not failresp_val_gated) OR
                                  gate(mmio_fail_resp(31 downto 0),  mmio_fail_ack) OR
                                  gate(rd_fail_resp(31 downto 0),    failresp_val_gated and not srq_tlxt_failresp_type) OR
                                  gate(padmem_fail_resp(31 downto 0), failresp_val_gated and    srq_tlxt_failresp_type);


  --------------------------------------------------------------------------------------------------
  -- Interrupt Source
  --------------------------------------------------------------------------------------------------
  global_fir_chan_xstop_d <= global_fir_chan_xstop;
  global_fir_rec_attn_d <= global_fir_rec_attn;
  global_fir_sp_attn_d <= global_fir_sp_attn;
  global_fir_mchk_d <= global_fir_mchk;

  intrp_chan_xstop <= global_fir_chan_xstop_d and not global_fir_chan_xstop_q;
  intrp_rec_attn <= global_fir_rec_attn_d and not global_fir_rec_attn_q;
  intrp_sp_attn <= global_fir_sp_attn_d and not global_fir_sp_attn_q;
  intrp_app_intrp <= global_fir_mchk_d and not global_fir_mchk_q;

  xstop_rd_gate <= not xstop_rd_gate_dis and global_fir_chan_xstop;
  --------------------------------------------------------------------------------------------------
  -- Debug Bus
  --------------------------------------------------------------------------------------------------

  tlxt_dbg_fedc(0 to 43)        <= flit_arb_debug_fedc(0 to 27)       -- 0:27
                                 & rdf_tlxt_resp_valid                -- 28
                                 & rdf_tlxt_resp_dpart(0)             -- 29    (strand 1 always 0 as never 256Byte op)
                                 & rdf_tlxt_data_valid                -- 30
                                 & rdf_tlxt_meta_valid(0)             -- 31
                                 & tlxr_tlxt_write_resp_val           -- 32
                                 & tlxr_tlxt_write_resp(0)            -- 33    (strand 1 not very useful)
                                 & srq_tlxt_padmem_done_val           -- 34
                                 & srq_tlxt_failresp_val              -- 35
                                 & mmio_tlxt_resp_valid               -- 36
                                 & tlxr_tlxt_return_val               -- 37
                                 & or_reduce(tlxr_tlxt_dcp1_release(1 downto 0)) -- 38
                                 & or_reduce(tlxr_tlxt_vc0_release(1 downto 0))  -- 39
                                 & or_reduce(tlxr_tlxt_vc1_release & srq_tlxt_cmdq_release)      -- 40

                                 & and_reduce(tlxr_tlxt_dcp1_release(1 downto 0)) -- 41
                                 & low_lat_mode_q              -- 42
                                 & xor_reduce(dlx_tlxt_lane_width_status(1 downto 0));             -- 43

  tlxt_dbg_a_debug_bus(0 to 87) <= tlxt_dbg_fedc(0 to 43)
                                 & tlxc_dbg_a_debug_bus(0 TO 43);

  tlxt_dbg_b_debug_bus(0 to 87) <=   tlxc_dbg_b_debug_bus(0 TO 87);

  -- TLXT Debug C is mainly what is driving us
  tlxt_dbg_c_debug_bus(0 to 87) <= srq_tlxt_padmem_done_val           -- 0
                                 & srq_tlxt_failresp_val              -- 1
                                 & srq_tlxt_failresp_code(1 to 3)     -- 2:4   (strand 0 not useful as always >=8)
                                 & rdf_tlxt_resp_valid                -- 5
                                 & rdf_tlxt_resp_dpart(0)             -- 6     (strand 1 always 0 as never 256Byte op)
                                 & rdf_tlxt_data_valid                -- 7
                                 & rdf_tlxt_meta_valid(0 to 1)        -- 8:9
                                 & rdf_tlxt_bad_data_valid            -- 10
                                 & rdf_tlxt_data_err_int           -- 11 previouisltbad_data_1st32
                                                                   -- which is unused
                                 & rdf_tlxt_bad_data                  -- 12
                                 & tlxr_tlxt_write_resp_val           -- 13
                                 & mmio_tlxt_resp_valid               -- 14
                                 & tlxr_tlxt_write_resp(0)            -- 15    (strand 1 not very useful)
                                 & tlxr_tlxt_write_resp(5 downto 2)   -- 16:19 (5:2 = response code)
                                 & mmio_tlxt_resp_code(3 downto 0)    -- 20:23
                                 & tlxr_tlxt_intrp_resp(7 downto 0)   -- 24:31
                                 & srq_tlxt_padmem_done_tag(0 to 15)  -- 32:47
                                 & rdf_tlxt_resp_otag                 -- 48:63
                                 & tlxr_tlxt_write_resp(21 downto 6)  -- 64:79 -- 21:6 are Tag
                                 & srq_tlxt_failresp_dlen(0 to 1)     -- 80:81
                                 & rdf_tlxt_meta(0 to 5);             -- 82:87

  -- TLXT Debug D is mainly internal state on flit assembly
  tlxt_dbg_d_debug_bus(0 to 87) <= flit_arb_debug_bus(0 to 87);

  tlxt_dbg_debug_bus <=  tlxt_debug_bus ; -- RLM output to trace muxing

  -----------------------------------------------------------------------------
  -- output mapping
  -----------------------------------------------------------------------------

  tlxt_srq_rdbuf_pop <= tlxt_srq_rdbuf_pop_int;

  --------------------------------------------------------------------------------------------------
  -- actag invalid config error
  --------------------------------------------------------------------------------------------------
  actag_invalid_cfg <= NOT ((cfg_f1_octrl00_afu_actag_base=cfg_f1_ofunc_func_actag_base) AND (cfg_f1_octrl00_afu_actag_len_enab=cfg_f1_ofunc_func_actag_len_enab));
  --------------------------------------------------------------------------------------------------
  -- TLXT Errors
  --------------------------------------------------------------------------------------------------
  tlxt_errors_d(0) <= tlxt_fifo_ptr_perr(0);
  tlxt_errors_d(1) <= tlxt_fifo_ptr_perr(1);
  tlxt_errors_d(2) <= tlxt_fifo_ptr_perr(2);
  tlxt_errors_d(3) <= tlxt_fifo_ptr_perr(3);
  tlxt_errors_d(4) <= tlxt_fifo_ptr_perr(4);
  tlxt_errors_d(5) <= tlxt_err_fifo_CE;   --rec ctrl err
  tlxt_errors_d(6) <= intrp_req_failed;   --rec ctrl err
  tlxt_errors_d(7) <= unexp_intrp_resp;   -- rec ctrl err
  tlxt_errors_d(8) <= tlxt_err_bdi_poisoned;  --rec ctrl err
  tlxt_errors_d(9) <= tlxt_err_fifo_UE(0);   --unrec ctrl err
  tlxt_errors_d(10) <= tlxt_err_invalid_meta_cfg;
  tlxt_errors_d(11) <= tlxt_err_invalid_cfg;-- OR
  tlxt_errors_d(12) <= tlxt_err_fifo_UE(1);
  tlxt_errors_d(13) <= tlxt_err_fifo_UE(2);
  tlxt_errors_d(14) <= tlxt_err_fifo_UE(3);
  tlxt_errors_d(15) <= tlxt_err_fifo_UE(4);
  tlxt_errors_d(16) <= tlxt_err_invalid_crd_ret;  --unrec err
  tlxt_errors_d(17) <= tlxt_err_dropped_crd_ret;  --unrec err
  tlxt_errors_d(18) <= tlxt_err_unexpected_val;
  tlxt_errors_d(19) <= tlxt_fifo_overflow(0);  --tlxt HW error
  tlxt_errors_d(20) <= tlxt_fifo_overflow(1);  --HW err
  tlxt_errors_d(21) <= tlxt_fifo_overflow(2);  --HW err
  tlxt_errors_d(22) <= tlxt_fifo_overflow(3);  --HW err
  tlxt_errors_d(23) <= tlxt_fifo_overflow(4);  --HW err
  tlxt_errors_d(24) <= tlxt_fifo_underflow(0);  --HW err
  tlxt_errors_d(25) <= tlxt_fifo_underflow(1);  --HW err
  tlxt_errors_d(26) <= tlxt_fifo_underflow(2);  --HW err
  tlxt_errors_d(27) <= tlxt_fifo_underflow(3);  --HW err
  tlxt_errors_d(28) <= tlxt_fifo_underflow(4);  --HW err
  tlxt_errors_d(29) <= flit_credit_underflow;
  tlxt_errors_d(30) <= flit_credit_overflow;
  tlxt_errors_d(31) <= tlxt_err_invalid_tmpl_cfg;
  tlxt_errors_d(32) <= tlxt_rdf_data_taken_int and not rdf_tlxt_data_valid;  --taken but not valid

  tlxt_errors <= tlxt_errors_q;
  --------------------------------------------------------------------------------------------------
  -- Parity Checkers
  --------------------------------------------------------------------------------------------------

  -- Config register inputs (from MMIO macro) (check every cycle)
  tlxt_perrors( 0) <= XOR_REDUCE(cfg_otl0_tl_minor_vers_config & cfg_otl0_tl_minor_vers_config_p);
  tlxt_perrors( 1) <= XOR_REDUCE(cfg_otl0_tl_xmt_tmpl_config); -- Bit 12 is P
  tlxt_perrors( 2) <= XOR_REDUCE(cfg_otl0_tl_xmt_rate_tmpl_config); -- Bit 48 is P
  tlxt_perrors( 3) <= XOR_REDUCE(cfg_f1_octrl00_enable_afu & cfg_f1_octrl00_metadata_enabled & cfg_f1_octrl00_p);
  tlxt_perrors( 4) <= XOR_REDUCE(cfg_f1_ofunc_func_actag_base); -- Bit 12 is P
  tlxt_perrors( 5) <= XOR_REDUCE(cfg_f1_ofunc_func_actag_len_enab); -- Bit 12 is P
  tlxt_perrors( 6) <= XOR_REDUCE(cfg_f1_octrl00_pasid_length_enabled); -- Bit 5 is P
  tlxt_perrors( 7) <= XOR_REDUCE(cfg_f1_octrl00_pasid_base); -- Bit 20 is P

  -- Boundary inputs from TLXR (check every cycle)
  tlxt_perrors( 8) <= XOR_REDUCE(tlxr_tlxt_write_resp(21 downto 14) & tlxr_tlxt_write_resp_p(2));
  tlxt_perrors( 9) <= XOR_REDUCE(tlxr_tlxt_write_resp(13 downto  6) & tlxr_tlxt_write_resp_p(1));
  tlxt_perrors(10) <= XOR_REDUCE(tlxr_tlxt_write_resp( 5 downto  0) & tlxr_tlxt_write_resp_val & tlxr_tlxt_write_resp_p(0));

  -- Boundary inputs from MMIO (check every cycle)
  tlxt_perrors(11) <= XOR_REDUCE(mmio_tlxt_resp_valid & mmio_tlxt_resp_opcode & mmio_tlxt_resp_dl & mmio_tlxt_resp_capptag & mmio_tlxt_resp_dp & mmio_tlxt_resp_code & mmio_tlxt_rdata_offset & mmio_tlxt_rdata_bdi & mmio_tlxt_resp_par);

  -- Boundary inputs from RDF (bad checked every cycle, meta only when valid)
  tlxt_perrors(12) <= XOR_REDUCE(rdf_tlxt_bad_data_valid & rdf_tlxt_bad_data & rdf_tlxt_bad_data_1st32B & rdf_tlxt_bad_data_p);
  tlxt_perrors(13) <= OR_REDUCE(rdf_tlxt_meta_valid) and XOR_REDUCE(rdf_tlxt_meta & rdf_tlxt_meta_p);

  -- SRQ boundary inputs (check when valid)
  tlxt_perrors(14) <= (srq_tlxt_padmem_done_val or srq_tlxt_failresp_val) and XOR_REDUCE(srq_tlxt_padmem_done_tag(0 to  7) & srq_tlxt_padmem_done_tag_p(0));
  tlxt_perrors(15) <= (srq_tlxt_padmem_done_val or srq_tlxt_failresp_val) and XOR_REDUCE(srq_tlxt_padmem_done_tag(8 to 15) & srq_tlxt_padmem_done_tag_p(1));

  tlxt_perrors(16 to 23) <= flit_arb_perrors(0 to 7);

  tlxt_perrors(24) <= rdf_tlxt_resp_valid and XOR_REDUCE(rdf_tlxt_resp_p&rdf_tlxt_resp_otag&rdf_tlxt_resp_dpart&rdf_tlxt_resp_len32&rdf_tlxt_resp_exit0);
  tlxt_perrors(25) <= mmio_data_par_err_q;
  tlxt_perrors(26) <= '0';              --For Fututre use

  tlxt_perrors(27 to 31) <= trans_arb_perrors(0 to 4);

  tlxt_perrors(32) <= flit_arb_perrors(8);

  --------------------------------------------------------------------------------------------------
  -- MMIO Data Parity Check
  --------------------------------------------------------------------------------------------------
  mmio_data_par_err <= or_reduce(mmio_data_par(31 downto 0));

  mmio_data_par(0) <= xor_reduce(mmio_tlxt_rdata_bus(256)&mmio_tlxt_rdata_bus(7 downto 0));
  mmio_data_par(1) <= xor_reduce(mmio_tlxt_rdata_bus(257)&mmio_tlxt_rdata_bus(15 downto 8));
  mmio_data_par(2) <= xor_reduce(mmio_tlxt_rdata_bus(258)&mmio_tlxt_rdata_bus(23 downto 16));
  mmio_data_par(3) <= xor_reduce(mmio_tlxt_rdata_bus(259)&mmio_tlxt_rdata_bus(31 downto 24));
  mmio_data_par(4) <= xor_reduce(mmio_tlxt_rdata_bus(260)&mmio_tlxt_rdata_bus(39 downto 32));
  mmio_data_par(5) <= xor_reduce(mmio_tlxt_rdata_bus(261)&mmio_tlxt_rdata_bus(47 downto 40));
  mmio_data_par(6) <= xor_reduce(mmio_tlxt_rdata_bus(262)&mmio_tlxt_rdata_bus(55 downto 48));
  mmio_data_par(7) <= xor_reduce(mmio_tlxt_rdata_bus(263)&mmio_tlxt_rdata_bus(63 downto 56));
  mmio_data_par(8) <= xor_reduce(mmio_tlxt_rdata_bus(264)&mmio_tlxt_rdata_bus(71 downto 64));
  mmio_data_par(9) <= xor_reduce(mmio_tlxt_rdata_bus(265)&mmio_tlxt_rdata_bus(79 downto 72));
  mmio_data_par(10) <= xor_reduce(mmio_tlxt_rdata_bus(266)&mmio_tlxt_rdata_bus(87 downto 80));
  mmio_data_par(11) <= xor_reduce(mmio_tlxt_rdata_bus(267)&mmio_tlxt_rdata_bus(95 downto 88));
  mmio_data_par(12) <= xor_reduce(mmio_tlxt_rdata_bus(268)&mmio_tlxt_rdata_bus(103 downto 96));
  mmio_data_par(13) <= xor_reduce(mmio_tlxt_rdata_bus(269)&mmio_tlxt_rdata_bus(111 downto 104));
  mmio_data_par(14) <= xor_reduce(mmio_tlxt_rdata_bus(270)&mmio_tlxt_rdata_bus(119 downto 112));
  mmio_data_par(15) <= xor_reduce(mmio_tlxt_rdata_bus(271)&mmio_tlxt_rdata_bus(127 downto 120));
  mmio_data_par(16) <= xor_reduce(mmio_tlxt_rdata_bus(272)&mmio_tlxt_rdata_bus(135 downto 128));
  mmio_data_par(17) <= xor_reduce(mmio_tlxt_rdata_bus(273)&mmio_tlxt_rdata_bus(143 downto 136));
  mmio_data_par(18) <= xor_reduce(mmio_tlxt_rdata_bus(274)&mmio_tlxt_rdata_bus(151 downto 144));
  mmio_data_par(19) <= xor_reduce(mmio_tlxt_rdata_bus(275)&mmio_tlxt_rdata_bus(159 downto 152));
  mmio_data_par(20) <= xor_reduce(mmio_tlxt_rdata_bus(276)&mmio_tlxt_rdata_bus(167 downto 160));
  mmio_data_par(21) <= xor_reduce(mmio_tlxt_rdata_bus(277)&mmio_tlxt_rdata_bus(175 downto 168));
  mmio_data_par(22) <= xor_reduce(mmio_tlxt_rdata_bus(278)&mmio_tlxt_rdata_bus(183 downto 176));
  mmio_data_par(23) <= xor_reduce(mmio_tlxt_rdata_bus(279)&mmio_tlxt_rdata_bus(191 downto 184));
  mmio_data_par(24) <= xor_reduce(mmio_tlxt_rdata_bus(280)&mmio_tlxt_rdata_bus(199 downto 192));
  mmio_data_par(25) <= xor_reduce(mmio_tlxt_rdata_bus(281)&mmio_tlxt_rdata_bus(207 downto 200));
  mmio_data_par(26) <= xor_reduce(mmio_tlxt_rdata_bus(282)&mmio_tlxt_rdata_bus(215 downto 208));
  mmio_data_par(27) <= xor_reduce(mmio_tlxt_rdata_bus(283)&mmio_tlxt_rdata_bus(223 downto 216));
  mmio_data_par(28) <= xor_reduce(mmio_tlxt_rdata_bus(284)&mmio_tlxt_rdata_bus(231 downto 224));
  mmio_data_par(29) <= xor_reduce(mmio_tlxt_rdata_bus(285)&mmio_tlxt_rdata_bus(239 downto 232));
  mmio_data_par(30) <= xor_reduce(mmio_tlxt_rdata_bus(286)&mmio_tlxt_rdata_bus(247 downto 240));
  mmio_data_par(31) <= xor_reduce(mmio_tlxt_rdata_bus(287)&mmio_tlxt_rdata_bus(255 downto 248));


crd_mgmt : entity work.cb_tlxt_crd_mgmt_rlm
port map (
    gckn                                => gckn                               , -- MSR: cb_tlxt_crd_mgmt_rlm(crd_mgmt)
    gnd                                 => gnd                                , -- MSB: cb_tlxt_crd_mgmt_rlm(crd_mgmt)
    syncr                               => syncr                             , --
    cfg_half_dimm_mode                 => cfg_half_dimm_mode_q               , --
    srq_tlxt_cmdq_release               => srq_tlxt_cmdq_release              , -- MSR: cb_tlxt_crd_mgmt_rlm(crd_mgmt)
    tlxc_crd_cfg_reg (0 to 63)          => tlxc_crd_cfg_reg (0 to 63)         , -- MSR: cb_tlxt_crd_mgmt_rlm(crd_mgmt)
    tlxc_wat_en_reg (0 to 23)           => tlxc_wat_en_reg (0 to 23)         , -- MSR: cb_tlxt_crd_mgmt_rlm(crd_mgmt)
    dbg_tlxt_wat_event(0 TO 3)          => dbg_tlxt_wat_event(0 TO 3),
    tlxc_crd_status_reg (0 to 127)      => tlxc_crd_status_reg (0 to 127)      , -- MSD: cb_tlxt_crd_mgmt_rlm(crd_mgmt)
    tlxc_errors (0 to 15)               => tlxc_errors (0 to 15)               , -- MSD: cb_tlxt_crd_mgmt_rlm(crd_mgmt)
    tlxc_perrors (0 to 7)               => tlxc_perrors (0 to 7)               , -- MSD: cb_tlxt_crd_mgmt_rlm(crd_mgmt)

    tlxc_dbg_a_debug_bus                => tlxc_dbg_a_debug_bus(0 to 43)      , -- MSD: cb_tlxt_crd_mgmt_rlm(crd_mgmt)
    tlxc_dbg_b_debug_bus                => tlxc_dbg_b_debug_bus(0 to 87)      , -- MSD: cb_tlxt_crd_mgmt_rlm(crd_mgmt)
    tlxc_tlxt_avail_dcp0 (3 downto 0)   => tlxc_tlxt_avail_dcp0 (3 downto 0)  , -- MSD: cb_tlxt_crd_mgmt_rlm(crd_mgmt)
    tlxc_tlxt_avail_dcp3 (3 downto 0)   => tlxc_tlxt_avail_dcp3 (3 downto 0)  , -- MSD: cb_tlxt_crd_mgmt_rlm(crd_mgmt)
    tlxc_tlxt_avail_vc0 (3 downto 0)    => tlxc_tlxt_avail_vc0 (3 downto 0)   , -- MSD: cb_tlxt_crd_mgmt_rlm(crd_mgmt)
    tlxc_tlxt_avail_vc3 (3 downto 0)    => tlxc_tlxt_avail_vc3 (3 downto 0)   , -- MSD: cb_tlxt_crd_mgmt_rlm(crd_mgmt)
    tlxc_tlxt_crd_ret_val               => tlxc_tlxt_crd_ret_val              , -- MSD: cb_tlxt_crd_mgmt_rlm(crd_mgmt)
    tlxc_tlxt_dcp1_credits (5 downto 0) => tlxc_tlxt_dcp1_credits (5 downto 0), -- MSD: cb_tlxt_crd_mgmt_rlm(crd_mgmt)
    tlxc_tlxt_vc0_credits (3 downto 0)  => tlxc_tlxt_vc0_credits (3 downto 0) , -- MSD: cb_tlxt_crd_mgmt_rlm(crd_mgmt)
    tlxc_tlxt_vc1_credits (3 downto 0)  => tlxc_tlxt_vc1_credits (3 downto 0) , -- MSD: cb_tlxt_crd_mgmt_rlm(crd_mgmt)
    tlxc_tlxt_dcp1_credits_p            => tlxc_tlxt_dcp1_credits_p , -- MSD: cb_tlxt_crd_mgmt_rlm(crd_mgmt)
    tlxc_tlxt_vc0_credits_p             => tlxc_tlxt_vc0_credits_p  , -- MSD: cb_tlxt_crd_mgmt_rlm(crd_mgmt)
    tlxc_tlxt_vc1_credits_p             => tlxc_tlxt_vc1_credits_p  , -- MSD: cb_tlxt_crd_mgmt_rlm(crd_mgmt)
    tlxr_tlxt_consume_dcp1 (2 downto 0) => tlxr_tlxt_consume_dcp1 (2 downto 0), -- MSR: cb_tlxt_crd_mgmt_rlm(crd_mgmt)
    tlxr_tlxt_consume_vc0               => tlxr_tlxt_consume_vc0              , -- MSR: cb_tlxt_crd_mgmt_rlm(crd_mgmt)
    tlxr_tlxt_consume_vc1               => tlxr_tlxt_consume_vc1              , -- MSR: cb_tlxt_crd_mgmt_rlm(crd_mgmt)
    tlxr_tlxt_dcp1_release (2 downto 0) => tlxr_tlxt_dcp1_release (2 downto 0), -- MSR: cb_tlxt_crd_mgmt_rlm(crd_mgmt)
    tlxr_tlxt_vc0_release (1 downto 0)  => tlxr_tlxt_vc0_release (1 downto 0), -- MSR: cb_tlxt_crd_mgmt_rlm(crd_mgmt)
    tlxr_tlxt_vc1_release               => tlxr_tlxt_vc1_release,              -- MSR: cb_tlxt_crd_mgmt_rlm(crd_mgmt)
    tlxr_tlxt_return_dcp0 (5 downto 0)  => tlxr_tlxt_return_dcp0 (5 downto 0) , -- MSR: cb_tlxt_crd_mgmt_rlm(crd_mgmt)
    tlxr_tlxt_return_dcp3 (5 downto 0)  => tlxr_tlxt_return_dcp3 (5 downto 0) , -- MSR: cb_tlxt_crd_mgmt_rlm(crd_mgmt)
    tlxr_tlxt_return_val                => tlxr_tlxt_return_val               , -- MSR: cb_tlxt_crd_mgmt_rlm(crd_mgmt)
    tlxr_tlxt_return_vc0 (3 downto 0)   => tlxr_tlxt_return_vc0 (3 downto 0)  , -- MSR: cb_tlxt_crd_mgmt_rlm(crd_mgmt)
    tlxr_tlxt_return_vc3 (3 downto 0)   => tlxr_tlxt_return_vc3 (3 downto 0)  , -- MSR: cb_tlxt_crd_mgmt_rlm(crd_mgmt)
    tlxt_tlxc_consume_dcp0 (3 downto 0) => tlxt_tlxc_consume_dcp0 (3 downto 0), -- MSR: cb_tlxt_crd_mgmt_rlm(crd_mgmt)
    tlxt_tlxc_consume_dcp3 (3 downto 0) => tlxt_tlxc_consume_dcp3 (3 downto 0), -- MSR: cb_tlxt_crd_mgmt_rlm(crd_mgmt)
    tlxt_tlxc_consume_val               => tlxt_tlxc_consume_val              , -- MSR: cb_tlxt_crd_mgmt_rlm(crd_mgmt)
    tlxt_tlxc_consume_vc0 (3 downto 0)  => tlxt_tlxc_consume_vc0 (3 downto 0) , -- MSR: cb_tlxt_crd_mgmt_rlm(crd_mgmt)
    tlxt_tlxc_consume_vc3 (3 downto 0)  => tlxt_tlxc_consume_vc3 (3 downto 0) , -- MSR: cb_tlxt_crd_mgmt_rlm(crd_mgmt)
    tlxt_tlxc_crd_ret_taken             => tlxt_tlxc_crd_ret_taken            , -- MSR: cb_tlxt_crd_mgmt_rlm(crd_mgmt)
    vdd                                 => vdd                                  -- MSB: cb_tlxt_crd_mgmt_rlm(crd_mgmt)
);                      

trans_arb : entity work.cb_tlxt_trans_arb_rlm
port map (
    cfei_enab                             => cfei_enab                            ,
    cfei_persist                          => cfei_persist                         ,
    cfei_bit0                             => cfei_bit0                            ,
    cfei_bit1                             => cfei_bit1                            ,
    data_flit_xmit                        => data_flit_xmit                       , -- MSD: cb_tlxt_trans_arb_rlm(trans_arb)
    data_pending                          => data_pending                         , -- MSR: cb_tlxt_trans_arb_rlm(trans_arb)
    data_valid                            => data_valid                           , -- MSD: cb_tlxt_trans_arb_rlm(trans_arb)
    data_xmit                             => data_xmit                            , -- MSD: cb_tlxt_trans_arb_rlm(trans_arb)
    dl_cont_bdi_vec (7 downto 0)          => dl_cont_bdi_vec (7 downto 0)         , -- MSR: cb_tlxt_trans_arb_rlm(trans_arb)
    dl_cont_bdi_vec_p                     => dl_cont_bdi_vec_p                    , -- MSR: cb_tlxt_trans_arb_rlm(trans_arb)
    dl_cont_data_run_len (3 downto 0)     => dl_cont_data_run_len (3 downto 0)    , -- MSR: cb_tlxt_trans_arb_rlm(trans_arb)
    dl_cont_tl_tmpl (5 downto 0)          => dl_cont_tl_tmpl (5 downto 0)         , -- MSR: cb_tlxt_trans_arb_rlm(trans_arb)
    dl_cont_tl_tmpl_p                     => dl_cont_tl_tmpl_p                    , -- MSR: cb_tlxt_trans_arb_rlm(trans_arb)
    dlx_tlxr_link_up                      => dlx_tlxr_link_up                     , -- MSR: cb_tlxt_trans_arb_rlm(trans_arb)
    dlx_tlxt_flit_credit                  => dlx_tlxt_flit_credit                 , -- MSR: cb_tlxt_trans_arb_rlm(trans_arb)
    flit_credit_avail                     => flit_credit_avail                    , -- MSD: cb_tlxt_trans_arb_rlm(trans_arb)
    flit_credit_overflow                  => flit_credit_overflow                 , -- MSD: cb_tlxt_trans_arb_rlm(trans_arb)
    flit_credit_underflow                  => flit_credit_underflow                 , -- MSD: cb_tlxt_trans_arb_rlm(trans_arb)
    flit_part (127 downto 0)              => flit_part (127 downto 0)             , -- MSR: cb_tlxt_trans_arb_rlm(trans_arb)
    flit_part_p (15 downto 0)             => flit_part_p (15 downto 0)            , -- MSR: cb_tlxt_trans_arb_rlm(trans_arb)
    flit_part_last (63 downto 0)          => flit_part_last (63 downto 0)         , -- MSR: cb_tlxt_trans_arb_rlm(trans_arb)
    flit_part_last_p(7 downto 0)          => flit_part_last_p (7 downto 0)        , -- MSR: cb_tlxt_trans_arb_rlm(trans_arb)
    flit_part_last_vld                    => flit_part_last_vld                   , -- MSR: cb_tlxt_trans_arb_rlm(trans_arb)
    flit_part_vld                         => flit_part_vld                        , -- MSR: cb_tlxt_trans_arb_rlm(trans_arb)
    flit_xmit_done                        => flit_xmit_done                       , -- MSD: cb_tlxt_trans_arb_rlm(trans_arb)
    flit_xmit_early_done                  => flit_xmit_early_done                 , -- MSD: cb_tlxt_trans_arb_rlm(trans_arb)
    flit_xmit_start                       => flit_xmit_start                      , -- MSR: cb_tlxt_trans_arb_rlm(trans_arb)
    flit_xmit_start_early                 => flit_xmit_start_early                ,
    half_dimm_mode                        => cfg_half_dimm_mode_q                 ,
    gckn                                  => gckn                                 , -- MSR: cb_tlxt_trans_arb_rlm(trans_arb)
    gnd                                   => gnd                                  , -- MSB: cb_tlxt_trans_arb_rlm(trans_arb)
    link_up_pulse                         => link_up_pulse                        , -- MSR: cb_tlxt_trans_arb_rlm(trans_arb)
    mmio_data_val                         => mmio_data_val                        , -- MSR: cb_tlxt_trans_arb_rlm(trans_arb)
    mmio_data_flit                         => mmio_data_flit                        , -- MSR: cb_tlxt_trans_arb_rlm(trans_arb)
    mmio_data_flit_early                         => mmio_data_flit_early                        , -- MSR: cb_tlxt_trans_arb_rlm(trans_arb)
    rd_resp_len32_flit                    => rd_resp_len32_flit                   ,
    rd_resp_len32_flit_early              => rd_resp_len32_flit_early             ,
    rdf_tlxt_data                         => rdf_tlxt_data_le                     , -- OVR: cb_tlxt_trans_arb_rlm(trans_arb)
    rdf_tlxt_data_ecc                     => rdf_tlxt_data_ecc_le                 , -- OVR: cb_tlxt_trans_arb_rlm(trans_arb)
    rdf_tlxt_data_valid                   => rdf_tlxt_data_valid                  , -- MSR: cb_tlxt_trans_arb_rlm(trans_arb)
    syncr                                 => syncr                                , -- MSR: cb_tlxt_trans_arb_rlm(trans_arb)
    tmpl9_data_val                        => tmpl9_data_val                       , -- MSR: cb_tlxt_trans_arb_rlm(trans_arb)
    tmplB_data_val                      => tmplB_data_val                     , -- MSD: cb_tlxt_flit_arb_rlm(flit_arb)
    tlxt_clk_gate_dis                     => tlxt_clk_gate_dis                    ,
    tlxt_dlx_flit_data (127 downto 0)     => tlxt_dlx_flit_data (127 downto 0)    , -- MSD: cb_tlxt_trans_arb_rlm(trans_arb)
    tlxt_dlx_flit_early_vld_a               => tlxt_dlx_flit_early_vld_a              , -- MSD: cb_tlxt_trans_arb_rlm(trans_arb)
    tlxt_dlx_flit_early_vld_b           => tlxt_dlx_flit_early_vld_b                  , -- MSD: cb_tlxt_trans_arb_rlm(trans_arb)
    tlxt_dlx_flit_ecc (15 downto 0)       => tlxt_dlx_flit_ecc (15 downto 0)      , -- MSD: cb_tlxt_trans_arb_rlm(trans_arb)
    tlxt_dlx_flit_lbip_data (81 downto 0) => tlxt_dlx_flit_lbip_data (81 downto 0), -- MSD: cb_tlxt_trans_arb_rlm(trans_arb)
--  tlxt_dlx_flit_lbip_ecc (15 downto 0)  => tlxt_dlx_flit_lbip_ecc (15 downto 0) , -- MSD: cb_tlxt_trans_arb_rlm(trans_arb)
    tlxt_dlx_flit_lbip_vld                => tlxt_dlx_flit_lbip_vld               , -- MSD: cb_tlxt_trans_arb_rlm(trans_arb)
    tlxt_dlx_flit_vld                     => tlxt_dlx_flit_vld                    , -- MSD: cb_tlxt_trans_arb_rlm(trans_arb)
    tlxt_rdf_data_taken                   => tlxt_rdf_data_taken_int              , -- MSD: cb_tlxt_trans_arb_rlm(trans_arb)
    tlxt_srq_rdbuf_pop                    => tlxt_srq_rdbuf_pop_int               , -- MSD: cb_tlxt_trans_arb_rlm(trans_arb)
    trans_arb_perrors(0 to 4)             => trans_arb_perrors(0 to 4)            , -- MSD: cb_tlxt_trans_arb_rlm(trans_arb)
    low_lat_mode                          => low_lat_mode                         , -- MSR: cb_tlxt_trans_arb_rlm(trans_arb)
    vdd                                   => vdd                                    -- MSB: cb_tlxt_trans_arb_rlm(trans_arb)
);

flit_arb : entity work.cb_tlxt_flit_arb_rlm
port map (
    actag_base (12 downto 0)            => cfg_f1_ofunc_func_actag_base (12 downto 0)                        ,  --MSR: cb_tlxt_flit_arb_rlm(flit_arb)
    actag_len_enab (11 downto 0)        => cfg_f1_ofunc_func_actag_len_enab (11 downto 0)                    ,  --MSR: cb_tlxt_flit_arb_rlm(flit_arb)
    actag_err                           => actag_invalid_cfg                                                 , --MSR: cb_tlxt_flit_arb_rlm(flit_arb)
    bad_data                            => rdf_tlxt_bad_data                           , -- MSR: cb_tlxt_flit_arb_rlm(flit_arb)
    bad_data_1st32b                     => '0'                    , -- MSR: cb_tlxt_flit_arb_rlm(flit_arb)
    bad_data_valid                      => rdf_tlxt_bad_data_valid                     , -- MSR: cb_tlxt_flit_arb_rlm(flit_arb)
    busnum (8 downto 0 )                => mmio_tlxt_busnum(8 downto 0)                ,  -- MSR: cb_tlxt_flit_arb_rlm(flit_arb)
    cmd_flag_0 (3 downto 0)             => tlxt_intrp_cmdflag_0 (0 to 3)                ,
    cmd_flag_1 (3 downto 0)             => tlxt_intrp_cmdflag_1 (0 to 3)                ,
    cmd_flag_2 (3 downto 0)             => tlxt_intrp_cmdflag_2 (0 to 3)                ,
    cmd_flag_3 (3 downto 0)             => tlxt_intrp_cmdflag_3 (0 to 3)                ,
    data_flit_xmit                      => data_flit_xmit                     , -- MSR: cb_tlxt_flit_arb_rlm(flit_arb)
    data_pending                        => data_pending                       , -- MSD: cb_tlxt_flit_arb_rlm(flit_arb)
    data_valid                          => data_valid                         , -- MSR: cb_tlxt_flit_arb_rlm(flit_arb)
    data_xmit                           => data_xmit                          , -- MSR: cb_tlxt_flit_arb_rlm(flit_arb)
    dl_cont_bdi_vec (7 downto 0)        => dl_cont_bdi_vec (7 downto 0)       , -- MSD: cb_tlxt_flit_arb_rlm(flit_arb)
    dl_cont_bdi_vec_p                   => dl_cont_bdi_vec_p                  , -- MSD: cb_tlxt_flit_arb_rlm(flit_arb)
    dl_cont_data_run_len (3 downto 0)   => dl_cont_data_run_len (3 downto 0)  , -- MSD: cb_tlxt_flit_arb_rlm(flit_arb)
    dl_cont_tl_tmpl (5 downto 0)        => dl_cont_tl_tmpl (5 downto 0)       , -- MSD: cb_tlxt_flit_arb_rlm(flit_arb)
    dl_cont_tl_tmpl_p                   => dl_cont_tl_tmpl_p                  , -- MSD: cb_tlxt_flit_arb_rlm(flit_arb)
    dlx_tlxt_lane_width_status          => dlx_tlxt_lane_width_status         , 
    link_up_pulse                       => link_up_pulse                      , -- MSR: cb_tlxt_flit_arb_rlm(flit_arb)
    link_up                             => link_up_q                          , -- MSR: cb_tlxt_flit_arb_rlm(flit_arb)
    low_lat_degrade_dis                => low_lat_degrade_dis                         , -- MSR: cb_tlxt_flit_arb_rlm(flit_arb)
    fail_resp_full                      => fail_resp_full                     ,  --MSR: cb_tlxt_flit_arb_rlm(flit_arb)
    fail_resp_input (31 downto 0)       => fail_resp_input (31 downto 0)      , -- MSR: cb_tlxt_flit_arb_rlm(flit_arb)
    fail_resp_val                       => fail_resp_val                      , -- MSR: cb_tlxt_flit_arb_rlm(flit_arb)
    flit_credit_avail                   => flit_credit_avail                  , -- MSR: cb_tlxt_flit_arb_rlm(flit_arb)
    flit_part (127 downto 0)            => flit_part (127 downto 0)           , -- MSD: cb_tlxt_flit_arb_rlm(flit_arb)
    flit_part_p (15 downto 0)           => flit_part_p (15 downto 0)          , -- MSD: cb_tlxt_flit_arb_rlm(flit_arb)
    flit_part_last (63 downto 0)        => flit_part_last (63 downto 0)       , -- MSD: cb_tlxt_flit_arb_rlm(flit_arb)
    flit_part_last_p (7 downto 0)       => flit_part_last_p (7 downto 0)      , -- MSD: cb_tlxt_flit_arb_rlm(flit_arb)
    flit_part_last_vld                  => flit_part_last_vld                 , -- MSD: cb_tlxt_flit_arb_rlm(flit_arb)
    flit_part_vld                       => flit_part_vld                      , -- MSD: cb_tlxt_flit_arb_rlm(flit_arb)
    flit_xmit_done                      => flit_xmit_done                     , -- MSR: cb_tlxt_flit_arb_rlm(flit_arb)
    flit_xmit_early_done                => flit_xmit_early_done                 , -- MSR: cb_tlxt_trans_arb_rlm(flit_arb)
    flit_xmit_start                     => flit_xmit_start                    , -- MSD: cb_tlxt_flit_arb_rlm(flit_arb)
    flit_xmit_start_early               => flit_xmit_start_early              ,
    gckn                                => gckn                               , -- MSR: cb_tlxt_flit_arb_rlm(flit_arb)
    half_dimm_mode                      => cfg_half_dimm_mode_q               ,
    intrp_app_intrp                     => intrp_app_intrp                     ,  -- MSR: cb_tlxt_flit_arb_rlm(flit_arb)
    intrp_chan_xstop                    => intrp_chan_xstop               ,  -- MSR: cb_tlxt_flit_arb_rlm(flit_arb)
    intrp_resp (7 downto 0)             => tlxr_tlxt_intrp_resp (7 downto 0)  ,  -- MSR: cb_tlxt_flit_arb_rlm(flit_arb)
    intrp_rec_attn                      => intrp_rec_attn                ,  -- MSR: cb_tlxt_flit_arb_rlm(flit_arb)
    intrp_sp_attn                       => intrp_sp_attn                 ,  -- MSR: cb_tlxt_flit_arb_rlm(flit_arb)
    syncr                               => syncr                             , --
    gnd                                 => gnd                                , -- MSB: cb_tlxt_flit_arb_rlm(flit_arb)
    meta                                => rdf_tlxt_meta_le                   , -- OVR: cb_tlxt_flit_arb_rlm(flit_arb)
    meta_p                              => rdf_tlxt_meta_p                    , -- OVR: cb_tlxt_flit_arb_rlm(flit_arb)
    meta_val                            => rdf_tlxt_meta_valid_le             , -- OVR: cb_tlxt_flit_arb_rlm(flit_arb)
    metadata_enabled                    => cfg_f1_octrl00_metadata_enabled                   , -- MSR: cb_tlxt_flit_arb_rlm(flit_arb)
    mmio_data_val                       => mmio_data_val                      , -- MSD: cb_tlxt_flit_arb_rlm(flit_arb)
    mmio_data_flit                       => mmio_data_flit                     , -- MSD: cb_tlxt_flit_arb_rlm(flit_arb)
    mmio_data_flit_early                       => mmio_data_flit_early                     , -- MSD: cb_tlxt_flit_arb_rlm(flit_arb)
    mmio_resp_val                       => mmio_resp_val                      , -- MSR: cb_tlxt_flit_arb_rlm(flit_arb)
    mmio_tlxt_rdata_bdi                 => mmio_tlxt_rdata_bdi                , -- MSR: cb_tlxt_flit_arb_rlm(flit_arb)
    mmio_tlxt_rdata_bus (287 downto 0)  => mmio_tlxt_rdata_bus (287 downto 0) , -- MSR: cb_tlxt_flit_arb_rlm(flit_arb)
    mmio_tlxt_rdata_offset              => mmio_tlxt_rdata_offset             , -- MSR: cb_tlxt_flit_arb_rlm(flit_arb)
    mmio_tlxt_resp (17 downto 0)        => mmio_tlxt_resp (17 downto 0)       , -- MSR: cb_tlxt_flit_arb_rlm(flit_arb)
    pasid_base (20 downto 0)            => cfg_f1_octrl00_pasid_base (20 downto 0)          ,  --MSR: cb_tlxt_flit_arb_rlm(flit_arb)
    pasid_length_enabled (4 downto 0)   => cfg_f1_octrl00_pasid_length_enabled (4 downto 0)              ,  --MSR: cb_tlxt_flit_arb_rlm(flit_arb)
    rd_resp_exit0                       => rdf_tlxt_resp_exit0                ,
    rd_resp_len32_flit                  => rd_resp_len32_flit                 ,
    rd_resp_len32_flit_early            => rd_resp_len32_flit_early           ,
    rd_resp (17 downto 0)               => rd_resp (17 downto 0)              , -- MSR: cb_tlxt_flit_arb_rlm(flit_arb)
    rd_resp_val                         => rd_resp_val                        , -- MSR: cb_tlxt_flit_arb_rlm(flit_arb)
    rdf_tlxt_data_err                   => rdf_tlxt_data_err_int              ,
    tmpl9_data_val                      => tmpl9_data_val                     , -- MSD: cb_tlxt_flit_arb_rlm(flit_arb)
    tmplB_data_val                      => tmplB_data_val                     , -- MSD: cb_tlxt_flit_arb_rlm(flit_arb)
    tlxc_tlxt_avail_dcp0 (3 downto 0)   => tlxc_tlxt_avail_dcp0 (3 downto 0)  , -- MSR: cb_tlxt_flit_arb_rlm(flit_arb)
    tlxc_tlxt_avail_dcp3 (3 downto 0)   => tlxc_tlxt_avail_dcp3 (3 downto 0)  , -- MSR: cb_tlxt_flit_arb_rlm(flit_arb)
    tlxc_tlxt_avail_vc0 (3 downto 0)    => tlxc_tlxt_avail_vc0 (3 downto 0)   , -- MSR: cb_tlxt_flit_arb_rlm(flit_arb)
    tlxc_tlxt_avail_vc3 (3 downto 0)    => tlxc_tlxt_avail_vc3 (3 downto 0)   , -- MSR: cb_tlxt_flit_arb_rlm(flit_arb)
    tlxc_tlxt_crd_ret_val               => tlxc_tlxt_crd_ret_val              , -- MSR: cb_tlxt_flit_arb_rlm(flit_arb)
    tlxc_tlxt_dcp1_credits (5 downto 0) => tlxc_tlxt_dcp1_credits (5 downto 0), -- MSR: cb_tlxt_flit_arb_rlm(flit_arb)
    tlxc_tlxt_vc0_credits (3 downto 0)  => tlxc_tlxt_vc0_credits (3 downto 0) , -- MSR: cb_tlxt_flit_arb_rlm(flit_arb)
    tlxc_tlxt_vc1_credits (3 downto 0)  => tlxc_tlxt_vc1_credits (3 downto 0) , -- MSR: cb_tlxt_flit_arb_rlm(flit_arb)
    tlxc_tlxt_dcp1_credits_p            => tlxc_tlxt_dcp1_credits_p           , -- MSR: cb_tlxt_flit_arb_rlm(flit_arb)
    tlxc_tlxt_vc0_credits_p             => tlxc_tlxt_vc0_credits_p            , -- MSR: cb_tlxt_flit_arb_rlm(flit_arb)
    tlxc_tlxt_vc1_credits_p             => tlxc_tlxt_vc1_credits_p            , -- MSR: cb_tlxt_flit_arb_rlm(flit_arb)
    mmio_resp_ack                       => mmio_resp_ack                      , -- MSD: cb_tlxt_flit_arb_rlm(flit_arb)
    tlxt_intrp_handle_0                 => tlxt_intrp_handle_0                , -- MSR: cb_tlxt_flit_arb_rlm(flit_arb)
    tlxt_intrp_handle_1                 => tlxt_intrp_handle_1                , -- MSR: cb_tlxt_flit_arb_rlm(flit_arb)
    tlxt_intrp_handle_2                 => tlxt_intrp_handle_2                , -- MSR: cb_tlxt_flit_arb_rlm(flit_arb)
    tlxt_intrp_handle_3                 => tlxt_intrp_handle_3                , -- MSR: cb_tlxt_flit_arb_rlm(flit_arb)
    tlxt_err_invalid_meta_cfg           => tlxt_err_invalid_meta_cfg          , -- MSD: cb_tlxt_flit_arb_rlm(flit_arb)
    tlxt_err_invalid_tmpl_cfg           => tlxt_err_invalid_tmpl_cfg          , -- MSD: cb_tlxt_flit_arb_rlm(flit_arb)
    tlxt_err_invalid_cfg                => tlxt_err_invalid_cfg               , -- MSD: cb_tlxt_flit_arb_rlm(flit_arb)
    tlxt_err_invalid_crd_ret            => tlxt_err_invalid_crd_ret           , -- MSD: cb_tlxt_flit_arb_rlm(flit_arb)
    tlxt_err_dropped_crd_ret            => tlxt_err_dropped_crd_ret           , -- MSD: cb_tlxt_flit_arb_rlm(flit_arb)
    tlxt_err_fifo_UE (0 to 4)       => tlxt_err_fifo_UE (0 to 4)      , -- MSD: cb_tlxt_flit_arb_rlm(flit_arb)
    tlxt_err_fifo_CE                    => tlxt_err_fifo_CE                   , -- MSD: cb_tlxt_flit_arb_rlm(flit_arb)
    intrp_req_failed                    => intrp_req_failed                   , -- MSD: cb_tlxt_flit_arb_rlm(flit_arb)
    intrp_req_sm_perr (0 to 3)             => intrp_req_sm_perr  (0 to 3)                 , -- MSD: cb_tlxt_flit_arb_rlm(flit_arb)
    unexp_intrp_resp                    => unexp_intrp_resp                   , -- MSD: cb_tlxt_flit_arb_rlm(flit_arb)
    tlxt_clk_gate_dis                   => tlxt_clk_gate_dis                  ,
    tlxt_err_bdi_poisoned               => tlxt_err_bdi_poisoned              , -- MSD: cb_tlxt_flit_arb_rlm(flit_arb)
    tlxt_fifo_overflow (0 to 4)         => tlxt_fifo_overflow (0 to 4)        , -- MSD: cb_tlxt_flit_arb_rlm(flit_arb)
    tlxt_fifo_underflow (0 to 4)        => tlxt_fifo_underflow (0 to 4)       , -- MSD: cb_tlxt_flit_arb_rlm(flit_arb)
    tlxt_fifo_ptr_perr (0 to 4)         => tlxt_fifo_ptr_perr (0 to 4)         , -- MSD: cb_tlxt_flit_arb_rlm(flit_arb)
    tlxt_srq_rdbuf_pop                  => tlxt_srq_rdbuf_pop_int             , -- OVR: cb_tlxt_flit_arb_rlm(flit_arb)
    tlxt_tlxc_consume_dcp0 (3 downto 0) => tlxt_tlxc_consume_dcp0 (3 downto 0), -- MSD: cb_tlxt_flit_arb_rlm(flit_arb)
    tlxt_tlxc_consume_dcp3 (3 downto 0) => tlxt_tlxc_consume_dcp3 (3 downto 0), -- MSD: cb_tlxt_flit_arb_rlm(flit_arb)
    tlxt_tlxc_consume_val               => tlxt_tlxc_consume_val              , -- MSD: cb_tlxt_flit_arb_rlm(flit_arb)
    tlxt_tlxc_consume_vc0 (3 downto 0)  => tlxt_tlxc_consume_vc0 (3 downto 0) , -- MSD: cb_tlxt_flit_arb_rlm(flit_arb)
    tlxt_tlxc_consume_vc3 (3 downto 0)  => tlxt_tlxc_consume_vc3 (3 downto 0) , -- MSD: cb_tlxt_flit_arb_rlm(flit_arb)
    tlxt_tlxc_crd_ret_taken             => tlxt_tlxc_crd_ret_taken            , -- MSD: cb_tlxt_flit_arb_rlm(flit_arb)
    tlxt_tlxr_wr_resp_full              => wr_resp_fifo_full                       , -- MSD: cb_tlxt_flit_arb_rlm(flit_arb)
    tmpl_config (11 downto 0)            => cfg_otl0_tl_xmt_tmpl_config (11 downto 0)           , -- MSR: cb_tlxt_flit_arb_rlm(flit_arb)
    xmit_rate_config (47 downto 0)      => cfg_otl0_tl_xmt_rate_tmpl_config(47 downto 0)      , -- MSR: cb_tlxt_flit_arb_rlm(flit_arb)
    vdd                                 => vdd                                , -- MSB: cb_tlxt_flit_arb_rlm(flit_arb)
    wr_resp (20 downto 0)               => wr_resp (20 downto 0)              , -- MSR: cb_tlxt_flit_arb_rlm(flit_arb)
    wr_resp_val                         => wr_resp_val                        , -- MSR: cb_tlxt_flit_arb_rlm(flit_arb)
    hi_bw_threshold (2 downto 0)        => hi_bw_threshold (2 downto 0)       , -- MSR: cb_tlxt_flit_arb_rlm(flit_arb)
    mid_bw_threshold (2 downto 0)       => mid_bw_threshold (2 downto 0)      , -- MSR: cb_tlxt_flit_arb_rlm(flit_arb)
    hi_bw_dis                           => hi_bw_dis                          , -- MSR: cb_tlxt_flit_arb_rlm(flit_arb)
    mid_bw_enab                         => mid_bw_enab                        , -- MSR: cb_tlxt_flit_arb_rlm(flit_arb)
    hi_bw_enab_rd_thresh                => hi_bw_enab_rd_thresh               , -- MSR: cb_tlxt_flit_arb_rlm(flit_arb)
    low_lat_mode                        => low_lat_mode                       , -- MSR: cb_tlxt_flit_arb_rlm(flit_arb)
    flit_arb_perrors(0 to 8)            => flit_arb_perrors(0 to 8)           , -- MSD: cb_tlxt_flit_arb_rlm(flit_arb)
    flit_arb_debug_bus                  => flit_arb_debug_bus(0 to 87)        , -- MSD: cb_tlxt_flit_arb_rlm(flit_arb)
    flit_arb_debug_fedc                 => flit_arb_debug_fedc(0 to 27)       , -- MSD: cb_tlxt_flit_arb_rlm(flit_arb)
    xstop_rd_gate                       => xstop_rd_gate              
);

  tlxt_regs: entity work.cb_tlxt_regs
    PORT MAP (
      gckn => gckn,                     -- [IN  STD_ULOGIC]
      syncr => syncr                             , --

      scom_tlx_sat_id => scom_tlx_sat_id,  -- [in  std_ulogic_vector(0 to 1) := "00"] Satellite id

      tcm_tlxt_scom_cch => tcm_tlxt_scom_cch,  -- [IN  STD_ULOGIC] SCOM address port to tlxt
      tlxt_tcm_scom_cch => tlxt_tcm_scom_cch,  -- [OUT STD_ULOGIC] SCOM address port from tlxt

      tcm_tlxt_scom_dch => tcm_tlxt_scom_dch,  -- [IN  STD_ULOGIC] SCOM data port to tlxt
      tlxt_tcm_scom_dch => tlxt_tcm_scom_dch,  -- [OUT STD_ULOGIC] SCOM data port from tlxt

      tlx_xstop_err   => tlx_xstop_err,    -- [OUT std_ulogic] checkstop   output to Global FIR
      tlx_recov_err   => tlx_recov_err,    -- [OUT std_ulogic] recoverable output to Global FIR
      tlx_recov_int   => tlx_recov_int,    -- [OUT std_ulogic] recoverable interrupt output to Global FIR
      tlx_mchk_out    => tlx_mchk_out,     -- [OUT std_ulogic] used only if implement_mchk=true
      tlx_trace_error => tlx_trace_error,  -- [OUT std_ulogic] error to connect to error_input of closest trdata macro
      tlx_fir_out     => tlx_fir_out,      -- [OUT std_ulogic_vector(0 to 27)] output of current FIR state if needed

      tlxc_crd_cfg_reg    => tlxc_crd_cfg_reg,     -- [OUT STD_ULOGIC_VECTOR(0 TO 63)]
      tlxc_wat_en_reg     => tlxc_wat_en_reg ,
      tlxc_crd_status_reg => tlxc_crd_status_reg,  -- [IN  STD_ULOGIC_VECTOR(0 TO 127)]

      tlxt_tlxr_early_wdone_disable => tlxt_tlxr_early_wdone_disable, --: OUT STD_ULOGIC;
      tlxt_tlxr_ctrl => tlxt_tlxr_ctrl, --: OUT STD_ULOGIC_VECTOR(0 to 15);
      tlxc_tlxt_ctrl => tlxc_tlxt_ctrl, --: OUT STD_ULOGIC_VECTOR(0 to 15);
      xstop_rd_gate_dis => xstop_rd_gate_dis, 

      tlxt_debug_bus => tlxt_debug_bus,  -- [in std_ulogic_vector(0 to 87)]
      tlxt_dbg_mode => tlxt_dbg_mode,  -- [out std_ulogic_vector(0 to 15)]

      tlxt_intrp_cmdflag_0      => tlxt_intrp_cmdflag_0, --     : out STD_ULOGIC_VECTOR(0 to 3);
      tlxt_intrp_cmdflag_1      => tlxt_intrp_cmdflag_1, --     : out STD_ULOGIC_VECTOR(0 to 3);
      tlxt_intrp_cmdflag_2      => tlxt_intrp_cmdflag_2, --     : out STD_ULOGIC_VECTOR(0 to 3);
      tlxt_intrp_cmdflag_3      => tlxt_intrp_cmdflag_3, --     : out STD_ULOGIC_VECTOR(0 to 3);
      tlxt_intrp_handle_0       => tlxt_intrp_handle_0, --     : out STD_ULOGIC_VECTOR(0 to 63);
      tlxt_intrp_handle_1       => tlxt_intrp_handle_1, --     : out STD_ULOGIC_VECTOR(0 to 63);
      tlxt_intrp_handle_2       => tlxt_intrp_handle_2, --     : out STD_ULOGIC_VECTOR(0 to 63);
      tlxt_intrp_handle_3       => tlxt_intrp_handle_3, --     : out STD_ULOGIC_VECTOR(0 to 63);

      tlxt_errors      => tlxt_errors,       -- [IN  STD_ULOGIC_VECTOR(0 TO 31)]
      tlxt_perrors      => tlxt_perrors,       -- [IN  STD_ULOGIC_VECTOR(0 TO 32)]
      tlxr_tlxt_errors => tlxr_tlxt_errors,       -- [IN  STD_ULOGIC_VECTOR(0 TO 63)]
      tlxr_tlxt_signature_dat    => tlxr_tlxt_signature_dat, --    : IN std_ulogic_vector(0 TO 63);
      tlxr_tlxt_signature_strobe => tlxr_tlxt_signature_strobe, --    : IN std_ulogic;
      tlxc_errors         => tlxc_errors,       -- [IN  STD_ULOGIC_VECTOR(0 TO 15)]
      tlxc_perrors        => tlxc_perrors,         -- [out std_ulogic_vector(0 to 7)]
      intrp_req_sm_perr      => intrp_req_sm_perr,

      gnd => gnd,                       -- [INOUT power_logic]
      vdd => vdd);                      -- [INOUT power_logic]

  dbg: entity work.cb_tlxt_dbg
    PORT MAP (
      gckn  => gckn,                    -- [in  std_ulogic]
      gnd   => gnd,                     -- [inout power_logic]
      vdd   => vdd,                     -- [inout power_logic]
      syncr => syncr,                   -- [in  std_ulogic]

      tlxt_debug_bus => tlxt_debug_bus,  -- [out std_ulogic_vector(0 to 87)]

      tlxt_dbg_a_debug_bus => tlxt_dbg_a_debug_bus,  -- [in  std_ulogic_vector(0 to 87)]
      tlxt_dbg_b_debug_bus => tlxt_dbg_b_debug_bus,  -- [in  std_ulogic_vector(0 to 87)]
      tlxt_dbg_c_debug_bus => tlxt_dbg_c_debug_bus,  -- [in  std_ulogic_vector(0 to 87)]
      tlxt_dbg_d_debug_bus => tlxt_dbg_d_debug_bus,  -- [in  std_ulogic_vector(0 to 87)]

      tlxt_dbg_mode => tlxt_dbg_mode);  -- [in std_ulogic_vector(0 to 15)]

cfg_half_dimm_modeq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(cfg_half_dimm_mode_d),
           Tconv(q)             => cfg_half_dimm_mode_q);
global_fir_chan_xstopq: entity latches.c_morph_dff
   generic map (width => 1, offset => 0)
   port map(gckn                 => gckn,
            e                    => act,
            vdd                  => vdd,
            vss                  => gnd,
            d                    => Tconv(global_fir_chan_xstop_d),
            Tconv(q)             => global_fir_chan_xstop_q);

 global_fir_rec_attnq: entity latches.c_morph_dff
   generic map (width => 1, offset => 0)
   port map(gckn                 => gckn,
            e                    => act,
            vdd                  => vdd,
            vss                  => gnd,
            d                    => Tconv(global_fir_rec_attn_d),
            Tconv(q)             => global_fir_rec_attn_q);

global_fir_sp_attnq: entity latches.c_morph_dff
   generic map (width => 1, offset => 0)
   port map(gckn                 => gckn,
            e                    => act,
            vdd                  => vdd,
            vss                  => gnd,
            d                    => Tconv(global_fir_sp_attn_d),
            Tconv(q)             => global_fir_sp_attn_q);

global_fir_mchkq: entity latches.c_morph_dff
   generic map (width => 1, offset => 0)
   port map(gckn                 => gckn,
            e                    => act,
            vdd                  => vdd,
            vss                  => gnd,
            d                    => Tconv(global_fir_mchk_d),
            Tconv(q)             => global_fir_mchk_q);

link_upq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(link_up_d),
           syncr                => syncr,
           Tconv(q)             => link_up_q);

low_lat_modeq: entity latches.c_morph_dff
   generic map (width => 1, offset => 0)
   port map(gckn                 => gckn,
            e                    => act,
            vdd                  => vdd,
            vss                  => gnd,
            d                    => Tconv(low_lat_mode_d),
            Tconv(q)             => low_lat_mode_q);

mmio_data_par_errq: entity latches.c_morph_dff
   generic map (width => 1, offset => 0)
   port map(gckn                 => gckn,
            e                    => act,
            vdd                  => vdd,
            vss                  => gnd,
            d                    => Tconv(mmio_data_par_err_d),
            Tconv(q)             => mmio_data_par_err_q);

mmio_tlxt_resp_validq: entity latches.c_morph_dff
   generic map (width => 1, offset => 0)
   port map(gckn                 => gckn,
            e                    => act,
            vdd                  => vdd,
            vss                  => gnd,
            d                    => Tconv(mmio_tlxt_resp_valid_d),
            Tconv(q)             => mmio_tlxt_resp_valid_q);

tlxt_srq_padmem_done_ackq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(tlxt_srq_padmem_done_ack_d),
           Tconv(q)             => tlxt_srq_padmem_done_ack_q);

tlxt_errorsq: entity latches.c_morph_dff
  generic map (width => 33, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => tlxt_errors_d(0 to 32),
           q                    => tlxt_errors_q(0 to 32));

end cb_tlxt_mac;
