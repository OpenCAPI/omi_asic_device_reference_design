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
module dlc_omi_rx_train (

  dl2tl_link_up                 //--  output
 ,dl2tl_dead_cycle              //--  output
//-- only need two odd and two even lanes to prove consistent data for in training sets.  
 ,ln0_valid                     //--  input
 ,ln1_valid                     //--  input
 ,ln2_valid                     //--  input
 ,ln3_valid                     //--  input
 ,ln4_valid                     //--  input
 ,ln5_valid                     //--  input
 ,ln6_valid                     //--  input
 ,ln7_valid                     //--  input

 ,ln0_data                      //--  input  [15:0]
 ,ln1_data                      //--  input  [15:0]
 ,ln2_data                      //--  input  [15:0]
 ,ln3_data                      //--  input  [15:0]
 ,ln4_data                      //--  input  [15:0]
 ,ln5_data                      //--  input  [15:0]
 ,ln6_data                      //--  input  [15:0]
 ,ln7_data                      //--  input  [15:0]

 ,ln_data_sync_hdr              //--  input   [7:0]
 ,ln_ctl_sync_hdr               //--  input   [7:0]

//--  Training information from each lane
 ,ln_rx_slow_pat_a              //--  input  [7:0]
 ,ln_pattern_a                  //--  input  [7:0]
 ,ln_pattern_b                  //--  input  [7:0]
 ,ln_sync                       //--  input  [7:0]
 ,ln_block_lock                 //--  input  [7:0]
 ,ln_TS1                        //--  input  [7:0]
 ,ln_TS2                        //--  input  [7:0]
 ,ln_TS3                        //--  input  [7:0]
 ,ln_retrain                    //--  output
 ,ln_deskew_enable              //--  output
 ,ln_deskew_found               //--  input  [7:0]
 ,ln_deskew_hold                //--  input  [7:0]
 ,ln_deskew_valid               //--  input  [7:0]
 ,ln_deskew_overflow            //--  input  [7:0]
 ,ln_all_valid                  //--  output
 ,ln_deskew_reset               //--  output
 ,ln_phy_training               //--  output
 ,ln_phy_init_done              //--  output [7:0]
 ,ln_ts_training                //--  output
 ,ln_disabled                   //--  output [7:0]
                         
//-- signals between the RX and TX
 ,tx_rx_reset_n                 //--  input
 ,rx_reset_n                    //--  output
 ,tx_rx_tsm                     //--  input  [2:0]    
 ,tx_rx_phy_init_done           //--  input
 ,tx_rx_half_width              //--  input
 ,tx_rx_quarter_width           //--  input
 ,tx_rx_start_retrain           //--  input
 ,tx_rx_cfg_disable_rx_lanes    //--  input  [7:0]
 ,tx_rx_PM_rx_lanes_disable     //--  input  [7:0]
 ,tx_rx_PM_rx_lanes_enable      //--  input  [7:0]
 ,tx_rx_PM_deskew_reset         //--  input
 ,tx_rx_psave_sts_off           //--  input
 ,tx_rx_retrain_not_due2_PM     //--  input
 ,tx_rx_cfg_version             //--  input  [5:0]
 ,rx_tx_version_number          //--  output [5:0]
 ,rx_tx_slow_clock              //--  output
 ,rx_tx_deskew_overflow         //--  output
 ,rx_tx_train_status            //--  output [72:0]   -- status of each lane in the training sequence
 ,rx_tx_disabled_rx_lanes       //--  output [7:0]
 ,rx_tx_disabled_tx_lanes       //--  output [7:0]
 ,rx_tx_ts_valid                //--  output
 ,rx_tx_ts_good_lanes           //--  output [15:0]
 ,rx_tx_deskew_config_valid     //--  output
 ,rx_tx_deskew_config           //--  output [18:0]
 ,rx_tx_tx_ordering             //--  output
 ,rx_tx_rem_supported_widths    //--  output [3:0]
 ,rx_tx_trained_mode            //--  output [3:0]
 ,tx_rx_cfg_supported_widths    //--  input [3:0]
 ,rx_tx_tx_lane_swap            //--  output
 ,rx_tx_rem_PM_enable           //--  output
 ,rx_tx_rx_lane_reverse         //--  output
 ,rx_tx_lost_data_sync          //--  output
 ,rx_tx_trn_dbg                 //--  output[87:0]
 ,tx_rx_macro_dbg_sel           //--  input [3:0]
 ,rx_tx_training_sync_hdr       //--  output
 ,tx_rx_sim_only_fast_train     //--  input
 ,tx_rx_sim_only_request_ln_rev //--  input
 ,trn_mn_trained                //--  output
 ,trn_agn_trained               //--  output
 ,trn_agn_retrain               //--  output
 ,trn_ln_trained                //--  output
 ,trn_agn_x4_mode               //--  output [1:0]  --1: odd only  0: even only
 ,trn_agn_x2_mode               //--  output [1:0]
 ,trn_agn_ln_swap               //--  output        --lanes are reversed
 ,reg_dl_1us_tick               //--  input
 ,omi_enable                    //--  input
 ,dl_clk                        //--  input
 ,chip_reset                    //--  input
 ,global_reset_control          //--  input
);


output          dl2tl_link_up;
output          dl2tl_dead_cycle;
input           ln0_valid;
input           ln1_valid;
input           ln2_valid;
input           ln3_valid;
input           ln4_valid;
input           ln5_valid;
input           ln6_valid;
input           ln7_valid;
input  [15:0]   ln0_data;
input  [15:0]   ln1_data;
input  [15:0]   ln2_data;
input  [15:0]   ln3_data;
input  [15:0]   ln4_data;
input  [15:0]   ln5_data;
input  [15:0]   ln6_data;
input  [15:0]   ln7_data;
input  [7:0]    ln_data_sync_hdr;
input  [7:0]    ln_ctl_sync_hdr;
input  [7:0]    ln_rx_slow_pat_a;
input  [7:0]    ln_pattern_a;
input  [7:0]    ln_pattern_b;
input  [7:0]    ln_sync;
input  [7:0]    ln_block_lock;
input  [7:0]    ln_TS1;
input  [7:0]    ln_TS2;
input  [7:0]    ln_TS3;
output          ln_retrain;
output          ln_deskew_enable;
input  [7:0]    ln_deskew_found;
input  [7:0]    ln_deskew_hold;
input  [7:0]    ln_deskew_valid;
input  [7:0]    ln_deskew_overflow;
output          ln_all_valid;
output          ln_deskew_reset;
output          ln_phy_training;
output [7:0]    ln_phy_init_done;
output          ln_ts_training;
output [7:0]    ln_disabled;
input           tx_rx_reset_n;
output          rx_reset_n;
input  [2:0]    tx_rx_tsm;
input  [7:0]    tx_rx_phy_init_done;
output [5:0]    rx_tx_version_number;
output          rx_tx_slow_clock;
output          rx_tx_deskew_overflow;
output [72:0]   rx_tx_train_status;
output [7:0]    rx_tx_disabled_rx_lanes;
output [7:0]    rx_tx_disabled_tx_lanes;
output          rx_tx_tx_lane_swap;
output          rx_tx_rem_PM_enable;
output          rx_tx_ts_valid;
output [15:0]   rx_tx_ts_good_lanes;
output          rx_tx_deskew_config_valid;
output [18:0]   rx_tx_deskew_config;
output          rx_tx_tx_ordering;
output [3:0]    rx_tx_rem_supported_widths;
output [3:0]    rx_tx_trained_mode;
input  [3:0]    tx_rx_cfg_supported_widths;
output          rx_tx_rx_lane_reverse;
output          rx_tx_lost_data_sync;
output [87:0]   rx_tx_trn_dbg;
input  [3:0]    tx_rx_macro_dbg_sel;
output          rx_tx_training_sync_hdr;
input           tx_rx_half_width;
input           tx_rx_quarter_width;
input           tx_rx_start_retrain;
input  [7:0]    tx_rx_cfg_disable_rx_lanes;
input  [7:0]    tx_rx_PM_rx_lanes_disable;
input  [7:0]    tx_rx_PM_rx_lanes_enable;
input           tx_rx_PM_deskew_reset;
input           tx_rx_psave_sts_off;
input           tx_rx_retrain_not_due2_PM;
input  [5:0]    tx_rx_cfg_version;
input           tx_rx_sim_only_fast_train;
input           tx_rx_sim_only_request_ln_rev;
output          trn_mn_trained;
output          trn_agn_trained;
output          trn_agn_retrain;
output          trn_ln_trained;
output [1:0]    trn_agn_x4_mode;
output [1:0]    trn_agn_x2_mode;
output          trn_agn_ln_swap;
input           reg_dl_1us_tick;
input           omi_enable;
input           dl_clk;
input           chip_reset;
input           global_reset_control; 

