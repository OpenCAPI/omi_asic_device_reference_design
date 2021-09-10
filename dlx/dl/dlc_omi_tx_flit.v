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
//-- *!********************************************************************


module dlc_omi_tx_flit (
//-- signals from the TL
  tl2dl_flit_early_vld,          //--  input
  tl2dl_flit_vld,                //--  input
  tl2dl_flit_data,               //--  input   [127:0]
  tl2dl_flit_ecc,                //--  input   [15:0]
  tl2dl_flit_lbip_vld,           //--  input
  tl2dl_flit_lbip_data,          //--  input   [81:0]
//-- tl2dl_flit_lbip_ecc,           //--  input   [15:0]

  dl2tl_flit_credit,             //--  output
  dl2tl_link_up,                 //--  output

//-- signals between the RX and TX
  rx_tx_crc_error,               //--  input
  rx_tx_nack,                    //--  input

  rx_tx_rx_ack_inc,              //--  input  [3:0]
  rx_tx_tx_ack_rtn,              //--  input  [4:0]
  rx_tx_tx_ack_ptr_vld,          //--  input
  rx_tx_tx_ack_ptr,              //--  input  [11:0]
  rx_link_up,                    //--  input

//-- register interface                        
  reg_rmt_write,                 //--  input
  reg_rmt_config,                //--  input  [31:0]
  dlc_reset_n,                   //--  input
  chip_reset,                    //--  Input
  global_reset_control,          //--  Input
  reg_dl_cya_bits,               //--  Input
  flt_trn_reset_hammer,          //--  output
  flt_trn_retrain_hammer,        //--  output
  flt_trn_retrain_rply,          //--  output
  flt_trn_retrain_no_rply,       //--  output

//-- Interface to the TX macros
  flt_agn_data,                  //--  output  [127:0]
//--  flt_agn_fp_vld,                //--  output
//--  flt_agn_use_ngbr,              //--  output
  trn_flt_train_done,            //--  input
  trn_flt_tsm4,                  //--  input
  trn_flt_tsm,                   //--  input
  flt_stall,                     //--  input
  trn_flt_x2_tx_mode,            //--  input            //--  new ports for power management
  trn_flt_x4_tx_mode,            //--  input            //--  new ports for power management
  trn_flt_x8_tx_mode,            //--  input            //--  new ports for power management
  trn_flt_real_stall,            //--  input
  trn_flt_macro_dbg_sel,         //--  input

 //-- flt_trn_x2_tx_status,          //--  output            //--  new ports for power management
 //-- flt_trn_x4_tx_status,          //--  output            //--  new ports for power management
 //-- flt_trn_x8_tx_status,          //--  output            //--  new ports for power management
  trn_flt_recal_state,           //--  input  [1:0]      //--  new ports for power management
  trn_flt_send_pm_msg,           //--  input 
  trn_flt_pm_narrow_not_wide,    //--  input                 only valid when trn_flt_send_pm_msg is active (high)
  flt_trn_pm_msg_sent,           //--  output
  trn_flt_pm_msg,                //--  input  [3:0]      //--  new ports for power management



  trn_flt_link_errors,           //--  input  [7:0]
  trn_flt_tl_credits,            //--  input  [5:0]
  enable_short_idle,             //--  input
  enable_fastpath,               //--  input
  all_tx_credits_returned,       //--  output

//-- FRBUF(Flit Replay BUFfer) interface
  frbuf_wr_en,                   //--  output 
  frbuf_wr_addr,                 //--  output
  frbuf_wr_data,                 //--  output
  frbuf_rd0_en,                  //--  output
  frbuf_rd0_addr,                //--  output
  frbuf_rd0_data,                //--  input
  frbuf_rd1_en,                  //--  output
  frbuf_rd1_addr,                //--  output
  frbuf_rd1_data,                //--  input

//-- only used so didn't need to add latches in frbuf, not needed for a true 2 read port array
  frbuf_rd0_select_pair0_d1,     //--  output
  frbuf_rd0_select_pair1_d1,     //--  output

//-- 
flt_trn_no_fwd_prog  ,     //-- output
flt_trn_fp_start     ,     //-- output
flt_trn_rpl_data_flt ,     //-- output
flt_trn_data_flt     ,     //-- output
flt_trn_ctl_flt      ,     //-- output
flt_trn_rpl_flt      ,     //-- output
flt_trn_idle_flt     ,     //-- output
flt_trn_ue_rpb_df    ,     //-- output
flt_trn_ue_frb_df    ,     //-- output
flt_trn_ce_rpb       ,     //-- output
flt_trn_ce_frb       ,     //-- output
flt_trn_data_pty_err ,     //-- output
flt_trn_tl_trunc     ,     //-- output
flt_trn_tl_rl_err    ,     //-- output
flt_trn_ack_ptr_err  ,     //-- output
flt_trn_ue_rpb_cf    ,     //-- output
flt_trn_ue_frb_cf    ,     //-- output
flt_trn_dbg_tx_info  ,     //-- output  
flt_trn_in_replay    ,     //-- output

trn_flt_inj_ecc_ce  ,     //-- input
trn_flt_inj_ecc_ue  ,     //-- input
trn_flt_rpb_rm_depth,     //-- input
omi_enable          ,     //-- input
reg_dl_1us_tick     ,     //-- input

  dl_clk                         //--  input
);


input              tl2dl_flit_early_vld;
input              tl2dl_flit_vld;
input  [127:0]     tl2dl_flit_data;
input  [15:0]      tl2dl_flit_ecc;
input              tl2dl_flit_lbip_vld;
input  [81:0]      tl2dl_flit_lbip_data;
//-- input  [15:0]      tl2dl_flit_lbip_ecc;
output             dl2tl_flit_credit;
output             dl2tl_link_up;

input              rx_tx_crc_error;
input              rx_tx_nack;

input  [3:0]       rx_tx_rx_ack_inc;
input  [4:0]       rx_tx_tx_ack_rtn;
input              rx_tx_tx_ack_ptr_vld;
input  [11:0]      rx_tx_tx_ack_ptr;
input              rx_link_up;
input              reg_rmt_write;
input  [31:0]      reg_rmt_config;
input              dlc_reset_n;
input              chip_reset;
input              global_reset_control;
input  [31:0]      reg_dl_cya_bits;
output             flt_trn_reset_hammer;
output             flt_trn_retrain_hammer;
output             flt_trn_retrain_rply;
output             flt_trn_retrain_no_rply;
output [127:0]     flt_agn_data;
//-- output             flt_agn_fp_vld;
//-- output             flt_agn_use_ngbr;
input              trn_flt_train_done;
input              trn_flt_tsm4;
input   [2:0]      trn_flt_tsm;
input              flt_stall;
input              trn_flt_x2_tx_mode;
input              trn_flt_x4_tx_mode;
input              trn_flt_x8_tx_mode;
input              trn_flt_real_stall;
input [3:0]        trn_flt_macro_dbg_sel;
//-- output             flt_trn_x2_tx_status;
//-- output             flt_trn_x4_tx_status;
//-- output             flt_trn_x8_tx_status;
input  [1:0]       trn_flt_recal_state;
input              trn_flt_send_pm_msg;
input              trn_flt_pm_narrow_not_wide;
output             flt_trn_pm_msg_sent;
input  [3:0]       trn_flt_pm_msg;

input  [7:0]       trn_flt_link_errors;
input  [5:0]       trn_flt_tl_credits;
input              enable_short_idle;
input              enable_fastpath;
output             all_tx_credits_returned;


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

//
output             flt_trn_no_fwd_prog  ;
output             flt_trn_fp_start     ;
output             flt_trn_rpl_data_flt ;
output             flt_trn_data_flt     ;
output             flt_trn_ctl_flt      ;
output             flt_trn_rpl_flt      ;
output             flt_trn_idle_flt     ;
output             flt_trn_ue_rpb_df    ;
output             flt_trn_ue_frb_df    ;
output             flt_trn_ce_rpb       ;
output             flt_trn_ce_frb       ;
output             flt_trn_data_pty_err ;
output             flt_trn_tl_trunc     ;
output             flt_trn_tl_rl_err    ;
output             flt_trn_ack_ptr_err  ;
output             flt_trn_ue_rpb_cf    ;
output             flt_trn_ue_frb_cf    ;
output [87:0]      flt_trn_dbg_tx_info  ;  
output             flt_trn_in_replay    ;

input              trn_flt_inj_ecc_ce  ;
input              trn_flt_inj_ecc_ue  ;
input [3:0]        trn_flt_rpb_rm_depth;
input              omi_enable          ;
input              reg_dl_1us_tick     ;

input              dl_clk;


//-- signals
wire [511:0]   zeros     = 512'h0;
wire [127:0]   flt_agn_data;
wire [127:0]   flt_agn_data_int;
wire [511:384] ctl_flit;
wire [511:0]   dl2dl_replay_flit; 
wire [511:0]   dl2dl_idle_flit; 
wire [127:0]   tl2dl_flit_data;  
wire [127:0]   crc_data_in;
wire [127:0]   crc_shift_data_in;
wire [127:0]   buffer_out_corrected;
wire [127:0]   lbip_corrected;
wire [127:0]   DL_wo_short_flit_next;
wire [127:0]   crc_data_in_part1;
wire [127:0]   crc_data_in_part1_ctl; 
wire [127:0]   crc_data_in_part2;
wire [127:0]   DL_wo_short_flit_next_fp;
wire [127:0]   buffer_out_d3;
wire [127:0]   lbip_d3;
wire [127:0]   crc_data_in_part12;
wire [81:0]    ctl_flit_in;
wire [87:0]    dbg_0;
wire [87:0]    dbg_1;
wire [87:0]    dbg_2;
wire [87:0]    dbg_3;
wire [87:0]    dbg_4;
wire [87:0]    dbg_5;
wire [87:0]    dbg_6;
wire [87:0]    dbg_7;
wire [87:0]    dbg_8;
wire [87:0]    dbg_9;
wire [87:0]    dbg_A;
wire [87:0]    dbg_B;
wire [87:0]    dbg_C;
wire [87:0]    dbg_D;
wire [87:0]    dbg_E;
wire [87:0]    dbg_F;

wire [35:0]    crc_checkbits_out;
wire [35:0]    crc_shift_checkbits_out;
wire [35:0]    crc_idle_checkbits_out;
wire [1:0]     flit_type;
wire [5:0]     rtn_acks;
wire [3:0]     stalled_RL;
wire [3:0]     gated_stalled_RL;
wire [7:0]     syn0_L;
wire [7:0]     syn0_R;
wire [7:0]     syn1_L;
wire [7:0]     syn1_R;
wire [7:0]     stomp_syn_fp;
wire [7:0]     syn_in_L;
wire [7:0]     syn_in_R;
wire [7:0]     rpb_rm_depth;
wire [4:0]     reset_latches_n;
wire           ce_in_L;
wire           ce_in_R;
wire           ce0_L;
wire           ce0_R;
wire           ce1_L;
wire           ce1_R;
wire           ue0_L;
wire           ue0_R;
wire           ue1_L;
wire           ue1_R;
wire           data_stalled;
wire           data_stalled_end;
wire           short_flit_next;
wire           beat0;
wire           beat1; 
wire           beat2;
wire           beat3;
wire           send_ctl;
wire           send_ctl_b0;
wire           send_ctl_b1;
wire           send_ctl_b1_e0;
wire           send_ctl_b2;
wire           send_ctl_b3;
wire           send_replay;
wire           send_replay_b0; 
wire           send_replay_b0_e0;
wire           send_replay_b0_e1;
wire           send_replay_b1; 
wire           send_replay_b1_e0; 
wire           send_replay_b2; 
wire           send_replay_b3; 
wire           send_idle;
wire           send_idle_b0;   
wire           send_idle_b0_e0;   
wire           send_idle_b1;   
wire           send_idle_b1_e0;   
wire           send_idle_b2;   
wire           send_idle_b3;   
wire           data_from_frbuf;
wire           data_from_frbuf_next;
wire           replay_b1;
wire           replay_go_ni;
wire           replay_b1_ni;
wire           frbuf_empty;
wire           frbuf_wr_en_int;   //-- internal signal
wire           fp_frbuf_empty;
wire           idle;
wire           flit_vld;
// wire           flit_vld_w_replay;
wire           max_ack_cnt;
wire           replay_due2_errors;
//--wire           dl2dl_sent;
wire           crc_zero_checkbits;
wire           fastpath_start;
wire           fastpath_end;
wire           any_fastpath_d0;
wire           dl2tl_link_up_int;
wire           give_flit_credit;
wire           new_flit_sent;
wire           send_dl2dl;
wire           dlc_reset_n;
wire           frbuf_xm1_vld;
wire           frbuf_xm1_load;
wire           frbuf_xm1_not_vld;
wire           all_tx_credits_returned_int;
wire           force_idle_now;
//-- wire           pm_msg_hold_now;
wire           replay_go;
wire           rd_catching_wr;
wire           block_credits;
wire           block_credits_valid;
wire           send_idle_next;
wire           fastpath_start_for_fp_only;
wire           data_from_frbuf_e0;
wire           stomp_now;
wire           go_narrow_delay;
wire           data_stall_pm;
//--wire           data_stalled_other;
wire           x4_rpf_rp_stalled;
wire           real_stall_d3; 
wire           short_flit_next_sometimes;
wire           tx_ack_ptr_pend_vld;
wire           frbuf_replay_full_hold_reset;
wire           reset_crc_hammer;
wire           retrain_crc_hammer;
wire           reset_pm_hammer;
wire           retrain_pm_hammer;
wire           frbuf_rd_p40_gt_beats;
wire           pm_msg_dly;
wire [3:0]     pm_msg_dly_cnt;

wire [5:0]    unused;

//-- latches
wire [143:0]   buffer_out_din;
wire [143:0]   buffer_out_q;
wire [127:0]   buffer_out_d0_din;
wire [127:0]   buffer_out_d0_q;
wire [127:0]   buffer_out_d1_din;
wire [127:0]   buffer_out_d1_q;
wire [127:0]   buffer_out_d2_din;
wire [127:0]   buffer_out_d2_q;
//-- wire [127:0]   buffer_out_d3_din;
//-- wire [127:0]   buffer_out_d3_q;
wire [143:0]   lbip_din;
wire [143:0]   lbip_q;
wire [127:0]   lbip_d0_din;
wire [127:0]   lbip_d0_q;
wire [127:0]   lbip_d1_din;
wire [127:0]   lbip_d1_q;
wire [127:0]   lbip_d2_din;
wire [127:0]   lbip_d2_q;
//-- wire [127:0]   lbip_d3_din;
//-- wire [127:0]   lbip_d3_q;
wire [81:0]    crc_data_in_p1ctl_din; 
wire [81:0]    crc_data_in_p1ctl_q;
wire [127:0]   crc_data_in_p1dat_din; 
wire [127:0]   crc_data_in_p1dat_q;
wire [127:0]   crc_shift_data_fp_din; 
wire [127:0]   crc_shift_data_fp_q;
wire           send_ctl_b2_e0_din;
wire           send_ctl_b2_e0_q;
wire           send_replay_b2_e0_din;
wire           send_replay_b2_e0_q;
wire           send_idle_b2_e0_din;
wire           send_idle_b2_e0_q;
wire           force_idle_hold;
wire           tl_trunc;

wire [1:0]     beat_din;
wire [1:0]     beat_q;
wire [3:0]     run_length_din;
wire [3:0]     run_length_q;
wire [35:0]    crc_checkbits_din;
wire [35:0]    crc_checkbits_q;
wire [127:0]   dl_content_din; 
wire [127:0]   dl_content_q;
wire [127:0]   dl_content_short_flit_next_din; 
wire [127:0]   dl_content_short_flit_next_q;
wire [127:96]   dl2dl_flit_to_send_din;
wire [127:96]   dl2dl_flit_to_send_q;
wire [7:0]     frbuf_wr_ptr_din;   
wire [7:0]     frbuf_wr_ptr_q;   
wire [7:0]     frbuf_rd_ptr_din;
wire [7:0]     frbuf_rd_ptr_q;
wire [3:0]     replay_count_din;
wire [3:0]     replay_count_q;
wire [7:0]     link_errors_din;
wire [7:0]     link_errors_q;
wire [63:0]    link_info_din;
wire [63:0]    link_info_q;
wire [7:0]     get_to_next_ctl_cnt_din;
wire [7:0]     get_to_next_ctl_cnt_q;
wire [13:0]    frbuf_replay_pointer_din;
wire [13:0]    frbuf_replay_pointer_q;
wire [13:0]    rx_ack_ptr_din;
wire [13:0]    rx_ack_ptr_q;
wire [13:0]    tx_ack_ptr_din;
wire [13:0]    tx_ack_ptr_q;
wire [13:0]    tx_ack_ptr_pend_din;
wire [13:0]    tx_ack_ptr_pend_q;
wire [5:0]     rtn_ack_cnt_din;
wire [5:0]     rtn_ack_cnt_q;
wire [1:0]     flit_type_din;
wire [1:0]     flit_type_q;
wire [7:0]     frame_buf_credit_cnt_din;
wire [7:0]     frame_buf_credit_cnt_q;
wire [7:0]     tl_credit_cnt_din;
wire [7:0]     tl_credit_cnt_q;
wire [2:0]     slowpath_cnt_din;
wire [2:0]     slowpath_cnt_q;
wire [2:0]     pre_replay_idle_cnt_din;
wire [2:0]     pre_replay_idle_cnt_q;
wire [3:0]     prev_cmd_run_length_din;
wire [3:0]     prev_cmd_run_length_q;
wire [7:0]     beats_sent_din;
wire [7:0]     beats_sent_q;
wire [3:0]     cnt_after_early_vld_drops_din;
wire [3:0]     cnt_after_early_vld_drops_q;
wire [5:0]     ue_rpb_cf_delay_din;
wire [5:0]     ue_rpb_cf_delay_q;
wire [5:0]     ue_rpb_df0_delay_din;
wire [5:0]     ue_rpb_df0_delay_q;
wire [5:0]     ue_rpb_df1_delay_din;
wire [5:0]     ue_rpb_df1_delay_q;
wire [4:0]     reset_n_din;
wire [4:0]     reset_n_q;
wire [3:0]     go_narrow_cnt_din;
wire [3:0]     go_narrow_cnt_q;
wire [2:0]     beats_sent_retrain_adj_din;
wire [2:0]     beats_sent_retrain_adj_q;
//-- wire [2:0]     req_width_tx_mode_din;
//-- wire [2:0]     req_width_tx_mode_q;
wire [127:0]   flt_agn_data_int_din;
wire [127:0]   flt_agn_data_int_q;
wire [95:64]   tl2dl_data_debug_din;
wire [95:64]   tl2dl_data_debug_q;
wire [2:0]     tl2dl_misc_debug_din;
wire [2:0]     tl2dl_misc_debug_q;
wire           replay_short_idle_din;
wire           replay_short_idle_q;
wire           not_reset_ack_cnt_din;
wire           not_reset_ack_cnt_q;
wire           fastpath_din;
wire           fastpath_q;
wire           fastpath_l_din;
wire           fastpath_l_q;
wire           fastpath_r_din;
wire           fastpath_r_q;
wire           fastpath_d0_din;
wire           fastpath_d0_q;
wire           fastpath_d1_din;
wire           fastpath_d1_q;
wire           delayed_fastpath_din;
wire           delayed_fastpath_q;
wire           delayed_fastpath_d0_din;
wire           delayed_fastpath_d0_q;
wire           double_delayed_fastpath_din;
wire           double_delayed_fastpath_q;
wire           double_delayed_fastpath_d0_din;
wire           double_delayed_fastpath_d0_q;
wire           double_delayed_fastpath_d1_din;
wire           double_delayed_fastpath_d1_q;
wire           triple_delayed_fastpath_din;
wire           triple_delayed_fastpath_q;
wire           triple_delayed_fastpath_d0_din;
wire           triple_delayed_fastpath_d0_q;
wire           quad_delayed_fastpath_din;
wire           quad_delayed_fastpath_q;
wire           quad_delayed_fastpath_d0_din;
wire           quad_delayed_fastpath_d0_q;
wire           quad_delayed_fastpath_d1_din;
wire           quad_delayed_fastpath_d1_q;
wire           quad_delayed_fastpath_d2_din;
wire           quad_delayed_fastpath_d2_q;
wire           quad_delayed_fastpath_d3_din;
wire           quad_delayed_fastpath_d3_q;
wire           quad_delayed_fastpath_d4_din;
wire           quad_delayed_fastpath_d4_q;
wire           any_fastpath_din;
wire           any_fastpath_q;
wire           any_fastpath_d0_din;
wire           any_fastpath_d0_q;
wire           any_fastpath_d1_din;
wire           any_fastpath_d1_q;
wire           any_fastpath_d2_din;
wire           any_fastpath_d2_q;
wire           any_fastpath_d3_din;
wire           any_fastpath_d3_q;
wire           any_fastpath_d4_din;
wire           any_fastpath_d4_q;
wire           stall_d0_din; 
wire           stall_d0_q; 
wire           stall_d1_din; 
wire           stall_d1_q; 
wire           stall_d2_din; 
wire           stall_d2_q; 
wire           stall_d3_din; 
wire           stall_d3_q; 
wire           stall_d4_din; 
wire           stall_d4_q; 
wire           stall_d5_din; 
wire           stall_d5_q; 
wire           stall_d6_din; 
wire           stall_d6_q; 
wire           stall_d7_din; 
wire           stall_d7_q; 
//-- wire           real_stall_d0_din; 
//-- wire           real_stall_d0_q; 
//-- wire           real_stall_d1_din; 
//-- wire           real_stall_d1_q; 
//-- wire           real_stall_d2_din; 
//-- wire           real_stall_d2_q; 
//-- wire           real_stall_d3_din; 
//-- wire           real_stall_d3_q; 
wire           real_stall_d4_din; 
wire           real_stall_d4_q;
wire           beats_sent_invalid_din;
wire           beats_sent_invalid_q;
wire           frbuf_rd_vld_din; 
wire           frbuf_rd_vld_q; 
wire           frbuf_rd_vld_d0_din; 
wire           frbuf_rd_vld_d0_q; 
wire           frbuf_rd_vld_d1_din; 
wire           frbuf_rd_vld_d1_q; 
wire           frbuf_rd_vld_d2_din; 
wire           frbuf_rd_vld_d2_q; 
wire           frbuf_rd_vld_d3_din; 
wire           frbuf_rd_vld_d3_q; 
wire           frbuf_rd_vld_d4_din; 
wire           frbuf_rd_vld_d4_q;
wire           frbuf_x2_continue_din;
wire           frbuf_x2_continue_q;
wire           replay_in_progress_din;
wire           replay_in_progress_q;
wire           replay_in_progress_d0_din;
wire           replay_in_progress_d0_q;
wire           replay_in_progress_d1_din;
wire           replay_in_progress_d1_q;
wire           send_nack_din;
wire           send_nack_q;
wire           nack_din;
wire           nack_q;
wire           nack_d0_din;
wire           nack_d0_q;
wire           nack_pend_din;
wire           nack_pend_q;
wire           init_replay_done_din;
wire           init_replay_done_q;
wire           init_replay_late_done_din;
wire           init_replay_late_done_q;
wire           send_no_replay_data_din;
wire           send_no_replay_data_q;
wire           frbuf_empty_din;
wire           frbuf_empty_q;
wire           frbuf_empty_d0_din;
wire           frbuf_empty_d0_q;
wire           train_done_din;
wire           train_done_q;
wire           train_done_d0_din;
wire           train_done_d0_q;
wire           train_done_d1_din;
wire           train_done_d1_q;
//--wire           rx_rl_not_vld_din;
//--wire           rx_rl_not_vld_q;
//--wire           rx_ack_ptr_6_d_din;
//--wire           rx_ack_ptr_6_d_q;
wire           flit_vld_din;
wire           flit_vld_q;
wire           tx_rl_not_vld_din;
wire           tx_rl_not_vld_q;
wire           reset_occurred_din;
wire           reset_occurred_q;
wire           frbuf_rd0_select_pair0_din;
wire           frbuf_rd0_select_pair0_q;
wire           frbuf_rd0_select_pair1_din;
wire           frbuf_rd0_select_pair1_q;
wire           send_ctl_din;
wire           send_ctl_q;
wire           crc_zero_checkbits_next_din;
wire           crc_zero_checkbits_next_q;
wire           crc_zero_checkbits_next_d0_din;
wire           crc_zero_checkbits_next_d0_q;
wire           crc_zero_checkbits_next_d1_din;
wire           crc_zero_checkbits_next_d1_q;
wire           crc_zero_checkbits_next_d2_din;
wire           crc_zero_checkbits_next_d2_q;
//-- wire           crc_zero_checkbits_next_d3_din;
//-- wire           crc_zero_checkbits_next_d3_q;
//-- wire           crc_zero_checkbits_next_d4_din;
//-- wire           crc_zero_checkbits_next_d4_q;
wire           crc_zero_checkbits_stall_delay_din;
wire           crc_zero_checkbits_stall_delay_q;
wire           tl2dl_flit_vld_din;
wire           tl2dl_flit_vld_q;
wire           tl2dl_flit_vld_d0_q;
wire           tl2dl_flit_vld_d0_din;
wire           tl2dl_flit_early_vld_din;
wire           tl2dl_flit_early_vld_q;
wire           tl2dl_flit_early_vld_l_din;
wire           tl2dl_flit_early_vld_l_q;
wire           tl2dl_flit_early_vld_r_din;
wire           tl2dl_flit_early_vld_r_q;
wire           tl2dl_flit_early_vld_d1_din;
wire           tl2dl_flit_early_vld_d1_q;
wire           short_flit_next_e0_din;
wire           short_flit_next_e0_q;
wire           send_idle_next_e0_din;
wire           send_idle_next_e0_q;
wire           send_idle_next_partial_din;
wire           send_idle_next_partial_q;
wire           short_flit_next_din;
wire           short_flit_next_q;
wire           send_idle_next_din;
wire           send_idle_next_q;
wire           short_flit_next_d0_din;
wire           short_flit_next_d0_q;
wire           short_flit_next_d1_din;
wire           short_flit_next_d1_q;
wire           short_flit_next_d2_din;
wire           short_flit_next_d2_q;
wire           short_flit_next_d3_din;
wire           short_flit_next_d3_q;
wire           go_to_idle_after_flit_din;
wire           go_to_idle_after_flit_q;
wire           read_from_array_valid_din;
wire           read_from_array_valid_q;
wire           slowpath_align_din;
wire           slowpath_align_q;
wire           enable_credit_return_din;
wire           enable_credit_return_q;
wire           enable_credit_return_d0_din;
wire           enable_credit_return_d0_q;
wire           enable_credit_return_d1_din;
wire           enable_credit_return_d1_q;
wire           fp_frbuf_empty_din;
wire           fp_frbuf_empty_q;
wire           fp_frbuf_empty_d0_din;
wire           fp_frbuf_empty_d0_q;
wire           frbuf_empty_d1_din;
wire           frbuf_empty_d1_q;
wire           fastpath_start_din;
wire           fastpath_start_q;
wire           fastpath_start_d0_din;
wire           fastpath_start_d0_q;
wire           fastpath_end_din;
wire           fastpath_end_q;
wire           fastpath_end_d0_din;
wire           fastpath_end_d0_q;
wire           fastpath_end_d1_din;
wire           fastpath_end_d1_q;
wire           send_ctl_b3_fp_din;
wire           send_ctl_b3_fp_q;
wire           one_valid_stutter_din;
wire           one_valid_stutter_q;
wire           one_valid_stutter_d0_din;
wire           one_valid_stutter_d0_q;
wire           one_valid_stutter_d1_din;
wire           one_valid_stutter_d1_q;
wire           one_valid_stutter_d2_din;
wire           one_valid_stutter_d2_q;
wire           one_valid_stutter_d3_din;
wire           one_valid_stutter_d3_q;
wire           two_valid_stutter_din;
wire           two_valid_stutter_q;
wire           two_valid_stutter_d0_din;
wire           two_valid_stutter_d0_q;
//-- wire           three_valid_stutter_din;
//-- wire           three_valid_stutter_q;
wire           replay_b2_din;
wire           replay_b2_q;
wire           replay_b2_d0_din;
wire           replay_b2_d0_q;
wire           replay_b2_d1_din;
wire           replay_b2_d1_q;
wire           replay_b2_d2_din;
wire           replay_b2_d2_q;
wire           replay_b2_d3_din;
wire           replay_b2_d3_q;
wire           replay_b2_d4_din;
wire           replay_b2_d4_q;
wire           replay_b2_d5_din;
wire           replay_b2_d5_q;
wire           replay_b2_d6_din;
wire           replay_b2_d6_q;
wire           replay_b2_d7_din;
wire           replay_b2_d7_q;
wire           replay_b2_d8_din;
wire           replay_b2_d8_q;
wire           replay_done_din;
wire           replay_done_q;
wire           replay_done_d0_din;
wire           replay_done_d0_q;
wire           replay_done_d1_din;
wire           replay_done_d1_q;
wire           replay_done_b0_din;
wire           replay_done_b0_q;
wire           no_data_in_frbuf_din;
wire           no_data_in_frbuf_q;
wire           slowpath_glitch_din;
wire           slowpath_glitch_q;
wire           slowpath_glitch_cmplt_din;
wire           slowpath_glitch_cmplt_q;
wire           slowpath_glitch_cmplt_d0_din;
wire           slowpath_glitch_cmplt_d0_q;
wire           send_dl2dl_flit_din;
wire           send_dl2dl_flit_q;
wire           send_idle_b0_e0_din;
wire           send_idle_b0_e0_q;
wire           pre_fastpath_idle_din;
wire           pre_fastpath_idle_q;
wire           idle_din;
wire           idle_q;
wire           send_idle_b0_din;
wire           send_idle_b0_q;
wire           send_idle_b1_din;
wire           send_idle_b1_q;
wire           send_idle_b2_din;
wire           send_idle_b2_q;
wire           quad_stall_dly_din;
wire           quad_stall_dly_q;
wire           x8_tx_mode_din;
wire           x8_tx_mode_q;
wire           x8_tx_mode_d0_din;
wire           x8_tx_mode_d0_q;
wire           x4_tx_mode_din;
wire           x4_tx_mode_q;
wire           x2_tx_mode_din;
wire           x2_tx_mode_q;
wire           send_ctl_b3_din;
wire           send_ctl_b3_q;
wire           send_ctl_b3_d0_din;
wire           send_ctl_b3_d0_q;
wire           send_ctl_b3_d1_din;
wire           send_ctl_b3_d1_q;
wire           send_replay_b0_e0_din;
wire           send_replay_b0_e0_q;
wire           send_replay_b3_din;
wire           send_replay_b3_q;
wire           send_replay_b3_d0_din;
wire           send_replay_b3_d0_q;
wire           send_replay_b3_d1_din;
wire           send_replay_b3_d1_q;
wire           send_idle_b3_e0_din;
wire           send_idle_b3_e0_q;
wire           send_idle_b3_din;
wire           send_idle_b3_q;
wire           send_idle_b3_d0_din;
wire           send_idle_b3_d0_q;
wire           send_idle_b3_d1_din;
wire           send_idle_b3_d1_q;
wire           slowpath_continue_din;
wire           slowpath_continue_q;
wire           beat2_din;
wire           beat2_q;
wire           beat2_d0_din;
wire           beat2_d0_q;
wire           ue_in_L_din;
wire           ue_in_L_q;
wire           ue_in_R_din;
wire           ue_in_R_q;
wire           sue_in_L_din;
wire           sue_in_L_q;
wire           sue_in_R_din;
wire           sue_in_R_q;
wire  [13:0]   tx_ack_ptr_old_din;
wire  [13:0]   tx_ack_ptr_old_q;
wire  [1:0]    recal_state_din;
wire  [1:0]    recal_state_q;
wire  [3:0]    pm_msg_din;
wire  [3:0]    pm_msg_q;
//-- wire  [1:0]    rx_rcv_width_din;
//-- wire  [1:0]    rx_rcv_width_q;
wire  [7:0]    stomp_syn_fp_din;
wire  [7:0]    stomp_syn_fp_q;
wire           tx_ack_ptr_no_update_din;
wire           tx_ack_ptr_no_update_q;
wire [3:0]     data_stalled_RL_din;
wire [3:0]     data_stalled_RL_q;
wire [11:0]    tx_ack_ptr_retrain_din;
wire [11:0]    tx_ack_ptr_retrain_q;
wire           retrain_occurred_din;
wire           retrain_occurred_q;
wire           data_stalled_din;
wire           data_stalled_q;
wire           data_stalled_replay_din;
wire           data_stalled_replay_q;
wire           data_from_fastpath_din;
wire           data_from_fastpath_q;
wire           frbuf_replay_delay_din;
wire           frbuf_replay_delay_q;
wire           frbuf_replay_full_din;
wire           frbuf_replay_full_q;
wire           force_idle_after_rbf_din;
wire           force_idle_after_rbf_q;
wire           frbuf_replay_full_reset_din;
wire           frbuf_replay_full_reset_q;
wire           force_idle_hold_din;
wire           force_idle_hold_q;
wire           force_idle_hold_d0_din;
wire           force_idle_hold_d0_q;
wire           force_idle_hold_pm_msg_din;
wire           force_idle_hold_pm_msg_q;
wire           tsm4_din;
wire           tsm4_q;
wire           tsm4_d0_din;
wire           tsm4_d0_q;
wire           tsm4_d1_din;
wire           tsm4_d1_q;
wire           tsm4_d2_din;
wire           tsm4_d2_q;
wire           tsm4_d3_din;
wire           tsm4_d3_q;
wire           second_replay_pend_din;
wire           second_replay_pend_q;
wire           second_error_after_reset_din;
wire           second_error_after_reset_q;
wire           rd_catching_wr_din;
wire           rd_catching_wr_q;
wire           force_idle_now_din;
wire           force_idle_now_q;
wire           force_idle_now_d0_din;
wire           force_idle_now_d0_q;
wire           short_flit_next_partial_din;
wire           short_flit_next_partial_q;
wire           retrain_replay_done_din;
wire           retrain_replay_done_q;
wire           init_credits_sent_din;
wire           init_credits_sent_q;
wire           link_up_din;
wire           link_up_q;
wire           data_stall_finished_din;
wire           data_stall_finished_q;
wire           enable_short_idle_din;
wire           enable_short_idle_q;
wire           crc_data_from_frbuf_din;
wire           crc_data_from_frbuf_q;
wire           send_idle_b012_e0_din;
wire           send_idle_b012_e0_q;
wire           frbuf_xm1_vld_din;
wire           frbuf_xm1_vld_q;
wire           frbuf_xm1_vld_d0_din;
wire           frbuf_xm1_vld_d0_q;
wire           frbuf_xm1_vld_d1_din;
wire           frbuf_xm1_vld_d1_q;
wire           frbuf_xm1_vld_d2_din;
wire           frbuf_xm1_vld_d2_q;
wire           frbuf_xm1_vld_d3_din;
wire           frbuf_xm1_vld_d3_q;
wire           frbuf_xm1_vld_d4_din;
wire           frbuf_xm1_vld_d4_q;
wire           send_idle_din;
wire           send_idle_q;
wire           send_idle_d0_din;
wire           send_idle_d0_q;
wire           send_idle_b0_tmg_din;
wire           send_idle_b0_tmg_q;
wire           send_idle_b1_tmg_din;
wire           send_idle_b1_tmg_q;
wire           stomp_next_sp_syn_din;
wire           stomp_next_sp_syn_q;
wire           send_pm_msg_din;
wire           send_pm_msg_q;
wire           send_pm_msg_d0_din;
wire           send_pm_msg_d0_q;
wire           send_pm_msg_d1_din;
wire           send_pm_msg_d1_q;
wire           pm_sendable_din;
wire           pm_sendable_q;
wire           data_stall_pm_din;
wire           data_stall_pm_q;
wire           go_narrow_next_din;
wire           go_narrow_next_q;
//--wire           pm_msg_sent_wait_din;
//--wire           pm_msg_sent_wait_q;
wire           pm_msg_sent_e0_din;
wire           pm_msg_sent_e0_q;
wire           pm_msg_sent_din;
wire           pm_msg_sent_q;
wire           pm_msg_sent_d0_din;
wire           pm_msg_sent_d0_q;
wire           pm_msg_sent_d1_din;
wire           pm_msg_sent_d1_q;
wire           pm_msg_sent_stall_din;
wire           pm_msg_sent_stall_q;
wire           acks_sent_din;
wire           acks_sent_q;
wire           lbip_vld_din;
wire           lbip_vld_q;
wire           go_narrow_delay_din;
wire           go_narrow_delay_q;
wire           go_narrow_delay_d0_din;
wire           go_narrow_delay_d0_q;
wire           go_narrow_delay_d1_din;
wire           go_narrow_delay_d1_q;
wire           go_narrow_delay_d2_din;
wire           go_narrow_delay_d2_q;
wire           go_narrow_delay_d3_din;
wire           go_narrow_delay_d3_q;
wire           ack_gt_write_din;
wire           ack_gt_write_q;
wire           ack_ptr_err_din;
wire           ack_ptr_err_q;
wire           ack_ptr_wraps_din;
wire           ack_ptr_wraps_q;
wire           rd_catching_wr_e0_din;
wire           rd_catching_wr_e0_q;
wire           truncate_has_occured_din;
wire           truncate_has_occured_q;
wire           frbuf_rd_ptr_ovrflw_din;
wire           frbuf_rd_ptr_ovrflw_q;
wire           tx_ack_pend_vld_din;
wire           tx_ack_pend_vld_q;
wire           send_ctl_b1_din;
wire           send_ctl_b1_q;
wire           frbuf_rd_eq_wr_din;         
wire           frbuf_rd_eq_wr_q;         
wire           frbuf_rd_p1_eq_wr_din;      
wire           frbuf_rd_p1_eq_wr_q;      
wire           frbuf_rd_eq_beats_din;      
wire           frbuf_rd_eq_beats_q;      
wire           frbuf_rd_eq_beats_72_din;   
wire           frbuf_rd_eq_beats_72_q;   
wire           frbuf_rd_m1_eq_beats_din;   
wire           frbuf_rd_m1_eq_beats_q;   
wire           frbuf_rd_p1_eq_beats_72_din;
wire           frbuf_rd_p1_eq_beats_72_q;

