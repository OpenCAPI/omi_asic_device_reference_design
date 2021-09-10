// *!***************************************************************************
// *! Copyright 2019 International Business Machines
// *!
// *! Licensed under the Apache License, Version 2.0 (the "License");
// *! you may not use this file except in compliance with the License.
// *! You may obtain a copy of the License at
// *! http://www.apache.org/licenses/LICENSE-2.0 
// *!
// *! The patent license granted to you in Section 3 of the License, as applied
// *! to the "Work," hereby includes implementations of the Work in physical form.  
// *!
// *! Unless required by applicable law or agreed to in writing, the reference design
// *! distributed under the License is distributed on an "AS IS" BASIS,
// *! WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// *! See the License for the specific language governing permissions and
// *! limitations under the License.
// *! 
// *! The background Specification upon which this is based is managed by and available from
// *! the OpenCAPI Consortium.  More information can be found at https://opencapi.org. 
// *!***************************************************************************
`timescale 100ps/10ps
//-- *!********************************************************************
//-- *!           
//-- *!******************************************************************
module dlc_omi_tx_train #(
parameter             RX_EQ_TX_CLK = 0
) (

  dl_phy_run_lane_0             //--  output
 ,dl_phy_run_lane_1             //--  output
 ,dl_phy_run_lane_2             //--  output
 ,dl_phy_run_lane_3             //--  output
 ,dl_phy_run_lane_4             //--  output
 ,dl_phy_run_lane_5             //--  output
 ,dl_phy_run_lane_6             //--  output
 ,dl_phy_run_lane_7             //--  output
 ,phy_dl_init_done_0            //--  input
 ,phy_dl_init_done_1            //--  input
 ,phy_dl_init_done_2            //--  input
 ,phy_dl_init_done_3            //--  input
 ,phy_dl_init_done_4            //--  input
 ,phy_dl_init_done_5            //--  input
 ,phy_dl_init_done_6            //--  input
 ,phy_dl_init_done_7            //--  input
 ,dl_phy_recal_req_0            //--  output                //--  new ports for power management
 ,dl_phy_recal_req_1            //--  output                //--  new ports for power management
 ,dl_phy_recal_req_2            //--  output                //--  new ports for power management
 ,dl_phy_recal_req_3            //--  output                //--  new ports for power management
 ,dl_phy_recal_req_4            //--  output                //--  new ports for power management
 ,dl_phy_recal_req_5            //--  output                //--  new ports for power management
 ,dl_phy_recal_req_6            //--  output                //--  new ports for power management
 ,dl_phy_recal_req_7            //--  output                //--  new ports for power management
 ,phy_dl_recal_done_0           //--  input                //--  new ports for power management
 ,phy_dl_recal_done_1           //--  input                //--  new ports for power management
 ,phy_dl_recal_done_2           //--  input                //--  new ports for power management
 ,phy_dl_recal_done_3           //--  input                //--  new ports for power management
 ,phy_dl_recal_done_4           //--  input                //--  new ports for power management
 ,phy_dl_recal_done_5           //--  input                //--  new ports for power management
 ,phy_dl_recal_done_6           //--  input                //--  new ports for power management
 ,phy_dl_recal_done_7           //--  input                //--  new ports for power management
 ,dl_phy_rx_psave_req_0         //--  output                //--  new ports for power management
 ,dl_phy_rx_psave_req_1         //--  output                //--  new ports for power management
 ,dl_phy_rx_psave_req_2         //--  output                //--  new ports for power management
 ,dl_phy_rx_psave_req_3         //--  output                //--  new ports for power management
 ,dl_phy_rx_psave_req_4         //--  output                //--  new ports for power management
 ,dl_phy_rx_psave_req_5         //--  output                //--  new ports for power management
 ,dl_phy_rx_psave_req_6         //--  output                //--  new ports for power management
 ,dl_phy_rx_psave_req_7         //--  output                //--  new ports for power management
 ,phy_dl_rx_psave_sts_0         //--  input                //--  new ports for power management
 ,phy_dl_rx_psave_sts_1         //--  input                //--  new ports for power management
 ,phy_dl_rx_psave_sts_2         //--  input                //--  new ports for power management
 ,phy_dl_rx_psave_sts_3         //--  input                //--  new ports for power management
 ,phy_dl_rx_psave_sts_4         //--  input                //--  new ports for power management
 ,phy_dl_rx_psave_sts_5         //--  input                //--  new ports for power management
 ,phy_dl_rx_psave_sts_6         //--  input                //--  new ports for power management
 ,phy_dl_rx_psave_sts_7         //--  input                //--  new ports for power management
 ,dl_phy_tx_psave_req_0         //--  output                //--  new ports for power management
 ,dl_phy_tx_psave_req_1         //--  output                //--  new ports for power management
 ,dl_phy_tx_psave_req_2         //--  output                //--  new ports for power management
 ,dl_phy_tx_psave_req_3         //--  output                //--  new ports for power management
 ,dl_phy_tx_psave_req_4         //--  output                //--  new ports for power management
 ,dl_phy_tx_psave_req_5         //--  output                //--  new ports for power management
 ,dl_phy_tx_psave_req_6         //--  output                //--  new ports for power management
 ,dl_phy_tx_psave_req_7         //--  output                //--  new ports for power management
 ,phy_dl_tx_psave_sts_0         //--  input                //--  new ports for power management
 ,phy_dl_tx_psave_sts_1         //--  input                //--  new ports for power management
 ,phy_dl_tx_psave_sts_2         //--  input                //--  new ports for power management
 ,phy_dl_tx_psave_sts_3         //--  input                //--  new ports for power management
 ,phy_dl_tx_psave_sts_4         //--  input                //--  new ports for power management
 ,phy_dl_tx_psave_sts_5         //--  input                //--  new ports for power management
 ,phy_dl_tx_psave_sts_6         //--  input                //--  new ports for power management
 ,phy_dl_tx_psave_sts_7         //--  input                //--  new ports for power management
                        
//-- signals between the RX and TX
 ,rx_tx_recal_status            //--  input   [1:0]      //--  new ports for power management
 ,rx_tx_pm_status               //--  input   [3:0]      //--  new ports for power management
 ,rx_tx_crc_error               //--  input
 ,rx_tx_nack                    //--  input
 ,rx_tx_data_flt                //--  input
 ,rx_tx_ctl_flt                 //--  input
 ,rx_tx_rpl_flt                 //--  input
 ,rx_tx_idle_flt                //--  input
 ,rx_tx_ill_rl                  //--  input
 ,rx_tx_slow_clock              //--  input
 ,rx_tx_deskew_overflow         //--  input
 ,rx_tx_rmt_error               //--  input  [7:0]
 ,rx_tx_rmt_message             //--  input  [63:0]
 ,rx_tx_dbg_rx_info             //--  input  [87:0]
 ,tx_rx_macro_dbg_sel           //--  output [3:0]
 ,rx_tx_iobist_prbs_error       //--  input  [7:0]
 ,tx_rx_reset_n                 //--  output
 ,tx_rx_tsm                     //--  output [2:0]
 ,tx_rx_phy_init_done           //--  output [7:0]
 ,rx_tx_version_number          //--  input  [5:0]
 ,rx_tx_train_status            //--  input  [72:0]
 ,rx_tx_disabled_rx_lanes       //--  input  [7:0]
 ,rx_tx_disabled_tx_lanes       //--  input  [7:0]
 ,rx_tx_ts_valid                //--  input
 ,rx_tx_ts_good_lanes           //--  input  [15:0]
 ,rx_tx_deskew_config_valid     //--  input
 ,rx_tx_deskew_config           //--  input [18:0]
 ,rx_tx_tx_ordering             //--  input  
 ,rx_tx_rem_supported_widths    //--  input  [3:0]
 ,rx_tx_trained_mode            //--  input  [3:0]
 ,tx_rx_cfg_supported_widths    //--  output [3:0]
 ,rx_tx_tx_lane_swap            //--  input
 ,rx_tx_rem_PM_enable           //--  input
 ,rx_tx_rx_lane_reverse         //--  input
 ,rx_tx_lost_data_sync          //--  input
 ,rx_tx_trn_dbg                 //--  input [87:0]
 ,rx_tx_training_sync_hdr       //--  input
 ,rx_tx_EDPL_max_cnts           //--  input [63:0]
 ,rx_tx_EDPL_errors             //--  input [7:0]
 ,rx_tx_EDPL_thres_reached      //--  input [7:0]
 ,tx_rx_EDPL_cfg                //--  output [4:0]
 ,tx_rx_cfg_patA_length         //--  output [1:0]
 ,tx_rx_cfg_patB_length         //--  output [1:0]
 ,tx_rx_cfg_patA_hyst           //--  output [3:0]
 ,tx_rx_cfg_patB_hyst           //--  output [3:0]
 ,tx_rx_rx_BEI_inject           //--  output [7:0]
 ,tx_rx_inj_pty_err             //--  output
 ,rx_tx_mn_trn_in_replay        //--  input
 ,tx_rx_start_retrain           //--  output
 ,tx_rx_half_width              //--  output
 ,tx_rx_quarter_width           //--  output
 ,tx_rx_cfg_disable_rx_lanes    //--  output [7:0]
 ,tx_rx_PM_rx_lanes_disable     //--  output [7:0]
 ,tx_rx_PM_rx_lanes_enable      //--  output [7:0]
 ,tx_rx_PM_deskew_reset         //--  output
 ,tx_rx_psave_sts_off           //--  output
 ,tx_rx_retrain_not_due2_PM     //--  output
 ,tx_rx_cfg_version             //--  output [5:0]
 ,tx_rx_enable_short_idle       //--  output
 ,tx_rx_cfg_sync_mode           //--  output
 ,tx_rx_sim_only_fast_train     //--  output
 ,tx_rx_sim_only_request_ln_rev //--  output
 ,tl2dl_lane_width_request      //--  input[1:0]                 //--  new ports for power management
 ,dl2tl_lane_width_status       //--  output[1:0]                //--  new ports for power management
//-- reg interface
 ,reg_dl_config0                //--  input  [63:0]
 ,reg_dl_config1                //--  input  [63:0]
 ,reg_dl_error_message          //--  input  [3:0]
 ,reg_dl_link_down              //--  input
 ,reg_dl_cya_bits               //--  input  [31:0]
 ,flt_trn_reset_hammer          //--  input
 ,flt_trn_retrain_hammer        //--  input
 ,flt_trn_retrain_rply          //--  input
 ,flt_trn_retrain_no_rply       //--  input


 ,dl_reg_errors                 //--  output [47:0]
 ,dl_reg_error_capture          //--  output [62:0]
//-- threshold register?                         
 ,dl_reg_status                 //--  output [63:0]
 ,dl_reg_training_status        //--  output [63:0]
 ,dl_reg_edpl_max_count         //--  output [63:0]
//-- remote config?                          
 ,dl_reg_rmt_message            //--  output [63:0]
 ,dl_reg_trace_data             //--  output [87:0]
 ,dl_reg_trace_trig             //--  output [1:0]
 ,dl_reg_perf_mon               //--  output [11:0]
 ,dl_phy_iobist_prbs_error      //--  output [7:0]
 ,reg_dl_err_cap_reset          //--  input 

 ,tl2dl_tl_error                //--  input
 ,tl2dl_tl_event                //--  input
//-- signals with flit
 ,trn_flt_train_done            //--  output 
 ,trn_flt_tsm4                  //--  output
 ,trn_flt_x2_tx_mode            //--  output                             //--  new ports for power management                            
 ,trn_flt_x4_tx_mode            //--  output                             //--  new ports for power management                            
 ,trn_flt_x8_tx_mode            //--  output                             //--  new ports for power management                            
 ,trn_flt_recal_state           //--  output  [1:0]      //--  new ports for power management
 ,trn_flt_send_pm_msg           //--  output 
 ,trn_flt_pm_narrow_not_wide    //--  output              only valid when trn_flt_send_pm_msg is active (high)
 ,flt_trn_pm_msg_sent           //--  input
 ,trn_flt_pm_msg                //--  output  [3:0]      //--  new ports for power management

 ,trn_flt_stall                 //--  output                         
 ,trn_flt_real_stall            //--  output
 ,trn_flt_link_errors           //--  output [7:0]
 ,trn_flt_enable_short_idle     //--  output
 ,trn_flt_enable_fast_path      //--  output
 ,trn_flt_inj_ecc_ce            //--  output
 ,trn_flt_inj_ecc_ue            //--  output
 ,trn_flt_rpb_rm_depth          //--  output [3:0]
 ,trn_flt_1us_tick              //--  output
 ,trn_flt_tl_credits            //--  output [5:0]
 ,trn_flt_macro_dbg_sel         //--  output [3:0]
 ,flt_trn_in_replay             //--  input
 ,all_tx_credits_returned       //--  input
 ,flt_trn_no_fwd_prog           //--  input
 ,flt_trn_fp_start              //--  input
 ,flt_trn_rpl_data_flt          //--  input
 ,flt_trn_data_flt              //--  input
 ,flt_trn_ctl_flt               //--  input
 ,flt_trn_rpl_flt               //--  input
 ,flt_trn_idle_flt              //--  input
 ,flt_trn_ue_rpb_df             //--  input
 ,flt_trn_ue_frb_df             //--  input
 ,flt_trn_ce_rpb                //--  input
 ,flt_trn_ce_frb                //--  input
 ,flt_trn_data_pty_err          //--  input
 ,flt_trn_tl_trunc              //--  input
 ,flt_trn_tl_rl_err             //--  input
 ,flt_trn_ack_ptr_err           //--  input
 ,flt_trn_ue_rpb_cf             //--  input
 ,flt_trn_ue_frb_cf             //--  input
 ,flt_trn_dbg_tx_info           //--  input [87:0]

//-- signals to align
 ,trn_agn_train_done            //--  output
 ,trn_agn_half_width            //--  output
 ,trn_agn_ln_swap               //--  output
 ,trn_agn_x2_mode               //--  output [1:0]
 ,trn_agn_x4_mode               //--  output [1:0]
 ,trn_agn_training              //--  output 
 ,trn_agn_training_set          //--  output [127:0]
 ,trn_agn_stall                 //--  output                         
 ,trn_agn_send_TS1              //--  output [7:0]
 ,trn_agn_PM_store_reset        //--  output
                        
//-- signals to lane
 ,trn_ln0_scrambler             //--  output [15:0]                       
 ,trn_ln1_scrambler             //--  output [15:0]                       
 ,trn_ln2_scrambler             //--  output [15:0]                       
 ,trn_ln3_scrambler             //--  output [15:0]                       
 ,trn_ln4_scrambler             //--  output [15:0]                       
 ,trn_ln5_scrambler             //--  output [15:0]                       
 ,trn_ln6_scrambler             //--  output [15:0]                       
 ,trn_ln7_scrambler             //--  output [15:0]                       
 ,trn_ln_train_data             //--  output [15:0]                       
 ,trn_ln_reverse                //--  output                         
 ,trn_ln_disable                //--  output [7:0]
 ,trn_ln_phy_training           //--  output [7:0]
 ,trn_ln_dl_training            //--  output [7:0]
 ,trn_ln_tx_EDPL_ena            //--  output
 ,trn_ln_tx_BEI_inject          //--  output [7:0]
 ,trn_reset_n                   //--  output                         
 ,trn_enable                    //--  output
 ,reg_dl_edpl_max_count_reset   //--  input
 ,reg_dl_1us_tick               //--  input
 ,reg_dl_100ms_tick             //--  input
 ,reg_dl_recal_start            //--  input                //--  new ports for power management
 ,global_trace_enable           //--  input
 ,omi_enable_out                //--  output
 ,chip_reset                    //--  input
 ,global_reset_control          //--  input
 ,sync_mode                     //--  input
 ,dl_clk                        //--  input
);


output             dl_phy_run_lane_0; 
output             dl_phy_run_lane_1; 
output             dl_phy_run_lane_2; 
output             dl_phy_run_lane_3; 
output             dl_phy_run_lane_4; 
output             dl_phy_run_lane_5; 
output             dl_phy_run_lane_6; 
output             dl_phy_run_lane_7; 
input              phy_dl_init_done_0;
input              phy_dl_init_done_1;
input              phy_dl_init_done_2;
input              phy_dl_init_done_3;
input              phy_dl_init_done_4;
input              phy_dl_init_done_5;
input              phy_dl_init_done_6;
input              phy_dl_init_done_7;
output            dl_phy_recal_req_0;
output            dl_phy_recal_req_1;
output            dl_phy_recal_req_2;
output            dl_phy_recal_req_3;
output            dl_phy_recal_req_4;
output            dl_phy_recal_req_5;
output            dl_phy_recal_req_6;
output            dl_phy_recal_req_7;
input             phy_dl_recal_done_0;
input             phy_dl_recal_done_1;
input             phy_dl_recal_done_2;
input             phy_dl_recal_done_3;
input             phy_dl_recal_done_4;
input             phy_dl_recal_done_5;
input             phy_dl_recal_done_6;
input             phy_dl_recal_done_7;
output            dl_phy_rx_psave_req_0;
output            dl_phy_rx_psave_req_1;
output            dl_phy_rx_psave_req_2;
output            dl_phy_rx_psave_req_3;
output            dl_phy_rx_psave_req_4;
output            dl_phy_rx_psave_req_5;
output            dl_phy_rx_psave_req_6;
output            dl_phy_rx_psave_req_7;
input             phy_dl_rx_psave_sts_0;
input             phy_dl_rx_psave_sts_1;
input             phy_dl_rx_psave_sts_2;
input             phy_dl_rx_psave_sts_3;
input             phy_dl_rx_psave_sts_4;
input             phy_dl_rx_psave_sts_5;
input             phy_dl_rx_psave_sts_6;
input             phy_dl_rx_psave_sts_7;
output            dl_phy_tx_psave_req_0;
output            dl_phy_tx_psave_req_1;
output            dl_phy_tx_psave_req_2;
output            dl_phy_tx_psave_req_3;
output            dl_phy_tx_psave_req_4;
output            dl_phy_tx_psave_req_5;
output            dl_phy_tx_psave_req_6;
output            dl_phy_tx_psave_req_7;
input             phy_dl_tx_psave_sts_0;
input             phy_dl_tx_psave_sts_1;
input             phy_dl_tx_psave_sts_2;
input             phy_dl_tx_psave_sts_3;
input             phy_dl_tx_psave_sts_4;
input             phy_dl_tx_psave_sts_5;
input             phy_dl_tx_psave_sts_6;
input             phy_dl_tx_psave_sts_7;

input [1:0]        rx_tx_recal_status;
input [3:0]        rx_tx_pm_status;
input              rx_tx_crc_error;
input              rx_tx_nack;
input              rx_tx_data_flt;
input              rx_tx_ctl_flt;
input              rx_tx_rpl_flt;
input              rx_tx_idle_flt;
input              rx_tx_ill_rl;
input              rx_tx_slow_clock;
input              rx_tx_deskew_overflow;
input  [7:0]       rx_tx_rmt_error;
input  [63:0]      rx_tx_rmt_message;
input  [87:0]      rx_tx_dbg_rx_info;
output [3:0]       tx_rx_macro_dbg_sel;
input  [7:0]       rx_tx_iobist_prbs_error;
output             tx_rx_reset_n;
output [2:0]       tx_rx_tsm;
output [7:0]       tx_rx_phy_init_done;
input  [5:0]       rx_tx_version_number;
input  [72:0]      rx_tx_train_status;
input  [7:0]       rx_tx_disabled_rx_lanes;
input  [7:0]       rx_tx_disabled_tx_lanes;
input              rx_tx_ts_valid;
input  [15:0]      rx_tx_ts_good_lanes;
input              rx_tx_deskew_config_valid;
input  [18:0]      rx_tx_deskew_config;
input              rx_tx_tx_ordering;
input  [3:0]       rx_tx_rem_supported_widths;
input  [3:0]       rx_tx_trained_mode;
output [3:0]       tx_rx_cfg_supported_widths;
input              rx_tx_tx_lane_swap;
input              rx_tx_rem_PM_enable;
input              rx_tx_rx_lane_reverse;
input              rx_tx_lost_data_sync;
input  [87:0]      rx_tx_trn_dbg;
input              rx_tx_training_sync_hdr;
input  [63:0]      rx_tx_EDPL_max_cnts;
input  [7:0]       rx_tx_EDPL_errors;
input  [7:0]       rx_tx_EDPL_thres_reached;
output [4:0]       tx_rx_EDPL_cfg;
output [1:0]       tx_rx_cfg_patA_length;
output [1:0]       tx_rx_cfg_patB_length;
output [3:0]       tx_rx_cfg_patA_hyst;
output [3:0]       tx_rx_cfg_patB_hyst;
output [7:0]       tx_rx_rx_BEI_inject;
output             tx_rx_inj_pty_err;
input              rx_tx_mn_trn_in_replay;
output             tx_rx_start_retrain;
output             tx_rx_half_width;
output             tx_rx_quarter_width;
output [7:0]       tx_rx_cfg_disable_rx_lanes;
output [7:0]       tx_rx_PM_rx_lanes_disable;
output [7:0]       tx_rx_PM_rx_lanes_enable;
output             tx_rx_PM_deskew_reset;
output             tx_rx_psave_sts_off;
output             tx_rx_retrain_not_due2_PM;
output [5:0]       tx_rx_cfg_version;
output             tx_rx_enable_short_idle;
output             tx_rx_cfg_sync_mode;
output             tx_rx_sim_only_fast_train;
output             tx_rx_sim_only_request_ln_rev;

input  [1:0]       tl2dl_lane_width_request;
output [1:0]       dl2tl_lane_width_status;
input  [63:0]      reg_dl_config0;                 
input  [63:0]      reg_dl_config1;                 
input  [31:0]      reg_dl_cya_bits;
input              flt_trn_reset_hammer;
input              flt_trn_retrain_hammer;
input              flt_trn_retrain_rply;
input              flt_trn_retrain_no_rply;
input  [3:0]       reg_dl_error_message;
input              reg_dl_link_down;
input              tl2dl_tl_error;
input              tl2dl_tl_event;
output [47:0]      dl_reg_errors;                
output [63:0]      dl_reg_rmt_message;
output [63:0]      dl_reg_edpl_max_count;           
output [63:0]      dl_reg_status;                
output [63:0]      dl_reg_training_status;       
output [62:0]      dl_reg_error_capture;         
input              reg_dl_err_cap_reset;
output [1:0]       dl_reg_trace_trig;         
output [87:0]      dl_reg_trace_data;         
output [11:0]      dl_reg_perf_mon;         
output [7:0]       dl_phy_iobist_prbs_error;
output             trn_flt_train_done;
output             trn_flt_tsm4;
output             trn_flt_x2_tx_mode;
output             trn_flt_x4_tx_mode;
output             trn_flt_x8_tx_mode;
output [1:0]       trn_flt_recal_state;
output             trn_flt_send_pm_msg;
output             trn_flt_pm_narrow_not_wide;
input              flt_trn_pm_msg_sent;
output  [3:0]      trn_flt_pm_msg;
output             trn_flt_stall;
output             trn_flt_real_stall;
output [7:0]       trn_flt_link_errors;
output             trn_flt_enable_short_idle;
output             trn_flt_enable_fast_path;
output             trn_flt_inj_ecc_ce;
output             trn_flt_inj_ecc_ue;
output [3:0]       trn_flt_rpb_rm_depth;
output             trn_flt_1us_tick;
output [5:0]       trn_flt_tl_credits;
output [3:0]       trn_flt_macro_dbg_sel;
input              flt_trn_in_replay;
input              all_tx_credits_returned;
input              flt_trn_no_fwd_prog;
input              flt_trn_fp_start;
input              flt_trn_rpl_data_flt;
input              flt_trn_data_flt;
input              flt_trn_ctl_flt;
input              flt_trn_rpl_flt;
input              flt_trn_idle_flt;
input              flt_trn_ue_rpb_df;
input              flt_trn_ue_frb_df;
input              flt_trn_ce_rpb;
input              flt_trn_ce_frb;
input              flt_trn_data_pty_err;
input              flt_trn_tl_trunc;
input              flt_trn_tl_rl_err;
input              flt_trn_ack_ptr_err;
input              flt_trn_ue_rpb_cf;
input              flt_trn_ue_frb_cf; 

input [87:0]       flt_trn_dbg_tx_info;
output             trn_agn_train_done;
output             trn_agn_half_width;
output             trn_agn_ln_swap;
output [1:0]       trn_agn_x2_mode;
output [1:0]       trn_agn_x4_mode;
output             trn_agn_training;         
output [127:0]     trn_agn_training_set;
output             trn_agn_stall;                            
output [7:0]       trn_agn_send_TS1;
output             trn_agn_PM_store_reset;
output [15:0]      trn_ln0_scrambler;                             
output [15:0]      trn_ln1_scrambler;                             
output [15:0]      trn_ln2_scrambler;                             
output [15:0]      trn_ln3_scrambler;                             
output [15:0]      trn_ln4_scrambler;                             
output [15:0]      trn_ln5_scrambler;                             
output [15:0]      trn_ln6_scrambler;                             
output [15:0]      trn_ln7_scrambler;                             
output [15:0]      trn_ln_train_data;                             
output             trn_ln_reverse;
output [7:0]       trn_ln_disable;
output [7:0]       trn_ln_phy_training;
output [7:0]       trn_ln_dl_training;                                
output             trn_ln_tx_EDPL_ena;
output [7:0]       trn_ln_tx_BEI_inject;
output             trn_reset_n;  
output             trn_enable;
input              reg_dl_edpl_max_count_reset;
input              reg_dl_1us_tick;
input              reg_dl_100ms_tick;
input              reg_dl_recal_start;
input              global_trace_enable;
output             omi_enable_out;
input              chip_reset;
input              global_reset_control;
input              sync_mode;
input              dl_clk;


wire               act_dbg;
wire               act_fwd_prog_timer;
wire               act_omi_enable;
wire               adv_1to2;
wire               adv_2to3;
wire               adv_3to4;
wire               adv_4to5;
wire               adv_5to6;
wire               adv_6to7;
wire               BEI_inject_din;
wire               BEI_inject_q;
wire [20:0]        BEI_rate;
wire [20:0]        BEI_timer_din;
wire               BEI_timer_inc;
wire [20:0]        BEI_timer_q;
wire               BEI_timer_reset;
wire               block_locked_din;
wire               block_locked_q;
wire [62:0]        captured_info0;
wire [62:0]        captured_info1;
wire [62:0]        captured_info2;
wire [62:0]        captured_info3;
wire               cfg_BEI_ln_dir_din;
wire               cfg_BEI_ln_dir_q;
wire               cfg_BEI_ln_ena_din;
wire               cfg_BEI_ln_ena_q;
wire [2:0]         cfg_BEI_ln_rate_din;
wire [2:0]         cfg_BEI_ln_rate_q;
wire [2:0]         cfg_BEI_ln_sel_din;
wire [2:0]         cfg_BEI_ln_sel_q;
wire [31:0]        cfg_cya_bits_ena_din;
wire [31:0]        cfg_cya_bits_q;
wire               cfg_debug_ena_q;
wire [2:0]         cfg_debug_sel_din;
wire [2:0]         cfg_debug_sel_q;
wire [23:0]        cfg_deskew_ln0;
wire [23:0]        cfg_deskew_ln1;
wire [23:0]        cfg_deskew_ln2;
wire [23:0]        cfg_deskew_ln3;
wire [23:0]        cfg_deskew_ln4;
wire [23:0]        cfg_deskew_ln5;
wire [23:0]        cfg_deskew_ln6;
wire [23:0]        cfg_deskew_ln7;
wire               cfg_disable_fast_path_din;
wire               cfg_disable_fast_path_q;
wire               cfg_EDPL_ena_din;
wire               cfg_EDPL_ena_q;
wire [2:0]         cfg_EDPL_err_threshold_din;
wire [2:0]         cfg_EDPL_err_threshold_q;
wire [3:0]         cfg_EDPL_time_window_din;
wire [3:0]         cfg_EDPL_time_window_q;
wire               cfg_enable_tx_lane_swap_din;
wire               cfg_enable_tx_lane_swap_q;
wire [15:0]        cfg_good_lanes;
wire               cfg_inj_ctl_pty_din;
wire               cfg_inj_ctl_pty_dly_din;
wire               cfg_inj_ctl_pty_dly_q;
wire               cfg_inj_ctl_pty_q;
wire               cfg_inj_data_pty_din;
wire               cfg_inj_data_pty_dly_din;
wire               cfg_inj_data_pty_dly_q;
wire               cfg_inj_data_pty_q;
wire               cfg_inj_ecc_ce_din;
wire               cfg_inj_ecc_ce_dly_din;
wire               cfg_inj_ecc_ce_dly_q;
wire               cfg_inj_ecc_ce_q;
wire               cfg_inj_ecc_ue_din;
wire               cfg_inj_ecc_ue_dly_din;
wire               cfg_inj_ecc_ue_dly_q;
wire               cfg_inj_ecc_ue_q;
wire [3:0]         cfg_no_fwd_prog_timer_rate_din;
wire [3:0]         cfg_no_fwd_prog_timer_rate_q;
wire               cfg_omi_128_130_en_din;
wire               cfg_omi_128_130_en_q;
wire               cfg_omi_enable_din;
wire               cfg_omi_enable_q;
wire [3:0]         cfg_omi_phy_cntr_limit_din;
wire [3:0]         cfg_omi_phy_cntr_limit_q;
wire               cfg_omi_PM_enable_din;
wire               cfg_omi_PM_enable_q;
wire               cfg_omi_reset_din;
wire               cfg_omi_reset_q ;
wire               cfg_omi_retrain_din;
wire               cfg_omi_retrain_dly_din;
wire               cfg_omi_retrain_dly_q;
wire               cfg_omi_retrain_q;
wire [3:0]         cfg_omi_supported_widths_din;
wire [3:0]         cfg_omi_supported_widths_q;
wire [3:0]         cfg_omi_train_mode_din;
wire [3:0]         cfg_omi_train_mode_q;
wire               cfg_omi_run_lane_override_din;
wire               cfg_omi_run_lane_override_q;
wire [5:0]         cfg_omi_version_din;
wire [5:0]         cfg_omi_version_q;
wire               cfg_omi_quarter_width_enable_din;
wire               cfg_omi_quarter_width_enable_q;
wire               cfg_omi_half_width_enable_din;
wire               cfg_omi_half_width_enable_q;
wire [3:0]         cfg_patB_hyst_din;
wire [3:0]         cfg_patB_hyst_q;
wire [3:0]         cfg_patA_hyst_din;
wire [3:0]         cfg_patA_hyst_q;
wire [1:0]         cfg_patB_length_din;
wire [1:0]         cfg_patB_length_q;
wire [1:0]         cfg_patA_length_din;
wire [1:0]         cfg_patA_length_q;
wire [3:0]         cfg_rpb_rm_depth_din;
wire [3:0]         cfg_rpb_rm_depth_q;
wire [1:0]         cfg_rx_degraded_threshold_din;
wire [1:0]         cfg_rx_degraded_threshold_q;
wire [7:0]         cfg_rx_lanes_disable_din;
wire [7:0]         cfg_rx_lanes_disable_q;
wire               cfg_sync_mode_din;
wire               cfg_sync_mode_q;
wire               cfg_tl_error_afu_freeze_din;
wire               cfg_tl_error_afu_freeze_q;
wire               cfg_tl_error_all_freeze_din;
wire               cfg_tl_error_all_freeze_q;
wire               cfg_tl_error_ila_trigger_din;
wire               cfg_tl_error_ila_trigger_q;
wire               cfg_tl_error_link_down_din;
wire               cfg_tl_error_link_down_q;
wire               cfg_tl_event_afu_freeze_din;
wire               cfg_tl_event_afu_freeze_q;
wire               cfg_tl_event_all_freeze_din;
wire               cfg_tl_event_all_freeze_q;
wire               cfg_tl_event_ila_trigger_din;
wire               cfg_tl_event_ila_trigger_q;
wire               cfg_tl_event_link_down_din;
wire               cfg_tl_event_link_down_q;
wire               cfg_tx_a_pattern;
wire               cfg_tx_b_pattern;
wire [1:0]         cfg_tx_degraded_threshold_din;
wire [1:0]         cfg_tx_degraded_threshold_q;
wire [7:0]         cfg_tx_lanes_disable_din;
wire [7:0]         cfg_tx_lanes_disable_q;
wire               cfg_tx_sync_pattern;
wire               cfg_tx_zeros;
wire [10:0]        cfg_unused_din;
wire [10:0]        cfg_unused_q;
wire               ctl_parity_error_din;
wire               ctl_parity_error_q;
wire [1:0]         PM_cycle_din;
wire [1:0]         PM_cycle_q;
wire [1:0]         current_state_din;
wire [1:0]         current_state_q;
wire [5:0]         cycle_cnt_din;
wire [5:0]         cycle_cnt_q;
wire [87:0]        dbg_default_trace;
wire [87:0]        selected_dbg_trn_info;
wire [87:0]        dbg_trn_info0;
wire [87:0]        dbg_trn_info1;
wire [87:0]        dbg_trn_info2;
wire [87:0]        dbg_trn_info3;
wire [87:0]        dbg_trn_info4;
wire [87:0]        dbg_trn_info5;
wire [87:0]        dbg_trn_info6;
wire [87:0]        dbg_trn_info7;
wire [87:0]        dbg_trn_info8;
wire [87:0]        dbg_trn_info9;
wire [87:0]        dbg_trn_infoA;
wire [87:0]        dbg_trn_infoB;
wire [87:0]        dbg_trn_infoC;
wire [87:0]        dbg_trn_infoD;
wire [87:0]        dbg_trn_infoE;
wire [87:0]        dbg_trn_infoF;
wire [87:0]        debug_dbg_din;
wire [87:0]        debug_dbg_q;
wire               deskew_done;
wire [7:0]         disabled_tx_lanes_din;
wire [7:0]         disabled_tx_lanes_q;
wire [3:0]         disabled_tx_lanes_cnt;
wire               dl_phy_run_lane_0;
wire               dl_phy_run_lane_1;
wire               dl_phy_run_lane_2;
wire               dl_phy_run_lane_3;
wire               dl_phy_run_lane_4;
wire               dl_phy_run_lane_5;
wire               dl_phy_run_lane_6;
wire               dl_phy_run_lane_7;
wire [63:0]        dl_reg_status;
wire [63:0]        dl_reg_training_status;
wire [7:0]         EDPL_bad_lane_din;
wire [7:0]         EDPL_bad_lane_q;
wire [7:0]         EDPL_kill_lane_pend_din;
wire [7:0]         EDPL_kill_lane_pend_q;
wire               EDPL_reset_cnts_din;
wire               EDPL_reset_cnts_q ;
wire               EDPL_thres_reached_din;
wire               EDPL_thres_reached_q;
wire [44:0]        EDPL_time_window;
wire [43:0]        EDPL_timer_din;
wire               EDPL_timer_inc;
wire [43:0]        EDPL_timer_q;
wire               EDPL_timer_reset;
wire               ena_BEI_rx;
wire [7:0]         ena_BEI_rx_ln;
wire               ena_BEI_tx;
wire [7:0]         ena_BEI_tx_ln;
wire               sim_only_request_ln_rev;
wire               err_locked_din;
wire               err_locked_q;
wire [62:0]        error_capture_din;
wire [62:0]        error_capture_q;
wire [3:0]         errors_unused_din;
wire [3:0]         errors_unused_q;
wire               ts_x2_inner_din;
wire               ts_x2_inner_q;
wire [5:0]         fir_0_err;
wire               fir_0_fired;
wire [5:0]         fir_10_err;
wire               fir_10_fired;
wire [5:0]         fir_11_err;
wire               fir_11_fired;
wire [5:0]         fir_12_err;
wire               fir_12_fired;
wire [5:0]         fir_13_err;
wire               fir_13_fired;
wire [5:0]         fir_14_err;
wire               fir_14_fired;
wire [5:0]         fir_15_err;
wire               fir_15_fired;
wire [5:0]         fir_16_err;
wire               fir_16_fired;
wire [5:0]         fir_17_err;
wire               fir_17_fired;
wire [5:0]         fir_18_err;
wire               fir_18_fired;
wire [5:0]         fir_19_err;
wire               fir_19_fired;
wire [5:0]         fir_1_err;
wire               fir_1_fired;
wire [5:0]         fir_2_err;
wire               fir_2_fired;
wire [5:0]         fir_3_err;
wire               fir_3_fired;
wire [5:0]         fir_4_err;
wire               fir_4_fired;
wire [5:0]         fir_5_err;
wire               fir_5_fired;
wire [5:0]         fir_6_err;
wire               fir_6_fired;
wire [5:0]         fir_7_err;
wire               fir_7_fired;
wire [5:0]         fir_8_err;
wire               fir_8_fired;
wire [5:0]         fir_9_err;
wire               fir_9_fired;
wire               fir_fired;
wire [5:0]         first_error_din;
wire [5:0]         first_error_q;
wire               flt_trn_ack_ptr_err_din;
wire               flt_trn_ack_ptr_err_q;
wire               flt_trn_ce_frb_din;
wire               flt_trn_ce_frb_q;
wire               flt_trn_ce_rpb_din;
wire               flt_trn_ce_rpb_q;
wire               flt_trn_data_pty_err_din;
wire               flt_trn_data_pty_err_q;
wire               flt_trn_tl_rl_err_din;
wire               flt_trn_tl_rl_err_q;
wire               flt_trn_tl_trunc_din;
wire               flt_trn_tl_trunc_q;
wire               flt_trn_ue_frb_cf_din;
wire               flt_trn_ue_frb_cf_q;
wire               flt_trn_ue_frb_df_din;
wire               flt_trn_ue_frb_df_q;
wire               flt_trn_ue_rpb_cf_din;
wire               flt_trn_ue_rpb_cf_q;
wire               flt_trn_ue_rpb_df_din;
wire               flt_trn_ue_rpb_df_q;
wire               frame_vld_din;
wire               frame_vld_q;
wire               fwd_prog_fired_din;
wire               fwd_prog_fired_q;
wire [13:0]        fwd_prog_rate;
wire [13:0]        fwd_prog_timer_din;
wire               fwd_prog_timer_inc;
wire [13:0]        fwd_prog_timer_q;
wire               fwd_prog_timer_reset;
wire               inj_ctl_pty_err_din;
wire               inj_ctl_pty_err_q;
wire               inj_data_pty_err_din;
wire               inj_data_pty_err_q;
wire               inj_ecc_ce_din;
wire               inj_ecc_ce_q;
wire               inj_ecc_ue_din;
wire               inj_ecc_ue_q;
wire               incr_rx_deg_thres_cntr;
wire               incr_tx_deg_thres_cntr;
wire [1:0]         input_state;
wire               insert_deskew;
wire [4:0]         insert_deskew_ts_cnt_din;
wire [4:0]         insert_deskew_ts_cnt_q;
wire [7:0]         is_TS1;
wire [22:0]        lfsr_din;
wire [15:0]        lfsr_next_16;
wire [22:0]        lfsr_q;
wire               link_down_din;
wire               link_down_q;
wire [7:0]         ln_block_lock_din;
wire [7:0]         ln_block_lock_q;
wire [7:0]         ln_ctl_sync_hdr_din;
wire [7:0]         ln_ctl_sync_hdr_q;
wire [7:0]         ln_data_sync_hdr_din;
wire [7:0]         ln_data_sync_hdr_q;
wire [7:0]         ln_pattern_a_din;
wire [7:0]         ln_pattern_a_q;
wire [7:0]         ln_pattern_b_din;
wire [7:0]         ln_pattern_b_q;
wire [7:0]         ln_sync_din;
wire [7:0]         ln_sync_q;
wire [7:0]         ln_TS1_din;
wire [7:0]         ln_TS1_q;
wire [7:0]         ln_TS2_din;
wire [7:0]         ln_TS2_q;
wire [7:0]         ln_TS3_din;
wire [7:0]         ln_TS3_q;
wire               lost_block_lock_din;
wire               lost_block_lock_q;
wire               lost_data_sync_din;
wire               lost_data_sync_q;
wire               manual_adv;
wire               ts_x2_outer_din;
wire               ts_x2_outer_q;
wire               ts_x4_inner_din;
wire               ts_x4_inner_q;
wire [11:0]        perf_mon_din;
wire [11:0]        perf_mon_q;
wire [15:0]        phy_count_din;
wire [15:0]        phy_count_q;
wire [7:0]         phy_dl_init_done_din;
wire [7:0]         phy_dl_init_done_q;
wire               phy_init_done;
wire [15:0]        phy_limit;
wire               phy_limit_hit;
wire [8:0]         phy_training_d0_din;
wire [8:0]         phy_training_d0_q;
wire               phy_training_din;
wire               phy_training_q;
wire               reg_dl_100ms_tick_din;
wire               reg_dl_100ms_tick_q;
wire               reg_dl_1us_tick_din;
wire               reg_dl_1us_tick_q;
wire [18:0]        remote_deskew_cfg;
wire               remote_deskew_cfg_vld;
wire               remote_retrain_din;
wire               remote_retrain_q;
wire [15:0]        remote_ts_good_lanes;
wire               remote_ts_valid;
wire               request_lane_reverse_din;
wire               request_lane_reverse_q;
wire               reset;
wire               reset_rx_deg_thres_cntr;
wire               reset_tx_deg_thres_cntr;
wire               run_lane0_din;
wire               run_lane0_q;
wire               run_lane1_din;
wire               run_lane1_q;
wire               run_lane2_din;
wire               run_lane2_q;
wire               run_lane3_din;
wire               run_lane3_q;
wire               run_lane4_din;
wire               run_lane4_q;
wire               run_lane5_din;
wire               run_lane5_q;
wire               run_lane6_din;
wire               run_lane6_q;
wire               run_lane7_din;
wire               run_lane7_q;
wire [7:0]         run_lanes;
wire               rx_data_sync_hdr_din;
wire               rx_data_sync_hdr_q;
wire [22:0]        rx_deg_thres_cntr_din;
wire [22:0]        rx_deg_thres_cntr_q;
wire               rx_deg_thres_hit_din;
wire               rx_deg_thres_hit_q;
wire [22:0]        rx_degraded_threshold;
wire               rx_lane_reverse;
wire               rx_no_pattern_din;
wire               rx_no_pattern_q;
wire               rx_pattern_a_din;
wire               rx_pattern_a_done;
wire               rx_pattern_a_q;
wire               rx_pattern_b_din;
wire               rx_pattern_b_done;
wire               rx_pattern_b_q;
wire [7:0]         rx_trained_lanes;
wire [7:0]         rx_trained_lanes_din;
wire [7:0]         rx_trained_lanes_q;
wire               rx_ts1_din;
wire               rx_ts1_done;
wire               rx_ts1_q;
wire               rx_ts2_din;
wire               rx_ts2_done;
wire               rx_ts2_q;
wire               rx_ts3_din;
wire               rx_ts3_done;
wire               rx_ts3_q;
wire [15:0]        scramble_0;
wire [15:0]        scramble_1;
wire [15:0]        scramble_2;
wire [15:0]        scramble_3;
wire [15:0]        scramble_4;
wire [15:0]        scramble_5;
wire [15:0]        scramble_6;
wire [15:0]        scramble_7;
wire               software_retrain_din;
wire               software_retrain_q;
wire               spare_00_din;
wire               spare_00_q;
wire               spare_01_din;
wire               spare_01_q;
wire               spare_02_din;
wire               spare_02_q;
wire               spare_03_din;
wire               spare_03_q;
wire               spare_04_din;
wire               spare_04_q;
wire               spare_05_din;
wire               spare_05_q;
wire               spare_06_din;
wire               spare_06_q;
wire               spare_07_din;
wire               spare_07_q;
wire               spare_08_din;
wire               spare_08_q;
wire               spare_09_din;
wire               spare_09_q;
wire               spare_0A_din;
wire               spare_0A_q;
wire               spare_0B_din;
wire               spare_0B_q;
wire               spare_0C_din;
wire               spare_0C_q;
wire               spare_0D_din;
wire               spare_0D_q;
wire               spare_0E_din;
wire               spare_0E_q;
wire               spare_0F_din;
wire               spare_0F_q;
wire               spare_10_din;
wire               spare_10_q;
wire               spare_11_din;
wire               spare_11_q;
wire               spare_12_din;
wire               spare_12_q;
wire               spare_13_din;
wire               spare_13_q;
wire               spare_14_din;
wire               spare_14_q;
wire               spare_15_din;
wire               spare_15_q;
wire               spare_16_din;
wire               spare_16_q;
wire               spare_17_din;
wire               spare_17_q;
wire               spare_18_din;
wire               spare_18_q;
wire               spare_19_din;
wire               spare_19_q;
wire               spare_1A_din;
wire               spare_1A_q;
wire               spare_1B_din;
wire               spare_1B_q;
wire               spare_1C_din;
wire               spare_1C_q;
wire               spare_1D_din;
wire               spare_1D_q;
wire               spare_1E_din;
wire               spare_1E_q;
wire               spare_1F_din;
wire               spare_1F_q;
wire               start_retrain;
wire [2:0]         start_retrain_dly_din;
wire [2:0]         start_retrain_dly_q;
wire [3:0]         start_retrain_pend_din;
wire [3:0]         start_retrain_pend_q;
wire [10:0]        status_unused_din;
wire [10:0]        status_unused_q;
wire               sync_hdrs;
wire [15:0]        train_data_din;
wire [15:0]        train_data_q;
wire               train_done_din;
wire               train_done_q;
wire               train_state_parity_din;
wire               train_state_parity_q;
wire [15:0]        training_set_ln0;
wire [15:0]        training_set_ln1;
wire [15:0]        training_set_ln2;
wire [15:0]        training_set_ln3;
wire [15:0]        training_set_ln4;
wire [15:0]        training_set_ln5;
wire [15:0]        training_set_ln6;
wire [15:0]        training_set_ln7;
wire [15:0]        training_set_word_0;
wire [15:0]        training_set_word_1;
wire [15:0]        training_set_word_2_ln0;
wire [15:0]        training_set_word_2_ln1;
wire [15:0]        training_set_word_2_ln2;
wire [15:0]        training_set_word_2_ln3;
wire [15:0]        training_set_word_2_ln4;
wire [15:0]        training_set_word_2_ln5;
wire [15:0]        training_set_word_2_ln6;
wire [15:0]        training_set_word_2_ln7;
wire [15:0]        training_set_word_3_ln0;
wire [15:0]        training_set_word_3_ln1;
wire [15:0]        training_set_word_3_ln2;
wire [15:0]        training_set_word_3_ln3;
wire [15:0]        training_set_word_3_ln4;
wire [15:0]        training_set_word_3_ln5;
wire [15:0]        training_set_word_3_ln6;
wire [15:0]        training_set_word_3_ln7;
wire [2:0]         training_state;
wire               training_update;
wire               trn_flt_train_done;
wire [15:0]        trn_ln0_scrambler;
wire [15:0]        trn_ln1_scrambler;
wire [15:0]        trn_ln2_scrambler;
wire [15:0]        trn_ln3_scrambler;
wire [15:0]        trn_ln4_scrambler;
wire [15:0]        trn_ln5_scrambler;
wire [15:0]        trn_ln6_scrambler;
wire [15:0]        trn_ln7_scrambler;
wire [15:0]        trn_ln_train_data;
wire [3:0]         tsm4_dly_din;
wire [3:0]         tsm4_dly_q;
wire [2:0]         tsm_din;
wire [2:0]         tsm_q;
wire [22:0]        tx_deg_thres_cntr_din;
wire [22:0]        tx_deg_thres_cntr_q;
wire               tx_deg_thres_hit_din;
wire               tx_deg_thres_hit_q;
wire [22:0]        tx_degraded_threshold;
wire               tx_EDPL_ena_din;
wire               tx_EDPL_ena_q;
wire [1:0]         tx_lane_swap_din;
wire [1:0]         tx_lane_swap_q;
wire               tx_lane_swap_err_din;
wire               tx_lane_swap_err_q;
wire               tx_sent_sync_done;
wire [7:0]         tx_trained_lanes;
wire               x4_rx_mode;
wire [1:0]         half_width_rx_mode_din;
wire [1:0]         half_width_rx_mode_q;
wire               x4_tx_mode;
wire [1:0]         half_width_tx_mode_din;
wire [1:0]         half_width_tx_mode_q;
wire               ts_x4_outer_din;
wire               ts_x4_outer_q;
wire [5:0]         cfg_tl_credits_din;
wire [5:0]         cfg_tl_credits_q;
wire               enable_short_idle_din;
wire               enable_short_idle_q;
wire [7:0]         disabled_rx_lanes;
wire [3:0]         disabled_rx_lanes_cnt;
wire               x8_tx_mode;
wire               x2_tx_outer_mode;
wire               x2_tx_inner_mode;
wire               x2_tx_mode;
wire               x4_tx_outer_mode;
wire               x4_tx_inner_mode;
wire [15:0]        cfg_good_lanes_x4;
wire [15:0]        cfg_good_lanes_x8;
wire               rx_cfg_x32;
wire               rx_cfg_x16;
wire               rx_cfg_x8;
wire               rx_cfg_x4;
wire               tx_cfg_x32;
wire               tx_cfg_x16;
wire               tx_cfg_x8;
wire               tx_cfg_x4;
wire               cfg_x4;
wire               cfg_x8;
wire [3:0]         ts_trained_mode;
wire [1:0]         cfg_lane_width_sel_din;
wire [1:0]         cfg_lane_width_sel_q;
wire               cfg_pre_IPL_PRBS_ena_din;
wire               cfg_pre_IPL_PRBS_ena_q;
wire [2:0]         cfg_pre_IPL_PRBS_timer_din;
wire [2:0]         cfg_pre_IPL_PRBS_timer_q;
wire [3:0]         rem_PM_status;
wire [3:0]         PM_msg;
wire [1:0]         lane_width_req_pend_din;
wire [1:0]         lane_width_req_pend_q;
wire               req_quarter_width;
wire               req_half_width;
wire               req_full_width;
wire               lane_width_change_ip_din;
wire               lane_width_change_ip_q;
wire [1:0]         lane_width_change_ip_dly_din;
wire [1:0]         lane_width_change_ip_dly_q;
wire               lane_width_change_done;
wire               PM_narrow_not_wide_din;
wire               PM_narrow_not_wide_q;
wire               PM_narrow_not_wide_next;
wire               PM_width_move_down;
wire               PM_width_move_up;
wire               send_PM_msg;
wire               PM_msg_sent;
wire [1:0]         init_width_din;
wire [1:0]         init_width_q;
wire               init_train_done;
wire               init_train_done_din;
wire               init_train_done_q;
wire               init_train_done_set;
wire [2:0]         x4_width;
wire [2:0]         x4_tx_width;
wire [2:0]         x4_rx_width;
wire [2:0]         x8_width;
wire [2:0]         x8_tx_width;
wire [2:0]         x8_rx_width;
wire [2:0]         selected_width;
wire [1:0]         lane_width_next_status;
wire [1:0]         lane_width_status_din;
wire [1:0]         lane_width_status_q;
wire [7:0]         PM_tx_lanes_disable;
wire [7:0]         PM_tx_lanes_disable_din;
wire [7:0]         PM_tx_lanes_disable_q;
wire [7:0]         PM_rx_lanes_disable;
wire               PM_state_reset;
wire [3:0]         PM_state_din;
wire [3:0]         PM_state_q;
wire               PM_state_update;
wire [3:0]         PM_next_state;
wire               PM_adv_run_full;
wire               PM_adv_run_half;
wire               PM_adv_run_quarter;
wire               PM_adv_host_full2half;
wire               PM_adv_EP_full2half;
wire               PM_state_disabled;
wire               PM_state_running_quarter;
wire               PM_state_running_half;
wire               PM_state_running_full;
wire               PM_state_wake_quarter2half;
wire               PM_state_wake_half2full;
wire               PM_state_ready_quarter2half;
wire               PM_state_ready_half2full;
wire               PM_state_host_full2half;
wire               PM_state_EP_full2half;
wire               PM_state_host_half2quarter;
wire               PM_state_EP_half2quarter;
wire               train_done_dly_din;
wire               train_done_dly_q;
wire               PM_tx_lane_timer_ena_din;
wire               PM_tx_lane_timer_ena_q;
wire               PM_tx_lane_timer_done;
wire               PM_tx_lane_timer_inc;
wire [4:0]         PM_tx_lane_timer_din;
wire [4:0]         PM_tx_lane_timer_q;
wire               PM_tx_send_TS1s;
wire [7:0]         disabled_tx_lanes_hold_din;
wire [7:0]         disabled_tx_lanes_hold_q;
wire               PM_adv_host_half2quarter;
wire               PM_adv_EP_half2quarter;
wire [7:0]         PM_tx_lanes_disable_half;
wire [7:0]         PM_tx_lanes_disable_quarter;
wire               x4_rx_outer_mode;
wire               x4_rx_inner_mode;
wire [7:0]         tx_psave_req_din;
wire [7:0]         tx_psave_req_q;
wire [7:0]         tx_psave_sts_din;
wire [7:0]         tx_psave_sts_q;
wire [7:0]         rx_psave_req_din;
wire [7:0]         rx_psave_req_q;
wire [7:0]         rx_psave_sts_din;
wire [7:0]         rx_psave_sts_q;
wire               x4_tx_outer_mode_din;
wire               x4_tx_outer_mode_q;
wire               x4_tx_inner_mode_din;
wire               x4_tx_inner_mode_q;
wire               PM_msg_sent_dly_din;
wire               PM_msg_sent_dly_q;
wire [4:0]         lane0_number;
wire [4:0]         lane1_number;
wire [4:0]         lane2_number;
wire [4:0]         lane3_number;
wire [4:0]         lane4_number;
wire [4:0]         lane5_number;
wire [4:0]         lane6_number;
wire [4:0]         lane7_number;
wire               sim_only_fast_train     = 1'b0; //-- set to a 1'b1 to enable fast train
wire [2:0]         sim_only_fast_train_q;
wire [2:0]         sim_only_fast_train_din = {sim_only_fast_train, sim_only_fast_train_q[2:1]};
wire               sim_only_fast_train_pulse;
wire               sim_only_hold_cycle_cnt = sim_only_fast_train & ~(&sim_only_fast_train_q[2:0]);
wire               PM_store_reset;
wire               PM_adv_wake_quarter2half;
wire               PM_adv_wake_half2full;
wire               PM_adv_ready_quarter2half;
wire               PM_adv_ready_half2full;
wire               PM_start_retrain;
wire [7:0]         PM_rx_lanes_enable;
wire [7:0]         PM_tx_lanes_enable;
wire [7:0]         PM_tx_lanes_enable_half;
wire [7:0]         PM_tx_lanes_enable_full;
wire               PM_deskew_reset;
wire [47:0]        dl_errors;
wire [63:0]        dl_config0;
wire [63:0]        dl_config1;
wire [63:0]        dl_status;
wire [63:0]        dl_training_status;
wire [63:0]        EDPL_max_cnts;
wire               cfg_x16;
wire               cfg_x32;
wire [7:0]         recal_rx_req_din;
wire [7:0]         recal_rx_req_q;
wire [7:0]         recal_rx_done_din;
wire [7:0]         recal_rx_done_q;
wire               recal_state_reset;
wire [1:0]         recal_state_din;
wire [1:0]         recal_state_q;
wire               recal_state_no_cal;
wire               recal_state_reset_cal;
wire               recal_state_cal0;
wire               recal_state_cal1;
wire               recal_state_update;
wire [1:0]         recal_next_state;
wire               recal_adv_no_cal;
wire               recal_adv_reset_cal;
wire               recal_adv_cal0;
wire               recal_adv_cal1;
wire [3:0]         recal_rx_lane_number_din;
wire [3:0]         recal_rx_lane_number_q;
wire               recal_rx_lane_number_reset;
wire               recal_rx_lane_number_update;
wire [1:0]         rem_recal_status;
wire               recal_rx_lane0;
wire               recal_rx_lane1;
wire               recal_rx_lane2;
wire               recal_rx_lane3;
wire               recal_rx_lane4;
wire               recal_rx_lane5;
wire               recal_rx_lane6;
wire               recal_rx_lane7;
wire [7:0]         recal_rx_done;
wire               recal_start;
wire               rem_recal_done_din;
wire               rem_recal_done_q;
wire               is_host_din;
wire               is_host_q;
wire               around_stall;
wire               update_PM_cycle;
wire               PM_start_retrain_din;
wire               PM_start_retrain_q;
wire               PM_start_retrain_pulse;
wire [7:0]         recal_rx_lane_enable;
wire [7:0]         recal_rx_lane_enable_din;
wire [7:0]         recal_rx_lane_enable_q;
wire [7:0]         recal_rx_lane_disable;
wire               rem_PM_enable;
wire               PM_enable_din;
wire               PM_enable_q;
wire               recal_tx_send_TS1s;
wire [7:0]         recal_tx_lane_enable;
wire [7:0]         recal_tx_lane_enable_din;
wire [7:0]         recal_tx_lane_enable_q;
wire [7:0]         recal_tx_lane_disable;
wire [1:0]         requested_lane_width_din;
wire [1:0]         requested_lane_width_q;
wire               PM_disable;
wire               PM_disable_due2_EDPL;
wire               PM_start_retrain_sent_din;
wire               PM_start_retrain_sent_q;
wire               PM_caused_retrain;
wire               PM_caused_retrain_din;
wire               PM_caused_retrain_q;
wire [7:0]         tx_trained_lanes_din;
wire [7:0]         tx_trained_lanes_q;
wire [7:0]         sts_disabled_rx_lanes_din;
wire [7:0]         sts_disabled_rx_lanes_q;
wire [7:0]         cfg_tx_lanes_disable;
wire [7:0]         cfg_rx_lanes_disable;
wire [21:0]        pre_IPL_PRBS_timer_din;
wire [21:0]        pre_IPL_PRBS_timer_q;
wire               incr_pre_IPL_PRBS_timer;
wire               pre_IPL_PRBS_timer_done_din;
wire               pre_IPL_PRBS_timer_done_q;
wire               pre_IPL_PRBS_timer_done_dly_din;
wire               pre_IPL_PRBS_timer_done_dly_q;
wire               pre_IPL_PRBS_timer_finished;
wire [21:0]        pre_IPL_PRBS_timer_rate;
wire               start_pre_IPL_PRBS;
wire               fatal_errors;
wire [3:0]         recal_rx_lane_number_next;
wire               recal_toggle_din;
wire               recal_toggle_q;
wire               half_width_x4_tx_mode_din;
wire               half_width_x4_tx_mode_q;
wire               half_width_x8_tx_mode_din;
wire               half_width_x8_tx_mode_q;
wire               half_width_x4_rx_mode_din;
wire               half_width_x4_rx_mode_q;
wire               half_width_x8_rx_mode_din;
wire               half_width_x8_rx_mode_q;
wire               half_width_x4_outer_tx_mode_din;
wire               half_width_x4_outer_tx_mode_q;
wire               half_width_x4_inner_tx_mode_din;
wire               half_width_x4_inner_tx_mode_q;
wire               half_width_x4_outer_rx_mode_din;
wire               half_width_x4_outer_rx_mode_q;
wire               half_width_x4_inner_rx_mode_din;
wire               half_width_x4_inner_rx_mode_q;
wire               half_width_x8_outer_tx_mode_din;
wire               half_width_x8_outer_tx_mode_q;
wire               half_width_x8_inner_tx_mode_din;
wire               half_width_x8_inner_tx_mode_q;
wire               half_width_x8_outer_rx_mode_din;
wire               half_width_x8_outer_rx_mode_q;
wire               half_width_x8_inner_rx_mode_din;
wire               half_width_x8_inner_rx_mode_q;
wire               full_width_x8_rx_mode_din;
wire               full_width_x8_tx_mode_din;
wire               full_width_x4_rx_mode_din;
wire               full_width_x4_tx_mode_din;
wire               full_width_x8_rx_mode_q;
wire               full_width_x8_tx_mode_q;
wire               full_width_x4_rx_mode_q;
wire               full_width_x4_tx_mode_q;
wire [3:0]         full_width_x8_rx_mode_next_ln;
wire [3:0]         full_width_x8_rx_mode_rev_next_ln;
wire [3:0]         full_width_x4_rx_mode_next_ln;
wire [3:0]         full_width_x4_rx_mode_rev_next_ln;
wire [3:0]         recal_rx_lane_number_reset_val;
wire               rem_recal_ip;
wire               recal_state_cal;
wire               first_recal_started_din;
wire               first_recal_started_q;
wire [3:0]         full_width_x8_tx_mode_next_ln;
wire [3:0]         full_width_x8_tx_mode_rev_next_ln;
wire [3:0]         full_width_x4_tx_mode_next_ln;
wire [3:0]         full_width_x4_tx_mode_rev_next_ln;
wire [3:0]         recal_tx_lane_number_reset_val;
wire [3:0]         recal_tx_lane_number_next;
wire [3:0]         recal_tx_lane_number_din;
wire [3:0]         recal_tx_lane_number_q;
wire               recal_tx_lane_number_reset;
wire               recal_tx_lane_number_update;
wire               recal_tx_lane0;
wire               recal_tx_lane1;
wire               recal_tx_lane2;
wire               recal_tx_lane3;
wire               recal_tx_lane4;
wire               recal_tx_lane5;
wire               recal_tx_lane6;
wire               recal_tx_lane7;
wire               recal_selected_lane_done;
wire [3:0]         recal_num_done_din;
wire [3:0]         recal_num_done_q;
wire               recal_all_lanes_done;
wire               recal_num_done_inc;
wire [7:0]         degraded_lanes;
wire [7:0]         tx_psave_req;
wire [7:0]         rx_psave_req;
wire               recal_tx_last_lane;
wire               recal_rx_last_lane;
wire [7:0]         full_width_enable_lanes;
wire [7:0]         half_width_disable_lanes;
wire [7:0]         half_width_enable_lanes;
wire [7:0]         quarter_width_disable_lanes;
wire               send_PM_ready_msg_din;
wire               send_PM_ready_msg_q;
wire [3:0]         rem_PM_status_dly_din;
wire [3:0]         rem_PM_status_dly_q;
wire               rem_PM_status_updated;
wire               PM_adv_disabled;
wire               PM_stop_din;
wire               PM_stop_q;
wire               PM_wake_msg_sent_din;
wire               PM_wake_msg_sent_q;
wire               real_stall_din;
wire               real_stall_q;
wire               begin_start_retrain;
wire               retrain_ip_din;
wire               retrain_ip_q;
wire               retrained_in_degr_width;
wire               retrained_in_degr_width_din;
wire               retrained_in_degr_width_q;
wire               both_sides_switch_not_ip;
wire               end_of_start_retrain;
wire               retrain_not_due2_PM;
wire               tx_psave_timer_reset;
wire               tx_psave_timer_inc;
wire               tx_psave_timer_full2half_ena_din;
wire               tx_psave_timer_full2half_ena_q;
wire               tx_psave_timer_half2quarter_ena_din;
wire               tx_psave_timer_half2quarter_ena_q;
wire [7:0]         tx_psave_timer_din;
wire [7:0]         tx_psave_timer_q;
wire               crc_error;
wire               retrain_not_due2_PM_dly_din;
wire               retrain_not_due2_PM_dly_q;
wire               psave_sts_off;
wire               retrain_not_due2_PM_din;
wire               retrain_not_due2_PM_q;
wire               training;
wire               PM_back_to_quarter_din;
wire               PM_back_to_quarter_q;
wire               PM_back_to_quarter_start;
wire               PM_is_host_din;
wire               PM_is_host_q;
wire [1:0]         current_width;
wire               PM_rx_psave_host_full2half;
wire               PM_rx_psave_host_half2quarter;
wire               unexpected_remote_retrain;
wire               unexpected_lost_data_sync;
wire               PM_ignore_lost_block_lock;
wire               manual_adv_train_done;
wire               update_valid_lanes_in_status_reg;
wire               retrained_in_degr_cfg_x8;
wire               retrained_in_degr_cfg_x4;
wire               trn_timeout_fired_din;
wire               trn_timeout_fired_q;
wire [5:0]         trn_timeout_timer_din;
wire [5:0]         trn_timeout_timer_q;
wire [5:0]         trn_timeout_val;
wire               trn_timeout_timer_reset;
wire               trn_timeout_timer_inc;
wire               trn_timeout_fired;
wire               trn_timeout_has_fired_din;
wire               trn_timeout_has_fired_q;
wire               trn_timeout_fired_twice;
wire               retrain_due2_trn_timeout;
wire [10:0]        start_retrain_cond;
wire               start_retrain_flt;
wire               PM_msg_8to2_early_din;
wire               PM_msg_8to2_early_q;
wire               PM_msg_9to1_early_din;
wire               PM_msg_9to1_early_q;
wire               PM_msg8;
wire               PM_msg9;
wire               around_stall_EP_hold_din;
wire               around_stall_EP_hold_q;
wire               around_stall_EP;
wire               around_stall_EP_hold_done;
wire               EDPL_ena_din;
wire               EDPL_ena_q;
wire               EDPL_allowed_version8;
wire               EDPL_allowed_version9;
wire               EDPL_allowed_version10;
wire [6:0]         sim_only_version;
wire [5:0]         deskew_version;
wire [1:0]         trace_trig_din;
wire [1:0]         trace_trig_q;
wire [87:0]        debug_dbg_stg0_din;
wire [87:0]        debug_dbg_stg0_q;
wire [47:0]        dl_errors_din;
wire [47:0]        dl_errors_q;
wire [7:0]         iobist_prbs_error_din;
wire [7:0]         iobist_prbs_error_q;
wire [1:0]         rem_recal_status_dly_din;
wire [1:0]         rem_recal_status_dly_q;
wire               rem_recal_status_updated;
wire [3:0]         cfg_macro_dbg_sel_din;
wire [3:0]         cfg_macro_dbg_sel_q;
wire               phy_limit_hit_din;
wire [0:0]         unused; //-- flipflop outputs used for testability
wire [5:0]         EDPL_compare_din;
wire [5:0]         EDPL_compare_q;
wire               EDPL_time_window_disable;
wire               EDPL_window_hit;
wire [7:0]         tx_psave_req_PM;
wire [7:0]         rx_psave_req_PM;
wire               PM_allow_wake_din;
wire               PM_allow_wake_q;
wire               PM_allow_wake_clear;
wire               PM_allow_wake_clear_half;
wire [7:0]         recal_rx_in_degr_width_lanes;
wire [7:0]         recal_tx_in_degr_width_lanes;
wire [7:0]         recal_rx_in_degr_width_fakeout;
wire               psaves_done;
wire [7:0]         ln_disable_PM_wake_din;
wire [7:0]         ln_disable_PM_wake_q;
wire [7:0]         rx_psave_req_PM_din;
wire [7:0]         rx_psave_req_PM_q;
wire               PM_EP_start_retrain_set;
wire               PM_EP_start_retrain_clear;
wire               PM_EP_start_retrain_din;
wire               PM_EP_start_retrain_q;

//--------------------------------------------------------
//--           Configuration Registers 
//--
//--------------------------------------------------------
//--
//-- Configuration0 Register (1 per ODL) [scom addresses of x10, x20, x30]
//-- 
//------------------------------------------------------------------------------------------------------------------------------------------
//-- Bits    Access    Init Value   Name                              Description
//-- ----    ------    ----------   ----                              -----------
//-- 63      RW        0            OMI Enable                        Clock enable for all OMI latches
//-- 62:58   RW        1            Spare                             Spare
//---57:52   RW        100000       TL credits                        Configurable number of credits that should be given to the TL
//-- 51      RW        0            TL event = All freeze             Freeze the AFU, TL, and DL on event
//-- 50      RW        0            TL event = AFU                    Freeze Freeze the AFU but leave the DL and TL running on event
//-- 49      RW        1            TL event = ILA trigger            Trigger the internal logic analyzers on TL event
//-- 48      RW        0            TL event = Link Down              Bring down the link on TL event
//-- 47      RW        0            TL error = All freeze             Freeze the AFU, TL, and DL on error
//-- 46      RW        1            TL error = AFU                    Freeze Freeze the AFU but leave the DL and TL running on error
//-- 45      RW        1            TL error = ILA trigger            Trigger the internal logic analyzers on TL error
//-- 44      RW        0            TL error = Link Down              Bring down the link on TL error
//-- 43:40   RW        0100         No Forward Progress Timer         Length of time no forward progress can be made before a retrain of the link is preformed.
//--                                                                  0000 - 1 us
//--                                                                  0001 - 2 us
//--                                                                  0010 - 4 us
//--                                                                  0011 - 8 us
//--                                                                  0100 - 16 us
//--                                                                  0101 - 32 us
//--                                                                  0110 - 64 us
//--                                                                  0111 - 128 us
//--                                                                  1000 - 256 us
//--                                                                  1001 - 512 us
//--                                                                  1010 - 1 ms
//--                                                                  1011 - 2 ms
//--                                                                  1100 - 4 ms
//--                                                                  1101 - 8 ms
//--                                                                  1110 - 16 ms
//--                                                                  1111 - disabled
//-- 39:36   RW        0000         Replay Buffers reserved           This value multiplied by 32 is the number of 16B replay buffer slots that are
//--                                                                  reserved for testing purposes. A value of 'F' is reserved.
//-- 35:33   RW        111          Debug Select                      000 - zeros
//--                                                                  001 - ODL RX information
//--                                                                  010 - ODL TX FLT and ODL TX CTL pointer information
//--                                                                  011 - ODL TX FLT and ODL TX CTL training information
//--                                                                  100 - bits 10:0 only of RX information
//--                                                                  101 - bits 10:0 only of TX control information
//--                                                                  110 - bits 10:0 only of TX flit information
//--                                                                  111 - zeros
//-- 32      RW        1            Debug enable                      Clock gating for the debug/trace logic
//-- 31      RW        0            Inject DL2TL Data parity error    Inject a single parity error into the DL2DL data
//-- 30      RW        0            Inject DL2TL Control parity error Inject a single parity error into the DL2DL control information
//-- 29      RW        0            Inject ECC UE                     Inject a single ECC UE into the Frame buffer/Replay buffer data
//-- 28      RW        0            Inject ECC CE                     Inject a single ECC CE into the Frame buffer/Replay buffer data
//-- 27      RW        0            Disable Fast path                 Disable frame buffer bypass "fast path" in TX flit
//-- 26      RW        0            Spare                             Spare
//-- 25      RW        0            Enable TX lane reversal           When set, the TX is allowed to reverse the lanes if the remote side requested 
//--                                                                  it in the deskew marker.  When not set, the DL will set error bit 9 when the
//--                                                                  remote side requests it.
//-- 24      RW        0            128/130 Encoding Enable           Allow the link to attempt to train using 128/130 encoding
//-- 23:20   RW        0001         PHY control limit                 Length of time the RX needs to receive a pattern A or pattern B before advancing state.
//--                                                                  x'0' = 1 us
//--                                                                  x'1' = 50 us
//--                                                                  x'2' = 100 us
//--                                                                  x'3' = 200 us
//--                                                                  x'4' = 500 us
//--                                                                  x'5' = 1 ms
//--                                                                  x'6' = 2 ms
//--                                                                  x'7' = 3 ms
//--                                                                  x'8' = 4 ms
//--                                                                  x'9' = 5 ms
//--                                                                  x'A' = 6 ms
//--                                                                  x'B' = 8 ms
//--                                                                  x'C' = 10 ms
//--                                                                  x'D' = 15 ms
//--                                                                  x'E' = 30 ms
//--                                                                  x'F' = 60 ms
//-- 19      RW        0            TX degraded mode ordering         When running in x4 or x1 back-off modes, selects which lane is transmitted first.
//--                                                                  0 = Send neighbor lane data and then this lanes data
//--                                                                  1 = Send this lanes data and then neighbor lanes data
//-- 18      RW        0            Power-Management Enable           This function is not supported in version 1. Allow the link to switch 
//--                                                                  to use only 1 lane if the link is idle to save power.
//-- 17      RW        0            x1 Back-off Enable                Allow the link to run on lane 0 or lane 1 if multiple lanes don't train
//-- 16      RW        1            x4 Back-off Enable                Allow the link to run in half bandwidth mode. All odd or even lanes will be disabled
//--                                                                  if one lane in their group doesn't train.
//-- 15:12   RW        0010         Supported Widths                  1-hot vector of supported widths
//--                                                                  [15] = x32
//--                                                                  [14] = x16
//--                                                                  [13] = x08
//--                                                                  [12] = x04
//-- 11:8    RW        1000         Training Mode                     1xxx = enable training
//--                                                                  0000 = send zero
//--                                                                  0001 = send pattern A
//--                                                                  0010 = send pattern B
//--                                                                  0011 = send sync
//--                                                                  0100 = send ts1
//--                                                                  0101 = send ts2
//--                                                                  0110 = send ts3
//--                                                                  0111 = send ts0
//-- 7:2     RW        001000       Version Number                    Open CAPI version Version 1 which matches the 0.7 Open CAPI Architecture Specification
//-- 1       RW        0            Retrain                           Reset the training sequence to sending of control sync headers with TS1 pattern
//-- 0       RW        0            Reset                             Reset ODL to Power-on Values

assign dl_config0[63:0]                    = reg_dl_config0[63:0];
//-- clock gate so omi_enable latch can turn itself off
assign act_omi_enable                      = dl_config0[63] | cfg_omi_enable_q;
assign omi_enable_out                      = cfg_omi_enable_q;
assign omi_enable                          = cfg_omi_enable_q;

assign cfg_omi_enable_din                  = dl_config0[63];
assign cfg_sync_mode_din                   = sync_mode;
assign cfg_unused_din[4:1]                 = dl_config0[61:58];
assign cfg_tl_credits_din[5:0]             = dl_config0[57:52];
assign cfg_tl_event_all_freeze_din         = dl_config0[51];
assign cfg_tl_event_afu_freeze_din         = dl_config0[50];
assign cfg_tl_event_ila_trigger_din        = dl_config0[49];
assign cfg_tl_event_link_down_din          = dl_config0[48];
assign cfg_tl_error_all_freeze_din         = dl_config0[47];
assign cfg_tl_error_afu_freeze_din         = dl_config0[46];
assign cfg_tl_error_ila_trigger_din        = dl_config0[45];
assign cfg_tl_error_link_down_din          = dl_config0[44];
assign cfg_no_fwd_prog_timer_rate_din[3:0] = dl_config0[43:40];
assign cfg_rpb_rm_depth_din[3:0]           = dl_config0[39:36]; 
assign cfg_debug_sel_din[2:0]              = dl_config0[35:33];
assign cfg_debug_ena_din                   = dl_config0[32] | global_trace_enable;
assign cfg_inj_data_pty_din                = dl_config0[31];
assign cfg_inj_ctl_pty_din                 = dl_config0[30];
assign cfg_inj_ecc_ue_din                  = dl_config0[29];
assign cfg_inj_ecc_ce_din                  = dl_config0[28];
assign cfg_disable_fast_path_din           = dl_config0[27];
assign cfg_unused_din[0]                   = dl_config0[26] | dl_config0[62];
assign cfg_enable_tx_lane_swap_din         = dl_config0[25];
assign cfg_omi_128_130_en_din              = dl_config0[24];
assign cfg_omi_phy_cntr_limit_din[3:0]     = dl_config0[23:20];
assign cfg_omi_run_lane_override_din       = dl_config0[19];
assign cfg_omi_PM_enable_din               = dl_config0[18];
assign cfg_omi_quarter_width_enable_din    = dl_config0[17];
assign cfg_omi_half_width_enable_din       = dl_config0[16];
assign cfg_omi_supported_widths_din[3:0]   = dl_config0[15:12];
assign cfg_omi_train_mode_din[3:0]         = dl_config0[11:8];
assign cfg_omi_version_din[5:0]            = dl_config0[7:2];
assign cfg_omi_retrain_din                 = dl_config0[1];
assign cfg_omi_reset_din                   = dl_config0[0]; 

//----------------------
//-- Power Management
//----------------------

//-- Calibration message (2 bits) are sent in every control flit, idle flit, and replay flit, Messages "10" and "11" will
//-- be alternated to indicate that the next lane is to be calibrated.
//-- "00" -> no recalibration in progress
//-- "10" -> even lane is being calibrated
//-- "11" -> odd lane is being calibrated
//-- "01" -> reset lane counter to zero
//-- guarentee that the recal state machine will get reset if the omi reset/chip reset aren't applied correctly.
assign recal_state_reset            = tsm_q[2:0] == 3'b010;
assign recal_state_din[1:0]         = recal_state_reset  ? 2'b01 :
                                      recal_state_update ? recal_next_state[1:0] :
                                                           recal_state_q[1:0];

assign trn_flt_recal_state[1:0]     = recal_state_q[1:0];

//-- Recal State Machine Decode
assign recal_state_no_cal           = (recal_state_q[1:0] == 2'b00);
assign recal_state_reset_cal        = (recal_state_q[1:0] == 2'b01);
assign recal_state_cal0             = (recal_state_q[1:0] == 2'b10);
assign recal_state_cal1             = (recal_state_q[1:0] == 2'b11);

assign recal_state_cal              = recal_state_cal0 | recal_state_cal1;

//-- Next recal states
assign recal_state_update           = recal_adv_no_cal | recal_adv_reset_cal | recal_adv_cal0 | recal_adv_cal1;
assign recal_next_state[1:0]        = (2'b00 & {2{recal_adv_no_cal   }}) |
                                      (2'b01 & {2{recal_adv_reset_cal}}) |
                                      (2'b10 & {2{recal_adv_cal0     }}) |
                                      (2'b11 & {2{recal_adv_cal1     }});

assign recal_adv_no_cal             = recal_state_cal & recal_selected_lane_done & ~recal_adv_reset_cal;

assign recal_adv_reset_cal          = recal_state_cal & recal_all_lanes_done & is_host_q;

assign recal_adv_cal0               = (recal_state_no_cal & ~recal_toggle_q & recal_start) | (recal_state_reset_cal & recal_start);
assign recal_adv_cal1               = (recal_state_no_cal &  recal_toggle_q & recal_start);

//-- Conditions to advance to the next recal state
//-- Advance once handshake recal request is done.  eg: recal req = 1 -> recal_done = 1 -> recal req = 0 -> recal done = 0
assign recal_selected_lane_done     = (recal_rx_lane0 & recal_rx_done_q[0] & ~recal_rx_done[0]) |
                                      (recal_rx_lane1 & recal_rx_done_q[1] & ~recal_rx_done[1]) |
                                      (recal_rx_lane2 & recal_rx_done_q[2] & ~recal_rx_done[2]) |
                                      (recal_rx_lane3 & recal_rx_done_q[3] & ~recal_rx_done[3]) |
                                      (recal_rx_lane4 & recal_rx_done_q[4] & ~recal_rx_done[4]) |
                                      (recal_rx_lane5 & recal_rx_done_q[5] & ~recal_rx_done[5]) |
                                      (recal_rx_lane6 & recal_rx_done_q[6] & ~recal_rx_done[6]) |
                                      (recal_rx_lane7 & recal_rx_done_q[7] & ~recal_rx_done[7]);
assign recal_num_done_din[3:0]      = recal_all_lanes_done ? 4'h1 :
                                      recal_num_done_inc   ? recal_num_done_q[3:0] + 4'h1 :
                                                             recal_num_done_q[3:0];
assign recal_all_lanes_done         = ((recal_num_done_q[3:0] == 4'h8) & recal_num_done_inc & cfg_x8) |
                                      ((recal_num_done_q[3:0] == 4'h4) & recal_num_done_inc & cfg_x4);
assign recal_num_done_inc           = recal_selected_lane_done;

//-- Used to determine which state the recal state machine should advance to:
//-- 0 -> 2'b10 (cal0)
//-- 1 -> 2'b11 (cal1)
assign recal_toggle_din             = ( recal_adv_no_cal                        & ~recal_toggle_q) | 
                                      ( recal_adv_reset_cal                     &  1'b0          ) |
                                      (~recal_adv_no_cal & ~recal_adv_reset_cal &  recal_toggle_q);

assign rem_recal_status[1:0]        = rx_tx_recal_status[1:0];
assign rem_recal_status_dly_din[1:0]= rem_recal_status[1:0];
assign rem_recal_status_updated     = (rem_recal_status[1:0] != rem_recal_status_dly_q[1:0]);
assign rem_recal_ip                 = (rem_recal_status[1:0] == 2'b10) | (rem_recal_status[1:0] == 2'b11);

//-- Make sure remote recal is finished before starting a recal on the next lane
assign rem_recal_done_din           = ((((rem_recal_status[1:0] == 2'b00) | (rem_recal_status[1:0] == 2'b01)) & rem_recal_status_updated) | rem_recal_done_q) & ~recal_start;
assign first_recal_started_din      = rem_recal_ip       | first_recal_started_q;
assign is_host_din                  = (reg_dl_recal_start & frame_vld_q) | is_host_q;
//-- Ignore DL recal start if in the middle of a PM request or if link is not up and running
assign recal_start                  = ~lane_width_change_ip_q & frame_vld_q & 
                                       ( (reg_dl_recal_start & rem_recal_done_q & ~recal_state_cal) | 
                                         (rem_recal_ip       & rem_recal_done_q & ~is_host_q      ) );
//-- 8/3assign recal_start                  = ~lane_width_change_ip_q & frame_vld_q & ((reg_dl_recal_start & ~recal_state_cal) | (rem_recal_ip & rem_recal_done_q & ~is_host_q) );

assign recal_rx_lane_number_din[3:0] = recal_rx_lane_number_reset  ? recal_rx_lane_number_reset_val[3:0] :
                                       recal_rx_lane_number_update ? recal_rx_lane_number_next[3:0] :
                                                                     recal_rx_lane_number_q[3:0];

assign recal_rx_lane_number_update   = (recal_adv_no_cal | recal_adv_reset_cal);

//-- Update reset value based on if lanes are disabled or not
assign recal_rx_lane_number_reset    = (recal_rx_lane_number_update & recal_rx_last_lane) | (init_train_done_set);
assign recal_rx_last_lane            = (rx_lane_reverse & recal_rx_lane0) | (~rx_lane_reverse & recal_rx_lane7);

assign recal_rx_lane0                = (recal_rx_lane_number_q[3:0] == 4'h0);
assign recal_rx_lane1                = (recal_rx_lane_number_q[3:0] == 4'h1);
assign recal_rx_lane2                = (recal_rx_lane_number_q[3:0] == 4'h2);
assign recal_rx_lane3                = (recal_rx_lane_number_q[3:0] == 4'h3);
assign recal_rx_lane4                = (recal_rx_lane_number_q[3:0] == 4'h4);
assign recal_rx_lane5                = (recal_rx_lane_number_q[3:0] == 4'h5);
assign recal_rx_lane6                = (recal_rx_lane_number_q[3:0] == 4'h6);
assign recal_rx_lane7                = (recal_rx_lane_number_q[3:0] == 4'h7);

//-- Starting lane to recal depends on...
//-- 1. half width or full width
//-- 2. configured in 
//-- 3. lanes are reversed
assign recal_rx_lane_number_reset_val[3:0]    = ({4{~rx_lane_reverse}} & 4'h0) |
                                                ({4{ rx_lane_reverse}} & 4'h7);

//-- All possible ways for how the lane number can increment to the next lane to recal
assign recal_rx_lane_number_next[3:0]         = ({4{cfg_x8 & ~rx_lane_reverse}} & full_width_x8_rx_mode_next_ln[3:0]    ) |
                                                ({4{cfg_x8 &  rx_lane_reverse}} & full_width_x8_rx_mode_rev_next_ln[3:0]) |
                                                ({4{cfg_x4 & ~rx_lane_reverse}} & full_width_x4_rx_mode_next_ln[3:0]    ) |
                                                ({4{cfg_x4 &  rx_lane_reverse}} & full_width_x4_rx_mode_rev_next_ln[3:0]);

assign full_width_x8_rx_mode_next_ln[3:0]     = ({4{recal_rx_lane0 & ~recal_adv_reset_cal}} & 4'h1) |
                                                ({4{recal_rx_lane1 & ~recal_adv_reset_cal}} & 4'h2) |
                                                ({4{recal_rx_lane2 & ~recal_adv_reset_cal}} & 4'h3) |
                                                ({4{recal_rx_lane3 & ~recal_adv_reset_cal}} & 4'h4) |
                                                ({4{recal_rx_lane4 & ~recal_adv_reset_cal}} & 4'h5) |
                                                ({4{recal_rx_lane5 & ~recal_adv_reset_cal}} & 4'h6) |
                                                ({4{recal_rx_lane6 & ~recal_adv_reset_cal}} & 4'h7) |
                                                ({4{recal_rx_lane7 & ~recal_adv_reset_cal}} & 4'h0) |
                                                ({4{                  recal_adv_reset_cal}} & 4'h0);
assign full_width_x8_rx_mode_rev_next_ln[3:0] = ({4{recal_rx_lane7 & ~recal_adv_reset_cal}} & 4'h6) |
                                                ({4{recal_rx_lane6 & ~recal_adv_reset_cal}} & 4'h5) |
                                                ({4{recal_rx_lane5 & ~recal_adv_reset_cal}} & 4'h4) |
                                                ({4{recal_rx_lane4 & ~recal_adv_reset_cal}} & 4'h3) |
                                                ({4{recal_rx_lane3 & ~recal_adv_reset_cal}} & 4'h2) |
                                                ({4{recal_rx_lane2 & ~recal_adv_reset_cal}} & 4'h1) |
                                                ({4{recal_rx_lane1 & ~recal_adv_reset_cal}} & 4'h0) |
                                                ({4{recal_rx_lane0 & ~recal_adv_reset_cal}} & 4'h7) |
                                                ({4{                  recal_adv_reset_cal}} & 4'h7);
assign full_width_x4_rx_mode_next_ln[3:0]     = ({4{recal_rx_lane0 & ~recal_adv_reset_cal}} & 4'h2) |
                                                ({4{recal_rx_lane2 & ~recal_adv_reset_cal}} & 4'h5) |
                                                ({4{recal_rx_lane5 & ~recal_adv_reset_cal}} & 4'h7) |
                                                ({4{recal_rx_lane7 & ~recal_adv_reset_cal}} & 4'h0) |
                                                ({4{                  recal_adv_reset_cal}} & 4'h0);
assign full_width_x4_rx_mode_rev_next_ln[3:0] = ({4{recal_rx_lane7 & ~recal_adv_reset_cal}} & 4'h5) |
                                                ({4{recal_rx_lane5 & ~recal_adv_reset_cal}} & 4'h2) |
                                                ({4{recal_rx_lane2 & ~recal_adv_reset_cal}} & 4'h0) |
                                                ({4{recal_rx_lane0 & ~recal_adv_reset_cal}} & 4'h7) |
                                                ({4{                  recal_adv_reset_cal}} & 4'h7);

//-- Don't send a recal request until the rx psave is turned off (psave_sts), an active psave request is issued, or on certain lanes if configured as a x4.
assign recal_rx_req_din[0]          = ((recal_rx_lane0 & recal_state_cal & ~(rx_psave_sts_q[0] | (rx_psave_req_PM_q[0] & ~recal_rx_lane_enable_q[0]) | degraded_lanes[0] | recal_rx_in_degr_width_lanes[0])) | recal_rx_req_q[0]) & ~recal_rx_done_q[0];
assign recal_rx_req_din[1]          = ((recal_rx_lane1 & recal_state_cal & ~(rx_psave_sts_q[1] | (rx_psave_req_PM_q[1] & ~recal_rx_lane_enable_q[1]) | degraded_lanes[1] | recal_rx_in_degr_width_lanes[1])) | recal_rx_req_q[1]) & ~recal_rx_done_q[1];
assign recal_rx_req_din[2]          = ((recal_rx_lane2 & recal_state_cal & ~(rx_psave_sts_q[2] | (rx_psave_req_PM_q[2] & ~recal_rx_lane_enable_q[2]) | degraded_lanes[2] | recal_rx_in_degr_width_lanes[2])) | recal_rx_req_q[2]) & ~recal_rx_done_q[2];
assign recal_rx_req_din[3]          = ((recal_rx_lane3 & recal_state_cal & ~(rx_psave_sts_q[3] | (rx_psave_req_PM_q[3] & ~recal_rx_lane_enable_q[3]) | degraded_lanes[3] | recal_rx_in_degr_width_lanes[3])) | recal_rx_req_q[3]) & ~recal_rx_done_q[3];
assign recal_rx_req_din[4]          = ((recal_rx_lane4 & recal_state_cal & ~(rx_psave_sts_q[4] | (rx_psave_req_PM_q[4] & ~recal_rx_lane_enable_q[4]) | degraded_lanes[4] | recal_rx_in_degr_width_lanes[4])) | recal_rx_req_q[4]) & ~recal_rx_done_q[4];
assign recal_rx_req_din[5]          = ((recal_rx_lane5 & recal_state_cal & ~(rx_psave_sts_q[5] | (rx_psave_req_PM_q[5] & ~recal_rx_lane_enable_q[5]) | degraded_lanes[5] | recal_rx_in_degr_width_lanes[5])) | recal_rx_req_q[5]) & ~recal_rx_done_q[5];
assign recal_rx_req_din[6]          = ((recal_rx_lane6 & recal_state_cal & ~(rx_psave_sts_q[6] | (rx_psave_req_PM_q[6] & ~recal_rx_lane_enable_q[6]) | degraded_lanes[6] | recal_rx_in_degr_width_lanes[6])) | recal_rx_req_q[6]) & ~recal_rx_done_q[6];
assign recal_rx_req_din[7]          = ((recal_rx_lane7 & recal_state_cal & ~(rx_psave_sts_q[7] | (rx_psave_req_PM_q[7] & ~recal_rx_lane_enable_q[7]) | degraded_lanes[7] | recal_rx_in_degr_width_lanes[7])) | recal_rx_req_q[7]) & ~recal_rx_done_q[7];

//-- Turn on a lane if it is powered off when a recal needs to happen and that lane isn't disabled
assign recal_rx_lane_enable[0]      = recal_rx_lane0 & ((recal_state_cal & ~is_host_q) | (rem_recal_ip & recal_state_cal & is_host_q)) & ~recal_rx_in_degr_width_lanes[0];
assign recal_rx_lane_enable[1]      = recal_rx_lane1 & ((recal_state_cal & ~is_host_q) | (rem_recal_ip & recal_state_cal & is_host_q)) & ~recal_rx_in_degr_width_lanes[1];
assign recal_rx_lane_enable[2]      = recal_rx_lane2 & ((recal_state_cal & ~is_host_q) | (rem_recal_ip & recal_state_cal & is_host_q)) & ~recal_rx_in_degr_width_lanes[2];
assign recal_rx_lane_enable[3]      = recal_rx_lane3 & ((recal_state_cal & ~is_host_q) | (rem_recal_ip & recal_state_cal & is_host_q)) & ~recal_rx_in_degr_width_lanes[3];
assign recal_rx_lane_enable[4]      = recal_rx_lane4 & ((recal_state_cal & ~is_host_q) | (rem_recal_ip & recal_state_cal & is_host_q)) & ~recal_rx_in_degr_width_lanes[4];
assign recal_rx_lane_enable[5]      = recal_rx_lane5 & ((recal_state_cal & ~is_host_q) | (rem_recal_ip & recal_state_cal & is_host_q)) & ~recal_rx_in_degr_width_lanes[5];
assign recal_rx_lane_enable[6]      = recal_rx_lane6 & ((recal_state_cal & ~is_host_q) | (rem_recal_ip & recal_state_cal & is_host_q)) & ~recal_rx_in_degr_width_lanes[6];
assign recal_rx_lane_enable[7]      = recal_rx_lane7 & ((recal_state_cal & ~is_host_q) | (rem_recal_ip & recal_state_cal & is_host_q)) & ~recal_rx_in_degr_width_lanes[7];

//-- If recal causes a RX lane to turn on, make sure to turn it off after the recal finishes.
//-- 9/11assign recal_rx_lane_enable_din[7:0] = recal_rx_lane_enable[7:0] | (recal_rx_lane_enable_q[7:0] & recal_rx_req_q[7:0] & ~recal_rx_done_q[7:0]);
//-- 9/11assign recal_rx_lane_disable[7:0]    = recal_rx_lane_enable_q[7:0] & recal_rx_done_q[7:0];
assign recal_rx_lane_enable_din[7:0] = (recal_rx_lane_enable[7:0] | recal_rx_lane_enable_q[7:0]) & ~(~recal_rx_done[7:0] & recal_rx_done_q[7:0]); //-- falling edge of recal done
assign recal_rx_lane_disable[7:0]    = recal_rx_lane_enable_q[7:0]                               &  (~recal_rx_done[7:0] & recal_rx_done_q[7:0]); //-- falling edge of recal done

assign dl_phy_recal_req_0            = recal_rx_req_q[0];
assign dl_phy_recal_req_1            = recal_rx_req_q[1];
assign dl_phy_recal_req_2            = recal_rx_req_q[2];
assign dl_phy_recal_req_3            = recal_rx_req_q[3];
assign dl_phy_recal_req_4            = recal_rx_req_q[4];
assign dl_phy_recal_req_5            = recal_rx_req_q[5];
assign dl_phy_recal_req_6            = recal_rx_req_q[6];
assign dl_phy_recal_req_7            = recal_rx_req_q[7];

assign recal_rx_done[7:0]            = {phy_dl_recal_done_7, phy_dl_recal_done_6, phy_dl_recal_done_5, phy_dl_recal_done_4, phy_dl_recal_done_3, phy_dl_recal_done_2, phy_dl_recal_done_1, phy_dl_recal_done_0};
assign recal_rx_done_din[7:0]        = (recal_rx_done[7:0] | recal_rx_done_q[7:0] | degraded_lanes[7:0] | recal_rx_in_degr_width_fakeout[7:0]) & ~{8{recal_adv_no_cal | (recal_rx_last_lane & recal_adv_reset_cal)}};
//-- 10/12assign recal_rx_done_din[7:0]        = (recal_rx_done[7:0] | recal_rx_done_q[7:0] | degraded_lanes[7:0]) & ~{8{recal_adv_no_cal | (recal_rx_last_lane & recal_adv_reset_cal)}};
//-- 8/23assign recal_rx_done_din[7:0]        = (recal_rx_done[7:0] | recal_rx_done_q[7:0] | degraded_lanes[7:0]) & ~{8{recal_adv_no_cal}};
 
//-- Need to delay receiving a recal done if that lane is degraded to guarentee the recal message was sent to the other side.  Once we know other side received the message, indicate recal is done.
assign recal_rx_in_degr_width_fakeout[7:0] = ({8{half_width_x4_outer_rx_mode_q & first_recal_started_q & ((is_host_q & rem_recal_ip & recal_state_cal) | (~is_host_q & rem_recal_done_q))}} & 8'h7E) |
                                             ({8{half_width_x4_inner_rx_mode_q & first_recal_started_q & ((is_host_q & rem_recal_ip & recal_state_cal) | (~is_host_q & rem_recal_done_q))}} & 8'hDB) |
                                             ({8{half_width_x8_outer_rx_mode_q & first_recal_started_q & ((is_host_q & rem_recal_ip & recal_state_cal) | (~is_host_q & rem_recal_done_q))}} & 8'h5A) |
                                             ({8{half_width_x8_inner_rx_mode_q & first_recal_started_q & ((is_host_q & rem_recal_ip & recal_state_cal) | (~is_host_q & rem_recal_done_q))}} & 8'hA5);

//-- Needs to be active as soon as we know we are in a degraded mode to stop from enabling the RX lanes
assign recal_rx_in_degr_width_lanes[7:0]   = ({8{half_width_x4_outer_rx_mode_q}} & 8'h7E) |
                                             ({8{half_width_x4_inner_rx_mode_q}} & 8'hDB) |
                                             ({8{half_width_x8_outer_rx_mode_q}} & 8'h5A) |
                                             ({8{half_width_x8_inner_rx_mode_q}} & 8'hA5);



//-- Needs to be active as soon as we know we are in a degraded mode to stop from enabling the TX lanes
assign recal_tx_in_degr_width_lanes[7:0] = ({8{half_width_x4_outer_tx_mode_q}} & 8'h7E) |
                                           ({8{half_width_x4_inner_tx_mode_q}} & 8'hDB) |
                                           ({8{half_width_x8_outer_tx_mode_q}} & 8'h5A) |
                                           ({8{half_width_x8_inner_tx_mode_q}} & 8'hA5);



assign recal_tx_lane_number_din[3:0] = recal_tx_lane_number_reset  ? recal_tx_lane_number_reset_val[3:0] :
                                       recal_tx_lane_number_update ? recal_tx_lane_number_next[3:0] :
                                                                     recal_tx_lane_number_q[3:0];

assign recal_tx_lane_number_update   = (rem_recal_done_din & ~rem_recal_done_q & first_recal_started_q);
//-- 8/23assign recal_tx_lane_number_update   = ((rem_recal_done_din & ~rem_recal_done_q & first_recal_started_q) | recal_adv_reset_cal);

//-- Update reset value based on if lanes are disabled or not
assign recal_tx_lane_number_reset    = (recal_tx_lane_number_update & recal_tx_last_lane) | (init_train_done_set);
assign recal_tx_last_lane            = (tx_lane_swap_q[1] & recal_tx_lane0) | (~tx_lane_swap_q[1] & recal_tx_lane7);

assign recal_tx_lane0                = (recal_tx_lane_number_q[3:0] == 4'h0);
assign recal_tx_lane1                = (recal_tx_lane_number_q[3:0] == 4'h1);
assign recal_tx_lane2                = (recal_tx_lane_number_q[3:0] == 4'h2);
assign recal_tx_lane3                = (recal_tx_lane_number_q[3:0] == 4'h3);
assign recal_tx_lane4                = (recal_tx_lane_number_q[3:0] == 4'h4);
assign recal_tx_lane5                = (recal_tx_lane_number_q[3:0] == 4'h5);
assign recal_tx_lane6                = (recal_tx_lane_number_q[3:0] == 4'h6);
assign recal_tx_lane7                = (recal_tx_lane_number_q[3:0] == 4'h7);

//-- Starting lane to recal depends on...
//-- 1. half width or full width
//-- 2. configured in 
//-- 3. lanes are reversed
assign recal_tx_lane_number_reset_val[3:0] = ({4{~tx_lane_swap_q[1]}} & 4'h0) |
                                             ({4{ tx_lane_swap_q[1]}} & 4'h7);

//-- All possible ways for how the lane number can increment to the next lane to recal
assign recal_tx_lane_number_next[3:0]      = ({4{cfg_x8 & ~tx_lane_swap_q[1]}} & full_width_x8_tx_mode_next_ln[3:0]    ) |
                                             ({4{cfg_x8 &  tx_lane_swap_q[1]}} & full_width_x8_tx_mode_rev_next_ln[3:0]) |
                                             ({4{cfg_x4 & ~tx_lane_swap_q[1]}} & full_width_x4_tx_mode_next_ln[3:0]    ) |
                                             ({4{cfg_x4 &  tx_lane_swap_q[1]}} & full_width_x4_tx_mode_rev_next_ln[3:0]);

assign full_width_x8_tx_mode_next_ln[3:0]     = ({4{recal_tx_lane0 & ~recal_adv_reset_cal}} & 4'h1) |
                                                ({4{recal_tx_lane1 & ~recal_adv_reset_cal}} & 4'h2) |
                                                ({4{recal_tx_lane2 & ~recal_adv_reset_cal}} & 4'h3) |
                                                ({4{recal_tx_lane3 & ~recal_adv_reset_cal}} & 4'h4) |
                                                ({4{recal_tx_lane4 & ~recal_adv_reset_cal}} & 4'h5) |
                                                ({4{recal_tx_lane5 & ~recal_adv_reset_cal}} & 4'h6) |
                                                ({4{recal_tx_lane6 & ~recal_adv_reset_cal}} & 4'h7) |
                                                ({4{recal_tx_lane7 & ~recal_adv_reset_cal}} & 4'h0) |
                                                ({4{                  recal_adv_reset_cal}} & 4'h0);
assign full_width_x8_tx_mode_rev_next_ln[3:0] = ({4{recal_tx_lane7 & ~recal_adv_reset_cal}} & 4'h6) |
                                                ({4{recal_tx_lane6 & ~recal_adv_reset_cal}} & 4'h5) |
                                                ({4{recal_tx_lane5 & ~recal_adv_reset_cal}} & 4'h4) |
                                                ({4{recal_tx_lane4 & ~recal_adv_reset_cal}} & 4'h3) |
                                                ({4{recal_tx_lane3 & ~recal_adv_reset_cal}} & 4'h2) |
                                                ({4{recal_tx_lane2 & ~recal_adv_reset_cal}} & 4'h1) |
                                                ({4{recal_tx_lane1 & ~recal_adv_reset_cal}} & 4'h0) |
                                                ({4{recal_tx_lane0 & ~recal_adv_reset_cal}} & 4'h7) |
                                                ({4{                  recal_adv_reset_cal}} & 4'h7);
assign full_width_x4_tx_mode_next_ln[3:0]     = ({4{recal_tx_lane0 & ~recal_adv_reset_cal}} & 4'h2) |
                                                ({4{recal_tx_lane2 & ~recal_adv_reset_cal}} & 4'h5) |
                                                ({4{recal_tx_lane5 & ~recal_adv_reset_cal}} & 4'h7) |
                                                ({4{recal_tx_lane7 & ~recal_adv_reset_cal}} & 4'h0) |
                                                ({4{                  recal_adv_reset_cal}} & 4'h0);
assign full_width_x4_tx_mode_rev_next_ln[3:0] = ({4{recal_tx_lane7 & ~recal_adv_reset_cal}} & 4'h5) |
                                                ({4{recal_tx_lane5 & ~recal_adv_reset_cal}} & 4'h2) |
                                                ({4{recal_tx_lane2 & ~recal_adv_reset_cal}} & 4'h0) |
                                                ({4{recal_tx_lane0 & ~recal_adv_reset_cal}} & 4'h7) |
                                                ({4{                  recal_adv_reset_cal}} & 4'h7);

//-- Turn on a lane if it is powered off when a recal needs to happen and we are not in a degraded width for that lane
assign recal_tx_lane_enable[0]      = recal_tx_lane0 & recal_state_cal & tx_psave_sts_q[0] & ~recal_tx_in_degr_width_lanes[0];
assign recal_tx_lane_enable[1]      = recal_tx_lane1 & recal_state_cal & tx_psave_sts_q[1] & ~recal_tx_in_degr_width_lanes[1];
assign recal_tx_lane_enable[2]      = recal_tx_lane2 & recal_state_cal & tx_psave_sts_q[2] & ~recal_tx_in_degr_width_lanes[2];
assign recal_tx_lane_enable[3]      = recal_tx_lane3 & recal_state_cal & tx_psave_sts_q[3] & ~recal_tx_in_degr_width_lanes[3];
assign recal_tx_lane_enable[4]      = recal_tx_lane4 & recal_state_cal & tx_psave_sts_q[4] & ~recal_tx_in_degr_width_lanes[4];
assign recal_tx_lane_enable[5]      = recal_tx_lane5 & recal_state_cal & tx_psave_sts_q[5] & ~recal_tx_in_degr_width_lanes[5];
assign recal_tx_lane_enable[6]      = recal_tx_lane6 & recal_state_cal & tx_psave_sts_q[6] & ~recal_tx_in_degr_width_lanes[6];
assign recal_tx_lane_enable[7]      = recal_tx_lane7 & recal_state_cal & tx_psave_sts_q[7] & ~recal_tx_in_degr_width_lanes[7];

//-- If recal causes a TX lane to turn on, make sure to turn it off after the recal finishes.
assign recal_tx_lane_enable_din[7:0] = (recal_tx_lane_enable[7:0] | (recal_tx_lane_enable_q[7:0] & {8{~rem_recal_done_q}})) & ~degraded_lanes[7:0];
assign recal_tx_lane_disable[7:0]    = recal_tx_lane_enable_q[7:0] & {8{rem_recal_done_q}};
//-- 9/11assign recal_tx_lane_enable_din[7:0] = (recal_tx_lane_enable[7:0] | (recal_tx_lane_enable_q[7:0] & {8{rem_recal_status[1:0] != 2'b00}})) & ~degraded_lanes[7:0];
//-- 9/11assign recal_tx_lane_disable[7:0]    = recal_tx_lane_enable_q[7:0] & {8{rem_recal_status[1:0] == 2'b00}};
assign recal_tx_send_TS1s            = ~PM_tx_send_TS1s & (|recal_tx_lane_enable_q[7:0]);

//-- Power management message in Idle and Replay flits.
//--  0000   = Power Management Disabled
//--  0001   = Running in 1/4  width mode
//--  0010   = Running in 1/2  width mode
//--  0011   = Running in full width mode
//--  0100   = wake from 1/4 -> 1/2
//--  0101   = wake from 1/2 -> full
//--  0110   = ready to switch 1/4 -> 1/2
//--  0111   = ready to switch 1/2 -> full
//--  1000   = switching from full -> 1/2
//--  1001   = switching from 1/2  -> 1/4
//--  OTHERS = RESERVED

//-- DL2TL Status
//--"00" => not trained or retraining
//--"01" => quarter width
//--"10" => half width
//--"11" => full width

//-- TL2DL Lane Width Request
//--"00" => Power Management not invoked
//--"01" => quarter width
//--"10" => half width
//--"11" => full width

assign rem_PM_enable              = rx_tx_rem_PM_enable;

//-- Power Management is enabled if this side has PM enabled, remote side has PM enabled, and both RX and TX were able to train to full width
assign PM_enable_din              = (cfg_omi_PM_enable_q & rem_PM_enable & ~PM_disable);

assign rem_PM_status[3:0]         = {4{PM_enable_q}} & rx_tx_pm_status[3:0];
assign rem_PM_status_dly_din[3:0] = rem_PM_status[3:0];
assign rem_PM_status_updated      = frame_vld_q & (rem_PM_status[3:0] != rem_PM_status_dly_q[3:0]);

//-- Constants for lanes to kill or enable based on if we are running in x4 or x8 mode
assign full_width_enable_lanes[7:0]     = ({8{cfg_x8}} & 8'hFF) | ({8{cfg_x4}} & 8'hA5);
assign half_width_disable_lanes[7:0]    = ({8{cfg_x8}} & 8'h5A) | ({8{cfg_x4}} & 8'h7E);
assign half_width_enable_lanes[7:0]     = ({8{cfg_x8}} & 8'hA5); //--  can't go from quarter width into half
assign quarter_width_disable_lanes[7:0] = ({8{cfg_x8}} & 8'h7E); //--  can't go into quarter width from half



assign PM_rx_lanes_disable[7:0]       = ({8{(rem_PM_status[3:0] == 4'b1000) & rem_PM_status_updated}} & half_width_disable_lanes[7:0]   ) | //-- Change RX to half    width
                                        ({8{(rem_PM_status[3:0] == 4'b1001) & rem_PM_status_updated}} & quarter_width_disable_lanes[7:0]);  //-- Change RX to quarter width
assign tx_rx_PM_rx_lanes_disable[7:0] = PM_rx_lanes_disable[7:0];

assign PM_rx_lanes_enable[7:0]        = retrain_not_due2_PM                                                                 ? full_width_enable_lanes[7:0] :
                                        (end_of_start_retrain & (PM_state_wake_quarter2half | PM_state_ready_quarter2half)) ? half_width_enable_lanes[7:0] :
                                        (end_of_start_retrain & (PM_state_wake_half2full    | PM_state_ready_half2full   )) ? full_width_enable_lanes[7:0] :
                                                                                                                              8'h00;
assign tx_rx_PM_rx_lanes_enable[7:0]  = PM_rx_lanes_enable[7:0];

//-- This signal is only used to indicate the requested lane width from either the TL or the DL config1 register.
assign requested_lane_width_din[1:0]  = ({2{cfg_lane_width_sel_q[1:0] == 2'b00}} & tl2dl_lane_width_request[1:0]) | 
                                        ({2{cfg_lane_width_sel_q[1:0] != 2'b00}} &     cfg_lane_width_sel_q[1:0]);

//-- This signal is used to control the Power Management State Machine with a new lane width request.
//-- Don't accept new PM requests if a previous PM request is in progress or if a recal is in progress.
//-- 9/11 assign lane_width_req_pend_din[1:0] = (  {2{PM_enable_q & ~lane_width_change_ip_q & both_sides_switch_not_ip}} &
assign lane_width_req_pend_din[1:0] = (  {2{PM_enable_q & ~lane_width_change_ip_q & both_sides_switch_not_ip & ~(recal_state_cal | recal_start)}} &
                                      ( ({2{cfg_lane_width_sel_q[1:0] == 2'b00}} & tl2dl_lane_width_request[1:0]) | 
                                        ({2{cfg_lane_width_sel_q[1:0] != 2'b00}} &     cfg_lane_width_sel_q[1:0]) ) );

assign both_sides_switch_not_ip     = ( (PM_state_running_full    & rem_PM_status[3:0] == 4'b0011) |
                                        (PM_state_running_half    & rem_PM_status[3:0] == 4'b0010) |
                                        (PM_state_running_quarter & rem_PM_status[3:0] == 4'b0001) |
                                        (PM_state_disabled        & rem_PM_status[3:0] == 4'b0000) ) & frame_vld_q;

assign PM_is_host_din               = (lane_width_req_pend_q[1:0] != 2'b00) | PM_is_host_q;
assign req_quarter_width            = (lane_width_req_pend_q[1:0] == 2'b01) & ~PM_state_running_quarter & ~tx_psave_timer_full2half_ena_q;
assign req_half_width               = ((lane_width_req_pend_q[1:0] == 2'b10) | (PM_is_host_q & PM_back_to_quarter_start)) & ~PM_state_running_half & ~tx_psave_timer_half2quarter_ena_q;
assign req_full_width               = (lane_width_req_pend_q[1:0] == 2'b11) & ~PM_state_running_full;

assign lane_width_change_ip_din     = ( (~lane_width_change_ip_q & (PM_state_update & (PM_state_running_quarter | PM_state_running_half | PM_state_running_full))) | 
                                        ( lane_width_change_ip_q & ~lane_width_change_done                                                                       ) ) & PM_enable_q;

assign lane_width_change_ip_dly_din[1:0] = {lane_width_change_ip_dly_q[0], lane_width_change_ip_q};

assign lane_width_change_done       = (PM_state_running_quarter | PM_state_running_half | PM_state_running_full | PM_state_disabled);

assign trn_flt_pm_narrow_not_wide   = PM_narrow_not_wide_q;
assign PM_narrow_not_wide_din       = (init_train_done_set & 1'b1) | (~init_train_done_set & PM_narrow_not_wide_next);
assign PM_narrow_not_wide_next      = ( PM_narrow_not_wide_q & ((PM_width_move_up   & ~PM_narrow_not_wide_q) | (~PM_width_move_up   & PM_narrow_not_wide_q))) | 
                                      (~PM_narrow_not_wide_q & ((PM_width_move_down & ~PM_narrow_not_wide_q) | (~PM_width_move_down & PM_narrow_not_wide_q)));

assign PM_width_move_down           = (PM_state_running_full    & (PM_adv_EP_full2half    | PM_adv_host_full2half   )) |
                                      (PM_state_running_half    & (PM_adv_EP_half2quarter | PM_adv_host_half2quarter));
assign PM_width_move_up             = (PM_state_running_half    & (PM_adv_wake_half2full   )) |
                                      (PM_state_running_quarter & (PM_adv_wake_quarter2half));




//-- Once Power Management message is sent when switching down in width, we need to start a timer that counts up to 24 to send TS1s on the "dead lanes" to ensure the PM switch msg was receiving correctly.
assign PM_msg_sent                   = flt_trn_pm_msg_sent & PM_narrow_not_wide_q;  //-- Only enable the tx lane timer when moving down in width
assign PM_msg_sent_dly_din           = PM_msg_sent & (cycle_cnt_q[5]); //-- Don't start the timer on a stall
assign PM_wake_msg_sent_din          = (((PM_state_wake_half2full | PM_state_wake_quarter2half) & flt_trn_pm_msg_sent) | PM_wake_msg_sent_q) & ~(PM_adv_ready_half2full | PM_adv_ready_quarter2half);
assign PM_tx_lane_timer_ena_din      = ((PM_msg_sent & (~cycle_cnt_q[5]) | PM_msg_sent_dly_q) | PM_tx_lane_timer_ena_q) & ~PM_tx_lane_timer_done;
assign PM_tx_lane_timer_done         = (PM_tx_lane_timer_q[4:0] == 5'b1_0111) | retrain_not_due2_PM;
assign PM_tx_lane_timer_inc          = PM_tx_lane_timer_ena_q & ~PM_tx_lane_timer_done & ~cycle_cnt_q[5]; //-- Hold value on a stall
assign PM_tx_lane_timer_din[4:0]     = PM_tx_lane_timer_done ? 5'b00000 :
                                       PM_tx_lane_timer_inc  ? PM_tx_lane_timer_q[4:0] + 5'b00001 :
                                                               PM_tx_lane_timer_q[4:0];

//--  make sure disabled lanes are still driving TS1s
assign PM_tx_send_TS1s               = PM_tx_lane_timer_ena_q & (PM_tx_lane_timer_q[4:0] >= 5'b00110) & (PM_tx_lane_timer_q[4:0] <= 5'b11000) & ~(PM_state_wake_half2full | PM_state_wake_quarter2half | PM_state_ready_half2full | PM_state_ready_quarter2half); //-- Send 2 cycles earlier to allow time to propagate through latches 
assign PM_store_reset                = (cfg_x8 & ((x2_tx_mode & PM_state_running_quarter & (PM_tx_lane_timer_q[4:0] == 5'b00111) & PM_tx_lane_timer_inc) |
                                                  (x4_tx_mode & PM_state_running_half    & (PM_tx_lane_timer_q[4:0] == 5'b00101) & PM_tx_lane_timer_inc) ) )
                                     | (cfg_x4 & ( x2_tx_mode & PM_state_running_half    & (PM_tx_lane_timer_q[4:0] == 5'b00111) & PM_tx_lane_timer_inc  ) );

//-- Only reset the latches in TX align when going down in width (link is still up and active).  Otherwise, latches are reset during a retrain
assign trn_agn_PM_store_reset        = PM_store_reset;

//-- TS1 should only be sent on lanes that are disabled.  For recal, data is already a scrambled PRBS pattern
assign trn_agn_send_TS1[7:0]         = ({8{PM_tx_send_TS1s   }} &  PM_tx_lanes_disable_q[7:0]) |
                                       ({8{recal_tx_send_TS1s}} & recal_tx_lane_enable_q[7:0]);

//-- Turn off lanes after PM message is sent and 16 TS1 patterns
assign PM_tx_lanes_disable_din[7:0]     = PM_tx_lane_timer_ena_q ? (PM_tx_lanes_disable[7:0] | PM_tx_lanes_disable_q[7:0]) & ~PM_tx_lanes_enable[7:0] : (PM_tx_lanes_disable_q[7:0] & ~PM_tx_lanes_enable[7:0]);
assign PM_tx_lanes_disable[7:0]         = PM_tx_lanes_disable_half[7:0] | PM_tx_lanes_disable_quarter[7:0];
assign PM_tx_lanes_disable_half[7:0]    = {8{PM_state_host_full2half    | PM_state_EP_full2half   }} & half_width_disable_lanes[7:0];
assign PM_tx_lanes_disable_quarter[7:0] = {8{PM_state_host_half2quarter | PM_state_EP_half2quarter}} & quarter_width_disable_lanes[7:0];

assign PM_tx_lanes_enable[7:0]          = (PM_tx_lanes_enable_half[7:0] | PM_tx_lanes_enable_full[7:0]);
assign PM_tx_lanes_enable_half[7:0]     = {8{(PM_adv_run_half & (PM_state_wake_quarter2half | PM_state_ready_quarter2half))                        }} & half_width_enable_lanes[7:0];
assign PM_tx_lanes_enable_full[7:0]     = {8{(PM_adv_run_full & (PM_state_wake_half2full    | PM_state_ready_half2full   )) | (retrain_not_due2_PM)}} & full_width_enable_lanes[7:0];

//-- Don't stop tranmitting on the TX lanes until the timer is done
//-- 10/11assign disabled_tx_lanes_hold_din[7:0] = ((PM_tx_lane_timer_ena_q & ~PM_tx_lane_timer_done) | recal_tx_send_TS1s) ? ((disabled_tx_lanes_hold_q[7:0] & ~recal_tx_lane_enable_q[7:0]) | recal_tx_lane_disable[7:0]) : disabled_tx_lanes_q[7:0];
assign disabled_tx_lanes_hold_din[7:0] = (PM_tx_lane_timer_ena_q & ~PM_tx_lane_timer_done) ? ((disabled_tx_lanes_hold_q[7:0] & ~recal_tx_lane_enable_q[7:0]) | recal_tx_lane_disable[7:0]) :
                                         (recal_tx_send_TS1s                             ) ? ((disabled_tx_lanes_q[7:0]      & ~recal_tx_lane_enable_q[7:0]) | recal_tx_lane_disable[7:0]) :
                                                                                               disabled_tx_lanes_q[7:0];

assign PM_state_reset             = ~PM_enable_q;

//-- Power Management State Machine
assign PM_state_din[3:0]          = PM_state_reset  ? 4'b0000 :
                                    PM_state_update ? PM_next_state[3:0] :
                                                      PM_state_q[3:0];
//-- PM state machine needs to advance to a new state
assign PM_state_update            = PM_adv_run_quarter | PM_adv_run_half | PM_adv_run_full | PM_adv_wake_quarter2half | PM_adv_wake_half2full |
                                    PM_adv_ready_quarter2half | PM_adv_ready_half2full | PM_adv_host_half2quarter | PM_adv_host_full2half |
                                    PM_adv_EP_half2quarter | PM_adv_EP_full2half | PM_adv_disabled;

assign PM_next_state[3:0]         = (4'b0000 & {4{PM_adv_disabled          }}) |
                                    (4'b0001 & {4{PM_adv_run_quarter       }}) |
                                    (4'b0010 & {4{PM_adv_run_half          }}) |
                                    (4'b0011 & {4{PM_adv_run_full          }}) |
                                    (4'b0100 & {4{PM_adv_wake_quarter2half }}) |
                                    (4'b0101 & {4{PM_adv_wake_half2full    }}) |
                                    (4'b0110 & {4{PM_adv_ready_quarter2half}}) |
                                    (4'b0111 & {4{PM_adv_ready_half2full   }}) |
                                    (4'b1000 & {4{PM_adv_host_full2half    }}) |
                                    (4'b1001 & {4{PM_adv_EP_full2half      }}) |
                                    (4'b1010 & {4{PM_adv_host_half2quarter }}) |
                                    (4'b1011 & {4{PM_adv_EP_half2quarter   }});

//-- Conditions to advance to the specified state
assign PM_adv_run_full            = ~PM_adv_disabled & (
                                    (PM_state_disabled           & PM_enable_q & selected_width[2] & init_train_done) |
                                    (PM_state_wake_half2full     & (rem_PM_status[3:0] == 4'b0111) & (rx_psave_sts_q[7:0] == (~full_width_enable_lanes[7:0])) & lane_width_change_ip_q & end_of_start_retrain & PM_start_retrain_sent_q) |
                                    (PM_state_ready_half2full    & (rem_PM_status[3:0] == 4'b0101) & lane_width_change_ip_q & end_of_start_retrain) |
                                    (~PM_state_disabled          & (retrain_not_due2_PM)));

assign PM_adv_run_half            = ~(PM_adv_disabled | PM_adv_run_full) & (
                                    (PM_state_disabled           & PM_enable_q & selected_width[1] & init_train_done) |
                                    (PM_state_host_full2half     & (PM_tx_lane_timer_q[4:0] == 5'b00010) & lane_width_change_ip_q) |
                                    (PM_state_EP_full2half       & (PM_tx_lane_timer_q[4:0] == 5'b00010) & lane_width_change_ip_q) |
                                    (PM_state_wake_quarter2half  & (rem_PM_status[3:0] == 4'b0110) & (rx_psave_sts_q[7:0] == half_width_disable_lanes[7:0]) & lane_width_change_ip_q & end_of_start_retrain & PM_start_retrain_sent_q) |
                                    (PM_state_ready_quarter2half & (rem_PM_status[3:0] == 4'b0100) & lane_width_change_ip_q & end_of_start_retrain));

assign PM_adv_run_quarter         = ~(PM_adv_disabled | PM_adv_run_full) & (
                                    (PM_state_disabled           & PM_enable_q & selected_width[0] & init_train_done) |
                                    (PM_state_host_half2quarter  & (PM_tx_lane_timer_q[4:0] == 5'b00010) & lane_width_change_ip_q) |
                                    (PM_state_EP_half2quarter    & (PM_tx_lane_timer_q[4:0] == 5'b00010) & lane_width_change_ip_q));

//-- 10/11assign PM_adv_wake_quarter2half   = ~(PM_adv_disabled | PM_adv_run_full) & (
//-- 10/11                                    PM_state_running_quarter     & (req_half_width | (rem_PM_status[3:0] == 4'b0100)) & ~lane_width_change_ip_q);
//-- 10/11assign PM_adv_wake_half2full      = ~(PM_adv_disabled | PM_adv_run_full) & (
//-- 10/11                                    PM_state_running_half        & (req_full_width | (rem_PM_status[3:0] == 4'b0101)) & ~lane_width_change_ip_q);
//-- If we request to move down in width (half->quarter), allow wake latch needs to make sure that the previous allowed wake for half->full is cleared.  Otherwise, clear if the normal wake from half->full is processed.
assign PM_allow_wake_clear_half   = PM_adv_wake_half2full | PM_adv_EP_half2quarter | PM_adv_host_half2quarter;
assign PM_allow_wake_clear        = (PM_state_running_quarter & PM_adv_wake_quarter2half) |
                                    (PM_state_running_half    & PM_allow_wake_clear_half) |
                                                                PM_adv_run_full           | //-- unexpected retrain
                                                                PM_adv_disabled;            //-- PM disabled

//-- psave status achieved for original PM request before processing a new PM request to wake up the sleeping lanes.
//-- Eg: x8->x4 transition succesfully, A recal start on one of the powered down lanes comes in.  Recal turns on a powered off lane, but we want PM
//--     to proceed without waiting for a recal to turn the lane off again.  So, we make sure that at some initial point the psaves were the expected values.
assign PM_allow_wake_din          = ( ((PM_state_running_quarter & (tx_psave_sts_q[7:0] == quarter_width_disable_lanes[7:0]) & (rx_psave_sts_q[7:0] == quarter_width_disable_lanes[7:0])) |
                                       (PM_state_running_half    & (tx_psave_sts_q[7:0] ==    half_width_disable_lanes[7:0]) & (rx_psave_sts_q[7:0] ==    half_width_disable_lanes[7:0])) ) | PM_allow_wake_q) & ~PM_allow_wake_clear;

assign PM_adv_wake_quarter2half   = ~(PM_adv_disabled | PM_adv_run_full) & (
                                    PM_state_running_quarter     & (req_half_width | (rem_PM_status[3:0] == 4'b0100)) & ~lane_width_change_ip_q & PM_allow_wake_q);
assign PM_adv_wake_half2full      = ~(PM_adv_disabled | PM_adv_run_full) & (
                                    PM_state_running_half        & (req_full_width | (rem_PM_status[3:0] == 4'b0101)) & ~lane_width_change_ip_q & PM_allow_wake_q);

assign PM_adv_ready_quarter2half  = ~(PM_adv_disabled | PM_adv_run_full) & (
                                    PM_state_wake_quarter2half   & ~req_half_width & ~PM_is_host_q & PM_wake_msg_sent_q &
                                    (rx_psave_sts_q[7:0] ==   half_width_disable_lanes[7:0]) & (tx_psave_sts_q[7:0] ==   half_width_disable_lanes[7:0]));
assign PM_adv_ready_half2full     = ~(PM_adv_disabled | PM_adv_run_full) & (
                                    PM_state_wake_half2full      & ~req_full_width & ~PM_is_host_q & PM_wake_msg_sent_q & 
                                    (rx_psave_sts_q[7:0] == (~full_width_enable_lanes[7:0])) & (tx_psave_sts_q[7:0] == (~full_width_enable_lanes[7:0])));

//-- Delay updating the PM msg if a transition would happen around a stall.  should only need to delay when transitioning down in width
assign around_stall               = (cycle_cnt_q[5:0] >= 6'b011100) | (cycle_cnt_q[5:0] == 6'b000000);
assign around_stall_EP            = around_stall & ((rem_PM_status[3:0] == 4'b1000) | (rem_PM_status[3:0] == 4'b1001)) & rem_PM_status_updated & ~PM_is_host_q;
assign around_stall_EP_hold_din   = (around_stall_EP | around_stall_EP_hold_q) & around_stall;
assign around_stall_EP_hold_done  = around_stall_EP_hold_q & ~around_stall;
assign PM_adv_host_full2half      = ~(PM_adv_disabled | PM_adv_run_full) & (
                                    PM_state_running_full & ~around_stall & req_half_width                  & ~lane_width_change_ip_q);
assign PM_adv_EP_full2half        = ~(PM_adv_disabled | PM_adv_run_full) & (
                                    PM_state_running_full & ~around_stall & (((rem_PM_status[3:0] == 4'b1000) & rem_PM_status_updated) | around_stall_EP_hold_done) & ~lane_width_change_ip_q);
assign PM_adv_host_half2quarter   = ~(PM_adv_disabled | PM_adv_run_full) & (
                                    PM_state_running_half & ~around_stall & req_quarter_width               & ~lane_width_change_ip_q);
assign PM_adv_EP_half2quarter     = ~(PM_adv_disabled | PM_adv_run_full) & (
                                    PM_state_running_half & ~around_stall & (((rem_PM_status[3:0] == 4'b1001) & rem_PM_status_updated) | around_stall_EP_hold_done) & ~lane_width_change_ip_q);

//-- Reasons to stop power management from happening
assign PM_adv_disabled            = ~PM_state_disabled & PM_stop_q;

//-- Power Management State Decodes
assign PM_state_disabled           = (PM_state_q[3:0] == 4'b0000);
assign PM_state_running_quarter    = (PM_state_q[3:0] == 4'b0001);
assign PM_state_running_half       = (PM_state_q[3:0] == 4'b0010);
assign PM_state_running_full       = (PM_state_q[3:0] == 4'b0011);
assign PM_state_wake_quarter2half  = (PM_state_q[3:0] == 4'b0100);
assign PM_state_wake_half2full     = (PM_state_q[3:0] == 4'b0101);
assign PM_state_ready_quarter2half = (PM_state_q[3:0] == 4'b0110);
assign PM_state_ready_half2full    = (PM_state_q[3:0] == 4'b0111);
assign PM_state_host_full2half     = (PM_state_q[3:0] == 4'b1000);
assign PM_state_EP_full2half       = (PM_state_q[3:0] == 4'b1001);
assign PM_state_host_half2quarter  = (PM_state_q[3:0] == 4'b1010);
assign PM_state_EP_half2quarter    = (PM_state_q[3:0] == 4'b1011);

//-- When moving down in widths, update the PM msg sent to flit the cycle after the transition down msg sent signal was active
assign PM_msg_8to2_early_din       = (((PM_msg_sent & (PM_state_host_full2half    | PM_state_EP_full2half   )) | PM_msg_8to2_early_q) & ~PM_state_running_half   ) & frame_vld_q;
assign PM_msg_9to1_early_din       = (((PM_msg_sent & (PM_state_host_half2quarter | PM_state_EP_half2quarter)) | PM_msg_9to1_early_q) & ~PM_state_running_quarter) & frame_vld_q;
assign PM_msg8                     = (PM_state_host_full2half    | PM_state_EP_full2half   ) & ~PM_msg_8to2_early_q;
assign PM_msg9                     = (PM_state_host_half2quarter | PM_state_EP_half2quarter) & ~PM_msg_9to1_early_q;

assign PM_msg[3:0]                 = (4'b0000 & {4{PM_state_disabled                             }}) |
                                     (4'b0001 & {4{PM_state_running_quarter | PM_msg_9to1_early_q}}) |
                                     (4'b0010 & {4{PM_state_running_half    | PM_msg_8to2_early_q}}) |
                                     (4'b0011 & {4{PM_state_running_full                         }}) |
                                     (4'b0100 & {4{PM_state_wake_quarter2half                    }}) |
                                     (4'b0101 & {4{PM_state_wake_half2full                       }}) |
                                     (4'b0110 & {4{PM_state_ready_quarter2half                   }}) |
                                     (4'b0111 & {4{PM_state_ready_half2full                      }}) |
                                     (4'b1000 & {4{PM_msg8                                       }}) |
                                     (4'b1001 & {4{PM_msg9                                       }});

assign trn_flt_pm_msg[3:0]         = PM_msg[3:0];

assign PM_stop_din                 = PM_stop_q | (PM_disable);

//-- Interrupt Flit stream to insert PM request from TL
assign send_PM_ready_msg_din       = (PM_adv_ready_half2full | PM_adv_ready_quarter2half);
assign retrain_not_due2_PM_dly_din = retrain_not_due2_PM;
assign send_PM_msg                 = ((lane_width_change_ip_q & ~lane_width_change_ip_dly_q[0]) | send_PM_ready_msg_q) & ~retrain_not_due2_PM_dly_q;
assign trn_flt_send_pm_msg         = send_PM_msg;

assign init_train_done             = train_done_q | init_train_done_q;
assign init_train_done_din         = init_train_done;
assign init_train_done_set         = train_done_q & ~init_train_done_q;

//-- Configured and trained width.  If in degraded mode, report lowest width (half-width) for both RX and TX side.
//-- Eg: configured as a x8, TX trains x8 and RX trains x4 outer, report lane width status as x4
//-- 2 - Full    Width
//-- 1 - Half    Width
//-- 0 - Quarter Width (N/A) for either supported width of x4 or x8

//-- Lowest reported RX/TX x4 width
assign x4_width[2:0]              = (3'b100 & {3{(tsm_q[2:1] == 2'b11) & cfg_x4 & (disabled_rx_lanes_cnt[3:0] == 4'h4) & (disabled_tx_lanes_cnt[3:0] == 4'h4)}}) |
                                    (3'b010 & {3{(tsm_q[2:1] == 2'b11) & cfg_x4 & (disabled_rx_lanes_cnt[3:0] == 4'h6) | (disabled_tx_lanes_cnt[3:0] == 4'h6)}}) |
                                    (3'b001 & {3{(tsm_q[2:1] == 2'b11) & 1'b0                                                                                }});

assign x4_rx_width[2:0]           = (3'b100 & {3{(tsm_q[2:1] == 2'b11) & cfg_x4 & (disabled_rx_lanes_cnt[3:0] == 4'h4)}}) |
                                    (3'b010 & {3{(tsm_q[2:1] == 2'b11) & cfg_x4 & (disabled_rx_lanes_cnt[3:0] == 4'h6)}}) |
                                    (3'b001 & {3{(tsm_q[2:1] == 2'b11) & 1'b0                                         }});
assign x4_tx_width[2:0]           = (3'b100 & {3{(tsm_q[2:1] == 2'b11) & cfg_x4 & (disabled_tx_lanes_cnt[3:0] == 4'h4)}}) |
                                    (3'b010 & {3{(tsm_q[2:1] == 2'b11) & cfg_x4 & (disabled_tx_lanes_cnt[3:0] == 4'h6)}}) |
                                    (3'b001 & {3{(tsm_q[2:1] == 2'b11) & 1'b0                                         }});

//-- Lowest reported RX/TX x8 width
assign x8_width[2:0]              = (3'b100 & {3{(tsm_q[2:1] == 2'b11) & cfg_x8 & (disabled_rx_lanes_cnt[3:0] == 4'h0) & (disabled_tx_lanes_cnt[3:0] == 4'h0)}}) |
                                    (3'b010 & {3{(tsm_q[2:1] == 2'b11) & cfg_x8 & (disabled_rx_lanes_cnt[3:0] == 4'h4) | (disabled_tx_lanes_cnt[3:0] == 4'h4)}}) |
                                    (3'b001 & {3{(tsm_q[2:1] == 2'b11) & 1'b0                                                                                }});

assign x8_rx_width[2:0]           = (3'b100 & {3{(tsm_q[2:1] == 2'b11) & cfg_x8 & (disabled_rx_lanes_cnt[3:0] == 4'h0)}}) |
                                    (3'b010 & {3{(tsm_q[2:1] == 2'b11) & cfg_x8 & (disabled_rx_lanes_cnt[3:0] == 4'h4)}}) |
                                    (3'b001 & {3{(tsm_q[2:1] == 2'b11) & 1'b0                                         }});
assign x8_tx_width[2:0]           = (3'b100 & {3{(tsm_q[2:1] == 2'b11) & cfg_x8 & (disabled_tx_lanes_cnt[3:0] == 4'h0)}}) |
                                    (3'b010 & {3{(tsm_q[2:1] == 2'b11) & cfg_x8 & (disabled_tx_lanes_cnt[3:0] == 4'h4)}}) |
                                    (3'b001 & {3{(tsm_q[2:1] == 2'b11) & 1'b0                                         }});

assign selected_width[2:0]        = ({3{cfg_x4}} & x4_width[2:0]) |
                                    ({3{cfg_x8}} & x8_width[2:0]);

//-- Determine initial trained width
assign init_width_din[1:0]        = ( (({2{selected_width[2]}} & 2'b11) |
                                       ({2{selected_width[1]}} & 2'b10) |
                                       ({2{selected_width[0]}} & 2'b01)) & ~{2{init_train_done_q}}) | init_width_q[1:0];

assign current_width[1:0]         = ({2{ retrained_in_degr_width_q}} & 2'b10            ) |
                                    ({2{~retrained_in_degr_width_q}} & init_width_q[1:0]);

//-- Disable Power Management if initial train isn't full width, or we retrained in a degraded width.  Delay killing power management if it was due to EDPL threshold reached, because
//-- this can caused the retrain_not_due2_PM to never fire.
assign PM_disable_due2_EDPL       = end_of_start_retrain & (|EDPL_bad_lane_q[7:0]);
assign PM_disable                 = ((init_width_q[1:0] != 2'b11) | retrained_in_degr_width_q | ((PM_disable_due2_EDPL & ~reg_dl_cya_bits[12]) | (EDPL_thres_reached_q & reg_dl_cya_bits[12])) | PM_stop_q) & init_train_done_q;
//--  11/9/18  assign PM_disable                 = ((init_width_q[1:0] != 2'b11) | retrained_in_degr_width_q | PM_stop_q | EDPL_thres_reached_q) & init_train_done_q;


assign lane_width_next_status[1:0] = ({2{PM_state_running_quarter}} & 2'b01             ) | 
                                     ({2{PM_state_running_half   }} & 2'b10             ) | 
                                     ({2{PM_state_running_full   }} & 2'b11             ) |
                                     ({2{PM_state_disabled       }} & current_width[1:0]);

assign lane_width_status_din[1:0]  = ({2{(~lane_width_change_ip_q &  both_sides_switch_not_ip) & (tsm_q[2:0] == 3'b111)}} & lane_width_next_status[1:0]) |
                                     ({2{( lane_width_change_ip_q | ~both_sides_switch_not_ip) & (tsm_q[2:0] == 3'b111)}} & lane_width_status_q[1:0]   ) |
                                     ({2{                                                        (tsm_q[2:0] != 3'b111)}} & 2'b00                      );


assign dl2tl_lane_width_status[1:0] = lane_width_status_q[1:0];

assign rx_psave_sts_din[7:0]        = {phy_dl_rx_psave_sts_7, phy_dl_rx_psave_sts_6, phy_dl_rx_psave_sts_5, phy_dl_rx_psave_sts_4, phy_dl_rx_psave_sts_3, phy_dl_rx_psave_sts_2, phy_dl_rx_psave_sts_1, phy_dl_rx_psave_sts_0};
assign tx_psave_sts_din[7:0]        = {phy_dl_tx_psave_sts_7, phy_dl_tx_psave_sts_6, phy_dl_tx_psave_sts_5, phy_dl_tx_psave_sts_4, phy_dl_tx_psave_sts_3, phy_dl_tx_psave_sts_2, phy_dl_tx_psave_sts_1, phy_dl_tx_psave_sts_0};

assign psave_sts_off                = (((rx_psave_req_q[7:0] | rx_psave_sts_q[7:0]) & ~degraded_lanes[7:0]) == 8'h00) & 
                                      (((tx_psave_req_q[7:0] | tx_psave_sts_q[7:0]) & ~degraded_lanes[7:0]) == 8'h00);
assign tx_rx_psave_sts_off          = psave_sts_off;
assign tx_rx_retrain_not_due2_PM    = retrain_not_due2_PM;

// If an unexpected retrain happens, stop tsm_q from advancing until all psave sts are correct value, so the retrain dly timer works correctly
assign psaves_done                  = (psave_sts_off &  retrain_not_due2_PM_q) |
                                      (1'b1          & ~retrain_not_due2_PM_q);


assign PM_start_retrain             = (PM_state_wake_quarter2half & (rem_PM_status[3:0] == 4'b0110) & PM_is_host_q & (rx_psave_sts_q[7:0] ==   half_width_disable_lanes[7:0]) & lane_width_change_ip_q) |
                                      (PM_state_wake_half2full    & (rem_PM_status[3:0] == 4'b0111) & PM_is_host_q & (rx_psave_sts_q[7:0] == (~full_width_enable_lanes[7:0])) & lane_width_change_ip_q);
assign PM_start_retrain_din         = (PM_start_retrain | PM_start_retrain_q) & ~(PM_state_running_full | PM_state_running_half);
assign PM_start_retrain_pulse       = PM_start_retrain & ~PM_start_retrain_q;

//-- Make sure a retrain was due to power management
assign PM_start_retrain_sent_din    = (PM_start_retrain | PM_start_retrain_sent_q) & ~end_of_start_retrain;

//-- 
//-- When the initial training sync headers are received to have the endpoint switch up in width, make sure the endpoint's start retrain is done processing an expected retrain, so
//-- the endpoint doesn't incorrectly report an unexpected retrain happens if a crc error messes up the 2nd set of headers (report a remote retrain DIDN'T happen).
assign PM_EP_start_retrain_set      = (PM_state_ready_quarter2half & (rem_PM_status[3:0] == 4'b0100) & lane_width_change_ip_q & remote_retrain_q) |
                                      (PM_state_ready_half2full    & (rem_PM_status[3:0] == 4'b0101) & lane_width_change_ip_q & remote_retrain_q);
assign PM_EP_start_retrain_clear    = end_of_start_retrain;
assign PM_EP_start_retrain_din      = (PM_EP_start_retrain_set | PM_EP_start_retrain_q) & ~(PM_EP_start_retrain_clear);


assign PM_deskew_reset              = PM_start_retrain | (start_retrain & (PM_state_wake_quarter2half | PM_state_wake_half2full | PM_state_ready_half2full | PM_state_ready_quarter2half)) | //-- Normal Conditions
                                      retrain_not_due2_PM; //-- Unexpected Conditions
assign tx_rx_PM_deskew_reset        = PM_deskew_reset;

//-- Power off the TX lanes once 128 good cycles of crc have been received.  On RX, 1 dead cycle every 33, so we'll add on 4 to the cycle count to turn off the lanes
assign tx_psave_timer_reset                = (tx_psave_timer_q[7:0] == 8'd132) | retrain_not_due2_PM;
assign tx_psave_timer_inc                  = (tx_psave_timer_half2quarter_ena_q | tx_psave_timer_full2half_ena_q) & ~tx_psave_timer_reset;
assign tx_psave_timer_full2half_ena_din    = (((rem_PM_status[3:0] == 4'b1000) & rem_PM_status_updated) | tx_psave_timer_full2half_ena_q   ) & ~tx_psave_timer_reset;
assign tx_psave_timer_half2quarter_ena_din = (((rem_PM_status[3:0] == 4'b1001) & rem_PM_status_updated) | tx_psave_timer_half2quarter_ena_q) & ~tx_psave_timer_reset;
assign tx_psave_timer_din[7:0]             = tx_psave_timer_reset ? 8'h00 :
                                             tx_psave_timer_inc   ? tx_psave_timer_q[7:0] + 8'h01 :
                                                                    tx_psave_timer_q[7:0];

assign tx_psave_req_PM[7:0]         = half_width_tx_mode_q[0]                                  ? disabled_tx_lanes_q[7:0] :
                                      retrain_not_due2_PM_q                                    ? ~full_width_enable_lanes[7:0] :
//-- 10/12                                      retrained_in_degr_width_q                                ? disabled_tx_lanes_q[7:0] :
                                      tx_psave_timer_full2half_ena_q    & tx_psave_timer_reset ? half_width_disable_lanes[7:0] :
                                      tx_psave_timer_half2quarter_ena_q & tx_psave_timer_reset ? quarter_width_disable_lanes[7:0] :
                                      (PM_state_wake_quarter2half                           )  ? half_width_disable_lanes[7:0] :
                                      (PM_state_wake_half2full                              )  ? ~full_width_enable_lanes[7:0] :
                                                                                                 tx_psave_req_q;
//-- 10/11                                                                                                ((tx_psave_req_q[7:0] & ~recal_tx_lane_enable_q[7:0]) | recal_tx_lane_disable[7:0]);
//-- Compute lanes that Power Management wants off and then turn on if a recal needs them on.
assign tx_psave_req[7:0]            = (tx_psave_req_PM[7:0] & ~recal_tx_lane_enable_q[7:0]) | recal_tx_lane_disable[7:0];


//-- Kill Host's RX lanes when receiving a PM msg to switch down in width
//-- Endpoints RX lanes switch on recieving a PM msg to switch down in width as well.
assign PM_rx_psave_host_full2half    = (PM_is_host_q & rem_PM_status_updated & (rem_PM_status[3:0] == 4'h8));
assign PM_rx_psave_host_half2quarter = (PM_is_host_q & rem_PM_status_updated & (rem_PM_status[3:0] == 4'h9));

assign rx_psave_req_PM[7:0]          = half_width_rx_mode_q[0]                                 ? disabled_rx_lanes[7:0] :
                                       retrain_not_due2_PM_q                                   ? ~full_width_enable_lanes[7:0] :
                                       (PM_rx_psave_host_half2quarter                        ) ? quarter_width_disable_lanes[7:0] :
                                       (PM_state_EP_half2quarter                             ) ? quarter_width_disable_lanes[7:0] :
                                       (PM_rx_psave_host_full2half                           ) ? half_width_disable_lanes[7:0] :
                                       (PM_state_EP_full2half    | PM_state_wake_quarter2half) ? half_width_disable_lanes[7:0] :
                                       (PM_state_wake_half2full                              ) ? ~full_width_enable_lanes[7:0] :
                                                                                                 rx_psave_req_PM_q[7:0];
assign rx_psave_req_PM_din[7:0]      = rx_psave_req_PM[7:0];

//-- 10/11                                                                                                ((rx_psave_req_q[7:0] & ~recal_rx_lane_enable_q[7:0]) | recal_rx_lane_disable[7:0]);
//-- Compute lanes that Power Management wants off and then turn on if a recal needs them on.
assign rx_psave_req[7:0]            = (rx_psave_req_PM[7:0] & ~recal_rx_lane_enable_q[7:0]) | recal_rx_lane_disable[7:0];

assign tx_psave_req_din[7:0]        = tx_psave_req[7:0] | degraded_lanes[7:0];
assign rx_psave_req_din[7:0]        = rx_psave_req[7:0] | degraded_lanes[7:0];

assign dl_phy_rx_psave_req_0        = rx_psave_req_q[0];
assign dl_phy_rx_psave_req_1        = rx_psave_req_q[1];
assign dl_phy_rx_psave_req_2        = rx_psave_req_q[2];
assign dl_phy_rx_psave_req_3        = rx_psave_req_q[3];
assign dl_phy_rx_psave_req_4        = rx_psave_req_q[4];
assign dl_phy_rx_psave_req_5        = rx_psave_req_q[5];
assign dl_phy_rx_psave_req_6        = rx_psave_req_q[6];
assign dl_phy_rx_psave_req_7        = rx_psave_req_q[7];
assign dl_phy_tx_psave_req_0        = tx_psave_req_q[0];
assign dl_phy_tx_psave_req_1        = tx_psave_req_q[1];
assign dl_phy_tx_psave_req_2        = tx_psave_req_q[2];
assign dl_phy_tx_psave_req_3        = tx_psave_req_q[3];
assign dl_phy_tx_psave_req_4        = tx_psave_req_q[4];
assign dl_phy_tx_psave_req_5        = tx_psave_req_q[5];
assign dl_phy_tx_psave_req_6        = tx_psave_req_q[6];
assign dl_phy_tx_psave_req_7        = tx_psave_req_q[7];


//----------------------
//-- Config Bit Settings
//----------------------


assign tx_rx_cfg_sync_mode                 = cfg_sync_mode_q;

//-- Legal version numbers
//-- cfg'd version # -> received version #
//-- (s) means it trains using short idles
//-- (e) means it trains using EDPL
//-- 8 -> 6s ,7se,8se,9se,11se
//-- 9 -> 3  ,4  ,5e ,6s ,7se,8se,9se,10e ,11se
//-- 10-> 3  ,4  ,5e ,6  ,7e ,9e ,10e ,11e
assign enable_short_idle_version8          = (cfg_omi_version_q[5:0] == 6'b001000) & ((rx_tx_version_number[5:0] == 6'b000110) | //-- host = 8, EP = 6
                                                                                      (rx_tx_version_number[5:0] == 6'b000111) | //-- host = 8, EP = 7
                                                                                      (rx_tx_version_number[5:0] == 6'b001000) | //-- host = 8, EP = 8
                                                                                      (rx_tx_version_number[5:0] == 6'b001001) | //-- host = 8, EP = 9
                                                                                      (rx_tx_version_number[5:0] == 6'b001011)); //-- host = 8, EP = 11
assign enable_short_idle_version9          = (cfg_omi_version_q[5:0] == 6'b001001) & ((rx_tx_version_number[5:0] == 6'b000110) | //-- host = 9, EP = 6
                                                                                      (rx_tx_version_number[5:0] == 6'b000111) | //-- host = 9, EP = 7
                                                                                      (rx_tx_version_number[5:0] == 6'b001000) | //-- host = 9, EP = 8
                                                                                      (rx_tx_version_number[5:0] == 6'b001001) | //-- host = 9, EP = 9
                                                                                      (rx_tx_version_number[5:0] == 6'b001011)); //-- host = 9, EP = 11


assign enable_short_idle_din               = enable_short_idle_version8 | enable_short_idle_version9;
assign tx_rx_cfg_version[5:0]              = cfg_omi_version_q[5:0];
assign trn_flt_enable_short_idle           = enable_short_idle_q;  //-- Version Number 8-F enables short idle
assign tx_rx_enable_short_idle             = enable_short_idle_q;
assign trn_flt_enable_fast_path            = ~cfg_disable_fast_path_q;
assign trn_flt_tl_credits[5:0]             = cfg_tl_credits_q[5:0];

assign trn_flt_inj_ecc_ce        = inj_ecc_ce_q;
assign trn_flt_inj_ecc_ue        = inj_ecc_ue_q;
assign trn_flt_rpb_rm_depth[3:0] = cfg_rpb_rm_depth_q[3:0];
//--                             = inj_ctl_pty_err_q; //-- not currently used
assign tx_rx_inj_pty_err         = inj_data_pty_err_q;

assign inj_ecc_ce_din            = cfg_inj_ecc_ce_q   & ~cfg_inj_ecc_ce_dly_q;   //-- single inject error on rising edge
assign inj_ecc_ue_din            = cfg_inj_ecc_ue_q   & ~cfg_inj_ecc_ue_dly_q;   //-- single inject error on rising edge
assign inj_ctl_pty_err_din       = cfg_inj_ctl_pty_q  & ~cfg_inj_ctl_pty_dly_q;  //-- single inject error on rising edge
assign inj_data_pty_err_din      = cfg_inj_data_pty_q & ~cfg_inj_data_pty_dly_q; //-- single inject error on rising edge


assign cfg_inj_ecc_ce_dly_din    = cfg_inj_ecc_ce_q;
assign cfg_inj_ecc_ue_dly_din    = cfg_inj_ecc_ue_q;
assign cfg_inj_ctl_pty_dly_din   = cfg_inj_ctl_pty_q;
assign cfg_inj_data_pty_dly_din  = cfg_inj_data_pty_q;

//-- bits [463:456] of replay flit
assign trn_flt_link_errors[7:0]            = {reg_dl_error_message[3:0],                                                                     //--7:4 
                                             (tl2dl_tl_event & cfg_tl_event_all_freeze_q ) | (tl2dl_tl_error & cfg_tl_error_all_freeze_q ),  //--3
                                             (tl2dl_tl_event & cfg_tl_event_afu_freeze_q ) | (tl2dl_tl_error & cfg_tl_error_afu_freeze_q ),  //--2
                                             (tl2dl_tl_event & cfg_tl_event_ila_trigger_q) | (tl2dl_tl_error & cfg_tl_error_ila_trigger_q),  //--1
                                             (tl2dl_tl_event & cfg_tl_event_link_down_q  ) | (tl2dl_tl_error & cfg_tl_error_link_down_q  )}; //--0                                             
                          
assign tx_rx_cfg_supported_widths[3:0]     = cfg_omi_supported_widths_q[3:0];


//-- Configuration1 Register (1 per ODL) [scom addresses of x11, x21, x31]
//-- 
//------------------------------------------------------------------------------------------------------------------------------------------
//-- Bits    Access    Init Value   Name                              Description
//-- ----    ------    ----------   ----                              -----------
//-- 63:62   RW        0            Spare                             Spare
//-- 59      RW        0            Pre-IPL PRBS enable               When enabled, will send scrambled data before training starts to allow
//--                                                                  the receivers to lock for the amount of time specified in the Pre-IPL timer
//-- 58:56   RW        100          Pre-IPL PRBS timer                Amount time to send scrambled data before training starts
//--                                                                  "000" = 256 us
//--                                                                  "001" = 1 ms
//--                                                                  "010" = 4 ms
//--                                                                  "011" = 16 ms
//--                                                                  "100" = 64 ms
//--                                                                  "101" = 256 ms
//--                                                                  "110" = 1 s
//--                                                                  "111" = 4 s
//-- 55:52   RW        0000         Pattern B Hysteresis              Number of consecutive pattern B seen before indicating received pattern B.
//--                                                                  "0000" = 16
//--                                                                  "0001" = 24
//--                                                                  "0010" = 32
//--                                                                  "0011" = 40
//--                                                                  "0100" = 48
//--                                                                  "0101" = 56
//--                                                                  "0110" = 64
//--                                                                  "0111" = 72
//--                                                                  "1000" = 80
//--                                                                  "1001" = 96
//--                                                                  "1010" = 128
//--                                                                  "1011" = 256
//--                                                                  "1100" = 512
//--                                                                  "1101" = 1K
//--                                                                  "1110" = 2K
//--                                                                  "1111" = 4K
//-- 51:48   RW        0000         Pattern A Hysteresis              Number of consecutive pattern A seen before indicating received pattern A.
//--                                                                  "0000" = 16
//--                                                                  "0001" = 24
//--                                                                  "0010" = 32
//--                                                                  "0011" = 48
//--                                                                  "0100" = 64
//--                                                                  "0101" = 96
//--                                                                  "0110" = 128
//--                                                                  "0111" = 256
//--                                                                  "1000" = 512
//--                                                                  "1001" = 1024
//--                                                                  "1010" = 2K
//--                                                                  "1011" = 4K
//--                                                                  "1100" = 8K
//--                                                                  "1101" = 16K
//--                                                                  "1110" = 32K
//--                                                                  "1111" = 64K
//-- 47:46   RW        00           Pattern B length                  Number of consecutive 1's and 0's needed to represent training Pattern
//--                                                                  B               => "11111111111111110000000000000000"
//--                                                                  "00" = two X's  => "11111111111111XX00000000000000XX"
//--                                                                  "10" = four X's => "111111111111XXXX000000000000XXXX"
//--                                                                  "01" = one X's  => "111111111111111X000000000000000X"
//--                                                                  "11" = same as "10"
//-- 45:44   RW        00           Pattern A length                  Number of consecutive 1's and 0's needed to represent training Pattern
//--                                                                  A               => "1111111100000000"
//--                                                                  "00" = two X's  => "111111XX000000XX"
//--                                                                  "10" = four X's => "1111XXXX0000XXXX"
//--                                                                  "01" = one X's  => "1111111X0000000X"
//--                                                                  "11" = same as "10"
//-- 43:42   RW        0            TX degraded threshold             Percent of TX traffic that due to crc errors before setting FIR
//--                                                                  "00" = 1%
//--                                                                  "01" = 2%
//--                                                                  "10" = 3%
//--                                                                  "11" = 4%
//-- 41:40   RW        0            RX degraded threshold             Percent of RX traffic that due to crc errors before setting FIR
//--                                                                  "00" = 1%
//--                                                                  "01" = 2%
//--                                                                  "10" = 3%
//--                                                                  "11" = 4%
//-- 39:32   RW        0            TX Lanes disable                  Prevent TX lanes(7:0) from training.
//-- 31:24   RW        0            RX Lanes disable                  Prevent RX lanes(7:0) from training.
//-- 23:20   RW        0            Macro Debug Select                Macro Debug Select
//-- 19      RW        0            Reset Error Hold register         Reset error hold register      when it is read
//-- 18      RW        0            Reset Error Capture register      Reset error capture register   when it is read
//-- 17      RW        0            Reset Threshold Register          Reset error threshold register when it is read
//-- 16      RW        0            Reset Remote Message on Read      Reset the remote register      when it is read
//-- 15      RW        0            Lane Injection Direction          '0' Inject error on RX side of link
//--                                                                  '1' Inject error on TX side of link
//-- 14:12   RW        0            Lane Bit Error injection rate     Injection rate for the lane bit errors
//--                                                                  000 = 1 us
//--                                                                  001 = 8 us
//--                                                                  010 = 64 us
//--                                                                  011 = 512 us
//--                                                                  100 = 4 ms
//--                                                                  101 = 32 ms
//--                                                                  110 = 256 ms
//--                                                                  111 = 2 s
//-- 11:9    RW        000          Lane select                       Lane to inject a periodic error
//-- 8       RW        0            Lane bit error injection enable   Inject a periodic error on a lane
//-- 7:4     RW        0101         EDPL Time Window                  0000 = no time window
//--                                                                  0001 = 4 us   = 1x105 bits
//--                                                                  0010 = 32 us  = 8x105 bits
//--                                                                  0011 = 256 us = 6.4x106 bits
//--                                                                  0100 = 2 ms   = 5.0x107 bits
//--                                                                  0101 = 16 ms  = 4x108 bits
//--                                                                  0110 = 128 ms = 3,2x109 bits
//--                                                                  0111 = 1 s    = 2.5x1010 bits
//--                                                                  1000 = 8 s    = 2x1011 bits
//--                                                                  1001 = 64 s   = 1,6x1012 bits
//--                                                                  1010 = 512 s  = 1.2x1013 bits
//--                                                                  1011 = 4 ks   = 1.0x1014 bits
//--                                                                  1100 = 32 ks  = 8x1014 bits
//--                                                                  1101 = 256 ks = 6.4x1015 bits
//--                                                                  1110 = 2 Ms   = 5.1x1016 bits
//--                                                                  1111 = 16 Ms  = 4x1017 bits = 189 days
//-- 3:1     RW        100          EDPL Error Threshold              000  = disabled
//--                                                                  001  = 2 errors
//--                                                                  010  = 4 errors
//--                                                                  011  = 8 errors
//--                                                                  100  = 16 errors
//--                                                                  101  = 32 errors
//--                                                                  110  = 64 errors
//--                                                                  111  = 128 errors
//-- 0       RW        1            EDPL Enable                       Error Detection Per Lane Override
//--                                                                  EDPL is based on version number, but if this bit is a zero, it will override
//--                                                                  the exchanged mode of operation
//--                                                                  '1' - Based on Version number
//--                                                                  '0' - disabled
assign dl_config1[63:0]                   = reg_dl_config1[63:0];

assign cfg_unused_din[10:9]               = dl_config1[63:62];
assign cfg_lane_width_sel_din[1:0]        = dl_config1[61:60];
assign cfg_pre_IPL_PRBS_ena_din           = dl_config1[59];
assign cfg_pre_IPL_PRBS_timer_din[2:0]    = dl_config1[58:56];
assign cfg_patB_hyst_din[3:0]             = dl_config1[55:52];
assign cfg_patA_hyst_din[3:0]             = dl_config1[51:48];
assign cfg_patB_length_din[1:0]           = dl_config1[47:46];
assign cfg_patA_length_din[1:0]           = dl_config1[45:44];
assign cfg_tx_degraded_threshold_din[1:0] = dl_config1[43:42];
assign cfg_rx_degraded_threshold_din[1:0] = dl_config1[41:40];
assign cfg_tx_lanes_disable_din[7:0]      = dl_config1[39:32];
assign cfg_rx_lanes_disable_din[7:0]      = dl_config1[31:24]; 
assign cfg_macro_dbg_sel_din[3:0]         = dl_config1[23:20];
assign cfg_unused_din[ 8]                 = dl_config1[19]; //-- Implemented in cmn_pmac
assign cfg_unused_din[ 7]                 = dl_config1[18]; //-- Implemented in cmn_pmac
assign cfg_unused_din[ 6]                 = dl_config1[17]; //-- Implemented in cmn_pmac
assign cfg_unused_din[ 5]                 = dl_config1[16]; //-- Implemented in cmn_pmac
assign cfg_BEI_ln_dir_din                 = dl_config1[15];
assign cfg_BEI_ln_rate_din[2:0]           = dl_config1[14:12];
assign cfg_BEI_ln_sel_din[2:0]            = dl_config1[11:9];
assign cfg_BEI_ln_ena_din                 = dl_config1[8];
assign cfg_EDPL_time_window_din[3:0]      = dl_config1[7:4];
assign cfg_EDPL_err_threshold_din[2:0]    = dl_config1[3:1];
assign cfg_EDPL_ena_din                   = dl_config1[0];

assign cfg_cya_bits_ena_din[31:0]         = reg_dl_cya_bits[31:0] | cfg_cya_bits_q[31:0];

assign spare_00_din                       = spare_1F_q     | (|cfg_unused_q[10:0]) | cfg_omi_128_130_en_q | x4_tx_width[0] | x4_rx_width[0] |
                                            x8_rx_width[0] | x8_tx_width[0]        | rx_cfg_x32           | rx_cfg_x16     |
                                            tx_cfg_x32     | tx_cfg_x16            | inj_ctl_pty_err_q    | lane_width_change_ip_dly_q[1]; //--   connect sinkless nets
assign spare_01_din = spare_00_q;
assign spare_02_din = spare_01_q;
assign spare_03_din = spare_02_q;
assign spare_04_din = spare_03_q;
assign spare_05_din = spare_04_q;
assign spare_06_din = spare_05_q;
assign spare_07_din = spare_06_q;
assign spare_08_din = spare_07_q;
assign spare_09_din = spare_08_q;
assign spare_0A_din = spare_09_q;
assign spare_0B_din = spare_0A_q;
assign spare_0C_din = spare_0B_q;
assign spare_0D_din = spare_0C_q;
assign spare_0E_din = spare_0D_q;
assign spare_0F_din = spare_0E_q;
assign spare_10_din = spare_0F_q;
assign spare_11_din = spare_10_q;
assign spare_12_din = spare_11_q;
assign spare_13_din = spare_12_q;
assign spare_14_din = spare_13_q;
assign spare_15_din = spare_14_q;
assign spare_16_din = spare_15_q;
assign spare_17_din = spare_16_q;
assign spare_18_din = spare_17_q;
assign spare_19_din = spare_18_q;
assign spare_1A_din = spare_19_q;
assign spare_1B_din = spare_1A_q;
assign spare_1C_din = spare_1B_q;
assign spare_1D_din = spare_1C_q;
assign spare_1E_din = spare_1D_q;
assign spare_1F_din = spare_1E_q;

assign tx_rx_cfg_patA_length[1:0] = cfg_patA_length_q[1:0];
assign tx_rx_cfg_patB_length[1:0] = cfg_patB_length_q[1:0];
assign tx_rx_cfg_patA_hyst[3:0]   = cfg_patA_hyst_q[3:0];
assign tx_rx_cfg_patB_hyst[3:0]   = cfg_patB_hyst_q[3:0];


assign pre_IPL_PRBS_timer_rate[21:0] = ({2'b00, 20'h00100} & {22{cfg_pre_IPL_PRBS_timer_q[2:0] == 3'b000}}) | //--  256 us
                                       ({2'b00, 20'h003E8} & {22{cfg_pre_IPL_PRBS_timer_q[2:0] == 3'b001}}) | //--    1 ms
                                       ({2'b00, 20'h00FA0} & {22{cfg_pre_IPL_PRBS_timer_q[2:0] == 3'b010}}) | //--    4 ms
                                       ({2'b00, 20'h03E80} & {22{cfg_pre_IPL_PRBS_timer_q[2:0] == 3'b011}}) | //--   16 ms
                                       ({2'b00, 20'h0FA00} & {22{cfg_pre_IPL_PRBS_timer_q[2:0] == 3'b100}}) | //--   64 ms
                                       ({2'b00, 20'h3E800} & {22{cfg_pre_IPL_PRBS_timer_q[2:0] == 3'b101}}) | //--  256 ms
                                       ({2'b00, 20'hF4240} & {22{cfg_pre_IPL_PRBS_timer_q[2:0] == 3'b110}}) | //--    1  s
                                       ({2'b11, 20'hD0900} & {22{cfg_pre_IPL_PRBS_timer_q[2:0] == 3'b111}});  //--    4  s

//-- When are PHYs guaranteed to send/receive data??
assign incr_pre_IPL_PRBS_timer         = (cfg_pre_IPL_PRBS_ena_q & (pre_IPL_PRBS_timer_rate[21:0] != pre_IPL_PRBS_timer_q[21:0]) & reg_dl_1us_tick_q) & ~pre_IPL_PRBS_timer_done_q;
assign pre_IPL_PRBS_timer_din[21:0]    = incr_pre_IPL_PRBS_timer ? pre_IPL_PRBS_timer_q[21:0] + {2'b00, 20'h00001} : pre_IPL_PRBS_timer_q[21:0];
assign pre_IPL_PRBS_timer_done_din     = (pre_IPL_PRBS_timer_rate[21:0] == pre_IPL_PRBS_timer_q[21:0]);
assign pre_IPL_PRBS_timer_done_dly_din = pre_IPL_PRBS_timer_done_q;
assign pre_IPL_PRBS_timer_finished     = pre_IPL_PRBS_timer_done_q & ~pre_IPL_PRBS_timer_done_dly_q;
assign start_pre_IPL_PRBS              = cfg_pre_IPL_PRBS_ena_q & ~pre_IPL_PRBS_timer_done_q;

//-- Degraded rx/tx threshold logic
assign rx_degraded_threshold[22:0] = ({3'b001, 20'h86A00} & {23{(cfg_rx_degraded_threshold_q[1:0] == 2'b00)}}) |  //-- 1% 1,600,000 counts
                                     ({3'b011, 20'h0D400} & {23{(cfg_rx_degraded_threshold_q[1:0] == 2'b01)}}) |  //-- 2% 3,200,000 counts
                                     ({3'b100, 20'h93E00} & {23{(cfg_rx_degraded_threshold_q[1:0] == 2'b10)}}) |  //-- 3% 4,800,000 counts
                                     ({3'b110, 20'h1A800} & {23{(cfg_rx_degraded_threshold_q[1:0] == 2'b11)}});   //-- 4% 6,400,000 counts

assign rx_deg_thres_hit_din        = (rx_degraded_threshold[22:0] == rx_deg_thres_cntr_q[22:0]) & ~rx_deg_thres_hit_q;
assign reset_rx_deg_thres_cntr     = reg_dl_100ms_tick_q | rx_deg_thres_hit_q;
assign incr_rx_deg_thres_cntr      = rx_tx_mn_trn_in_replay & ~rx_deg_thres_hit_q & frame_vld_q;
assign rx_deg_thres_cntr_din[22:0] = reset_rx_deg_thres_cntr  ? {3'b000, 20'h00000} :
                                     incr_rx_deg_thres_cntr   ? rx_deg_thres_cntr_q[22:0] + {3'b000, 20'h00001} :
                                                                rx_deg_thres_cntr_q[22:0];

assign tx_degraded_threshold[22:0] = ({3'b001, 20'h86A00} & {23{(cfg_tx_degraded_threshold_q[1:0] == 2'b00)}}) |  //-- 1% 1,600,000 counts
                                     ({3'b011, 20'h0D400} & {23{(cfg_tx_degraded_threshold_q[1:0] == 2'b01)}}) |  //-- 2% 3,200,000 counts
                                     ({3'b100, 20'h93E00} & {23{(cfg_tx_degraded_threshold_q[1:0] == 2'b10)}}) |  //-- 3% 4,800,000 counts
                                     ({3'b110, 20'h1A800} & {23{(cfg_tx_degraded_threshold_q[1:0] == 2'b11)}});   //-- 4% 6,400,000 counts

assign tx_deg_thres_hit_din        = (tx_degraded_threshold[22:0] == tx_deg_thres_cntr_q[22:0]) & ~tx_deg_thres_hit_q;
assign reset_tx_deg_thres_cntr     = reg_dl_100ms_tick_q | tx_deg_thres_hit_q;
assign incr_tx_deg_thres_cntr      = flt_trn_in_replay & ~tx_deg_thres_hit_q & frame_vld_q;
assign tx_deg_thres_cntr_din[22:0] = reset_tx_deg_thres_cntr ? {3'b000, 20'h00000} :
                                     incr_tx_deg_thres_cntr  ? tx_deg_thres_cntr_q[22:0] + {3'b000, 20'h00001} :
                                                               tx_deg_thres_cntr_q[22:0];

//-- Lane Bit Error Injection logic
assign BEI_rate[20:0]              = ({1'b0, 20'h0_0001} & {21{(cfg_BEI_ln_rate_q[2:0] == 3'b000)}}) |  //--   1 us
                                     ({1'b0, 20'h0_0008} & {21{(cfg_BEI_ln_rate_q[2:0] == 3'b001)}}) |  //--   8 us
                                     ({1'b0, 20'h0_0040} & {21{(cfg_BEI_ln_rate_q[2:0] == 3'b010)}}) |  //--  64 us 
                                     ({1'b0, 20'h0_0200} & {21{(cfg_BEI_ln_rate_q[2:0] == 3'b011)}}) |  //-- 512 us
                                     ({1'b0, 20'h0_0FA0} & {21{(cfg_BEI_ln_rate_q[2:0] == 3'b100)}}) |  //--   4 ms
                                     ({1'b0, 20'h0_7D00} & {21{(cfg_BEI_ln_rate_q[2:0] == 3'b101)}}) |  //--  32 ms
                                     ({1'b0, 20'h3_E800} & {21{(cfg_BEI_ln_rate_q[2:0] == 3'b110)}}) |  //-- 256 ms
                                     ({1'b1, 20'hE_8480} & {21{(cfg_BEI_ln_rate_q[2:0] == 3'b111)}});   //--   2 s

assign ena_BEI_tx                  = cfg_BEI_ln_ena_q &  cfg_BEI_ln_dir_q;
assign ena_BEI_rx                  = cfg_BEI_ln_ena_q & ~cfg_BEI_ln_dir_q;
//-- one hot based on current selected lane
assign ena_BEI_tx_ln[7:0]          = {ena_BEI_tx & (cfg_BEI_ln_sel_q[2:0] == 3'b111),
                                      ena_BEI_tx & (cfg_BEI_ln_sel_q[2:0] == 3'b110),
                                      ena_BEI_tx & (cfg_BEI_ln_sel_q[2:0] == 3'b101),
                                      ena_BEI_tx & (cfg_BEI_ln_sel_q[2:0] == 3'b100),
                                      ena_BEI_tx & (cfg_BEI_ln_sel_q[2:0] == 3'b011),
                                      ena_BEI_tx & (cfg_BEI_ln_sel_q[2:0] == 3'b010),
                                      ena_BEI_tx & (cfg_BEI_ln_sel_q[2:0] == 3'b001),
                                      ena_BEI_tx & (cfg_BEI_ln_sel_q[2:0] == 3'b000)};
assign ena_BEI_rx_ln[7:0]          = {ena_BEI_rx & (cfg_BEI_ln_sel_q[2:0] == 3'b111),
                                      ena_BEI_rx & (cfg_BEI_ln_sel_q[2:0] == 3'b110),
                                      ena_BEI_rx & (cfg_BEI_ln_sel_q[2:0] == 3'b101),
                                      ena_BEI_rx & (cfg_BEI_ln_sel_q[2:0] == 3'b100),
                                      ena_BEI_rx & (cfg_BEI_ln_sel_q[2:0] == 3'b011),
                                      ena_BEI_rx & (cfg_BEI_ln_sel_q[2:0] == 3'b010),
                                      ena_BEI_rx & (cfg_BEI_ln_sel_q[2:0] == 3'b001),
                                      ena_BEI_rx & (cfg_BEI_ln_sel_q[2:0] == 3'b000)};

assign trn_ln_tx_BEI_inject[7:0] = ena_BEI_tx_ln[7:0] & {8{BEI_inject_q}}; //-- output to tx_lane
assign tx_rx_rx_BEI_inject[7:0]  = ena_BEI_rx_ln[7:0] & {8{BEI_inject_q}}; //-- output to rx_lane

assign reg_dl_1us_tick_din      = reg_dl_1us_tick;     //-- latch for timing
assign trn_flt_1us_tick         = reg_dl_1us_tick_q;
assign reg_dl_100ms_tick_din    = reg_dl_100ms_tick;   //-- latch for timing

assign BEI_inject_din           = (BEI_timer_q[20:0] == BEI_rate[20:0]) & ~BEI_inject_q;
assign BEI_timer_reset          = BEI_inject_q | ~frame_vld_q;
assign BEI_timer_inc            = cfg_BEI_ln_ena_q & reg_dl_1us_tick_q & frame_vld_q;
assign BEI_timer_din[20:0]      = BEI_timer_reset ? {20'h00000, 1'b0} :
                                  BEI_timer_inc   ? BEI_timer_q[20:0] + {20'h00000, 1'b1} :
                                                    BEI_timer_q[20:0];


//-- EDPL logic, version 8 and 10 cannot train together
assign EDPL_allowed_version8  = (cfg_omi_version_q[5:0] == 6'b001000) & ((rx_tx_version_number[5:0] == 6'b000111) |
                                                                         (rx_tx_version_number[5:0] == 6'b001000) |
                                                                         (rx_tx_version_number[5:0] == 6'b001001) |
                                                                         (rx_tx_version_number[5:0] == 6'b001011));
assign EDPL_allowed_version9  = (cfg_omi_version_q[5:0] == 6'b001001) & ((rx_tx_version_number[5:0] == 6'b000101) |
                                                                         (rx_tx_version_number[5:0] == 6'b000111) |
                                                                         (rx_tx_version_number[5:0] == 6'b001000) |
                                                                         (rx_tx_version_number[5:0] == 6'b001001) |
                                                                         (rx_tx_version_number[5:0] == 6'b001010) |
                                                                         (rx_tx_version_number[5:0] == 6'b001011));
assign EDPL_allowed_version10 = (cfg_omi_version_q[5:0] == 6'b001010) & ((rx_tx_version_number[5:0] == 6'b000101) |
                                                                         (rx_tx_version_number[5:0] == 6'b000111) |
                                                                         (rx_tx_version_number[5:0] == 6'b001001) |
                                                                         (rx_tx_version_number[5:0] == 6'b001010) |
                                                                         (rx_tx_version_number[5:0] == 6'b001011));
assign EDPL_ena_din           = cfg_EDPL_ena_q & (EDPL_allowed_version8 | EDPL_allowed_version9 | EDPL_allowed_version10);

assign tx_rx_EDPL_cfg[4:0]    = {EDPL_reset_cnts_q, cfg_EDPL_err_threshold_q[2:0], EDPL_ena_q};
assign trn_ln_tx_EDPL_ena     = tx_EDPL_ena_q;
//-- Delay enabling TX EDPL so very first sync header is 2'b01 to allow RX side on other link
//-- to determine link is up before messing with the headers.
assign tx_EDPL_ena_din        = ((EDPL_ena_q & frame_vld_q & (cycle_cnt_q[5:0] == 6'b000001)) | tx_EDPL_ena_q) & ~start_retrain;

//-- Upper bit is a disable bit to stop the EDPL timer from incrementing
assign EDPL_time_window_disable = EDPL_time_window[44];
assign EDPL_time_window[44:0] = ({1'b1, 44'hFFF_FFFF_FFFF} & {45{(cfg_EDPL_time_window_q[3:0] == 4'b0000)}}) |  //-- no time window 
                                ({1'b0, 44'h000_0000_0004} & {45{(cfg_EDPL_time_window_q[3:0] == 4'b0001)}}) |  //--   4 us
                                ({1'b0, 44'h000_0000_0020} & {45{(cfg_EDPL_time_window_q[3:0] == 4'b0010)}}) |  //--  32 us
                                ({1'b0, 44'h000_0000_0100} & {45{(cfg_EDPL_time_window_q[3:0] == 4'b0011)}}) |  //-- 256 us
                                ({1'b0, 44'h000_0000_07D0} & {45{(cfg_EDPL_time_window_q[3:0] == 4'b0100)}}) |  //--   2 ms
                                ({1'b0, 44'h000_0000_3E80} & {45{(cfg_EDPL_time_window_q[3:0] == 4'b0101)}}) |  //--  16 ms
                                ({1'b0, 44'h000_0001_F400} & {45{(cfg_EDPL_time_window_q[3:0] == 4'b0110)}}) |  //-- 128 ms
                                ({1'b0, 44'h000_000F_4240} & {45{(cfg_EDPL_time_window_q[3:0] == 4'b0111)}}) |  //--   1  s
                                ({1'b0, 44'h000_007A_1200} & {45{(cfg_EDPL_time_window_q[3:0] == 4'b1000)}}) |  //--   8  s
                                ({1'b0, 44'h000_03D0_9000} & {45{(cfg_EDPL_time_window_q[3:0] == 4'b1001)}}) |  //--  64  s
                                ({1'b0, 44'h000_1E84_8000} & {45{(cfg_EDPL_time_window_q[3:0] == 4'b1010)}}) |  //-- 512  s
                                ({1'b0, 44'h000_EE6B_2800} & {45{(cfg_EDPL_time_window_q[3:0] == 4'b1011)}}) |  //--   4 ks
                                ({1'b0, 44'h007_7359_4000} & {45{(cfg_EDPL_time_window_q[3:0] == 4'b1100)}}) |  //--  32 ks
                                ({1'b0, 44'h03B_9ACA_0000} & {45{(cfg_EDPL_time_window_q[3:0] == 4'b1101)}}) |  //-- 256 ks
                                ({1'b0, 44'h1D1_A94A_2000} & {45{(cfg_EDPL_time_window_q[3:0] == 4'b1110)}}) |  //--   2 Ms
                                ({1'b0, 44'hE8D_4A51_0000} & {45{(cfg_EDPL_time_window_q[3:0] == 4'b1111)}});   //--  16 Ms

//-- Inserted for testability and should also improve timing
assign EDPL_compare_din[5]    = (EDPL_timer_q[43:40] == EDPL_time_window[43:40]) & ~EDPL_reset_cnts_q;
assign EDPL_compare_din[4]    = (EDPL_timer_q[39:32] == EDPL_time_window[39:32]) & ~EDPL_reset_cnts_q;
assign EDPL_compare_din[3]    = (EDPL_timer_q[31:24] == EDPL_time_window[31:24]) & ~EDPL_reset_cnts_q;
assign EDPL_compare_din[2]    = (EDPL_timer_q[23:16] == EDPL_time_window[23:16]) & ~EDPL_reset_cnts_q;
assign EDPL_compare_din[1]    = (EDPL_timer_q[15: 8] == EDPL_time_window[15: 8]) & ~EDPL_reset_cnts_q;
assign EDPL_compare_din[0]    = (EDPL_timer_q[ 7: 0] == EDPL_time_window[ 7: 0]) & ~EDPL_reset_cnts_q;
assign EDPL_window_hit        = (&EDPL_compare_q[5:0]);

assign EDPL_reset_cnts_din    = (EDPL_window_hit) & ~EDPL_reset_cnts_q;
//-- 9/28assign EDPL_reset_cnts_din    = (EDPL_timer_q[43:0] == EDPL_time_window[43:0 ) & ~EDPL_reset_cnts_q;
assign EDPL_timer_reset       =  EDPL_time_window_disable | EDPL_reset_cnts_q | reg_dl_edpl_max_count_reset;
assign EDPL_timer_inc         = ~EDPL_time_window_disable & reg_dl_1us_tick_q;
assign EDPL_timer_din[43:0]   =  EDPL_timer_reset  ? 44'b0 :
                                 EDPL_timer_inc    ? EDPL_timer_q[43:0] + 44'b1 :
                                                     EDPL_timer_q[43:0];

//-- error signal
assign EDPL_thres_reached_din       = (|rx_tx_EDPL_thres_reached[7:0]);
//-- wait until retrain launches to kill the correct lane
assign EDPL_kill_lane_pend_din[7:0] = (EDPL_kill_lane_pend_q[7:0] | rx_tx_EDPL_thres_reached[7:0]);
assign EDPL_bad_lane_din[7:0]       = ({8{start_retrain | start_retrain_dly_q[2]}} & EDPL_kill_lane_pend_q[7:0]) | EDPL_bad_lane_q[7:0];

//--------------------------------------------------------
//--           Information Registers 
//--
//--------------------------------------------------------
//-- 

//-- register are in iool_common_pmac,  need to drive the errors and status

//-- Trigger on ILA trigger (set from config0)
assign trace_trig_din[1:0]                 = {rx_tx_rmt_error[5], rx_tx_rmt_error[1]};
assign dl_reg_trace_trig[1:0]              = trace_trig_q[1:0];

assign act_dbg                             = cfg_omi_enable_q & (cfg_debug_ena_q | ~reset);
assign trn_flt_macro_dbg_sel[3:0]          = cfg_macro_dbg_sel_q[3:0];
assign tx_rx_macro_dbg_sel[3:0]            = cfg_macro_dbg_sel_q[3:0];

//-- : rx_tx_trn_dbg
assign selected_dbg_trn_info[87:0]        = ({88{cfg_macro_dbg_sel_q[3:0] == 4'h0}} & dbg_trn_info0[87:0]) |
                                            ({88{cfg_macro_dbg_sel_q[3:0] == 4'h1}} & dbg_trn_info1[87:0]) |
                                            ({88{cfg_macro_dbg_sel_q[3:0] == 4'h2}} & dbg_trn_info2[87:0]) |
                                            ({88{cfg_macro_dbg_sel_q[3:0] == 4'h3}} & dbg_trn_info3[87:0]) |
                                            ({88{cfg_macro_dbg_sel_q[3:0] == 4'h4}} & dbg_trn_info4[87:0]) |
                                            ({88{cfg_macro_dbg_sel_q[3:0] == 4'h5}} & dbg_trn_info5[87:0]) |
                                            ({88{cfg_macro_dbg_sel_q[3:0] == 4'h6}} & dbg_trn_info6[87:0]) |
                                            ({88{cfg_macro_dbg_sel_q[3:0] == 4'h7}} & dbg_trn_info7[87:0]) |
                                            ({88{cfg_macro_dbg_sel_q[3:0] == 4'h8}} & dbg_trn_info8[87:0]) |
                                            ({88{cfg_macro_dbg_sel_q[3:0] == 4'h9}} & dbg_trn_info9[87:0]) |
                                            ({88{cfg_macro_dbg_sel_q[3:0] == 4'hA}} & dbg_trn_infoA[87:0]) |
                                            ({88{cfg_macro_dbg_sel_q[3:0] == 4'hB}} & dbg_trn_infoB[87:0]) |
                                            ({88{cfg_macro_dbg_sel_q[3:0] == 4'hC}} & dbg_trn_infoC[87:0]) |
                                            ({88{cfg_macro_dbg_sel_q[3:0] == 4'hD}} & dbg_trn_infoD[87:0]) |
                                            ({88{cfg_macro_dbg_sel_q[3:0] == 4'hE}} & dbg_trn_infoE[87:0]) |
                                            ({88{cfg_macro_dbg_sel_q[3:0] == 4'hF}} & dbg_trn_infoF[87:0]);


assign dbg_trn_info0[87:0]                 = {16'h0000,                   //--87:72 Extra
                                              remote_deskew_cfg_vld,      //--71
                                              remote_deskew_cfg[18:0],    //--70:52
                                              remote_ts_valid,            //--51
                                              remote_ts_good_lanes[15:0], //--50:35
                                              phy_limit_hit,              //--34
                                              current_state_q[1:0],       //--33:32
                                              ln_ctl_sync_hdr_q[7:0],     //--31:24
                                              ln_data_sync_hdr_q[7:0],    //--23:16
                                              start_retrain,              //--15
                                              adv_1to2,                   //--14
                                              adv_2to3,                   //--13
                                              adv_3to4,                   //--12
                                              adv_4to5,                   //--11
                                              adv_5to6,                   //--10
                                              adv_6to7,                   //--9
                                              cycle_cnt_q[5:0],           //--8:3
                                              tsm_q[2:0]};                //--2:0

//-- Power Management Debug
assign dbg_trn_info1[87:0]                 = {send_PM_msg,                 //--87
                                              flt_trn_pm_msg_sent,         //--86
                                              cycle_cnt_q[5:0],            //--85:80
                                              1'b0,                        //--79
                                              lane_width_status_q[1:0],    //--78:77
                                              PM_tx_lane_timer_q[4:0],     //--76:72
                                              PM_tx_lanes_disable_q[7:0],  //--71:64
                                              PM_rx_lanes_disable[7:0],    //--63:56
                                              rx_psave_req_q[7:0],         //--55:48
                                              rx_psave_sts_q[7:0],         //--47:40
                                              tx_psave_req_q[7:0],         //--39:32
                                              tx_psave_sts_q[7:0],         //--31:24
                                              tx_psave_timer_q[7:0],       //--23:16
                                              1'b0,                        //--15
                                              lane_width_req_pend_q[1:0],  //--14:13
                                              rem_PM_status_updated,       //--12
                                              rem_PM_status[3:0],          //--11:8
                                              PM_state_q[3:0],             //--7:4 
                                              PM_msg[3:0]};                //--3:0

//-- Recal Debug
assign dbg_trn_info2[87:0]                 = {1'b0,                        //--87
                                              tsm_q[2:0],                  //--86:84
                                              1'b0,                        //--83
                                              recal_start,                 //--82
                                              rem_recal_done_q,            //--81
                                              recal_tx_send_TS1s,          //--80
                                              recal_rx_lane_enable_q[7:0], //--79:72
                                              recal_tx_lane_enable_q[7:0], //--71:64
                                              recal_rx_lane_number_q[3:0], //--63:60
                                              recal_tx_lane_number_q[3:0], //--59:56
                                              rx_psave_req_q[7:0],         //--55:48
                                              rx_psave_sts_q[7:0],         //--47:40
                                              tx_psave_req_q[7:0],         //--39:32
                                              tx_psave_sts_q[7:0],         //--31:24
                                              recal_rx_req_q[7:0],         //--23:16
                                              recal_rx_done_q[7:0],        //--15:8
                                              lane_width_status_q[1:0],    //--7:6
                                              lane_width_req_pend_q[1:0],  //--5:4
                                              rem_recal_status[1:0],       //--3:2
                                              recal_state_q[1:0]};         //--1:0   


assign dbg_trn_info3[87:0]                 = 88'h0;
assign dbg_trn_info4[87:0]                 = 88'h0;
assign dbg_trn_info5[87:0]                 = 88'h0;
assign dbg_trn_info6[87:0]                 = 88'h0;
assign dbg_trn_info7[87:0]                 = 88'h0;
assign dbg_trn_info8[87:0]                 = 88'h0;
assign dbg_trn_info9[87:0]                 = 88'h0;
assign dbg_trn_infoA[87:0]                 = 88'h0;
assign dbg_trn_infoB[87:0]                 = 88'h0;
assign dbg_trn_infoC[87:0]                 = rx_tx_trn_dbg[87:0]; //-- TS Check
assign dbg_trn_infoD[87:0]                 = rx_tx_trn_dbg[87:0]; //-- DM Check
assign dbg_trn_infoE[87:0]                 = rx_tx_trn_dbg[87:0]; //-- Inner lane debug info
assign dbg_trn_infoF[87:0]                 = rx_tx_trn_dbg[87:0]; //-- Outer lane debug info

assign dbg_default_trace[87:0]             = {61'b0,                       //--87:27 reserved
                                              cfg_tl_credits_q[5:0],       //--26:21 tx --> frame buffer credit depth(5:0)
                                              flt_trn_dbg_tx_info[36:35],  //--20:19 tx --> flit type(1:0)
                                              flt_trn_dbg_tx_info[34:31],  //--18:15 tx --> run_length field(3:0)
                                              flt_trn_dbg_tx_info[84],     //--14    tx --> short flit next
                                              flt_trn_dbg_tx_info[87],     //--13    tx --> stall_d3_q
                                              3'b000,                      //--12:10 tx --> fastpath state -->   needs to implement
                                              rx_tx_dbg_rx_info[84:81],    //--9:6   rx --> run_length field(3:0)
                                              rx_tx_dbg_rx_info[79],       //--5     rx --> short flit next
                                              rx_tx_ctl_flt,               //--4     rx --> is_control_flit
                                              rx_tx_idle_flt,              //--3     rx --> is_idle_flit
                                              rx_tx_rpl_flt,               //--2     rx --> is_replay_flit
                                              rx_tx_data_flt,              //--1     rx --> is_data_flit
                                              rx_tx_dbg_rx_info[61]};      //--0     rx --> replay_duplicates_q



assign debug_dbg_din[87:0]                 = (88'h0                                & {88{cfg_debug_sel_q[2:0] == 3'b000}}) |
                                             (            rx_tx_dbg_rx_info[87:0]  & {88{cfg_debug_sel_q[2:0] == 3'b001}}) |
                                             (          flt_trn_dbg_tx_info[87:0]  & {88{cfg_debug_sel_q[2:0] == 3'b010}}) |
                                             (        selected_dbg_trn_info[87:0]  & {88{cfg_debug_sel_q[2:0] == 3'b011}}) |
                                             ({77'h0,     rx_tx_dbg_rx_info[10:0]} & {88{cfg_debug_sel_q[2:0] == 3'b100}}) |
                                             ({77'h0,   flt_trn_dbg_tx_info[10:0]} & {88{cfg_debug_sel_q[2:0] == 3'b101}}) |
                                             ({77'h0, selected_dbg_trn_info[10:0]} & {88{cfg_debug_sel_q[2:0] == 3'b110}}) |
                                             (            dbg_default_trace[87:0]  & {88{cfg_debug_sel_q[2:0] == 3'b111}});
assign debug_dbg_stg0_din[87:0]            = debug_dbg_q[87:0];
assign dl_reg_trace_data[87:0]             = debug_dbg_stg0_q[87:0];

assign perf_mon_din[11:0]                  = {flt_trn_fp_start,     //--11 TX Fast Path Start
                                              flt_trn_rpl_data_flt, //--10 TX from replay buffer
                                              flt_trn_data_flt,     //-- 9 TX data flit
                                              flt_trn_ctl_flt,      //-- 8 TX control flit
                                              flt_trn_rpl_flt,      //-- 7 TX replay flit
                                              flt_trn_idle_flt,     //-- 6 TX idle flit
                                              rx_tx_nack,           //-- 5 RX nack received
                                              crc_error,            //-- 4 RX crc error detected
                                              rx_tx_data_flt,       //-- 3 RX data flit
                                              rx_tx_ctl_flt,        //-- 2 RX control flit
                                              rx_tx_rpl_flt,        //-- 1 RX replay flit
                                              rx_tx_idle_flt};      //-- 0 RX idle flit

assign dl_reg_perf_mon[11:0]               = perf_mon_q[11:0];

assign iobist_prbs_error_din[7:0]          = rx_tx_iobist_prbs_error[7:0];
assign dl_phy_iobist_prbs_error[7:0]       = iobist_prbs_error_q[7:0];
//-- scom addresses of x12, x22, x32 Error Mask register
//-- handled in dlc_cmn__pmac.vhdl

assign flt_trn_ce_rpb_din       = flt_trn_ce_rpb;
assign flt_trn_ce_frb_din       = flt_trn_ce_frb;
assign flt_trn_ue_rpb_df_din    = flt_trn_ue_rpb_df;
assign flt_trn_ue_frb_df_din    = flt_trn_ue_frb_df;
assign flt_trn_data_pty_err_din = flt_trn_data_pty_err;
assign flt_trn_tl_trunc_din     = flt_trn_tl_trunc;
assign flt_trn_tl_rl_err_din    = flt_trn_tl_rl_err;
assign flt_trn_ack_ptr_err_din  = flt_trn_ack_ptr_err;
assign flt_trn_ue_rpb_cf_din    = flt_trn_ue_rpb_cf;
assign flt_trn_ue_frb_cf_din    = flt_trn_ue_frb_cf;

//-- Don't report a crc error if it was caused due to a PM retrain condition
assign crc_error                = rx_tx_crc_error & ~PM_caused_retrain_q;

//-- Chicken switch to control if flit can cause a retrain to happen.   is defined as a disable bit, so function is enabled by default
assign start_retrain_flt        = (~reg_dl_cya_bits[8] & flt_trn_retrain_rply) | (~reg_dl_cya_bits[9] & flt_trn_retrain_no_rply) | flt_trn_retrain_hammer;
//--11/13  assign start_retrain_flt        = (~reg_dl__bits[8] & flt_trn_retrain_rply) | (~reg_dl__bits[9] & flt_trn_retrain_no_rply) | flt_trn_retrain_hammer;

//-- scom addresses of x13, x23, x33 Error Hold register
//-- Cerr hold registers, see implement workbook for individual descriptions
assign errors_unused_din[3:0]              = 4'b0000;
assign dl_errors_din[47:0]                 = {rx_tx_rmt_error[7:4],             //--47:44 DLx_msg_errors
                                              rx_tx_rmt_error[3:0],             //--43:40 TLx_msg_errors
                                              train_done_q,                     //--39    train done
                                              tx_deg_thres_hit_q,               //--38    tx degraded threshold
                                              rx_deg_thres_hit_q,               //--37    rx degraded threshold
                                              EDPL_thres_reached_q,             //--36    EDPL threshold reached
                                              unexpected_lost_data_sync,        //--35    lost data sync header
                                              rx_tx_deskew_overflow,            //--34    deskew overflow
                                              lost_block_lock_q,                //--33    lost block lock
                                              software_retrain_q,               //--32    software retrain
                                              unexpected_remote_retrain,        //--31    remote retrain
                                              fwd_prog_fired_q,                 //--30    no forward progress
                                              start_retrain_flt,                //--29    Flit wants a retrain to happen
                                              errors_unused_q[2],               //--28    EDPL lane 8  in 
                                              rx_tx_EDPL_errors[7],             //--27    EDPL lane 7
                                              rx_tx_EDPL_errors[6],             //--26    EDPL lane 6
                                              rx_tx_EDPL_errors[5],             //--25    EDPL lane 5
                                              rx_tx_EDPL_errors[4],             //--24    EDPL lane 4
                                              rx_tx_EDPL_errors[3],             //--23    EDPL lane 3
                                              rx_tx_EDPL_errors[2],             //--22    EDPL lane 2
                                              rx_tx_EDPL_errors[1],             //--21    EDPL lane 1
                                              rx_tx_EDPL_errors[0],             //--20    EDPL lane 0
                                              half_width_rx_mode_q[1],          //--19    Running in half width mode RX
                                              half_width_tx_mode_q[1],          //--18    Running in half width mode TX
                                              rx_tx_nack,                       //--17    RX Nack
                                              crc_error,                        //--16    RX CRC error
                                              flt_trn_ce_rpb_q,                 //--15    CE RPB
                                              flt_trn_ce_frb_q,                 //--14    CE FRB
                                              flt_trn_ue_rpb_df_q,              //--13    UE RPB DF
                                              flt_trn_ue_frb_df_q,              //--12    UE FRB DF
                                              errors_unused_q[1],               //--11    spare
                                              flt_trn_reset_hammer,             //--10    Flit - multiple error case, cause reset to stop Data Integrity error. STOP....It's hammer time!
                                              tx_lane_swap_err_q,               //-- 9    TX lane reversal requested illegally
                                              rx_tx_slow_clock,                 //-- 8    RX slow clock
                                              rx_tx_ill_rl,                     //-- 7    rx illegal run length
                                              ctl_parity_error_q,               //-- 6    ctl parity error
                                              flt_trn_data_pty_err_q,           //-- 5    data parity error
                                              flt_trn_tl_trunc_q,               //-- 4    tl flit truncated
                                              flt_trn_tl_rl_err_q,              //-- 3    tl run length error
                                              flt_trn_ack_ptr_err_q,            //-- 2    Ack pointer error (remote device sent too many acknowledges)
                                              flt_trn_ue_rpb_cf_q,              //-- 1    UE RPB CF
                                              flt_trn_ue_frb_cf_q} &            //-- 0    UE FRB CF
                                              {48{~link_down_q}};               //-- Don't report new errors if link is down
assign dl_errors[47:0]                     = dl_errors_q[47:0];
assign dl_reg_errors[47:0]                 = dl_errors[47:0];
assign fatal_errors                        = (|dl_errors[11:0]) | reg_dl_link_down;

//-- scom addresses of x14, x24, x34 Error Capture registers
assign fir_fired             = (fir_0_fired  | fir_1_fired  | fir_2_fired  | fir_3_fired  | fir_4_fired  | fir_5_fired  | fir_6_fired  | fir_7_fired  | fir_8_fired  | fir_9_fired | 
                                fir_10_fired | fir_11_fired | fir_12_fired | fir_13_fired | fir_14_fired | fir_15_fired | fir_16_fired | fir_17_fired | fir_18_fired);
assign err_locked_din        =  ~reg_dl_err_cap_reset & (err_locked_q | (~err_locked_q & fir_fired));
assign captured_info0[62:0]  = {err_locked_q, first_error_q[5:0], 56'b0}; //-- 
assign captured_info1[62:0]  = {err_locked_q, first_error_q[5:0], 56'b0}; //-- 
assign captured_info2[62:0]  = {err_locked_q, first_error_q[5:0], 56'b0}; //-- 
assign captured_info3[62:0]  = {err_locked_q, first_error_q[5:0], 56'b0}; //-- 


assign first_error_din[5:0]               = err_locked_q ? first_error_q[5:0] : 
                                            fir_0_fired  ? fir_0_err[5:0]  :
                                            fir_1_fired  ? fir_1_err[5:0]  :
                                            fir_2_fired  ? fir_2_err[5:0]  :
                                            fir_3_fired  ? fir_3_err[5:0]  :
                                            fir_4_fired  ? fir_4_err[5:0]  :
                                            fir_5_fired  ? fir_5_err[5:0]  :
                                            fir_6_fired  ? fir_6_err[5:0]  :
                                            fir_7_fired  ? fir_7_err[5:0]  :
                                            fir_8_fired  ? fir_8_err[5:0]  :
                                            fir_9_fired  ? fir_9_err[5:0]  :
                                            fir_10_fired ? fir_10_err[5:0] :
                                            fir_11_fired ? fir_11_err[5:0] :
                                            fir_12_fired ? fir_12_err[5:0] :
                                            fir_13_fired ? fir_13_err[5:0] :
                                            fir_14_fired ? fir_14_err[5:0] :
                                            fir_15_fired ? fir_15_err[5:0] :
                                            fir_16_fired ? fir_16_err[5:0] :
                                            fir_17_fired ? fir_17_err[5:0] :
                                            fir_18_fired ? fir_18_err[5:0] :
                                            fir_19_fired ? fir_19_err[5:0] :
                                                           6'b000000;
assign fir_0_fired                        = rx_tx_slow_clock | rx_tx_ill_rl | ctl_parity_error_q | flt_trn_data_pty_err_q | flt_trn_tl_trunc_q | flt_trn_tl_rl_err_q |
                                            flt_trn_ack_ptr_err_q | flt_trn_ue_rpb_cf_q | flt_trn_ue_frb_cf_q;
assign fir_0_err[5:0]                     = flt_trn_ue_frb_cf_q    ? 6'd0 :
                                            flt_trn_ue_rpb_cf_q    ? 6'd1 :
                                            flt_trn_ack_ptr_err_q  ? 6'd2 :
                                            flt_trn_tl_rl_err_q    ? 6'd3 :
                                            flt_trn_tl_trunc_q     ? 6'd4 :
                                            flt_trn_data_pty_err_q ? 6'd5 :
                                            ctl_parity_error_q     ? 6'd6 :
                                            rx_tx_ill_rl           ? 6'd7 :
                                                                     6'd8 ; //-- slow clock
assign fir_1_fired                         = flt_trn_ue_rpb_df_q | flt_trn_ue_frb_df_q;
assign fir_1_err[5:0]                      = flt_trn_ue_frb_df_q ? 6'd12 :
                                                                   6'd13; //-- flt_trn_ue_rpb_df
assign fir_2_fired                         = flt_trn_ce_frb_q | flt_trn_ce_rpb_q;
assign fir_2_err[5:0]                      = flt_trn_ce_frb_q ? 6'd14 :
                                                                6'd15; //-- flt_trn_ce_rpb
assign fir_3_fired                         = crc_error;
assign fir_3_err[5:0]                      = 6'd16;
assign fir_4_fired                         = rx_tx_nack;
assign fir_4_err[5:0]                      = 6'd17;
assign fir_5_fired                         = x4_tx_mode | x4_rx_mode;
assign fir_5_err[5:0]                      = x4_tx_mode ? 6'd18 :
                                                          6'd19; //-- x4_rx_mode
assign fir_6_fired                         = (|rx_tx_EDPL_errors[7:0]);
assign fir_6_err[5:0]                      = rx_tx_EDPL_errors[0] ? 6'd20 :
                                             rx_tx_EDPL_errors[1] ? 6'd21 :
                                             rx_tx_EDPL_errors[2] ? 6'd22 :
                                             rx_tx_EDPL_errors[3] ? 6'd23 :
                                             rx_tx_EDPL_errors[4] ? 6'd24 :
                                             rx_tx_EDPL_errors[5] ? 6'd25 :
                                             rx_tx_EDPL_errors[6] ? 6'd26 :
                                                                    6'd27; //-- rx_tx_EDPL_errors[7]
assign fir_7_fired                         = fwd_prog_fired_q; 
assign fir_7_err[5:0]                      = 6'd30;
//--assign fir_8_fired                         = remote_retrain_q;
assign fir_8_fired                         = unexpected_remote_retrain;
assign fir_8_err[5:0]                      = 6'd31;
assign fir_9_fired                         = software_retrain_q | lost_block_lock_q | rx_tx_deskew_overflow | unexpected_lost_data_sync;
assign fir_9_err[5:0]                      = software_retrain_q    ? 6'd32 :
                                             lost_block_lock_q     ? 6'd33 :
                                             rx_tx_deskew_overflow ? 6'd34 :
                                                                     6'd35; //-- lost_data_sync_q
assign fir_10_fired                        = EDPL_thres_reached_q | rx_deg_thres_hit_q | tx_deg_thres_hit_q;
assign fir_10_err[5:0]                     = EDPL_thres_reached_q ? 6'd36 :
                                             rx_deg_thres_hit_q   ? 6'd37 :
                                                                    6'd38; //-- tx_deg_thres_hit_q
assign fir_11_fired                        = train_done_q;
assign fir_11_err[5:0]                     = 6'd39;

//-- DLx/TLx initiated message and errors (defined at a later time)
assign fir_12_fired                        = rx_tx_rmt_error[0];
assign fir_12_err[5:0]                     = 6'd40;
assign fir_13_fired                        = rx_tx_rmt_error[1];
assign fir_13_err[5:0]                     = 6'd41;
assign fir_14_fired                        = rx_tx_rmt_error[2];
assign fir_14_err[5:0]                     = 6'd42;
assign fir_15_fired                        = rx_tx_rmt_error[3];
assign fir_15_err[5:0]                     = 6'd43;
assign fir_16_fired                        = rx_tx_rmt_error[4];
assign fir_16_err[5:0]                     = 6'd44;
assign fir_17_fired                        = rx_tx_rmt_error[5];
assign fir_17_err[5:0]                     = 6'd45;
assign fir_18_fired                        = rx_tx_rmt_error[6];
assign fir_18_err[5:0]                     = 6'd46;
assign fir_19_fired                        = rx_tx_rmt_error[7];
assign fir_19_err[5:0]                     = 6'd47;

assign error_capture_din[62:0]             = (captured_info0[62:0] & {63{(first_error_q[5:0] >= 6'd0 ) && (first_error_q[5:0] <  6'd18)}}) |
                                             (captured_info1[62:0] & {63{(first_error_q[5:0] >= 6'd18) && (first_error_q[5:0] <  6'd29)}}) |
                                             (captured_info2[62:0] & {63{(first_error_q[5:0] >= 6'd30) && (first_error_q[5:0] <  6'd39)}}) |
                                             (captured_info3[62:0] & {63{(first_error_q[5:0] >= 6'd40) && (first_error_q[5:0] <= 6'd47)}});

assign dl_reg_error_capture[62:0]          = error_capture_q[62:0];

//-- scom addresses of x15, x25, x35 EDPL Max Count register
assign EDPL_max_cnts[63:0]                 = {rx_tx_EDPL_max_cnts[63:56],  //-- lane 7
                                              rx_tx_EDPL_max_cnts[55:48],  //-- lane 6
                                              rx_tx_EDPL_max_cnts[47:40],  //-- lane 5
                                              rx_tx_EDPL_max_cnts[39:32],  //-- lane 4
                                              rx_tx_EDPL_max_cnts[31:24],  //-- lane 3
                                              rx_tx_EDPL_max_cnts[23:16],  //-- lane 2
                                              rx_tx_EDPL_max_cnts[15: 8],  //-- lane 1
                                              rx_tx_EDPL_max_cnts[ 7: 0]}; //-- lane 0

assign dl_reg_edpl_max_count[63:0]         = EDPL_max_cnts[63:0];


//-- scom addresses of x16, x26, x36
assign status_unused_din[10:0]             = {8'h00, 3'b000};
assign dl_status[63:0]                     = {rx_tx_trained_mode[3:0],         //--63:60  trained mode (only x8/x4 supported)
                                              rx_lane_reverse,                 //--59     rx lanes have been reversed
                                              tx_lane_swap_q[1],               //--58     tx lanes have been reversed
                                              enable_short_idle_q,             //--57     idle flit negotiated size
                                              all_tx_credits_returned,         //--56     replay pointers match indicates that all transmitted flits have been acknowledged
                                              status_unused_q[10:7],           //--55:52  reserved
                                              requested_lane_width_q[1:0],     //--51:50  Requested lane width
                                              lane_width_status_q[1:0],        //--49:48  Actual    lane width
                                              tx_trained_lanes[7:0],           //--47:40  indicates which tx lanes were trainable
                                              rx_trained_lanes[7:0],           //--39:32  indicates which rx lanes were trainable
                                              rx_tx_rem_supported_widths[3:0], //--31:28  endpoint supported modes            endpoint config that was passed across the link
                                              status_unused_q[6:5],            //--27:26  reserved
                                              rx_tx_version_number[5:0],       //--25:20  endpoint version number             endpoint config that was passed across the link
                                              rx_tx_tx_ordering,               //--19     endpoint tx ordering                endpoint config that was passed across the link
                                              tx_lane_swap_q[0],               //--18     endpoint lane swap requested        endpoint config that was passed across the link 
                                              rem_PM_enable,                   //--17     endpoint power management supported endpoint config that was passed across the link
                                              status_unused_q[4:3],            //--16:15  reserved
                                              tsm_q[2:0],                      //--14:12  current training state
                                              status_unused_q[2:0],            //--11: 9
                                              deskew_done,                     //-- 8     received 8 consecutive matching deskew patterns
                                              sts_disabled_rx_lanes_q[7:0]};   //-- 7: 0  lanes that have been disabled, either due to not being trained or a different lane in its
                                                                               //--       even/odd group that didn't train
assign dl_reg_status[63:0]                 = dl_status[63:0];


//-- scom addresses of x17, x27, x37
assign dl_training_status[63:0]            = {ln_pattern_a_q[7:0],     //--63:56 (1 bit per lane for all status signals)
                                              ln_pattern_b_q[7:0],     //--55:48
                                              ln_sync_q[7:0],          //--47:40
                                              phy_dl_init_done_q[7:0], //--39:32
                                              ln_block_lock_q[7:0],    //--31:24
                                              ln_TS1_q[7:0],           //--23:16
                                              ln_TS2_q[7:0],           //--15: 8
                                              ln_TS3_q[7:0]};          //-- 7: 0
assign dl_reg_training_status[63:0]        = dl_training_status[63:0];


//-- scom addresses of x18, x28, x38 Endpoint Configuration Register 
//-- sent directly to dlc_omi_tx_flit.v, NOT handled here

//-- scom addresses of x19, x29, x39 Endpoint Information Register
assign dl_reg_rmt_message[63:0]            = {rx_tx_rmt_message[63:32],  //--63:32 DLx information that was received in a replay flit
                                              rx_tx_rmt_message[31: 0]}; //--31: 0 TLx information that was received in a replay flit


//--------------------------------------------------------
//--           TX training state machine 
//--
//--------------------------------------------------------
//-- 
//-- state 000  == send zero
//-- state 001  == send pattern A
//-- state 010  == send pattern B (64/66 vs 128/130 based on config bit)
//-- state 011  == send sync
//-- state 100  == send ts1 
//-- state 101  == send ts2
//-- state 110  == send ts3
//-- state 111  == send flit 

//-- sim_only_fast_train speeds up the entire link training process as a whole.  It skips states 1-3 and speeds up certain aspects of state 4
//-- such as block lock and lane-to-lane deskew
assign tx_rx_sim_only_fast_train  = sim_only_fast_train;
assign sim_only_fast_train_pulse  = sim_only_fast_train_q[2] & ~sim_only_fast_train_q[1]; //-- Rising edge detect for sim_only_fast_train 

//-- When automatic training isn't enabled, only allow state machine to advance when cycle count reaches max value to keep things in sync,
//-- When switching to state 7 in manual train mode, make sure train done is set, so replay flits are transmitted.
assign manual_adv                 = (~cfg_omi_train_mode_q[3] & (cfg_omi_train_mode_q[2:0] != 3'b111) & (cycle_cnt_q[5:0] == 6'b100000)               ) |
                                    (~cfg_omi_train_mode_q[3] & (cfg_omi_train_mode_q[2:0] == 3'b111) & (cycle_cnt_q[5:0] == 6'b100000) & manual_adv_train_done);
assign manual_adv_train_done      = (train_done_q     & (cfg_x8         ) &  x8_tx_mode) | //-- when training all 8 lanes,  train done happens @ cycle_cnt 6'h20
                                    (train_done_dly_q & (cfg_x8 | cfg_x4) & ~x8_tx_mode);  //-- all other cases, train done happens @ cycle_cnt 6'h1F

//-- Current TX Training State
//--  set tsm_q to 0 after a fatal link error. eg: error bits 0-11
assign tsm_din[2:0]               = (                  link_down_q  ) ? 3'b000                    :
                                    (                  manual_adv   ) ? cfg_omi_train_mode_q[2:0] :
                                    (training_update & training     ) ? training_state[2:0]       :
                                                                        tsm_q[2:0];
assign tx_rx_tsm[2:0]             = tsm_q[2:0];

//-- Reasons to advance the current state to next state
assign adv_1to2 = (rx_pattern_a_done | rx_pattern_b_done) & (cycle_cnt_q[5:0] == 6'b100000);
assign adv_2to3 = (rx_pattern_b_done | sync_hdrs)         & (cycle_cnt_q[5:0] == 6'b100000);
assign adv_3to4 = tx_sent_sync_done;
//--assign adv_4to5 = block_locked_q & phy_init_done & deskew_done & (rx_ts1_done | rx_ts2_done) & (cycle_cnt_q[5:0] == 6'b100000) & ~start_retrain;
assign adv_4to5 = block_locked_q & phy_init_done & deskew_done & psaves_done & (rx_ts1_done | rx_ts2_done) & (cycle_cnt_q[5:0] == 6'b100000) & ~start_retrain;
assign adv_5to6 = ( rx_ts2_done | rx_ts3_done ) & (cycle_cnt_q[5:0] == 6'b100000) & ~start_retrain;
assign adv_6to7 = ((x8_tx_mode & train_done_q) | (~x8_tx_mode & train_done_dly_q)) & (cycle_cnt_q[5:0] == 6'b100000) & ~start_retrain;

//-- Signal a change in the training state is required
assign training_update            = (sim_only_fast_train_pulse                          ) |
                                    (tsm_q[2:0] == 3'b000 & ~sim_only_fast_train        ) |
                                    (tsm_q[2:0] == 3'b000 & start_pre_IPL_PRBS          ) |
                                    (tsm_q[2:0] == 3'b100 & pre_IPL_PRBS_timer_finished ) |
                                    (tsm_q[2:0] == 3'b001 & adv_1to2                    ) |
                                    (tsm_q[2:0] == 3'b010 & adv_2to3                    ) |
                                    (tsm_q[2:0] == 3'b011 & adv_3to4                    ) |
                                    (tsm_q[2:0] == 3'b100 & adv_4to5                    ) |
                                    (tsm_q[2:0] == 3'b101 & adv_5to6                    ) |
                                    (tsm_q[2:0] == 3'b110 & adv_6to7                    ) |
                                    (tsm_q[2]   == 1'b1   & start_retrain               );
                                      
//-- The training state to advance to next
assign training_state[2:0]        = (3'b001 & {3{(tsm_q[2:0] == 3'b000 & ~sim_only_fast_train )}}) |
                                    (3'b100 & {3{(sim_only_fast_train_pulse                   )}}) | //-- sim only condition for fast training
                                    (3'b100 & {3{(start_pre_IPL_PRBS                          )}}) |
                                    (3'b001 & {3{(pre_IPL_PRBS_timer_finished                 )}}) |
                                    (3'b010 & {3{(tsm_q[2:0] == 3'b001 & adv_1to2             )}}) |
                                    (3'b011 & {3{(tsm_q[2:0] == 3'b010 & adv_2to3             )}}) |
                                    (3'b100 & {3{(tsm_q[2:0] == 3'b011 & adv_3to4             )}}) |
                                    (3'b101 & {3{(tsm_q[2:0] == 3'b100 & adv_4to5             )}}) |
                                    (3'b110 & {3{(tsm_q[2:0] == 3'b101 & adv_5to6             )}}) |
                                    (3'b111 & {3{(tsm_q[2:0] == 3'b110 & adv_6to7             )}}) |
                                    (3'b100 & {3{(tsm_q[2]   == 1'b1   & start_retrain        )}});


//-- automatic training enabled
assign training                   = cfg_omi_train_mode_q[3] | sim_only_fast_train_pulse;

assign train_state_parity_din     = (link_down_q                   ) ? 1'b0                         :
                                    (                  manual_adv  ) ? ^(cfg_omi_train_mode_q[2:0]) :
                                    (training_update & training    ) ? ^(training_state[2:0])       :
                                                                       train_state_parity_q;
assign ctl_parity_error_din       = ~((^tsm_q[2:0]) == train_state_parity_q);


//--------------------------------------------------------
//--          Decode RX Train State Machine
//--
//--------------------------------------------------------
//--
//--

//-- If we see pattern b's, we unset that we are seeing pattern A's
assign ln_pattern_a_din[7:0]     = (rx_tx_train_status[72:65]  | ln_pattern_a_q[7:0]) & ~ln_pattern_b_q[7:0];
assign ln_pattern_b_din[7:0]     = (rx_tx_train_status[64:57]) | ln_pattern_b_q[7:0];
assign ln_sync_din[7:0]          = (rx_tx_train_status[56:49]) | ln_sync_q[7:0];
assign ln_block_lock_din[7:0]    = (rx_tx_train_status[48:41]);
//--assign ln_block_lock_din[7:0]    = (rx_tx_train_status[48:41]) | ln_block_lock_q[7:0];
assign deskew_done               = (rx_tx_train_status[40   ]);
assign ln_TS1_din[7:0]           = ((rx_tx_train_status[39:32]) | ln_TS1_q[7:0]) & ~{8{start_retrain}};
assign is_TS1[7:0]               =   rx_tx_train_status[39:32]; 
//-- during normal training if other side advances to state 5 first while this side is in state 4, need to see TS2s in order to advance.
//-- if this side was seeing TS2s and is now seeing TS1s, unlatch.
assign ln_TS2_din[7:0]           = ((rx_tx_train_status[31:24]) | ln_TS2_q[7:0]) & ~({8{start_retrain}} | is_TS1[7:0]);
//-- retraining happening during state 6 ignore TS3's when in state 4
assign ln_TS3_din[7:0]           = ((rx_tx_train_status[23:16]) | ln_TS3_q[7:0]) & ~{8{start_retrain | (tsm_q[2:0] == 3'b100)}};
assign ln_data_sync_hdr_din[7:0] = (rx_tx_train_status[15: 8] & {8{tsm_q[2:1] == 2'b11}}) | (ln_data_sync_hdr_q[7:0] & ~{8{start_retrain}});
assign ln_ctl_sync_hdr_din[7:0]  = (rx_tx_train_status[ 7: 0] & {8{tsm_q[2:1] == 2'b11}}) | (ln_ctl_sync_hdr_q[7:0] & ~{8{start_retrain}});


//--------------------------------------------------------
//--        Slow Speed Pattern A,B, Sync Detection
//--       
//--------------------------------------------------------
//--
//-- When any lane is receiving PATTERN A or PATTERN B, 
//-- count up for a programmable number of times in order 
//-- to determine what state the lanes are in once the 
//-- limit is reached
//-- 
//-- PATTERN A = 16'hFF00
//-- PATTERN B = 32'hFFFF0000
//-- Sync      = 32'hFF0000FF

assign rx_pattern_a_din        =  (|ln_pattern_a_q[7:0]                       ) & ~(tsm_q[2:0] == 3'b000);
assign rx_pattern_b_din        =  (|ln_pattern_b_q[7:0]                       ) & ~(tsm_q[2:0] == 3'b000);
assign rx_no_pattern_din       = ~(|{ln_pattern_a_q[7:0], ln_pattern_b_q[7:0]}) & ~(tsm_q[2:0] == 3'b000);  //--no lanes reporting either pattern

//-- report when all enabled lanes have received pattern A/B
assign input_state[1:0]        = {rx_pattern_a_q, rx_pattern_b_q} | {2{rx_no_pattern_q}};  //--A=10, B=01, none=11
assign current_state_din[1:0]  = input_state[1:0];
assign rx_pattern_a_done       = phy_limit_hit & (current_state_q == 2'b10);
assign rx_pattern_b_done       = phy_limit_hit & (current_state_q == 2'b01);

//-- increment counter for consecutive cycles of the received state, clear counter for a different state 
assign phy_count_din[15:0]     = (  ((phy_count_q[15:0] + 16'h0001) &  {16{( reg_dl_1us_tick_q & ~phy_limit_hit)}}  ) |
                                    ( phy_count_q[15:0]             & ~{16{( reg_dl_1us_tick_q & ~phy_limit_hit)}}  ) )
                                 &  {16{((current_state_q == input_state) & ~training_update)}};
                          
//-- if count matches programmable limit, report received state
assign phy_limit_hit              = (phy_count_q[15:0] == phy_limit[15:0]) & (current_state_q == input_state);
assign phy_limit_hit_din          = phy_limit_hit; //-- inserted for testability

//-- count is 1 more than time because first increment is less than 1 us (time to first 1us pulse)
assign phy_limit[15:0] = (16'h0002 & {16{(cfg_omi_phy_cntr_limit_q[3:0] == 4'h0)}}) |  //--1   us
                         (16'h0033 & {16{(cfg_omi_phy_cntr_limit_q[3:0] == 4'h1)}}) |  //--50  us
                         (16'h0065 & {16{(cfg_omi_phy_cntr_limit_q[3:0] == 4'h2)}}) |  //--100 us
                         (16'h00C9 & {16{(cfg_omi_phy_cntr_limit_q[3:0] == 4'h3)}}) |  //--200 us
                         (16'h01F5 & {16{(cfg_omi_phy_cntr_limit_q[3:0] == 4'h4)}}) |  //--500 us
                         (16'h03E9 & {16{(cfg_omi_phy_cntr_limit_q[3:0] == 4'h5)}}) |  //--1   ms
                         (16'h07D1 & {16{(cfg_omi_phy_cntr_limit_q[3:0] == 4'h6)}}) |  //--2   ms
                         (16'h0BB9 & {16{(cfg_omi_phy_cntr_limit_q[3:0] == 4'h7)}}) |  //--3   ms
                         (16'h0FA1 & {16{(cfg_omi_phy_cntr_limit_q[3:0] == 4'h8)}}) |  //--4   ms
                         (16'h1389 & {16{(cfg_omi_phy_cntr_limit_q[3:0] == 4'h9)}}) |  //--5   ms
                         (16'h1771 & {16{(cfg_omi_phy_cntr_limit_q[3:0] == 4'hA)}}) |  //--6   ms
                         (16'h1F41 & {16{(cfg_omi_phy_cntr_limit_q[3:0] == 4'hB)}}) |  //--8   ms
                         (16'h2711 & {16{(cfg_omi_phy_cntr_limit_q[3:0] == 4'hC)}}) |  //--10  ms
                         (16'h3A99 & {16{(cfg_omi_phy_cntr_limit_q[3:0] == 4'hD)}}) |  //--15  ms
                         (16'h7531 & {16{(cfg_omi_phy_cntr_limit_q[3:0] == 4'hE)}}) |  //--30  ms
                         (16'hEA61 & {16{(cfg_omi_phy_cntr_limit_q[3:0] == 4'hF)}});   //--60  ms

//-- Sync detected
assign sync_hdrs               = (|ln_sync_q[7:0]);


//--------------------------------------------------------
//--       Full Speed TS1/TS2/TS3 Deskew Detection
//--       
//--------------------------------------------------------
assign disabled_rx_lanes[7:0]     = rx_tx_disabled_rx_lanes[7:0];
assign disabled_rx_lanes_cnt[3:0] = {3'b000, disabled_rx_lanes[7]} + {3'b000, disabled_rx_lanes[6]} + {3'b000, disabled_rx_lanes[5]} + {3'b000, disabled_rx_lanes[4]} +
                                    {3'b000, disabled_rx_lanes[3]} + {3'b000, disabled_rx_lanes[2]} + {3'b000, disabled_rx_lanes[1]} + {3'b000, disabled_rx_lanes[0]};

assign rx_ts1_din              = (is_TS1[7:0] | disabled_rx_lanes[7:0]) == 8'hFF;

assign rx_ts1_done             = ((disabled_rx_lanes[7:0] | ln_TS1_q[7:0]) == 8'hFF);

//-- Stop TX lanes from transmitting if configured to run as a x4 only at startup.
assign cfg_tx_lanes_disable[7:0] = (cfg_omi_supported_widths_q[3:0] == 4'h1) ? (8'h5A | cfg_tx_lanes_disable_q[7:0]) : cfg_tx_lanes_disable_q[7:0];

//-- If we are configed in x4/, we don't need to turn off the psave for the 4 dead unused lanes.
assign degraded_lanes[7:0]       = {8{cfg_x4}} & 8'h5A;

assign disabled_tx_lanes_din[7:0] = rx_tx_disabled_tx_lanes[7:0] | //-- Lanes disabled from TS2/3 message
                                    cfg_tx_lanes_disable[7:0]    | //-- Lanes disabled from config1[39:32] or supported width set to x4 only
                                    PM_tx_lanes_disable_q[7:0];    //-- Lanes disabled due to Power Management

assign disabled_tx_lanes_cnt[3:0] = {3'b000, disabled_tx_lanes_q[7]} + {3'b000, disabled_tx_lanes_q[6]} + {3'b000, disabled_tx_lanes_q[5]} + {3'b000, disabled_tx_lanes_q[4]} +
                                    {3'b000, disabled_tx_lanes_q[3]} + {3'b000, disabled_tx_lanes_q[2]} + {3'b000, disabled_tx_lanes_q[1]} + {3'b000, disabled_tx_lanes_q[0]};

//-- Don't stop transmitting until PM timer is done when going down in width.  Otherwise, if we are in a PM wake/ready state, make sure scrambled data is being transmitted on the lanes.
assign ln_disable_PM_wake_din[7:0] = PM_state_wake_half2full     | PM_state_ready_half2full   ? disabled_tx_lanes_hold_q[7:0] & ~full_width_enable_lanes[7:0] :
                                     PM_state_ready_quarter2half | PM_state_wake_quarter2half ? disabled_tx_lanes_hold_q[7:0] & ~half_width_enable_lanes[7:0] :
                                                                                                disabled_tx_lanes_hold_q[7:0];
assign trn_ln_disable[7:0]         = ln_disable_PM_wake_q[7:0];

assign PM_caused_retrain          = (PM_start_retrain_sent_q) | //-- Host initiates a retrain
                                    (PM_EP_start_retrain_q);    //-- EP   sees host's retrain
//--  12/4/18            (PM_state_ready_quarter2half & (rem_PM_status[3:0] == 4'b0100) & lane_width_change_ip_q & remote_retrain_q) | //-- EP   sees host's retrain
//--  12/4/18            (PM_state_ready_half2full    & (rem_PM_status[3:0] == 4'b0101) & lane_width_change_ip_q & remote_retrain_q);  //-- EP   sees host's retrain
assign PM_caused_retrain_din      = (PM_caused_retrain | PM_caused_retrain_q) & ~(train_done_q | retrain_due2_trn_timeout | (~PM_caused_retrain & start_retrain));
//--assign PM_caused_retrain_din      = (PM_caused_retrain | PM_caused_retrain_q) & ~(train_done_q | (retrain_due2_trn_timeout));
assign retrain_ip_din             = (end_of_start_retrain | retrain_ip_q) & ~train_done_q;
assign retrain_not_due2_PM        = end_of_start_retrain & ((~PM_caused_retrain_q & PM_enable_q) | retrain_due2_trn_timeout);
assign retrain_not_due2_PM_din    = (retrain_not_due2_PM | retrain_not_due2_PM_q) & ~train_done_q;

//-- If an unexpected retrain happens, and we were requested to be in quarter width.  Start the transition back to half width, so the quarter width request can be processed.
//-- Go back to half width from full width will be done automatically.
assign PM_back_to_quarter_din = ((train_done_q & retrain_not_due2_PM_q & selected_width[2] & (requested_lane_width_q[1:0] == 2'b01))
                                   | PM_back_to_quarter_q) & ~(PM_adv_host_full2half | PM_adv_EP_full2half);

//-- Make sure side gets the latest PM msg after a retrain
assign PM_back_to_quarter_start = PM_back_to_quarter_q & PM_state_running_full  & (rem_PM_status[3:0] == 4'h3);
//-- Initially trained at full width and entered a retrain NOT due to Power Management.  After the retrain, we are not able to train in full width, eg: degraded half mode
//-- Since we retrained into a degraded mode, we block all PM requests from the TL or DL config register
//-- If a multilane CRC error happens during wake up from quarter->half mode, one side can think the retrain is expected while the other isn't.
//-- This CAN cause 1 side to think we are in degraded rx/tx while the other side thinks we retrained succesfully to half width.  This is a fatal error for PM, so we need to disable PM
//-- on the side that is still running.
assign retrained_in_degr_width     = (retrain_ip_q & (retrained_in_degr_cfg_x8 | retrained_in_degr_cfg_x4) & train_done_q & (init_width_q[1:0] == 2'b11)  ) | 
                                     (~PM_state_disabled & rem_PM_status_updated & rem_PM_status[3:0] == 4'h0 & (PM_enable_q | reg_dl_cya_bits[12])       ) |
//-- 11/9/18              (~PM_state_disabled & rem_PM_status_updated & rem_PM_status[3:0] == 4'h0) |
                                     retrained_in_degr_width_q;
assign retrained_in_degr_width_din = retrained_in_degr_width;
//-- Scenarios where we retrain in a degraded width
assign retrained_in_degr_cfg_x8    = cfg_x8 & selected_width[1] & ~PM_state_running_half; //-- trained in half width and PM wasn't expecting to
assign retrained_in_degr_cfg_x4    = cfg_x4 & selected_width[1];

//-- Only report max width lanes.  A power management request can't cause the status register to show lanes were disabled
//-- Signals only go to status register.  Don't update register when link is up or when a PM causes a retrain
assign begin_start_retrain              = start_retrain & ~start_retrain_dly_q[0];
//-- 8/30assign update_valid_lanes_in_status_reg = (~PM_caused_retrain_q & ~frame_vld_q) | ~init_train_done_q | retrained_in_degr_width_q;
assign update_valid_lanes_in_status_reg = (~PM_caused_retrain_q & ~frame_vld_q) | ~init_train_done_q | retrained_in_degr_width;
assign rx_trained_lanes_din[7:0]        = update_valid_lanes_in_status_reg ? (ln_TS1_q[7:0] | ln_TS2_q[7:0]) :
                                                                             rx_trained_lanes_q[7:0];

assign sts_disabled_rx_lanes_din[7:0]   = update_valid_lanes_in_status_reg ? disabled_rx_lanes[7:0] :
                                                                             sts_disabled_rx_lanes_q[7:0];

assign tx_trained_lanes_din[7:0]        = update_valid_lanes_in_status_reg ? ~disabled_tx_lanes_q[7:0] :
                                                                             tx_trained_lanes_q[7:0];


//-- only drive 0's in state 6 or 7 to guard against case where remote side advances to state 5 when it is receiving ts2's.  This doesn't give this side
//-- enough time to correct figure out the TS2/3 good lanes messages
assign tx_trained_lanes[7:0]      = tx_trained_lanes_q[7:0];
assign rx_trained_lanes[7:0]      = rx_trained_lanes_q[7:0];



assign block_locked_din        =  ((disabled_rx_lanes[7:0] | ln_block_lock_q[7:0]) == 8'hFF) & ~(tsm_q[2:0] == 3'b000);
//-- Don't report a lost block lock if a retrain causes a lost block lock.
assign lost_block_lock_din     =  block_locked_q & ~block_locked_din & ~(PM_ignore_lost_block_lock | start_retrain); //-- falling edge of block_locked
//-- 9/18assign lost_block_lock_din     =  block_locked_q & ~block_locked_din & ~PM_ignore_lost_block_lock; //-- falling edge of block_locked
//-- If a dead lane due to PM was reactivated, ignore its lost block lock
assign PM_ignore_lost_block_lock = (PM_caused_retrain_q | retrain_not_due2_PM_q) & (tsm_q[2:0] == 3'b100);

assign rx_ts2_din              = ((disabled_rx_lanes[7:0] | ln_TS2_q[7:0]) == 8'hFF);
assign rx_ts2_done             = rx_ts2_q & ~(tsm_q[2:0] == 3'b000);


//-- If lane detects TS3/Flit, advance to next state
assign rx_ts3_din              = (((disabled_rx_lanes[7:0] | ln_TS3_q[7:0])           == 8'hFF) | rx_ts3_q) & ~(tsm_q[2:0] == 3'b100);
assign rx_data_sync_hdr_din    =  ((disabled_rx_lanes[7:0] | ln_data_sync_hdr_q[7:0]) == 8'hFF);

assign rx_ts3_done             = rx_ts3_q & ~(tsm_q[2:0] == 3'b000);




//--------------------------------------------------------
//--  TS1/TS2 Descramble/Block Lock/Deskew/Enabled RX Lanes
//--          Recenter eye on High Speed Data
//--                tsm_q[2:0] = 3'b100
//--------------------------------------------------------
//--
//-- 1. Signal PHY to retrain eye on higher speed data
//-- 2. Individual lane finds constant 2 bit control sync header
//-- 3. Descramble individual lane to lock onto TS1/TS2 patterns and extract lane info
//-- 4. Lane-to-lane deskew
//--
//-- TS1 PATTERN    = 40'h4B4A4A4A4A4A
//-- DESKEW PATTERN = 32'h4B1E1E1E1E
//-- BLOCK LOCK     = 2 bit header = 2'b10 for X cycles



//-- PHY tells us it has recentered the eye on the full speed data
assign phy_dl_init_done_din[7:0]  = {phy_dl_init_done_7, phy_dl_init_done_6, phy_dl_init_done_5, phy_dl_init_done_4, phy_dl_init_done_3, phy_dl_init_done_2, phy_dl_init_done_1, phy_dl_init_done_0};
assign phy_init_done              = &(phy_dl_init_done_q[7:0] | cfg_rx_lanes_disable_q[7:0]);
assign tx_rx_phy_init_done[7:0]   =  (phy_dl_init_done_q[7:0] | cfg_rx_lanes_disable_q[7:0]);


 
//-- Tell the PHY to recenter the eye on the full speed data once a sync is detected
assign run_lane7_din     = (tsm_q[2:0] == 3'b100) | (cfg_omi_run_lane_override_q & (|tsm_q[2:0])) | run_lane7_q;
assign run_lane6_din     = (tsm_q[2:0] == 3'b100) | (cfg_omi_run_lane_override_q & (|tsm_q[2:0])) | run_lane6_q;
assign run_lane5_din     = (tsm_q[2:0] == 3'b100) | (cfg_omi_run_lane_override_q & (|tsm_q[2:0])) | run_lane5_q;
assign run_lane4_din     = (tsm_q[2:0] == 3'b100) | (cfg_omi_run_lane_override_q & (|tsm_q[2:0])) | run_lane4_q;
assign run_lane3_din     = (tsm_q[2:0] == 3'b100) | (cfg_omi_run_lane_override_q & (|tsm_q[2:0])) | run_lane3_q;
assign run_lane2_din     = (tsm_q[2:0] == 3'b100) | (cfg_omi_run_lane_override_q & (|tsm_q[2:0])) | run_lane2_q;
assign run_lane1_din     = (tsm_q[2:0] == 3'b100) | (cfg_omi_run_lane_override_q & (|tsm_q[2:0])) | run_lane1_q;
assign run_lane0_din     = (tsm_q[2:0] == 3'b100) | (cfg_omi_run_lane_override_q & (|tsm_q[2:0])) | run_lane0_q;

assign run_lanes[7:0]    = {run_lane7_q, run_lane6_q, run_lane5_q, run_lane4_q, run_lane3_q, run_lane2_q, run_lane1_q, run_lane0_q};

assign dl_phy_run_lane_7 = run_lanes[7];
assign dl_phy_run_lane_6 = run_lanes[6];
assign dl_phy_run_lane_5 = run_lanes[5]; 
assign dl_phy_run_lane_4 = run_lanes[4];
assign dl_phy_run_lane_3 = run_lanes[3];
assign dl_phy_run_lane_2 = run_lanes[2];
assign dl_phy_run_lane_1 = run_lanes[1];
assign dl_phy_run_lane_0 = run_lanes[0];






//--------------------------------------------------------
//--       Transmission Pattern A/B and Sync Logic
//--  
//--------------------------------------------------------
//-- Slow speed patterns


//-- latching for timing and to keep trn_ln_train_data pipelined with trn_agn_training_set
//-- This latch NEEDS to drive 0's when tsm_q is 4 or larger because this is how the TX side transmits 0's across the link.
assign train_data_din[15:0]    = (16'hFF00 & {16{cfg_tx_a_pattern   }}) | // PATTERN A and first 2 bytes of Sync PATTERN       
                                 (16'hFFFF & {16{cfg_tx_b_pattern   }}) | // First 2 bytes of B PATTERN                        
                                 (16'h0000 & {16{cfg_tx_zeros       }}) | // Last  2 bytes of B PATTERN                        
                                 (16'h00FF & {16{cfg_tx_sync_pattern}});  // Last  2 bytes of Sync PATTERN (Inverted PATTERN A)
                                
assign trn_ln_train_data[15:0] = train_data_q[15:0];
                                 
                                 
                                 


//-- Need to send pattern A when not sending a pattern B or sync pattern
assign cfg_tx_a_pattern        = (tsm_q[2:0] == 3'b001) |
                                ((tsm_q[2:0] == 3'b010) & ~(cycle_cnt_q[5:0] == 6'b011111) & ~(cycle_cnt_q[5:0] == 6'b100000)) | 
                                ((tsm_q[2:0] == 3'b011) & ~(cycle_cnt_q[5:0] == 6'b100000));

assign cfg_tx_b_pattern        = (tsm_q[2:0] == 3'b010) & (cycle_cnt_q[5:0] == 6'b011111);
assign cfg_tx_zeros            = (tsm_q[2:0] == 3'b010  &  cycle_cnt_q[5:0] == 6'b100000) | link_down_q;
assign cfg_tx_sync_pattern     = (tsm_q[2:0] == 3'b011) & (cycle_cnt_q[5:0] == 6'b100000);


//-- Sends sync pattern at cycle count before the stall
assign tx_sent_sync_done       = (tsm_q[2:0] == 3'b011) & (cycle_cnt_q[5:0] == 6'b100000);



//--------------------------------------------------------
//--         Transmission TS1/TS2/TS3/Deskew Logic
//--  
//--------------------------------------------------------
//-- Full speed patterns
//-- Determines when to send TSX/Deskew Patterns
//-- cycle_cnt_q increments to 6'b100000 to allow dead cycle to insert header bits 
//--
//-- word 0 gets transmitted first, word 3 gets transmitted last
//--
//--          word 0  | word 1  | word 2  | word 3
//-- TS1    =  4A4B   |  4A4A   |  4A4A   |  4A4A
//-- TS2    =  454B   |  4545   |  4545   |  ----
//-- TS3    =  414B   |  4141   |  4141   |  ----
//-- Deskew =  1E4B   |  1E1E   |  --1E   |  ----

assign trn_agn_training_set[127:0] = {training_set_ln7[15:0], training_set_ln6[15:0], training_set_ln5[15:0], training_set_ln4[15:0], training_set_ln3[15:0], training_set_ln2[15:0], training_set_ln1[15:0], training_set_ln0[15:0]};

//-- Sending TS1, TS2, TS3, DESKEW patterns.
assign trn_agn_training  = (((tsm_q[2:0] == 3'b100) | (tsm_q[2:0] == 3'b101) | (tsm_q[2:0] == 3'b110)) & ~(start_retrain | start_retrain_dly_q[0]))
                           | cfg_tx_sync_pattern;   //-- Needs to turn on 1 cycle early because TSX data gets latched before being sent to PHY

assign training_set_ln0[15:0] = (training_set_word_0[15:0]     & {16{cycle_cnt_q[1:0] == 2'b00}}) |
                                (training_set_word_1[15:0]     & {16{cycle_cnt_q[1:0] == 2'b01}}) |
                                (training_set_word_2_ln0[15:0] & {16{cycle_cnt_q[1:0] == 2'b10}}) |
                                (training_set_word_3_ln0[15:0] & {16{cycle_cnt_q[1:0] == 2'b11}});
assign training_set_ln1[15:0] = (training_set_word_0[15:0]     & {16{cycle_cnt_q[1:0] == 2'b00}}) |
                                (training_set_word_1[15:0]     & {16{cycle_cnt_q[1:0] == 2'b01}}) |
                                (training_set_word_2_ln1[15:0] & {16{cycle_cnt_q[1:0] == 2'b10}}) |
                                (training_set_word_3_ln1[15:0] & {16{cycle_cnt_q[1:0] == 2'b11}});
assign training_set_ln2[15:0] = (training_set_word_0[15:0]     & {16{cycle_cnt_q[1:0] == 2'b00}}) |
                                (training_set_word_1[15:0]     & {16{cycle_cnt_q[1:0] == 2'b01}}) |
                                (training_set_word_2_ln2[15:0] & {16{cycle_cnt_q[1:0] == 2'b10}}) |
                                (training_set_word_3_ln2[15:0] & {16{cycle_cnt_q[1:0] == 2'b11}});
assign training_set_ln3[15:0] = (training_set_word_0[15:0]     & {16{cycle_cnt_q[1:0] == 2'b00}}) |
                                (training_set_word_1[15:0]     & {16{cycle_cnt_q[1:0] == 2'b01}}) |
                                (training_set_word_2_ln3[15:0] & {16{cycle_cnt_q[1:0] == 2'b10}}) |
                                (training_set_word_3_ln3[15:0] & {16{cycle_cnt_q[1:0] == 2'b11}});
assign training_set_ln4[15:0] = (training_set_word_0[15:0]     & {16{cycle_cnt_q[1:0] == 2'b00}}) |
                                (training_set_word_1[15:0]     & {16{cycle_cnt_q[1:0] == 2'b01}}) |
                                (training_set_word_2_ln4[15:0] & {16{cycle_cnt_q[1:0] == 2'b10}}) |
                                (training_set_word_3_ln4[15:0] & {16{cycle_cnt_q[1:0] == 2'b11}});
assign training_set_ln5[15:0] = (training_set_word_0[15:0]     & {16{cycle_cnt_q[1:0] == 2'b00}}) |
                                (training_set_word_1[15:0]     & {16{cycle_cnt_q[1:0] == 2'b01}}) |
                                (training_set_word_2_ln5[15:0] & {16{cycle_cnt_q[1:0] == 2'b10}}) |
                                (training_set_word_3_ln5[15:0] & {16{cycle_cnt_q[1:0] == 2'b11}});
assign training_set_ln6[15:0] = (training_set_word_0[15:0]     & {16{cycle_cnt_q[1:0] == 2'b00}}) |
                                (training_set_word_1[15:0]     & {16{cycle_cnt_q[1:0] == 2'b01}}) |
                                (training_set_word_2_ln6[15:0] & {16{cycle_cnt_q[1:0] == 2'b10}}) |
                                (training_set_word_3_ln6[15:0] & {16{cycle_cnt_q[1:0] == 2'b11}});
assign training_set_ln7[15:0] = (training_set_word_0[15:0]     & {16{cycle_cnt_q[1:0] == 2'b00}}) |
                                (training_set_word_1[15:0]     & {16{cycle_cnt_q[1:0] == 2'b01}}) |
                                (training_set_word_2_ln7[15:0] & {16{cycle_cnt_q[1:0] == 2'b10}}) |
                                (training_set_word_3_ln7[15:0] & {16{cycle_cnt_q[1:0] == 2'b11}});



assign training_set_word_0[15:0]      = (16'h1E4B                       & {16{(tsm_q[2  ] == 1'b1                    ) &  insert_deskew}}) | //-- Deskew
                                        (16'h4A4B                       & {16{(tsm_q[2:0] == 3'b100 | PM_tx_send_TS1s) & ~insert_deskew}}) | //-- TS1
                                        (16'h454B                       & {16{(tsm_q[2:0] == 3'b101                  ) & ~insert_deskew}}) | //-- TS2
                                        (16'h414B                       & {16{(tsm_q[2:0] == 3'b110                  ) & ~insert_deskew}});  //-- TS3
assign training_set_word_1[15:0]      = (16'h1E1E                       & {16{(tsm_q[2  ] == 1'b1                    ) &  insert_deskew}}) | //-- Deskew
                                        (16'h4A4A                       & {16{(tsm_q[2:0] == 3'b100 | PM_tx_send_TS1s) & ~insert_deskew}}) | //-- TS1
                                        (16'h4545                       & {16{(tsm_q[2:0] == 3'b101                  ) & ~insert_deskew}}) | //-- TS2
                                        (16'h4141                       & {16{(tsm_q[2:0] == 3'b110                  ) & ~insert_deskew}});  //-- TS3

assign training_set_word_2_ln0[15:0]  = ({cfg_deskew_ln0[ 7: 0], 8'h1E} & {16{(tsm_q[2  ] == 1'b1                    ) &  insert_deskew}}) | //-- Deskew
                                        (16'h4A4A                       & {16{(tsm_q[2:0] == 3'b100 | PM_tx_send_TS1s) & ~insert_deskew}}) | //-- TS1
                                        (16'h4545                       & {16{(tsm_q[2:0] == 3'b101                  ) & ~insert_deskew}}) | //-- TS2
                                        (16'h4141                       & {16{(tsm_q[2:0] == 3'b110                  ) & ~insert_deskew}});  //-- TS3
assign training_set_word_2_ln1[15:0]  = ({cfg_deskew_ln1[ 7: 0], 8'h1E} & {16{(tsm_q[2  ] == 1'b1                    ) &  insert_deskew}}) | //-- Deskew
                                        (16'h4A4A                       & {16{(tsm_q[2:0] == 3'b100 | PM_tx_send_TS1s) & ~insert_deskew}}) | //-- TS1
                                        (16'h4545                       & {16{(tsm_q[2:0] == 3'b101                  ) & ~insert_deskew}}) | //-- TS2
                                        (16'h4141                       & {16{(tsm_q[2:0] == 3'b110                  ) & ~insert_deskew}});  //-- TS3
assign training_set_word_2_ln2[15:0]  = ({cfg_deskew_ln2[ 7: 0], 8'h1E} & {16{(tsm_q[2  ] == 1'b1                    ) &  insert_deskew}}) | //-- Deskew
                                        (16'h4A4A                       & {16{(tsm_q[2:0] == 3'b100 | PM_tx_send_TS1s) & ~insert_deskew}}) | //-- TS1
                                        (16'h4545                       & {16{(tsm_q[2:0] == 3'b101                  ) & ~insert_deskew}}) | //-- TS2
                                        (16'h4141                       & {16{(tsm_q[2:0] == 3'b110                  ) & ~insert_deskew}});  //-- TS3
assign training_set_word_2_ln3[15:0]  = ({cfg_deskew_ln3[ 7: 0], 8'h1E} & {16{(tsm_q[2  ] == 1'b1                    ) &  insert_deskew}}) | //-- Deskew
                                        (16'h4A4A                       & {16{(tsm_q[2:0] == 3'b100 | PM_tx_send_TS1s) & ~insert_deskew}}) | //-- TS1
                                        (16'h4545                       & {16{(tsm_q[2:0] == 3'b101                  ) & ~insert_deskew}}) | //-- TS2
                                        (16'h4141                       & {16{(tsm_q[2:0] == 3'b110                  ) & ~insert_deskew}});  //-- TS3
assign training_set_word_2_ln4[15:0]  = ({cfg_deskew_ln4[ 7: 0], 8'h1E} & {16{(tsm_q[2  ] == 1'b1                    ) &  insert_deskew}}) | //-- Deskew
                                        (16'h4A4A                       & {16{(tsm_q[2:0] == 3'b100 | PM_tx_send_TS1s) & ~insert_deskew}}) | //-- TS1
                                        (16'h4545                       & {16{(tsm_q[2:0] == 3'b101                  ) & ~insert_deskew}}) | //-- TS2
                                        (16'h4141                       & {16{(tsm_q[2:0] == 3'b110                  ) & ~insert_deskew}});  //-- TS3
assign training_set_word_2_ln5[15:0]  = ({cfg_deskew_ln5[ 7: 0], 8'h1E} & {16{(tsm_q[2  ] == 1'b1                    ) &  insert_deskew}}) | //-- Deskew
                                        (16'h4A4A                       & {16{(tsm_q[2:0] == 3'b100 | PM_tx_send_TS1s) & ~insert_deskew}}) | //-- TS1
                                        (16'h4545                       & {16{(tsm_q[2:0] == 3'b101                  ) & ~insert_deskew}}) | //-- TS2
                                        (16'h4141                       & {16{(tsm_q[2:0] == 3'b110                  ) & ~insert_deskew}});  //-- TS3
assign training_set_word_2_ln6[15:0]  = ({cfg_deskew_ln6[ 7: 0], 8'h1E} & {16{(tsm_q[2  ] == 1'b1                    ) &  insert_deskew}}) | //-- Deskew
                                        (16'h4A4A                       & {16{(tsm_q[2:0] == 3'b100 | PM_tx_send_TS1s) & ~insert_deskew}}) | //-- TS1
                                        (16'h4545                       & {16{(tsm_q[2:0] == 3'b101                  ) & ~insert_deskew}}) | //-- TS2
                                        (16'h4141                       & {16{(tsm_q[2:0] == 3'b110                  ) & ~insert_deskew}});  //-- TS3
assign training_set_word_2_ln7[15:0]  = ({cfg_deskew_ln7[ 7: 0], 8'h1E} & {16{(tsm_q[2  ] == 1'b1                    ) &  insert_deskew}}) | //-- Deskew
                                        (16'h4A4A                       & {16{(tsm_q[2:0] == 3'b100 | PM_tx_send_TS1s) & ~insert_deskew}}) | //-- TS1
                                        (16'h4545                       & {16{(tsm_q[2:0] == 3'b101                  ) & ~insert_deskew}}) | //-- TS2
                                        (16'h4141                       & {16{(tsm_q[2:0] == 3'b110                  ) & ~insert_deskew}});  //-- TS3


assign training_set_word_3_ln0[15:0]  = (cfg_deskew_ln0[23: 8]          & {16{(tsm_q[2  ] == 1'b1                    ) &  insert_deskew}}) | //-- Deskew
                                        (16'h4A4A                       & {16{(tsm_q[2:0] == 3'b100 | PM_tx_send_TS1s) & ~insert_deskew}}) | //-- TS1
                                        (cfg_good_lanes[15: 0]          & {16{(tsm_q[2:0] == 3'b101                  ) & ~insert_deskew}}) | //-- TS2
                                        (cfg_good_lanes[15: 0]          & {16{(tsm_q[2:0] == 3'b110                  ) & ~insert_deskew}});  //-- TS3
assign training_set_word_3_ln1[15:0]  = (cfg_deskew_ln1[23: 8]          & {16{(tsm_q[2  ] == 1'b1                    ) &  insert_deskew}}) | //-- Deskew
                                        (16'h4A4A                       & {16{(tsm_q[2:0] == 3'b100 | PM_tx_send_TS1s) & ~insert_deskew}}) | //-- TS1
                                        (cfg_good_lanes[15: 0]          & {16{(tsm_q[2:0] == 3'b101                  ) & ~insert_deskew}}) | //-- TS2
                                        (cfg_good_lanes[15: 0]          & {16{(tsm_q[2:0] == 3'b110                  ) & ~insert_deskew}});  //-- TS3
assign training_set_word_3_ln2[15:0]  = (cfg_deskew_ln2[23: 8]          & {16{(tsm_q[2  ] == 1'b1                    ) &  insert_deskew}}) | //-- Deskew
                                        (16'h4A4A                       & {16{(tsm_q[2:0] == 3'b100 | PM_tx_send_TS1s) & ~insert_deskew}}) | //-- TS1
                                        (cfg_good_lanes[15: 0]          & {16{(tsm_q[2:0] == 3'b101                  ) & ~insert_deskew}}) | //-- TS2
                                        (cfg_good_lanes[15: 0]          & {16{(tsm_q[2:0] == 3'b110                  ) & ~insert_deskew}});  //-- TS3
assign training_set_word_3_ln3[15:0]  = (cfg_deskew_ln3[23: 8]          & {16{(tsm_q[2  ] == 1'b1                    ) &  insert_deskew}}) | //-- Deskew
                                        (16'h4A4A                       & {16{(tsm_q[2:0] == 3'b100 | PM_tx_send_TS1s) & ~insert_deskew}}) | //-- TS1
                                        (cfg_good_lanes[15: 0]          & {16{(tsm_q[2:0] == 3'b101                  ) & ~insert_deskew}}) | //-- TS2
                                        (cfg_good_lanes[15: 0]          & {16{(tsm_q[2:0] == 3'b110                  ) & ~insert_deskew}});  //-- TS3
assign training_set_word_3_ln4[15:0]  = (cfg_deskew_ln4[23: 8]          & {16{(tsm_q[2  ] == 1'b1                    ) &  insert_deskew}}) | //-- Deskew
                                        (16'h4A4A                       & {16{(tsm_q[2:0] == 3'b100 | PM_tx_send_TS1s) & ~insert_deskew}}) | //-- TS1
                                        (cfg_good_lanes[15: 0]          & {16{(tsm_q[2:0] == 3'b101                  ) & ~insert_deskew}}) | //-- TS2
                                        (cfg_good_lanes[15: 0]          & {16{(tsm_q[2:0] == 3'b110                  ) & ~insert_deskew}});  //-- TS3
assign training_set_word_3_ln5[15:0]  = (cfg_deskew_ln5[23: 8]          & {16{(tsm_q[2  ] == 1'b1                    ) &  insert_deskew}}) | //-- Deskew
                                        (16'h4A4A                       & {16{(tsm_q[2:0] == 3'b100 | PM_tx_send_TS1s) & ~insert_deskew}}) | //-- TS1
                                        (cfg_good_lanes[15: 0]          & {16{(tsm_q[2:0] == 3'b101                  ) & ~insert_deskew}}) | //-- TS2
                                        (cfg_good_lanes[15: 0]          & {16{(tsm_q[2:0] == 3'b110                  ) & ~insert_deskew}});  //-- TS3
assign training_set_word_3_ln6[15:0]  = (cfg_deskew_ln6[23: 8]          & {16{(tsm_q[2  ] == 1'b1                    ) &  insert_deskew}}) | //-- Deskew
                                        (16'h4A4A                       & {16{(tsm_q[2:0] == 3'b100 | PM_tx_send_TS1s) & ~insert_deskew}}) | //-- TS1
                                        (cfg_good_lanes[15: 0]          & {16{(tsm_q[2:0] == 3'b101                  ) & ~insert_deskew}}) | //-- TS2
                                        (cfg_good_lanes[15: 0]          & {16{(tsm_q[2:0] == 3'b110                  ) & ~insert_deskew}});  //-- TS3
assign training_set_word_3_ln7[15:0]  = (cfg_deskew_ln7[23: 8]          & {16{(tsm_q[2  ] == 1'b1                    ) &  insert_deskew}}) | //-- Deskew
                                        (16'h4A4A                       & {16{(tsm_q[2:0] == 3'b100 | PM_tx_send_TS1s) & ~insert_deskew}}) | //-- TS1
                                        (cfg_good_lanes[15: 0]          & {16{(tsm_q[2:0] == 3'b101                  ) & ~insert_deskew}}) | //-- TS2
                                        (cfg_good_lanes[15: 0]          & {16{(tsm_q[2:0] == 3'b110                  ) & ~insert_deskew}});  //-- TS3

//-- Need to insert deskew pattern every 32 TSX patterns, counter rolls over to restart count
assign insert_deskew                 = insert_deskew_ts_cnt_q[4:0] == 5'b11111;


//-- deskew inserted in states 4-6
assign insert_deskew_ts_cnt_din[4:0] = ((tsm_q[2] == 1'b0) | (&tsm_q[2:0]))     ? 5'b000000 :
                                       (tsm_q[2] & (cycle_cnt_q[1:0] == 2'b11)) ? insert_deskew_ts_cnt_q[4:0] + 5'b000001 : // 1 TSX pattern sent
                                                                                  insert_deskew_ts_cnt_q[4:0];
//-- Format x4 and x8 TS good lanes message
assign rx_cfg_x32                 = rx_tx_rem_supported_widths[3];
assign rx_cfg_x16                 = rx_tx_rem_supported_widths[2];
assign rx_cfg_x8                  = rx_tx_rem_supported_widths[1];
assign rx_cfg_x4                  = rx_tx_rem_supported_widths[0];
assign tx_cfg_x32                 = cfg_omi_supported_widths_q[3];
assign tx_cfg_x16                 = cfg_omi_supported_widths_q[2];
assign tx_cfg_x8                  = cfg_omi_supported_widths_q[1];
assign tx_cfg_x4                  = cfg_omi_supported_widths_q[0];

//-- Need to report the good lanes back to the TX of the remote side.
assign cfg_x4                     =         tx_cfg_x4 & rx_cfg_x4 &     //-- both sides can run as x4 AND
                                         (( tx_cfg_x8 ^  rx_cfg_x8 ) |  //-- one  side  can't run as a x8 or
                                          (~tx_cfg_x8 & ~rx_cfg_x8));   //-- both sides can't run as a x8

assign cfg_x8                     = ~cfg_x4;
assign cfg_x16                    = 1'b0; //-- Reservered for future implementation
assign cfg_x32                    = 1'b0; //-- Reservered for future implementation

assign ts_trained_mode[3:0]       = {cfg_x32, cfg_x16, cfg_x8, cfg_x4};
assign cfg_good_lanes_x4[15:0]    = {ts_trained_mode[3:0], ~ts_x2_inner_q, ~ts_x2_outer_q, 1'b0, 1'b0, 8'h00};
assign cfg_good_lanes_x8[15:0]    = {ts_trained_mode[3:0], ~ts_x4_inner_q, ~ts_x4_outer_q, 1'b0, 1'b0, 8'h00};


//-- Select TS good lanes message to send
assign cfg_good_lanes[15:0]       = ({16{ cfg_x4}} & cfg_good_lanes_x4[15:0]) | 
                                    ({16{~cfg_x4}} & cfg_good_lanes_x8[15:0]);

assign ts_x4_outer_din            = ((disabled_rx_lanes[7] & disabled_rx_lanes[5] & disabled_rx_lanes[2] & disabled_rx_lanes[0]) | ts_x4_outer_q) & ~start_retrain;
assign ts_x4_inner_din            = ((disabled_rx_lanes[6] & disabled_rx_lanes[4] & disabled_rx_lanes[3] & disabled_rx_lanes[1]) | ts_x4_inner_q) & ~start_retrain;

assign ts_x2_inner_din            = ((disabled_rx_lanes[5] & disabled_rx_lanes[2]) | ts_x2_inner_q) & ~start_retrain;
assign ts_x2_outer_din            = ((disabled_rx_lanes[7] & disabled_rx_lanes[0]) | ts_x2_outer_q) & ~start_retrain;


//-- Deskew Pattern: Lane Number and Configuration
//--
//--  Lane # and Configuration info
//--  orig[63:0]   info
//--  ----------   ----
//--  23:18        reserved
//--  17           x8 mode supported
//--  16:14        reserved
//--  13:8         Version Number
//--  7            TX lane ordering for degraded modes: 1 = FPGA (lane then neighbor), 0 = HOST (neighbor then lane)
//--  6            TX lane swap requested (bus reversal)
//--  5            Reserved
//--  4:0          Lane number

//-- Sim signals to stick in order to test different  or version number combinations
assign lane0_number[4:0] = 5'b00000;
assign lane1_number[4:0] = 5'b00001;
assign lane2_number[4:0] = 5'b00010;
assign lane3_number[4:0] = 5'b00011;
assign lane4_number[4:0] = 5'b00100;
assign lane5_number[4:0] = 5'b00101;
assign lane6_number[4:0] = 5'b00110;
assign lane7_number[4:0] = 5'b00111;

assign sim_only_version[6:0] = 7'b000_0000;  //-- Bit 6 = enable bit.  Bits [5:0] = version number override
assign deskew_version[5:0]   = sim_only_version[6] ? sim_only_version[5:0] : cfg_omi_version_q[5:0];

assign cfg_deskew_ln0[23:0]       = {1'b0,                             //--bits[23   ] Deskew Byte 2
                                     request_lane_reverse_q,           //--bits[22   ] Deskew Byte 2
                                     cfg_omi_PM_enable_q,              //--bits[21   ] Deskew Byte 2
                                     lane0_number[4:0],                //--bits[20:16] Deskew Byte 2
                                     cfg_omi_half_width_enable_q,      //--bits[15   ] Deskew Byte 1
                                     cfg_omi_quarter_width_enable_q,   //--bits[14   ] Deskew Byte 1
                                     deskew_version[5:0],              //--bits[13: 8] Deskew Byte 1
                                     4'b0000,                          //--bits[ 7: 4] Deskew Byte 0
                                     cfg_omi_supported_widths_q[3:0]}; //--bits[ 3: 0] Deskew Byte 0
                                     
assign cfg_deskew_ln1[23:0]       = {1'b0, request_lane_reverse_q, cfg_omi_PM_enable_q, lane1_number[4:0], cfg_omi_half_width_enable_q, cfg_omi_quarter_width_enable_q, deskew_version[5:0], 4'b0000, cfg_omi_supported_widths_q[3:0]};
assign cfg_deskew_ln2[23:0]       = {1'b0, request_lane_reverse_q, cfg_omi_PM_enable_q, lane2_number[4:0], cfg_omi_half_width_enable_q, cfg_omi_quarter_width_enable_q, deskew_version[5:0], 4'b0000, cfg_omi_supported_widths_q[3:0]};
assign cfg_deskew_ln3[23:0]       = {1'b0, request_lane_reverse_q, cfg_omi_PM_enable_q, lane3_number[4:0], cfg_omi_half_width_enable_q, cfg_omi_quarter_width_enable_q, deskew_version[5:0], 4'b0000, cfg_omi_supported_widths_q[3:0]};
assign cfg_deskew_ln4[23:0]       = {1'b0, request_lane_reverse_q, cfg_omi_PM_enable_q, lane4_number[4:0], cfg_omi_half_width_enable_q, cfg_omi_quarter_width_enable_q, deskew_version[5:0], 4'b0000, cfg_omi_supported_widths_q[3:0]};
assign cfg_deskew_ln5[23:0]       = {1'b0, request_lane_reverse_q, cfg_omi_PM_enable_q, lane5_number[4:0], cfg_omi_half_width_enable_q, cfg_omi_quarter_width_enable_q, deskew_version[5:0], 4'b0000, cfg_omi_supported_widths_q[3:0]};
assign cfg_deskew_ln6[23:0]       = {1'b0, request_lane_reverse_q, cfg_omi_PM_enable_q, lane6_number[4:0], cfg_omi_half_width_enable_q, cfg_omi_quarter_width_enable_q, deskew_version[5:0], 4'b0000, cfg_omi_supported_widths_q[3:0]};
assign cfg_deskew_ln7[23:0]       = {1'b0, request_lane_reverse_q, cfg_omi_PM_enable_q, lane7_number[4:0], cfg_omi_half_width_enable_q, cfg_omi_quarter_width_enable_q, deskew_version[5:0], 4'b0000, cfg_omi_supported_widths_q[3:0]};

assign sim_only_request_ln_rev       = 1'b0; //-- '0' OMI handles all lane reversal on RX side
                                             //-- '1' SIM ONLY function to request TX lane swap
assign tx_rx_sim_only_request_ln_rev = sim_only_request_ln_rev;
assign rx_lane_reverse               = rx_tx_rx_lane_reverse;
assign request_lane_reverse_din      = sim_only_request_ln_rev & rx_lane_reverse; //-- Tell TX from otherside to reverse transmit order

//-- lane swap determined from deskew pattern.  Only allow lane swap to happen if the config bit allows it
//-- bit 0 --> tx lane swap requested
//-- bit 1 --> tx lanes reversed
assign tx_lane_swap_din[0]        = rx_tx_tx_lane_swap;
assign tx_lane_swap_din[1]        = tx_lane_swap_q[0] & cfg_enable_tx_lane_swap_q;
//-- Report error on rising edge of tx lane swap if lane swap is not allowed
assign tx_lane_swap_err_din       = (tx_lane_swap_din[0] & ~tx_lane_swap_q[0]) & ~cfg_enable_tx_lane_swap_q;
assign trn_ln_reverse             = 1'b0;

generate
if (RX_EQ_TX_CLK == 1) //--  OCMB chip will never need to swap its TX lanes.  Let synthesis rip out all TX lane muxing
  begin
   assign trn_agn_ln_swap         = 1'b0;
  end
else
  begin
   assign trn_agn_ln_swap         = tx_lane_swap_q[1];
  end
endgenerate

//--------------------------------------------------------
//--                   Scrambling
//--
//--------------------------------------------------------
//--
//-- 1. All lanes are scrambled to help make sure there isn't a long string of 1's or 0's sent across the PHY
//-- 2. LFSR (Linear Feedback Shift Register) shifts left to right with rightmost bit being fed back to input.
//-- 3. Advance by 16 bits per clock cycle because that's how many bits are transmitted each cycle.
//-- 4. In order to disable scrambling, set lfsr_q to 0.

//-- Fibonacci LFSR, advance for all cycles
//-- this register shifts left to right
//-- PRBS-23 polynomial X^23 + X^21 + X^16 + X^8 + X^5 + X^2 + 1
assign lfsr_din[22:0] =                                        {23{phy_training_d0_q[8]}}                            |            //--set to all 1 before coding cycle starts
                        ( lfsr_q[22:0]                       & {23{(cycle_cnt_q[5:0] == 6'b000000)}})                |            //--stall LFSR from advancing (allow time to insert header bits)
                        ({lfsr_next_16[15:0], lfsr_q[22:16]} & {23{(~phy_training_d0_q[8] & ~(cycle_cnt_q[5:0] == 6'b000000))}}); //--advance 16 bits

//-- Advance the lfsr by 16 bits/cycle
assign lfsr_next_16[15]  = lfsr_q[18]  ^ lfsr_q[15]  ^ lfsr_q[14] ^ lfsr_q[11] ^ lfsr_q[9]  ^ lfsr_q[6]  ^ lfsr_q[4]  ^ lfsr_q[3];
assign lfsr_next_16[14]  = lfsr_q[17]  ^ lfsr_q[14]  ^ lfsr_q[13] ^ lfsr_q[10] ^ lfsr_q[8]  ^ lfsr_q[5]  ^ lfsr_q[3]  ^ lfsr_q[2];
assign lfsr_next_16[13]  = lfsr_q[16]  ^ lfsr_q[13]  ^ lfsr_q[12] ^ lfsr_q[9]  ^ lfsr_q[7]  ^ lfsr_q[4]  ^ lfsr_q[2]  ^ lfsr_q[1];
assign lfsr_next_16[12]  = lfsr_q[15]  ^ lfsr_q[12]  ^ lfsr_q[11] ^ lfsr_q[8]  ^ lfsr_q[6]  ^ lfsr_q[3]  ^ lfsr_q[1]  ^ lfsr_q[0];
assign lfsr_next_16[11]  = lfsr_q[22]  ^ lfsr_q[20]  ^ lfsr_q[15] ^ lfsr_q[14] ^ lfsr_q[11] ^ lfsr_q[10] ^ lfsr_q[5]  ^ lfsr_q[4]  ^
                           lfsr_q[2]   ^ lfsr_q[1]   ^ lfsr_q[0];
assign lfsr_next_16[10]  = lfsr_q[22]  ^ lfsr_q[21]  ^ lfsr_q[20] ^ lfsr_q[19] ^ lfsr_q[15] ^ lfsr_q[14] ^ lfsr_q[13] ^ lfsr_q[10] ^
                           lfsr_q[9]   ^ lfsr_q[7]   ^ lfsr_q[3]  ^ lfsr_q[0];
assign lfsr_next_16[9]   = lfsr_q[22]  ^ lfsr_q[21]  ^ lfsr_q[19] ^ lfsr_q[18] ^ lfsr_q[15] ^ lfsr_q[14] ^ lfsr_q[13] ^ lfsr_q[12] ^
                           lfsr_q[9]   ^ lfsr_q[8]   ^ lfsr_q[7]  ^ lfsr_q[6]  ^ lfsr_q[4]  ^ lfsr_q[2]  ^ lfsr_q[1];
assign lfsr_next_16[8]   = lfsr_q[21]  ^ lfsr_q[20]  ^ lfsr_q[18] ^ lfsr_q[17] ^ lfsr_q[14] ^ lfsr_q[13] ^ lfsr_q[12] ^ lfsr_q[11] ^
                           lfsr_q[8]   ^ lfsr_q[7]   ^ lfsr_q[6]  ^ lfsr_q[5]  ^ lfsr_q[3]  ^ lfsr_q[1]  ^ lfsr_q[0];
assign lfsr_next_16[7]   = lfsr_q[22]  ^ lfsr_q[19]  ^ lfsr_q[17] ^ lfsr_q[16] ^ lfsr_q[15] ^ lfsr_q[13] ^ lfsr_q[12] ^ lfsr_q[11] ^
                           lfsr_q[10]  ^ lfsr_q[6]   ^ lfsr_q[5]  ^ lfsr_q[2]  ^ lfsr_q[1]  ^ lfsr_q[0];
assign lfsr_next_16[6]   = lfsr_q[22]  ^ lfsr_q[21]  ^ lfsr_q[20] ^ lfsr_q[18] ^ lfsr_q[16] ^ lfsr_q[14] ^ lfsr_q[12] ^ lfsr_q[11] ^
                           lfsr_q[10]  ^ lfsr_q[9]   ^ lfsr_q[7]  ^ lfsr_q[5]  ^ lfsr_q[0];
assign lfsr_next_16[5]   = lfsr_q[22]  ^ lfsr_q[21]  ^ lfsr_q[19] ^ lfsr_q[17] ^ lfsr_q[13] ^ lfsr_q[11] ^ lfsr_q[10] ^ lfsr_q[9]  ^
                           lfsr_q[8]   ^ lfsr_q[7]   ^ lfsr_q[6]  ^ lfsr_q[1];
assign lfsr_next_16[4]   = lfsr_q[21]  ^ lfsr_q[20]  ^ lfsr_q[18] ^ lfsr_q[16] ^ lfsr_q[12] ^ lfsr_q[10] ^ lfsr_q[9]  ^ lfsr_q[8]  ^
                           lfsr_q[7]   ^ lfsr_q[6]   ^ lfsr_q[5]  ^ lfsr_q[0];
assign lfsr_next_16[3]   = lfsr_q[22]  ^ lfsr_q[19]  ^ lfsr_q[17] ^ lfsr_q[11] ^ lfsr_q[9]  ^ lfsr_q[8]  ^ lfsr_q[6]  ^ lfsr_q[5]  ^ lfsr_q[1];
assign lfsr_next_16[2]   = lfsr_q[21]  ^ lfsr_q[18]  ^ lfsr_q[16] ^ lfsr_q[10] ^ lfsr_q[8]  ^ lfsr_q[7]  ^ lfsr_q[5]  ^ lfsr_q[4]  ^ lfsr_q[0];
assign lfsr_next_16[1]   = lfsr_q[22]  ^ lfsr_q[17]  ^ lfsr_q[9]  ^ lfsr_q[6]  ^ lfsr_q[3]  ^ lfsr_q[1];
assign lfsr_next_16[0]   = lfsr_q[21]  ^ lfsr_q[16]  ^ lfsr_q[8]  ^ lfsr_q[5]  ^ lfsr_q[2]  ^ lfsr_q[0];


//-- each lane is a different phase of the bit stream, these signals are bits 15 to 0 in the order produced by the LFSR (transmit order)
assign scramble_0[15:0] = {(lfsr_q[0]), 
                           (lfsr_q[1]), 
                           (lfsr_q[2]), 
                           (lfsr_q[3]), 
                           (lfsr_q[4]), 
                           (lfsr_q[5]), 
                           (lfsr_q[6]), 
                           (lfsr_q[7]), 
                           (lfsr_q[8]), 
                           (lfsr_q[9]), 
                           (lfsr_q[10]), 
                           (lfsr_q[11]), 
                           (lfsr_q[12]), 
                           (lfsr_q[13]), 
                           (lfsr_q[14]), 
                           (lfsr_q[15])};

assign scramble_1[15:0] = {(lfsr_q[5]  ^ lfsr_q[2]  ^ lfsr_q[0]), 
                           (lfsr_q[6]  ^ lfsr_q[3]  ^ lfsr_q[1]), 
                           (lfsr_q[7]  ^ lfsr_q[4]  ^ lfsr_q[2]), 
                           (lfsr_q[8]  ^ lfsr_q[5]  ^ lfsr_q[3]), 
                           (lfsr_q[9]  ^ lfsr_q[6]  ^ lfsr_q[4]), 
                           (lfsr_q[10] ^ lfsr_q[7]  ^ lfsr_q[5]), 
                           (lfsr_q[11] ^ lfsr_q[8]  ^ lfsr_q[6]), 
                           (lfsr_q[12] ^ lfsr_q[9]  ^ lfsr_q[7]), 
                           (lfsr_q[13] ^ lfsr_q[10] ^ lfsr_q[8]), 
                           (lfsr_q[14] ^ lfsr_q[11] ^ lfsr_q[9]), 
                           (lfsr_q[15] ^ lfsr_q[12] ^ lfsr_q[10]), 
                           (lfsr_q[16] ^ lfsr_q[13] ^ lfsr_q[11]), 
                           (lfsr_q[17] ^ lfsr_q[14] ^ lfsr_q[12]), 
                           (lfsr_q[18] ^ lfsr_q[15] ^ lfsr_q[13]), 
                           (lfsr_q[19] ^ lfsr_q[16] ^ lfsr_q[14]), 
                           (lfsr_q[20] ^ lfsr_q[17] ^ lfsr_q[15])};

assign scramble_2[15:0] = {(lfsr_q[6]  ^ lfsr_q[1]  ^ lfsr_q[0]), 
                           (lfsr_q[7]  ^ lfsr_q[2]  ^ lfsr_q[1]), 
                           (lfsr_q[8]  ^ lfsr_q[3]  ^ lfsr_q[2]), 
                           (lfsr_q[9]  ^ lfsr_q[4]  ^ lfsr_q[3]), 
                           (lfsr_q[10] ^ lfsr_q[5]  ^ lfsr_q[4]), 
                           (lfsr_q[11] ^ lfsr_q[6]  ^ lfsr_q[5]), 
                           (lfsr_q[12] ^ lfsr_q[7]  ^ lfsr_q[6]), 
                           (lfsr_q[13] ^ lfsr_q[8]  ^ lfsr_q[7]), 
                           (lfsr_q[14] ^ lfsr_q[9]  ^ lfsr_q[8]), 
                           (lfsr_q[15] ^ lfsr_q[10] ^ lfsr_q[9]), 
                           (lfsr_q[16] ^ lfsr_q[11] ^ lfsr_q[10]), 
                           (lfsr_q[17] ^ lfsr_q[12] ^ lfsr_q[11]), 
                           (lfsr_q[18] ^ lfsr_q[13] ^ lfsr_q[12]), 
                           (lfsr_q[19] ^ lfsr_q[14] ^ lfsr_q[13]), 
                           (lfsr_q[20] ^ lfsr_q[15] ^ lfsr_q[14]), 
                           (lfsr_q[21] ^ lfsr_q[16] ^ lfsr_q[15])};

assign scramble_3[15:0] = {(lfsr_q[7]  ^ lfsr_q[2]  ^ lfsr_q[0]), 
                           (lfsr_q[8]  ^ lfsr_q[3]  ^ lfsr_q[1]), 
                           (lfsr_q[9]  ^ lfsr_q[4]  ^ lfsr_q[2]), 
                           (lfsr_q[10] ^ lfsr_q[5]  ^ lfsr_q[3]), 
                           (lfsr_q[11] ^ lfsr_q[6]  ^ lfsr_q[4]), 
                           (lfsr_q[12] ^ lfsr_q[7]  ^ lfsr_q[5]), 
                           (lfsr_q[13] ^ lfsr_q[8]  ^ lfsr_q[6]), 
                           (lfsr_q[14] ^ lfsr_q[9]  ^ lfsr_q[7]), 
                           (lfsr_q[15] ^ lfsr_q[10] ^ lfsr_q[8]), 
                           (lfsr_q[16] ^ lfsr_q[11] ^ lfsr_q[9]), 
                           (lfsr_q[17] ^ lfsr_q[12] ^ lfsr_q[10]), 
                           (lfsr_q[18] ^ lfsr_q[13] ^ lfsr_q[11]), 
                           (lfsr_q[19] ^ lfsr_q[14] ^ lfsr_q[12]), 
                           (lfsr_q[20] ^ lfsr_q[15] ^ lfsr_q[13]), 
                           (lfsr_q[21] ^ lfsr_q[16] ^ lfsr_q[14]), 
                           (lfsr_q[22] ^ lfsr_q[17] ^ lfsr_q[15])};

assign scramble_4[15:0] = {(lfsr_q[5]  ^ lfsr_q[4]  ^ lfsr_q[0]), 
                           (lfsr_q[6]  ^ lfsr_q[5]  ^ lfsr_q[1]), 
                           (lfsr_q[7]  ^ lfsr_q[6]  ^ lfsr_q[2]), 
                           (lfsr_q[8]  ^ lfsr_q[7]  ^ lfsr_q[3]), 
                           (lfsr_q[9]  ^ lfsr_q[8]  ^ lfsr_q[4]), 
                           (lfsr_q[10] ^ lfsr_q[9]  ^ lfsr_q[5]), 
                           (lfsr_q[11] ^ lfsr_q[10] ^ lfsr_q[6]), 
                           (lfsr_q[12] ^ lfsr_q[11] ^ lfsr_q[7]), 
                           (lfsr_q[13] ^ lfsr_q[12] ^ lfsr_q[8]), 
                           (lfsr_q[14] ^ lfsr_q[13] ^ lfsr_q[9]), 
                           (lfsr_q[15] ^ lfsr_q[14] ^ lfsr_q[10]), 
                           (lfsr_q[16] ^ lfsr_q[15] ^ lfsr_q[11]), 
                           (lfsr_q[17] ^ lfsr_q[16] ^ lfsr_q[12]), 
                           (lfsr_q[18] ^ lfsr_q[17] ^ lfsr_q[13]), 
                           (lfsr_q[19] ^ lfsr_q[18] ^ lfsr_q[14]), 
                           (lfsr_q[20] ^ lfsr_q[19] ^ lfsr_q[15])};

assign scramble_5[15:0] = {(lfsr_q[6]  ^ lfsr_q[0]), 
                           (lfsr_q[7]  ^ lfsr_q[1]), 
                           (lfsr_q[8]  ^ lfsr_q[2]), 
                           (lfsr_q[9]  ^ lfsr_q[3]), 
                           (lfsr_q[10] ^ lfsr_q[4]), 
                           (lfsr_q[11] ^ lfsr_q[5]), 
                           (lfsr_q[12] ^ lfsr_q[6]), 
                           (lfsr_q[13] ^ lfsr_q[7]), 
                           (lfsr_q[14] ^ lfsr_q[8]), 
                           (lfsr_q[15] ^ lfsr_q[9]), 
                           (lfsr_q[16] ^ lfsr_q[10]), 
                           (lfsr_q[17] ^ lfsr_q[11]), 
                           (lfsr_q[18] ^ lfsr_q[12]), 
                           (lfsr_q[19] ^ lfsr_q[13]), 
                           (lfsr_q[20] ^ lfsr_q[14]), 
                           (lfsr_q[21] ^ lfsr_q[15])};

assign scramble_6[15:0] = {(lfsr_q[7]  ^ lfsr_q[1]  ^ lfsr_q[0]), 
                           (lfsr_q[8]  ^ lfsr_q[2]  ^ lfsr_q[1]), 
                           (lfsr_q[9]  ^ lfsr_q[3]  ^ lfsr_q[2]), 
                           (lfsr_q[10] ^ lfsr_q[4]  ^ lfsr_q[3]), 
                           (lfsr_q[11] ^ lfsr_q[5]  ^ lfsr_q[4]), 
                           (lfsr_q[12] ^ lfsr_q[6]  ^ lfsr_q[5]), 
                           (lfsr_q[13] ^ lfsr_q[7]  ^ lfsr_q[6]), 
                           (lfsr_q[14] ^ lfsr_q[8]  ^ lfsr_q[7]), 
                           (lfsr_q[15] ^ lfsr_q[9]  ^ lfsr_q[8]), 
                           (lfsr_q[16] ^ lfsr_q[10] ^ lfsr_q[9]), 
                           (lfsr_q[17] ^ lfsr_q[11] ^ lfsr_q[10]), 
                           (lfsr_q[18] ^ lfsr_q[12] ^ lfsr_q[11]), 
                           (lfsr_q[19] ^ lfsr_q[13] ^ lfsr_q[12]), 
                           (lfsr_q[20] ^ lfsr_q[14] ^ lfsr_q[13]), 
                           (lfsr_q[21] ^ lfsr_q[15] ^ lfsr_q[14]), 
                           (lfsr_q[22] ^ lfsr_q[16] ^ lfsr_q[15])};

assign scramble_7[15:0] = {(lfsr_q[6]  ^ lfsr_q[5]  ^ lfsr_q[0]), 
                           (lfsr_q[7]  ^ lfsr_q[6]  ^ lfsr_q[1]), 
                           (lfsr_q[8]  ^ lfsr_q[7]  ^ lfsr_q[2]), 
                           (lfsr_q[9]  ^ lfsr_q[8]  ^ lfsr_q[3]), 
                           (lfsr_q[10] ^ lfsr_q[9]  ^ lfsr_q[4]), 
                           (lfsr_q[11] ^ lfsr_q[10] ^ lfsr_q[5]), 
                           (lfsr_q[12] ^ lfsr_q[11] ^ lfsr_q[6]), 
                           (lfsr_q[13] ^ lfsr_q[12] ^ lfsr_q[7]), 
                           (lfsr_q[14] ^ lfsr_q[13] ^ lfsr_q[8]), 
                           (lfsr_q[15] ^ lfsr_q[14] ^ lfsr_q[9]), 
                           (lfsr_q[16] ^ lfsr_q[15] ^ lfsr_q[10]), 
                           (lfsr_q[17] ^ lfsr_q[16] ^ lfsr_q[11]), 
                           (lfsr_q[18] ^ lfsr_q[17] ^ lfsr_q[12]), 
                           (lfsr_q[19] ^ lfsr_q[18] ^ lfsr_q[13]), 
                           (lfsr_q[20] ^ lfsr_q[19] ^ lfsr_q[14]), 
                           (lfsr_q[21] ^ lfsr_q[20] ^ lfsr_q[15])};
  
assign trn_ln0_scrambler[15:0]        = scramble_0[15:0]; 
assign trn_ln1_scrambler[15:0]        = scramble_1[15:0]; 
assign trn_ln2_scrambler[15:0]        = scramble_2[15:0]; 
assign trn_ln3_scrambler[15:0]        = scramble_3[15:0]; 
assign trn_ln4_scrambler[15:0]        = scramble_4[15:0]; 
assign trn_ln5_scrambler[15:0]        = scramble_5[15:0]; 
assign trn_ln6_scrambler[15:0]        = scramble_6[15:0]; 
assign trn_ln7_scrambler[15:0]        = scramble_7[15:0]; 

//-----------------------------------------------
//--         Training Control Logic
//-----------------------------------------------
assign trn_ln_dl_training[7:0]       = {8{(tsm_q[2:0] == 3'b100) | (tsm_q[2:0] == 3'b101) | (tsm_q[2:0] == 3'b110)}} | (disabled_tx_lanes_q[7:0] & {8{PM_tx_send_TS1s}});
assign tx_rx_reset_n                 = cfg_omi_reset_q;

assign trn_reset_n                   = cfg_omi_reset_q;
assign trn_enable                    = cfg_omi_enable_q;

//-- Need to delay this a cycle because trn_agn_training_set[15:0] gets latched in tx align before going to tx lane
assign phy_training_din           = ~tsm_q[2] & ~cfg_tx_sync_pattern; 
//-- reduce fanout and add lane disable capability
assign phy_training_d0_din[8]         = phy_training_q;      //-- only goes to LFSR in this file
assign phy_training_d0_din[7:0]       = {8{phy_training_q}}; //-- goes to individual lanes (dlc_omi_tx_lane.v)
//-- switch mux in dlc_omi_tx.v to allow transmission of 0's
assign trn_ln_phy_training[7:0]       = phy_training_d0_q[7:0];


assign cycle_cnt_din[5:0]    = (cycle_cnt_q[5:0] == 6'b100000 ) | //-- TSX and Deskew 
                               (sim_only_hold_cycle_cnt       )   ? 6'b000000 : 
                                                                    cycle_cnt_q[5:0] + 6'b000001;

assign trn_agn_stall         = (cycle_cnt_q[5:0] == 6'b100000);

//--assign trn_flt_stall         = (x8_tx_mode & (  cycle_cnt_q[5:0] == 6'b011100)) |
//--                               (x4_tx_mode & ( (cycle_cnt_q[  0]           & ~(cycle_cnt_q[5:2] == 4'b0111  )) | (cycle_cnt_q[5:0] == 6'b011110) | (cycle_cnt_q[5]) | (cycle_cnt_q[5:0] == 6'b011100))) |
//--                               (x2_tx_mode & (((cycle_cnt_q[1:0] != 2'b00) & ~(cycle_cnt_q[5:0] == 6'b011101)) |                                   (cycle_cnt_q[5]) | (cycle_cnt_q[5:0] == 6'b011100)));
//-- assign trn_flt_stall         = (x8_tx_mode & (   cycle_cnt_q[5:0] == 6'b011100)) |
//--                                (x4_tx_mode & ( ((cycle_cnt_q[  0] != 1'b1 ) & ~(cycle_cnt_q[5:2] == 4'b0111 | cycle_cnt_q[5])) | (cycle_cnt_q[5:0] == 6'b011011) | (cycle_cnt_q[5:0] == 6'b011101) | (cycle_cnt_q[5:0] == 6'b011111))) |
//--                                (x2_tx_mode & ( ((cycle_cnt_q[1:0] != 2'b11) & ~(cycle_cnt_q[5:2] == 4'b0111 | cycle_cnt_q[5])) | (cycle_cnt_q[5:0] == 6'b011011) | ((cycle_cnt_q[5:2] == 4'b0111) & cycle_cnt_q[1:0] != 2'b00)));

//-- need to capture when the pm_msg_sent is received so we can base the stalls to the flit macro accordingly.  also need to reset the PM_cycle with each retrain.
assign update_PM_cycle             = PM_msg_sent & (PM_state_host_half2quarter | PM_state_host_full2half | PM_state_EP_half2quarter | PM_state_EP_full2half);

assign PM_cycle_din[1:0]           = (2'b01 & {2{(update_PM_cycle & (cycle_cnt_q[5:0] == 6'b000000))}}) | 
                                     (2'b10 & {2{(update_PM_cycle & (cycle_cnt_q[5:0] == 6'b000001))}}) | 
                                     (2'b11 & {2{(update_PM_cycle & (cycle_cnt_q[5:0] == 6'b000010))}}) | 
                                     (2'b00 & {2{(update_PM_cycle & (cycle_cnt_q[5:0] == 6'b000011))}}) | 
                                     (2'b01 & {2{(update_PM_cycle & (cycle_cnt_q[5:0] == 6'b000100))}}) | 
                                     (2'b10 & {2{(update_PM_cycle & (cycle_cnt_q[5:0] == 6'b000101))}}) | 
                                     (2'b11 & {2{(update_PM_cycle & (cycle_cnt_q[5:0] == 6'b000110))}}) | 
                                     (2'b00 & {2{(update_PM_cycle & (cycle_cnt_q[5:0] == 6'b000111))}}) | 
                                     (2'b01 & {2{(update_PM_cycle & (cycle_cnt_q[5:0] == 6'b001000))}}) | 
                                     (2'b10 & {2{(update_PM_cycle & (cycle_cnt_q[5:0] == 6'b001001))}}) | 
                                     (2'b11 & {2{(update_PM_cycle & (cycle_cnt_q[5:0] == 6'b001010))}}) | 
                                     (2'b00 & {2{(update_PM_cycle & (cycle_cnt_q[5:0] == 6'b001011))}}) | 
                                     (2'b01 & {2{(update_PM_cycle & (cycle_cnt_q[5:0] == 6'b001100))}}) | 
                                     (2'b10 & {2{(update_PM_cycle & (cycle_cnt_q[5:0] == 6'b001101))}}) | 
                                     (2'b11 & {2{(update_PM_cycle & (cycle_cnt_q[5:0] == 6'b001110))}}) | 
                                     (2'b00 & {2{(update_PM_cycle & (cycle_cnt_q[5:0] == 6'b001111))}}) | 
                                     (2'b01 & {2{(update_PM_cycle & (cycle_cnt_q[5:0] == 6'b010000))}}) | 
                                     (2'b10 & {2{(update_PM_cycle & (cycle_cnt_q[5:0] == 6'b010001))}}) | 
                                     (2'b11 & {2{(update_PM_cycle & (cycle_cnt_q[5:0] == 6'b010010))}}) | 
                                     (2'b00 & {2{(update_PM_cycle & (cycle_cnt_q[5:0] == 6'b010011))}}) | 
                                     (2'b01 & {2{(update_PM_cycle & (cycle_cnt_q[5:0] == 6'b010100))}}) | 
                                     (2'b10 & {2{(update_PM_cycle & (cycle_cnt_q[5:0] == 6'b010101))}}) | 
                                     (2'b11 & {2{(update_PM_cycle & (cycle_cnt_q[5:0] == 6'b010110))}}) | 
                                     (2'b00 & {2{(update_PM_cycle & (cycle_cnt_q[5:0] == 6'b010111))}}) | 
                                     (2'b01 & {2{(update_PM_cycle & (cycle_cnt_q[5:0] == 6'b011000))}}) | 
                                     (2'b10 & {2{(update_PM_cycle & (cycle_cnt_q[5:0] == 6'b011001))}}) | 
                                     (2'b11 & {2{(update_PM_cycle & (cycle_cnt_q[5:0] == 6'b011010))}}) | 
                                     (2'b00 & {2{(update_PM_cycle & (cycle_cnt_q[5:0] == 6'b011011))}}) | 
                                     (2'b01 & {2{(update_PM_cycle & (cycle_cnt_q[5:0] == 6'b011100))}}) | //--  33 cycle stall
                                     (2'b10 & {2{(update_PM_cycle & (cycle_cnt_q[5:0] == 6'b011101))}}) | 
                                     (2'b11 & {2{(update_PM_cycle & (cycle_cnt_q[5:0] == 6'b011110))}}) | 
                                     (2'b00 & {2{(update_PM_cycle & (cycle_cnt_q[5:0] == 6'b011111))}}) |
                                     (2'b01 & {2{(update_PM_cycle & (cycle_cnt_q[5:0] == 6'b100000))}}) |
                                     (PM_cycle_q[1:0] & {2{(~update_PM_cycle & ~(tsm_q[2:0] == 3'b100))}});

assign trn_flt_stall         = (x8_tx_mode & (   cycle_cnt_q[5:0] == 6'b011100)) |
                               (x4_tx_mode & ~PM_cycle_q[0] & ( (cycle_cnt_q[5:0] == 6'b000000)   |
                                                                (cycle_cnt_q[5:0] == 6'b000010)   |
                                                                (cycle_cnt_q[5:0] == 6'b000100)   |
                                                                (cycle_cnt_q[5:0] == 6'b000110)   |
                                                                (cycle_cnt_q[5:0] == 6'b001000)   |
                                                                (cycle_cnt_q[5:0] == 6'b001010)   |
                                                                (cycle_cnt_q[5:0] == 6'b001100)   |
                                                                (cycle_cnt_q[5:0] == 6'b001110)   |
                                                                (cycle_cnt_q[5:0] == 6'b010000)   |
                                                                (cycle_cnt_q[5:0] == 6'b010010)   |
                                                                (cycle_cnt_q[5:0] == 6'b010100)   |
                                                                (cycle_cnt_q[5:0] == 6'b010110)   |
                                                                (cycle_cnt_q[5:0] == 6'b011000)   |
                                                                (cycle_cnt_q[5:0] == 6'b011010)   |
                                                                (cycle_cnt_q[5:0] == 6'b011011)   |
                                                                (cycle_cnt_q[5:0] == 6'b011101)   |
                                                                (cycle_cnt_q[5:0] == 6'b011111))) |
                               (x4_tx_mode &  PM_cycle_q[0] & ( (cycle_cnt_q[5:0] == 6'b000001)   |
                                                                (cycle_cnt_q[5:0] == 6'b000011)   |
                                                                (cycle_cnt_q[5:0] == 6'b000101)   |
                                                                (cycle_cnt_q[5:0] == 6'b000111)   |
                                                                (cycle_cnt_q[5:0] == 6'b001001)   |
                                                                (cycle_cnt_q[5:0] == 6'b001011)   |
                                                                (cycle_cnt_q[5:0] == 6'b001101)   |
                                                                (cycle_cnt_q[5:0] == 6'b001111)   |
                                                                (cycle_cnt_q[5:0] == 6'b010001)   |
                                                                (cycle_cnt_q[5:0] == 6'b010011)   |
                                                                (cycle_cnt_q[5:0] == 6'b010101)   |
                                                                (cycle_cnt_q[5:0] == 6'b010111)   |
                                                                (cycle_cnt_q[5:0] == 6'b011001)   |
                                                                (cycle_cnt_q[5:0] == 6'b011011)   |
                                                                (cycle_cnt_q[5:0] == 6'b011100)   |
                                                                (cycle_cnt_q[5:0] == 6'b011110)   |
                                                                (cycle_cnt_q[5:0] == 6'b100000))) |
                               (x2_tx_mode &  (PM_cycle_q[1:0] == 2'b01) & ~((cycle_cnt_q[5:0] == 6'b000000)  |
                                                                             (cycle_cnt_q[5:0] == 6'b000100)  |
                                                                             (cycle_cnt_q[5:0] == 6'b001000)  |
                                                                             (cycle_cnt_q[5:0] == 6'b001100)  |
                                                                             (cycle_cnt_q[5:0] == 6'b010000)  |
                                                                             (cycle_cnt_q[5:0] == 6'b010100)  |
                                                                             (cycle_cnt_q[5:0] == 6'b011000)  |
                                                                             (cycle_cnt_q[5:0] == 6'b011101))) |
                               (x2_tx_mode &  (PM_cycle_q[1:0] == 2'b10) & ~((cycle_cnt_q[5:0] == 6'b000001)  |
                                                                             (cycle_cnt_q[5:0] == 6'b000101)  |
                                                                             (cycle_cnt_q[5:0] == 6'b001001)  |
                                                                             (cycle_cnt_q[5:0] == 6'b001101)  |
                                                                             (cycle_cnt_q[5:0] == 6'b010001)  |
                                                                             (cycle_cnt_q[5:0] == 6'b010101)  |
                                                                             (cycle_cnt_q[5:0] == 6'b011001)  |
                                                                             (cycle_cnt_q[5:0] == 6'b011110))) |
                               (x2_tx_mode &  (PM_cycle_q[1:0] == 2'b11) & ~((cycle_cnt_q[5:0] == 6'b000010)  |
                                                                             (cycle_cnt_q[5:0] == 6'b000110)  |
                                                                             (cycle_cnt_q[5:0] == 6'b001010)  |
                                                                             (cycle_cnt_q[5:0] == 6'b001110)  |
                                                                             (cycle_cnt_q[5:0] == 6'b010010)  |
                                                                             (cycle_cnt_q[5:0] == 6'b010110)  |
                                                                             (cycle_cnt_q[5:0] == 6'b011010)  |
                                                                             (cycle_cnt_q[5:0] == 6'b011111))) |
                               (x2_tx_mode &  (PM_cycle_q[1:0] == 2'b00) & ~((cycle_cnt_q[5:0] == 6'b000011)  |
                                                                             (cycle_cnt_q[5:0] == 6'b000111)  |
                                                                             (cycle_cnt_q[5:0] == 6'b001011)  |
                                                                             (cycle_cnt_q[5:0] == 6'b001111)  |
                                                                             (cycle_cnt_q[5:0] == 6'b010011)  |
                                                                             (cycle_cnt_q[5:0] == 6'b010111)  |
                                                                             (cycle_cnt_q[5:0] == 6'b011100)  | //-- 7/19 
                                                                             (cycle_cnt_q[5:0] == 6'b100000)));

//-- Indicates when the start of a long pulse will happen.  (Aligns with flit's stall_d3_q)
assign real_stall_din          = (x8_tx_mode &                              (cycle_cnt_q[5:0] == 6'b01_1111)) |
                                 (x4_tx_mode & (PM_cycle_q[  0] == 1'b0 ) & (cycle_cnt_q[5:0] == 6'b01_1101)) |
                                 (x4_tx_mode & (PM_cycle_q[  0] == 1'b1 ) & (cycle_cnt_q[5:0] == 6'b01_1110)) |
                                 (x2_tx_mode & (PM_cycle_q[1:0] == 2'b00) & (cycle_cnt_q[5:0] == 6'b01_1011)) | //-- 7/19 
                                 (x2_tx_mode & (PM_cycle_q[1:0] == 2'b01) & (cycle_cnt_q[5:0] == 6'b01_1100)) |
                                 (x2_tx_mode & (PM_cycle_q[1:0] == 2'b10) & (cycle_cnt_q[5:0] == 6'b01_1101)) |
                                 (x2_tx_mode & (PM_cycle_q[1:0] == 2'b11) & (cycle_cnt_q[5:0] == 6'b01_1110));
assign trn_flt_real_stall      = real_stall_q;

//-- Cycle Count Stalls (decimal radix).  Cycle count 28 is 4 cycles prior to stall for the 64/66 encoding headers
//-- x8 stall(s) = 28
//-- x4 stall(s) = 1, 3, 5, 7, 9, 11, 13, 15, 17, 19, 21, 23, 25, 27, 28, 30, 32
//-- x2 stall(s) = 1, 2, 3, 5, 6,  7,  9, 10, 11, 13, 14, 15, 17, 18, 19, 21, 22, 23, 25, 26, 27, 28, 30, 31, 32 (data transferred on 0, 4, 8, 12, 16, 20, 24, 29)

//-- Keep signal '1' for 6 cycles at the start of a retrain to allow flit to reinitialize itself.  However, the rising edge should happen right at linkup.
assign x8_tx_mode               = ~(x2_tx_mode | x4_tx_mode);
assign trn_flt_x8_tx_mode       = ((frame_vld_q | (|start_retrain_dly_q[2:0])) & x8_tx_mode);
assign trn_flt_x4_tx_mode       = ((frame_vld_q | (|start_retrain_dly_q[2:0])) & x4_tx_mode);
assign trn_flt_x2_tx_mode       = ((frame_vld_q | (|start_retrain_dly_q[2:0])) & x2_tx_mode);

assign trn_agn_half_width              = cfg_omi_half_width_enable_q;
assign tx_rx_half_width                = cfg_omi_half_width_enable_q;
assign tx_rx_quarter_width             = cfg_omi_quarter_width_enable_q;

//-- Stop RX lanes from receiving if configured to run as a x4 only at startup.
assign cfg_rx_lanes_disable[7:0]       = (cfg_omi_supported_widths_q[3:0] == 4'h1) ? (8'h5A | cfg_rx_lanes_disable_q[7:0]) : cfg_rx_lanes_disable_q[7:0];
assign tx_rx_cfg_disable_rx_lanes[7:0] = cfg_rx_lanes_disable[7:0] | //-- Manually Disable Lanes to due Config1 register bits
                                         EDPL_bad_lane_q[7:0];       //-- Disable lanes due to EDPL threshold reached

assign x2_tx_outer_mode                 = (disabled_tx_lanes_q[7:0] == 8'h7E);
assign x2_tx_inner_mode                 = (disabled_tx_lanes_q[7:0] == 8'hDB);
assign x2_tx_mode                       =  x2_tx_outer_mode | x2_tx_inner_mode;
assign trn_agn_x2_mode[1:0]             = {x2_tx_outer_mode, x2_tx_inner_mode};

assign x4_tx_outer_mode                 = (disabled_tx_lanes_q[7:0] == 8'h5A);
assign x4_tx_inner_mode                 = (disabled_tx_lanes_q[7:0] == 8'hA5);
assign x4_tx_outer_mode_din             = x4_tx_outer_mode;
assign x4_tx_inner_mode_din             = x4_tx_inner_mode;
assign trn_agn_x4_mode[1:0]             = {x4_tx_outer_mode_q, x4_tx_inner_mode_q} & {2{~x2_tx_mode}}; //-- Delay 1 cycle to get PM to switch on right cycle, turn off a cycle early for  fail

assign x4_rx_outer_mode                 = (disabled_rx_lanes[7:0] == 8'h5A);
assign x4_rx_inner_mode                 = (disabled_rx_lanes[7:0] == 8'hA5);

//-- remote side is reporting that some lanes didn't train.  Therefore we are in x4 backoff mode using either the odd or even lanes.
assign x4_tx_mode                  = x4_tx_outer_mode | x4_tx_inner_mode;
assign x4_rx_mode                  = x4_rx_outer_mode | x4_rx_inner_mode;

//-- Entering a degraded mode on the initial train.  Power management is impossible
assign half_width_x4_outer_tx_mode_din = ((disabled_tx_lanes_q[7:0] == 8'h7E) & x4_tx_width[1] & (~init_train_done_q | retrained_in_degr_width_q)) | half_width_x4_outer_tx_mode_q;
assign half_width_x4_inner_tx_mode_din = ((disabled_tx_lanes_q[7:0] == 8'hDB) & x4_tx_width[1] & (~init_train_done_q | retrained_in_degr_width_q)) | half_width_x4_inner_tx_mode_q;
assign half_width_x8_outer_tx_mode_din = ((disabled_tx_lanes_q[7:0] == 8'h5A) & x8_tx_width[1] & (~init_train_done_q | retrained_in_degr_width_q)) | half_width_x8_outer_tx_mode_q;
assign half_width_x8_inner_tx_mode_din = ((disabled_tx_lanes_q[7:0] == 8'hA5) & x8_tx_width[1] & (~init_train_done_q | retrained_in_degr_width_q)) | half_width_x8_inner_tx_mode_q;

assign half_width_x4_tx_mode_din   = (x4_tx_width[1] & (~init_train_done_q | retrained_in_degr_width_q) ) | half_width_x4_tx_mode_q;
assign half_width_x8_tx_mode_din   = (x8_tx_width[1] & (~init_train_done_q | retrained_in_degr_width_q) ) | half_width_x8_tx_mode_q;
assign half_width_tx_mode_din[0]   = ((half_width_x4_tx_mode_q | half_width_x8_tx_mode_q) & (~init_train_done_q | retrained_in_degr_width_q) ) |  half_width_tx_mode_q[0];
assign half_width_tx_mode_din[1]   = ((half_width_x4_tx_mode_q | half_width_x8_tx_mode_q) & (~init_train_done_q | retrained_in_degr_width_q) ) & ~half_width_tx_mode_q[0]; //-- Pulse for rising edge

assign half_width_x4_outer_rx_mode_din = ((disabled_rx_lanes[7:0] == 8'h7E) & x4_rx_width[1] & (~init_train_done_q | retrained_in_degr_width_q)) | half_width_x4_outer_rx_mode_q;
assign half_width_x4_inner_rx_mode_din = ((disabled_rx_lanes[7:0] == 8'hDB) & x4_rx_width[1] & (~init_train_done_q | retrained_in_degr_width_q)) | half_width_x4_inner_rx_mode_q;
assign half_width_x8_outer_rx_mode_din = ((disabled_rx_lanes[7:0] == 8'h5A) & x8_rx_width[1] & (~init_train_done_q | retrained_in_degr_width_q)) | half_width_x8_outer_rx_mode_q;
assign half_width_x8_inner_rx_mode_din = ((disabled_rx_lanes[7:0] == 8'hA5) & x8_rx_width[1] & (~init_train_done_q | retrained_in_degr_width_q)) | half_width_x8_inner_rx_mode_q;

assign half_width_x4_rx_mode_din   = (x4_rx_width[1] & (~init_train_done_q | retrained_in_degr_width_q) ) | half_width_x4_rx_mode_q;
assign half_width_x8_rx_mode_din   = (x8_rx_width[1] & (~init_train_done_q | retrained_in_degr_width_q) ) | half_width_x8_rx_mode_q;
assign half_width_rx_mode_din[0]   = ((half_width_x4_rx_mode_q | half_width_x8_rx_mode_q) & (~init_train_done_q | retrained_in_degr_width_q) ) |  half_width_rx_mode_q[0];
assign half_width_rx_mode_din[1]   = ((half_width_x4_rx_mode_q | half_width_x8_rx_mode_q) & (~init_train_done_q | retrained_in_degr_width_q) ) & ~half_width_rx_mode_q[0]; //-- Pulse for rising edge

assign full_width_x8_rx_mode_din   = (x8_rx_width[2] & ~init_train_done_q) | full_width_x8_rx_mode_q;
assign full_width_x8_tx_mode_din   = (x8_tx_width[2] & ~init_train_done_q) | full_width_x8_tx_mode_q;
assign full_width_x4_rx_mode_din   = (x4_rx_width[2] & ~init_train_done_q) | full_width_x4_rx_mode_q;
assign full_width_x4_tx_mode_din   = (x4_tx_width[2] & ~init_train_done_q) | full_width_x4_tx_mode_q;



assign remote_ts_valid             = rx_tx_ts_valid;
assign remote_ts_good_lanes[15:0]  = rx_tx_ts_good_lanes[15:0];
assign remote_deskew_cfg_vld       = rx_tx_deskew_config_valid;
assign remote_deskew_cfg[18:0]     = rx_tx_deskew_config[18:0];

assign frame_vld_din                             = (train_done_q | frame_vld_q) & ~start_retrain;
//-- Single cycle pulse, indicating the transmission of flits should begin.  If manual training is enabled, make sure pulse can only happen once.
assign train_done_din                            = ((cfg_omi_train_mode_q[3  ] == 1'b1   ) & (tsm_q[2:0] == 3'b110) & (rx_ts3_q | rx_data_sync_hdr_q) & ( x8_tx_mode               & cycle_cnt_q[5:0] == 6'b011111)) | //-- automatic training advance (x8)
                                                   ((cfg_omi_train_mode_q[3  ] == 1'b1   ) & (tsm_q[2:0] == 3'b110) & (rx_ts3_q | rx_data_sync_hdr_q) & ((x4_tx_mode | x2_tx_mode) & cycle_cnt_q[5:0] == 6'b011110)) | //-- automatic training advance (x4/x2)
                                                   ((cfg_omi_train_mode_q[3:0] == 4'b0111) & (tsm_q[2:0] != 3'b111) &                                   ( x8_tx_mode               & cycle_cnt_q[5:0] == 6'b011111)) | //-- manual    training advance (x8)
                                                   ((cfg_omi_train_mode_q[3:0] == 4'b0111) & (tsm_q[2:0] != 3'b111) &                                   ((x4_tx_mode | x2_tx_mode) & cycle_cnt_q[5:0] == 6'b011110));  //-- manual    training advance (x4/x2)

assign trn_flt_train_done                        = train_done_q;
assign train_done_dly_din                        = train_done_q;

//-- Need to transmit last flit data before going into a retrain
assign trn_agn_train_done                        = frame_vld_q | start_retrain | start_retrain_dly_q[0];

assign trn_flt_tsm4                              = tsm4_dly_q[3];
assign tsm4_dly_din[3:1]                         = tsm4_dly_q[2:0];
assign tsm4_dly_din[0]                           = (tsm_q[2:0] == 3'b100);

assign link_down_din              = fatal_errors | link_down_q; //-- Keep link down until a reset is issued
assign cfg_omi_retrain_dly_din    = cfg_omi_retrain_q;
assign software_retrain_din       = cfg_omi_retrain_q & ~cfg_omi_retrain_dly_q; //-- rising edge of cfg_omi_retrain_q

//-- Need to keep on a couple cycles after fwd_prog_fired_q fires to allow the latch to reset itself
assign act_fwd_prog_timer         = cfg_omi_enable_q &   (((cfg_no_fwd_prog_timer_rate_q[3:0] != 4'b1111) & (frame_vld_q | start_retrain)) | ~reset);
assign fwd_prog_rate[13:0]        = ({2'b00,12'h002} & {14{(cfg_no_fwd_prog_timer_rate_q[3:0] == 4'b0000)}}) |  //--   2 us
                                    ({2'b00,12'h003} & {14{(cfg_no_fwd_prog_timer_rate_q[3:0] == 4'b0001)}}) |  //--   3 us
                                    ({2'b00,12'h004} & {14{(cfg_no_fwd_prog_timer_rate_q[3:0] == 4'b0010)}}) |  //--   4 us 
                                    ({2'b00,12'h008} & {14{(cfg_no_fwd_prog_timer_rate_q[3:0] == 4'b0011)}}) |  //--   8 us
                                    ({2'b00,12'h010} & {14{(cfg_no_fwd_prog_timer_rate_q[3:0] == 4'b0100)}}) |  //--  16 us
                                    ({2'b00,12'h020} & {14{(cfg_no_fwd_prog_timer_rate_q[3:0] == 4'b0101)}}) |  //--  32 us
                                    ({2'b00,12'h040} & {14{(cfg_no_fwd_prog_timer_rate_q[3:0] == 4'b0110)}}) |  //--  64 us
                                    ({2'b00,12'h080} & {14{(cfg_no_fwd_prog_timer_rate_q[3:0] == 4'b0111)}}) |  //-- 128 us
                                    ({2'b00,12'h100} & {14{(cfg_no_fwd_prog_timer_rate_q[3:0] == 4'b1000)}}) |  //-- 256 us
                                    ({2'b00,12'h200} & {14{(cfg_no_fwd_prog_timer_rate_q[3:0] == 4'b1001)}}) |  //-- 512 us
                                    ({2'b00,12'h3E8} & {14{(cfg_no_fwd_prog_timer_rate_q[3:0] == 4'b1010)}}) |  //--   1 ms
                                    ({2'b00,12'h7D0} & {14{(cfg_no_fwd_prog_timer_rate_q[3:0] == 4'b1011)}}) |  //--   2 ms
                                    ({2'b00,12'hFA0} & {14{(cfg_no_fwd_prog_timer_rate_q[3:0] == 4'b1100)}}) |  //--   4 ms
                                    ({2'b01,12'hF40} & {14{(cfg_no_fwd_prog_timer_rate_q[3:0] == 4'b1101)}}) |  //--   8 ms
                                    ({2'b11,12'hE80} & {14{(cfg_no_fwd_prog_timer_rate_q[3:0] == 4'b1110)}}) |  //--  16 ms
                                    ({2'b11,12'hFFF} & {14{(cfg_no_fwd_prog_timer_rate_q[3:0] == 4'b1111)}});   //--  Disabled

//-- flt_trn_no_fwd_prog arrives as a tick instead of always '1'
assign fwd_prog_fired_din         = (fwd_prog_timer_q[13:0] == fwd_prog_rate[13:0]) & ~fwd_prog_fired_q;
assign fwd_prog_timer_reset       = fwd_prog_fired_q | start_retrain | (reg_dl_1us_tick_q & ~flt_trn_no_fwd_prog);
assign fwd_prog_timer_inc         = reg_dl_1us_tick_q & frame_vld_q & flt_trn_no_fwd_prog;
assign fwd_prog_timer_din[13:0]   = fwd_prog_timer_reset ? {12'h000, 2'b00} : 
                                    fwd_prog_timer_inc   ? fwd_prog_timer_q[13:0] + {12'h000, 2'b01} :
                                                           fwd_prog_timer_q[13:0];

//-- train timeout value needs to be greater than the time it takes to decide if a lanes is dead (16 us).
//-- Therefore, the link should be able to train in 24-16 = 8 us after the decision to kill lane(s) is made
assign trn_timeout_val[5:0]       = {6'b01_1000}; //-- 24 us before turning on all lanes and starting a retrain

//-- trn_timeout can repeatedly fire
assign trn_timeout_fired          = (trn_timeout_timer_q[5:0] == trn_timeout_val[5:0]) & ~trn_timeout_fired_q;
//-- 10/15assign trn_timeout_fired          = (trn_timeout_timer_q[5:0] == trn_timeout_val[5:0]) & ~trn_timeout_fired_q & ~trn_timeout_has_fired_q;
assign trn_timeout_fired_din      = trn_timeout_fired;
assign trn_timeout_has_fired_din  = trn_timeout_fired | (trn_timeout_has_fired_q & ~train_done_q);
assign trn_timeout_fired_twice    = trn_timeout_has_fired_q & trn_timeout_fired_q;
assign retrain_due2_trn_timeout   = end_of_start_retrain & trn_timeout_has_fired_q;

//-- 8/1assign trn_timeout_timer_reset    = start_retrain | trn_timeout_fired_q | train_done_q;
assign trn_timeout_timer_reset    = trn_timeout_fired_q | train_done_q;
assign trn_timeout_timer_inc      = reg_dl_1us_tick_q & retrain_ip_q;
//-- 10/15assign trn_timeout_timer_inc      = reg_dl_1us_tick_q & retrain_ip_q & ~trn_timeout_has_fired_q;

assign trn_timeout_timer_din[5:0] = trn_timeout_timer_reset ? 6'b000000 :
                                    trn_timeout_timer_inc   ? trn_timeout_timer_q[5:0] + 6'b000001 :
                                                              trn_timeout_timer_q[5:0];

//-- report error only when EDPL is disabled, since headers can be either '00', '01', or '11'
//-- if header is '10' it must be a control header
assign lost_data_sync_din            = rx_tx_lost_data_sync & ~cfg_EDPL_ena_q;
assign unexpected_lost_data_sync     = lost_data_sync_q & ~PM_caused_retrain;
assign remote_retrain_din            = rx_tx_training_sync_hdr;
assign unexpected_remote_retrain     = remote_retrain_q & ~PM_caused_retrain;

assign tx_rx_start_retrain           = start_retrain_dly_q[0]; //-- Delay one cycle for timing
assign start_retrain                 = start_retrain_pend_q[3];
assign start_retrain_dly_din[2:0]    = {start_retrain_dly_q[1:0], start_retrain};
assign end_of_start_retrain          = (start_retrain_dly_q[2] & ~start_retrain_dly_q[1]);
assign start_retrain_pend_din[3:1]   = start_retrain_pend_q[2:0];
assign start_retrain_pend_din[0]     = ( ( ((tsm_q[2:0] == 3'b101) | (tsm_q[2:0] == 3'b110) | (tsm_q[2:0] == 3'b111)) &  
                                           ((~block_locked_q      )              |      //--Lost block alignment
                                            (~deskew_done         )              |      //--Lost deskew alignment or deskew overflow
                                            (software_retrain_q   )              |      //--scom write initiated
                                            (fwd_prog_fired_q     )              |      //--no forward progress
                                            (start_retrain_flt    )) )              |   //--flit decided to start a retrain
                                         ( (tsm_q[2:1] == 2'b11  ) &                    //--In states 6 or 7,for the below 5 cases
                                           ((lost_data_sync_q      )              |     //--Lost data sync headers for 6 consecutive cycles
                                            (PM_start_retrain_pulse)              |     //--Power management moving up in width
                                            (EDPL_thres_reached_q  )              |     //--EDPL Error Threshold reached on any lane
                                            (rx_ts1_q              )              |     //--ts1 received while in states 6 or 7 
                                            (remote_retrain_q      )) )           |     //--Lost data sync headers for 6 consecutive cycles
                                         ( trn_timeout_fired_q )               |        //--**Special case which will only hapen in states 4-6**
                                      (start_retrain_pend_q[0])    ) & ~start_retrain;  //--hold pending until retrain has been launched
assign start_retrain_cond[10:0]      = {((tsm_q[2:0] == 3'b101) | (tsm_q[2:0] == 3'b110) | (tsm_q[2:0] == 3'b111)) & ~block_locked_q,        //--bit: 10
                                        ((tsm_q[2:0] == 3'b101) | (tsm_q[2:0] == 3'b110) | (tsm_q[2:0] == 3'b111)) & ~deskew_done,           //--bit:  9
                                        ((tsm_q[2:0] == 3'b101) | (tsm_q[2:0] == 3'b110) | (tsm_q[2:0] == 3'b111)) & software_retrain_q,     //--bit:  8
                                        ((tsm_q[2:0] == 3'b101) | (tsm_q[2:0] == 3'b110) | (tsm_q[2:0] == 3'b111)) & fwd_prog_fired_q,       //--bit:  7
                                        ((tsm_q[2:0] == 3'b101) | (tsm_q[2:0] == 3'b110) | (tsm_q[2:0] == 3'b111)) & start_retrain_flt,      //--bit:  6
                                        (tsm_q[2:1] == 2'b11  )                                                    & lost_data_sync_q,       //--bit:  5
                                        (tsm_q[2:1] == 2'b11  )                                                    & PM_start_retrain_pulse, //--bit:  4
                                        (tsm_q[2:1] == 2'b11  )                                                    & EDPL_thres_reached_q,   //--bit:  3
                                        (tsm_q[2:1] == 2'b11  )                                                    & rx_ts1_q,               //--bit:  2
                                        (tsm_q[2:1] == 2'b11  )                                                    & remote_retrain_q,       //--bit:  1
                                                                                                                     trn_timeout_fired_q};   //--bit:  0


assign reset = global_reset_control ? cfg_omi_reset_q : ~chip_reset; 

//-- sim only flipflop
dlc_ff       #(.width(  3) ,.rstv({  3{1'b0}})) ff_sim_only_fast_train          (.clk(dl_clk      )  ,.reset_n(reset)  ,.enable(omi_enable )  ,.din(sim_only_fast_train_din           )  ,.q(sim_only_fast_train_q           ) );

//-- normal flipflops 
dlc_ff       #(.width( 14) ,.rstv({ 14{1'b0}})) ff_fwd_prog_timer                  (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(act_fwd_prog_timer)  ,.din(fwd_prog_timer_din                )  ,.q(fwd_prog_timer_q                ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_fwd_prog_fired                  (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(act_fwd_prog_timer)  ,.din(fwd_prog_fired_din                )  ,.q(fwd_prog_fired_q                ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b1}})) ff_cfg_omi_reset                   (.clk(dl_clk)  ,.reset_n(1'b1 )  ,.enable(omi_enable        )  ,.din(cfg_omi_reset_din                 )  ,.q(cfg_omi_reset_q                 ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b1}})) ff_cfg_omi_enable                  (.clk(dl_clk)  ,.reset_n(1'b1 )  ,.enable(act_omi_enable    )  ,.din(cfg_omi_enable_din                )  ,.q(cfg_omi_enable_q                ) );
dlc_ff       #(.width( 88) ,.rstv({ 88{1'b0}})) ff_debug_dbg                       (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(act_dbg           )  ,.din(debug_dbg_din                     )  ,.q(debug_dbg_q                     ) );

dlc_ff       #(.width( 32) ,.rstv({ 32{1'b0}})) ff_cfg_cya_bits                    (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(cfg_cya_bits_ena_din                )  ,.q(cfg_cya_bits_q                    ) );
dlc_ff       #(.width(  2) ,.rstv({  2{1'b0}})) ff_cfg_tx_degraded_threshold       (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(cfg_tx_degraded_threshold_din       )  ,.q(cfg_tx_degraded_threshold_q       ) );
dlc_ff       #(.width(  2) ,.rstv({  2{1'b0}})) ff_cfg_rx_degraded_threshold       (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(cfg_rx_degraded_threshold_din       )  ,.q(cfg_rx_degraded_threshold_q       ) );
dlc_ff       #(.width(  8) ,.rstv({  8{1'b0}})) ff_cfg_tx_lanes_disable            (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(cfg_tx_lanes_disable_din            )  ,.q(cfg_tx_lanes_disable_q            ) );
dlc_ff       #(.width(  8) ,.rstv({  8{1'b0}})) ff_cfg_rx_lanes_disable            (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(cfg_rx_lanes_disable_din            )  ,.q(cfg_rx_lanes_disable_q            ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_cfg_BEI_ln_dir                  (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(cfg_BEI_ln_dir_din                  )  ,.q(cfg_BEI_ln_dir_q                  ) );
dlc_ff       #(.width(  3) ,.rstv({  3{1'b0}})) ff_cfg_BEI_ln_rate                 (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(cfg_BEI_ln_rate_din                 )  ,.q(cfg_BEI_ln_rate_q                 ) );
dlc_ff       #(.width(  3) ,.rstv({  3{1'b0}})) ff_cfg_BEI_ln_sel                  (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(cfg_BEI_ln_sel_din                  )  ,.q(cfg_BEI_ln_sel_q                  ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_cfg_BEI_ln_ena                  (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(cfg_BEI_ln_ena_din                  )  ,.q(cfg_BEI_ln_ena_q                  ) );
dlc_ff       #(.width(  4) ,.rstv({  4{1'b0}})) ff_cfg_EDPL_time_window            (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(cfg_EDPL_time_window_din            )  ,.q(cfg_EDPL_time_window_q            ) );
dlc_ff       #(.width(  3) ,.rstv({  3{1'b0}})) ff_cfg_EDPL_err_threshold          (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(cfg_EDPL_err_threshold_din          )  ,.q(cfg_EDPL_err_threshold_q          ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_cfg_EDPL_ena                    (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(cfg_EDPL_ena_din                    )  ,.q(cfg_EDPL_ena_q                    ) );
dlc_ff       #(.width( 23) ,.rstv({ 23{1'b0}})) ff_rx_deg_thres_cntr               (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(rx_deg_thres_cntr_din               )  ,.q(rx_deg_thres_cntr_q               ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_rx_deg_thres_hit_q              (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(rx_deg_thres_hit_din                )  ,.q(rx_deg_thres_hit_q                ) );
dlc_ff       #(.width( 23) ,.rstv({ 23{1'b0}})) ff_tx_deg_thres_cntr               (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(tx_deg_thres_cntr_din               )  ,.q(tx_deg_thres_cntr_q               ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_tx_deg_thres_hit_q              (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(tx_deg_thres_hit_din                )  ,.q(tx_deg_thres_hit_q                ) );
dlc_ff       #(.width(  8) ,.rstv({  8{1'b0}})) ff_disabled_tx_lanes               (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(disabled_tx_lanes_din               )  ,.q(disabled_tx_lanes_q               ) );
dlc_ff       #(.width( 44) ,.rstv({ 44{1'b0}})) ff_EDPL_timer                      (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(EDPL_timer_din                      )  ,.q(EDPL_timer_q                      ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_EDPL_reset_cnts                 (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(EDPL_reset_cnts_din                 )  ,.q(EDPL_reset_cnts_q                 ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_BEI_inject                      (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(BEI_inject_din                      )  ,.q(BEI_inject_q                      ) );
dlc_ff       #(.width( 21) ,.rstv({ 21{1'b0}})) ff_BEI_timer                       (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(BEI_timer_din                       )  ,.q(BEI_timer_q                       ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_cfg_omi_retrain                 (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(cfg_omi_retrain_din                 )  ,.q(cfg_omi_retrain_q                 ) );
dlc_ff       #(.width(  6) ,.rstv({  6{1'b0}})) ff_cfg_omi_version                 (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(cfg_omi_version_din                 )  ,.q(cfg_omi_version_q                 ) );
dlc_ff       #(.width(  4) ,.rstv({  4{1'b0}})) ff_cfg_omi_train_mode              (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(cfg_omi_train_mode_din              )  ,.q(cfg_omi_train_mode_q              ) );
dlc_ff       #(.width(  4) ,.rstv({  4{1'b0}})) ff_cfg_omi_supported_widths        (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(cfg_omi_supported_widths_din        )  ,.q(cfg_omi_supported_widths_q        ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_cfg_omi_half_width_enable       (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(cfg_omi_half_width_enable_din       )  ,.q(cfg_omi_half_width_enable_q       ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_cfg_omi_quarter_width_enable    (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(cfg_omi_quarter_width_enable_din    )  ,.q(cfg_omi_quarter_width_enable_q    ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_cfg_omi_PM_enable               (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(cfg_omi_PM_enable_din               )  ,.q(cfg_omi_PM_enable_q               ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_cfg_omi_run_lane_override       (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(cfg_omi_run_lane_override_din       )  ,.q(cfg_omi_run_lane_override_q       ) );
dlc_ff       #(.width(  4) ,.rstv({  4{1'b0}})) ff_cfg_omi_phy_cntr_limit          (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(cfg_omi_phy_cntr_limit_din          )  ,.q(cfg_omi_phy_cntr_limit_q          ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_cfg_omi_128_130_en              (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(cfg_omi_128_130_en_din              )  ,.q(cfg_omi_128_130_en_q              ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_cfg_inj_ecc_ue                  (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(cfg_inj_ecc_ue_din                  )  ,.q(cfg_inj_ecc_ue_q                  ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_cfg_inj_ecc_ce                  (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(cfg_inj_ecc_ce_din                  )  ,.q(cfg_inj_ecc_ce_q                  ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_cfg_inj_ctl_pty                 (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(cfg_inj_ctl_pty_din                 )  ,.q(cfg_inj_ctl_pty_q                 ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_cfg_inj_data_pty                (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(cfg_inj_data_pty_din                )  ,.q(cfg_inj_data_pty_q                ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_cfg_tl_event_all_freeze         (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(cfg_tl_event_all_freeze_din         )  ,.q(cfg_tl_event_all_freeze_q         ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_cfg_tl_event_afu_freeze         (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(cfg_tl_event_afu_freeze_din         )  ,.q(cfg_tl_event_afu_freeze_q         ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_cfg_tl_event_ila_trigger        (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(cfg_tl_event_ila_trigger_din        )  ,.q(cfg_tl_event_ila_trigger_q        ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_cfg_tl_event_link_down          (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(cfg_tl_event_link_down_din          )  ,.q(cfg_tl_event_link_down_q          ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_cfg_tl_error_all_freeze         (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(cfg_tl_error_all_freeze_din         )  ,.q(cfg_tl_error_all_freeze_q         ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_cfg_tl_error_afu_freeze         (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(cfg_tl_error_afu_freeze_din         )  ,.q(cfg_tl_error_afu_freeze_q         ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_cfg_tl_error_ila_trigger        (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(cfg_tl_error_ila_trigger_din        )  ,.q(cfg_tl_error_ila_trigger_q        ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_cfg_tl_error_link_down          (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(cfg_tl_error_link_down_din          )  ,.q(cfg_tl_error_link_down_q          ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_cfg_debug_ena                   (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(cfg_debug_ena_din                   )  ,.q(cfg_debug_ena_q                   ) );
dlc_ff       #(.width(  3) ,.rstv({  3{1'b0}})) ff_cfg_debug_sel                   (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(cfg_debug_sel_din                   )  ,.q(cfg_debug_sel_q                   ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_link_down                       (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(link_down_din                       )  ,.q(link_down_q                       ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_train_state_parity              (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(train_state_parity_din              )  ,.q(train_state_parity_q              ) );
dlc_ff       #(.width(  6) ,.rstv({  6{1'b0}})) ff_cycle_cnt                       (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(cycle_cnt_din                       )  ,.q(cycle_cnt_q                       ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_phy_training                    (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(phy_training_din                    )  ,.q(phy_training_q                    ) );
dlc_ff       #(.width(  5) ,.rstv({  5{1'b0}})) ff_insert_deskew_ts_cnt            (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(insert_deskew_ts_cnt_din            )  ,.q(insert_deskew_ts_cnt_q            ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_ts_x2_inner                     (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(ts_x2_inner_din                     )  ,.q(ts_x2_inner_q                     ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_ts_x2_outer                     (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(ts_x2_outer_din                     )  ,.q(ts_x2_outer_q                     ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_ts_x4_outer                     (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(ts_x4_outer_din                     )  ,.q(ts_x4_outer_q                     ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_ts_x4_inner                     (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(ts_x4_inner_din                     )  ,.q(ts_x4_inner_q                     ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_rx_pattern_a                    (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(rx_pattern_a_din                    )  ,.q(rx_pattern_a_q                    ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_rx_pattern_b                    (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(rx_pattern_b_din                    )  ,.q(rx_pattern_b_q                    ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_rx_no_pattern                   (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(rx_no_pattern_din                   )  ,.q(rx_no_pattern_q                   ) );
dlc_ff       #(.width(  2) ,.rstv({  2{1'b0}})) ff_current_state                   (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(current_state_din                   )  ,.q(current_state_q                   ) );
dlc_ff       #(.width( 16) ,.rstv({ 16{1'b0}})) ff_phy_count                       (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(phy_count_din                       )  ,.q(phy_count_q                       ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_run_lane7                       (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(run_lane7_din                       )  ,.q(run_lane7_q                       ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_run_lane6                       (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(run_lane6_din                       )  ,.q(run_lane6_q                       ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_run_lane5                       (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(run_lane5_din                       )  ,.q(run_lane5_q                       ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_run_lane4                       (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(run_lane4_din                       )  ,.q(run_lane4_q                       ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_run_lane3                       (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(run_lane3_din                       )  ,.q(run_lane3_q                       ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_run_lane2                       (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(run_lane2_din                       )  ,.q(run_lane2_q                       ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_run_lane1                       (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(run_lane1_din                       )  ,.q(run_lane1_q                       ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_run_lane0                       (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(run_lane0_din                       )  ,.q(run_lane0_q                       ) );
dlc_ff       #(.width(  8) ,.rstv({  8{1'b0}})) ff_phy_dl_init_done                (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(phy_dl_init_done_din                )  ,.q(phy_dl_init_done_q                ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_rx_ts1                          (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(rx_ts1_din                          )  ,.q(rx_ts1_q                          ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_block_locked                    (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(block_locked_din                    )  ,.q(block_locked_q                    ) );
dlc_ff       #(.width(  8) ,.rstv({  8{1'b0}})) ff_rx_trained_lanes                (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(rx_trained_lanes_din                )  ,.q(rx_trained_lanes_q                ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_rx_ts2                          (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(rx_ts2_din                          )  ,.q(rx_ts2_q                          ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_rx_ts3                          (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(rx_ts3_din                          )  ,.q(rx_ts3_q                          ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_rx_data_sync_hdr                (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(rx_data_sync_hdr_din                )  ,.q(rx_data_sync_hdr_q                ) );
dlc_ff       #(.width( 23) ,.rstv({ 23{1'b0}})) ff_lfsr                            (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(lfsr_din                            )  ,.q(lfsr_q                            ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_frame_vld                       (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(frame_vld_din                       )  ,.q(frame_vld_q                       ) );
dlc_ff       #(.width(  2) ,.rstv({  2{1'b0}})) ff_tx_lane_swap                    (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(tx_lane_swap_din                    )  ,.q(tx_lane_swap_q                    ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_train_done                      (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(train_done_din                      )  ,.q(train_done_q                      ) );
dlc_ff       #(.width(  3) ,.rstv({  3{1'b0}})) ff_tsm                             (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(tsm_din                             )  ,.q(tsm_q                             ) );
dlc_ff       #(.width(  8) ,.rstv({  8{1'b0}})) ff_ln_pattern_a                    (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(ln_pattern_a_din                    )  ,.q(ln_pattern_a_q                    ) );
dlc_ff       #(.width(  8) ,.rstv({  8{1'b0}})) ff_ln_pattern_b                    (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(ln_pattern_b_din                    )  ,.q(ln_pattern_b_q                    ) );
dlc_ff       #(.width(  8) ,.rstv({  8{1'b0}})) ff_ln_sync                         (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(ln_sync_din                         )  ,.q(ln_sync_q                         ) );
dlc_ff       #(.width(  8) ,.rstv({  8{1'b0}})) ff_ln_TS1                          (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(ln_TS1_din                          )  ,.q(ln_TS1_q                          ) );
dlc_ff       #(.width(  8) ,.rstv({  8{1'b0}})) ff_ln_TS2                          (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(ln_TS2_din                          )  ,.q(ln_TS2_q                          ) );
dlc_ff       #(.width(  8) ,.rstv({  8{1'b0}})) ff_ln_TS3                          (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(ln_TS3_din                          )  ,.q(ln_TS3_q                          ) );
dlc_ff       #(.width(  8) ,.rstv({  8{1'b0}})) ff_ln_block_lock                   (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(ln_block_lock_din                   )  ,.q(ln_block_lock_q                   ) );
dlc_ff       #(.width(  8) ,.rstv({  8{1'b0}})) ff_ln_data_sync_hdr                (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(ln_data_sync_hdr_din                )  ,.q(ln_data_sync_hdr_q                ) );
dlc_ff       #(.width(  8) ,.rstv({  8{1'b0}})) ff_ln_ctl_sync_hdr                 (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(ln_ctl_sync_hdr_din                 )  ,.q(ln_ctl_sync_hdr_q                 ) );
dlc_ff       #(.width(  9) ,.rstv({  9{1'b0}})) ff_phy_training_d0                 (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(phy_training_d0_din                 )  ,.q(phy_training_d0_q                 ) );
dlc_ff       #(.width( 16) ,.rstv({ 16{1'b0}})) ff_train_data                      (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(train_data_din                      )  ,.q(train_data_q                      ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_cfg_disable_fast_path           (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(cfg_disable_fast_path_din           )  ,.q(cfg_disable_fast_path_q           ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_request_lane_reverse            (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(request_lane_reverse_din            )  ,.q(request_lane_reverse_q            ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_cfg_inj_ecc_ce_dly              (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(cfg_inj_ecc_ce_dly_din              )  ,.q(cfg_inj_ecc_ce_dly_q              ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_cfg_inj_ecc_ue_dly              (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(cfg_inj_ecc_ue_dly_din              )  ,.q(cfg_inj_ecc_ue_dly_q              ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_cfg_inj_ctl_pty_dly             (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(cfg_inj_ctl_pty_dly_din             )  ,.q(cfg_inj_ctl_pty_dly_q             ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_cfg_inj_data_pty_dly            (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(cfg_inj_data_pty_dly_din            )  ,.q(cfg_inj_data_pty_dly_q            ) );
dlc_ff       #(.width( 63) ,.rstv({ 63{1'b0}})) ff_error_capture                   (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(error_capture_din                   )  ,.q(error_capture_q                   ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_err_locked                      (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(err_locked_din                      )  ,.q(err_locked_q                      ) );
dlc_ff       #(.width(  6) ,.rstv({  6{1'b0}})) ff_first_error                     (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(first_error_din                     )  ,.q(first_error_q                     ) );
dlc_ff       #(.width(  4) ,.rstv({  4{1'b0}})) ff_cfg_no_fwd_prog_timer_rate      (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(cfg_no_fwd_prog_timer_rate_din      )  ,.q(cfg_no_fwd_prog_timer_rate_q      ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_inj_ecc_ce                      (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(inj_ecc_ce_din                      )  ,.q(inj_ecc_ce_q                      ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_inj_ecc_ue                      (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(inj_ecc_ue_din                      )  ,.q(inj_ecc_ue_q                      ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_inj_ctl_pty_err                 (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(inj_ctl_pty_err_din                 )  ,.q(inj_ctl_pty_err_q                 ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_inj_data_pty_err                (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(inj_data_pty_err_din                )  ,.q(inj_data_pty_err_q                ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_tx_EDPL_ena                     (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(tx_EDPL_ena_din                     )  ,.q(tx_EDPL_ena_q                     ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_lost_block_lock                 (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(lost_block_lock_din                 )  ,.q(lost_block_lock_q                 ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_cfg_omi_retrain_dly             (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(cfg_omi_retrain_dly_din             )  ,.q(cfg_omi_retrain_dly_q             ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_software_retrain                (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(software_retrain_din                )  ,.q(software_retrain_q                ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_lost_data_sync                  (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(lost_data_sync_din                  )  ,.q(lost_data_sync_q                  ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_remote_retrain                  (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(remote_retrain_din                  )  ,.q(remote_retrain_q                  ) );
dlc_ff       #(.width(  4) ,.rstv({  4{1'b0}})) ff_start_retrain_pend              (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(start_retrain_pend_din              )  ,.q(start_retrain_pend_q              ) );
dlc_ff       #(.width(  2) ,.rstv({  2{1'b0}})) ff_x4_tx_mode                      (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(half_width_tx_mode_din              )  ,.q(half_width_tx_mode_q              ) );
dlc_ff       #(.width(  2) ,.rstv({  2{1'b0}})) ff_x4_rx_mode                      (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(half_width_rx_mode_din              )  ,.q(half_width_rx_mode_q              ) );
dlc_ff       #(.width(  2) ,.rstv({  2{1'b0}})) ff_PM_cycle                        (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(PM_cycle_din                        )  ,.q(PM_cycle_q                        ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_ctl_parity_error                (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(ctl_parity_error_din                )  ,.q(ctl_parity_error_q                ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_EDPL_thres_reached              (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(EDPL_thres_reached_din              )  ,.q(EDPL_thres_reached_q              ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_flt_trn_data_pty_err            (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(flt_trn_data_pty_err_din            )  ,.q(flt_trn_data_pty_err_q            ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_flt_trn_tl_trunc                (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(flt_trn_tl_trunc_din                )  ,.q(flt_trn_tl_trunc_q                ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_flt_trn_tl_rl_err               (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(flt_trn_tl_rl_err_din               )  ,.q(flt_trn_tl_rl_err_q               ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_flt_trn_ack_ptr_err             (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(flt_trn_ack_ptr_err_din             )  ,.q(flt_trn_ack_ptr_err_q             ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_flt_trn_ue_rpb_cf               (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(flt_trn_ue_rpb_cf_din               )  ,.q(flt_trn_ue_rpb_cf_q               ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_flt_trn_ue_frb_cf               (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(flt_trn_ue_frb_cf_din               )  ,.q(flt_trn_ue_frb_cf_q               ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_flt_trn_ce_rpb                  (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(flt_trn_ce_rpb_din                  )  ,.q(flt_trn_ce_rpb_q                  ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_flt_trn_ce_frb                  (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(flt_trn_ce_frb_din                  )  ,.q(flt_trn_ce_frb_q                  ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_flt_trn_ue_rpb_df               (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(flt_trn_ue_rpb_df_din               )  ,.q(flt_trn_ue_rpb_df_q               ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_flt_trn_ue_frb_df               (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(flt_trn_ue_frb_df_din               )  ,.q(flt_trn_ue_frb_df_q               ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_cfg_sync_mode                   (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(cfg_sync_mode_din                   )  ,.q(cfg_sync_mode_q                   ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_reg_dl_1us_tick                 (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(reg_dl_1us_tick_din                 )  ,.q(reg_dl_1us_tick_q                 ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_reg_dl_100ms_tick               (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(reg_dl_100ms_tick_din               )  ,.q(reg_dl_100ms_tick_q               ) );
dlc_ff       #(.width(  4) ,.rstv({  4{1'b0}})) ff_cfg_rpb_rm_depth                (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(cfg_rpb_rm_depth_din                )  ,.q(cfg_rpb_rm_depth_q                ) );
dlc_ff       #(.width( 11) ,.rstv({ 11{1'b0}})) ff_cfg_unused                      (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(cfg_unused_din                      )  ,.q(cfg_unused_q                      ) );
dlc_ff       #(.width( 12) ,.rstv({ 12{1'b0}})) ff_perf_mon                        (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(perf_mon_din                        )  ,.q(perf_mon_q                        ) );
dlc_ff       #(.width(  4) ,.rstv({  4{1'b0}})) ff_errors_unused                   (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(errors_unused_din                   )  ,.q(errors_unused_q                   ) );
dlc_ff       #(.width( 11) ,.rstv({ 11{1'b0}})) ff_status_unused                   (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(status_unused_din                   )  ,.q(status_unused_q                   ) );
dlc_ff       #(.width(  3) ,.rstv({  3{1'b0}})) ff_start_retrain_dly               (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(start_retrain_dly_din               )  ,.q(start_retrain_dly_q               ) );
dlc_ff       #(.width(  8) ,.rstv({  8{1'b0}})) ff_EDPL_kill_lane_pend             (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(EDPL_kill_lane_pend_din             )  ,.q(EDPL_kill_lane_pend_q             ) );
dlc_ff       #(.width(  8) ,.rstv({  8{1'b0}})) ff_EDPL_bad_lane                   (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(EDPL_bad_lane_din                   )  ,.q(EDPL_bad_lane_q                   ) );
dlc_ff       #(.width(  4) ,.rstv({  4{1'b0}})) ff_tsm4_dly                        (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(tsm4_dly_din                        )  ,.q(tsm4_dly_q                        ) );
dlc_ff_spare #(.width(  1) ,.rstv({  1{1'b0}})) ff_spare_00                        (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(spare_00_din                        )  ,.q(spare_00_q                        ) );
dlc_ff_spare #(.width(  1) ,.rstv({  1{1'b0}})) ff_spare_01                        (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(spare_01_din                        )  ,.q(spare_01_q                        ) );
dlc_ff_spare #(.width(  1) ,.rstv({  1{1'b0}})) ff_spare_02                        (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(spare_02_din                        )  ,.q(spare_02_q                        ) );
dlc_ff_spare #(.width(  1) ,.rstv({  1{1'b0}})) ff_spare_03                        (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(spare_03_din                        )  ,.q(spare_03_q                        ) );
dlc_ff_spare #(.width(  1) ,.rstv({  1{1'b0}})) ff_spare_04                        (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(spare_04_din                        )  ,.q(spare_04_q                        ) );
dlc_ff_spare #(.width(  1) ,.rstv({  1{1'b0}})) ff_spare_05                        (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(spare_05_din                        )  ,.q(spare_05_q                        ) );
dlc_ff_spare #(.width(  1) ,.rstv({  1{1'b0}})) ff_spare_06                        (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(spare_06_din                        )  ,.q(spare_06_q                        ) );
dlc_ff_spare #(.width(  1) ,.rstv({  1{1'b0}})) ff_spare_07                        (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(spare_07_din                        )  ,.q(spare_07_q                        ) );
dlc_ff_spare #(.width(  1) ,.rstv({  1{1'b0}})) ff_spare_08                        (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(spare_08_din                        )  ,.q(spare_08_q                        ) );
dlc_ff_spare #(.width(  1) ,.rstv({  1{1'b0}})) ff_spare_09                        (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(spare_09_din                        )  ,.q(spare_09_q                        ) );
dlc_ff_spare #(.width(  1) ,.rstv({  1{1'b0}})) ff_spare_0A                        (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(spare_0A_din                        )  ,.q(spare_0A_q                        ) );
dlc_ff_spare #(.width(  1) ,.rstv({  1{1'b0}})) ff_spare_0B                        (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(spare_0B_din                        )  ,.q(spare_0B_q                        ) );
dlc_ff_spare #(.width(  1) ,.rstv({  1{1'b0}})) ff_spare_0C                        (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(spare_0C_din                        )  ,.q(spare_0C_q                        ) );
dlc_ff_spare #(.width(  1) ,.rstv({  1{1'b0}})) ff_spare_0D                        (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(spare_0D_din                        )  ,.q(spare_0D_q                        ) );
dlc_ff_spare #(.width(  1) ,.rstv({  1{1'b0}})) ff_spare_0E                        (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(spare_0E_din                        )  ,.q(spare_0E_q                        ) );
dlc_ff_spare #(.width(  1) ,.rstv({  1{1'b0}})) ff_spare_0F                        (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(spare_0F_din                        )  ,.q(spare_0F_q                        ) );
dlc_ff_spare #(.width(  1) ,.rstv({  1{1'b0}})) ff_spare_10                        (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(spare_10_din                        )  ,.q(spare_10_q                        ) );
dlc_ff_spare #(.width(  1) ,.rstv({  1{1'b0}})) ff_spare_11                        (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(spare_11_din                        )  ,.q(spare_11_q                        ) );
dlc_ff_spare #(.width(  1) ,.rstv({  1{1'b0}})) ff_spare_12                        (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(spare_12_din                        )  ,.q(spare_12_q                        ) );
dlc_ff_spare #(.width(  1) ,.rstv({  1{1'b0}})) ff_spare_13                        (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(spare_13_din                        )  ,.q(spare_13_q                        ) );
dlc_ff_spare #(.width(  1) ,.rstv({  1{1'b0}})) ff_spare_14                        (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(spare_14_din                        )  ,.q(spare_14_q                        ) );
dlc_ff_spare #(.width(  1) ,.rstv({  1{1'b0}})) ff_spare_15                        (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(spare_15_din                        )  ,.q(spare_15_q                        ) );
dlc_ff_spare #(.width(  1) ,.rstv({  1{1'b0}})) ff_spare_16                        (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(spare_16_din                        )  ,.q(spare_16_q                        ) );
dlc_ff_spare #(.width(  1) ,.rstv({  1{1'b0}})) ff_spare_17                        (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(spare_17_din                        )  ,.q(spare_17_q                        ) );
dlc_ff_spare #(.width(  1) ,.rstv({  1{1'b0}})) ff_spare_18                        (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(spare_18_din                        )  ,.q(spare_18_q                        ) );
dlc_ff_spare #(.width(  1) ,.rstv({  1{1'b0}})) ff_spare_19                        (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(spare_19_din                        )  ,.q(spare_19_q                        ) );
dlc_ff_spare #(.width(  1) ,.rstv({  1{1'b0}})) ff_spare_1A                        (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(spare_1A_din                        )  ,.q(spare_1A_q                        ) );
dlc_ff_spare #(.width(  1) ,.rstv({  1{1'b0}})) ff_spare_1B                        (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(spare_1B_din                        )  ,.q(spare_1B_q                        ) );
dlc_ff_spare #(.width(  1) ,.rstv({  1{1'b0}})) ff_spare_1C                        (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(spare_1C_din                        )  ,.q(spare_1C_q                        ) );
dlc_ff_spare #(.width(  1) ,.rstv({  1{1'b0}})) ff_spare_1D                        (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(spare_1D_din                        )  ,.q(spare_1D_q                        ) );
dlc_ff_spare #(.width(  1) ,.rstv({  1{1'b0}})) ff_spare_1E                        (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(spare_1E_din                        )  ,.q(spare_1E_q                        ) );
dlc_ff_spare #(.width(  1) ,.rstv({  1{1'b0}})) ff_spare_1F                        (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(spare_1F_din                        )  ,.q(spare_1F_q                        ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_cfg_enable_tx_lane_swap         (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(cfg_enable_tx_lane_swap_din         )  ,.q(cfg_enable_tx_lane_swap_q         ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_cfg_enable_tx_lane_swap_err     (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(tx_lane_swap_err_din                )  ,.q(tx_lane_swap_err_q                ) );
dlc_ff       #(.width(  6) ,.rstv({  6{1'b0}})) ff_cfg_tl_credits                  (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(cfg_tl_credits_din                  )  ,.q(cfg_tl_credits_q                  ) );
dlc_ff       #(.width(  4) ,.rstv({  4{1'b0}})) ff_cfg_patB_hyst                   (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(cfg_patB_hyst_din                   )  ,.q(cfg_patB_hyst_q                   ) );
dlc_ff       #(.width(  4) ,.rstv({  4{1'b0}})) ff_cfg_patA_hyst                   (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(cfg_patA_hyst_din                   )  ,.q(cfg_patA_hyst_q                   ) );
dlc_ff       #(.width(  2) ,.rstv({  2{1'b0}})) ff_cfg_patB_length                 (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(cfg_patB_length_din                 )  ,.q(cfg_patB_length_q                 ) );
dlc_ff       #(.width(  2) ,.rstv({  2{1'b0}})) ff_cfg_patA_length                 (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(cfg_patA_length_din                 )  ,.q(cfg_patA_length_q                 ) );
dlc_ff       #(.width(  2) ,.rstv({  2{1'b0}})) ff_cfg_lane_width_sel              (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(cfg_lane_width_sel_din              )  ,.q(cfg_lane_width_sel_q              ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_cfg_pre_IPL_PRBS_ena            (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(cfg_pre_IPL_PRBS_ena_din            )  ,.q(cfg_pre_IPL_PRBS_ena_q            ) );
dlc_ff       #(.width(  3) ,.rstv({  3{1'b0}})) ff_cfg_pre_IPL_PRBS_timer          (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(cfg_pre_IPL_PRBS_timer_din          )  ,.q(cfg_pre_IPL_PRBS_timer_q          ) );
dlc_ff       #(.width(  2) ,.rstv({  2{1'b0}})) ff_lane_width_req_pend             (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(lane_width_req_pend_din             )  ,.q(lane_width_req_pend_q             ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_lane_width_change_ip            (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(lane_width_change_ip_din            )  ,.q(lane_width_change_ip_q            ) );
dlc_ff       #(.width(  2) ,.rstv({  2{1'b0}})) ff_lane_width_change_ip_dly        (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(lane_width_change_ip_dly_din        )  ,.q(lane_width_change_ip_dly_q        ) );
dlc_ff       #(.width(  2) ,.rstv({  2{1'b0}})) ff_init_width                      (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(init_width_din                      )  ,.q(init_width_q                      ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_init_train_done                 (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(init_train_done_din                 )  ,.q(init_train_done_q                 ) );
dlc_ff       #(.width(  2) ,.rstv({  2{1'b0}})) ff_lane_width_status               (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(lane_width_status_din               )  ,.q(lane_width_status_q               ) );
dlc_ff       #(.width(  8) ,.rstv({  8{1'b0}})) ff_PM_tx_lanes_disable             (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(PM_tx_lanes_disable_din             )  ,.q(PM_tx_lanes_disable_q             ) );
dlc_ff       #(.width(  8) ,.rstv({  8{1'b0}})) ff_disabled_tx_lanes_hold          (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(disabled_tx_lanes_hold_din          )  ,.q(disabled_tx_lanes_hold_q          ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_train_done_dly                  (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(train_done_dly_din                  )  ,.q(train_done_dly_q                  ) );
dlc_ff       #(.width(  4) ,.rstv({  4{1'b0}})) ff_PM_state                        (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(PM_state_din                        )  ,.q(PM_state_q                        ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_PM_tx_lane_timer_ena            (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(PM_tx_lane_timer_ena_din            )  ,.q(PM_tx_lane_timer_ena_q            ) );
dlc_ff       #(.width(  5) ,.rstv({  5{1'b0}})) ff_PM_tx_lane_timer                (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(PM_tx_lane_timer_din                )  ,.q(PM_tx_lane_timer_q                ) );
dlc_ff       #(.width(  8) ,.rstv({  8{1'b0}})) ff_tx_psave_req                    (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(tx_psave_req_din                    )  ,.q(tx_psave_req_q                    ) );
dlc_ff       #(.width(  8) ,.rstv({  8{1'b0}})) ff_rx_psave_req                    (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(rx_psave_req_din                    )  ,.q(rx_psave_req_q                    ) );
dlc_ff       #(.width(  8) ,.rstv({  8{1'b0}})) ff_tx_psave_sts                    (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(tx_psave_sts_din                    )  ,.q(tx_psave_sts_q                    ) );
dlc_ff       #(.width(  8) ,.rstv({  8{1'b0}})) ff_rx_psave_sts                    (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(rx_psave_sts_din                    )  ,.q(rx_psave_sts_q                    ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_x4_tx_outer_mode                (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(x4_tx_outer_mode_din                )  ,.q(x4_tx_outer_mode_q                ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_x4_tx_inner_mode                (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(x4_tx_inner_mode_din                )  ,.q(x4_tx_inner_mode_q                ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_PM_msg_sent_dly                 (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(PM_msg_sent_dly_din                 )  ,.q(PM_msg_sent_dly_q                 ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b1}})) ff_PM_narrow_not_wide              (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(PM_narrow_not_wide_din              )  ,.q(PM_narrow_not_wide_q              ) );
dlc_ff       #(.width(  8) ,.rstv({  8{1'b0}})) ff_recal_rx_req                    (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(recal_rx_req_din                    )  ,.q(recal_rx_req_q                    ) );
dlc_ff       #(.width(  8) ,.rstv({  8{1'b0}})) ff_recal_rx_done                   (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(recal_rx_done_din                   )  ,.q(recal_rx_done_q                   ) );
dlc_ff       #(.width(  2) ,.rstv({  {2'b01}})) ff_recal_state                     (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(recal_state_din                     )  ,.q(recal_state_q                     ) );
dlc_ff       #(.width(  4) ,.rstv({  4{1'b0}})) ff_recal_rx_lane_number            (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(recal_rx_lane_number_din            )  ,.q(recal_rx_lane_number_q            ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_rem_recal_done                  (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(rem_recal_done_din                  )  ,.q(rem_recal_done_q                  ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_is_host                         (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(is_host_din                         )  ,.q(is_host_q                         ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_PM_start_retrain                (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(PM_start_retrain_din                )  ,.q(PM_start_retrain_q                ) );
dlc_ff       #(.width(  8) ,.rstv({  8{1'b0}})) ff_recal_rx_lane_enable            (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(recal_rx_lane_enable_din            )  ,.q(recal_rx_lane_enable_q            ) );
dlc_ff       #(.width(  8) ,.rstv({  8{1'b0}})) ff_recal_tx_lane_enable            (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(recal_tx_lane_enable_din            )  ,.q(recal_tx_lane_enable_q            ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_PM_enable                       (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(PM_enable_din                       )  ,.q(PM_enable_q                       ) );
dlc_ff       #(.width(  2) ,.rstv({  2{1'b0}})) ff_requested_lane_width            (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(requested_lane_width_din            )  ,.q(requested_lane_width_q            ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_PM_start_retrain_sent           (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(PM_start_retrain_sent_din           )  ,.q(PM_start_retrain_sent_q           ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_PM_caused_retrain               (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(PM_caused_retrain_din               )  ,.q(PM_caused_retrain_q               ) );
dlc_ff       #(.width(  8) ,.rstv({  8{1'b0}})) ff_tx_trained_lanes                (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(tx_trained_lanes_din                )  ,.q(tx_trained_lanes_q                ) );
dlc_ff       #(.width(  8) ,.rstv({  8{1'b0}})) ff_sts_disabled_rx_lanes           (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(sts_disabled_rx_lanes_din           )  ,.q(sts_disabled_rx_lanes_q           ) );
dlc_ff       #(.width( 22) ,.rstv({ 22{1'b0}})) ff_pre_IPL_PRBS_timer              (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(pre_IPL_PRBS_timer_din              )  ,.q(pre_IPL_PRBS_timer_q              ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_pre_IPL_PRBS_timer_done         (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(pre_IPL_PRBS_timer_done_din         )  ,.q(pre_IPL_PRBS_timer_done_q         ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_pre_IPL_PRBS_timer_done_dly     (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(pre_IPL_PRBS_timer_done_dly_din     )  ,.q(pre_IPL_PRBS_timer_done_dly_q     ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_recal_toggle                    (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(recal_toggle_din                    )  ,.q(recal_toggle_q                    ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_half_width_x4_tx_mode           (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(half_width_x4_tx_mode_din           )  ,.q(half_width_x4_tx_mode_q           ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_half_width_x8_tx_mode           (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(half_width_x8_tx_mode_din           )  ,.q(half_width_x8_tx_mode_q           ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_half_width_x4_rx_mode           (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(half_width_x4_rx_mode_din           )  ,.q(half_width_x4_rx_mode_q           ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_half_width_x8_rx_mode           (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(half_width_x8_rx_mode_din           )  ,.q(half_width_x8_rx_mode_q           ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_half_width_x4_outer_tx_mode     (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(half_width_x4_outer_tx_mode_din     )  ,.q(half_width_x4_outer_tx_mode_q     ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_half_width_x4_inner_tx_mode     (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(half_width_x4_inner_tx_mode_din     )  ,.q(half_width_x4_inner_tx_mode_q     ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_half_width_x4_outer_rx_mode     (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(half_width_x4_outer_rx_mode_din     )  ,.q(half_width_x4_outer_rx_mode_q     ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_half_width_x4_inner_rx_mode     (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(half_width_x4_inner_rx_mode_din     )  ,.q(half_width_x4_inner_rx_mode_q     ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_half_width_x8_outer_tx_mode     (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(half_width_x8_outer_tx_mode_din     )  ,.q(half_width_x8_outer_tx_mode_q     ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_half_width_x8_inner_tx_mode     (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(half_width_x8_inner_tx_mode_din     )  ,.q(half_width_x8_inner_tx_mode_q     ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_half_width_x8_outer_rx_mode     (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(half_width_x8_outer_rx_mode_din     )  ,.q(half_width_x8_outer_rx_mode_q     ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_half_width_x8_inner_rx_mode     (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(half_width_x8_inner_rx_mode_din     )  ,.q(half_width_x8_inner_rx_mode_q     ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_full_width_x8_rx_mode           (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(full_width_x8_rx_mode_din           )  ,.q(full_width_x8_rx_mode_q           ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_full_width_x8_tx_mode           (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(full_width_x8_tx_mode_din           )  ,.q(full_width_x8_tx_mode_q           ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_full_width_x4_rx_mode           (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(full_width_x4_rx_mode_din           )  ,.q(full_width_x4_rx_mode_q           ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_full_width_x4_tx_mode           (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(full_width_x4_tx_mode_din           )  ,.q(full_width_x4_tx_mode_q           ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_first_recal_started             (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(first_recal_started_din             )  ,.q(first_recal_started_q             ) );
dlc_ff       #(.width(  4) ,.rstv({  4{1'b0}})) ff_recal_tx_lane_number            (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(recal_tx_lane_number_din            )  ,.q(recal_tx_lane_number_q            ) );
dlc_ff       #(.width(  4) ,.rstv({   {4'h1}})) ff_recal_num_done                  (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(recal_num_done_din                  )  ,.q(recal_num_done_q                  ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_send_PM_ready_msg               (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(send_PM_ready_msg_din               )  ,.q(send_PM_ready_msg_q               ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_PM_stop                         (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(PM_stop_din                         )  ,.q(PM_stop_q                         ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_PM_wake_msg_sent                (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(PM_wake_msg_sent_din                )  ,.q(PM_wake_msg_sent_q                ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_real_stall                      (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(real_stall_din                      )  ,.q(real_stall_q                      ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_retrain_ip                      (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(retrain_ip_din                      )  ,.q(retrain_ip_q                      ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_retrained_in_degr_width         (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(retrained_in_degr_width_din         )  ,.q(retrained_in_degr_width_q         ) );
dlc_ff       #(.width(  4) ,.rstv({  4{1'b0}})) ff_rem_PM_status_dly               (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(rem_PM_status_dly_din               )  ,.q(rem_PM_status_dly_q               ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_tx_psave_timer_full2half_ena    (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(tx_psave_timer_full2half_ena_din    )  ,.q(tx_psave_timer_full2half_ena_q    ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_tx_psave_timer_half2quarter_ena (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(tx_psave_timer_half2quarter_ena_din )  ,.q(tx_psave_timer_half2quarter_ena_q ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_retrain_not_due2_PM_dly         (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(retrain_not_due2_PM_dly_din         )  ,.q(retrain_not_due2_PM_dly_q         ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_retrain_not_due2_PM             (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(retrain_not_due2_PM_din             )  ,.q(retrain_not_due2_PM_q             ) );
dlc_ff       #(.width(  8) ,.rstv({  8{1'b0}})) ff_tx_psave_timer                  (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(tx_psave_timer_din                  )  ,.q(tx_psave_timer_q                  ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_PM_back_to_quarter              (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(PM_back_to_quarter_din              )  ,.q(PM_back_to_quarter_q              ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_PM_is_host                      (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(PM_is_host_din                      )  ,.q(PM_is_host_q                      ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_trn_timeout_fired               (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(trn_timeout_fired_din               )  ,.q(trn_timeout_fired_q               ) );
dlc_ff       #(.width(  6) ,.rstv({  6{1'b0}})) ff_trn_timeout_timer               (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(trn_timeout_timer_din               )  ,.q(trn_timeout_timer_q               ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_trn_timeout_has_fired           (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(trn_timeout_has_fired_din           )  ,.q(trn_timeout_has_fired_q           ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_PM_msg_8to2_early               (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(PM_msg_8to2_early_din               )  ,.q(PM_msg_8to2_early_q               ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_PM_msg_9to1_early               (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(PM_msg_9to1_early_din               )  ,.q(PM_msg_9to1_early_q               ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_around_stall_EP_hold            (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(around_stall_EP_hold_din            )  ,.q(around_stall_EP_hold_q            ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_enable_short_idle               (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(enable_short_idle_din               )  ,.q(enable_short_idle_q               ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_EDPL_ena                        (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(EDPL_ena_din                        )  ,.q(EDPL_ena_q                        ) );
dlc_ff       #(.width(  2) ,.rstv({  2{1'b0}})) ff_trace_trig                      (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(trace_trig_din                      )  ,.q(trace_trig_q                      ) );
dlc_ff       #(.width( 88) ,.rstv({ 88{1'b0}})) ff_debug_dbg_stg0                  (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(debug_dbg_stg0_din                  )  ,.q(debug_dbg_stg0_q                  ) );
dlc_ff       #(.width( 48) ,.rstv({ 48{1'b0}})) ff_dl_errors                       (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(dl_errors_din                       )  ,.q(dl_errors_q                       ) );
dlc_ff       #(.width(  8) ,.rstv({  8{1'b0}})) ff_iobist_prbs_error               (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(iobist_prbs_error_din               )  ,.q(iobist_prbs_error_q               ) );
dlc_ff       #(.width(  2) ,.rstv({  2{1'b0}})) ff_rem_recal_status_dly            (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(rem_recal_status_dly_din            )  ,.q(rem_recal_status_dly_q            ) );
dlc_ff       #(.width(  4) ,.rstv({  4{1'b0}})) ff_cfg_macro_dbg_sel               (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(cfg_macro_dbg_sel_din               )  ,.q(cfg_macro_dbg_sel_q               ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_phy_limit_hit                   (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(phy_limit_hit_din                   )  ,.q(unused[0]                         ) );
dlc_ff       #(.width(  6) ,.rstv({  6{1'b0}})) ff_EDPL_compare                    (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(EDPL_compare_din                    )  ,.q(EDPL_compare_q                    ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_PM_allow_wake                   (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(PM_allow_wake_din                   )  ,.q(PM_allow_wake_q                   ) );
dlc_ff       #(.width(  8) ,.rstv({  8{1'b0}})) ff_ln_disable_PM_wake              (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(ln_disable_PM_wake_din              )  ,.q(ln_disable_PM_wake_q              ) );
dlc_ff       #(.width(  8) ,.rstv({  8{1'b0}})) ff_rx_psave_req_PM                 (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(rx_psave_req_PM_din                 )  ,.q(rx_psave_req_PM_q                 ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_PM_EP_start_retrain             (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(PM_EP_start_retrain_din             )  ,.q(PM_EP_start_retrain_q             ) );

endmodule  //-- dlc_omi_tx_train