// signal declarations
wire               reset;
wire               tx_cfg_x32;
wire               tx_cfg_x16;
wire               tx_cfg_x8;
wire               tx_cfg_x4;
wire               deskew_done_din;
wire               deskew_done_q;
wire               deskew_all_valid;
wire               deskew_all_valid_din;
wire               deskew_all_valid_q;
wire               deskew_overflow_din;
wire               deskew_overflow_q;
wire               deskew_reset;
wire [3:0]         deskew_cnt_din;
wire [3:0]         deskew_cnt_q;
wire               deskew_tick;
wire [7:0]         disabled_rx_lanes_din;
wire [7:0]         disabled_rx_lanes_q;
wire [23:0]        rx_deskew_ln0_data_din;
wire [23:0]        rx_deskew_ln0_data_q;
wire [23:0]        rx_deskew_ln1_data_din;
wire [23:0]        rx_deskew_ln1_data_q;
wire               reset_n_din;
wire               reset_n_q;
wire               rx_slow_a_pattern;
wire [7:0]         rx_trained_lanes_din;
wire [7:0]         rx_trained_lanes_q;
wire [6:0]         slow_a_cnt_din;
wire [6:0]         slow_a_cnt_q;
wire               start_retrain;
wire [5:0]         rx_trained_lanes_cntr_din;
wire [5:0]         rx_trained_lanes_cntr_q;
wire               rx_trained_lanes_cntr_done;
wire               rx_lane_reverse_din;
wire               rx_lane_reverse_q;
wire               dl_training;
wire               rx_deskew_ln0_b0_din;
wire               rx_deskew_ln0_b0_q;
wire               rx_deskew_ln0_b1_din;
wire               rx_deskew_ln0_b1_q;
wire               rx_deskew_ln0_b2_din;
wire               rx_deskew_ln0_b2_q;
wire               rx_deskew_ln0_b3_din;
wire               rx_deskew_ln0_b3_q;
wire               rx_deskew_ln1_b0_din;
wire               rx_deskew_ln1_b0_q;
wire               rx_deskew_ln1_b1_din;
wire               rx_deskew_ln1_b1_q;
wire               rx_deskew_ln1_b2_din;
wire               rx_deskew_ln1_b2_q;
wire               rx_deskew_ln1_b3_din;
wire               rx_deskew_ln1_b3_q;
wire               ln0_dskw_match_c0_din;
wire               ln0_dskw_match_c0_q;
wire               ln1_dskw_match_c0_din;
wire               ln1_dskw_match_c0_q;
wire               ln0_dskw_match;
wire               ln1_dskw_match;
wire [3:0]         sum_data_sync_hdr;
wire               data_sync_hdr;
wire [3:0]         sum_trn_sync_hdr;
wire               sum_trn_sync_hdr_din;
wire               sum_trn_sync_hdr_q;
wire               link_up_din;
wire               link_up_q;
wire               dsc_eq_zero;
wire [6:0]         data_sync_cnt_din;
wire [6:0]         data_sync_cnt_q;
wire               rx_trained_ln0_b0_din;
wire               rx_trained_ln0_b1_din;
wire               rx_trained_ln0_b2_din;
wire               rx_trained_ln0_b0_q;
wire               rx_trained_ln0_b1_q;
wire               rx_trained_ln0_b2_q;
wire               rx_trained_ln1_b0_din;
wire               rx_trained_ln1_b1_din;
wire               rx_trained_ln1_b2_din;
wire               rx_trained_ln1_b0_q;
wire               rx_trained_ln1_b1_q;
wire               rx_trained_ln1_b2_q;
wire [7:0]         ln_sync_din;
wire [7:0]         ln_sync_q;
wire [7:0]         ln_TS1_din;
wire [7:0]         ln_TS2_din;
wire [7:0]         ln_TS3_din;
wire [7:0]         ln_TS1_q;
wire [7:0]         ln_TS2_q;
wire [7:0]         ln_TS3_q;
wire               deskew_enable_din;
wire               deskew_enable_q;  
wire               sim_only_fast_train;
wire               rx_neighbor_last;
wire [5:0]         version_number;
wire [15:0]        rx_ts_ln0_data_din;
wire [15:0]        rx_ts_ln0_data_q;
wire [15:0]        rx_ts_ln1_data_din;
wire [15:0]        rx_ts_ln1_data_q;
wire [15:0]        ts_good_lanes_din;
wire [15:0]        ts_good_lanes_q;
wire [3:0]         ts_cntr_din;
wire [3:0]         ts_cntr_q;
wire               deskew_found_din;
wire               deskew_found_q;
wire               inc_deskew_enable_dly_count;
wire [4:0]         deskew_enable_dly_din;
wire [4:0]         deskew_enable_dly_q;
wire               deskew_enable_dly_maxed;
wire [7:0]         disabled_tx_lanes;
wire [23:0]        deskew_config_din;
wire [23:0]        deskew_config_q;
wire               deskew_config_valid;
wire               half_width;
wire               quarter_width;
wire               mode_x8;
wire               ts_valid_din;
wire               ts_valid_q;
wire               rx_trained_lanes_cntr_reset;
wire               inc_rx_trained_lanes_cntr;
wire [7:0]         cfg_disable_rx_lanes;
wire [7:0]         PM_rx_lanes_disable;
wire [7:0]         PM_rx_lanes_enable;
wire [7:0]         data_sync_hdr_din;
wire [7:0]         data_sync_hdr_q;
wire [7:0]         trn_sync_hdr_din;
wire [7:0]         trn_sync_hdr_q;
wire [72:0]        train_status;
wire [7:0]         ln_pattern_a_din;
wire [7:0]         ln_pattern_a_q;
wire [7:0]         ln_pattern_b_din;
wire [7:0]         ln_pattern_b_q;
wire [7:0]         ln_block_lock_din;
wire [7:0]         ln_block_lock_q;
wire               link_trained_din;
wire               link_trained_q;
wire [3:0]         phy_trn_cntr_din;
wire [3:0]         phy_trn_cntr_q;
wire               phy_trn_cntr_ena;
wire               phy_trn_cntr_done;
wire               reg_dl_1us_tick_din;
wire               reg_dl_1us_tick_q;
wire               one_dskw_match;
wire [3:0]         supported_widths;
wire               rx_cfg_x32;
wire               rx_cfg_x16;
wire               rx_cfg_x8;
wire               rx_cfg_x4;
wire               choose_x8;
wire               choose_x4;
wire               deskew_config_rising_edge;
wire               ts_valid_rising_edge;
wire               ts_new_pattern;
wire               ts_recheck_din;
wire               ts_recheck_q;
wire               ts_recheck_matches_prev;
wire               ts_recheck_inc;
wire               load_new_ts_pattern;
wire [15:0]        new_ts_pattern;
wire               ts_recheck_reset;
wire [2:0]         ts_recheck_cntr_din;
wire [2:0]         ts_recheck_cntr_q;
wire               spare_00_din;
wire               spare_01_din;
wire               spare_02_din;
wire               spare_03_din;
wire               spare_04_din;
wire               spare_05_din;
wire               spare_06_din;
wire               spare_07_din;
wire               spare_08_din;
wire               spare_09_din;
wire               spare_0A_din;
wire               spare_0B_din;
wire               spare_0C_din;
wire               spare_0D_din;
wire               spare_0E_din;
wire               spare_0F_din;
wire               spare_00_q;
wire               spare_01_q;
wire               spare_02_q;
wire               spare_03_q;
wire               spare_04_q;
wire               spare_05_q;
wire               spare_06_q;
wire               spare_07_q;
wire               spare_08_q;
wire               spare_09_q;
wire               spare_0A_q;
wire               spare_0B_q;
wire               spare_0C_q;
wire               spare_0D_q;
wire               spare_0E_q;
wire               spare_0F_q;
wire [2:0]         deskew_overflow_cntr_din;
wire [2:0]         deskew_overflow_cntr_q;
wire               reset_deskew_overflow_cntr;
wire               inc_deskew_overflow_cntr;
wire               retry_timer_start;
wire               retry_timer_running_din;
wire               retry_timer_running_q;
wire               retry_timer_done;
wire               retry_timer_inc;
wire [3:0]         deskew_overflow_retry_timer_din;
wire [3:0]         deskew_overflow_retry_timer_q;
wire               deskew_overflow_dly_din;
wire               deskew_overflow_dly_q;
wire               sim_only_request_ln_rev;
wire               tx_lane_swap;
wire               rx_trained_lanes_done;
wire               DM_new_pattern;
wire               DM_recheck_din;
wire               DM_recheck_q;
wire               DM_recheck_matches_prev;
wire               DM_recheck_inc;
wire               load_new_DM_pattern;
wire [23:0]        new_DM_pattern;
wire               DM_recheck_reset;
wire [1:0]         DM_recheck_cntr_din;
wire [1:0]         DM_recheck_cntr_q;
wire               DM_recheck_c0_matches_prev_din;
wire               DM_recheck_c0_matches_prev_q;
wire [3:0]         sum_unlatched_data_sync_hdr;
wire               mode_x4_inner;
wire               mode_x4_outer;
wire               mode_x4;
wire               mode_x2_inner;
wire               mode_x2_outer;
wire               mode_x2;
wire               ts_mode_x4_inner;
wire               ts_mode_x4_outer;
wire               ts_mode_x2_inner;
wire               ts_mode_x2_outer;
wire               ts_trained_x32;
wire               ts_trained_x16;
wire               ts_trained_x8;
wire               ts_trained_x4;
wire               PM_mode_x8;
wire               PM_mode_x4_inner;
wire               PM_mode_x4_outer;
wire               PM_mode_x4;
wire               PM_mode_x2_inner;
wire               PM_mode_x2_outer;
wire               PM_mode_x2;
wire               PM_deskew_reset;
wire [7:0]         ts_byte0;
wire [7:0]         ts_byte1;
wire [7:0]         deskew_byte0;
wire [7:0]         deskew_byte1;
wire [7:0]         deskew_byte2;
wire               rem_PM_enable;
wire [15:0]        rx_ts_ln5_data_din;
wire [15:0]        rx_ts_ln5_data_q;
wire               rx_trained_ln5_b0_din;
wire               rx_trained_ln5_b1_din;
wire               rx_trained_ln5_b2_din;
wire               rx_trained_ln5_b0_q;
wire               rx_trained_ln5_b1_q;
wire               rx_trained_ln5_b2_q;
wire               rx_deskew_ln5_b0_din;
wire               rx_deskew_ln5_b1_din;
wire               rx_deskew_ln5_b2_din;
wire               rx_deskew_ln5_b3_din;
wire               rx_deskew_ln5_b0_q;
wire               rx_deskew_ln5_b1_q;
wire               rx_deskew_ln5_b2_q;
wire               rx_deskew_ln5_b3_q;
wire [23:0]        rx_deskew_ln5_data_din;
wire [23:0]        rx_deskew_ln5_data_q;
wire               ln5_dskw_match_c0_din;
wire               ln5_dskw_match_c0_q;
wire               ln5_dskw_match;
wire               rx_lane5_rev_cases;
wire               psave_sts_off;
wire               retrain_not_due2_PM;
wire               PM_retrain_dly_timer_ena_din;
wire               PM_retrain_dly_timer_ena_q;
wire               PM_retrain_dly_timer_done;
wire               PM_retrain_dly_timer_load;
wire               PM_retrain_dly_timer_clear;
wire               PM_retrain_dly_timer_inc;
wire [2:0]         PM_retrain_dly_timer_din;
wire [2:0]         PM_retrain_dly_timer_q;
wire               rx_lane0_rev_cases;
wire               rx_deskew_ln2_b0_din;
wire               rx_deskew_ln2_b0_q;
wire               rx_deskew_ln2_b1_din;
wire               rx_deskew_ln2_b1_q;
wire               rx_deskew_ln2_b2_din;
wire               rx_deskew_ln2_b2_q;
wire [5:0]         cfg_version_number;
wire               versions_allowed;
wire               version8_allowed;
wire               version9_allowed;
wire               version10_allowed;
wire               data_sync_hdr_found;
wire [3:0]         macro_dbg_sel;
wire [87:0]        selected_trn_dbg;
wire [87:0]        trn_dbg0;
wire [87:0]        trn_dbg1;
wire [87:0]        trn_dbg2;
wire [87:0]        trn_dbg3;
wire [87:0]        trn_dbg4;
wire [87:0]        trn_dbg5;
wire [87:0]        trn_dbg6;
wire [87:0]        trn_dbg7;
wire [87:0]        trn_dbg8;
wire [87:0]        trn_dbg9;
wire [87:0]        trn_dbgA;
wire [87:0]        trn_dbgB;
wire [87:0]        trn_dbgC;
wire [87:0]        trn_dbgD;
wire [87:0]        trn_dbgE;
wire [87:0]        trn_dbgF;
wire [4:0]         ln2_lane_num_din;
wire [4:0]         ln2_lane_num_q;




assign sim_only_fast_train          = tx_rx_sim_only_fast_train;

assign start_retrain              = tx_rx_start_retrain;
assign ln_retrain                 = start_retrain;
assign train_status[72:0]         = {ln_pattern_a_q[7:0],   //--72:65
                                     ln_pattern_b_q[7:0],   //--64:57
                                     ln_sync_q[7:0],        //--56:49
                                     ln_block_lock_q[7:0],  //--48:41
                                     deskew_done_q,         //--40
/* TS1 can happen at anytime */      ln_TS1[7:0],           //--39:32
                                     ln_TS2_q[7:0],         //--31:24
                                     ln_TS3_q[7:0],         //--23:16
                                     ln_data_sync_hdr[7:0], //--15: 8
                                     ln_ctl_sync_hdr[7:0]}; //-- 7: 0

assign rx_tx_train_status[72:0]   = train_status[72:0];


//--------------------------------------------------------
//--           Disabled Lanes Control Logic
//--  
//--------------------------------------------------------
//--
//-- Determine when enough time has elapsed to consider a RX lane is unable to train 
//-- After 32, 1 us ticks consider the lanes that aren't receiving patterns TS1 or TS2 disabled.
//--
//-- TS1 PATTERN    = 40'h4B4A4A4A4A4A
//-- TS2 PATTERN    = 40'h4B4545454545

//-- Disable RX lane(s) if unable to detect good TS1/TS2 pattern after 32 us (rx_trained_lanes_cntr_done)
assign rx_trained_lanes_din[7:0]       = (start_retrain) ? 8'b00000000 : (ln_TS1[7:0] | ln_TS2[7:0] | rx_trained_lanes_q[7:0]);
                                                                
assign reg_dl_1us_tick_din             = reg_dl_1us_tick;
assign psave_sts_off                   = tx_rx_psave_sts_off;

//-- If Power Management is enabled and an unexpected retrain happens (not due to PM), all psave requests are disabled to power on the lanes.
//-- Start a 4 us timer after all lanes on this side are powered on to give the remote side ample time to have all it's lanes powered on
//-- before resuming the retrain.

