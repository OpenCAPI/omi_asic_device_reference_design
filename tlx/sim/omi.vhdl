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


library latches,ieee,ibm,support,stdcell;
use ibm.synthesis_support.all;
use ieee.std_logic_1164.all;
use support.logic_support_pkg.all;
use support.power_logic_pkg.all;

entity omi is
  port (
    gnd                            : inout power_logic;
    vdd                            : inout power_logic;
    gck                            : in std_ulogic;
    pclk                           : in std_ulogic;
    sync_reset_gck_out             : out std_ulogic;
    sync_reset_pclk_out            : out std_ulogic;
    test_clk_1                     : in std_ulogic;
    testclk_selb                   : in std_ulogic;
    scanb                          : in std_ulogic;
    sw_reset                       : in std_ulogic;
    sw_reset_clock_divider         : in std_ulogic;
    async_resetb                   : in std_ulogic;
    fuse_enterprise_dis            : in std_ulogic;

    ---------------------------------------------------------------------------
    -- Pervasive --------------------------------------------------------------
    ---------------------------------------------------------------------------

    -- DLX
    dlx_tc_fir_recov_err           : in std_ulogic;
    dlx_tc_fir_xstop_err           : in std_ulogic;
    dlx_tc_fir_spec_attn           : in std_ulogic;
    dlx_tc_fir_mchk                : in std_ulogic;
    dlx_tc_fir_trace_err           : in std_ulogic;
    dlx_tc_scom_cch                : in std_ulogic;
    dlx_tc_scom_dch                : in std_ulogic;
    tc_dlx_scom_cch                : out std_ulogic;
    tc_dlx_scom_dch                : out std_ulogic;

    --GIF Master Side Interface (Attaches to GIF2AXI)
    pib2gif_maddr                  : out std_ulogic_vector(31 downto 0);
    pib2gif_mburst                 : out std_ulogic_vector(1 downto 0);
    pib2gif_mcache                 : out std_ulogic_vector(3 downto 0);
    pib2gif_mdata                  : out std_ulogic_vector(31 downto 0);
    pib2gif_mid                    : out std_ulogic_vector(4 downto 0);
    pib2gif_mlast                  : out std_ulogic;
    pib2gif_mlen                   : out std_ulogic_vector(3 downto 0);
    pib2gif_mlock                  : out std_ulogic;
    pib2gif_mprot                  : out std_ulogic_vector(2 downto 0);
    pib2gif_mread                  : out std_ulogic;
    pib2gif_mready                 : out std_ulogic;
    pib2gif_msize                  : out std_ulogic_vector(2 downto 0);
    pib2gif_mwrite                 : out std_ulogic;
    pib2gif_mwstrb                 : out std_ulogic_vector(3 downto 0);
    pib2gif_saccept                : in std_ulogic;
    pib2gif_sdata                  : in std_ulogic_vector(31 downto 0);
    pib2gif_sid                    : in std_ulogic_vector(4 downto 0);
    pib2gif_slast                  : in std_ulogic;
    pib2gif_sresp                  : in std_ulogic_vector(2 downto 0);
    pib2gif_svalid                 : in std_ulogic;
    pib2gif_masideband             : out std_ulogic;
    pib2gif_mwsideband             : out std_ulogic_vector(3 downto 0);
    pib2gif_srsideband             : in std_ulogic_vector(3 downto 0);

   --GIF Slave Side Interface (Attaches to AXI2GIF)
    gif2pcb_maddr                  : in std_ulogic_vector(31 downto 0);
    gif2pcb_mburst                 : in std_ulogic_vector(1 downto 0);
    gif2pcb_mdata                  : in std_ulogic_vector(31 downto 0);
    gif2pcb_mlast                  : in std_ulogic;
    gif2pcb_mlen                   : in std_ulogic_vector(3 downto 0);
    gif2pcb_mread                  : in std_ulogic;
    gif2pcb_mready                 : in std_ulogic;
    gif2pcb_msize                  : in std_ulogic_vector(2 downto 0);
    gif2pcb_mwrite                 : in std_ulogic;
    gif2pcb_mwstrb                 : in std_ulogic_vector(3 downto 0);
    gif2pcb_saccept                : out std_ulogic;

    gif2pcb_sdata                  : out std_ulogic_vector(31 downto 0);
    gif2pcb_slast                  : out std_ulogic;
    gif2pcb_sresp                  : out std_ulogic_vector(1 downto 0);
    gif2pcb_svalid                 : out std_ulogic;
    gif2pcb_masideband             : in  std_ulogic;
    gif2pcb_mwsideband             : in  std_ulogic_vector(3 downto 0);
    gif2pcb_srsideband             : out std_ulogic_vector(3 downto 0);

    --IBM/Microsemi Sideband signals
    gpbc_to_mb_top_error_info      : in std_ulogic_vector(52 downto 0);
    mb_top_to_gpbc_error_info      : out std_ulogic_vector(15 downto 0);

    ---------------------------------------------------------------------------
    -- DFI --------------------------------------------------------------------
    ---------------------------------------------------------------------------
    -- DFI Control
    dfi_reset_n                    : out std_ulogic;
    dfi_act_n_a                    : out std_ulogic;
    dfi_address_a                  : out std_ulogic_vector(0 to 17);
    dfi_bank_a                     : out std_ulogic_vector(0 to 1);
    dfi_bg_a                       : out std_ulogic_vector(0 to 1);
    dfi_cas_n_a                    : out std_ulogic;
    dfi_cid_a                      : out std_ulogic_vector(0 to 1);
    dfi_cke_a                      : out std_ulogic_vector(0 to 1);
    dfi_cs_n_a                     : out std_ulogic_vector(0 to 1);
    dfi_odt_a                      : out std_ulogic_vector(0 to 1);
    dfi_ras_n_a                    : out std_ulogic;
    dfi_we_n_a                     : out std_ulogic;
    dfi_act_n_b                    : out std_ulogic;
    dfi_address_b                  : out std_ulogic_vector(0 to 17);
    dfi_bank_b                     : out std_ulogic_vector(0 to 1);
    dfi_bg_b                       : out std_ulogic_vector(0 to 1);
    dfi_cas_n_b                    : out std_ulogic;
    dfi_cid_b                      : out std_ulogic_vector(0 to 1);
    dfi_cke_b                      : out std_ulogic_vector(0 to 1);
    dfi_cs_n_b                     : out std_ulogic_vector(0 to 1);
    dfi_odt_b                      : out std_ulogic_vector(0 to 1);
    dfi_ras_n_b                    : out std_ulogic;
    dfi_we_n_b                     : out std_ulogic;

    -- DFI Write Data
    dfi_wrdata                     : out std_ulogic_vector(0 to 159);
    dfi_wrdata_cs_n                : out std_ulogic_vector(0 to 39);
    dfi_wrdata_en                  : out std_ulogic_vector(0 to 9);

    -- DFI Read Data
    dfi_rddata                     : in std_ulogic_vector(0 to 159);
    dfi_rddata_cs_n                : out std_ulogic_vector(0 to 39);
    dfi_rddata_en                  : out std_ulogic_vector(0 to 9);
    dfi_rddata_valid               : in std_ulogic_vector(0 to 9);

    -- DFI Update
    dfi_ctrlupd_ack                : in std_ulogic;
    dfi_ctrlupd_req                : out std_ulogic;

    -- DFI Status
    dfi_alert_n                    : in std_ulogic;
    dfi_dram_clk_disable_a         : out std_ulogic_vector(0 to 1);
    dfi_dram_clk_disable_b         : out std_ulogic_vector(0 to 1);
    dfi_freq                       : out std_ulogic_vector(0 to 4);
    dfi_init_complete              : in std_ulogic;
    dfi_init_start                 : out std_ulogic;
    dfi_parity_in_a                : out std_ulogic;
    dfi_parity_in_b                : out std_ulogic;

    -- DFI Low Power
    dfi_lp_ack                     : in std_ulogic;
    dfi_lp_ctrl_req                : out std_ulogic;
    dfi_lp_data_req                : out std_ulogic;
    dfi_lp_wakeup                  : out std_ulogic_vector(0 to 3);

    -- DQ Bypass for NTTM
    dqbypass                       : in std_ulogic_vector(0 to 79);

    -- DFI spare
    spare_input_acx4_a             : out std_ulogic_vector(0 to 3);
    spare_output_acx4_a            : in  std_ulogic_vector(0 to 3);
    spare_input_acx4_b             : out std_ulogic_vector(0 to 3);
    spare_output_acx4_b            : in  std_ulogic_vector(0 to 3);
    spare_input_dbyte              : out std_ulogic_vector(0 to 9);
    spare_output_dbyte             : in  std_ulogic_vector(0 to 9);
    spare_input_pub                : out std_ulogic_vector(0 to 3);
    spare_output_pub               : in  std_ulogic_vector(0 to 3);

    ---------------------------------------------------------------------------
    -- DLX / TLX --------------------------------------------------------------
    ---------------------------------------------------------------------------
    -- DLX to TLX
    dlx_tlxr_flit_vld              : in std_ulogic;
    dlx_tlxr_flit_error            : in std_ulogic;
    dlx_tlxr_flit_data             : in std_ulogic_vector(127 downto 0);
    dlx_tlxr_flit_pty              : in std_ulogic_vector(15 downto 0);
    dlx_tlxt_flit_credit           : in std_ulogic;
    dlx_tlxr_link_up               : in std_ulogic;
    dlx_tlxt_lane_width_status     : in std_ulogic_vector(1 downto 0);
    dlx_tlxr_fast_act_info_l   : in std_ulogic_vector(34 downto 0);
    dlx_tlxr_idle_transition_l : in std_ulogic;
    dlx_tlxr_fast_act_info_r   : in std_ulogic_vector(34 downto 0);
    dlx_tlxr_idle_transition_r : in std_ulogic;
    dlx_tlxr_fast_act_info   : in std_ulogic_vector(34 downto 0);
    dlx_tlxr_idle_transition : in std_ulogic;

    -- TLX to DLX
    tlxt_dlx_flit_early_vld        : out std_ulogic;
    tlxt_dlx_flit_vld              : out std_ulogic;
    tlxt_dlx_flit_data             : out std_ulogic_vector(127 downto 0);
    tlxt_dlx_flit_ecc              : out std_ulogic_vector(15 downto 0);
    tlxt_dlx_flit_lbip_vld         : out std_ulogic;
    tlxt_dlx_flit_lbip_data        : out std_ulogic_vector(81 downto 0);
    tlxt_dlx_tl_error              : out std_ulogic;
    tlxt_dlx_tl_event              : out std_ulogic;

    -- Other DLX
    dlx_dbg_debug_bus              : in std_ulogic_vector(0 to 87);

    ---------------------------------------------------------------------------
    -- Miscellaneous
    ---------------------------------------------------------------------------
    c4_eventn                      : in std_ulogic;
    c4_epow                        : in std_ulogic;
    c4_saven                       : out std_ulogic
  );


end omi;

