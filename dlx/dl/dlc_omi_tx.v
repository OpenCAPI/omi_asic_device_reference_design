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
module dlc_omi_tx #(
parameter             RX_EQ_TX_CLK = 0
) (
//-- inputs from the 8 TL
   tl2dl_flit_early_vld          //--  input
  ,tl2dl_flit_vld                //--  input
  ,tl2dl_flit_data               //--  input   [127:0]
  ,tl2dl_flit_ecc                //--  input   [15:0]
  ,tl2dl_flit_lbip_vld           //--  input
  ,tl2dl_flit_lbip_data          //--  input   [81:0]
//  ,tl2dl_flit_lbip_ecc           //--  input   [15:0]
  ,dl2tl_link_up                 //--  output

  ,dl2tl_flit_credit             //--  output
  ,tl2dl_lane_width_request      //--  input[1:0]
  ,dl2tl_lane_width_status       //--  output[1:0]
  ,tl2dl_tl_error                //--  input
  ,tl2dl_tl_event                //--  input
  ,dl_phy_recal_req_0            //--  output
  ,dl_phy_recal_req_1            //--  output
  ,dl_phy_recal_req_2            //--  output
  ,dl_phy_recal_req_3            //--  output
  ,dl_phy_recal_req_4            //--  output
  ,dl_phy_recal_req_5            //--  output
  ,dl_phy_recal_req_6            //--  output
  ,dl_phy_recal_req_7            //--  output
  ,phy_dl_recal_done_0           //--  input
  ,phy_dl_recal_done_1           //--  input
  ,phy_dl_recal_done_2           //--  input
  ,phy_dl_recal_done_3           //--  input
  ,phy_dl_recal_done_4           //--  input
  ,phy_dl_recal_done_5           //--  input
  ,phy_dl_recal_done_6           //--  input
  ,phy_dl_recal_done_7           //--  input
  ,dl_phy_rx_psave_req_0         //--  output
  ,dl_phy_rx_psave_req_1         //--  output
  ,dl_phy_rx_psave_req_2         //--  output
  ,dl_phy_rx_psave_req_3         //--  output
  ,dl_phy_rx_psave_req_4         //--  output
  ,dl_phy_rx_psave_req_5         //--  output
  ,dl_phy_rx_psave_req_6         //--  output
  ,dl_phy_rx_psave_req_7         //--  output
  ,phy_dl_rx_psave_sts_0         //--  input
  ,phy_dl_rx_psave_sts_1         //--  input
  ,phy_dl_rx_psave_sts_2         //--  input
  ,phy_dl_rx_psave_sts_3         //--  input
  ,phy_dl_rx_psave_sts_4         //--  input
  ,phy_dl_rx_psave_sts_5         //--  input
  ,phy_dl_rx_psave_sts_6         //--  input
  ,phy_dl_rx_psave_sts_7         //--  input
  ,dl_phy_tx_psave_req_0         //--  output
  ,dl_phy_tx_psave_req_1         //--  output
  ,dl_phy_tx_psave_req_2         //--  output
  ,dl_phy_tx_psave_req_3         //--  output
  ,dl_phy_tx_psave_req_4         //--  output
  ,dl_phy_tx_psave_req_5         //--  output
  ,dl_phy_tx_psave_req_6         //--  output
  ,dl_phy_tx_psave_req_7         //--  output
  ,phy_dl_tx_psave_sts_0         //--  input
  ,phy_dl_tx_psave_sts_1         //--  input
  ,phy_dl_tx_psave_sts_2         //--  input
  ,phy_dl_tx_psave_sts_3         //--  input
  ,phy_dl_tx_psave_sts_4         //--  input
  ,phy_dl_tx_psave_sts_5         //--  input
  ,phy_dl_tx_psave_sts_6         //--  input
  ,phy_dl_tx_psave_sts_7         //--  input

//--  signals to the PHY
  ,dl_phy_lane_0                 //--  output  [15:0]
  ,dl_phy_lane_1                 //--  output  [15:0]
  ,dl_phy_lane_2                 //--  output  [15:0]
  ,dl_phy_lane_3                 //--  output  [15:0]
  ,dl_phy_lane_4                 //--  output  [15:0]
  ,dl_phy_lane_5                 //--  output  [15:0]
  ,dl_phy_lane_6                 //--  output  [15:0]
  ,dl_phy_lane_7                 //--  output  [15:0]
  ,dl_phy_run_lane_0             //--  output
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

//-- signals between the RX and TX
 ,rx_tx_crc_error               //--  input
 ,rx_tx_nack                    //--  input
 ,rx_tx_rx_ack_inc              //--  input  [3:0]
 ,rx_tx_tx_ack_rtn              //--  input  [4:0]
 ,rx_tx_tx_ack_ptr_vld          //--  input
 ,rx_tx_tx_ack_ptr              //--  input  [11:0]
 ,rx_tx_rmt_error               //--  input  [7:0]
 ,rx_tx_recal_status            //--  input   [1:0]      //--  new ports for power management
 ,rx_tx_pm_status               //--  input   [3:0]      //--  new ports for power management
 ,rx_tx_rmt_message             //--  input  [63:0]
 ,tx_rx_reset_n                 //--  output
 ,tx_rx_tsm                     //--  output [2:0]    
 ,tx_rx_phy_init_done           //--  output [7:0]
 ,rx_tx_version_number          //--  input  [5:0]
 ,rx_tx_slow_clock              //--  input
 ,rx_tx_deskew_overflow         //--  input
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
 ,rx_tx_training_sync_hdr       //--  input
 ,rx_tx_lost_data_sync          //--  input
 ,rx_tx_trn_dbg                 //--  input [87:0]
 ,rx_tx_EDPL_max_cnts           //--  input [63:0]
 ,rx_tx_EDPL_errors             //--  input [7:0]
 ,rx_tx_EDPL_thres_reached      //--  input [7:0]
 ,tx_rx_EDPL_cfg                //--  output [4:0]
 ,tx_rx_cfg_patA_length         //--  output [1:0]
 ,tx_rx_cfg_patB_length         //--  output [1:0]
 ,tx_rx_cfg_patA_hyst           //--  output [3:0]
 ,tx_rx_cfg_patB_hyst           //--  output [3:0]
 ,tx_rx_rx_BEI_inject           //--  output [7:0]
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
 ,rx_link_up                    //--  input

//-- FRBUF(Flit Replay BUFfer) interface
 ,frbuf_wr_en                   //-- output
 ,frbuf_wr_addr                 //--  output
 ,frbuf_wr_data                 //--  output
 ,frbuf_rd0_en                  //--  output
 ,frbuf_rd0_addr                //--  output
 ,frbuf_rd0_data                //--  input
 ,frbuf_rd1_en                  //--  output
 ,frbuf_rd1_addr                //--  output
 ,frbuf_rd1_data                //--  input
 ,frbuf_rd0_select_pair0_d1     //--  output
 ,frbuf_rd0_select_pair1_d1     //--  output

// reg interface
 ,reg_dl_config0                //--  input  [63:0]
 ,reg_dl_config1                //--  input  [63:0]
 ,reg_dl_error_message          //--  input  [3:0]
 ,reg_dl_link_down              //--  input
 ,reg_rmt_write                 //--  input
 ,reg_rmt_config                //--  input  [31:0]
 ,reg_dl_cya_bits               //--  input  [31:0]

 ,dl_reg_errors                 //--  output [47:0]
 ,dl_reg_rmt_message            //--  output [63:0]
 ,dl_reg_status                 //--  output [63:0]
 ,dl_reg_training_status        //--  output [63:0]

 ,dl_reg_error_capture          //--  output [62:0]
 ,reg_dl_err_cap_reset          //--  input 
 ,dl_reg_edpl_max_count         //--  output [63:0]
 ,dl_reg_trace_data             //--  output [87:0]
 ,dl_reg_trace_trig             //--  output [1:0]
 ,dl_reg_perf_mon               //--  output [11:0]
 ,dl_phy_iobist_prbs_error      //--  output [7:0]
 ,reg_dl_edpl_max_count_reset   //--  input
 ,reg_dl_1us_tick               //--  input
 ,reg_dl_100ms_tick             //--  input
 ,reg_dl_recal_start            //--  input
 ,global_trace_enable           //--  input
 ,omi_enable                    //--  output 
 ,dl_clk                        //--  input
 ,rx_tx_mn_trn_in_replay        //--  input 
 ,rx_tx_data_flt                //--  input 
 ,rx_tx_ctl_flt                 //--  input
 ,rx_tx_rpl_flt                 //--  input 
 ,rx_tx_idle_flt                //--  input 
 ,rx_tx_ill_rl                  //--  input   
 ,rx_tx_dbg_rx_info             //--  input  [87:0]
 ,tx_rx_macro_dbg_sel           //--  output [3:0]
 ,rx_tx_iobist_prbs_error       //--  input  [7:0]
 ,tx_rx_inj_pty_err             //--  output
 ,chip_reset                    //--  input
 ,global_reset_control          //--  input 
 ,sync_mode                     //--  input
);


