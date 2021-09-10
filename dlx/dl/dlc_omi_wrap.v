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
//| &Module;
module dlc_omi_wrap #(
`ifndef EQ_CLOCKS
   parameter             RX_EQ_TX_CLOCK = 0
`else
   parameter             RX_EQ_TX_CLOCK = 1
`endif
)
(
//-- inputs from the TL
   tl2dl_flit_early_vld          //--  input  
 
  ,tl2dl_flit_vld                //--  input
  ,tl2dl_flit_data               //--  input[127:0]
  ,tl2dl_flit_ecc                //--  input[15:0]
  ,tl2dl_flit_lbip_vld           //--  input
  ,tl2dl_flit_lbip_data          //--  input[81:0]
//  ,tl2dl_flit_lbip_ecc           //--  input[15:0]

  ,dl2tl_flit_credit             //--  output
  ,tl2dl_lane_width_request      //--  input[1:0]
  ,dl2tl_lane_width_status       //--  output[1:0]

//-- outputs to the TL            
  ,dl2tl_dead_cycle              //--  output
  ,dl2tl_flit_vld                //--  output
  ,dl2tl_flit_error              //--  output
  ,dl2tl_flit_badcrc             //--  output
  ,dl2tl_flit_data               //--  output[127:0]
  ,dl2tl_flit_pty                //--  output[15:0]
  ,dl2tl_link_up                 //--  output
  ,dl2tl_idle_transition         //--  output
  ,dl2tl_fast_act_info           //--  output[34:0]
  ,dl2tl_idle_transition_l       //--  output
  ,dl2tl_fast_act_info_l         //--  output[34:0]
  ,dl2tl_idle_transition_r       //--  output
  ,dl2tl_fast_act_info_r         //--  output[34:0]
  ,dl2tl_flit_act                //--  output
  ,tl2dl_tl_error                //--  input
  ,tl2dl_tl_event                //--  input
//--  signals to the PHY
  ,dl_phy_lane_0                 //--  output[15:0]
  ,dl_phy_lane_1                 //--  output[15:0]
  ,dl_phy_lane_2                 //--  output[15:0]
  ,dl_phy_lane_3                 //--  output[15:0]
  ,dl_phy_lane_4                 //--  output[15:0]
  ,dl_phy_lane_5                 //--  output[15:0]
  ,dl_phy_lane_6                 //--  output[15:0]
  ,dl_phy_lane_7                 //--  output[15:0]
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
  ,phy_dl_clock_0                //--  input
  ,phy_dl_clock_1                //--  input
  ,phy_dl_clock_2                //--  input
  ,phy_dl_clock_3                //--  input
  ,phy_dl_clock_4                //--  input
  ,phy_dl_clock_5                //--  input
  ,phy_dl_clock_6                //--  input
  ,phy_dl_clock_7                //--  input
  ,phy_dl_lane_0                 //--  input[15:0]
  ,phy_dl_lane_1                 //--  input[15:0]
  ,phy_dl_lane_2                 //--  input[15:0]
  ,phy_dl_lane_3                 //--  input[15:0]
  ,phy_dl_lane_4                 //--  input[15:0]
  ,phy_dl_lane_5                 //--  input[15:0]
  ,phy_dl_lane_6                 //--  input[15:0]
  ,phy_dl_lane_7                 //--  input[15:0]
  ,phy_dl_iobist_reset           //--  input
  ,dl_phy_iobist_prbs_error      //--  output [7:0]
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

//-- FRBUF(Flit Replay BUFfer) interface
  ,frbuf_wr_en                   //--  output 
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
  ,reg_dl_1us_tick               //--  input
  ,reg_dl_100ms_tick             //--  input
  ,reg_dl_recal_start            //--  input

  ,dl_reg_errors                 //--  output [47:0]
  ,dl_reg_rmt_message            //--  output [63:0]
  ,dl_reg_status                 //--  output [63:0]
  ,dl_reg_training_status        //--  output [63:0]

  ,dl_reg_error_capture          //--  output [62:0]
  ,reg_dl_err_cap_reset          //--  input
  ,dl_reg_edpl_max_count         //--  output [63:0]
  ,reg_dl_edpl_max_count_reset   //--  input
  ,dl_reg_trace_data             //--  output [87:0]
  ,dl_reg_trace_trig             //--  output [1:0]
  ,dl_reg_perf_mon               //--  output [11:0]
  ,lbist_en_dc                   //--  input
  ,global_trace_enable           //--  input                                  
  ,dl_clk                        //--  input
  ,chip_reset                    //--  input
  ,global_reset_control          //--  input 
  ,sync_mode                     //--  input
);


input             tl2dl_flit_early_vld;
input             tl2dl_flit_vld;
input  [127:0]    tl2dl_flit_data;
input  [15:0]     tl2dl_flit_ecc;
input             tl2dl_flit_lbip_vld;
input  [81:0]     tl2dl_flit_lbip_data;
//input  [15:0]     tl2dl_flit_lbip_ecc;
output [34:0]     dl2tl_fast_act_info;
output            dl2tl_idle_transition;
output [34:0]     dl2tl_fast_act_info_l;
output            dl2tl_idle_transition_l;
output [34:0]     dl2tl_fast_act_info_r;
output            dl2tl_idle_transition_r;
output            dl2tl_flit_credit;
input  [1:0]      tl2dl_lane_width_request;
output [1:0]      dl2tl_lane_width_status;
output            dl2tl_dead_cycle;
output            dl2tl_flit_vld;
output            dl2tl_flit_error;
output            dl2tl_flit_badcrc;
output [127:0]    dl2tl_flit_data;
output [15:0]     dl2tl_flit_pty;
output            dl2tl_link_up;
output            dl2tl_flit_act;
input             tl2dl_tl_error;
input             tl2dl_tl_event;
input             phy_dl_clock_0;
input             phy_dl_clock_1;
input             phy_dl_clock_2;
input             phy_dl_clock_3;
input             phy_dl_clock_4;
input             phy_dl_clock_5;
input             phy_dl_clock_6;
input             phy_dl_clock_7;
input  [15:0]     phy_dl_lane_0;
input  [15:0]     phy_dl_lane_1;
input  [15:0]     phy_dl_lane_2;
input  [15:0]     phy_dl_lane_3;
input  [15:0]     phy_dl_lane_4;
input  [15:0]     phy_dl_lane_5;
input  [15:0]     phy_dl_lane_6;
input  [15:0]     phy_dl_lane_7;
output [15:0]     dl_phy_lane_0;
output [15:0]     dl_phy_lane_1;
output [15:0]     dl_phy_lane_2;
output [15:0]     dl_phy_lane_3;
output [15:0]     dl_phy_lane_4;
output [15:0]     dl_phy_lane_5;
output [15:0]     dl_phy_lane_6;
output [15:0]     dl_phy_lane_7;
output            dl_phy_run_lane_0;
output            dl_phy_run_lane_1;
output            dl_phy_run_lane_2;
output            dl_phy_run_lane_3;
output            dl_phy_run_lane_4;
output            dl_phy_run_lane_5;
output            dl_phy_run_lane_6;
output            dl_phy_run_lane_7;
input             phy_dl_init_done_0;
input             phy_dl_init_done_1;
input             phy_dl_init_done_2;
input             phy_dl_init_done_3;
input             phy_dl_init_done_4;
input             phy_dl_init_done_5;
input             phy_dl_init_done_6;
input             phy_dl_init_done_7;
input             phy_dl_iobist_reset;
output [7:0]      dl_phy_iobist_prbs_error;
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
output            frbuf_wr_en;
output [7:0]      frbuf_wr_addr;
output [143:0]    frbuf_wr_data;
output            frbuf_rd0_en;
output [7:0]      frbuf_rd0_addr;
input  [143:0]    frbuf_rd0_data;
output            frbuf_rd1_en;
output [7:0]      frbuf_rd1_addr;
input  [143:0]    frbuf_rd1_data;
output            frbuf_rd0_select_pair0_d1; 
output            frbuf_rd0_select_pair1_d1; 
input  [63:0]     reg_dl_config0;
input  [63:0]     reg_dl_config1;
input  [3:0]      reg_dl_error_message;
input             reg_dl_link_down;
input             reg_rmt_write;
input  [31:0]     reg_rmt_config;
input  [31:0]     reg_dl_cya_bits;
input             reg_dl_1us_tick;
input             reg_dl_100ms_tick;
input             reg_dl_recal_start;
output [47:0]     dl_reg_errors;
output [63:0]     dl_reg_rmt_message;
output [63:0]     dl_reg_status;
output [63:0]     dl_reg_training_status;
output [62:0]     dl_reg_error_capture;
input             reg_dl_err_cap_reset;
output [63:0]     dl_reg_edpl_max_count;
input             reg_dl_edpl_max_count_reset;
output [1:0]      dl_reg_trace_trig;         
output [87:0]     dl_reg_trace_data;         
output [11:0]     dl_reg_perf_mon;
input             lbist_en_dc;
input             global_trace_enable;
input             dl_clk ;
input             chip_reset;
input             global_reset_control;
input             sync_mode;

wire           omi_enable;
wire           rx_link_up;
wire           rx_tx_crc_error;
wire           rx_tx_nack;
wire [3:0]     rx_tx_rx_ack_inc;
wire [4:0]     rx_tx_tx_ack_rtn;
wire           rx_tx_tx_ack_ptr_vld;
wire [11:0]    rx_tx_tx_ack_ptr;
wire [7:0]     rx_tx_rmt_error;
wire [63:0]    rx_tx_rmt_message;
wire [1:0]     rx_tx_recal_status;
wire [3:0]     rx_tx_pm_status;
wire           tx_rx_reset_n;
wire [2:0]     tx_rx_tsm;
wire [7:0]     tx_rx_phy_init_done;
wire [5:0]     rx_tx_version_number;
wire           rx_tx_slow_clock;
wire           rx_tx_deskew_overflow;
wire [72:0]    rx_tx_train_status;
wire [7:0]     rx_tx_disabled_rx_lanes;
wire [7:0]     rx_tx_disabled_tx_lanes;
wire           rx_tx_ts_valid;
wire [15:0]    rx_tx_ts_good_lanes;
wire           rx_tx_deskew_config_valid;
wire [18:0]    rx_tx_deskew_config;
wire           rx_tx_tx_ordering;
wire [3:0]     rx_tx_rem_supported_widths;
wire [3:0]     rx_tx_trained_mode;
wire [3:0]     tx_rx_cfg_supported_widths;
wire           rx_tx_tx_lane_swap;
wire           rx_tx_rem_PM_enable;
wire           rx_tx_rx_lane_reverse;
wire           rx_tx_lost_data_sync;
wire [87:0]    rx_tx_trn_dbg;
wire           rx_tx_training_sync_hdr;
wire [63:0]    rx_tx_EDPL_max_cnts;
wire [7:0]     rx_tx_EDPL_errors;
wire [7:0]     rx_tx_EDPL_thres_reached;
wire [4:0]     tx_rx_EDPL_cfg;
wire [1:0]     tx_rx_cfg_patA_length;
wire [1:0]     tx_rx_cfg_patB_length;
wire [3:0]     tx_rx_cfg_patA_hyst; 
wire [3:0]     tx_rx_cfg_patB_hyst;
wire [7:0]     tx_rx_rx_BEI_inject;
wire           tx_rx_start_retrain;
wire           tx_rx_half_width;
wire           tx_rx_quarter_width;
wire [7:0]     tx_rx_cfg_disable_rx_lanes;
wire [7:0]     tx_rx_PM_rx_lanes_disable;
wire [7:0]     tx_rx_PM_rx_lanes_enable;
wire           tx_rx_PM_deskew_reset;
wire           tx_rx_psave_sts_off;
wire           tx_rx_retrain_not_due2_PM;
wire [5:0]     tx_rx_cfg_version;
wire           tx_rx_enable_short_idle;
wire           tx_rx_cfg_sync_mode;
wire           tx_rx_sim_only_fast_train;
wire           tx_rx_sim_only_request_ln_rev;
wire           rx_tx_mn_trn_in_replay;  
wire           rx_tx_data_flt;          
wire           rx_tx_ctl_flt;           
wire           rx_tx_rpl_flt;           
wire           rx_tx_idle_flt;          
wire           rx_tx_ill_rl;               
wire [87:0]    rx_tx_dbg_rx_info;
wire [3:0]     tx_rx_macro_dbg_sel;
wire [7:0]     rx_tx_iobist_prbs_error;

dlc_omi_tx #(.RX_EQ_TX_CLK(RX_EQ_TX_CLOCK)) otx (
   .tl2dl_flit_early_vld          (tl2dl_flit_early_vld)           //--  input
  ,.tl2dl_flit_vld                (tl2dl_flit_vld)                 //--  input
  ,.tl2dl_flit_data               (tl2dl_flit_data[127:0])         //--  input  [127:0]
  ,.tl2dl_flit_ecc                (tl2dl_flit_ecc[15:0])           //--  input  [15:0]
  ,.tl2dl_flit_lbip_vld           (tl2dl_flit_lbip_vld)            //--  input
  ,.tl2dl_flit_lbip_data          (tl2dl_flit_lbip_data[81:0])     //--  input  [81:0]
//  ,.tl2dl_flit_lbip_ecc           (tl2dl_flit_lbip_ecc[15:0])      //--  input  [15:0]
  ,.dl2tl_link_up                 (dl2tl_link_up)                  //--  outout
  ,.tl2dl_tl_error                (tl2dl_tl_error)                 //--  input
  ,.tl2dl_tl_event                (tl2dl_tl_event)                 //--  input
  ,.dl2tl_flit_credit             (dl2tl_flit_credit)              //--  output
  ,.tl2dl_lane_width_request      (tl2dl_lane_width_request[1:0])  //--  input  [1:0]
  ,.dl2tl_lane_width_status       (dl2tl_lane_width_status[1:0])   //--  output [1:0]
  ,.dl_phy_lane_0                 (dl_phy_lane_0[15:0])            //--  output [15:0]
  ,.dl_phy_lane_1                 (dl_phy_lane_1[15:0])            //--  output [15:0]
  ,.dl_phy_lane_2                 (dl_phy_lane_2[15:0])            //--  output [15:0]
  ,.dl_phy_lane_3                 (dl_phy_lane_3[15:0])            //--  output [15:0]
  ,.dl_phy_lane_4                 (dl_phy_lane_4[15:0])            //--  output [15:0]
  ,.dl_phy_lane_5                 (dl_phy_lane_5[15:0])            //--  output [15:0]
  ,.dl_phy_lane_6                 (dl_phy_lane_6[15:0])            //--  output [15:0]
  ,.dl_phy_lane_7                 (dl_phy_lane_7[15:0])            //--  output [15:0]
  ,.dl_phy_run_lane_0             (dl_phy_run_lane_0)              //--  output
  ,.dl_phy_run_lane_1             (dl_phy_run_lane_1)              //--  output
  ,.dl_phy_run_lane_2             (dl_phy_run_lane_2)              //--  output
  ,.dl_phy_run_lane_3             (dl_phy_run_lane_3)              //--  output
  ,.dl_phy_run_lane_4             (dl_phy_run_lane_4)              //--  output
  ,.dl_phy_run_lane_5             (dl_phy_run_lane_5)              //--  output
  ,.dl_phy_run_lane_6             (dl_phy_run_lane_6)              //--  output
  ,.dl_phy_run_lane_7             (dl_phy_run_lane_7)              //--  output
  ,.phy_dl_init_done_0            (phy_dl_init_done_0)             //--  input
  ,.phy_dl_init_done_1            (phy_dl_init_done_1)             //--  input
  ,.phy_dl_init_done_2            (phy_dl_init_done_2)             //--  input
  ,.phy_dl_init_done_3            (phy_dl_init_done_3)             //--  input
  ,.phy_dl_init_done_4            (phy_dl_init_done_4)             //--  input
  ,.phy_dl_init_done_5            (phy_dl_init_done_5)             //--  input
  ,.phy_dl_init_done_6            (phy_dl_init_done_6)             //--  input
  ,.phy_dl_init_done_7            (phy_dl_init_done_7)             //--  input
  ,.dl_phy_recal_req_0            (dl_phy_recal_req_0)             //--  output
  ,.dl_phy_recal_req_1            (dl_phy_recal_req_1)             //--  output
  ,.dl_phy_recal_req_2            (dl_phy_recal_req_2)             //--  output
  ,.dl_phy_recal_req_3            (dl_phy_recal_req_3)             //--  output
  ,.dl_phy_recal_req_4            (dl_phy_recal_req_4)             //--  output
  ,.dl_phy_recal_req_5            (dl_phy_recal_req_5)             //--  output
  ,.dl_phy_recal_req_6            (dl_phy_recal_req_6)             //--  output
  ,.dl_phy_recal_req_7            (dl_phy_recal_req_7)             //--  output
  ,.phy_dl_recal_done_0           (phy_dl_recal_done_0)            //--  input
  ,.phy_dl_recal_done_1           (phy_dl_recal_done_1)            //--  input
  ,.phy_dl_recal_done_2           (phy_dl_recal_done_2)            //--  input
  ,.phy_dl_recal_done_3           (phy_dl_recal_done_3)            //--  input
  ,.phy_dl_recal_done_4           (phy_dl_recal_done_4)            //--  input
  ,.phy_dl_recal_done_5           (phy_dl_recal_done_5)            //--  input
  ,.phy_dl_recal_done_6           (phy_dl_recal_done_6)            //--  input
  ,.phy_dl_recal_done_7           (phy_dl_recal_done_7)            //--  input
  ,.dl_phy_rx_psave_req_0         (dl_phy_rx_psave_req_0)          //--  output
  ,.dl_phy_rx_psave_req_1         (dl_phy_rx_psave_req_1)          //--  output
  ,.dl_phy_rx_psave_req_2         (dl_phy_rx_psave_req_2)          //--  output
  ,.dl_phy_rx_psave_req_3         (dl_phy_rx_psave_req_3)          //--  output
  ,.dl_phy_rx_psave_req_4         (dl_phy_rx_psave_req_4)          //--  output
  ,.dl_phy_rx_psave_req_5         (dl_phy_rx_psave_req_5)          //--  output
  ,.dl_phy_rx_psave_req_6         (dl_phy_rx_psave_req_6)          //--  output
  ,.dl_phy_rx_psave_req_7         (dl_phy_rx_psave_req_7)          //--  output
  ,.phy_dl_rx_psave_sts_0         (phy_dl_rx_psave_sts_0)          //--  input
  ,.phy_dl_rx_psave_sts_1         (phy_dl_rx_psave_sts_1)          //--  input
  ,.phy_dl_rx_psave_sts_2         (phy_dl_rx_psave_sts_2)          //--  input
  ,.phy_dl_rx_psave_sts_3         (phy_dl_rx_psave_sts_3)          //--  input
  ,.phy_dl_rx_psave_sts_4         (phy_dl_rx_psave_sts_4)          //--  input
  ,.phy_dl_rx_psave_sts_5         (phy_dl_rx_psave_sts_5)          //--  input
  ,.phy_dl_rx_psave_sts_6         (phy_dl_rx_psave_sts_6)          //--  input
  ,.phy_dl_rx_psave_sts_7         (phy_dl_rx_psave_sts_7)          //--  input
  ,.dl_phy_tx_psave_req_0         (dl_phy_tx_psave_req_0)          //--  output
  ,.dl_phy_tx_psave_req_1         (dl_phy_tx_psave_req_1)          //--  output
  ,.dl_phy_tx_psave_req_2         (dl_phy_tx_psave_req_2)          //--  output
  ,.dl_phy_tx_psave_req_3         (dl_phy_tx_psave_req_3)          //--  output
  ,.dl_phy_tx_psave_req_4         (dl_phy_tx_psave_req_4)          //--  output
  ,.dl_phy_tx_psave_req_5         (dl_phy_tx_psave_req_5)          //--  output
  ,.dl_phy_tx_psave_req_6         (dl_phy_tx_psave_req_6)          //--  output
  ,.dl_phy_tx_psave_req_7         (dl_phy_tx_psave_req_7)          //--  output
  ,.phy_dl_tx_psave_sts_0         (phy_dl_tx_psave_sts_0)          //--  input
  ,.phy_dl_tx_psave_sts_1         (phy_dl_tx_psave_sts_1)          //--  input
  ,.phy_dl_tx_psave_sts_2         (phy_dl_tx_psave_sts_2)          //--  input
  ,.phy_dl_tx_psave_sts_3         (phy_dl_tx_psave_sts_3)          //--  input
  ,.phy_dl_tx_psave_sts_4         (phy_dl_tx_psave_sts_4)          //--  input
  ,.phy_dl_tx_psave_sts_5         (phy_dl_tx_psave_sts_5)          //--  input
  ,.phy_dl_tx_psave_sts_6         (phy_dl_tx_psave_sts_6)          //--  input
  ,.phy_dl_tx_psave_sts_7         (phy_dl_tx_psave_sts_7)          //--  input
  ,.rx_link_up                    (rx_link_up)                     //--  input
  ,.rx_tx_crc_error               (rx_tx_crc_error)                //--  input
  ,.rx_tx_nack                    (rx_tx_nack)                     //--  input
  ,.rx_tx_rx_ack_inc              (rx_tx_rx_ack_inc[3:0])          //--  input  [3:0]
  ,.rx_tx_tx_ack_rtn              (rx_tx_tx_ack_rtn[4:0])          //--  input  [4:0]
  ,.rx_tx_tx_ack_ptr_vld          (rx_tx_tx_ack_ptr_vld)           //--  input
  ,.rx_tx_tx_ack_ptr              (rx_tx_tx_ack_ptr[11:0])         //--  input  [11:0]
  ,.rx_tx_rmt_error               (rx_tx_rmt_error[7:0])           //--  input  [7:0]
  ,.rx_tx_rmt_message             (rx_tx_rmt_message[63:0])        //--  input  [63:0]
  ,.rx_tx_recal_status            (rx_tx_recal_status[1:0])        //--  input  [1:0]
  ,.rx_tx_pm_status               (rx_tx_pm_status[3:0])           //--  input  [3:0]
  ,.tx_rx_reset_n                 (tx_rx_reset_n)                  //--  output
  ,.tx_rx_tsm                     (tx_rx_tsm[2:0])                 //--  output [2:0]    
  ,.tx_rx_phy_init_done           (tx_rx_phy_init_done[7:0])       //--  output [7:0]
  ,.rx_tx_version_number          (rx_tx_version_number[5:0])      //--  input  [5:0]
  ,.rx_tx_slow_clock              (rx_tx_slow_clock)               //--  input
  ,.rx_tx_deskew_overflow         (rx_tx_deskew_overflow)          //--  input
  ,.rx_tx_train_status            (rx_tx_train_status[72:0])       //--  input  [72:0]
  ,.rx_tx_disabled_rx_lanes       (rx_tx_disabled_rx_lanes[7:0])   //--  input  [7:0]
  ,.frbuf_wr_en                   (frbuf_wr_en)                    //--  output 
  ,.frbuf_wr_addr                 (frbuf_wr_addr[7:0])             //--  output[7:0]
  ,.frbuf_wr_data                 (frbuf_wr_data[143:0])           //--  output[143:0]
  ,.frbuf_rd0_en                  (frbuf_rd0_en)                   //--  output
  ,.frbuf_rd0_addr                (frbuf_rd0_addr[7:0])            //--  output[7:0]
  ,.frbuf_rd0_data                (frbuf_rd0_data[143:0])          //--  input[143:0]
  ,.frbuf_rd1_en                  (frbuf_rd1_en)                   //--  output
  ,.frbuf_rd1_addr                (frbuf_rd1_addr[7:0])            //--  output[7:0]
  ,.frbuf_rd1_data                (frbuf_rd1_data[143:0])          //--  input[143:0]
  ,.frbuf_rd0_select_pair0_d1     (frbuf_rd0_select_pair0_d1)      //--  output
  ,.frbuf_rd0_select_pair1_d1     (frbuf_rd0_select_pair1_d1)      //--  output
  ,.rx_tx_disabled_tx_lanes       (rx_tx_disabled_tx_lanes[7:0])   //--  input  [7:0]
  ,.rx_tx_ts_valid                (rx_tx_ts_valid)                 //--  input
  ,.rx_tx_ts_good_lanes           (rx_tx_ts_good_lanes[15:0])      //--  input [15:0]
  ,.rx_tx_deskew_config_valid     (rx_tx_deskew_config_valid)      //--  input
  ,.rx_tx_deskew_config           (rx_tx_deskew_config[18:0])      //--  input [18:0]      
  ,.rx_tx_tx_ordering             (rx_tx_tx_ordering)              //--  input
  ,.rx_tx_rem_supported_widths    (rx_tx_rem_supported_widths[3:0])//--  input  [3:0]
  ,.rx_tx_trained_mode            (rx_tx_trained_mode[3:0])        //--  input  [3:0]
  ,.tx_rx_cfg_supported_widths    (tx_rx_cfg_supported_widths[3:0])//--  output [3:0]
  ,.rx_tx_tx_lane_swap            (rx_tx_tx_lane_swap)             //--  input
  ,.rx_tx_rem_PM_enable           (rx_tx_rem_PM_enable)            //--  input
  ,.rx_tx_rx_lane_reverse         (rx_tx_rx_lane_reverse)          //--  input
  ,.rx_tx_training_sync_hdr       (rx_tx_training_sync_hdr)        //--  input
  ,.rx_tx_lost_data_sync          (rx_tx_lost_data_sync)           //--  input
  ,.rx_tx_trn_dbg                 (rx_tx_trn_dbg[87:0])            //--  input [87:0]
  ,.rx_tx_EDPL_max_cnts           (rx_tx_EDPL_max_cnts[63:0])      //--  input [63:0]
  ,.rx_tx_EDPL_errors             (rx_tx_EDPL_errors[7:0])         //--  input [7:0]
  ,.rx_tx_EDPL_thres_reached      (rx_tx_EDPL_thres_reached[7:0])  //--  input [7:0]
  ,.tx_rx_EDPL_cfg                (tx_rx_EDPL_cfg[4:0])            //--  output [4:0]
  ,.tx_rx_cfg_patA_length         (tx_rx_cfg_patA_length)          //--  output [1:0]
  ,.tx_rx_cfg_patB_length         (tx_rx_cfg_patB_length)          //--  output [1:0]
  ,.tx_rx_cfg_patA_hyst           (tx_rx_cfg_patA_hyst)            //--  output [3:0]
  ,.tx_rx_cfg_patB_hyst           (tx_rx_cfg_patB_hyst)            //--  output [3:0]
  ,.tx_rx_rx_BEI_inject           (tx_rx_rx_BEI_inject[7:0])       //--  output [7:0]
  ,.tx_rx_start_retrain           (tx_rx_start_retrain)            //--  output
  ,.tx_rx_half_width              (tx_rx_half_width)               //--  output
  ,.tx_rx_quarter_width           (tx_rx_quarter_width)            //--  output
  ,.tx_rx_cfg_disable_rx_lanes    (tx_rx_cfg_disable_rx_lanes[7:0])//--  output [7:0]
  ,.tx_rx_PM_rx_lanes_disable     (tx_rx_PM_rx_lanes_disable[7:0]) //--  output [7:0]
  ,.tx_rx_PM_rx_lanes_enable      (tx_rx_PM_rx_lanes_enable[7:0])  //--  output [7:0]
  ,.tx_rx_PM_deskew_reset         (tx_rx_PM_deskew_reset)          //--  output
  ,.tx_rx_psave_sts_off           (tx_rx_psave_sts_off)            //--  output
  ,.tx_rx_retrain_not_due2_PM     (tx_rx_retrain_not_due2_PM)      //--  output
  ,.tx_rx_cfg_version             (tx_rx_cfg_version[5:0])         //--  output [5:0]
  ,.tx_rx_enable_short_idle       (tx_rx_enable_short_idle)        //--  output
  ,.tx_rx_cfg_sync_mode           (tx_rx_cfg_sync_mode)            //--  output 
  ,.tx_rx_sim_only_fast_train     (tx_rx_sim_only_fast_train)      //--  output
  ,.tx_rx_sim_only_request_ln_rev (tx_rx_sim_only_request_ln_rev)  //--  output
  ,.reg_dl_config0                (reg_dl_config0[63:0])           //--  input  [63:0]
  ,.reg_dl_config1                (reg_dl_config1[63:0])           //--  input  [63:0]
  ,.reg_dl_error_message          (reg_dl_error_message[3:0])      //--  input  [3:0]
  ,.reg_dl_link_down              (reg_dl_link_down)               //--  input
  ,.reg_rmt_write                 (reg_rmt_write)                  //--  input  [31:0]
  ,.reg_rmt_config                (reg_rmt_config[31:0])           //--  input  [31:0]
  ,.reg_dl_cya_bits               (reg_dl_cya_bits[31:0])          //--  input  [31:0]
  ,.dl_reg_errors                 (dl_reg_errors[47:0])            //--  output [47:0]
  ,.dl_reg_rmt_message            (dl_reg_rmt_message[63:0])       //--  output [63:0]
  ,.dl_reg_status                 (dl_reg_status[63:0])            //--  output [63:0]
  ,.dl_reg_training_status        (dl_reg_training_status[63:0])   //--  output [63:0]
  ,.dl_reg_error_capture          (dl_reg_error_capture[62:0])     //--  output [62:0]
  ,.reg_dl_err_cap_reset          (reg_dl_err_cap_reset)           //--  input
  ,.dl_reg_edpl_max_count         (dl_reg_edpl_max_count[63:0])    //--  output [63:0]
  ,.dl_reg_trace_data             (dl_reg_trace_data[87:0])        //--  output[87:0]
  ,.dl_reg_trace_trig             (dl_reg_trace_trig[1:0])         //--  output[1:0]
  ,.dl_reg_perf_mon               (dl_reg_perf_mon[11:0])          //--  output[15:0]
  ,.dl_phy_iobist_prbs_error      (dl_phy_iobist_prbs_error[7:0])  //--  output [7:0]
  ,.reg_dl_edpl_max_count_reset   (reg_dl_edpl_max_count_reset)    //--  input
  ,.reg_dl_1us_tick               (reg_dl_1us_tick)                //--  input
  ,.reg_dl_100ms_tick             (reg_dl_100ms_tick)              //--  input
  ,.reg_dl_recal_start            (reg_dl_recal_start)             //--  input
  ,.omi_enable                    (omi_enable)                     //--  output
  ,.dl_clk                        (dl_clk )                        //--  input
  ,.rx_tx_mn_trn_in_replay        (rx_tx_mn_trn_in_replay)         //--  input 
  ,.rx_tx_data_flt                (rx_tx_data_flt)                 //--  input
  ,.rx_tx_ctl_flt                 (rx_tx_ctl_flt)                  //--  input
  ,.rx_tx_rpl_flt                 (rx_tx_rpl_flt)                  //--  input
  ,.rx_tx_idle_flt                (rx_tx_idle_flt)                 //--  input
  ,.rx_tx_ill_rl                  (rx_tx_ill_rl)                   //--  input     
  ,.rx_tx_dbg_rx_info             (rx_tx_dbg_rx_info[87:0])        //--  input[87:0]
  ,.tx_rx_macro_dbg_sel           (tx_rx_macro_dbg_sel[3:0])       //--  output[3:0]
  ,.rx_tx_iobist_prbs_error       (rx_tx_iobist_prbs_error[7:0])   //--  input
  ,.tx_rx_inj_pty_err             (tx_rx_inj_pty_err)              //--  output 
  ,.chip_reset                    (chip_reset)                     //--  input
  ,.global_reset_control          (global_reset_control)           //--  input 
  ,.global_trace_enable           (global_trace_enable)            //--  input
  ,.sync_mode                     (sync_mode)                      //--  input 
);

dlc_omi_rx #(.RX_EQ_TX_CLK(RX_EQ_TX_CLOCK)) orx 
 (
   .phy_dl_clock_0                (phy_dl_clock_0)                 //--  input
  ,.phy_dl_clock_1                (phy_dl_clock_1)                 //--  input
  ,.phy_dl_clock_2                (phy_dl_clock_2)                 //--  input
  ,.phy_dl_clock_3                (phy_dl_clock_3)                 //--  input
  ,.phy_dl_clock_4                (phy_dl_clock_4)                 //--  input
  ,.phy_dl_clock_5                (phy_dl_clock_5)                 //--  input
  ,.phy_dl_clock_6                (phy_dl_clock_6)                 //--  input
  ,.phy_dl_clock_7                (phy_dl_clock_7)                 //--  input
  ,.phy_dl_lane_0                 (phy_dl_lane_0[15:0])            //--  input  [15:0]
  ,.phy_dl_lane_1                 (phy_dl_lane_1[15:0])            //--  input  [15:0]
  ,.phy_dl_lane_2                 (phy_dl_lane_2[15:0])            //--  input  [15:0]
  ,.phy_dl_lane_3                 (phy_dl_lane_3[15:0])            //--  input  [15:0]
  ,.phy_dl_lane_4                 (phy_dl_lane_4[15:0])            //--  input  [15:0]
  ,.phy_dl_lane_5                 (phy_dl_lane_5[15:0])            //--  input  [15:0]
  ,.phy_dl_lane_6                 (phy_dl_lane_6[15:0])            //--  input  [15:0]
  ,.phy_dl_lane_7                 (phy_dl_lane_7[15:0])            //--  input  [15:0]
  ,.phy_dl_iobist_reset           (phy_dl_iobist_reset)            //--  input
  ,.lbist_en_dc                   (lbist_en_dc)                    //--  input  
  ,.dl2tl_fast_act_info           (dl2tl_fast_act_info[34:0])
  ,.dl2tl_idle_transition         (dl2tl_idle_transition)
  ,.dl2tl_fast_act_info_l         (dl2tl_fast_act_info_l[34:0])
  ,.dl2tl_idle_transition_l       (dl2tl_idle_transition_l)
  ,.dl2tl_fast_act_info_r         (dl2tl_fast_act_info_r[34:0])
  ,.dl2tl_idle_transition_r       (dl2tl_idle_transition_r)
  ,.dl2tl_dead_cycle              (dl2tl_dead_cycle)               //--  output
  ,.dl2tl_flit_vld                (dl2tl_flit_vld)                 //--  output
  ,.dl2tl_flit_error              (dl2tl_flit_error)               //--  output
  ,.dl2tl_flit_badcrc             (dl2tl_flit_badcrc)              //--  output
  ,.dl2tl_flit_data               (dl2tl_flit_data[127:0])         //--  output [127:0]
  ,.dl2tl_flit_pty                (dl2tl_flit_pty[15:0])           //--  output [15:0]
  ,.dl2tl_flit_act                (dl2tl_flit_act)               //--  output[15:0]
  ,.rx_link_up                    (rx_link_up)                     //--  output
  ,.rx_tx_crc_error               (rx_tx_crc_error)                //--  output
  ,.rx_tx_nack                    (rx_tx_nack)                     //--  output
  ,.rx_tx_rx_ack_inc              (rx_tx_rx_ack_inc[3:0])          //--  output [3:0]
  ,.rx_tx_tx_ack_rtn              (rx_tx_tx_ack_rtn[4:0])          //--  output [4:0]
  ,.rx_tx_tx_ack_ptr_vld          (rx_tx_tx_ack_ptr_vld)           //--  output
  ,.rx_tx_tx_ack_ptr              (rx_tx_tx_ack_ptr[11:0])         //--  output [11:0]
  ,.rx_tx_rmt_error               (rx_tx_rmt_error[7:0])           //--  output [7:0]
  ,.rx_tx_rmt_message             (rx_tx_rmt_message[63:0])        //--  output [63:0]
  ,.rx_tx_recal_status            (rx_tx_recal_status[1:0])        //--  output [1:0]
  ,.rx_tx_pm_status               (rx_tx_pm_status[3:0])           //--  output [3:0]
  ,.tx_rx_reset_n                 (tx_rx_reset_n)                  //--  input
  ,.chip_reset                    (chip_reset)                     //--  input
  ,.global_reset_control          (global_reset_control)           //--  input 
  ,.tx_rx_tsm                     (tx_rx_tsm[2:0])                 //--  input  [2:0]    
  ,.tx_rx_phy_init_done           (tx_rx_phy_init_done[7:0])       //--  input  [7:0]
  ,.rx_tx_version_number          (rx_tx_version_number[5:0])      //--  output [5:0]
  ,.rx_tx_slow_clock              (rx_tx_slow_clock)               //--  output
  ,.rx_tx_deskew_overflow         (rx_tx_deskew_overflow)          //--  output
  ,.rx_tx_train_status            (rx_tx_train_status[72:0])       //--  output [72:0]   
  ,.rx_tx_disabled_rx_lanes       (rx_tx_disabled_rx_lanes[7:0])   //--  output [7:0]
  ,.rx_tx_disabled_tx_lanes       (rx_tx_disabled_tx_lanes[7:0])   //--  output [7:0]
  ,.rx_tx_ts_valid                (rx_tx_ts_valid)                 //--  output
  ,.rx_tx_ts_good_lanes           (rx_tx_ts_good_lanes[15:0])      //--  output [15:0]
  ,.rx_tx_deskew_config_valid     (rx_tx_deskew_config_valid)      //--  output
  ,.rx_tx_deskew_config           (rx_tx_deskew_config[18:0])      //--  output [18:0]
  ,.rx_tx_tx_ordering             (rx_tx_tx_ordering)              //--  output
  ,.rx_tx_rem_supported_widths    (rx_tx_rem_supported_widths[3:0])//--  output [3:0]
  ,.rx_tx_trained_mode            (rx_tx_trained_mode[3:0])        //--  output [3:0]
  ,.tx_rx_cfg_supported_widths    (tx_rx_cfg_supported_widths[3:0])//--  input [3:0]
  ,.rx_tx_tx_lane_swap            (rx_tx_tx_lane_swap)             //--  output
  ,.rx_tx_rem_PM_enable           (rx_tx_rem_PM_enable)            //--  output
  ,.rx_tx_rx_lane_reverse         (rx_tx_rx_lane_reverse)          //--  output
  ,.rx_tx_training_sync_hdr       (rx_tx_training_sync_hdr)        //--  output
  ,.rx_tx_lost_data_sync          (rx_tx_lost_data_sync)           //--  output
  ,.rx_tx_trn_dbg                 (rx_tx_trn_dbg[87:0])            //--  output [87:0]
  ,.rx_tx_EDPL_max_cnts           (rx_tx_EDPL_max_cnts[63:0])      //--  output [63:0]
  ,.rx_tx_EDPL_errors             (rx_tx_EDPL_errors[7:0])         //--  output [7:0]
  ,.rx_tx_EDPL_thres_reached      (rx_tx_EDPL_thres_reached[7:0])  //--  output [7:0]
  ,.tx_rx_EDPL_cfg                (tx_rx_EDPL_cfg[4:0])            //--  input [4:0]
  ,.tx_rx_cfg_patA_length         (tx_rx_cfg_patA_length)          //--  input [1:0]
  ,.tx_rx_cfg_patB_length         (tx_rx_cfg_patB_length)          //--  input [1:0]
  ,.tx_rx_cfg_patA_hyst           (tx_rx_cfg_patA_hyst)            //--  input [3:0]
  ,.tx_rx_cfg_patB_hyst           (tx_rx_cfg_patB_hyst)            //--  input [3:0]
  ,.tx_rx_rx_BEI_inject           (tx_rx_rx_BEI_inject[7:0])       //--  input [7:0]
  ,.tx_rx_start_retrain           (tx_rx_start_retrain)            //--  input
  ,.tx_rx_half_width              (tx_rx_half_width)               //--  input
  ,.tx_rx_quarter_width           (tx_rx_quarter_width)            //--  input
  ,.tx_rx_cfg_disable_rx_lanes    (tx_rx_cfg_disable_rx_lanes[7:0])//--  input [7:0]
  ,.tx_rx_PM_rx_lanes_disable     (tx_rx_PM_rx_lanes_disable[7:0]) //--  input [7;0]
  ,.tx_rx_PM_rx_lanes_enable      (tx_rx_PM_rx_lanes_enable[7:0])  //--  input [7:0]
  ,.tx_rx_PM_deskew_reset         (tx_rx_PM_deskew_reset)          //--  input
  ,.tx_rx_psave_sts_off           (tx_rx_psave_sts_off)            //--  input
  ,.tx_rx_retrain_not_due2_PM     (tx_rx_retrain_not_due2_PM)      //--  input
  ,.tx_rx_cfg_version             (tx_rx_cfg_version[5:0])         //--  input
  ,.tx_rx_enable_short_idle       (tx_rx_enable_short_idle)        //--  input
  ,.tx_rx_cfg_sync_mode           (tx_rx_cfg_sync_mode)            //--  input
  ,.tx_rx_sim_only_fast_train     (tx_rx_sim_only_fast_train)      //--  input
  ,.tx_rx_sim_only_request_ln_rev (tx_rx_sim_only_request_ln_rev)  //--  input
  ,.reg_dl_edpl_max_count_reset   (reg_dl_edpl_max_count_reset)    //--  input
  ,.reg_dl_1us_tick               (reg_dl_1us_tick)                //--  input                
  ,.omi_enable                    (omi_enable)                     //--  input
  ,.dl_clk                        (dl_clk )                        //--  input
  ,.rx_tx_mn_trn_in_replay        (rx_tx_mn_trn_in_replay)         //--  output 
  ,.rx_tx_data_flt                (rx_tx_data_flt)                 //--  output
  ,.rx_tx_ctl_flt                 (rx_tx_ctl_flt)                  //--  output
  ,.rx_tx_rpl_flt                 (rx_tx_rpl_flt)                  //--  output
  ,.rx_tx_idle_flt                (rx_tx_idle_flt)                 //--  output
  ,.rx_tx_ill_rl                  (rx_tx_ill_rl)                   //--  output     
  ,.rx_tx_dbg_rx_info             (rx_tx_dbg_rx_info[87:0])        //--  output[87:0]
  ,.tx_rx_macro_dbg_sel           (tx_rx_macro_dbg_sel[3:0])       //--  input[3:0]
  ,.rx_tx_iobist_prbs_error       (rx_tx_iobist_prbs_error[7:0])   //--  output[7:0]
  ,.tx_rx_inj_pty_err             (tx_rx_inj_pty_err)              //--  input
);

endmodule     //-- dlc_omi_wrap