architecture omi of omi is

  SIGNAL tc_mmio_mips_itr : std_ulogic;
  SIGNAL fuse_enterprise_dis_b : std_ulogic;
  SIGNAL cfg_enterprise_mode : std_ulogic;
  SIGNAL tp_unused : std_ulogic_vector(0 to 20);
  SIGNAL tc_tlx_scom_cch : std_ulogic;
  SIGNAL tc_tlx_scom_dch : std_ulogic;
  SIGNAL tlx_tc_fir_recov_err : std_ulogic;
  SIGNAL tlx_tc_fir_xstop_err : std_ulogic;
  SIGNAL tlx_tc_scom_cch : std_ulogic;
  SIGNAL tlx_tc_scom_dch : std_ulogic;
  SIGNAL mcbist_tc_fir_recov_err : std_ulogic;
  SIGNAL mcbist_tc_fir_xstop_err : std_ulogic;
  SIGNAL mcbist_tc_fir_spec_attn : std_ulogic;
  SIGNAL mcb_tc_fir_mchk : std_ulogic;
  SIGNAL mcbist_tc_scom_cch : std_ulogic;
  SIGNAL mcbist_scom_cch_out : std_ulogic;
  SIGNAL mcbist_tc_scom_dch : std_ulogic;
  SIGNAL mcbist_scom_dch_out : std_ulogic;
  SIGNAL mcbist_scom_cch_in : std_ulogic;
  SIGNAL tc_mcbist_scom_cch : std_ulogic;
  SIGNAL mcbist_scom_dch_in : std_ulogic;
  SIGNAL tc_mcbist_scom_dch : std_ulogic;
  SIGNAL mmio_tc_fir_recov_err : std_ulogic;
  SIGNAL mmio_tc_fir_xstop_err : std_ulogic;
  SIGNAL mmio_tc_fir_trace_err : std_ulogic;
  SIGNAL mmio_tc_fir_spec_attn : std_ulogic;
  SIGNAL mmio_tc_fir_mchk_out : std_ulogic;
  SIGNAL mmio_enterprise_mode : std_ulogic;
  SIGNAL mmio_half_dimm_mode : std_ulogic;
  SIGNAL mmio_tp_cmd_int : std_ulogic;
  SIGNAL tp_mmio_mips_int : std_ulogic;
  SIGNAL mmio_tc_scom_cch : std_ulogic;
  SIGNAL mmio_scom_cch_out : std_ulogic;
  SIGNAL mmio_tc_scom_dch : std_ulogic;
  SIGNAL mmio_scom_dch_out : std_ulogic;
  SIGNAL scom_mmio_cch_in : std_ulogic;
  SIGNAL tc_mmio_scom_cch : std_ulogic;
  SIGNAL scom_mmio_dch_in : std_ulogic;
  SIGNAL tc_mmio_scom_dch : std_ulogic;
  SIGNAL rdf_tc_fir_attention : std_ulogic;
  SIGNAL rdf_tc_fir_mchk : std_ulogic;
  SIGNAL rdf_tc_fir_recov_err : std_ulogic;
  SIGNAL rdf_tc_fir_xstop_err : std_ulogic;
  SIGNAL rdf_tc_fir_trace_err : std_ulogic;
  SIGNAL rdf_tc_scom_cch : std_ulogic;
  SIGNAL rdf_tc_scom_dch : std_ulogic;
  SIGNAL tc_rdf_scom_cch : std_ulogic;
  SIGNAL tc_rdf_scom_dch : std_ulogic;
  SIGNAL srq_tc_fir_recov_err : std_ulogic;
  SIGNAL srq_tc_fir_xstop_err : std_ulogic;
  SIGNAL srq_tc_scom_cch : std_ulogic;
  SIGNAL srq_tcm_scom_cch : std_ulogic;
  SIGNAL srq_tc_scom_dch : std_ulogic;
  SIGNAL srq_tcm_scom_dch : std_ulogic;
  SIGNAL tcm_srq_scom_cch : std_ulogic;
  SIGNAL tc_srq_scom_cch : std_ulogic;
  SIGNAL tcm_srq_scom_dch : std_ulogic;
  SIGNAL tc_srq_scom_dch : std_ulogic;
  SIGNAL wdf_tc_fir_recov_err : std_ulogic;
  SIGNAL wdf_tc_fir_xstop_err : std_ulogic;
  SIGNAL wdf_tc_scom_cch : std_ulogic;
  SIGNAL wdf_scom_cch_out : std_ulogic;
  SIGNAL wdf_tc_scom_dch : std_ulogic;
  SIGNAL wdf_scom_dch_out : std_ulogic;
  SIGNAL scom_wdf_cch_in : std_ulogic;
  SIGNAL tc_wdf_scom_cch : std_ulogic;
  SIGNAL scom_wdf_dch_in : std_ulogic;
  SIGNAL tc_wdf_scom_dch : std_ulogic;
  SIGNAL mmio_pib_pibmst_req_addr : std_ulogic_vector(0 to 31);
  SIGNAL mmio_pib_pibmst_req_addr_p : std_ulogic_vector(0 to 1);
  SIGNAL mmio_pib_pibmst_req_arb : std_ulogic;
  SIGNAL mmio_pib_pibmst_req_ctrl : std_ulogic_vector(0 to 5);
  SIGNAL mmio_pib_pibmst_req_data : std_ulogic_vector(0 to 63);
  SIGNAL mmio_pib_pibmst_req_data_p : std_ulogic_vector(0 to 3);
  SIGNAL mmio_pib_pibmst_req_p : std_ulogic;
  SIGNAL mmio_pib_pibmst_rd_not_wr : std_ulogic;
  SIGNAL mmio_pib_pibmst_req_vld : std_ulogic;
  SIGNAL mmio_pib_pibmst_rsp_ack : std_ulogic;
  SIGNAL mmio_pib_pibmst_rst_request : std_ulogic;
  SIGNAL mmio_pib_pibmst_spare : std_ulogic_vector(0 to 1);
  SIGNAL pib_mmio_pibmst_req_ack : std_ulogic;
  SIGNAL pib_mmio_pibmst_req_grant : std_ulogic;
  SIGNAL pib_mmio_pibmst_rsp_ctrl : std_ulogic_vector(0 to 5);
  SIGNAL pib_mmio_pibmst_rsp_data : std_ulogic_vector(0 to 63);
  SIGNAL pib_mmio_pibmst_rsp_data_p : std_ulogic_vector(0 to 3);
  SIGNAL pib_mmio_pibmst_rsp_info : std_ulogic_vector(0 to 2);
  SIGNAL pib_mmio_pibmst_rsp_p : std_ulogic;
  SIGNAL pib_mmio_pibmst_rsp_vld : std_ulogic;
  SIGNAL pib_mmio_pibmst_rst : std_ulogic;
  SIGNAL pib_mmio_pibmst_spare : std_ulogic_vector(0 to 1);
  SIGNAL scom_wdf_sat_id : std_ulogic_vector(0 to 1);
  SIGNAL scom_mmio_sat_id : std_ulogic_vector(0 to 1);
  SIGNAL mmio_pib_master_id : std_ulogic_vector(0 to 3);
  SIGNAL srq_mcbcntl_debug_bus : std_ulogic_vector(0 to 87);
  SIGNAL ecc_noise_window_start : std_ulogic;
  SIGNAL pbi01_mcb_s_wat_event : std_ulogic_vector(0 to 3);
  SIGNAL dbg_srq_wat_event : std_ulogic_vector(0 to 3);
  SIGNAL dbg_tlxt_wat_event : std_ulogic_vector(0 to 3);
  SIGNAL dbg_tlxr_wat_event : std_ulogic_vector(0 to 3);
  SIGNAL dbg_rdf_wat_event : std_ulogic_vector(0 to 3);
  SIGNAL dbg_mmio_wat_event : std_ulogic_vector(0 to 3);
  SIGNAL dbg_wdf_wat_event : std_ulogic_vector(0 to 3);
  SIGNAL rdf_mcb_ecc_addr_valid : std_ulogic;
  SIGNAL rdf_mcb_ecc_bank : std_ulogic_vector(0 to 2);
  SIGNAL rdf_mcb_ecc_bank_group : std_ulogic_vector(0 to 1);
  SIGNAL rdf_mcb_ecc_col : std_ulogic_vector(2 to 9);
  SIGNAL rdf_mcb_ecc_data_req : std_ulogic;
  SIGNAL rdf_mcb_ecc_dimm : std_ulogic;
  SIGNAL rdf_mcb_ecc_error_type : std_ulogic_vector(0 to 3);
  SIGNAL rdf_mcb_ecc_error_vector : std_ulogic_vector(0 to 35);
  SIGNAL rdf_mcb_ecc_log_full : std_ulogic;
  SIGNAL rdf_mcb_ecc_log_write : std_ulogic;
  SIGNAL rdf_mcb_ecc_mrank : std_ulogic_vector(0 to 1);
  SIGNAL rdf_mcb_ecc_rce_error : std_ulogic;
  SIGNAL rdf_mcb_ecc_rdtag : std_ulogic_vector(0 to 6);
  SIGNAL rdf_mcb_ecc_read_val : std_ulogic;
  SIGNAL rdf_mcb_ecc_row : std_ulogic_vector(0 to 17);
  SIGNAL rdf_mcb_ecc_spare : std_ulogic_vector(0 to 2);
  SIGNAL rdf_mcb_ecc_srank : std_ulogic_vector(0 to 2);
  SIGNAL rdf_mcb_ecc_sue_error : std_ulogic;
  SIGNAL srq_ddra_dfi_actn : std_ulogic;
  SIGNAL srq_ddra_dfi_address : std_ulogic_vector(0 to 17);
  SIGNAL srq_ddra_dfi_bank : std_ulogic_vector(0 to 1);
  SIGNAL srq_ddra_dfi_bank_group : std_ulogic_vector(0 to 1);
  SIGNAL srq_ddra_dfi_chip_id : std_ulogic_vector(0 to 1);
  SIGNAL srq_ddra_dfi_cke : std_ulogic_vector(0 to 1);
  SIGNAL srq_ddra_dfi_csn : std_ulogic_vector(0 to 1);
  SIGNAL srq_ddra_dfi_odt : std_ulogic_vector(0 to 1);
  SIGNAL srq_ddra_dfi_par : std_ulogic;
  SIGNAL srq_ddrb_dfi_actn : std_ulogic;
  SIGNAL srq_ddrb_dfi_address : std_ulogic_vector(0 to 17);
  SIGNAL srq_ddrb_dfi_bank : std_ulogic_vector(0 to 1);
  SIGNAL srq_ddrb_dfi_bank_group : std_ulogic_vector(0 to 1);
  SIGNAL srq_ddrb_dfi_chip_id : std_ulogic_vector(0 to 1);
  SIGNAL srq_ddrb_dfi_cke : std_ulogic_vector(0 to 1);
  SIGNAL srq_ddrb_dfi_csn : std_ulogic_vector(0 to 1);
  SIGNAL srq_ddrb_dfi_odt : std_ulogic_vector(0 to 1);
  SIGNAL srq_ddrb_dfi_par : std_ulogic;
  SIGNAL srq_ddr_resetn : std_ulogic;
  SIGNAL wdf_dfi_wdat : std_ulogic_vector(0 to 159);
  SIGNAL ddr_srq_errn : std_ulogic;
  SIGNAL cal_ccs_cal_req_ack : std_ulogic;
  SIGNAL cal_ccs_cal_req_done : std_ulogic;
  SIGNAL ccs_cal_cal_dfi_rank : std_ulogic_vector(0 to 3);
  SIGNAL ccs_cal_cal_req : std_ulogic;
  SIGNAL ccs_cal_cal_req_type : std_ulogic_vector(0 to 3);
  SIGNAL ccs_farb_port_fail : std_ulogic;
  SIGNAL cfg_f1_csh_memory_space : std_ulogic;
  SIGNAL cfg_f1_csh_mmio_bar0 : std_ulogic_vector(63 downto 35);
  SIGNAL cfg_f1_csh_p : std_ulogic;
  SIGNAL cfg_f1_octrl00_enable_afu : std_ulogic;
  SIGNAL cfg_f1_octrl00_metadata_enabled : std_ulogic;
  SIGNAL cfg_f1_octrl00_p : std_ulogic;
  SIGNAL cfg_f1_octrl00_pasid_base : std_ulogic_vector(20 downto 0);
  SIGNAL cfg_f1_octrl00_pasid_length_enabled : std_ulogic_vector(5 downto 0);
  SIGNAL cfg_f1_ofunc_func_actag_base : std_ulogic_vector(12 downto 0);
  SIGNAL cfg_f1_ofunc_func_actag_len_enab : std_ulogic_vector(12 downto 0);
  SIGNAL cfg_f1_octrl00_afu_actag_base : std_ulogic_vector(12 downto 0);
  SIGNAL cfg_f1_octrl00_afu_actag_len_enab : std_ulogic_vector(12 downto 0);
  SIGNAL cfg_otl0_tl_minor_vers_config : std_ulogic;
  SIGNAL cfg_otl0_tl_minor_vers_config_p : std_ulogic;
  SIGNAL cfg_otl0_tl_xmt_rate_tmpl_config : std_ulogic_vector(48 downto 0);
  SIGNAL cfg_otl0_tl_xmt_tmpl_config : std_ulogic_vector(12 downto 0);
  SIGNAL cfg_otl0_long_backoff_timer : std_ulogic_vector(3 downto 0);
  SIGNAL cfg_srq_ack : std_ulogic;
  SIGNAL farb_ccs_cmd_err : std_ulogic;
  SIGNAL mcb_pbi_s_wat_event : std_ulogic_vector(0 to 3);
  SIGNAL mcb_rdf_ecc_cmp_data : std_ulogic_vector(0 to 159);
  SIGNAL mcb_rdf_ecc_ddr4e_blind_steer_mode : std_ulogic;
  SIGNAL mcb_rdf_ecc_err_log_reset : std_ulogic;
  SIGNAL mcb_rdf_ecc_mcbist_wont_retry : std_ulogic;
  SIGNAL mcb_rdf_ecc_subtest_number : std_ulogic_vector(0 to 4);
  SIGNAL mcb_rdf_ecc_trap_cnfg_reset : std_ulogic;
  SIGNAL mcb_rq_stg_act : std_ulogic;
  SIGNAL mcb_srq_ccs_dfi_actn : std_ulogic;
  SIGNAL mcb_srq_ccs_dfi_address : std_ulogic_vector(0 to 17);
  SIGNAL mcb_srq_ccs_dfi_bank : std_ulogic_vector(0 to 2);
  SIGNAL mcb_srq_ccs_dfi_bank_group : std_ulogic_vector(0 to 1);
  SIGNAL mcb_srq_ccs_dfi_chip_id : std_ulogic_vector(0 to 2);
  SIGNAL mcb_srq_ccs_dfi_cke : std_ulogic_vector(0 to 3);
  SIGNAL mcb_srq_ccs_dfi_csn : std_ulogic_vector(0 to 3);
  SIGNAL mcb_srq_ccs_dfi_odt : std_ulogic_vector(0 to 3);
  SIGNAL mcb_srq_ccs_dfi_par_in : std_ulogic;
  SIGNAL mcb_srq_ccs_ip : std_ulogic;
  SIGNAL mcb_srq_ccs_ip_p : std_ulogic;
  SIGNAL mcb_srq_ccs_resetn : std_ulogic;
  SIGNAL mcb_srq_cmd : std_ulogic_vector(0 to 63);
  SIGNAL mcb_srq_cmd_req : std_ulogic;
  SIGNAL mcb_srq_nttm_bypass_en : std_ulogic;
  SIGNAL mcb_srq_nttm_rd_start : std_ulogic;
  SIGNAL mcb_srq_nttm_wr_start : std_ulogic;
  signal mcb_srq_pda_write : std_ulogic;    
  SIGNAL mcb_srq_slot0_valid : std_ulogic;
  SIGNAL mcb_srq_slot0_num_mranks : std_ulogic_vector(0 to 1);
  SIGNAL mcb_srq_slot0_num_sranks : std_ulogic_vector(0 to 1);
  SIGNAL mcb_srq_slot1_valid : std_ulogic;
  SIGNAL mcb_srq_slot1_num_mranks : std_ulogic_vector(0 to 1);
  SIGNAL mcb_srq_slot1_num_sranks : std_ulogic_vector(0 to 1);
  SIGNAL mcb_srq_rmw_abort : std_ulogic;
  SIGNAL mcb_srq_rmw_go : std_ulogic;
  SIGNAL mcb_tlxr_enab_row_addr_hash : std_ulogic;
  SIGNAL mcb_tlxr_xlt_b0_bit_map : std_ulogic_vector(0 to 4);
  SIGNAL mcb_tlxr_xlt_b1_bit_map : std_ulogic_vector(0 to 4);
  SIGNAL mcb_tlxr_xlt_bg0_bit_map : std_ulogic_vector(0 to 4);
  SIGNAL mcb_tlxr_xlt_bg1_bit_map : std_ulogic_vector(0 to 4);
  SIGNAL mcb_tlxr_xlt_c3_bit_map : std_ulogic_vector(0 to 4);
  SIGNAL mcb_tlxr_xlt_c4_bit_map : std_ulogic_vector(0 to 4);
  SIGNAL mcb_tlxr_xlt_c5_bit_map : std_ulogic_vector(0 to 4);
  SIGNAL mcb_tlxr_xlt_c6_bit_map : std_ulogic_vector(0 to 4);
  SIGNAL mcb_tlxr_xlt_c7_bit_map : std_ulogic_vector(0 to 4);
  SIGNAL mcb_tlxr_xlt_c8_bit_map : std_ulogic_vector(0 to 4);
  SIGNAL mcb_tlxr_xlt_c9_bit_map : std_ulogic_vector(0 to 4);
  SIGNAL mcb_tlxr_xlt_d_bit_map : std_ulogic_vector(0 to 4);
  SIGNAL mcb_tlxr_xlt_m0_bit_map : std_ulogic_vector(0 to 4);
  SIGNAL mcb_tlxr_xlt_m1_bit_map : std_ulogic_vector(0 to 4);
  SIGNAL mcb_tlxr_xlt_r15_bit_map : std_ulogic_vector(0 to 4);
  SIGNAL mcb_tlxr_xlt_r16_bit_map : std_ulogic_vector(0 to 4);
  SIGNAL mcb_tlxr_xlt_r17_bit_map : std_ulogic_vector(0 to 4);
  SIGNAL mcb_tlxr_xlt_s0_bit_map : std_ulogic_vector(0 to 4);
  SIGNAL mcb_tlxr_xlt_s1_bit_map : std_ulogic_vector(0 to 4);
  SIGNAL mcb_tlxr_xlt_s2_bit_map : std_ulogic_vector(0 to 4);
  SIGNAL mcb_tlxr_xlt_slot0_d_value : std_ulogic;
  SIGNAL mcb_tlxr_xlt_slot0_m0_valid : std_ulogic;
  SIGNAL mcb_tlxr_xlt_slot0_m1_valid : std_ulogic;
  SIGNAL mcb_tlxr_xlt_slot0_r15_valid : std_ulogic;
  SIGNAL mcb_tlxr_xlt_slot0_r16_valid : std_ulogic;
  SIGNAL mcb_tlxr_xlt_slot0_r17_valid : std_ulogic;
  SIGNAL mcb_tlxr_xlt_slot0_s0_valid : std_ulogic;
  SIGNAL mcb_tlxr_xlt_slot0_s1_valid : std_ulogic;
  SIGNAL mcb_tlxr_xlt_slot0_s2_valid : std_ulogic;
  SIGNAL mcb_tlxr_xlt_slot0_valid : std_ulogic;
  SIGNAL mcb_tlxr_xlt_slot1_d_value : std_ulogic;
  SIGNAL mcb_tlxr_xlt_slot1_m0_valid : std_ulogic;
  SIGNAL mcb_tlxr_xlt_slot1_m1_valid : std_ulogic;
  SIGNAL mcb_tlxr_xlt_slot1_r15_valid : std_ulogic;
  SIGNAL mcb_tlxr_xlt_slot1_r16_valid : std_ulogic;
  SIGNAL mcb_tlxr_xlt_slot1_r17_valid : std_ulogic;
  SIGNAL mcb_tlxr_xlt_slot1_s0_valid : std_ulogic;
  SIGNAL mcb_tlxr_xlt_slot1_s1_valid : std_ulogic;
  SIGNAL mcb_tlxr_xlt_slot1_s2_valid : std_ulogic;
  SIGNAL mcb_tlxr_xlt_slot1_valid : std_ulogic;
  SIGNAL mcb_wdf_meccg_err_inj_symbol : std_ulogic_vector(0 to 6);
  SIGNAL mcb_wdf_meccg_err_inj_type : std_ulogic_vector(0 to 3);
  SIGNAL mcb_wdf_wdgen_wrd_data : std_ulogic_vector(0 to 159);
  SIGNAL mcb_wdf_force_write : std_ulogic;
  SIGNAL mcbist_rq_ccs_done : std_ulogic;
  SIGNAL mcbist_rq_ccs_req : std_ulogic;
  SIGNAL mcbist_rq_spare : std_ulogic;
  SIGNAL mem_tcm_fir_host_attn : std_ulogic;
  SIGNAL mem_tcm_fir_local_xstop_err : std_ulogic;
  SIGNAL mem_tcm_fir_recov_err : std_ulogic;
  SIGNAL mem_tcm_fir_spec_attn : std_ulogic;
  SIGNAL mem_tcm_fir_trace_err : std_ulogic;
  SIGNAL mem_tcm_fir_xstop_err : std_ulogic;
  SIGNAL mmio_srq_ack : std_ulogic;
  SIGNAL mmio_idle : std_ulogic;
  SIGNAL mmio_srq_snsc_start : std_ulogic_vector(0 to 1);
  SIGNAL mmio_tlxr_resp_code : std_ulogic_vector(3 downto 0);
  SIGNAL mmio_tlxr_wr_buf_free : std_ulogic;
  SIGNAL mmio_tlxr_wr_buf_par : std_ulogic;
  SIGNAL mmio_tlxr_wr_buf_tag : std_ulogic_vector(5 downto 0);
  SIGNAL mmio_tlxt_busnum : std_ulogic_vector(8 downto 0);
  SIGNAL mmio_tlxt_rdata_bdi : std_ulogic;
  SIGNAL mmio_tlxt_rdata_bus : std_ulogic_vector(287 downto 0);
  SIGNAL mmio_tlxt_rdata_offset : std_ulogic;
  SIGNAL mmio_tlxt_resp_capptag : std_ulogic_vector(15 downto 0);
  SIGNAL mmio_tlxt_resp_code : std_ulogic_vector(3 downto 0);
  SIGNAL mmio_tlxt_resp_dl : std_ulogic_vector(1 downto 0);
  SIGNAL mmio_tlxt_resp_dp : std_ulogic_vector(1 downto 0);
  SIGNAL mmio_tlxt_resp_opcode : std_ulogic_vector(7 downto 0);
  SIGNAL mmio_tlxt_resp_par : std_ulogic;
  SIGNAL mmio_tlxt_resp_valid : std_ulogic;
  SIGNAL mmio_wdf_buf : std_ulogic_vector(0 to 5);
  SIGNAL mmio_wdf_offset : std_ulogic_vector(0 to 2);
  SIGNAL mmio_wdf_parity : std_ulogic;
  SIGNAL mmio_wdf_rd : std_ulogic;
  SIGNAL rdf_tlxt_data : std_ulogic_vector(0 to 127);
  SIGNAL rdf_tlxt_data_ecc : std_ulogic_vector(0 to 15);
  SIGNAL rdf_tlxt_data_valid : std_ulogic;
  SIGNAL rdf_tlxt_data_err : std_ulogic;
  SIGNAL rdf_tlxt_meta : std_ulogic_vector(0 to 5);
  SIGNAL rdf_tlxt_meta_p : std_ulogic;
  SIGNAL rdf_tlxt_meta_valid : std_ulogic_vector(0 to 1);
  SIGNAL rdf_tlxt_resp_dpart : std_ulogic_vector(0 to 1);
  SIGNAL rdf_tlxt_resp_exit0 : std_ulogic;
  SIGNAL rdf_tlxt_resp_len32 : std_ulogic;
  SIGNAL rdf_tlxt_resp_otag : std_ulogic_vector(0 to 15);
  SIGNAL rdf_tlxt_resp_p : std_ulogic;
  SIGNAL rdf_tlxt_resp_valid : std_ulogic;
  SIGNAL rdf_tlxt_bad_data_valid : std_ulogic;
  SIGNAL rdf_tlxt_bad_data_1st32B : std_ulogic;
  SIGNAL rdf_tlxt_bad_data : std_ulogic;
  SIGNAL rdf_tlxt_bad_data_p : std_ulogic;
  SIGNAL rdf_wdf_cfg_data_chkbit_inv : std_ulogic_vector(0 to 1);
  SIGNAL rdf_wdf_cfg_metadata_mode : std_ulogic_vector(0 to 2);
  SIGNAL rdf_wdf_cfg_use_address_hash : std_ulogic;
  SIGNAL rdf_wdf_bebuf_data : std_ulogic_vector(0 to 71);
  SIGNAL rdf_wdf_bebuf_wptr : std_ulogic_vector(0 to 5);
  SIGNAL rdf_wdf_bebuf_wr : std_ulogic;
  SIGNAL rdf_wdf_bebuf_wr_p : std_ulogic;
  SIGNAL rdf_wdf_rmwbuf_data : std_ulogic_vector(0 to 159);
  SIGNAL rdf_wdf_rmwbuf_wptr : std_ulogic_vector(0 to 5);
  SIGNAL rdf_wdf_rmwbuf_wr : std_ulogic;
  SIGNAL rdf_wdf_rmwbuf_wr_p : std_ulogic;
  SIGNAL rdf_srq_rmwbuf_ue : std_ulogic;
  SIGNAL rq_mcbist_ccs_ack : std_ulogic;
  SIGNAL srq_dbg_debug_bus : std_ulogic_vector(0 to 87);
  SIGNAL srq_cfg_addr : std_ulogic_vector(0 to 31);
  SIGNAL srq_cfg_info : std_ulogic_vector(0 to 15);
  SIGNAL srq_cfg_parity : std_ulogic;
  SIGNAL srq_cfg_plen : std_ulogic_vector(0 to 2);
  SIGNAL srq_cfg_rd : std_ulogic;
  SIGNAL srq_cfg_req : std_ulogic;
  SIGNAL srq_cfg_t : std_ulogic;
  SIGNAL srq_ddr_nttm_bypass_en : std_ulogic;
  SIGNAL srq_ddr_nttm_rd_start : std_ulogic;
  SIGNAL srq_ddr_nttm_wr_start : std_ulogic;
  SIGNAL srq_mcb_2n_addr : std_ulogic;
  SIGNAL srq_mcb_cmd_ack : std_ulogic;
  SIGNAL srq_mcb_rcmd_valid : std_ulogic;
  SIGNAL srq_mcb_wcmd_valid : std_ulogic;
  SIGNAL srq_mcb_wdone_val : std_ulogic;
  SIGNAL srq_mmio_addr : std_ulogic_vector(0 to 34);
  SIGNAL srq_mmio_info : std_ulogic_vector(0 to 15);
  SIGNAL srq_mmio_parity : std_ulogic;
  SIGNAL srq_mmio_plen : std_ulogic_vector(0 to 2);
  SIGNAL srq_mmio_snsc_event : std_ulogic;
  SIGNAL srq_mmio_rd : std_ulogic;
  SIGNAL srq_mmio_req : std_ulogic;
  SIGNAL srq_mmio_snsc_data_valid : std_ulogic;
  SIGNAL srq_mmio_snsc_data : std_ulogic_vector(0 to 31);
  SIGNAL srq_mmio_snsc_data_p : std_ulogic;
  SIGNAL srq_rdf_cfg_crit_ow_first_en : std_ulogic;
  SIGNAL srq_rdf_rcd_err : std_ulogic;
  SIGNAL srq_rdf_rdtag_rcd_err : std_ulogic;
  SIGNAL srq_rdf_rdtag : std_ulogic_vector(0 to 15);
  SIGNAL srq_rdf_rdtag_bank : std_ulogic_vector(0 to 2);
  SIGNAL srq_rdf_rdtag_bank_group : std_ulogic_vector(0 to 1);
  SIGNAL srq_rdf_rdtag_col : std_ulogic_vector(2 to 9);
  SIGNAL srq_rdf_rdtag_col_bank_par : std_ulogic;
  SIGNAL srq_rdf_rdtag_data_dest : std_ulogic_vector(0 to 1);
  SIGNAL srq_rdf_rdtag_dimm_select : std_ulogic;
  SIGNAL srq_rdf_rdtag_len64 : std_ulogic;
  SIGNAL srq_rdf_rdtag_len32 : std_ulogic;
  SIGNAL srq_rdf_rdtag_mcbist : std_ulogic;
  SIGNAL srq_rdf_rdtag_mrank : std_ulogic_vector(0 to 1);
  SIGNAL srq_rdf_rdtag_other_par : std_ulogic;
  SIGNAL srq_rdf_rdtag_rank_par : std_ulogic;
  SIGNAL srq_rdf_rdtag_row : std_ulogic_vector(0 to 17);
  SIGNAL srq_rdf_rdtag_row_bank_par : std_ulogic;
  SIGNAL srq_rdf_rdtag_sel : std_ulogic;
  SIGNAL srq_rdf_rdtag_spare : std_ulogic_vector(0 to 1);
  SIGNAL srq_rdf_rdtag_srank : std_ulogic_vector(0 to 2);
  SIGNAL srq_rdf_rdtag_val : std_ulogic;
  SIGNAL srq_tlxr_epow : std_ulogic;
  SIGNAL srq_tlxr_wdone_derr : std_ulogic;
  SIGNAL srq_tlxr_wdone_last : std_ulogic;
  SIGNAL srq_tlxr_wdone_p : std_ulogic;
  SIGNAL srq_tlxr_wdone_tag : std_ulogic_vector(0 to 5);
  SIGNAL srq_tlxr_wdone_val : std_ulogic;
  SIGNAL srq_tlxt_cmdq_release : std_ulogic;
  SIGNAL srq_tlxt_failresp_val : std_ulogic;
  SIGNAL srq_tlxt_failresp_type : std_ulogic;
  SIGNAL srq_tlxt_failresp_code : std_ulogic_vector(0 to 3);
  SIGNAL srq_tlxt_failresp_dlen : std_ulogic_vector(0 to 1);
  SIGNAL srq_tlxt_padmem_done_val : std_ulogic;
  SIGNAL srq_tlxt_padmem_done_tag : std_ulogic_vector(0 to 15);
  SIGNAL srq_tlxt_padmem_done_tag_p : std_ulogic_vector(0 to 1);
  SIGNAL tlxt_srq_padmem_done_ack : std_ulogic;
  SIGNAL srq_wdf_rmwbuf_rptr : std_ulogic_vector(0 to 3);
  SIGNAL srq_wdf_wrbuf_bank : std_ulogic_vector(0 to 2);
  SIGNAL srq_wdf_wrbuf_bank_group : std_ulogic_vector(0 to 1);
  SIGNAL srq_wdf_wrbuf_col : std_ulogic_vector(2 to 9);
  SIGNAL srq_wdf_wrbuf_data_source : std_ulogic;
  SIGNAL srq_wdf_wrbuf_dimm_select : std_ulogic;
  SIGNAL srq_wdf_wrbuf_mrank : std_ulogic_vector(0 to 1);
  SIGNAL srq_wdf_wrbuf_rd : std_ulogic;
  SIGNAL srq_wdf_wrbuf_rd_p : std_ulogic;
  SIGNAL srq_wdf_wrbuf_row : std_ulogic_vector(0 to 17);
  SIGNAL srq_wdf_wrbuf_rptr : std_ulogic_vector(0 to 6);
  SIGNAL srq_wdf_wrbuf_srank : std_ulogic_vector(0 to 2);
  SIGNAL tcm_tlxt_scom_cch : std_ulogic;
  SIGNAL tcm_tlxt_scom_dch : std_ulogic;
  SIGNAL tlxr_dbg_debug_bus : std_ulogic_vector(0 to 87);
  SIGNAL tlxr_srq_cmd : std_ulogic_vector(0 to 63);
  SIGNAL tlxr_srq_cmd_val : std_ulogic;
  SIGNAL tlxr_srq_fast_act_val : std_ulogic;
  SIGNAL tlxr_srq_fast_addr : std_ulogic_vector(0 to 26);
  SIGNAL tlxr_srq_fast_dimm : std_ulogic;
  SIGNAL tlxr_srq_fast_act_val_a : std_ulogic;
  SIGNAL tlxr_srq_fast_act_val_b : std_ulogic;
  SIGNAL tlxr_srq_fast_addr_a : std_ulogic_vector(0 to 26);
  SIGNAL tlxr_srq_fast_addr_b : std_ulogic_vector(0 to 26);
  SIGNAL tlxr_srq_fast_dimm_a : std_ulogic;
  SIGNAL tlxr_srq_fast_dimm_b : std_ulogic;
  SIGNAL tlxr_srq_wrbuf_crcval_vec : std_ulogic_vector(0 to 63);
  SIGNAL tlxr_tp_fir_trace_err : std_ulogic;
  SIGNAL tlxr_tlxt_consume_dcp1 : std_ulogic_vector(2 downto 0);
  SIGNAL tlxr_tlxt_consume_vc0 : std_ulogic;
  SIGNAL tlxr_tlxt_consume_vc1 : std_ulogic;
  SIGNAL tlxr_tlxt_dcp1_release : std_ulogic_vector(2 downto 0);
  SIGNAL tlxr_tlxt_errors : std_ulogic_vector(63 downto 0);
  SIGNAL tlxr_tlxt_signature_dat : std_ulogic_vector(63 downto 0);
  SIGNAL tlxr_tlxt_signature_strobe : std_ulogic;
  SIGNAL tlxr_tlxt_return_dcp0 : std_ulogic_vector(5 downto 0);
  SIGNAL tlxr_tlxt_return_dcp3 : std_ulogic_vector(5 downto 0);
  SIGNAL tlxr_tlxt_return_val : std_ulogic;
  SIGNAL tlxr_tlxt_return_vc0 : std_ulogic_vector(3 downto 0);
  SIGNAL tlxr_tlxt_return_vc3 : std_ulogic_vector(3 downto 0);
  SIGNAL tlxr_tlxt_write_resp : std_ulogic_vector(21 downto 0);
  SIGNAL tlxr_tlxt_write_resp_p : std_ulogic_vector(2 downto 0);
  SIGNAL tlxr_tlxt_write_resp_val : std_ulogic;
  SIGNAL tlxr_tlxt_vc0_release : std_ulogic_vector(1 downto 0);
  SIGNAL tlxr_tlxt_vc1_release : std_ulogic;
  SIGNAL tlxr_srq_memcntl_req : std_ulogic;
  SIGNAL tlxr_srq_memcntl_cmd_flag : std_ulogic_vector(0 to 3);
  SIGNAL tlxr_tlxt_intrp_resp : std_ulogic_vector(7 downto 0);
  SIGNAL tlxr_wdf_be : std_ulogic_vector(0 to 71);
  SIGNAL tlxr_wdf_be_wptr : std_ulogic_vector(0 to 5);
  SIGNAL tlxr_wdf_be_wr : std_ulogic;
  SIGNAL tlxr_wdf_be_wr_p : std_ulogic;
  SIGNAL tlxr_wdf_wrbuf_bad : std_ulogic_vector(0 to 64);
  SIGNAL tlxr_wdf_wrbuf_dat : std_ulogic_vector(0 to 145);
  SIGNAL tlxr_wdf_wrbuf_woffset : std_ulogic_vector(0 to 1);
  SIGNAL tlxr_wdf_wrbuf_wptr : std_ulogic_vector(0 to 5);
  SIGNAL tlxr_wdf_wrbuf_wr : std_ulogic;
  SIGNAL tlxr_wdf_wrbuf_wr_p : std_ulogic;
  SIGNAL tlxt_mmio_resp_ack : std_ulogic;
  SIGNAL tlxt_rdf_data_taken : std_ulogic;
  SIGNAL tlxt_srq_rdbuf_pop : std_ulogic;
  SIGNAL tlxt_tcm_scom_cch : std_ulogic;
  SIGNAL tlxt_tcm_scom_dch : std_ulogic;
  SIGNAL tlxt_tlxr_control : std_ulogic_vector(15 downto 0);
  SIGNAL tlxt_tlxr_wr_resp_full : std_ulogic;
  SIGNAL tlxt_tlxr_early_wdone_disable : std_ulogic_vector(1 downto 0);
  SIGNAL trc_master_clock_enable : std_ulogic;
  SIGNAL wdf_mcb_wdgen_addr : std_ulogic_vector(0 to 36);
  SIGNAL wdf_mcb_wdgen_req : std_ulogic;
  SIGNAL wdf_mmio_bad : std_ulogic;
  SIGNAL wdf_mmio_data : std_ulogic_vector(0 to 71);
  SIGNAL wdf_mmio_done : std_ulogic;
  SIGNAL wdf_srq_errors : std_ulogic_vector(0 to 7);
  SIGNAL wdf_srq_cfg_crc_en : std_ulogic;
  SIGNAL srq_unused : std_ulogic_vector(0 to 8);
  SIGNAL tra0_mux0_sel : std_ulogic_vector(0 to 1);
  SIGNAL tra0_mux1_sel : std_ulogic_vector(0 to 1);
  SIGNAL unit_tc_trace0_data : std_ulogic_vector(0 to 87);
  SIGNAL unit_tc_trace1_data : std_ulogic_vector(0 to 87);
  SIGNAL rdf_dbg_dfi_rddata : std_ulogic_vector(0 to 159);
  SIGNAL rdf_dbg_dfi_rddata_valid : std_ulogic_vector(0 to 9);
  SIGNAL rdf_dbg_debug_bus : std_ulogic_vector(0 to 87);
  SIGNAL wdf_dbg_debug_bus : std_ulogic_vector(0 to 87);
  SIGNAL mcb_dbg_debug_bus_config : std_ulogic_vector(0 to 63);
  SIGNAL mcb_dbg_debug_bus : std_ulogic_vector(0 to 87);
  SIGNAL tlxt_dbg_debug_bus : std_ulogic_vector(0 to 87);
  SIGNAL mmio_dbg_debug_bus : std_ulogic_vector(0 to 87);
  SIGNAL dfi_act_n_a_int : std_ulogic;
  SIGNAL dfi_address_a_int : std_ulogic_vector(0 to 17);
  SIGNAL dfi_bank_a_int : std_ulogic_vector(0 to 1);
  SIGNAL dfi_bg_a_int : std_ulogic_vector(0 to 1);
  SIGNAL dfi_cas_n_a_int : std_ulogic;
  SIGNAL dfi_cid_a_int : std_ulogic_vector(0 to 1);
  SIGNAL dfi_cke_a_int : std_ulogic_vector(0 to 1);
  SIGNAL dfi_cs_n_a_int : std_ulogic_vector(0 to 1);
  SIGNAL dfi_odt_a_int : std_ulogic_vector(0 to 1);
  SIGNAL dfi_ras_n_a_int : std_ulogic;
  SIGNAL dfi_we_n_a_int : std_ulogic;
  SIGNAL dfi_act_n_b_int : std_ulogic;
  SIGNAL dfi_address_b_int : std_ulogic_vector(0 to 17);
  SIGNAL dfi_bank_b_int : std_ulogic_vector(0 to 1);
  SIGNAL dfi_bg_b_int : std_ulogic_vector(0 to 1);
  SIGNAL dfi_cas_n_b_int : std_ulogic;
  SIGNAL dfi_cid_b_int : std_ulogic_vector(0 to 1);
  SIGNAL dfi_cke_b_int : std_ulogic_vector(0 to 1);
  SIGNAL dfi_cs_n_b_int : std_ulogic_vector(0 to 1);
  SIGNAL dfi_odt_b_int : std_ulogic_vector(0 to 1);
  SIGNAL dfi_ras_n_b_int : std_ulogic;
  SIGNAL dfi_we_n_b_int : std_ulogic;
  SIGNAL dfi_dram_clk_disable_int : std_ulogic_vector(0 to 3);
  SIGNAL dfi_freq_int : std_ulogic_vector(0 to 4);
  SIGNAL dfi_init_start_int : std_ulogic;
  SIGNAL dfi_lp_ctrl_req_int : std_ulogic;
  SIGNAL dfi_lp_data_req_int : std_ulogic;
  SIGNAL dfi_lp_wakeup_int : std_ulogic_vector(0 to 3);
  SIGNAL dfi_parity_in_int : std_ulogic;
  SIGNAL dfi_rddata_cs_n_int : std_ulogic_vector(0 to 39);
  SIGNAL dfi_rddata_en_int : std_ulogic_vector(0 to 9);
  SIGNAL dfi_reset_n_int : std_ulogic;
  SIGNAL dfi_wrdata_int : std_ulogic_vector(0 to 159);
  SIGNAL dfi_wrdata_cs_n_int : std_ulogic_vector(0 to 39);
  SIGNAL dfi_wrdata_en_int : std_ulogic_vector(0 to 9);
  SIGNAL tlx_xstop_err : std_ulogic;                  -- [OUT] checkstop   output to Global FIR
  SIGNAL tlx_recov_err : std_ulogic;                  -- [OUT] recoverable output to Global FIR
  SIGNAL tlx_recov_int : std_ulogic;                  -- [OUT] recoverable interrupt output to Global FIR
  SIGNAL tlx_mchk_out : std_ulogic;
  SIGNAL tlx_trace_error : std_ulogic;                  -- [OUT] error to connect to error_input of closest trdata macro
  SIGNAL global_fir_chan_xstop : std_ulogic;
  SIGNAL global_fir_rec_attn : std_ulogic;
  SIGNAL global_fir_sp_attn : std_ulogic;
  SIGNAL asyncr : std_ulogic;
  SIGNAL fir_tc_pcb_recov : std_ulogic;
  SIGNAL fir_tc_pcb_spattn : std_ulogic;
  SIGNAL fir_tc_pcb_xstop : std_ulogic;
  SIGNAL fir_tc_pcb_mchk : std_ulogic;
  SIGNAL pib_mmio_pibmst_req_rst : std_ulogic;
  SIGNAL tc_tra0_fir_err : std_ulogic;
  SIGNAL tc_tra1_fir_err : std_ulogic;
  SIGNAL tc_unit_debug_trigger_out : std_ulogic_vector(0 to 2);
  SIGNAL tra0_master_clock_enable : std_ulogic;
  SIGNAL tra1_master_clock_enable : std_ulogic;
  SIGNAL tra1_mux0_sel : std_ulogic_vector(0 to 1);
  SIGNAL tra1_mux1_sel : std_ulogic_vector(0 to 1);
  SIGNAL unit_tc_fir_err_dis : std_ulogic_vector(0 to 9);
  SIGNAL unit_tc_tra0_fir_err : std_ulogic;
  SIGNAL unit_tc_tra1_fir_err : std_ulogic;
  SIGNAL gckn : std_ulogic;
  SIGNAL gck_div4  : std_ulogic;
  SIGNAL gck_div4_out : std_ulogic;
  SIGNAL sync_reset_gck_dlx : std_ulogic;
  SIGNAL sync_reset_gck_mcb : std_ulogic;
  SIGNAL sync_reset_gck_mmio : std_ulogic;
  SIGNAL sync_reset_gck_rdf : std_ulogic;
  SIGNAL sync_reset_gck_srq : std_ulogic;
  SIGNAL sync_reset_gck_tlxr : std_ulogic;
  SIGNAL sync_reset_gck_tlxt : std_ulogic;
  SIGNAL sync_reset_gck_tp : std_ulogic;
  SIGNAL sync_reset_gck_wdf : std_ulogic;
  SIGNAL sync_reset_gck_dbg : std_ulogic;
  SIGNAL sync_reset_gck_clock_divider : std_ulogic;
  SIGNAL sync_reset_gck_div4 : std_ulogic;
  SIGNAL sync_reset_pclk : std_ulogic;
  SIGNAL global_fir_mchk : std_ulogic;
  SIGNAL mcb_mem_tcm_fir_trace_err : std_ulogic;
  SIGNAL dbg_mcbist_watact_frc_tb_pulse : std_ulogic;
  SIGNAL dbg_mcbist_watact_mnt_go_idle : std_ulogic;
  SIGNAL dbg_mcbist_watact_set_spattn : std_ulogic;
  SIGNAL dbgcfg0 : std_ulogic_vector(0 to 47);
  SIGNAL dbgcfg1 : std_ulogic_vector(0 to 63);
  SIGNAL dbgcfg2 : std_ulogic_vector(0 to 63);
  SIGNAL dbgcfg3 : std_ulogic_vector(0 to 58);
  SIGNAL watcfg0a : std_ulogic_vector(0 to 47);
  SIGNAL watcfg0b : std_ulogic_vector(0 to 60);
  SIGNAL watcfg0c : std_ulogic_vector(0 to 43);
  SIGNAL watcfg0d : std_ulogic_vector(0 to 43);
  SIGNAL watcfg0e : std_ulogic_vector(0 to 43);
  SIGNAL watcfg1a : std_ulogic_vector(0 to 47);
  SIGNAL watcfg1b : std_ulogic_vector(0 to 60);
  SIGNAL watcfg1c : std_ulogic_vector(0 to 43);
  SIGNAL watcfg1d : std_ulogic_vector(0 to 43);
  SIGNAL watcfg1e : std_ulogic_vector(0 to 43);
  SIGNAL watcfg2a : std_ulogic_vector(0 to 47);
  SIGNAL watcfg2b : std_ulogic_vector(0 to 60);
  SIGNAL watcfg2c : std_ulogic_vector(0 to 43);
  SIGNAL watcfg2d : std_ulogic_vector(0 to 43);
  SIGNAL watcfg2e : std_ulogic_vector(0 to 43);
  SIGNAL watcfg3a : std_ulogic_vector(0 to 47);
  SIGNAL watcfg3b : std_ulogic_vector(0 to 60);
  SIGNAL watcfg3c : std_ulogic_vector(0 to 43);
  SIGNAL watcfg3d : std_ulogic_vector(0 to 43);
  SIGNAL watcfg3e : std_ulogic_vector(0 to 43);
  SIGNAL tlxt_tlxr_low_lat_mode : std_ulogic;
  SIGNAL dfi_dram_clk_disable_a_int : std_ulogic_vector(0 to 1);
  SIGNAL dfi_dram_clk_disable_b_int : std_ulogic_vector(0 to 1);
  SIGNAL dfi_parity_in_a_int : std_ulogic;
  SIGNAL dfi_parity_in_b_int : std_ulogic;
  SIGNAL srq_tlxr_fast_act_fifo_next : std_ulogic;
  SIGNAL srq_tlxr_fast_act_fifo_drain : std_ulogic;
  SIGNAL tlxr_srq_fast_act_fifo_val : std_ulogic;
  SIGNAL tlxr_srq_fast_act_fifo_addr : std_ulogic_vector(0 to 26);
  SIGNAL tlxr_srq_fast_act_fifo_dimm : std_ulogic;
  SIGNAL tlxr_srq_fast_act_fifo_row_bank_par : std_ulogic;
  SIGNAL tlxr_srq_fast_act_fifo_rank_par : std_ulogic;
  SIGNAL tlxr_srq_fast_act_fifo_val_a : std_ulogic;
  SIGNAL tlxr_srq_fast_act_fifo_addr_a : std_ulogic_vector(0 to 26);
  SIGNAL tlxr_srq_fast_act_fifo_dimm_a : std_ulogic;
  SIGNAL tlxr_srq_fast_act_fifo_row_bank_par_a : std_ulogic;
  SIGNAL tlxr_srq_fast_act_fifo_rank_par_a : std_ulogic;
  SIGNAL tlxr_srq_fast_act_fifo_val_b : std_ulogic;
  SIGNAL tlxr_srq_fast_act_fifo_addr_b : std_ulogic_vector(0 to 26);
  SIGNAL tlxr_srq_fast_act_fifo_dimm_b : std_ulogic;
  SIGNAL tlxr_srq_fast_act_fifo_row_bank_par_b : std_ulogic;
  SIGNAL tlxr_srq_fast_act_fifo_rank_par_b : std_ulogic;
  SIGNAL dfi_ctrlupd_req_int : std_ulogic;
  SIGNAL cfg_half_dimm_mode : std_ulogic;
  SIGNAL tlxr_dbg_trace_err : std_ulogic;
  SIGNAL tlxt_dbg_trace_err : std_ulogic;
  SIGNAL dlx_dbg_trace_err : std_ulogic;
  SIGNAL srq_dbg_trace_err : std_ulogic;
  SIGNAL mcb_dbg_trace_err : std_ulogic;
  SIGNAL mmio_dbg_trace_err : std_ulogic;
  SIGNAL rdf_dbg_trace_err : std_ulogic;
  SIGNAL tc_srq_ddr_phy_func_itr : std_ulogic;