input              tl2dl_flit_early_vld;
input              tl2dl_flit_vld;
input   [127:0]    tl2dl_flit_data;
input   [15:0]     tl2dl_flit_ecc;
input              tl2dl_flit_lbip_vld;
input   [81:0]     tl2dl_flit_lbip_data;
//input   [15:0]     tl2dl_flit_lbip_ecc;
input  [1:0]       tl2dl_lane_width_request;
output [1:0]       dl2tl_lane_width_status;
output             dl2tl_flit_credit;
output             dl2tl_link_up;
input              tl2dl_tl_error;
input              tl2dl_tl_event;
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
output  [15:0]     dl_phy_lane_0;
output  [15:0]     dl_phy_lane_1;
output  [15:0]     dl_phy_lane_2;
output  [15:0]     dl_phy_lane_3;
output  [15:0]     dl_phy_lane_4;
output  [15:0]     dl_phy_lane_5;
output  [15:0]     dl_phy_lane_6;
output  [15:0]     dl_phy_lane_7;
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

input              rx_tx_crc_error;
input              rx_tx_nack;
input  [3:0]       rx_tx_rx_ack_inc;
input  [4:0]       rx_tx_tx_ack_rtn;
input              rx_tx_tx_ack_ptr_vld;
input  [11:0]      rx_tx_tx_ack_ptr;
input  [7:0]       rx_tx_rmt_error;
input  [1:0]       rx_tx_recal_status;
input  [3:0]       rx_tx_pm_status;
input  [63:0]      rx_tx_rmt_message;
output             tx_rx_reset_n;
output [2:0]       tx_rx_tsm;
output [7:0]       tx_rx_phy_init_done;
input  [5:0]       rx_tx_version_number;
input              rx_tx_slow_clock;
input              rx_tx_deskew_overflow;
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
input              rx_link_up;
 
output             frbuf_wr_en;
output [7:0]       frbuf_wr_addr;
output [143:0]     frbuf_wr_data;
output             frbuf_rd0_en;
output [7:0]       frbuf_rd0_addr;
input  [143:0]     frbuf_rd0_data;
output             frbuf_rd1_en;
output [7:0]       frbuf_rd1_addr;
input  [143:0]     frbuf_rd1_data;
output             frbuf_rd0_select_pair0_d1;
output             frbuf_rd0_select_pair1_d1;

input  [63:0]      reg_dl_config0;
input  [63:0]      reg_dl_config1;
input  [3:0]       reg_dl_error_message;
input              reg_dl_link_down;
input              reg_rmt_write;
input  [31:0]      reg_rmt_config;
input  [31:0]      reg_dl_cya_bits;

output [47:0]      dl_reg_errors;
output [63:0]      dl_reg_rmt_message;
output [63:0]      dl_reg_status;
output [63:0]      dl_reg_training_status;
output [62:0]      dl_reg_error_capture;
input              reg_dl_err_cap_reset;
output [63:0]      dl_reg_edpl_max_count;
output [1:0]       dl_reg_trace_trig;         
output [87:0]      dl_reg_trace_data;         
output [11:0]      dl_reg_perf_mon;    
output [7:0]       dl_phy_iobist_prbs_error;
input              reg_dl_edpl_max_count_reset;
input              reg_dl_1us_tick;
input              reg_dl_100ms_tick;
input              reg_dl_recal_start;
input              global_trace_enable;
output             omi_enable;
input              dl_clk;
input              rx_tx_mn_trn_in_replay; 
input              rx_tx_data_flt;         
input              rx_tx_ctl_flt;          
input              rx_tx_rpl_flt;          
input              rx_tx_idle_flt;         
input              rx_tx_ill_rl;       
input  [87:0]      rx_tx_dbg_rx_info;     
output [3:0]       tx_rx_macro_dbg_sel;
input  [7:0]       rx_tx_iobist_prbs_error;
output             tx_rx_inj_pty_err;
input              chip_reset;
input              global_reset_control;
input              sync_mode;

wire             trn_flt_train_done;           
wire             trn_agn_half_width;
wire             trn_agn_train_done;
wire             trn_agn_ln_swap;
wire [1:0]       trn_agn_x4_mode;
wire [1:0]       trn_agn_x2_mode;
wire             trn_agn_training;         
wire [127:0]     trn_agn_training_set;
wire             trn_agn_stall;                            
wire [7:0]       trn_agn_send_TS1;
wire             trn_agn_PM_store_reset;
wire [15:0]      trn_ln0_scrambler;                             
wire [15:0]      trn_ln1_scrambler;                             
wire [15:0]      trn_ln2_scrambler;                             
wire [15:0]      trn_ln3_scrambler;                             
wire [15:0]      trn_ln4_scrambler;                             
wire [15:0]      trn_ln5_scrambler;                             
wire [15:0]      trn_ln6_scrambler;                             
wire [15:0]      trn_ln7_scrambler;                             
wire [15:0]      trn_ln_train_data;                             
wire             trn_reset_n;                                
wire             trn_enable;                                
wire             trn_ln_reverse;
wire [7:0]       trn_ln_disable;
wire [7:0]       trn_ln_phy_training;
wire [7:0]       trn_ln_dl_training;
wire             trn_ln_tx_EDPL_ena;
wire [7:0]       trn_ln_tx_BEI_inject;
wire [127:0]     flt_agn_data;
//-- wire             flt_agn_fp_vld;
//-- wire             flt_agn_use_ngbr;
wire [15:0]      agn_ln0_next_2B;
wire [15:0]      agn_ln1_next_2B;
wire [15:0]      agn_ln2_next_2B;
wire [15:0]      agn_ln3_next_2B;
wire [15:0]      agn_ln4_next_2B;
wire [15:0]      agn_ln5_next_2B;
wire [15:0]      agn_ln6_next_2B;
wire [15:0]      agn_ln7_next_2B;

wire             trn_flt_stall;
wire             trn_flt_real_stall; 
wire             trn_flt_x2_tx_mode;
wire             trn_flt_x4_tx_mode;
wire             trn_flt_x8_tx_mode;
wire [1:0]       trn_flt_recal_state;
wire             trn_flt_send_pm_msg;
wire             trn_flt_pm_narrow_not_wide;
wire             flt_trn_pm_msg_sent;
wire [3:0]       trn_flt_pm_msg;
wire             flt_trn_reset_hammer;
wire             flt_trn_retrain_hammer;
wire             flt_trn_retrain_rply;
wire             flt_trn_retrain_no_rply;

