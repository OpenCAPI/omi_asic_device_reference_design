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
module dlc_omi_rx_lane (

//-- inputs from the PHY lanes
  phy_dl_clock                  //--  input
 ,phy_dl_lane                   //--  input  [15:0]
 ,phy_dl_iobist_reset           //--  input
 ,rx_tx_iobist_prbs_error       //--  output
//-- interface to the rx macros
 ,ln_valid                      //--  output
 ,ln_data                       //--  output [15:0]
 ,ln_trn_data                   //--  output [15:0]
 ,ln_parity                     //--  output [1:0]
 ,ln_data_sync_hdr              //--  output
 ,ln_ctl_sync_hdr               //--  output
 ,ln_rx_slow_pat_a              //--  output
 ,ln_pattern_a                  //--  output
 ,ln_pattern_b                  //--  output
 ,ln_sync                       //--  output
 ,ln_block_lock                 //--  output
 ,ln_TS1                        //--  output
 ,ln_TS2                        //--  output
 ,ln_TS3                        //--  output
 ,ln_retrain                    //--  input
 ,ln_deskew_enable              //--  input
 ,ln_deskew_hold                //--  output
 ,ln_deskew_found               //--  output
 ,ln_deskew_valid               //--  output
 ,ln_deskew_overflow            //--  output
 ,ln_all_valid                  //--  input
 ,ln_deskew_reset               //--  input
 ,ln_phy_training               //--  input
 ,ln_phy_init_done              //--  input                        
 ,ln_ts_training                //--  input
 ,ln_disabled                   //--  input
 ,ln_trained                    //--  input
 ,rx_tx_EDPL_max_cnt            //--  output [7:0]
 ,rx_tx_EDPL_error              //--  output
 ,rx_tx_EDPL_thres_reached      //--  output
 ,tx_rx_EDPL_cfg                //--  input [4:0]
 ,tx_rx_cfg_patA_length         //--  input [1:0]
 ,tx_rx_cfg_patB_length         //--  input [1:0]
 ,tx_rx_cfg_patA_hyst           //--  input [3:0]
 ,tx_rx_cfg_patB_hyst           //--  input [3:0]
 ,tx_rx_rx_BEI_inject           //--  input
 ,tx_rx_cfg_sync_mode           //--  input
 ,reg_dl_edpl_max_count_reset   //--  input
//-- signals between the RX and TX
 ,lbist_en_dc                   //--  input
 ,rx_reset_n                    //--  input
 ,chip_reset                    //--  Input
 ,global_reset_control          //--  Input
 ,omi_enable                    //--  input
 ,dl_clk                        //--  input
);


input           phy_dl_clock;
input  [15:0]   phy_dl_lane;
input           phy_dl_iobist_reset;
output          rx_tx_iobist_prbs_error;
output          ln_valid;
output [15:0]   ln_data;
output [15:0]   ln_trn_data;
output [1:0]    ln_parity;
output          ln_ctl_sync_hdr;
output          ln_rx_slow_pat_a;
output          ln_data_sync_hdr;
output          ln_pattern_a;
output          ln_pattern_b;
output          ln_sync;
output          ln_block_lock;
output          ln_TS1;
output          ln_TS2;
output          ln_TS3;
input           ln_retrain;
input           ln_deskew_enable;
output          ln_deskew_hold;
output          ln_deskew_found;
output          ln_deskew_valid;
output          ln_deskew_overflow;
input           ln_all_valid;
input           ln_deskew_reset;
input           ln_phy_training;
input           ln_phy_init_done;
input           ln_ts_training;
input           ln_disabled;
input           ln_trained;
output [7:0]    rx_tx_EDPL_max_cnt;
output          rx_tx_EDPL_error;
output          rx_tx_EDPL_thres_reached;
input  [4:0]    tx_rx_EDPL_cfg;
input  [1:0]    tx_rx_cfg_patA_length;
input  [1:0]    tx_rx_cfg_patB_length;
input  [3:0]    tx_rx_cfg_patA_hyst; 
input  [3:0]    tx_rx_cfg_patB_hyst;
input           tx_rx_rx_BEI_inject;
input           tx_rx_cfg_sync_mode;
input           reg_dl_edpl_max_count_reset;
input           lbist_en_dc;
input           rx_reset_n;
input           omi_enable;
input           chip_reset;
input           global_reset_control;
input           dl_clk;


function [7:0] reverse8 (input [7:0] forward);
  integer i;
  for (i=0; i<=7; i=i+1)
    reverse8[7-i] = forward[i];
endfunction
function [15:0] reverse16 (input [15:0] forward);
  integer i;
  for (i=0; i<=15; i=i+1)
    reverse16[15-i] = forward[i];
endfunction
function [22:0] reverse23 (input [22:0] forward);
  integer i;
  for (i=0; i<=22; i=i+1)
    reverse23[22-i] = forward[i];
endfunction


//-- signal declaration
wire         reset;
wire         reset_phy;
wire [7:0]   data_toggle;
wire         toggle0_t0_din;
wire         toggle1_t1_din;
wire         toggle2_t2_din;
wire         toggle3_t3_din;
wire         toggle4_t4_din;
wire         toggle5_t5_din;
wire         toggle6_t6_din;
wire         toggle7_t7_din;
wire         toggle0_t0_q; 
wire         toggle1_t1_q; 
wire         toggle2_t2_q; 
wire         toggle3_t3_q; 
wire         toggle4_t4_q; 
wire         toggle5_t5_q; 
wire         toggle6_t6_q; 
wire         toggle7_t7_q;
wire         enable_phy; 
wire         rx_reset_n_phy;    
wire         Block_Lock_q;
wire         Block_Lock_din;
wire [3:0]   DM_Count_q;
wire [3:0]   DM_Count_din;
wire [7:0]   DM_Data_q;
wire [7:0]   DM_Data_din;
wire         Deskew_Valid_q;
wire         Deskew_Valid_din;
wire         F_pattern_cnt_q;
wire         F_pattern_cnt_din;
wire [5:0]   sh_count_grid_q;
wire [5:0]   sh_count_grid_din;
wire [3:0]   SH_invalid_count_q;
wire [3:0]   SH_invalid_count_din;
wire [17:5]  Test_Obs_q;
wire [17:5]  Test_Obs_din;
wire [3:0]   Training_Count_q;
wire [3:0]   Training_Count_din;
wire [7:0]   Training_Data_q;
wire [7:0]   Training_Data_din;
wire [1:0]   Training_Type_q;
wire [1:0]   Training_Type_din;
wire         buffer_block_valid_q;
wire         buffer_block_valid_din;
wire [3:0]   cfg_phy_a_hyst_q;
wire [3:0]   cfg_phy_a_hyst_din;
wire [3:0]   cfg_phy_b_hyst_q;
wire [3:0]   cfg_phy_b_hyst_din;
wire         cfg_phy_train_a_less_x_q;
wire         cfg_phy_train_a_less_x_din;
wire         cfg_phy_train_a_more_x_q;
wire         cfg_phy_train_a_more_x_din;
wire         cfg_phy_train_b_less_x_q;
wire         cfg_phy_train_b_less_x_din;
wire         cfg_phy_train_b_more_x_q;
wire         cfg_phy_train_b_more_x_din;
wire [15:0]  deskew_data00_q;
wire [15:0]  deskew_data00_din;
wire [15:0]  deskew_data01_q;
wire [15:0]  deskew_data01_din;
wire [15:0]  deskew_data02_q;
wire [15:0]  deskew_data02_din;
wire [15:0]  deskew_data03_q;
wire [15:0]  deskew_data03_din;
wire [1:0]   deskew_sync0_q;
wire [1:0]   deskew_sync0_din;
wire         do_inversion_q;
wire         do_inversion_din;
wire         do_shift_left_q;
wire         do_shift_left_din;
wire         do_shift_right_q;
wire         do_shift_right_din;
wire [3:0]   read_ptr_din;
wire [3:0]   read_ptr_q;
wire         inv_rec1_q;
wire         inv_rec1_din;
wire         inv_rec2_q;
wire         inv_rec2_din;
wire         lane_disabled_q;
wire         lane_disabled_din;
wire         lfsr_bad_TS_q;
wire         lfsr_bad_TS_din;
wire [22:0]  lfsr_q;
wire [22:0]  lfsr_din;
wire         lfsr_locked_q;
wire         lfsr_locked_din;
wire         lfsr_running_q;
wire         lfsr_running_din;
wire [3:0]   need_shift_left_cnt_q;
wire [3:0]   need_shift_left_cnt_din;
wire [3:0]   need_shift_right_cnt_q;
wire [3:0]   need_shift_right_cnt_din;
wire         only_good_bits_q;
wire         only_good_bits_din;
wire [15:0]  pattern_a_count_q;
wire [15:0]  pattern_a_count_din;
wire         pattern_a_detected_q;
wire         pattern_a_detected_din;
wire [11:0]  pattern_b_count_q;
wire [11:0]  pattern_b_count_din;
wire [15:0]  pattern_b_cycle1_q;
wire [15:0]  pattern_b_cycle1_din;
wire [15:0]  pattern_b_cycle2_q;
wire [15:0]  pattern_b_cycle2_din;
wire         pattern_b_detected_q;
wire         pattern_b_detected_din;
wire         pattern_b_timer_q;
wire         pattern_b_timer_din;
wire         phy_training_q;
wire         phy_training_din;
wire [1:0]   prev_sh_q;
wire [1:0]   prev_sh_din;
wire [15:0]  prev_raw_data_q;
wire [15:0]  prev_raw_data_din;
wire [15:0]  prev_raw_data_dly_din;
wire [15:0]  prev_raw_data_dly_q;
wire         reset_deskew_q;
wire         reset_deskew_din;
wire         rx_inverted_q;
wire         rx_inverted_din;
wire         sync_received_q;
wire         sync_received_din;
wire         pattern_b_timer;
wire [7:0]   sync_data_toggle;
wire         buffer_reset;
wire         selected_data_toggle;
wire         prev_selected_data_toggle;
wire         buffer_has_16;
wire [17:0]  selected_data_raw;
wire [31:0]  slow_raw_data;
wire [12:0]  pattern_F_det_a;
wire [12:0]  pattern_F_det_b;
wire         detect_pattern_F;
wire [29:0]  selected_data_wrap;
wire [6:0]   pattern_a_mask;
wire [15:0]  pattern_A_det_a;
wire [15:0]  pattern_A_det_b;
wire [17:5]  Test_Obs;
wire [15:0]  pattern_A_detect;
wire [15:0]  pattern_b_mask;
wire [15:0]  pattern_B_det1_a;
wire [15:0]  pattern_B_det1_b;
wire [15:0]  pattern_B_detect1;
wire [15:0]  pattern_B_det2_a;
wire [15:0]  pattern_B_det2_b;
wire [15:0]  pattern_B_detect2;
wire [15:0]  pattern_B_det3_a;
wire [15:0]  pattern_B_det3_b;
wire [15:0]  pattern_B_detect3;
wire         normal_phy_cycle;
wire         need_to_shift_left;
wire         need_to_shift_right;
wire         only_good_bits;
wire         only_bad_bits;
wire [15:0]  pattern_a_limit;
wire         pat_a_count_high_limit;
wire         pat_a_count_low_limit;
wire         inc_pattern_a_count;
wire         dec_pattern_a_count;
wire         sync_received;
wire         inversion_rec;
wire [15:0]  pattern_b_net_detect;
wire [11:0]  pattern_b_limit;
wire         pat_b_count_high_limit;
wire         pat_b_count_low_limit;
wire         inc_pattern_b_count;
wire         dec_pattern_b_count;
wire         pattern_b_good;
wire [15:0]  descramble;
wire [15:0]  lfsr_next_16;
wire         lfsr_advance;
wire         lfsr_init_check;
wire         load_pattern1;
wire         load_pattern2;
wire         lfsr_lock;
wire         lfsr_unlock;
wire [47:0]  raw_sequence1x;
wire [47:0]  raw_sequence2x;
wire [47:0]  raw_sequence1;
wire [47:0]  raw_sequence2;
wire [22:0]  initial_lfsr1;
wire [22:0]  final_lfsr1;
wire [47:23] prbs_pattern1;
wire [4:0]   match_pat1;
wire         match_pattern1;
wire [22:0]  initial_lfsr2;
wire [22:0]  final_lfsr2;
wire [47:23] prbs_pattern2;
wire [4:0]   match_pat2;
wire         match_pattern2;
wire [1:0]   input_sync_hdr;
wire [15:0]  selected_data;
wire [15:0]  input_data;
wire         write_deskew_data;
wire         mid_block;
wire         SH_valid;
wire         SH_invalid;
wire         unlocked_inc_SH_count;
wire         unlocked_Set_Block_Lock;
wire         locked_inc_SH_count;
wire         locked_reset_counts;
wire         locked_inc_SH_invalid_count;
wire         locked_Clear_Block_Lock;
wire         input_taken;
wire         Set_Block_Lock;
wire         Clear_Block_Lock;
wire         inc_SH_invalid_count;
wire         inc_SH_count;
wire         Clear_SH_counts;
wire [63:0]  Block_Data0;
wire [6:0]   Dec0_TS1;
wire         Decode0_TS1;
wire [5:0]   Dec0_TS2;
wire         Decode0_TS2;
wire [5:0]   Dec0_TS3;
wire         Decode0_TS3;
wire [4:0]   Dec0_DM;
wire         Decode0_DM;
wire         TS1_Valid;
wire         TS2_Valid;
wire         TS3_Valid;
wire         DM_Valid;
wire         Any_TS;
wire         Any_TS_or_DM;
wire [7:0]   TS_Data;
wire [1:0]   current_training_type;
wire         current_matches_last;
wire         increment_training_count;
wire         load_1_training_count;
wire [3:0]   Training_Count_Inc;
wire         increment_DM_count;
wire         load_1_DM_count;
wire [3:0]   DM_Count_Inc;
wire         all_lanes_valid;
wire         OC_endpoint;

assign OC_endpoint = 1'b0;

