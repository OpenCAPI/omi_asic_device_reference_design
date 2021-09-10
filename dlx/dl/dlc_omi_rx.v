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
module dlc_omi_rx #(
parameter             RX_EQ_TX_CLK = 0
) (
//-- inputs from the 8 different PHY lanes
  phy_dl_clock_0                //-- < input
 ,phy_dl_clock_1                //-- < input
 ,phy_dl_clock_2                //-- < input
 ,phy_dl_clock_3                //-- < input
 ,phy_dl_clock_4                //-- < input
 ,phy_dl_clock_5                //-- < input
 ,phy_dl_clock_6                //-- < input
 ,phy_dl_clock_7                //-- < input
 ,phy_dl_lane_0                 //-- < input   [15:0]
 ,phy_dl_lane_1                 //-- < input   [15:0]
 ,phy_dl_lane_2                 //-- < input   [15:0]
 ,phy_dl_lane_3                 //-- < input   [15:0]
 ,phy_dl_lane_4                 //-- < input   [15:0]
 ,phy_dl_lane_5                 //-- < input   [15:0]
 ,phy_dl_lane_6                 //-- < input   [15:0]
 ,phy_dl_lane_7                 //-- < input   [15:0]
 ,phy_dl_iobist_reset           //-- < input
 ,lbist_en_dc                   //-- < input
 ,rx_tx_iobist_prbs_error       //-- > output  [7:0]
//-- outputs to the TL            
 ,dl2tl_dead_cycle              //-- > output
 ,dl2tl_flit_vld                //-- > output
 ,dl2tl_flit_error              //-- > output
 ,dl2tl_flit_badcrc             //-- > output
 ,dl2tl_flit_data               //-- > output  [127:0]
 ,dl2tl_flit_pty                //-- > output  [15:0]
 ,dl2tl_flit_act                //-- > output
 ,rx_link_up                    //-- > output
 ,dl2tl_idle_transition_l       //-- > output
 ,dl2tl_fast_act_info_l         //-- > output
 ,dl2tl_idle_transition_r       //-- > output
 ,dl2tl_fast_act_info_r         //-- > output
 ,dl2tl_idle_transition         //-- > output
 ,dl2tl_fast_act_info           //-- > output
//-- signals between the RX and TX
 ,rx_tx_crc_error               //-- > output
 ,rx_tx_nack                    //-- > output
 ,rx_tx_rx_ack_inc              //-- > output [3:0]
 ,rx_tx_tx_ack_rtn              //-- > output [4:0]
 ,rx_tx_tx_ack_ptr_vld          //-- > output
 ,rx_tx_tx_ack_ptr              //-- > output [11:0]
 ,rx_tx_rmt_error               //-- > output [7:0]
 ,rx_tx_rmt_message             //-- > output [63:0]
 ,rx_tx_recal_status            //-- > output [1:0]      //--  new ports for power management
 ,rx_tx_pm_status               //-- > output [3:0]      //--  new ports for power management
 ,tx_rx_reset_n                 //-- < input
 ,chip_reset                    //-- < input
 ,global_reset_control          //-- < input
 ,tx_rx_tsm                     //-- < input  [2:0]    
 ,tx_rx_phy_init_done           //-- < input  [7:0]
 ,rx_tx_version_number          //-- > output [5:0]
 ,rx_tx_slow_clock              //-- > output
 ,rx_tx_deskew_overflow         //-- > output
 ,rx_tx_train_status            //-- > output [72:0]   
 ,rx_tx_disabled_rx_lanes       //-- > output [7:0]
 ,rx_tx_disabled_tx_lanes       //-- > output [7:0]
 ,rx_tx_ts_valid                //-- > output
 ,rx_tx_ts_good_lanes           //-- > output [15:0]
 ,rx_tx_deskew_config_valid     //-- > output 
 ,rx_tx_deskew_config           //-- > output [18:0]
 ,rx_tx_tx_ordering             //-- > output
 ,rx_tx_rem_supported_widths    //-- > output [3:0]
 ,rx_tx_trained_mode            //-- > output [3:0]
 ,tx_rx_cfg_supported_widths    //-- < input [3:0]
 ,rx_tx_tx_lane_swap            //-- > output
 ,rx_tx_rem_PM_enable           //-- > output
 ,rx_tx_rx_lane_reverse         //-- > output
 ,rx_tx_lost_data_sync          //-- > output
 ,rx_tx_trn_dbg                 //-- > output[87:0]
 ,rx_tx_training_sync_hdr       //-- > output
 ,rx_tx_EDPL_max_cnts           //-- > output [63:0]
 ,rx_tx_EDPL_errors             //-- > output [7:0]
 ,rx_tx_EDPL_thres_reached      //-- > output [7:0]
 ,tx_rx_EDPL_cfg                //-- < input [4:0]
 ,tx_rx_cfg_patA_length         //-- < input [1:0]
 ,tx_rx_cfg_patB_length         //-- < input [1:0]
 ,tx_rx_cfg_patA_hyst           //-- < input [3:0]
 ,tx_rx_cfg_patB_hyst           //-- < input [3:0]
 ,tx_rx_rx_BEI_inject           //-- < input [7:0]
 ,tx_rx_start_retrain           //-- < input
 ,tx_rx_half_width              //-- < input
 ,tx_rx_quarter_width           //-- < input
 ,tx_rx_cfg_disable_rx_lanes    //-- < input [7:0]
 ,tx_rx_PM_rx_lanes_disable     //-- < input [7:0]
 ,tx_rx_PM_rx_lanes_enable      //-- < input [7:0]
 ,tx_rx_PM_deskew_reset         //-- < input
 ,tx_rx_psave_sts_off           //-- < input
 ,tx_rx_retrain_not_due2_PM     //-- < input
 ,tx_rx_cfg_version             //-- < input [5:0]
 ,tx_rx_enable_short_idle       //-- < input
 ,tx_rx_cfg_sync_mode           //-- < input
 ,tx_rx_sim_only_fast_train     //-- < input
 ,tx_rx_sim_only_request_ln_rev //-- < input
 ,reg_dl_edpl_max_count_reset   //-- < input
 ,reg_dl_1us_tick               //-- < input
 ,omi_enable                    //-- < input 
 ,dl_clk                        //-- < input
 ,rx_tx_mn_trn_in_replay        //-- > output
 ,rx_tx_data_flt                //-- > output
 ,rx_tx_ctl_flt                 //-- > output
 ,rx_tx_rpl_flt                 //-- > output
 ,rx_tx_idle_flt                //-- > output
 ,rx_tx_ill_rl                  //-- > output     
 ,rx_tx_dbg_rx_info             //-- > output[87:0]
 ,tx_rx_macro_dbg_sel           //-- < input [3:0]
 ,tx_rx_inj_pty_err             //-- < input 
);


input              phy_dl_clock_0;
input              phy_dl_clock_1;
input              phy_dl_clock_2;
input              phy_dl_clock_3;
input              phy_dl_clock_4;
input              phy_dl_clock_5;
input              phy_dl_clock_6;
input              phy_dl_clock_7;
input   [15:0]     phy_dl_lane_0;
input   [15:0]     phy_dl_lane_1;
input   [15:0]     phy_dl_lane_2;
input   [15:0]     phy_dl_lane_3;
input   [15:0]     phy_dl_lane_4;
input   [15:0]     phy_dl_lane_5;
input   [15:0]     phy_dl_lane_6;
input   [15:0]     phy_dl_lane_7;
input              phy_dl_iobist_reset;
input              lbist_en_dc;
output             dl2tl_idle_transition;
output  [34:0]     dl2tl_fast_act_info;
output             dl2tl_idle_transition_l;
output  [34:0]     dl2tl_fast_act_info_l;
output             dl2tl_idle_transition_r;
output  [34:0]     dl2tl_fast_act_info_r;
output             dl2tl_dead_cycle;
output             dl2tl_flit_vld;
output             dl2tl_flit_error;
output             dl2tl_flit_badcrc;
output  [127:0]    dl2tl_flit_data;
output  [15:0]     dl2tl_flit_pty;
output             dl2tl_flit_act;
output             rx_link_up;
output             rx_tx_crc_error;
output             rx_tx_nack;
output [3:0]       rx_tx_rx_ack_inc;
output [4:0]       rx_tx_tx_ack_rtn;
output             rx_tx_tx_ack_ptr_vld;
output [11:0]      rx_tx_tx_ack_ptr;
output [7:0]       rx_tx_rmt_error;
output [63:0]      rx_tx_rmt_message;
output [1:0]       rx_tx_recal_status;
output [3:0]       rx_tx_pm_status;
input              tx_rx_reset_n;
input              chip_reset;
input              global_reset_control;
input  [2:0]       tx_rx_tsm;
input  [7:0]       tx_rx_phy_init_done;
output [5:0]       rx_tx_version_number;
output             rx_tx_slow_clock;
output             rx_tx_deskew_overflow;
output [72:0]      rx_tx_train_status;
output [7:0]       rx_tx_disabled_rx_lanes;
output [7:0]       rx_tx_disabled_tx_lanes;
output             rx_tx_ts_valid;
output [15:0]      rx_tx_ts_good_lanes;
output             rx_tx_deskew_config_valid;
output [18:0]      rx_tx_deskew_config;
output             rx_tx_tx_ordering;
output [3:0]       rx_tx_rem_supported_widths;
output [3:0]       rx_tx_trained_mode;
input  [3:0]       tx_rx_cfg_supported_widths;
output             rx_tx_tx_lane_swap;
output             rx_tx_rem_PM_enable;
output             rx_tx_rx_lane_reverse;
output             rx_tx_lost_data_sync;
output [87:0]      rx_tx_trn_dbg;
output             rx_tx_training_sync_hdr;
output [63:0]      rx_tx_EDPL_max_cnts;
output [7:0]       rx_tx_EDPL_errors;
output [7:0]       rx_tx_EDPL_thres_reached;
input  [4:0]       tx_rx_EDPL_cfg;
input  [1:0]       tx_rx_cfg_patA_length;
input  [1:0]       tx_rx_cfg_patB_length;
input  [3:0]       tx_rx_cfg_patA_hyst; 
input  [3:0]       tx_rx_cfg_patB_hyst;
input  [7:0]       tx_rx_rx_BEI_inject;
input              tx_rx_start_retrain;
input              tx_rx_half_width;
input              tx_rx_quarter_width;
input [7:0]        tx_rx_cfg_disable_rx_lanes;
input [7:0]        tx_rx_PM_rx_lanes_disable;
input [7:0]        tx_rx_PM_rx_lanes_enable;
input              tx_rx_PM_deskew_reset;
input              tx_rx_psave_sts_off;
input              tx_rx_retrain_not_due2_PM;
input [5:0]        tx_rx_cfg_version;
input              tx_rx_enable_short_idle;
input              tx_rx_cfg_sync_mode;
input              tx_rx_sim_only_fast_train;
input              tx_rx_sim_only_request_ln_rev;
input              reg_dl_edpl_max_count_reset;
input              reg_dl_1us_tick;
input              omi_enable;
input              dl_clk;
output             rx_tx_mn_trn_in_replay;       
output             rx_tx_data_flt;               
output             rx_tx_ctl_flt;                
output             rx_tx_rpl_flt;                
output             rx_tx_idle_flt;               
output             rx_tx_ill_rl;                    
output [87:0]      rx_tx_dbg_rx_info;           
input  [3:0]       tx_rx_macro_dbg_sel;
output [7:0]       rx_tx_iobist_prbs_error;
input              tx_rx_inj_pty_err;




wire          rx_link_up;
wire          ln0_valid;
wire          ln1_valid;
wire          ln2_valid;
wire          ln3_valid;
wire          ln4_valid;
wire          ln5_valid;
wire          ln6_valid;
wire          ln7_valid;
wire  [15:0]  ln0_data;
wire  [15:0]  ln1_data;
wire  [15:0]  ln2_data;
wire  [15:0]  ln3_data;
wire  [15:0]  ln4_data;
wire  [15:0]  ln5_data;
wire  [15:0]  ln6_data;
wire  [15:0]  ln7_data;
wire  [15:0]  ln0_trn_data;
wire  [15:0]  ln1_trn_data;
wire  [15:0]  ln2_trn_data;
wire  [15:0]  ln3_trn_data;
wire  [15:0]  ln4_trn_data;
wire  [15:0]  ln5_trn_data;
wire  [15:0]  ln6_trn_data;
wire  [15:0]  ln7_trn_data;
wire  [1:0]   ln0_parity;  
wire  [1:0]   ln1_parity;  
wire  [1:0]   ln2_parity;  
wire  [1:0]   ln3_parity;  
wire  [1:0]   ln4_parity;  
wire  [1:0]   ln5_parity;  
wire  [1:0]   ln6_parity;  
wire  [1:0]   ln7_parity;  
wire  [7:0]   ln_data_sync_hdr;
wire  [7:0]   ln_ctl_sync_hdr;
wire  [7:0]   ln_rx_slow_pat_a;
wire  [7:0]   ln_pattern_a;
wire  [7:0]   ln_pattern_b;
wire  [7:0]   ln_sync;
wire  [7:0]   ln_block_lock;
wire  [7:0]   ln_TS1;
wire  [7:0]   ln_TS2;
wire  [7:0]   ln_TS3;
wire          ln_deskew_enable;
wire  [7:0]   ln_deskew_found;
wire  [7:0]   ln_deskew_hold;
wire  [7:0]   ln_deskew_valid;
wire  [7:0]   ln_deskew_overflow;
wire          ln_all_valid;
wire          ln_deskew_reset;
wire          ln_phy_training;
wire  [7:0]   ln_phy_init_done;
wire  [7:0]   ln_disabled;
wire          rx_reset_n;
wire          trn_mn_trained;
wire  [127:0] agn_mn_flit;
wire          agn_mn_flit_vld;
wire  [15:0]  agn_mn_flit_pty;
wire          trn_agn_ln_swap;
wire          trn_agn_trained;
wire          trn_agn_retrain;
wire          trn_ln_trained;
wire  [1:0]   trn_agn_x4_mode;
wire  [1:0]   trn_agn_x2_mode;
wire          agn_mn_ln_swap;
wire  [1:0]   agn_mn_x4_mode;
wire  [1:0]   agn_mn_x2_mode;
wire          mn_agn_dead_cycle_reset;