wire           spare_00_din;
wire           spare_00_q;
wire           spare_01_din;
wire           spare_01_q;
wire           spare_02_din;
wire           spare_02_q;
wire           spare_03_din;
wire           spare_03_q;
wire           spare_04_din;
wire           spare_04_q;
wire           spare_05_din;
wire           spare_05_q;
wire           spare_06_din;
wire           spare_06_q;
wire           spare_07_din;
wire           spare_07_q;
wire           spare_08_din;
wire           spare_08_q;
wire           spare_09_din;
wire           spare_09_q;
wire           spare_0A_din;
wire           spare_0A_q;
wire           spare_0B_din;
wire           spare_0B_q;
wire           spare_0C_din;
wire           spare_0C_q;
wire           spare_0D_din;
wire           spare_0D_q;
wire           spare_0E_din;
wire           spare_0E_q;
wire           spare_0F_din;
wire           spare_0F_q;
wire           spare_10_din;
wire           spare_10_q;
wire           spare_11_din;
wire           spare_11_q;
wire           spare_12_din;
wire           spare_12_q;
wire           spare_13_din;
wire           spare_13_q;
wire           spare_14_din;
wire           spare_14_q;
wire           spare_15_din;
wire           spare_15_q;
wire           spare_16_din;
wire           spare_16_q;
wire           spare_17_din;
wire           spare_17_q;
wire           spare_18_din;
wire           spare_18_q;
wire           spare_19_din;
wire           spare_19_q;
wire           spare_1A_din;
wire           spare_1A_q;
wire           spare_1B_din;
wire           spare_1B_q;
wire           spare_1C_din;
wire           spare_1C_q;
wire           spare_1D_din;
wire           spare_1D_q;
wire           spare_1E_din;
wire           spare_1E_q;
wire           spare_1F_din;
wire           spare_1F_q;
wire           spare_20_din;
wire           spare_20_q;
wire           spare_21_din;
wire           spare_21_q;
wire           spare_22_din;
wire           spare_22_q;
wire           spare_23_din;
wire           spare_23_q;
wire           spare_24_din;
wire           spare_24_q;
wire           spare_25_din;
wire           spare_25_q;
wire           spare_26_din;
wire           spare_26_q;
wire           spare_27_din;
wire           spare_27_q;
wire           spare_28_din;
wire           spare_28_q;
wire           spare_29_din;
wire           spare_29_q;
wire           spare_2A_din;
wire           spare_2A_q;
wire           spare_2B_din;
wire           spare_2B_q;
wire           spare_2C_din;
wire           spare_2C_q;
wire           spare_2D_din;
wire           spare_2D_q;
wire           spare_2E_din;
wire           spare_2E_q;
wire           spare_2F_din;
wire           spare_2F_q;
wire           spare_30_din;
wire           spare_30_q;
wire           spare_31_din;
wire           spare_31_q;
wire           spare_32_din;
wire           spare_32_q;
wire           spare_33_din;
wire           spare_33_q;
wire           spare_34_din;
wire           spare_34_q;
wire           spare_35_din;
wire           spare_35_q;
wire           spare_36_din;
wire           spare_36_q;
wire           spare_37_din;
wire           spare_37_q;
wire           spare_38_din;
wire           spare_38_q;
wire           spare_39_din;
wire           spare_39_q;
wire           spare_3A_din;
wire           spare_3A_q;
wire           spare_3B_din;
wire           spare_3B_q;
wire           spare_3C_din;
wire           spare_3C_q;
wire           spare_3D_din;
wire           spare_3D_q;
wire           spare_3E_din;
wire           spare_3E_q;
wire           spare_3F_din;
wire           spare_3F_q;

//-- parameter frbuf_size     = 8'hFF;
parameter max_TL_credits = 8'h20;


//-- Load L2s *****************************************************************************************************
dlc_ff #(.width(5)    ,.rstv(0)) reg_reset_n                              (.clk(dl_clk)  ,.reset_n(1'b1)                ,.enable(1'b1)        ,.din(reset_n_din                           )  ,.q(reset_n_q                             ));
dlc_ff #(.width(144)  ,.rstv(0)) reg_buffer_out                           (.clk(dl_clk)  ,.reset_n(reset_latches_n[1])  ,.enable(flt_enable)  ,.din(buffer_out_din                        )  ,.q(buffer_out_q                          ));
dlc_ff #(.width(128)  ,.rstv(0)) reg_buffer_out_d0                        (.clk(dl_clk)  ,.reset_n(reset_latches_n[1])  ,.enable(flt_enable)  ,.din(buffer_out_d0_din                     )  ,.q(buffer_out_d0_q                       ));
dlc_ff #(.width(128)  ,.rstv(0)) reg_buffer_out_d1                        (.clk(dl_clk)  ,.reset_n(reset_latches_n[1])  ,.enable(flt_enable)  ,.din(buffer_out_d1_din                     )  ,.q(buffer_out_d1_q                       ));
dlc_ff #(.width(128)  ,.rstv(0)) reg_buffer_out_d2                        (.clk(dl_clk)  ,.reset_n(reset_latches_n[1])  ,.enable(flt_enable)  ,.din(buffer_out_d2_din                     )  ,.q(buffer_out_d2_q                       ));
dlc_ff #(.width(144)  ,.rstv(0)) reg_lbip                                 (.clk(dl_clk)  ,.reset_n(reset_latches_n[1])  ,.enable(flt_enable)  ,.din(lbip_din                              )  ,.q(lbip_q                                ));
dlc_ff #(.width(128)  ,.rstv(0)) reg_lbip_d0                              (.clk(dl_clk)  ,.reset_n(reset_latches_n[1])  ,.enable(flt_enable)  ,.din(lbip_d0_din                           )  ,.q(lbip_d0_q                             ));
dlc_ff #(.width(128)  ,.rstv(0)) reg_lbip_d1                              (.clk(dl_clk)  ,.reset_n(reset_latches_n[1])  ,.enable(flt_enable)  ,.din(lbip_d1_din                           )  ,.q(lbip_d1_q                             ));
dlc_ff #(.width(128)  ,.rstv(0)) reg_lbip_d2                              (.clk(dl_clk)  ,.reset_n(reset_latches_n[1])  ,.enable(flt_enable)  ,.din(lbip_d2_din                           )  ,.q(lbip_d2_q                             ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_send_ctl_b2_e0                       (.clk(dl_clk)  ,.reset_n(reset_latches_n[1])  ,.enable(flt_enable)  ,.din(send_ctl_b2_e0_din                    )  ,.q(send_ctl_b2_e0_q                      ));  // 
dlc_ff #(.width(1)    ,.rstv(0)) reg_send_replay_b2_e0                    (.clk(dl_clk)  ,.reset_n(reset_latches_n[1])  ,.enable(flt_enable)  ,.din(send_replay_b2_e0_din                 )  ,.q(send_replay_b2_e0_q                   ));  // 
dlc_ff #(.width(1)    ,.rstv(0)) reg_send_idle_b2_e0                      (.clk(dl_clk)  ,.reset_n(reset_latches_n[1])  ,.enable(flt_enable)  ,.din(send_idle_b2_e0_din                   )  ,.q(send_idle_b2_e0_q                     ));  // 
dlc_ff #(.width(82)   ,.rstv(0)) reg_crc_data_in_p1ctl                    (.clk(dl_clk)  ,.reset_n(reset_latches_n[1])  ,.enable(flt_enable)  ,.din(crc_data_in_p1ctl_din                 )  ,.q(crc_data_in_p1ctl_q                   ));  // 
dlc_ff #(.width(128)  ,.rstv(0)) reg_crc_data_in_p1dat                    (.clk(dl_clk)  ,.reset_n(reset_latches_n[1])  ,.enable(flt_enable)  ,.din(crc_data_in_p1dat_din                 )  ,.q(crc_data_in_p1dat_q                   ));  // 
dlc_ff #(.width(128)  ,.rstv(0)) reg_crc_shift_data_fp                    (.clk(dl_clk)  ,.reset_n(reset_latches_n[1])  ,.enable(flt_enable)  ,.din(crc_shift_data_fp_din                 )  ,.q(crc_shift_data_fp_q                   ));  // 
dlc_ff #(.width(2)    ,.rstv(0)) reg_beat                                 (.clk(dl_clk)  ,.reset_n(reset_latches_n[1])  ,.enable(flt_enable)  ,.din(beat_din                              )  ,.q(beat_q                                ));
dlc_ff #(.width(4)    ,.rstv(0)) reg_run_length                           (.clk(dl_clk)  ,.reset_n(reset_latches_n[1])  ,.enable(flt_enable)  ,.din(run_length_din                        )  ,.q(run_length_q                          ));
dlc_ff #(.width(36)   ,.rstv(0)) reg_crc_checkbits                        (.clk(dl_clk)  ,.reset_n(reset_latches_n[1])  ,.enable(flt_enable)  ,.din(crc_checkbits_din                     )  ,.q(crc_checkbits_q                       ));
dlc_ff #(.width(128)  ,.rstv(0)) reg_dl_content                           (.clk(dl_clk)  ,.reset_n(reset_latches_n[1])  ,.enable(flt_enable)  ,.din(dl_content_din                        )  ,.q(dl_content_q                          ));
dlc_ff #(.width(128)  ,.rstv(0)) reg_dl_content_short_flit_next           (.clk(dl_clk)  ,.reset_n(reset_latches_n[1])  ,.enable(flt_enable)  ,.din(dl_content_short_flit_next_din        )  ,.q(dl_content_short_flit_next_q          ));
dlc_ff #(.width(32)   ,.rstv(0)) reg_dl2dl_flit_to_send                   (.clk(dl_clk)  ,.reset_n(reset_latches_n[1])  ,.enable(flt_enable)  ,.din(dl2dl_flit_to_send_din                )  ,.q(dl2dl_flit_to_send_q                  ));
dlc_ff #(.width(8)    ,.rstv(0)) reg_frbuf_wr_ptr                         (.clk(dl_clk)  ,.reset_n(reset_latches_n[1])  ,.enable(flt_enable)  ,.din(frbuf_wr_ptr_din                      )  ,.q(frbuf_wr_ptr_q                        ));
dlc_ff #(.width(8)    ,.rstv(0)) reg_frbuf_rd_ptr                         (.clk(dl_clk)  ,.reset_n(reset_latches_n[1])  ,.enable(flt_enable)  ,.din(frbuf_rd_ptr_din                      )  ,.q(frbuf_rd_ptr_q                        ));
dlc_ff #(.width(4)    ,.rstv(0)) reg_replay_count                         (.clk(dl_clk)  ,.reset_n(reset_latches_n[1])  ,.enable(flt_enable)  ,.din(replay_count_din                      )  ,.q(replay_count_q                        ));
dlc_ff #(.width(8)    ,.rstv(0)) reg_link_errors                          (.clk(dl_clk)  ,.reset_n(reset_latches_n[1])  ,.enable(flt_enable)  ,.din(link_errors_din                       )  ,.q(link_errors_q                         ));
dlc_ff #(.width(64)   ,.rstv(0)) reg_link_info                            (.clk(dl_clk)  ,.reset_n(reset_latches_n[1])  ,.enable(flt_enable)  ,.din(link_info_din                         )  ,.q(link_info_q                           ));
dlc_ff #(.width(8)    ,.rstv(0)) reg_get_to_next_ctl_cnt                  (.clk(dl_clk)  ,.reset_n(reset_latches_n[1])  ,.enable(flt_enable)  ,.din(get_to_next_ctl_cnt_din               )  ,.q(get_to_next_ctl_cnt_q                 ));
dlc_ff #(.width(14)   ,.rstv(0)) reg_frbuf_replay_pointer                 (.clk(dl_clk)  ,.reset_n(reset_latches_n[1])  ,.enable(flt_enable)  ,.din(frbuf_replay_pointer_din              )  ,.q(frbuf_replay_pointer_q                ));
dlc_ff #(.width(14)   ,.rstv(0)) reg_rx_ack_ptr                           (.clk(dl_clk)  ,.reset_n(reset_latches_n[1])  ,.enable(flt_enable)  ,.din(rx_ack_ptr_din                        )  ,.q(rx_ack_ptr_q                          ));
dlc_ff #(.width(14)   ,.rstv(0)) reg_tx_ack_ptr                           (.clk(dl_clk)  ,.reset_n(reset_latches_n[1])  ,.enable(flt_enable)  ,.din(tx_ack_ptr_din                        )  ,.q(tx_ack_ptr_q                          ));
dlc_ff #(.width(14)   ,.rstv(0)) reg_tx_ack_ptr_pend                      (.clk(dl_clk)  ,.reset_n(reset_latches_n[1])  ,.enable(flt_enable)  ,.din(tx_ack_ptr_pend_din                   )  ,.q(tx_ack_ptr_pend_q                     ));
dlc_ff #(.width(6)    ,.rstv(0)) reg_rtn_ack_cnt                          (.clk(dl_clk)  ,.reset_n(reset_latches_n[1])  ,.enable(flt_enable)  ,.din(rtn_ack_cnt_din                       )  ,.q(rtn_ack_cnt_q                         ));
dlc_ff #(.width(2)    ,.rstv(0)) reg_flit_type                            (.clk(dl_clk)  ,.reset_n(reset_latches_n[1])  ,.enable(flt_enable)  ,.din(flit_type_din                         )  ,.q(flit_type_q                           ));
dlc_ff #(.width(8)    ,.rstv(0)) reg_frame_buf_credit_cnt                 (.clk(dl_clk)  ,.reset_n(reset_latches_n[1])  ,.enable(flt_enable)  ,.din(frame_buf_credit_cnt_din              )  ,.q(frame_buf_credit_cnt_q                ));
dlc_ff #(.width(8)    ,.rstv(0)) reg_tl_credit_cnt                        (.clk(dl_clk)  ,.reset_n(reset_latches_n[1])  ,.enable(flt_enable)  ,.din(tl_credit_cnt_din                     )  ,.q(tl_credit_cnt_q                       ));
dlc_ff #(.width(3)    ,.rstv(0)) reg_slowpath_cnt                         (.clk(dl_clk)  ,.reset_n(reset_latches_n[1])  ,.enable(flt_enable)  ,.din(slowpath_cnt_din                      )  ,.q(slowpath_cnt_q                        ));
dlc_ff #(.width(3)    ,.rstv(0)) reg_pre_replay_idle_cnt                  (.clk(dl_clk)  ,.reset_n(reset_latches_n[1])  ,.enable(flt_enable)  ,.din(pre_replay_idle_cnt_din               )  ,.q(pre_replay_idle_cnt_q                 ));
dlc_ff #(.width(4)    ,.rstv(0)) reg_prev_cmd_run_length                  (.clk(dl_clk)  ,.reset_n(reset_latches_n[1])  ,.enable(flt_enable)  ,.din(prev_cmd_run_length_din               )  ,.q(prev_cmd_run_length_q                 ));
dlc_ff #(.width(8)    ,.rstv(0)) reg_beats_sent                           (.clk(dl_clk)  ,.reset_n(reset_latches_n[1])  ,.enable(flt_enable)  ,.din(beats_sent_din                        )  ,.q(beats_sent_q                          ));
dlc_ff #(.width(4)    ,.rstv(0)) reg_cnt_after_early_vld_drops            (.clk(dl_clk)  ,.reset_n(reset_latches_n[1])  ,.enable(flt_enable)  ,.din(cnt_after_early_vld_drops_din         )  ,.q(cnt_after_early_vld_drops_q           ));
dlc_ff #(.width(6)    ,.rstv(0)) reg_ue_rpb_cf_delay                      (.clk(dl_clk)  ,.reset_n(reset_latches_n[1])  ,.enable(flt_enable)  ,.din(ue_rpb_cf_delay_din                   )  ,.q(ue_rpb_cf_delay_q                     ));
dlc_ff #(.width(6)    ,.rstv(0)) reg_ue_rpb_df0_delay                     (.clk(dl_clk)  ,.reset_n(reset_latches_n[1])  ,.enable(flt_enable)  ,.din(ue_rpb_df0_delay_din                  )  ,.q(ue_rpb_df0_delay_q                    ));
dlc_ff #(.width(6)    ,.rstv(0)) reg_ue_rpb_df1_delay                     (.clk(dl_clk)  ,.reset_n(reset_latches_n[1])  ,.enable(flt_enable)  ,.din(ue_rpb_df1_delay_din                  )  ,.q(ue_rpb_df1_delay_q                    ));
dlc_ff #(.width(14)   ,.rstv(0)) reg_tx_ack_ptr_old                       (.clk(dl_clk)  ,.reset_n(reset_latches_n[1])  ,.enable(flt_enable)  ,.din(tx_ack_ptr_old_din                    )  ,.q(tx_ack_ptr_old_q                      ));
dlc_ff #(.width(2)    ,.rstv(0)) reg_recal_state                          (.clk(dl_clk)  ,.reset_n(reset_latches_n[1])  ,.enable(flt_enable)  ,.din(recal_state_din                       )  ,.q(recal_state_q                         ));
dlc_ff #(.width(4)    ,.rstv(0)) reg_pm_msg                               (.clk(dl_clk)  ,.reset_n(reset_latches_n[1])  ,.enable(flt_enable)  ,.din(pm_msg_din                            )  ,.q(pm_msg_q                              ));
dlc_ff #(.width(4)    ,.rstv(0)) reg_go_narrow_cnt                        (.clk(dl_clk)  ,.reset_n(reset_latches_n[1])  ,.enable(flt_enable)  ,.din(go_narrow_cnt_din                     )  ,.q(go_narrow_cnt_q                       ));
//-- dlc_ff #(.width(2)    ,.rstv(0)) reg_rx_rcv_width                         (.clk(dl_clk)  ,.reset_n(reset_latches_n[1])  ,.enable(flt_enable)  ,.din(rx_rcv_width_din                      )  ,.q(rx_rcv_width_q                        ));
dlc_ff #(.width(3)    ,.rstv(0)) reg_beats_sent_retrain_adj               (.clk(dl_clk)  ,.reset_n(reset_latches_n[1])  ,.enable(flt_enable)  ,.din(beats_sent_retrain_adj_din            )  ,.q(beats_sent_retrain_adj_q              ));
dlc_ff #(.width(8)    ,.rstv(0)) reg_stomp_syn_fp                         (.clk(dl_clk)  ,.reset_n(reset_latches_n[1])  ,.enable(flt_enable)  ,.din(stomp_syn_fp_din                      )  ,.q(stomp_syn_fp_q                        ));
dlc_ff #(.width(128)  ,.rstv(0)) reg_flt_agn_data_int                     (.clk(dl_clk)  ,.reset_n(reset_latches_n[1])  ,.enable(flt_enable)  ,.din(flt_agn_data_int_din                  )  ,.q(flt_agn_data_int_q                    ));
dlc_ff #(.width(32)   ,.rstv(0)) reg_tl2dl_data_debug                     (.clk(dl_clk)  ,.reset_n(reset_latches_n[1])  ,.enable(flt_enable)  ,.din(tl2dl_data_debug_din                  )  ,.q(tl2dl_data_debug_q                    ));
dlc_ff #(.width(3)    ,.rstv(0)) reg_tl2dl_misc_debug                     (.clk(dl_clk)  ,.reset_n(reset_latches_n[1])  ,.enable(flt_enable)  ,.din(tl2dl_misc_debug_din                  )  ,.q(tl2dl_misc_debug_q                    ));