assign ln_data_sync_hdr   = (input_taken & (input_sync_hdr[1:0] == 2'b01));
assign ln_ctl_sync_hdr    = (input_taken & (input_sync_hdr[1:0] == 2'b10));
assign ln_pattern_a       = pattern_a_detected_q & ~pattern_b_detected_q;
assign ln_pattern_b       = pattern_b_detected_q;
assign ln_sync            = sync_received_q;
assign ln_block_lock      = Block_Lock_q;
assign ln_TS1             = (Training_Type_q[1:0] == 2'b01) & Training_Count_q[3] & Block_Lock_q & lfsr_locked_q;
assign ln_TS2             = (Training_Type_q[1:0] == 2'b10) & Training_Count_q[3] & Block_Lock_q & lfsr_locked_q;
assign ln_TS3             = (Training_Type_q[1:0] == 2'b11) & Training_Count_q[3] & Block_Lock_q & lfsr_locked_q;


(* timing_type="async_gated" *) wire [ 1:0]  block0_hdr_q;
(* timing_type="async_gated" *) wire [15:0]  block0_0_q;
(* timing_type="async_gated" *) wire [15:0]  block0_1_q;
(* timing_type="async_gated" *) wire [15:0]  block0_2_q;
(* timing_type="async_gated" *) wire [15:0]  block0_3_q;
(* timing_type="async_gated" *) wire [ 1:0]  block1_hdr_q;
(* timing_type="async_gated" *) wire [15:0]  block1_0_q;
(* timing_type="async_gated" *) wire [15:0]  block1_1_q;
(* timing_type="async_gated" *) wire [15:0]  block1_2_q;
(* timing_type="async_gated" *) wire [15:0]  block1_3_q;
wire [ 1:0]  block0_hdr_din;
wire [15:0]  block0_0_din;
wire [15:0]  block0_1_din;
wire [15:0]  block0_2_din;
wire [15:0]  block0_3_din;
wire [ 1:0]  block1_hdr_din;
wire [15:0]  block1_0_din;
wire [15:0]  block1_1_din;
wire [15:0]  block1_2_din;
wire [15:0]  block1_3_din;
wire [3:0]   hdr_blocks;
wire [63:0]  block0;
wire [63:0]  block1;
wire         phy_training_sync;
wire         phy_training_async;
wire  [6:0]  slip_cntr_din;
wire  [6:0]  slip_cntr_q;
wire         slip_cntr_overflow;
wire         slip_left_sync;
wire         slip_left_async;
wire         slip_left_edge;
wire         slip_left_toggle_din;
wire         slip_left_toggle_q;
wire         slip_left_dly_din;
wire         slip_left_dly_q;
wire [16:0]  phy_dl_lane_d0_din;
wire [16:0]  phy_dl_lane_d0_q;
wire [32:0]  phy_dl_queue;
wire [17:0]  data_to_write;
wire [1:0]   block_pos_din;
wire [1:0]   block_pos_q;
wire         block_num_din;
wire         block_num_q;
wire [7:0]   block_num_pos;
wire [4:0]   write_ptr_din;
wire [4:0]   write_ptr_q;
wire         write_ptr_overflow_din;
wire         write_ptr_overflow_q;
wire         act_block0_0;
wire         act_block0_1;
wire         act_block0_2;
wire         act_block0_3;
wire         act_block1_0;
wire         act_block1_1;
wire         act_block1_2;
wire         act_block1_3;
wire         start_of_block;
wire         write_ptr_no_adv;
wire         write_ptr_back1;
wire         write_ptr_adv1;
wire         write_ptr_adv2;
wire         write_ptr_adv8;
wire [6:0]   sh_count_din;
wire [6:0]   sh_count_q;
wire         sh_good;
wire         sh_bad;
wire         sh_maxed;
wire         rx_inverted_async;
wire         rx_inverted_sync;
wire         rx_inverted_dly_din;
wire         rx_inverted_dly_q;
wire         rx_inverted_edge;
wire         slip_right_toggle_din;
wire         slip_right_toggle_q;
wire         slip_right_async;
wire         slip_right_sync;
wire         slip_right_dly_din;
wire         slip_right_dly_q;
wire         slip_right_edge;
wire         valid_data;
wire         last_value_din;
wire         last_value_q;
wire         deskew_found_dly_din;
wire         deskew_found_dly_q;
wire         buffer_started_din;
wire         buffer_started_q;
wire         last_value_dly_din;
wire         last_value_dly_q;
wire         data_overflow;
wire [2:0]   EDPL_cfg_err_thres;
wire         act_EDPL;
wire         EDPL_cntr_reset;
wire [8:0]   EDPL_err_thres;
wire         EDPL_cntr_maxed;
wire         EDPL_cntr_inc;
wire [7:0]   EDPL_cntr_din;
wire [7:0]   EDPL_cntr_q;
wire [7:0]   EDPL_max_cnt_din;
wire [7:0]   EDPL_max_cnt_q;
wire         EDPL_thres_reached_din;
wire         EDPL_thres_reached_q;
wire         EDPL_parity_error;
wire         BEI_inject_async;
wire         BEI_inject_sync;
wire         BEI_inject_toggle_din;
wire         BEI_inject_toggle_q;
wire         BEI_inject_edge;
wire         BEI_inject_dly_din;
wire         BEI_inject_dly_q;
wire         BEI_inject_edge_dly_din;
wire         BEI_inject_edge_dly_q;
wire         inj_err;
wire [1:0]   data_parity;
wire         spare_cfg_phy_din;
wire         spare_cfg_phy_q;
wire         spare_cfg_din;
wire         spare_cfg_q;
wire         EDPL_error_din;
wire         EDPL_error_q;
wire         cfg_sync_mode_din;
(* geyzer_phase="0" *)(* geyzer_waive="constant_checker" *) wire         cfg_sync_mode_q;
wire [7:0]   cfg_data_toggle;
wire         parity_in;
wire         start_cal_par;
wire         input_taken_dly_din;
wire         input_taken_dly_q;
wire         check_EDPL_din;
wire         check_EDPL_q;
wire         calc_par_din;
wire         calc_par_q;
wire         ln_train_done;
wire         iobist_reset;
wire         iobist_prbs_error;
wire         ln_trained_dly_din;
wire         ln_trained_dly_q;
wire         EDPL_thres_reached_dly_din;
wire         EDPL_thres_reached_dly_q;
wire         dl_reset_n_din;
wire         dl_reset_n_q;
wire         EDPL_ena;
wire         Clear_BL_async;
wire         Clear_BL_sync;
wire         Clear_BL_toggle_din;
wire         Clear_BL_toggle_q;
wire         clear_sh_count;
wire         not_BL_dly_din;
wire         not_BL_dly_q;
wire         not_BL_edge;
wire         spare_00_din;
wire         spare_01_din;
wire         spare_02_din;
wire         spare_03_din;
wire         spare_04_din;
wire         spare_05_din;
wire         spare_06_din;
wire         spare_07_din;
wire         spare_00_q;
wire         spare_01_q;
wire         spare_02_q;
wire         spare_03_q;
wire         spare_04_q;
wire         spare_05_q;
wire         spare_06_q;
wire         spare_07_q;
wire         spare_00_phy_din;
wire         spare_01_phy_din;
wire         spare_00_phy_q;
wire         spare_01_phy_q;
wire         ts_training;
wire         read_ptr_wraps;
wire         start_of_deskew_block;
wire         cfg_phy_train_a_more_x;
wire         cfg_phy_train_a_less_x;
wire         cfg_phy_train_b_more_x;
wire         cfg_phy_train_b_less_x;
wire [3:0]   cfg_phy_a_hyst;
wire [3:0]   cfg_phy_b_hyst;
wire         clear_lfsr_toggle_din;
wire         clear_lfsr_toggle_q;
wire         clear_lfsr_async;
wire         clear_lfsr_sync;
wire         clear_lfsr_dly_din;
wire         clear_lfsr_dly_q;
wire         do_clear_lfsr;
wire         TS1_Valid_din;
wire         TS2_Valid_din;
wire         TS3_Valid_din;
wire         DM_Valid_din;
wire [6:0]   pattern_F_det_test_din;
wire [10:0]  unused;
wire         act_lane_d0;
wire         prbs_enable;

assign       prbs_enable = enable_phy & ~lbist_en_dc;
//-- IOBIST prbs7 checker
dlc_omi_prbs7_chk prbs7_chk(
   .phy_dl_clock         (phy_dl_clock        ) //-- input  
  ,.omi_enable           (prbs_enable         ) //-- input  
  ,.omi_reset_n          (rx_reset_n_phy      ) //-- input  
  ,.rx_bist_reset        (iobist_reset        ) //-- input  
  ,.data_in              (phy_dl_lane[15:0]   ) //-- input  [15:0]
  ,.prbs_error_out       (iobist_prbs_error   ) //-- output 
  ,.chip_reset           (chip_reset          ) //-- input
  ,.global_reset_control (global_reset_control) //-- input
);

assign hdr_blocks[3:0] = {block0_hdr_q[1:0],  //-- [3:2]
                          block1_hdr_q[1:0]}; //-- [1:0]

                                             
assign block0[63:0]    = {block0_0_q[15:0],  //-- [ 63: 48]
                          block0_1_q[15:0],  //-- [ 47: 32]
                          block0_2_q[15:0],  //-- [ 31: 16]
                          block0_3_q[15:0]}; //-- [ 15:  0]
assign block1[63:0]    = {block1_0_q[15:0],  //-- [ 63: 48]
                          block1_1_q[15:0],  //-- [ 47: 32]
                          block1_2_q[15:0],  //-- [ 31: 16]
                          block1_3_q[15:0]}; //-- [ 15:  0]

assign spare_cfg_phy_din = spare_cfg_phy_q | slip_cntr_overflow;

assign slip_cntr_din[6:0]      = ( (slip_cntr_q[6:0] + 7'b1) & {7{ write_ptr_adv1}} | 
                                   (slip_cntr_q[6:0]       ) & {7{~write_ptr_adv1}} ) & {7{~phy_training_sync}};

assign slip_cntr_overflow      = (slip_cntr_q[6:0] == 7'd66) & write_ptr_adv1; //-- slipped around a 64/66 bit boundary

assign BEI_inject_dly_din      = BEI_inject_sync;
assign BEI_inject_edge         = BEI_inject_sync ^ BEI_inject_dly_q;
assign BEI_inject_edge_dly_din = BEI_inject_edge & write_ptr_overflow_q;

//-- if write pointer overflows, inject error on next cycle
assign inj_err             = BEI_inject_edge_dly_q | (~BEI_inject_edge_dly_q & BEI_inject_edge & ~write_ptr_overflow_q);

assign rx_inverted_dly_din = rx_inverted_sync;
assign rx_inverted_edge    = rx_inverted_sync ^ rx_inverted_dly_q;

assign slip_left_dly_din   = slip_left_sync;
assign slip_left_edge      = slip_left_sync ^ slip_left_dly_q;

assign slip_right_dly_din  = slip_right_sync;
assign slip_right_edge     = slip_right_sync ^ slip_right_dly_q;

assign not_BL_dly_din      = Clear_BL_sync;
assign not_BL_edge         = Clear_BL_sync ^ not_BL_dly_q;


//-- only count sync headers after receiving sync pattern
assign start_of_block    = (block_pos_q[1:0] == 2'b00) & ~write_ptr_overflow_q & ~phy_training_sync;
assign sh_good           = start_of_block & (data_to_write[17:16] == 2'b10) & ~sh_maxed;
assign sh_bad            = start_of_block & (data_to_write[17:16] != 2'b10) & ~sh_maxed;
assign clear_sh_count    = sh_bad | not_BL_edge;

//-- Unlock LFSR if an invalid sync header is detected and a slip happens before block lock is finished.
assign clear_lfsr_toggle_din = clear_sh_count ^ clear_lfsr_toggle_q;
assign clear_lfsr_async      = clear_lfsr_toggle_q;

assign sh_maxed          = sh_count_q[6]; //-- count = 7'd64
assign sh_count_din[6:0] = ( (sh_count_q[6:0] + 7'b1) & {7{ sh_good}} |
                             (sh_count_q[6:0]       ) & {7{~sh_good}} ) & ~{7{clear_sh_count}};


//-- priority:
//-- 1. adv8 
//-- 2. back1
//-- 3. adv1
//-- 4. adv2
assign write_ptr_adv8    =   phy_training_sync &  rx_inverted_edge;
assign write_ptr_back1   =   phy_training_sync & ~rx_inverted_edge &  slip_right_edge;
assign write_ptr_adv1    = ( phy_training_sync & ~rx_inverted_edge & ~slip_right_edge & slip_left_edge) | 
                           (~phy_training_sync & sh_bad);

//-- only adv2 when receiving 64/66 encoded date
assign write_ptr_adv2    =  ~phy_training_sync & (block_pos_q[1:0] == 2'b11) & ~write_ptr_overflow_q;

assign write_ptr_no_adv  = ~(write_ptr_adv1 | write_ptr_adv2 | write_ptr_adv8 | write_ptr_back1); 

assign write_ptr_din[4:0]   = (write_ptr_q[4:0] + 5'd1) & {5{write_ptr_adv1  }} |
                              (write_ptr_q[4:0] - 5'd1) & {5{write_ptr_back1 }} |
                              (write_ptr_q[4:0] + 5'd2) & {5{write_ptr_adv2  }} |
                              (write_ptr_q[4:0] + 5'd8) & {5{write_ptr_adv8  }} |
                              (write_ptr_q[4:0]       ) & {5{write_ptr_no_adv}};

assign write_ptr_overflow_din = (write_ptr_q[4] ^ write_ptr_din[4]) & ~write_ptr_back1; //-- write ptr going to overflow 


//-- 16/18 bits to write to next block location based off write pointer.  Only write 18 bits when at starting position of block
//-- queue gets updated right to left
//-- eg:                   time       n |      n+1        |      n+2
//-- phy_dl_lane[15:0]:            0001 |      0002       |      0003
//-- phy_dl_queue[32:0]:  '0',0000,0001 | '0', 0001, 0002 | '1', 0002, 0003

//-- When queue goes from 1 --> 2 (write pointer overflow), need to wait one cycle in order to get new valid data to read
//--
//--  write pointer end                                                       2.                                  1.
//-- phy_dl_queue[32:0] = |32|31|30|29|28|27|26|25|24|23|22|21|20|19|18|17|16|15|14|13|12|11|10|9|8|7|6|5|4|3|2|1|0|
//--  write pointer start  2.                                           1.

//-- write pointer needs to increment by 2 every four cycles to move to location of new sync header
//-- when the pointer wraps, we need to stall for 1 cycle to let data catch up
//-- during normal 64/66 operation, write pointer can only follow two different 8 combinations
//-- write pointer = 0, 2, 4, 6, 8, 10, 12, 14, 0, 2
//-- write pointer = 1, 3, 5, 6, 7, 11, 13, 15, 1, 3

assign act_lane_d0               = enable_phy & ~lbist_en_dc;

//--  
//--reg [15:0]  phy_dl_lane_temp;
//--always @ (posedge phy_dl_clock) begin
//--   phy_dl_lane_temp[15:0] <= phy_dl_lane[15:0];
//--end
//--
//--assign phy_dl_lane_d0_din[16  ]  =  phy_dl_lane_d0_q[0];
//--assign phy_dl_lane_d0_din[15:0]  =  phy_dl_lane_temp[15:0];
//--
//--assign phy_dl_queue[32:0]        = {phy_dl_lane_d0_q[16:0],  //-- [32:16]
//--                                    phy_dl_lane_temp[15:0]}; //-- [15: 0]
//-- Use this
assign phy_dl_lane_d0_din[16  ]  =  phy_dl_lane_d0_q[0];
assign phy_dl_lane_d0_din[15:0]  =  phy_dl_lane[15:0];

assign phy_dl_queue[32:0]        = {phy_dl_lane_d0_q[16:0], //-- [32:16]
                                    phy_dl_lane[15:0]};     //-- [15: 0]

//-- need to delay inversion 1 cycle to allow write pointer to update to correct spot first
assign data_to_write[17:0]       = {18{rx_inverted_dly_q}} ^ {{10{1'b0}}, inj_err, {7{1'b0}}}  ^ (
                                   {18{write_ptr_q[3:0] == 4'd0 }} & (phy_dl_queue[32:15]) | 
                                   {18{write_ptr_q[3:0] == 4'd1 }} & (phy_dl_queue[31:14]) | 
                                   {18{write_ptr_q[3:0] == 4'd2 }} & (phy_dl_queue[30:13]) | 
                                   {18{write_ptr_q[3:0] == 4'd3 }} & (phy_dl_queue[29:12]) | 
                                   {18{write_ptr_q[3:0] == 4'd4 }} & (phy_dl_queue[28:11]) | 
                                   {18{write_ptr_q[3:0] == 4'd5 }} & (phy_dl_queue[27:10]) | 
                                   {18{write_ptr_q[3:0] == 4'd6 }} & (phy_dl_queue[26: 9]) | 
                                   {18{write_ptr_q[3:0] == 4'd7 }} & (phy_dl_queue[25: 8]) | 
                                   {18{write_ptr_q[3:0] == 4'd8 }} & (phy_dl_queue[24: 7]) | 
                                   {18{write_ptr_q[3:0] == 4'd9 }} & (phy_dl_queue[23: 6]) | 
                                   {18{write_ptr_q[3:0] == 4'd10}} & (phy_dl_queue[22: 5]) | 
                                   {18{write_ptr_q[3:0] == 4'd11}} & (phy_dl_queue[21: 4]) | 
                                   {18{write_ptr_q[3:0] == 4'd12}} & (phy_dl_queue[20: 3]) | 
                                   {18{write_ptr_q[3:0] == 4'd13}} & (phy_dl_queue[19: 2]) | 
                                   {18{write_ptr_q[3:0] == 4'd14}} & (phy_dl_queue[18: 1]) | 
                                   {18{write_ptr_q[3:0] == 4'd15}} & (phy_dl_queue[17: 0])   );

//-- block position gets updated every clock cycle, unless there is a data overflow
//-- block number gets updated after the last position in the current block gets filled

//-- block[block_num]_[block_pos]
//-- ----------     data          | time
//-- |block0_0| <-- 4B4A          | n   | n+8
//-- ----------
//-- |block0_1| <-- 4A4A          | n+1 | n+9
//-- ----------
//-- |block0_2| <-- 4A4A          | n+2 | n+10
//-- ----------
//-- |block0_3| <-- 4A4A          | n+3 | n+11
//-- ----------
//-- |block1_0|
//-- ----------
//-- |block1_1|
//-- ----------
//-- |block1_2|
//-- ----------
//-- |block1_3| <-- 4A4A          | n+7 | n+15
//-- ----------
assign block_pos_din[1:0]  = (block_pos_q[1:0] + 2'b01) & {2{~write_ptr_overflow_q}} |
                             (block_pos_q[1:0]        ) & {2{ write_ptr_overflow_q}};
assign block_num_din       = (block_num_q      + 1'b1 ) & ((block_pos_q[1:0] == 2'b11) & ~write_ptr_overflow_q) |
                             (block_num_q             ) & ((block_pos_q[1:0] != 2'b11) |  write_ptr_overflow_q) ;

//-- the next position to write the next bits of data
assign block_num_pos[7:0]  = {3'b000, block_num_q, 
                              2'b00,  block_pos_q[1:0]};

//-- only write to a certain block position when there is enough data to fill it.
assign act_block0_0        = enable_phy & ~lbist_en_dc & (((block_num_pos[7:0] == 8'h00) & ~write_ptr_overflow_q) | ~reset_phy);
assign act_block0_1        = enable_phy & ~lbist_en_dc & (((block_num_pos[7:0] == 8'h01) & ~write_ptr_overflow_q) | ~reset_phy);
assign act_block0_2        = enable_phy & ~lbist_en_dc & (((block_num_pos[7:0] == 8'h02) & ~write_ptr_overflow_q) | ~reset_phy);
assign act_block0_3        = enable_phy & ~lbist_en_dc & (((block_num_pos[7:0] == 8'h03) & ~write_ptr_overflow_q) | ~reset_phy);
assign act_block1_0        = enable_phy & ~lbist_en_dc & (((block_num_pos[7:0] == 8'h10) & ~write_ptr_overflow_q) | ~reset_phy);
assign act_block1_1        = enable_phy & ~lbist_en_dc & (((block_num_pos[7:0] == 8'h11) & ~write_ptr_overflow_q) | ~reset_phy);
assign act_block1_2        = enable_phy & ~lbist_en_dc & (((block_num_pos[7:0] == 8'h12) & ~write_ptr_overflow_q) | ~reset_phy);
assign act_block1_3        = enable_phy & ~lbist_en_dc & (((block_num_pos[7:0] == 8'h13) & ~write_ptr_overflow_q) | ~reset_phy);

//-- gated by clock enable, only write headers when act_block*_0 is asserted
assign toggle0_t0_din      = ~toggle0_t0_q;
assign toggle1_t1_din      = ~toggle1_t1_q;
assign toggle2_t2_din      = ~toggle2_t2_q;
assign toggle3_t3_din      = ~toggle3_t3_q;
assign toggle4_t4_din      = ~toggle4_t4_q;
assign toggle5_t5_din      = ~toggle5_t5_q;
assign toggle6_t6_din      = ~toggle6_t6_q;
assign toggle7_t7_din      = ~toggle7_t7_q;

//-- when signal transitions either way, indicates that the data is good to read
assign data_toggle[7:0]    = {toggle0_t0_q, toggle1_t1_q, toggle2_t2_q, toggle3_t3_q, toggle4_t4_q, toggle5_t5_q, toggle6_t6_q, toggle7_t7_q};

//-- gated by clock enable, only write headers when act_block*_0 is asserted
assign block0_hdr_din[1:0] = data_to_write[17:16];
assign block0_0_din[15:0]  = data_to_write[15: 0];
assign block0_1_din[15:0]  = data_to_write[15: 0];
assign block0_2_din[15:0]  = data_to_write[15: 0];
assign block0_3_din[15:0]  = data_to_write[15: 0];

assign block1_hdr_din[1:0] = data_to_write[17:16];
assign block1_0_din[15:0]  = data_to_write[15: 0];
assign block1_1_din[15:0]  = data_to_write[15: 0];
assign block1_2_din[15:0]  = data_to_write[15: 0];
assign block1_3_din[15:0]  = data_to_write[15: 0];

//----
//-- Single Bit Error Injection
//----
assign BEI_inject_toggle_din     = tx_rx_rx_BEI_inject ^ BEI_inject_toggle_q;
assign BEI_inject_async          = BEI_inject_toggle_q;

//----
//-- Error Detection per Lane
//----
assign EDPL_cntr_reset           = tx_rx_EDPL_cfg[4] | reg_dl_edpl_max_count_reset | (~ln_trained); //-- reset generated in tx_train (time window reset)
assign EDPL_cfg_err_thres[2:0]   = tx_rx_EDPL_cfg[3:1];
assign EDPL_ena                  = tx_rx_EDPL_cfg[0];

//-- clock gate for latches
assign act_EDPL                  = (omi_enable & (EDPL_ena | ~reset)); //-- reset is active low

//-- Only grab 6 most significant bits when counting to 64 or 128 errors.
//-- At these thresholds, the actual count is 4*reported_count and can be off by up to +3. Otherwise, exact count is displayed.
//-- EG: reported count = 6'b01_0010 = 18 --> Actual count is 72-75
//-- 4/10assign rx_tx_EDPL_max_cnt[5:0]    = (EDPL_cfg_err_thres[2:1] == 2'b11) ? EDPL_max_cnt_q[7:2] : EDPL_max_cnt_q[5:0];
assign rx_tx_EDPL_max_cnt[7:0]    = EDPL_max_cnt_q[7:0];
assign rx_tx_EDPL_error           = EDPL_error_q;
assign rx_tx_EDPL_thres_reached   = EDPL_thres_reached_q & ~EDPL_thres_reached_dly_q; //-- pulse for rising edge of thres_reached

assign EDPL_err_thres[8:0]        = ({1'b0, 8'hFF} & {9{(EDPL_cfg_err_thres[2:0] == 3'b000)}}) |  //--   disabled
                                    ({1'b1, 8'h02} & {9{(EDPL_cfg_err_thres[2:0] == 3'b001)}}) |  //--   2 errors
                                    ({1'b1, 8'h04} & {9{(EDPL_cfg_err_thres[2:0] == 3'b010)}}) |  //--   4 errors
                                    ({1'b1, 8'h08} & {9{(EDPL_cfg_err_thres[2:0] == 3'b011)}}) |  //--   8 errors
                                    ({1'b1, 8'h10} & {9{(EDPL_cfg_err_thres[2:0] == 3'b100)}}) |  //--  16 errors
                                    ({1'b1, 8'h20} & {9{(EDPL_cfg_err_thres[2:0] == 3'b101)}}) |  //--  32 errors
                                    ({1'b1, 8'h40} & {9{(EDPL_cfg_err_thres[2:0] == 3'b110)}}) |  //--  64 errors
                                    ({1'b1, 8'h80} & {9{(EDPL_cfg_err_thres[2:0] == 3'b111)}});   //-- 128 errors



assign EDPL_cntr_maxed            = EDPL_cntr_q[7:0] == EDPL_err_thres[7:0];
assign EDPL_cntr_inc              = ~EDPL_cntr_maxed & EDPL_parity_error;
assign EDPL_cntr_din[7:0]         = EDPL_cntr_reset ? 8'h00 :
                                    EDPL_cntr_inc   ? EDPL_cntr_q[7:0] + 8'h01 :
                                                      EDPL_cntr_q[7:0];

assign EDPL_max_cnt_din[7:0]      = ( (EDPL_max_cnt_q[7:0] & {8{EDPL_max_cnt_q[7:0] >=  EDPL_cntr_q[7:0]}}) | 
                                      (EDPL_cntr_q[7:0]    & {8{EDPL_max_cnt_q[7:0] <   EDPL_cntr_q[7:0]}}) ) & {8{~reg_dl_edpl_max_count_reset}};

assign EDPL_thres_reached_din     = EDPL_err_thres[8] & (EDPL_cntr_q[7:0] >= EDPL_err_thres[7:0]);
assign EDPL_thres_reached_dly_din = EDPL_thres_reached_q;

assign check_EDPL_din      = write_deskew_data;              //-- This latch ALWAYS needs to be enabled.  Also used to check block lock.
assign parity_in           = (^deskew_data03_q[15:0]);
assign start_cal_par       = ln_train_done | check_EDPL_q;
assign ln_train_done       = ln_trained & ~ln_trained_dly_q; //-- pulse when link is initially trained
assign ln_trained_dly_din  = ln_trained;
assign input_taken_dly_din = input_taken;

//-- '0' = even number of 1's present. '1' = odd number of 1's present
assign calc_par_din        = ~input_taken_dly_q  ? calc_par_q :
                              start_cal_par      ? parity_in  :
                                                   parity_in ^ calc_par_q;

//-- Only count errors when header is '00', '01', or '11'
assign EDPL_parity_error   = EDPL_ena         & ln_trained  & ln_trained_dly_q  &                //-- don't check parity right when lane is trained or when link retrains
                             ~lane_disabled_q & (deskew_sync0_q[1:0] != 2'b10)  &                //-- don't check if lane is disabled or if header is a training sync hdr
                             ( (( deskew_sync0_q[1:0] != 2'b01) & ~calc_par_q & check_EDPL_q) |
                               ((^deskew_sync0_q[1:0]         ) &  calc_par_q & check_EDPL_q) ); //-- header is not 2'b11 or 2'b00

assign EDPL_error_din      = EDPL_parity_error;

//----
//-- Config Register Setttings
//----
assign cfg_phy_train_a_more_x     = tx_rx_cfg_patA_length[1];
assign cfg_phy_train_a_less_x     = tx_rx_cfg_patA_length[0];
assign cfg_phy_train_b_more_x     = tx_rx_cfg_patB_length[1];
assign cfg_phy_train_b_less_x     = tx_rx_cfg_patB_length[0];

assign cfg_phy_train_a_more_x_din = cfg_phy_train_a_more_x;
assign cfg_phy_train_a_less_x_din = cfg_phy_train_a_less_x;
assign cfg_phy_train_b_more_x_din = cfg_phy_train_b_more_x;
assign cfg_phy_train_b_less_x_din = cfg_phy_train_b_less_x;

assign cfg_phy_a_hyst[3:0]        = tx_rx_cfg_patA_hyst;
assign cfg_phy_b_hyst[3:0]        = tx_rx_cfg_patB_hyst;

assign cfg_phy_a_hyst_din[3:0]    = cfg_phy_a_hyst[3:0];
assign cfg_phy_b_hyst_din[3:0]    = cfg_phy_b_hyst[3:0];

assign Test_Obs_din[17:5] = Test_Obs[17:5];
assign spare_cfg_din      = spare_cfg_q | (|Test_Obs_q[17:5]);

//--
//-- Receive logic
//--

//-- indicates data is safe to read on dl clock domain
assign read_ptr_din[3:0] = ( (read_ptr_q[3:0] + 4'h1) & {4{ input_taken}} | 
                             (read_ptr_q[3:0]       ) & {4{~input_taken}} );

//-- reset with deskew is reset????
assign reset_deskew_din  = ln_deskew_reset;   //-- latching this OK?
assign buffer_reset      = reset_deskew_q;

//-- the buffer contains a newly written block in either half
assign buffer_block_valid_din = lfsr_running_q & input_taken & (read_ptr_q[1:0] == 2'b11); //-- writing the last beat of a block


//-- tail pointer is in terms of 16-bit groups, one group added for each toggle
//-- see how many toggle pulses this cycle (location of expected toggle based on low bits of tail pointer)
assign cfg_sync_mode_din     = tx_rx_cfg_sync_mode;
assign cfg_data_toggle[7:0]  = (sync_data_toggle[7:0] & {8{~cfg_sync_mode_q}}) | //-- use meta stability latch pair
                               (data_toggle[7:0]      & {8{ cfg_sync_mode_q}});  //-- bypass meta stablility latch pair

//-- check to see if data can be read
assign selected_data_toggle  = ((cfg_data_toggle[7]) & (read_ptr_q[2:0] == 3'b000)) |
                               ((cfg_data_toggle[6]) & (read_ptr_q[2:0] == 3'b001)) |
                               ((cfg_data_toggle[5]) & (read_ptr_q[2:0] == 3'b010)) |
                               ((cfg_data_toggle[4]) & (read_ptr_q[2:0] == 3'b011)) |
                               ((cfg_data_toggle[3]) & (read_ptr_q[2:0] == 3'b100)) |
                               ((cfg_data_toggle[2]) & (read_ptr_q[2:0] == 3'b101)) |
                               ((cfg_data_toggle[1]) & (read_ptr_q[2:0] == 3'b110)) |
                               ((cfg_data_toggle[0]) & (read_ptr_q[2:0] == 3'b111));

assign valid_data         = selected_data_toggle ^ last_value_q;
assign read_ptr_wraps     = read_ptr_din[3]      ^ read_ptr_q[3];

//-- When stalling read pointer for deskew, we can hit a crc on the deskew marker causing us to miss and have the buffer overflow.
//-- data overflow come on 1 cycle before the data overflows
assign last_value_din     = (read_ptr_wraps | data_overflow) ? ~last_value_q : last_value_q;
assign last_value_dly_din = (read_ptr_wraps | data_overflow) ?  last_value_q : last_value_dly_q;


//-- previous spot saw a toggle, so next cycle it will overflow
assign prev_selected_data_toggle = ( ((cfg_data_toggle[7]) & ((read_ptr_q[2:0] - 3'b001) == 3'b000)) |
                                     ((cfg_data_toggle[6]) & ((read_ptr_q[2:0] - 3'b001) == 3'b001)) |
                                     ((cfg_data_toggle[5]) & ((read_ptr_q[2:0] - 3'b001) == 3'b010)) |
                                     ((cfg_data_toggle[4]) & ((read_ptr_q[2:0] - 3'b001) == 3'b011)) |
                                     ((cfg_data_toggle[3]) & ((read_ptr_q[2:0] - 3'b001) == 3'b100)) |
                                     ((cfg_data_toggle[2]) & ((read_ptr_q[2:0] - 3'b001) == 3'b101)) |
                                     ((cfg_data_toggle[1]) & ((read_ptr_q[2:0] - 3'b001) == 3'b110)) |
                                     ((cfg_data_toggle[0]) & ((read_ptr_q[2:0] - 3'b001) == 3'b111)) );

assign buffer_started_din = cfg_data_toggle[7] | buffer_started_q;
assign data_overflow      = buffer_started_q & ((read_ptr_q[2:0] - 3'b001) == 3'b111 & (prev_selected_data_toggle == last_value_dly_q)) |
                                               ((read_ptr_q[2:0] - 3'b001) != 3'b111 & (prev_selected_data_toggle == last_value_q    ));
assign ln_deskew_overflow = data_overflow & ~lane_disabled_q;

//-- lane is disabled when config disables the lane, or the PHY fence is one (except fence ignored during phy training)
assign lane_disabled_din  =  ln_disabled;
assign phy_training_din   = ~ln_phy_init_done | (ln_phy_init_done & ln_phy_training & ~sync_received_q);
assign phy_training_async = phy_training_q;
assign ts_training        =  ln_phy_init_done & ln_ts_training;

//-- buffer has the number of bits needed for various needs
assign buffer_has_16 = valid_data & ~lane_disabled_q;

//-- 2 bit header location per block
//-- assign selected_data_raw[17:16] = ({ 2{(read_ptr_q[  2] == 1'b0  )}} & hdr_blocks[3:2]) | //-- block0
//--                                   ({ 2{(read_ptr_q[  2] == 1'b1  )}} & hdr_blocks[1:0]);  //-- block1
assign selected_data_raw[17:16] = ({ 2{ (read_ptr_q[2:0] == 3'b000)}} & hdr_blocks[3:2]) | //-- block0
                                  ({ 2{ (read_ptr_q[2:0] == 3'b100)}} & hdr_blocks[1:0]) | //-- block1
                                  ({ 2{~(read_ptr_q[1:0] ==  2'b00)}} &  prev_sh_q[1:0]);  //-- held value

assign prev_sh_din[1:0]         = selected_data_raw[17:16];

//-- data location
assign selected_data_raw[15: 0] = ({16{(read_ptr_q[2:0] == 3'b000)}} & block0[63:48]) |
                                  ({16{(read_ptr_q[2:0] == 3'b001)}} & block0[47:32]) |
                                  ({16{(read_ptr_q[2:0] == 3'b010)}} & block0[31:16]) |
                                  ({16{(read_ptr_q[2:0] == 3'b011)}} & block0[15: 0]) |
                                  ({16{(read_ptr_q[2:0] == 3'b100)}} & block1[63:48]) |
                                  ({16{(read_ptr_q[2:0] == 3'b101)}} & block1[47:32]) |
                                  ({16{(read_ptr_q[2:0] == 3'b110)}} & block1[31:16]) |
                                  ({16{(read_ptr_q[2:0] == 3'b111)}} & block1[15: 0]);


//--
//-- PHY training
//--
//--  added for detecting a slower pattern being received
//-- search for [9 ones followed by 9] or [9 zeros followed by 9 ones] zeros for 16 consecutive cycles.

assign prev_raw_data_din[15:0] = (selected_data_raw[15: 0] & {16{ normal_phy_cycle}}) |
                                 (  prev_raw_data_q[15: 0] & {16{~normal_phy_cycle}}) ;

assign prev_raw_data_dly_din[15:0] = prev_raw_data_q[15:0];

assign slow_raw_data[31:0]     = {prev_raw_data_dly_q[15:0], prev_raw_data_q[15:0]};

assign pattern_F_det_a[12]     = (&slow_raw_data[31:23]) & (&(~slow_raw_data[22:14]));
assign pattern_F_det_a[11]     = (&slow_raw_data[30:22]) & (&(~slow_raw_data[21:13]));
assign pattern_F_det_a[10]     = (&slow_raw_data[29:21]) & (&(~slow_raw_data[20:12]));
assign pattern_F_det_a[ 9]     = (&slow_raw_data[28:20]) & (&(~slow_raw_data[19:11]));
assign pattern_F_det_a[ 8]     = (&slow_raw_data[27:19]) & (&(~slow_raw_data[18:10]));
assign pattern_F_det_a[ 7]     = (&slow_raw_data[26:18]) & (&(~slow_raw_data[17: 9]));
assign pattern_F_det_a[ 6]     = (&slow_raw_data[25:17]) & (&(~slow_raw_data[16: 8]));
assign pattern_F_det_a[ 5]     = (&slow_raw_data[24:16]) & (&(~slow_raw_data[15: 7]));
assign pattern_F_det_a[ 4]     = (&slow_raw_data[23:15]) & (&(~slow_raw_data[14: 6]));
assign pattern_F_det_a[ 3]     = (&slow_raw_data[22:14]) & (&(~slow_raw_data[13: 5]));
assign pattern_F_det_a[ 2]     = (&slow_raw_data[21:13]) & (&(~slow_raw_data[12: 4]));
assign pattern_F_det_a[ 1]     = (&slow_raw_data[20:12]) & (&(~slow_raw_data[11: 3]));
assign pattern_F_det_a[ 0]     = (&slow_raw_data[19:11]) & (&(~slow_raw_data[10: 2]));

assign pattern_F_det_b[12]     = &(~slow_raw_data[31:23]) & (&slow_raw_data[22:14]);
assign pattern_F_det_b[11]     = &(~slow_raw_data[30:22]) & (&slow_raw_data[21:13]);
assign pattern_F_det_b[10]     = &(~slow_raw_data[29:21]) & (&slow_raw_data[20:12]);
assign pattern_F_det_b[ 9]     = &(~slow_raw_data[28:20]) & (&slow_raw_data[19:11]);
assign pattern_F_det_b[ 8]     = &(~slow_raw_data[27:19]) & (&slow_raw_data[18:10]);
assign pattern_F_det_b[ 7]     = &(~slow_raw_data[26:18]) & (&slow_raw_data[17: 9]);
assign pattern_F_det_b[ 6]     = &(~slow_raw_data[25:17]) & (&slow_raw_data[16: 8]);
assign pattern_F_det_b[ 5]     = &(~slow_raw_data[24:16]) & (&slow_raw_data[15: 7]);
assign pattern_F_det_b[ 4]     = &(~slow_raw_data[23:15]) & (&slow_raw_data[14: 6]);
assign pattern_F_det_b[ 3]     = &(~slow_raw_data[22:14]) & (&slow_raw_data[13: 5]);
assign pattern_F_det_b[ 2]     = &(~slow_raw_data[21:13]) & (&slow_raw_data[12: 4]);
assign pattern_F_det_b[ 1]     = &(~slow_raw_data[20:12]) & (&slow_raw_data[11: 3]);
assign pattern_F_det_b[ 0]     = &(~slow_raw_data[19:11]) & (&slow_raw_data[10: 2]);
assign detect_pattern_F        = |{pattern_F_det_a[12:0], pattern_F_det_b[12:0]};

//-- inserted for testability
assign pattern_F_det_test_din[0] = (|pattern_F_det_a[11:8]);
assign pattern_F_det_test_din[1] = (|pattern_F_det_a[ 7:4]);
assign pattern_F_det_test_din[2] = (|pattern_F_det_a[ 3:0]);
assign pattern_F_det_test_din[3] = (|pattern_F_det_b[11:8]);
assign pattern_F_det_test_din[4] = (|pattern_F_det_b[ 7:4]);
assign pattern_F_det_test_din[5] = (|pattern_F_det_b[ 3:0]);
assign pattern_F_det_test_din[6] = ( pattern_F_det_a[12] | pattern_F_det_b[12]);


assign F_pattern_cnt_din       = detect_pattern_F & normal_phy_cycle;
assign ln_rx_slow_pat_a        = F_pattern_cnt_q;


//-- wrap the data being looked at (when not aligned, the next data should be the same as current data, so just wrap)
assign selected_data_wrap[29:0]   = {prev_raw_data_q[15:0],  //-- bits[29:14]
                                     prev_raw_data_q[15:2]}; //-- bits[13: 0]

//-- detect 3 levels of X in the patterns, (4, 2, or 1, with the default being 2)
//-- detect pattern A (transmitted as FF00, detect 1111XXXX0000XXXX for 4 X mode
//--                                               111111XX000000XX for 2 X mode
//--                                               1111111X0000000X for 1 X mode
assign pattern_a_mask[6:0] = (7'b0000111 & {7{ cfg_phy_train_a_more_x_q                            }} ) |
                             (7'b0000001 & {7{~cfg_phy_train_a_more_x_q & ~cfg_phy_train_a_less_x_q}} ) |
                             (7'b0000000 & {7{~cfg_phy_train_a_more_x_q &  cfg_phy_train_a_less_x_q}} );

//-- the 16 possible alignments are decoded
assign pattern_A_det_a[15]  = &(selected_data_wrap[29:23] | pattern_a_mask[6:0]);   // 111111X---------
assign pattern_A_det_a[14]  = &(selected_data_wrap[28:22] | pattern_a_mask[6:0]);   // -111111X--------
assign pattern_A_det_a[13]  = &(selected_data_wrap[27:21] | pattern_a_mask[6:0]);   // --111111X-------
assign pattern_A_det_a[12]  = &(selected_data_wrap[26:20] | pattern_a_mask[6:0]);   // ---111111X------
assign pattern_A_det_a[11]  = &(selected_data_wrap[25:19] | pattern_a_mask[6:0]);   // ----111111X-----
assign pattern_A_det_a[10]  = &(selected_data_wrap[24:18] | pattern_a_mask[6:0]);   // -----111111X----
assign pattern_A_det_a[ 9]  = &(selected_data_wrap[23:17] | pattern_a_mask[6:0]);   // ------111111X---
assign pattern_A_det_a[ 8]  = &(selected_data_wrap[22:16] | pattern_a_mask[6:0]);   // -------111111X--
assign pattern_A_det_a[ 7]  = &(selected_data_wrap[21:15] | pattern_a_mask[6:0]);   // --------111111X-
assign pattern_A_det_a[ 6]  = &(selected_data_wrap[20:14] | pattern_a_mask[6:0]);   // ---------111111X
assign pattern_A_det_a[ 5]  = &(selected_data_wrap[19:13] | pattern_a_mask[6:0]);   // X---------111111
assign pattern_A_det_a[ 4]  = &(selected_data_wrap[18:12] | pattern_a_mask[6:0]);   // 1X---------11111
assign pattern_A_det_a[ 3]  = &(selected_data_wrap[17:11] | pattern_a_mask[6:0]);   // 11X---------1111
assign pattern_A_det_a[ 2]  = &(selected_data_wrap[16:10] | pattern_a_mask[6:0]);   // 111X---------111
assign pattern_A_det_a[ 1]  = &(selected_data_wrap[15: 9] | pattern_a_mask[6:0]);   // 1111X---------11
assign pattern_A_det_a[ 0]  = &(selected_data_wrap[14: 8] | pattern_a_mask[6:0]);   // 11111X---------1

assign pattern_A_det_b[15]  = &(~selected_data_wrap[21:15] | pattern_a_mask[6:0]);  // --------000000X-
assign pattern_A_det_b[14]  = &(~selected_data_wrap[20:14] | pattern_a_mask[6:0]);  // ---------000000X
assign pattern_A_det_b[13]  = &(~selected_data_wrap[19:13] | pattern_a_mask[6:0]);  // X---------000000
assign pattern_A_det_b[12]  = &(~selected_data_wrap[18:12] | pattern_a_mask[6:0]);  // 0X---------00000
assign pattern_A_det_b[11]  = &(~selected_data_wrap[17:11] | pattern_a_mask[6:0]);  // 00X---------0000
assign pattern_A_det_b[10]  = &(~selected_data_wrap[16:10] | pattern_a_mask[6:0]);  // 000X---------000
assign pattern_A_det_b[ 9]  = &(~selected_data_wrap[15: 9] | pattern_a_mask[6:0]);  // 0000X---------00
assign pattern_A_det_b[ 8]  = &(~selected_data_wrap[14: 8] | pattern_a_mask[6:0]);  // 00000X---------0
assign pattern_A_det_b[ 7]  = &(~selected_data_wrap[13: 7] | pattern_a_mask[6:0]);  // 000000X---------
assign pattern_A_det_b[ 6]  = &(~selected_data_wrap[12: 6] | pattern_a_mask[6:0]);  // -000000X--------
assign pattern_A_det_b[ 5]  = &(~selected_data_wrap[11: 5] | pattern_a_mask[6:0]);  // --000000X-------
assign pattern_A_det_b[ 4]  = &(~selected_data_wrap[10: 4] | pattern_a_mask[6:0]);  // ---000000X------
assign pattern_A_det_b[ 3]  = &(~selected_data_wrap[ 9: 3] | pattern_a_mask[6:0]);  // ----000000X-----
assign pattern_A_det_b[ 2]  = &(~selected_data_wrap[ 8: 2] | pattern_a_mask[6:0]);  // -----000000X----
assign pattern_A_det_b[ 1]  = &(~selected_data_wrap[ 7: 1] | pattern_a_mask[6:0]);  // ------000000X---
assign pattern_A_det_b[ 0]  = &(~selected_data_wrap[ 6: 0] | pattern_a_mask[6:0]);  // -------000000X--

assign Test_Obs[17]           = ^(pattern_A_det_a[15:0] | pattern_A_det_b[15:0]) & normal_phy_cycle;
assign pattern_A_detect[15:0] =   pattern_A_det_a[15:0] & pattern_A_det_b[15:0];

//  Possible pattern A detections
//  [15] = 111111X-000000X-
//  [14] = -111111X-000000X
//  [13] = X-111111X-000000
//  [12] = 0X-111111X-00000
//  [11] = 00X-111111X-0000
//  [10] = 000X-111111X-000
//  [ 9] = 0000X-111111X-00
//  [ 8] = 00000X-111111X-0
//  [ 7] = 000000X-111111X-
//  [ 6] = -000000X-111111X
//  [ 5] = X-000000X-111111
//  [ 4] = 1X-000000X-11111
//  [ 3] = 11X-000000X-1111
//  [ 2] = 111X-000000X-111
//  [ 1] = 1111X-000000X-11
//  [ 0] = 11111X-000000X-1



assign Test_Obs[16]             =  1'b0;




//-- detect pattern B (transmitted as FFFF 0000 with normal pattern A (FF00) before and after it)
//-- detect 111111111111XXXX 000000000000XXXX for 4 X mode
//--        11111111111111XX 00000000000000XX for 2 X mode
//--        111111111111111X 000000000000000X for 1 X mode
assign pattern_b_mask[15:0] = (16'b0000000000001111 & {16{ cfg_phy_train_b_more_x_q                            }} ) |
                              (16'b0000000000000011 & {16{~cfg_phy_train_b_more_x_q & ~cfg_phy_train_b_less_x_q}} ) |
                              (16'b0000000000000001 & {16{~cfg_phy_train_b_more_x_q &  cfg_phy_train_b_less_x_q}} );

//-- the long pattern could be detected on up to 3 different 16-bit cycles, depending on alignment
//-- ????  all the alignments


assign pattern_B_det1_a[15] = &(                                                                                                  (prev_raw_data_q[15:8] | pattern_b_mask[15: 8]));
assign pattern_B_det1_a[14] = &(                                                                                                  (prev_raw_data_q[14:8] | pattern_b_mask[15: 9]));
assign pattern_B_det1_a[13] = &({((                       ~prev_raw_data_q[15:15]) | (                     pattern_a_mask[0:0])), (prev_raw_data_q[13:8] | pattern_b_mask[15:10])});
assign pattern_B_det1_a[12] = &({((                       ~prev_raw_data_q[15:14]) | (                     pattern_a_mask[1:0])), (prev_raw_data_q[12:8] | pattern_b_mask[15:11])});
assign pattern_B_det1_a[11] = &({((                       ~prev_raw_data_q[15:13]) | (                     pattern_a_mask[2:0])), (prev_raw_data_q[11:8] | pattern_b_mask[15:12])});
assign pattern_B_det1_a[10] = &({((                       ~prev_raw_data_q[15:12]) | (                     pattern_a_mask[3:0])), (prev_raw_data_q[10:8] | pattern_b_mask[15:13])});
assign pattern_B_det1_a[ 9] = &({((                       ~prev_raw_data_q[15:11]) | (                     pattern_a_mask[4:0])), (prev_raw_data_q[ 9:8] | pattern_b_mask[15:14])});
assign pattern_B_det1_a[ 8] = &({((                       ~prev_raw_data_q[15:10]) | (                     pattern_a_mask[5:0])), (prev_raw_data_q[ 8:8] | pattern_b_mask[15:15])});
assign pattern_B_det1_a[ 7] = &((                         ~prev_raw_data_q[15: 9]) | (                     pattern_a_mask[6:0]));
assign pattern_B_det1_a[ 6] = &((                         ~prev_raw_data_q[14: 8]) | (                     pattern_a_mask[6:0]));
assign pattern_B_det1_a[ 5] = &(({prev_raw_data_q[15:15], ~prev_raw_data_q[13: 8]} | {pattern_a_mask[0:0], pattern_a_mask[6:1]}));
assign pattern_B_det1_a[ 4] = &(({prev_raw_data_q[15:14], ~prev_raw_data_q[12: 8]} | {pattern_a_mask[1:0], pattern_a_mask[6:2]}));
assign pattern_B_det1_a[ 3] = &(({prev_raw_data_q[15:13], ~prev_raw_data_q[11: 8]} | {pattern_a_mask[2:0], pattern_a_mask[6:3]}));
assign pattern_B_det1_a[ 2] = &(({prev_raw_data_q[15:12], ~prev_raw_data_q[10: 8]} | {pattern_a_mask[3:0], pattern_a_mask[6:4]}));
assign pattern_B_det1_a[ 1] = &(({prev_raw_data_q[15:11], ~prev_raw_data_q[ 9: 8]} | {pattern_a_mask[4:0], pattern_a_mask[6:5]}));
assign pattern_B_det1_a[ 0] = &(({prev_raw_data_q[15:10], ~prev_raw_data_q[ 8: 8]} | {pattern_a_mask[5:0], pattern_a_mask[6:6]}));

// pattern_B_det1_a[15] = 11111111------------------------  pattern_B_det1_b[15] = --------111111XX----------------
// pattern_B_det1_a[14] = -1111111------------------------  pattern_B_det1_b[14] = --------1111111X----------------
// pattern_B_det1_a[13] = X-111111------------------------  pattern_B_det1_b[13] = --------11111111----------------
// pattern_B_det1_a[12] = 0X-11111------------------------  pattern_B_det1_b[12] = --------11111111----------------
// pattern_B_det1_a[11] = 00X-1111------------------------  pattern_B_det1_b[11] = --------11111111----------------
// pattern_B_det1_a[10] = 000X-111------------------------  pattern_B_det1_b[10] = --------11111111----------------
// pattern_B_det1_a[ 9] = 0000X-11------------------------  pattern_B_det1_b[ 9] = --------11111111----------------
// pattern_B_det1_a[ 8] = 00000X-1------------------------  pattern_B_det1_b[ 8] = --------11111111----------------
// pattern_B_det1_a[ 7] = 000000X-------------------------  pattern_B_det1_b[ 7] = --------11111111----------------
// pattern_B_det1_a[ 6] = -000000X------------------------  pattern_B_det1_b[ 6] = ---------1111111----------------
// pattern_B_det1_a[ 5] = X-000000------------------------  pattern_B_det1_b[ 5] = --------X-111111----------------
// pattern_B_det1_a[ 4] = 1X-00000------------------------  pattern_B_det1_b[ 4] = --------0X-11111----------------
// pattern_B_det1_a[ 3] = 11X-0000------------------------  pattern_B_det1_b[ 3] = --------00X-1111----------------
// pattern_B_det1_a[ 2] = 111X-000------------------------  pattern_B_det1_b[ 2] = --------000X-111----------------
// pattern_B_det1_a[ 1] = 1111X-00------------------------  pattern_B_det1_b[ 1] = --------0000X-11----------------
// pattern_B_det1_a[ 0] = 11111X-0------------------------  pattern_B_det1_b[ 0] = --------00000X-1----------------

assign pattern_B_det1_b[15] = &(                                                (prev_raw_data_q[7:0] | pattern_b_mask[ 7: 0]));
assign pattern_B_det1_b[14] = &(                                                (prev_raw_data_q[7:0] | pattern_b_mask[ 8: 1]));
assign pattern_B_det1_b[13] = &(                                                (prev_raw_data_q[7:0] | pattern_b_mask[ 9: 2]));
assign pattern_B_det1_b[12] = &(                                                (prev_raw_data_q[7:0] | pattern_b_mask[10: 3]));
assign pattern_B_det1_b[11] = &(                                                (prev_raw_data_q[7:0] | pattern_b_mask[11: 4]));
assign pattern_B_det1_b[10] = &(                                                (prev_raw_data_q[7:0] | pattern_b_mask[12: 5]));
assign pattern_B_det1_b[ 9] = &(                                                (prev_raw_data_q[7:0] | pattern_b_mask[13: 6]));
assign pattern_B_det1_b[ 8] = &(                                                (prev_raw_data_q[7:0] | pattern_b_mask[14: 7]));
assign pattern_B_det1_b[ 7] = &(                                                (prev_raw_data_q[7:0] | pattern_b_mask[15: 8]));
assign pattern_B_det1_b[ 6] = &(                                                (prev_raw_data_q[6:0] | pattern_b_mask[15: 9]));
assign pattern_B_det1_b[ 5] = &({(~prev_raw_data_q[7:7] | pattern_a_mask[0:0]), (prev_raw_data_q[5:0] | pattern_b_mask[15:10])});
assign pattern_B_det1_b[ 4] = &({(~prev_raw_data_q[7:6] | pattern_a_mask[1:0]), (prev_raw_data_q[4:0] | pattern_b_mask[15:11])});
assign pattern_B_det1_b[ 3] = &({(~prev_raw_data_q[7:5] | pattern_a_mask[2:0]), (prev_raw_data_q[3:0] | pattern_b_mask[15:12])});
assign pattern_B_det1_b[ 2] = &({(~prev_raw_data_q[7:4] | pattern_a_mask[3:0]), (prev_raw_data_q[2:0] | pattern_b_mask[15:13])});
assign pattern_B_det1_b[ 1] = &({(~prev_raw_data_q[7:3] | pattern_a_mask[4:0]), (prev_raw_data_q[1:0] | pattern_b_mask[15:14])});
assign pattern_B_det1_b[ 0] = &({(~prev_raw_data_q[7:2] | pattern_a_mask[5:0]), (prev_raw_data_q[0:0] | pattern_b_mask[15:15])});

assign Test_Obs[15]            = ^(pattern_B_det1_a[15:0] | pattern_B_det1_b[15:0]) & normal_phy_cycle;
assign pattern_B_detect1[15:0] =   pattern_B_det1_a[15:0] & pattern_B_det1_b[15:0];

//  First Part of Pattern B detected
// [15] = 11111111111111XX----------------
// [14] = -11111111111111X----------------
// [13] = X-11111111111111----------------
// [12] = 0X-1111111111111----------------
// [11] = 00X-111111111111----------------
// [10] = 000X-11111111111----------------
// [ 9] = 0000X-1111111111----------------
// [ 8] = 00000X-111111111----------------
// [ 7] = 000000X-11111111----------------
// [ 6] = -000000X-1111111----------------
// [ 5] = X-000000X-111111----------------
// [ 4] = 1X-000000X-11111----------------
// [ 3] = 11X-000000X-1111----------------
// [ 2] = 111X-000000X-111----------------
// [ 1] = 1111X-000000X-11----------------
// [ 0] = 11111X-000000X-1----------------


assign pattern_B_det2_a[15] = &(                                                  (~prev_raw_data_q[15:8] | pattern_b_mask[15: 8]) );
assign pattern_B_det2_a[14] = &({(prev_raw_data_q[15:15] | pattern_b_mask[ 0:0]), (~prev_raw_data_q[14:8] | pattern_b_mask[15: 9])});
assign pattern_B_det2_a[13] = &({(prev_raw_data_q[15:14] | pattern_b_mask[ 1:0]), (~prev_raw_data_q[13:8] | pattern_b_mask[15:10])});
assign pattern_B_det2_a[12] = &({(prev_raw_data_q[15:13] | pattern_b_mask[ 2:0]), (~prev_raw_data_q[12:8] | pattern_b_mask[15:11])});
assign pattern_B_det2_a[11] = &({(prev_raw_data_q[15:12] | pattern_b_mask[ 3:0]), (~prev_raw_data_q[11:8] | pattern_b_mask[15:12])});
assign pattern_B_det2_a[10] = &({(prev_raw_data_q[15:11] | pattern_b_mask[ 4:0]), (~prev_raw_data_q[10:8] | pattern_b_mask[15:13])});
assign pattern_B_det2_a[ 9] = &({(prev_raw_data_q[15:10] | pattern_b_mask[ 5:0]), (~prev_raw_data_q[ 9:8] | pattern_b_mask[15:14])});
assign pattern_B_det2_a[ 8] = &({(prev_raw_data_q[15: 9] | pattern_b_mask[ 6:0]), (~prev_raw_data_q[ 8:8] | pattern_b_mask[15:15])});
assign pattern_B_det2_a[ 7] = &( (prev_raw_data_q[15: 8] | pattern_b_mask[ 7:0])                                                   );
assign pattern_B_det2_a[ 6] = &( (prev_raw_data_q[15: 8] | pattern_b_mask[ 8:1])                                                   );
assign pattern_B_det2_a[ 5] = &( (prev_raw_data_q[15: 8] | pattern_b_mask[ 9:2])                                                   );
assign pattern_B_det2_a[ 4] = &( (prev_raw_data_q[15: 8] | pattern_b_mask[10:3])                                                   );
assign pattern_B_det2_a[ 3] = &( (prev_raw_data_q[15: 8] | pattern_b_mask[11:4])                                                   );
assign pattern_B_det2_a[ 2] = &( (prev_raw_data_q[15: 8] | pattern_b_mask[12:5])                                                   );
assign pattern_B_det2_a[ 1] = &( (prev_raw_data_q[15: 8] | pattern_b_mask[13:6])                                                   );
assign pattern_B_det2_a[ 0] = &( (prev_raw_data_q[15: 8] | pattern_b_mask[14:7])                                                   );

// pattern_B_det2_a[15] = 00000000------------------------  pattern_B_det2_b[15] = --------000000XX----------------
// pattern_B_det2_a[14] = X0000000------------------------  pattern_B_det2_b[14] = --------0000000X----------------
// pattern_B_det2_a[13] = XX000000------------------------  pattern_B_det2_b[13] = --------00000000----------------
// pattern_B_det2_a[12] = 1XX00000------------------------  pattern_B_det2_b[12] = --------00000000----------------
// pattern_B_det2_a[11] = 11XX0000------------------------  pattern_B_det2_b[11] = --------00000000----------------
// pattern_B_det2_a[10] = 111XX000------------------------  pattern_B_det2_b[10] = --------00000000----------------
// pattern_B_det2_a[ 9] = 1111XX00------------------------  pattern_B_det2_b[ 9] = --------00000000----------------
// pattern_B_det2_a[ 8] = 11111XX0------------------------  pattern_B_det2_b[ 8] = --------00000000----------------
// pattern_B_det2_a[ 7] = 111111XX------------------------  pattern_B_det2_b[ 7] = --------00000000----------------
// pattern_B_det2_a[ 6] = 1111111X------------------------  pattern_B_det2_b[ 6] = --------X0000000----------------
// pattern_B_det2_a[ 5] = 11111111------------------------  pattern_B_det2_b[ 5] = --------XX000000----------------
// pattern_B_det2_a[ 4] = 11111111------------------------  pattern_B_det2_b[ 4] = --------1XX00000----------------
// pattern_B_det2_a[ 3] = 11111111------------------------  pattern_B_det2_b[ 3] = --------11XX0000----------------
// pattern_B_det2_a[ 2] = 11111111------------------------  pattern_B_det2_b[ 2] = --------111XX000----------------
// pattern_B_det2_a[ 1] = 11111111------------------------  pattern_B_det2_b[ 1] = --------1111XX00----------------
// pattern_B_det2_a[ 0] = 11111111------------------------  pattern_B_det2_b[ 0] = --------11111XX0----------------

assign pattern_B_det2_b[15] = &(                                               (~prev_raw_data_q[7:0] | pattern_b_mask[ 7: 0]) );
assign pattern_B_det2_b[14] = &(                                               (~prev_raw_data_q[7:0] | pattern_b_mask[ 8: 1]) );
assign pattern_B_det2_b[13] = &(                                               (~prev_raw_data_q[7:0] | pattern_b_mask[ 9: 2]) );
assign pattern_B_det2_b[12] = &(                                               (~prev_raw_data_q[7:0] | pattern_b_mask[10: 3]) );
assign pattern_B_det2_b[11] = &(                                               (~prev_raw_data_q[7:0] | pattern_b_mask[11: 4]) );
assign pattern_B_det2_b[10] = &(                                               (~prev_raw_data_q[7:0] | pattern_b_mask[12: 5]) );
assign pattern_B_det2_b[ 9] = &(                                               (~prev_raw_data_q[7:0] | pattern_b_mask[13: 6]) );
assign pattern_B_det2_b[ 8] = &(                                               (~prev_raw_data_q[7:0] | pattern_b_mask[14: 7]) );
assign pattern_B_det2_b[ 7] = &(                                               (~prev_raw_data_q[7:0] | pattern_b_mask[15: 8]) );
assign pattern_B_det2_b[ 6] = &({(prev_raw_data_q[7:7] | pattern_b_mask[0:0]), (~prev_raw_data_q[6:0] | pattern_b_mask[15: 9])});
assign pattern_B_det2_b[ 5] = &({(prev_raw_data_q[7:6] | pattern_b_mask[1:0]), (~prev_raw_data_q[5:0] | pattern_b_mask[15:10])});
assign pattern_B_det2_b[ 4] = &({(prev_raw_data_q[7:5] | pattern_b_mask[2:0]), (~prev_raw_data_q[4:0] | pattern_b_mask[15:11])});
assign pattern_B_det2_b[ 3] = &({(prev_raw_data_q[7:4] | pattern_b_mask[3:0]), (~prev_raw_data_q[3:0] | pattern_b_mask[15:12])});
assign pattern_B_det2_b[ 2] = &({(prev_raw_data_q[7:3] | pattern_b_mask[4:0]), (~prev_raw_data_q[2:0] | pattern_b_mask[15:13])});
assign pattern_B_det2_b[ 1] = &({(prev_raw_data_q[7:2] | pattern_b_mask[5:0]), (~prev_raw_data_q[1:0] | pattern_b_mask[15:14])});
assign pattern_B_det2_b[ 0] = &({(prev_raw_data_q[7:1] | pattern_b_mask[6:0]), (~prev_raw_data_q[0:0] | pattern_b_mask[15:15])});

assign Test_Obs[14]            = ^(pattern_B_det2_a[15:0] | pattern_B_det2_b[15:0]) & normal_phy_cycle;
assign pattern_B_detect2[15:0] =   pattern_B_det2_a[15:0] & pattern_B_det2_b[15:0];

//  Second Part of Pattern B detected
// [15] = 00000000000000XX----------------
// [14] = X00000000000000X----------------
// [13] = XX00000000000000----------------
// [12] = 1XX0000000000000----------------
// [11] = 11XX000000000000----------------
// [10] = 111XX00000000000----------------
// [ 9] = 1111XX0000000000----------------
// [ 8] = 11111XX000000000----------------
// [ 7] = 111111XX00000000----------------
// [ 6] = 1111111XX0000000----------------
// [ 5] = 11111111XX000000----------------
// [ 4] = 111111111XX00000----------------
// [ 3] = 1111111111XX0000----------------
// [ 2] = 11111111111XX000----------------
// [ 1] = 111111111111XX00----------------
// [ 0] = 1111111111111XX0----------------


assign pattern_B_det3_a[15] = &(                                                   (prev_raw_data_q[15: 9] | pattern_a_mask[6:0]) );
assign pattern_B_det3_a[14] = &({(~prev_raw_data_q[15:15] | pattern_b_mask[ 0:0]), (prev_raw_data_q[14: 8] | pattern_a_mask[6:0])});
assign pattern_B_det3_a[13] = &({(~prev_raw_data_q[15:14] | pattern_b_mask[ 1:0]), (prev_raw_data_q[13: 8] | pattern_a_mask[6:1])});
assign pattern_B_det3_a[12] = &({(~prev_raw_data_q[15:13] | pattern_b_mask[ 2:0]), (prev_raw_data_q[12: 8] | pattern_a_mask[6:2])});
assign pattern_B_det3_a[11] = &({(~prev_raw_data_q[15:12] | pattern_b_mask[ 3:0]), (prev_raw_data_q[11: 8] | pattern_a_mask[6:3])});
assign pattern_B_det3_a[10] = &({(~prev_raw_data_q[15:11] | pattern_b_mask[ 4:0]), (prev_raw_data_q[10: 8] | pattern_a_mask[6:4])});
assign pattern_B_det3_a[ 9] = &({(~prev_raw_data_q[15:10] | pattern_b_mask[ 5:0]), (prev_raw_data_q[ 9: 8] | pattern_a_mask[6:5])});
assign pattern_B_det3_a[ 8] = &({(~prev_raw_data_q[15: 9] | pattern_b_mask[ 6:0]), (prev_raw_data_q[ 8: 8] | pattern_a_mask[6:6])});
assign pattern_B_det3_a[ 7] = &( (~prev_raw_data_q[15: 8] | pattern_b_mask[ 7:0])                                                 );
assign pattern_B_det3_a[ 6] = &( (~prev_raw_data_q[15: 8] | pattern_b_mask[ 8:1])                                                 );
assign pattern_B_det3_a[ 5] = &( (~prev_raw_data_q[15: 8] | pattern_b_mask[ 9:2])                                                 );
assign pattern_B_det3_a[ 4] = &( (~prev_raw_data_q[15: 8] | pattern_b_mask[10:3])                                                 );
assign pattern_B_det3_a[ 3] = &( (~prev_raw_data_q[15: 8] | pattern_b_mask[11:4])                                                 );
assign pattern_B_det3_a[ 2] = &( (~prev_raw_data_q[15: 8] | pattern_b_mask[12:5])                                                 );
assign pattern_B_det3_a[ 1] = &( (~prev_raw_data_q[15: 8] | pattern_b_mask[13:6])                                                 );
assign pattern_B_det3_a[ 0] = &( (~prev_raw_data_q[15: 8] | pattern_b_mask[14:7])                                                 );

//-- pattern_B_det3_a[15] = 111111X-------------------------   pattern_B_det3_b[15] = --------000000X-----------------
//-- pattern_B_det3_a[14] = X111111X------------------------   pattern_B_det3_b[14] = ---------000000X----------------
//-- pattern_B_det3_a[13] = XX111111------------------------   pattern_B_det3_b[13] = --------X-000000----------------
//-- pattern_B_det3_a[12] = 0XX11111------------------------   pattern_B_det3_b[12] = --------1X-00000----------------
//-- pattern_B_det3_a[11] = 00XX1111------------------------   pattern_B_det3_b[11] = --------11X-0000----------------
//-- pattern_B_det3_a[10] = 000XX111------------------------   pattern_B_det3_b[10] = --------111X-000----------------
//-- pattern_B_det3_a[ 9] = 0000XX11------------------------   pattern_B_det3_b[ 9] = --------1111X-00----------------
//-- pattern_B_det3_a[ 8] = 00000XX1------------------------   pattern_B_det3_b[ 8] = --------11111X-0----------------
//-- pattern_B_det3_a[ 7] = 000000XX------------------------   pattern_B_det3_b[ 7] = --------111111X-----------------
//-- pattern_B_det3_a[ 6] = 0000000X------------------------   pattern_B_det3_b[ 6] = --------X111111X----------------
//-- pattern_B_det3_a[ 5] = 00000000------------------------   pattern_B_det3_b[ 5] = --------XX111111----------------
//-- pattern_B_det3_a[ 4] = 00000000------------------------   pattern_B_det3_b[ 4] = --------0XX11111----------------
//-- pattern_B_det3_a[ 3] = 00000000------------------------   pattern_B_det3_b[ 3] = --------00XX1111----------------
//-- pattern_B_det3_a[ 2] = 00000000------------------------   pattern_B_det3_b[ 2] = --------000XX111----------------
//-- pattern_B_det3_a[ 1] = 00000000------------------------   pattern_B_det3_b[ 1] = --------0000XX11----------------
//-- pattern_B_det3_a[ 0] = 00000000------------------------   pattern_B_det3_b[ 0] = --------00000XX1----------------

assign pattern_B_det3_b[15] = &(                                                 ((                      ~prev_raw_data_q[7:1]) | (                      pattern_a_mask[6:0])));
assign pattern_B_det3_b[14] = &(                                                 ((                      ~prev_raw_data_q[6:0]) | (                      pattern_a_mask[6:0])));
assign pattern_B_det3_b[13] = &(                                                 ({prev_raw_data_q[7:7], ~prev_raw_data_q[5:0]} | {pattern_a_mask[0:0],  pattern_a_mask[6:1]}));
assign pattern_B_det3_b[12] = &(                                                 ({prev_raw_data_q[7:6], ~prev_raw_data_q[4:0]} | {pattern_a_mask[1:0],  pattern_a_mask[6:2]}));
assign pattern_B_det3_b[11] = &(                                                 ({prev_raw_data_q[7:5], ~prev_raw_data_q[3:0]} | {pattern_a_mask[2:0],  pattern_a_mask[6:3]}));
assign pattern_B_det3_b[10] = &(                                                 ({prev_raw_data_q[7:4], ~prev_raw_data_q[2:0]} | {pattern_a_mask[3:0],  pattern_a_mask[6:4]}));
assign pattern_B_det3_b[ 9] = &(                                                 ({prev_raw_data_q[7:3], ~prev_raw_data_q[1:0]} | {pattern_a_mask[4:0],  pattern_a_mask[6:5]}));
assign pattern_B_det3_b[ 8] = &(                                                 ({prev_raw_data_q[7:2], ~prev_raw_data_q[0:0]} | {pattern_a_mask[5:0],  pattern_a_mask[6:6]}));
assign pattern_B_det3_b[ 7] = &(                                                 ((prev_raw_data_q[7:1]                       ) | (pattern_a_mask[6:0]))                      );
assign pattern_B_det3_b[ 6] = &({( ~prev_raw_data_q[7:7] | pattern_b_mask[0:0]), ((prev_raw_data_q[6:0]                       ) | (pattern_a_mask[6:0]))}                     );
assign pattern_B_det3_b[ 5] = &({( ~prev_raw_data_q[7:6] | pattern_b_mask[1:0]), ((prev_raw_data_q[5:0]                       ) | (pattern_a_mask[6:1]))}                     );
assign pattern_B_det3_b[ 4] = &({( ~prev_raw_data_q[7:5] | pattern_b_mask[2:0]), ((prev_raw_data_q[4:0]                       ) | (pattern_a_mask[6:2]))}                     );
assign pattern_B_det3_b[ 3] = &({( ~prev_raw_data_q[7:4] | pattern_b_mask[3:0]), ((prev_raw_data_q[3:0]                       ) | (pattern_a_mask[6:3]))}                     );
assign pattern_B_det3_b[ 2] = &({( ~prev_raw_data_q[7:3] | pattern_b_mask[4:0]), ((prev_raw_data_q[2:0]                       ) | (pattern_a_mask[6:4]))}                     );
assign pattern_B_det3_b[ 1] = &({( ~prev_raw_data_q[7:2] | pattern_b_mask[5:0]), ((prev_raw_data_q[1:0]                       ) | (pattern_a_mask[6:5]))}                     );
assign pattern_B_det3_b[ 0] = &({( ~prev_raw_data_q[7:1] | pattern_b_mask[6:0]), ((prev_raw_data_q[0:0]                       ) | (pattern_a_mask[6:6]))}                     );

assign Test_Obs[13]            = ^(pattern_B_det3_a[15:0] | pattern_B_det3_b[15:0]) & normal_phy_cycle;
assign pattern_B_detect3[15:0] =   pattern_B_det3_a[15:0] & pattern_B_det3_b[15:0];

//-- pattern_B_detect3[15] = 111111X-000000X-----------------
//-- pattern_B_detect3[14] = X111111X-000000X----------------
//-- pattern_B_detect3[13] = XX111111X-000000----------------
//-- pattern_B_detect3[12] = 0XX111111X-00000----------------
//-- pattern_B_detect3[11] = 00XX111111X-0000----------------
//-- pattern_B_detect3[10] = 000XX111111X-000----------------
//-- pattern_B_detect3[ 9] = 0000XX111111X-00----------------
//-- pattern_B_detect3[ 8] = 00000XX111111X-0----------------
//-- pattern_B_detect3[ 7] = 000000XX111111X-----------------
//-- pattern_B_detect3[ 6] = 0000000XX111111X----------------
//-- pattern_B_detect3[ 5] = 00000000XX111111----------------
//-- pattern_B_detect3[ 4] = 000000000XX11111----------------
//-- pattern_B_detect3[ 3] = 0000000000XX1111----------------
//-- pattern_B_detect3[ 2] = 00000000000XX111----------------
//-- pattern_B_detect3[ 1] = 000000000000XX11----------------
//-- pattern_B_detect3[ 0] = 0000000000000XX1----------------

//-- look at base case when there is at least 16 bits (if fewer, wait a cycle to have more) but not advancing for 32 bits
assign normal_phy_cycle = phy_training_q & valid_data & ~lane_disabled_q;

//-- if the pattern is detected outside the desired window (in bits 0 through 7), need to shift it
assign need_to_shift_left  = normal_phy_cycle &   ~pattern_A_detect[15] & ~need_to_shift_right;
assign need_to_shift_right = normal_phy_cycle & (|(pattern_A_detect[3:0]));

assign only_good_bits      = normal_phy_cycle & (pattern_A_detect[15:8] != 8'h00) & (pattern_A_detect[7:0] == 8'h00);
assign only_bad_bits       = normal_phy_cycle & (pattern_A_detect[15:8] == 8'h00) & (pattern_A_detect[7:0] != 8'h00);

assign need_shift_left_cnt_din [3:0] = (need_shift_left_cnt_q[3:0]  + 4'b0001) & {4{need_to_shift_left  & ~do_shift_left_q }};
assign need_shift_right_cnt_din[3:0] = (need_shift_right_cnt_q[3:0] + 4'b0001) & {4{need_to_shift_right & ~do_shift_right_q}};

assign do_shift_left_din  = ((need_shift_left_cnt_q[3:0]  == 4'b1111) & need_to_shift_left) | (do_shift_left_q & ~normal_phy_cycle & need_to_shift_left);
assign do_shift_right_din =  (need_shift_right_cnt_q[3:0] == 4'b1111) & need_to_shift_right;

assign slip_left_toggle_din  = do_shift_left_q ^ slip_left_toggle_q; //-- Toggle slip signal when needing to shift left
assign slip_left_async       = slip_left_toggle_q;

assign slip_right_toggle_din = do_shift_right_q ^ slip_right_toggle_q;
assign slip_right_async      = slip_right_toggle_q;


assign only_good_bits_din       = only_good_bits;   //-- delay for timing to the pattern A counter

//-- hysteresis counter for detecting pattern A
assign pattern_a_count_din[15:0] = (          pattern_a_count_q[15:0])
                                 + ({{15{1'b0}}, inc_pattern_a_count}) 
                                 - ({{15{1'b0}}, dec_pattern_a_count});

//-- programmable size of counter
assign pattern_a_limit[15:0] = (16'h0010 & {16{(cfg_phy_a_hyst_q[3:0] == 4'b0000)}}) |
                               (16'h0018 & {16{(cfg_phy_a_hyst_q[3:0] == 4'b0001)}}) |
                               (16'h0020 & {16{(cfg_phy_a_hyst_q[3:0] == 4'b0010)}}) |
                               (16'h0030 & {16{(cfg_phy_a_hyst_q[3:0] == 4'b0011)}}) |
                               (16'h0040 & {16{(cfg_phy_a_hyst_q[3:0] == 4'b0100)}}) |
                               (16'h0060 & {16{(cfg_phy_a_hyst_q[3:0] == 4'b0101)}}) |
                               (16'h0080 & {16{(cfg_phy_a_hyst_q[3:0] == 4'b0110)}}) |
                               (16'h0100 & {16{(cfg_phy_a_hyst_q[3:0] == 4'b0111)}}) |
                               (16'h0200 & {16{(cfg_phy_a_hyst_q[3:0] == 4'b1000)}}) |
                               (16'h0400 & {16{(cfg_phy_a_hyst_q[3:0] == 4'b1001)}}) |
                               (16'h0800 & {16{(cfg_phy_a_hyst_q[3:0] == 4'b1010)}}) |
                               (16'h1000 & {16{(cfg_phy_a_hyst_q[3:0] == 4'b1011)}}) |
                               (16'h2000 & {16{(cfg_phy_a_hyst_q[3:0] == 4'b1100)}}) |
                               (16'h4000 & {16{(cfg_phy_a_hyst_q[3:0] == 4'b1101)}}) |
                               (16'h8000 & {16{(cfg_phy_a_hyst_q[3:0] == 4'b1110)}}) |
                               (16'hFFFF & {16{(cfg_phy_a_hyst_q[3:0] == 4'b1111)}}) ;

assign pat_a_count_high_limit = (pattern_a_count_q[15:0] == pattern_a_limit[15:0]);
assign pat_a_count_low_limit  = (pattern_a_count_q[15:0] == 16'h0000);

//-- increment count when see a pattern A and decrement when don't see it, and change state when counter reaches a limit
assign inc_pattern_a_count        = ~pat_a_count_high_limit &             //-- no increment if at high limit
                                    normal_phy_cycle & only_good_bits_q;  //-- only increment when have aligned data

assign dec_pattern_a_count        = ~pat_a_count_low_limit &              //-- no decrement if at low limit
                                    normal_phy_cycle & ~only_good_bits_q; //-- decrement for not aligned pattern A

assign pattern_a_detected_din     = pat_a_count_high_limit | (pattern_a_detected_q & ~pat_a_count_low_limit);


//-- getting only "bad" bits, is a shifted FF00, or 00FF, which is the sync (when ready for it), or could be inverted pattern B
assign inversion_rec              = only_bad_bits & ~pattern_b_detected_q & pattern_a_detected_q;  //-- if no B's yet, assume it is an inversion
//-- 3/28assign sync_received              = only_bad_bits &  pattern_b_detected_q;                         //-- if have received pattern B's, then it must be a sync
assign sync_received              = only_bad_bits & (|pattern_b_count_q[11:2]);                    //-- if have received pattern B's, then it must be a sync
assign sync_received_din          = sync_received;


//-- if get the inversion indication, make sure it is a pattern B inverted and not a sync by checking the next couple cycles
assign inv_rec1_din               = inversion_rec                 | (inv_rec1_q     & ~normal_phy_cycle);  //-- hold the indication if no data
assign inv_rec2_din               = (inv_rec1_q & only_good_bits) | (inv_rec2_q     & ~normal_phy_cycle);
assign do_inversion_din           = (inv_rec2_q & only_good_bits) | (do_inversion_q & ~normal_phy_cycle);  //-- after 2 more cycles of pattern A, then do the inversion

//-- lane is inverted after getting the inverted pattern b
assign rx_inverted_din            = rx_inverted_q ^ (do_inversion_q & normal_phy_cycle);
assign rx_inverted_async          = rx_inverted_q; //-- Cross over to phy_dl_clock domain

//-- look for 8 pattern B's
assign pattern_b_cycle1_din[15:0] = {16{normal_phy_cycle}} & pattern_B_detect1[15:0];
assign pattern_b_cycle2_din[15:0] = {16{normal_phy_cycle}} & pattern_B_detect2[15:0] & pattern_b_cycle1_q[15:0];
assign pattern_b_net_detect[15:0] = {16{normal_phy_cycle}} & pattern_B_detect3[15:0] & pattern_b_cycle2_q[15:0];  //-- any bits set are complete 3-cycle patterns

//--                                 CYCLE 1          CYCLE 2          CYCLE 3
//-- pattern_b_net_detect[15] = 11111111111111XX 00000000000000XX 111111X-000000X-
//-- pattern_b_net_detect[14] = -11111111111111X X00000000000000X X111111X-000000X
//-- pattern_b_net_detect[13] = X-11111111111111 XX00000000000000 XX111111X-000000
//-- pattern_b_net_detect[12] = 0X-1111111111111 1XX0000000000000 0XX111111X-00000
//-- pattern_b_net_detect[11] = 00X-111111111111 11XX000000000000 00XX111111X-0000
//-- pattern_b_net_detect[10] = 000X-11111111111 111XX00000000000 000XX111111X-000
//-- pattern_b_net_detect[ 9] = 0000X-1111111111 1111XX0000000000 0000XX111111X-00
//-- pattern_b_net_detect[ 8] = 00000X-111111111 11111XX000000000 00000XX111111X-0
//-- pattern_b_net_detect[ 7] = 000000X-11111111 111111XX00000000 000000XX111111X-
//-- pattern_b_net_detect[ 6] = -000000X-1111111 1111111XX0000000 0000000XX111111X
//-- pattern_b_net_detect[ 5] = X-000000X-111111 11111111XX000000 00000000XX111111
//-- pattern_b_net_detect[ 4] = 1X-000000X-11111 111111111XX00000 000000000XX11111
//-- pattern_b_net_detect[ 3] = 11X-000000X-1111 1111111111XX0000 0000000000XX1111
//-- pattern_b_net_detect[ 2] = 111X-000000X-111 11111111111XX000 00000000000XX111
//-- pattern_b_net_detect[ 1] = 1111X-000000X-11 111111111111XX00 000000000000XX11
//-- pattern_b_net_detect[ 0] = 11111X-000000X-1 1111111111111XX0 0000000000000XX1



//-- hysteresis counter for detecting pattern B
assign pattern_b_count_din[11:0] = (               pattern_b_count_q[11:0])
                                 + ({11'b00000000000, inc_pattern_b_count})
                                 - ({11'b00000000000, dec_pattern_b_count});

//-- programmable size of counter
assign pattern_b_limit[11:0]= (12'h010 & {12{(cfg_phy_b_hyst_q[3:0] == 4'b0000)}}) |
                              (12'h018 & {12{(cfg_phy_b_hyst_q[3:0] == 4'b0001)}}) |
                              (12'h020 & {12{(cfg_phy_b_hyst_q[3:0] == 4'b0010)}}) |
                              (12'h028 & {12{(cfg_phy_b_hyst_q[3:0] == 4'b0011)}}) |
                              (12'h030 & {12{(cfg_phy_b_hyst_q[3:0] == 4'b0100)}}) |
                              (12'h038 & {12{(cfg_phy_b_hyst_q[3:0] == 4'b0101)}}) |
                              (12'h040 & {12{(cfg_phy_b_hyst_q[3:0] == 4'b0110)}}) |
                              (12'h048 & {12{(cfg_phy_b_hyst_q[3:0] == 4'b0111)}}) |
                              (12'h050 & {12{(cfg_phy_b_hyst_q[3:0] == 4'b1000)}}) |
                              (12'h060 & {12{(cfg_phy_b_hyst_q[3:0] == 4'b1001)}}) |
                              (12'h080 & {12{(cfg_phy_b_hyst_q[3:0] == 4'b1010)}}) |
                              (12'h100 & {12{(cfg_phy_b_hyst_q[3:0] == 4'b1011)}}) |
                              (12'h200 & {12{(cfg_phy_b_hyst_q[3:0] == 4'b1100)}}) |
                              (12'h400 & {12{(cfg_phy_b_hyst_q[3:0] == 4'b1101)}}) |
                              (12'h800 & {12{(cfg_phy_b_hyst_q[3:0] == 4'b1110)}}) |
                              (12'hFFF & {12{(cfg_phy_b_hyst_q[3:0] == 4'b1111)}}) ;

assign pat_b_count_high_limit = (pattern_b_count_q[11:0] == pattern_b_limit[11:0]);
assign pat_b_count_low_limit  = (pattern_b_count_q[11:0] == 12'h000);

//-- increment count when see a pattern B and decrement when don't see it, and change state when counter reaches a limit
assign inc_pattern_b_count    = ~pat_b_count_high_limit &           //-- no increment if at high limit
                                 normal_phy_cycle & pattern_b_good; //-- increment for aligned pattern B

assign dec_pattern_b_count    = ~pat_b_count_low_limit &                                                    //-- no decrement if at low limit
                                 normal_phy_cycle & pattern_b_timer & pattern_b_timer_q & ~pattern_b_good;  //-- decrement for each timer tick without a pattern B

assign pattern_b_detected_din = pat_b_count_high_limit | (pattern_b_detected_q & ~pat_b_count_low_limit);

assign pattern_b_good         = pattern_a_detected_q & (pattern_b_net_detect[15:8] != 8'h00);

assign pattern_b_timer        = 1'b0; //-- 
assign pattern_b_timer_din    = (pattern_b_timer | pattern_b_timer_q) & ~pattern_b_good;  //-- reset timer after take4  it missed a pattern B


//--
//-- descrambling LFSR
//--
//-- Fibonacci LFSR PRBS-23 polynomial X^23 + X^21 + X^16 + X^8 + X^5 + X^2 + 1

assign lfsr_din[22:0] = ( ( final_lfsr1                        & {23{load_pattern1}}) |                    //-- load initial LFSR patterns
                          ( final_lfsr2                        & {23{load_pattern2}}) |                     
                          ({lfsr_next_16[15:0], lfsr_q[22:16]} & {23{lfsr_advance }}) |                    //-- advance LFSR 16 bits
                          (lfsr_q[22:0]                        & {23{~load_pattern1 & ~load_pattern2 
                                                                   & ~lfsr_advance}}) )                    //-- otherwise hold
                                                               & {23{~lfsr_unlock}};                       //-- but clear if unlocked or disabled

assign descramble[15:0] = reverse16(lfsr_q[15:0]);

assign lfsr_next_16[15] = lfsr_q[18] ^ lfsr_q[15] ^ lfsr_q[14] ^ lfsr_q[11] ^ lfsr_q[9]  ^ lfsr_q[6]  ^ lfsr_q[4]  ^ lfsr_q[3];
assign lfsr_next_16[14] = lfsr_q[17] ^ lfsr_q[14] ^ lfsr_q[13] ^ lfsr_q[10] ^ lfsr_q[8]  ^ lfsr_q[5]  ^ lfsr_q[3]  ^ lfsr_q[2];
assign lfsr_next_16[13] = lfsr_q[16] ^ lfsr_q[13] ^ lfsr_q[12] ^ lfsr_q[9]  ^ lfsr_q[7]  ^ lfsr_q[4]  ^ lfsr_q[2]  ^ lfsr_q[1];
assign lfsr_next_16[12] = lfsr_q[15] ^ lfsr_q[12] ^ lfsr_q[11] ^ lfsr_q[8]  ^ lfsr_q[6]  ^ lfsr_q[3]  ^ lfsr_q[1]  ^ lfsr_q[0];
assign lfsr_next_16[11] = lfsr_q[22] ^ lfsr_q[20] ^ lfsr_q[15] ^ lfsr_q[14] ^ lfsr_q[11] ^ lfsr_q[10] ^ lfsr_q[5]  ^ lfsr_q[4]  ^
                          lfsr_q[2]  ^ lfsr_q[1]  ^ lfsr_q[0];
assign lfsr_next_16[10] = lfsr_q[22] ^ lfsr_q[21] ^ lfsr_q[20] ^ lfsr_q[19] ^ lfsr_q[15] ^ lfsr_q[14] ^ lfsr_q[13] ^ lfsr_q[10] ^
                          lfsr_q[9]  ^ lfsr_q[7]  ^ lfsr_q[3]  ^ lfsr_q[0];
assign lfsr_next_16[ 9] = lfsr_q[22] ^ lfsr_q[21] ^ lfsr_q[19] ^ lfsr_q[18] ^ lfsr_q[15] ^ lfsr_q[14] ^ lfsr_q[13] ^ lfsr_q[12] ^
                          lfsr_q[9]  ^ lfsr_q[8]  ^ lfsr_q[7]  ^ lfsr_q[6]  ^ lfsr_q[4]  ^ lfsr_q[2]  ^ lfsr_q[1];
assign lfsr_next_16[ 8] = lfsr_q[21] ^ lfsr_q[20] ^ lfsr_q[18] ^ lfsr_q[17] ^ lfsr_q[14] ^ lfsr_q[13] ^ lfsr_q[12] ^ lfsr_q[11] ^
                          lfsr_q[8]  ^ lfsr_q[7]  ^ lfsr_q[6]  ^ lfsr_q[5]  ^ lfsr_q[3]  ^ lfsr_q[1]  ^ lfsr_q[0];
assign lfsr_next_16[ 7] = lfsr_q[22] ^ lfsr_q[19] ^ lfsr_q[17] ^ lfsr_q[16] ^ lfsr_q[15] ^ lfsr_q[13] ^ lfsr_q[12] ^ lfsr_q[11] ^
                          lfsr_q[10] ^ lfsr_q[6]  ^ lfsr_q[5]  ^ lfsr_q[2]  ^ lfsr_q[1]  ^ lfsr_q[0];
assign lfsr_next_16[ 6] = lfsr_q[22] ^ lfsr_q[21] ^ lfsr_q[20] ^ lfsr_q[18] ^ lfsr_q[16] ^ lfsr_q[14] ^ lfsr_q[12] ^ lfsr_q[11] ^
                          lfsr_q[10] ^ lfsr_q[9]  ^ lfsr_q[7]  ^ lfsr_q[5]  ^ lfsr_q[0];
assign lfsr_next_16[ 5] = lfsr_q[22] ^ lfsr_q[21] ^ lfsr_q[19] ^ lfsr_q[17] ^ lfsr_q[13] ^ lfsr_q[11] ^ lfsr_q[10] ^ lfsr_q[9]  ^
                          lfsr_q[8]  ^ lfsr_q[7]  ^ lfsr_q[6]  ^ lfsr_q[1];
assign lfsr_next_16[ 4] = lfsr_q[21] ^ lfsr_q[20] ^ lfsr_q[18] ^ lfsr_q[16] ^ lfsr_q[12] ^ lfsr_q[10] ^ lfsr_q[9]  ^ lfsr_q[8]  ^
                          lfsr_q[7]  ^ lfsr_q[6]  ^ lfsr_q[5]  ^ lfsr_q[0];
assign lfsr_next_16[ 3] = lfsr_q[22] ^ lfsr_q[19] ^ lfsr_q[17] ^ lfsr_q[11] ^ lfsr_q[9]  ^ lfsr_q[8]  ^ lfsr_q[6]  ^ lfsr_q[5]  ^ lfsr_q[1];
assign lfsr_next_16[ 2] = lfsr_q[21] ^ lfsr_q[18] ^ lfsr_q[16] ^ lfsr_q[10] ^ lfsr_q[8]  ^ lfsr_q[7]  ^ lfsr_q[5]  ^ lfsr_q[4]  ^ lfsr_q[0];
assign lfsr_next_16[ 1] = lfsr_q[22] ^ lfsr_q[17] ^ lfsr_q[9]  ^ lfsr_q[6]  ^ lfsr_q[3]  ^ lfsr_q[1];
assign lfsr_next_16[ 0] = lfsr_q[21] ^ lfsr_q[16] ^ lfsr_q[8]  ^ lfsr_q[5]  ^ lfsr_q[2]  ^ lfsr_q[0];


//-- advance LFSR for data once initialized (when LFSR loaded)
assign lfsr_advance     = input_taken & lfsr_running_q & ~lane_disabled_q;

assign lfsr_running_din = (load_pattern1 | load_pattern2 | lfsr_running_q)  //-- set when loading pattern
                           & ~lfsr_unlock;

assign lfsr_locked_din  = (lfsr_lock | lfsr_locked_q)
                           & ~lfsr_unlock;

//-- check the block to load LFSR when 6 bytes have been loaded and not already running
assign lfsr_init_check  = (read_ptr_q[1:0] ==  2'b11) & ~lfsr_running_q & input_taken;  //-- which is when last part of block is about to be loaded

//-- load the init value if get a match
assign load_pattern1    = match_pattern1 & lfsr_init_check & ~lane_disabled_q;
assign load_pattern2    = match_pattern2 & lfsr_init_check & ~lane_disabled_q;

//-- lock the LFSR if get 8 good TS in a row
assign lfsr_lock        = lfsr_running_q & Training_Count_q[3];

//-- while looking for the 8 in a row, if get a bad TS, could have falsely initialized LFSR, so unlock (but only after 2 bad TS)
assign lfsr_bad_TS_din  = (lfsr_running_q & ~lfsr_locked_q & (buffer_block_valid_q != 1'b0) & ~Any_TS_or_DM) |
                          (lfsr_bad_TS_q  & ~lfsr_unlock);

assign lfsr_unlock      = (lfsr_running_q & ~lfsr_locked_q & (buffer_block_valid_q != 1'b0) & ~Any_TS_or_DM & lfsr_bad_TS_q) | 
                           lane_disabled_q | Clear_Block_Lock | data_overflow | do_clear_lfsr;  //-- second bad TS unlocks

//-- write ptr slips to new sync header location
assign clear_lfsr_dly_din = clear_lfsr_sync;
assign do_clear_lfsr      = clear_lfsr_sync ^ clear_lfsr_dly_q;

//-- the first 6 bytes of a block received for initializing descrambling XORed with the TS pattern gives the raw PRBS sequence used for scrambling
assign raw_sequence1x[47:0] = Block_Data0[63:16] ^ 48'h4A4A_4A4A_4A4B;
assign raw_sequence2x[47:0] = Block_Data0[63:16] ^ 48'h4545_4545_454B;
//-- 5/15 assign raw_sequence1x[47:0] = Block_Data0[47:0] ^ 48'h4B4A4A4A4A4A;
//-- 5/15 assign raw_sequence2x[47:0] = Block_Data0[47:0] ^ 48'h4B4545454545;

//-- also need to put back in transmit order
assign raw_sequence1[47:0]  = {reverse16(raw_sequence1x[15: 0]), reverse16(raw_sequence1x[31:16]), reverse16(raw_sequence1x[47:32])};
assign raw_sequence2[47:0]  = {reverse16(raw_sequence2x[15: 0]), reverse16(raw_sequence2x[31:16]), reverse16(raw_sequence2x[47:32])};
//-- 5/15assign raw_sequence1[47:0]  = {reverse8(raw_sequence1x[47:40]), reverse8(raw_sequence1x[39:32]), reverse8(raw_sequence1x[31:24]),
//-- 5/15                               reverse8(raw_sequence1x[23:16]), reverse8(raw_sequence1x[15: 8]), reverse8(raw_sequence1x[7 : 0])};
//-- 5/15
//-- 5/15assign raw_sequence2[47:0]  = {reverse8(raw_sequence2x[47:40]), reverse8(raw_sequence2x[39:32]), reverse8(raw_sequence2x[31:24]),
//-- 5/15                               reverse8(raw_sequence2x[23:16]), reverse8(raw_sequence2x[15: 8]), reverse8(raw_sequence2x[7 : 0])};

//-- initial LFSR value for this block would be the first 23 bits, but reversed (last bit of LFSR sent first)
assign initial_lfsr1[22:0]  =  reverse23(raw_sequence1[47:25]);

//-- advance this LFSR 64 bits to get the final value (for the next block)
assign final_lfsr1[0]  = initial_lfsr1[20] ^ initial_lfsr1[18] ^ initial_lfsr1[16] ^ initial_lfsr1[9]  ^ initial_lfsr1[7]  ^ initial_lfsr1[4]  ^
                         initial_lfsr1[3]  ^ initial_lfsr1[2]  ^ initial_lfsr1[0];
assign final_lfsr1[1]  = initial_lfsr1[21] ^ initial_lfsr1[19] ^ initial_lfsr1[17] ^ initial_lfsr1[10] ^ initial_lfsr1[8]  ^ initial_lfsr1[5]  ^
                         initial_lfsr1[4]  ^ initial_lfsr1[3]  ^ initial_lfsr1[1];
assign final_lfsr1[2]  = initial_lfsr1[22] ^ initial_lfsr1[20] ^ initial_lfsr1[18] ^ initial_lfsr1[11] ^ initial_lfsr1[9]  ^ initial_lfsr1[6]  ^
                         initial_lfsr1[5]  ^ initial_lfsr1[4]  ^ initial_lfsr1[2];
assign final_lfsr1[3]  = initial_lfsr1[19] ^ initial_lfsr1[16] ^ initial_lfsr1[12] ^ initial_lfsr1[10] ^ initial_lfsr1[8]  ^ initial_lfsr1[7]  ^
                         initial_lfsr1[6]  ^ initial_lfsr1[3]  ^ initial_lfsr1[2]  ^ initial_lfsr1[0];
assign final_lfsr1[4]  = initial_lfsr1[20] ^ initial_lfsr1[17] ^ initial_lfsr1[13] ^ initial_lfsr1[11] ^ initial_lfsr1[9]  ^ initial_lfsr1[8]  ^
                         initial_lfsr1[7]  ^ initial_lfsr1[4]  ^ initial_lfsr1[3]  ^ initial_lfsr1[1];
assign final_lfsr1[5]  = initial_lfsr1[21] ^ initial_lfsr1[18] ^ initial_lfsr1[14] ^ initial_lfsr1[12] ^ initial_lfsr1[10] ^ initial_lfsr1[9]  ^
                         initial_lfsr1[8]  ^ initial_lfsr1[5]  ^ initial_lfsr1[4]  ^ initial_lfsr1[2];
assign final_lfsr1[6]  = initial_lfsr1[22] ^ initial_lfsr1[19] ^ initial_lfsr1[15] ^ initial_lfsr1[13] ^ initial_lfsr1[11] ^ initial_lfsr1[10] ^
                         initial_lfsr1[9]  ^ initial_lfsr1[6]  ^ initial_lfsr1[5]  ^ initial_lfsr1[3];
assign final_lfsr1[7]  = initial_lfsr1[21] ^ initial_lfsr1[20] ^ initial_lfsr1[14] ^ initial_lfsr1[12] ^ initial_lfsr1[11] ^ initial_lfsr1[10] ^
                         initial_lfsr1[8]  ^ initial_lfsr1[7]  ^ initial_lfsr1[6]  ^ initial_lfsr1[5]  ^ initial_lfsr1[4]  ^ initial_lfsr1[2]  ^ initial_lfsr1[0];
assign final_lfsr1[8]  = initial_lfsr1[22] ^ initial_lfsr1[21] ^ initial_lfsr1[15] ^ initial_lfsr1[13] ^ initial_lfsr1[12] ^ initial_lfsr1[11] ^
                         initial_lfsr1[9]  ^ initial_lfsr1[8]  ^ initial_lfsr1[7]  ^ initial_lfsr1[6]  ^ initial_lfsr1[5]  ^ initial_lfsr1[3]  ^ initial_lfsr1[1];
assign final_lfsr1[9]  = initial_lfsr1[22] ^ initial_lfsr1[21] ^ initial_lfsr1[14] ^ initial_lfsr1[13] ^ initial_lfsr1[12] ^ initial_lfsr1[10] ^
                         initial_lfsr1[9]  ^ initial_lfsr1[7]  ^ initial_lfsr1[6]  ^ initial_lfsr1[5]  ^ initial_lfsr1[4]  ^ initial_lfsr1[0];
assign final_lfsr1[10] = initial_lfsr1[22] ^ initial_lfsr1[21] ^ initial_lfsr1[16] ^ initial_lfsr1[15] ^ initial_lfsr1[14] ^ initial_lfsr1[13] ^
                         initial_lfsr1[11] ^ initial_lfsr1[10] ^ initial_lfsr1[7]  ^ initial_lfsr1[6]  ^ initial_lfsr1[2]  ^ initial_lfsr1[1]  ^ initial_lfsr1[0];
assign final_lfsr1[11] = initial_lfsr1[22] ^ initial_lfsr1[21] ^ initial_lfsr1[17] ^ initial_lfsr1[15] ^ initial_lfsr1[14] ^ initial_lfsr1[12] ^
                         initial_lfsr1[11] ^ initial_lfsr1[7]  ^ initial_lfsr1[5]  ^ initial_lfsr1[3]  ^ initial_lfsr1[1]  ^ initial_lfsr1[0];
assign final_lfsr1[12] = initial_lfsr1[22] ^ initial_lfsr1[21] ^ initial_lfsr1[18] ^ initial_lfsr1[15] ^ initial_lfsr1[13] ^ initial_lfsr1[12] ^
                         initial_lfsr1[6]  ^ initial_lfsr1[5]  ^ initial_lfsr1[4]  ^ initial_lfsr1[1]  ^ initial_lfsr1[0];
assign final_lfsr1[13] = initial_lfsr1[22] ^ initial_lfsr1[21] ^ initial_lfsr1[19] ^ initial_lfsr1[14] ^ initial_lfsr1[13] ^ initial_lfsr1[8]  ^
                         initial_lfsr1[7]  ^ initial_lfsr1[6]  ^ initial_lfsr1[1]  ^ initial_lfsr1[0];
assign final_lfsr1[14] = initial_lfsr1[22] ^ initial_lfsr1[21] ^ initial_lfsr1[20] ^ initial_lfsr1[16] ^ initial_lfsr1[15] ^ initial_lfsr1[14] ^
                         initial_lfsr1[9]  ^ initial_lfsr1[7]  ^ initial_lfsr1[5]  ^ initial_lfsr1[1]  ^ initial_lfsr1[0];
assign final_lfsr1[15] = initial_lfsr1[22] ^ initial_lfsr1[17] ^ initial_lfsr1[15] ^ initial_lfsr1[10] ^ initial_lfsr1[6]  ^ initial_lfsr1[5]  ^
                         initial_lfsr1[1]  ^ initial_lfsr1[0];
assign final_lfsr1[16] = initial_lfsr1[21] ^ initial_lfsr1[18] ^ initial_lfsr1[11] ^ initial_lfsr1[8]  ^ initial_lfsr1[7]  ^ initial_lfsr1[6]  ^
                         initial_lfsr1[5]  ^ initial_lfsr1[1]  ^ initial_lfsr1[0];
assign final_lfsr1[17] = initial_lfsr1[22] ^ initial_lfsr1[19] ^ initial_lfsr1[12] ^ initial_lfsr1[9]  ^ initial_lfsr1[8]  ^ initial_lfsr1[7]  ^
                         initial_lfsr1[6]  ^ initial_lfsr1[2]  ^ initial_lfsr1[1];
assign final_lfsr1[18] = initial_lfsr1[21] ^ initial_lfsr1[20] ^ initial_lfsr1[16] ^ initial_lfsr1[13] ^ initial_lfsr1[10] ^ initial_lfsr1[9]  ^
                         initial_lfsr1[7]  ^ initial_lfsr1[5]  ^ initial_lfsr1[3]  ^ initial_lfsr1[0];
assign final_lfsr1[19] = initial_lfsr1[22] ^ initial_lfsr1[21] ^ initial_lfsr1[17] ^ initial_lfsr1[14] ^ initial_lfsr1[11] ^ initial_lfsr1[10] ^
                         initial_lfsr1[8]  ^ initial_lfsr1[6]  ^ initial_lfsr1[4]  ^ initial_lfsr1[1];
assign final_lfsr1[20] = initial_lfsr1[22] ^ initial_lfsr1[21] ^ initial_lfsr1[18] ^ initial_lfsr1[16] ^ initial_lfsr1[15] ^ initial_lfsr1[12] ^
                         initial_lfsr1[11] ^ initial_lfsr1[9]  ^ initial_lfsr1[8]  ^ initial_lfsr1[7]  ^ initial_lfsr1[0];
assign final_lfsr1[21] = initial_lfsr1[22] ^ initial_lfsr1[21] ^ initial_lfsr1[19] ^ initial_lfsr1[17] ^ initial_lfsr1[13] ^ initial_lfsr1[12] ^
                         initial_lfsr1[10] ^ initial_lfsr1[9]  ^ initial_lfsr1[5]  ^ initial_lfsr1[2]  ^ initial_lfsr1[1]  ^ initial_lfsr1[0];
assign final_lfsr1[22] = initial_lfsr1[22] ^ initial_lfsr1[21] ^ initial_lfsr1[20] ^ initial_lfsr1[18] ^ initial_lfsr1[16] ^ initial_lfsr1[14] ^
                         initial_lfsr1[13] ^ initial_lfsr1[11] ^ initial_lfsr1[10] ^ initial_lfsr1[8]  ^ initial_lfsr1[6]  ^ initial_lfsr1[5]  ^
                         initial_lfsr1[3]  ^ initial_lfsr1[1]  ^ initial_lfsr1[0];

//-- the scramble sequence from this LFSR value (first 23 bits are the initial value of the LFSR and don't matter)
//-- matches same sequence as lfsr_next_16
//-- look at last {1'b0, 20'h4A_4A4A} to see if it matches if we would update the lfsr to the next value
//-- advance lfsr by 24
assign prbs_pattern1[47] = initial_lfsr1[21] ^ initial_lfsr1[16] ^ initial_lfsr1[8]  ^ initial_lfsr1[5]  ^ initial_lfsr1[2]  ^ initial_lfsr1[0];
//-- advance lfsr by 25
assign prbs_pattern1[46] = initial_lfsr1[22] ^ initial_lfsr1[17] ^ initial_lfsr1[9]  ^ initial_lfsr1[6]  ^ initial_lfsr1[3]  ^ initial_lfsr1[1];
//-- advance lfsr by 26
assign prbs_pattern1[45] = initial_lfsr1[21] ^ initial_lfsr1[18] ^ initial_lfsr1[16] ^ initial_lfsr1[10] ^ initial_lfsr1[8]  ^ initial_lfsr1[7]  ^
                           initial_lfsr1[5]  ^ initial_lfsr1[4]  ^ initial_lfsr1[0];
//-- advance lfsr by 27, etc.
assign prbs_pattern1[44] = initial_lfsr1[22] ^ initial_lfsr1[19] ^ initial_lfsr1[17] ^ initial_lfsr1[11] ^ initial_lfsr1[9]  ^ initial_lfsr1[8]  ^
                           initial_lfsr1[6]  ^ initial_lfsr1[5]  ^ initial_lfsr1[1];
assign prbs_pattern1[43] = initial_lfsr1[21] ^ initial_lfsr1[20] ^ initial_lfsr1[18] ^ initial_lfsr1[16] ^ initial_lfsr1[12] ^ initial_lfsr1[10] ^
                           initial_lfsr1[9]  ^ initial_lfsr1[8]  ^ initial_lfsr1[7]  ^ initial_lfsr1[6]  ^ initial_lfsr1[5]  ^ initial_lfsr1[0];
assign prbs_pattern1[42] = initial_lfsr1[22] ^ initial_lfsr1[21] ^ initial_lfsr1[19] ^ initial_lfsr1[17] ^ initial_lfsr1[13] ^ initial_lfsr1[11] ^
                           initial_lfsr1[10] ^ initial_lfsr1[9]  ^ initial_lfsr1[8]  ^ initial_lfsr1[7]  ^ initial_lfsr1[6]  ^ initial_lfsr1[1];
assign prbs_pattern1[41] = initial_lfsr1[22] ^ initial_lfsr1[21] ^ initial_lfsr1[20] ^ initial_lfsr1[18] ^ initial_lfsr1[16] ^ initial_lfsr1[14] ^
                           initial_lfsr1[12] ^ initial_lfsr1[11] ^ initial_lfsr1[10] ^ initial_lfsr1[9]  ^ initial_lfsr1[7]  ^ initial_lfsr1[5]  ^ initial_lfsr1[0];
assign prbs_pattern1[40] = initial_lfsr1[22] ^ initial_lfsr1[19] ^ initial_lfsr1[17] ^ initial_lfsr1[16] ^ initial_lfsr1[15] ^ initial_lfsr1[13] ^
                           initial_lfsr1[12] ^ initial_lfsr1[11] ^ initial_lfsr1[10] ^ initial_lfsr1[6]  ^ initial_lfsr1[5]  ^ initial_lfsr1[2]  ^
                           initial_lfsr1[1]  ^ initial_lfsr1[0];
assign prbs_pattern1[39] = initial_lfsr1[21] ^ initial_lfsr1[20] ^ initial_lfsr1[18] ^ initial_lfsr1[17] ^ initial_lfsr1[14] ^ initial_lfsr1[13] ^
                           initial_lfsr1[12] ^ initial_lfsr1[11] ^ initial_lfsr1[8]  ^ initial_lfsr1[7]  ^ initial_lfsr1[6]  ^ initial_lfsr1[5]  ^
                           initial_lfsr1[3]  ^ initial_lfsr1[1]  ^ initial_lfsr1[0];
assign prbs_pattern1[38] = initial_lfsr1[22] ^ initial_lfsr1[21] ^ initial_lfsr1[19] ^ initial_lfsr1[18] ^ initial_lfsr1[15] ^ initial_lfsr1[14] ^
                           initial_lfsr1[13] ^ initial_lfsr1[12] ^ initial_lfsr1[9]  ^ initial_lfsr1[8]  ^ initial_lfsr1[7]  ^ initial_lfsr1[6]  ^
                           initial_lfsr1[4]  ^ initial_lfsr1[2]  ^ initial_lfsr1[1];
assign prbs_pattern1[37] = initial_lfsr1[22] ^ initial_lfsr1[21] ^ initial_lfsr1[20] ^ initial_lfsr1[19] ^ initial_lfsr1[15] ^ initial_lfsr1[14] ^
                           initial_lfsr1[13] ^ initial_lfsr1[10] ^ initial_lfsr1[9]  ^ initial_lfsr1[7]  ^ initial_lfsr1[3]  ^ initial_lfsr1[0];
assign prbs_pattern1[36] = initial_lfsr1[22] ^ initial_lfsr1[20] ^ initial_lfsr1[15] ^ initial_lfsr1[14] ^ initial_lfsr1[11] ^ initial_lfsr1[10] ^
                           initial_lfsr1[5]  ^ initial_lfsr1[4]  ^ initial_lfsr1[2]  ^ initial_lfsr1[1]  ^ initial_lfsr1[0];
assign prbs_pattern1[35] = initial_lfsr1[15] ^ initial_lfsr1[12] ^ initial_lfsr1[11] ^ initial_lfsr1[8]  ^ initial_lfsr1[6]  ^ initial_lfsr1[3]  ^
                           initial_lfsr1[1]  ^ initial_lfsr1[0];
assign prbs_pattern1[34] = initial_lfsr1[16] ^ initial_lfsr1[13] ^ initial_lfsr1[12] ^ initial_lfsr1[9]  ^ initial_lfsr1[7]  ^ initial_lfsr1[4]  ^
                           initial_lfsr1[2]  ^ initial_lfsr1[1];
assign prbs_pattern1[33] = initial_lfsr1[17] ^ initial_lfsr1[14] ^ initial_lfsr1[13] ^ initial_lfsr1[10] ^ initial_lfsr1[8]  ^ initial_lfsr1[5]  ^
                           initial_lfsr1[3]  ^ initial_lfsr1[2];
assign prbs_pattern1[32] = initial_lfsr1[18] ^ initial_lfsr1[15] ^ initial_lfsr1[14] ^ initial_lfsr1[11] ^ initial_lfsr1[9]  ^ initial_lfsr1[6]  ^
                           initial_lfsr1[4]  ^ initial_lfsr1[3];
assign prbs_pattern1[31] = initial_lfsr1[19] ^ initial_lfsr1[16] ^ initial_lfsr1[15] ^ initial_lfsr1[12] ^ initial_lfsr1[10] ^ initial_lfsr1[7]  ^
                           initial_lfsr1[5]  ^ initial_lfsr1[4];
assign prbs_pattern1[30] = initial_lfsr1[20] ^ initial_lfsr1[17] ^ initial_lfsr1[16] ^ initial_lfsr1[13] ^ initial_lfsr1[11] ^ initial_lfsr1[8]  ^
                           initial_lfsr1[6]  ^ initial_lfsr1[5];
assign prbs_pattern1[29] = initial_lfsr1[21] ^ initial_lfsr1[18] ^ initial_lfsr1[17] ^ initial_lfsr1[14] ^ initial_lfsr1[12] ^ initial_lfsr1[9]  ^
                           initial_lfsr1[7]  ^ initial_lfsr1[6];
assign prbs_pattern1[28] = initial_lfsr1[22] ^ initial_lfsr1[19] ^ initial_lfsr1[18] ^ initial_lfsr1[15] ^ initial_lfsr1[13] ^ initial_lfsr1[10] ^
                           initial_lfsr1[8]  ^ initial_lfsr1[7];
assign prbs_pattern1[27] = initial_lfsr1[21] ^ initial_lfsr1[20] ^ initial_lfsr1[19] ^ initial_lfsr1[14] ^ initial_lfsr1[11] ^ initial_lfsr1[9]  ^
                           initial_lfsr1[5]  ^ initial_lfsr1[2]  ^ initial_lfsr1[0];
assign prbs_pattern1[26] = initial_lfsr1[22] ^ initial_lfsr1[21] ^ initial_lfsr1[20] ^ initial_lfsr1[15] ^ initial_lfsr1[12] ^ initial_lfsr1[10] ^
                           initial_lfsr1[6]  ^ initial_lfsr1[3]  ^ initial_lfsr1[1];
assign prbs_pattern1[25] = initial_lfsr1[22] ^ initial_lfsr1[13] ^ initial_lfsr1[11] ^ initial_lfsr1[8]  ^ initial_lfsr1[7]  ^ initial_lfsr1[5]  ^
                           initial_lfsr1[4]  ^ initial_lfsr1[0];
assign prbs_pattern1[24] = initial_lfsr1[21] ^ initial_lfsr1[16] ^ initial_lfsr1[14] ^ initial_lfsr1[12] ^ initial_lfsr1[9]  ^ initial_lfsr1[6]  ^
                           initial_lfsr1[2]  ^ initial_lfsr1[1]  ^ initial_lfsr1[0];
assign prbs_pattern1[23] = initial_lfsr1[22] ^ initial_lfsr1[17] ^ initial_lfsr1[15] ^ initial_lfsr1[13] ^ initial_lfsr1[10] ^ initial_lfsr1[7]  ^
                           initial_lfsr1[3]  ^ initial_lfsr1[2]  ^ initial_lfsr1[1];

//-- good initialization if matches
assign match_pat1[4]     = (prbs_pattern1[47:43] == raw_sequence1[24:20]);
assign match_pat1[3]     = (prbs_pattern1[42:38] == raw_sequence1[19:15]);
assign match_pat1[2]     = (prbs_pattern1[37:33] == raw_sequence1[14:10]);
assign match_pat1[1]     = (prbs_pattern1[32:28] == raw_sequence1[ 9: 5]);
assign match_pat1[0]     = (prbs_pattern1[27:23] == raw_sequence1[ 4: 0]);

assign Test_Obs[12]      = |(match_pat1[4:0]);
assign match_pattern1    = &(match_pat1[4:0]);


//-- initial LFSR value for this block would be the first 23 bits, but reversed (last bit of LFSR sent first)
assign initial_lfsr2[22:0] = reverse23(raw_sequence2[47:25]);

//-- advance this LFSR 64 bits to get the final value (for the next block)
assign final_lfsr2[ 0] = initial_lfsr2[20] ^ initial_lfsr2[18] ^ initial_lfsr2[16] ^ initial_lfsr2[9]  ^ initial_lfsr2[7]  ^ initial_lfsr2[4]  ^
                         initial_lfsr2[3]  ^ initial_lfsr2[2]  ^ initial_lfsr2[0];
assign final_lfsr2[ 1] = initial_lfsr2[21] ^ initial_lfsr2[19] ^ initial_lfsr2[17] ^ initial_lfsr2[10] ^ initial_lfsr2[8]  ^ initial_lfsr2[5]  ^
                         initial_lfsr2[4]  ^ initial_lfsr2[3]  ^ initial_lfsr2[1];
assign final_lfsr2[ 2] = initial_lfsr2[22] ^ initial_lfsr2[20] ^ initial_lfsr2[18] ^ initial_lfsr2[11] ^ initial_lfsr2[9]  ^ initial_lfsr2[6]  ^
                         initial_lfsr2[5]  ^ initial_lfsr2[4]  ^ initial_lfsr2[2];
assign final_lfsr2[ 3] = initial_lfsr2[19] ^ initial_lfsr2[16] ^ initial_lfsr2[12] ^ initial_lfsr2[10] ^ initial_lfsr2[8]  ^ initial_lfsr2[7]  ^
                         initial_lfsr2[6]  ^ initial_lfsr2[3]  ^ initial_lfsr2[2]  ^ initial_lfsr2[0];
assign final_lfsr2[ 4] = initial_lfsr2[20] ^ initial_lfsr2[17] ^ initial_lfsr2[13] ^ initial_lfsr2[11] ^ initial_lfsr2[9]  ^ initial_lfsr2[8]  ^
                         initial_lfsr2[7]  ^ initial_lfsr2[4]  ^ initial_lfsr2[3]  ^ initial_lfsr2[1];
assign final_lfsr2[ 5] = initial_lfsr2[21] ^ initial_lfsr2[18] ^ initial_lfsr2[14] ^ initial_lfsr2[12] ^ initial_lfsr2[10] ^ initial_lfsr2[9]  ^
                         initial_lfsr2[8]  ^ initial_lfsr2[5]  ^ initial_lfsr2[4]  ^ initial_lfsr2[2];
assign final_lfsr2[ 6] = initial_lfsr2[22] ^ initial_lfsr2[19] ^ initial_lfsr2[15] ^ initial_lfsr2[13] ^ initial_lfsr2[11] ^ initial_lfsr2[10] ^
                         initial_lfsr2[9]  ^ initial_lfsr2[6]  ^ initial_lfsr2[5]  ^ initial_lfsr2[3];
assign final_lfsr2[ 7] = initial_lfsr2[21] ^ initial_lfsr2[20] ^ initial_lfsr2[14] ^ initial_lfsr2[12] ^ initial_lfsr2[11] ^ initial_lfsr2[10] ^
                         initial_lfsr2[8]  ^ initial_lfsr2[7]  ^ initial_lfsr2[6]  ^ initial_lfsr2[5]  ^ initial_lfsr2[4]  ^ initial_lfsr2[2]  ^ initial_lfsr2[0];
assign final_lfsr2[ 8] = initial_lfsr2[22] ^ initial_lfsr2[21] ^ initial_lfsr2[15] ^ initial_lfsr2[13] ^ initial_lfsr2[12] ^ initial_lfsr2[11] ^
                         initial_lfsr2[9]  ^ initial_lfsr2[8]  ^ initial_lfsr2[7]  ^ initial_lfsr2[6]  ^ initial_lfsr2[5]  ^ initial_lfsr2[3]  ^ initial_lfsr2[1];
assign final_lfsr2[ 9] = initial_lfsr2[22] ^ initial_lfsr2[21] ^ initial_lfsr2[14] ^ initial_lfsr2[13] ^ initial_lfsr2[12] ^ initial_lfsr2[10] ^
                         initial_lfsr2[9]  ^ initial_lfsr2[7]  ^ initial_lfsr2[6]  ^ initial_lfsr2[5]  ^ initial_lfsr2[4]  ^ initial_lfsr2[0];
assign final_lfsr2[10] = initial_lfsr2[22] ^ initial_lfsr2[21] ^ initial_lfsr2[16] ^ initial_lfsr2[15] ^ initial_lfsr2[14] ^ initial_lfsr2[13] ^
                         initial_lfsr2[11] ^ initial_lfsr2[10] ^ initial_lfsr2[7]  ^ initial_lfsr2[6]  ^ initial_lfsr2[2]  ^ initial_lfsr2[1]  ^ initial_lfsr2[0];
assign final_lfsr2[11] = initial_lfsr2[22] ^ initial_lfsr2[21] ^ initial_lfsr2[17] ^ initial_lfsr2[15] ^ initial_lfsr2[14] ^ initial_lfsr2[12] ^
                         initial_lfsr2[11] ^ initial_lfsr2[7]  ^ initial_lfsr2[5]  ^ initial_lfsr2[3]  ^ initial_lfsr2[1]  ^ initial_lfsr2[0];
assign final_lfsr2[12] = initial_lfsr2[22] ^ initial_lfsr2[21] ^ initial_lfsr2[18] ^ initial_lfsr2[15] ^ initial_lfsr2[13] ^ initial_lfsr2[12] ^
                         initial_lfsr2[6]  ^ initial_lfsr2[5]  ^ initial_lfsr2[4]  ^ initial_lfsr2[1]  ^ initial_lfsr2[0];
assign final_lfsr2[13] = initial_lfsr2[22] ^ initial_lfsr2[21] ^ initial_lfsr2[19] ^ initial_lfsr2[14] ^ initial_lfsr2[13] ^ initial_lfsr2[8]  ^
                         initial_lfsr2[7]  ^ initial_lfsr2[6]  ^ initial_lfsr2[1]  ^ initial_lfsr2[0];
assign final_lfsr2[14] = initial_lfsr2[22] ^ initial_lfsr2[21] ^ initial_lfsr2[20] ^ initial_lfsr2[16] ^ initial_lfsr2[15] ^ initial_lfsr2[14] ^
                         initial_lfsr2[9]  ^ initial_lfsr2[7]  ^ initial_lfsr2[5]  ^ initial_lfsr2[1]  ^ initial_lfsr2[0];
assign final_lfsr2[15] = initial_lfsr2[22] ^ initial_lfsr2[17] ^ initial_lfsr2[15] ^ initial_lfsr2[10] ^ initial_lfsr2[6]  ^ initial_lfsr2[5]  ^
                         initial_lfsr2[1]  ^ initial_lfsr2[0];
assign final_lfsr2[16] = initial_lfsr2[21] ^ initial_lfsr2[18] ^ initial_lfsr2[11] ^ initial_lfsr2[8]  ^ initial_lfsr2[7]  ^ initial_lfsr2[6]  ^
                         initial_lfsr2[5]  ^ initial_lfsr2[1]  ^ initial_lfsr2[0];
assign final_lfsr2[17] = initial_lfsr2[22] ^ initial_lfsr2[19] ^ initial_lfsr2[12] ^ initial_lfsr2[9]  ^ initial_lfsr2[8]  ^ initial_lfsr2[7]  ^
                         initial_lfsr2[6]  ^ initial_lfsr2[2]  ^ initial_lfsr2[1];
assign final_lfsr2[18] = initial_lfsr2[21] ^ initial_lfsr2[20] ^ initial_lfsr2[16] ^ initial_lfsr2[13] ^ initial_lfsr2[10] ^ initial_lfsr2[9]  ^
                         initial_lfsr2[7]  ^ initial_lfsr2[5]  ^ initial_lfsr2[3]  ^ initial_lfsr2[0];
assign final_lfsr2[19] = initial_lfsr2[22] ^ initial_lfsr2[21] ^ initial_lfsr2[17] ^ initial_lfsr2[14] ^ initial_lfsr2[11] ^ initial_lfsr2[10] ^
                         initial_lfsr2[8]  ^ initial_lfsr2[6]  ^ initial_lfsr2[4]  ^ initial_lfsr2[1];
assign final_lfsr2[20] = initial_lfsr2[22] ^ initial_lfsr2[21] ^ initial_lfsr2[18] ^ initial_lfsr2[16] ^ initial_lfsr2[15] ^ initial_lfsr2[12] ^
                         initial_lfsr2[11] ^ initial_lfsr2[9]  ^ initial_lfsr2[8]  ^ initial_lfsr2[7]  ^ initial_lfsr2[0];
assign final_lfsr2[21] = initial_lfsr2[22] ^ initial_lfsr2[21] ^ initial_lfsr2[19] ^ initial_lfsr2[17] ^ initial_lfsr2[13] ^ initial_lfsr2[12] ^
                         initial_lfsr2[10] ^ initial_lfsr2[9]  ^ initial_lfsr2[5]  ^ initial_lfsr2[2]  ^ initial_lfsr2[1]  ^ initial_lfsr2[0];
assign final_lfsr2[22] = initial_lfsr2[22] ^ initial_lfsr2[21] ^ initial_lfsr2[20] ^ initial_lfsr2[18] ^ initial_lfsr2[16] ^ initial_lfsr2[14] ^
                         initial_lfsr2[13] ^ initial_lfsr2[11] ^ initial_lfsr2[10] ^ initial_lfsr2[8]  ^ initial_lfsr2[6]  ^ initial_lfsr2[5]  ^
                         initial_lfsr2[3]  ^ initial_lfsr2[1]  ^ initial_lfsr2[0];

//-- the scramble sequence from this LFSR value (first 23 bits are the initial value of the LFSR and don't matter)
assign prbs_pattern2[47] = initial_lfsr2[21] ^ initial_lfsr2[16] ^ initial_lfsr2[8]  ^ initial_lfsr2[5]  ^ initial_lfsr2[2]  ^ initial_lfsr2[0];
assign prbs_pattern2[46] = initial_lfsr2[22] ^ initial_lfsr2[17] ^ initial_lfsr2[9]  ^ initial_lfsr2[6]  ^ initial_lfsr2[3]  ^ initial_lfsr2[1];
assign prbs_pattern2[45] = initial_lfsr2[21] ^ initial_lfsr2[18] ^ initial_lfsr2[16] ^ initial_lfsr2[10] ^ initial_lfsr2[8]  ^ initial_lfsr2[7]  ^
                           initial_lfsr2[5]  ^ initial_lfsr2[4]  ^ initial_lfsr2[0];
assign prbs_pattern2[44] = initial_lfsr2[22] ^ initial_lfsr2[19] ^ initial_lfsr2[17] ^ initial_lfsr2[11] ^ initial_lfsr2[9]  ^ initial_lfsr2[8]  ^
                           initial_lfsr2[6]  ^ initial_lfsr2[5]  ^ initial_lfsr2[1];
assign prbs_pattern2[43] = initial_lfsr2[21] ^ initial_lfsr2[20] ^ initial_lfsr2[18] ^ initial_lfsr2[16] ^ initial_lfsr2[12] ^ initial_lfsr2[10] ^
                           initial_lfsr2[9]  ^ initial_lfsr2[8]  ^ initial_lfsr2[7]  ^ initial_lfsr2[6]  ^ initial_lfsr2[5]  ^ initial_lfsr2[0];
assign prbs_pattern2[42] = initial_lfsr2[22] ^ initial_lfsr2[21] ^ initial_lfsr2[19] ^ initial_lfsr2[17] ^ initial_lfsr2[13] ^ initial_lfsr2[11] ^
                           initial_lfsr2[10] ^ initial_lfsr2[9]  ^ initial_lfsr2[8]  ^ initial_lfsr2[7]  ^ initial_lfsr2[6]  ^ initial_lfsr2[1];
assign prbs_pattern2[41] = initial_lfsr2[22] ^ initial_lfsr2[21] ^ initial_lfsr2[20] ^ initial_lfsr2[18] ^ initial_lfsr2[16] ^ initial_lfsr2[14] ^
                           initial_lfsr2[12] ^ initial_lfsr2[11] ^ initial_lfsr2[10] ^ initial_lfsr2[9]  ^ initial_lfsr2[7]  ^ initial_lfsr2[5]  ^ initial_lfsr2[0];
assign prbs_pattern2[40] = initial_lfsr2[22] ^ initial_lfsr2[19] ^ initial_lfsr2[17] ^ initial_lfsr2[16] ^ initial_lfsr2[15] ^ initial_lfsr2[13] ^
                           initial_lfsr2[12] ^ initial_lfsr2[11] ^ initial_lfsr2[10] ^ initial_lfsr2[6]  ^ initial_lfsr2[5]  ^ initial_lfsr2[2]  ^
                           initial_lfsr2[1]  ^ initial_lfsr2[0];
assign prbs_pattern2[39] = initial_lfsr2[21] ^ initial_lfsr2[20] ^ initial_lfsr2[18] ^ initial_lfsr2[17] ^ initial_lfsr2[14] ^ initial_lfsr2[13] ^
                           initial_lfsr2[12] ^ initial_lfsr2[11] ^ initial_lfsr2[8]  ^ initial_lfsr2[7]  ^ initial_lfsr2[6]  ^ initial_lfsr2[5]  ^
                           initial_lfsr2[3]  ^ initial_lfsr2[1]  ^ initial_lfsr2[0];
assign prbs_pattern2[38] = initial_lfsr2[22] ^ initial_lfsr2[21] ^ initial_lfsr2[19] ^ initial_lfsr2[18] ^ initial_lfsr2[15] ^ initial_lfsr2[14] ^
                           initial_lfsr2[13] ^ initial_lfsr2[12] ^ initial_lfsr2[9]  ^ initial_lfsr2[8]  ^ initial_lfsr2[7]  ^ initial_lfsr2[6]  ^
                           initial_lfsr2[4]  ^ initial_lfsr2[2]  ^ initial_lfsr2[1];
assign prbs_pattern2[37] = initial_lfsr2[22] ^ initial_lfsr2[21] ^ initial_lfsr2[20] ^ initial_lfsr2[19] ^ initial_lfsr2[15] ^ initial_lfsr2[14] ^
                           initial_lfsr2[13] ^ initial_lfsr2[10] ^ initial_lfsr2[9]  ^ initial_lfsr2[7]  ^ initial_lfsr2[3]  ^ initial_lfsr2[0];
assign prbs_pattern2[36] = initial_lfsr2[22] ^ initial_lfsr2[20] ^ initial_lfsr2[15] ^ initial_lfsr2[14] ^ initial_lfsr2[11] ^ initial_lfsr2[10] ^
                           initial_lfsr2[5]  ^ initial_lfsr2[4]  ^ initial_lfsr2[2]  ^ initial_lfsr2[1]  ^ initial_lfsr2[0];
assign prbs_pattern2[35] = initial_lfsr2[15] ^ initial_lfsr2[12] ^ initial_lfsr2[11] ^ initial_lfsr2[8]  ^ initial_lfsr2[6]  ^ initial_lfsr2[3]  ^
                           initial_lfsr2[1]  ^ initial_lfsr2[0];
assign prbs_pattern2[34] = initial_lfsr2[16] ^ initial_lfsr2[13] ^ initial_lfsr2[12] ^ initial_lfsr2[9]  ^ initial_lfsr2[7]  ^ initial_lfsr2[4]  ^
                           initial_lfsr2[2]  ^ initial_lfsr2[1];
assign prbs_pattern2[33] = initial_lfsr2[17] ^ initial_lfsr2[14] ^ initial_lfsr2[13] ^ initial_lfsr2[10] ^ initial_lfsr2[8]  ^ initial_lfsr2[5]  ^
                           initial_lfsr2[3]  ^ initial_lfsr2[2];
assign prbs_pattern2[32] = initial_lfsr2[18] ^ initial_lfsr2[15] ^ initial_lfsr2[14] ^ initial_lfsr2[11] ^ initial_lfsr2[9]  ^ initial_lfsr2[6]  ^
                           initial_lfsr2[4]  ^ initial_lfsr2[3];
assign prbs_pattern2[31] = initial_lfsr2[19] ^ initial_lfsr2[16] ^ initial_lfsr2[15] ^ initial_lfsr2[12] ^ initial_lfsr2[10] ^ initial_lfsr2[7]  ^
                           initial_lfsr2[5]  ^ initial_lfsr2[4];
assign prbs_pattern2[30] = initial_lfsr2[20] ^ initial_lfsr2[17] ^ initial_lfsr2[16] ^ initial_lfsr2[13] ^ initial_lfsr2[11] ^ initial_lfsr2[8]  ^
                           initial_lfsr2[6]  ^ initial_lfsr2[5];
assign prbs_pattern2[29] = initial_lfsr2[21] ^ initial_lfsr2[18] ^ initial_lfsr2[17] ^ initial_lfsr2[14] ^ initial_lfsr2[12] ^ initial_lfsr2[9]  ^
                           initial_lfsr2[7]  ^ initial_lfsr2[6];
assign prbs_pattern2[28] = initial_lfsr2[22] ^ initial_lfsr2[19] ^ initial_lfsr2[18] ^ initial_lfsr2[15] ^ initial_lfsr2[13] ^ initial_lfsr2[10] ^
                           initial_lfsr2[8]  ^ initial_lfsr2[7];
assign prbs_pattern2[27] = initial_lfsr2[21] ^ initial_lfsr2[20] ^ initial_lfsr2[19] ^ initial_lfsr2[14] ^ initial_lfsr2[11] ^ initial_lfsr2[9]  ^
                           initial_lfsr2[5]  ^ initial_lfsr2[2]  ^ initial_lfsr2[0];
assign prbs_pattern2[26] = initial_lfsr2[22] ^ initial_lfsr2[21] ^ initial_lfsr2[20] ^ initial_lfsr2[15] ^ initial_lfsr2[12] ^ initial_lfsr2[10] ^
                           initial_lfsr2[6]  ^ initial_lfsr2[3]  ^ initial_lfsr2[1];
assign prbs_pattern2[25] = initial_lfsr2[22] ^ initial_lfsr2[13] ^ initial_lfsr2[11] ^ initial_lfsr2[8]  ^ initial_lfsr2[7]  ^ initial_lfsr2[5]  ^
                           initial_lfsr2[4]  ^ initial_lfsr2[0];
assign prbs_pattern2[24] = initial_lfsr2[21] ^ initial_lfsr2[16] ^ initial_lfsr2[14] ^ initial_lfsr2[12] ^ initial_lfsr2[9]  ^ initial_lfsr2[6]  ^
                           initial_lfsr2[2]  ^ initial_lfsr2[1]  ^ initial_lfsr2[0];
assign prbs_pattern2[23] = initial_lfsr2[22] ^ initial_lfsr2[17] ^ initial_lfsr2[15] ^ initial_lfsr2[13] ^ initial_lfsr2[10] ^ initial_lfsr2[7]  ^
                           initial_lfsr2[3]  ^ initial_lfsr2[2]  ^ initial_lfsr2[1];

//-- good initialization if matches
assign match_pat2[4]     = (prbs_pattern2[47:43] == raw_sequence2[24:20]);
assign match_pat2[3]     = (prbs_pattern2[42:38] == raw_sequence2[19:15]);
assign match_pat2[2]     = (prbs_pattern2[37:33] == raw_sequence2[14:10]);
assign match_pat2[1]     = (prbs_pattern2[32:28] == raw_sequence2[ 9: 5]);
assign match_pat2[0]     = (prbs_pattern2[27:23] == raw_sequence2[ 4: 0]);

assign Test_Obs[11]      = |(match_pat2[4:0]);
assign match_pattern2    = &(match_pat2[4:0]);

assign Test_Obs[10]      = 1'b0;

//--
//-- Deskew Buffer
//--

//-- separate selected data into data and sync headers (and apply error injection)
assign input_sync_hdr[1:0] = selected_data_raw[17:16];
assign selected_data[15:0] = selected_data_raw[15: 0] ^ descramble[15:0];                               

//-- reorder the 2 bytes (they are transmitted LSB first)
assign input_data[15:0]    = {selected_data[0], selected_data[1], selected_data[2],  selected_data[3],  selected_data[4],  selected_data[5],  selected_data[6],  selected_data[7],
                              selected_data[8], selected_data[9], selected_data[10], selected_data[11], selected_data[12], selected_data[13], selected_data[14], selected_data[15]};
//-- 5/15assign input_data[15:0]    = {selected_data[8], selected_data[9], selected_data[10], selected_data[11], selected_data[12], selected_data[13], selected_data[14], selected_data[15],
//-- 5/15                              selected_data[0], selected_data[1], selected_data[2],  selected_data[3],  selected_data[4],  selected_data[5],  selected_data[6],  selected_data[7]};

assign write_deskew_data       = input_taken & (read_ptr_q[1:0] == 2'b00);

assign deskew_sync0_din[1:0]   = (input_sync_hdr[1:0]   & { 2{ write_deskew_data}}) |
                                 (deskew_sync0_q[1:0]   & { 2{~write_deskew_data}});

assign deskew_data00_din[15:0] = (deskew_data01_q[15:0] & {16{ input_taken}}) |
                                 (deskew_data00_q[15:0] & {16{~input_taken}});
                                                                                   
assign deskew_data01_din[15:0] = (deskew_data02_q[15:0] & {16{ input_taken}}) |
                                 (deskew_data01_q[15:0] & {16{~input_taken}});
                                                                                   
assign deskew_data02_din[15:0] = (deskew_data03_q[15:0] & {16{ input_taken}}) |
                                 (deskew_data02_q[15:0] & {16{~input_taken}});
                                                                                   
assign deskew_data03_din[15:0] = (input_data[15:0]      & {16{ input_taken}}) |
                                 (deskew_data03_q[15:0] & {16{~input_taken}});


//--
//-- Deskew control
//--
assign ln_deskew_valid         = Deskew_Valid_q;

//--                            Example Timing Diagram:
//--
//-- After 1st rising edge of ln_all_valid, all lanes are deskewed
//-- 
//-- ln_all_valid        ____________________|^^^^^^^^^^^^^^^^^^^^^^^|_|^^^^^^^^^^^^^^ 
//-- 
//-- ln0_valid          ^^^|_|^^^^^^^^^^^|___|^^^^^^^^^^^^^^^^^^^^^^^|_|^^^^^^^^^^^^^^
//-- 
//-- ln1_valid          ^^^|_|^^^^^^^^^^^|___|^^^^^^^^^^^^^^^^^^^^^^^|_|^^^^^^^^^^^^^^
//-- 
//-- ln6_valid          ^^^^^^^^^^^^|_|^^^^|_|^^^^^^^^^^^^^^^^^^^^^^^|_|^^^^^^^^^^^^^^
//--                  
//-- NOTE: ln0/ln1 are faster than ln6 in this example, so they have a longer 
//--       pause before rising edge of ln_all_valid

//-- need to hold all lanes once THIS lane doesn't have enough data to read
//-- However, only do this when we enable deskew and after the inital pause to deskew all the lanes (indicated by ln_all_valid)  
assign ln_deskew_hold       = (valid_data & ~lane_disabled_q) & ln_deskew_enable;
assign ln_valid             = valid_data;
assign ln_data[15:0]        = input_data[15:0];
assign ln_trn_data[15:0]    = deskew_data03_q[15:0]; //-- data delayed a cycle to reduce fanout from main data path
assign ln_parity[1:0]       = data_parity[1:0];
//-- even parity generation per byte
assign data_parity[1]       = ^input_data[15:8];
assign data_parity[0]       = ^input_data[ 7:0];

assign deskew_found_dly_din = DM_Valid & Block_Lock_q & ~valid_data;
assign ln_deskew_found      = (DM_Valid & Block_Lock_q & valid_data) | (deskew_found_dly_q);
assign Deskew_Valid_din     = (Deskew_Valid_q | (ln_deskew_enable & ((DM_Valid & Block_Lock_q & valid_data) | (deskew_found_dly_q))))   //-- set when a deskew marker is found
                               & ~(reset_deskew_q | data_overflow);

//-- make faster lane(s) wait the same cycle as the slowest lane(s) only after THIS lane finds deskew pattern
assign all_lanes_valid      = (Deskew_Valid_q & ln_all_valid) | ~Deskew_Valid_q;

//-- net results, and only do things when the input has enough data (if not enough data, dead cycle and next cycle will do it)
assign input_taken          = valid_data & all_lanes_valid;



//-- ****************
//-- Block lock state machine
//-- ****************

assign Block_Lock_din = Set_Block_Lock | (Block_Lock_q & ~Clear_Block_Lock);


assign sh_count_grid_din[5:0] =
           ( ((sh_count_grid_q[5:0] + 6'b000001)  & {6{ inc_SH_count}}) |
             ( sh_count_grid_q[5:0]               & {6{~inc_SH_count}}) ) & {6{~Clear_SH_counts}};

assign SH_invalid_count_din[3:0] = 
           ( ((SH_invalid_count_q[3:0] + 4'b0001) & {4{ inc_SH_invalid_count}}) |
             ( SH_invalid_count_q[3:0]            & {4{~inc_SH_invalid_count}}) ) & {4{~Clear_SH_counts}};

//-- only state variable is Block_Lock (locked and unlocked states), the slip and reset_count states are handled without additional cycles
//-- the block_pos_q is 0 when a sync header is present to be tested, if it is non-zero, the rest of the block is read in
//-- so either mid block or there is a sync header to test, see if valid or not
assign start_of_deskew_block   = check_EDPL_q;
assign mid_block               = ~start_of_deskew_block;
assign SH_valid                =  start_of_deskew_block & ts_training & (deskew_sync0_q[1:0] == 2'b10);

//-- Only count bad SH when EDPL is off.  Link retraining will clear block lock
assign SH_invalid              = start_of_deskew_block & ts_training & (deskew_sync0_q[1:0] != 2'b10);

//-- what is done with the sync header depends on being locked or not
//-- when not locked, valid sync header, increment SH count, and if got 64th valid sync header, set locked (invalid, slip)
assign unlocked_inc_SH_count   = ~Block_Lock_q & SH_valid;
assign unlocked_Set_Block_Lock = ~Block_Lock_q & SH_valid & (sh_count_grid_q[5:0] == 6'b111111);  //-- count = 63, have 64th (count gets reset)

//-- when locked, count all sync headers and for invalid, the invalid count.  Only count invalid headers when receiving TSX Data.
//-- EDPL causes all combinations of headers except for 2'b10.
assign locked_inc_SH_count         = Block_Lock_q & ~mid_block;                                                       //-- any SH (valid or ~) increment SH count
assign locked_reset_counts         = Block_Lock_q & ~mid_block  & (sh_count_grid_q[5:0] == 6'b111111);                //-- reset counts on 64th
assign locked_inc_SH_invalid_count = Block_Lock_q & ts_training & SH_invalid;  
assign locked_Clear_Block_Lock     = Block_Lock_q & ts_training & SH_invalid & (SH_invalid_count_q[3:0] == 4'b1111);  //-- count 15, got 16th invalid

assign Set_Block_Lock       = buffer_has_16 & unlocked_Set_Block_Lock;
assign Clear_Block_Lock     = ~phy_training_q & locked_Clear_Block_Lock;   //-- other reasons to loose block lock???
assign Clear_BL_toggle_din  = Clear_Block_Lock ^ Clear_BL_toggle_q;
assign Clear_BL_async       = Clear_BL_toggle_q;

assign inc_SH_invalid_count = buffer_has_16 & locked_inc_SH_invalid_count;
assign inc_SH_count         = buffer_has_16 & (unlocked_inc_SH_count | locked_inc_SH_count);

assign Clear_SH_counts      = Set_Block_Lock | (locked_reset_counts & buffer_has_16) | Clear_Block_Lock;


//-- ****************
//-- Control Block decode
//-- ****************
//-- assign Block_Data0[63:0] = {deskew_data00_q[15:0], deskew_data01_q[15:0], deskew_data02_q[15:0], deskew_data03_q[15:0]};
assign Block_Data0[63:0] = {deskew_data03_q[15:0], deskew_data02_q[15:0], deskew_data01_q[15:0], deskew_data00_q[15:0]};

assign Dec0_TS1[6]  = (Block_Data0[63:56] == 8'h4A); 
assign Dec0_TS1[5]  = (Block_Data0[55:48] == 8'h4A);
assign Dec0_TS1[4]  = (Block_Data0[47:40] == 8'h4A);
assign Dec0_TS1[3]  = (Block_Data0[39:32] == 8'h4A);
assign Dec0_TS1[2]  = (Block_Data0[31:24] == 8'h4A);
assign Dec0_TS1[1]  = (Block_Data0[23:16] == 8'h4A);
assign Dec0_TS1[0]  = (Block_Data0[15: 8] == 8'h4A);

assign Test_Obs[9]  = |Dec0_TS1;
assign Decode0_TS1  = &Dec0_TS1;

assign Dec0_TS2[5]  = (Block_Data0[47:40] == 8'h45);
assign Dec0_TS2[4]  = (Block_Data0[39:32] == 8'h45);
assign Dec0_TS2[3]  = (Block_Data0[31:24] == 8'h45);
assign Dec0_TS2[2]  = (Block_Data0[23:16] == 8'h45);
assign Dec0_TS2[1]  = (Block_Data0[15: 8] == 8'h45);
assign Dec0_TS2[0]  = 1'b1;

assign Test_Obs[8]  = |Dec0_TS2;
assign Decode0_TS2  = &Dec0_TS2;

assign Dec0_TS3[5]  = (Block_Data0[47:40] == 8'h41);
assign Dec0_TS3[4]  = (Block_Data0[39:32] == 8'h41);
assign Dec0_TS3[3]  = (Block_Data0[31:24] == 8'h41);
assign Dec0_TS3[2]  = (Block_Data0[23:16] == 8'h41);
assign Dec0_TS3[1]  = (Block_Data0[15: 8] == 8'h41);
assign Dec0_TS3[0]  = 1'b1;
                    
assign Test_Obs[7]  = |Dec0_TS3;
assign Decode0_TS3  = &Dec0_TS3;

assign Test_Obs[6]  = 1'b0;

assign Dec0_DM[4]   = (Block_Data0[39:32] == 8'h1E);
assign Dec0_DM[3]   = (Block_Data0[31:24] == 8'h1E);
assign Dec0_DM[2]   = (Block_Data0[23:16] == 8'h1E);
assign Dec0_DM[1]   = (Block_Data0[15: 8] == 8'h1E);
assign Dec0_DM[0]   = 1'b1;

assign Test_Obs[5]  = |Dec0_DM;
assign Decode0_DM   = &Dec0_DM;


//-- a training set has been received
assign TS1_Valid = (buffer_block_valid_q & Decode0_TS1);
assign TS2_Valid = (buffer_block_valid_q & Decode0_TS2);
assign TS3_Valid = (buffer_block_valid_q & Decode0_TS3);
assign DM_Valid  = (buffer_block_valid_q & Decode0_DM);

//-- Inserted for testability
assign TS1_Valid_din = TS1_Valid;
assign TS2_Valid_din = TS2_Valid;
assign TS3_Valid_din = TS3_Valid;
assign DM_Valid_din  = DM_Valid;

assign Any_TS = TS1_Valid | TS2_Valid | TS3_Valid;

assign Any_TS_or_DM = Any_TS | DM_Valid;

//-- training set data from TS Byte 0
assign TS_Data[7:0] = Block_Data0[55:48] & {8{buffer_block_valid_q}};



//--
//-- training set counter
//--

//-- currently received a training set (or 0 if none)
//-- Receiving a DM shouldn't reset the training count
assign current_training_type[1:0] = (2'b01                & {2{TS1_Valid}}) |
                                    (2'b10                & {2{TS2_Valid}}) |
                                    (2'b11                & {2{TS3_Valid}}) |
                                    (Training_Type_q[1:0] & {2{DM_Valid }});

//-- save the new training type
assign Training_Type_din[1:0] = (current_training_type[1:0] & {2{buffer_block_valid_q != 1'b0}}) |
                                (Training_Type_q[1:0]       & {2{buffer_block_valid_q == 1'b0}});

assign Training_Data_din[7:0] = (TS_Data[7:0]         & {8{ Any_TS}}) |
                                (Training_Data_q[7:0] & {8{~Any_TS}});

//-- it matches the previous one
assign current_matches_last = (current_training_type[1:0] == Training_Type_q[1:0]) & (TS_Data[7:0] == Training_Data_q[7:0]);

//-- cases for counter:
//-- receiving a training set that matches the last one, increment
//-- Receiving a DM shouldn't reset the training count
assign increment_training_count = ((Any_TS & current_matches_last) | DM_Valid) & (buffer_block_valid_q != 1'b0);

//-- receiving a training set that does not match the last one, set count to 1
assign load_1_training_count    = Any_TS & ~current_matches_last & (buffer_block_valid_q != 1'b0);

//-- if neither of the above, not receiving a training packet, clear counter
assign Training_Count_din[3:0]  = (Training_Count_Inc[3:0] & {4{increment_training_count}}) |
                                  (4'b0001                 & {4{load_1_training_count}})    |
                                  (Training_Count_q[3:0]   & {4{(buffer_block_valid_q == 1'b0)}});


//-- counter saturates at 8
assign Training_Count_Inc[3:0] = ( 4'b1000                     & {4{ Training_Count_q[3]}}) |
                                 ((Training_Count_q + 4'b0001) & {4{~Training_Count_q[3]}});


//-- also count data markers that match for lane number
assign increment_DM_count = DM_Valid & (TS_Data[7:0] == DM_Data_q[7:0]);  //-- increment when data matches
assign load_1_DM_count    = DM_Valid & (TS_Data[7:0] != DM_Data_q[7:0]);  //-- otherwise load 1

assign DM_Count_din[3:0] = (DM_Count_Inc[3:0] & {4{ increment_DM_count}}) |
                           (4'b0001           & {4{ load_1_DM_count}})    |
                           (DM_Count_q[3:0]   & {4{~DM_Valid}});  


//-- counter saturates at 8
assign DM_Count_Inc[3:0] = ( 4'b1000                    & {4{ DM_Count_q[3]}}) |
                           ((DM_Count_q[3:0] + 4'b0001) & {4{~DM_Count_q[3]}});

//-- save the value
assign DM_Data_din[7:0] = (TS_Data[7:0]   & {8{ DM_Valid}}) |
                          (DM_Data_q[7:0] & {8{~DM_Valid}});


//-- spare latches on phy_dl_clock;
assign spare_00_phy_din = spare_01_phy_q;
assign spare_01_phy_din = spare_00_phy_q;

//-- spare latches on dl_clk
assign spare_00_din = spare_07_q | OC_endpoint | buffer_reset | (|slow_raw_data) | (|pattern_b_net_detect) |
                      (|Block_Data0[7:0]) | ln_retrain; //-- : connect sinkless nets
assign spare_01_din = spare_00_q;
assign spare_02_din = spare_01_q;
assign spare_03_din = spare_02_q;
assign spare_04_din = spare_03_q;
assign spare_05_din = spare_04_q;
assign spare_06_din = spare_05_q;
assign spare_07_din = spare_06_q;

//-- pb_iool_rx_lane_main.vhdl --end
assign dl_reset_n_din = rx_reset_n;

//-- async cross dl_clk --> phy_dl_clock
dlc_async  BEI_inject             (.clk(phy_dl_clock), .din(BEI_inject_async  ), .q(BEI_inject_sync  ));
dlc_async  slip_left              (.clk(phy_dl_clock), .din(slip_left_async   ), .q(slip_left_sync   ));
dlc_async  slip_right             (.clk(phy_dl_clock), .din(slip_right_async  ), .q(slip_right_sync  ));
dlc_async  phy_training_sync2     (.clk(phy_dl_clock), .din(phy_training_async), .q(phy_training_sync));
dlc_async  rx_inverted_phy_sync   (.clk(phy_dl_clock), .din(rx_inverted_async ), .q(rx_inverted_sync ));
dlc_async  ena_phy_sync           (.clk(phy_dl_clock), .din(omi_enable        ), .q(enable_phy       ));
dlc_async  reset_n_phy_sync       (.clk(phy_dl_clock), .din(dl_reset_n_q      ), .q(rx_reset_n_phy   ));
dlc_async  phy_dl_iobist_rst      (.clk(phy_dl_clock), .din(phy_dl_iobist_reset), .q(iobist_reset    ));
dlc_async  Clear_BL_asy           (.clk(phy_dl_clock), .din(Clear_BL_async    ), .q(Clear_BL_sync    ));

//-- async cross phy_dl_clock --> dl_clk
dlc_async  toggle_async0     (.clk(dl_clk), .din(data_toggle[0]),  .q(sync_data_toggle[0]));
dlc_async  toggle_async1     (.clk(dl_clk), .din(data_toggle[1]),  .q(sync_data_toggle[1]));
dlc_async  toggle_async2     (.clk(dl_clk), .din(data_toggle[2]),  .q(sync_data_toggle[2]));
dlc_async  toggle_async3     (.clk(dl_clk), .din(data_toggle[3]),  .q(sync_data_toggle[3]));
dlc_async  toggle_async4     (.clk(dl_clk), .din(data_toggle[4]),  .q(sync_data_toggle[4]));
dlc_async  toggle_async5     (.clk(dl_clk), .din(data_toggle[5]),  .q(sync_data_toggle[5]));
dlc_async  toggle_async6     (.clk(dl_clk), .din(data_toggle[6]),  .q(sync_data_toggle[6]));
dlc_async  toggle_async7     (.clk(dl_clk), .din(data_toggle[7]),  .q(sync_data_toggle[7]));
dlc_async  iobist_prbs_err   (.clk(dl_clk), .din(iobist_prbs_error), .q(rx_tx_iobist_prbs_error));
dlc_async  clear_lfsr        (.clk(dl_clk), .din(clear_lfsr_async), .q(clear_lfsr_sync));

assign reset_phy = global_reset_control ? rx_reset_n_phy : ~chip_reset;
assign reset     = global_reset_control ? dl_reset_n_q   : ~chip_reset; 
//-- phy_dl_clock flip flops
dlc_ff_spare #(.width(  1) ,.rstv({ 1{1'b0}})) ff_spare_00_phy         (.clk(phy_dl_clock)  ,.reset_n(reset_phy)    ,.enable(enable_phy )    ,.din(spare_00_phy_din       )   ,.q(spare_00_phy_q       ) );
dlc_ff_spare #(.width(  1) ,.rstv({ 1{1'b0}})) ff_spare_01_phy         (.clk(phy_dl_clock)  ,.reset_n(reset_phy)    ,.enable(enable_phy )    ,.din(spare_01_phy_din       )   ,.q(spare_01_phy_q       ) );
dlc_ff_spare #(.width(  1) ,.rstv({ 1{1'b0}})) ff_spare_cfg_phy        (.clk(phy_dl_clock)  ,.reset_n(reset_phy)    ,.enable(enable_phy )    ,.din(spare_cfg_phy_din      )   ,.q(spare_cfg_phy_q      ) );
dlc_ff       #(.width(  7) ,.rstv({ 7{1'b0}})) ff_sh_count_phy         (.clk(phy_dl_clock)  ,.reset_n(reset_phy)    ,.enable(enable_phy )    ,.din(sh_count_din           )   ,.q(sh_count_q           ) );
dlc_ff       #(.width(  1) ,.rstv({ 1{1'b0}})) ff_write_ptr_overflow   (.clk(phy_dl_clock)  ,.reset_n(reset_phy)    ,.enable(enable_phy )    ,.din(write_ptr_overflow_din )   ,.q(write_ptr_overflow_q ) );
dlc_ff       #(.width(  1) ,.rstv({ 1{1'b0}})) ff_slip_left_dly        (.clk(phy_dl_clock)  ,.reset_n(reset_phy)    ,.enable(enable_phy )    ,.din(slip_left_dly_din      )   ,.q(slip_left_dly_q      ) );
dlc_ff       #(.width(  1) ,.rstv({ 1{1'b0}})) ff_slip_right_dly       (.clk(phy_dl_clock)  ,.reset_n(reset_phy)    ,.enable(enable_phy )    ,.din(slip_right_dly_din     )   ,.q(slip_right_dly_q     ) );
dlc_ff       #(.width(  1) ,.rstv({ 1{1'b0}})) ff_rx_inverted_dly      (.clk(phy_dl_clock)  ,.reset_n(reset_phy)    ,.enable(enable_phy )    ,.din(rx_inverted_dly_din    )   ,.q(rx_inverted_dly_q    ) );
dlc_ff       #(.width(  1) ,.rstv({ 1{1'b0}})) ff_block_num            (.clk(phy_dl_clock)  ,.reset_n(reset_phy)    ,.enable(enable_phy )    ,.din(block_num_din          )   ,.q(block_num_q          ) );
dlc_ff       #(.width(  2) ,.rstv({ 2{1'b0}})) ff_block_pos            (.clk(phy_dl_clock)  ,.reset_n(reset_phy)    ,.enable(enable_phy )    ,.din(block_pos_din          )   ,.q(block_pos_q          ) );
dlc_ff       #(.width(  5) ,.rstv({ 5{1'b0}})) ff_write_ptr            (.clk(phy_dl_clock)  ,.reset_n(reset_phy)    ,.enable(enable_phy )    ,.din(write_ptr_din          )   ,.q(write_ptr_q          ) );
dlc_ff       #(.width( 17) ,.rstv({17{1'b0}})) ff_phy_dl_lane_d0       (.clk(phy_dl_clock)  ,.reset_n(reset_phy)    ,.enable(act_lane_d0)    ,.din(phy_dl_lane_d0_din     )   ,.q(phy_dl_lane_d0_q     ) );
dlc_ff       #(.width(  7) ,.rstv({ 7{1'b0}})) ff_slip_cntr            (.clk(phy_dl_clock)  ,.reset_n(reset_phy)    ,.enable(enable_phy )    ,.din(slip_cntr_din          )   ,.q(slip_cntr_q          ) );
dlc_ff       #(.width(  1) ,.rstv({ 1{1'b0}})) ff_BEI_inject_dly       (.clk(phy_dl_clock)  ,.reset_n(reset_phy)    ,.enable(enable_phy )    ,.din(BEI_inject_dly_din     )   ,.q(BEI_inject_dly_q     ) );
dlc_ff       #(.width(  1) ,.rstv({ 1{1'b0}})) ff_BEI_inject_edge_dly  (.clk(phy_dl_clock)  ,.reset_n(reset_phy)    ,.enable(enable_phy )    ,.din(BEI_inject_edge_dly_din)   ,.q(BEI_inject_edge_dly_q) );
dlc_ff       #(.width(  1) ,.rstv({ 1{1'b0}})) ff_not_BL_dly           (.clk(phy_dl_clock)  ,.reset_n(reset_phy)    ,.enable(enable_phy )    ,.din(not_BL_dly_din         )   ,.q(not_BL_dly_q         ) );
dlc_ff       #(.width(  1) ,.rstv({ 1{1'b0}})) ff_clear_lfsr_toggle    (.clk(phy_dl_clock)  ,.reset_n(reset_phy)    ,.enable(enable_phy )    ,.din(clear_lfsr_toggle_din  )   ,.q(clear_lfsr_toggle_q  ) );


dlc_ff       #(.width(  2) ,.rstv({ 2{1'b0}})) ff_block0_hdr           (.clk(phy_dl_clock)  ,.reset_n(reset_phy)    ,.enable(act_block0_0)    ,.din(block0_hdr_din        )   ,.q(block0_hdr_q         ) );
dlc_ff       #(.width(  2) ,.rstv({ 2{1'b0}})) ff_block1_hdr           (.clk(phy_dl_clock)  ,.reset_n(reset_phy)    ,.enable(act_block1_0)    ,.din(block1_hdr_din        )   ,.q(block1_hdr_q         ) );
dlc_ff       #(.width( 16) ,.rstv({16{1'b0}})) ff_block0_0             (.clk(phy_dl_clock)  ,.reset_n(reset_phy)    ,.enable(act_block0_0)    ,.din(block0_0_din          )   ,.q(block0_0_q           ) );
dlc_ff       #(.width( 16) ,.rstv({16{1'b0}})) ff_block0_1             (.clk(phy_dl_clock)  ,.reset_n(reset_phy)    ,.enable(act_block0_1)    ,.din(block0_1_din          )   ,.q(block0_1_q           ) );
dlc_ff       #(.width( 16) ,.rstv({16{1'b0}})) ff_block0_2             (.clk(phy_dl_clock)  ,.reset_n(reset_phy)    ,.enable(act_block0_2)    ,.din(block0_2_din          )   ,.q(block0_2_q           ) );
dlc_ff       #(.width( 16) ,.rstv({16{1'b0}})) ff_block0_3             (.clk(phy_dl_clock)  ,.reset_n(reset_phy)    ,.enable(act_block0_3)    ,.din(block0_3_din          )   ,.q(block0_3_q           ) );
dlc_ff       #(.width( 16) ,.rstv({16{1'b0}})) ff_block1_0             (.clk(phy_dl_clock)  ,.reset_n(reset_phy)    ,.enable(act_block1_0)    ,.din(block1_0_din          )   ,.q(block1_0_q           ) );
dlc_ff       #(.width( 16) ,.rstv({16{1'b0}})) ff_block1_1             (.clk(phy_dl_clock)  ,.reset_n(reset_phy)    ,.enable(act_block1_1)    ,.din(block1_1_din          )   ,.q(block1_1_q           ) );
dlc_ff       #(.width( 16) ,.rstv({16{1'b0}})) ff_block1_2             (.clk(phy_dl_clock)  ,.reset_n(reset_phy)    ,.enable(act_block1_2)    ,.din(block1_2_din          )   ,.q(block1_2_q           ) );
dlc_ff       #(.width( 16) ,.rstv({16{1'b0}})) ff_block1_3             (.clk(phy_dl_clock)  ,.reset_n(reset_phy)    ,.enable(act_block1_3)    ,.din(block1_3_din          )   ,.q(block1_3_q           ) );
dlc_ff       #(.width(  1) ,.rstv({ 1{1'b0}})) ff_toggle0_t0           (.clk(phy_dl_clock)  ,.reset_n(reset_phy)    ,.enable(act_block0_0)    ,.din(toggle0_t0_din        )   ,.q(toggle0_t0_q         ) );
dlc_ff       #(.width(  1) ,.rstv({ 1{1'b0}})) ff_toggle1_t1           (.clk(phy_dl_clock)  ,.reset_n(reset_phy)    ,.enable(act_block0_1)    ,.din(toggle1_t1_din        )   ,.q(toggle1_t1_q         ) );
dlc_ff       #(.width(  1) ,.rstv({ 1{1'b0}})) ff_toggle2_t2           (.clk(phy_dl_clock)  ,.reset_n(reset_phy)    ,.enable(act_block0_2)    ,.din(toggle2_t2_din        )   ,.q(toggle2_t2_q         ) );
dlc_ff       #(.width(  1) ,.rstv({ 1{1'b0}})) ff_toggle3_t3           (.clk(phy_dl_clock)  ,.reset_n(reset_phy)    ,.enable(act_block0_3)    ,.din(toggle3_t3_din        )   ,.q(toggle3_t3_q         ) );
dlc_ff       #(.width(  1) ,.rstv({ 1{1'b0}})) ff_toggle4_t4           (.clk(phy_dl_clock)  ,.reset_n(reset_phy)    ,.enable(act_block1_0)    ,.din(toggle4_t4_din        )   ,.q(toggle4_t4_q         ) );
dlc_ff       #(.width(  1) ,.rstv({ 1{1'b0}})) ff_toggle5_t5           (.clk(phy_dl_clock)  ,.reset_n(reset_phy)    ,.enable(act_block1_1)    ,.din(toggle5_t5_din        )   ,.q(toggle5_t5_q         ) );
dlc_ff       #(.width(  1) ,.rstv({ 1{1'b0}})) ff_toggle6_t6           (.clk(phy_dl_clock)  ,.reset_n(reset_phy)    ,.enable(act_block1_2)    ,.din(toggle6_t6_din        )   ,.q(toggle6_t6_q         ) );
dlc_ff       #(.width(  1) ,.rstv({ 1{1'b0}})) ff_toggle7_t7           (.clk(phy_dl_clock)  ,.reset_n(reset_phy)    ,.enable(act_block1_3)    ,.din(toggle7_t7_din        )   ,.q(toggle7_t7_q         ) );

//-- dl_clk flip flops
dlc_ff_spare #(.width(  1) ,.rstv({  1{1'b0}})) ff_spare_cfg                      (.clk(dl_clk      )  ,.reset_n(reset)    ,.enable(omi_enable  )    ,.din(spare_cfg_din                 )        ,.q(spare_cfg_q                   ) );
dlc_ff_spare #(.width(  1) ,.rstv({  1{1'b0}})) ff_spare_00                       (.clk(dl_clk      )  ,.reset_n(reset)    ,.enable(omi_enable  )    ,.din(spare_00_din                  )        ,.q(spare_00_q                    ) );
dlc_ff_spare #(.width(  1) ,.rstv({  1{1'b0}})) ff_spare_01                       (.clk(dl_clk      )  ,.reset_n(reset)    ,.enable(omi_enable  )    ,.din(spare_01_din                  )        ,.q(spare_01_q                    ) );
dlc_ff_spare #(.width(  1) ,.rstv({  1{1'b0}})) ff_spare_02                       (.clk(dl_clk      )  ,.reset_n(reset)    ,.enable(omi_enable  )    ,.din(spare_02_din                  )        ,.q(spare_02_q                    ) );
dlc_ff_spare #(.width(  1) ,.rstv({  1{1'b0}})) ff_spare_03                       (.clk(dl_clk      )  ,.reset_n(reset)    ,.enable(omi_enable  )    ,.din(spare_03_din                  )        ,.q(spare_03_q                    ) );
dlc_ff_spare #(.width(  1) ,.rstv({  1{1'b0}})) ff_spare_04                       (.clk(dl_clk      )  ,.reset_n(reset)    ,.enable(omi_enable  )    ,.din(spare_04_din                  )        ,.q(spare_04_q                    ) );
dlc_ff_spare #(.width(  1) ,.rstv({  1{1'b0}})) ff_spare_05                       (.clk(dl_clk      )  ,.reset_n(reset)    ,.enable(omi_enable  )    ,.din(spare_05_din                  )        ,.q(spare_05_q                    ) );
dlc_ff_spare #(.width(  1) ,.rstv({  1{1'b0}})) ff_spare_06                       (.clk(dl_clk      )  ,.reset_n(reset)    ,.enable(omi_enable  )    ,.din(spare_06_din                  )        ,.q(spare_06_q                    ) );
dlc_ff_spare #(.width(  1) ,.rstv({  1{1'b0}})) ff_spare_07                       (.clk(dl_clk      )  ,.reset_n(reset)    ,.enable(omi_enable  )    ,.din(spare_07_din                  )        ,.q(spare_07_q                    ) );

dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_dl_reset                       (.clk(dl_clk      )  ,.reset_n(1'b1 )    ,.enable(omi_enable  )    ,.din(dl_reset_n_din                )        ,.q(dl_reset_n_q                  ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_slip_left_toggle               (.clk(dl_clk      )  ,.reset_n(reset)    ,.enable(omi_enable  )    ,.din(slip_left_toggle_din          )        ,.q(slip_left_toggle_q            ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_slip_right_toggle              (.clk(dl_clk      )  ,.reset_n(reset)    ,.enable(omi_enable  )    ,.din(slip_right_toggle_din         )        ,.q(slip_right_toggle_q           ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_Block_Lock                     (.clk(dl_clk      )  ,.reset_n(reset)    ,.enable(omi_enable  )    ,.din(Block_Lock_din                )        ,.q(Block_Lock_q                  ) );
dlc_ff       #(.width(  4) ,.rstv({  4{1'b0}})) ff_DM_Count                       (.clk(dl_clk      )  ,.reset_n(reset)    ,.enable(omi_enable  )    ,.din(DM_Count_din                  )        ,.q(DM_Count_q                    ) );
dlc_ff       #(.width(  8) ,.rstv({  8{1'b0}})) ff_DM_Data                        (.clk(dl_clk      )  ,.reset_n(reset)    ,.enable(omi_enable  )    ,.din(DM_Data_din                   )        ,.q(DM_Data_q                     ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_Deskew_Valid                   (.clk(dl_clk      )  ,.reset_n(reset)    ,.enable(omi_enable  )    ,.din(Deskew_Valid_din              )        ,.q(Deskew_Valid_q                ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_F_pattern_cnt                  (.clk(dl_clk      )  ,.reset_n(reset)    ,.enable(omi_enable  )    ,.din(F_pattern_cnt_din             )        ,.q(F_pattern_cnt_q               ) );
dlc_ff       #(.width(  6) ,.rstv({  6{1'b0}})) ff_sh_count_grid                  (.clk(dl_clk      )  ,.reset_n(reset)    ,.enable(omi_enable  )    ,.din(sh_count_grid_din             )        ,.q(sh_count_grid_q               ) );
dlc_ff       #(.width(  4) ,.rstv({  4{1'b0}})) ff_SH_invalid_count               (.clk(dl_clk      )  ,.reset_n(reset)    ,.enable(omi_enable  )    ,.din(SH_invalid_count_din          )        ,.q(SH_invalid_count_q            ) );
dlc_ff       #(.width( 13) ,.rstv({ 13{1'b0}})) ff_Test_Obs                       (.clk(dl_clk      )  ,.reset_n(reset)    ,.enable(omi_enable  )    ,.din(Test_Obs_din                  )        ,.q(Test_Obs_q                    ) );
dlc_ff       #(.width(  4) ,.rstv({  4{1'b0}})) ff_Training_Count                 (.clk(dl_clk      )  ,.reset_n(reset)    ,.enable(omi_enable  )    ,.din(Training_Count_din            )        ,.q(Training_Count_q              ) );
dlc_ff       #(.width(  8) ,.rstv({  8{1'b0}})) ff_Training_Data                  (.clk(dl_clk      )  ,.reset_n(reset)    ,.enable(omi_enable  )    ,.din(Training_Data_din             )        ,.q(Training_Data_q               ) );
dlc_ff       #(.width(  2) ,.rstv({  2{1'b0}})) ff_Training_Type                  (.clk(dl_clk      )  ,.reset_n(reset)    ,.enable(omi_enable  )    ,.din(Training_Type_din             )        ,.q(Training_Type_q               ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_buffer_block_valid             (.clk(dl_clk      )  ,.reset_n(reset)    ,.enable(omi_enable  )    ,.din(buffer_block_valid_din        )        ,.q(buffer_block_valid_q          ) );
dlc_ff       #(.width(  4) ,.rstv({  4{1'b0}})) ff_cfg_phy_a_hyst                 (.clk(dl_clk      )  ,.reset_n(reset)    ,.enable(omi_enable  )    ,.din(cfg_phy_a_hyst_din            )        ,.q(cfg_phy_a_hyst_q              ) );
dlc_ff       #(.width(  4) ,.rstv({  4{1'b0}})) ff_cfg_phy_b_hyst                 (.clk(dl_clk      )  ,.reset_n(reset)    ,.enable(omi_enable  )    ,.din(cfg_phy_b_hyst_din            )        ,.q(cfg_phy_b_hyst_q              ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_cfg_phy_train_a_less_x         (.clk(dl_clk      )  ,.reset_n(reset)    ,.enable(omi_enable  )    ,.din(cfg_phy_train_a_less_x_din    )        ,.q(cfg_phy_train_a_less_x_q      ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_cfg_phy_train_a_more_x         (.clk(dl_clk      )  ,.reset_n(reset)    ,.enable(omi_enable  )    ,.din(cfg_phy_train_a_more_x_din    )        ,.q(cfg_phy_train_a_more_x_q      ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_cfg_phy_train_b_less_x         (.clk(dl_clk      )  ,.reset_n(reset)    ,.enable(omi_enable  )    ,.din(cfg_phy_train_b_less_x_din    )        ,.q(cfg_phy_train_b_less_x_q      ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_cfg_phy_train_b_more_x         (.clk(dl_clk      )  ,.reset_n(reset)    ,.enable(omi_enable  )    ,.din(cfg_phy_train_b_more_x_din    )        ,.q(cfg_phy_train_b_more_x_q      ) );
dlc_ff       #(.width( 16) ,.rstv({ 16{1'b0}})) ff_deskew_data00                  (.clk(dl_clk      )  ,.reset_n(reset)    ,.enable(omi_enable  )    ,.din(deskew_data00_din             )        ,.q(deskew_data00_q               ) );
dlc_ff       #(.width( 16) ,.rstv({ 16{1'b0}})) ff_deskew_data01                  (.clk(dl_clk      )  ,.reset_n(reset)    ,.enable(omi_enable  )    ,.din(deskew_data01_din             )        ,.q(deskew_data01_q               ) );
dlc_ff       #(.width( 16) ,.rstv({ 16{1'b0}})) ff_deskew_data02                  (.clk(dl_clk      )  ,.reset_n(reset)    ,.enable(omi_enable  )    ,.din(deskew_data02_din             )        ,.q(deskew_data02_q               ) );
dlc_ff       #(.width( 16) ,.rstv({ 16{1'b0}})) ff_deskew_data03                  (.clk(dl_clk      )  ,.reset_n(reset)    ,.enable(omi_enable  )    ,.din(deskew_data03_din             )        ,.q(deskew_data03_q               ) );
dlc_ff       #(.width(  2) ,.rstv({  2{1'b0}})) ff_deskew_sync0                   (.clk(dl_clk      )  ,.reset_n(reset)    ,.enable(omi_enable  )    ,.din(deskew_sync0_din              )        ,.q(deskew_sync0_q                ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_do_inversion                   (.clk(dl_clk      )  ,.reset_n(reset)    ,.enable(omi_enable  )    ,.din(do_inversion_din              )        ,.q(do_inversion_q                ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_do_shift_left                  (.clk(dl_clk      )  ,.reset_n(reset)    ,.enable(omi_enable  )    ,.din(do_shift_left_din             )        ,.q(do_shift_left_q               ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_do_shift_right                 (.clk(dl_clk      )  ,.reset_n(reset)    ,.enable(omi_enable  )    ,.din(do_shift_right_din            )        ,.q(do_shift_right_q              ) );
dlc_ff       #(.width(  4) ,.rstv({  4{1'b0}})) ff_read_ptr                       (.clk(dl_clk      )  ,.reset_n(reset)    ,.enable(omi_enable  )    ,.din(read_ptr_din                  )        ,.q(read_ptr_q                    ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_inv_rec1                       (.clk(dl_clk      )  ,.reset_n(reset)    ,.enable(omi_enable  )    ,.din(inv_rec1_din                  )        ,.q(inv_rec1_q                    ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_inv_rec2                       (.clk(dl_clk      )  ,.reset_n(reset)    ,.enable(omi_enable  )    ,.din(inv_rec2_din                  )        ,.q(inv_rec2_q                    ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_lane_disabled                  (.clk(dl_clk      )  ,.reset_n(reset)    ,.enable(omi_enable  )    ,.din(lane_disabled_din             )        ,.q(lane_disabled_q               ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_lfsr_bad_TS                    (.clk(dl_clk      )  ,.reset_n(reset)    ,.enable(omi_enable  )    ,.din(lfsr_bad_TS_din               )        ,.q(lfsr_bad_TS_q                 ) );
dlc_ff       #(.width( 23) ,.rstv({ 23{1'b0}})) ff_lfsr                           (.clk(dl_clk      )  ,.reset_n(reset)    ,.enable(omi_enable  )    ,.din(lfsr_din                      )        ,.q(lfsr_q                        ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_lfsr_locked                    (.clk(dl_clk      )  ,.reset_n(reset)    ,.enable(omi_enable  )    ,.din(lfsr_locked_din               )        ,.q(lfsr_locked_q                 ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_lfsr_running                   (.clk(dl_clk      )  ,.reset_n(reset)    ,.enable(omi_enable  )    ,.din(lfsr_running_din              )        ,.q(lfsr_running_q                ) );
dlc_ff       #(.width(  4) ,.rstv({  4{1'b0}})) ff_need_shift_left_cnt            (.clk(dl_clk      )  ,.reset_n(reset)    ,.enable(omi_enable  )    ,.din(need_shift_left_cnt_din       )        ,.q(need_shift_left_cnt_q         ) );
dlc_ff       #(.width(  4) ,.rstv({  4{1'b0}})) ff_need_shift_right_cnt           (.clk(dl_clk      )  ,.reset_n(reset)    ,.enable(omi_enable  )    ,.din(need_shift_right_cnt_din      )        ,.q(need_shift_right_cnt_q        ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_only_good_bits                 (.clk(dl_clk      )  ,.reset_n(reset)    ,.enable(omi_enable  )    ,.din(only_good_bits_din            )        ,.q(only_good_bits_q              ) );
dlc_ff       #(.width( 16) ,.rstv({ 16{1'b0}})) ff_pattern_a_count                (.clk(dl_clk      )  ,.reset_n(reset)    ,.enable(omi_enable  )    ,.din(pattern_a_count_din           )        ,.q(pattern_a_count_q             ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_pattern_a_detected             (.clk(dl_clk      )  ,.reset_n(reset)    ,.enable(omi_enable  )    ,.din(pattern_a_detected_din        )        ,.q(pattern_a_detected_q          ) );
dlc_ff       #(.width( 12) ,.rstv({ 12{1'b0}})) ff_pattern_b_count                (.clk(dl_clk      )  ,.reset_n(reset)    ,.enable(omi_enable  )    ,.din(pattern_b_count_din           )        ,.q(pattern_b_count_q             ) );
dlc_ff       #(.width( 16) ,.rstv({ 16{1'b0}})) ff_pattern_b_cycle1               (.clk(dl_clk      )  ,.reset_n(reset)    ,.enable(omi_enable  )    ,.din(pattern_b_cycle1_din          )        ,.q(pattern_b_cycle1_q            ) );
dlc_ff       #(.width( 16) ,.rstv({ 16{1'b0}})) ff_pattern_b_cycle2               (.clk(dl_clk      )  ,.reset_n(reset)    ,.enable(omi_enable  )    ,.din(pattern_b_cycle2_din          )        ,.q(pattern_b_cycle2_q            ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_pattern_b_detected             (.clk(dl_clk      )  ,.reset_n(reset)    ,.enable(omi_enable  )    ,.din(pattern_b_detected_din        )        ,.q(pattern_b_detected_q          ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_pattern_b_timer                (.clk(dl_clk      )  ,.reset_n(reset)    ,.enable(omi_enable  )    ,.din(pattern_b_timer_din           )        ,.q(pattern_b_timer_q             ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_phy_training                   (.clk(dl_clk      )  ,.reset_n(reset)    ,.enable(omi_enable  )    ,.din(phy_training_din              )        ,.q(phy_training_q                ) );
dlc_ff       #(.width(  2) ,.rstv({  2{1'b0}})) ff_prev_sh                        (.clk(dl_clk      )  ,.reset_n(reset)    ,.enable(omi_enable  )    ,.din(prev_sh_din                   )        ,.q(prev_sh_q                     ) );
dlc_ff       #(.width( 16) ,.rstv({ 16{1'b0}})) ff_prev_raw_data                  (.clk(dl_clk      )  ,.reset_n(reset)    ,.enable(omi_enable  )    ,.din(prev_raw_data_din             )        ,.q(prev_raw_data_q               ) );
dlc_ff       #(.width( 16) ,.rstv({ 16{1'b0}})) ff_prev_raw_data_dly              (.clk(dl_clk      )  ,.reset_n(reset)    ,.enable(omi_enable  )    ,.din(prev_raw_data_dly_din         )        ,.q(prev_raw_data_dly_q           ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_reset_deskew                   (.clk(dl_clk      )  ,.reset_n(reset)    ,.enable(omi_enable  )    ,.din(reset_deskew_din              )        ,.q(reset_deskew_q                ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_rx_inverted                    (.clk(dl_clk      )  ,.reset_n(reset)    ,.enable(omi_enable  )    ,.din(rx_inverted_din               )        ,.q(rx_inverted_q                 ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_sync_received                  (.clk(dl_clk      )  ,.reset_n(reset)    ,.enable(omi_enable  )    ,.din(sync_received_din             )        ,.q(sync_received_q               ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_last_value                     (.clk(dl_clk      )  ,.reset_n(reset)    ,.enable(omi_enable  )    ,.din(last_value_din                )        ,.q(last_value_q                  ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_last_value_dly                 (.clk(dl_clk      )  ,.reset_n(reset)    ,.enable(omi_enable  )    ,.din(last_value_dly_din            )        ,.q(last_value_dly_q              ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_deskew_found_dly               (.clk(dl_clk      )  ,.reset_n(reset)    ,.enable(omi_enable  )    ,.din(deskew_found_dly_din          )        ,.q(deskew_found_dly_q            ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_buffer_started                 (.clk(dl_clk      )  ,.reset_n(reset)    ,.enable(omi_enable  )    ,.din(buffer_started_din            )        ,.q(buffer_started_q              ) );
dlc_ff       #(.width(  8) ,.rstv({  8{1'b0}})) ff_EDPL_cntr                      (.clk(dl_clk      )  ,.reset_n(reset)    ,.enable(act_EDPL    )    ,.din(EDPL_cntr_din                 )        ,.q(EDPL_cntr_q                   ) );
dlc_ff       #(.width(  8) ,.rstv({  8{1'b0}})) ff_EDPL_max_cnt                   (.clk(dl_clk      )  ,.reset_n(reset)    ,.enable(act_EDPL    )    ,.din(EDPL_max_cnt_din              )        ,.q(EDPL_max_cnt_q                ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_EDPL_thres_reached             (.clk(dl_clk      )  ,.reset_n(reset)    ,.enable(act_EDPL    )    ,.din(EDPL_thres_reached_din        )        ,.q(EDPL_thres_reached_q          ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_BEI_inject_toggle              (.clk(dl_clk      )  ,.reset_n(reset)    ,.enable(omi_enable  )    ,.din(BEI_inject_toggle_din         )        ,.q(BEI_inject_toggle_q           ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_EDPL_error                     (.clk(dl_clk      )  ,.reset_n(reset)    ,.enable(omi_enable  )    ,.din(EDPL_error_din                )        ,.q(EDPL_error_q                  ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_cfg_sync_mode                  (.clk(dl_clk      )  ,.reset_n(reset)    ,.enable(omi_enable  )    ,.din(cfg_sync_mode_din             )        ,.q(cfg_sync_mode_q               ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_check_EDPL                     (.clk(dl_clk      )  ,.reset_n(reset)    ,.enable(omi_enable  )    ,.din(check_EDPL_din                )        ,.q(check_EDPL_q                  ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_input_taken_dly                (.clk(dl_clk      )  ,.reset_n(reset)    ,.enable(omi_enable  )    ,.din(input_taken_dly_din           )        ,.q(input_taken_dly_q             ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_calc_par                       (.clk(dl_clk      )  ,.reset_n(reset)    ,.enable(omi_enable  )    ,.din(calc_par_din                  )        ,.q(calc_par_q                    ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_ln_trained_dly                 (.clk(dl_clk      )  ,.reset_n(reset)    ,.enable(omi_enable  )    ,.din(ln_trained_dly_din            )        ,.q(ln_trained_dly_q              ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_EDPL_thres_reached_dly         (.clk(dl_clk      )  ,.reset_n(reset)    ,.enable(omi_enable  )    ,.din(EDPL_thres_reached_dly_din    )        ,.q(EDPL_thres_reached_dly_q      ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_Clear_BL_toggle                (.clk(dl_clk      )  ,.reset_n(reset)    ,.enable(omi_enable  )    ,.din(Clear_BL_toggle_din           )        ,.q(Clear_BL_toggle_q             ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_clear_lfsr_dly                 (.clk(dl_clk      )  ,.reset_n(reset)    ,.enable(omi_enable  )    ,.din(clear_lfsr_dly_din            )        ,.q(clear_lfsr_dly_q              ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_TS1_Valid                      (.clk(dl_clk      )  ,.reset_n(reset)    ,.enable(omi_enable  )    ,.din(TS1_Valid_din                 )        ,.q(unused[0]                     ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_TS2_Valid                      (.clk(dl_clk      )  ,.reset_n(reset)    ,.enable(omi_enable  )    ,.din(TS2_Valid_din                 )        ,.q(unused[1]                     ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_TS3_Valid                      (.clk(dl_clk      )  ,.reset_n(reset)    ,.enable(omi_enable  )    ,.din(TS3_Valid_din                 )        ,.q(unused[2]                     ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_DM_Valid                       (.clk(dl_clk      )  ,.reset_n(reset)    ,.enable(omi_enable  )    ,.din(DM_Valid_din                  )        ,.q(unused[3]                     ) );
dlc_ff       #(.width(  7) ,.rstv({  7{1'b0}})) ff_pattern_F_det_test             (.clk(dl_clk      )  ,.reset_n(reset)    ,.enable(omi_enable  )    ,.din(pattern_F_det_test_din        )        ,.q(unused[10:4]                  ) );

endmodule //-- dlc_omi_rx_lanei