//-- 8/7 Added Cloning

wire  [15:0]  ln2_data_clone_l;
wire  [15:0]  ln3_data_clone_l;
wire  [15:0]  ln4_data_clone_l;
wire  [15:0]  ln5_data_clone_l;
wire  [15:0]  ln2_data_clone_r;
wire  [15:0]  ln3_data_clone_r;
wire  [15:0]  ln4_data_clone_r;
wire  [15:0]  ln5_data_clone_r;
wire  [15:0]  ln2_data_clone_c;
wire  [15:0]  ln3_data_clone_c;
wire  [15:0]  ln4_data_clone_c;
wire  [15:0]  ln5_data_clone_c;
wire  [15:0]  ln2_data_clone_l_int;
wire  [15:0]  ln3_data_clone_l_int;
wire  [15:0]  ln4_data_clone_l_int;
wire  [15:0]  ln5_data_clone_l_int;
wire  [15:0]  ln2_data_clone_r_int;
wire  [15:0]  ln3_data_clone_r_int;
wire  [15:0]  ln4_data_clone_r_int;
wire  [15:0]  ln5_data_clone_r_int;
wire  [15:0]  ln2_data_clone_c_int;
wire  [15:0]  ln3_data_clone_c_int;
wire  [15:0]  ln4_data_clone_c_int;
wire  [15:0]  ln5_data_clone_c_int;
wire          ocmb_not_axone;


generate
if (RX_EQ_TX_CLK == 1) //--  needs cloning,  Does not 
  begin
   assign ln2_data_clone_l_int[15:0] = ln2_data_clone_l; 
   assign ln2_data_clone_c_int[15:0] = ln2_data_clone_c; 
   assign ln2_data_clone_r_int[15:0] = ln2_data_clone_r; 
   assign ln3_data_clone_l_int[15:0] = ln3_data_clone_l; 
   assign ln3_data_clone_c_int[15:0] = ln3_data_clone_c; 
   assign ln3_data_clone_r_int[15:0] = ln3_data_clone_r; 
   assign ln4_data_clone_l_int[15:0] = ln4_data_clone_l; 
   assign ln4_data_clone_c_int[15:0] = ln4_data_clone_c; 
   assign ln4_data_clone_r_int[15:0] = ln4_data_clone_r; 
   assign ln5_data_clone_l_int[15:0] = ln5_data_clone_l; 
   assign ln5_data_clone_c_int[15:0] = ln5_data_clone_c; 
   assign ln5_data_clone_r_int[15:0] = ln5_data_clone_r;
   assign ocmb_not_axone             = 1'b1; 
  end
else
  begin
   assign ln2_data_clone_l_int[15:0] = 16'h0000; 
   assign ln2_data_clone_c_int[15:0] = 16'h0000; 
   assign ln2_data_clone_r_int[15:0] = 16'h0000; 
   assign ln3_data_clone_l_int[15:0] = 16'h0000; 
   assign ln3_data_clone_c_int[15:0] = 16'h0000; 
   assign ln3_data_clone_r_int[15:0] = 16'h0000; 
   assign ln4_data_clone_l_int[15:0] = 16'h0000; 
   assign ln4_data_clone_c_int[15:0] = 16'h0000; 
   assign ln4_data_clone_r_int[15:0] = 16'h0000; 
   assign ln5_data_clone_l_int[15:0] = 16'h0000; 
   assign ln5_data_clone_c_int[15:0] = 16'h0000; 
   assign ln5_data_clone_r_int[15:0] = 16'h0000; 
   
   assign ln2_data_clone_l[15:0] = 16'h0000; 
   assign ln2_data_clone_c[15:0] = 16'h0000; 
   assign ln2_data_clone_r[15:0] = 16'h0000; 
   assign ln3_data_clone_l[15:0] = 16'h0000; 
   assign ln3_data_clone_c[15:0] = 16'h0000; 
   assign ln3_data_clone_r[15:0] = 16'h0000; 
   assign ln4_data_clone_l[15:0] = 16'h0000; 
   assign ln4_data_clone_c[15:0] = 16'h0000; 
   assign ln4_data_clone_r[15:0] = 16'h0000; 
   assign ln5_data_clone_l[15:0] = 16'h0000; 
   assign ln5_data_clone_c[15:0] = 16'h0000; 
   assign ln5_data_clone_r[15:0] = 16'h0000; 
   assign ocmb_not_axone             = 1'b0; 
  end
endgenerate
dlc_omi_rx_align agn (
  .ln_all_valid                    (ln_all_valid)                  //-- input   
 ,.ln0_data                        (ln0_data[15:0])                //-- input[15:0]  
 ,.ln1_data                        (ln1_data[15:0])                //-- input[15:0]  
 ,.ln2_data                        (ln2_data[15:0])                //-- input[15:0]  
 ,.ln3_data                        (ln3_data[15:0])                //-- input[15:0]  
 ,.ln4_data                        (ln4_data[15:0])                //-- input[15:0]  
 ,.ln5_data                        (ln5_data[15:0])                //-- input[15:0]  
 ,.ln6_data                        (ln6_data[15:0])                //-- input[15:0]  
 ,.ln7_data                        (ln7_data[15:0])                //-- input[15:0]  
 ,.ln2_data_clone_l                (ln2_data_clone_l_int[15:0])                //-- input[15:0]  
 ,.ln3_data_clone_l                (ln3_data_clone_l_int[15:0])                //-- input[15:0]  
 ,.ln4_data_clone_l                (ln4_data_clone_l_int[15:0])                //-- input[15:0]  
 ,.ln5_data_clone_l                (ln5_data_clone_l_int[15:0])                //-- input[15:0]  
 ,.ln2_data_clone_r                (ln2_data_clone_r_int[15:0])                //-- input[15:0]  
 ,.ln3_data_clone_r                (ln3_data_clone_r_int[15:0])                //-- input[15:0]  
 ,.ln4_data_clone_r                (ln4_data_clone_r_int[15:0])                //-- input[15:0]  
 ,.ln5_data_clone_r                (ln5_data_clone_r_int[15:0])                //-- input[15:0]  
 ,.ln2_data_clone_c                (ln2_data_clone_c_int[15:0])                //-- input[15:0]  
 ,.ln3_data_clone_c                (ln3_data_clone_c_int[15:0])                //-- input[15:0]  
 ,.ln4_data_clone_c                (ln4_data_clone_c_int[15:0])                //-- input[15:0]  
 ,.ln5_data_clone_c                (ln5_data_clone_c_int[15:0])                //-- input[15:0]  
 ,.ln0_parity                      (ln0_parity[1:0])               //-- input[1:0]
 ,.ln1_parity                      (ln1_parity[1:0])               //-- input[1:0]
 ,.ln2_parity                      (ln2_parity[1:0])               //-- input[1:0]
 ,.ln3_parity                      (ln3_parity[1:0])               //-- input[1:0]
 ,.ln4_parity                      (ln4_parity[1:0])               //-- input[1:0]
 ,.ln5_parity                      (ln5_parity[1:0])               //-- input[1:0]
 ,.ln6_parity                      (ln6_parity[1:0])               //-- input[1:0]
 ,.ln7_parity                      (ln7_parity[1:0])               //-- input[1:0]
 ,.agn_mn_flit                     (agn_mn_flit[127:0])            //-- input[127:0]
 ,.agn_mn_flit_vld                 (agn_mn_flit_vld)               //-- input 
 ,.agn_mn_flit_pty                 (agn_mn_flit_pty[15:0])         //-- output[15:0] 
 ,.dl_clk                          (dl_clk)                        //-- input
 ,.rx_reset_n                      (rx_reset_n)                    //-- input
 ,.chip_reset                      (chip_reset)                    //-- input
 ,.global_reset_control            (global_reset_control)          //-- input
 ,.trn_agn_trained                 (trn_agn_trained)               //-- input 
 ,.trn_agn_retrain                 (trn_agn_retrain)               //-- input 
 ,.trn_agn_ln_swap                 (trn_agn_ln_swap)               //-- input   
 ,.trn_agn_x4_mode                 (trn_agn_x4_mode[1:0])          //-- input[1:0] 
 ,.trn_agn_x2_mode                 (trn_agn_x2_mode[1:0])          //-- input[1:0]
 ,.omi_enable                      (omi_enable)                    //-- input
 ,.agn_mn_ln_swap                  (agn_mn_ln_swap)                //-- output
 ,.agn_mn_x4_mode                  (agn_mn_x4_mode[1:0])           //-- output[1:0]
 ,.agn_mn_x2_mode                  (agn_mn_x2_mode[1:0])           //-- output[1:0]
 ,.tx_rx_inj_pty_err               (tx_rx_inj_pty_err)             //-- input 
 ,.tx_rx_tsm                       (tx_rx_tsm[2:0])               //--  input [2:0]
 ,.dl2tl_fast_act_info             (dl2tl_fast_act_info[34:0])     //-- output[34:0]
 ,.dl2tl_fast_act_info_l           (dl2tl_fast_act_info_l[34:0])     //-- output[34:0]
 ,.dl2tl_fast_act_info_r           (dl2tl_fast_act_info_r[34:0])     //-- output[34:0]
 ,.mn_agn_dead_cycle_reset         (mn_agn_dead_cycle_reset)       //-- input
);

dlc_omi_rx_main main (

  .agn_mn_flit                   (agn_mn_flit[127:0])           //--  input[127:0]
 ,.ln_all_valid                  (ln_all_valid)                 //--  input 
 ,.agn_mn_flit_vld               (agn_mn_flit_vld)              //--  input 
 ,.agn_mn_flit_pty               (agn_mn_flit_pty[15:0])        //--  input[15:0]
 ,.dl2tl_idle_transition         (dl2tl_idle_transition)   
 ,.dl2tl_idle_transition_l       (dl2tl_idle_transition_l)   
 ,.dl2tl_idle_transition_r       (dl2tl_idle_transition_r)   
 ,.trn_mn_retrain                (trn_agn_retrain)              //--  input 
 ,.trn_mn_trained                (trn_mn_trained)               //--  input   
 ,.trn_mn_short_idle_enable      (tx_rx_enable_short_idle)      //--  input
 ,.dl2tl_flit_vld                (dl2tl_flit_vld)               //--  output
 ,.dl2tl_flit_error              (dl2tl_flit_error)             //--  output
 ,.dl2tl_flit_badcrc             (dl2tl_flit_badcrc)            //--  output
 ,.dl2tl_flit_data               (dl2tl_flit_data[127:0])       //--  output[127:0]
 ,.dl2tl_flit_pty                (dl2tl_flit_pty[15:0])         //--  output[15:0]
 ,.dl2tl_flit_act                (dl2tl_flit_act)               //--  output[15:0]
 ,.rx_reset_n                    (rx_reset_n)                   //--  input
 ,.chip_reset                    (chip_reset)                   //--  input
 ,.global_reset_control          (global_reset_control)         //--  input
 ,.omi_enable                    (omi_enable)                   //--  input
 ,.rx_tx_crc_error               (rx_tx_crc_error)              //--  output
 ,.rx_tx_nack                    (rx_tx_nack)                   //--  output
 ,.rx_tx_rx_ack_inc              (rx_tx_rx_ack_inc[3:0])        //--  output[3:0]
 ,.rx_tx_tx_ack_rtn              (rx_tx_tx_ack_rtn[4:0])        //--  output[4:0]
 ,.rx_tx_tx_ack_ptr_vld          (rx_tx_tx_ack_ptr_vld)         //--  output
 ,.rx_tx_tx_ack_ptr              (rx_tx_tx_ack_ptr[11:0])       //--  output[11:0]
 ,.rx_tx_rmt_error               (rx_tx_rmt_error[7:0])         //--  output[7:0]
 ,.rx_tx_rmt_message             (rx_tx_rmt_message[63:0])      //--  output[63:0]
 ,.rx_tx_recal_status            (rx_tx_recal_status[1:0])      //--  output[1:0]
 ,.rx_tx_pm_status               (rx_tx_pm_status[3:0])         //--  output[3:0]
 ,.dl_clk                        (dl_clk)                       //--  input
 ,.rx_tx_mn_trn_in_replay        (rx_tx_mn_trn_in_replay)       //--  output 
 ,.rx_tx_data_flt                (rx_tx_data_flt)               //--  output
 ,.rx_tx_ctl_flt                 (rx_tx_ctl_flt)                //--  output
 ,.rx_tx_rpl_flt                 (rx_tx_rpl_flt)                //--  output
 ,.rx_tx_idle_flt                (rx_tx_idle_flt)               //--  output
 ,.rx_tx_ill_rl                  (rx_tx_ill_rl)                 //--  output     
 ,.rx_tx_dbg_rx_info             (rx_tx_dbg_rx_info[87:0])      //--  output[87:0]
 ,.tx_rx_macro_dbg_sel           (tx_rx_macro_dbg_sel[3:0])     //--  input[3:0] :  Connect
 ,.tx_rx_tsm                     (tx_rx_tsm[2:0])               //--  input [2:0]
 ,.agn_mn_ln_swap                (agn_mn_ln_swap)               //--  input
 ,.agn_mn_x4_mode                (agn_mn_x4_mode[1:0])          //--  input[1:0]
 ,.agn_mn_x2_mode                (agn_mn_x2_mode[1:0])          //--  input[1:0]
 ,.mn_agn_dead_cycle_reset       (mn_agn_dead_cycle_reset)      //--  output
);