wire [7:0]       trn_flt_link_errors;
wire             trn_flt_enable_short_idle;
wire             trn_flt_enable_fast_path;
wire             all_tx_credits_returned;

wire             flt_trn_no_fwd_prog;
wire             flt_trn_fp_start;
wire             flt_trn_rpl_data_flt;
wire             flt_trn_data_flt;
wire             flt_trn_ctl_flt;
wire             flt_trn_rpl_flt;
wire             flt_trn_idle_flt;
wire             flt_trn_ue_rpb_df;
wire             flt_trn_ue_frb_df;
wire             flt_trn_ce_rpb;
wire             flt_trn_ce_frb;
wire             flt_trn_data_pty_err;
wire             flt_trn_tl_trunc;
wire             flt_trn_tl_rl_err;
wire             flt_trn_ack_ptr_err;
wire             flt_trn_ue_rpb_cf;
wire             flt_trn_ue_frb_cf;
wire  [87:0]     flt_trn_dbg_tx_info;
wire             flt_trn_in_replay;
wire             trn_flt_inj_ecc_ce;
wire             trn_flt_inj_ecc_ue;
wire  [3:0]      trn_flt_rpb_rm_depth;
wire             trn_flt_1us_tick;
wire  [5:0]      trn_flt_tl_credits;
wire  [3:0]      trn_flt_macro_dbg_sel;
wire             trn_flt_tsm4;
wire             omi_enable_int;
wire [2:0]       tx_tsm;

assign           omi_enable     = omi_enable_int; //-- output of tx.v
assign           tx_rx_tsm[2:0] = tx_tsm[2:0];