//-- dlc_ff #(.width(3)    ,.rstv(0)) reg_req_width_tx_mode                    (.clk(dl_clk)  ,.reset_n(reset_latches_n[1])  ,.enable(flt_enable)  ,.din(req_width_tx_mode_din                 )  ,.q(req_width_tx_mode_q                   ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_fastpath                             (.clk(dl_clk)  ,.reset_n(reset_latches_n[1])  ,.enable(flt_enable)  ,.din(fastpath_din                          )  ,.q(fastpath_q                            ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_fastpath_l                           (.clk(dl_clk)  ,.reset_n(reset_latches_n[1])  ,.enable(flt_enable)  ,.din(fastpath_l_din                        )  ,.q(fastpath_l_q                          ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_fastpath_r                           (.clk(dl_clk)  ,.reset_n(reset_latches_n[1])  ,.enable(flt_enable)  ,.din(fastpath_r_din                        )  ,.q(fastpath_r_q                          ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_fastpath_d0                          (.clk(dl_clk)  ,.reset_n(reset_latches_n[1])  ,.enable(flt_enable)  ,.din(fastpath_d0_din                       )  ,.q(fastpath_d0_q                         ));  
dlc_ff #(.width(1)    ,.rstv(0)) reg_fastpath_d1                          (.clk(dl_clk)  ,.reset_n(reset_latches_n[1])  ,.enable(flt_enable)  ,.din(fastpath_d1_din                       )  ,.q(fastpath_d1_q                         ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_delayed_fastpath                     (.clk(dl_clk)  ,.reset_n(reset_latches_n[1])  ,.enable(flt_enable)  ,.din(delayed_fastpath_din                  )  ,.q(delayed_fastpath_q                    ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_delayed_fastpath_d0                  (.clk(dl_clk)  ,.reset_n(reset_latches_n[2])  ,.enable(flt_enable)  ,.din(delayed_fastpath_d0_din               )  ,.q(delayed_fastpath_d0_q                 ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_double_delayed_fastpath              (.clk(dl_clk)  ,.reset_n(reset_latches_n[2])  ,.enable(flt_enable)  ,.din(double_delayed_fastpath_din           )  ,.q(double_delayed_fastpath_q             ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_double_delayed_fastpath_d0           (.clk(dl_clk)  ,.reset_n(reset_latches_n[2])  ,.enable(flt_enable)  ,.din(double_delayed_fastpath_d0_din        )  ,.q(double_delayed_fastpath_d0_q          ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_double_delayed_fastpath_d1           (.clk(dl_clk)  ,.reset_n(reset_latches_n[2])  ,.enable(flt_enable)  ,.din(double_delayed_fastpath_d1_din        )  ,.q(double_delayed_fastpath_d1_q          ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_triple_delayed_fastpath              (.clk(dl_clk)  ,.reset_n(reset_latches_n[2])  ,.enable(flt_enable)  ,.din(triple_delayed_fastpath_din           )  ,.q(triple_delayed_fastpath_q             ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_triple_delayed_fastpath_d0           (.clk(dl_clk)  ,.reset_n(reset_latches_n[2])  ,.enable(flt_enable)  ,.din(triple_delayed_fastpath_d0_din        )  ,.q(triple_delayed_fastpath_d0_q          ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_quad_delayed_fastpath                (.clk(dl_clk)  ,.reset_n(reset_latches_n[2])  ,.enable(flt_enable)  ,.din(quad_delayed_fastpath_din             )  ,.q(quad_delayed_fastpath_q               ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_quad_delayed_fastpath_d0             (.clk(dl_clk)  ,.reset_n(reset_latches_n[2])  ,.enable(flt_enable)  ,.din(quad_delayed_fastpath_d0_din          )  ,.q(quad_delayed_fastpath_d0_q            ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_quad_delayed_fastpath_d1             (.clk(dl_clk)  ,.reset_n(reset_latches_n[2])  ,.enable(flt_enable)  ,.din(quad_delayed_fastpath_d1_din          )  ,.q(quad_delayed_fastpath_d1_q            ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_quad_delayed_fastpath_d2             (.clk(dl_clk)  ,.reset_n(reset_latches_n[2])  ,.enable(flt_enable)  ,.din(quad_delayed_fastpath_d2_din          )  ,.q(quad_delayed_fastpath_d2_q            ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_quad_delayed_fastpath_d3             (.clk(dl_clk)  ,.reset_n(reset_latches_n[2])  ,.enable(flt_enable)  ,.din(quad_delayed_fastpath_d3_din          )  ,.q(quad_delayed_fastpath_d3_q            ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_quad_delayed_fastpath_d4             (.clk(dl_clk)  ,.reset_n(reset_latches_n[2])  ,.enable(flt_enable)  ,.din(quad_delayed_fastpath_d4_din          )  ,.q(quad_delayed_fastpath_d4_q            ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_any_fastpath                         (.clk(dl_clk)  ,.reset_n(reset_latches_n[2])  ,.enable(flt_enable)  ,.din(any_fastpath_din                      )  ,.q(any_fastpath_q                        ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_any_fastpath_d0                      (.clk(dl_clk)  ,.reset_n(reset_latches_n[2])  ,.enable(flt_enable)  ,.din(any_fastpath_d0_din                   )  ,.q(any_fastpath_d0_q                     ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_any_fastpath_d1                      (.clk(dl_clk)  ,.reset_n(reset_latches_n[2])  ,.enable(flt_enable)  ,.din(any_fastpath_d1_din                   )  ,.q(any_fastpath_d1_q                     ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_any_fastpath_d2                      (.clk(dl_clk)  ,.reset_n(reset_latches_n[2])  ,.enable(flt_enable)  ,.din(any_fastpath_d2_din                   )  ,.q(any_fastpath_d2_q                     ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_any_fastpath_d3                      (.clk(dl_clk)  ,.reset_n(reset_latches_n[2])  ,.enable(flt_enable)  ,.din(any_fastpath_d3_din                   )  ,.q(any_fastpath_d3_q                     ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_any_fastpath_d4                      (.clk(dl_clk)  ,.reset_n(reset_latches_n[2])  ,.enable(flt_enable)  ,.din(any_fastpath_d4_din                   )  ,.q(any_fastpath_d4_q                     ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_stall_d0                             (.clk(dl_clk)  ,.reset_n(reset_latches_n[2])  ,.enable(flt_enable)  ,.din(stall_d0_din                          )  ,.q(stall_d0_q                            ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_stall_d1                             (.clk(dl_clk)  ,.reset_n(reset_latches_n[2])  ,.enable(flt_enable)  ,.din(stall_d1_din                          )  ,.q(stall_d1_q                            ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_stall_d2                             (.clk(dl_clk)  ,.reset_n(reset_latches_n[2])  ,.enable(flt_enable)  ,.din(stall_d2_din                          )  ,.q(stall_d2_q                            ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_stall_d3                             (.clk(dl_clk)  ,.reset_n(reset_latches_n[2])  ,.enable(flt_enable)  ,.din(stall_d3_din                          )  ,.q(stall_d3_q                            ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_stall_d4                             (.clk(dl_clk)  ,.reset_n(reset_latches_n[2])  ,.enable(flt_enable)  ,.din(stall_d4_din                          )  ,.q(stall_d4_q                            ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_stall_d5                             (.clk(dl_clk)  ,.reset_n(reset_latches_n[2])  ,.enable(flt_enable)  ,.din(stall_d5_din                          )  ,.q(stall_d5_q                            ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_stall_d6                             (.clk(dl_clk)  ,.reset_n(reset_latches_n[2])  ,.enable(flt_enable)  ,.din(stall_d6_din                          )  ,.q(stall_d6_q                            ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_stall_d7                             (.clk(dl_clk)  ,.reset_n(reset_latches_n[2])  ,.enable(flt_enable)  ,.din(stall_d7_din                          )  ,.q(stall_d7_q                            ));
//-- dlc_ff #(.width(1)    ,.rstv(0)) reg_real_stall_d0                        (.clk(dl_clk)  ,.reset_n(reset_latches_n[2])  ,.enable(flt_enable)  ,.din(real_stall_d0_din                     )  ,.q(real_stall_d0_q                       ));
//-- dlc_ff #(.width(1)    ,.rstv(0)) reg_real_stall_d1                        (.clk(dl_clk)  ,.reset_n(reset_latches_n[2])  ,.enable(flt_enable)  ,.din(real_stall_d1_din                     )  ,.q(real_stall_d1_q                       ));
//-- dlc_ff #(.width(1)    ,.rstv(0)) reg_real_stall_d2                        (.clk(dl_clk)  ,.reset_n(reset_latches_n[2])  ,.enable(flt_enable)  ,.din(real_stall_d2_din                     )  ,.q(real_stall_d2_q                       ));
//-- dlc_ff #(.width(1)    ,.rstv(0)) reg_real_stall_d3                        (.clk(dl_clk)  ,.reset_n(reset_latches_n[2])  ,.enable(flt_enable)  ,.din(real_stall_d3_din                     )  ,.q(real_stall_d3_q                       ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_real_stall_d4                        (.clk(dl_clk)  ,.reset_n(reset_latches_n[2])  ,.enable(flt_enable)  ,.din(real_stall_d4_din                     )  ,.q(real_stall_d4_q                       ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_beats_sent_invalid                   (.clk(dl_clk)  ,.reset_n(reset_latches_n[2])  ,.enable(flt_enable)  ,.din(beats_sent_invalid_din                )  ,.q(beats_sent_invalid_q                  ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_frbuf_rd_vld                         (.clk(dl_clk)  ,.reset_n(reset_latches_n[2])  ,.enable(flt_enable)  ,.din(frbuf_rd_vld_din                      )  ,.q(frbuf_rd_vld_q                        ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_frbuf_rd_vld_d0                      (.clk(dl_clk)  ,.reset_n(reset_latches_n[2])  ,.enable(flt_enable)  ,.din(frbuf_rd_vld_d0_din                   )  ,.q(frbuf_rd_vld_d0_q                     ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_frbuf_rd_vld_d1                      (.clk(dl_clk)  ,.reset_n(reset_latches_n[2])  ,.enable(flt_enable)  ,.din(frbuf_rd_vld_d1_din                   )  ,.q(frbuf_rd_vld_d1_q                     ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_frbuf_rd_vld_d2                      (.clk(dl_clk)  ,.reset_n(reset_latches_n[2])  ,.enable(flt_enable)  ,.din(frbuf_rd_vld_d2_din                   )  ,.q(frbuf_rd_vld_d2_q                     ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_frbuf_rd_vld_d3                      (.clk(dl_clk)  ,.reset_n(reset_latches_n[2])  ,.enable(flt_enable)  ,.din(frbuf_rd_vld_d3_din                   )  ,.q(frbuf_rd_vld_d3_q                     ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_frbuf_rd_vld_d4                      (.clk(dl_clk)  ,.reset_n(reset_latches_n[2])  ,.enable(flt_enable)  ,.din(frbuf_rd_vld_d4_din                   )  ,.q(frbuf_rd_vld_d4_q                     ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_frbuf_x2_continue                    (.clk(dl_clk)  ,.reset_n(reset_latches_n[2])  ,.enable(flt_enable)  ,.din(frbuf_x2_continue_din                 )  ,.q(frbuf_x2_continue_q                   ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_replay_in_progress                   (.clk(dl_clk)  ,.reset_n(reset_latches_n[2])  ,.enable(flt_enable)  ,.din(replay_in_progress_din                )  ,.q(replay_in_progress_q                  ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_replay_in_progress_d0                (.clk(dl_clk)  ,.reset_n(reset_latches_n[2])  ,.enable(flt_enable)  ,.din(replay_in_progress_d0_din             )  ,.q(replay_in_progress_d0_q               ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_replay_in_progress_d1                (.clk(dl_clk)  ,.reset_n(reset_latches_n[2])  ,.enable(flt_enable)  ,.din(replay_in_progress_d1_din             )  ,.q(replay_in_progress_d1_q               ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_send_nack                            (.clk(dl_clk)  ,.reset_n(reset_latches_n[2])  ,.enable(flt_enable)  ,.din(send_nack_din                         )  ,.q(send_nack_q                           ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_nack                                 (.clk(dl_clk)  ,.reset_n(reset_latches_n[2])  ,.enable(flt_enable)  ,.din(nack_din                              )  ,.q(nack_q                                ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_nack_d0                              (.clk(dl_clk)  ,.reset_n(reset_latches_n[2])  ,.enable(flt_enable)  ,.din(nack_d0_din                           )  ,.q(nack_d0_q                             ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_nack_pend                            (.clk(dl_clk)  ,.reset_n(reset_latches_n[2])  ,.enable(flt_enable)  ,.din(nack_pend_din                         )  ,.q(nack_pend_q                           ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_init_replay_done                     (.clk(dl_clk)  ,.reset_n(reset_latches_n[2])  ,.enable(flt_enable)  ,.din(init_replay_done_din                  )  ,.q(init_replay_done_q                    ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_init_replay_late_done                (.clk(dl_clk)  ,.reset_n(reset_latches_n[2])  ,.enable(flt_enable)  ,.din(init_replay_late_done_din             )  ,.q(init_replay_late_done_q               ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_send_no_replay_data                  (.clk(dl_clk)  ,.reset_n(reset_latches_n[2])  ,.enable(flt_enable)  ,.din(send_no_replay_data_din               )  ,.q(send_no_replay_data_q                 ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_frbuf_empty                          (.clk(dl_clk)  ,.reset_n(reset_latches_n[2])  ,.enable(flt_enable)  ,.din(frbuf_empty_din                       )  ,.q(frbuf_empty_q                         ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_frbuf_empty_d0                       (.clk(dl_clk)  ,.reset_n(reset_latches_n[2])  ,.enable(flt_enable)  ,.din(frbuf_empty_d0_din                    )  ,.q(frbuf_empty_d0_q                      ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_frbuf_empty_d1                       (.clk(dl_clk)  ,.reset_n(reset_latches_n[2])  ,.enable(flt_enable)  ,.din(frbuf_empty_d1_din                    )  ,.q(frbuf_empty_d1_q                      ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_train_done                           (.clk(dl_clk)  ,.reset_n(reset_latches_n[2])  ,.enable(flt_enable)  ,.din(train_done_din                        )  ,.q(train_done_q                          ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_train_done_d0                        (.clk(dl_clk)  ,.reset_n(reset_latches_n[2])  ,.enable(flt_enable)  ,.din(train_done_d0_din                     )  ,.q(train_done_d0_q                       ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_train_done_d1                        (.clk(dl_clk)  ,.reset_n(reset_latches_n[2])  ,.enable(flt_enable)  ,.din(train_done_d1_din                     )  ,.q(train_done_d1_q                       ));
//-- dlc_ff #(.width(1)    ,.rstv(0)) reg_rx_rl_not_vld                        (.clk(dl_clk)  ,.reset_n(reset_latches_n[2])  ,.enable(flt_enable)  ,.din(rx_rl_not_vld_din                     )  ,.q(rx_rl_not_vld_q                       ));
//-- dlc_ff #(.width(1)    ,.rstv(0)) reg_rx_ack_ptr_6_d                       (.clk(dl_clk)  ,.reset_n(reset_latches_n[2])  ,.enable(flt_enable)  ,.din(rx_ack_ptr_6_d_din                    )  ,.q(rx_ack_ptr_6_d_q                      ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_flit_vld                             (.clk(dl_clk)  ,.reset_n(reset_latches_n[2])  ,.enable(flt_enable)  ,.din(flit_vld_din                          )  ,.q(flit_vld_q                            ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_tx_rl_not_vld                        (.clk(dl_clk)  ,.reset_n(reset_latches_n[2])  ,.enable(flt_enable)  ,.din(tx_rl_not_vld_din                     )  ,.q(tx_rl_not_vld_q                       ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_reset_occurred                       (.clk(dl_clk)  ,.reset_n(reset_latches_n[2])  ,.enable(flt_enable)  ,.din(reset_occurred_din                    )  ,.q(reset_occurred_q                      ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_frbuf_rd0_select_pair0               (.clk(dl_clk)  ,.reset_n(reset_latches_n[2])  ,.enable(flt_enable)  ,.din(frbuf_rd0_select_pair0_din            )  ,.q(frbuf_rd0_select_pair0_q              ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_frbuf_rd0_select_pair1               (.clk(dl_clk)  ,.reset_n(reset_latches_n[2])  ,.enable(flt_enable)  ,.din(frbuf_rd0_select_pair1_din            )  ,.q(frbuf_rd0_select_pair1_q              ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_send_ctl                             (.clk(dl_clk)  ,.reset_n(reset_latches_n[2])  ,.enable(flt_enable)  ,.din(send_ctl_din                          )  ,.q(send_ctl_q                            ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_crc_zero_checkbits_next              (.clk(dl_clk)  ,.reset_n(reset_latches_n[2])  ,.enable(flt_enable)  ,.din(crc_zero_checkbits_next_din           )  ,.q(crc_zero_checkbits_next_q             ));
dlc_ff #(.width(1)    ,.rstv(0)) data_stall_finished                      (.clk(dl_clk)  ,.reset_n(reset_latches_n[2])  ,.enable(flt_enable)  ,.din(data_stall_finished_din               )  ,.q(data_stall_finished_q                 ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_crc_zero_checkbits_next_d0           (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(crc_zero_checkbits_next_d0_din        )  ,.q(crc_zero_checkbits_next_d0_q          ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_crc_zero_checkbits_next_d1           (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(crc_zero_checkbits_next_d1_din        )  ,.q(crc_zero_checkbits_next_d1_q          ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_crc_zero_checkbits_next_d2           (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(crc_zero_checkbits_next_d2_din        )  ,.q(crc_zero_checkbits_next_d2_q          ));
//-- dlc_ff #(.width(1)    ,.rstv(0)) reg_crc_zero_checkbits_next_d3           (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(crc_zero_checkbits_next_d3_din        )  ,.q(crc_zero_checkbits_next_d3_q          ));
//-- dlc_ff #(.width(1)    ,.rstv(0)) reg_crc_zero_checkbits_next_d4           (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(crc_zero_checkbits_next_d4_din        )  ,.q(crc_zero_checkbits_next_d4_q          ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_crc_zero_checkbits_stall_delay       (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(crc_zero_checkbits_stall_delay_din    )  ,.q(crc_zero_checkbits_stall_delay_q      ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_tl2dl_flit_vld                       (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(tl2dl_flit_vld_din                    )  ,.q(tl2dl_flit_vld_q                      ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_tl2dl_flit_vld_d0                    (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(tl2dl_flit_vld_d0_din                 )  ,.q(tl2dl_flit_vld_d0_q                   ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_tl2dl_flit_early_vld                 (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(tl2dl_flit_early_vld_din              )  ,.q(tl2dl_flit_early_vld_q                ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_tl2dl_flit_early_l_vld               (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(tl2dl_flit_early_vld_l_din            )  ,.q(tl2dl_flit_early_vld_l_q                ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_tl2dl_flit_early_r_vld               (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(tl2dl_flit_early_vld_r_din            )  ,.q(tl2dl_flit_early_vld_r_q                ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_tl2dl_flit_early_vld_d1              (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(tl2dl_flit_early_vld_d1_din           )  ,.q(tl2dl_flit_early_vld_d1_q             ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_not_reset_ack_cnt                    (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(not_reset_ack_cnt_din                 )  ,.q(not_reset_ack_cnt_q                   ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_send_idle_next                       (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(send_idle_next_din                    )  ,.q(send_idle_next_q                      ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_short_flit_next                      (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(short_flit_next_din                   )  ,.q(short_flit_next_q                     ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_short_flit_next_d0                   (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(short_flit_next_d0_din                )  ,.q(short_flit_next_d0_q                  ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_short_flit_next_d1                   (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(short_flit_next_d1_din                )  ,.q(short_flit_next_d1_q                  ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_short_flit_next_d2                   (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(short_flit_next_d2_din                )  ,.q(short_flit_next_d2_q                  ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_short_flit_next_d3                   (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(short_flit_next_d3_din                )  ,.q(short_flit_next_d3_q                  ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_go_to_idle_after_flit                (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(go_to_idle_after_flit_din             )  ,.q(go_to_idle_after_flit_q               ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_read_from_array_valid                (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(read_from_array_valid_din             )  ,.q(read_from_array_valid_q               ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_slowpath_align                       (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(slowpath_align_din                    )  ,.q(slowpath_align_q                      ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_enable_credit_return                 (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(enable_credit_return_din              )  ,.q(enable_credit_return_q                ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_enable_credit_return_d0              (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(enable_credit_return_d0_din           )  ,.q(enable_credit_return_d0_q             ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_enable_credit_return_d1              (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(enable_credit_return_d1_din           )  ,.q(enable_credit_return_d1_q             ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_fp_frbuf_empty                       (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(fp_frbuf_empty_din                    )  ,.q(fp_frbuf_empty_q                      ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_fp_frbuf_empty_d0                    (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(fp_frbuf_empty_d0_din                 )  ,.q(fp_frbuf_empty_d0_q                   ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_fastpath_start                       (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(fastpath_start_din                    )  ,.q(fastpath_start_q                      ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_fastpath_start_d0                    (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(fastpath_start_d0_din                 )  ,.q(fastpath_start_d0_q                   ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_short_flit_next_e0                   (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(short_flit_next_e0_din                )  ,.q(short_flit_next_e0_q                  ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_send_idle_next_e0                    (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(send_idle_next_e0_din                 )  ,.q(send_idle_next_e0_q                   ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_send_idle_next_partial               (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(send_idle_next_partial_din            )  ,.q(send_idle_next_partial_q              ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_fastpath_end                         (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(fastpath_end_din                      )  ,.q(fastpath_end_q                        ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_fastpath_end_d0                      (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(fastpath_end_d0_din                   )  ,.q(fastpath_end_d0_q                     ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_fastpath_end_d1                      (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(fastpath_end_d1_din                   )  ,.q(fastpath_end_d1_q                     ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_send_ctl_b3_fp                       (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(send_ctl_b3_fp_din                    )  ,.q(send_ctl_b3_fp_q                      ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_one_valid_stutter                    (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(one_valid_stutter_din                 )  ,.q(one_valid_stutter_q                   ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_one_valid_stutter_d0                 (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(one_valid_stutter_d0_din              )  ,.q(one_valid_stutter_d0_q                ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_one_valid_stutter_d1                 (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(one_valid_stutter_d1_din              )  ,.q(one_valid_stutter_d1_q                ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_one_valid_stutter_d2                 (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(one_valid_stutter_d2_din              )  ,.q(one_valid_stutter_d2_q                ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_one_valid_stutter_d3                 (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(one_valid_stutter_d3_din              )  ,.q(one_valid_stutter_d3_q                ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_two_valid_stutter                    (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(two_valid_stutter_din                 )  ,.q(two_valid_stutter_q                   ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_two_valid_stutter_d0                 (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(two_valid_stutter_d0_din              )  ,.q(two_valid_stutter_d0_q                ));
//-- dlc_ff #(.width(1)    ,.rstv(0)) reg_three_valid_stutter                  (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(three_valid_stutter_din               )  ,.q(three_valid_stutter_q                 ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_replay_short_idle                    (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(replay_short_idle_din                 )  ,.q(replay_short_idle_q                   ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_replay_b2                            (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(replay_b2_din                         )  ,.q(replay_b2_q                           ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_replay_b2_d0                         (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(replay_b2_d0_din                      )  ,.q(replay_b2_d0_q                        ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_replay_b2_d1                         (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(replay_b2_d1_din                      )  ,.q(replay_b2_d1_q                        ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_replay_b2_d2                         (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(replay_b2_d2_din                      )  ,.q(replay_b2_d2_q                        ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_replay_b2_d3                         (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(replay_b2_d3_din                      )  ,.q(replay_b2_d3_q                        ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_replay_b2_d4                         (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(replay_b2_d4_din                      )  ,.q(replay_b2_d4_q                        ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_replay_b2_d5                         (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(replay_b2_d5_din                      )  ,.q(replay_b2_d5_q                        ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_replay_b2_d6                         (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(replay_b2_d6_din                      )  ,.q(replay_b2_d6_q                        ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_replay_b2_d7                         (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(replay_b2_d7_din                      )  ,.q(replay_b2_d7_q                        ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_replay_b2_d8                         (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(replay_b2_d8_din                      )  ,.q(replay_b2_d8_q                        ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_replay_done                          (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(replay_done_din                       )  ,.q(replay_done_q                         ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_replay_done_d0                       (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(replay_done_d0_din                    )  ,.q(replay_done_d0_q                      ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_replay_done_d1                       (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(replay_done_d1_din                    )  ,.q(replay_done_d1_q                      ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_no_data_in_frbuf                     (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(no_data_in_frbuf_din                  )  ,.q(no_data_in_frbuf_q                    ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_slowpath_glitch                      (.clk(dl_clk)  ,.reset_n(reset_latches_n[4])  ,.enable(flt_enable)  ,.din(slowpath_glitch_din                   )  ,.q(slowpath_glitch_q                     ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_slowpath_glitch_cmplt                (.clk(dl_clk)  ,.reset_n(reset_latches_n[4])  ,.enable(flt_enable)  ,.din(slowpath_glitch_cmplt_din             )  ,.q(slowpath_glitch_cmplt_q               ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_slowpath_glitch_cmplt_d0             (.clk(dl_clk)  ,.reset_n(reset_latches_n[4])  ,.enable(flt_enable)  ,.din(slowpath_glitch_cmplt_d0_din          )  ,.q(slowpath_glitch_cmplt_d0_q            ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_send_dl2dl_flit                      (.clk(dl_clk)  ,.reset_n(reset_latches_n[4])  ,.enable(flt_enable)  ,.din(send_dl2dl_flit_din                   )  ,.q(send_dl2dl_flit_q                     ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_send_idle_b0_e0                      (.clk(dl_clk)  ,.reset_n(reset_latches_n[4])  ,.enable(flt_enable)  ,.din(send_idle_b0_e0_din                   )  ,.q(send_idle_b0_e0_q                     ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_pre_fastpath_idle                    (.clk(dl_clk)  ,.reset_n(reset_latches_n[4])  ,.enable(flt_enable)  ,.din(pre_fastpath_idle_din                 )  ,.q(pre_fastpath_idle_q                   ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_idle                                 (.clk(dl_clk)  ,.reset_n(reset_latches_n[4])  ,.enable(flt_enable)  ,.din(idle_din                              )  ,.q(idle_q                                ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_send_idle_b0                         (.clk(dl_clk)  ,.reset_n(reset_latches_n[4])  ,.enable(flt_enable)  ,.din(send_idle_b0_din                      )  ,.q(send_idle_b0_q                        ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_send_idle_b1                         (.clk(dl_clk)  ,.reset_n(reset_latches_n[4])  ,.enable(flt_enable)  ,.din(send_idle_b1_din                      )  ,.q(send_idle_b1_q                        ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_send_idle_b2                         (.clk(dl_clk)  ,.reset_n(reset_latches_n[4])  ,.enable(flt_enable)  ,.din(send_idle_b2_din                      )  ,.q(send_idle_b2_q                        ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_quad_stall_dly                       (.clk(dl_clk)  ,.reset_n(reset_latches_n[4])  ,.enable(flt_enable)  ,.din(quad_stall_dly_din                    )  ,.q(quad_stall_dly_q                      ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_x8_tx_mode                           (.clk(dl_clk)  ,.reset_n(reset_latches_n[4])  ,.enable(flt_enable)  ,.din(x8_tx_mode_din                        )  ,.q(x8_tx_mode_q                          ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_x8_tx_mode_d0                        (.clk(dl_clk)  ,.reset_n(reset_latches_n[4])  ,.enable(flt_enable)  ,.din(x8_tx_mode_d0_din                     )  ,.q(x8_tx_mode_d0_q                       ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_x4_tx_mode                           (.clk(dl_clk)  ,.reset_n(reset_latches_n[4])  ,.enable(flt_enable)  ,.din(x4_tx_mode_din                        )  ,.q(x4_tx_mode_q                          ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_x2_tx_mode                           (.clk(dl_clk)  ,.reset_n(reset_latches_n[4])  ,.enable(flt_enable)  ,.din(x2_tx_mode_din                        )  ,.q(x2_tx_mode_q                          ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_send_ctl_b3                          (.clk(dl_clk)  ,.reset_n(reset_latches_n[4])  ,.enable(flt_enable)  ,.din(send_ctl_b3_din                       )  ,.q(send_ctl_b3_q                         ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_send_ctl_b3_d0                       (.clk(dl_clk)  ,.reset_n(reset_latches_n[4])  ,.enable(flt_enable)  ,.din(send_ctl_b3_d0_din                    )  ,.q(send_ctl_b3_d0_q                      ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_send_ctl_b3_d1                       (.clk(dl_clk)  ,.reset_n(reset_latches_n[4])  ,.enable(flt_enable)  ,.din(send_ctl_b3_d1_din                    )  ,.q(send_ctl_b3_d1_q                      ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_send_replay_b3                       (.clk(dl_clk)  ,.reset_n(reset_latches_n[4])  ,.enable(flt_enable)  ,.din(send_replay_b3_din                    )  ,.q(send_replay_b3_q                      ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_send_replay_b3_d0                    (.clk(dl_clk)  ,.reset_n(reset_latches_n[4])  ,.enable(flt_enable)  ,.din(send_replay_b3_d0_din                 )  ,.q(send_replay_b3_d0_q                   ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_send_replay_b3_d1                    (.clk(dl_clk)  ,.reset_n(reset_latches_n[4])  ,.enable(flt_enable)  ,.din(send_replay_b3_d1_din                 )  ,.q(send_replay_b3_d1_q                   ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_send_replay_b0_e0                    (.clk(dl_clk)  ,.reset_n(reset_latches_n[4])  ,.enable(flt_enable)  ,.din(send_replay_b0_e0_din                 )  ,.q(send_replay_b0_e0_q                   ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_send_idle_b3_e0                      (.clk(dl_clk)  ,.reset_n(reset_latches_n[4])  ,.enable(flt_enable)  ,.din(send_idle_b3_e0_din                   )  ,.q(send_idle_b3_e0_q                     ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_send_idle_b3                         (.clk(dl_clk)  ,.reset_n(reset_latches_n[4])  ,.enable(flt_enable)  ,.din(send_idle_b3_din                      )  ,.q(send_idle_b3_q                        ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_send_idle_b3_d0                      (.clk(dl_clk)  ,.reset_n(reset_latches_n[4])  ,.enable(flt_enable)  ,.din(send_idle_b3_d0_din                   )  ,.q(send_idle_b3_d0_q                     ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_send_idle_b3_d1                      (.clk(dl_clk)  ,.reset_n(reset_latches_n[4])  ,.enable(flt_enable)  ,.din(send_idle_b3_d1_din                   )  ,.q(send_idle_b3_d1_q                     ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_slowpath_continue                    (.clk(dl_clk)  ,.reset_n(reset_latches_n[4])  ,.enable(flt_enable)  ,.din(slowpath_continue_din                 )  ,.q(slowpath_continue_q                   ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_beat2                                (.clk(dl_clk)  ,.reset_n(reset_latches_n[4])  ,.enable(flt_enable)  ,.din(beat2_din                             )  ,.q(beat2_q                               ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_beat2_d0                             (.clk(dl_clk)  ,.reset_n(reset_latches_n[4])  ,.enable(flt_enable)  ,.din(beat2_d0_din                          )  ,.q(beat2_d0_q                            ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_ue_in_L                              (.clk(dl_clk)  ,.reset_n(reset_latches_n[4])  ,.enable(flt_enable)  ,.din(ue_in_L_din                           )  ,.q(ue_in_L_q                             ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_ue_in_R                              (.clk(dl_clk)  ,.reset_n(reset_latches_n[4])  ,.enable(flt_enable)  ,.din(ue_in_R_din                           )  ,.q(ue_in_R_q                             ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_sue_in_L                             (.clk(dl_clk)  ,.reset_n(reset_latches_n[4])  ,.enable(flt_enable)  ,.din(sue_in_L_din                          )  ,.q(sue_in_L_q                            ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_sue_in_R                             (.clk(dl_clk)  ,.reset_n(reset_latches_n[4])  ,.enable(flt_enable)  ,.din(sue_in_R_din                          )  ,.q(sue_in_R_q                            ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_tx_ack_ptr_no_update                 (.clk(dl_clk)  ,.reset_n(reset_latches_n[4])  ,.enable(flt_enable)  ,.din(tx_ack_ptr_no_update_din              )  ,.q(tx_ack_ptr_no_update_q                ));
dlc_ff #(.width(4)    ,.rstv(0)) reg_data_stalled_RL                      (.clk(dl_clk)  ,.reset_n(reset_latches_n[4])  ,.enable(flt_enable)  ,.din(data_stalled_RL_din                   )  ,.q(data_stalled_RL_q                     ));
dlc_ff #(.width(12)   ,.rstv(0)) reg_tx_ack_ptr_retrain                   (.clk(dl_clk)  ,.reset_n(reset_latches_n[4])  ,.enable(flt_enable)  ,.din(tx_ack_ptr_retrain_din                )  ,.q(tx_ack_ptr_retrain_q                  ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_retrain_occurred                     (.clk(dl_clk)  ,.reset_n(reset_latches_n[4])  ,.enable(flt_enable)  ,.din(retrain_occurred_din                  )  ,.q(retrain_occurred_q                    ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_data_stalled                         (.clk(dl_clk)  ,.reset_n(reset_latches_n[4])  ,.enable(flt_enable)  ,.din(data_stalled_din                      )  ,.q(data_stalled_q                        ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_data_stalled_replay                  (.clk(dl_clk)  ,.reset_n(reset_latches_n[4])  ,.enable(flt_enable)  ,.din(data_stalled_replay_din               )  ,.q(data_stalled_replay_q                 ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_data_from_fastpath_e0                (.clk(dl_clk)  ,.reset_n(reset_latches_n[4])  ,.enable(flt_enable)  ,.din(data_from_fastpath_e0_din             )  ,.q(data_from_fastpath_e0_q               ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_data_from_fastpath                   (.clk(dl_clk)  ,.reset_n(reset_latches_n[4])  ,.enable(flt_enable)  ,.din(data_from_fastpath_din                )  ,.q(data_from_fastpath_q                  ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_frbuf_replay_delay                   (.clk(dl_clk)  ,.reset_n(reset_latches_n[4])  ,.enable(flt_enable)  ,.din(frbuf_replay_delay_din                )  ,.q(frbuf_replay_delay_q                  ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_retrain_replay_done                  (.clk(dl_clk)  ,.reset_n(reset_latches_n[2])  ,.enable(flt_enable)  ,.din(retrain_replay_done_din               )  ,.q(retrain_replay_done_q                 ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_replay_done_b0                       (.clk(dl_clk)  ,.reset_n(reset_latches_n[2])  ,.enable(flt_enable)  ,.din(replay_done_b0_din                    )  ,.q(replay_done_b0_q                      ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_init_credits_sent                    (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(init_credits_sent_din                 )  ,.q(init_credits_sent_q                   ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_link_up                              (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(link_up_din                           )  ,.q(link_up_q                             ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_frbuf_replay_full                    (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(frbuf_replay_full_din                 )  ,.q(frbuf_replay_full_q                   ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_force_idle_after_rbf                 (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(force_idle_after_rbf_din              )  ,.q(force_idle_after_rbf_q                ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_frbuf_replay_full_reset              (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(frbuf_replay_full_reset_din           )  ,.q(frbuf_replay_full_reset_q             ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_force_idle_hold                      (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(force_idle_hold_din                   )  ,.q(force_idle_hold_q                     ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_force_idle_hold_d0                   (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(force_idle_hold_d0_din                )  ,.q(force_idle_hold_d0_q                  ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_force_idle_hold_pm_msg               (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(force_idle_hold_pm_msg_din            )  ,.q(force_idle_hold_pm_msg_q              ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_tsm4                                 (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(tsm4_din                              )  ,.q(tsm4_q                                ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_tsm4_d0                              (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(tsm4_d0_din                           )  ,.q(tsm4_d0_q                             ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_tsm4_d1                              (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(tsm4_d1_din                           )  ,.q(tsm4_d1_q                             ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_tsm4_d2                              (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(tsm4_d2_din                           )  ,.q(tsm4_d2_q                             ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_tsm4_d3                              (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(tsm4_d3_din                           )  ,.q(tsm4_d3_q                             ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_second_replay_pend                   (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(second_replay_pend_din                )  ,.q(second_replay_pend_q                  ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_second_error_after_reset             (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(second_error_after_reset_din          )  ,.q(second_error_after_reset_q            ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_rd_catching_wr                       (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(rd_catching_wr_din                    )  ,.q(rd_catching_wr_q                      ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_force_idle_now                       (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(force_idle_now_din                    )  ,.q(force_idle_now_q                      ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_force_idle_now_d0                    (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(force_idle_now_d0_din                 )  ,.q(force_idle_now_d0_q                   ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_short_flit_next_partial              (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(short_flit_next_partial_din           )  ,.q(short_flit_next_partial_q             ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_enable_short_idle                    (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(enable_short_idle_din                 )  ,.q(enable_short_idle_q                   ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_crc_data_from_frbuf                  (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(crc_data_from_frbuf_din               )  ,.q(crc_data_from_frbuf_q                 ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_send_idle_b012_e0                    (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(send_idle_b012_e0_din                 )  ,.q(send_idle_b012_e0_q                   ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_frbuf_xm1_vld                        (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(frbuf_xm1_vld_din                     )  ,.q(frbuf_xm1_vld_q                       ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_frbuf_xm1_vld_d0                     (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(frbuf_xm1_vld_d0_din                  )  ,.q(frbuf_xm1_vld_d0_q                    ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_frbuf_xm1_vld_d1                     (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(frbuf_xm1_vld_d1_din                  )  ,.q(frbuf_xm1_vld_d1_q                    ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_frbuf_xm2_vld_d1                     (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(frbuf_xm1_vld_d2_din                  )  ,.q(frbuf_xm1_vld_d2_q                    ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_frbuf_xm3_vld_d1                     (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(frbuf_xm1_vld_d3_din                  )  ,.q(frbuf_xm1_vld_d3_q                    ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_frbuf_xm4_vld_d1                     (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(frbuf_xm1_vld_d4_din                  )  ,.q(frbuf_xm1_vld_d4_q                    ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_send_idle                            (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(send_idle_din                         )  ,.q(send_idle_q                           ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_send_idle_d0                         (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(send_idle_d0_din                      )  ,.q(send_idle_d0_q                        ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_send_idle_b0_tmg                     (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(send_idle_b0_tmg_din                  )  ,.q(send_idle_b0_tmg_q                    ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_send_idle_b1_tmg                     (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(send_idle_b1_tmg_din                  )  ,.q(send_idle_b1_tmg_q                    ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_stomp_next_sp_syn                    (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(stomp_next_sp_syn_din                 )  ,.q(stomp_next_sp_syn_q                   ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_send_pm_msg                          (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(send_pm_msg_din                       )  ,.q(send_pm_msg_q                         ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_send_pm_msg_d0                       (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(send_pm_msg_d0_din                    )  ,.q(send_pm_msg_d0_q                      ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_send_pm_msg_d1                       (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(send_pm_msg_d1_din                    )  ,.q(send_pm_msg_d1_q                      ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_pm_sendable                          (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(pm_sendable_din                       )  ,.q(pm_sendable_q                         ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_data_stall_pm                        (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(data_stall_pm_din                     )  ,.q(data_stall_pm_q                       ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_go_narrow_next                       (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(go_narrow_next_din                    )  ,.q(go_narrow_next_q                      ));
//-- dlc_ff #(.width(1)    ,.rstv(0)) reg_pm_msg_sent_wait                     (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(pm_msg_sent_wait_din                  )  ,.q(pm_msg_sent_wait_q                    ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_pm_msg_e0_sent                       (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(pm_msg_sent_e0_din                    )  ,.q(pm_msg_sent_e0_q                      ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_pm_msg_sent                          (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(pm_msg_sent_din                       )  ,.q(pm_msg_sent_q                         ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_pm_msg_sent_d0                       (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(pm_msg_sent_d0_din                    )  ,.q(pm_msg_sent_d0_q                      ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_pm_msg_sent_d1                       (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(pm_msg_sent_d1_din                    )  ,.q(pm_msg_sent_d1_q                      ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_pm_msg_sent_stall                    (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(pm_msg_sent_stall_din                 )  ,.q(pm_msg_sent_stall_q                   ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_acks_sent                            (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(acks_sent_din                         )  ,.q(acks_sent_q                           ));
//-- dlc_ff #(.width(1)    ,.rstv(0)) reg_acks_sent_d0                         (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(acks_sent_d0_din                      )  ,.q(acks_sent_d0_q                        ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_lbip_vld                             (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(lbip_vld_din                          )  ,.q(lbip_vld_q                            ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_go_narrow_delay                      (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(go_narrow_delay_din                   )  ,.q(go_narrow_delay_q                     ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_go_narrow_delay_d0                   (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(go_narrow_delay_d0_din                )  ,.q(go_narrow_delay_d0_q                  ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_go_narrow_delay_d1                   (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(go_narrow_delay_d1_din                )  ,.q(go_narrow_delay_d1_q                  ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_go_narrow_delay_d2                   (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(go_narrow_delay_d2_din                )  ,.q(go_narrow_delay_d2_q                  ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_go_narrow_delay_d3                   (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(go_narrow_delay_d3_din                )  ,.q(go_narrow_delay_d3_q                  ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_ack_gt_write                         (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(ack_gt_write_din                      )  ,.q(ack_gt_write_q                        ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_ack_ptr_err                          (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(ack_ptr_err_din                       )  ,.q(ack_ptr_err_q                         ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_ack_ptr_wraps                        (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(ack_ptr_wraps_din                     )  ,.q(ack_ptr_wraps_q                       ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_rd_catching_wr_e0                    (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(rd_catching_wr_e0_din                 )  ,.q(rd_catching_wr_e0_q                   ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_truncate_has_occured                 (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(truncate_has_occured_din              )  ,.q(truncate_has_occured_q                ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_frbuf_rd_ptr_ovrflw                  (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(frbuf_rd_ptr_ovrflw_din               )  ,.q(frbuf_rd_ptr_ovrflw_q                 ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_tx_ack_pend_vld                      (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(tx_ack_pend_vld_din                   )  ,.q(tx_ack_pend_vld_q                     ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_send_ctl_b1                          (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(send_ctl_b1_din                       )  ,.q(send_ctl_b1_q                         ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_frbuf_rd_eq_wr                       (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(frbuf_rd_eq_wr_din                    )  ,.q(frbuf_rd_eq_wr_q                      ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_frbuf_rd_p1_eq_wr                    (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(frbuf_rd_p1_eq_wr_din                 )  ,.q(frbuf_rd_p1_eq_wr_q                   ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_frbuf_rd_eq_beats                    (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(frbuf_rd_eq_beats_din                 )  ,.q(frbuf_rd_eq_beats_q                   ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_frbuf_rd_eq_beats_72                 (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(frbuf_rd_eq_beats_72_din              )  ,.q(frbuf_rd_eq_beats_72_q                ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_frbuf_rd_m1_eq_beats                 (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(frbuf_rd_m1_eq_beats_din              )  ,.q(frbuf_rd_m1_eq_beats_q                ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_frbuf_rd_p1_eq_beats_72              (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(frbuf_rd_p1_eq_beats_72_din           )  ,.q(frbuf_rd_p1_eq_beats_72_q             ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_beat0_e0                             (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(beat0_e0_din                          )  ,.q(beat0_e0_q                            ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_beat1_e0                             (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(beat1_e0_din                          )  ,.q(beat1_e0_q                            ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_beat2_e0                             (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(beat2_e0_din                          )  ,.q(beat2_e0_q                            ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_beat3_e0                             (.clk(dl_clk)  ,.reset_n(reset_latches_n[3])  ,.enable(flt_enable)  ,.din(beat3_e0_din                          )  ,.q(beat3_e0_q                            ));

//--11/20  
dlc_ff #(.width(1)    ,.rstv(0)) reg_spare_00                             (.clk(dl_clk)  ,.reset_n(reset_latches_n[4])  ,.enable(flt_enable)  ,.din(spare_00_din                          )  ,.q(spare_00_q                            ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_spare_01                             (.clk(dl_clk)  ,.reset_n(reset_latches_n[4])  ,.enable(flt_enable)  ,.din(spare_01_din                          )  ,.q(spare_01_q                            ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_spare_02                             (.clk(dl_clk)  ,.reset_n(reset_latches_n[4])  ,.enable(flt_enable)  ,.din(spare_02_din                          )  ,.q(spare_02_q                            ));
dlc_ff #(.width(1)    ,.rstv(0)) reg_spare_03                             (.clk(dl_clk)  ,.reset_n(reset_latches_n[4])  ,.enable(flt_enable)  ,.din(spare_03_din                          )  ,.q(spare_03_q                            ));

dlc_ff_spare #(.width(1)    ,.rstv(0)) reg_spare_04                             (.clk(dl_clk)  ,.reset_n(reset_latches_n[4])  ,.enable(flt_enable)  ,.din(spare_04_din                          )  ,.q(spare_04_q                            ));
dlc_ff_spare #(.width(1)    ,.rstv(0)) reg_spare_05                             (.clk(dl_clk)  ,.reset_n(reset_latches_n[4])  ,.enable(flt_enable)  ,.din(spare_05_din                          )  ,.q(spare_05_q                            ));
dlc_ff_spare #(.width(1)    ,.rstv(0)) reg_spare_06                             (.clk(dl_clk)  ,.reset_n(reset_latches_n[4])  ,.enable(flt_enable)  ,.din(spare_06_din                          )  ,.q(spare_06_q                            ));
dlc_ff_spare #(.width(1)    ,.rstv(0)) reg_spare_07                             (.clk(dl_clk)  ,.reset_n(reset_latches_n[4])  ,.enable(flt_enable)  ,.din(spare_07_din                          )  ,.q(spare_07_q                            ));
dlc_ff_spare #(.width(1)    ,.rstv(0)) reg_spare_08                             (.clk(dl_clk)  ,.reset_n(reset_latches_n[4])  ,.enable(flt_enable)  ,.din(spare_08_din                          )  ,.q(spare_08_q                            ));
dlc_ff_spare #(.width(1)    ,.rstv(0)) reg_spare_09                             (.clk(dl_clk)  ,.reset_n(reset_latches_n[4])  ,.enable(flt_enable)  ,.din(spare_09_din                          )  ,.q(spare_09_q                            ));
dlc_ff_spare #(.width(1)    ,.rstv(0)) reg_spare_0A                             (.clk(dl_clk)  ,.reset_n(reset_latches_n[4])  ,.enable(flt_enable)  ,.din(spare_0A_din                          )  ,.q(spare_0A_q                            ));
dlc_ff_spare #(.width(1)    ,.rstv(0)) reg_spare_0B                             (.clk(dl_clk)  ,.reset_n(reset_latches_n[4])  ,.enable(flt_enable)  ,.din(spare_0B_din                          )  ,.q(spare_0B_q                            ));
dlc_ff_spare #(.width(1)    ,.rstv(0)) reg_spare_0C                             (.clk(dl_clk)  ,.reset_n(reset_latches_n[4])  ,.enable(flt_enable)  ,.din(spare_0C_din                          )  ,.q(spare_0C_q                            ));
dlc_ff_spare #(.width(1)    ,.rstv(0)) reg_spare_0D                             (.clk(dl_clk)  ,.reset_n(reset_latches_n[4])  ,.enable(flt_enable)  ,.din(spare_0D_din                          )  ,.q(spare_0D_q                            ));
dlc_ff_spare #(.width(1)    ,.rstv(0)) reg_spare_0E                             (.clk(dl_clk)  ,.reset_n(reset_latches_n[4])  ,.enable(flt_enable)  ,.din(spare_0E_din                          )  ,.q(spare_0E_q                            ));
dlc_ff_spare #(.width(1)    ,.rstv(0)) reg_spare_0F                             (.clk(dl_clk)  ,.reset_n(reset_latches_n[4])  ,.enable(flt_enable)  ,.din(spare_0F_din                          )  ,.q(spare_0F_q                            ));
dlc_ff_spare #(.width(1)    ,.rstv(0)) reg_spare_10                             (.clk(dl_clk)  ,.reset_n(reset_latches_n[4])  ,.enable(flt_enable)  ,.din(spare_10_din                          )  ,.q(spare_10_q                            ));
dlc_ff_spare #(.width(1)    ,.rstv(0)) reg_spare_11                             (.clk(dl_clk)  ,.reset_n(reset_latches_n[4])  ,.enable(flt_enable)  ,.din(spare_11_din                          )  ,.q(spare_11_q                            ));
dlc_ff_spare #(.width(1)    ,.rstv(0)) reg_spare_12                             (.clk(dl_clk)  ,.reset_n(reset_latches_n[4])  ,.enable(flt_enable)  ,.din(spare_12_din                          )  ,.q(spare_12_q                            ));
dlc_ff_spare #(.width(1)    ,.rstv(0)) reg_spare_13                             (.clk(dl_clk)  ,.reset_n(reset_latches_n[4])  ,.enable(flt_enable)  ,.din(spare_13_din                          )  ,.q(spare_13_q                            ));
dlc_ff_spare #(.width(1)    ,.rstv(0)) reg_spare_14                             (.clk(dl_clk)  ,.reset_n(reset_latches_n[4])  ,.enable(flt_enable)  ,.din(spare_14_din                          )  ,.q(spare_14_q                            ));
dlc_ff_spare #(.width(1)    ,.rstv(0)) reg_spare_15                             (.clk(dl_clk)  ,.reset_n(reset_latches_n[4])  ,.enable(flt_enable)  ,.din(spare_15_din                          )  ,.q(spare_15_q                            ));
dlc_ff_spare #(.width(1)    ,.rstv(0)) reg_spare_16                             (.clk(dl_clk)  ,.reset_n(reset_latches_n[4])  ,.enable(flt_enable)  ,.din(spare_16_din                          )  ,.q(spare_16_q                            ));
dlc_ff_spare #(.width(1)    ,.rstv(0)) reg_spare_17                             (.clk(dl_clk)  ,.reset_n(reset_latches_n[4])  ,.enable(flt_enable)  ,.din(spare_17_din                          )  ,.q(spare_17_q                            ));
dlc_ff_spare #(.width(1)    ,.rstv(0)) reg_spare_18                             (.clk(dl_clk)  ,.reset_n(reset_latches_n[4])  ,.enable(flt_enable)  ,.din(spare_18_din                          )  ,.q(spare_18_q                            ));
dlc_ff_spare #(.width(1)    ,.rstv(0)) reg_spare_19                             (.clk(dl_clk)  ,.reset_n(reset_latches_n[4])  ,.enable(flt_enable)  ,.din(spare_19_din                          )  ,.q(spare_19_q                            ));
dlc_ff_spare #(.width(1)    ,.rstv(0)) reg_spare_1A                             (.clk(dl_clk)  ,.reset_n(reset_latches_n[4])  ,.enable(flt_enable)  ,.din(spare_1A_din                          )  ,.q(spare_1A_q                            ));
dlc_ff_spare #(.width(1)    ,.rstv(0)) reg_spare_1B                             (.clk(dl_clk)  ,.reset_n(reset_latches_n[4])  ,.enable(flt_enable)  ,.din(spare_1B_din                          )  ,.q(spare_1B_q                            ));
dlc_ff_spare #(.width(1)    ,.rstv(0)) reg_spare_1C                             (.clk(dl_clk)  ,.reset_n(reset_latches_n[4])  ,.enable(flt_enable)  ,.din(spare_1C_din                          )  ,.q(spare_1C_q                            ));
dlc_ff_spare #(.width(1)    ,.rstv(0)) reg_spare_1D                             (.clk(dl_clk)  ,.reset_n(reset_latches_n[4])  ,.enable(flt_enable)  ,.din(spare_1D_din                          )  ,.q(spare_1D_q                            ));
dlc_ff_spare #(.width(1)    ,.rstv(0)) reg_spare_1E                             (.clk(dl_clk)  ,.reset_n(reset_latches_n[4])  ,.enable(flt_enable)  ,.din(spare_1E_din                          )  ,.q(spare_1E_q                            ));
dlc_ff_spare #(.width(1)    ,.rstv(0)) reg_spare_1F                             (.clk(dl_clk)  ,.reset_n(reset_latches_n[4])  ,.enable(flt_enable)  ,.din(spare_1F_din                          )  ,.q(spare_1F_q                            ));
dlc_ff_spare #(.width(1)    ,.rstv(0)) reg_spare_20                             (.clk(dl_clk)  ,.reset_n(reset_latches_n[4])  ,.enable(flt_enable)  ,.din(spare_20_din                          )  ,.q(spare_20_q                            ));
dlc_ff_spare #(.width(1)    ,.rstv(0)) reg_spare_21                             (.clk(dl_clk)  ,.reset_n(reset_latches_n[4])  ,.enable(flt_enable)  ,.din(spare_21_din                          )  ,.q(spare_21_q                            ));
dlc_ff_spare #(.width(1)    ,.rstv(0)) reg_spare_22                             (.clk(dl_clk)  ,.reset_n(reset_latches_n[4])  ,.enable(flt_enable)  ,.din(spare_22_din                          )  ,.q(spare_22_q                            ));
dlc_ff_spare #(.width(1)    ,.rstv(0)) reg_spare_23                             (.clk(dl_clk)  ,.reset_n(reset_latches_n[4])  ,.enable(flt_enable)  ,.din(spare_23_din                          )  ,.q(spare_23_q                            ));
dlc_ff_spare #(.width(1)    ,.rstv(0)) reg_spare_24                             (.clk(dl_clk)  ,.reset_n(reset_latches_n[4])  ,.enable(flt_enable)  ,.din(spare_24_din                          )  ,.q(spare_24_q                            ));
dlc_ff_spare #(.width(1)    ,.rstv(0)) reg_spare_25                             (.clk(dl_clk)  ,.reset_n(reset_latches_n[4])  ,.enable(flt_enable)  ,.din(spare_25_din                          )  ,.q(spare_25_q                            ));
dlc_ff_spare #(.width(1)    ,.rstv(0)) reg_spare_26                             (.clk(dl_clk)  ,.reset_n(reset_latches_n[4])  ,.enable(flt_enable)  ,.din(spare_26_din                          )  ,.q(spare_26_q                            ));
dlc_ff_spare #(.width(1)    ,.rstv(0)) reg_spare_27                             (.clk(dl_clk)  ,.reset_n(reset_latches_n[4])  ,.enable(flt_enable)  ,.din(spare_27_din                          )  ,.q(spare_27_q                            ));
dlc_ff_spare #(.width(1)    ,.rstv(0)) reg_spare_28                             (.clk(dl_clk)  ,.reset_n(reset_latches_n[4])  ,.enable(flt_enable)  ,.din(spare_28_din                          )  ,.q(spare_28_q                            ));
dlc_ff_spare #(.width(1)    ,.rstv(0)) reg_spare_29                             (.clk(dl_clk)  ,.reset_n(reset_latches_n[4])  ,.enable(flt_enable)  ,.din(spare_29_din                          )  ,.q(spare_29_q                            ));
dlc_ff_spare #(.width(1)    ,.rstv(0)) reg_spare_2A                             (.clk(dl_clk)  ,.reset_n(reset_latches_n[4])  ,.enable(flt_enable)  ,.din(spare_2A_din                          )  ,.q(spare_2A_q                            ));
dlc_ff_spare #(.width(1)    ,.rstv(0)) reg_spare_2B                             (.clk(dl_clk)  ,.reset_n(reset_latches_n[4])  ,.enable(flt_enable)  ,.din(spare_2B_din                          )  ,.q(spare_2B_q                            ));
dlc_ff_spare #(.width(1)    ,.rstv(0)) reg_spare_2C                             (.clk(dl_clk)  ,.reset_n(reset_latches_n[4])  ,.enable(flt_enable)  ,.din(spare_2C_din                          )  ,.q(spare_2C_q                            ));
dlc_ff_spare #(.width(1)    ,.rstv(0)) reg_spare_2D                             (.clk(dl_clk)  ,.reset_n(reset_latches_n[4])  ,.enable(flt_enable)  ,.din(spare_2D_din                          )  ,.q(spare_2D_q                            ));
dlc_ff_spare #(.width(1)    ,.rstv(0)) reg_spare_2E                             (.clk(dl_clk)  ,.reset_n(reset_latches_n[4])  ,.enable(flt_enable)  ,.din(spare_2E_din                          )  ,.q(spare_2E_q                            ));
dlc_ff_spare #(.width(1)    ,.rstv(0)) reg_spare_2F                             (.clk(dl_clk)  ,.reset_n(reset_latches_n[4])  ,.enable(flt_enable)  ,.din(spare_2F_din                          )  ,.q(spare_2F_q                            ));
dlc_ff_spare #(.width(1)    ,.rstv(0)) reg_spare_30                             (.clk(dl_clk)  ,.reset_n(reset_latches_n[4])  ,.enable(flt_enable)  ,.din(spare_30_din                          )  ,.q(spare_30_q                            ));
dlc_ff_spare #(.width(1)    ,.rstv(0)) reg_spare_31                             (.clk(dl_clk)  ,.reset_n(reset_latches_n[4])  ,.enable(flt_enable)  ,.din(spare_31_din                          )  ,.q(spare_31_q                            ));
dlc_ff_spare #(.width(1)    ,.rstv(0)) reg_spare_32                             (.clk(dl_clk)  ,.reset_n(reset_latches_n[4])  ,.enable(flt_enable)  ,.din(spare_32_din                          )  ,.q(spare_32_q                            ));
dlc_ff_spare #(.width(1)    ,.rstv(0)) reg_spare_33                             (.clk(dl_clk)  ,.reset_n(reset_latches_n[4])  ,.enable(flt_enable)  ,.din(spare_33_din                          )  ,.q(spare_33_q                            ));
dlc_ff_spare #(.width(1)    ,.rstv(0)) reg_spare_34                             (.clk(dl_clk)  ,.reset_n(reset_latches_n[4])  ,.enable(flt_enable)  ,.din(spare_34_din                          )  ,.q(spare_34_q                            ));
dlc_ff_spare #(.width(1)    ,.rstv(0)) reg_spare_35                             (.clk(dl_clk)  ,.reset_n(reset_latches_n[4])  ,.enable(flt_enable)  ,.din(spare_35_din                          )  ,.q(spare_35_q                            ));
dlc_ff_spare #(.width(1)    ,.rstv(0)) reg_spare_36                             (.clk(dl_clk)  ,.reset_n(reset_latches_n[4])  ,.enable(flt_enable)  ,.din(spare_36_din                          )  ,.q(spare_36_q                            ));
dlc_ff_spare #(.width(1)    ,.rstv(0)) reg_spare_37                             (.clk(dl_clk)  ,.reset_n(reset_latches_n[4])  ,.enable(flt_enable)  ,.din(spare_37_din                          )  ,.q(spare_37_q                            ));
dlc_ff_spare #(.width(1)    ,.rstv(0)) reg_spare_38                             (.clk(dl_clk)  ,.reset_n(reset_latches_n[4])  ,.enable(flt_enable)  ,.din(spare_38_din                          )  ,.q(spare_38_q                            ));
dlc_ff_spare #(.width(1)    ,.rstv(0)) reg_spare_39                             (.clk(dl_clk)  ,.reset_n(reset_latches_n[4])  ,.enable(flt_enable)  ,.din(spare_39_din                          )  ,.q(spare_39_q                            ));
dlc_ff_spare #(.width(1)    ,.rstv(0)) reg_spare_3A                             (.clk(dl_clk)  ,.reset_n(reset_latches_n[4])  ,.enable(flt_enable)  ,.din(spare_3A_din                          )  ,.q(spare_3A_q                            ));
dlc_ff_spare #(.width(1)    ,.rstv(0)) reg_spare_3B                             (.clk(dl_clk)  ,.reset_n(reset_latches_n[4])  ,.enable(flt_enable)  ,.din(spare_3B_din                          )  ,.q(spare_3B_q                            ));
dlc_ff_spare #(.width(1)    ,.rstv(0)) reg_spare_3C                             (.clk(dl_clk)  ,.reset_n(reset_latches_n[4])  ,.enable(flt_enable)  ,.din(spare_3C_din                          )  ,.q(spare_3C_q                            ));
dlc_ff_spare #(.width(1)    ,.rstv(0)) reg_spare_3D                             (.clk(dl_clk)  ,.reset_n(reset_latches_n[4])  ,.enable(flt_enable)  ,.din(spare_3D_din                          )  ,.q(spare_3D_q                            ));
dlc_ff_spare #(.width(1)    ,.rstv(0)) reg_spare_3E                             (.clk(dl_clk)  ,.reset_n(reset_latches_n[4])  ,.enable(flt_enable)  ,.din(spare_3E_din                          )  ,.q(spare_3E_q                            ));
dlc_ff_spare #(.width(1)    ,.rstv(0)) reg_spare_3F                             (.clk(dl_clk)  ,.reset_n(reset_latches_n[4])  ,.enable(flt_enable)  ,.din(spare_3F_din                          )  ,.q(spare_3F_q                            ));