dlc_omi_rx_train trn (
  .dl2tl_link_up                 (rx_link_up)                      //--  output
 ,.dl2tl_dead_cycle              (dl2tl_dead_cycle)                //--  output
 ,.ln0_valid                     (ln0_valid)                       //--  input
 ,.ln1_valid                     (ln1_valid)                       //--  input
 ,.ln2_valid                     (ln2_valid)                       //--  input
 ,.ln3_valid                     (ln3_valid)                       //--  input
 ,.ln4_valid                     (ln4_valid)                       //--  input
 ,.ln5_valid                     (ln5_valid)                       //--  input
 ,.ln6_valid                     (ln6_valid)                       //--  input
 ,.ln7_valid                     (ln7_valid)                       //--  input
 ,.ln0_data                      (ln0_trn_data[15:0])              //--  input[15:0]
 ,.ln1_data                      (ln1_trn_data[15:0])              //--  input[15:0]
 ,.ln2_data                      (ln2_trn_data[15:0])              //--  input[15:0]
 ,.ln3_data                      (ln3_trn_data[15:0])              //--  input[15:0]
 ,.ln4_data                      (ln4_trn_data[15:0])              //--  input[15:0]
 ,.ln5_data                      (ln5_trn_data[15:0])              //--  input[15:0]
 ,.ln6_data                      (ln6_trn_data[15:0])              //--  input[15:0]
 ,.ln7_data                      (ln7_trn_data[15:0])              //--  input[15:0]
 ,.ln_data_sync_hdr              (ln_data_sync_hdr[7:0])           //--  input[7:0]
 ,.ln_ctl_sync_hdr               (ln_ctl_sync_hdr[7:0])            //--  input[7:0]
 ,.ln_rx_slow_pat_a              (ln_rx_slow_pat_a[7:0])           //--  input[7:0]
 ,.ln_pattern_a                  (ln_pattern_a[7:0])               //--  input[7:0]
 ,.ln_pattern_b                  (ln_pattern_b[7:0])               //--  input[7:0]
 ,.ln_sync                       (ln_sync[7:0])                    //--  input[7:0]
 ,.ln_block_lock                 (ln_block_lock[7:0])              //--  input[7:0]
 ,.ln_TS1                        (ln_TS1[7:0])                     //--  input[7:0]
 ,.ln_TS2                        (ln_TS2[7:0])                     //--  input[7:0]
 ,.ln_TS3                        (ln_TS3[7:0])                     //--  input[7:0] 
 ,.ln_retrain                    (ln_retrain)                      //--  output
 ,.ln_deskew_enable              (ln_deskew_enable)                //--  output
 ,.ln_deskew_hold                (ln_deskew_hold[7:0])             //--  input[7:0]
 ,.ln_deskew_found               (ln_deskew_found[7:0])            //--  input[7:0]
 ,.ln_deskew_overflow            (ln_deskew_overflow[7:0])         //--  input[7:0]
 ,.ln_deskew_valid               (ln_deskew_valid[7:0])            //--  input[7:0]
 ,.ln_all_valid                  (ln_all_valid)                    //--  output
 ,.ln_deskew_reset               (ln_deskew_reset)                 //--  output
 ,.ln_phy_training               (ln_phy_training)                 //--  output                      
 ,.ln_phy_init_done              (ln_phy_init_done[7:0])           //--  output                      
 ,.ln_ts_training                (ln_ts_training)                  //--  output
 ,.ln_disabled                   (ln_disabled[7:0])                //--  output
 ,.tx_rx_reset_n                 (tx_rx_reset_n)                   //--  input
 ,.rx_reset_n                    (rx_reset_n)                      //--  output
 ,.chip_reset                    (chip_reset)                      //--  input
 ,.global_reset_control          (global_reset_control)            //--  input
 ,.tx_rx_tsm                     (tx_rx_tsm[2:0])                  //--  input[2:0]    
 ,.tx_rx_phy_init_done           (tx_rx_phy_init_done)             //--  input[7:0]
 ,.rx_tx_version_number          (rx_tx_version_number)            //--  output[5:0]
 ,.rx_tx_slow_clock              (rx_tx_slow_clock)                //--  output
 ,.rx_tx_deskew_overflow         (rx_tx_deskew_overflow)           //--  output
 ,.rx_tx_train_status            (rx_tx_train_status[72:0])        //--  output[72:0] 
 ,.rx_tx_disabled_rx_lanes       (rx_tx_disabled_rx_lanes[7:0])    //--  output[7:0]
 ,.rx_tx_disabled_tx_lanes       (rx_tx_disabled_tx_lanes[7:0])    //--  output[7:0]
 ,.rx_tx_ts_valid                (rx_tx_ts_valid)                  //--  output
 ,.rx_tx_ts_good_lanes           (rx_tx_ts_good_lanes[15:0])       //--  output[15:0]
 ,.rx_tx_deskew_config_valid     (rx_tx_deskew_config_valid)       //--  output [18:0]
 ,.rx_tx_deskew_config           (rx_tx_deskew_config[18:0])       //--  output
 ,.rx_tx_tx_ordering             (rx_tx_tx_ordering)               //--  output
 ,.rx_tx_rem_supported_widths    (rx_tx_rem_supported_widths[3:0]) //--  output[3:0]
 ,.rx_tx_trained_mode            (rx_tx_trained_mode[3:0])         //--  output[3:0]
 ,.tx_rx_cfg_supported_widths    (tx_rx_cfg_supported_widths[3:0]) //--  input[3:0]
 ,.rx_tx_tx_lane_swap            (rx_tx_tx_lane_swap)              //--  output
 ,.rx_tx_rem_PM_enable           (rx_tx_rem_PM_enable)             //--  output
 ,.rx_tx_rx_lane_reverse         (rx_tx_rx_lane_reverse)           //--  output
 ,.rx_tx_lost_data_sync          (rx_tx_lost_data_sync)            //--  output
 ,.rx_tx_trn_dbg                 (rx_tx_trn_dbg[87:0])             //--  output [87:0]
 ,.tx_rx_macro_dbg_sel           (tx_rx_macro_dbg_sel[3:0])        //--  input [3:0]
 ,.rx_tx_training_sync_hdr       (rx_tx_training_sync_hdr)         //--  output
 ,.tx_rx_half_width              (tx_rx_half_width)                //--  input
 ,.tx_rx_quarter_width           (tx_rx_quarter_width)             //--  input
 ,.tx_rx_start_retrain           (tx_rx_start_retrain)             //--  input
 ,.tx_rx_cfg_disable_rx_lanes    (tx_rx_cfg_disable_rx_lanes[7:0]) //--  input[7:0]
 ,.tx_rx_PM_rx_lanes_disable     (tx_rx_PM_rx_lanes_disable[7:0])  //--  input[7:0]
 ,.tx_rx_PM_rx_lanes_enable      (tx_rx_PM_rx_lanes_enable[7:0])   //--  input[7:0]
 ,.tx_rx_PM_deskew_reset         (tx_rx_PM_deskew_reset)           //--  input
 ,.tx_rx_psave_sts_off           (tx_rx_psave_sts_off)             //--  input
 ,.tx_rx_retrain_not_due2_PM     (tx_rx_retrain_not_due2_PM)       //--  input
 ,.tx_rx_cfg_version             (tx_rx_cfg_version[5:0])          //--  input
 ,.tx_rx_sim_only_fast_train     (tx_rx_sim_only_fast_train)       //--  input
 ,.tx_rx_sim_only_request_ln_rev (tx_rx_sim_only_request_ln_rev)   //--  input
 ,.trn_mn_trained                (trn_mn_trained)                  //--  output  
 ,.trn_agn_trained               (trn_agn_trained)                 //--  output
 ,.trn_agn_retrain               (trn_agn_retrain)                 //--  output
 ,.trn_ln_trained                (trn_ln_trained)                  //--  output
 ,.trn_agn_x4_mode               (trn_agn_x4_mode[1:0])            //--  output[1:0]
 ,.trn_agn_x2_mode               (trn_agn_x2_mode[1:0])            //--  output
 ,.trn_agn_ln_swap               (trn_agn_ln_swap)                 //--  output
 ,.reg_dl_1us_tick               (reg_dl_1us_tick)                 //--  input
 ,.omi_enable                    (omi_enable)                      //--  input
 ,.dl_clk                        (dl_clk)                          //--  input
);


generate
if (RX_EQ_TX_CLK == 1)

dlc_omi_rx_lane_shift ln0 (
  .phy_dl_clock                  (phy_dl_clock_0)                //--  input
 ,.phy_dl_lane                   (phy_dl_lane_0[15:0])           //--  input[15:0]
 ,.phy_dl_iobist_reset           (phy_dl_iobist_reset)           //--  input
 ,.rx_tx_iobist_prbs_error       (rx_tx_iobist_prbs_error[0])    //--  output
 ,.ln_valid                      (ln0_valid)                     //--  output
 ,.ln_data                       (ln0_data[15:0])                //--  output[15:0]
 ,.ln_trn_data                   (ln0_trn_data[15:0])            //--  output[15:0]
 ,.ln_parity                     (ln0_parity[1:0])               //--  output[1:0]
 ,.ln_data_sync_hdr              (ln_data_sync_hdr[0])           //--  output
 ,.ln_ctl_sync_hdr               (ln_ctl_sync_hdr[0])            //--  output
 ,.ln_rx_slow_pat_a              (ln_rx_slow_pat_a[0])           //--  output
 ,.ln_pattern_a                  (ln_pattern_a[0])               //--  output
 ,.ln_pattern_b                  (ln_pattern_b[0])               //--  output
 ,.ln_sync                       (ln_sync[0])                    //--  output
 ,.ln_block_lock                 (ln_block_lock[0])              //--  output
 ,.ln_TS1                        (ln_TS1[0])                     //--  output
 ,.ln_TS2                        (ln_TS2[0])                     //--  output
 ,.ln_TS3                        (ln_TS3[0])                     //--  output
 ,.ln_retrain                    (ln_retrain)                    //--  input
 ,.ln_deskew_enable              (ln_deskew_enable)              //--  input
 ,.ln_deskew_found               (ln_deskew_found[0])            //--  output
 ,.ln_deskew_hold                (ln_deskew_hold[0])             //--  output
 ,.ln_deskew_overflow            (ln_deskew_overflow[0])         //--  output
 ,.ln_deskew_valid               (ln_deskew_valid[0])            //--  output
 ,.ln_all_valid                  (ln_all_valid)                  //--  input
 ,.ln_deskew_reset               (ln_deskew_reset)               //--  input
 ,.ln_phy_training               (ln_phy_training)               //--  input
 ,.ln_phy_init_done              (ln_phy_init_done[0])           //--  input                        
 ,.ln_ts_training                (ln_ts_training)                //--  input
 ,.ln_disabled                   (ln_disabled[0])                //--  input
 ,.ln_trained                    (trn_ln_trained)                //--  input
 ,.rx_tx_EDPL_max_cnt            (rx_tx_EDPL_max_cnts[7:0])      //--  output [7:0]
 ,.rx_tx_EDPL_error              (rx_tx_EDPL_errors[0])          //--  output
 ,.rx_tx_EDPL_thres_reached      (rx_tx_EDPL_thres_reached[0])   //--  output
 ,.tx_rx_EDPL_cfg                (tx_rx_EDPL_cfg[4:0])           //--  input  [4:0]
 ,.tx_rx_cfg_patA_length         (tx_rx_cfg_patA_length)         //--  input [1:0]
 ,.tx_rx_cfg_patB_length         (tx_rx_cfg_patB_length)         //--  input [1:0]
 ,.tx_rx_cfg_patA_hyst           (tx_rx_cfg_patA_hyst)           //--  input [3:0]
 ,.tx_rx_cfg_patB_hyst           (tx_rx_cfg_patB_hyst)           //--  input [3:0]
 ,.tx_rx_rx_BEI_inject           (tx_rx_rx_BEI_inject[0])        //--  input
 ,.tx_rx_cfg_sync_mode           (tx_rx_cfg_sync_mode)           //--  input
 ,.reg_dl_edpl_max_count_reset   (reg_dl_edpl_max_count_reset)   //--  input
 ,.rx_reset_n                    (rx_reset_n)                    //--  input
 ,.chip_reset                    (chip_reset)                    //-- input
 ,.global_reset_control          (global_reset_control)          //-- input
 ,.omi_enable                    (omi_enable)                    //--  input
 ,.dl_clk                        (dl_clk)                        //--  input
);