dlc_omi_tx_train #(.RX_EQ_TX_CLK(RX_EQ_TX_CLK))  trn (
  .dl_phy_run_lane_0             (dl_phy_run_lane_0)              //-- output
 ,.dl_phy_run_lane_1             (dl_phy_run_lane_1)              //-- output
 ,.dl_phy_run_lane_2             (dl_phy_run_lane_2)              //-- output
 ,.dl_phy_run_lane_3             (dl_phy_run_lane_3)              //-- output
 ,.dl_phy_run_lane_4             (dl_phy_run_lane_4)              //-- output
 ,.dl_phy_run_lane_5             (dl_phy_run_lane_5)              //-- output
 ,.dl_phy_run_lane_6             (dl_phy_run_lane_6)              //-- output
 ,.dl_phy_run_lane_7             (dl_phy_run_lane_7)              //-- output
 ,.phy_dl_init_done_0            (phy_dl_init_done_0)             //-- input
 ,.phy_dl_init_done_1            (phy_dl_init_done_1)             //-- input
 ,.phy_dl_init_done_2            (phy_dl_init_done_2)             //-- input
 ,.phy_dl_init_done_3            (phy_dl_init_done_3)             //-- input
 ,.phy_dl_init_done_4            (phy_dl_init_done_4)             //-- input
 ,.phy_dl_init_done_5            (phy_dl_init_done_5)             //-- input
 ,.phy_dl_init_done_6            (phy_dl_init_done_6)             //-- input
 ,.phy_dl_init_done_7            (phy_dl_init_done_7)             //-- input
 ,.tl2dl_lane_width_request      (tl2dl_lane_width_request[1:0])  //-- input  [1:0]
 ,.dl2tl_lane_width_status       (dl2tl_lane_width_status[1:0])   //-- output [1:0]
 ,.dl_phy_recal_req_0            (dl_phy_recal_req_0)             //-- output
 ,.dl_phy_recal_req_1            (dl_phy_recal_req_1)             //-- output
 ,.dl_phy_recal_req_2            (dl_phy_recal_req_2)             //-- output
 ,.dl_phy_recal_req_3            (dl_phy_recal_req_3)             //-- output
 ,.dl_phy_recal_req_4            (dl_phy_recal_req_4)             //-- output
 ,.dl_phy_recal_req_5            (dl_phy_recal_req_5)             //-- output
 ,.dl_phy_recal_req_6            (dl_phy_recal_req_6)             //-- output
 ,.dl_phy_recal_req_7            (dl_phy_recal_req_7)             //-- output
 ,.phy_dl_recal_done_0           (phy_dl_recal_done_0)            //-- input
 ,.phy_dl_recal_done_1           (phy_dl_recal_done_1)            //-- input
 ,.phy_dl_recal_done_2           (phy_dl_recal_done_2)            //-- input
 ,.phy_dl_recal_done_3           (phy_dl_recal_done_3)            //-- input
 ,.phy_dl_recal_done_4           (phy_dl_recal_done_4)            //-- input
 ,.phy_dl_recal_done_5           (phy_dl_recal_done_5)            //-- input
 ,.phy_dl_recal_done_6           (phy_dl_recal_done_6)            //-- input
 ,.phy_dl_recal_done_7           (phy_dl_recal_done_7)            //-- input
 ,.dl_phy_rx_psave_req_0         (dl_phy_rx_psave_req_0)          //-- output
 ,.dl_phy_rx_psave_req_1         (dl_phy_rx_psave_req_1)          //-- output
 ,.dl_phy_rx_psave_req_2         (dl_phy_rx_psave_req_2)          //-- output
 ,.dl_phy_rx_psave_req_3         (dl_phy_rx_psave_req_3)          //-- output
 ,.dl_phy_rx_psave_req_4         (dl_phy_rx_psave_req_4)          //-- output
 ,.dl_phy_rx_psave_req_5         (dl_phy_rx_psave_req_5)          //-- output
 ,.dl_phy_rx_psave_req_6         (dl_phy_rx_psave_req_6)          //-- output
 ,.dl_phy_rx_psave_req_7         (dl_phy_rx_psave_req_7)          //-- output
 ,.phy_dl_rx_psave_sts_0         (phy_dl_rx_psave_sts_0)          //-- input
 ,.phy_dl_rx_psave_sts_1         (phy_dl_rx_psave_sts_1)          //-- input
 ,.phy_dl_rx_psave_sts_2         (phy_dl_rx_psave_sts_2)          //-- input
 ,.phy_dl_rx_psave_sts_3         (phy_dl_rx_psave_sts_3)          //-- input
 ,.phy_dl_rx_psave_sts_4         (phy_dl_rx_psave_sts_4)          //-- input
 ,.phy_dl_rx_psave_sts_5         (phy_dl_rx_psave_sts_5)          //-- input
 ,.phy_dl_rx_psave_sts_6         (phy_dl_rx_psave_sts_6)          //-- input
 ,.phy_dl_rx_psave_sts_7         (phy_dl_rx_psave_sts_7)          //-- input
 ,.dl_phy_tx_psave_req_0         (dl_phy_tx_psave_req_0)          //-- output
 ,.dl_phy_tx_psave_req_1         (dl_phy_tx_psave_req_1)          //-- output
 ,.dl_phy_tx_psave_req_2         (dl_phy_tx_psave_req_2)          //-- output
 ,.dl_phy_tx_psave_req_3         (dl_phy_tx_psave_req_3)          //-- output
 ,.dl_phy_tx_psave_req_4         (dl_phy_tx_psave_req_4)          //-- output
 ,.dl_phy_tx_psave_req_5         (dl_phy_tx_psave_req_5)          //-- output
 ,.dl_phy_tx_psave_req_6         (dl_phy_tx_psave_req_6)          //-- output
 ,.dl_phy_tx_psave_req_7         (dl_phy_tx_psave_req_7)          //-- output
 ,.phy_dl_tx_psave_sts_0         (phy_dl_tx_psave_sts_0)          //-- input
 ,.phy_dl_tx_psave_sts_1         (phy_dl_tx_psave_sts_1)          //-- input
 ,.phy_dl_tx_psave_sts_2         (phy_dl_tx_psave_sts_2)          //-- input
 ,.phy_dl_tx_psave_sts_3         (phy_dl_tx_psave_sts_3)          //-- input
 ,.phy_dl_tx_psave_sts_4         (phy_dl_tx_psave_sts_4)          //-- input
 ,.phy_dl_tx_psave_sts_5         (phy_dl_tx_psave_sts_5)          //-- input
 ,.phy_dl_tx_psave_sts_6         (phy_dl_tx_psave_sts_6)          //-- input
 ,.phy_dl_tx_psave_sts_7         (phy_dl_tx_psave_sts_7)          //-- input
 ,.rx_tx_crc_error               (rx_tx_crc_error)                //-- input
 ,.rx_tx_nack                    (rx_tx_nack)                     //-- input
 ,.rx_tx_data_flt                (rx_tx_data_flt)                 //-- input
 ,.rx_tx_ctl_flt                 (rx_tx_ctl_flt)                  //-- input
 ,.rx_tx_rpl_flt                 (rx_tx_rpl_flt)                  //-- input
 ,.rx_tx_idle_flt                (rx_tx_idle_flt)                 //-- input
 ,.rx_tx_ill_rl                  (rx_tx_ill_rl)                   //-- input
 ,.rx_tx_slow_clock              (rx_tx_slow_clock)               //-- input
 ,.rx_tx_deskew_overflow         (rx_tx_deskew_overflow)          //-- input
 ,.rx_tx_recal_status            (rx_tx_recal_status[1:0])        //-- input[1:0]
 ,.rx_tx_pm_status               (rx_tx_pm_status[3:0])           //-- input[3:0]
 ,.rx_tx_rmt_error               (rx_tx_rmt_error[7:0])           //-- input[7:0]
 ,.rx_tx_rmt_message             (rx_tx_rmt_message[63:0])        //-- input[63:0]
 ,.rx_tx_dbg_rx_info             (rx_tx_dbg_rx_info[87:0])        //-- input [87:0]
 ,.rx_tx_iobist_prbs_error       (rx_tx_iobist_prbs_error[7:0])   //-- input [7:0]
 ,.tx_rx_reset_n                 (tx_rx_reset_n)                  //-- output
 ,.tx_rx_tsm                     (tx_tsm[2:0])                    //-- output[2:0]
 ,.tx_rx_phy_init_done           (tx_rx_phy_init_done[7:0])       //-- output[7:0]
 ,.rx_tx_version_number          (rx_tx_version_number[5:0])      //-- input[5:0]
 ,.rx_tx_train_status            (rx_tx_train_status[72:0])       //-- input[72:0]
 ,.rx_tx_disabled_rx_lanes       (rx_tx_disabled_rx_lanes[7:0])   //-- input[7:0]
 ,.rx_tx_disabled_tx_lanes       (rx_tx_disabled_tx_lanes[7:0])   //-- input[7:0]
 ,.rx_tx_ts_valid                (rx_tx_ts_valid)                 //-- input
 ,.rx_tx_ts_good_lanes           (rx_tx_ts_good_lanes[15:0])      //-- input[15:0]
 ,.rx_tx_deskew_config_valid     (rx_tx_deskew_config_valid)      //-- input
 ,.rx_tx_deskew_config           (rx_tx_deskew_config[18:0])      //-- input [18:0]
 ,.rx_tx_tx_ordering             (rx_tx_tx_ordering)              //-- input
 ,.rx_tx_rem_supported_widths    (rx_tx_rem_supported_widths[3:0])//-- input[3:0]
 ,.rx_tx_trained_mode            (rx_tx_trained_mode[3:0])        //-- input
 ,.tx_rx_cfg_supported_widths    (tx_rx_cfg_supported_widths[3:0])//-- output[3:0]
 ,.rx_tx_tx_lane_swap            (rx_tx_tx_lane_swap)             //-- input
 ,.rx_tx_rem_PM_enable           (rx_tx_rem_PM_enable)            //-- input
 ,.rx_tx_rx_lane_reverse         (rx_tx_rx_lane_reverse)          //-- input
 ,.rx_tx_lost_data_sync          (rx_tx_lost_data_sync)           //-- input
 ,.rx_tx_trn_dbg                 (rx_tx_trn_dbg[87:0])            //-- input
 ,.rx_tx_training_sync_hdr       (rx_tx_training_sync_hdr)        //-- input
 ,.rx_tx_EDPL_max_cnts           (rx_tx_EDPL_max_cnts[63:0])      //-- input [63:0]
 ,.rx_tx_EDPL_errors             (rx_tx_EDPL_errors[7:0])         //-- input [7:0]
 ,.rx_tx_EDPL_thres_reached      (rx_tx_EDPL_thres_reached[7:0])  //-- input [7:0]
 ,.tx_rx_EDPL_cfg                (tx_rx_EDPL_cfg[4:0])            //-- output [4:0]
 ,.tx_rx_cfg_patA_length         (tx_rx_cfg_patA_length)          //-- output [1:0] 
 ,.tx_rx_cfg_patB_length         (tx_rx_cfg_patB_length)          //-- output [1:0] 
 ,.tx_rx_cfg_patA_hyst           (tx_rx_cfg_patA_hyst)            //-- output [3:0] 
 ,.tx_rx_cfg_patB_hyst           (tx_rx_cfg_patB_hyst)            //-- output [3:0]     
 ,.tx_rx_rx_BEI_inject           (tx_rx_rx_BEI_inject[7:0])       //-- output [7:0]
 ,.tx_rx_start_retrain           (tx_rx_start_retrain)            //-- output
 ,.tx_rx_inj_pty_err             (tx_rx_inj_pty_err)              //-- output
 ,.rx_tx_mn_trn_in_replay        (rx_tx_mn_trn_in_replay)         //-- input
 ,.tx_rx_half_width              (tx_rx_half_width)               //-- output
 ,.tx_rx_quarter_width           (tx_rx_quarter_width)            //-- output
 ,.tx_rx_cfg_disable_rx_lanes    (tx_rx_cfg_disable_rx_lanes[7:0])//-- output[7:0]
 ,.tx_rx_PM_rx_lanes_disable     (tx_rx_PM_rx_lanes_disable[7:0]) //-- output[7:0]
 ,.tx_rx_PM_rx_lanes_enable      (tx_rx_PM_rx_lanes_enable[7:0])  //-- output[7:0]
 ,.tx_rx_PM_deskew_reset         (tx_rx_PM_deskew_reset)          //-- output
 ,.tx_rx_psave_sts_off           (tx_rx_psave_sts_off)            //-- output
 ,.tx_rx_retrain_not_due2_PM     (tx_rx_retrain_not_due2_PM)      //-- output
 ,.tx_rx_cfg_version             (tx_rx_cfg_version[5:0])         //-- output [5:0]
 ,.tx_rx_enable_short_idle       (tx_rx_enable_short_idle)        //-- output
 ,.tx_rx_cfg_sync_mode           (tx_rx_cfg_sync_mode)            //-- output
 ,.tx_rx_sim_only_fast_train     (tx_rx_sim_only_fast_train)      //-- output
 ,.tx_rx_sim_only_request_ln_rev (tx_rx_sim_only_request_ln_rev)  //-- output
 ,.reg_dl_config0                (reg_dl_config0[63:0])           //-- input[63:0]
 ,.reg_dl_config1                (reg_dl_config1[63:0])           //-- input[63:0]
 ,.reg_dl_error_message          (reg_dl_error_message[3:0])      //-- input[3:0]
 ,.reg_dl_link_down              (reg_dl_link_down)               //-- input
 ,.reg_dl_cya_bits               (reg_dl_cya_bits[31:0])          //-- input[31:0]
 ,.flt_trn_reset_hammer          (flt_trn_reset_hammer)           //-- input
 ,.flt_trn_retrain_hammer        (flt_trn_retrain_hammer)         //-- input
 ,.flt_trn_retrain_rply          (flt_trn_retrain_rply)           //-- input
 ,.flt_trn_retrain_no_rply       (flt_trn_retrain_no_rply)        //-- input
 ,.tl2dl_tl_error                (tl2dl_tl_error)                 //-- input
 ,.tl2dl_tl_event                (tl2dl_tl_event)                 //-- input
 ,.dl_reg_errors                 (dl_reg_errors[47:0])            //-- output[47:0]
 ,.dl_reg_rmt_message            (dl_reg_rmt_message[63:0])       //-- output[63:0]
 ,.dl_reg_edpl_max_count         (dl_reg_edpl_max_count[63:0])    //-- output[63:0]
 ,.dl_reg_status                 (dl_reg_status[63:0])            //-- output[63:0]
 ,.dl_reg_training_status        (dl_reg_training_status[63:0 ])  //-- output[63:0]
 ,.dl_reg_error_capture          (dl_reg_error_capture[62:0])     //-- output[62:0]
 ,.reg_dl_err_cap_reset          (reg_dl_err_cap_reset)           //-- input
 ,.dl_reg_trace_data             (dl_reg_trace_data[87:0])        //-- output[87:0]
 ,.dl_reg_trace_trig             (dl_reg_trace_trig[1:0])         //-- output[1:0]
 ,.dl_reg_perf_mon               (dl_reg_perf_mon[11:0])          //-- output[11:0]
 ,.dl_phy_iobist_prbs_error      (dl_phy_iobist_prbs_error[7:0])  //-- output[7:0]
 ,.trn_flt_train_done            (trn_flt_train_done)             //-- output
 ,.trn_flt_tsm4                  (trn_flt_tsm4)                   //-- output
 ,.trn_agn_train_done            (trn_agn_train_done)             //-- output
 ,.trn_agn_half_width            (trn_agn_half_width)             //-- output
 ,.trn_agn_ln_swap               (trn_agn_ln_swap)                //-- output
 ,.trn_agn_x2_mode               (trn_agn_x2_mode[1:0])           //-- output [1:0]
 ,.trn_agn_x4_mode               (trn_agn_x4_mode[1:0])           //-- output [1:0]
 ,.trn_flt_x2_tx_mode            (trn_flt_x2_tx_mode)             //-- output
 ,.trn_flt_x4_tx_mode            (trn_flt_x4_tx_mode)             //-- output
 ,.trn_flt_x8_tx_mode            (trn_flt_x8_tx_mode)             //-- output
 ,.trn_flt_recal_state           (trn_flt_recal_state[1:0])       //-- output
 ,.trn_flt_send_pm_msg           (trn_flt_send_pm_msg)            //-- output
 ,.trn_flt_pm_narrow_not_wide    (trn_flt_pm_narrow_not_wide)     //-- output      only valid when trn_flt_send_pm_msg is active (high)
 ,.flt_trn_pm_msg_sent           (flt_trn_pm_msg_sent)            //-- input
 ,.trn_flt_pm_msg                (trn_flt_pm_msg[3:0])            //-- output
 ,.trn_flt_link_errors           (trn_flt_link_errors)            //-- output[7:0]
 ,.trn_flt_enable_short_idle     (trn_flt_enable_short_idle)      //-- output
 ,.trn_flt_enable_fast_path      (trn_flt_enable_fast_path)       //-- output
 ,.trn_flt_inj_ecc_ce            (trn_flt_inj_ecc_ce)             //-- output
 ,.trn_flt_inj_ecc_ue            (trn_flt_inj_ecc_ue)             //-- output
 ,.trn_flt_rpb_rm_depth          (trn_flt_rpb_rm_depth[3:0])      //-- output [3:0]
 ,.trn_flt_1us_tick              (trn_flt_1us_tick)               //-- output
 ,.trn_flt_tl_credits            (trn_flt_tl_credits[5:0])        //-- output [5:0]
 ,.trn_flt_macro_dbg_sel         (trn_flt_macro_dbg_sel[3:0])     //-- output [3:0]
 ,.tx_rx_macro_dbg_sel           (tx_rx_macro_dbg_sel[3:0])       //-- output [3:0]
 ,.flt_trn_in_replay             (flt_trn_in_replay)              //-- input
 ,.all_tx_credits_returned       (all_tx_credits_returned)        //-- input
 ,.flt_trn_no_fwd_prog           (flt_trn_no_fwd_prog)            //-- input
 ,.flt_trn_fp_start              (flt_trn_fp_start)               //-- input
 ,.flt_trn_rpl_data_flt          (flt_trn_rpl_data_flt)           //-- input
 ,.flt_trn_data_flt              (flt_trn_data_flt)               //-- input
 ,.flt_trn_ctl_flt               (flt_trn_ctl_flt)                //-- input
 ,.flt_trn_rpl_flt               (flt_trn_rpl_flt)                //-- input
 ,.flt_trn_idle_flt              (flt_trn_idle_flt)               //-- input
 ,.flt_trn_ue_rpb_df             (flt_trn_ue_rpb_df)              //-- input
 ,.flt_trn_ue_frb_df             (flt_trn_ue_frb_df)              //-- input
 ,.flt_trn_ce_rpb                (flt_trn_ce_rpb)                 //-- input
 ,.flt_trn_ce_frb                (flt_trn_ce_frb)                 //-- input
 ,.flt_trn_data_pty_err          (flt_trn_data_pty_err)           //-- input
 ,.flt_trn_tl_trunc              (flt_trn_tl_trunc)               //-- input
 ,.flt_trn_tl_rl_err             (flt_trn_tl_rl_err)              //-- input
 ,.flt_trn_ack_ptr_err           (flt_trn_ack_ptr_err)            //-- input
 ,.flt_trn_ue_rpb_cf             (flt_trn_ue_rpb_cf)              //-- input
 ,.flt_trn_ue_frb_cf             (flt_trn_ue_frb_cf)              //-- input
 ,.flt_trn_dbg_tx_info           (flt_trn_dbg_tx_info[87:0])      //-- input [87:0]
 ,.trn_agn_training              (trn_agn_training)               //-- output
 ,.trn_agn_training_set          (trn_agn_training_set[127:0])    //-- output[127:0]
 ,.trn_agn_stall                 (trn_agn_stall)                  //-- output
 ,.trn_agn_send_TS1              (trn_agn_send_TS1[7:0])          //-- output[7:0]
 ,.trn_agn_PM_store_reset        (trn_agn_PM_store_reset)         //-- output
 ,.trn_flt_stall                 (trn_flt_stall)                  //-- output
 ,.trn_flt_real_stall            (trn_flt_real_stall)             //-- output
 ,.trn_ln0_scrambler             (trn_ln0_scrambler[15:0])        //-- output[15:0]
 ,.trn_ln1_scrambler             (trn_ln1_scrambler[15:0])        //-- output[15:0]
 ,.trn_ln2_scrambler             (trn_ln2_scrambler[15:0])        //-- output[15:0]
 ,.trn_ln3_scrambler             (trn_ln3_scrambler[15:0])        //-- output[15:0]
 ,.trn_ln4_scrambler             (trn_ln4_scrambler[15:0])        //-- output[15:0]
 ,.trn_ln5_scrambler             (trn_ln5_scrambler[15:0])        //-- output[15:0]
 ,.trn_ln6_scrambler             (trn_ln6_scrambler[15:0])        //-- output[15:0]
 ,.trn_ln7_scrambler             (trn_ln7_scrambler[15:0])        //-- output[15:0]
 ,.trn_ln_train_data             (trn_ln_train_data[15:0])        //-- output[15:0]
 ,.trn_ln_reverse                (trn_ln_reverse)                 //-- output
 ,.trn_ln_disable                (trn_ln_disable[7:0])            //-- output
 ,.trn_ln_phy_training           (trn_ln_phy_training[7:0])       //-- output [7:0]
 ,.trn_ln_dl_training            (trn_ln_dl_training[7:0])        //-- output [7:0]
 ,.trn_ln_tx_EDPL_ena            (trn_ln_tx_EDPL_ena)             //-- output
 ,.trn_ln_tx_BEI_inject          (trn_ln_tx_BEI_inject[7:0])      //-- output [7:0]
 ,.trn_reset_n                   (trn_reset_n)                    //-- output
 ,.reg_dl_edpl_max_count_reset   (reg_dl_edpl_max_count_reset  )  //-- input
 ,.reg_dl_1us_tick               (reg_dl_1us_tick)                //-- input
 ,.reg_dl_100ms_tick             (reg_dl_100ms_tick)              //-- input
 ,.reg_dl_recal_start            (reg_dl_recal_start)             //-- input
 ,.trn_enable                    (trn_enable)                     //-- output
 ,.global_trace_enable           (global_trace_enable)            //-- input
 ,.omi_enable_out                (omi_enable_int)                 //-- output
 ,.chip_reset                    (chip_reset)                     //-- input
 ,.global_reset_control          (global_reset_control)           //-- input
 ,.sync_mode                     (sync_mode)                      //-- input
 ,.dl_clk                        (dl_clk)                         //-- input
);

            
dlc_omi_tx_flit flt (
  .tl2dl_flit_early_vld (tl2dl_flit_early_vld)             //-- input
 ,.tl2dl_flit_vld       (tl2dl_flit_vld)                   //-- input
 ,.tl2dl_flit_data      (tl2dl_flit_data[127:0])           //-- input[127:0]
 ,.tl2dl_flit_ecc       (tl2dl_flit_ecc[15:0])             //-- input[15:0]
 ,.tl2dl_flit_lbip_vld  (tl2dl_flit_lbip_vld)              //-- input
 ,.tl2dl_flit_lbip_data (tl2dl_flit_lbip_data[81:0])       //-- input[81:0]
// ,.tl2dl_flit_lbip_ecc  (tl2dl_flit_lbip_ecc[15:0])        //-- input[15:0]
 ,.dl2tl_flit_credit    (dl2tl_flit_credit)                //-- output
 ,.dl2tl_link_up        (dl2tl_link_up)                    //-- output
 ,.rx_tx_crc_error      (rx_tx_crc_error)                  //-- input
 ,.rx_tx_nack           (rx_tx_nack)                       //-- input
 ,.rx_tx_rx_ack_inc     (rx_tx_rx_ack_inc[3:0])            //-- input[3:0]
 ,.rx_tx_tx_ack_rtn     (rx_tx_tx_ack_rtn[4:0])            //-- input[4:0]
 ,.rx_tx_tx_ack_ptr_vld (rx_tx_tx_ack_ptr_vld)             //-- input
 ,.rx_tx_tx_ack_ptr     (rx_tx_tx_ack_ptr[11:0])            //-- input[6:0]
 ,.rx_link_up           (rx_link_up)                       //-- input
 ,.flt_stall            (trn_flt_stall)                    //-- input
 ,.trn_flt_x2_tx_mode   (trn_flt_x2_tx_mode)               //-- input
 ,.trn_flt_x4_tx_mode   (trn_flt_x4_tx_mode)               //-- input
 ,.trn_flt_x8_tx_mode   (trn_flt_x8_tx_mode)               //-- input
 ,.trn_flt_real_stall            (trn_flt_real_stall)             //-- input
 ,.trn_flt_recal_state  (trn_flt_recal_state[1:0])         //-- input
 ,.trn_flt_send_pm_msg           (trn_flt_send_pm_msg)            //-- input
 ,.trn_flt_pm_narrow_not_wide    (trn_flt_pm_narrow_not_wide)     //-- input      only valid when trn_flt_send_pm_msg is active (high)
 ,.flt_trn_pm_msg_sent           (flt_trn_pm_msg_sent)            //-- output
 ,.trn_flt_pm_msg                (trn_flt_pm_msg[3:0])            //-- input
 ,.enable_short_idle    (trn_flt_enable_short_idle)        //-- input
 ,.enable_fastpath     (trn_flt_enable_fast_path)          //-- input
 ,.all_tx_credits_returned (all_tx_credits_returned)       //-- output
 ,.trn_flt_link_errors  (trn_flt_link_errors[7:0])         //-- input[7:0]
 ,.frbuf_wr_en          (frbuf_wr_en)                      //-- output 
 ,.frbuf_wr_addr        (frbuf_wr_addr[7:0])               //-- output[7:0]
 ,.frbuf_wr_data        (frbuf_wr_data[143:0])             //-- output[143:0]
 ,.frbuf_rd0_en         (frbuf_rd0_en)                     //-- output
 ,.frbuf_rd0_addr       (frbuf_rd0_addr[7:0])              //-- output[7:0]
 ,.frbuf_rd0_data       (frbuf_rd0_data[143:0])            //-- input[143:0]
 ,.frbuf_rd1_en         (frbuf_rd1_en)                     //-- output
 ,.frbuf_rd1_addr       (frbuf_rd1_addr[7:0])              //-- output[7:0]
 ,.frbuf_rd1_data       (frbuf_rd1_data[143:0])            //-- input[143:0]
 ,.frbuf_rd0_select_pair0_d1  (frbuf_rd0_select_pair0_d1)  //-- output
 ,.frbuf_rd0_select_pair1_d1  (frbuf_rd0_select_pair1_d1)  //-- output
 ,.reg_rmt_write        (reg_rmt_write)                    //-- input[31:0]
 ,.reg_rmt_config       (reg_rmt_config[31:0])             //-- input[31:0]
 ,.flt_agn_data         (flt_agn_data[127:0])              //-- output[127:0]
 //-- ,.flt_agn_fp_vld       (flt_agn_fp_vld)                   //-- output
 //-- ,.flt_agn_use_ngbr     (flt_agn_use_ngbr)                 //-- output
 ,.trn_flt_train_done   (trn_flt_train_done)               //-- input
 ,.trn_flt_tl_credits   (trn_flt_tl_credits)               //-- input
 ,.trn_flt_macro_dbg_sel(trn_flt_macro_dbg_sel[3:0])       //-- input :  ADD I/O
 ,.dl_clk               (dl_clk)                           //-- input
 ,.dlc_reset_n          (trn_reset_n)                      //-- input
 ,.chip_reset           (chip_reset)                       //-- input
 ,.global_reset_control (global_reset_control )            //-- input
 ,.flt_trn_reset_hammer (flt_trn_reset_hammer)             //-- output
 ,.flt_trn_retrain_hammer (flt_trn_retrain_hammer)         //-- output
 ,.flt_trn_retrain_rply (flt_trn_retrain_rply)             //--  output
 ,.flt_trn_retrain_no_rply (flt_trn_retrain_no_rply)       //--  output
 ,.reg_dl_cya_bits      (reg_dl_cya_bits[31:0])            //-- input[31:0]
 ,.flt_trn_no_fwd_prog  (flt_trn_no_fwd_prog  )            //-- output
 ,.flt_trn_fp_start     (flt_trn_fp_start     )            //-- output
 ,.flt_trn_rpl_data_flt (flt_trn_rpl_data_flt )            //-- output
 ,.flt_trn_data_flt     (flt_trn_data_flt     )            //-- output
 ,.flt_trn_ctl_flt      (flt_trn_ctl_flt      )            //-- output
 ,.flt_trn_rpl_flt      (flt_trn_rpl_flt      )            //-- output
 ,.flt_trn_idle_flt     (flt_trn_idle_flt     )            //-- output
 ,.flt_trn_ue_rpb_df    (flt_trn_ue_rpb_df    )            //-- output
 ,.flt_trn_ue_frb_df    (flt_trn_ue_frb_df    )            //-- output
 ,.flt_trn_ce_rpb       (flt_trn_ce_rpb       )            //-- output
 ,.flt_trn_ce_frb       (flt_trn_ce_frb       )            //-- output
 ,.flt_trn_data_pty_err (flt_trn_data_pty_err )            //-- output
 ,.flt_trn_tl_trunc     (flt_trn_tl_trunc     )            //-- output
 ,.flt_trn_tl_rl_err    (flt_trn_tl_rl_err    )            //-- output
 ,.flt_trn_ack_ptr_err  (flt_trn_ack_ptr_err  )            //-- output
 ,.flt_trn_ue_rpb_cf    (flt_trn_ue_rpb_cf    )            //-- output
 ,.flt_trn_ue_frb_cf    (flt_trn_ue_frb_cf    )            //-- output
 ,.flt_trn_dbg_tx_info  (flt_trn_dbg_tx_info  )            //-- output  
 ,.flt_trn_in_replay    (flt_trn_in_replay    )            //-- output
 ,.trn_flt_tsm4         (trn_flt_tsm4         )            //-- input
 ,.trn_flt_tsm          (tx_tsm[2:0]          )            //-- input
 ,.trn_flt_inj_ecc_ce   (trn_flt_inj_ecc_ce   )            //-- input
 ,.trn_flt_inj_ecc_ue   (trn_flt_inj_ecc_ue   )            //-- input
 ,.trn_flt_rpb_rm_depth (trn_flt_rpb_rm_depth )            //-- input
 ,.omi_enable           (omi_enable_int       )            //-- input
 ,.reg_dl_1us_tick      (trn_flt_1us_tick     )            //-- input, use latched version for timing

 );

 dlc_omi_tx_align #(.RX_EQ_TX_CLK(RX_EQ_TX_CLK)) agn (
  .flt_agn_data              (flt_agn_data[127:0])            //-- input[127:0]
 ,.trn_agn_train_done        (trn_agn_train_done)             //-- input
 ,.trn_agn_half_width        (trn_agn_half_width)             //-- input
 ,.trn_agn_ln_swap           (trn_agn_ln_swap)                //-- input
 ,.trn_agn_x2_mode           (trn_agn_x2_mode[1:0])           //-- input [1:0]
 ,.trn_agn_x4_mode           (trn_agn_x4_mode[1:0])           //-- input [1:0]
 ,.trn_agn_training          (trn_agn_training)               //-- input
 ,.trn_agn_training_set      (trn_agn_training_set[127:0])    //-- input[127:0]
 ,.trn_agn_stall             (trn_agn_stall)                  //-- input
 ,.trn_agn_send_TS1          (trn_agn_send_TS1[7:0])          //-- input [7:0]
 ,.trn_agn_PM_store_reset    (trn_agn_PM_store_reset)         //-- input
 ,.agn_ln7_next_2B           (agn_ln7_next_2B)                //-- output [15:0]
 ,.agn_ln6_next_2B           (agn_ln6_next_2B)                //-- output [15:0]
 ,.agn_ln5_next_2B           (agn_ln5_next_2B)                //-- output [15:0]
 ,.agn_ln4_next_2B           (agn_ln4_next_2B)                //-- output [15:0]
 ,.agn_ln3_next_2B           (agn_ln3_next_2B)                //-- output [15:0]
 ,.agn_ln2_next_2B           (agn_ln2_next_2B)                //-- output [15:0]
 ,.agn_ln1_next_2B           (agn_ln1_next_2B)                //-- output [15:0]
 ,.agn_ln0_next_2B           (agn_ln0_next_2B)                //-- output [15:0]
 ,.trn_reset_n               (trn_reset_n)                    //-- input
 ,.chip_reset                (chip_reset)                    //-- input
 ,.global_reset_control      (global_reset_control )    //-- input
 ,.trn_enable                (trn_enable)                     //-- input
 ,.dl_clk                    (dl_clk)                         //-- input
 );

 dlc_omi_tx_lane ln0 (
  .agn_ln_next_2B            (agn_ln0_next_2B[15:0])        //-- input[15:0]
 ,.trn_ln_scrambler          (trn_ln0_scrambler[15:0])      //-- input[15:0]
 ,.trn_ln_train_data         (trn_ln_train_data[15:0])      //-- input[15:0]
 ,.trn_ln_reverse            (trn_ln_reverse)               //-- input
 ,.trn_ln_disable            (trn_ln_disable[0])            //-- input
 ,.trn_ln_phy_training       (trn_ln_phy_training[0])       //-- input
 ,.trn_ln_dl_training        (trn_ln_dl_training[0])        //-- input
 ,.trn_ln_tx_EDPL_ena        (trn_ln_tx_EDPL_ena)           //-- input
 ,.trn_ln_tx_BEI_inject      (trn_ln_tx_BEI_inject[0])      //-- output     
 ,.dl_phy_lane               (dl_phy_lane_0[15:0])          //-- output[15:0]
 ,.trn_reset_n               (trn_reset_n)                  //-- input
 ,.chip_reset                (chip_reset)                   //-- input
 ,.global_reset_control      (global_reset_control)         //-- input
 ,.trn_enable                (trn_enable)                   //-- input
 ,.dl_clk                    (dl_clk)                       //-- input
 );

 dlc_omi_tx_lane ln1 (
  .agn_ln_next_2B            (agn_ln1_next_2B[15:0])        //-- input[15:0]
 ,.trn_ln_scrambler          (trn_ln1_scrambler[15:0])      //-- input[15:0]
 ,.trn_ln_train_data         (trn_ln_train_data[15:0])      //-- input[15:0]
 ,.trn_ln_reverse            (trn_ln_reverse)               //-- input
 ,.trn_ln_disable            (trn_ln_disable[1])            //-- input
 ,.trn_ln_phy_training       (trn_ln_phy_training[1])       //-- input
 ,.trn_ln_dl_training        (trn_ln_dl_training[1])        //-- input
 ,.trn_ln_tx_EDPL_ena        (trn_ln_tx_EDPL_ena)           //-- input
 ,.trn_ln_tx_BEI_inject      (trn_ln_tx_BEI_inject[1])      //-- output     
 ,.dl_phy_lane               (dl_phy_lane_1[15:0])          //-- output[15:0]
 ,.trn_reset_n               (trn_reset_n)                  //-- input
 ,.chip_reset                (chip_reset)                   //-- input
 ,.global_reset_control      (global_reset_control)         //-- input
 ,.trn_enable                (trn_enable)                   //-- input
 ,.dl_clk                    (dl_clk)                       //-- input
 );

 dlc_omi_tx_lane ln2 (
  .agn_ln_next_2B            (agn_ln2_next_2B[15:0])        //-- input[15:0]
 ,.trn_ln_scrambler          (trn_ln2_scrambler[15:0])      //-- input[15:0]
 ,.trn_ln_train_data         (trn_ln_train_data[15:0])      //-- input[15:0]
 ,.trn_ln_reverse            (trn_ln_reverse)               //-- input
 ,.trn_ln_disable            (trn_ln_disable[2])            //-- input
 ,.trn_ln_phy_training       (trn_ln_phy_training[2])       //-- input
 ,.trn_ln_dl_training        (trn_ln_dl_training[2])        //-- input
 ,.trn_ln_tx_EDPL_ena        (trn_ln_tx_EDPL_ena)           //-- input
 ,.trn_ln_tx_BEI_inject      (trn_ln_tx_BEI_inject[2])      //-- output     
 ,.dl_phy_lane               (dl_phy_lane_2[15:0])          //-- output[15:0]
 ,.trn_reset_n               (trn_reset_n)                  //-- input
 ,.chip_reset                (chip_reset)                   //-- input
 ,.global_reset_control      (global_reset_control)         //-- input
 ,.trn_enable                (trn_enable)                   //-- input
 ,.dl_clk                    (dl_clk)                       //-- input
 );

 dlc_omi_tx_lane ln3 (
  .agn_ln_next_2B            (agn_ln3_next_2B[15:0])        //-- input[15:0]
 ,.trn_ln_scrambler          (trn_ln3_scrambler[15:0])      //-- input[15:0]
 ,.trn_ln_train_data         (trn_ln_train_data[15:0])      //-- input[15:0]
 ,.trn_ln_reverse            (trn_ln_reverse)               //-- input
 ,.trn_ln_disable            (trn_ln_disable[3])            //-- input
 ,.trn_ln_phy_training       (trn_ln_phy_training[3])       //-- input
 ,.trn_ln_dl_training        (trn_ln_dl_training[3])        //-- input
 ,.trn_ln_tx_EDPL_ena        (trn_ln_tx_EDPL_ena)           //-- input
 ,.trn_ln_tx_BEI_inject      (trn_ln_tx_BEI_inject[3])      //-- output     
 ,.dl_phy_lane               (dl_phy_lane_3[15:0])          //-- output[15:0]
 ,.trn_reset_n               (trn_reset_n)                  //-- input
 ,.chip_reset                (chip_reset)                   //-- input
 ,.global_reset_control      (global_reset_control )        //-- input
 ,.trn_enable                (trn_enable)                   //-- input
 ,.dl_clk                    (dl_clk)                       //-- input
 );

 dlc_omi_tx_lane ln4 (
  .agn_ln_next_2B            (agn_ln4_next_2B[15:0])        //-- input[15:0]
 ,.trn_ln_scrambler          (trn_ln4_scrambler[15:0])      //-- input[15:0]
 ,.trn_ln_train_data         (trn_ln_train_data[15:0])      //-- input[15:0]
 ,.trn_ln_reverse            (trn_ln_reverse)               //-- input
 ,.trn_ln_disable            (trn_ln_disable[4])            //-- input
 ,.trn_ln_phy_training       (trn_ln_phy_training[4])       //-- input
 ,.trn_ln_dl_training        (trn_ln_dl_training[4])        //-- input
 ,.trn_ln_tx_EDPL_ena        (trn_ln_tx_EDPL_ena)           //-- input
 ,.trn_ln_tx_BEI_inject      (trn_ln_tx_BEI_inject[4])      //-- output     
 ,.dl_phy_lane               (dl_phy_lane_4[15:0])          //-- output[15:0]
 ,.trn_reset_n               (trn_reset_n)                  //-- input
 ,.chip_reset                (chip_reset)                   //-- input
 ,.global_reset_control      (global_reset_control )        //-- input
 ,.trn_enable                (trn_enable)                   //-- input
 ,.dl_clk                    (dl_clk)                       //-- input
 );

 dlc_omi_tx_lane ln5 (
  .agn_ln_next_2B            (agn_ln5_next_2B[15:0])         //-- input[15:0]
 ,.trn_ln_scrambler          (trn_ln5_scrambler[15:0])       //-- input[15:0]
 ,.trn_ln_train_data         (trn_ln_train_data[15:0])       //-- input[15:0]
 ,.trn_ln_reverse            (trn_ln_reverse)                //-- input
 ,.trn_ln_disable            (trn_ln_disable[5])             //-- input
 ,.trn_ln_phy_training       (trn_ln_phy_training[5])        //-- input
 ,.trn_ln_dl_training        (trn_ln_dl_training[5])         //-- input
 ,.trn_ln_tx_EDPL_ena        (trn_ln_tx_EDPL_ena)            //-- input
 ,.trn_ln_tx_BEI_inject      (trn_ln_tx_BEI_inject[5])       //-- output     
 ,.dl_phy_lane               (dl_phy_lane_5[15:0])           //-- output[15:0]
 ,.trn_reset_n               (trn_reset_n)                   //-- input
 ,.chip_reset                (chip_reset)                    //-- input
 ,.global_reset_control      (global_reset_control )         //-- input
 ,.trn_enable                (trn_enable)                    //-- input
 ,.dl_clk                    (dl_clk)                        //-- input
 );

 dlc_omi_tx_lane ln6 (
  .agn_ln_next_2B            (agn_ln6_next_2B[15:0])         //-- input[15:0]
 ,.trn_ln_scrambler          (trn_ln6_scrambler[15:0])       //-- input[15:0]
 ,.trn_ln_train_data         (trn_ln_train_data[15:0])       //-- input[15:0]
 ,.trn_ln_reverse            (trn_ln_reverse)                //-- input
 ,.trn_ln_disable            (trn_ln_disable[6])             //-- input
 ,.trn_ln_phy_training       (trn_ln_phy_training[6])        //-- input
 ,.trn_ln_dl_training        (trn_ln_dl_training[6])         //-- input
 ,.trn_ln_tx_EDPL_ena        (trn_ln_tx_EDPL_ena)            //-- input
 ,.trn_ln_tx_BEI_inject      (trn_ln_tx_BEI_inject[6])       //-- output     
 ,.dl_phy_lane               (dl_phy_lane_6[15:0])           //-- output[15:0]
 ,.trn_reset_n               (trn_reset_n)                   //-- input
 ,.chip_reset                (chip_reset)                    //-- input
 ,.global_reset_control      (global_reset_control )         //-- input
 ,.trn_enable                (trn_enable)                    //-- input
 ,.dl_clk                    (dl_clk)                        //-- input
 );

 dlc_omi_tx_lane ln7 (
  .agn_ln_next_2B            (agn_ln7_next_2B[15:0])         //-- input[15:0]
 ,.trn_ln_scrambler          (trn_ln7_scrambler[15:0])       //-- input[15:0]
 ,.trn_ln_train_data         (trn_ln_train_data[15:0])       //-- input[15:0]
 ,.trn_ln_reverse            (trn_ln_reverse)                //-- input
 ,.trn_ln_disable            (trn_ln_disable[7])             //-- input
 ,.trn_ln_phy_training       (trn_ln_phy_training[7])        //-- input
 ,.trn_ln_dl_training        (trn_ln_dl_training[7])         //-- input
 ,.trn_ln_tx_EDPL_ena        (trn_ln_tx_EDPL_ena)            //-- input
 ,.trn_ln_tx_BEI_inject      (trn_ln_tx_BEI_inject[7])       //-- output     
 ,.dl_phy_lane               (dl_phy_lane_7[15:0])           //-- output[15:0]
 ,.trn_reset_n               (trn_reset_n)                   //-- input
 ,.chip_reset                (chip_reset)                    //-- input
 ,.global_reset_control      (global_reset_control )         //-- input
 ,.trn_enable                (trn_enable)                    //-- input
 ,.dl_clk                    (dl_clk)                        //-- input
 );

endmodule  // dlc_omi_tx