//--11/20 assign spare_00_din = 1'b0;
//--11/20 assign spare_01_din = 1'b0;
//--11/20 assign spare_02_din = 1'b0;
//--11/20 assign spare_03_din = 1'b0;
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
assign spare_20_din = spare_1F_q;
assign spare_21_din = spare_20_q;
assign spare_22_din = spare_21_q;
assign spare_23_din = spare_22_q;
assign spare_24_din = spare_23_q;
assign spare_25_din = spare_24_q;
assign spare_26_din = spare_25_q;
assign spare_27_din = spare_26_q;
assign spare_28_din = spare_27_q;
assign spare_29_din = spare_28_q;
assign spare_2A_din = spare_29_q;
assign spare_2B_din = spare_2A_q;
assign spare_2C_din = spare_2B_q;
assign spare_2D_din = spare_2C_q;
assign spare_2E_din = spare_2D_q;
assign spare_2F_din = spare_2E_q;
assign spare_30_din = spare_2F_q;
assign spare_31_din = spare_30_q;
assign spare_32_din = spare_31_q;
assign spare_33_din = spare_32_q;
assign spare_34_din = spare_33_q;
assign spare_35_din = spare_34_q;
assign spare_36_din = spare_35_q;
assign spare_37_din = spare_36_q;
assign spare_38_din = spare_37_q;
assign spare_39_din = spare_38_q;
assign spare_3A_din = spare_39_q;
assign spare_3B_din = spare_3A_q;
assign spare_3C_din = spare_3B_q;
assign spare_3D_din = spare_3C_q;
assign spare_3E_din = spare_3D_q;
assign spare_3F_din = spare_3E_q;


//--******************************************************************************************************
//-- DATAFLOW
//--******************************************************************************************************
assign lbip_vld_din = tl2dl_flit_lbip_vld | lbip_vld_q;