else // Host version with async crossing
dlc_omi_rx_lane ln0 (
  .phy_dl_clock                  (phy_dl_clock_0)                //--  input
 ,.phy_dl_lane                   (phy_dl_lane_0[15:0])           //--  input[15:0]
 ,.phy_dl_iobist_reset           (phy_dl_iobist_reset)           //--  input
 ,.lbist_en_dc                   (lbist_en_dc)                   //--  input
 ,.rx_tx_iobist_prbs_error       (rx_tx_iobist_prbs_error[0])    //--  output
 ,.ln_valid                      (ln0_valid)                     //--  output
 ,.ln_data                       (ln0_data[15:0])                //--  output[15:0]
 ,.ln_trn_data                   (ln0_trn_data[15:0])            //--  output[15:0]
 ,.ln_parity                     (ln0_parity[1:0])               //--  output[1:0]
 ,.ln_data_sync_hdr              (ln_data_sync_hdr[0])           //--  output
 ,.ln_ctl_sync_hdr               (ln_ctl_sync_hdr[0])            //--  output
 ,.ln_rx_slow_pat_a              (ln_rx_slow_pat_a[0])           //--  output
 ,.ln_pattern_a                  (ln_pattern_a[0])               //--  output
 ,.ln_pattern_b                  (ln_pattern_b[0])               //--  output
 ,.ln_sync                       (ln_sync[0])                    //--  output
 ,.ln_block_lock                 (ln_block_lock[0])              //--  output
 ,.ln_TS1                        (ln_TS1[0])                     //--  output
 ,.ln_TS2                        (ln_TS2[0])                     //--  output
 ,.ln_TS3                        (ln_TS3[0])                     //--  output
 ,.ln_retrain                    (ln_retrain)                    //--  input
 ,.ln_deskew_enable              (ln_deskew_enable)              //--  input
 ,.ln_deskew_found               (ln_deskew_found[0])            //--  output
 ,.ln_deskew_hold                (ln_deskew_hold[0])             //--  output
 ,.ln_deskew_overflow            (ln_deskew_overflow[0])         //--  output
 ,.ln_deskew_valid               (ln_deskew_valid[0])            //--  output
 ,.ln_all_valid                  (ln_all_valid)                  //--  input
 ,.ln_deskew_reset               (ln_deskew_reset)               //--  input
 ,.ln_phy_training               (ln_phy_training)               //--  input
 ,.ln_phy_init_done              (ln_phy_init_done[0])           //--  input                        
 ,.ln_ts_training                (ln_ts_training)                //--  input
 ,.ln_disabled                   (ln_disabled[0])                //--  input
 ,.ln_trained                    (trn_ln_trained)                //--  input
 ,.rx_tx_EDPL_max_cnt            (rx_tx_EDPL_max_cnts[7:0])      //--  output [7:0]
 ,.rx_tx_EDPL_error              (rx_tx_EDPL_errors[0])          //--  output
 ,.rx_tx_EDPL_thres_reached      (rx_tx_EDPL_thres_reached[0])   //--  output
 ,.tx_rx_EDPL_cfg                (tx_rx_EDPL_cfg[4:0])           //--  input  [4:0]
 ,.tx_rx_cfg_patA_length         (tx_rx_cfg_patA_length)         //--  input [1:0]
 ,.tx_rx_cfg_patB_length         (tx_rx_cfg_patB_length)         //--  input [1:0]
 ,.tx_rx_cfg_patA_hyst           (tx_rx_cfg_patA_hyst)           //--  input [3:0]
 ,.tx_rx_cfg_patB_hyst           (tx_rx_cfg_patB_hyst)           //--  input [3:0]
 ,.tx_rx_rx_BEI_inject           (tx_rx_rx_BEI_inject[0])        //--  input
 ,.tx_rx_cfg_sync_mode           (tx_rx_cfg_sync_mode)           //--  input
 ,.reg_dl_edpl_max_count_reset   (reg_dl_edpl_max_count_reset)   //--  input
 ,.rx_reset_n                    (rx_reset_n)                    //--  input
 ,.chip_reset                    (chip_reset)                    //-- input
 ,.global_reset_control          (global_reset_control)          //-- input
 ,.omi_enable                    (omi_enable)                    //--  input
 ,.dl_clk                        (dl_clk)                        //--  input
);
endgenerate

generate
if (RX_EQ_TX_CLK == 1)

dlc_omi_rx_lane_shift ln1 (
  .phy_dl_clock                  (phy_dl_clock_1)                //--  input
 ,.phy_dl_lane                   (phy_dl_lane_1[15:0])           //--  input[15:0]
 ,.phy_dl_iobist_reset           (phy_dl_iobist_reset)           //--  input
 ,.rx_tx_iobist_prbs_error       (rx_tx_iobist_prbs_error[1])    //--  output
 ,.ln_valid                      (ln1_valid)                     //--  output
 ,.ln_data                       (ln1_data[15:0])                //--  output[15:0]
 ,.ln_trn_data                   (ln1_trn_data[15:0])            //--  output[15:0]
 ,.ln_parity                     (ln1_parity[1:0])               //--  output[1:0]
 ,.ln_data_sync_hdr              (ln_data_sync_hdr[1])           //--  output
 ,.ln_ctl_sync_hdr               (ln_ctl_sync_hdr[1])            //--  output
 ,.ln_rx_slow_pat_a              (ln_rx_slow_pat_a[1])           //--  output
 ,.ln_pattern_a                  (ln_pattern_a[1])               //--  output
 ,.ln_pattern_b                  (ln_pattern_b[1])               //--  output
 ,.ln_sync                       (ln_sync[1])                    //--  output
 ,.ln_block_lock                 (ln_block_lock[1])              //--  output
 ,.ln_TS1                        (ln_TS1[1])                     //--  output
 ,.ln_TS2                        (ln_TS2[1])                     //--  output
 ,.ln_TS3                        (ln_TS3[1])                     //--  output
 ,.ln_retrain                    (ln_retrain)                    //--  input
 ,.ln_deskew_enable              (ln_deskew_enable)              //--  input
 ,.ln_deskew_found               (ln_deskew_found[1])            //--  output
 ,.ln_deskew_hold                (ln_deskew_hold[1])             //--  ouput
 ,.ln_deskew_overflow            (ln_deskew_overflow[1])         //--  output
 ,.ln_deskew_valid               (ln_deskew_valid[1])            //--  output
 ,.ln_all_valid                  (ln_all_valid)                  //--  inpu
 ,.ln_deskew_reset               (ln_deskew_reset)               //--  input
 ,.ln_phy_training               (ln_phy_training)               //--  input
 ,.ln_phy_init_done              (ln_phy_init_done[1])           //--  input
 ,.ln_ts_training                (ln_ts_training)                //--  input
 ,.ln_disabled                   (ln_disabled[1])                //--  input
 ,.ln_trained                    (trn_ln_trained)                //--  input
 ,.rx_tx_EDPL_max_cnt            (rx_tx_EDPL_max_cnts[15:8])     //--  output [7:0]
 ,.rx_tx_EDPL_error              (rx_tx_EDPL_errors[1])          //--  output
 ,.rx_tx_EDPL_thres_reached      (rx_tx_EDPL_thres_reached[1])   //--  output
 ,.tx_rx_EDPL_cfg                (tx_rx_EDPL_cfg[4:0])           //--  input  [4:0]
 ,.tx_rx_cfg_patA_length         (tx_rx_cfg_patA_length)         //--  input [1:0]
 ,.tx_rx_cfg_patB_length         (tx_rx_cfg_patB_length)         //--  input [1:0]
 ,.tx_rx_cfg_patA_hyst           (tx_rx_cfg_patA_hyst)           //--  input [3:0]
 ,.tx_rx_cfg_patB_hyst           (tx_rx_cfg_patB_hyst)           //--  input [3:0]
 ,.tx_rx_rx_BEI_inject           (tx_rx_rx_BEI_inject[1])        //--  input
 ,.tx_rx_cfg_sync_mode           (tx_rx_cfg_sync_mode)           //--  input
 ,.reg_dl_edpl_max_count_reset   (reg_dl_edpl_max_count_reset)   //--  input
 ,.rx_reset_n                    (rx_reset_n)                    //--  input
 ,.chip_reset                    (chip_reset)                    //-- input
 ,.global_reset_control          (global_reset_control)          //-- input
 ,.omi_enable                    (omi_enable)                    //--  input
 ,.dl_clk                        (dl_clk)                        //--  input
);

else

dlc_omi_rx_lane ln1 (
  .phy_dl_clock                  (phy_dl_clock_1)                //--  input
 ,.phy_dl_lane                   (phy_dl_lane_1[15:0])           //--  input[15:0]
 ,.phy_dl_iobist_reset           (phy_dl_iobist_reset)           //--  input
 ,.lbist_en_dc                   (lbist_en_dc)                   //--  input
 ,.rx_tx_iobist_prbs_error       (rx_tx_iobist_prbs_error[1])    //--  output
 ,.ln_valid                      (ln1_valid)                     //--  output
 ,.ln_data                       (ln1_data[15:0])                //--  output[15:0]
 ,.ln_trn_data                   (ln1_trn_data[15:0])            //--  output[15:0]
 ,.ln_parity                     (ln1_parity[1:0])               //--  output[1:0]
 ,.ln_data_sync_hdr              (ln_data_sync_hdr[1])           //--  output
 ,.ln_ctl_sync_hdr               (ln_ctl_sync_hdr[1])            //--  output
 ,.ln_rx_slow_pat_a              (ln_rx_slow_pat_a[1])           //--  output
 ,.ln_pattern_a                  (ln_pattern_a[1])               //--  output
 ,.ln_pattern_b                  (ln_pattern_b[1])               //--  output
 ,.ln_sync                       (ln_sync[1])                    //--  output
 ,.ln_block_lock                 (ln_block_lock[1])              //--  output
 ,.ln_TS1                        (ln_TS1[1])                     //--  output
 ,.ln_TS2                        (ln_TS2[1])                     //--  output
 ,.ln_TS3                        (ln_TS3[1])                     //--  output
 ,.ln_retrain                    (ln_retrain)                    //--  input
 ,.ln_deskew_enable              (ln_deskew_enable)              //--  input
 ,.ln_deskew_found               (ln_deskew_found[1])            //--  output
 ,.ln_deskew_hold                (ln_deskew_hold[1])             //--  ouput
 ,.ln_deskew_overflow            (ln_deskew_overflow[1])         //--  output
 ,.ln_deskew_valid               (ln_deskew_valid[1])            //--  output
 ,.ln_all_valid                  (ln_all_valid)                  //--  inpu
 ,.ln_deskew_reset               (ln_deskew_reset)               //--  input
 ,.ln_phy_training               (ln_phy_training)               //--  input
 ,.ln_phy_init_done              (ln_phy_init_done[1])           //--  input
 ,.ln_ts_training                (ln_ts_training)                //--  input
 ,.ln_disabled                   (ln_disabled[1])                //--  input
 ,.ln_trained                    (trn_ln_trained)                //--  input
 ,.rx_tx_EDPL_max_cnt            (rx_tx_EDPL_max_cnts[15:8])     //--  output [7:0]
 ,.rx_tx_EDPL_error              (rx_tx_EDPL_errors[1])          //--  output
 ,.rx_tx_EDPL_thres_reached      (rx_tx_EDPL_thres_reached[1])   //--  output
 ,.tx_rx_EDPL_cfg                (tx_rx_EDPL_cfg[4:0])           //--  input  [4:0]
 ,.tx_rx_cfg_patA_length         (tx_rx_cfg_patA_length)         //--  input [1:0]
 ,.tx_rx_cfg_patB_length         (tx_rx_cfg_patB_length)         //--  input [1:0]
 ,.tx_rx_cfg_patA_hyst           (tx_rx_cfg_patA_hyst)           //--  input [3:0]
 ,.tx_rx_cfg_patB_hyst           (tx_rx_cfg_patB_hyst)           //--  input [3:0]
 ,.tx_rx_rx_BEI_inject           (tx_rx_rx_BEI_inject[1])        //--  input
 ,.tx_rx_cfg_sync_mode           (tx_rx_cfg_sync_mode)           //--  input
 ,.reg_dl_edpl_max_count_reset   (reg_dl_edpl_max_count_reset)   //--  input
 ,.rx_reset_n                    (rx_reset_n)                    //--  input
 ,.chip_reset                    (chip_reset)                    //-- input
 ,.global_reset_control          (global_reset_control)          //-- input
 ,.omi_enable                    (omi_enable)                    //--  input
 ,.dl_clk                        (dl_clk)                        //--  input
);
endgenerate