begin


tlxt : entity work.cb_tlxt_mac
port map (
    cfg_half_dimm_mode                                  => cfg_half_dimm_mode                   , -- OVR: cb_rdf_wrap(rdf)   -- TODO source?
    dlx_tlxr_link_up                                    => dlx_tlxr_link_up                     , -- MSR: cb_tlxt_mac(tlxt)
    dlx_tlxt_flit_credit                                => dlx_tlxt_flit_credit                 , -- MSR: cb_tlxt_mac(tlxt)
    dlx_tlxt_lane_width_status                          => dlx_tlxt_lane_width_status                 , -- MSR: cb_tlxt_mac(tlxt)
    cfg_f1_octrl00_enable_afu                           => cfg_f1_octrl00_enable_afu                       , -- MSR: cb_mmio_mac(mmio)
    cfg_f1_octrl00_metadata_enabled                     => cfg_f1_octrl00_metadata_enabled                 , -- MSR: cb_mmio_mac(mmio)
    cfg_f1_octrl00_p                                    => cfg_f1_octrl00_p                                , -- MSR: cb_mmio_mac(mmio)
    cfg_f1_octrl00_pasid_base (20 downto 0)             => cfg_f1_octrl00_pasid_base (20 downto 0)         , -- MSR: cb_mmio_mac(mmio)
    cfg_f1_octrl00_pasid_length_enabled (5 downto 0)    => cfg_f1_octrl00_pasid_length_enabled (5 downto 0), -- MSR: cb_mmio_mac(mmio)
    cfg_f1_octrl00_afu_actag_base(12 DOWNTO 0)          => cfg_f1_octrl00_afu_actag_base (12 DOWNTO 0)     , -- MSR: cb_mmio_mac(mmio)
    cfg_f1_octrl00_afu_actag_len_enab (12 DOWNTO 0)     => cfg_f1_octrl00_afu_actag_len_enab (12 DOWNTO 0) , -- MSR: cb_mmio_mac(mmio)
    cfg_f1_ofunc_func_actag_base (12 downto 0)          => cfg_f1_ofunc_func_actag_base (12 downto 0)      , -- MSR: cb_mmio_mac(mmio)
    cfg_f1_ofunc_func_actag_len_enab (12 downto 0)      => cfg_f1_ofunc_func_actag_len_enab (12 downto 0)  , -- MSR: cb_mmio_mac(mmio)
    cfg_otl0_tl_minor_vers_config                       => cfg_otl0_tl_minor_vers_config                   , -- MSR: cb_mmio_mac(mmio)
    cfg_otl0_tl_minor_vers_config_p                     => cfg_otl0_tl_minor_vers_config_p                 , -- MSR: cb_mmio_mac(mmio)
    cfg_otl0_tl_xmt_rate_tmpl_config (48 downto 0)      => cfg_otl0_tl_xmt_rate_tmpl_config (48 downto 0)  , -- MSR: cb_mmio_mac(mmio)
    cfg_otl0_tl_xmt_tmpl_config (12 downto 0)           => cfg_otl0_tl_xmt_tmpl_config (12 downto 0)       , -- MSR: cb_mmio_mac(mmio)
    gckn                                                => gckn                                 , -- MSR: cb_tlxt_mac(tlxt)
    tlx_xstop_err                                       => tlx_xstop_err,    -- [OUT std_ulogic] checkstop   output to Global FIR
    tlx_recov_err                                       => tlx_recov_err,    -- [OUT std_ulogic] recoverable output to Global FIR
    tlx_recov_int                                       => tlx_recov_int,    -- [OUT std_ulogic] recoverable interrupt output to Global FIR
    tlx_mchk_out                                        => tlx_mchk_out,     -- [OUT std_ulogic] used only if implement_mchk=true
    tlx_trace_error                                     => tlx_trace_error,  -- [OUT std_ulogic] error to connect to error_input of closest trdata macro
    global_fir_chan_xstop                               => global_fir_chan_xstop                , -- MSR: cb_tlxt_mac(tlxt)
    global_fir_rec_attn                                 => global_fir_rec_attn                  , -- MSR: cb_tlxt_mac(tlxt)
    global_fir_sp_attn                                  => global_fir_sp_attn                   , -- MSR: cb_tlxt_mac(tlxt)
    global_fir_mchk                                     => global_fir_mchk                      , -- MSR: cb_tlxt_mac(tlxt)
    gnd                                                 => gnd                                  , -- MSB: cb_tlxt_mac(tlxt)
    mmio_tlxt_busnum (8 downto 0)                       => mmio_tlxt_busnum (8 downto 0)        , -- MSR: cb_tlxt_mac(tlxt)
    mmio_tlxt_rdata_bdi                                 => mmio_tlxt_rdata_bdi                  , -- MSR: cb_tlxt_mac(tlxt)
    mmio_tlxt_rdata_bus (287 downto 0)                  => mmio_tlxt_rdata_bus (287 downto 0)   , -- MSR: cb_tlxt_mac(tlxt)
    mmio_tlxt_rdata_offset                              => mmio_tlxt_rdata_offset               , -- MSR: cb_tlxt_mac(tlxt)
    mmio_tlxt_resp_capptag (15 downto 0)                => mmio_tlxt_resp_capptag (15 downto 0) , -- MSR: cb_tlxt_mac(tlxt)
    mmio_tlxt_resp_code (3 downto 0)                    => mmio_tlxt_resp_code (3 downto 0)     , -- MSR: cb_tlxt_mac(tlxt)
    mmio_tlxt_resp_dl (1 downto 0)                      => mmio_tlxt_resp_dl (1 downto 0)       , -- MSR: cb_tlxt_mac(tlxt)
    mmio_tlxt_resp_dp (1 downto 0)                      => mmio_tlxt_resp_dp (1 downto 0)       , -- MSR: cb_tlxt_mac(tlxt)
    mmio_tlxt_resp_opcode (7 downto 0)                  => mmio_tlxt_resp_opcode (7 downto 0)   , -- MSR: cb_tlxt_mac(tlxt)
    mmio_tlxt_resp_par                                  => mmio_tlxt_resp_par                   , -- MSR: cb_mmio_mac(tlxt)
    mmio_tlxt_resp_valid                                => mmio_tlxt_resp_valid                 , -- MSR: cb_tlxt_mac(tlxt)
    rdf_tlxt_bad_data_valid                             => rdf_tlxt_bad_data_valid              , -- MSR: cb_tlxt_mac(tlxt)
    rdf_tlxt_bad_data_1st32B                            => rdf_tlxt_bad_data_1st32B             , -- MSR: cb_tlxt_mac(tlxt)
    rdf_tlxt_bad_data                                   => rdf_tlxt_bad_data                    , -- MSR: cb_tlxt_mac(tlxt)
    rdf_tlxt_bad_data_p                                 => rdf_tlxt_bad_data_p                  , -- MSR: cb_tlxt_mac(tlxt)
    rdf_tlxt_data (0 to 127)                            => rdf_tlxt_data (0 to 127)             , -- MSR: cb_tlxt_mac(tlxt)
    rdf_tlxt_data_ecc (0 to 15)                         => rdf_tlxt_data_ecc (0 to 15)          , -- MSR: cb_tlxt_mac(tlxt)
    rdf_tlxt_data_err                                   => rdf_tlxt_data_err                    , -- MSR: cb_tlxt_mac(tlxt)
    rdf_tlxt_data_valid                                 => rdf_tlxt_data_valid                  , -- MSR: cb_tlxt_mac(tlxt)
    rdf_tlxt_meta (0 to 5)                              => rdf_tlxt_meta (0 to 5)               , -- MSR: cb_tlxt_mac(tlxt)
    rdf_tlxt_meta_p                                     => rdf_tlxt_meta_p                      , -- MSR: cb_tlxt_mac(tlxt)
    rdf_tlxt_meta_valid (0 to 1)                        => rdf_tlxt_meta_valid (0 to 1)         , -- MSR: cb_tlxt_mac(tlxt)
    rdf_tlxt_resp_dpart (0 to 1)                        => rdf_tlxt_resp_dpart (0 to 1)         , -- MSR: cb_tlxt_mac(tlxt)
    rdf_tlxt_resp_exit0                                 => rdf_tlxt_resp_exit0                  , -- MSR: cb_tlxt_mac(tlxt)
    rdf_tlxt_resp_len32                                 => rdf_tlxt_resp_len32                  , -- MSR: cb_tlxt_mac(tlxt)
    rdf_tlxt_resp_otag (0 to 15)                        => rdf_tlxt_resp_otag (0 to 15)         , -- MSR: cb_tlxt_mac(tlxt)
    rdf_tlxt_resp_p                                     => rdf_tlxt_resp_p                      , -- MSR: cb_tlxt_mac(tlxt)
    rdf_tlxt_resp_valid                                 => rdf_tlxt_resp_valid                  , -- MSR: cb_tlxt_mac(tlxt)
    syncr                                               => sync_reset_gck_tlxt                  , -- MSR: cb_tlxt_mac(tlxt)
    srq_tlxt_cmdq_release                               => srq_tlxt_cmdq_release                , -- MSR: cb_tlxt_mac(tlxt)
    srq_tlxt_failresp_val                               => srq_tlxt_failresp_val                , -- MSR: cb_tlxt_mac(tlxt)
    srq_tlxt_failresp_type                              => srq_tlxt_failresp_type                , -- MSR: cb_tlxt_mac(tlxt)
    srq_tlxt_failresp_code (0 to 3)                     => srq_tlxt_failresp_code (0 to 3)      , -- MSR: cb_tlxt_mac(tlxt)
    srq_tlxt_failresp_dlen                              => srq_tlxt_failresp_dlen               , -- MSR: cb_tlxt_mac(tlxt)
    srq_tlxt_padmem_done_val                            => srq_tlxt_padmem_done_val,    -- [in std_ulogic]
    srq_tlxt_padmem_done_tag                            => srq_tlxt_padmem_done_tag,    -- [in std_ulogic_vector(0 TO 15)]
    srq_tlxt_padmem_done_tag_p                          => srq_tlxt_padmem_done_tag_p,  -- [in std_ulogic(0 TO 1)]
    tlxt_srq_padmem_done_ack                            => tlxt_srq_padmem_done_ack,    -- [out  std_ulogic]
    tcm_tlxt_scom_cch                                   => tcm_tlxt_scom_cch                    , -- MSR: cb_tlxt_mac(tlxt)
    tcm_tlxt_scom_dch                                   => tcm_tlxt_scom_dch                    , -- MSR: cb_tlxt_mac(tlxt)
    tlxr_tlxt_consume_dcp1 (2 downto 0)                 => tlxr_tlxt_consume_dcp1 (2 downto 0)  , -- MSR: cb_tlxt_mac(tlxt)
    tlxr_tlxt_consume_vc0                               => tlxr_tlxt_consume_vc0                , -- MSR: cb_tlxt_mac(tlxt)
    tlxr_tlxt_consume_vc1                               => tlxr_tlxt_consume_vc1                , -- MSR: cb_tlxt_mac(tlxt)
    tlxr_tlxt_dcp1_release (2 downto 0)                 => tlxr_tlxt_dcp1_release (2 downto 0)  , -- MSR: cb_tlxt_mac(tlxt)
    tlxr_tlxt_intrp_resp (7 downto 0)                   => tlxr_tlxt_intrp_resp (7 downto 0)    , -- MSR: cb_tlxr_mac(tlxr)
    tlxr_tlxt_vc0_release (1 downto 0)                  => tlxr_tlxt_vc0_release (1 downto 0)   , -- MSR: cb_tlxr_mac(tlxt)
    tlxr_tlxt_vc1_release                               => tlxr_tlxt_vc1_release                , -- MSR: cb_tlxr_mac(tlxt)
    tlxr_tlxt_return_dcp0 (5 downto 0)                  => tlxr_tlxt_return_dcp0 (5 downto 0)   , -- MSR: cb_tlxt_mac(tlxt)
    tlxr_tlxt_return_dcp3 (5 downto 0)                  => tlxr_tlxt_return_dcp3 (5 downto 0)   , -- MSR: cb_tlxt_mac(tlxt)
    tlxr_tlxt_return_val                                => tlxr_tlxt_return_val                 , -- MSR: cb_tlxt_mac(tlxt)
    tlxr_tlxt_return_vc0 (3 downto 0)                   => tlxr_tlxt_return_vc0 (3 downto 0)    , -- MSR: cb_tlxt_mac(tlxt)
    tlxr_tlxt_return_vc3 (3 downto 0)                   => tlxr_tlxt_return_vc3 (3 downto 0)    , -- MSR: cb_tlxt_mac(tlxt)
    tlxr_tlxt_write_resp (21 downto 0)                  => tlxr_tlxt_write_resp (21 downto 0)   , -- MSR: cb_tlxt_mac(tlxt)
    tlxr_tlxt_write_resp_p (2 downto 0)                 => tlxr_tlxt_write_resp_p (2 downto 0)  , -- MSR: cb_tlxt_mac(tlxt)
    tlxr_tlxt_write_resp_val                            => tlxr_tlxt_write_resp_val             , -- MSR: cb_tlxt_mac(tlxt)
    tlxt_dbg_debug_bus (0 to 87    )                    => tlxt_dbg_debug_bus (0 to 87)         , -- MSD: cb_tlxt_mac(tlxt)
    tlxt_dlx_flit_data (127 downto 0)                   => tlxt_dlx_flit_data (127 downto 0)    , -- MSD: cb_tlxt_mac(tlxt)
    tlxt_dlx_flit_ecc (15 downto 0)                     => tlxt_dlx_flit_ecc (15 downto 0)      , -- MSD: cb_tlxt_mac(tlxt)
    tlxt_dlx_flit_lbip_data (81 downto 0)               => tlxt_dlx_flit_lbip_data (81 downto 0), -- MSD: cb_tlxt_mac(tlxt)
    tlxt_dlx_flit_lbip_vld                              => tlxt_dlx_flit_lbip_vld               , -- MSD: cb_tlxt_mac(tlxt)
    tlxt_dlx_flit_early_vld_a                           => tlxt_dlx_flit_early_vld              , -- MSD: cb_tlxt_mac(tlxt)
    tlxt_dlx_flit_early_vld_b                           => open                                 , -- MSD: cb_tlxt_mac(tlxt)
    tlxt_dlx_flit_vld                                   => tlxt_dlx_flit_vld                    , -- MSD: cb_tlxt_mac(tlxt)
    tlxt_dlx_tl_error                                   => tlxt_dlx_tl_error                    , -- MSD: cb_tlxt_mac(tlxt)
    tlxt_dlx_tl_event                                   => tlxt_dlx_tl_event                    , -- MSD: cb_tlxt_mac(tlxt)
    tlxt_mmio_resp_ack                                  => tlxt_mmio_resp_ack                   , -- MSD: cb_tlxt_mac(tlxt)
    tlxt_rdf_data_taken                                 => tlxt_rdf_data_taken                  , -- MSD: cb_tlxt_mac(tlxt)
    tlxt_srq_rdbuf_pop                                  => tlxt_srq_rdbuf_pop                   , -- MSD: cb_tlxt_mac(tlxt)
    tlxt_tcm_scom_cch                                   => tlxt_tcm_scom_cch                    , -- MSD: cb_tlxt_mac(tlxt)
    tlxt_tcm_scom_dch                                   => tlxt_tcm_scom_dch                    , -- MSD: cb_tlxt_mac(tlxt)
    tlxt_tlxr_wr_resp_full                              => tlxt_tlxr_wr_resp_full               , -- MSD: cb_tlxt_mac(tlxt)
    tlxt_tlxr_early_wdone_disable                       => tlxt_tlxr_early_wdone_disable        , -- MSR: cb_tlxr_mac(tlxt)
    tlxt_tlxr_ctrl                                      => tlxt_tlxr_control                    , -- OUT STD_ULOGIC_VECTOR(0 to 15);
    tlxt_tlxr_low_lat_mode                              => tlxt_tlxr_low_lat_mode               , -- MSD: cb_tlxt_mac(tlxt)
    tlxr_tlxt_errors                                    => tlxr_tlxt_errors (63 downto 0)       , -- MSD: cb_tlxr_mac(tlxr)
    tlxr_tlxt_signature_dat(63 downto 0)                => tlxr_tlxt_signature_dat(63 downto 0) , -- std_ulogic_vector(0 TO 63);
    tlxr_tlxt_signature_strobe                          => tlxr_tlxt_signature_strobe           , --    : IN std_ulogic;
    dbg_tlxt_wat_event(0 TO 3)                          => dbg_tlxt_wat_event(0 TO 3),
    vdd                                                 => vdd                                   -- MSB: cb_tlxt_mac(tlxt)
);