//-- check incoming data for ECC errors
 dlc_ecc_chk TL_in_L(.data            (tl2dl_flit_data[127:64]),
                     .ecc             (tl2dl_flit_ecc[15:8]),
                     .dval            (tl2dl_flit_vld),
                     .ecc_cor_disable (1'b0),
                     .syn             (syn_in_L[7:0]),
                     .ce              (ce_in_L),
                     .sue             (sue_in_L_din),
                     .ue              (ue_in_L_din)
                     );
 
 dlc_ecc_chk TL_in_R(.data            (tl2dl_flit_data[63:0]),
                     .ecc             (tl2dl_flit_ecc[7:0]),
                     .dval            (tl2dl_flit_vld),
                     .ecc_cor_disable (1'b0),
                     .syn             (syn_in_R[7:0]),
                     .ce              (ce_in_R),
                     .sue             (sue_in_R_din),
                     .ue              (ue_in_R_din)
                     );

assign stomp_syn_fp_din[7:0] = any_fastpath_q & tl2dl_flit_vld ? stomp_syn_fp_q[7:0] | syn_in_R[7:0] | syn_in_L[7:0]:
                                                                 8'h00;        

assign stomp_syn_fp[7:0] = (stomp_syn_fp_q[7:0] | syn_in_R[7:0] | syn_in_L[7:0]) & {8{any_fastpath_q & tl2dl_flit_vld}};

assign flt_trn_ce_frb       = ce_in_L | ce_in_R;        //-- CE from TL 
assign flt_trn_ue_frb_df    = 1'b0;    //-- UE from TL
//--9/13 assign flt_trn_ue_frb_df    = ue_in_L_q | ue_in_R_q;    //-- UE from TL
assign flt_trn_ue_frb_cf    = sue_in_L_q | sue_in_R_q | ue_in_L_q | ue_in_R_q;  //-- SUE/UE from TL
//--9/13 assign flt_trn_ue_frb_cf    = sue_in_L_q | sue_in_L_q;  //-- SUE from TL

//--   **********************************************************************************************
//--wire [7:0]     syn_in_lbip_L;
//--wire [7:0]     syn_in_lbip_R;
//--wire           ce_in_lbip_L;
//--wire           ce_in_lbip_R;
//--wire           ue_in_lbip_L;
//--wire           ue_in_lbip_R;
//--wire           sue_in_lbip_L;
//--wire           sue_in_lbip_R;
//--
//-- dlc_ecc_chk TL_LBIP_in_L(.data               (tl2dl_flit_lbip_data[127:64]),
//--                               .ecc             (tl2dl_flit_lbip_ecc[15:8]),
//--                               .dval            (tl2dl_flit_lbip_vld),
//--                               .ecc_cor_disable (1'b0),
//--                               .syn             (syn_in_lbip_L[7:0]),
//--                               .ce              (ce_in_lbip_L),
//--                               .sue             (sue_in_lbip_L),
//--                               .ue              (ue_in_lbip_L)
//--                               );
//-- 
//-- dlc_ecc_chk TL_LBIP_in_R(.data               (tl2dl_flit_lbip_data[63:0]),
//--                               .ecc             (tl2dl_flit_lbip_ecc[7:0]),
//--                               .dval            (tl2dl_flit_lbip_vld),
//--                               .ecc_cor_disable (1'b0),
//--                               .syn             (syn_in_lbip_R[7:0]),
//--                               .ce              (ce_in_lbip_R),
//--                               .sue             (sue_in_lbip_R),
//--                               .ue              (ue_in_lbip_R)
//--                               );
//-- 

//-- Frame/Replay Buffer (frbuf) ******************************************************************************
//-- for IBM tech these are a 2x2 grid of AR8 128x72b -- includes ECC
//-- stick trn_flt_inj_ecc_ce in Sim to prove slowpath is always corrected
assign frbuf_wr_data[143:0] = trn_flt_inj_ecc_ce ? {tl2dl_flit_ecc[15:0],(tl2dl_flit_data[127:0] ^ 128'h00002000000000000000000000800000)}: // -- write data, includes ecc inject CE error on both double words
                              trn_flt_inj_ecc_ue ? {tl2dl_flit_ecc[15:0],(tl2dl_flit_data[127:0] ^ 128'h04002000000000000000000000C00000)}: // -- write data, includes ecc inject UE error on both double words
                                                   {tl2dl_flit_ecc[15:0],tl2dl_flit_data[127:0]}; // -- write data, includes ecc

//-- latch used to handle stall in fastpath (1 of 33 cycles) and used as a timing latch on the output of the frbuf
//-- this is only used because the frbuf will add 2 cycles when we may get by with only 1
//-- use frbuf_wr_en as a gate as it will always be on if good data is being received
assign data_from_fastpath_e0_din =  tl2dl_flit_early_vld_din & ((fastpath_q & stall_d3_din) | delayed_fastpath_din | double_delayed_fastpath_din | triple_delayed_fastpath_din |
                                    (quad_delayed_fastpath_din & (one_valid_stutter_din | one_valid_stutter_d0_din)) | (quad_delayed_fastpath_din & ~((stall_d2_din | stall_d3_din) & ~fastpath_end_d1_din)));

assign data_from_fastpath_din = data_from_fastpath_e0_q;

assign buffer_out_din[143:0] = data_from_fastpath_e0_q                     ? {tl2dl_flit_ecc[15:0],tl2dl_flit_data[127:0]}:
                               stall_d0_q & stall_d1_q                     ? buffer_out_q[143:0]:            
                                                                              frbuf_rd0_data[143:0];                                                

assign ctl_flit_in[81:0]     = data_from_fastpath_e0_q      ? tl2dl_flit_data[81:0]:
                                                              buffer_out_q[81:0];            

assign buffer_out_d0_din[127:0] = buffer_out_corrected[127:0];
assign buffer_out_d1_din[127:0] = buffer_out_d0_q[127:0];

assign buffer_out_d2_din[127:0] = stall_d3_q & quad_delayed_fastpath_q ? buffer_out_d2_q[127:0]:
                                                                          buffer_out_d1_q[127:0];

assign buffer_out_d3[127:0]     = buffer_out_d2_q[127:0];

dlc_ecc_chk frbuf_chk_port0_L(.data            (buffer_out_q[127:64]),
                              .ecc             (buffer_out_q[143:136]),
                              .dval            (1'b1),
                              .ecc_cor_disable (1'b0),
                              .syn             (syn0_L[7:0]),
                              .ce              (ce0_L),
                              .sue             (unused[3]),
                              .ue              (ue0_L)
                              );

dlc_ecc_cor frbuf_corport0_L(.data            (buffer_out_q[127:64]),
                             .syn             (syn0_L[7:0]),
                             .out_data        (buffer_out_corrected[127:64])
                             );

dlc_ecc_chk frbuf_chk_port0_R(.data            (buffer_out_q[63:0]),
                              .ecc             (buffer_out_q[135:128]),
                              .dval            (1'b1),
                              .ecc_cor_disable (1'b0),
                              .syn             (syn0_R[7:0]),
                              .ce              (ce0_R),
                              .sue             (unused[2]),
                              .ue              (ue0_R)
                              );

dlc_ecc_cor frbuf_corport0_R(.data            (buffer_out_q[63:0]),
                             .syn             (syn0_R[7:0]),
                             .out_data        (buffer_out_corrected[63:0])
                             );

//--2/13 : Creating Beat-2 latch-launch selects, for timing/fanout problems
assign beat2_e0               = (beat_din[1:0] == 2'b10);
assign send_ctl_b2_e0_din     = send_ctl_din & beat2_e0;
assign send_replay_b2_e0_din  = (replay_count_din[3:0] < 4'hA) & beat2_e0; 
assign send_idle_b2_e0_din    =  stall_d4_din ? send_idle_b2_din:
                                                send_idle_b1_din & (beat_din[1:0] == 2'b10);
//--2/27 timing fix... or beats 0,1 & 2 a cycle early
assign send_idle_b012_e0_din  =  stall_d4_din ? (send_idle_b0_din | send_idle_b1_din | send_idle_b2_din):
                                                (send_idle_b0_e0_din |
                                                 (send_idle_b0_din & (beat_din[1:0] == 2'b01)) |
                                                 (send_idle_b1_din & (beat_din[1:0] == 2'b10)));


//--: Restructure this muxing. Reduce fanout? No different prioritization, yet. Maybe work with CRC generation to do that, though. 
assign crc_data_in_part1_ctl[127:82] = ctl_flit[511:466];

assign crc_data_in_p1ctl_din[81:0]   = lbip_din[81:0]                                           & {82{delayed_fastpath_din        }} |
                                       lbip_d1_din[81:0]                                        & {82{double_delayed_fastpath_din  &   stall_d4_din & one_valid_stutter_din }} |
                                       lbip_d0_din[81:0]                                        & {82{double_delayed_fastpath_din  & ~(stall_d4_din & one_valid_stutter_din)}} |
                                       lbip_d2_din[81:0]                                        & {82{triple_delayed_fastpath_din  &   stall_d4_din & one_valid_stutter_d0_din}} |
                                       lbip_d1_din[81:0]                                        & {82{triple_delayed_fastpath_din  & ~(stall_d4_din & one_valid_stutter_d0_din)  }} |
                                       lbip_d2_din[81:0]                                        & {82{quad_delayed_fastpath_din    & ~one_valid_stutter_d1_din}} |
                                       lbip_d3[81:0]                                            & {82{quad_delayed_fastpath_din    &  one_valid_stutter_d1_din}};

assign crc_data_in_part1_ctl[81:0]  =  fastpath_q ? tl2dl_flit_lbip_data[81:0]:
                                                    crc_data_in_p1ctl_q[81:0];

assign crc_data_in_p1dat_din[127:0] =  buffer_out_din[127:0]                                    & {128{delayed_fastpath_din        }} |
                                       buffer_out_d0_din[127:0]                                 & {128{double_delayed_fastpath_din }} |
                                       buffer_out_d1_din[127:0]                                 & {128{triple_delayed_fastpath_din }} |
                                       buffer_out_d2_din[127:0]                                 & {128{quad_delayed_fastpath_din   }};

assign crc_data_in_part1[127:0]     = send_ctl_b2  ? crc_data_in_part1_ctl[127:0] :
                                                     crc_data_in_p1dat_q[127:0]; 

assign crc_data_in_part2[127:0] = ctl_flit[511:384]          & {128{send_ctl_b2_e0_q }} |
                                  dl2dl_replay_flit[127:0]   & {128{send_replay_b0}} | 
                                  dl2dl_replay_flit[255:128] & {128{send_replay_b1}} | 
                                  dl2dl_replay_flit[511:384] & {128{send_replay_b2_e0_q}} | 
                                  dl2dl_idle_flit[127:0]     & {128{send_idle_b0  }} | 
                                  dl2dl_idle_flit[255:128]   & {128{send_idle_b1  }} | 
                                  dl2dl_idle_flit[511:384]   & {128{send_idle_b2_e0_q  }};

assign crc_data_in_part12[127:0] =  any_fastpath_q                                     ? crc_data_in_part1[127:0]:
                                    send_dl2dl                                         ? crc_data_in_part2[127:0]:
                                    crc_data_from_frbuf_q                              ? buffer_out_d2_q[127:0]:  //--  needed to move this to prioritization logic. 
                                                                                         buffer_out_d1_q[127:0];

assign crc_data_in[127:0]                = //-- (fastpath_q & ~send_ctl_b2_e0_q & ~tl2dl_flit_early_vld) ? dl2dl_idle_flit[511:384]:
                                           (fastpath_q & ~send_ctl_b2_e0_q &  tl2dl_flit_early_vld_q) ? tl2dl_flit_data[127:0]  :
                                                                                                      crc_data_in_part12[127:0]; 

//--8/21 timing  assign crc_data_in[127:0]                = (fastpath_q & ~send_ctl_b2_e0_q & ~tl2dl_flit_early_vld) ? dl2dl_idle_flit[511:384]:
//--8/21                                            (fastpath_q & ~send_ctl_b2_e0_q &  tl2dl_flit_early_vld) ? tl2dl_flit_data[127:0]  :
//--8/21                                                                                                       crc_data_in_part12[127:0]; 

assign send_dl2dl = send_ctl_b2_e0_q | ((replay_count_q[3:0] < 4'hA) & ~(beat_q[1:0] == 2'b11)) | send_idle_b012_e0_q | replay_b2_d6_q; 

assign lbip_din[143:0]          =  any_fastpath_q ? {16'h0000, ctl_flit[511:466], tl2dl_flit_lbip_data[81:0]}:
                                                  frbuf_rd1_data[143:0];

assign lbip_d0_din[127:0]       = lbip_corrected[127:0];
assign lbip_d1_din[127:0]       = lbip_d0_q[127:0];
assign lbip_d2_din[127:0]       = lbip_d1_q[127:0];
assign lbip_d3[127:0]           = lbip_d2_q[127:0];

dlc_ecc_chk frbuf_chk_port1_L(.data            (lbip_q[127:64]),
                              .ecc             (lbip_q[143:136]),
                              .dval            (~any_fastpath_d0),
                              .ecc_cor_disable (any_fastpath_d0),
                              .syn             (syn1_L[7:0]),
                              .ce              (ce1_L),
                              .sue             (unused[1]),
                              .ue              (ue1_L)
                              );

dlc_ecc_cor frbuf_corport1_L(.data            (lbip_q[127:64]),
                             .syn             (syn1_L[7:0]),
                             .out_data        (lbip_corrected[127:64])
                             );

dlc_ecc_chk frbuf_chk_port1_R(.data            (lbip_q[63:0]),
                              .ecc             (lbip_q[135:128]),
                              .dval            (~any_fastpath_d0),
                              .ecc_cor_disable (any_fastpath_d0),
                              .syn             (syn1_R[7:0]),
                              .ce              (ce1_R),
                              .sue             (unused[0]),
                              .ue              (ue1_R)
                              );

dlc_ecc_cor frbuf_corport1_R(.data            (lbip_q[63:0]),
                             .syn             (syn1_R[7:0]),
                             .out_data        (lbip_corrected[63:0])
                             );

//--  gate cf with control signal, opposite for ce0 on _df
assign ue_rpb_cf_delay_din[0]     = (ue0_L | ue0_R | ue1_L | ue1_R) & ~data_from_fastpath_q;
assign ue_rpb_df0_delay_din[0]    = (ue0_L | ue0_R) & ~data_from_fastpath_q;
assign ue_rpb_df1_delay_din[0]    = (ue1_L | ue1_R) & ~data_from_fastpath_q;

assign flt_trn_ce_rpb             = ce0_L | ce0_R | ce1_L | ce1_R;

assign ue_rpb_cf_delay_din[1]     = ue_rpb_cf_delay_q[0];
assign ue_rpb_cf_delay_din[2]     = ue_rpb_cf_delay_q[1];
assign ue_rpb_cf_delay_din[3]     = ue_rpb_cf_delay_q[2];
assign ue_rpb_cf_delay_din[4]     = ue_rpb_cf_delay_q[3];
assign ue_rpb_cf_delay_din[5]     = ue_rpb_cf_delay_q[4];

assign flt_trn_ue_rpb_cf          = ue_rpb_cf_delay_q[3] & send_ctl_q;
//--9/28 assign flt_trn_ue_rpb_cf          = ue_rpb_cf_delay_din[5] & send_ctl_q;

assign ue_rpb_df0_delay_din[1]   = ue_rpb_df0_delay_q[0];
assign ue_rpb_df0_delay_din[2]   = ue_rpb_df0_delay_q[1];
assign ue_rpb_df0_delay_din[3]   = ue_rpb_df0_delay_q[2];
assign ue_rpb_df0_delay_din[4]   = ue_rpb_df0_delay_q[3];
assign ue_rpb_df0_delay_din[5]   = ue_rpb_df0_delay_q[4];

assign ue_rpb_df1_delay_din[1]   = ue_rpb_df1_delay_q[0];
assign ue_rpb_df1_delay_din[2]   = ue_rpb_df1_delay_q[1];
assign ue_rpb_df1_delay_din[3]   = ue_rpb_df1_delay_q[2];
assign ue_rpb_df1_delay_din[4]   = ue_rpb_df1_delay_q[3];
assign ue_rpb_df1_delay_din[5]   = ue_rpb_df1_delay_q[4];

assign flt_trn_ue_rpb_df          = (ue_rpb_df0_delay_din[5] & ~send_ctl_q) | ue_rpb_df1_delay_din[5];

//-- zero part of syndrome if error occured.
assign stomp_next_sp_syn_din = ((((ce_in_L | ce_in_R) & any_fastpath_q & tl2dl_flit_vld) | ue_rpb_df0_delay_q[0] | ue_rpb_df1_delay_q[0] | ue_rpb_cf_delay_q[0]) | stomp_next_sp_syn_q) & ~send_ctl_b2;
//--9/19 assign stomp_next_sp_syn_din = ((((ce_in_R | ce_in_R) & any_fastpath_q & tl2dl_flit_vld) | ue_rpb_df0_delay_q[0] | ue_rpb_df1_delay_q[0] | ue_rpb_cf_delay_q[0]) | stomp_next_sp_syn_q) & ~send_ctl_b2;
assign stomp_now             = (ue_rpb_df0_delay_din[0] | ue_rpb_df1_delay_din[0] | ue_rpb_cf_delay_din[0] | ue_rpb_cf_delay_q[0]) & (send_ctl_b1 | (stall_d3_q & send_ctl_b1_q));
//--9/28  assign stomp_now             = (ue_rpb_df0_delay_din[0] | ue_rpb_df1_delay_din[0] | ue_rpb_cf_delay_din[0] | ue_rpb_cf_delay_q[0]) & send_ctl_b1;
//--9/6  assign stomp_now             = (ue_rpb_df0_delay_din[0] | ue_rpb_df1_delay_din[0] | ue_rpb_cf_delay_din[0]) & send_ctl_b1;

assign crc_shift_data_fp_din[127:0] =
                                      (delayed_fastpath_din & ~(stall_d3_q & ~fastpath_d0_din))                        | 
                                      (fastpath_d0_din & ~delayed_fastpath_din & stall_d3_q)                           ? buffer_out_din[127:0]:              //-- last flit ends on this cycle

                                      (double_delayed_fastpath_din & ~(stall_d3_q & ~delayed_fastpath_d0_din))         | 
                                      (delayed_fastpath_d0_din & ~double_delayed_fastpath_din & stall_d3_q)            ? buffer_out_d0_din[127:0]:              //-- last flit ends on this cycle

                                      (triple_delayed_fastpath_din & ~(stall_d3_q & ~double_delayed_fastpath_d0_din))  |
                                      (quad_delayed_fastpath_q & stall_d4_q & one_valid_stutter_d0_q)                  |
                                      (double_delayed_fastpath_d0_din & ~triple_delayed_fastpath_din & stall_d3_q)     ? buffer_out_d1_din[127:0]:

                                      (quad_delayed_fastpath_din   &  ~(stall_d3_q & ~triple_delayed_fastpath_d0_din) & ~one_valid_stutter_d0_q) |
                                      (triple_delayed_fastpath_d0_din & ~quad_delayed_fastpath_din & stall_d3_q)       ? buffer_out_d2_din[127:0]:       

                                      quad_delayed_fastpath_din & stall_d5_din & one_valid_stutter_d1_din              |
                                      (quad_delayed_fastpath_d0_din & ~triple_delayed_fastpath_din & stall_d3_q)       ? buffer_out_d3[127:0]:

                                       stall_d3_q                                                                      ? buffer_out_d2_din[127:0]:          //-- slowpath 2nd beat

                                                                                                                         buffer_out_d1_din[127:0];     


assign crc_shift_data_in[127:0] =
                                  ~(send_ctl_b2_e0_q | send_replay_b2_e0_q)                                  ? dl2dl_idle_flit[383:256]:       //--send_idle_b2  
                                  send_replay_b2_e0_q                                                        ? dl2dl_replay_flit[383:256]:
                                  fastpath_q                                                                 ? tl2dl_flit_data[127:0]:
                                                                                                               crc_shift_data_fp_q[127:0]; 

//-- CRC generation *****************************************************************************************************
//-- zero beats 0 & 2 (beat 3 of flit) for control, output of beat 1 feeds to crc_shift during beat 2 (beat 2 of data)

dlc_crc dlc_mod (.init (crc_zero_checkbits),       
                 .checkbits_in (crc_checkbits_q[35:0]),
                 .data (crc_data_in[127:0]),
                 .checkbits_out (crc_checkbits_out[35:0]),
                 .nonzero_check (unused[4]));

//-- take short_flit_next out of path before xors
dlc_crc dlc_idle (.init (1'b1),       
                 .checkbits_in (crc_checkbits_q[35:0]),
                 .data (dl2dl_idle_flit[511:384]),
                 .checkbits_out (crc_idle_checkbits_out[35:0]),
                 .nonzero_check (unused[5]));

//-- CRC (used on fastpath only) on 3rd beat of packet
dlc_crc_shift dlc_shift_mod (.init (1'b0),       
                             .checkbits_in (crc_checkbits_q[35:0]),
                             .data (crc_shift_data_in[127:0]),
                             .checkbits_out (crc_shift_checkbits_out[35:0]));

//-- for the first two beats, bad checkbits are fed into crc_shift, but we ignore the results
//--LIF 9/17 no assign crc_checkbits_din[35:0] = (stall_d3_q | stall_d4_q)  & (send_ctl | send_replay) ? crc_checkbits_q[35:0] ^ {28'h0000000, {8{stomp_next_sp_syn_q | stomp_now}}}:                 //-- need this during control packets
assign crc_checkbits_din[35:0] = stall_d3_q & beat2 & (send_ctl | send_replay) ? crc_checkbits_q[35:0] ^ {28'h0000000, {8{stomp_next_sp_syn_q | stomp_now}}}:                 //-- need this during control packets
                                 stall_d4_q &         (send_ctl | send_replay) ? crc_checkbits_q[35:0] ^ {28'h0000000, {8{stomp_next_sp_syn_q | stomp_now}}}:                 //-- need this during control packets
                                 stall_d3_q &        ~(send_ctl | send_replay) ? crc_checkbits_q[35:0] ^ {28'h0000000, {8{stomp_next_sp_syn_q | stomp_now}}}:                 //-- need this during data transfers
                                                                              {crc_checkbits_out[35:8], crc_checkbits_out[7:0] ^ (stomp_syn_fp[7:0] | {8{stomp_next_sp_syn_q | stomp_now}})} ;        //-- Cause bad CRC if incoming data has bad ECC and this is a fastpath

//-- Data Output *****************************************************************************************************
//-- data output  -- fastpath, from frbuf, data w/CRC, or DL2DL flit 
assign dl_content_din[127:0] = DL_wo_short_flit_next[127:0];

assign DL_wo_short_flit_next[127:0] = ~fastpath_q & stall_d3_q                                       ? dl_content_q[127:0]:
//--9/20 reject - beats 2&3 don't need coverage     (send_idle_b2 | send_ctl_b2 | send_replay_b2) & ~stall_d3_q     ? {(crc_checkbits_out[35:8] ^ crc_shift_checkbits_out[35:8]),(crc_checkbits_out[7:0] ^ crc_shift_checkbits_out[7:0] ^ stomp_syn_fp[7:0]) , crc_data_in[91:0]}:
                                     (send_idle_b2 | send_ctl_b2 | send_replay_b2) & ~stall_d3_q     ? {(crc_checkbits_out[35:0] ^ crc_shift_checkbits_out[35:0]), crc_data_in[91:0]}:
                                      short_flit_next                                                ? {(crc_idle_checkbits_out[35:0]), dl2dl_idle_flit[475:384]}:
//--9/25                                      send_dl2dl_flit_q                                              ? dl2dl_flit_to_send_q[127:0]:
                                      send_dl2dl_flit_q                                              ? {dl2dl_flit_to_send_q[127:96],32'h00000000,32'h00000000,32'h00000000}:
                                      send_idle_b0_e0                                                ? dl2dl_idle_flit[127:0]:
                                      any_fastpath_q                                                 ? DL_wo_short_flit_next_fp[127:0]:
                                      data_from_frbuf_next & ~replay_b2_d6_q & stall_d3_q            ? buffer_out_d1_q[127:0]:
                                      data_from_frbuf_next & ~replay_b2_d6_q                         ? buffer_out_d0_q[127:0]:
                                                                                                       crc_data_in[127:0];

assign DL_wo_short_flit_next_fp[127:0] = tl2dl_flit_data[127:0] & {128{fastpath_q                &  stall_d3_q                                                          }} |
                                         buffer_out_d0_q[127:0] & {128{fastpath_q                & ~stall_d3_q                                                          }} |

                                         tl2dl_flit_data[127:0] & {128{delayed_fastpath_q                                                                               }} | 

                                         buffer_out_q[127:0]    & {128{double_delayed_fastpath_q & ~fastpath_end_q                                                      }} |
                                         tl2dl_flit_data[127:0] & {128{double_delayed_fastpath_q &  fastpath_end_q & one_valid_stutter_q                                }} |

                                         buffer_out_d0_q[127:0] & {128{triple_delayed_fastpath_q & ~fastpath_end_d0_q                                                   }} |
                                         buffer_out_q[127:0]    & {128{triple_delayed_fastpath_q &  fastpath_end_d0_q &  one_valid_stutter_d0_q                         }} |
                                         buffer_out_q[127:0]    & {128{triple_delayed_fastpath_q &  fastpath_end_d0_q & ~one_valid_stutter_d0_q & two_valid_stutter_q   }} |

                                         buffer_out_d1_q[127:0] & {128{quad_delayed_fastpath_q   & ~fastpath_end_d0_q & ~fastpath_end_d1_q                              }} |
                                         buffer_out_d0_q[127:0] & {128{quad_delayed_fastpath_q                        &  fastpath_end_d1_q &  one_valid_stutter_d1_q    }} |

                                         buffer_out_d0_q[127:0] & {128{quad_delayed_fastpath_q   &  fastpath_end_d0_q &  one_valid_stutter_d0_q                         }} |
                                         buffer_out_d0_q[127:0] & {128{quad_delayed_fastpath_q                        &  fastpath_end_d1_q & ~one_valid_stutter_d1_q & two_valid_stutter_q   }};

assign dl_content_short_flit_next_din[127:0] = DL_wo_short_flit_next[127:0] ^ 128'h7ADF479D500400000000000000000000;        //-- xor on bit 82 + CRC

//-- the next are to make fastpath time
assign send_ctl_b3_fp_din     = send_ctl_b2 & fastpath_q;      //-- need other stuff for stalls, but want send_ctl_b3 & ~short_flit_next

assign flt_agn_data_int[127:64]   =
                               short_flit_next                           ? dl_content_short_flit_next_q[127:64]:           //-- beat 3 of control flit w/ next idle (dl_content_din xor 128'h7ADF479D500400000000000000000000)
                               send_ctl_b3_fp_q                          ? dl_content_q[127:64]:                           //-- beat 3 of control flit
                               fastpath_l_q & tl2dl_flit_early_vld_l_q   ? tl2dl_flit_data[127:64]:                        //-- all other beats of ctl and/or data
                                                                           dl_content_q[127:64];                           //-- all other paths
 
assign flt_agn_data_int[63:0]   =
                               short_flit_next                           ? dl_content_short_flit_next_q[63:0]:           //-- beat 3 of control flit w/ next idle (dl_content_din xor 128'h7ADF479D500400000000000000000000)
                               send_ctl_b3_fp_q                          ? dl_content_q[63:0]:                           //-- beat 3 of control flit
                               fastpath_r_q & tl2dl_flit_early_vld_r_q   ? tl2dl_flit_data[63:0]:                        //-- all other beats of ctl and/or data
                                                                           dl_content_q[63:0];                           //-- all other paths

assign flt_agn_data[127:0] = flt_agn_data_int[127:0];

//--7/17 timing? assign flt_agn_data[127:0]   =
//--7/17 timing?                                short_flit_next                           ? dl_content_short_flit_next_q[127:0]:           //-- beat 3 of control flit w/ next idle (dl_content_din xor 128'h7ADF479D500400000000000000000000)
//--7/17 timing?                                send_ctl_b3_fp_q                          ? dl_content_q[127:0]:                           //-- beat 3 of control flit
//--7/17 timing?                                fastpath_q & tl2dl_flit_vld               ? tl2dl_flit_data[127:0]:                        //-- all other beats of ctl and/or data
//--7/17 timing?                                                                            dl_content_q[127:0];                           //-- all other paths
 
//--******************************************************************************************************
//-- BUILD FLITS in case they are needed
   //-- Create control flit if needed   (split because Synthesis sucks)
assign ctl_flit[511:466] =                                                                    {zeros[511:476],                       //--bits=511:476 crc 0's               --> 127:92 --> 63:28
                                                                                               rtn_acks[4:0],                        //--bits=475:471 ack cnt               -->  91:87 --> 27:23
                                                                                               recal_state_q[1:0],                   //--bits=470:469 reserved              -->  86:85 --> 22:21
                                                                                               zeros[468],                           //--bits=468 reserved                  -->  84    --> 20
                                                                                               (data_stalled_din | data_stalled_q),  //--bit =467                           -->  83    --> 19
                                                                                               zeros[466]};                          //--bit =466     short_flit_next       -->  82    --> 18            add this in on the way out  

assign ctl_flit[465:384] = any_fastpath_q ?                                                   ctl_flit_in[81:0]:

                            delayed_fastpath_d0_q & ~double_delayed_fastpath_q & stall_d4_q ? {buffer_out_q[81:64],           //--bits 465:383 Control flit from TL  -->  81:64 --> 17:0
                                                                                               buffer_out_q[63:0]}:           //--bits 465:383 Control flit from TL  -->  63:0
                                                                                     
                                                                                              {buffer_out_d0_q[81:64],        //--bits 465:383 Control flit from TL  -->  81:64 --> 17:0
                                                                                               buffer_out_d0_q[63:0]};        //--bits 465:383 Control flit from TL  -->  63:0  


    // --Create dl2dl replay  - 48 bytes reserved, last 16 bytes: beat_0 - 127:0, beat_1 - 255:128, beat_2 - 383:256, beat_3 - 511:384 
assign dl2dl_replay_flit[511:0] = {zeros[511:476],                //--bits=511:476 crc 0's               --> 127:92 --> 63:28
                                   rtn_acks[4:0],                 //--bits=475:471 ack cnt               -->  91:87 --> 27:23
                                   recal_state_q[1:0],            //--bits=470:469 reserved              -->  86:85 --> 22:21
                                   send_nack_q,                   //--bit =468     nack                  -->  84    --> 20
                                   data_stalled_q,                //--bit =467                           -->  83    --> 19
                                   zeros[466],                    //--bit =466     short_flit_next       -->  82    --> 18            add this in on the way out  
                                   zeros[465:464],                //--bits=465:464 reserved              -->  81:80 --> 17:16
                                   link_errors_q[7:0],            //--bits=463:456 link errors           -->  79:72 --> 15:8
                                   prev_cmd_run_length_q[3:0],    //--bits=455:452 previous run length   -->  71:68 -->  7:4
                                   4'hA,                          //--bits=451:448 "A" run length replay -->  67:64 -->  3:0
                                   pm_msg_din[3:0],               //--bits=447:444                       --> 63:60      NOTUSED FOR CHANGING WIDTH COMMANDS
                                   frbuf_replay_pointer_q[13:2],  //--bits=443:432 starting seq # - lower bits (where this side will restart from)*/               --> 59:48
                                   zeros[431:428],                //--bits=431:428 reserved                                                                        --> 47:44
                                   rx_ack_ptr_q[13:2],            //--bits=431:416 ack seq # - lower bits (where we are requesting the other side to start from)*/ --> 43:32
//--  for debug                                   zeros[415:272], 16'h3333, zeros[255:144], 16'h2222, zeros[127:16], 16'h1111};
                                   link_info_q[63:32],             //--bits=415:384 Link error info - upper bits                                          --> 31:0 
//-- beats 2,1,0
                                   link_info_q[31:0],              //--bits=383:352 Link error info - lower bits                                          --> 31:0 
                                   zeros[351:0]};

    // --Create dl2dl idle  - 56 bytes reserved, last 8 bytes
assign dl2dl_idle_flit[511:0] =   {zeros[511:476],                //--bits=511:476 crc 0's               --> 127:92 --> 63:28
                                   rtn_acks[4:0],                 //--bits=475:471 ack cnt               -->  91:87 --> 27:23
                                   recal_state_q[1:0],            //--bits=470:469 reserved              -->  86:85 --> 22:21
                                   zeros[468],                    //--bits=468 reserved                  -->  84    --> 20
                                   data_stalled_q,                //--bit =467                           -->  83    --> 19
                                   zeros[466],                    //--bit =466     short_flit_next       -->  82    --> 18            add this in on the way out  
                                   zeros[465:460],                //--bits=465:462 reserved              -->  81:78 --> 17:14
                                   pm_msg_din[3:0],               //--bits=447:444                       -->  75:72 
                                   gated_stalled_RL[3:0],         //--bits=455:452 Stalled Run Length    -->  71:68 -->  7:4
                                   4'hF,                          //--bits=451:448 "F" run length idle   -->  67:64 -->  3:0
//-- beats 2,1,0
//-- used for  for debug                                   zeros[447:416], zeros[415:272], 16'h3033, zeros[255:144], 16'h2022, zeros[127:16], 16'h1011};
                                   zeros[447:0]};


//-- for timing purposes, pre select which control flit to use
//-- save dl2dl_flit_to_send_din[95:0] latches
assign dl2dl_flit_to_send_din[127:96] =   (send_idle_b1_e0 & x8_tx_mode_q)        |
                                          (send_idle_b1 & x4_tx_mode_q)           |
                                          (send_idle_b1 & x2_tx_mode_q)          ? 32'h00000000:
                                                                                   link_info_q[31:0];
//--9/25 assign dl2dl_flit_to_send_din[127:0] =    (send_idle_b1_e0 & x8_tx_mode_q)         |
//--                                          (send_idle_b1 & x4_tx_mode_q)            |
//--                                          (send_idle_b1 & x2_tx_mode_q)          ? dl2dl_idle_flit[383:256]:
//--                                          send_replay_b1_e0 & train_done_d0_q    ? dl2dl_replay_flit[383:256]:
//--                                          send_replay_b0_e1                      ? dl2dl_replay_flit[127:0]:     
//--                                          send_replay_b0_e0 & train_done_q       ? dl2dl_replay_flit[255:128]:   
//--                                                                                   dl2dl_idle_flit[255:128];


//--******************************************************************************************************
//--******************************************************************************************************   
//-- Control flow
assign reset_latches_n[4:0] = global_reset_control ? reset_n_q[4:0] :
                                                     {5{~chip_reset}};

assign reset_n_din[4:0]     = {5{dlc_reset_n}};
assign x8_tx_mode_din       = trn_flt_x8_tx_mode;
assign x8_tx_mode_d0_din    = x8_tx_mode_q;
assign x4_tx_mode_din       = trn_flt_x4_tx_mode;
assign x2_tx_mode_din       = trn_flt_x2_tx_mode;
assign recal_state_din[1:0] = trn_flt_recal_state[1:0];

assign pm_msg_din[3:0]      =  pm_msg_sent_e0_din & ~(~enable_short_idle_q & frbuf_rd_vld_q) | (go_narrow_cnt_q == 4'h5) | ~(send_pm_msg_din | pm_msg_sent_q | go_narrow_delay) ? trn_flt_pm_msg[3:0]:
                                                                                                                                                                                  pm_msg_q[3:0];

assign enable_short_idle_din = enable_short_idle;

//-- clock gate
assign flt_enable            = omi_enable;
assign tsm4_din              = trn_flt_tsm4;
assign tsm4_d0_din           = tsm4_q;
assign tsm4_d1_din           = tsm4_d0_q;
assign tsm4_d2_din           = tsm4_d1_q;
assign tsm4_d3_din           = tsm4_d2_q;

//-- track wihich of the 4 parts of the flit is sending out
assign beat_din[1:0] = ~reset_latches_n[0]                                                                        |
                       ((~short_flit_next      & short_flit_next_q)    & ~stall_d3_q)                             |
                       ((~short_flit_next_q    & short_flit_next_d0_q) & stall_d4_q & ~stall_d3_q)                |
                       ((~short_flit_next_d0_q & short_flit_next_d1_q) & stall_d4_q & stall_d5_q) & x4_tx_mode_q  |
                       ((~short_flit_next_d2_q & short_flit_next_d3_q) & stall_d6_q & stall_d7_q) & x2_tx_mode_q      ? 2'b00:
                       tsm4_d2_q                                                                                      ? 2'b00:
                       enable_short_idle_q & short_flit_next                                                          ? 2'b11:
                       (x8_tx_mode_q & go_narrow_cnt_q[3:0] == 4'h6) | (x2_tx_mode_q & go_narrow_cnt_q[3:0] == 4'h2)  ? 2'b00:
                       stall_d3_q | real_stall_d3                                                                     ? beat_q[1:0]:
                       train_done_d0_q                                                                                ? beat_q[1:0] + 2'b01:
                                                                                                                        beat_q[1:0];

//--8/24 timing
assign beat0_e0_din  = (beat_din[1:0] == 2'b00);
assign beat1_e0_din  = (beat_din[1:0] == 2'b01);
assign beat2_e0_din  = (beat_din[1:0] == 2'b10);
assign beat3_e0_din  = (beat_din[1:0] == 2'b11);

assign beat0 = beat0_e0_q;
assign beat1 = beat1_e0_q;
assign beat2 = beat2_e0_q;
assign beat3 = beat3_e0_q;

//--8/24 timing assign beat0 = (beat_q[1:0] == 2'b00);
//--8/24 timing assign beat1 = (beat_q[1:0] == 2'b01);
//--8/24 timing assign beat2 = (beat_q[1:0] == 2'b10);
assign beat2_din = beat2;
assign beat2_d0_din = (stall_d3_q & stall_d4_q) ? beat2_d0_q:
                                                  beat2_q;

//--8/24 timing assign beat3 = (beat_q[1:0] == 2'b11);

//-- stall due to 66/64 encodiing, in our case it it one stall after 32 active cycles in x8 mode, every other + 1/32 for x4 mode, 3/4 + 1/32 in x2 mode
assign stall_d0_din            = flt_stall;
assign stall_d1_din            = stall_d0_q;
assign stall_d2_din            = stall_d1_q;
assign stall_d3_din            = stall_d2_q;
assign stall_d4_din            = stall_d3_q;
assign stall_d5_din            = stall_d4_q;
assign stall_d6_din            = stall_d5_q;
assign stall_d7_din            = stall_d6_q;

assign real_stall_d3           = trn_flt_real_stall; 
assign real_stall_d4_din       = real_stall_d3; 

//-- fastpath signals *******************
//-- fastpath valid only if buffer is empty and we not dl2dl, also don't bother with fastpath if in degraded mode
//-- valid until first stall or other inturruption (replay, error, etc)
assign fp_frbuf_empty                  = frbuf_rd_eq_wr_q & ~frbuf_wr_en_int;
//--10/1 assign fp_frbuf_empty                  = (frbuf_wr_ptr_q[7:0] == frbuf_rd_ptr_q[7:0]) & ~frbuf_wr_en_int;
assign fp_frbuf_empty_din              = fp_frbuf_empty;
assign fp_frbuf_empty_d0_din           = fp_frbuf_empty_q;

assign fastpath_din                    = ((((fp_frbuf_empty_q & fastpath_start_for_fp_only & x8_tx_mode_q & (flit_type_q[1:0] == 2'b11)) | (fastpath_d0_q & fastpath_start_for_fp_only & one_valid_stutter_din) | (fastpath_d1_q & fastpath_start_for_fp_only & two_valid_stutter_din)) &
                                         ((beat3 & ~enable_short_idle_q) | enable_short_idle_q)) | fastpath_q | (delayed_fastpath_q & fastpath_start_for_fp_only)) &
                                          tl2dl_flit_early_vld & ~stall_d3_q & init_replay_done_q & ~replay_b2_d0_q & ~(force_idle_now & ~beat2) & ~force_idle_now_q & ~(force_idle_hold & rd_catching_wr);

assign fastpath_l_din     = fastpath_din;
assign fastpath_r_din     = fastpath_din;

assign fastpath_d0_din                 = fastpath_q;
assign fastpath_d1_din                 = fastpath_d0_q;

//-- valid after fastpath's first stall until second stall.  Needed to fill gap where we can't get through the array quick enough
//--  add  ~(tl2dl_flit_early_vld | ~tl2dl_flit_vld) if valid glitches off one cycle
assign delayed_fastpath_din           = ((fastpath_q & tl2dl_flit_vld & tl2dl_flit_early_vld & stall_d3_q) | delayed_fastpath_q | (double_delayed_fastpath_q & one_valid_stutter_q & ~stall_d4_q)) &  //-- turn on - forward | stay on | turn on - back
                                         (tl2dl_flit_early_vld | tl2dl_flit_vld) & ~(delayed_fastpath_q & fastpath_start) & ~(stall_d3_q & ~fastpath_q) & ~replay_b2_d0_q & ~force_idle_now_q;       //-- shut off, no data & ? & shut off (but gate so it can start), go to next delay & don't start

assign delayed_fastpath_d0_din        = delayed_fastpath_q;

//-- valid after fastpath's second stall until third stall.  Needed to fill gap where we can't get through the array quick enough
assign double_delayed_fastpath_din    = ((delayed_fastpath_q & tl2dl_flit_vld & stall_d3_q) | double_delayed_fastpath_q | (triple_delayed_fastpath_q & one_valid_stutter_d0_q & ~stall_d4_q)) & //-- start from delayed or triple_delayed
                                          (tl2dl_flit_vld_q | ((one_valid_stutter_q | one_valid_stutter_din) & (stall_d3_q | stall_d4_q))) &                                                    //-- end, stutter/stall at same time | don't shut off if stutter & stall
                                         ~(triple_delayed_fastpath_q & fastpath_start) &                                                                                                        //-- ??  
                                         ~(stall_d3_q & ~delayed_fastpath_q & ~(one_valid_stutter_q | one_valid_stutter_din)) & ~replay_b2_d0_q & ~force_idle_now_q;                                                                            //-- end, but stay on if a stutter & a stall

assign double_delayed_fastpath_d0_din = double_delayed_fastpath_q;
assign double_delayed_fastpath_d1_din = double_delayed_fastpath_d0_q;

//-- valid after fastpath's third stall until fourth stall.  Needed to fill gap where we can't get through the array quick enough
assign triple_delayed_fastpath_din    = ((double_delayed_fastpath_q & tl2dl_flit_vld & tl2dl_flit_early_vld & stall_d3_q & ~one_valid_stutter_q) | triple_delayed_fastpath_q | (quad_delayed_fastpath_q & one_valid_stutter_d1_q & ~(stall_d3_q | stall_d4_q | stall_d5_q))) &            //-- turn on - forward | stay on | turn on - back
                                          (tl2dl_flit_vld_d0_q | (one_valid_stutter_d0_q & (stall_d3_q | stall_d4_q))) &                                                                     //-- end | stutter/stall at same time
                                         ~(quad_delayed_fastpath_q & ((stall_d3_q | stall_d4_q) & (one_valid_stutter_q | one_valid_stutter_d0_q | one_valid_stutter_d1_q))) &
                                         ~(quad_delayed_fastpath_q & fastpath_start) & ~(stall_d3_q & ~double_delayed_fastpath_q & ~(one_valid_stutter_q | one_valid_stutter_d0_q)) & ~replay_b2_d0_q & ~force_idle_now_q;   //-- ?? | stutter and stall, keep on

assign triple_delayed_fastpath_d0_din = triple_delayed_fastpath_q;

//-- valid after fastpath's fourth stall until fifth stall.  Needed to fill gap where we can't get through the array quick enough ... note if a one cycle stutter happens during a stall_d4_q, I can't know quick enough, so have to go idle
assign quad_delayed_fastpath_din    = ((triple_delayed_fastpath_q & tl2dl_flit_vld_d0_q & stall_d3_q &  ~(one_valid_stutter_q | one_valid_stutter_d0_q)) | quad_delayed_fastpath_q) &
                                       ~(fastpath_end_d1_q & ~((stall_d3_q | stall_d4_q | stall_d5_q) & (one_valid_stutter_q | one_valid_stutter_d0_q | one_valid_stutter_d1_q))) &
                                     ~(stall_d3_q & ~triple_delayed_fastpath_q & ~(one_valid_stutter_q | one_valid_stutter_d0_q | one_valid_stutter_d1_q)) & ~replay_b2_d0_q & ~force_idle_now_q;

assign quad_delayed_fastpath_d0_din    = quad_delayed_fastpath_q;
assign quad_delayed_fastpath_d1_din    = quad_delayed_fastpath_d0_q;
assign quad_delayed_fastpath_d2_din    = quad_delayed_fastpath_d1_q;
assign quad_delayed_fastpath_d3_din    = quad_delayed_fastpath_d2_q;
assign quad_delayed_fastpath_d4_din    = quad_delayed_fastpath_d3_q;

assign quad_stall_dly_din              = ((quad_delayed_fastpath_q & (slowpath_cnt_q[2:0] == 3'b101)) | quad_stall_dly_q) & ~(~tl2dl_flit_early_vld | stall_d0_q);


//--4/25  try for x4 fp, wrong assign fastpath_start                 = enable_fastpath & tl2dl_flit_early_vld & ~tl2dl_flit_early_vld_q & ~(replay_b2_q | replay_b2_d0_q | replay_b2_d1_q | replay_in_progress_q);
//--4/25  try for x4 fp, wrong assign fastpath_start_for_fp_only     = enable_fastpath &                        ~tl2dl_flit_early_vld_q & ~(replay_b2_q | replay_b2_d0_q | replay_b2_d1_q | replay_in_progress_q);
assign fastpath_start                 = enable_fastpath & tl2dl_flit_early_vld & ~tl2dl_flit_early_vld_q & ~stall_d4_q & ~(replay_b2_q | replay_b2_d0_q | replay_b2_d1_q | replay_in_progress_q);
assign fastpath_start_for_fp_only     = enable_fastpath &                        ~tl2dl_flit_early_vld_q & ~stall_d4_q & ~(replay_b2_q | replay_b2_d0_q | replay_b2_d1_q | replay_in_progress_q) & ~(pm_msg_sent_e0_q | pm_msg_sent_q | go_narrow_delay);

assign fastpath_start_din             = fastpath_start;
assign fastpath_start_d0_din          = fastpath_start_q;

//-- not really checking for fastpath, but it is used by the various fastpaths
assign fastpath_end                   = enable_fastpath & ((tl2dl_flit_vld_q & ~tl2dl_flit_early_vld_q) | force_idle_now_q);
assign fastpath_end_din               = fastpath_end;
assign fastpath_end_d0_din            = fastpath_end_q;
assign fastpath_end_d1_din            = fastpath_end_d0_q;
assign any_fastpath_din               = fastpath_din | delayed_fastpath_din | double_delayed_fastpath_din | triple_delayed_fastpath_din | quad_delayed_fastpath_din;
assign any_fastpath_d0                = fastpath_d0_q | delayed_fastpath_d0_q | double_delayed_fastpath_d0_q | triple_delayed_fastpath_d0_q | quad_delayed_fastpath_d0_q;
assign any_fastpath_d0_din            = any_fastpath_d0;
assign any_fastpath_d1_din            = any_fastpath_d0_q;
assign any_fastpath_d2_din            = any_fastpath_d1_q;
assign any_fastpath_d3_din            = any_fastpath_d2_q;
assign any_fastpath_d4_din            = any_fastpath_d3_q;


//-- flit type & valid ******************************************************************************************************************
// --flit_type [1:0] ==>  "01" = from frbuf;   "10" = replay cmd flit;   "11" = idle flit;    "00" = fastpath

assign flit_type[1:0] = stall_d4_q & (flit_type_q[1:0] == 2'b11)                                                                                                                ? flit_type_q[1:0]: 
                        (replay_count_q[3:0] < 4'hA)                                                                                                                            ? 2'b10:             //-- dl2dl replay flit -> 9 total
                         replay_in_progress_q                                                                                                                                   ? 2'b01:             //-- replay in progress, read from frbuf buffer
                        (short_flit_next_q & ~stall_d4_q) | send_idle_b0                                                                                                        ? 2'b11:
                         fastpath_q & ~fastpath_d0_q                                                                                                                            ? 2'b00:
                         (flit_type_q[1:0] == 2'b00) & (fastpath_q | (fastpath_d0_q & stall_d4_q) | delayed_fastpath_q | double_delayed_fastpath_q | triple_delayed_fastpath_q | quad_delayed_fastpath_q) ? 2'b00:
                         ~idle & (beat0 | quad_delayed_fastpath_d0_q) & ~go_narrow_delay                                                                                        ? 2'b01:   
                         ~(slowpath_cnt_q[2:0] == 3'b000) & (((flit_type_q[1:0] == 2'b01) & beat0) | (flit_type_q[1:0] == 2'b11)) & enable_short_idle_q                         ? 2'b11:
                         ~(slowpath_cnt_q[2:0] < 3'b011) & ~frbuf_rd_vld_d0_q & (((flit_type_q[1:0] == 2'b01) & beat0) | (flit_type_q[1:0] == 2'b11)) & ~enable_short_idle_q    ? 2'b11:
                         ~idle & ((beat0 & (read_from_array_valid_q | (flit_type_q == 2'b01))) | enable_short_idle_q) & ~(stall_d4_q & stall_d5_q)                              ? 2'b01:             //-- normal flits, read from frbuf buffer
                         (flit_type_q[1:0] == 2'b01) & ~beat0                                                                                                                   ? 2'b01:
                                                                                                                                                                                  2'b11;             //-- rtp full go to idle if possible

assign flit_type_din[1:0] = flit_type[1:0];

   // --Idle when things are empty, full, or max count (Cannot be idle if in the middle of a replay or in the middle of a frame)
   // --Full and send and idle when.  replay buffer is full and the next command is not a control flit (to send back acks)
   // --Does not necesarilly mean buffer read pointer have caught up for fastpath cases
   // --Idle will line up to one cycle before flt_agn_data is sending idle packets
assign idle_din  = ~reset_latches_n[0] | max_ack_cnt                                                                                               ? 1'b0: 
                   replay_b2_q | trn_flt_train_done                                                                                                ? 1'b0:
                   frbuf_empty_d0_q & ~((fastpath_din | any_fastpath_q) | (fastpath_q & stall_d3_q)) & ~replay_in_progress_q & init_replay_done_q  ? 1'b1:  //-- delay 2 for fetch from frbuf to get to flt_agn_data
                   fastpath_q                & ~tl2dl_flit_early_vld                                                                               ? 1'b1:  //-- delayed starts one cycle late, other is covered on idle signal
                   delayed_fastpath_q        & ~tl2dl_flit_early_vld & (cnt_after_early_vld_drops_din[3:0] == 4'h1)                                ? 1'b1:  //-- delayed ends w/o going to double delayed
                   double_delayed_fastpath_q & ~tl2dl_flit_early_vld & (cnt_after_early_vld_drops_q[3:0] == 4'h1)                                  ? 1'b1:  //-- .. double delayed
                   triple_delayed_fastpath_q & ~tl2dl_flit_early_vld & (cnt_after_early_vld_drops_q[3:0] == 4'h2)                                  ? 1'b1:  //-- ... triple_delayed
                   quad_delayed_fastpath_q   & ~tl2dl_flit_early_vld & (cnt_after_early_vld_drops_q[3:0] == 4'h3)                                  ? 1'b1:  //-- ... quad_delayed
                   enable_short_idle_q & frbuf_empty & beat2  & init_replay_done_q & ~any_fastpath_q                                               ? 1'b1:
                   (tl2dl_flit_early_vld & fastpath_start) | (~frbuf_empty_q & (beat2 | (slowpath_cnt_q[2:0] == 3'b011)))                          ? 1'b0:  //-- when it first gets busy
                                                                                                                                                     idle_q;

assign cnt_after_early_vld_drops_din[3:0] = tl2dl_flit_early_vld ? 4'h0:
                                            stall_d2_q           ? cnt_after_early_vld_drops_q[3:0]: 
                                                                   (cnt_after_early_vld_drops_q[3:0] + 4'h1);

assign pre_fastpath_idle_din = enable_short_idle_q & fastpath_din;
assign idle      = (idle_q & ~fastpath_din) | (pre_fastpath_idle_q & ~tl2dl_flit_early_vld);

assign send_replay_b0_e0 = send_replay_b0_e0_q | ((train_done_q & ~train_done_d0_q) | (~enable_short_idle_q & replay_b2_d0_q) | (~enable_short_idle_q & x4_tx_mode_q & replay_b2_d1_q) | (~enable_short_idle_q & x2_tx_mode_q & replay_b2_d4_q) |
                                                                                         ((send_replay & beat3 & ~stall_d3_q) & (replay_count_q[3:0] < 4'h9))  | ((send_replay & beat0 & stall_d3_q) & (replay_count_q[3:0] < 4'hA)));

assign send_replay_b0_e0_din = send_replay_b0_e0 & stall_d3_q;
assign send_replay_b0_e1 = (train_done_din & ~train_done_q) | (~enable_short_idle_q & replay_b2_q) | ((send_replay & (beat2 | (beat3 & stall_d3_q))) & (replay_count_q[3:0] < 4'h9)) | ((replay_count_q[3:0] == 4'h0) & (enable_short_idle_q & (pre_replay_idle_cnt_q[2:0] == 3'b001) & ~stall_d4_q));
assign send_replay       = (flit_type == 2'b10);

assign send_replay_b0     = (replay_count_q[3:0] < 4'hA) & beat0;
assign send_replay_b1     = (replay_count_q[3:0] < 4'hA) & beat1;
assign send_replay_b1_e0  = (send_replay_b0 & ~stall_d3_q) | (send_replay_b1 & stall_d3_q);
assign send_replay_b2     = (replay_count_q[3:0] < 4'hA) & beat2;
assign send_replay_b3     = (replay_count_q[3:0] < 4'hA) & beat3;
assign send_replay_b3_din = send_replay_b3;
assign send_replay_b3_d0_din = send_replay_b3_q;
assign send_replay_b3_d1_din = send_replay_b3_d0_q;

assign send_idle         = (flit_type == 2'b11);
assign send_idle_din     = send_idle;
assign send_idle_d0_din  = send_idle_q;

assign send_idle_b0_tmg_din      = stall_d3_q ? send_idle_b0_din:
                                                send_idle_b0_e0_din;

assign send_idle_b0      = send_idle_b0_tmg_q;

//--9/4 timing assign send_idle_b0      = stall_d4_q ? send_idle_b0_q:
//--9/4 timing                                         send_idle_b0_e0_q;

assign send_idle_b0_din  = send_idle_b0;

assign send_idle_b1_tmg_din      = stall_d3_q ? send_idle_b1_din:
                                                send_idle_b0_din & beat0;

assign send_idle_b1      = send_idle_b1_tmg_q;

//--9/4 timing assign send_idle_b1      = stall_d4_q ? send_idle_b1_q:
//--9/4 timing                                         send_idle_b0_q & beat1;
//--9/4 timing                                        send_idle_b0_q & (beat_q[1:0] == 2'b01);

assign send_idle_b1_e0   = send_idle_b0;
assign send_idle_b1_din  = send_idle_b1;

assign send_idle_b2      =  go_narrow_cnt_q[3:0] == 4'h4  ? 1'b0:
                            stall_d4_q                    ? send_idle_b2_q:
                                                            send_idle_b1_q & (beat_q[1:0] == 2'b10);

assign send_idle_b2_din  = send_idle_b2;

//--****** timing fix  
assign send_idle_b3_e0_din      = stall_d3_q                        ? send_idle_b3:
                                  (go_narrow_cnt_din[3:0] > 4'h1)   ? 1'b1:
                                                   (send_idle_b2_din | (send_idle_b3_din & (beat_din[1:0] == 2'b11)) | (short_flit_next_din & x8_tx_mode_q) | (short_flit_next_din & (beat_din[1:0] == 2'b11) & ~beat2_d0_din & x4_tx_mode_q) | (short_flit_next_d2_din & (beat_din[1:0] == 2'b11) & ~beat2_d0_din & x2_tx_mode_q)) & ((beat_din[1:0] == 2'b11) | enable_short_idle_q);

assign send_idle_b3          = send_idle_b3_e0_q;

//--8/8 assign send_idle_b3      = stall_d4_q      ? send_idle_b3_q:
//--8/8                            go_narrow_delay ? 1'b1:
//--8/8                                        (send_idle_b2_q | (send_idle_b3_q & beat3) | (short_flit_next_q & x8_tx_mode_q) | (short_flit_next_q & beat3 & ~beat2_d0_q & x4_tx_mode_q) | (short_flit_next_d2_q & beat3 & ~beat2_d0_q & x2_tx_mode_q)) & ((beat_q[1:0] == 2'b11) | enable_short_idle_q);
//--****** end timing fix

assign send_idle_b3_din    = send_idle_b3;
assign send_idle_b3_d0_din = send_idle_b3_q;
assign send_idle_b3_d1_din = send_idle_b3_d0_q;
assign send_idle_b0_e0     = ((send_idle_next & beat3 & ~stall_d3_q) | (go_narrow_cnt_q[3:0] == 4'h2)) & ~enable_short_idle_q;
assign send_idle_b0_e0_din = send_idle_b0_e0;

assign send_dl2dl_flit_din  = send_idle_b0_e0 | send_idle_b0_e0_q | send_idle_b1_e0 |   (send_idle_b1 & ~x8_tx_mode_q) | send_replay_b1_e0 | send_replay_b0_e1 | send_replay_b0_e0_q | (send_replay_b0_e0 & train_done_q) ;

assign crc_data_from_frbuf_din = data_from_frbuf_e0 & ~send_ctl_b2_e0_din & stall_d4_din; 
assign data_from_frbuf_e0      = (~any_fastpath_din & ~replay_in_progress_din & ~(replay_count_din[3:0] == 4'h9)) | (replay_in_progress_din & (replay_count_din[3:0] > 4'h9));

assign data_from_frbuf   = (~any_fastpath_q & ~replay_in_progress_q & ~(replay_count_q[3:0] == 4'h9)) | (replay_in_progress_q & (replay_count_q[3:0] > 4'h9));
assign data_from_frbuf_next  = ~any_fastpath_q | (replay_in_progress_din & (replay_count_din[3:0] < 4'h6));


assign flit_vld          = train_done_d0_q & ((flit_type[1:0] == 2'b00) | ((flit_type[1:0] == 2'b01) & ~replay_in_progress_q) | ((flit_type[1:0] == 2'b10) &
                                stall_d5_q & ((flit_type_q[1:0] == 2'b00) | (x8_tx_mode_q & (flit_type_q[1:0] == 2'b01))) & ~replay_in_progress_q)) & ~stall_d4_q & ~go_narrow_delay;

assign flit_vld_din      = flit_vld;

assign train_done_din    = (trn_flt_train_done | train_done_q) & ~tsm4_d0_q;

assign train_done_d0_din = train_done_q;
assign train_done_d1_din = train_done_d0_q;

//-- incoming control flit
//-- run_length_q counts flits, so only changes every four beat_q
assign send_ctl        = ((beat0 & (run_length_q[3:0] == 4'h0) & ~(send_replay | send_idle)) | send_ctl_q) & ~(beat3 & ~stall_d3_q);
assign send_ctl_din    = send_ctl & ~tsm4_d0_q;
assign send_ctl_b0     = beat0 & (run_length_q[3:0] == 4'h0) & ~(send_replay | send_idle);
assign send_ctl_b1     = send_ctl_q & beat1;
assign send_ctl_b1_din = send_ctl_b1;
assign send_ctl_b1_e0  = send_ctl_b0;
assign send_ctl_b2     = send_ctl_q & beat2;
assign send_ctl_b3     = send_ctl_q & beat3;
assign send_ctl_b3_din = send_ctl_b3;
assign send_ctl_b3_d0_din = send_ctl_b3_q;
assign send_ctl_b3_d1_din = send_ctl_b3_d0_q;

//-- zero after any control flit AND the first replay flit after training ALSO beat 2 of same
assign crc_zero_checkbits_stall_delay_din    =  ((stall_d2_q | stall_d3_q) & ((send_ctl_b3      | send_replay_b3      | send_idle_b3) | (train_done_q & ~train_done_d0_q))) |
                                                  (stall_d2_q & stall_d3_q  &  (send_ctl_b3_q    | send_replay_b3_q    | send_idle_b3_q)) |
                                                  (stall_d2_q & stall_d3_q  &  (send_ctl_b3_d1_q | send_replay_b3_d1_q | send_idle_b3_d1_q) & x2_tx_mode_q);
assign crc_zero_checkbits_next_din           = ~stall_d3_q &  (send_ctl_b3 | send_replay_b3 | send_idle_b3) | (train_done_q & ~train_done_d0_q) | crc_zero_checkbits_stall_delay_q;
assign crc_zero_checkbits_next_d0_din        = (crc_zero_checkbits_next_q & ~stall_d3_q) & (send_idle_b0 | send_ctl_b0 | send_replay_b0);
assign crc_zero_checkbits_next_d1_din        = crc_zero_checkbits_next_d0_q & ~(x4_tx_mode_q & real_stall_d3);
assign crc_zero_checkbits_next_d2_din        = crc_zero_checkbits_next_d1_q | (go_narrow_cnt_q[3:0] == 4'h1);  //-- gated by x4 mode later
assign crc_zero_checkbits                    = crc_zero_checkbits_next_q | ((x8_tx_mode_q & crc_zero_checkbits_next_d1_q) | (x4_tx_mode_q & crc_zero_checkbits_next_d2_q & ~real_stall_d3)) |
                                                                                         send_ctl_b2 | send_replay_b2 | send_idle_b2 | (~enable_short_idle_q & (go_narrow_cnt_q[3:0] == 4'h1));


//-- assign tl_error = send_ctl_b3 & ~(tl2dl_flit_data[451:448] == 4'b0000);
//-- load command length for use later in 9th replay flit

//-- run_length *****************************************************************************************************
assign run_length_din[3:0] = tsm4_q | ~reset_latches_n[0] | replay_b2_q                                  ? 4'h0:                     //-- If there's a reset, or a replay that hits in the middle
                             send_ctl_b2 & ~(stall_d2_q & stall_d3_q)                                    ? crc_data_in[67:64]:       // --Length of Control flit (beat3[67:64] = 451:448 of whole flit)
                             data_stall_finished_q | data_stall_finished_din                             ? data_stalled_RL_q[3:0]:        //-- comining out of a stall,  need to add one to because it will decrement the following cycle before the data is really sent
                             stall_d3_q | ~beat3                                                         ? run_length_q[3:0]:        //-- If stalled, grab previous data 
                             (send_replay_b3 & (replay_count_q[3:0] == 4'h9) & init_replay_done_q)       ? prev_cmd_run_length_q[3:0]: // --Replay Started
                             (run_length_q[3:0] > 4'h0) & send_ctl_q                                     ? run_length_q[3:0]:        //-- If stalled, grab previous data 
                             (run_length_q[3:0] > 4'h0)                                                  ? run_length_q[3:0] - 4'h1: //-- Sending Data Flits, decrement as each flit is sent
                             (send_replay_b0 & (replay_count_q[3:0] == 4'h7) && init_replay_done_q)
                                                                 & (prev_cmd_run_length_q[3:0] == 4'h0)  ? 4'h0:                     // --Replay after reset, before any acks were received
//--10/9                                              & (rx_rl_not_vld_q & (prev_cmd_run_length_q[3:0] == 4'h0))  ? 4'h0:                     // --Replay after reset, before any acks were received
                                                                                                           4'h0;                                 

//-- Misc Signals *****************************************************************************************************

//-- FRBuf control -- write
assign frbuf_wr_en_int        = tl2dl_flit_early_vld_q;   //-- should be the same as tl2dl_flit_vld, but should time better
assign frbuf_wr_en            = frbuf_wr_en_int;
assign frbuf_wr_addr[7:0]     = frbuf_wr_ptr_q[7:0];

assign frbuf_wr_ptr_din[7:0]  =  ~reset_latches_n[0] & init_credits_sent_q         ? 8'h00:                        // -- write address
                                 tl2dl_flit_vld        ? frbuf_wr_ptr_q[7:0] + 8'h01:  // -- increment to address to use for next store
                                                         frbuf_wr_ptr_q[7:0];

assign frbuf_rd0_select_pair0_d1  = frbuf_rd0_select_pair0_q;

assign tl2dl_flit_vld_din          = tl2dl_flit_vld;
assign tl2dl_flit_vld_d0_din       = tl2dl_flit_vld_q;
assign tl2dl_flit_early_vld_din    = tl2dl_flit_early_vld;
//--7/17 timing?
assign tl2dl_flit_early_vld_l_din    = tl2dl_flit_early_vld;
assign tl2dl_flit_early_vld_r_din    = tl2dl_flit_early_vld;
assign tl2dl_flit_early_vld_d1_din = tl2dl_flit_early_vld_q;

assign frbuf_rd0_select_pair1_d1  = 1'b0;

assign no_data_in_frbuf_din = (replay_count_q[3:0] == 4'h7) & beat2 & (frbuf_wr_ptr_q[7:0] == frbuf_replay_pointer_q[7:0]);

//-- xm1 = x-1, to get prev cmd length
assign frbuf_xm1_load       = ((((replay_count_q[3:0] == 4'h7) & beat2 & x8_tx_mode_q) | ((replay_count_q[3:0] == 4'h7) & beat3 & stall_d3_q & x8_tx_mode_q) | ((replay_count_q[3:0] == 4'h7) & beat3 & x4_tx_mode_q) | ((replay_count_q[3:0] == 4'h8) & beat3 & x2_tx_mode_q)) & (init_replay_done_q)) & ~slowpath_glitch_q;
assign frbuf_xm1_vld        = ((((replay_count_q[3:0] == 4'h7) & beat3 & x8_tx_mode_q & ~stall_d3_q) | ((replay_count_q[3:0] == 4'h8) & beat0 & x4_tx_mode_q) | ((replay_count_q[3:0] == 4'h9) & beat0 & x2_tx_mode_q)) &
                                                       (init_replay_done_q & ~second_error_after_reset_q & ~frbuf_rd_eq_wr_q)) & ~slowpath_glitch_q;
//--10/22 SI                                                       (init_replay_done_q & ~frbuf_rd_eq_wr_q)) & ~slowpath_glitch_q;
//--10/1                                                       (init_replay_done_q & ~(frbuf_wr_ptr_q[7:0] == frbuf_rd_ptr_q[7:0]))) & ~slowpath_glitch_q;

assign frbuf_xm1_vld_din    = (frbuf_xm1_vld & x8_tx_mode_q) | (frbuf_xm1_vld & ~x8_tx_mode_q & ~stall_d3_q);
assign frbuf_xm1_vld_d0_din =  frbuf_xm1_vld_q;
assign frbuf_xm1_vld_d1_din =  frbuf_xm1_vld_d0_q;
assign frbuf_xm1_vld_d2_din =  frbuf_xm1_vld_d1_q               | (frbuf_xm1_vld_d2_q & stall_d3_q & ~x8_tx_mode_q);
assign frbuf_xm1_vld_d3_din =  frbuf_xm1_vld_d2_q               | (frbuf_xm1_vld_d3_q & stall_d3_q);
assign frbuf_xm1_vld_d4_din = (frbuf_xm1_vld_d3_q & stall_d2_q) | (frbuf_xm1_vld_d4_q & stall_d3_q);

assign frbuf_xm1_not_vld = ((((replay_count_q[3:0] == 4'h8) & beat2 & x8_tx_mode_q) | ((replay_count_q[3:0] == 4'h9) & beat0 & x4_tx_mode_q)) & ~((init_replay_done_q & ~frbuf_rd_eq_wr_q)) & ~slowpath_glitch_q);
//--10/1 assign frbuf_xm1_not_vld = ((((replay_count_q[3:0] == 4'h8) & beat2 & x8_tx_mode_q) | ((replay_count_q[3:0] == 4'h9) & beat0 & x4_tx_mode_q)) & ~((init_replay_done_q & ~(frbuf_wr_ptr_q[7:0] == frbuf_rd_ptr_q[7:0]))) & ~slowpath_glitch_q);

//-- conditions to start a read in x2 mode, but not the correct time... hold to the correct time
assign frbuf_x2_continue_din =  ((init_replay_done_q & read_from_array_valid_din & ~frbuf_empty_q & ~enable_short_idle_q & ~replay_in_progress_q & ~go_narrow_delay & x2_tx_mode_q & ~real_stall_d3) | frbuf_x2_continue_q) & ~frbuf_rd_vld_q;    

//-- FRBuf control -- read
//--8/23 no assign frbuf_rd_vld_din = ~reset_latches_n[0] | ~train_done_q | tsm4_q | replay_b2_q | force_idle_now | (force_idle_hold & rd_catching_wr & ~replay_in_progress_q) | data_stalled_q                                     ? 1'b0:  //-- read enable    
assign frbuf_rd_vld_din = ~reset_latches_n[0] | ~train_done_q | tsm4_q | replay_b2_q | force_idle_now | (force_idle_hold & rd_catching_wr & ~replay_in_progress_q)                                                   ? 1'b0:  //-- read enable    
                          frbuf_xm1_vld_q | frbuf_xm1_vld_d0_q | frbuf_xm1_vld_d1_q                                                                                                                                    ? 1'b1:  //-- read x-1 location for prev cmd length
                          init_replay_done_q & (fastpath_q | (double_delayed_fastpath_q & fastpath_start & ~send_idle_next & ~two_valid_stutter_din))                                                                  ? 1'b1:
                          (slowpath_cnt_q[2:0] == 3'b111)                                                                                                                                                                |
                          ((frbuf_rd_p1_eq_wr_q & ~tl2dl_flit_early_vld_q) | frbuf_empty) & ~(flt_stall & stall_d0_q) &
//--10/1                          ((((frbuf_rd_ptr_q[7:0] + 8'h01) == frbuf_wr_ptr_q[7:0]) & ~tl2dl_flit_early_vld_q) | frbuf_empty) & ~(flt_stall & stall_d0_q) &
                                                                                          ~(one_valid_stutter_din & (double_delayed_fastpath_d0_q | triple_delayed_fastpath_d0_q | quad_delayed_fastpath_d0_q))        ? 1'b0:
                          init_replay_done_q & (fastpath_q | (any_fastpath_q & fastpath_start))                                                                                                                        ? 1'b1:
                          init_replay_done_din & ~frbuf_empty_q & ~send_pm_msg_q & ~send_pm_msg_d0_q & ~pm_msg_sent_q & ~go_narrow_delay & ~stall_d1_q & ~stall_d2_q & beat3 & ~replay_in_progress_q & 
//--10/9                            init_replay_done_din & ~frbuf_empty_q & ~send_pm_msg_q & ~pm_msg_sent_q & ~go_narrow_delay & ~stall_d1_q & ~stall_d2_q & beat3 & ~replay_in_progress_q & 
                                                                                                  (pre_replay_idle_cnt_q[2:0] == 3'b000) & (slowpath_cnt_q[2:0] == 3'b000) & ~slowpath_glitch_q & enable_short_idle_q  ? 1'b1:
                          frbuf_x2_continue_q & beat2 & ~stall_d3_q                                                                                                                                                      |
                          init_replay_done_q & read_from_array_valid_din & ~enable_short_idle_q & ~replay_in_progress_q & ~pm_msg_sent_e0_q & ~pm_msg_sent_q & ~go_narrow_delay & 
                                         ((x8_tx_mode_q & beat3 & ~(stall_d3_q | stall_d4_q)) | (x4_tx_mode_q & beat1 & ~(stall_d2_q & stall_d3_q)) | (x2_tx_mode_q & beat2 & ~real_stall_d3))                         ? 1'b1: //-- Long Idle only
                          init_replay_done_q & ((slowpath_cnt_q[2:0] == 3'b110) & ~((flt_stall | stall_d0_q) & ~fastpath_q) & ~(stall_d1_q & slowpath_glitch_q) & enable_short_idle_q) & ~(stall_d4_q & stall_d5_q) & ~replay_in_progress_q        ? 1'b1:  
                          (init_replay_done_q & enable_short_idle_q & ~replay_in_progress_q & (slowpath_cnt_q[2:0] == 3'b101) & (stall_d0_q | stall_d1_q)) & ~frbuf_empty                                              ? 1'b1:
                          quad_delayed_fastpath_q & ~tl2dl_flit_early_vld_q                                                                                                                                            ? 1'b0:  //-- needed when switching to slow path
                          quad_delayed_fastpath_q & (stall_d2_q | stall_d3_q) & enable_short_idle_q                                                                                                                    ? 1'b1:  //-- switching from delayed_fp to buffer 
                                                                                                                                                                                                                         frbuf_rd_vld_q;

assign frbuf_rd_vld_d0_din = frbuf_rd_vld_q;
assign frbuf_rd_vld_d1_din = frbuf_rd_vld_d0_q;
assign frbuf_rd_vld_d2_din = frbuf_rd_vld_d1_q;
assign frbuf_rd_vld_d3_din = frbuf_rd_vld_d2_q;
assign frbuf_rd_vld_d4_din = frbuf_rd_vld_d3_q;

//-- as fastpath -> delayed_fastpath -> double_delayed_fastpath, The rd_ptr cannot skip with the stalls.  If it does and we go from double_delayed_fastpath back to buffer, the correct
//-- data is not being fetched out of the buffer in time.  This will make figuring out idle more difficult but can't be helped.

//-- align frbuf_rd_ptr to slowpath count after a replay
assign frbuf_replay_delay_din = replay_done_din & init_replay_late_done_q & (slowpath_cnt_q[2:0] == 3'b111)                     ? 1'b1:
                                ((slowpath_cnt_q[2:0] == 3'b101) | (slowpath_cnt_q[2:0] == 3'b000) | any_fastpath_q)            ? 1'b0:          
                                                                                                                                  frbuf_replay_delay_q;


assign frbuf_rd_ptr_din[7:0]    =  ~reset_latches_n[0]                                                                                                                ? 8'h00:                                  // -- read address
                                   tsm4_q                                                                                                                             ? beats_sent_q[7:0]:   // -- start sending replay where incoming replay command started
                                   x2_tx_mode_q & ~stall_d3_q & replay_in_progress_q & replay_done_q & force_idle_now                                                 ? (frbuf_rd_ptr_q[7:0] - 8'h01):
                                   (force_idle_now_d0_q | x4_rpf_rp_stalled)                                                                                          ? beats_sent_q[7:0]:        
//--8/10                                    (force_idle_now | x4_rpf_rp_stalled)                                                                                               ? beats_sent_q[7:0]:        
                                   (force_idle_now_q & ~send_idle_q & frbuf_rd_vld_q) | (force_idle_now_d0_q & ~send_idle_d0_q & ~frbuf_empty & frbuf_rd_vld_q & x8_tx_mode_q)                          ? (frbuf_rd_ptr_q[7:0] + 8'h01):        
                                   frbuf_xm1_load                                                                                                                     ? frbuf_replay_pointer_q[7:0]:   // -- start sending replay where incoming replay command started
                                   frbuf_xm1_vld_q & ~slowpath_glitch_q                                                                                               ? (frbuf_rd_ptr_q[7:0] - 8'h01):           // -- if didn't dec last cycle due to stalls
                                   (force_idle_hold & rd_catching_wr & ~replay_in_progress_q)                                                                          |
                                   (x4_tx_mode_q & (frbuf_xm1_vld_d3_q | frbuf_xm1_vld_d4_q))                                                                          |
                                   (frbuf_xm1_vld | frbuf_xm1_vld_d0_q | frbuf_xm1_vld_d1_q | (frbuf_xm1_vld_d2_q & (stall_d2_q | stall_d3_q | stall_d4_q | stall_d5_q | stall_d6_q)))   ? (frbuf_rd_ptr_q[7:0]):     // --wait after getting the previous run length 
                                   (~enable_short_idle_q & one_valid_stutter_d2_q & send_idle_next & quad_delayed_fastpath_d4_q)                                       |
                                   (frbuf_rd_eq_wr_q | no_data_in_frbuf_q  | slowpath_glitch_q | frbuf_replay_delay_din)                   |
//--10/1                                   ((frbuf_rd_ptr_q[7:0] == frbuf_wr_ptr_q[7:0]) | no_data_in_frbuf_q  | slowpath_glitch_q | frbuf_replay_delay_din)                   |
                                   (~enable_short_idle_q & ((one_valid_stutter_d0_q & quad_delayed_fastpath_d2_q & beat1) |
                                   (one_valid_stutter_d1_q & quad_delayed_fastpath_d3_q & beat2) | (one_valid_stutter_d2_q & quad_delayed_fastpath_d4_q & beat1)) & 
                                                                                                                    ~quad_delayed_fastpath_q   & ~stall_d3_q)          |
                                   (quad_delayed_fastpath_q & ((stall_d0_q & fastpath_end_d1_q & ~one_valid_stutter_d1_q) | (stall_d1_q & two_valid_stutter_d0_q)))   ? frbuf_rd_ptr_q[7:0]:                     // -- quad is ending on a two_stutter... slowpath will start
                                   (any_fastpath_q & frbuf_wr_en_int & ~(two_valid_stutter_d0_q & quad_delayed_fastpath_q))                                            |
                                   (quad_delayed_fastpath_q & stall_d2_q & ~frbuf_empty)                                                                               |                                         // -- switching from double_delayed_fp to buffer
                                   (any_fastpath_q & tl2dl_flit_vld &  tl2dl_flit_vld_q & ~(two_valid_stutter_d0_q & quad_delayed_fastpath_q))                        ? (frbuf_rd_ptr_q[7:0] + 8'h01):
                                   any_fastpath_q & tl2dl_flit_vld & ~tl2dl_flit_vld_q                                                                                ?   frbuf_rd_ptr_q[7:0]:
                                   (stall_d0_q & ~(stall_d1_q & ~frbuf_rd_vld_q))                                                                                      | 
                                   ((replay_count_q[3:0] == 4'h8) & beat2 & init_replay_late_done_q  & (stall_d1_q | stall_d2_q | stall_d3_q))                         |                                         // -- 
                                   ((replay_count_q[3:0] == 4'h9) & init_replay_late_done_q & (~stall_d3_q & ~stall_d1_q) & x4_tx_mode_q)                             ? (frbuf_rd_ptr_q[7:0]):                   // -- only increment every other cycle in x4
                                   (replay_count_q[3:0] == 4'h9) & init_replay_late_done_q & x4_tx_mode_q & ~(stall_d0_q & stall_d1_q)                                ? (frbuf_rd_ptr_q[7:0] + 8'h01):           // -- only increment every other cycle in x4
                                   (replay_count_q[3:0] == 4'h8) & beat3 & init_replay_late_done_q & (stall_d1_q)                                                     ? (frbuf_rd_ptr_q[7:0]):                   // -- if didn't dec last cycle due to stalls
                                   (stall_d1_q & ~frbuf_rd_vld_q & frbuf_rd_vld_d0_q & ~frbuf_empty & ~force_idle_now_q)                                               |                                         // -- finished last read during stall_d0_q, catch pointer back up
                                   (frbuf_rd_vld_q  & ~frbuf_empty)                                                                                                   ? (frbuf_rd_ptr_q[7:0] + 8'h01):           // -- increment to address to use for next read
                                                                                                                                                                        frbuf_rd_ptr_q[7:0];

assign frbuf_rd0_en               = frbuf_rd_vld_q;
assign frbuf_rd0_addr[7:0]        = frbuf_rd_ptr_q[7:0];
assign frbuf_rd0_select_pair0_din = frbuf_rd_vld_q & ~frbuf_rd_ptr_q[0];
assign frbuf_rd0_select_pair1_din = frbuf_rd_vld_q;

//--10/1 timing
assign frbuf_rd_eq_wr_din          = (frbuf_wr_ptr_din[7:0] ==  frbuf_rd_ptr_din[7:0]);
assign frbuf_rd_p1_eq_wr_din       = (frbuf_wr_ptr_din[7:0] == (frbuf_rd_ptr_din[7:0] + 8'h01));
assign frbuf_rd_eq_beats_din       = (beats_sent_din[7:0]   ==  frbuf_rd_ptr_din[7:0]);
assign frbuf_rd_eq_beats_72_din    = (beats_sent_din[7:2]   ==  frbuf_rd_ptr_din[7:2]);
assign frbuf_rd_m1_eq_beats_din    = (beats_sent_din[7:0]   == (frbuf_rd_ptr_din[7:0] - 8'h01));
assign frbuf_rd_p1_eq_beats_72_din = (beats_sent_din[7:2]   == (frbuf_rd_ptr_din[7:2] + 6'b000001)); 

assign frbuf_rd1_en               = 1'b0;
//--4/13 assign frbuf_rd1_en               = ~tsm4_q & send_ctl_b0 & ~send_replay & ~fastpath_q & ~delayed_fastpath_q & ~double_delayed_fastpath_q & ~triple_delayed_fastpath_q & ~quad_delayed_fastpath_q;
assign frbuf_rd1_addr[7:0]        = {frbuf_rd_ptr_q[7:2], 2'b11};      //--frbuf_rd_ptr_q should always be even in send_ctl_b2 cycle.  fetch odd in parallel

assign frbuf_empty                = (~fastpath_din & fastpath_q) ? (frbuf_rd_eq_wr_q | ((frbuf_wr_ptr_q[7:0] == (frbuf_rd_ptr_q[7:0] + 8'h01)) & stall_d4_q)) & ~tl2dl_flit_early_vld:
//--10/1 assign frbuf_empty                = (~fastpath_din & fastpath_q) ? ((frbuf_wr_ptr_q[7:0] == frbuf_rd_ptr_q[7:0]) | ((frbuf_wr_ptr_q[7:0] == (frbuf_rd_ptr_q[7:0] + 8'h01)) & stall_d4_q)) & ~tl2dl_flit_early_vld:
                                                                    frbuf_rd_eq_wr_q & ~tl2dl_flit_early_vld_q;
//--10/1                                                                     (frbuf_wr_ptr_q[7:0] == frbuf_rd_ptr_q[7:0]) & ~tl2dl_flit_early_vld_q;

assign frbuf_empty_din            = frbuf_empty;
assign frbuf_empty_d0_din         = frbuf_empty_q;
assign frbuf_empty_d1_din         = frbuf_empty_d0_q;


//-- buffer is used for TL data to be sent as well as data that has not yet been acked (may need to be replayed)  
    // --check to see if buffers are full - (tl2dl_flit_lbip_vld = add an entry)

assign rpb_rm_depth[7:0] = 
                           (trn_flt_rpb_rm_depth[3:0] == 4'h6) ?  8'hc0:
                           (trn_flt_rpb_rm_depth[3:0] == 4'h5) ?  8'ha0:
                           (trn_flt_rpb_rm_depth[3:0] == 4'h4) ?  8'h80:
                           (trn_flt_rpb_rm_depth[3:0] == 4'h3) ?  8'h60:
                           (trn_flt_rpb_rm_depth[3:0] == 4'h2) ?  8'h40:
                           (trn_flt_rpb_rm_depth[3:0] == 4'h1) ?  8'h20:
                                                                  8'h00;   

//-- Replay Control *****************************************************************************************************
//-- Start replay if (RX received a nack (bad CRC received), or (after a short idle
//--_ni = not idle (need to break a loop)
assign replay_go_ni           = ((nack_d0_q | nack_q | nack_pend_q | second_replay_pend_q) & ((run_length_q[3:0] == 4'h0) & beat1) & ~tsm4_q & ~pm_msg_sent_e0_q & ~pm_msg_sent_q & ~go_narrow_delay &
                                ~replay_b2_q & ~replay_b2_d0_q & ~replay_b2_d1_q & ~stall_d3_q & init_replay_done_q) | (init_replay_done_q & retrain_replay_done_q & ~train_done_d0_q);

assign replay_go              = ((nack_d0_q | nack_q | nack_pend_q | second_replay_pend_q) & (((run_length_q[3:0] == 4'h0) & beat1) | (enable_short_idle_q & short_flit_next & send_idle_b3)) &
                                                                                                         ~tsm4_q & ~pm_msg_sent_e0_q & ~pm_msg_sent_stall_q & ~pm_msg_sent_q & ~go_narrow_delay & ~pm_msg_dly &
//--11/20  assign replay_go              = ((nack_d0_q | nack_q | nack_pend_q | second_replay_pend_q) & (((run_length_q[3:0] == 4'h0) & beat1) | (enable_short_idle_q & short_flit_next & send_idle_b3)) & ~tsm4_q & ~pm_msg_sent_e0_q & ~pm_msg_sent_q & ~go_narrow_delay &
                                ~replay_b2_q & ~replay_b2_d0_q & ~replay_b2_d1_q & ~stall_d3_q & init_replay_done_q) | (init_replay_done_q & retrain_replay_done_q & ~train_done_d0_q);

assign replay_b1_ni           = replay_go_ni & ~(replay_in_progress_q & ~((replay_done_din | replay_done_q | replay_done_d0_q) & second_replay_pend_q & (replay_count_q == 4'hB))) ;
assign replay_b1              = replay_go    & ~(replay_in_progress_q & ~((replay_done_din | replay_done_q | replay_done_d0_q) & second_replay_pend_q & (replay_count_q == 4'hB))) ;
//-- 9/12  (two consecutive replays, stall goes on immediately after the first one.  replay_b1 waits one flit) assign replay_b1              = replay_go & ~replay_in_progress_q ;

//--11/20  add delay after pm_msg for x4 & x8 mode (use spare latches)
assign pm_msg_dly             = {spare_03_q, spare_02_q, spare_01_q, spare_00_q} != 4'h0;

assign spare_03_din                  = pm_msg_sent_q ? 1'b1:
                                                       pm_msg_dly_cnt[3];
assign spare_02_din                  = pm_msg_sent_q ? 1'b1:
                                                       pm_msg_dly_cnt[2];   
assign spare_01_din                  = pm_msg_sent_q ? 1'b1:
                                                       pm_msg_dly_cnt[1];   
assign spare_00_din                  = pm_msg_sent_q ? 1'b1:
                                                       pm_msg_dly_cnt[0];

assign pm_msg_dly_cnt[3:0]    = ({spare_03_q, spare_02_q, spare_01_q, spare_00_q} != 4'h0) ? {spare_03_q, spare_02_q, spare_01_q, spare_00_q} - 4'h1:
                                                                                             {spare_03_q, spare_02_q, spare_01_q, spare_00_q};   
//--11/20  end

assign replay_b2_din          = replay_b1;
assign replay_b2_d0_din       = replay_b2_q;
assign replay_b2_d1_din       = replay_b2_d0_q;
assign replay_b2_d2_din       = replay_b2_d1_q;
assign replay_b2_d3_din       = replay_b2_d2_q;
assign replay_b2_d4_din       = replay_b2_d3_q;
assign replay_b2_d5_din       = replay_b2_d4_q;
assign replay_b2_d6_din       = replay_b2_d5_q;
assign replay_b2_d7_din       = replay_b2_d6_q;
assign replay_b2_d8_din       = replay_b2_d7_q;

 //-- no second replays for nacks
//-- 12/3 need to reset when in state 4
//-- assign second_replay_pend_din = ((rx_tx_crc_error & ~tsm4_d0_q & (replay_in_progress_q | replay_short_idle_q)) | second_replay_pend_q) & ~(replay_count_q[3:0] == 4'h1); 
assign second_replay_pend_din = ((rx_tx_crc_error & ~tsm4_d0_q & (replay_in_progress_q | replay_short_idle_q)) | second_replay_pend_q) & ~(replay_count_q[3:0] == 4'h1) & ~tsm4_d0_q; 

//--10/22 SI
assign second_error_after_reset_din = ((second_replay_pend_q & ~init_replay_done_q) | second_error_after_reset_q) & ~((flit_type_q == 2'b11) & ~replay_short_idle_q & (trn_flt_tsm[2:0] == 3'b111));
//--10/24 assign second_error_after_reset_din = ((second_replay_pend_q & ~init_replay_done_q) | second_error_after_reset_q) & ~(send_ctl_b0);

//-- Set replay in progresss when the links are retraining.
assign replay_in_progress_din = (replay_in_progress_q | (replay_count_q[3:0] == 4'h0) | ((retrain_replay_done_din & ~retrain_replay_done_q) & link_up_q)) &
                                                   ~(~reset_latches_n[0] | (replay_done_d1_q & (((replay_count_q[3:0] == 4'h9) & beat3) | (replay_count_q[3:0] > 4'h9))) | tsm4_d1_q);  

assign replay_in_progress_d0_din = replay_in_progress_q;
assign replay_in_progress_d1_din = replay_in_progress_d0_q;

//-- add in the '4' to not count the last one sent before the replay            
assign replay_done_din            = ((replay_count_q[3:0] == 4'h8) & beat3 & ~init_replay_done_q)                                                                                                                 |       //-- initial replay only
                                    (slowpath_glitch_q & (replay_count_q[3:0] == 4'h9) & beat3 & replay_in_progress_q & init_replay_done_q)                                                                       |       //-- was empty during replay, nothing to send
                                    ((frbuf_rd_eq_beats_q | (frbuf_rd_m1_eq_beats_q & stall_d1_q)) & replay_in_progress_q  &
                                                                              ((x8_tx_mode_q & (replay_count_q[3:0] > 4'h7)) | (~x8_tx_mode_q & (replay_count_q[3:0] > 4'h8))) & init_replay_done_q)              |
//--10/16                                                                               ((~x2_tx_mode_q & (replay_count_q[3:0] > 4'h7)) | (x2_tx_mode_q & (replay_count_q[3:0] > 4'h8))) & init_replay_done_q)              |
                                    (force_idle_hold & frbuf_rd_eq_wr_q & replay_in_progress_q  & (replay_count_q[3:0] > 4'h7) & init_replay_done_q) ;
//--10/1                                   (((beats_sent_q[7:0] == frbuf_rd_ptr_q[7:0]) | ((beats_sent_q[7:0] == (frbuf_rd_ptr_q[7:0] - 8'h01)) & stall_d1_q)) & replay_in_progress_q  &
//--10/1                                    (force_idle_hold & (frbuf_wr_ptr_q[7:0] == frbuf_rd_ptr_q[7:0]) & replay_in_progress_q  & (replay_count_q[3:0] > 4'h7) & init_replay_done_q) ;

assign replay_done_b0_din         = beat3 & frbuf_rd_p1_eq_beats_72_q & replay_in_progress_q & (replay_count_q[3:0] == 4'hB) & init_replay_done_q;

assign replay_done_d0_din = replay_done_q;
assign replay_done_d1_din = replay_done_d0_q;

    //--Need to know this is the 'replay' after training... set after initial training
    //-- leave init_replay signals asserted unless whole link is reset.   added retrain replay done and reset with each retrain.
//--10/17  remove 10/19 assign init_replay_done_din      = (((replay_count_q[3:0]==4'h8) & beat3 & ~stall_d3_q & ~second_replay_pend_q) | init_replay_done_q) & reset_latches_n[0];
//--10/17  remove 10/19 assign init_replay_late_done_din = (((replay_count_q[3:0]==4'hA) & beat3 & ~stall_d3_q & ~second_replay_pend_q) | init_replay_late_done_q) & reset_latches_n[0];
//--10/18  remove 10/19 assign retrain_replay_done_din   = (((replay_count_q[3:0]==4'h3) & beat3 & ~stall_d3_q) | retrain_replay_done_q) & reset_latches_n[0] & ~tsm4_d0_q & ~((replay_count_q[3:0]==4'h9) & beat1 & ~init_replay_done_q);
assign init_replay_done_din      = (((replay_count_q[3:0]==4'h8) & beat3 & ~stall_d3_q) | init_replay_done_q) & reset_latches_n[0];

assign init_replay_late_done_din = (((replay_count_q[3:0]==4'hA) & beat3 & ~stall_d3_q & ~second_error_after_reset_q) | ((flit_type_q == 2'b11) & ~replay_short_idle_q & (trn_flt_tsm[2:0] == 3'b111)) | init_replay_late_done_q) & reset_latches_n[0];
//--10/24  assign init_replay_late_done_din = (((replay_count_q[3:0]==4'hA) & beat3 & ~stall_d3_q & ~second_error_after_reset_q) | init_replay_late_done_q) & reset_latches_n[0];
//--10/22  assign init_replay_late_done_din = (((replay_count_q[3:0]==4'hA) & beat3 & ~stall_d3_q) | init_replay_late_done_q) & reset_latches_n[0];
assign retrain_replay_done_din   = (((replay_count_q[3:0]==4'h3) & beat3 & ~stall_d3_q) | retrain_replay_done_q) & reset_latches_n[0] & ~tsm4_d0_q;


//-- Add three short idles if short idles are enabled before we start replays
assign replay_short_idle_din           = ((((replay_b1 & ~stall_d2_q) | (replay_b2_q & stall_d3_q & ~stall_d2_q) | (replay_b2_d0_q  & stall_d4_q & ~x2_tx_mode_q) |
                                                                 ((replay_b2_d1_q | replay_b2_d2_q)  & ~stall_d2_q & x2_tx_mode_q)) & enable_short_idle_q) | replay_short_idle_q) & ~(((pre_replay_idle_cnt_q[2:0] == 3'b001) & ~stall_d3_q) | tsm4_d1_q); 

//-- in order to give 'main' a chance to realign, send 4 short idles, main can use the 'short_flit_next' signal to realign
assign pre_replay_idle_cnt_din[2:0] = ~reset_latches_n[0]                                                                                                                    ? 3'b000:
                                      stall_d3_q & ~replay_b2_q                                                                                                              ? pre_replay_idle_cnt_q[2:0]:           // -- stall.. pretend the cycle didn't occur
                                      (replay_b2_q & x8_tx_mode_q) | ((replay_b2_d2_q | replay_b2_d3_q) & x4_tx_mode_q) | ((replay_b2_d2_q | replay_b2_d3_q) & x2_tx_mode_q) ? 3'b100:                               // -- start sending 4 short flits
                                      ~(pre_replay_idle_cnt_q[2:0] == 3'b000) & ~stall_d3_q                                                                                  ? pre_replay_idle_cnt_q[2:0] - 3'b001:  // --
                                                                                                                                                                               pre_replay_idle_cnt_q[2:0];

//-- Count to control replays.  This runs from the start of a replay until data from frbuf starts.
//-- This is used as a sequencer state (replays start @ count starts at 2)
assign replay_count_din[3:0] = ~reset_latches_n[0] | trn_flt_train_done                                                                                    ? 4'h1:
                                tsm4_d1_q                                                                                                                  ? 4'h0:                         // -- retrain
                                x8_tx_mode_q & replay_b2_d0_q & ~stall_d3_q                                                                                ? 4'h0:                         // --set = 0 when replay begins and no stalls in the way
                                x4_tx_mode_q & ((replay_b2_d1_q & ~(stall_d3_q & stall_d4_q) & beat3) |
                                                (replay_b2_d2_q &   stall_d4_q & stall_d5_q  & beat3) |
                                                (replay_b2_d3_q &   stall_d6_q & stall_d7_q))                                                              ? 4'h0:                         // --set = 0 when replay begins
                                x8_tx_mode_q & replay_b2_d0_q &  stall_d3_q                                                                                ? 4'h0:                         // --Wait one cycle due to stall (0-1)
                                x2_tx_mode_q & ((replay_b2_d6_q & ~stall_d3_q & beat3) |
                                                (replay_b2_d7_q & ~stall_d3_q))                                                                            ? 4'h0:                         // --set = 0 when replay begins
                                stall_d3_q                                                                                                                 ? replay_count_q[3:0]:          // --stall.. pretend the cycle didn't occur
                                (replay_count_q == 4'h3) & beat3 & ~replay_short_idle_q & ~enable_short_idle_q & x8_tx_mode_q & retrain_replay_done_q      ? replay_count_q[3:0] + 4'h2:   // --skip a count for long idle x8 mode only. 0 sends a replay in this mode, easier than messing w/ either end  
//--8/4  only sent 8           (replay_count_q == 4'h5) & beat3 & ~replay_short_idle_q & ~enable_short_idle_q & x2_tx_mode_q & init_replay_done_q         ? replay_count_q[3:0] + 4'h2:   // --skip a count for long idle x2 mode only. 0 sends a replay in this mode, easier than messing w/ either end  
                                (replay_count_q < 4'hB) & beat3 & ~replay_short_idle_q & ~((pre_replay_idle_cnt_q[2:0] == 3'b100) & ~enable_short_idle_q)  ? replay_count_q[3:0] + 4'h1:   // --increment count if not done (final count = 9 replays sent + ?? cycles of set up)
                                                                                                                                                             replay_count_q[3:0];

    // --Grab previous run length when taking from the replay buffer - Sent 9th with replay flit, init_replay_done_q is used to block data on last replay flit after first training.
    // -- also after reset, don't send 'old' value for length, send zeros --- add to block 'old' data if there is nothing to send
    //-- (beat3[67:64] = 451:448 of whole flit)

assign reset_occurred_din  = ((trn_flt_tsm[2:0] == 3'b001) | reset_occurred_q) & (tx_ack_ptr_q[11:2] == 10'b0000000000);
//--10/23 assign reset_occurred_din  = ((reset_n_din[0] & ~reset_n_q[0]) | reset_occurred_q) & (tx_ack_ptr_q[11:2] == 10'b0000000000);
//--10/22  assign reset_occurred_din  = (~reset_latches_n[0] | reset_occurred_q) & (tx_ack_ptr_q[11:2] == 10'b0000000000);

//--10/23 I don't think this following statement does anything except on a full reset, most of it could probably be deleted.
assign tx_rl_not_vld_din   = ~(tsm4_q & ~reset_occurred_q) & (~init_replay_done_q | ~reset_latches_n[0] | frbuf_xm1_not_vld | ((replay_count_q[3:0] == 4'h9) & beat2 & all_tx_credits_returned_int & ~(stall_d2_q & stall_d3_q)) | tx_rl_not_vld_q) & reset_occurred_q;
//--10/25  assign tx_rl_not_vld_din   = ~tsm4_q & (~init_replay_done_q | ~reset_latches_n[0] | frbuf_xm1_not_vld | ((replay_count_q[3:0] == 4'h9) & beat2 & all_tx_credits_returned_int & ~(stall_d2_q & stall_d3_q)) | tx_rl_not_vld_q) & reset_occurred_q;
//--10/22  assign tx_rl_not_vld_din   = ~tsm4_q & (~init_replay_done_q | ~reset_latches_n[0] | frbuf_xm1_not_vld | ((replay_count_q[3:0] == 4'h9) & beat2 & all_tx_credits_returned_int & ~(stall_d2_q & stall_d3_q)) | tx_rl_not_vld_q) & reset_occurred_q;
//--10/15  assign tx_rl_not_vld_din   = ~tsm4_q & (~init_replay_done_q | ~reset_latches_n[0] | frbuf_xm1_not_vld | ((replay_count_q[3:0] == 4'h9) & beat2 & all_tx_credits_returned_int & ~(stall_d2_q & stall_d3_q)) | tx_rl_not_vld_q) & (tx_ack_ptr_q[11:2] == 10'b0000000000);

assign prev_cmd_run_length_din[3:0]  = tx_rl_not_vld_q | tsm4_q                                                                                                                           ? 4'h0:
                                       (replay_count_q[3:1] == 3'b101) | frbuf_empty                                                                                                      ? 4'h0:   //--  reset count to zero when count = A or B for next replay.
                                       ((frbuf_xm1_vld_d3_q & ~x2_tx_mode_q) | (frbuf_xm1_vld_d3_q & frbuf_xm1_vld_d4_q & x2_tx_mode_q)) & init_replay_late_done_q & ~slowpath_glitch_q   ? buffer_out_d0_q[67:64]:
                                                                                                                                                                                            prev_cmd_run_length_q;

    //-- Save replay pointer to use in replay command (in case incoming replay flit tells me to start at another address... which will only happen if we happen to do another replay)
//-- low order 2 bits are always 00
assign frbuf_replay_pointer_din[13:0] = (replay_count_q[3:0]==4'h5) ? tx_ack_ptr_q[13:0]:
//--10/4  to make change elsewhere easier assign frbuf_replay_pointer_din[13:0] = ((x2_tx_mode_q & (replay_count_q[3:0]==4'h5)) | (x4_tx_mode_q & (replay_count_q[3:0]==4'h4)) | (x8_tx_mode_q & (replay_count_q[3:0]==4'h5))) ? tx_ack_ptr_q[13:0]:
//--9/17 assign frbuf_replay_pointer_din[13:0] = ((x2_tx_mode_q & (replay_count_q[3:0]==4'h5)) | (x4_tx_mode_q & (replay_count_q[3:0]==4'h4)) | (x8_tx_mode_q & (replay_count_q[3:0]==4'h3))) ? tx_ack_ptr_q[13:0]:
                                                                                                                                                                                      frbuf_replay_pointer_q[13:0];

assign all_tx_credits_returned_int = (frbuf_wr_ptr_q[7:2] == tx_ack_ptr_q[7:2]);
assign all_tx_credits_returned     = all_tx_credits_returned_int;

assign send_no_replay_data_din = ~reset_latches_n[0]                                                                           ? 1'b0:
                                 ((x4_tx_mode_q & (replay_count_q[3:0]==4'h4)) | (x8_tx_mode_q & (replay_count_q[3:0]==4'h3))) ? (frbuf_wr_ptr_q[7:2] == tx_ack_ptr_q[7:2]): 
                                                                                                                                 send_no_replay_data_q;

//-- Signals mainly used to determine how to switch between fastpaths (more delayed to less delayed)
assign one_valid_stutter_din      = enable_fastpath & (tl2dl_flit_vld_q & ~tl2dl_flit_early_vld_q) & tl2dl_flit_early_vld;
assign one_valid_stutter_d0_din   = one_valid_stutter_q;
assign one_valid_stutter_d1_din   = one_valid_stutter_d0_q;
assign one_valid_stutter_d2_din   = one_valid_stutter_d1_q;
assign one_valid_stutter_d3_din   = one_valid_stutter_d2_q;
assign two_valid_stutter_din      = fastpath_end_q    & ~tl2dl_flit_early_vld_q & tl2dl_flit_early_vld;
//--10/4 timing assign two_valid_stutter_din      = fastpath_end_q    & ~tl2dl_flit_vld & tl2dl_flit_early_vld;
assign two_valid_stutter_d0_din   = two_valid_stutter_q;
//-- assign three_valid_stutter_din    = fastpath_end_d0_q & ~tl2dl_flit_vld & tl2dl_flit_early_vld;


assign short_flit_next_e0_din =
                            ~enable_short_idle_q | ~train_done_q | ~retrain_replay_done_q                                                                                    ? 1'b0:
//--11/26 
                             stall_d3_q                                                                                                                                      ? short_flit_next:  
                             go_narrow_delay                                                                                                                                 ? 1'b1:
                             beat2 & ~stall_d3_q & slowpath_glitch_q & (replay_count_q[3:0] == 4'h9)                                                                         ? 1'b1:         //-- add lbist observation latch for this leg??
                             ((replay_count_q[3:0] == 4'h9) & beat2 & ~stall_d3_q) & (frbuf_empty_d0_q | (force_idle_hold & rd_catching_wr))                                 ? 1'b1:
                              replay_short_idle_q & (pre_replay_idle_cnt_q[2:0] == 3'b001) & ~stall_d3_q                                                                     ? 1'b0:
                              replay_short_idle_q                                                                                                                                |
                              (replay_b1 & (beat2 | send_idle_b3))                                                                                                               |
                              ((force_idle_now | (force_idle_hold & rd_catching_wr)) &
                              ((force_idle_now | (force_idle_hold & rd_catching_wr)) & ~(replay_in_progress_q & ~(data_stalled_q & replay_done_d0_q)))) ? 1'b1:  //-- added force_idle... should already get to idle, just stay here for a while
//--10/17                                ((force_idle_now | (force_idle_hold & rd_catching_wr)) & ~(replay_in_progress_q & ~(data_stalled_q & replay_done_d0_q & (replay_count_q[3:0] == 4'hB)))) ? 1'b1:  //-- added force_idle... should already get to idle, just stay here for a while
                              quad_delayed_fastpath_q & ~tl2dl_flit_vld & beat2 & ~stall_d3_q                                                                                ? 1'b1:
                              quad_delayed_fastpath_q & beat3 & ~tl2dl_flit_vld_q                                                                                            ? 1'b1:
                              fastpath_q                                & beat3 & ~tl2dl_flit_early_vld                                                                      ? 1'b1:
                              any_fastpath_q & ~quad_delayed_fastpath_q & beat2 & ~tl2dl_flit_early_vld & ~stall_d3_q                                                        ? 1'b1:
                              any_fastpath_q & ~quad_delayed_fastpath_q & beat3 & ~tl2dl_flit_early_vld                                                                      ? 1'b1:
                             (frbuf_rd_vld_d1_q & ~frbuf_rd_vld_d2_q) & ~(replay_b1 | replay_b2_q | replay_b2_d0_q)                                                              | 
                             (frbuf_rd_vld_d0_q & ~frbuf_rd_vld_d1_q) & ~(replay_b1 | replay_b2_q | replay_b2_d0_q) & stall_d2_q                                             ? 1'b0:   
//--11/16                              (frbuf_rd_vld_d1_q & ~frbuf_rd_vld_d2_q) & ~(replay_b1 | replay_b2_q | replay_b2_d0_q)                                                          ? 1'b0:    //-- if timing issue, only know it needs replay_b2_q (so could take out replay_b1
                             (slowpath_cnt_q[2:0] == 3'b100) & frbuf_rd_vld_q &  (stall_d1_q &  stall_d2_q) & ~go_to_idle_after_flit_din                                     ? 1'b0:   //--x4 only
                             (slowpath_cnt_q[2:0] == 3'b011) & frbuf_rd_vld_q & ~(stall_d3_q & ~stall_d2_q) & ~go_to_idle_after_flit_din                                     ? 1'b0:   //-- incorrect found by , fixed above
                             (slowpath_cnt_q[2:0] == 3'b010) & frbuf_rd_vld_q &   stall_d4_q &                ~go_to_idle_after_flit_q & ~force_idle_hold                    ? 1'b0:    //-- anyfastpath is part of go_to_idle_after_flit_q
                             (slowpath_cnt_q[2:0] == 3'b001) & frbuf_rd_vld_q &   stall_d5_q & ~fp_frbuf_empty_din & ~replay_b2_q      & ~force_idle_hold                    ? 1'b0:
                             ~any_fastpath_q & beat2 & ~frbuf_empty & ~send_replay & ~frbuf_rd_vld_din  & ~stall_d3_q                                                        ? 1'b1: 
                             ~any_fastpath_q & beat2 & ~(slowpath_cnt_din == 3'b000) & ~send_replay & ~frbuf_rd_vld_din & ~stall_d3_q                                        ? 1'b1:
                             ~any_fastpath_q & beat2 & ~tl2dl_flit_vld & ~send_replay & ~frbuf_rd_vld_din  & ~stall_d3_q                                                     ? 1'b1:
                             ~any_fastpath_q & beat2 & (slowpath_cnt_q == 3'b110) & ~send_replay & ~frbuf_rd_vld_q & ~stall_d3_q                                             ? 1'b1: 
                             ~any_fastpath_q & beat2 & (slowpath_cnt_q == 3'b101) & ~send_replay & ~frbuf_rd_vld_d0_q & ~stall_d3_q                                          ? 1'b1: 
                             ~any_fastpath_q & beat2 & (slowpath_cnt_q == 3'b100) & ~send_replay & ~((frbuf_rd_vld_d1_q & x8_tx_mode_q) | (frbuf_rd_vld_d0_q & x4_tx_mode_q)) & ~stall_d3_q  ? 1'b1: 
                             ~any_fastpath_q & beat2 & (slowpath_cnt_q == 3'b011) & ~send_replay & ~frbuf_rd_vld_d2_q & ~stall_d3_q                                          ? 1'b1: 
                              two_valid_stutter_din  & triple_delayed_fastpath_q & ~stall_d3_q & beat2                                                                       ? 1'b1:
                              two_valid_stutter_q    & triple_delayed_fastpath_q & ~stall_d3_q & beat2                                                                       ? 1'b1:
                              two_valid_stutter_din  & quad_delayed_fastpath_q   & ~stall_d3_q & beat2                                                                       ? 1'b1:
                              two_valid_stutter_q    & quad_delayed_fastpath_q   & ~stall_d3_q & beat2                                                                       ? 1'b1:
                              (one_valid_stutter_q | one_valid_stutter_d0_q | one_valid_stutter_d1_q | two_valid_stutter_d0_q) &
                                   (any_fastpath_d0_q | any_fastpath_d1_q | any_fastpath_d2_q | any_fastpath_d3_q) & ~any_fastpath_q & ~stall_d3_q & beat2 & ~x2_tx_mode_q   ? 1'b1:
                              fastpath_din & ~fastpath_q & beat3                                                                                                             ? 1'b0:
                                                                                                                                                                               short_flit_next_e0_q;

//-- nothing added to this that was added to flit_next in february
assign send_idle_next_e0_din =
                             enable_short_idle_q                                                                                                                    ? 1'b0: 
                             ~train_done_q | ~retrain_replay_done_q                                                                                                 ? 1'b0:
                              go_narrow_delay                                                                                                                       ? 1'b1:
//--10/17 moved up
                             ((replay_count_q[3:0] == 4'h9) & ((beat2 & ~stall_d3_q) | (beat3 & ~x8_tx_mode_q))) & (frbuf_empty_d0_q | (force_idle_hold & rd_catching_wr) | force_idle_now)       ? 1'b1:
//--10/17                              ((replay_count_q[3:0] == 4'h9) & beat2 & ~stall_d3_q) & (frbuf_empty_d0_q | (force_idle_hold & rd_catching_wr) | force_idle_now)       ? 1'b1:
                              send_replay_b0_e1 | send_replay_b0_e0 | (send_replay & ~slowpath_glitch_q & ~(replay_done_q | replay_done_d0_q))                      ? 1'b0:
//--10/17                               send_replay_b0_e1 | send_replay_b0_e0 | (send_replay & ~slowpath_glitch_q)                                                            ? 1'b0:
                              slowpath_glitch_q & (replay_count_q[3:0] == 4'h9) & beat2 & ~stall_d3_q                                                               ? 1'b1:
                              one_valid_stutter_d1_q & quad_delayed_fastpath_d3_q & ~quad_delayed_fastpath_q   & ~stall_d3_q & beat2                                ? 1'b1:
//--8/22 
                            ((replay_in_progress_q & (replay_done_din | replay_done_q | replay_done_d0_q) & frbuf_rd_eq_beats_72_q & block_credits & ~frbuf_replay_full_reset_q) & send_ctl_b2) | //-- data_stall @ end of replay, but didn't idle
//--10/1                            ((replay_in_progress_q & (replay_done_din | replay_done_q | replay_done_d0_q) & (beats_sent_q[7:2] == frbuf_rd_ptr_q[7:2]) & block_credits & ~frbuf_replay_full_reset_q) & send_ctl_b2) | //-- data_stall @ end of replay, but didn't idle
                             (replay_in_progress_q & beat2 & ~stall_d3_q & (frbuf_empty_d0_q | (force_idle_hold & rd_catching_wr)) & replay_done_q)                 ? 1'b1:
//--10/16                               ((replay_count_q[3:0] == 4'h9) & beat2 & ~stall_d3_q) & (frbuf_empty_d0_q | (force_idle_hold & rd_catching_wr))                        ? 1'b1:
                              replay_short_idle_q | (replay_b1 & (beat2 | send_idle_b3)) | force_idle_now                                                           ? 1'b1:  //-- added force_idle... should already get to idle, just stay here for a while
                              frbuf_rd_vld_q & (slowpath_cnt_q[2:0] == 3'b010) &~go_to_idle_after_flit_din & x2_tx_mode_q                                           ? 1'b0:  //--x2 li only
                              quad_delayed_fastpath_q & beat2 & ~tl2dl_flit_vld & ~stall_d3_q                                                                       ? 1'b1:
                              quad_delayed_fastpath_q & beat3 & ~tl2dl_flit_vld_q                                                                                   ? 1'b1:
                              fastpath_q                              & beat3 & ~tl2dl_flit_early_vld                                                               ? 1'b1:
                              any_fastpath_q & ~quad_delayed_fastpath_q & beat2 & ~tl2dl_flit_early_vld & ~stall_d3_q                                               ? 1'b1:
                              any_fastpath_q & ~quad_delayed_fastpath_q & beat3 & ~tl2dl_flit_early_vld                                                             ? 1'b1:
            frbuf_rd_vld_q & (slowpath_cnt_q[2:0] == 3'b100) & (stall_d1_q & stall_d2_q) & ~go_to_idle_after_flit_din                                               ? 1'b0:   //--x4 only
            frbuf_rd_vld_q & (slowpath_cnt_q[2:0] == 3'b011) & ~(stall_d3_q & ~stall_d2_q) & ~go_to_idle_after_flit_din                                             ? 1'b0:
            frbuf_rd_vld_q & (slowpath_cnt_q[2:0] == 3'b010) & stall_d4_q & ~go_to_idle_after_flit_q & ~force_idle_hold                                             ? 1'b0:    //-- anyfastpath is part of go_to_idle_after_flit_q
            frbuf_rd_vld_q & (slowpath_cnt_q[2:0] == 3'b001) &  stall_d5_q & ~fp_frbuf_empty_din & ~replay_b2_q & ~force_idle_hold                                  ? 1'b0:
            frbuf_rd_vld_q & beat2                                                                                                                                  ? 1'b0:    
            frbuf_rd_vld_q & beat3 & x2_tx_mode_q                                                                                                                   ? 1'b0:    
                             ~any_fastpath_q & beat2 & ~frbuf_empty & ~send_replay & ~frbuf_rd_vld_din  & ~stall_d3_q                                               ? 1'b1: 
                             ~any_fastpath_q & beat2 & ~(slowpath_cnt_din == 3'b000) & ~send_replay & ~frbuf_rd_vld_din & ~stall_d3_q                               ? 1'b1:
                             ~any_fastpath_q & beat2 & ~tl2dl_flit_vld & ~send_replay & ~frbuf_rd_vld_din  & ~stall_d3_q                                            ? 1'b1:
                             ~any_fastpath_q & beat2 & (slowpath_cnt_q == 3'b110) & ~send_replay & ~frbuf_rd_vld_q & ~stall_d3_q                                    ? 1'b1: 
                             ~any_fastpath_q & beat2 & (slowpath_cnt_q == 3'b101) & ~send_replay & ~frbuf_rd_vld_d0_q & ~stall_d3_q                                 ? 1'b1: 
                             ~any_fastpath_q & beat2 & (slowpath_cnt_q == 3'b100) & ~send_replay & ~((frbuf_rd_vld_d1_q & x8_tx_mode_q) | (frbuf_rd_vld_d0_q & x4_tx_mode_q)) & ~stall_d3_q   ? 1'b1: 
                             ~any_fastpath_q & beat2 & (slowpath_cnt_q == 3'b011) & ~send_replay & ~frbuf_rd_vld_d2_q & ~stall_d3_q                                 ? 1'b1: 
                              two_valid_stutter_din & triple_delayed_fastpath_q & ~stall_d3_q & beat2                                                               ? 1'b1:
                              two_valid_stutter_q & triple_delayed_fastpath_q & ~stall_d3_q & beat2                                                                 ? 1'b1:
                              two_valid_stutter_din & quad_delayed_fastpath_q & ~stall_d3_q & beat2                                                                 ? 1'b1:
                              two_valid_stutter_q & quad_delayed_fastpath_q & ~stall_d3_q & beat2                                                                   ? 1'b1:
                              fastpath_din & ~fastpath_q & beat3                                                                                                    ? 1'b0:
                                                                                                                                                                      send_idle_next_e0_q;

assign send_idle_next     = (send_idle_next_e0_q & ~fastpath_din) |                                                                            //-- gate pre calculated value if fastpath starts (no warning on early_vld)
                            (~tl2dl_flit_early_vld  &  fastpath_q & send_idle_next_partial_q & ~(send_replay_b0_e1 | send_replay_b0_e0 | send_replay));                                              //-- set after fastpath ends (no warning on early_vld)

assign send_idle_next_partial_din = ~((replay_count_q[3:0] < 4'hA) & ~((replay_count_q[3:0] == 4'h9) & beat3)) & ~stall_d3_q & ~enable_short_idle_q;

assign short_flit_next     = (short_flit_next_e0_q & ~fastpath_din) |                                                                            //-- gate pre calculated value if fastpath starts (no warning on early_vld)
                             (~tl2dl_flit_early_vld  &  fastpath_q & short_flit_next_partial_q);                                              //-- set after fastpath ends (no warning on early_vld)

assign send_idle_next_din = send_idle_next;

//-- squeeze all we can for timing
//-- (replay_count_q[3:0] < 4'hA) == send_replay (move back a cycle)
assign short_flit_next_partial_din = ~((replay_count_q[3:0] < 4'hA) & ~((replay_count_q[3:0] == 4'h9) & beat3)) & ~stall_d3_q & enable_short_idle_q;

assign short_flit_next_din    = short_flit_next;
assign short_flit_next_d0_din = short_flit_next_q;
assign short_flit_next_d1_din = short_flit_next_d0_q;
assign short_flit_next_d2_din = short_flit_next_d1_q;
assign short_flit_next_d3_din = short_flit_next_d2_q;

//-- if we missed fast path, count to make sure we can pull from the array
//-- stalls won't impact if we are empty as we are just skipping an idle.  
//--*************************************************

//-- when a glitch causes us to fall out of fastpath, but flits are still coming in
assign slowpath_continue_din = ((tl2dl_flit_early_vld & ~tl2dl_flit_early_vld_q ) | slowpath_continue_q) & ~(((slowpath_cnt_q[2:0] == 3'b000) | (slowpath_cnt_q[2:0] == 3'b110)) & (send_idle | send_replay)) & ~any_fastpath_q; 


assign slowpath_cnt_din[2:0] = tsm4_q | fastpath_q                                                                                                                               ? 3'b000:
                               slowpath_glitch_q                                                                                                                                 ? 3'b111:        //-- reset if it crashes into the end of a replay
                                force_idle_now | ~(pre_replay_idle_cnt_q[2:0] == 3'b000)                                                                                         ? 3'b000:
                               (go_narrow_cnt_q[3:0] == 4'h1) & ~frbuf_empty_q & (slowpath_cnt_q[2:0] == 3'b000) & ~real_stall_d3 & ~(go_narrow_next_q | go_narrow_delay)        ? 3'b110:        //-- update pm message sent
                               (send_pm_msg_q | send_pm_msg_d0_q | go_narrow_delay) & ((slowpath_cnt_q[2:0] == 3'b000) | (slowpath_cnt_q[2:0] == 3'b111))                        ? slowpath_cnt_q[2:0]:  //-- if turned data stalled on for ctl2, don't start slowpath
                                      ((tl2dl_flit_early_vld & ~tl2dl_flit_early_vld_q) & frbuf_empty) & ~(go_narrow_next_q | go_narrow_delay)                                   ? 3'b110: 
                               ~force_idle_hold_din & force_idle_hold & ~frbuf_rd_p1_eq_wr_q & ~(go_narrow_next_q | go_narrow_delay)                                             ? 3'b110:        //-- start slowpath after buffer full ( something is there)
//--10/1                               ~force_idle_hold_din & force_idle_hold & ~(frbuf_wr_ptr_q[7:0] == (frbuf_rd_ptr_q[7:0] + 8'h01)) & ~(go_narrow_next_q | go_narrow_delay)            ? 3'b110:        //-- start slowpath after buffer full ( something is there)
                               ((tl2dl_flit_early_vld & ~tl2dl_flit_early_vld_q) | slowpath_align_q) & ~(replay_count_q[3:0] == 4'h8) & ~fastpath_q & ~no_data_in_frbuf_q &
                                     ~slowpath_glitch_cmplt_q & ~(one_valid_stutter_din & x2_tx_mode_q) & ~(stall_d3_q & x2_tx_mode_q) &
                                     ~(data_stalled_q | force_idle_now | (force_idle_hold & rd_catching_wr)) & ~(go_narrow_next_q | go_narrow_delay) &
                                      ((slowpath_cnt_q[2:0] == 3'b000) | (slowpath_cnt_q[2:0] == 3'b001) | (slowpath_cnt_q[2:0] == 3'b010) | (slowpath_cnt_q[2:0] == 3'b111))    ? 3'b110:        //-- don't update while slowpath_glitch may be 
                               ~slowpath_glitch_cmplt_q & slowpath_glitch_cmplt_d0_q & ~(replay_count_q[3:0] == 4'h8) & ~any_fastpath_q & ~no_data_in_frbuf_q  & ((slowpath_cnt_q[2:0] == 3'b000) | (slowpath_cnt_q[2:0] == 3'b111)) &
                                                                    ~(go_narrow_next_q | go_narrow_delay) &  ~(force_idle_now | (force_idle_hold & rd_catching_wr)) & send_idle   ? 3'b110:        //-- when slowpath_glitch_cmplt_q suts off, see if we should run slowpath
                               slowpath_continue_q & ~(replay_count_q[3:0] == 4'h8) & ~fastpath_q & ~no_data_in_frbuf_q & (slowpath_cnt_q[2:0] == 3'b111) & ~(go_narrow_next_q | go_narrow_delay) ? 3'b110:        //-- update after replay
                               (slowpath_cnt_q[2:0] == 3'b100) & frbuf_empty_q                                                                                                   ? 3'b000:        //-- cancel slowpath glitch delay
                               (slowpath_cnt_q[2:0] == 3'b110) & stall_d4_q & stall_d5_q                                                                                         ? slowpath_cnt_q[2:0]:  //-- Kludge for x4 mode that starts on a real stall
                               ~(slowpath_cnt_q[2:0] == 3'b000) & ~(slowpath_cnt_q[2:0] == 3'b111)                                                                               ? (slowpath_cnt_q[2:0] - 3'b001):
//--8/8  case
                               ~frbuf_empty_q & ~frbuf_rd_vld_q & ~(go_narrow_next_q | go_narrow_delay) & (slowpath_cnt_q[2:0] == 3'b000) &  ~(data_stalled_q | force_idle_now | force_idle_hold)  ? 3'b110:       //-- should have already been started, but 
                                                                                                                                                                                   slowpath_cnt_q[2:0];

assign slowpath_glitch_din          = (no_data_in_frbuf_q | slowpath_glitch_q) & ~(replay_count_q[3:0] == 4'hA);
assign slowpath_glitch_cmplt_din    = ((slowpath_glitch_q | slowpath_glitch_cmplt_q) & ~(slowpath_cnt_q[2:0] == 3'b000) & ~any_fastpath_q) & replay_in_progress_d1_q;
assign slowpath_glitch_cmplt_d0_din = slowpath_glitch_cmplt_q;
assign read_from_array_valid_din    = ((slowpath_cnt_q[2:0] == 3'b101) | read_from_array_valid_q) & ~((frbuf_rd_vld_d0_q & ~x2_tx_mode_q) | (x2_tx_mode_q & (frbuf_rd_vld_d4_q | (slowpath_cnt_q[2:0] == 3'b000)))) & init_replay_done_q & ~frbuf_empty_q;

assign slowpath_align_din           = ((tl2dl_flit_early_vld & ~tl2dl_flit_early_vld_q & (stall_d3_q | go_narrow_delay) & x2_tx_mode_q) | slowpath_align_q) & (slowpath_cnt_q[2:0] == 3'b000);
//-- assign slowpath_align_din           = ((tl2dl_flit_early_vld & ~tl2dl_flit_early_vld_q & stall_d3_q & x2_tx_mode_q) | slowpath_align_q) & (slowpath_cnt_q[2:0] == 3'b000);

//-- This may fire and still not send a pm msg, if slowpath_cnt_q starts before we get to the idle
assign data_stall_pm                = (send_pm_msg_din | send_pm_msg_q) & ~(replay_b1_ni | replay_b2_q | replay_b2_d0_q | replay_b2_d1_q | replay_b2_d2_q) & (pre_replay_idle_cnt_q[2:0] == 3'b000) & send_ctl_b2 & ((slowpath_cnt_q[2:0] == 3'b000) | (slowpath_cnt_q[2:0] == 3'b110));
//--10/8  assign data_stall_pm                = (send_pm_msg_din | send_pm_msg_q) & ~replay_b1_ni & (pre_replay_idle_cnt_q[2:0] == 3'b000) & send_ctl_b2 & ((slowpath_cnt_q[2:0] == 3'b000) | (slowpath_cnt_q[2:0] == 3'b110));
//--10/4  assign data_stall_pm                = (send_pm_msg_din | send_pm_msg_q) & (pre_replay_idle_cnt_q[2:0] == 3'b000) & send_ctl_b2 & ((slowpath_cnt_q[2:0] == 3'b000) | (slowpath_cnt_q[2:0] == 3'b110));
assign data_stall_pm_din            = (data_stall_pm | data_stall_pm_q) & ~pm_msg_sent_d0_q & ~(beats_sent_invalid_q & ~(replay_done_q | replay_done_d0_q));

assign data_stalled                 = replay_b1 |
                                         (send_ctl_b0 & frbuf_replay_full_q & rd_catching_wr & ~(replay_in_progress_q & ~replay_done_b0_q) & (run_length_q[3:0]  == 4'h0))   |
//--10/24                                          (send_ctl_b0 & frbuf_replay_full_q & rd_catching_wr & ~replay_in_progress_q & (run_length_q[3:0]  == 4'h0))   |
                                         (data_stall_pm_din & ~data_stalled_q & ~(replay_in_progress_q & ~(replay_done_q | (x8_tx_mode_q & replay_done_d0_q))) & (pre_replay_idle_cnt_q[2:0] == 3'b000)) |
                                         ((replay_in_progress_q & (replay_done_din | replay_done_q | replay_done_d0_q) & frbuf_rd_eq_beats_72_q & block_credits & ~frbuf_replay_full_reset_q) & (send_ctl_b1 | (send_ctl_b2 & x2_tx_mode_q)));
//--10/15                                          ((replay_in_progress_q & (replay_done_din | replay_done_q | replay_done_d0_q) & frbuf_rd_eq_beats_72_q & block_credits & ~frbuf_replay_full_reset_q) & send_ctl_b1);
//--10/10                                         ((replay_in_progress_q & (replay_done_din | replay_done_q | replay_done_d0_q) & frbuf_rd_eq_beats_72_q & block_credits & ~frbuf_replay_full_reset_q) & send_ctl_b2);
//--10/1 timing                                         ((replay_in_progress_q & (replay_done_din | replay_done_q | replay_done_d0_q) & (beats_sent_q[7:2] == frbuf_rd_ptr_q[7:2]) & block_credits & ~frbuf_replay_full_reset_q) & send_ctl_b2);

assign data_stalled_replay_din      = (replay_b1 | data_stalled_replay_q) & ~data_stalled_end & ~tsm4_d1_q;
assign data_stalled_din             = (data_stalled | data_stalled_q) & ~data_stalled_end & ~tsm4_d1_q;

//--8/23  no assign data_stalled_end             = (data_stalled_replay_q & send_replay_b1) |
//--8/23  no                                       (data_stalled_q & (((send_replay_b1 | (replay_in_progress_q & replay_done_q)) & ~force_idle_hold) |

//--8/29 timing  -- 
//-- assign short_flit_next     = (short_flit_next_e0_q & ~fastpath_din) | ***** remove fastpath_din for data_stalled_end.  Worst case, we don't end stall as quick as we could (I hope)
assign short_flit_next_sometimes     = short_flit_next_e0_q |                                                                            //-- gate pre calculated value if fastpath starts (no warning on early_vld)
                                       (~tl2dl_flit_early_vld  &  fastpath_q & short_flit_next_partial_q);                                              //-- set after fastpath ends (no warning on early_vld)

assign data_stalled_end             = data_stalled_q & (send_replay_b1 |
                                                        (send_idle_b3 | (~enable_short_idle_q & (go_narrow_cnt_q[3:0] == 4'h1)) | (~enable_short_idle_q & send_replay_b1)) &
//--10/24 run from pm msg until we go wide                                                        ((enable_short_idle_q & send_idle_b3) | (~enable_short_idle_q & (go_narrow_cnt_q[3:0] == 4'h1)) | (~enable_short_idle_q & send_replay_b1)) &
                                                                                ((~send_idle_next & ~enable_short_idle_q)
                                                                                 | (~short_flit_next_sometimes & enable_short_idle_q & ~stall_d3_q & ~(go_narrow_next_q | go_narrow_delay))                                      //--short idle only
//--8/29 timing                                                                                 | (~short_flit_next & enable_short_idle_q & ~stall_d3_q & ~(go_narrow_next_q | go_narrow_delay))
                                                                                 | ((slowpath_cnt_q[2:0] == 3'b011)                      & ~(go_narrow_next_q | go_narrow_delay))
                                                                                 | (go_narrow_cnt_q[3:0] == 4'h1)
//--10/24 run from pm msg until we go wide
                                                                                 | (pm_msg_sent_q                                        & ~(go_narrow_next_q | go_narrow_delay))                    //-- go wide, run untill retrained
                                                                                 | (~force_idle_hold_q                                   & ~(go_narrow_next_q | go_narrow_delay))));


assign data_stall_finished_din      = (data_stalled_end & ~send_replay) | (data_stall_finished_q & send_idle);   //-- stall lining up with data_stall_finished cut the runlength short by 1 cycle. 

//-- Power managment   *****************************************************************************************************

//-- keep latch on until msg is sent  -- if data_stalled gets set, there is always an idle sent

assign send_pm_msg_din      = (trn_flt_send_pm_msg | send_pm_msg_q) & ~(pm_msg_sent_e0_q | tsm4_q);

assign send_pm_msg_d0_din   = send_pm_msg_q;
assign send_pm_msg_d1_din   = send_pm_msg_d0_q;
//-- send note to train that we sent the pm(power management) msg

//-- assign pm_msg_sent_d0_din   = pm_msg_sent_q;
assign pm_sendable_din      = ((~x8_tx_mode_q & ~enable_short_idle_q & send_idle_b2 & ~frbuf_rd_vld_q) | (send_idle_b1 & ~(~enable_short_idle_q & frbuf_rd_vld_q)) | short_flit_next | send_replay_b2 | send_ctl_b2) &
                              ((x8_tx_mode_q & ~stall_d3_q) | (~x8_tx_mode_q & ~stall_d2_q)) & init_replay_done_q & ~nack_q;        //-- can only send idle_b2 when in long idle mode, short_flit_next only valid in short idle mode
//--8/24                               ((x8_tx_mode_q & ~stall_d3_q) | (~x8_tx_mode_q & ~stall_d2_q)) & init_replay_done_q;        //-- can only send idle_b2 when in long idle mode, short_flit_next only valid in short idle mode

 assign pm_msg_sent_e0_din   = send_pm_msg_d0_q & send_pm_msg_q & acks_sent_din & ~(send_ctl_q & ~(send_ctl_b3 & short_flit_next)) & ~frbuf_rd_vld_q &
                               ~((slowpath_cnt_q[2:0] == 3'b011) | (~enable_short_idle & (slowpath_cnt_q[2:0] == 3'b100) | (slowpath_cnt_q[2:0] == 3'b101))) & ~replay_go & ~replay_b2_q & ~replay_b2_d0_q & ~replay_b2_d1_q & ~replay_b2_d2_q & ~replay_b2_d3_q & ~send_replay; 
assign pm_msg_sent_din      = (pm_msg_sent_e0_q & ~pm_msg_sent_q & ~(x8_tx_mode_q & real_stall_d3)) | pm_msg_sent_stall_q;  //-- delay one cycle if x8_tx_mode_q & real_stall_d3 

assign pm_msg_sent_stall_din = ~pm_msg_sent_din & pm_msg_sent_e0_q & ~pm_msg_sent_q;

assign pm_msg_sent_d0_din = pm_msg_sent_q;
//-- sent is one cycle after the idle is sent in x8 mode and the stall_d3 cycle's data is never used,  therefore it should always be zero the cycle after d3.  

assign pm_msg_sent_d1_din = pm_msg_sent_d0_q;

assign flt_trn_pm_msg_sent  = pm_msg_sent_q;

//-- wait 8 cycles (not beats) before starting again w/ a narrower bus (send idles, w/ acks of '1f' during this time.
assign go_narrow_next_din     = ((trn_flt_pm_narrow_not_wide & trn_flt_send_pm_msg) | go_narrow_next_q) & ~(pm_msg_sent_d1_q | tsm4_q);
//--10/10  assign go_narrow_next_din     = ((trn_flt_pm_narrow_not_wide & trn_flt_send_pm_msg) | go_narrow_next_q) & ~pm_msg_sent_d1_q;

assign go_narrow_cnt_din[3:0] = pm_msg_sent_q & go_narrow_next_q & x8_tx_mode_q                         ? 4'h7:
                                pm_msg_sent_q & go_narrow_next_q & x4_tx_mode_q & real_stall_d4_q       ? 4'hA:
                                pm_msg_sent_q & go_narrow_next_q & x4_tx_mode_q                         ? 4'h9:
                                (go_narrow_cnt_q[3:0] != 4'h0) & ~trn_flt_real_stall                    ? go_narrow_cnt_q[3:0] - 4'h1:
                                                                                                          go_narrow_cnt_q[3:0];

assign go_narrow_delay        = (go_narrow_cnt_q[3:0] > 4'h1);
assign go_narrow_delay_din    = go_narrow_delay;
assign go_narrow_delay_d0_din = go_narrow_delay_q;
assign go_narrow_delay_d1_din = go_narrow_delay_d0_q;
assign go_narrow_delay_d2_din = go_narrow_delay_d1_q;
assign go_narrow_delay_d3_din = go_narrow_delay_d2_q;

//-- keep run length in case of a stall
assign data_stalled_RL_din[3:0]     = tsm4_d0_q        ? 4'h0:
                                      send_ctl_b2      ? crc_data_in[67:64]:
//--   assign data_stalled_RL_din[3:0]     = send_ctl_b2      ? crc_data_in[67:64]:
                                                         data_stalled_RL_q[3:0];

assign stalled_RL[3:0]              = (((data_stalled_q | go_narrow_delay_d3_q) & (slowpath_cnt_q[2:0] == 3'b011)) | (data_stall_finished_q & stall_d4_q)) ? data_stalled_RL_q[3:0]:
                                                                                                                                    4'h0;

assign gated_stalled_RL[3:0]        = stalled_RL[3:0] & {4{~(replay_b2_q | replay_b2_d0_q | replay_b2_d1_q | replay_in_progress_q)}};

//-- delay that early valid went off,  the stall causes a problem
assign go_to_idle_after_flit_din = ((any_fastpath_q & stall_d3_q & send_ctl_b3 & ~tl2dl_flit_early_vld) | go_to_idle_after_flit_q) & ~short_flit_next_e0_q;


//-- Nacks  *****************************************************************************************************

    // --Nack set it RX received CRC error or a replay flit w/ Nack set, keep it on until is is processed
    //-- reset nack and nack pending with the link is retraining.
assign nack_din      = (rx_tx_crc_error || replay_due2_errors || reg_rmt_write || nack_q) && ~((nack_q & replay_b2_q) || ~reset_latches_n[0]) & ~tsm4_d0_q;
assign nack_d0_din   = (nack_q | nack_d0_q) & ~init_replay_done_q & ~tsm4_d0_q;
assign nack_pend_din = (rx_tx_nack || (nack_pend_q & ~(replay_count_q[3:0] == 4'h9))) & reset_latches_n[0] & ~tsm4_d0_q; //-- ignore multiple nacks coming from a replay 
    // --send=1 if previous was nacked, or previously sent && not 9th replay 
assign send_nack_din = (nack_q | send_nack_q) & ~((replay_count_q[3:0] == 4'h9) & beat3) & train_done_q; 

    //-- receive runlength not valid
//--assign rx_ack_ptr_6_d_din          = rx_ack_ptr_q[8];                                                        //-- keep old bit six for use below
//--10/9 assign rx_rl_not_vld_din           = (~reset_latches_n[0] | rx_rl_not_vld_q) & ~(rx_ack_ptr_6_d_q & ~rx_ack_ptr_q[8]) ;  //-- ignore runlength on replay after a reset until the receive counter rolls
//--10/9 assign rx_rl_not_vld_din           = (~reset_latches_n[0] | rx_rl_not_vld_q) & ~(rx_ack_ptr_6_d_q & ~rx_ack_ptr_q[8]) ;  //-- ignore runlength on replay after a reset until the receive counter rolls


//-- Acks & Credits *****************************************************************************************************
    //-- This keeps track of the replay buffer pointer that will be where a replay starts, it will be sent if we request a replay
    //-- Add in good flits seen by rx from ODL (will send these back to other side as ack_rtn - this is an intermediate step in case the state
    //-- machine is in the middle of an operation)
    //-- (accounts for any acks missed from flits that were never received)
    //-- low two bits are always 00
assign rx_ack_ptr_din[13:0] = ~reset_latches_n[0]  ? {12'h000, 2'b00}:
                                                    (rx_ack_ptr_q[13:0] + {8'h00, rx_tx_rx_ack_inc[3:0], 2'b00});

    //-- Ack to return to ODL, this is an intermediate step 
    //-- If the count exceeded F(rtn_ack_cnt_q[5]), keep track of overflow
    //-- If acks have been sent, replace the count with the new value
    //-- Otherwise, add the new count to the previous count
    //-- Acks are blocked during the go_narrow_delay as flits are not looked at by the receiver
assign rtn_ack_cnt_din[5:0] = ~reset_latches_n[0]                 ? 6'b0:
                              (rtn_ack_cnt_q[5] & acks_sent_din)  ? {2'b0, rx_tx_rx_ack_inc[3:0]} + {1'b0, rtn_ack_cnt_q[4:0]} + 6'b000001:
                              acks_sent_din                       ? {2'b0, rx_tx_rx_ack_inc[3:0]}:
                                                                    {2'b0, rx_tx_rx_ack_inc[3:0]} + rtn_ack_cnt_q[5:0]; 

    // --This is the acks that are returned to ODL
    // --If the value is =100000, we can only send 31 acks, otherwise we can send the full count
assign rtn_acks[5:0] = rtn_ack_cnt_q[5] ? 6'b011111:
                       (go_narrow_delay | ((pm_msg_sent_din | pm_msg_sent_q) & go_narrow_next_q))  ?  6'b000000:                     //-- send illegal length on purpose to signify this field is not to be used
                                                                                                      rtn_ack_cnt_q[5:0];

    // --Acks sent ctl_flits or dl2dl flits

assign acks_sent_din     = (send_idle_b2 | short_flit_next | send_replay_b2 | send_ctl_b2) & ~stall_d3_q & init_replay_done_q &
                                      ~(go_narrow_delay | ((((pm_msg_sent_din | pm_msg_sent_q) & x8_tx_mode_q) | (pm_msg_sent_e0_q & x8_tx_mode_q & stall_d4_q) | pm_msg_sent_q | pm_msg_sent_d0_q | pm_msg_sent_d1_q) & go_narrow_next_q));        //-- can only send idle_b2 when in long idle mode, short_flit_next only valid in short idle mode

    // --Don't overflow returned ack count, not sure how we could, but put in logic to handle anyway
    // --Signals to send an idle flit (to send back the acks)
assign max_ack_cnt = (rtn_ack_cnt_q[5:4] == 2'b11);
    
    // --Update tx pointer, normally just keeps adding in acks, but a replay from ODL gives us a new start pointer
    // --These are the acks for what I have sent across
    // --This are FLIT counts.. don't really need bit 6 as frbuf only holds 256/4 flits = 64
    //-- low order two bits are always zero, makes reading it for debug easier
//--9/24 
assign tx_ack_ptr_pend_din[13:0] = ~reset_latches_n[0]   ? {12'h000,2'b0}:
                                    rx_tx_tx_ack_ptr_vld ? {rx_tx_tx_ack_ptr[11:0],2'b0}: 
                                                           tx_ack_ptr_pend_q[13:0] + {7'b0000000,rx_tx_tx_ack_rtn[4:0],2'b0};

assign tx_ack_pend_vld_din = (rx_tx_tx_ack_ptr_vld | tx_ack_pend_vld_q) & ~tx_ack_ptr_pend_vld;

//-- used to see if the rd_ptr wraps for loading tx_ack_ptr, rd_ptr must pass through 00, only valid from tx_ack_ptr_pend_vld until tx_ack_ptr_din is loaded.
assign frbuf_rd_ptr_ovrflw_din = ((tx_ack_pend_vld_q & ((frbuf_rd_ptr_din[7:0] != 8'h00) & (frbuf_rd_ptr_q[7:0] == 8'h00))) | frbuf_rd_ptr_ovrflw_q) & ~tx_ack_ptr_pend_vld;

assign tx_ack_ptr_din[13:0] = ~reset_latches_n[0]     ? {12'h000,2'b0}:
                               tx_ack_ptr_pend_vld    ? tx_ack_ptr_pend_q[13:0] + {7'b0000000,rx_tx_tx_ack_rtn[4:0],2'b0}: 
//-- 
                               tx_ack_pend_vld_q      ? tx_ack_ptr_q[13:0]: 
//--9/25                                tx_ack_ptr_pend_vld    ? tx_ack_ptr_pend_q[13:0]: 
//--9/24                                rx_tx_tx_ack_ptr_vld ? {rx_tx_tx_ack_ptr[11:0],2'b0}: 
                                                        tx_ack_ptr_q[13:0] + {7'b0000000,rx_tx_tx_ack_rtn[4:0],2'b0};

assign tx_ack_ptr_pend_vld = ~tx_ack_pend_vld_q | (send_replay & (replay_count_q[3:0] >= 4'h5))                      ? 1'b0:             //-- cover when replay_pointer gets loaded into frbuf_rd_ptr
//--10/15  assign tx_ack_ptr_pend_vld = ~tx_ack_pend_vld_q                                                                      ? 1'b0:
                             replay_b1                                                                               ? 1'b1:       
                             (tx_ack_ptr_pend_q[8] != tx_ack_ptr_q[8]) & (frbuf_rd_ptr_q[7:0] >= tx_ack_ptr_q[7:0])  ? frbuf_rd_ptr_ovrflw_q & (frbuf_rd_ptr_q[7:0] >= tx_ack_ptr_pend_q[7:0]):
                             (tx_ack_ptr_pend_q[8] != tx_ack_ptr_q[8]) & (frbuf_rd_ptr_q[7:0] <  tx_ack_ptr_q[7:0])  |                       //-- ? 1'b1:
                             (tx_ack_ptr_pend_q[8] == tx_ack_ptr_q[8]) & (frbuf_rd_ptr_q[7:0] <  tx_ack_ptr_q[7:0])  ? 1'b1: 
                                                                                                                       (frbuf_rd_ptr_q[7:0] >= tx_ack_ptr_pend_q[7:0]);
//-- other case              (tx_ack_ptr_pend_q[8] == tx_ack_ptr_q[8]) & (frbuf_rd_ptr_q[7:0] >= tx_ack_ptr_q[7:0])  ? (frbuf_rd_ptr_q[7:0] >= tx_ack_pend_ptr_q[7:0]):

//-- replay_ack_cnt and frame_ack_cnt are both counters to manage the frbuf.  The frbuf is 256 BEAT deep combination buffer for frames and for replay.
//--   replay_ack_cnt counts FLITs, this means each count is actually 4 entries in the frbuf and keeps track of acks from across the link.
//--   frame_ack_cnt counts BEATS, so each count is 1 entry in the frbuf.
//--   reset counts after 'resets' but not after 'retrain:s'

//-- ?

assign tx_ack_ptr_old_din[13:0]    = reg_dl_1us_tick ? tx_ack_ptr_q[13:0]:
                                                       tx_ack_ptr_old_q[13:0];

assign tx_ack_ptr_no_update_din   =  ~reset_latches_n[0]                                               ? 1'b0:
//-- 8/16                                      (frbuf_rd_ptr_q[7:2] == tx_ack_ptr_q[5:0])                      ? 1'b0:
                                     (frbuf_wr_ptr_q[7:2] == tx_ack_ptr_q[7:2])                        ? 1'b0: 
                                     reg_dl_1us_tick & (tx_ack_ptr_old_q[13:2] == tx_ack_ptr_q[13:2])  ? 1'b1:
                                     ~(tx_ack_ptr_old_q[13:2] == tx_ack_ptr_q[13:2])                   ? 1'b0:
                                                                                                         tx_ack_ptr_no_update_q;


//-- send link up and wait a couple of cycles before sending credits
//-- These are BEAT counts (4 per FLIT)
//-- Once it is set,  should only be reset when the link is reset,  should stay asserted for retrains of the link
assign link_up_din                 = (dl2tl_link_up_int | link_up_q) & ~(trn_flt_tsm[2:0] == 3'b000);
//--9/20 assign link_up_din                 = dl2tl_link_up_int | link_up_q;
assign dl2tl_link_up               = link_up_q;
assign dl2tl_link_up_int           = rx_link_up & train_done_q & not_reset_ack_cnt_q;

//-- Only need to return credits with the first train.  not with retrains.
assign init_credits_sent_din       = (~enable_credit_return_d0_q & enable_credit_return_d1_q) | init_credits_sent_q;
assign enable_credit_return_din    = (~dl2tl_link_up_int | ~init_replay_late_done_q) & ~init_credits_sent_q;

assign enable_credit_return_d0_din = enable_credit_return_q;
assign enable_credit_return_d1_din = enable_credit_return_d0_q;

//-- latch is not required, but may be nice for debug & timing
//--7/16   caused this to be changed on 7/20
assign frbuf_replay_full_din       = (frbuf_wr_ptr_q[7:0] == tx_ack_ptr_q[7:0])                  ? 1'b0:                                                                                     //-- redundant, but easier to read
                                     (frbuf_wr_ptr_q[7:0] <  tx_ack_ptr_q[7:0])                  ? (({1'b0,frbuf_wr_ptr_q[7:0]} + {1'b0,max_TL_credits} + 9'b000001110) > {1'b0,tx_ack_ptr_q[7:0]}):
                                     (frbuf_wr_ptr_q[7:0] >  tx_ack_ptr_q[7:0])                  ? (({1'b0,frbuf_wr_ptr_q[7:0]} + {1'b0,max_TL_credits} + 9'b000001110) > {1'b1,tx_ack_ptr_q[7:0]}):
                                                                                                   1'b0;

//-- in order to guarentee that a full packet can be sent after a replay buffer full rbf condition (ctl + data), don't start a new packet until we have room in the buffer as there is no max time to get tx_credits back
assign force_idle_after_rbf_din = (frbuf_replay_full_q | force_idle_after_rbf_q) & ~(frbuf_replay_full_reset_q);

assign x4_rpf_rp_stalled        = replay_in_progress_q & force_idle_now_q & data_stalled_q & x4_tx_mode_q;

assign force_idle_now           = ~((replay_in_progress_q & ~(replay_done_q | replay_done_d0_q)) & ~(replay_done_q & ~frbuf_replay_full_reset_q)) &
                                    (pre_replay_idle_cnt_q[2:0] == 3'b000) &
                                   ~stall_d3_q & ((send_replay_b2 & replay_done_q & data_stall_pm_q) | send_ctl_b2 | send_idle_b2 | (send_idle_b3 & ~force_idle_hold)) & (data_stall_pm | data_stall_pm_q | data_stalled_q) &
                                                                                                                                  ~go_narrow_delay_d0_q & ~(beats_sent_invalid_q & ~(replay_done_q | replay_done_d0_q | replay_done_d1_q));
//--10/15                                   ~stall_d3_q & (send_ctl_b2 | send_idle_b2 | (send_idle_b3 & ~force_idle_hold)) & (data_stall_pm | data_stall_pm_q | data_stalled_q) & ~go_narrow_delay_d0_q & ~(beats_sent_invalid_q & ~(replay_done_q | replay_done_d0_q | replay_done_d1_q));
//--8/8                                                          ~stall_d3_q & (send_ctl_b2 | send_idle_b2 | (send_idle_b3 & ~force_idle_hold)) & (data_stall_pm | data_stall_pm_q | data_stalled_q) & ~go_narrow_delay_d0_q & ~beats_sent_invalid_q;
assign force_idle_now_din       = force_idle_now;
assign force_idle_now_d0_din    = force_idle_now_q;
assign force_idle_hold_din      = force_idle_now | (force_idle_hold_q & ~(frbuf_replay_full_hold_reset & ~go_narrow_delay & ~(stall_d3_q & stall_d4_q) & ~data_stalled_q));   //-- needed to reset the stall condition
//--10/4  assign force_idle_hold_din      = force_idle_now | (force_idle_hold_q & ~(frbuf_replay_full_reset_din & ~go_narrow_delay & ~(stall_d3_q & stall_d4_q) & ~data_stalled_q));   //-- needed to reset the stall condition
//--10/2  LI fix assign force_idle_hold_din      = force_idle_now | (force_idle_hold_q & ~(frbuf_replay_full_reset_q & ~go_narrow_delay & ~(stall_d3_q & stall_d4_q) & ~data_stalled_q));   //-- needed to reset the stall condition
//--8/10 ( added data_stalled_q, seems to only be needed for LI, may not be req at all) assign force_idle_hold_din      = force_idle_now | (force_idle_hold_q & ~(frbuf_replay_full_reset_q & ~go_narrow_delay & ~(stall_d3_q & stall_d4_q)));   //-- needed to reset the stall condition
assign force_idle_hold_d0_din   = force_idle_hold_q;
assign force_idle_hold          = force_idle_hold_q | force_idle_hold_pm_msg_q | (pm_msg_sent_d0_q & go_narrow_next_q);

//-- starts w/ any pm_msg_sent, not just a hold
assign force_idle_hold_pm_msg_din   = ((send_pm_msg_q & force_idle_now) | pm_msg_sent_d0_q | force_idle_hold_pm_msg_q) & ~(pm_msg_sent_d0_q | replay_in_progress_q);   

assign frbuf_replay_full_reset_din     = 
                                         ((frbuf_wr_ptr_q[7:0] < tx_ack_ptr_q[7:0]) & (~replay_in_progress_q | (replay_in_progress_q & (replay_count_q[3:0] < 4'h5))))  ? (({1'b0,frbuf_wr_ptr_q[7:0]} + 9'b000110000) <  {1'b0,tx_ack_ptr_q[7:0]}):
                                         ((frbuf_wr_ptr_q[7:0] > tx_ack_ptr_q[7:0]) & (~replay_in_progress_q | (replay_in_progress_q & (replay_count_q[3:0] < 4'h5))))  ? (({1'b0,frbuf_wr_ptr_q[7:0]} + 9'b000110000) <  {1'b1,tx_ack_ptr_q[7:0]}):
                                         ~replay_in_progress_din & replay_in_progress_q                                                                                 ? 1'b1:
                                                                                                                                                                          1'b0;

assign frbuf_replay_full_hold_reset     =  
                                          (frbuf_wr_ptr_q[7:0] < {tx_ack_ptr_q[7:0]})              ? (({1'b0,frbuf_wr_ptr_q[7:0]} + 9'b000110000) <  {1'b0,tx_ack_ptr_q[7:0]}):
                                          (frbuf_wr_ptr_q[7:0] > {tx_ack_ptr_q[7:0]})              ? (({1'b0,frbuf_wr_ptr_q[7:0]} + 9'b000110000) <  {1'b1,tx_ack_ptr_q[7:0]}):
                                          ~replay_in_progress_din & replay_in_progress_q           ? 1'b1:
                                                                                                     1'b0;

//--10/4  assign frbuf_replay_full_reset_din     =  
//--10/4                                          (frbuf_wr_ptr_q[7:0] < {tx_ack_ptr_q[7:0]})              ? (({1'b0,frbuf_wr_ptr_q[7:0]} + 9'b000110000) <  {1'b0,tx_ack_ptr_q[7:0]}):
//--10/4                                          (frbuf_wr_ptr_q[7:0] > {tx_ack_ptr_q[7:0]})              ? (({1'b0,frbuf_wr_ptr_q[7:0]} + 9'b000110000) <  {1'b1,tx_ack_ptr_q[7:0]}):
//--10/4                                          ~replay_in_progress_din & replay_in_progress_q           ? 1'b1:
//--10/4                                                                                                     1'b0;

//-- Stop sending data 
//-- assign rd_catching_wr     =              (frbuf_wr_ptr_q[7:0] < frbuf_rd_ptr_q[7:0])                     ? (({1'b0,frbuf_rd_ptr_q[7:0]} + 9'b000110000) > {1'b1,frbuf_wr_ptr_q[7:0]}):
//--                                          (frbuf_wr_ptr_q[7:0] > frbuf_rd_ptr_q[7:0])                     ? (({1'b0,frbuf_rd_ptr_q[7:0]} + 9'b000110000) > {1'b0,frbuf_wr_ptr_q[7:0]}):
//--                                                                                                            1'b1;
//-- equivilant to above
//--************* Timing fix

assign rd_catching_wr_e0_din   =         (frbuf_wr_ptr_q[7:0] < frbuf_rd_ptr_q[7:0])                     ? (({1'b0,frbuf_rd_ptr_q[7:0]} + 9'b000110000) > {1'b1,frbuf_wr_ptr_q[7:0]}):
                                         (frbuf_wr_ptr_q[7:0] > frbuf_rd_ptr_q[7:0])                     ? (({1'b0,frbuf_rd_ptr_q[7:0]} + 9'b000110000) > {1'b0,frbuf_wr_ptr_q[7:0]}):
                                                                                                           1'b1;

assign rd_catching_wr = rd_catching_wr_e0_q | frbuf_rd_eq_wr_q;
//--10/1 assign rd_catching_wr = rd_catching_wr_e0_q | (frbuf_wr_ptr_q[7:0] == frbuf_rd_ptr_q[7:0]);

//--************* Timing fix
//--
//--wire a_w;
//--wire a_q;
//--wire a_1;
//--wire b_1;
//--wire b_q;
//--wire q_1;
//--wire w_1;
//--
//--assign sq_a =   frbuf_wr_ptr_q[7:6] == frbuf_rd_ptr_q[7:6];
//--assign sq_b =   frbuf_wr_ptr_q[7:6] == ({(frbuf_rd_ptr_q[7] ^ frbuf_rd_ptr_q[6]), ~frbuf_rd_ptr_q[6]});
//--assign a_w  =   frbuf_rd_ptr_q[5:4] == frbuf_wr_ptr_q[5:4];
//--assign a_q  =   frbuf_rd_ptr_q[5:4] == 2'b00 & frbuf_wr_ptr_q[5:4]==2'b11;
//--assign a_1  =  (frbuf_rd_ptr_q[5:4] <  frbuf_wr_ptr_q[5:4]) & ~a_q;
//--assign b_1  =  (frbuf_rd_ptr_q[5]   == 1'b1    & frbuf_wr_ptr_q[5:4]==2'b00) | (frbuf_rd_ptr_q[5:4] == 2'b11 & frbuf_wr_ptr_q[5] == 1'b0);
//--
//--assign b_q  =  (frbuf_rd_ptr_q[5:4] == 2'b01 & frbuf_wr_ptr_q[5:4] == 2'b00)
//--             | (frbuf_rd_ptr_q[5:4] == 2'b10 & frbuf_wr_ptr_q[5:4] == 2'b01)
//--             | (frbuf_rd_ptr_q[5:4] == 2'b11 & frbuf_wr_ptr_q[5:4] == 2'b10);
//--assign q_1  = frbuf_rd_ptr_q[3:0]   >  frbuf_wr_ptr_q[3:0];
//--assign w_1  = ~ q_1;
//--
//--assign rd_catching_wr =  (sq_a & a_w & w_1)
//--                       | (sq_a & (a_1 | (a_q & q_1)))
//--                       | (sq_b & (b_1 | (b_q & q_1)));
//--************* end timing fix 


assign rd_catching_wr_din = ((rd_catching_wr & data_stalled_q) | rd_catching_wr_q) & ~data_stalled_end;

//-- have to let TL have enough credits to get to a ctl flit (8 data +1 ctl) * 4 = 36 credits (24h) + a few for edge affects
//-- The TL has credits equal to (max_TL_credits + beats_sent_q - frbuf_wr_ptr_q)
assign block_credits_valid      =        (frbuf_wr_ptr_q[7:0] < tx_ack_ptr_q[7:0])                ? (({1'b0,frbuf_wr_ptr_q[7:0]} + 9'b000101000) > {1'b0,tx_ack_ptr_q[7:0]}):
                                         (frbuf_wr_ptr_q[7:0] > tx_ack_ptr_q[7:0])                ? (({1'b0,frbuf_wr_ptr_q[7:0]} + 9'b000101000) > {1'b1,tx_ack_ptr_q[7:0]}):
                                                                                                    1'b0;

//-- must allow up to 36 credits before we know we have had a ctl flit
assign get_to_next_ctl_cnt_din[7:0] = block_credits_valid & (get_to_next_ctl_cnt_q[7:0] == 8'h00)           ? (8'h24 - tl_credit_cnt_q[7:0]):
                                      (trn_flt_tsm[2:0] != 3'b111)                                          ? get_to_next_ctl_cnt_q[7:0]:                    //-- Hold the value while in retrain.  
//--10/25                                       tsm4_q                                                                ? get_to_next_ctl_cnt_q[7:0]:                    //-- Hold the value while in retrain.  
                                      block_credits_valid & (get_to_next_ctl_cnt_q[7:0] == 8'h01)           ? 8'h01:
//--11/15                  
                                      ~give_flit_credit                                                     ? get_to_next_ctl_cnt_q[7:0]:              //-- Only count as each one goes out
//-- 11/13                                        stall_d3_q                                                            ? get_to_next_ctl_cnt_q[7:0]:              //-- Only count as each one goes out
                                      block_credits_valid & (trn_flt_tsm[2:0] == 3'b111) & train_done_d1_q  ? (get_to_next_ctl_cnt_q[7:0] - 8'h01):
//--10/23                                       block_credits_valid                                          ? (get_to_next_ctl_cnt_q[7:0] - 8'h01):
                                      replay_in_progress_q & ~replay_done_q                                 ? get_to_next_ctl_cnt_q[7:0]:              //-- Don't unblock during a replay
                                                                                                              8'h00;                                   //-- if ~block_credits_valid, crisis is over
//--8/23                                       tsm4_q                                                       ? tl_credit_cnt_q[7:0]:                    //-- Hold the value while in retrain.  
//--9/7 assign get_to_next_ctl_cnt_din[7:0] = block_credits_valid & (get_to_next_ctl_cnt_q[7:0] == 8'h00)  ? (8'h24 - ({2'b00,trn_flt_tl_credits[5:0]} - frame_buf_credit_cnt_q[7:0])): 
//--7/16   assign get_to_next_ctl_cnt_din[7:0] = block_credits_valid & (get_to_next_ctl_cnt_q[7:0] == 8'h00)  ? (8'h29 - ({2'b00,trn_flt_tl_credits[5:0]} - frame_buf_credit_cnt_q[7:0])): 

assign block_credits               = (get_to_next_ctl_cnt_q[7:0] == 8'h01);

assign give_flit_credit            = (~(frame_buf_credit_cnt_q[7:3] == 5'b00000) | (frame_buf_credit_cnt_q[2:0] > beats_sent_retrain_adj_q[2:0])) & train_done_d1_q & ~(frbuf_replay_full_q & block_credits) & (trn_flt_tsm[2:0] == 3'b111);
//--10/15  no assign give_flit_credit            = ~(frame_buf_credit_cnt_q[7:0] == 8'h00) & (beats_sent_retrain_adj_q[2:0] == 3'b000) & train_done_d1_q & ~(frbuf_replay_full_q & block_credits) & (trn_flt_tsm[2:0] == 3'b111);
//--10/15  assign give_flit_credit            = ~(frame_buf_credit_cnt_q[7:0] == 8'h00) & train_done_d1_q & ~(frbuf_replay_full_q & block_credits) & (trn_flt_tsm[2:0] == 3'b111);
//--9/27  assign give_flit_credit            = ~(frame_buf_credit_cnt_q[7:0] == 8'h00) & train_done_d1_q & ~(frbuf_replay_full_q & block_credits) & (trn_flt_tsm[2:0] != 3'b000);
//--9/24  assign give_flit_credit            = ~(frame_buf_credit_cnt_q[7:0] == 8'h00) & train_done_d1_q & ~(frbuf_replay_full_q & block_credits);

assign beats_sent_din[7:0]         = ~reset_latches_n[0]    ? 8'h00:
                                     flit_vld               ? (beats_sent_q[7:0] +8'h01):
                                     tsm4_d3_q              ? {beats_sent_q[7:2],2'b00}:
                                                               beats_sent_q[7:0];

assign beats_sent_retrain_adj_din[2:0] = tsm4_d2_q & ~tsm4_d3_q                                            ? (beats_sent_retrain_adj_q[2:0] + {1'b0,beats_sent_q[1:0]}):
                                         flit_vld & ~tsm4_d3_q & (beats_sent_retrain_adj_q[2:0] != 3'b000) ? (beats_sent_retrain_adj_q[2:0] - 3'b001):
                                                                                                              beats_sent_retrain_adj_q[2:0];

assign beats_sent_invalid_din   = (tsm4_q | beats_sent_invalid_q) & ~(send_ctl_b1 & ~replay_in_progress_q);
//--9/5  assign beats_sent_invalid_din   = (tsm4_q | beats_sent_invalid_q) & ~(send_ctl_b3 & ~replay_in_progress_q);

//-- when starting replay flits,  we send out one last flit and need to take credit for it.
assign new_flit_sent               = flit_vld & (beats_sent_retrain_adj_q[2:0] == 3'b000);

//--9/7 How many credits does TL have 
assign tl_credit_cnt_din[7:0]  = ~enable_credit_return_d0_q & enable_credit_return_d1_q ? 8'h00:                         //-- initialize to 0
                                 give_flit_credit &  tl2dl_flit_vld                     ?  tl_credit_cnt_q[7:0]: 
                                 give_flit_credit                                       ? (tl_credit_cnt_q[7:0] + 8'h01): 
                                 tl2dl_flit_vld                                         ? (tl_credit_cnt_q[7:0] - 8'h01): 
                                                                                           tl_credit_cnt_q[7:0]; 

//-- simpication:  if our replay area is full (all but max_TL_credits) wait for acks from other end.
//-- this should only happen on some kind or recovery
assign frame_buf_credit_cnt_din[7:0]  = ~enable_credit_return_d0_q & enable_credit_return_d1_q ? {2'b00,trn_flt_tl_credits[5:0]}:                         //-- initialize to 32
                                         new_flit_sent & ~tsm4_d2_q & give_flit_credit         ?  frame_buf_credit_cnt_q[7:0]:            //-- decrement & increment both             
                                         new_flit_sent & ~tsm4_d2_q                            ? (frame_buf_credit_cnt_q[7:0] + 8'h01):   
                                         give_flit_credit                                      ? (frame_buf_credit_cnt_q[7:0] - 8'h01):    //-- give TL one beat of credit every cycle that we can
                                                                                                  frame_buf_credit_cnt_q[7:0];
 
assign not_reset_ack_cnt_din = ~reset_latches_n[0]                   ? 1'b0:          //-- count on this intializing to zero on POR
                               trn_flt_train_done                    ? 1'b1:
                                                                       not_reset_ack_cnt_q;

    // -- send credit response to TL
assign dl2tl_flit_credit = give_flit_credit;   //-- credits available

//-- Errors *****************************************************************************************************
assign link_errors_din[7:0]     = trn_flt_link_errors[7:0];
assign link_info_din[63:0]      = {reg_rmt_config[31:0],32'h00000000};

assign replay_due2_errors       = |({link_errors_q[7:0]});

//-- debug ************************************************************************************************

//-- assign flt_agn_fp_vld             = any_fastpath_q;                                                                             //-- all beats
//-- assign flt_agn_use_ngbr           = 1'b0;                                                                                     //-- not currently used
assign flt_trn_no_fwd_prog        = tx_ack_ptr_no_update_q & reg_dl_1us_tick & (tx_ack_ptr_old_q[13:2] == tx_ack_ptr_q[13:2]);  //-- if nothing was acked for over 1 usec & we are doing nothing
assign flt_trn_fp_start           = fastpath_start_q & fastpath_q;                                                            //-- once per set of fastpaths
assign flt_trn_rpl_data_flt       = replay_in_progress_q & ~send_replay & ~send_ctl & beat0;                                  //-- data flit being resent for replay, once per flit
assign flt_trn_data_flt           = (any_fastpath_q | (flit_type[1:0] == 2'b01)) & ~send_ctl & beat0;                           //-- data flit (includes replay data flits), once per flit 
assign flt_trn_ctl_flt            = send_ctl_b0;                                                                              //-- once per flit
assign flt_trn_rpl_flt            = replay_in_progress_q & beat0;                                                             //-- all flits during replay, includes 9 replay flits, control and data (does not include 5 beats of pre replay idles), once per flit
assign flt_trn_idle_flt           = send_idle_b0;                                                                             //-- once per flit

//--10/19  assign flt_trn_data_pty_err       =  second_replay_pend_q & ~init_replay_done_q;              //-- replay caused during initial replay or in replay starting after a reset.
assign flt_trn_data_pty_err       = 1'b0;                                                                                     //-- not currently used

assign tl_trunc                   = (beats_sent_din[7:2] == frbuf_wr_ptr_q[7:2]) & ~stall_d1_q & (((flit_type[1:0] == 2'b11) & (run_length_q[3:0] != 4'h0)) | (~frbuf_rd_vld_q & (frbuf_rd_ptr_q[1:0] != 2'b00) &
                                                                (~send_idle | (any_fastpath_d0_q & ~send_idle_d0_q)) & ~replay_in_progress_din & ~replay_in_progress_q & ~one_valid_stutter_q & ~force_idle_now_d0_q)) & ~tsm4_q & ~data_stalled_q;     
//--9/14                                                                ~send_idle & ~replay_in_progress_din & ~replay_in_progress_q & ~one_valid_stutter_q & ~force_idle_now_d0_q)) & ~tsm4_q & ~data_stalled_q;     
//--9/11 assign flt_trn_tl_trunc           = (beats_sent_q[7:2] == frbuf_wr_ptr_q[7:2]) & (((flit_type[1:0] == 2'b11) & (run_length_q[3:0] != 4'h0)) | (~frbuf_rd_vld_q & (frbuf_rd_ptr_q[1:0] != 2'b00) &
//--9/12                                                                ~send_idle & ~replay_in_progress_q & ~one_valid_stutter_q & ~force_idle_now_d0_q)) & ~tsm4_q & ~data_stalled_q;     
//--9/6 assign flt_trn_tl_trunc           = (beats_sent_q[7:2] == frbuf_wr_ptr_q[7:2]) & (flit_type[1:0] == 2'b11)  & ~(run_length_q[3:0] == 4'h0) & ~tsm4_q & ~data_stalled_q;      //-- replay_stall
//--9/13
assign flt_trn_tl_trunc           = tl_trunc;
assign truncate_has_occured_din   = (tl_trunc | truncate_has_occured_q) & ~tsm4_q;
assign flt_trn_tl_rl_err          = (run_length_q[3:0] > 4'h8) & ~trn_flt_tsm4;                                                     //-- run length error (from TL bits 67:64)
assign ack_gt_write_din           = tx_ack_ptr_q[7:2]   > frbuf_wr_ptr_q[7:2];
assign ack_ptr_wraps_din          = tx_ack_ptr_din[7:2] < tx_ack_ptr_q[7:2];
assign ack_ptr_err_din            =                                                                                           //-- 3 cases of ack pointer passing write pointer.    
                                    (~ack_gt_write_q & ack_gt_write_din & ~(frbuf_wr_ptr_q[7:2] == 6'b000000)) |              //-- 1) ack < wrt and then ack > write and write didn't wrap
                                    (~ack_gt_write_q & ack_ptr_wraps_q) |                                                     //-- 2) ack < wrt and then ack wraps
                                    ( ack_gt_write_q & ack_ptr_wraps_q & ack_gt_write_din);                                   //-- 3) ack > wrt and then ack wraps and ack > write
assign flt_trn_ack_ptr_err        = ack_ptr_err_q;  
assign flt_trn_in_replay          = replay_in_progress_q;   //-- all beats
assign tl2dl_misc_debug_din[2:0]  = {tl2dl_flit_early_vld, tl2dl_flit_vld, tl2dl_flit_lbip_vld};
assign tl2dl_data_debug_din[95:64] = tl2dl_flit_data[95:64];
assign flt_agn_data_int_din[127:0] = flt_agn_data_int[127:0];

//--10/30  errors to cause machine checks instead of Data issues.
//--11/13
assign flt_trn_reset_hammer   = (reset_crc_hammer &  reg_dl_cya_bits[4])  | (retrain_crc_hammer &  reg_dl_cya_bits[5])  | (reset_pm_hammer & reg_dl_cya_bits[6])  | (retrain_pm_hammer & reg_dl_cya_bits[7]) |
                                                                                     (((nack_pend_q & replay_in_progress_q & (replay_count_q[3:0] == 4'hB)) | second_replay_pend_q) & reg_dl_cya_bits[14]); //-- positive active -- default Inactive
assign flt_trn_retrain_hammer = (reset_crc_hammer & ~reg_dl_cya_bits[10]) | (retrain_crc_hammer & ~reg_dl_cya_bits[11]) |
                                                                                     (((nack_pend_q & replay_in_progress_q & (replay_count_q[3:0] == 4'hB)) | second_replay_pend_q) & ~reg_dl_cya_bits[13]);  //-- both of these are Always Active (reg_dl__bits[10 & 11] are negative active)
//--11/30 assign flt_trn_reset_hammer   = (reset_crc_hammer &  reg_dl_cya_bits[4])  | (retrain_crc_hammer &  reg_dl_cya_bits[5])  | (reset_pm_hammer & reg_dl_cya_bits[6])  | (retrain_pm_hammer & reg_dl_cya_bits[7] ); //-- positive active -- default Inactive
//--11/30 assign flt_trn_retrain_hammer = (reset_crc_hammer & ~reg_dl_cya_bits[10]) | (retrain_crc_hammer & ~reg_dl_cya_bits[11]);  //-- both of these are Always Active (reg_dl__bits[10 & 11] are negative active)

assign reset_crc_hammer       = (rx_tx_crc_error| rx_tx_nack) & reset_occurred_q  ;
assign retrain_crc_hammer     = (rx_tx_crc_error| rx_tx_nack) & retrain_occurred_q;
assign reset_pm_hammer        = trn_flt_send_pm_msg           & reset_occurred_q  ;
assign retrain_pm_hammer      = trn_flt_send_pm_msg           & retrain_occurred_q;

//--11/13 assign assign flt_trn_reset_hammer   = reset_crc_hammer | retrain_crc_hammer | reset_pm_hammer | retrain_pm_hammer;
//--11/13 assign assign reset_crc_hammer       = (rx_tx_crc_error| rx_tx_nack) & reset_occurred_q   & reg_dl__bits[4];
//--11/13 assign assign retrain_crc_hammer     = (rx_tx_crc_error| rx_tx_nack) & retrain_occurred_q & reg_dl__bits[5];
//--11/13 assign assign reset_pm_hammer        = trn_flt_send_pm_msg           & reset_occurred_q   & reg_dl__bits[6];
//--11/13 assign assign retrain_pm_hammer      = trn_flt_send_pm_msg           & retrain_occurred_q & reg_dl__bits[7];

assign frbuf_rd_p40_gt_beats  = (beats_sent_q[7:0] < frbuf_rd_ptr_q[7:0]) ? ({1'b1,beats_sent_q[7:0]} < ({1'b0,frbuf_rd_ptr_q[7:0]} + 9'b001000000)):
                                (beats_sent_q[7:0] > frbuf_rd_ptr_q[7:0]) ? ({1'b0,beats_sent_q[7:0]} < ({1'b0,frbuf_rd_ptr_q[7:0]} + 9'b001000000)):
                                                                            1'b0;
                                 
assign flt_trn_retrain_rply    = (trn_flt_tsm[2:0] == 3'b111) & ~(flit_type_q == 2'b10) &  replay_in_progress_q & frbuf_replay_full_q & frbuf_rd_p40_gt_beats;
assign flt_trn_retrain_no_rply = (trn_flt_tsm[2:0] == 3'b111) & ~(flit_type_q == 2'b10) & ~replay_in_progress_q & frbuf_replay_full_q;
//-- ensure trained and not sending replay flits assign flt_trn_retrain_rply    =   replay_in_progress_q & frbuf_replay_full_q & frbuf_rd_p40_gt_beats;
//-- ensure trained and not sending replay flits assign flt_trn_retrain_no_rply =  ~replay_in_progress_q & frbuf_replay_full_q;

assign retrain_occurred_din         = (((trn_flt_tsm[2:0] == 3'b100) & ~reset_occurred_q) | retrain_occurred_q) & (tx_ack_ptr_q[11:2] == tx_ack_ptr_retrain_q[11:2]);
assign tx_ack_ptr_retrain_din[11:0] = retrain_occurred_din & ~retrain_occurred_q ? tx_ack_ptr_q[11:0]:
                                                                                   tx_ack_ptr_retrain_q[11:0];
//--10/30 end inserted logic

assign flt_trn_dbg_tx_info[87:0]  = dbg_0[87:0] & {88{(trn_flt_macro_dbg_sel[3:0] == 4'b0000)}} |
                                    dbg_1[87:0] & {88{(trn_flt_macro_dbg_sel[3:0] == 4'b0001)}} |
                                    dbg_2[87:0] & {88{(trn_flt_macro_dbg_sel[3:0] == 4'b0010)}} |
                                    dbg_3[87:0] & {88{(trn_flt_macro_dbg_sel[3:0] == 4'b0011)}} |
                                    dbg_4[87:0] & {88{(trn_flt_macro_dbg_sel[3:0] == 4'b0100)}} |
                                    dbg_5[87:0] & {88{(trn_flt_macro_dbg_sel[3:0] == 4'b0101)}} |
                                    dbg_6[87:0] & {88{(trn_flt_macro_dbg_sel[3:0] == 4'b0110)}} |
                                    dbg_7[87:0] & {88{(trn_flt_macro_dbg_sel[3:0] == 4'b0111)}} |
                                    dbg_8[87:0] & {88{(trn_flt_macro_dbg_sel[3:0] == 4'b1000)}} |
                                    dbg_9[87:0] & {88{(trn_flt_macro_dbg_sel[3:0] == 4'b1001)}} |
                                    dbg_A[87:0] & {88{(trn_flt_macro_dbg_sel[3:0] == 4'b1010)}} |
                                    dbg_B[87:0] & {88{(trn_flt_macro_dbg_sel[3:0] == 4'b1011)}} |
                                    dbg_C[87:0] & {88{(trn_flt_macro_dbg_sel[3:0] == 4'b1100)}} |
                                    dbg_D[87:0] & {88{(trn_flt_macro_dbg_sel[3:0] == 4'b1101)}} |
                                    dbg_E[87:0] & {88{(trn_flt_macro_dbg_sel[3:0] == 4'b1110)}} |
                                    dbg_F[87:0] & {88{(trn_flt_macro_dbg_sel[3:0] == 4'b1111)}} ;

//-- TL interface
assign dbg_0[87:0]  = {
                        stall_d3_q                      ,  //-- bit 87
                        tl2dl_flit_vld                  ,  //-- bit 86
                        train_done_q                    ,  //-- bit 85 
                        short_flit_next                 ,  //-- bit 84 
                        fastpath_start                  ,  //-- bit 83 
                        fastpath_end                    ,  //-- bit 82 
                        fastpath_q                      ,  //-- bit 81 
                        delayed_fastpath_q              ,  //-- bit 80 
                        double_delayed_fastpath_q       ,  //-- bit 79 
                        triple_delayed_fastpath_q       ,  //-- bit 78 
                        quad_delayed_fastpath_q         ,  //-- bit 77 
                        slowpath_cnt_q[2:0]             ,  //-- bit 76-74 
                        send_ctl_q                      ,  //-- bit 73
                        beat_q[1:0]                     ,  //-- bit 72-71
                        pre_replay_idle_cnt_q[2:0]      ,  //-- bit 70-68
                        replay_in_progress_q            ,  //-- bit 67  
                        replay_count_q[3:0]             ,  //-- bit 66-63
                        prev_cmd_run_length_q[3:0]      ,  //-- bit 62-59
                        one_valid_stutter_q             ,  //-- bit 58  
                        two_valid_stutter_q             ,  //-- bit 57  
                        frbuf_empty_q                   ,  //-- bit 56  
                        frbuf_wr_en_int                 ,  //-- bit 55  
                        frbuf_wr_ptr_q[7:0]             ,  //-- bit 54-47
                        frbuf_rd_vld_q                  ,  //-- bit 46  
                        frbuf_rd_ptr_q[7:0]             ,  //-- bit 45-38
                        flit_vld                        ,  //-- bit 37 
                        flit_type[1:0]                  ,  //-- bit 36-35
                        run_length_q[3:0]               ,  //-- bit 34-31
                        send_idle_b3                    ,  //-- bit 30   
                        send_ctl_b3                     ,  //-- bit 29   
                        send_replay_b3                  ,  //-- bit 28   
                        nack_q                          ,  //-- bit 27   
                        nack_pend_q                     ,  //-- bit 26   
                        rx_tx_crc_error                 ,  //-- bit 25   
                        rx_ack_ptr_q[8:2]               ,  //-- bit 24-18
                        tx_ack_ptr_q[8:2]               ,  //-- bit 17-11
                        acks_sent_q                     ,  //-- bit 10  
                        frbuf_replay_pointer_q[8:2]     ,  //-- bit 9-3
                        new_flit_sent                   ,  //-- bit 2    
                        give_flit_credit                ,  //-- bit 1    
                        crc_zero_checkbits                 //-- bit 0    
                        };                                  

//-- AGN interface
assign dbg_1[87:0]  = {
                        stall_d3_q                      ,  //-- bit 87
                        real_stall_d3                   ,  //-- bit 86
                        beat_q[1:0]                     ,  //-- bit 85-84
                        send_ctl_b3                     ,  //-- bit 83
                        send_replay_b3                  ,  //-- bit 82
                        send_idle_b3                    ,  //-- bit 81
                        x8_tx_mode_q                    ,  //-- bit 80
                        x4_tx_mode_q                    ,  //-- bit 79
                        x2_tx_mode_q                    ,  //-- bit 78
                        2'b00                           ,  //-- bit 77-76
                        12'h000                         ,  //-- bit 75-64
                        flt_agn_data_int_q[127:64]         //-- bit 63-0                        
                        };                                  
                        
//-- AGN interface
assign dbg_2[87:0]  = {
                        stall_d3_q                      ,  //-- bit 87
                        real_stall_d3                   ,  //-- bit 86
                        beat_q[1:0]                     ,  //-- bit 85-84
                        send_ctl_b3                     ,  //-- bit 83
                        send_replay_b3                  ,  //-- bit 82
                        send_idle_b3                    ,  //-- bit 81
                        x8_tx_mode_q                    ,  //-- bit 80
                        x4_tx_mode_q                    ,  //-- bit 79
                        x2_tx_mode_q                    ,  //-- bit 78
                        2'b00                           ,  //-- bit 77-76
                        12'h000                         ,  //-- bit 75-64
                        flt_agn_data_int_q[63:0]           //-- bit 63-0                        
                        };                                  


//-- pointers
assign dbg_3[87:0]  = {
                        stall_d3_q                      ,  //-- bit 87
                        real_stall_d3                   ,  //-- bit 86
                        beat_q[1:0]                     ,  //-- bit 85-84
                        frbuf_wr_ptr_q[7:0]             ,  //-- bit 83-76
                        frbuf_rd_vld_q                  ,  //-- bit 75
                        frbuf_empty                     ,  //-- bit 74
                        force_idle_now_q                ,  //-- bit 73
                        frbuf_rd_vld_q                  ,  //-- bit 72
                        frbuf_rd_ptr_q[7:0]             ,  //-- bit 71-64
                        frbuf_wr_en_int                 ,  //-- bit 63
                        frbuf_xm1_load                  ,  //-- bit 62
                        tx_ack_ptr_q[13:0]              ,  //-- bit 61-48
                        x8_tx_mode_q                    ,  //-- bit 47
                        x4_tx_mode_q                    ,  //-- bit 46
                        x2_tx_mode_q                    ,  //-- bit 45
                        rx_tx_tx_ack_rtn[4:0]           ,  //-- bit 44-40
                        send_ctl_b3                     ,  //-- bit 39
                        send_replay_b3                  ,  //-- bit 38
                        send_idle_b3                    ,  //-- bit 37
                        rx_tx_tx_ack_ptr_vld            ,  //-- bit 36
                        rx_tx_tx_ack_ptr[11:0]          ,  //-- bit 35-24
                        beats_sent_q[7:0]               ,  //-- bit 23-16
                        frbuf_replay_pointer_q[7:0]     ,  //-- bit 15-7
                        8'h00                              //-- bit 8-0
                        };                                  

//-- fastpath
assign dbg_4[87:0]  = {
                        stall_d3_q                      ,  //-- bit 87
                        real_stall_d3                   ,  //-- bit 86
                        beat_q[1:0]                     ,  //-- bit 85-84
                        short_flit_next                 ,  //-- bit 83 
                        send_idle_next                  ,  //-- bit 82 
                        fastpath_q                      ,  //-- bit 81
                        delayed_fastpath_q              ,  //-- bit 80
                        double_delayed_fastpath_q       ,  //-- bit 79
                        triple_delayed_fastpath_q       ,  //-- bit 78
                        quad_delayed_fastpath_q         ,  //-- bit 77
                        fastpath_start_q                ,  //-- bit 76
                        fastpath_end_q                  ,  //-- bit 75
                        one_valid_stutter_q             ,  //-- bit 74
                        two_valid_stutter_q             ,  //-- bit 73
                        fastpath_start_for_fp_only      ,  //-- bit 72
                        flit_type_q[1:0]                ,  //-- bit 71-70
                        x8_tx_mode_q                    ,  //-- bit 69
                        x4_tx_mode_q                    ,  //-- bit 68
                        x2_tx_mode_q                    ,  //-- bit 67
                        fp_frbuf_empty_q                ,  //-- bit 66
                        force_idle_now_q                ,  //-- bit 65
                        force_idle_hold                 ,  //-- bit 64
                        rd_catching_wr                  ,  //-- bit 63
                        replay_b2_d0_q                  ,  //-- bit 62
                        init_replay_done_q              ,  //-- bit 61
                        1'b0                            ,  //-- bit 60
                        60'h000000000000000                //-- bit 59-0
                        };                                  

assign dbg_5[87:0]  = {
                        tl2dl_misc_debug_q[2:0]         ,  //-- bit 87-85       tl2dl_flit_early_vld, tl2dl_flit_vld, tl2dl_flit_lbip_vld
                        give_flit_credit                ,  //-- bit 84
                        x8_tx_mode_q                    ,  //-- bit 83
                        x4_tx_mode_q                    ,  //-- bit 82
                        x2_tx_mode_q                    ,  //-- bit 81
                        link_up_q                       ,  //-- bit 80
                        16'h0000                        ,  //-- bit 79-64
                        16'h0000                        ,  //-- bit 63-48
                        16'h0000                        ,  //-- bit 47-32
                        tl2dl_data_debug_q[95:64]          //-- bit 31-0   tl2dl_flit_data[95:64]
                        };                                  
                        
assign dbg_6[87:0] = 88'h0000000000000000000000;                                
assign dbg_7[87:0] = 88'h0000000000000000000000;                                
assign dbg_8[87:0] = 88'h0000000000000000000000;                                
assign dbg_9[87:0] = 88'h0000000000000000000000;                                
assign dbg_A[87:0] = 88'h0000000000000000000000;                                
assign dbg_B[87:0] = 88'h0000000000000000000000;                                
assign dbg_C[87:0] = 88'h0000000000000000000000;                                
assign dbg_D[87:0] = 88'h0000000000000000000000;                                
assign dbg_E[87:0] = 88'h0000000000000000000000;                                
assign dbg_F[87:0] = 88'h0000000000000000000000;                                
                                    
endmodule  //-- dlc_omi_tx_flit     
                                    