generate
if (RX_EQ_TX_CLK == 1)

dlc_omi_rx_lane_shift ln2 (
  .phy_dl_clock                  (phy_dl_clock_2)                //--  input
 ,.phy_dl_lane                   (phy_dl_lane_2[15:0])           //--  input[15:0]
 ,.phy_dl_iobist_reset           (phy_dl_iobist_reset)           //--  input
 ,.rx_tx_iobist_prbs_error       (rx_tx_iobist_prbs_error[2])    //--  output
 ,.ln_valid                      (ln2_valid)                     //--  output
 ,.ln_data                       (ln2_data[15:0])                //--  output[15:0]
 ,.ln_data_clone_l               (ln2_data_clone_l[15:0])        //--  output[15:0]
 ,.ln_data_clone_r               (ln2_data_clone_r[15:0])        //--  output[15:0]
 ,.ln_data_clone_c               (ln2_data_clone_c[15:0])        //--  output[15:0]
 ,.ln_trn_data                   (ln2_trn_data[15:0])            //--  output[15:0]
 ,.ln_parity                     (ln2_parity[1:0])               //--  output[1:0]
 ,.ln_data_sync_hdr              (ln_data_sync_hdr[2])           //--  output
 ,.ln_ctl_sync_hdr               (ln_ctl_sync_hdr[2])            //--  output
 ,.ln_rx_slow_pat_a              (ln_rx_slow_pat_a[2])           //--  output
 ,.ln_pattern_a                  (ln_pattern_a[2])               //--  output
 ,.ln_pattern_b                  (ln_pattern_b[2])               //--  output
 ,.ln_sync                       (ln_sync[2])                    //--  output
 ,.ln_block_lock                 (ln_block_lock[2])              //--  output
 ,.ln_TS1                        (ln_TS1[2])                     //--  output
 ,.ln_TS2                        (ln_TS2[2])                     //--  output
 ,.ln_TS3                        (ln_TS3[2])                     //--  output
 ,.ln_retrain                    (ln_retrain)                    //--  input
 ,.ln_deskew_enable              (ln_deskew_enable)              //--  input
 ,.ln_deskew_found               (ln_deskew_found[2])            //--  output
 ,.ln_deskew_hold                (ln_deskew_hold[2])             //--  ouput
 ,.ln_deskew_overflow            (ln_deskew_overflow[2])         //--  output
 ,.ln_deskew_valid               (ln_deskew_valid[2])            //--  output 
 ,.ln_all_valid                  (ln_all_valid)                  //--  input
 ,.ln_deskew_reset               (ln_deskew_reset)               //--  input
 ,.ln_phy_training               (ln_phy_training)               //--  input
 ,.ln_phy_init_done              (ln_phy_init_done[2])           //--  input
 ,.ln_ts_training                (ln_ts_training)                //--  input
 ,.ln_disabled                   (ln_disabled[2])                //--  input
 ,.ln_trained                    (trn_ln_trained)                //--  input
 ,.rx_tx_EDPL_max_cnt            (rx_tx_EDPL_max_cnts[23:16])    //--  output [7:0]
 ,.rx_tx_EDPL_error              (rx_tx_EDPL_errors[2])          //--  output
 ,.rx_tx_EDPL_thres_reached      (rx_tx_EDPL_thres_reached[2])   //--  output
 ,.tx_rx_EDPL_cfg                (tx_rx_EDPL_cfg[4:0])           //--  input  [4:0]
 ,.tx_rx_cfg_patA_length         (tx_rx_cfg_patA_length)         //--  input [1:0]
 ,.tx_rx_cfg_patB_length         (tx_rx_cfg_patB_length)         //--  input [1:0]
 ,.tx_rx_cfg_patA_hyst           (tx_rx_cfg_patA_hyst)           //--  input [3:0]
 ,.tx_rx_cfg_patB_hyst           (tx_rx_cfg_patB_hyst)           //--  input [3:0]
 ,.tx_rx_rx_BEI_inject           (tx_rx_rx_BEI_inject[2])        //--  input
 ,.tx_rx_cfg_sync_mode           (tx_rx_cfg_sync_mode)           //--  input
 ,.reg_dl_edpl_max_count_reset   (reg_dl_edpl_max_count_reset)   //--  input
 ,.rx_reset_n                    (rx_reset_n)                    //--  input
 ,.chip_reset                    (chip_reset)                    //-- input
 ,.global_reset_control          (global_reset_control)          //-- input
 ,.omi_enable                    (omi_enable)                    //--  input
 ,.dl_clk                        (dl_clk)                        //--  input
);

else

dlc_omi_rx_lane ln2 (
  .phy_dl_clock                  (phy_dl_clock_2)                //--  input
 ,.phy_dl_lane                   (phy_dl_lane_2[15:0])           //--  input[15:0]
 ,.phy_dl_iobist_reset           (phy_dl_iobist_reset)           //--  input
 ,.rx_tx_iobist_prbs_error       (rx_tx_iobist_prbs_error[2])    //--  output
 ,.lbist_en_dc                   (lbist_en_dc)                   //--  input
 ,.ln_valid                      (ln2_valid)                     //--  output
 ,.ln_data                       (ln2_data[15:0])                //--  output[15:0]
 ,.ln_trn_data                   (ln2_trn_data[15:0])            //--  output[15:0]
 ,.ln_parity                     (ln2_parity[1:0])               //--  output[1:0]
 ,.ln_data_sync_hdr              (ln_data_sync_hdr[2])           //--  output
 ,.ln_ctl_sync_hdr               (ln_ctl_sync_hdr[2])            //--  output
 ,.ln_rx_slow_pat_a              (ln_rx_slow_pat_a[2])           //--  output
 ,.ln_pattern_a                  (ln_pattern_a[2])               //--  output
 ,.ln_pattern_b                  (ln_pattern_b[2])               //--  output
 ,.ln_sync                       (ln_sync[2])                    //--  output
 ,.ln_block_lock                 (ln_block_lock[2])              //--  output
 ,.ln_TS1                        (ln_TS1[2])                     //--  output
 ,.ln_TS2                        (ln_TS2[2])                     //--  output
 ,.ln_TS3                        (ln_TS3[2])                     //--  output
 ,.ln_retrain                    (ln_retrain)                    //--  input
 ,.ln_deskew_enable              (ln_deskew_enable)              //--  input
 ,.ln_deskew_found               (ln_deskew_found[2])            //--  output
 ,.ln_deskew_hold                (ln_deskew_hold[2])             //--  ouput
 ,.ln_deskew_overflow            (ln_deskew_overflow[2])         //--  output
 ,.ln_deskew_valid               (ln_deskew_valid[2])            //--  output 
 ,.ln_all_valid                  (ln_all_valid)                  //--  input
 ,.ln_deskew_reset               (ln_deskew_reset)               //--  input
 ,.ln_phy_training               (ln_phy_training)               //--  input
 ,.ln_phy_init_done              (ln_phy_init_done[2])           //--  input
 ,.ln_ts_training                (ln_ts_training)                //--  input
 ,.ln_disabled                   (ln_disabled[2])                //--  input
 ,.ln_trained                    (trn_ln_trained)                //--  input
 ,.rx_tx_EDPL_max_cnt            (rx_tx_EDPL_max_cnts[23:16])    //--  output [7:0]
 ,.rx_tx_EDPL_error              (rx_tx_EDPL_errors[2])          //--  output
 ,.rx_tx_EDPL_thres_reached      (rx_tx_EDPL_thres_reached[2])   //--  output
 ,.tx_rx_EDPL_cfg                (tx_rx_EDPL_cfg[4:0])           //--  input  [4:0]
 ,.tx_rx_cfg_patA_length         (tx_rx_cfg_patA_length)         //--  input [1:0]
 ,.tx_rx_cfg_patB_length         (tx_rx_cfg_patB_length)         //--  input [1:0]
 ,.tx_rx_cfg_patA_hyst           (tx_rx_cfg_patA_hyst)           //--  input [3:0]
 ,.tx_rx_cfg_patB_hyst           (tx_rx_cfg_patB_hyst)           //--  input [3:0]
 ,.tx_rx_rx_BEI_inject           (tx_rx_rx_BEI_inject[2])        //--  input
 ,.tx_rx_cfg_sync_mode           (tx_rx_cfg_sync_mode)           //--  input
 ,.reg_dl_edpl_max_count_reset   (reg_dl_edpl_max_count_reset)   //--  input
 ,.rx_reset_n                      (rx_reset_n)                      //--  input
 ,.chip_reset                    (chip_reset)                    //-- input
 ,.global_reset_control          (global_reset_control)          //-- input
 ,.omi_enable                    (omi_enable)                    //--  input
 ,.dl_clk                        (dl_clk)                        //--  input
);
endgenerate

generate
if (RX_EQ_TX_CLK == 1)

dlc_omi_rx_lane_shift ln3 (
  .phy_dl_clock                  (phy_dl_clock_3)                //--  input
 ,.phy_dl_lane                   (phy_dl_lane_3[15:0])           //--  input[15:0]
 ,.phy_dl_iobist_reset           (phy_dl_iobist_reset)           //--  input
 ,.rx_tx_iobist_prbs_error       (rx_tx_iobist_prbs_error[3])    //--  output
 ,.ln_valid                      (ln3_valid)                     //--  output
 ,.ln_data                       (ln3_data[15:0])                //--  output[15:0]
 ,.ln_data_clone_l               (ln3_data_clone_l[15:0])        //--  output[15:0]
 ,.ln_data_clone_r               (ln3_data_clone_r[15:0])        //--  output[15:0]
 ,.ln_data_clone_c               (ln3_data_clone_c[15:0])        //--  output[15:0]
 ,.ln_trn_data                   (ln3_trn_data[15:0])            //--  output[15:0]
 ,.ln_parity                     (ln3_parity[1:0])               //--  output[1:0]
 ,.ln_data_sync_hdr              (ln_data_sync_hdr[3])           //--  output
 ,.ln_ctl_sync_hdr               (ln_ctl_sync_hdr[3])            //--  output
 ,.ln_rx_slow_pat_a              (ln_rx_slow_pat_a[3])           //--  output
 ,.ln_pattern_a                  (ln_pattern_a[3])               //--  output
 ,.ln_pattern_b                  (ln_pattern_b[3])               //--  output
 ,.ln_sync                       (ln_sync[3])                    //--  output
 ,.ln_block_lock                 (ln_block_lock[3])              //--  output
 ,.ln_TS1                        (ln_TS1[3])                     //--  output
 ,.ln_TS2                        (ln_TS2[3])                     //--  output
 ,.ln_TS3                        (ln_TS3[3])                     //--  output
 ,.ln_retrain                    (ln_retrain)                    //--  input
 ,.ln_deskew_enable              (ln_deskew_enable)              //--  input
 ,.ln_deskew_found               (ln_deskew_found[3])            //--  output
 ,.ln_deskew_hold                (ln_deskew_hold[3])             //--  ouput
 ,.ln_deskew_overflow            (ln_deskew_overflow[3])         //--  output
 ,.ln_deskew_valid               (ln_deskew_valid[3])            //--  output
 ,.ln_all_valid                  (ln_all_valid)                  //--  input
 ,.ln_deskew_reset               (ln_deskew_reset)               //--  input
 ,.ln_phy_training               (ln_phy_training)               //--  input
 ,.ln_phy_init_done              (ln_phy_init_done[3])           //--  input
 ,.ln_ts_training                (ln_ts_training)                //--  input
 ,.ln_disabled                   (ln_disabled[3])                //--  input
 ,.ln_trained                    (trn_ln_trained)                //--  input
 ,.rx_tx_EDPL_max_cnt            (rx_tx_EDPL_max_cnts[31:24])    //--  output [7:0]
 ,.rx_tx_EDPL_error              (rx_tx_EDPL_errors[3])          //--  output
 ,.rx_tx_EDPL_thres_reached      (rx_tx_EDPL_thres_reached[3])   //--  output
 ,.tx_rx_EDPL_cfg                (tx_rx_EDPL_cfg[4:0])           //--  input  [4:0]
 ,.tx_rx_cfg_patA_length         (tx_rx_cfg_patA_length)         //--  input [1:0]
 ,.tx_rx_cfg_patB_length         (tx_rx_cfg_patB_length)         //--  input [1:0]
 ,.tx_rx_cfg_patA_hyst           (tx_rx_cfg_patA_hyst)           //--  input [3:0]
 ,.tx_rx_cfg_patB_hyst           (tx_rx_cfg_patB_hyst)           //--  input [3:0]
 ,.tx_rx_rx_BEI_inject           (tx_rx_rx_BEI_inject[3])        //--  input
 ,.tx_rx_cfg_sync_mode           (tx_rx_cfg_sync_mode)           //--  input
 ,.reg_dl_edpl_max_count_reset   (reg_dl_edpl_max_count_reset)   //--  input
 ,.rx_reset_n                    (rx_reset_n)                    //--  input
 ,.chip_reset                    (chip_reset)                    //-- input
 ,.global_reset_control          (global_reset_control)          //-- input
 ,.omi_enable                    (omi_enable)                    //--  input
 ,.dl_clk                        (dl_clk)                        //--  input
);