assign retrain_not_due2_PM             = tx_rx_retrain_not_due2_PM;
//-- start the timer on retrain_not_due2_PM and stop it after it switches to 4
assign PM_retrain_dly_timer_ena_din    = ((retrain_not_due2_PM | PM_retrain_dly_timer_ena_q) & ~((PM_retrain_dly_timer_inc & PM_retrain_dly_timer_q[2:0] == 3'b011) & PM_retrain_dly_timer_ena_q)) & tx_rx_tsm[2];
assign PM_retrain_dly_timer_done       = PM_retrain_dly_timer_q[2];

assign PM_retrain_dly_timer_load       = (tx_rx_tsm[2:0] == 3'b011);
assign PM_retrain_dly_timer_clear      = retrain_not_due2_PM;
assign PM_retrain_dly_timer_inc        = PM_retrain_dly_timer_ena_q & reg_dl_1us_tick_q & ~PM_retrain_dly_timer_done;

assign PM_retrain_dly_timer_din[2:0]   = PM_retrain_dly_timer_load  ? 3'b100 :  //-- load initial value
                                         PM_retrain_dly_timer_clear ? 3'b000 :
                                         PM_retrain_dly_timer_inc   ? PM_retrain_dly_timer_q[2:0] + 3'b001 :
                                                                      PM_retrain_dly_timer_q[2:0];


assign rx_trained_lanes_cntr_reset     = (start_retrain | (~rx_trained_lanes_cntr_done & (rx_trained_lanes_din[7:0] != rx_trained_lanes_q[7:0])) |
                                          ~(&tx_rx_phy_init_done[7:0]) | ~PM_retrain_dly_timer_done);
assign inc_rx_trained_lanes_cntr       = (reg_dl_1us_tick_q & (|rx_trained_lanes_q[7:0]) & ~rx_trained_lanes_cntr_done);
//-- Don't skip rx_trained_lanes_cntr to the end if all lanes are disabled.  Handles case of PM in lower width and EDPL causes enabled lane(s) to turn off.
//-- At the beginning of the retrain, all lanes were being disabled too soon.
assign rx_trained_lanes_done           = ((rx_trained_lanes_q[7:0] | ((disabled_rx_lanes_q[7:0] & ~PM_rx_lanes_enable[7:0]) | cfg_disable_rx_lanes[7:0])) == 8'hFF) &
                                         ((disabled_rx_lanes_q[7:0] | cfg_disable_rx_lanes[7:0])                                                          != 8'hFF);
assign rx_trained_lanes_cntr_done      = rx_trained_lanes_cntr_q[4];
assign rx_trained_lanes_cntr_din[5:0]  =  rx_trained_lanes_cntr_reset      ? 6'b000000 :
                                          rx_trained_lanes_done            ? 6'b01_0000:
                                          inc_rx_trained_lanes_cntr        ? rx_trained_lanes_cntr_q[5:0] + 6'b000001 :
                                                                             rx_trained_lanes_cntr_q[5:0];
                                                                                                                                          

//-- width this side of link is configured to run at
assign tx_cfg_x32                      = tx_rx_cfg_supported_widths[3]; //-- not supported
assign tx_cfg_x16                      = tx_rx_cfg_supported_widths[2]; //-- not supported
assign tx_cfg_x8                       = tx_rx_cfg_supported_widths[1];
assign tx_cfg_x4                       = tx_rx_cfg_supported_widths[0];

//-- bring up link as x8 if both sides are set to run as x8
assign cfg_version_number[5:0]         =  tx_rx_cfg_version[5:0];
//-- Legal version numbers
//-- cfg'd version # -> received version #
//-- (s) means it trains using short idles
//-- 8-> 5s,8s,9s,
//-- 9-> 3,5s,8s,9s,10
//-- 10->3,5,9,10
assign version8_allowed                = (cfg_version_number[5:0] == 6'b001000) & ((version_number[5:0] == 6'b000110) |
                                                                                   (version_number[5:0] == 6'b000111) |
                                                                                   (version_number[5:0] == 6'b001000) |
                                                                                   (version_number[5:0] == 6'b001001) |
                                                                                   (version_number[5:0] == 6'b001011));
assign version9_allowed                = (cfg_version_number[5:0] == 6'b001001) & ((version_number[5:0] == 6'b000011) |
                                                                                   (version_number[5:0] == 6'b000100) |
                                                                                   (version_number[5:0] == 6'b000101) |
                                                                                   (version_number[5:0] == 6'b000110) |
                                                                                   (version_number[5:0] == 6'b000111) |
                                                                                   (version_number[5:0] == 6'b001000) |
                                                                                   (version_number[5:0] == 6'b001001) |
                                                                                   (version_number[5:0] == 6'b001010) |
                                                                                   (version_number[5:0] == 6'b001011));
assign version10_allowed               = (cfg_version_number[5:0] == 6'b001010) & ((version_number[5:0] == 6'b000011) |
                                                                                   (version_number[5:0] == 6'b000100) |
                                                                                   (version_number[5:0] == 6'b000101) |
                                                                                   (version_number[5:0] == 6'b000110) |
                                                                                   (version_number[5:0] == 6'b000111) |
                                                                                   (version_number[5:0] == 6'b001001) |
                                                                                   (version_number[5:0] == 6'b001010) |
                                                                                   (version_number[5:0] == 6'b001011));
assign versions_allowed                = version8_allowed | version9_allowed | version10_allowed;

//-- 9/24 assign choose_x8                       = tx_cfg_x8 & rx_cfg_x8 & versions_allowed;
assign choose_x8                       = versions_allowed &
                                         (( tx_cfg_x8 &               rx_cfg_x8             ) |  //-- both sides as x8
                                          ( tx_cfg_x8 & ~tx_cfg_x4 & ~rx_cfg_x8 &  rx_cfg_x4) |  //-- this side as x8 only; remote as x4 only
                                          (~tx_cfg_x8 &  tx_cfg_x4 &  rx_cfg_x8 & ~rx_cfg_x4) ); //-- this side as x4 only; remote as x8 only
assign choose_x4                       =    tx_cfg_x4 & rx_cfg_x4 & versions_allowed & //-- both sides can run as x4 AND
                                         (( tx_cfg_x8 ^  rx_cfg_x8 ) |                 //-- one  side  can't run as a x8 or
                                          (~tx_cfg_x8 & ~rx_cfg_x8));                  //-- both sides can't run as a x8
//-- 8/8 assign choose_x8                       = tx_cfg_x8 & rx_cfg_x8;
//-- 8/8 assign choose_x4                       =    tx_cfg_x4 & rx_cfg_x4 &     //-- both sides can run as x4 AND
//-- 8/8                                          (( tx_cfg_x8 ^  rx_cfg_x8 ) |  //-- one  side  can't run as a x8 or
//-- 8/8                                           (~tx_cfg_x8 & ~rx_cfg_x8));   //-- both sides can't run as a x8

assign mode_x8                         = choose_x8 & (rx_trained_lanes_q[7:0] == 8'b1111_1111);
assign mode_x4_inner                   = ~mode_x8 & (rx_trained_lanes_q[1] & rx_trained_lanes_q[3] & rx_trained_lanes_q[4] & rx_trained_lanes_q[6]);
assign mode_x4_outer                   = ~mode_x8 & (rx_trained_lanes_q[0] & rx_trained_lanes_q[2] & rx_trained_lanes_q[5] & rx_trained_lanes_q[7]);
assign mode_x4                         = mode_x4_inner | mode_x4_outer;
assign mode_x2_inner                   = ~mode_x8 & ~mode_x4 & (rx_trained_lanes_q[2] & rx_trained_lanes_q[5]);
assign mode_x2_outer                   = ~mode_x8 & ~mode_x4 & (rx_trained_lanes_q[0] & rx_trained_lanes_q[7]);
assign mode_x2                         = mode_x2_inner | mode_x2_outer;

 
//-- lanes remains enabled until deskew markers determine what mode all lanes should be in
//-- 1. Is version number valid?
//-- 2. What mode are we in?
assign enable_ln7                   = (~deskew_config_valid & rx_trained_lanes_q[7]) | 
                                      ( deskew_config_valid & ( (choose_x8 & (mode_x4_outer | mode_x8      )) | 
                                                                (choose_x4 & (mode_x4_outer | mode_x2_outer)) ) );

assign enable_ln6                   = (~deskew_config_valid & rx_trained_lanes_q[6]) | 
                                      ( deskew_config_valid & ( (choose_x8 & (mode_x4_inner | mode_x8      )) |
                                                                (choose_x4 & (1'b0                         )) ) );

assign enable_ln5                   = (~deskew_config_valid & rx_trained_lanes_q[5]) | 
                                      ( deskew_config_valid & ( (choose_x8 & (mode_x4_outer | mode_x8      )) |
                                                                (choose_x4 & (mode_x4_outer | mode_x2_inner)) ) );

assign enable_ln4                   = (~deskew_config_valid & rx_trained_lanes_q[4]) | 
                                      ( deskew_config_valid & ( (choose_x8 & (mode_x4_inner | mode_x8      )) |
                                                                (choose_x4 & (1'b0                         )) ) );

assign enable_ln3                   = (~deskew_config_valid & rx_trained_lanes_q[3]) | 
                                      ( deskew_config_valid & ( (choose_x8 & (mode_x4_inner | mode_x8      )) |
                                                                (choose_x4 & (1'b0                         )) ) );

assign enable_ln2                   = (~deskew_config_valid & rx_trained_lanes_q[2]) | 
                                      ( deskew_config_valid & ( (choose_x8 & (mode_x4_outer | mode_x8      )) |
                                                                (choose_x4 & (mode_x4_outer | mode_x2_inner)) ) );

assign enable_ln1                   = (~deskew_config_valid & rx_trained_lanes_q[1]) | 
                                      ( deskew_config_valid & ( (choose_x8 & (mode_x4_inner | mode_x8      )) |
                                                                (choose_x4 & (1'b0                         )) ) );

assign enable_ln0                   = (~deskew_config_valid & rx_trained_lanes_q[0]) | 
                                      ( deskew_config_valid & ( (choose_x8 & (mode_x4_outer | mode_x8      )) |
                                                                (choose_x4 & (mode_x4_outer | mode_x2_outer)) ) );

assign half_width                   = tx_rx_half_width;
assign quarter_width                = tx_rx_quarter_width;
assign disabled_rx_lanes_din[7]     = (((rx_trained_lanes_cntr_done & ~enable_ln7) | (disabled_rx_lanes_q[7] & ~PM_rx_lanes_enable[7]) | PM_rx_lanes_disable[7]) & half_width);
assign disabled_rx_lanes_din[6]     = (((rx_trained_lanes_cntr_done & ~enable_ln6) | (disabled_rx_lanes_q[6] & ~PM_rx_lanes_enable[6]) | PM_rx_lanes_disable[6]) & half_width);
assign disabled_rx_lanes_din[5]     = (((rx_trained_lanes_cntr_done & ~enable_ln5) | (disabled_rx_lanes_q[5] & ~PM_rx_lanes_enable[5]) | PM_rx_lanes_disable[5]) & half_width);
assign disabled_rx_lanes_din[4]     = (((rx_trained_lanes_cntr_done & ~enable_ln4) | (disabled_rx_lanes_q[4] & ~PM_rx_lanes_enable[4]) | PM_rx_lanes_disable[4]) & half_width);
assign disabled_rx_lanes_din[3]     = (((rx_trained_lanes_cntr_done & ~enable_ln3) | (disabled_rx_lanes_q[3] & ~PM_rx_lanes_enable[3]) | PM_rx_lanes_disable[3]) & half_width);
assign disabled_rx_lanes_din[2]     = (((rx_trained_lanes_cntr_done & ~enable_ln2) | (disabled_rx_lanes_q[2] & ~PM_rx_lanes_enable[2]) | PM_rx_lanes_disable[2]) & half_width);
assign disabled_rx_lanes_din[1]     = (((rx_trained_lanes_cntr_done & ~enable_ln1) | (disabled_rx_lanes_q[1] & ~PM_rx_lanes_enable[1]) | PM_rx_lanes_disable[1]) & half_width);
assign disabled_rx_lanes_din[0]     = (((rx_trained_lanes_cntr_done & ~enable_ln0) | (disabled_rx_lanes_q[0] & ~PM_rx_lanes_enable[0]) | PM_rx_lanes_disable[0]) & half_width);

assign PM_mode_x8                   = (disabled_rx_lanes_q[7:0] == 8'b0000_0000);
assign PM_mode_x4_inner             = ~PM_mode_x8 & ~(disabled_rx_lanes_q[1] | disabled_rx_lanes_q[3] | disabled_rx_lanes_q[4] | disabled_rx_lanes_q[6]);
assign PM_mode_x4_outer             = ~PM_mode_x8 & ~(disabled_rx_lanes_q[0] | disabled_rx_lanes_q[2] | disabled_rx_lanes_q[5] | disabled_rx_lanes_q[7]);
assign PM_mode_x4                   = PM_mode_x4_inner | PM_mode_x4_outer;
assign PM_mode_x2_inner             = ~PM_mode_x8 & ~PM_mode_x4 & ~(disabled_rx_lanes_q[2] | disabled_rx_lanes_q[5]);
assign PM_mode_x2_outer             = ~PM_mode_x8 & ~PM_mode_x4 & ~(disabled_rx_lanes_q[0] | disabled_rx_lanes_q[7]);
assign PM_mode_x2                   = PM_mode_x2_inner | PM_mode_x2_outer;

assign trn_agn_x2_mode[1:0]         = {PM_mode_x2_outer, PM_mode_x2_inner};
assign trn_agn_x4_mode[1:0]         = {PM_mode_x4_outer, PM_mode_x4_inner};

assign rx_tx_disabled_rx_lanes[7:0] = {8{rx_trained_lanes_cntr_done}} & disabled_rx_lanes_q[7:0]; //-- gated by rx_trained_lanes_cntr_q

//-- stop lanes from detecting TS patterns during retrain
assign cfg_disable_rx_lanes[7:0]    = tx_rx_cfg_disable_rx_lanes[7:0];
assign PM_rx_lanes_disable[7:0]     = tx_rx_PM_rx_lanes_disable[7:0];
assign PM_rx_lanes_enable[7:0]      = tx_rx_PM_rx_lanes_enable[7:0];
assign ln_disabled[7:0]             = (cfg_disable_rx_lanes[7:0] | disabled_rx_lanes_q[7:0]); //-- output to dlc_omi_rx_lane.v


//--------------------------------------------------------
//--            Link Training Control Logic
//--
//--------------------------------------------------------

assign reset_n_din                  = tx_rx_reset_n;
assign rx_reset_n                   = reset_n_q;

assign ln_phy_training              = ~phy_trn_cntr_done;        //-- PHY is training until it sees a sync on the lanes
assign ln_phy_init_done[7:0]        = tx_rx_phy_init_done[7:0];
//-- TSM in states 4-6 and link is not up due to sync headers
assign ln_ts_training               = ((tx_rx_tsm[2] == 1'b1) & (tx_rx_tsm[2:0] != 3'b111)) & ~link_trained_q;
assign dl_training                  = ~(tx_rx_tsm[2:0] == 3'b111) & ~(tx_rx_tsm[2:0] == 3'b000);

//-- give all lanes 8 cycles to try and find the sync pattern before telling them to stop looking for it
//-- once the fastest lanes find the sync pattern
assign phy_trn_cntr_ena             = (|ln_sync_q[7:0]);
assign phy_trn_cntr_done            = phy_trn_cntr_q[3];
assign phy_trn_cntr_din[3:0]        = phy_trn_cntr_ena & ~phy_trn_cntr_done ? phy_trn_cntr_q[3:0] + 4'b0001 :
                                                                              phy_trn_cntr_q[3:0];

//-- Slow PATTERN A detection logic
assign rx_slow_a_pattern        =  (|ln_rx_slow_pat_a[7:0]) & ~(tx_rx_tsm[2:0] == 3'b000);                                
                                
assign slow_a_cnt_din[6:0]      = (slow_a_cnt_q[6]   & (tx_rx_tsm[2:0] == 3'b001)) ? slow_a_cnt_q[6:0]              :
                                  (rx_slow_a_pattern & (tx_rx_tsm[2:0] == 3'b001)) ? slow_a_cnt_q[6:0] + 7'b0000001 :
                                                                                     7'b0000000;
assign rx_tx_slow_clock         = slow_a_cnt_q[6];

assign ln_pattern_a_din[7:0]  = ln_pattern_a[7:0]   | ln_pattern_a_q[7:0];
assign ln_pattern_b_din[7:0]  = ln_pattern_b[7:0]   | ln_pattern_b_q[7:0];
assign ln_sync_din[7:0]       = (ln_sync[7:0]       | ln_sync_q[7:0]) | {8{sim_only_fast_train}};
assign ln_block_lock_din[7:0] = ln_block_lock[7:0];
//-- don't report seeing patterns until enough time has elapsed to determine which lanes are trainable
assign ln_TS1_din[7:0]        = ((ln_TS1[7:0] & {8{rx_trained_lanes_cntr_done}})      | ln_TS1_q[7:0]) & ~{8{(|ln_TS2_q[7:0]) | start_retrain}}; //-- latch high if seeing pattern and clear if seeing next pattern
assign ln_TS2_din[7:0]        = ((ln_TS2[7:0] & {8{rx_trained_lanes_cntr_done}})      | ln_TS2_q[7:0]) & ~{8{(|ln_TS3_q[7:0]) | start_retrain}}; //-- latch high if seeing pattern and clear if seeing next pattern
assign ln_TS3_din[7:0]        = ((ln_TS3[7:0] & {8{rx_trained_lanes_cntr_done}})      | ln_TS3_q[7:0]) & ~{8{                 | start_retrain}};



//--------------------------------------------------------
//--            TS2/TS3 Pattern Decode
//--  
//--------------------------------------------------------
//-- Receive TS2/TS3 patterns with bytes reversed
//-- Determines which TX lanes to disable
//--
//--            block 0 | block 1 | block 2 | block 3
//-- eg: TS2  =  454B   |  4545   |  4545   |  YYXX
//-- eg: TS3  =  414B   |  4141   |  4141   |  YYXX
//--
//-- XX = TS Byte 0
//-- YY = TS Byte 1
//--
//--  VERSION 8
//--  Good Lanes INFO
//--  received[15:0]  TS Byte  info
//--  --------------  -------  ----
//--  15  (block 3)   1        x32 width
//--  14  (block 3)   1        x16 width
//--  13  (block 3)   1        x8  width
//--  12  (block 3)   1        x4  width
//--  11  (block 3)   1        outside lanes trained (0, 2, 5, 7)
//--  10  (block 3)   1        inside  lanes trained (1, 3, 4, 6)
//--  9   (block 3)   1        lanes 2 and 5 trained
//--  8   (block 3)   1        lanes 0 and 7 trained
//--  7:0 (block 3)   0        reserved
assign rx_ts_ln0_data_din[15:0]   = (deskew_all_valid_q & rx_trained_ln0_b2_q) ? ln0_data[15:0] : rx_ts_ln0_data_q[15:0];
assign rx_ts_ln1_data_din[15:0]   = (deskew_all_valid_q & rx_trained_ln1_b2_q) ? ln1_data[15:0] : rx_ts_ln1_data_q[15:0];
assign rx_ts_ln5_data_din[15:0]   = (deskew_all_valid_q & rx_trained_ln5_b2_q) ? ln5_data[15:0] : rx_ts_ln5_data_q[15:0]; //-- Only needed for Z x2 degraded inner mode

assign ts_match                   = deskew_all_valid_q & ( (rx_trained_ln0_b2_q & (ln0_data[15:0] == rx_ts_ln0_data_q[15:0]) & ( enable_ln0                            & rx_trained_lanes_q[0])) |  //-- use lane 0 if able to train
                                                           (rx_trained_ln1_b2_q & (ln1_data[15:0] == rx_ts_ln1_data_q[15:0]) & (~enable_ln0 &  enable_ln1              & rx_trained_lanes_q[1])) |  //-- use lane 1 if unable to train lane 0
                                                           (rx_trained_ln5_b2_q & (ln5_data[15:0] == rx_ts_ln5_data_q[15:0]) & (~enable_ln0 & ~enable_ln1 & enable_ln5 & rx_trained_lanes_q[5])) ); //-- use lane 2 if unable to train lane 1 & 2

//--  already decoded TS good lanes, but are seeing a new value in the TS good lanes during a TS2/TS3
assign ts_new_pattern             = deskew_all_valid_q & ts_valid_q &
                                    ( (rx_trained_ln0_b2_q & (ln0_data[15:0] != rx_ts_ln0_data_q[15:0]) & (enable_ln0 & rx_trained_lanes_q[0])) |  //-- use lane 0 if able to train
                                      (rx_trained_ln1_b2_q & (ln1_data[15:0] != rx_ts_ln1_data_q[15:0]) & (enable_ln1 & rx_trained_lanes_q[1])) |  //-- use lane 1 if unable to train lane 0
                                      (rx_trained_ln5_b2_q & (ln5_data[15:0] != rx_ts_ln5_data_q[15:0]) & (enable_ln5 & rx_trained_lanes_q[5])) ); //-- use lane 2 if unable to train lane 1 & 2


assign ts_recheck_din             = (ts_new_pattern | ts_recheck_q) & ~(ts_recheck_matches_prev | start_retrain | load_new_ts_pattern | link_trained_q);
//-- check to see if current pattern matches already accepted good lane pattern
assign ts_recheck_matches_prev    = ts_recheck_q &
                                    ( (rx_trained_ln0_b2_q & (ln0_data[15:0] == ts_good_lanes_q[15:0]) & (enable_ln0 & rx_trained_lanes_q[0])) | 
                                      (rx_trained_ln1_b2_q & (ln1_data[15:0] == ts_good_lanes_q[15:0]) & (enable_ln1 & rx_trained_lanes_q[1])) | 
                                      (rx_trained_ln5_b2_q & (ln5_data[15:0] == ts_good_lanes_q[15:0]) & (enable_ln5 & rx_trained_lanes_q[5])) );

assign ts_recheck_inc             = ts_recheck_q & ~load_new_ts_pattern & ~ts_recheck_matches_prev &
                                    ( (rx_trained_ln0_b2_q & (ln0_data[15:0] == rx_ts_ln0_data_q[15:0]) & (enable_ln0 & rx_trained_lanes_q[0])) |  //-- use lane 0 if able to train
                                      (rx_trained_ln1_b2_q & (ln1_data[15:0] == rx_ts_ln1_data_q[15:0]) & (enable_ln1 & rx_trained_lanes_q[1])) |  //-- use lane 1 if unable to train lane 0
                                      (rx_trained_ln5_b2_q & (ln5_data[15:0] == rx_ts_ln5_data_q[15:0]) & (enable_ln5 & rx_trained_lanes_q[5])));
assign load_new_ts_pattern        = ts_recheck_cntr_q[2];
assign new_ts_pattern[15:0]       = load_new_ts_pattern & (enable_ln0 & rx_trained_lanes_q[0]) ? rx_ts_ln0_data_q[15:0] :
                                    load_new_ts_pattern & (enable_ln1 & rx_trained_lanes_q[1]) ? rx_ts_ln1_data_q[15:0] :
                                    load_new_ts_pattern & (enable_ln5 & rx_trained_lanes_q[5]) ? rx_ts_ln5_data_q[15:0] :
                                                                                                 16'h0000;

assign ts_recheck_reset           = start_retrain | ts_recheck_matches_prev | load_new_ts_pattern;
assign ts_recheck_cntr_din[2:0]   = ts_recheck_reset ? 3'b000 :
                                    ts_recheck_inc   ? ts_recheck_cntr_q[2:0] + 3'b001 :
                                                       ts_recheck_cntr_q[2:0];

//-- Increment count when seeing same TS2/3 pattern in a row
//-- 8/22assign ts_cntr_din[3:0]           = start_retrain | 
assign ts_cntr_din[3:0]           = start_retrain | (|ln_TS1[7:0]) |
                                    (((rx_trained_ln0_b2_q & enable_ln0 & rx_trained_lanes_q[0]) |
                                      (rx_trained_ln1_b2_q & enable_ln1 & rx_trained_lanes_q[1]) |
                                      (rx_trained_ln5_b2_q & enable_ln5 & rx_trained_lanes_q[5])) & ~ts_match & ~ts_cntr_q[3]) ? 4'b0000                  :
                                                                                                    (ts_match & ~ts_cntr_q[3]) ? ts_cntr_q[3:0] + 4'b0001 :
                                                                                                                                 ts_cntr_q[3:0];
//-- deskew parser needs to be done first before ts_parser so we can tell if lanes need to be reversed
assign ts_valid_din               = (|ts_cntr_q[3:2]) & deskew_done_q;
assign ts_valid_rising_edge       = ts_valid_din & ~ts_valid_q;
assign ts_good_lanes_din[15:0]    = ts_valid_q & ~load_new_ts_pattern                         ? ts_good_lanes_q[15:0]  :
                                    ts_valid_q &  load_new_ts_pattern                         ? new_ts_pattern[15:0]   : //-- received good pattern but now there are 4 new consecutive matching patterns
                                    ts_valid_rising_edge & enable_ln0 & rx_trained_lanes_q[0] ? rx_ts_ln0_data_q[15:0] : //-- initial consecutive TS pattern
                                    ts_valid_rising_edge & enable_ln1 & rx_trained_lanes_q[1] ? rx_ts_ln1_data_q[15:0] : //-- initial consecutive TS pattern
                                    ts_valid_rising_edge & enable_ln5 & rx_trained_lanes_q[5] ? rx_ts_ln5_data_q[15:0] : //-- initial consecutive TS pattern
                                                                                                ts_good_lanes_q[15:0];
assign rx_tx_ts_valid             = ts_valid_q;
assign rx_tx_ts_good_lanes[15:0]  = ts_good_lanes_q[15:0];
assign ts_byte0[7:0]              = ts_good_lanes_q[ 7:0];
assign ts_byte1[7:0]              = ts_good_lanes_q[15:8];

//-- Align block # of TS2/TS3 Pattern 
assign rx_trained_ln0_b0_din      = deskew_all_valid_q ? dl_training         & ((ln0_data[15:0] == 16'h454B) | (ln0_data[15:0] == 16'h414B)) : rx_trained_ln0_b0_q;
assign rx_trained_ln0_b1_din      = deskew_all_valid_q ? rx_trained_ln0_b0_q & ((ln0_data[15:0] == 16'h4545) | (ln0_data[15:0] == 16'h4141)) : rx_trained_ln0_b1_q;
assign rx_trained_ln0_b2_din      = deskew_all_valid_q ? rx_trained_ln0_b1_q & ((ln0_data[15:0] == 16'h4545) | (ln0_data[15:0] == 16'h4141)) : rx_trained_ln0_b2_q;

assign rx_trained_ln1_b0_din      = deskew_all_valid_q ? dl_training         & ((ln1_data[15:0] == 16'h454B) | (ln1_data[15:0] == 16'h414B)) : rx_trained_ln1_b0_q;
assign rx_trained_ln1_b1_din      = deskew_all_valid_q ? rx_trained_ln1_b0_q & ((ln1_data[15:0] == 16'h4545) | (ln1_data[15:0] == 16'h4141)) : rx_trained_ln1_b1_q;
assign rx_trained_ln1_b2_din      = deskew_all_valid_q ? rx_trained_ln1_b1_q & ((ln1_data[15:0] == 16'h4545) | (ln1_data[15:0] == 16'h4141)) : rx_trained_ln1_b2_q;

assign rx_trained_ln5_b0_din      = deskew_all_valid_q ? dl_training         & ((ln5_data[15:0] == 16'h454B) | (ln5_data[15:0] == 16'h414B)) : rx_trained_ln5_b0_q;
assign rx_trained_ln5_b1_din      = deskew_all_valid_q ? rx_trained_ln5_b0_q & ((ln5_data[15:0] == 16'h4545) | (ln5_data[15:0] == 16'h4141)) : rx_trained_ln5_b1_q;
assign rx_trained_ln5_b2_din      = deskew_all_valid_q ? rx_trained_ln5_b1_q & ((ln5_data[15:0] == 16'h4545) | (ln5_data[15:0] == 16'h4141)) : rx_trained_ln5_b2_q;


//-- TS2/TS3 decode.  Determine which TX lanes should be killed
assign ts_trained_x32             = ts_valid_q & ts_byte1[7];
assign ts_trained_x16             = ts_valid_q & ts_byte1[6];
assign ts_trained_x8              = ts_valid_q & ts_byte1[5];
assign ts_trained_x4              = ts_valid_q & ts_byte1[4];
assign ts_mode_x4_inner           = ts_valid_q & ts_byte1[3] & ts_trained_x8;
assign ts_mode_x4_outer           = ts_valid_q & ts_byte1[2] & ts_trained_x8;
assign ts_mode_x2_inner           = ts_valid_q & ts_byte1[3] & ts_trained_x4;
assign ts_mode_x2_outer           = ts_valid_q & ts_byte1[2] & ts_trained_x4;
assign rx_tx_trained_mode[3:0]    = {ts_trained_x32, ts_trained_x16, ts_trained_x8, ts_trained_x4};

assign disabled_tx_lanes[7]       = ts_valid_q & ~(ts_mode_x4_outer | ts_mode_x2_outer);                              
assign disabled_tx_lanes[6]       = ts_valid_q & ~(ts_mode_x4_inner                   );                              
assign disabled_tx_lanes[5]       = ts_valid_q & ~(ts_mode_x4_outer | ts_mode_x2_inner);
assign disabled_tx_lanes[4]       = ts_valid_q & ~(ts_mode_x4_inner                   );
assign disabled_tx_lanes[3]       = ts_valid_q & ~(ts_mode_x4_inner                   );
assign disabled_tx_lanes[2]       = ts_valid_q & ~(ts_mode_x4_outer | ts_mode_x2_inner);
assign disabled_tx_lanes[1]       = ts_valid_q & ~(ts_mode_x4_inner                   );
assign disabled_tx_lanes[0]       = ts_valid_q & ~(ts_mode_x4_outer | ts_mode_x2_outer);

assign rx_tx_disabled_tx_lanes[7:0] = disabled_tx_lanes[7:0];

//--------------------------------------------------------
//--            Deskew Control Logic 
//--
//--------------------------------------------------------
//-- Tell lanes to start deskew once every lane is block locked and seeing either TS1/TS2 patterns
//--
//--

//-- reset when at least one lane loses block lock.  deskew enable makes deskew_reset a single cycle pulse
assign deskew_reset           = deskew_enable_q & ( ((ln_block_lock_q[7:0] | disabled_rx_lanes_q[7:0]) != 8'hFF) |
                                                    ( deskew_overflow_q                                        ) |
                                                    ( PM_deskew_reset                                          ) );
assign PM_deskew_reset        = tx_rx_PM_deskew_reset;

assign ln_deskew_reset        = deskew_reset;
assign deskew_found_din       = ((|ln_deskew_found[7:0]) & (&(ln_TS1_q[7:0] | ln_TS2_q[7:0] | disabled_rx_lanes_q[7:0]))) | (deskew_found_q & ~deskew_reset);

assign inc_deskew_enable_dly_count = deskew_found_q & ~deskew_enable_dly_maxed;
assign deskew_enable_dly_maxed     = deskew_enable_dly_q[4];

assign deskew_enable_dly_din[4:0] = ( (deskew_enable_dly_q[4:0] + 5'b1) & {5{ inc_deskew_enable_dly_count}} |
                                      (deskew_enable_dly_q[4:0]       ) & {5{~inc_deskew_enable_dly_count}} ) & {5{~deskew_reset}};


assign deskew_enable_din          = ( (&( ln_block_lock[7:0]             | disabled_rx_lanes_q[7:0])) &
                                      (&((ln_TS1_q[7:0] | ln_TS2_q[7:0]) | disabled_rx_lanes_q[7:0])) &
                                      (deskew_enable_dly_maxed                                      )   ) | (deskew_enable_q & ~deskew_reset);
assign ln_deskew_enable           = deskew_enable_q;

assign deskew_all_valid           = (((ln_deskew_valid[7:0] & ln_deskew_hold[7:0]) | disabled_rx_lanes_q[7:0]) == 8'hFF);
assign deskew_all_valid_din       = deskew_all_valid;
assign ln_all_valid               = deskew_all_valid;


assign deskew_overflow_din           = (|ln_deskew_overflow[7:0]);
assign deskew_overflow_dly_din       = deskew_overflow_q;
//-- report overflow when it has happened 4 times
assign rx_tx_deskew_overflow         = deskew_overflow_q & deskew_overflow_cntr_q[2];
assign reset_deskew_overflow_cntr    = (tx_rx_tsm[2:0] == 3'b111);
assign inc_deskew_overflow_cntr      = deskew_overflow_q & ~deskew_overflow_cntr_q[2] & ~retry_timer_running_q;
assign deskew_overflow_cntr_din[2:0] = reset_deskew_overflow_cntr ? 3'b000 :
                                       inc_deskew_overflow_cntr   ? deskew_overflow_cntr_q[2:0] + 3'b001 :
                                                                    deskew_overflow_cntr_q[2:0];

//-- When any lane reports a deskew overflow, increment the deskew overflow counter once.  However, don't increment back to back cycles
//-- need to wait 16 cycles before checking for another deskew overflow aka when the retry timer is finished.
assign retry_timer_start             = deskew_overflow_q & ~deskew_overflow_dly_q & ~retry_timer_running_q;
assign retry_timer_running_din       = (retry_timer_start | retry_timer_running_q) & ~retry_timer_done;
assign retry_timer_done              = (deskew_overflow_retry_timer_q[3:0] == 4'b1111);
assign retry_timer_inc               = retry_timer_running_q & ~retry_timer_done;
assign deskew_overflow_retry_timer_din[3:0] = retry_timer_done ? 4'b0000 :
                                              retry_timer_inc  ? deskew_overflow_retry_timer_q[3:0] + 4'b0001 :
                                                                 deskew_overflow_retry_timer_q[3:0];



assign deskew_done_din            = (deskew_cnt_q[3] | deskew_done_q) & ~(start_retrain | deskew_reset);

//-- 8/2assign one_dskw_match      = (rx_deskew_ln0_b2_q & ~disabled_rx_lanes_q[0]) | (rx_deskew_ln1_b2_q & (disabled_rx_lanes_q[0] & ~disabled_rx_lanes_q[1]));
assign one_dskw_match      = (rx_deskew_ln0_b2_q & ~disabled_rx_lanes_q[0]) | (rx_deskew_ln1_b2_q & (disabled_rx_lanes_q[1:0] == 2'b01)) |
                             (rx_deskew_ln5_b2_q & (disabled_rx_lanes_q[1:0] == 2'b11) & ~disabled_rx_lanes_q[5]);
assign deskew_cnt_din[3:0] = (deskew_overflow_q | deskew_reset |
                             (one_dskw_match & ~deskew_tick & ~(|deskew_cnt_q[3:2]))  )  ? 4'b0000                     :
                              start_retrain & deskew_cnt_q[3]                       ? 4'b0111                     : //-- decrease retraining linkup time
//-- 7/10                  start_retrain                                         ? 4'b0111                     : //-- decrease retraining linkup time
                             (deskew_tick & ~deskew_cnt_q[3])                       ? deskew_cnt_q[3:0] + 4'b0001 :
                                                                                      deskew_cnt_q[3:0];                                

assign deskew_tick         = (ln0_dskw_match & ~disabled_rx_lanes_q[0]                                                    ) | 
                             (ln1_dskw_match &  disabled_rx_lanes_q[0] & ~disabled_rx_lanes_q[1]                          ) | 
                             (ln5_dskw_match &  disabled_rx_lanes_q[0] &  disabled_rx_lanes_q[1] & ~disabled_rx_lanes_q[5]);


//--------------------------------------------------------
//--            Deskew Pattern Decode
//--  
//--------------------------------------------------------
//-- Wait until a match on block 0 and then try to match all subsequent blocks
//-- Determine if lanes are reversed, supported modes, or if TX needs to swap lanes.
//--
//--               block 0 | block 1 | block 2 | block 3
//-- eg: DESKEW  =  1E4B   |  1E1E   |  XX1E   |  ZZYY
//--
//-- XX = Deskew Byte 0
//-- YY = Deskew Byte 1
//-- ZZ = Deskew Byte 2
//--
//--  Lane # and Configuration INFO 
//--  received[15:0]      Deskew Byte   info
//--  --------------      -----------   ----

//--  15    (block 3 ZZ)  2             TX lane ordering for degraded modes: 1 = FPGA (lane then neighbor), 0 = HOST (neighbor then lane)
//--  14    (block 3 ZZ)  2             TX lane swap requested
//--  13    (block 3 ZZ)  2             Power management supported
//--  12:8  (block 3 ZZ)  2             Lane number

//--  7     (block 3 YY)  1             Half width degraded mode supported
//--  6     (block 3 YY)  1             Reserved
//--  5:0   (block 3 YY)  1             Version Number
//--
//--  15:12 (block 2 XX)  0             reserved
//--  11    (block 2 XX)  0             x32 mode supported
//--  10    (block 2 XX)  0             x16 mode supported
//--  9     (block 2 XX)  0             x8  mode supported
//--  8     (block 2 XX)  0             x4  mode supported


//-- Align block # of DESKEW Pattern 
assign rx_deskew_ln0_b0_din           = deskew_all_valid_q ? dl_training        & (ln0_data[15:0] == 16'h1E4B) : rx_deskew_ln0_b0_q;
assign rx_deskew_ln0_b1_din           = deskew_all_valid_q ? rx_deskew_ln0_b0_q & (ln0_data[15:0] == 16'h1E1E) : rx_deskew_ln0_b1_q;
assign rx_deskew_ln0_b2_din           = deskew_all_valid_q ? rx_deskew_ln0_b1_q & (ln0_data[ 7:0] ==  8'h1E  ) : rx_deskew_ln0_b2_q;
assign rx_deskew_ln0_b3_din           = deskew_all_valid_q ? rx_deskew_ln0_b2_q                                : rx_deskew_ln0_b3_q;

assign rx_deskew_ln1_b0_din           = deskew_all_valid_q ? dl_training        & (ln1_data[15:0] == 16'h1E4B) : rx_deskew_ln1_b0_q;
assign rx_deskew_ln1_b1_din           = deskew_all_valid_q ? rx_deskew_ln1_b0_q & (ln1_data[15:0] == 16'h1E1E) : rx_deskew_ln1_b1_q;
assign rx_deskew_ln1_b2_din           = deskew_all_valid_q ? rx_deskew_ln1_b1_q & (ln1_data[ 7:0] ==  8'h1E  ) : rx_deskew_ln1_b2_q;
assign rx_deskew_ln1_b3_din           = deskew_all_valid_q ? rx_deskew_ln1_b2_q                                : rx_deskew_ln1_b3_q;

//-- Only need lane 2 to determine if rx lanes are reversed
assign rx_deskew_ln2_b0_din           = deskew_all_valid_q ? dl_training        & (ln2_data[15:0] == 16'h1E4B) : rx_deskew_ln2_b0_q;
assign rx_deskew_ln2_b1_din           = deskew_all_valid_q ? rx_deskew_ln2_b0_q & (ln2_data[15:0] == 16'h1E1E) : rx_deskew_ln2_b1_q;
assign rx_deskew_ln2_b2_din           = deskew_all_valid_q ? rx_deskew_ln2_b1_q & (ln2_data[ 7:0] ==  8'h1E  ) : rx_deskew_ln2_b2_q;

assign rx_deskew_ln5_b0_din           = deskew_all_valid_q ? dl_training        & (ln5_data[15:0] == 16'h1E4B) : rx_deskew_ln5_b0_q;
assign rx_deskew_ln5_b1_din           = deskew_all_valid_q ? rx_deskew_ln5_b0_q & (ln5_data[15:0] == 16'h1E1E) : rx_deskew_ln5_b1_q;
assign rx_deskew_ln5_b2_din           = deskew_all_valid_q ? rx_deskew_ln5_b1_q & (ln5_data[ 7:0] ==  8'h1E  ) : rx_deskew_ln5_b2_q;
assign rx_deskew_ln5_b3_din           = deskew_all_valid_q ? rx_deskew_ln5_b2_q                                : rx_deskew_ln5_b3_q;


assign rx_deskew_ln0_data_din[ 7: 0]  = (deskew_all_valid_q & rx_deskew_ln0_b1_q) ? ln0_data[15:8] : rx_deskew_ln0_data_q[ 7: 0];
assign rx_deskew_ln0_data_din[23: 8]  = (deskew_all_valid_q & rx_deskew_ln0_b2_q) ? ln0_data[15:0] : rx_deskew_ln0_data_q[23: 8];
assign rx_deskew_ln1_data_din[ 7: 0]  = (deskew_all_valid_q & rx_deskew_ln1_b1_q) ? ln1_data[15:8] : rx_deskew_ln1_data_q[ 7: 0];
assign rx_deskew_ln1_data_din[23: 8]  = (deskew_all_valid_q & rx_deskew_ln1_b2_q) ? ln1_data[15:0] : rx_deskew_ln1_data_q[23: 8];
assign rx_deskew_ln5_data_din[ 7: 0]  = (deskew_all_valid_q & rx_deskew_ln5_b1_q) ? ln5_data[15:8] : rx_deskew_ln5_data_q[ 7: 0];
assign rx_deskew_ln5_data_din[23: 8]  = (deskew_all_valid_q & rx_deskew_ln5_b2_q) ? ln5_data[15:0] : rx_deskew_ln5_data_q[23: 8];


//-- current deskew matches previous deskew, block 2 INFO                                           
assign ln0_dskw_match_c0_din          = deskew_all_valid_q ? ((ln0_data[15:8] == rx_deskew_ln0_data_q[7:0]) & rx_deskew_ln0_b1_q) : ln0_dskw_match_c0_q;
assign ln1_dskw_match_c0_din          = deskew_all_valid_q ? ((ln1_data[15:8] == rx_deskew_ln1_data_q[7:0]) & rx_deskew_ln1_b1_q) : ln1_dskw_match_c0_q;
assign ln5_dskw_match_c0_din          = deskew_all_valid_q ? ((ln5_data[15:8] == rx_deskew_ln5_data_q[7:0]) & rx_deskew_ln5_b1_q) : ln5_dskw_match_c0_q;

//-- current deskew matches prevous entire deskew pattern 
assign ln0_dskw_match                 = (ln0_data[15:0] == rx_deskew_ln0_data_q[23:8]) & rx_deskew_ln0_b2_q & ln0_dskw_match_c0_q;
assign ln1_dskw_match                 = (ln1_data[15:0] == rx_deskew_ln1_data_q[23:8]) & rx_deskew_ln1_b2_q & ln1_dskw_match_c0_q;
assign ln5_dskw_match                 = (ln5_data[15:0] == rx_deskew_ln5_data_q[23:8]) & rx_deskew_ln5_b2_q & ln5_dskw_match_c0_q;

//-- deskew pattern decode
//-- If the lanes are reversed,  ln 0, 2, 5, and 7 are hooked to ln 3, 2, 1, 0 respectively
//--  lane 1 is never attached to a 
assign rx_lane0_rev_cases             = (ln0_data[12:8] == 5'b00011) | //--  connected to Z     and lanes reversed
                                        (ln0_data[12:8] == 5'b00111);  //--  connected to  and lanes reversed
//-- Need to look at inner pair to determine if lanes are reversed for  (8 Lane) or Z (4 Lane) because looking at a single inner lane cannot tell difference between reversed or not reversed.
//-- Look at last 2 values of lane 2's lane number to make sure a CRC on the lane number doesn't cause the DL to think the lanes are reversed.
assign rx_lane5_rev_cases             = ((ln5_data[12:8] == 5'b00010) & (ln2_data[12:8] == 5'b00101) & (ln2_lane_num_q[4:0] == 5'b00101) & rx_deskew_ln2_b2_q) | //--  connected to and lanes reversed
                                        ((ln5_data[12:8] == 5'b00001) & (ln2_data[12:8] == 5'b00010) & (ln2_lane_num_q[4:0] == 5'b00010) & rx_deskew_ln2_b2_q);  //--  connected to and lanes reversed
//-- retrain last valid lane number
assign ln2_lane_num_din[4:0]          = ((ln2_data[12:8]     ) & {5{ rx_deskew_ln2_b2_q}}) |
                                        ((ln2_lane_num_q[4:0]) & {5{~rx_deskew_ln2_b2_q}});

assign rx_lane_reverse_din            = ( (((choose_x8 & ln0_data[12:8] == 5'b00111) | (choose_x4 & rx_lane0_rev_cases)) & deskew_all_valid_q & rx_deskew_ln0_b2_q & ln0_dskw_match & (|deskew_cnt_q[3:2])) |
                                          (((choose_x8 & ln1_data[12:8] == 5'b00110)                                   ) & deskew_all_valid_q & rx_deskew_ln1_b2_q & ln1_dskw_match & (|deskew_cnt_q[3:2])) |
                                          (((choose_x8 & ln5_data[12:8] == 5'b00010) | (choose_x4 & rx_lane5_rev_cases)) & deskew_all_valid_q & rx_deskew_ln5_b2_q & ln5_dskw_match & (|deskew_cnt_q[3:2])) |
                                           rx_lane_reverse_q );

assign sim_only_request_ln_rev        = tx_rx_sim_only_request_ln_rev;
assign trn_agn_ln_swap                = ~sim_only_request_ln_rev & rx_lane_reverse_q; //-- Reverse lanes on this side of link
assign rx_tx_rx_lane_reverse          = rx_lane_reverse_q; //-- Tell other side of link to reverse order, note this is always disabled
                                                           //-- unless a stick is applied in dlc_omi_tx_train.v

assign deskew_config_valid            = (|deskew_cnt_q[3:2]);
assign deskew_config_rising_edge      = (|deskew_cnt_din[3:2]) & ~(|deskew_cnt_q[3:2]);
assign deskew_config_din[23:0]        = deskew_config_valid       & ~load_new_DM_pattern               ? deskew_config_q[23:0]      :
                                        deskew_config_valid       &  load_new_DM_pattern               ? new_DM_pattern[23:0]       :
                                        deskew_config_rising_edge & enable_ln0 & rx_trained_lanes_q[0] ? rx_deskew_ln0_data_q[23:0] :
                                        deskew_config_rising_edge & enable_ln1 & rx_trained_lanes_q[1] ? rx_deskew_ln1_data_q[23:0] :
                                        deskew_config_rising_edge & enable_ln5 & rx_trained_lanes_q[5] ? rx_deskew_ln5_data_q[23:0] :
                                                                                                         deskew_config_q[23:0];
assign rx_tx_deskew_config_valid      = deskew_config_valid;                                       //-- To debug bus
assign rx_tx_deskew_config[18:0]      = {deskew_byte2[7:5], deskew_byte1[7:0], deskew_byte0[7:0]}; //-- To debug bus ( to send lane number)

//--  already decoded valid DM, but are seeing a new value in the DM during link training
assign DM_new_pattern             = deskew_all_valid_q & deskew_config_valid &
                                    ( ((rx_deskew_ln0_b2_q & (~ln0_dskw_match_c0_q | ~ln0_dskw_match)) & (enable_ln0 & rx_trained_lanes_q[0])) |  //-- use lane 0 if able to train
                                      ((rx_deskew_ln1_b2_q & (~ln1_dskw_match_c0_q | ~ln1_dskw_match)) & (enable_ln1 & rx_trained_lanes_q[1])) |  //-- use lane 1 if unable to train lane 0
                                      ((rx_deskew_ln5_b2_q & (~ln5_dskw_match_c0_q | ~ln5_dskw_match)) & (enable_ln5 & rx_trained_lanes_q[5])) ); //-- use lane 2 if unable to train lane 0 & 1

assign DM_recheck_din             = (DM_new_pattern | DM_recheck_q) & ~(DM_recheck_matches_prev | start_retrain | load_new_DM_pattern | link_trained_q);

//-- check to see if current pattern matches already accepted DM pattern. Therefore, new DM pattern was due to crc error
assign DM_recheck_c0_matches_prev_din = (~deskew_all_valid_q & DM_recheck_c0_matches_prev_q & DM_recheck_q) |  //-- hold previous value if not deskew all valid
                                        ( deskew_all_valid_q & DM_recheck_q &                                  //-- compare the first byte of DM
                                           ( (rx_deskew_ln0_b1_q & (ln0_data[15:8] == deskew_config_q[7:0]) & (enable_ln0 & rx_trained_lanes_q[0])) | 
                                             (rx_deskew_ln1_b1_q & (ln1_data[15:8] == deskew_config_q[7:0]) & (enable_ln1 & rx_trained_lanes_q[1])) |
                                             (rx_deskew_ln5_b1_q & (ln5_data[15:8] == deskew_config_q[7:0]) & (enable_ln5 & rx_trained_lanes_q[5])) ) );

assign DM_recheck_matches_prev    = DM_recheck_q &
                                    ( (rx_deskew_ln0_b2_q & (ln0_data[15:0] == deskew_config_q[23:8]) & DM_recheck_c0_matches_prev_q & (enable_ln0 & rx_trained_lanes_q[0])) | 
                                      (rx_deskew_ln1_b2_q & (ln1_data[15:0] == deskew_config_q[23:8]) & DM_recheck_c0_matches_prev_q & (enable_ln1 & rx_trained_lanes_q[1])) |
                                      (rx_deskew_ln5_b2_q & (ln5_data[15:0] == deskew_config_q[23:8]) & DM_recheck_c0_matches_prev_q & (enable_ln5 & rx_trained_lanes_q[5])) );

assign DM_recheck_inc             = DM_recheck_q & ~load_new_DM_pattern & ~DM_recheck_matches_prev &
                                    ( (rx_deskew_ln0_b2_q & (ln0_data[15:0] == rx_deskew_ln0_data_q[23:8]) & ln0_dskw_match_c0_q  & (enable_ln0 & rx_trained_lanes_q[0])) |  //-- use lane 0 if able to train
                                      (rx_deskew_ln1_b2_q & (ln1_data[15:0] == rx_deskew_ln1_data_q[23:8]) & ln1_dskw_match_c0_q  & (enable_ln1 & rx_trained_lanes_q[1])) |  //-- use lane 1 if unable to train lane 0
                                      (rx_deskew_ln5_b2_q & (ln5_data[15:0] == rx_deskew_ln5_data_q[23:8]) & ln5_dskw_match_c0_q  & (enable_ln5 & rx_trained_lanes_q[5])) ); //-- use lane 2 if unable to train lane 0 & 1

//-- received 3 consecutive matching DM patterns
assign load_new_DM_pattern        = DM_recheck_cntr_q[1];
assign new_DM_pattern[23:0]       = load_new_DM_pattern & (enable_ln0 & rx_trained_lanes_q[0]) ? rx_deskew_ln0_data_q[23:0] :
                                    load_new_DM_pattern & (enable_ln1 & rx_trained_lanes_q[1]) ? rx_deskew_ln1_data_q[23:0] :
                                    load_new_DM_pattern & (enable_ln5 & rx_trained_lanes_q[5]) ? rx_deskew_ln5_data_q[23:0] :
                                                                                                 24'b0;

assign DM_recheck_reset           = start_retrain | DM_recheck_matches_prev | load_new_DM_pattern;
assign DM_recheck_cntr_din[1:0]   = DM_recheck_reset ? 2'b00 :
                                    DM_recheck_inc   ? DM_recheck_cntr_q[1:0] + 2'b01 :
                                                       DM_recheck_cntr_q[1:0];

//-- Version Number is identical between lanes and are seeing same version number for at least 4 deskew patterns
assign deskew_byte0[7:0]               = deskew_config_q[ 7: 0];
assign deskew_byte1[7:0]               = deskew_config_q[15: 8];
assign deskew_byte2[7:0]               = deskew_config_q[23:16];

assign version_number[5:0]             = deskew_byte1[5:0];
assign rx_tx_version_number[5:0]       = version_number[5:0];

assign supported_widths[3:0]           = deskew_byte0[3:0];      //-- Endpoint supported modes
assign rx_cfg_x32                      = supported_widths[3];
assign rx_cfg_x16                      = supported_widths[2];
assign rx_cfg_x8                       = supported_widths[1];
assign rx_cfg_x4                       = supported_widths[0];
assign rx_tx_rem_supported_widths[3:0] = supported_widths[3:0];
assign rx_neighbor_last                = deskew_byte2[7];
assign tx_lane_swap                    = deskew_byte2[6];
assign rem_PM_enable                   = deskew_byte2[5];

assign rx_tx_tx_ordering               = rx_neighbor_last;       //-- Endpoint info for status register
assign rx_tx_tx_lane_swap              = tx_lane_swap;
assign rx_tx_rem_PM_enable             = rem_PM_enable;

//--------------------------------------------------------
//--              64/66 Header Control Logic
//--
//--------------------------------------------------------
//--                   
//--  Anaylze headers to determine if link is up or needs to retrain
//--
assign link_up_din                    = data_sync_hdr | link_up_q;
assign trn_mn_trained                 = link_trained_q;
assign trn_agn_trained                = link_trained_q;
assign trn_agn_retrain                = start_retrain;

assign trn_ln_trained                 = link_trained_q;
assign dl2tl_link_up                  = link_up_q;  
assign dl2tl_dead_cycle               = link_up_q & ~deskew_all_valid_q;

assign data_sync_hdr_din[7:0]         = ln_data_sync_hdr[7:0];
assign trn_sync_hdr_din[7:0]          = ln_ctl_sync_hdr[7:0];

//-- if lane is disabled, treat it as if it is always seeing the data sync header.
assign sum_data_sync_hdr[3:0]         = {3'b000, (data_sync_hdr_q[7] | disabled_rx_lanes_q[7])} +
                                        {3'b000, (data_sync_hdr_q[6] | disabled_rx_lanes_q[6])} + 
                                        {3'b000, (data_sync_hdr_q[5] | disabled_rx_lanes_q[5])} + 
                                        {3'b000, (data_sync_hdr_q[4] | disabled_rx_lanes_q[4])} + 
                                        {3'b000, (data_sync_hdr_q[3] | disabled_rx_lanes_q[3])} + 
                                        {3'b000, (data_sync_hdr_q[2] | disabled_rx_lanes_q[2])} + 
                                        {3'b000, (data_sync_hdr_q[1] | disabled_rx_lanes_q[1])} + 
                                        {3'b000, (data_sync_hdr_q[0] | disabled_rx_lanes_q[0])};
assign data_sync_hdr_found            = (sum_data_sync_hdr[3] & deskew_all_valid_q) & link_trained_q;

//-- only use to determine if link is now up to reduce fanout on critical path
assign sum_unlatched_data_sync_hdr[3:0] = {3'b000, (ln_data_sync_hdr[7] & ~disabled_rx_lanes_q[7])} +
                                          {3'b000, (ln_data_sync_hdr[6] & ~disabled_rx_lanes_q[6])} + 
                                          {3'b000, (ln_data_sync_hdr[5] & ~disabled_rx_lanes_q[5])} + 
                                          {3'b000, (ln_data_sync_hdr[4] & ~disabled_rx_lanes_q[4])} + 
                                          {3'b000, (ln_data_sync_hdr[3] & ~disabled_rx_lanes_q[3])} + 
                                          {3'b000, (ln_data_sync_hdr[2] & ~disabled_rx_lanes_q[2])} + 
                                          {3'b000, (ln_data_sync_hdr[1] & ~disabled_rx_lanes_q[1])} + 
                                          {3'b000, (ln_data_sync_hdr[0] & ~disabled_rx_lanes_q[0])};

//-- make sure there are at least 2 lanes seeing data headers 2'b01
assign data_sync_hdr                  = deskew_all_valid & (sum_unlatched_data_sync_hdr[3:0] >= 4'b0010);
//-- link is dead when going into a retrain.  Make sure link doesn't go up/back up until at least 1 lane is able to see TS1/TS2s.
assign link_trained_din               = ((data_sync_hdr & (|rx_trained_lanes_q[7:0])) | link_trained_q) & ~start_retrain & (tx_rx_tsm[2:1] == 2'b11);
//-- don't count if lane is disabled
assign sum_trn_sync_hdr[3:0]          = {3'b000, (trn_sync_hdr_q[7] & ~disabled_rx_lanes_q[7])} +
                                        {3'b000, (trn_sync_hdr_q[6] & ~disabled_rx_lanes_q[6])} +
                                        {3'b000, (trn_sync_hdr_q[5] & ~disabled_rx_lanes_q[5])} +
                                        {3'b000, (trn_sync_hdr_q[4] & ~disabled_rx_lanes_q[4])} +
                                        {3'b000, (trn_sync_hdr_q[3] & ~disabled_rx_lanes_q[3])} +
                                        {3'b000, (trn_sync_hdr_q[2] & ~disabled_rx_lanes_q[2])} +
                                        {3'b000, (trn_sync_hdr_q[1] & ~disabled_rx_lanes_q[1])} +
                                        {3'b000, (trn_sync_hdr_q[0] & ~disabled_rx_lanes_q[0])};
                                      
//-- make sure there are at least 2 lanes seeing training sync headers 2'b10
assign sum_trn_sync_hdr_din           = (|sum_trn_sync_hdr[3:1]) & deskew_all_valid_q & link_trained_q;
assign rx_tx_training_sync_hdr        = sum_trn_sync_hdr_q;


//-- It takes 4 cycles to get a new header.  Looking at 32/4 = 8 headers in a row. If the next 7
//-- are missing the sync, report lost data sync.  This only happens when the link is trained, and EDPL is disabled.
//-- Headers have to be '11' or '00' to report lost data sync error
assign data_sync_cnt_din[6:1]     = data_sync_hdr_found               ? 6'b100000 :
                                    sum_trn_sync_hdr_q                ? 6'b000000 :
                                    ~dsc_eq_zero & deskew_all_valid_q ? data_sync_cnt_q[6:1] - 6'b000001 : //-- Don't decrement count when data is not valid 
                                                                        data_sync_cnt_q[6:1];
assign data_sync_cnt_din[0]       = ~dsc_eq_zero;
assign dsc_eq_zero                = data_sync_cnt_q[6:1] == 6'b000000;

//-- lost data sync if we had data sync and then have 7 cycles without data sync in a row when the link is up.
assign rx_tx_lost_data_sync       = data_sync_cnt_q[0] & dsc_eq_zero & link_trained_q;

//-- Debug Bus
assign trn_dbg0[87:0]             = 88'h0; //-- TX Train Information
assign trn_dbg1[87:0]             = 88'h0; //-- TX Train Information
assign trn_dbg2[87:0]             = 88'h0; //-- TX Train Information
assign trn_dbg3[87:0]             = 88'h0;
assign trn_dbg4[87:0]             = 88'h0;
assign trn_dbg5[87:0]             = 88'h0;
assign trn_dbg6[87:0]             = 88'h0;
assign trn_dbg7[87:0]             = 88'h0;
assign trn_dbg8[87:0]             = 88'h0;
assign trn_dbg9[87:0]             = 88'h0;
assign trn_dbgA[87:0]             = 88'h0;
assign trn_dbgB[87:0]             = 88'h0;

//-- TS Check
assign trn_dbgC[87:0]             = {1'b0,                         //--87
                                     tx_rx_tsm[2:0],               //--86:84
                                     rx_trained_lanes_cntr_q[5:0], //--83:78
                                     1'b0,                         //--77
                                     rx_trained_ln5_b2_q,          //--76
                                     rx_trained_ln1_b2_q,          //--75
                                     rx_trained_ln0_b2_q,          //--74
                                     deskew_all_valid_q,           //--73
                                     ts_valid_q,                   //--72
                                     ts_cntr_q[3:0],               //--71:68
                                     ts_recheck_q,                 //--67
                                     ts_recheck_cntr_q[2:0],       //--66:64
                                     ts_byte1[7:0],                //--63:56
                                     ts_byte0[7:0],                //--55:48
                                     ln5_data[15:0],               //--47:32
                                     ln1_data[15:0],               //--31:16
                                     ln0_data[15:0]};              //--15: 0

//-- DM Check
assign trn_dbgD[87:0]             = {1'b0,                         //--87
                                     tx_rx_tsm[2:0],               //--86:84
                                     rx_trained_lanes_cntr_q[5:0], //--83:78
                                     DM_recheck_cntr_q[1:0],       //--77:76
                                     DM_recheck_c0_matches_prev_q, //--75
                                     DM_recheck_q,                 //--74
                                     deskew_config_valid,          //--73
                                     deskew_all_valid_q,           //--72
                                     deskew_byte2[7:0],            //--71:64
                                     deskew_byte1[7:0],            //--63:56
                                     deskew_byte0[7:0],            //--55:48
                                     ln5_data[15:0],               //--47:32
                                     ln1_data[15:0],               //--31:16
                                     ln0_data[15:0]};              //--15: 0

//-- Inner lane debug info
assign trn_dbgE[87:0]             = {1'b0,                         //--87
                                     tx_rx_tsm[2:0],               //--86:84
                                     rx_trained_lanes_cntr_q[5:3], //--83:81
                                     deskew_all_valid_q,           //--80
                                     trn_sync_hdr_q[6],            //--79
                                     trn_sync_hdr_q[4],            //--78
                                     trn_sync_hdr_q[3],            //--77
                                     trn_sync_hdr_q[1],            //--76
                                     data_sync_hdr_q[6],           //--75
                                     data_sync_hdr_q[4],           //--74
                                     data_sync_hdr_q[3],           //--73
                                     data_sync_hdr_q[1],           //--72
                                     disabled_rx_lanes_q[7:0],     //--71:64
                                     ln6_data[15:0],               //--63:48
                                     ln4_data[15:0],               //--47:32
                                     ln3_data[15:0],               //--31:16
                                     ln1_data[15:0]};              //--15: 0

//-- Outer lane debug info
assign trn_dbgF[87:0]             = {1'b0,                         //--87
                                     tx_rx_tsm[2:0],               //--86:84
                                     rx_trained_lanes_cntr_q[5:3], //--83:81
                                     deskew_all_valid_q,           //--80
                                     trn_sync_hdr_q[7],            //--79
                                     trn_sync_hdr_q[5],            //--78
                                     trn_sync_hdr_q[2],            //--77
                                     trn_sync_hdr_q[0],            //--76
                                     data_sync_hdr_q[7],           //--75
                                     data_sync_hdr_q[5],           //--74
                                     data_sync_hdr_q[2],           //--73
                                     data_sync_hdr_q[0],           //--72
                                     disabled_rx_lanes_q[7:0],     //--71:64
                                     ln7_data[15:0],               //--63:48
                                     ln5_data[15:0],               //--47:32
                                     ln2_data[15:0],               //--31:16
                                     ln0_data[15:0]};              //--15: 0


assign macro_dbg_sel[3:0]         = tx_rx_macro_dbg_sel[3:0];
assign selected_trn_dbg[87:0]     = ({88{macro_dbg_sel[3:0] == 4'h0}} & trn_dbg0[87:0]) |
                                    ({88{macro_dbg_sel[3:0] == 4'h1}} & trn_dbg1[87:0]) |
                                    ({88{macro_dbg_sel[3:0] == 4'h2}} & trn_dbg2[87:0]) |
                                    ({88{macro_dbg_sel[3:0] == 4'h3}} & trn_dbg3[87:0]) |
                                    ({88{macro_dbg_sel[3:0] == 4'h4}} & trn_dbg4[87:0]) |
                                    ({88{macro_dbg_sel[3:0] == 4'h5}} & trn_dbg5[87:0]) |
                                    ({88{macro_dbg_sel[3:0] == 4'h6}} & trn_dbg6[87:0]) |
                                    ({88{macro_dbg_sel[3:0] == 4'h7}} & trn_dbg7[87:0]) |
                                    ({88{macro_dbg_sel[3:0] == 4'h8}} & trn_dbg8[87:0]) |
                                    ({88{macro_dbg_sel[3:0] == 4'h9}} & trn_dbg9[87:0]) |
                                    ({88{macro_dbg_sel[3:0] == 4'hA}} & trn_dbgA[87:0]) |
                                    ({88{macro_dbg_sel[3:0] == 4'hB}} & trn_dbgB[87:0]) |
                                    ({88{macro_dbg_sel[3:0] == 4'hC}} & trn_dbgC[87:0]) |
                                    ({88{macro_dbg_sel[3:0] == 4'hD}} & trn_dbgD[87:0]) |
                                    ({88{macro_dbg_sel[3:0] == 4'hE}} & trn_dbgE[87:0]) |
                                    ({88{macro_dbg_sel[3:0] == 4'hF}} & trn_dbgF[87:0]);
assign rx_tx_trn_dbg[87:0]        = selected_trn_dbg[87:0];








assign spare_00_din = spare_0F_q | tx_cfg_x32 |tx_cfg_x16 | mode_x2 | quarter_width | PM_mode_x2 | (|ts_byte0) | (|deskew_byte2) |
                      (|ts_byte1[1:0]) | rx_cfg_x32 | rx_cfg_x16 | sum_data_sync_hdr[0] | (|sum_trn_sync_hdr[2:0]) |
                      ln0_valid | ln1_valid | ln2_valid | ln3_valid | ln4_valid | ln5_valid | ln6_valid | ln7_valid | (|ln2_data) | 
                      (|ln3_data) | (|ln4_data) | (|ln6_data) | (|ln7_data)  ; //-- : Connect sinkless nets
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



assign reset = global_reset_control ? reset_n_q : ~chip_reset;

dlc_ff       #(.width(  7) ,.rstv({  7{1'b0}})) ff_slow_a_cnt                      (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(slow_a_cnt_din                      )  ,.q(slow_a_cnt_q                      ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_deskew_done                     (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(deskew_done_din                     )  ,.q(deskew_done_q                     ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_reset                           (.clk(dl_clk)  ,.reset_n(1'b1 )  ,.enable(omi_enable)  ,.din(reset_n_din                         )  ,.q(reset_n_q                         ) );
dlc_ff       #(.width(  8) ,.rstv({  8{1'b0}})) ff_rx_trained_lanes                (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(rx_trained_lanes_din                )  ,.q(rx_trained_lanes_q                ) );
dlc_ff       #(.width(  8) ,.rstv({  8{1'b0}})) ff_disabled_rx_lanes               (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(disabled_rx_lanes_din               )  ,.q(disabled_rx_lanes_q               ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_rx_deskew_ln0_b0                (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(rx_deskew_ln0_b0_din                )  ,.q(rx_deskew_ln0_b0_q                ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_rx_deskew_ln0_b1                (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(rx_deskew_ln0_b1_din                )  ,.q(rx_deskew_ln0_b1_q                ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_rx_deskew_ln0_b2                (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(rx_deskew_ln0_b2_din                )  ,.q(rx_deskew_ln0_b2_q                ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_rx_deskew_ln0_b3                (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(rx_deskew_ln0_b3_din                )  ,.q(rx_deskew_ln0_b3_q                ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_rx_deskew_ln1_b0                (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(rx_deskew_ln1_b0_din                )  ,.q(rx_deskew_ln1_b0_q                ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_rx_deskew_ln1_b1                (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(rx_deskew_ln1_b1_din                )  ,.q(rx_deskew_ln1_b1_q                ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_rx_deskew_ln1_b2                (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(rx_deskew_ln1_b2_din                )  ,.q(rx_deskew_ln1_b2_q                ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_rx_deskew_ln1_b3                (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(rx_deskew_ln1_b3_din                )  ,.q(rx_deskew_ln1_b3_q                ) );
dlc_ff       #(.width( 24) ,.rstv({ 24{1'b0}})) ff_rx_deskew_ln0_data              (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(rx_deskew_ln0_data_din              )  ,.q(rx_deskew_ln0_data_q              ) );
dlc_ff       #(.width( 24) ,.rstv({ 24{1'b0}})) ff_rx_deskew_ln1_data              (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(rx_deskew_ln1_data_din              )  ,.q(rx_deskew_ln1_data_q              ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_ln0_dskw_match_c0               (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(ln0_dskw_match_c0_din               )  ,.q(ln0_dskw_match_c0_q               ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_ln1_dskw_match_c0               (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(ln1_dskw_match_c0_din               )  ,.q(ln1_dskw_match_c0_q               ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_rx_lane_reverse                 (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(rx_lane_reverse_din                 )  ,.q(rx_lane_reverse_q                 ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_deskew_all_valid                (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(deskew_all_valid_din                )  ,.q(deskew_all_valid_q                ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_deskew_overflow                 (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(deskew_overflow_din                 )  ,.q(deskew_overflow_q                 ) );
dlc_ff       #(.width(  4) ,.rstv({  4{1'b0}})) ff_deskew_cnt                      (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(deskew_cnt_din                      )  ,.q(deskew_cnt_q                      ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_link_up                         (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(link_up_din                         )  ,.q(link_up_q                         ) );
dlc_ff       #(.width(  7) ,.rstv({  7{1'b0}})) ff_data_sync_cnt                   (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(data_sync_cnt_din                   )  ,.q(data_sync_cnt_q                   ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_rx_trained_ln0_b0               (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(rx_trained_ln0_b0_din               )  ,.q(rx_trained_ln0_b0_q               ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_rx_trained_ln0_b1               (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(rx_trained_ln0_b1_din               )  ,.q(rx_trained_ln0_b1_q               ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_rx_trained_ln0_b2               (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(rx_trained_ln0_b2_din               )  ,.q(rx_trained_ln0_b2_q               ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_rx_trained_ln1_b0               (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(rx_trained_ln1_b0_din               )  ,.q(rx_trained_ln1_b0_q               ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_rx_trained_ln1_b1               (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(rx_trained_ln1_b1_din               )  ,.q(rx_trained_ln1_b1_q               ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_rx_trained_ln1_b2               (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(rx_trained_ln1_b2_din               )  ,.q(rx_trained_ln1_b2_q               ) );
dlc_ff       #(.width(  6) ,.rstv({  6{1'b0}})) ff_rx_trained_lanes_cntr           (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(rx_trained_lanes_cntr_din           )  ,.q(rx_trained_lanes_cntr_q           ) );
dlc_ff       #(.width(  8) ,.rstv({  8{1'b0}})) ff_ln_pattern_a                    (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(ln_pattern_a_din                    )  ,.q(ln_pattern_a_q                    ) );
dlc_ff       #(.width(  8) ,.rstv({  8{1'b0}})) ff_ln_pattern_b                    (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(ln_pattern_b_din                    )  ,.q(ln_pattern_b_q                    ) );
dlc_ff       #(.width(  8) ,.rstv({  8{1'b0}})) ff_ln_sync                         (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(ln_sync_din                         )  ,.q(ln_sync_q                         ) );
dlc_ff       #(.width(  8) ,.rstv({  8{1'b0}})) ff_ln_block_lock                   (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(ln_block_lock_din                   )  ,.q(ln_block_lock_q                   ) );
dlc_ff       #(.width(  8) ,.rstv({  8{1'b0}})) ff_ln_TS1                          (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(ln_TS1_din                          )  ,.q(ln_TS1_q                          ) );
dlc_ff       #(.width(  8) ,.rstv({  8{1'b0}})) ff_ln_TS2                          (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(ln_TS2_din                          )  ,.q(ln_TS2_q                          ) );
dlc_ff       #(.width(  8) ,.rstv({  8{1'b0}})) ff_ln_TS3                          (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(ln_TS3_din                          )  ,.q(ln_TS3_q                          ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_deskew_enable                   (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(deskew_enable_din                   )  ,.q(deskew_enable_q                   ) );
dlc_ff       #(.width( 16) ,.rstv({ 16{1'b0}})) ff_rx_ts_ln0_data                  (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(rx_ts_ln0_data_din                  )  ,.q(rx_ts_ln0_data_q                  ) );
dlc_ff       #(.width( 16) ,.rstv({ 16{1'b0}})) ff_rx_ts_ln1_data                  (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(rx_ts_ln1_data_din                  )  ,.q(rx_ts_ln1_data_q                  ) );
dlc_ff       #(.width(  4) ,.rstv({  4{1'b0}})) ff_ts_cntr                         (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(ts_cntr_din                         )  ,.q(ts_cntr_q                         ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_deskew_found                    (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(deskew_found_din                    )  ,.q(deskew_found_q                    ) );
dlc_ff       #(.width(  5) ,.rstv({  5{1'b0}})) ff_deskew_enable_dly               (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(deskew_enable_dly_din               )  ,.q(deskew_enable_dly_q               ) );
dlc_ff       #(.width( 24) ,.rstv({ 24{1'b0}})) ff_deskew_config                   (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(deskew_config_din                   )  ,.q(deskew_config_q                   ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_ts_valid                        (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(ts_valid_din                        )  ,.q(ts_valid_q                        ) );
dlc_ff       #(.width( 16) ,.rstv({ 16{1'b0}})) ff_ts_good_lanes                   (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(ts_good_lanes_din                   )  ,.q(ts_good_lanes_q                   ) );
dlc_ff       #(.width(  8) ,.rstv({  8{1'b0}})) ff_data_sync_hdr                   (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(data_sync_hdr_din                   )  ,.q(data_sync_hdr_q                   ) );
dlc_ff       #(.width(  8) ,.rstv({  8{1'b0}})) ff_trn_sync_hdr                    (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(trn_sync_hdr_din                    )  ,.q(trn_sync_hdr_q                    ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_sum_trn_sync_hdr                (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(sum_trn_sync_hdr_din                )  ,.q(sum_trn_sync_hdr_q                ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_link_trained                    (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(link_trained_din                    )  ,.q(link_trained_q                    ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_reg_dl_1us_tick                 (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(reg_dl_1us_tick_din                 )  ,.q(reg_dl_1us_tick_q                 ) );
dlc_ff       #(.width(  4) ,.rstv({  4{1'b0}})) ff_phy_trn_cntr                    (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(phy_trn_cntr_din                    )  ,.q(phy_trn_cntr_q                    ) );
dlc_ff       #(.width(  3) ,.rstv({  3{1'b0}})) ff_ts_recheck_cntr                 (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(ts_recheck_cntr_din                 )  ,.q(ts_recheck_cntr_q                 ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_ts_recheck                      (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(ts_recheck_din                      )  ,.q(ts_recheck_q                      ) );
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
dlc_ff       #(.width(  3) ,.rstv({  3{1'b0}})) ff_deskew_overflow_cntr            (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(deskew_overflow_cntr_din            )  ,.q(deskew_overflow_cntr_q            ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_retry_timer_running             (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(retry_timer_running_din             )  ,.q(retry_timer_running_q             ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_deskew_overflow_dly             (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(deskew_overflow_dly_din             )  ,.q(deskew_overflow_dly_q             ) );
dlc_ff       #(.width(  4) ,.rstv({  4{1'b0}})) ff_deskew_overflow_retry_timer     (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(deskew_overflow_retry_timer_din     )  ,.q(deskew_overflow_retry_timer_q     ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_DM_recheck                      (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(DM_recheck_din                      )  ,.q(DM_recheck_q                      ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_DM_recheck_c0_matches_prev      (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(DM_recheck_c0_matches_prev_din      )  ,.q(DM_recheck_c0_matches_prev_q      ) );
dlc_ff       #(.width(  2) ,.rstv({  2{1'b0}})) ff_DM_recheck_cntr                 (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(DM_recheck_cntr_din                 )  ,.q(DM_recheck_cntr_q                 ) );
dlc_ff       #(.width( 16) ,.rstv({ 16{1'b0}})) ff_rx_ts_ln5_data                  (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(rx_ts_ln5_data_din                  )  ,.q(rx_ts_ln5_data_q                  ) );
dlc_ff       #(.width( 24) ,.rstv({ 24{1'b0}})) ff_rx_deskew_ln5_data              (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(rx_deskew_ln5_data_din              )  ,.q(rx_deskew_ln5_data_q              ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_rx_trained_ln5_b0               (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(rx_trained_ln5_b0_din               )  ,.q(rx_trained_ln5_b0_q               ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_rx_trained_ln5_b1               (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(rx_trained_ln5_b1_din               )  ,.q(rx_trained_ln5_b1_q               ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_rx_trained_ln5_b2               (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(rx_trained_ln5_b2_din               )  ,.q(rx_trained_ln5_b2_q               ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_rx_deskew_ln5_b0                (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(rx_deskew_ln5_b0_din                )  ,.q(rx_deskew_ln5_b0_q                ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_rx_deskew_ln5_b1                (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(rx_deskew_ln5_b1_din                )  ,.q(rx_deskew_ln5_b1_q                ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_rx_deskew_ln5_b2                (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(rx_deskew_ln5_b2_din                )  ,.q(rx_deskew_ln5_b2_q                ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_rx_deskew_ln5_b3                (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(rx_deskew_ln5_b3_din                )  ,.q(rx_deskew_ln5_b3_q                ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_ln5_dskw_match_c0               (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(ln5_dskw_match_c0_din               )  ,.q(ln5_dskw_match_c0_q               ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_rx_deskew_ln2_b0                (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(rx_deskew_ln2_b0_din                )  ,.q(rx_deskew_ln2_b0_q                ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_rx_deskew_ln2_b1                (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(rx_deskew_ln2_b1_din                )  ,.q(rx_deskew_ln2_b1_q                ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_rx_deskew_ln2_b2                (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(rx_deskew_ln2_b2_din                )  ,.q(rx_deskew_ln2_b2_q                ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_PM_retrain_dly_timer_ena        (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(PM_retrain_dly_timer_ena_din        )  ,.q(PM_retrain_dly_timer_ena_q        ) );
dlc_ff       #(.width(  3) ,.rstv({  3{1'b0}})) ff_PM_retrain_dly_timer            (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(PM_retrain_dly_timer_din            )  ,.q(PM_retrain_dly_timer_q            ) );
dlc_ff       #(.width(  5) ,.rstv({  5{1'b0}})) ff_ln2_lane_num                    (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(omi_enable)  ,.din(ln2_lane_num_din                    )  ,.q(ln2_lane_num_q                    ) );

endmodule  // dlc_omi_rx_train