tlxr : entity work.cb_tlxr_mac
port map (
    cfg_f1_csh_memory_space             => cfg_f1_csh_memory_space            , -- MSR: cb_tlxr_mac(tlxr)
    cfg_f1_csh_mmio_bar0 (63 downto 35) => cfg_f1_csh_mmio_bar0 (63 downto 35), -- MSR: cb_tlxr_mac(tlxr)
    cfg_f1_csh_p                        => cfg_f1_csh_p                       , -- MSR: cb_tlxr_mac(tlxr)
    cfg_f1_octrl00_metadata_enabled     => cfg_f1_octrl00_metadata_enabled    , -- MSD: cb_mmio_mac(mmio)
    cfg_otl0_long_backoff_timer(3 downto 0) => cfg_otl0_long_backoff_timer(3 downto 0),
    cfg_half_dimm_mode                  => cfg_half_dimm_mode                  ,
    dlx_tlxr_flit_data (127 downto 0)   => dlx_tlxr_flit_data (127 downto 0)  , -- MSR: cb_tlxr_mac(tlxr)
    dlx_tlxr_flit_error                 => dlx_tlxr_flit_error                , -- MSR: cb_tlxr_mac(tlxr)
    dlx_tlxr_flit_pty (15 downto 0)     => dlx_tlxr_flit_pty (15 downto 0)    , -- MSR: cb_tlxr_mac(tlxr)
    dlx_tlxr_flit_vld                   => dlx_tlxr_flit_vld                  , -- MSR: cb_tlxr_mac(tlxr)
    dlx_tlxr_link_up                    => dlx_tlxr_link_up                   , -- MSR: cb_tlxr_mac(tlxr)
    dlx_tlxr_fast_act_info              => dlx_tlxr_fast_act_info             ,
    dlx_tlxr_idle_transition            => dlx_tlxr_idle_transition           ,
    dlx_tlxr_fast_act_info_a            => dlx_tlxr_fast_act_info_l             ,
    dlx_tlxr_idle_transition_a          => dlx_tlxr_idle_transition_l           ,
    dlx_tlxr_fast_act_info_b            => dlx_tlxr_fast_act_info_r             ,
    dlx_tlxr_idle_transition_b          => dlx_tlxr_idle_transition_r           ,
    gckn                                => gckn                               , -- MSR: cb_tlxr_mac(tlxr)
    gnd                                 => gnd                                , -- MSB: cb_tlxr_mac(tlxr)
    syncr                               => sync_reset_gck_tlxr                , -- MSR: cb_tlxr_mac(tlxr)
    mcb_tlxr_enab_row_addr_hash         => mcb_tlxr_enab_row_addr_hash        , -- MSR: cb_tlxr_mac(tlxr)
    mcb_tlxr_xlt_slot0_valid            => mcb_tlxr_xlt_slot0_valid           ,
    mcb_tlxr_xlt_slot0_d_value          => mcb_tlxr_xlt_slot0_d_value         ,
    mcb_tlxr_xlt_slot1_valid            => mcb_tlxr_xlt_slot1_valid           ,
    mcb_tlxr_xlt_slot1_d_value          => mcb_tlxr_xlt_slot1_d_value         ,
    mcb_tlxr_xlt_d_bit_map              => mcb_tlxr_xlt_d_bit_map             ,
    mcb_tlxr_xlt_b0_bit_map (0 to 4)    => mcb_tlxr_xlt_b0_bit_map (0 to 4)   , -- MSR: cb_tlxr_mac(tlxr)
    mcb_tlxr_xlt_b1_bit_map (0 to 4)    => mcb_tlxr_xlt_b1_bit_map (0 to 4)   , -- MSR: cb_tlxr_mac(tlxr)
    mcb_tlxr_xlt_bg0_bit_map (0 to 4)   => mcb_tlxr_xlt_bg0_bit_map (0 to 4)  , -- MSR: cb_tlxr_mac(tlxr)
    mcb_tlxr_xlt_bg1_bit_map (0 to 4)   => mcb_tlxr_xlt_bg1_bit_map (0 to 4)  , -- MSR: cb_tlxr_mac(tlxr)
    mcb_tlxr_xlt_c3_bit_map (0 to 4)    => mcb_tlxr_xlt_c3_bit_map (0 to 4)   , -- MSR: cb_tlxr_mac(tlxr)
    mcb_tlxr_xlt_c4_bit_map (0 to 4)    => mcb_tlxr_xlt_c4_bit_map (0 to 4)   , -- MSR: cb_tlxr_mac(tlxr)
    mcb_tlxr_xlt_c5_bit_map (0 to 4)    => mcb_tlxr_xlt_c5_bit_map (0 to 4)   , -- MSR: cb_tlxr_mac(tlxr)
    mcb_tlxr_xlt_c6_bit_map (0 to 4)    => mcb_tlxr_xlt_c6_bit_map (0 to 4)   , -- MSR: cb_tlxr_mac(tlxr)
    mcb_tlxr_xlt_c7_bit_map (0 to 4)    => mcb_tlxr_xlt_c7_bit_map (0 to 4)   , -- MSR: cb_tlxr_mac(tlxr)
    mcb_tlxr_xlt_c8_bit_map (0 to 4)    => mcb_tlxr_xlt_c8_bit_map (0 to 4)   , -- MSR: cb_tlxr_mac(tlxr)
    mcb_tlxr_xlt_c9_bit_map (0 to 4)    => mcb_tlxr_xlt_c9_bit_map (0 to 4)   , -- MSR: cb_tlxr_mac(tlxr)
    mcb_tlxr_xlt_m0_bit_map (0 to 4)    => mcb_tlxr_xlt_m0_bit_map (0 to 4)   , -- MSR: cb_tlxr_mac(tlxr)
    mcb_tlxr_xlt_m1_bit_map (0 to 4)    => mcb_tlxr_xlt_m1_bit_map (0 to 4)   , -- MSR: cb_tlxr_mac(tlxr)
    mcb_tlxr_xlt_r15_bit_map (0 to 4)   => mcb_tlxr_xlt_r15_bit_map (0 to 4)  , -- MSR: cb_tlxr_mac(tlxr)
    mcb_tlxr_xlt_r16_bit_map (0 to 4)   => mcb_tlxr_xlt_r16_bit_map (0 to 4)  , -- MSR: cb_tlxr_mac(tlxr)
    mcb_tlxr_xlt_r17_bit_map (0 to 4)   => mcb_tlxr_xlt_r17_bit_map (0 to 4)  , -- MSR: cb_tlxr_mac(tlxr)
    mcb_tlxr_xlt_s0_bit_map (0 to 4)    => mcb_tlxr_xlt_s0_bit_map (0 to 4)   , -- MSR: cb_tlxr_mac(tlxr)
    mcb_tlxr_xlt_s1_bit_map (0 to 4)    => mcb_tlxr_xlt_s1_bit_map (0 to 4)   , -- MSR: cb_tlxr_mac(tlxr)
    mcb_tlxr_xlt_s2_bit_map (0 to 4)    => mcb_tlxr_xlt_s2_bit_map (0 to 4)   , -- MSR: cb_tlxr_mac(tlxr)
    mcb_tlxr_xlt_slot0_m0_valid         => mcb_tlxr_xlt_slot0_m0_valid        , -- MSR: cb_tlxr_mac(tlxr)
    mcb_tlxr_xlt_slot0_m1_valid         => mcb_tlxr_xlt_slot0_m1_valid        , -- MSR: cb_tlxr_mac(tlxr)
    mcb_tlxr_xlt_slot0_r15_valid        => mcb_tlxr_xlt_slot0_r15_valid       , -- MSR: cb_tlxr_mac(tlxr)
    mcb_tlxr_xlt_slot0_r16_valid        => mcb_tlxr_xlt_slot0_r16_valid       , -- MSR: cb_tlxr_mac(tlxr)
    mcb_tlxr_xlt_slot0_r17_valid        => mcb_tlxr_xlt_slot0_r17_valid       , -- MSR: cb_tlxr_mac(tlxr)
    mcb_tlxr_xlt_slot0_s0_valid         => mcb_tlxr_xlt_slot0_s0_valid        , -- MSR: cb_tlxr_mac(tlxr)
    mcb_tlxr_xlt_slot0_s1_valid         => mcb_tlxr_xlt_slot0_s1_valid        , -- MSR: cb_tlxr_mac(tlxr)
    mcb_tlxr_xlt_slot0_s2_valid         => mcb_tlxr_xlt_slot0_s2_valid        , -- MSR: cb_tlxr_mac(tlxr)
    mcb_tlxr_xlt_slot1_m0_valid         => mcb_tlxr_xlt_slot1_m0_valid        , -- MSR: cb_tlxr_mac(tlxr)
    mcb_tlxr_xlt_slot1_m1_valid         => mcb_tlxr_xlt_slot1_m1_valid        , -- MSR: cb_tlxr_mac(tlxr)
    mcb_tlxr_xlt_slot1_r15_valid        => mcb_tlxr_xlt_slot1_r15_valid       , -- MSR: cb_tlxr_mac(tlxr)
    mcb_tlxr_xlt_slot1_r16_valid        => mcb_tlxr_xlt_slot1_r16_valid       , -- MSR: cb_tlxr_mac(tlxr)
    mcb_tlxr_xlt_slot1_r17_valid        => mcb_tlxr_xlt_slot1_r17_valid       , -- MSR: cb_tlxr_mac(tlxr)
    mcb_tlxr_xlt_slot1_s0_valid         => mcb_tlxr_xlt_slot1_s0_valid        , -- MSR: cb_tlxr_mac(tlxr)
    mcb_tlxr_xlt_slot1_s1_valid         => mcb_tlxr_xlt_slot1_s1_valid        , -- MSR: cb_tlxr_mac(tlxr)
    mcb_tlxr_xlt_slot1_s2_valid         => mcb_tlxr_xlt_slot1_s2_valid        , -- MSR: cb_tlxr_mac(tlxr)
    mmio_tlxr_resp_code (3 downto 0)    => mmio_tlxr_resp_code (3 downto 0)   , -- MSR: cb_tlxr_mac(tlxr)
    mmio_tlxr_wr_buf_free               => mmio_tlxr_wr_buf_free              , -- MSR: cb_tlxr_mac(tlxr)
    mmio_tlxr_wr_buf_par                => mmio_tlxr_wr_buf_par               , -- MSR: cb_tlxr_mac(tlxr)
    mmio_tlxr_wr_buf_tag (5 downto 0)   => mmio_tlxr_wr_buf_tag (5 downto 0)  , -- MSR: cb_tlxr_mac(tlxr)
    srq_tlxr_wdone_last                 => srq_tlxr_wdone_last                , -- MSR: cb_tlxr_mac(tlxr)
    srq_tlxr_wdone_p                    => srq_tlxr_wdone_p                   , -- MSR: cb_tlxr_mac(tlxr)
    srq_tlxr_wdone_tag (0 to 5)         => srq_tlxr_wdone_tag (0 to 5)        , -- MSR: cb_tlxr_mac(tlxr)
    srq_tlxr_wdone_val                  => srq_tlxr_wdone_val                 , -- MSR: cb_tlxr_mac(tlxr)
    tlxr_dbg_debug_bus                  => tlxr_dbg_debug_bus (0 to 87)       , -- MSR: cb_tlxr_mac(tlxr)
    srq_tlxr_epow                       => srq_tlxr_epow                      , -- MSD: cb_tlxr_mac(tlx
    tlxr_srq_cmd (0 to 63)              => tlxr_srq_cmd (0 to 63)             , -- MSD: cb_tlxr_mac(tlxr)
    tlxr_srq_cmd_val                    => tlxr_srq_cmd_val                   , -- MSD: cb_tlxr_mac(tlxr)
    tlxr_srq_fast_act_val               => tlxr_srq_fast_act_val              , -- MSD: cb_tlxr_mac(tlxr)
    tlxr_srq_fast_addr (0 to 26)        => tlxr_srq_fast_addr (0 to 26)       , -- MSD: cb_tlxr_mac(tlxr)
    tlxr_srq_fast_dimm                  => tlxr_srq_fast_dimm                 , -- MSR: cb_srq_mac(srq)
    tlxr_srq_fast_act_val_a             => tlxr_srq_fast_act_val_a              , -- MSD: cb_tlxr_mac(tlxr)
    tlxr_srq_fast_addr_a (0 to 26)      => tlxr_srq_fast_addr_a (0 to 26)       , -- MSD: cb_tlxr_mac(tlxr)
    tlxr_srq_fast_dimm_a                => tlxr_srq_fast_dimm_a                 , -- MSR: cb_srq_mac(srq)
    tlxr_srq_fast_act_val_b             => tlxr_srq_fast_act_val_b              , -- MSD: cb_tlxr_mac(tlxr)
    tlxr_srq_fast_addr_b (0 to 26)      => tlxr_srq_fast_addr_b (0 to 26)       , -- MSD: cb_tlxr_mac(tlxr)
    tlxr_srq_fast_dimm_b                => tlxr_srq_fast_dimm_b                 , -- MSR: cb_srq_mac(srq)
    tlxr_srq_memcntl_req                => tlxr_srq_memcntl_req               , -- MSR: cb_tlxr_mac(tlxr)
    tlxr_srq_memcntl_cmd_flag (0 to 3)  => tlxr_srq_memcntl_cmd_flag (0 to 3) , -- MSR: cb_tlxr_mac(tlxr)
    tlxr_srq_wrbuf_crcval_vec (0 to 63) => tlxr_srq_wrbuf_crcval_vec (0 to 63), -- MSD: cb_tlxr_mac(tlxr)
    tlxr_tlxt_consume_dcp1 (2 downto 0) => tlxr_tlxt_consume_dcp1 (2 downto 0), -- MSD: cb_tlxr_mac(tlxr)
    tlxr_tlxt_consume_vc0               => tlxr_tlxt_consume_vc0              , -- MSD: cb_tlxr_mac(tlxr)
    tlxr_tlxt_consume_vc1               => tlxr_tlxt_consume_vc1              , -- MSD: cb_tlxr_mac(tlxr)
    tlxr_tlxt_dcp1_release (2 downto 0) => tlxr_tlxt_dcp1_release (2 downto 0), -- MSD: cb_tlxr_mac(tlxr)
    tlxr_tlxt_errors                    => tlxr_tlxt_errors (63 downto 0)     , -- MSD: cb_tlxr_mac(tlxr)
    tlxr_tlxt_vc0_release (1 downto 0)  => tlxr_tlxt_vc0_release (1 downto 0) , -- MSD: cb_tlxr_mac(tlxr)
    tlxr_tlxt_vc1_release               => tlxr_tlxt_vc1_release              , -- MSD: cb_tlxr_mac(tlxr)
    tlxr_tlxt_return_dcp0 (5 downto 0)  => tlxr_tlxt_return_dcp0 (5 downto 0) , -- MSD: cb_tlxr_mac(tlxr)
    tlxr_tlxt_return_dcp3 (5 downto 0)  => tlxr_tlxt_return_dcp3 (5 downto 0) , -- MSD: cb_tlxr_mac(tlxr)
    tlxr_tlxt_return_val                => tlxr_tlxt_return_val               , -- MSD: cb_tlxr_mac(tlxr)
    tlxr_tlxt_return_vc0 (3 downto 0)   => tlxr_tlxt_return_vc0 (3 downto 0)  , -- MSD: cb_tlxr_mac(tlxr)
    tlxr_tlxt_return_vc3 (3 downto 0)   => tlxr_tlxt_return_vc3 (3 downto 0)  , -- MSD: cb_tlxr_mac(tlxr)
    tlxr_tlxt_write_resp (21 downto 0)  => tlxr_tlxt_write_resp (21 downto 0) , -- MSD: cb_tlxr_mac(tlxr)
    tlxr_tlxt_write_resp_p (2 downto 0) => tlxr_tlxt_write_resp_p (2 downto 0), -- MSD: cb_tlxr_mac(tlxr)
    tlxr_tlxt_write_resp_val            => tlxr_tlxt_write_resp_val           , -- MSD: cb_tlxr_mac(tlxr)
    tlxr_tlxt_intrp_resp (7 downto 0)   => tlxr_tlxt_intrp_resp (7 downto 0)  , -- MSD: cb_tlxr_mac(tlxr)
    tlxr_tlxt_signature_dat(63 downto 0)   => tlxr_tlxt_signature_dat(63 downto 0) , -- std_ulogic_vector(0 TO 63);
    tlxr_tlxt_signature_strobe             => tlxr_tlxt_signature_strobe           , --    : IN std_ulogic;
    tlxr_tp_fir_trace_err               => tlxr_tp_fir_trace_err              , -- MSD: cb_tlxr_mac(tlxr)
    tlxr_wdf_be (0 to 71)               => tlxr_wdf_be (0 to 71)              , -- MSD: cb_tlxr_mac(tlxr)
    tlxr_wdf_be_wptr (0 to 5)           => tlxr_wdf_be_wptr (0 to 5)          , -- MSD: cb_tlxr_mac(tlxr)
    tlxr_wdf_be_wr                      => tlxr_wdf_be_wr                     , -- MSD: cb_tlxr_mac(tlxr)
    tlxr_wdf_be_wr_p                    => tlxr_wdf_be_wr_p                   , -- MSD: cb_tlxr_mac(tlxr)
    tlxr_wdf_wrbuf_bad (0 to 64)        => tlxr_wdf_wrbuf_bad (0 to 64)       , -- MSD: cb_tlxr_mac(tlxr)
    tlxr_wdf_wrbuf_dat (0 to 145)       => tlxr_wdf_wrbuf_dat (0 to 145)      , -- MSD: cb_tlxr_mac(tlxr)
    tlxr_wdf_wrbuf_woffset (0 to 1)     => tlxr_wdf_wrbuf_woffset (0 to 1)    , -- MSD: cb_tlxr_mac(tlxr)
    tlxr_wdf_wrbuf_wptr (0 to 5)        => tlxr_wdf_wrbuf_wptr (0 to 5)       , -- MSD: cb_tlxr_mac(tlxr)
    tlxr_wdf_wrbuf_wr                   => tlxr_wdf_wrbuf_wr                  , -- MSD: cb_tlxr_mac(tlxr)
    tlxr_wdf_wrbuf_wr_p                 => tlxr_wdf_wrbuf_wr_p                , -- MSD: cb_tlxr_mac(tlxr)
    tlxt_tlxr_wr_resp_full              => tlxt_tlxr_wr_resp_full             , -- MSR: cb_tlxr_mac(tlxr)
    tlxt_tlxr_early_wdone_disable       => tlxt_tlxr_early_wdone_disable      , -- MSR: cb_tlxr_mac(tlxr)
    tlxt_tlxr_control                   => tlxt_tlxr_control                  , -- MSR: cb_tlxr_mac(tlxr)
    tlxt_tlxr_low_lat_mode              => tlxt_tlxr_low_lat_mode             ,
    trc_master_clock_enable             => trc_master_clock_enable            , -- MSR: cb_tlxr_mac(tlxr)
    vdd                                 => vdd                                , -- MSB: cb_tlxr_mac(tlxr)
    srq_tlxr_fast_act_fifo_next         => srq_tlxr_fast_act_fifo_next        ,
    srq_tlxr_fast_act_fifo_drain        => srq_tlxr_fast_act_fifo_drain       ,
    tlxr_srq_fast_act_fifo_val_a          => tlxr_srq_fast_act_fifo_val_a         ,
    tlxr_srq_fast_act_fifo_addr_a         => tlxr_srq_fast_act_fifo_addr_a        ,
    tlxr_srq_fast_act_fifo_dimm_a         => tlxr_srq_fast_act_fifo_dimm_a        ,
    tlxr_srq_fast_act_fifo_row_bank_par_a => tlxr_srq_fast_act_fifo_row_bank_par_a,
    tlxr_srq_fast_act_fifo_rank_par_a     => tlxr_srq_fast_act_fifo_rank_par_a,
    tlxr_srq_fast_act_fifo_val_b          => tlxr_srq_fast_act_fifo_val_b         ,
    tlxr_srq_fast_act_fifo_addr_b         => tlxr_srq_fast_act_fifo_addr_b        ,
    tlxr_srq_fast_act_fifo_dimm_b         => tlxr_srq_fast_act_fifo_dimm_b        ,
    tlxr_srq_fast_act_fifo_row_bank_par_b => tlxr_srq_fast_act_fifo_row_bank_par_b,
    tlxr_srq_fast_act_fifo_rank_par_b     => tlxr_srq_fast_act_fifo_rank_par_b,
    tlxr_srq_fast_act_fifo_val          => tlxr_srq_fast_act_fifo_val         ,
    tlxr_srq_fast_act_fifo_addr         => tlxr_srq_fast_act_fifo_addr        ,
    tlxr_srq_fast_act_fifo_dimm         => tlxr_srq_fast_act_fifo_dimm        ,
    tlxr_srq_fast_act_fifo_row_bank_par => tlxr_srq_fast_act_fifo_row_bank_par,
    tlxr_srq_fast_act_fifo_rank_par     => tlxr_srq_fast_act_fifo_rank_par
);


end omi;