else

dlc_omi_rx_lane ln3 (
  .phy_dl_clock                  (phy_dl_clock_3)                //--  input
 ,.phy_dl_lane                   (phy_dl_lane_3[15:0])           //--  input[15:0]
 ,.phy_dl_iobist_reset           (phy_dl_iobist_reset)           //--  input
 ,.rx_tx_iobist_prbs_error       (rx_tx_iobist_prbs_error[3])    //--  output
 ,.lbist_en_dc                   (lbist_en_dc)                   //--  input
 ,.ln_valid                      (ln3_valid)                     //--  output
 ,.ln_data                       (ln3_data[15:0])                //--  output[15:0]
 ,.ln_trn_data                   (ln3_trn_data[15:0])            //--  output[15:0]
 ,.ln_parity                     (ln3_parity[1:0])               //--  output[1:0]
 ,.ln_data_sync_hdr              (ln_data_sync_hdr[3])           //--  output
 ,.ln_ctl_sync_hdr               (ln_ctl_sync_hdr[3])            //--  output
 ,.ln_rx_slow_pat_a              (ln_rx_slow_pat_a[3])           //--  output
 ,.ln_pattern_a                  (ln_pattern_a[3])               //--  output
 ,.ln_pattern_b                  (ln_pattern_b[3])               //--  output
 ,.ln_sync                       (ln_sync[3])                    //--  output
 ,.ln_block_lock                 (ln_block_lock[3])              //--  output
 ,.ln_TS1                        (ln_TS1[3])                     //--  output
 ,.ln_TS2                        (ln_TS2[3])                     //--  output
 ,.ln_TS3                        (ln_TS3[3])                     //--  output
 ,.ln_retrain                    (ln_retrain)                    //--  input
 ,.ln_deskew_enable              (ln_deskew_enable)              //--  input
 ,.ln_deskew_found               (ln_deskew_found[3])            //--  output
 ,.ln_deskew_hold                (ln_deskew_hold[3])             //--  ouput
 ,.ln_deskew_overflow            (ln_deskew_overflow[3])         //--  output
 ,.ln_deskew_valid               (ln_deskew_valid[3])            //--  output
 ,.ln_all_valid                  (ln_all_valid)                  //--  input
 ,.ln_deskew_reset               (ln_deskew_reset)               //--  input
 ,.ln_phy_training               (ln_phy_training)               //--  input
 ,.ln_phy_init_done              (ln_phy_init_done[3])           //--  input
 ,.ln_ts_training                (ln_ts_training)                //--  input
 ,.ln_disabled                   (ln_disabled[3])                //--  input
 ,.ln_trained                    (trn_ln_trained)                //--  input
 ,.rx_tx_EDPL_max_cnt            (rx_tx_EDPL_max_cnts[31:24])    //--  output [7:0]
 ,.rx_tx_EDPL_error              (rx_tx_EDPL_errors[3])          //--  output
 ,.rx_tx_EDPL_thres_reached      (rx_tx_EDPL_thres_reached[3])   //--  output
 ,.tx_rx_EDPL_cfg                (tx_rx_EDPL_cfg[4:0])           //--  input  [4:0]
 ,.tx_rx_cfg_patA_length         (tx_rx_cfg_patA_length)         //--  input [1:0]
 ,.tx_rx_cfg_patB_length         (tx_rx_cfg_patB_length)         //--  input [1:0]
 ,.tx_rx_cfg_patA_hyst           (tx_rx_cfg_patA_hyst)           //--  input [3:0]
 ,.tx_rx_cfg_patB_hyst           (tx_rx_cfg_patB_hyst)           //--  input [3:0]
 ,.tx_rx_rx_BEI_inject           (tx_rx_rx_BEI_inject[3])        //--  input
 ,.tx_rx_cfg_sync_mode           (tx_rx_cfg_sync_mode)           //--  input
 ,.reg_dl_edpl_max_count_reset   (reg_dl_edpl_max_count_reset)   //--  input
 ,.rx_reset_n                    (rx_reset_n)                    //--  input
 ,.chip_reset                    (chip_reset)                    //-- input
 ,.global_reset_control          (global_reset_control)          //-- input
 ,.omi_enable                    (omi_enable)                    //--  input
 ,.dl_clk                        (dl_clk)                        //--  input
);
endgenerate

generate
if (RX_EQ_TX_CLK == 1)

dlc_omi_rx_lane_shift ln4 (
  .phy_dl_clock                  (phy_dl_clock_4)                //--  input
 ,.phy_dl_lane                   (phy_dl_lane_4[15:0])           //--  input[15:0]
 ,.phy_dl_iobist_reset           (phy_dl_iobist_reset)           //--  input
 ,.rx_tx_iobist_prbs_error       (rx_tx_iobist_prbs_error[4])    //--  output
 ,.ln_valid                      (ln4_valid)                     //--  output
 ,.ln_data                       (ln4_data[15:0])                //--  output[15:0]
 ,.ln_data_clone_l               (ln4_data_clone_l[15:0])        //--  output[15:0]
 ,.ln_data_clone_r               (ln4_data_clone_r[15:0])        //--  output[15:0]
 ,.ln_data_clone_c               (ln4_data_clone_c[15:0])        //--  output[15:0]
 ,.ln_trn_data                   (ln4_trn_data[15:0])            //--  output[15:0]
 ,.ln_parity                     (ln4_parity[1:0])               //--  output[1:0]
 ,.ln_data_sync_hdr              (ln_data_sync_hdr[4])           //--  output
 ,.ln_ctl_sync_hdr               (ln_ctl_sync_hdr[4])            //--  output
 ,.ln_rx_slow_pat_a              (ln_rx_slow_pat_a[4])           //--  output
 ,.ln_pattern_a                  (ln_pattern_a[4])               //--  output
 ,.ln_pattern_b                  (ln_pattern_b[4])               //--  output
 ,.ln_sync                       (ln_sync[4])                    //--  output
 ,.ln_block_lock                 (ln_block_lock[4])              //--  output
 ,.ln_TS1                        (ln_TS1[4])                     //--  output
 ,.ln_TS2                        (ln_TS2[4])                     //--  output
 ,.ln_TS3                        (ln_TS3[4])                     //--  output
 ,.ln_retrain                    (ln_retrain)                    //--  input
 ,.ln_deskew_enable              (ln_deskew_enable)              //--  input
 ,.ln_deskew_found               (ln_deskew_found[4])            //--  output
 ,.ln_deskew_hold                (ln_deskew_hold[4])             //--  ouput
 ,.ln_deskew_overflow            (ln_deskew_overflow[4])         //--  output
 ,.ln_deskew_valid               (ln_deskew_valid[4])            //--  output 
 ,.ln_all_valid                  (ln_all_valid)                  //--  input
 ,.ln_deskew_reset               (ln_deskew_reset)               //--  input
 ,.ln_phy_training               (ln_phy_training)               //--  input
 ,.ln_phy_init_done              (ln_phy_init_done[4])           //--  input
 ,.ln_ts_training                (ln_ts_training)                //--  input
 ,.ln_disabled                   (ln_disabled[4])                //--  input
 ,.ln_trained                    (trn_ln_trained)                //--  input
 ,.rx_tx_EDPL_max_cnt            (rx_tx_EDPL_max_cnts[39:32])    //--  output [7:0]
 ,.rx_tx_EDPL_error              (rx_tx_EDPL_errors[4])          //--  output
 ,.rx_tx_EDPL_thres_reached      (rx_tx_EDPL_thres_reached[4])   //--  output
 ,.tx_rx_EDPL_cfg                (tx_rx_EDPL_cfg[4:0])           //--  input  [4:0]
 ,.tx_rx_cfg_patA_length         (tx_rx_cfg_patA_length)         //--  input [1:0]
 ,.tx_rx_cfg_patB_length         (tx_rx_cfg_patB_length)         //--  input [1:0]
 ,.tx_rx_cfg_patA_hyst           (tx_rx_cfg_patA_hyst)           //--  input [3:0]
 ,.tx_rx_cfg_patB_hyst           (tx_rx_cfg_patB_hyst)           //--  input [3:0]
 ,.tx_rx_rx_BEI_inject           (tx_rx_rx_BEI_inject[4])        //--  input
 ,.tx_rx_cfg_sync_mode           (tx_rx_cfg_sync_mode)           //--  input
 ,.reg_dl_edpl_max_count_reset   (reg_dl_edpl_max_count_reset)   //--  input
 ,.rx_reset_n                    (rx_reset_n)                    //--  input
 ,.chip_reset                    (chip_reset)                    //-- input
 ,.global_reset_control          (global_reset_control)          //-- input
 ,.omi_enable                    (omi_enable)                    //--  input
 ,.dl_clk                        (dl_clk)                        //--  input
);

else

dlc_omi_rx_lane ln4 (
  .phy_dl_clock                  (phy_dl_clock_4)                //--  input
 ,.phy_dl_lane                   (phy_dl_lane_4[15:0])           //--  input[15:0]
 ,.phy_dl_iobist_reset           (phy_dl_iobist_reset)           //--  input
 ,.rx_tx_iobist_prbs_error       (rx_tx_iobist_prbs_error[4])    //--  output
 ,.lbist_en_dc                   (lbist_en_dc)                   //--  input
 ,.ln_valid                      (ln4_valid)                     //--  output
 ,.ln_data                       (ln4_data[15:0])                //--  output[15:0]
 ,.ln_trn_data                   (ln4_trn_data[15:0])            //--  output[15:0]
 ,.ln_parity                     (ln4_parity[1:0])               //--  output[1:0]
 ,.ln_data_sync_hdr              (ln_data_sync_hdr[4])           //--  output
 ,.ln_ctl_sync_hdr               (ln_ctl_sync_hdr[4])            //--  output
 ,.ln_rx_slow_pat_a              (ln_rx_slow_pat_a[4])           //--  output
 ,.ln_pattern_a                  (ln_pattern_a[4])               //--  output
 ,.ln_pattern_b                  (ln_pattern_b[4])               //--  output
 ,.ln_sync                       (ln_sync[4])                    //--  output
 ,.ln_block_lock                 (ln_block_lock[4])              //--  output
 ,.ln_TS1                        (ln_TS1[4])                     //--  output
 ,.ln_TS2                        (ln_TS2[4])                     //--  output
 ,.ln_TS3                        (ln_TS3[4])                     //--  output
 ,.ln_retrain                    (ln_retrain)                    //--  input
 ,.ln_deskew_enable              (ln_deskew_enable)              //--  input
 ,.ln_deskew_found               (ln_deskew_found[4])            //--  output
 ,.ln_deskew_hold                (ln_deskew_hold[4])             //--  ouput
 ,.ln_deskew_overflow            (ln_deskew_overflow[4])         //--  output
 ,.ln_deskew_valid               (ln_deskew_valid[4])            //--  output 
 ,.ln_all_valid                  (ln_all_valid)                  //--  input
 ,.ln_deskew_reset               (ln_deskew_reset)               //--  input
 ,.ln_phy_training               (ln_phy_training)               //--  input
 ,.ln_phy_init_done              (ln_phy_init_done[4])           //--  input
 ,.ln_ts_training                (ln_ts_training)                //--  input
 ,.ln_disabled                   (ln_disabled[4])                //--  input
 ,.ln_trained                    (trn_ln_trained)                //--  input
 ,.rx_tx_EDPL_max_cnt            (rx_tx_EDPL_max_cnts[39:32])    //--  output [7:0]
 ,.rx_tx_EDPL_error              (rx_tx_EDPL_errors[4])          //--  output
 ,.rx_tx_EDPL_thres_reached      (rx_tx_EDPL_thres_reached[4])   //--  output
 ,.tx_rx_EDPL_cfg                (tx_rx_EDPL_cfg[4:0])           //--  input  [4:0]
 ,.tx_rx_cfg_patA_length         (tx_rx_cfg_patA_length)         //--  input [1:0]
 ,.tx_rx_cfg_patB_length         (tx_rx_cfg_patB_length)         //--  input [1:0]
 ,.tx_rx_cfg_patA_hyst           (tx_rx_cfg_patA_hyst)           //--  input [3:0]
 ,.tx_rx_cfg_patB_hyst           (tx_rx_cfg_patB_hyst)           //--  input [3:0]
 ,.tx_rx_rx_BEI_inject           (tx_rx_rx_BEI_inject[4])        //--  input
 ,.tx_rx_cfg_sync_mode           (tx_rx_cfg_sync_mode)           //--  input
 ,.reg_dl_edpl_max_count_reset   (reg_dl_edpl_max_count_reset)   //--  input
 ,.rx_reset_n                    (rx_reset_n)                    //--  input
 ,.chip_reset                    (chip_reset)                    //-- input
 ,.global_reset_control          (global_reset_control)          //-- input
 ,.omi_enable                    (omi_enable)                    //--  input
 ,.dl_clk                        (dl_clk)                        //--  input
);
endgenerate

generate
if (RX_EQ_TX_CLK == 1)

dlc_omi_rx_lane_shift ln5 (
  .phy_dl_clock                  (phy_dl_clock_5)                //--  input
 ,.phy_dl_lane                   (phy_dl_lane_5[15:0])           //--  input[15:0]
 ,.phy_dl_iobist_reset           (phy_dl_iobist_reset)           //--  input
 ,.rx_tx_iobist_prbs_error       (rx_tx_iobist_prbs_error[5])    //--  output
 ,.ln_valid                      (ln5_valid)                     //--  output
 ,.ln_data                       (ln5_data[15:0])                //--  output[15:0]
 ,.ln_data_clone_l               (ln5_data_clone_l[15:0])        //--  output[15:0]
 ,.ln_data_clone_r               (ln5_data_clone_r[15:0])        //--  output[15:0]
 ,.ln_data_clone_c               (ln5_data_clone_c[15:0])        //--  output[15:0]
 ,.ln_trn_data                   (ln5_trn_data[15:0])            //--  output[15:0]
 ,.ln_parity                     (ln5_parity[1:0])               //--  output[1:0]
 ,.ln_data_sync_hdr              (ln_data_sync_hdr[5])           //--  output
 ,.ln_ctl_sync_hdr               (ln_ctl_sync_hdr[5])            //--  output
 ,.ln_rx_slow_pat_a              (ln_rx_slow_pat_a[5])           //--  output
 ,.ln_pattern_a                  (ln_pattern_a[5])               //--  output
 ,.ln_pattern_b                  (ln_pattern_b[5])               //--  output
 ,.ln_sync                       (ln_sync[5])                    //--  output
 ,.ln_block_lock                 (ln_block_lock[5])              //--  output
 ,.ln_TS1                        (ln_TS1[5])                     //--  output
 ,.ln_TS2                        (ln_TS2[5])                     //--  output
 ,.ln_TS3                        (ln_TS3[5])                     //--  output
 ,.ln_retrain                    (ln_retrain)                    //--  input
 ,.ln_deskew_enable              (ln_deskew_enable)              //--  input
 ,.ln_deskew_found               (ln_deskew_found[5])            //--  output
 ,.ln_deskew_hold                (ln_deskew_hold[5])             //--  ouput
 ,.ln_deskew_overflow            (ln_deskew_overflow[5])         //--  output
 ,.ln_deskew_valid               (ln_deskew_valid[5])            //--  output
 ,.ln_all_valid                  (ln_all_valid)                  //--  input
 ,.ln_deskew_reset               (ln_deskew_reset)               //--  input
 ,.ln_phy_training               (ln_phy_training)               //--  input
 ,.ln_phy_init_done              (ln_phy_init_done[5])           //--  input
 ,.ln_ts_training                (ln_ts_training)                //--  input
 ,.ln_disabled                   (ln_disabled[5])                //--  input
 ,.ln_trained                    (trn_ln_trained)                //--  input
 ,.rx_tx_EDPL_max_cnt            (rx_tx_EDPL_max_cnts[47:40])    //--  output [7:0]
 ,.rx_tx_EDPL_error              (rx_tx_EDPL_errors[5])          //--  output
 ,.rx_tx_EDPL_thres_reached      (rx_tx_EDPL_thres_reached[5])   //--  output
 ,.tx_rx_EDPL_cfg                (tx_rx_EDPL_cfg[4:0])           //--  input  [4:0]
 ,.tx_rx_cfg_patA_length         (tx_rx_cfg_patA_length)         //--  input [1:0]
 ,.tx_rx_cfg_patB_length         (tx_rx_cfg_patB_length)         //--  input [1:0]
 ,.tx_rx_cfg_patA_hyst           (tx_rx_cfg_patA_hyst)           //--  input [3:0]
 ,.tx_rx_cfg_patB_hyst           (tx_rx_cfg_patB_hyst)           //--  input [3:0]
 ,.tx_rx_rx_BEI_inject           (tx_rx_rx_BEI_inject[5])        //--  input
 ,.tx_rx_cfg_sync_mode           (tx_rx_cfg_sync_mode)           //--  input
 ,.reg_dl_edpl_max_count_reset   (reg_dl_edpl_max_count_reset)   //--  input
 ,.rx_reset_n                    (rx_reset_n)                    //--  input
 ,.chip_reset                    (chip_reset)                    //-- input
 ,.global_reset_control          (global_reset_control)          //-- input
 ,.omi_enable                    (omi_enable)                    //--  input
 ,.dl_clk                        (dl_clk)                        //--  input
);

else

dlc_omi_rx_lane ln5 (
  .phy_dl_clock                  (phy_dl_clock_5)                //--  input
 ,.phy_dl_lane                   (phy_dl_lane_5[15:0])           //--  input[15:0]
 ,.phy_dl_iobist_reset           (phy_dl_iobist_reset)           //--  input
 ,.rx_tx_iobist_prbs_error       (rx_tx_iobist_prbs_error[5])    //--  output
 ,.lbist_en_dc                   (lbist_en_dc)                   //--  input
 ,.ln_valid                      (ln5_valid)                     //--  output
 ,.ln_data                       (ln5_data[15:0])                //--  output[15:0]
 ,.ln_trn_data                   (ln5_trn_data[15:0])            //--  output[15:0]
 ,.ln_parity                     (ln5_parity[1:0])               //--  output[1:0]
 ,.ln_data_sync_hdr              (ln_data_sync_hdr[5])           //--  output
 ,.ln_ctl_sync_hdr               (ln_ctl_sync_hdr[5])            //--  output
 ,.ln_rx_slow_pat_a              (ln_rx_slow_pat_a[5])           //--  output
 ,.ln_pattern_a                  (ln_pattern_a[5])               //--  output
 ,.ln_pattern_b                  (ln_pattern_b[5])               //--  output
 ,.ln_sync                       (ln_sync[5])                    //--  output
 ,.ln_block_lock                 (ln_block_lock[5])              //--  output
 ,.ln_TS1                        (ln_TS1[5])                     //--  output
 ,.ln_TS2                        (ln_TS2[5])                     //--  output
 ,.ln_TS3                        (ln_TS3[5])                     //--  output
 ,.ln_retrain                    (ln_retrain)                    //--  input
 ,.ln_deskew_enable              (ln_deskew_enable)              //--  input
 ,.ln_deskew_found               (ln_deskew_found[5])            //--  output
 ,.ln_deskew_hold                (ln_deskew_hold[5])             //--  ouput
 ,.ln_deskew_overflow            (ln_deskew_overflow[5])         //--  output
 ,.ln_deskew_valid               (ln_deskew_valid[5])            //--  output
 ,.ln_all_valid                  (ln_all_valid)                  //--  input
 ,.ln_deskew_reset               (ln_deskew_reset)               //--  input
 ,.ln_phy_training               (ln_phy_training)               //--  input
 ,.ln_phy_init_done              (ln_phy_init_done[5])           //--  input
 ,.ln_ts_training                (ln_ts_training)                //--  input
 ,.ln_disabled                   (ln_disabled[5])                //--  input
 ,.ln_trained                    (trn_ln_trained)                //--  input
 ,.rx_tx_EDPL_max_cnt            (rx_tx_EDPL_max_cnts[47:40])    //--  output [7:0]
 ,.rx_tx_EDPL_error              (rx_tx_EDPL_errors[5])          //--  output
 ,.rx_tx_EDPL_thres_reached      (rx_tx_EDPL_thres_reached[5])   //--  output
 ,.tx_rx_EDPL_cfg                (tx_rx_EDPL_cfg[4:0])           //--  input  [4:0]
 ,.tx_rx_cfg_patA_length         (tx_rx_cfg_patA_length)         //--  input [1:0]
 ,.tx_rx_cfg_patB_length         (tx_rx_cfg_patB_length)         //--  input [1:0]
 ,.tx_rx_cfg_patA_hyst           (tx_rx_cfg_patA_hyst)           //--  input [3:0]
 ,.tx_rx_cfg_patB_hyst           (tx_rx_cfg_patB_hyst)           //--  input [3:0]
 ,.tx_rx_rx_BEI_inject           (tx_rx_rx_BEI_inject[5])        //--  input
 ,.tx_rx_cfg_sync_mode           (tx_rx_cfg_sync_mode)           //--  input
 ,.reg_dl_edpl_max_count_reset   (reg_dl_edpl_max_count_reset)   //--  input
 ,.rx_reset_n                    (rx_reset_n)                    //--  input
 ,.chip_reset                    (chip_reset)                    //-- input
 ,.global_reset_control          (global_reset_control)          //-- input
 ,.omi_enable                    (omi_enable)                    //--  input
 ,.dl_clk                        (dl_clk)                        //--  input
);
endgenerate

generate
if (RX_EQ_TX_CLK == 1)

dlc_omi_rx_lane_shift ln6 (
  .phy_dl_clock                  (phy_dl_clock_6)                //--  input
 ,.phy_dl_lane                   (phy_dl_lane_6[15:0])           //--  input[15:0]
 ,.phy_dl_iobist_reset           (phy_dl_iobist_reset)           //--  input
 ,.rx_tx_iobist_prbs_error       (rx_tx_iobist_prbs_error[6])    //--  output
 ,.ln_valid                      (ln6_valid)                     //--  output
 ,.ln_data                       (ln6_data[15:0])                //--  output[15:0]
 ,.ln_trn_data                   (ln6_trn_data[15:0])            //--  output[15:0]
 ,.ln_parity                     (ln6_parity[1:0])               //--  output[1:0]
 ,.ln_data_sync_hdr              (ln_data_sync_hdr[6])           //--  output
 ,.ln_ctl_sync_hdr               (ln_ctl_sync_hdr[6])            //--  output
 ,.ln_rx_slow_pat_a              (ln_rx_slow_pat_a[6])           //--  output
 ,.ln_pattern_a                  (ln_pattern_a[6])               //--  output
 ,.ln_pattern_b                  (ln_pattern_b[6])               //--  output
 ,.ln_sync                       (ln_sync[6])                    //--  output
 ,.ln_block_lock                 (ln_block_lock[6])              //--  output
 ,.ln_TS1                        (ln_TS1[6])                     //--  output
 ,.ln_TS2                        (ln_TS2[6])                     //--  output
 ,.ln_TS3                        (ln_TS3[6])                     //--  output
 ,.ln_retrain                    (ln_retrain)                    //--  input
 ,.ln_deskew_enable              (ln_deskew_enable)              //--  input
 ,.ln_deskew_found               (ln_deskew_found[6])            //--  output
 ,.ln_deskew_hold                (ln_deskew_hold[6])             //--  ouput
 ,.ln_deskew_overflow            (ln_deskew_overflow[6])         //--  output
 ,.ln_deskew_valid               (ln_deskew_valid[6])            //--  output 
 ,.ln_all_valid                  (ln_all_valid)                  //--  input
 ,.ln_deskew_reset               (ln_deskew_reset)               //--  input
 ,.ln_phy_training               (ln_phy_training)               //--  input
 ,.ln_phy_init_done              (ln_phy_init_done[6])           //--  input
 ,.ln_ts_training                (ln_ts_training)                //--  input
 ,.ln_disabled                   (ln_disabled[6])                //--  input
 ,.ln_trained                    (trn_ln_trained)                //--  input
 ,.rx_tx_EDPL_max_cnt            (rx_tx_EDPL_max_cnts[55:48])    //--  output [7:0]
 ,.rx_tx_EDPL_error              (rx_tx_EDPL_errors[6])          //--  output
 ,.rx_tx_EDPL_thres_reached      (rx_tx_EDPL_thres_reached[6])   //--  output
 ,.tx_rx_EDPL_cfg                (tx_rx_EDPL_cfg[4:0])           //--  input  [4:0]
 ,.tx_rx_cfg_patA_length         (tx_rx_cfg_patA_length)         //--  input [1:0]
 ,.tx_rx_cfg_patB_length         (tx_rx_cfg_patB_length)         //--  input [1:0]
 ,.tx_rx_cfg_patA_hyst           (tx_rx_cfg_patA_hyst)           //--  input [3:0]
 ,.tx_rx_cfg_patB_hyst           (tx_rx_cfg_patB_hyst)           //--  input [3:0]
 ,.tx_rx_rx_BEI_inject           (tx_rx_rx_BEI_inject[6])        //--  input
 ,.tx_rx_cfg_sync_mode           (tx_rx_cfg_sync_mode)           //--  input
 ,.reg_dl_edpl_max_count_reset   (reg_dl_edpl_max_count_reset)   //--  input
 ,.rx_reset_n                    (rx_reset_n)                    //--  input
 ,.chip_reset                    (chip_reset)                    //-- input
 ,.global_reset_control          (global_reset_control)          //-- input
 ,.omi_enable                    (omi_enable)                    //--  input
 ,.dl_clk                        (dl_clk)                        //--  input
);

else

dlc_omi_rx_lane ln6 (
  .phy_dl_clock                  (phy_dl_clock_6)                //--  input
 ,.phy_dl_lane                   (phy_dl_lane_6[15:0])           //--  input[15:0]
 ,.phy_dl_iobist_reset           (phy_dl_iobist_reset)           //--  input
 ,.rx_tx_iobist_prbs_error       (rx_tx_iobist_prbs_error[6])    //--  output
 ,.lbist_en_dc                   (lbist_en_dc)                   //--  input
 ,.ln_valid                      (ln6_valid)                     //--  output
 ,.ln_data                       (ln6_data[15:0])                //--  output[15:0]
 ,.ln_trn_data                   (ln6_trn_data[15:0])            //--  output[15:0]
 ,.ln_parity                     (ln6_parity[1:0])               //--  output[1:0]
 ,.ln_data_sync_hdr              (ln_data_sync_hdr[6])           //--  output
 ,.ln_ctl_sync_hdr               (ln_ctl_sync_hdr[6])            //--  output
 ,.ln_rx_slow_pat_a              (ln_rx_slow_pat_a[6])           //--  output
 ,.ln_pattern_a                  (ln_pattern_a[6])               //--  output
 ,.ln_pattern_b                  (ln_pattern_b[6])               //--  output
 ,.ln_sync                       (ln_sync[6])                    //--  output
 ,.ln_block_lock                 (ln_block_lock[6])              //--  output
 ,.ln_TS1                        (ln_TS1[6])                     //--  output
 ,.ln_TS2                        (ln_TS2[6])                     //--  output
 ,.ln_TS3                        (ln_TS3[6])                     //--  output
 ,.ln_retrain                    (ln_retrain)                    //--  input
 ,.ln_deskew_enable              (ln_deskew_enable)              //--  input
 ,.ln_deskew_found               (ln_deskew_found[6])            //--  output
 ,.ln_deskew_hold                (ln_deskew_hold[6])             //--  ouput
 ,.ln_deskew_overflow            (ln_deskew_overflow[6])         //--  output
 ,.ln_deskew_valid               (ln_deskew_valid[6])            //--  output 
 ,.ln_all_valid                  (ln_all_valid)                  //--  input
 ,.ln_deskew_reset               (ln_deskew_reset)               //--  input
 ,.ln_phy_training               (ln_phy_training)               //--  input
 ,.ln_phy_init_done              (ln_phy_init_done[6])           //--  input
 ,.ln_ts_training                (ln_ts_training)                //--  input
 ,.ln_disabled                   (ln_disabled[6])                //--  input
 ,.ln_trained                    (trn_ln_trained)                //--  input
 ,.rx_tx_EDPL_max_cnt            (rx_tx_EDPL_max_cnts[55:48])    //--  output [7:0]
 ,.rx_tx_EDPL_error              (rx_tx_EDPL_errors[6])          //--  output
 ,.rx_tx_EDPL_thres_reached      (rx_tx_EDPL_thres_reached[6])   //--  output
 ,.tx_rx_EDPL_cfg                (tx_rx_EDPL_cfg[4:0])           //--  input  [4:0]
 ,.tx_rx_cfg_patA_length         (tx_rx_cfg_patA_length)         //--  input [1:0]
 ,.tx_rx_cfg_patB_length         (tx_rx_cfg_patB_length)         //--  input [1:0]
 ,.tx_rx_cfg_patA_hyst           (tx_rx_cfg_patA_hyst)           //--  input [3:0]
 ,.tx_rx_cfg_patB_hyst           (tx_rx_cfg_patB_hyst)           //--  input [3:0]
 ,.tx_rx_rx_BEI_inject           (tx_rx_rx_BEI_inject[6])        //--  input
 ,.tx_rx_cfg_sync_mode           (tx_rx_cfg_sync_mode)           //--  input
 ,.reg_dl_edpl_max_count_reset   (reg_dl_edpl_max_count_reset)   //--  input
 ,.rx_reset_n                    (rx_reset_n)                    //--  input
 ,.chip_reset                    (chip_reset)                    //-- input
 ,.global_reset_control          (global_reset_control)          //-- input
 ,.omi_enable                    (omi_enable)                    //--  input
 ,.dl_clk                        (dl_clk)                        //--  input
);
endgenerate

generate
if (RX_EQ_TX_CLK == 1)

dlc_omi_rx_lane_shift ln7 (
  .phy_dl_clock                  (phy_dl_clock_7)                //--  input
 ,.phy_dl_lane                   (phy_dl_lane_7[15:0])           //--  input[15:0]
 ,.phy_dl_iobist_reset           (phy_dl_iobist_reset)           //--  input
 ,.rx_tx_iobist_prbs_error       (rx_tx_iobist_prbs_error[7])    //--  output
 ,.ln_valid                      (ln7_valid)                     //--  output
 ,.ln_data                       (ln7_data[15:0])                //--  output[15:0]
 ,.ln_trn_data                   (ln7_trn_data[15:0])            //--  output[15:0]
 ,.ln_parity                     (ln7_parity[1:0])               //--  output[1:0]
 ,.ln_data_sync_hdr              (ln_data_sync_hdr[7])           //--  output
 ,.ln_ctl_sync_hdr               (ln_ctl_sync_hdr[7])            //--  output
 ,.ln_rx_slow_pat_a              (ln_rx_slow_pat_a[7])           //--  output
 ,.ln_pattern_a                  (ln_pattern_a[7])               //--  output
 ,.ln_pattern_b                  (ln_pattern_b[7])               //--  output
 ,.ln_sync                       (ln_sync[7])                    //--  output
 ,.ln_block_lock                 (ln_block_lock[7])              //--  output
 ,.ln_TS1                        (ln_TS1[7])                     //--  output
 ,.ln_TS2                        (ln_TS2[7])                     //--  output
 ,.ln_TS3                        (ln_TS3[7])                     //--  output
 ,.ln_retrain                    (ln_retrain)                    //--  input
 ,.ln_deskew_enable              (ln_deskew_enable)              //--  input
 ,.ln_deskew_found               (ln_deskew_found[7])            //--  output
 ,.ln_deskew_hold                (ln_deskew_hold[7])             //--  ouput
 ,.ln_deskew_overflow            (ln_deskew_overflow[7])         //--  output
 ,.ln_deskew_valid               (ln_deskew_valid[7])            //--  output 
 ,.ln_all_valid                  (ln_all_valid)                  //--  input
 ,.ln_deskew_reset               (ln_deskew_reset)               //--  input
 ,.ln_phy_training               (ln_phy_training)               //--  input
 ,.ln_phy_init_done              (ln_phy_init_done[7])           //--  input
 ,.ln_ts_training                (ln_ts_training)                //--  input
 ,.ln_disabled                   (ln_disabled[7])                //--  input
 ,.ln_trained                    (trn_ln_trained)                //--  input
 ,.rx_tx_EDPL_max_cnt            (rx_tx_EDPL_max_cnts[63:56])    //--  output [7:0]
 ,.rx_tx_EDPL_error              (rx_tx_EDPL_errors[7])          //--  output
 ,.rx_tx_EDPL_thres_reached      (rx_tx_EDPL_thres_reached[7])   //--  output
 ,.tx_rx_EDPL_cfg                (tx_rx_EDPL_cfg[4:0])           //--  input  [4:0]
 ,.tx_rx_cfg_patA_length         (tx_rx_cfg_patA_length)         //--  input [1:0]
 ,.tx_rx_cfg_patB_length         (tx_rx_cfg_patB_length)         //--  input [1:0]
 ,.tx_rx_cfg_patA_hyst           (tx_rx_cfg_patA_hyst)           //--  input [3:0]
 ,.tx_rx_cfg_patB_hyst           (tx_rx_cfg_patB_hyst)           //--  input [3:0]
 ,.tx_rx_rx_BEI_inject           (tx_rx_rx_BEI_inject[7])        //--  input
 ,.tx_rx_cfg_sync_mode           (tx_rx_cfg_sync_mode)           //--  input
 ,.reg_dl_edpl_max_count_reset   (reg_dl_edpl_max_count_reset)   //--  input
 ,.rx_reset_n                    (rx_reset_n)                    //--  input
 ,.chip_reset                    (chip_reset)                    //-- input
 ,.global_reset_control          (global_reset_control)          //-- input
 ,.omi_enable                    (omi_enable)                    //--  input
 ,.dl_clk                        (dl_clk)                        //--  input
);

else

dlc_omi_rx_lane ln7 (
  .phy_dl_clock                  (phy_dl_clock_7)                //--  input
 ,.phy_dl_lane                   (phy_dl_lane_7[15:0])           //--  input[15:0]
 ,.phy_dl_iobist_reset           (phy_dl_iobist_reset)           //--  input
 ,.rx_tx_iobist_prbs_error       (rx_tx_iobist_prbs_error[7])    //--  output
 ,.lbist_en_dc                   (lbist_en_dc)                   //--  input
 ,.ln_valid                      (ln7_valid)                     //--  output
 ,.ln_data                       (ln7_data[15:0])                //--  output[15:0]
 ,.ln_trn_data                   (ln7_trn_data[15:0])            //--  output[15:0]
 ,.ln_parity                     (ln7_parity[1:0])               //--  output[1:0]
 ,.ln_data_sync_hdr              (ln_data_sync_hdr[7])           //--  output
 ,.ln_ctl_sync_hdr               (ln_ctl_sync_hdr[7])            //--  output
 ,.ln_rx_slow_pat_a              (ln_rx_slow_pat_a[7])           //--  output
 ,.ln_pattern_a                  (ln_pattern_a[7])               //--  output
 ,.ln_pattern_b                  (ln_pattern_b[7])               //--  output
 ,.ln_sync                       (ln_sync[7])                    //--  output
 ,.ln_block_lock                 (ln_block_lock[7])              //--  output
 ,.ln_TS1                        (ln_TS1[7])                     //--  output
 ,.ln_TS2                        (ln_TS2[7])                     //--  output
 ,.ln_TS3                        (ln_TS3[7])                     //--  output
 ,.ln_retrain                    (ln_retrain)                    //--  input
 ,.ln_deskew_enable              (ln_deskew_enable)              //--  input
 ,.ln_deskew_found               (ln_deskew_found[7])            //--  output
 ,.ln_deskew_hold                (ln_deskew_hold[7])             //--  ouput
 ,.ln_deskew_overflow            (ln_deskew_overflow[7])         //--  output
 ,.ln_deskew_valid               (ln_deskew_valid[7])            //--  output 
 ,.ln_all_valid                  (ln_all_valid)                  //--  input
 ,.ln_deskew_reset               (ln_deskew_reset)               //--  input
 ,.ln_phy_training               (ln_phy_training)               //--  input
 ,.ln_phy_init_done              (ln_phy_init_done[7])           //--  input
 ,.ln_ts_training                (ln_ts_training)                //--  input
 ,.ln_disabled                   (ln_disabled[7])                //--  input
 ,.ln_trained                    (trn_ln_trained)                //--  input
 ,.rx_tx_EDPL_max_cnt            (rx_tx_EDPL_max_cnts[63:56])    //--  output [7:0]
 ,.rx_tx_EDPL_error              (rx_tx_EDPL_errors[7])          //--  output
 ,.rx_tx_EDPL_thres_reached      (rx_tx_EDPL_thres_reached[7])   //--  output
 ,.tx_rx_EDPL_cfg                (tx_rx_EDPL_cfg[4:0])           //--  input  [4:0]
 ,.tx_rx_cfg_patA_length         (tx_rx_cfg_patA_length)         //--  input [1:0]
 ,.tx_rx_cfg_patB_length         (tx_rx_cfg_patB_length)         //--  input [1:0]
 ,.tx_rx_cfg_patA_hyst           (tx_rx_cfg_patA_hyst)           //--  input [3:0]
 ,.tx_rx_cfg_patB_hyst           (tx_rx_cfg_patB_hyst)           //--  input [3:0]
 ,.tx_rx_rx_BEI_inject           (tx_rx_rx_BEI_inject[7])        //--  input
 ,.tx_rx_cfg_sync_mode           (tx_rx_cfg_sync_mode)           //--  input
 ,.reg_dl_edpl_max_count_reset   (reg_dl_edpl_max_count_reset)   //--  input
 ,.rx_reset_n                    (rx_reset_n)                    //--  input
 ,.chip_reset                    (chip_reset)                    //-- input
 ,.global_reset_control          (global_reset_control)          //-- input
 ,.omi_enable                    (omi_enable)                    //--  input
 ,.dl_clk                        (dl_clk)                        //--  input
);
endgenerate

endmodule     //-- dlc_omi_rx
