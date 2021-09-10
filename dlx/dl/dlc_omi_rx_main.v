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
module dlc_omi_rx_main (


  agn_mn_flit                    //--  input [127:0]
 ,agn_mn_flit_vld                //--  input
 ,ln_all_valid                   //-- input 
 ,agn_mn_flit_pty                //-- input [15:0]
 ,trn_mn_retrain                 //--  input   
 ,trn_mn_trained                 //--  input   
 ,trn_mn_short_idle_enable       //--  input
//-- outputs to the TL            
 ,dl2tl_flit_vld                //--  output
 ,dl2tl_flit_error              //--  output
 ,dl2tl_flit_data               //--  output  [127:0]
 ,dl2tl_flit_pty                //--  output  [15:0]
 ,dl2tl_idle_transition         //--  output
 ,dl2tl_idle_transition_l       //--  output
 ,dl2tl_idle_transition_r       //--  output
 ,dl2tl_flit_badcrc             //--  output 
 ,dl2tl_flit_act                //--  output
//-- signals between the RX and TX
 ,rx_reset_n                    //--  input
 ,chip_reset                    //--  Input
 ,global_reset_control          //--  Input
 ,omi_enable			//--  input
 ,rx_tx_crc_error               //--  output
 ,rx_tx_nack                    //--  output  
 
 ,rx_tx_rx_ack_inc              //--  output  
 ,rx_tx_tx_ack_rtn              //--  output  [4:0]
 ,rx_tx_tx_ack_ptr_vld          //--  output
 ,rx_tx_tx_ack_ptr              //--  output  [11:0]

 ,rx_tx_rmt_error               //--  output  [7:0]
 ,rx_tx_rmt_message             //--  output  [63:0]
 ,rx_tx_recal_status            //--  output [1:0]      //--  new ports for power management
 ,rx_tx_pm_status               //--  output [3:0]      //--  new ports for power management
 ,dl_clk                        //--  input
//--Error/Performance Monitor 
,rx_tx_mn_trn_in_replay         //-- output
,rx_tx_data_flt                 //-- output
,rx_tx_ctl_flt                  //-- output
,rx_tx_rpl_flt                  //-- output
,rx_tx_idle_flt                 //-- output 
,rx_tx_ill_rl                   //-- output 
,rx_tx_dbg_rx_info              //-- output [87:0]
,tx_rx_tsm                      //-- input [2:0]
,tx_rx_macro_dbg_sel            //-- input [3:0]
,agn_mn_x2_mode                 //-- input [1:0]
,agn_mn_x4_mode                 //-- input [1:0]
,agn_mn_ln_swap                 //-- input 
,mn_agn_dead_cycle_reset        //-- output 
);


input  [127:0]  agn_mn_flit;
input           agn_mn_flit_vld;
input           ln_all_valid;
input  [15:0]   agn_mn_flit_pty;
input           trn_mn_retrain;
input           trn_mn_trained;
input           trn_mn_short_idle_enable;
output          dl2tl_flit_vld;
output          dl2tl_flit_error;
output [127:0]  dl2tl_flit_data;
output [15:0]   dl2tl_flit_pty;
output          dl2tl_idle_transition;
output          dl2tl_idle_transition_l;
output          dl2tl_idle_transition_r;
output          dl2tl_flit_badcrc;
output          dl2tl_flit_act;
input           rx_reset_n;
input           chip_reset;
input           global_reset_control;
input 		omi_enable;
output          rx_tx_crc_error;
output          rx_tx_nack;
output [3:0]    rx_tx_rx_ack_inc;
output [4:0]    rx_tx_tx_ack_rtn;
output          rx_tx_tx_ack_ptr_vld;
//-- 8/21 output [6:0]    rx_tx_tx_ack_ptr;
output [11:0]   rx_tx_tx_ack_ptr;
output [7:0]    rx_tx_rmt_error;
output [63:0]   rx_tx_rmt_message;
output [1:0]    rx_tx_recal_status;
output [3:0]    rx_tx_pm_status;
input [2:0]     tx_rx_tsm;
input [3:0]     tx_rx_macro_dbg_sel; 
input           dl_clk;
output          rx_tx_mn_trn_in_replay;
output          rx_tx_data_flt;
output          rx_tx_ctl_flt;
output          rx_tx_rpl_flt;
output          rx_tx_idle_flt;
output          rx_tx_ill_rl;
output [87:0]   rx_tx_dbg_rx_info;

input  [1:0]    agn_mn_x2_mode;          
input  [1:0]    agn_mn_x4_mode;       
input           agn_mn_ln_swap;             
output          mn_agn_dead_cycle_reset;
//Signal Declarations
//Sim Only Signals for Receiving illegal run length
wire            sim_only_rl_fail;
wire [7:0]      sim_only_run_length;

//Signals used in Fast Act Path
wire [4:0]      ln_all_valid_cnt_din;           
wire [4:0]      ln_all_valid_cnt_q;
wire            dl2tl_idle_transition_din;
wire            dl2tl_idle_transition_q;
wire            dl2tl_idle_transition_l_din;
wire            dl2tl_idle_transition_l_q;
wire            dl2tl_idle_transition_r_din;
wire            dl2tl_idle_transition_r_q;
wire            dl2tl_idle_transition_trace_din;
wire            dl2tl_idle_transition_trace_q;
wire            dl2tl_idle_transition_int_din;
wire            dl2tl_idle_transition_int_q;
wire            dl2tl_idle_transition_l_int_din;
wire            dl2tl_idle_transition_l_int_q;
wire            dl2tl_idle_transition_r_int_din;
wire            dl2tl_idle_transition_r_int_q;
wire            dead_cycle;
wire [7:0]      rx_run_length;
wire            turn_off_valid_ill_rl_din;
wire            turn_off_valid_ill_rl_q;
wire            ill_rl_idle_replay;
wire            ill_rl_cntl;
wire            rx_tx_ctl_flt_int;
wire            rx_tx_rpl_flt_int;
wire            rx_tx_idle_flt_int;
wire            dl2tl_flit_badcrc_int;
wire            initial_imitation_data;
wire [3:0]      good_flits_rcvd_din;
wire [3:0]      good_flits_rcvd_q;
wire            retrain_clear;
wire            omi_enable_din;
wire            omi_enable_q;
wire [127:0]    partial_flit;
wire [127:0]    partial_flit_din;
wire [127:0]    partial_flit_q;
wire [127:0]    partial_flit_out;
wire            flit_vld_int;
//-- 8/16 wire            long_idle_stall_din;
//-- 8/16 wire            long_idle_stall_q;
//-- 8/16 wire            turn_on_long_idle_stall;
//-- 8/16 wire            turn_off_long_idle_stall;
wire            flit_error_int;
wire            flit_error_int_din;
wire            flit_error_int_q;
wire            flit_vld_int_din;
wire            flit_vld_int_q;
//-- 8/21 wire [6:0]      ptr_chk;
wire [11:0]     ptr_chk;
//SIM only to turn on/off inserting 0s on Control flit
wire            turn_on_cntl_zeros; 
//Delayed Training Signal Wires
wire            trn_dly1_din;
wire            trn_dly1_q;
wire            trn_dly2_din;
wire            trn_dly2_q;
wire            trn_dly3_din;
wire            trn_dly3_q;
//Latch enable signals for clock gating
wire            cg_ena;
wire            cg_ena_trn;
wire            cg_short_idle_ena;
wire            reset;
wire            rx_reset_n_din;
wire            rx_reset_n_q;

//Replay Signals
wire            replay_ip_din;
wire            replay_ip_q;
wire            replay_ip_dly_din;
wire            replay_ip_dly_q;
wire            replay_ip_dly2_din;
wire            replay_ip_dly2_q;
wire            replay_ip_turn_off_vld;
wire            replay_idles_seen_din;
wire            replay_idles_seen_q;
wire            seen_first_replay;
wire            replay_pending_din;
wire            initial_replay_done_din;
wire            initial_replay_done_q;
wire            replay_pending_q;
wire            replay_flit_crc_error_din;
wire            replay_flit_crc_error_q;

wire            initial_replay_ip_din;
wire            initial_replay_ip_q;
wire            initial_replay_pending_din;
wire            initial_replay_pending_q;
wire            initial_replay;
wire            imitation_data;
wire            imitation_data_din;
wire            imitation_data_q;
//CRC Signals 
wire [35:0]     crc_bits_out; 
wire [35:0]     crc_bits_din;
wire [35:0]     crc_bits_q; 
wire            crc_nonzero;
wire            crc_nonzero_din;
wire            crc_nonzero_q;
wire            crc_init_din;
wire            crc_init_q;
//Identifying Flit types
wire            is_cntl;
wire            is_replay;
wire            is_idle_64;
wire            is_idle_16;

wire            is_idle_16_dly_din;
wire            is_idle_16_dly_q;
wire            is_cntl_dly_din;
wire            is_cntl_dly_q;
wire            is_replay_dly_din;
wire            is_replay_dly_q;
wire            is_idle_64_dly_din;
wire            is_idle_64_dly_q;
wire            next_idle16_din;
wire            next_idle16_q;
wire            stalled;
wire            stalled_din;
wire            stalled_q;

//Internal Valid Signals
wire            total_valid; //used for all logic, in x4 mode only goes high on odd beats (meaning full 16byte partial flit is available)
wire            total_valid_din;
wire            total_valid_q;
wire            total_valid2_din;
wire            total_valid2_q;
wire [15:0]     partial_flit_pty; //stores parity data 
wire [15:0]     partial_flit_pty_din; //stores parity data 
wire [15:0]     partial_flit_pty_q; //stores parity data 
//Counters Signals
wire [1:0]      partial_flit_cnt_din; //Number of partial flits received (counts down from 3). Idle flit is 1 partial flit, Data/cntl/replay are 4 partial flits
wire [1:0]      partial_flit_cnt_q;
wire            flit_cnt_enable;
wire            flit_cnt_enable_din;
wire            flit_cnt_enable_q;
wire            partial_flit_enable;
wire            partial_flit_enable_din;
wire            partial_flit_enable_q;
wire [3:0]      flit_cnt_din; //Used for data flits, counts down to determine when next control flit is coming
wire [3:0]      flit_cnt_q;
wire [3:0]      replay_flit_cnt_din; //Counts the number of replay flits seen 
wire [3:0]      replay_flit_cnt_q;
wire            replay_flit_cnt_enable;
wire            replay_flit_cnt_enable_din;
wire            replay_flit_cnt_enable_q;
wire [3:0]      ack_cnt_din;
wire [3:0]      ack_cnt_q;
wire [3:0]      good_flits_rcvd;
wire [3:0]      tx_ack_inc;
//Latch signals for tx outputs
wire            rx_tx_crc_error_din;
wire            rx_tx_crc_error_q;
wire            rx_tx_crc_error_dly_din;
wire            rx_tx_crc_error_dly_q;
wire            crc_error_replay_din;
wire            crc_error_replay_q;
wire            rx_tx_nack_din;
wire            rx_tx_nack_q;
wire [3:0]      rx_tx_rx_ack_inc_din;
wire [3:0]      rx_tx_rx_ack_inc_q;
wire [4:0]      rx_tx_tx_ack_rtn_din;
wire [4:0]      rx_tx_tx_ack_rtn_q;
wire            rx_tx_tx_ack_ptr_vld_din;
wire            rx_tx_tx_ack_ptr_vld_q;
//-- 8/21 wire [6:0]      rx_tx_tx_ack_ptr_din;
//-- 8/21 wire [6:0]      rx_tx_tx_ack_ptr_q;
wire [11:0]     rx_tx_tx_ack_ptr_din;
wire [11:0]     rx_tx_tx_ack_ptr_q;
wire [7:0]      rx_tx_rmt_error_din;
wire [7:0]      rx_tx_rmt_error_q;  
wire [7:0]      rx_tx_rmt_error_dly_din;
wire [7:0]      rx_tx_rmt_error_dly_q;  
wire [63:0]     rx_tx_rmt_message_din;
wire [63:0]     rx_tx_rmt_message_q;
wire [63:0]     rx_tx_rmt_message_dly_din;
wire [63:0]     rx_tx_rmt_message_dly_q;
wire [31:0]     third_beat_replay_msg_din;
wire [31:0]     third_beat_replay_msg_q;
//-- 8/21 wire [6:0]      rx_curr_ptr_din;
//-- 8/21 wire [6:0]      rx_curr_ptr_q;
//-- 8/21 wire [6:0]      rx_ack_ptr_din;
//-- 8/21 wire [6:0]      rx_ack_ptr_q;
wire [11:0]    rx_curr_ptr_din;
wire [11:0]    rx_curr_ptr_q;
wire [11:0]    rx_ack_ptr_din;
wire [11:0]    rx_ack_ptr_q;

wire [3:0]     possible_ptr_din;
wire [3:0]     possible_ptr_q; 
wire           replay_duplicate_turn_on_din; 
wire           replay_duplicate_turn_on_q; 
wire           replay_duplicates_din;
wire           replay_duplicates_q;
wire           replay_duplicates2_din;
wire           replay_duplicates2_q;
wire           replay_duplicates3_din;
wire           replay_duplicates3_q;
//Latch Signals for Performance Counters/Error Signals
wire           rx_tx_mn_trn_in_replay_din;
wire           rx_tx_mn_trn_in_replay_q;
wire           rx_tx_data_flt_din;
wire           rx_tx_data_flt_q;
wire           rx_tx_ill_rl_din;
wire           rx_tx_ill_rl_q;
wire           rx_tx_ill_rl_dly_din;
wire           rx_tx_ill_rl_dly_q;

wire [1:0] agn_mn_x2_mode_din;
wire [1:0] agn_mn_x2_mode_q;
wire [1:0] agn_mn_x4_mode_din;
wire [1:0] agn_mn_x4_mode_q;
wire agn_mn_ln_swap_din;
wire agn_mn_ln_swap_q;
wire       four_cycle;
wire       four_cycle_start;
wire [2:0] four_cycle_cnt_din;
wire [2:0] four_cycle_cnt_q;
wire is_replay_perf_mon_din;
wire is_replay_perf_mon_q;
wire is_cntl_perf_mon_din;
wire is_cntl_perf_mon_q;
wire is_idle_64_perf_mon_din;
wire is_idle_64_perf_mon_q;
wire is_idle_16_perf_mon_din;
wire is_idle_16_perf_mon_q;

wire idle_16_now_din;
wire idle_16_now_q;
wire short_idle_enable_din;
wire short_idle_enable_q;
wire early_replay_run_length;
//Wires for clock gating to TL
wire is_cntl_replay_or_idle_now;
wire dl2tl_flit_act_din;
wire dl2tl_flit_act_q;
wire dl2tl_flit_act_int;
wire replay_turn_on_valid;

//Scan only Latch to keep tl2dl_flit_act high if needed
wire            dl2tl_flit_act_scan_din;
wire            dl2tl_flit_act_scan_q;

//Power Management signals
wire [1:0] rx_tx_recal_status_din;
wire [1:0] rx_tx_recal_status_q;
wire [3:0] rx_tx_pm_status_din;
wire [3:0] rx_tx_pm_status_q;
wire [3:0] pm_status_now;
wire [3:0] pm_status_trace;
wire       start_dead_cycle;
wire       turn_off_vld_dead_cycle;
wire       turn_off_vld_dead_cycle_dly_din;
wire       turn_off_vld_dead_cycle_dly_q;
wire       turn_off_vld_dead_cycle_dly2_din;
wire       turn_off_vld_dead_cycle_dly2_q;
wire [3:0] dead_cycle_cnt_din;
wire [3:0] dead_cycle_cnt_q;
wire       dead_cycle_finished;
wire       dead_cycle_crc_error;
wire       mode_x8;
wire       mode_x4;
wire       mode_x2;
//Debug Buses
wire [87:0] dbg_0;
wire [87:0] dbg_1;
wire [87:0] dbg_2;
wire [87:0] dbg_3;
wire [87:0] dbg_4;
wire [87:0] dbg_5;
wire [87:0] dbg_6;
wire [87:0] dbg_7;
wire [87:0] dbg_8;
wire [87:0] dbg_9;
wire [87:0] dbg_A;
wire [87:0] dbg_B;
wire [87:0] dbg_C;
wire [87:0] dbg_D;
wire [87:0] dbg_E;
wire [87:0] dbg_F;

//Spare Latches
wire  spare00_din;
wire  spare00_q;
wire  spare01_din;
wire  spare01_q;
wire  spare02_din;
wire  spare02_q;
wire  spare03_din;
wire  spare03_q;
wire  spare04_din;
wire  spare04_q;
wire  spare05_din;
wire  spare05_q;
wire  spare06_din;
wire  spare06_q;
wire  spare07_din;
wire  spare07_q;
wire  spare08_din;
wire  spare08_q;
wire  spare09_din;
wire  spare09_q;
wire  spare10_din;
wire  spare10_q;
wire  spare11_din;
wire  spare11_q;
wire  spare12_din;
wire  spare12_q;
wire  spare13_din;
wire  spare13_q;
wire  spare14_din;
wire  spare14_q;
wire  spare15_din;
wire  spare15_q;
wire  spare16_din;
wire  spare16_q;
wire  spare17_din;
wire  spare17_q;
wire  spare18_din;
wire  spare18_q;
wire  spare19_din;
wire  spare19_q;

//Assigning spares to random value so synthesis places close
assign spare00_din        = |tx_rx_tsm[2:0];                       //Unused
assign spare01_din        = spare00_q;         //Unused
assign spare02_din        = spare01_q;         //Unused
assign spare03_din        = spare02_q;         //Unused
assign spare04_din        = spare03_q;         //Unused
assign spare05_din        = spare04_q;         //Unused
assign spare06_din        = spare05_q;         //Unused
assign spare07_din        = spare06_q;         //Unused
assign spare08_din        = spare07_q;         //Unused
assign spare09_din        = spare08_q;         //Unused
assign spare10_din        = spare09_q;         //Unused
assign spare11_din        = spare10_q;         //Unused
assign spare12_din        = spare11_q;         //Unused
assign spare13_din        = spare12_q;                //Unused
assign spare14_din        = spare13_q;            //Unused
assign spare15_din        = spare14_q;         //Unused
assign spare16_din        = spare15_q;        //Unused
assign spare17_din        = spare16_q;        //Unused
assign spare18_din        = spare17_q;        //Unused
assign spare19_din        = spare18_q;        //Unused

//Latch Reset
assign rx_reset_n_din = rx_reset_n;

//Counter for dead cycle for microsemi timing test 2/15
assign ln_all_valid_cnt_din[4:0] = ~ln_all_valid ? 5'b00000 :
				   ln_all_valid_cnt_q[4:0] + 5'b00001; 

assign dead_cycle = ln_all_valid_cnt_q[4:0] ==  5'b11111;



//Latch short idle enable
assign short_idle_enable_din = trn_mn_short_idle_enable;
//Override in Diver to turn on muxing on DL2TL Path (for zeroing out control flit)
assign turn_on_cntl_zeros = 1'b0;

//Override to inject illegal run length error
assign sim_only_rl_fail = 1'b0;
assign sim_only_run_length[7:0] = 8'b00000000;

//Save run length for ill_rl check
assign rx_run_length[7:0] = sim_only_rl_fail ? sim_only_run_length[7:0] : partial_flit_q[71:64];

//Valid signal (Partial flit is parsed 1 cycle late, so delayed valid needed)
assign total_valid     = agn_mn_flit_vld;
//-- 7/19 assign total_valid_din = total_valid & dead_cycle_cnt_q[3:0] != 4'b1000;
assign total_valid_din = total_valid & ~dead_cycle_finished;
assign total_valid2_din = total_valid_q;
//Latch partial flit for parsing
assign partial_flit[127:0] = agn_mn_flit[127:0];
assign partial_flit_din[127:0] =  partial_flit[127:0];


//Identify 16 byte idles (in replay pending need to look at run length, since can't trust other data before the idles (to see bit 82) 
 assign is_idle_16 = (~short_idle_enable_q | turn_off_vld_dead_cycle_dly_q)? 1'b0 :
                     replay_pending_q     ? total_valid_q & partial_flit_q[67:64] == 4'b1111 & partial_flit_cnt_q[1:0] == 2'b00 & ~replay_idles_seen_q:
                                            ~initial_replay_pending_q & total_valid_q & next_idle16_q;


//12/20  assign idle_16_now_din = (~total_valid & idle_16_now_q) | (total_valid & ((idle_16_now_q | partial_flit_cnt_din[1:0] == 2'b11) & flit_cnt_q[3:0] == 4'b0000) & partial_flit[82]); 
//-- 7/19 assign idle_16_now_din = ~initial_replay_pending_q & short_idle_enable_q & ((~total_valid & idle_16_now_q & ~retrain_clear) | (total_valid & ((idle_16_now_q | partial_flit_cnt_din[1:0] == 2'b11) & flit_cnt_q[3:0] == 4'b0000) & partial_flit[82]) | dead_cycle_cnt_q[3:0] == 4'b1000); 
assign idle_16_now_din = ~initial_replay_pending_q & short_idle_enable_q & ((~total_valid & idle_16_now_q & ~retrain_clear) | (total_valid & ((idle_16_now_q | partial_flit_cnt_din[1:0] == 2'b11) & flit_cnt_q[3:0] == 4'b0000) & partial_flit[82]) | dead_cycle_finished); 
//Turn on partial flit counter if not a 16 byte idle flit 
assign partial_flit_enable = ~short_idle_enable_q                                ?  total_valid_q :
                             (~(replay_pending_din | replay_pending_q) | replay_ip_q) ? ~is_idle_16 & total_valid_q :
			                                                                total_valid_q & replay_idles_seen_q;

//Latch signal for trace array
assign partial_flit_enable_din = partial_flit_enable;
//Partial Flit counter, if 16 byte idle stay at 3, for all other flits count down to
//0, then roll back over to 3, if x4 mode, only updates on odd beats
assign partial_flit_cnt_din[1:0] = (~trn_mn_trained | is_idle_16 | ((short_idle_enable_q & replay_pending_q) & ~(replay_ip_q | replay_idles_seen_q)) | turn_off_vld_dead_cycle)      ? 2'b00 :          //If 16 byte idle, keep at 3
                                   partial_flit_enable                                                                                        ? (partial_flit_cnt_q[1:0] + 2'b01) : partial_flit_cnt_q[1:0];  //if enabled decrement 1, or hold value

//determines what type of 64 byte flit we are seeingi by looking at run length, only able to tell in 4th partial
//flit 
assign is_cntl    = ~initial_replay_pending_q & total_valid_q  & (partial_flit_cnt_q[1:0] == 2'b11) & (flit_cnt_q[3:0] == 4'b0000) & ((partial_flit_q[67] != 1'b1) | (partial_flit_q[67:64] ==  4'b1000)); //Check that it is 4th partial flit, valid data run length, and data counter == 0 (know that it is not a data flit)
assign is_replay  = total_valid_q  & (partial_flit_cnt_q[1:0] == 2'b11) & (partial_flit_q[67:64] == 4'b1010) & (flit_cnt_q[3:0] == 4'b0000);                    //Check run length and that it is 4th partial flit
assign is_idle_64 = ~initial_replay_pending_q & total_valid_q  & (partial_flit_cnt_q[1:0] == 2'b11) & (partial_flit_q[67:64] == 4'b1111) & (flit_cnt_q[3:0] == 4'b0000);                      //Check run length and that it is 4th partial flit 


// 11/1 Delayed Flit ID Signals to fix timing
assign is_cntl_dly_din    = is_cntl    ;
assign is_replay_dly_din  = is_replay  ;
assign is_idle_64_dly_din = is_idle_64 ;
assign is_idle_16_dly_din = is_idle_16;


//checks dl_content for short_flit_next to determine if next flit is 16byte
//idle
// 12/20assign next_idle16_din = ((is_idle_16 | is_idle_64 | is_cntl | is_replay) & partial_flit_q[82]) | (~total_valid_q & next_idle16_q); 
// 7/19 assign next_idle16_din = short_idle_enable_q & (((is_idle_16 | is_idle_64 | is_cntl | is_replay) & partial_flit_q[82]) | (~total_valid_q & next_idle16_q & ~retrain_clear) | dead_cycle_cnt_q[3:0] == 4'b1000); 
// 10/24 assign next_idle16_din = short_idle_enable_q & (((is_idle_16 | is_idle_64 | is_cntl | is_replay) & partial_flit_q[82]) | (~total_valid_q & next_idle16_q & ~retrain_clear) | dead_cycle_finished); 
assign next_idle16_din = short_idle_enable_q & (((is_idle_16 | is_idle_64 | is_cntl | (((initial_replay & replay_flit_cnt_q[3:0] == 4'b0111) | (crc_error_replay_q & replay_flit_cnt_q[3:0]==4'b1000) | (~initial_replay & ~crc_error_replay_q)) & is_replay)) & partial_flit_q[82]) | (~total_valid_q & next_idle16_q & ~retrain_clear) | dead_cycle_finished); 

//Parses stalled bit inside dl content
assign stalled = (is_idle_16 | is_cntl | is_replay | is_idle_64) & partial_flit_q[83];


//Turn off Valid on long idle stalls 

//-- 8/16 assign turn_on_long_idle_stall = total_valid & ~short_idle_enable_q & partial_flit[83] & partial_flit_cnt_din[1:0] == 2'b11 & flit_cnt_q[3:0] == 4'b0000;
//-- 8.16 assign turn_off_long_idle_stall = total_valid & partial_flit_cnt_din[1:0] == 2'b11 & flit_cnt_q[3:0] == 4'b0000 & partial_flit[67:64]==4'b1111 & partial_flit[83];

//-- 8/15 assign long_idle_stall_din = turn_on_long_idle_stall & ~turn_off_long_idle_stall; 
//-- 8/ 16 assign long_idle_stall_din = turn_on_long_idle_stall | (long_idle_stall_q & ~turn_off_long_idle_stall); 
//For debug bus
assign stalled_din = stalled; 


assign flit_cnt_enable = ~is_cntl & ~is_idle_64 & total_valid_q & partial_flit_cnt_q[1:0] == 2'b11 & ~stalled & ~is_replay; //data flit counter enable, high if 

//For debug bus
assign flit_cnt_enable_din = flit_cnt_enable;
//Data flit counter
// 12/12assign flit_cnt_din[3:0] =  (~partial_flit_q[82] & ~crc_nonzero_din & (((is_idle_16 | is_idle_64) & stalled) | (replay_flit_cnt_q[3:0]==4'b1000 & is_replay & ~stalled)))     ? partial_flit_q[71:68]         : //Coming out of stall condition with vall stalled run length
// 12/12                            (is_cntl & ~stalled & ~partial_flit_q[82] & ~crc_nonzero_din)                                                                                     ? partial_flit_q[67:64]         : //cntl flit contains number of data flits until next cntl flit
// 12/12                            flit_cnt_enable                                                                                                                                   ? (flit_cnt_q[3:0] - 4'b0001)   : //decrement by 1
// 12/12                            replay_pending_q                                                                                                                                  ? 4'b000                        : 

assign flit_cnt_din[3:0] =  (~partial_flit_q[82] & ~crc_nonzero_din & ((is_idle_16 | is_idle_64) | (~stalled & ((initial_replay & replay_flit_cnt_q[3:0] == 4'b0111) | (crc_error_replay_q & replay_flit_cnt_q[3:0]==4'b1000) | (~initial_replay & ~crc_error_replay_q)) & is_replay)))     ? partial_flit_q[71:68]         : //--Coming out of stall condition with vall stalled run length
                            (is_cntl & ~stalled & ~crc_nonzero_din & ~partial_flit_q[82])                                                                                     ? partial_flit_q[67:64]         : //--cntl flit contains number of data flits until next cntl flit
                            flit_cnt_enable                                                                                                             ? (flit_cnt_q[3:0] - 4'b0001)   : //--decrement by 1
                            replay_pending_q | retrain_clear                                                                                            ? 4'b0000                       : 
                                                                                                                                                          flit_cnt_q; //--hold value 


assign ack_cnt_din[3:0] = ~stalled & is_cntl & ~partial_flit_q[82]                                                            ? partial_flit_q[67:64] : 
                         is_cntl & ~stalled & partial_flit_q[82]                                                              ? 4'b000 :
                         (~partial_flit_q[82] & (is_idle_16 | is_idle_64)) | (~stalled & is_replay & ((initial_replay & replay_flit_cnt_q[3:0] == 4'b0111) | (crc_error_replay_q & replay_flit_cnt_q[3:0]==4'b1000) | (~initial_replay & ~crc_error_replay_q)))      ? partial_flit_q[71:68] :
                                                                                                                                   ack_cnt_q[3:0];

assign possible_ptr_din[3:0] =  (~partial_flit_q[82] & ~crc_nonzero_din & ((is_idle_16 | is_idle_64) | (~stalled & ((initial_replay & replay_flit_cnt_q[3:0] ==4'b0111) | (crc_error_replay_q & replay_flit_cnt_q[3:0]==4'b1000) | (~initial_replay & ~crc_error_replay_q)) & is_replay)))     ? partial_flit_q[71:68] + 4'b0001         : //Coming out of stall condition with vall stalled run length
                                (is_cntl & ~stalled & ~crc_nonzero_din & ~partial_flit_q[82])                                                                                                                                                                                               ? partial_flit_q[67:64] + 4'b0001         : //cntl flit contains number of data flits until next cntl flit
                            		                                                                                                                                                                                                                                                      possible_ptr_q[3:0];

// 1/17 timing assign good_flits_rcvd[3:0] = (is_cntl & ~crc_nonzero_din & ~replay_pending_q & ~trn_mn_retrain) ? (ack_cnt_q[3:0] + 4'b0001) :             //When new control flit, increment 1 (to account for control flit)
//                                       4'b0000;

assign good_flits_rcvd[3:0] = (is_cntl & ~replay_pending_q & ~trn_mn_retrain) ? (ack_cnt_q[3:0] + 4'b0001) :             //When new control flit, increment 1 (to account for control flit)
                                       4'b0000;
assign good_flits_rcvd_din[3:0] = good_flits_rcvd;
//If not a replay, load ack count for current frame and send to tx 
// 1/17 timing fix assign tx_ack_inc[3:0] = (~(replay_duplicates_q | replay_pending_q | replay_duplicates2_q | replay_ip_q) & total_valid_q & ~crc_nonzero_q)  ?  good_flits_rcvd[3:0] :
//                                                                                 4'b0000;

assign tx_ack_inc[3:0] = (~(replay_duplicates2_q | replay_duplicates_q | replay_pending_q | replay_ip_q | replay_duplicates3_q) & total_valid2_q & ~crc_nonzero_q)  ?  good_flits_rcvd_q[3:0] :
                                                                                 4'b0000;

assign rx_tx_rx_ack_inc_din[3:0] = tx_ack_inc;


//assign rx_tx_rx_ack_inc_din[3:0] = is_cntl ? ack_cnt_q[3:0] : 4'b0000;
//Gives last known good ack count, compared against during replay to avoid
//duplicate flits
//-- 8/21 assign rx_ack_ptr_din[6:0] = rx_ack_ptr_q[6:0] + {3'b0, tx_ack_inc[3:0]};
assign rx_ack_ptr_din[11:0] = rx_ack_ptr_q[11:0] + {8'h00, tx_ack_inc[3:0]};
//--assign rx_curr_ptr_din[6:0] = (is_replay & ((initial_replay_ip_q & replay_flit_cnt_q[3:0] == 4'b0111) | replay_flit_cnt_q[3:0] == 1'b1000))   ? partial_flit_q[54:48]  :           //If replay flit, take starting sequence number
//--                                            (rx_curr_ptr_q[6:0] + {3'b0, good_flits_rcvd[3:0]}); //Otherwise accumulate  acks
      
// 1/17 timing assign rx_curr_ptr_din[6:0] = (is_replay & ((initial_replay_ip_q & replay_flit_cnt_q[3:0] == 4'b0111) | (replay_flit_cnt_q[3:1] == 3'b100 & crc_error_replay_q) | ~crc_error_replay_q))   ? partial_flit_q[54:48]  :           //If replay flit, take starting sequence number
//                                            (rx_curr_ptr_q[6:0] + {3'b0, good_flits_rcvd[3:0]}); //Otherwise accumulate  acks
      
// 7/12 assign rx_curr_ptr_din[6:0] = (is_replay & ((initial_replay & replay_flit_cnt_q[3:0] == 4'b0111) | (replay_flit_cnt_q[3:1] == 3'b100 & crc_error_replay_q) | (~initial_replay & ~crc_error_replay_q)))   ? partial_flit_q[54:48]  :           //If replay flit, take starting sequence number
//-- 8/21 assign rx_curr_ptr_din[6:0] = (~crc_nonzero_din & is_replay & ((initial_replay & replay_flit_cnt_q[3:0] == 4'b0111) | (replay_flit_cnt_q[3:1] == 3'b100 & crc_error_replay_q) | (~initial_replay & ~crc_error_replay_q)))   ? partial_flit_q[54:48]  :           //If replay flit, take starting sequence number
//-- 8/21                              ~crc_nonzero_q                                                                                                                                              ?              (rx_curr_ptr_q[6:0] + {3'b0, good_flits_rcvd_q[3:0]}) :
//-- 8/21			      rx_curr_ptr_q[6:0];//Otherwise accumulate  acks

assign rx_curr_ptr_din[11:0] = (~crc_nonzero_din & is_replay & ((initial_replay & replay_flit_cnt_q[3:0] == 4'b0111) | (replay_flit_cnt_q[3:1] == 3'b100 & crc_error_replay_q) | (~initial_replay & ~crc_error_replay_q)))   ? partial_flit_q[59:48]  :           //If replay flit, take starting sequence number
                               ~crc_nonzero_q                                                                                                                                                                                ? (rx_curr_ptr_q[11:0] + {8'h00, good_flits_rcvd_q[3:0]}) :
			       rx_curr_ptr_q[11:0];//Otherwise accumulate  acks

        
//----------------Replay Handling-------------------------- 
//Initial Replay flit handling (first 9 after training)

assign initial_replay_pending_din = ~replay_pending_q & ((~trn_dly3_q & trn_dly3_din) | (initial_replay_pending_q & ~total_valid_q) | (initial_replay_pending_q & ~(seen_first_replay | (is_replay & crc_nonzero_din))));// | (initial_replay_ip_q & (crc_init_q & crc_nonzero_q)); 


// 11/28 assign initial_replay_ip_din = (initial_replay_ip_q & ~total_valid_q) | (initial_replay_pending_q & is_replay) | (initial_replay_ip_q & ~((replay_flit_cnt_q[3:0] == 4'b0111) & is_replay)); // Timing Fix 9/28
assign initial_replay_ip_din = ~(initial_replay_ip_q & crc_nonzero_q & crc_init_q) & ~replay_duplicates_q & ((replay_flit_cnt_q[3:0] != 4'b1000 & initial_replay_ip_q & ~total_valid_q) | (initial_replay_pending_q & is_replay) | (initial_replay_ip_q & (~total_valid_q | replay_flit_cnt_q[3:0] != 4'b1000))); // Timing Fix 9/28

assign replay_pending_din             = ((replay_pending_q | (~turn_off_vld_dead_cycle_dly2_q & crc_init_q & crc_nonzero_q))  & ~replay_ip_q & ~retrain_clear) | //Replay pending or crc error seen and first replay flit has not been seen OR
                                        (replay_ip_q & (crc_init_q & crc_nonzero_q))                                         |      //Replay in progress and CRC error is seen
                                        (crc_error_replay_q & imitation_data & replay_ip_dly_q)                              |
                                        (initial_imitation_data)                                                             |
                                        (early_replay_run_length)                                                            |
                                        (replay_pending_q & replay_flit_crc_error_q & ~retrain_clear);   

assign replay_flit_crc_error_din = crc_error_replay_q ? ((replay_ip_q & replay_flit_cnt_q[2] == 1'b1 & crc_init_q & crc_nonzero_q) | (replay_flit_crc_error_q & ~total_valid_q)) :
                                                        ((replay_ip_q & crc_init_q & crc_nonzero_q) | (replay_flit_crc_error_q & ~total_valid_q));
  
assign initial_replay_done_din = total_valid_q ? ~replay_duplicates_q & initial_replay_ip_q & replay_flit_cnt_q[3:0] == 4'b1000 : 
                                                 initial_replay_done_q; 

//Checks crc of replay flit to determine if it was a replay flit or imitation
//data flit)
//-- 10/02 assign seen_first_replay       = replay_flit_cnt_q[3:0] ==4'b0000 & is_replay & ~crc_nonzero_din;
assign seen_first_replay       = replay_flit_cnt_q[3:0] ==4'b0000 & is_replay & ~crc_nonzero_din & ((crc_error_replay_q & partial_flit_q[71:68] == 4'b0000) | ~crc_error_replay_q);


//If replay flit (during initial replays or replays due to crc error) has a previous run length, and it is not the 9th replay flit, flag a crc error
//--  7/30assign early_replay_run_length = crc_error_replay_q                               ? replay_flit_cnt_q[3] != 1'b1 & is_replay & partial_flit_q[71:68] != 4'b0000      : 
//-- 8/21 assign early_replay_run_length = crc_error_replay_q                               ? replay_flit_cnt_q[3] != 1'b1 & is_replay & partial_flit_q[71:68] != 4'b0000       : 
assign early_replay_run_length = crc_error_replay_q                               ? ~replay_pending_q & replay_flit_cnt_q[3] != 1'b1 & is_replay & partial_flit_q[71:68] != 4'b0000       : 
//--  7/30                                 (initial_replay_ip_q | initial_replay_pending_q) ? replay_flit_cnt_q[3:0] != 4'b0111 & is_replay & partial_flit_q[71:68] != 4'b0000 :
                                 (initial_replay_ip_q | initial_replay_pending_q) ? replay_flit_cnt_q[3:0] != 4'b0111 & is_replay & partial_flit_q[71:68] != 4'b0000  :
                                                                                    1'b0; 

// 11/15 assign replay_idles_seen_din  = replay_pending_q & ((~crc_nonzero_din & next_idle16_q & ~partial_flit_q[82]) | (replay_idles_seen_q & ~(total_valid_q & partial_flit_cnt_q == 2'b11))); 
assign replay_idles_seen_din  = replay_pending_q & ((total_valid_q & ~crc_nonzero_din & next_idle16_q & ~partial_flit_q[82]) | (replay_idles_seen_q & ~(total_valid_q & partial_flit_cnt_q == 2'b11))); 


// 11/6assign replay_ip_din = trn_mn_short_idle_enable ? ((~replay_ip_q & ~initial_replay & ~replay_pending_q & is_replay) | (~initial_replay & replay_pending_q & replay_idles_seen_q & seen_first_replay) | (~replay_pending_din & replay_ip_q & (replay_flit_cnt_din[3:0] != 4'b1001 | (replay_flit_cnt_din[3:0] == 4'b1001 & (rx_ack_ptr_q[6:0] != rx_curr_ptr_din[6:0]))))) :
  // 11/6                                               (replay_pending_q & seen_first_replay) | (replay_ip_q & (rx_ack_ptr_q[6:0] != rx_curr_ptr_din[6:0]));

// 02/02assign replay_ip_din = trn_mn_short_idle_enable ? ~(replay_ip_q & crc_nonzero_q & crc_init_q) & ~retrain_clear & ~imitation_data & ((~replay_ip_q & ~initial_replay & ~replay_pending_q & is_replay & replay_flit_cnt_q[3:0] != 4'b1000) | (~initial_replay & replay_pending_q & replay_idles_seen_q & seen_first_replay) | ((~replay_pending_q | (replay_pending_q & replay_flit_cnt_q[3:0] == 4'b0001)) & replay_ip_q & ~retrain_clear & ~(replay_flit_cnt_q[3:0] == 4'b1000 & ((agn_mn_x4_spare_mode_q[3] & partial_flit_cnt_q[1:0] == 2'b10) | (~agn_mn_x4_spare_mode_q[3] & partial_flit_cnt_q[1:0] == 2'b11))))) : 
  // 02/02                                               (replay_pending_q & seen_first_replay) | (replay_ip_q & (rx_ack_ptr_q[6:0] != rx_curr_ptr_din[6:0]));

//-- 8/15 assign replay_ip_din = ~(replay_ip_q & crc_nonzero_q & crc_init_q) & ~retrain_clear & ~imitation_data & ~early_replay_run_length & ((~short_idle_enable_q & replay_pending_q & is_replay) | (~replay_ip_q & ~initial_replay & ~replay_pending_q & is_replay & replay_flit_cnt_q[3:0] != 4'b1000) | (~initial_replay & replay_pending_q & replay_idles_seen_q & seen_first_replay & short_idle_enable_q) | ((~replay_pending_q | (replay_pending_q & replay_flit_cnt_q[3:0] == 4'b0001)) & replay_ip_q & ~retrain_clear & ~(replay_flit_cnt_q[3:0] == 4'b1000 & ((mode_x8 & partial_flit_cnt_q[1:0] == 2'b10) | ((~mode_x8 & partial_flit_cnt_q[1:0] == 2'b11) & total_valid_q)))));

assign replay_ip_din = ~(replay_ip_q & crc_nonzero_q & crc_init_q) & ~retrain_clear & ~imitation_data & ~early_replay_run_length & ((~short_idle_enable_q & replay_pending_q & seen_first_replay) | (~replay_ip_q & ~initial_replay & ~replay_pending_q & is_replay & replay_flit_cnt_q[3:0] != 4'b1000) | (~initial_replay & replay_pending_q & replay_idles_seen_q & seen_first_replay & short_idle_enable_q) | ((~replay_pending_q | (replay_pending_q & replay_flit_cnt_q[3:0] == 4'b0001)) & replay_ip_q & ~retrain_clear & ~(replay_flit_cnt_q[3:0] == 4'b1000 & ((mode_x8 & partial_flit_cnt_q[1:0] == 2'b10) | ((~mode_x8 & partial_flit_cnt_q[1:0] == 2'b11) & total_valid_q)))));

assign replay_ip_dly_din = replay_ip_q;
assign replay_ip_dly2_din = replay_ip_dly_q;
assign imitation_data = total_valid_q & replay_ip_dly_q & partial_flit_cnt_q[1:0] == 2'b11 & ~is_replay;
assign initial_imitation_data = total_valid_q & initial_replay_ip_q & partial_flit_cnt_q[1:0] == 2'b11 & ~is_replay;
assign imitation_data_din = imitation_data;
// 12/20 assign replay_duplicates_din = ((replay_flit_cnt_q[3:0] == 4'b1001 & (rx_curr_ptr_din[6:0] != rx_ack_ptr_q[6replay_flit_cnt_q[2] == 1'b1 &:0])) & ~(rx_ack_ptr_q[6:0] == (rx_curr_ptr_q[6:0] + {3'b000,possible_ptr_q[3:0]}) & flit_cnt_q[3:0] == 4'b0000 & partial_flit_cnt_din[1:0] == 2'b11 & replay_flit_cnt_q == 4'b1001)) | (~total_valid & replay_duplicates_q);
//-- 8/21 assign replay_duplicates_din = ((((((replay_flit_cnt_q[3:0] == 4'b1000 | (is_replay & replay_flit_cnt_q[3:0] == 4'b0111)) & initial_replay_ip_q) | ((crc_error_replay_q & replay_flit_cnt_q[3:0] == 4'b1001) | (~initial_replay_ip_q & replay_flit_cnt_q[3:0] != 4'b0000 & ~crc_error_replay_q))) & (rx_curr_ptr_din[6:0] != rx_ack_ptr_q[6:0])) & ~(rx_ack_ptr_q[6:0] == (rx_curr_ptr_q[6:0] + {3'b000,possible_ptr_q[3:0]}) & ((mode_x8 & ~replay_ip_dly_q) | (~mode_x8 & ~replay_ip_dly2_q)) & flit_cnt_q[3:0] == 4'b0000 & partial_flit_cnt_din[1:0]==2'b11 & ((initial_replay_ip_q & (replay_flit_cnt_q[3:0] == 4'b1000 | (is_replay & replay_flit_cnt_q[3:0] == 4'b0111))) |((crc_error_replay_q & replay_flit_cnt_q == 4'b1001) | (replay_flit_cnt_q[3:0] != 4'b0000 & ~crc_error_replay_q))))) | (~total_valid & replay_duplicates_q)) &  ~(~replay_duplicates_q & replay_duplicate_turn_on_q & ~replay_ip_dly_q);
//-- 9/05 assign replay_duplicates_din = ((((((replay_flit_cnt_q[3:0] == 4'b1000 | (is_replay & replay_flit_cnt_q[3:0] == 4'b0111)) & initial_replay_ip_q) | ((crc_error_replay_q & replay_flit_cnt_q[3:0] == 4'b1001) | (~initial_replay_ip_q & replay_flit_cnt_q[3:0] != 4'b0000 & ~crc_error_replay_q))) & (rx_curr_ptr_din[11:0] != rx_ack_ptr_q[11:0])) & ~(rx_ack_ptr_q[11:0] == (rx_curr_ptr_q[11:0] + {8'h00,possible_ptr_q[3:0]}) & ((mode_x8 & ~replay_ip_dly_q) | (~mode_x8 & ~replay_ip_dly2_q)) & flit_cnt_q[3:0] == 4'b0000 & partial_flit_cnt_din[1:0]==2'b11 & ((initial_replay_ip_q & (replay_flit_cnt_q[3:0] == 4'b1000 | (is_replay & replay_flit_cnt_q[3:0] == 4'b0111))) |((crc_error_replay_q & replay_flit_cnt_q == 4'b1001) | (replay_flit_cnt_q[3:0] != 4'b0000 & ~crc_error_replay_q))))) | (~total_valid & replay_duplicates_q & )) &  ~(~replay_duplicates_q & replay_duplicate_turn_on_q & ~replay_ip_dly_q);
assign replay_duplicates_din = ((((((replay_flit_cnt_q[3:0] == 4'b1000 | (is_replay & replay_flit_cnt_q[3:0] == 4'b0111)) & initial_replay_ip_q) | ((crc_error_replay_q & replay_flit_cnt_q[3:0] == 4'b1001) | (~initial_replay_ip_q & replay_flit_cnt_q[3:0] != 4'b0000 & ~crc_error_replay_q))) & (rx_curr_ptr_din[11:0] != rx_ack_ptr_q[11:0])) & ~(rx_ack_ptr_q[11:0] == (rx_curr_ptr_q[11:0] + {8'h00,possible_ptr_q[3:0]}) & ((mode_x8 & ~replay_ip_dly_q) | (~mode_x8 & ~replay_ip_dly2_q) | (~short_idle_enable_q & mode_x2 & imitation_data & (rx_ack_ptr_q[11:0] == ptr_chk[11:0]))) & flit_cnt_q[3:0] == 4'b0000 & (partial_flit_cnt_din[1:0]==2'b11| (mode_x2 & ~short_idle_enable_q & partial_flit_cnt_q[1:0] == 2'b11)) & ((initial_replay_ip_q & (replay_flit_cnt_q[3:0] == 4'b1000 | (is_replay & replay_flit_cnt_q[3:0] == 4'b0111))) |((crc_error_replay_q & replay_flit_cnt_q == 4'b1001) | (replay_flit_cnt_q[3:0] != 4'b0000 & ~crc_error_replay_q))))) | (~total_valid & replay_duplicates_q & ~(mode_x2 & ~short_idle_enable_q & imitation_data))) &  ~(~replay_duplicates_q & replay_duplicate_turn_on_q & ~replay_ip_dly_q);

//-- 9/05 assign replay_duplicate_turn_on_din = replay_duplicates_q | (replay_duplicate_turn_on_q & replay_flit_cnt_q != 4'b0000);
assign replay_duplicate_turn_on_din = replay_duplicates_q | (replay_duplicate_turn_on_q & replay_flit_cnt_q != 4'b0000 & ~imitation_data);
assign replay_duplicates2_din = replay_duplicates_q;

// 1/22 Added for timing, good_flits_rcvd fix
assign replay_duplicates3_din = replay_duplicates2_q;
//-- 8/21 assign ptr_chk[6:0] = rx_curr_ptr_q[6:0] + {3'b000,possible_ptr_q[3:0]};
assign ptr_chk[11:0] = rx_curr_ptr_q[11:0] + {8'h00,possible_ptr_q[3:0]};


// 11/16assign replay_flit_cnt_enable   = (initial_replay_ip_q | replay_ip_q) & is_replay & ~crc_nonzero_din; 
assign replay_flit_cnt_enable   = (initial_replay_ip_q | replay_ip_q) & is_replay; 
assign replay_flit_cnt_enable_din = replay_flit_cnt_enable;
//assign replay_flit_cnt_enable = is_replay & ~crc_nonzero_din;
// 11/16 assign replay_flit_cnt_din[3:0] = ((replay_flit_cnt_q[3:0] == 4'b1001 & ~replay_duplicates_din) | (initial_replay_done_q |initial_replay_pending_din) | (~replay_ip_q & ~seen_first_replay & replay_pending_q))   ? 4'b0000                             : //If replay is pending then reset this counter, will also trigger reset if crc when replay_ip_q =1


//-- 12/7 timing fix assign replay_flit_cnt_din[3:0] = (imitation_data | initial_replay_done_q | (replay_flit_cnt_q[3:0] == 4'b1001 & ~replay_duplicates_din) | (~is_replay & initial_replay_pending_q) | (~replay_ip_q & ~seen_first_replay & replay_pending_q))   ? 4'b0000                          : //--If replay is pending then reset this counter, will also trigger reset if crc when replay_ip_q =1
//-- 6/28 assign replay_flit_cnt_din[3:0] = ((imitation_data & ~replay_duplicates_q) | initial_replay_done_q | (replay_flit_cnt_q[3:0] == 4'b1001 & (rx_ack_ptr_q[6:0] == rx_curr_ptr_q[6:0])) | (~is_replay & initial_replay_pending_q) | (~replay_ip_q & ~seen_first_replay & replay_pending_q)) ? 4'b0000                          : //--If replay is pending then reset this counter, will also trigger reset if crc when replay_ip_q =1
//-- 7/02 assign replay_flit_cnt_din[3:0] = (imitation_data | initial_replay_done_q | (replay_flit_cnt_q[3:0] == 4'b1001 & (rx_ack_ptr_q[6:0] == rx_curr_ptr_q[6:0])) | (~is_replay & initial_replay_pending_q) | (~replay_ip_q & ~seen_first_replay & replay_pending_q)) ? 4'b0000                          : //--If replay is pending then reset this counter, will also trigger reset if crc when replay_ip_q =1
//-- 9/05 assign replay_flit_cnt_din[3:0] = (initial_replay_done_q | ((imitation_data | replay_flit_cnt_q[3:0] == 4'b1001) & (rx_ack_ptr_q[11:0] == rx_curr_ptr_q[11:0])) | (~is_replay & initial_replay_pending_q) | (~replay_ip_q & ~seen_first_replay & replay_pending_q)) ? 4'b0000                          : //--If replay is pending then reset this counter, will also trigger reset if crc when replay_ip_q =1
assign replay_flit_cnt_din[3:0] = ((~short_idle_enable_q & mode_x2 & imitation_data & (rx_ack_ptr_q[11:0] == ptr_chk[11:0]) & flit_cnt_q[3:0] == 4'b0000) | initial_replay_done_q | ((imitation_data | replay_flit_cnt_q[3:0] == 4'b1001) & (rx_ack_ptr_q[11:0] == rx_curr_ptr_q[11:0])) | (~is_replay & initial_replay_pending_q) | (~replay_ip_q & ~seen_first_replay & replay_pending_q)) ? 4'b0000                          : //--If replay is pending then reset this counter, will also trigger reset if crc when replay_ip_q =1
//-- 10/02                                  ((~initial_replay & ~replay_ip_q & is_replay & ~crc_nonzero_din & replay_flit_cnt_q[3:0] != 4'b1000) | seen_first_replay)                                                                                                                        ? 4'b0001                          : //--When first replay flit is seen, start at 1  
                                  ((~initial_replay & ~replay_ip_q & is_replay & ~crc_nonzero_din & replay_flit_cnt_q[3:0] != 4'b1000 & ((crc_error_replay_q & partial_flit_q[71:68] == 4'b0000) | ~crc_error_replay_q)) | seen_first_replay)                                                                                                                        ? 4'b0001                          : //--When first replay flit is seen, start at 1  
                                  (initial_replay_ip_q & replay_flit_cnt_q[3:0] == 4'b1000 & replay_duplicates_q)                                                                                                                                                                     ? 4'b1001                          : //--force to 9
                                  replay_flit_cnt_enable | (replay_flit_cnt_q[3:0] == 4'b1000 & is_replay)                                                                                                                                                      ? replay_flit_cnt_q[3:0] + 4'b0001 : //--Increment when enable signal is high, otherwise hold value
                                                                                                                                                                                                                                                                  replay_flit_cnt_q[3:0]; 

//During replay_ip, take message during 3rd beat of replay flit

assign third_beat_replay_msg_din[31:0] = (total_valid_q & replay_ip_q & partial_flit_cnt_q[1:0] == 2'b10) ? partial_flit_q[127:96] : {32{1'b0}};


assign initial_replay                  = initial_replay_ip_q | initial_replay_ip_din; //Used to block replay info from going to tx side during initial replay flits after training. The way initial_replay_ip works, requires both to be checked to avoid data from being sent to tx
assign rx_tx_rmt_message_dly_din[63:0] = {partial_flit_q[31:0], third_beat_replay_msg_q[31:0]};  //Create error message on replay flit 
//-- 10/02 assign rx_tx_tx_ack_rtn_din[4:0]       = ~turn_off_vld_dead_cycle_dly_q & (~crc_nonzero_din & ~replay_pending_q & ~replay_pending_din & (is_cntl | (((initial_replay & replay_flit_cnt_q[3:0] == 4'b0111) | (crc_error_replay_q & replay_flit_cnt_q[3:0] == 4'b1000) | (~crc_error_replay_q & ~initial_replay)) & is_replay) | is_idle_16 | is_idle_64)) ? partial_flit_q[91:87] : 5'b00000;  //Parses ack count on cntl, idle or replay flit
assign rx_tx_tx_ack_rtn_din[4:0]       = ~turn_off_vld_dead_cycle_dly_q & (~crc_nonzero_din & ~replay_pending_q & ~replay_pending_din & (is_cntl | is_idle_16 | is_idle_64)) ? partial_flit_q[91:87] : 5'b00000;  //Parses ack count on cntl, idle or replay flit
//-- 4/24 assign rx_tx_tx_ack_ptr_vld_din        = is_replay & ~crc_nonzero_din & ~early_replay_run_length;               //On replay flit, ack count is valid          
assign rx_tx_tx_ack_ptr_vld_din           = ((initial_replay & replay_flit_cnt_q[3:0]==4'b0111) | (crc_error_replay_q & replay_flit_cnt_q[3:0] == 4'b1000) | (~initial_replay & ~crc_error_replay_q)) & is_replay & ~crc_nonzero_din & ~early_replay_run_length;
//-- 8/21 assign rx_tx_tx_ack_ptr_din[6:0]       = partial_flit_q[38:32];           //Ack pointer field in replay flit
assign rx_tx_tx_ack_ptr_din[11:0]      = partial_flit_q[43:32];           //Ack pointer field in replay flit
assign rx_tx_rmt_error_dly_din[7:0]    = partial_flit_q[79:72];         //Parses link error field during replay flit 
assign rx_tx_nack_din                  = ((crc_error_replay_q & replay_flit_cnt_q[3:0] == 4'b1000) | ~crc_error_replay_q)  & ~initial_replay & is_replay & partial_flit_q[84] & ~crc_nonzero_din;                   //Parses nack field during replay flit   
//assign rx_tx_crc_error_din             = ~replay_pending_q & crc_init_q & crc_nonzero_q;              //Checks that it is time to check crc_nonzero_q and that it is nonzero

//-- 10/01 assign rx_tx_crc_error_dly_din             = ~turn_off_vld_dead_cycle_dly2_q & (early_replay_run_length | initial_imitation_data | (((replay_pending_q & replay_ip_dly_q) | (crc_error_replay_q & replay_flit_cnt_q[2] == 1'b1) | ~replay_pending_q) & crc_init_q & crc_nonzero_q));              //Checks that it is time to check crc_nonzero_q and that it is nonzero
//-- 10/03 assign rx_tx_crc_error_dly_din             = ~turn_off_vld_dead_cycle_dly2_q & ((early_replay_run_length & replay_flit_cnt_q[2] == 1'b1) | initial_imitation_data | (((crc_error_replay_q & replay_flit_cnt_q[2] == 1'b1) | ~replay_pending_q) & crc_init_q & crc_nonzero_q));              //Checks that it is time to check crc_nonzero_q and that it is nonzero
assign rx_tx_crc_error_dly_din             = ~turn_off_vld_dead_cycle_dly2_q & ((early_replay_run_length & replay_flit_cnt_q[2] == 1'b1) | initial_imitation_data | ((initial_replay_pending_q | initial_replay_ip_q | (crc_error_replay_q & replay_flit_cnt_q[2] == 1'b1) | ~replay_pending_q) & crc_init_q & crc_nonzero_q));              //Checks that it is time to check crc_nonzero_q and that it is nonzero

assign rx_tx_crc_error_din = rx_tx_crc_error_dly_q & trn_mn_trained;

//Power management fields to Tx
assign rx_tx_recal_status_din[1:0] = (is_cntl | is_idle_16 | is_idle_64 | (is_replay & ((initial_replay & replay_flit_cnt_q[3:0] == 4'b0111) | (~initial_replay & ~crc_error_replay_q) | (crc_error_replay_q & replay_flit_cnt_q[3:0] == 4'b1000)))) & ~crc_nonzero_din & ~turn_off_vld_dead_cycle_dly_q & ~replay_pending_q ? partial_flit_q[86:85] : rx_tx_recal_status_q[1:0]; 

//-- 11/14 472245 assign rx_tx_pm_status_din[3:0]    = ~replay_pending_q & trn_mn_trained & ~turn_off_vld_dead_cycle_dly_q & ((is_idle_16 | is_idle_64) & ~crc_nonzero_din) ? partial_flit_q[75:72] : 
assign rx_tx_pm_status_din[3:0]    = ~replay_pending_din & ~replay_pending_q & trn_mn_trained & ~turn_off_vld_dead_cycle_dly_q & ((is_idle_16 | is_idle_64) & ~crc_nonzero_din) ? partial_flit_q[75:72] : 
                                     ~replay_pending_q & trn_mn_trained & ~turn_off_vld_dead_cycle_dly_q & (is_replay & ~crc_nonzero_din & ((~initial_replay & ~crc_error_replay_q) | (initial_replay & replay_flit_cnt_q[3:0] == 4'b0111) | (crc_error_replay_q & replay_flit_cnt_q[3:0] == 4'b1000))) ? partial_flit_q[63:60] : rx_tx_pm_status_q[3:0];

assign pm_status_trace[3:0]        = (partial_flit_q[75:72] & {4{is_idle_16 | is_idle_64}}) | (partial_flit_q[63:60] & {4{is_replay}}); //-- for trace bus

// assign rx_tx_crc_error_din             = ((crc_error_replay_q & replay_flit_cnt_q[2] == 1'b1) & 
assign crc_error_replay_din = rx_tx_crc_error_q  | (~retrain_clear & crc_error_replay_q & replay_flit_cnt_q[3:0] != 4'b1001);

assign rx_tx_rmt_error_din[7:0] = ~crc_nonzero_q & is_replay_dly_q  & ((crc_error_replay_q & replay_flit_cnt_q[3:0] == 4'b1001) | (initial_replay & replay_flit_cnt_q[3:0] == 4'b1000) | (~initial_replay & ~crc_error_replay_q)) ? rx_tx_rmt_error_dly_q[7:0] : 
                                   crc_nonzero_q & is_replay_dly_q  & ((crc_error_replay_q & replay_flit_cnt_q[3:0] == 4'b1001) | (initial_replay & replay_flit_cnt_q[3:0] == 4'b1000) | (~initial_replay & ~crc_error_replay_q)) ? {8{1'b0}}                  :
                                                                                                                                                                                                                                              rx_tx_rmt_error_q[7:0];
                             
assign rx_tx_rmt_message_din[63:0] = ~crc_nonzero_q & is_replay_dly_q & ((crc_error_replay_q & replay_flit_cnt_q[3:0] == 4'b1001) | (initial_replay & replay_flit_cnt_q[3:0] == 4'b1000) | (~initial_replay & ~crc_error_replay_q)) ? rx_tx_rmt_message_dly_q[63:0] :
                                      crc_nonzero_q & is_replay_dly_q & ((crc_error_replay_q & replay_flit_cnt_q[3:0] == 4'b1001) | (initial_replay & replay_flit_cnt_q[3:0] == 4'b1000) | (~initial_replay & ~crc_error_replay_q)) ? {64{1'b0}}                    :
                                                                                                                                                                                                                                              rx_tx_rmt_message_q[63:0];

//PM Status Changes
assign pm_status_now[3:0] = trn_mn_trained & total_valid & (idle_16_now_q | (partial_flit_cnt_din[1:0] == 2'b11 & flit_cnt_q[3:0] == 4'b0000 & partial_flit[67:64] == 4'b1111)) ? partial_flit[75:72] :
                             trn_mn_trained & ((crc_error_replay_q & replay_flit_cnt_q[3:0] == 4'b1000) | (~initial_replay & ~crc_error_replay_q) | (initial_replay & replay_flit_cnt_q[3:0] == 4'b0111)) & total_valid & partial_flit_cnt_din[1:0] == 2'b11 & flit_cnt_q[3:0] == 4'b0000 & partial_flit[67:64] == 4'b1010                    ? partial_flit[63:60] : 4'b0000;

//-- 5/1assign start_dead_cycle   = trn_mn_trained & pm_status_now[3:0] == 4'b0100 | pm_status_now[3:0] == 4'b0101 | pm_status_now[3:0] == 4'b1000 | pm_status_now[3:0] == 4'b1001; 

//--  5/17, don't count dead cycles when going up in width
assign start_dead_cycle   = trn_mn_trained & ~(replay_ip_q | replay_pending_q) &   
                            (pm_status_now[3:0] == 4'b1000) |
                            (pm_status_now[3:0] == 4'b1001);
//--  6/18               (mode_x8 & pm_status_now[3:0] == 4'b1000) |
 //--  6/18              (mode_x4 & pm_status_now[3:0] == 4'b1001);
 //                           (mode_x2 & pm_status_now[3:0] == 4'b0100);

//-- 6/18 assign dead_cycle_cnt_din[3:0] = dead_cycle_cnt_q[3:0] == 4'b1000 & ln_all_valid                       ? 4'b0000                         : 
//-- 7/19 assign dead_cycle_cnt_din[3:0] = (dead_cycle_cnt_q[3:0] == 4'b1000 & ln_all_valid) | replay_pending_q  ? 4'b0000                         : 
//-- 8/21 assign dead_cycle_cnt_din[3:0] = (dead_cycle_finished & ln_all_valid) | replay_pending_q              ? 4'b0000                         : 
assign dead_cycle_cnt_din[3:0] = (dead_cycle_finished & ln_all_valid) | replay_pending_q | dead_cycle_crc_error              ? 4'b0000                         : 
                                 ln_all_valid & (start_dead_cycle | dead_cycle_cnt_q[3:0] != 4'b0000)                        ? dead_cycle_cnt_q[3:0] + 4'b0001 : dead_cycle_cnt_q[3:0];

//--8/21
assign dead_cycle_crc_error   = total_valid_q & (dead_cycle_cnt_q[3:0] == 4'b0001) & crc_nonzero_din;

//-- 7/25 assign dead_cycle_finished = (dead_cycle_cnt_q[3:0] == 4'b1000 & ~mode_x2) | (dead_cycle_cnt_q[3:0] == 4'b1001 & mode_x2);
assign dead_cycle_finished = dead_cycle_cnt_q[3:0] == 4'b1000;
//Determine mode so that dead cycle counter isn't triggered when already in that mode
assign mode_x8 = agn_mn_x2_mode_q[1:0] == 2'b00 & agn_mn_x4_mode_q[1:0] == 2'b00;
assign mode_x4 = agn_mn_x2_mode_q[1:0] == 2'b00 & agn_mn_x4_mode_q[1:0] != 2'b00;
assign mode_x2 = agn_mn_x2_mode_q[1:0] != 2'b00 & agn_mn_x4_mode_q[1:0] == 2'b00;

//Output to Align to reset odd beat latch
//-- 7/19 assign mn_agn_dead_cycle_reset = dead_cycle_cnt_q[3:0] == 4'b1000;
assign mn_agn_dead_cycle_reset = dead_cycle_finished;
//-- 8/21 assign turn_off_vld_dead_cycle = dead_cycle_cnt_q[3:0] != 4'b0000;
assign turn_off_vld_dead_cycle = dead_cycle_cnt_q[3:0] != 4'b0000 & ~dead_cycle_crc_error;
assign turn_off_vld_dead_cycle_dly_din = turn_off_vld_dead_cycle;
assign turn_off_vld_dead_cycle_dly2_din = turn_off_vld_dead_cycle_dly_q;

//-- 7/19 not using assign dead_cycle_reset_din    = dead_cycle_cnt_q[3:0] == 4'b1000;
//Outputs to TX
assign rx_tx_rx_ack_inc[3:0]   = rx_tx_rx_ack_inc_q[3:0];
assign rx_tx_tx_ack_rtn[4:0]   = rx_tx_tx_ack_rtn_q[4:0];
assign rx_tx_tx_ack_ptr_vld    = rx_tx_tx_ack_ptr_vld_q;
//-- 8/21 assign rx_tx_tx_ack_ptr[6:0]   = rx_tx_tx_ack_ptr_q[6:0];
assign rx_tx_tx_ack_ptr[11:0]  = rx_tx_tx_ack_ptr_q[11:0];
assign rx_tx_rmt_error[7:0]    = rx_tx_rmt_error_q[7:0];
assign rx_tx_rmt_message[63:0] = rx_tx_rmt_message_q[63:0];
assign rx_tx_nack              = rx_tx_nack_q;
assign rx_tx_crc_error         = rx_tx_crc_error_q;
assign rx_tx_recal_status[1:0] = rx_tx_recal_status_q[1:0]; 
assign rx_tx_pm_status[3:0]    = rx_tx_pm_status_q[3:0];  


//When to reset crc checker/check the crc_nonzero. If we are resetting crc
//count, this should be the same time we check if it is nonzero (end of crc
//coverage)
assign crc_init_din = turn_off_vld_dead_cycle | (trn_dly3_din & ~trn_dly3_q) | (~total_valid_q & crc_init_q) | (total_valid_q & (next_idle16_q | (short_idle_enable_q & replay_pending_q & ~((replay_idles_seen_q & partial_flit_cnt_q[1:0] != 2'b11)| replay_ip_q)) | (~(replay_pending_q & short_idle_enable_q) & flit_cnt_q[3:0] == 4'b0000 & partial_flit_cnt_q[1:0] == 2'b11)));   
//CRC Module
dlc_crc crc_mod(
   .init (crc_init_q)
  ,.checkbits_in (crc_bits_q)
  ,.data (partial_flit_q)
  ,.checkbits_out (crc_bits_out)
  ,.nonzero_check (crc_nonzero)
);

assign crc_bits_din[35:0] = total_valid_q ? crc_bits_out[35:0] : crc_bits_q[35:0];
assign crc_nonzero_din = (total_valid_q & crc_nonzero & ~turn_off_vld_dead_cycle_dly2_q) | (~total_valid_q & crc_nonzero_q & ~retrain_clear);



//If it is a control flit, need to zero out bits 127:82, therefore need to recalculate parity. Since top 46 bits are 0, parity for those are 0, therefore only need to calculate parity over bits 81:80
assign cntl_flit_pty = ^partial_flit[81:80];
//Zero out crc,ack_cnt,stalled,short_flit next on control flit
assign partial_flit_out[127:0] = turn_on_cntl_zeros & (partial_flit_cnt_din[1:0]==2'b11 & flit_cnt_q[3:0]==4'b0000 & (partial_flit[67] != 1'b1 | partial_flit[67:64]==4'b1000)) ? {{46{1'b0}},partial_flit[81:0]} : partial_flit[127:0]; 

assign partial_flit_pty[15:0] =turn_on_cntl_zeros & (partial_flit_cnt_din[1:0]==2'b11 & flit_cnt_q[3:0]==4'b0000 & (partial_flit[67] != 1'b1 | partial_flit[67:64]==4'b1000)) ? {{5{1'b0}},cntl_flit_pty,agn_mn_flit_pty[9:0]} : agn_mn_flit_pty[15:0];
assign partial_flit_pty_din[15:0] = partial_flit_pty[15:0];


assign replay_ip_turn_off_vld = (replay_ip_q & crc_error_replay_q & replay_flit_cnt_q[3] != 1'b1) | (~crc_error_replay_q & initial_replay_ip_q & (replay_flit_cnt_q[3:0] != 4'b0111 & replay_flit_cnt_q[3] != 1'b1)); 
//-- 8/16 assign flit_vld_int         = total_valid & ~(start_dead_cycle | replay_ip_turn_off_vld | turn_off_vld_dead_cycle | long_idle_stall_q | initial_replay_pending_q | idle_16_now_q | (~replay_ip_q & replay_duplicates_q) | replay_pending_q | turn_off_valid_ill_rl_q);// |  initial_replay_pending_q);     //Flit data is valid if total valid, not a 16 byte idle flit, or a replay in progress or pending
assign flit_vld_int         = total_valid & ~(replay_ip_turn_off_vld | turn_off_vld_dead_cycle | initial_replay_pending_q | idle_16_now_q | (~replay_ip_q & replay_duplicates_q) | replay_pending_q | turn_off_valid_ill_rl_q);// |  initial_replay_pending_q);     //Flit data is valid if total valid, not a 16 byte idle flit, or a replay in progress or pending
//12/20assign flit_error_int       = ((~replay_pending_q & crc_init_din & crc_nonzero_din) | is_replay | is_idle_64 | replay_duplicates_q);//) | (replay_duplicates_q & flit_error_int_q);   //Tells TL to throw away flit if crc error, or 64 byte idle
//-- 9/17 assign flit_error_int       = ~turn_off_vld_dead_cycle_dly2_q & (rx_tx_ill_rl_q | initial_imitation_data | (crc_error_replay_q & imitation_data) | (~replay_pending_q & crc_init_din & crc_nonzero_din) | retrain_clear | trn_mn_retrain | is_replay | is_idle_64 | replay_duplicates_q);//) | (replay_duplicates_q & flit_error_int_q);   //Tells TL to throw away flit if crc error, or 64 byte idle
assign flit_error_int       = ~turn_off_vld_dead_cycle_dly2_q & (rx_tx_ill_rl_q | initial_imitation_data | (crc_error_replay_q & imitation_data) | (~replay_pending_q & crc_init_din & crc_nonzero_din) | retrain_clear | trn_mn_retrain | is_replay | is_idle_64 | replay_duplicates_q | (trn_dly2_q & ~trn_dly1_q));//) | (replay_duplicates_q & flit_error_int_q);   //Tells TL to throw away flit if crc error, or 64 byte idle
assign retrain_clear = trn_dly1_q & ~trn_dly2_q;

assign flit_error_int_din = flit_error_int;
assign flit_vld_int_din = flit_vld_int;
//Flit outputs to TLX
assign dl2tl_flit_data[127:0] = partial_flit_out[127:0];       //Pass data to TL
assign dl2tl_flit_vld         = flit_vld_int;
assign dl2tl_flit_pty[15:0]   = partial_flit_pty[15:0];       //Parity for flit data, 1 bit for every byte. Valid when dl2tl_flit_vld is high
assign dl2tl_flit_error       = flit_error_int;
//-- 8/8 assign dl2tl_flit_badcrc      = ~(replay_pending_q | replay_pending_din) & crc_init_din & crc_nonzero_din & trn_mn_trained;
assign dl2tl_flit_badcrc_int      = ~(turn_off_vld_dead_cycle_dly_q | replay_pending_q | replay_pending_din) & total_valid_q & crc_init_din & crc_nonzero_din & trn_mn_trained;
assign dl2tl_flit_badcrc = dl2tl_flit_badcrc_int;
//Fast Act Logic
// 8/8 Added Cloning
// 7/19 assign dl2tl_idle_transition_din  = mode_x8 & ~dead_cycle & idle_16_now_q & ~partial_flit[82] & partial_flit[71:68] == 4'b0000;
assign dl2tl_idle_transition_int_din       = total_valid & ~turn_off_vld_dead_cycle & ~replay_pending_q & trn_mn_trained & mode_x8 & idle_16_now_q & ~partial_flit[82]  & partial_flit[71:68] == 4'b0000; //Needed incase we hit a stall when the first beat of the control flit is on. This will allow us to come on the next cycle on the input side of the latch 
assign dl2tl_idle_transition_l_int_din     = total_valid & ~turn_off_vld_dead_cycle & ~replay_pending_q & trn_mn_trained & mode_x8 & idle_16_now_q & ~partial_flit[82]  & partial_flit[71:68] == 4'b0000; //Needed incase we hit a stall when the first beat of the control flit is on. This will allow us to come on the next cycle on the input side of the latch 
assign dl2tl_idle_transition_r_int_din     = total_valid & ~turn_off_vld_dead_cycle & ~replay_pending_q & trn_mn_trained & mode_x8 & idle_16_now_q & ~partial_flit[82]  & partial_flit[71:68] == 4'b0000; //Needed incase we hit a stall when the first beat of the control flit is on. This will allow us to come on the next cycle on the input side of the latch 

assign dl2tl_idle_transition_din           = (total_valid & ~turn_off_vld_dead_cycle & ~replay_pending_q & trn_mn_trained & mode_x8 & ~dead_cycle & idle_16_now_q & ~partial_flit[82] & partial_flit[71:68] == 4'b0000) | (~total_valid & dl2tl_idle_transition_int_q);
assign dl2tl_idle_transition_l_din         = (total_valid & ~turn_off_vld_dead_cycle & ~replay_pending_q & trn_mn_trained & mode_x8 & ~dead_cycle & idle_16_now_q & ~partial_flit[82] & partial_flit[71:68] == 4'b0000) | (~total_valid & dl2tl_idle_transition_l_int_q);
assign dl2tl_idle_transition_r_din         = (total_valid & ~turn_off_vld_dead_cycle & ~replay_pending_q & trn_mn_trained & mode_x8 & ~dead_cycle & idle_16_now_q & ~partial_flit[82] & partial_flit[71:68] == 4'b0000) | (~total_valid & dl2tl_idle_transition_r_int_q);
assign dl2tl_idle_transition_trace_din         = (total_valid & ~turn_off_vld_dead_cycle & ~replay_pending_q & trn_mn_trained & mode_x8 & ~dead_cycle & idle_16_now_q & ~partial_flit[82] & partial_flit[71:68] == 4'b0000) | (~total_valid & dl2tl_idle_transition_r_int_q);

assign dl2tl_idle_transition               = dl2tl_idle_transition_q;
assign dl2tl_idle_transition_l             = dl2tl_idle_transition_l_q;
assign dl2tl_idle_transition_r             = dl2tl_idle_transition_r_q;

//TL Clock gating logic
//-- 9/21 assign is_cntl_replay_or_idle_now            = ~initial_replay_pending_q & total_valid  & (partial_flit_cnt_din[1:0] == 2'b11) & (flit_cnt_q[3:0] == 4'b0000) & ((partial_flit[67] != 1'b1) | (partial_flit[67:64] ==  4'b1000) | (partial_flit[67:64] == 4'b1010) | (partial_flit[67:64] == 4'b1111));
assign is_cntl_replay_or_idle_now            = ~initial_replay_pending_q & total_valid  & (partial_flit_cnt_din[1:0] == 2'b11) & (flit_cnt_q[3:0] == 4'b0000) & ((partial_flit[67] != 1'b1) | (partial_flit[67:64] ==  4'b1000) | (partial_flit[67:64] == 4'b1010) | ((partial_flit[67:64] == 4'b1111) & short_idle_enable_q));

//Allows flit_act to turn on one cycle before valid even on replays
assign replay_turn_on_valid = (initial_replay_ip_q & is_replay & replay_flit_cnt_q[3:0] == 4'b0110) | (replay_ip_q & is_replay & replay_flit_cnt_q[3:0] == 4'b0111);
//Should come on one cycle before dl2tl_flit_vld
//-- 9/21 assign dl2tl_flit_act_int     =(~replay_pending_q & total_valid & ((idle_16_now_q & ~partial_flit[82]) | ((flit_vld_int | replay_duplicates_q) & ~(is_cntl_replay_or_idle_now & partial_flit[82] == 1'b1)))) | (trn_mn_trained & ~total_valid & dl2tl_flit_act_q);
//-- 9/25assign dl2tl_flit_act_int     =(~replay_pending_q & (replay_turn_on_valid | (total_valid & ((idle_16_now_q & ~partial_flit[82]) | ((flit_vld_int | replay_duplicates_q) & ~(is_cntl_replay_or_idle_now & partial_flit[82] == 1'b1)))))) | (trn_mn_trained & ~total_valid & dl2tl_flit_act_q);

//-- 10/03assign dl2tl_flit_act_int     =(~replay_pending_q & (replay_turn_on_valid | (total_valid & ((idle_16_now_q & ~partial_flit[82]) | ((flit_vld_int | replay_duplicates_q) & ~(is_cntl_replay_or_idle_now & partial_flit[82] == 1'b1)))))) | (trn_mn_trained & ~total_valid & dl2tl_flit_act_q) | dl2tl_flit_act_scan_q;
assign dl2tl_flit_act_int     =(~replay_pending_q & (replay_turn_on_valid | (total_valid & ((idle_16_now_q & ~partial_flit[82]) | ((flit_vld_int | replay_duplicates_q) & ~(is_cntl_replay_or_idle_now & partial_flit[82] == 1'b1)))))) | (trn_mn_trained & ~total_valid & dl2tl_flit_act_q) | (~short_idle_enable_q & ~turn_off_vld_dead_cycle & turn_off_vld_dead_cycle_dly_q) | dl2tl_flit_act_scan_q;

//Scan only latch in case we want this on all the time 
assign dl2tl_flit_act_scan_din = dl2tl_flit_act_scan_q;
assign dl2tl_flit_act_din      = dl2tl_flit_act_int;
assign dl2tl_flit_act          = dl2tl_flit_act_int;

//Error Checkers/Performance Counter Signals
assign rx_tx_mn_trn_in_replay_din = total_valid_q & (replay_pending_q | replay_ip_q);
assign rx_tx_data_flt_din         = total_valid_q & flit_cnt_q[3:0] != 4'b0000;
assign rx_tx_ctl_flt_int              = total_valid_q & is_cntl_perf_mon_q;
assign rx_tx_rpl_flt_int              = total_valid_q & is_replay_perf_mon_q;
assign rx_tx_idle_flt_int             = is_idle_16_perf_mon_q | (total_valid_q & is_idle_64_perf_mon_q);

assign rx_tx_ctl_flt = rx_tx_ctl_flt_int;
assign rx_tx_rpl_flt = rx_tx_rpl_flt_int;
assign rx_tx_idle_flt = rx_tx_idle_flt_int;

//assign rx_tx_ill_rl_dly_din       = total_valid_q & ~replay_pending_q & flit_cnt_q[3:0] == 4'b0000 & (next_idle16_q | partial_flit_cnt_q[1:0] == 2'b11) & (partial_flit_q[67:64] == 4'h9 | partial_flit_q[67:64] == 4'hB | partial_flit_q[67:64] == 4'hC | partial_flit_q[67:64] == 4'hD | partial_flit_q[67:64] == 4'hE);


// added simonly override assign ill_rl_idle_replay = (is_replay | (~replay_pending_q & (is_idle_16 | is_idle_64))) & (partial_flit_q[71:68]==4'h9 | partial_flit_q[71:68]==4'hA | partial_flit_q[71:68]==4'hB | partial_flit_q[71:68]==4'hC | partial_flit_q[71:68]==4'hD | partial_flit_q[71:68]==4'hE | partial_flit_q[71:68]==4'hF);
// added simonly override assign ill_rl_cntl = flit_cnt_q[3:0]==4'b0000 & (partial_flit_q[67:64]==4'h9 | partial_flit_q[67:64]==4'hB | partial_flit_q[67:64]==4'hC | partial_flit_q[67:64]==4'hD | partial_flit_q[67:64]==4'hE) & ~replay_pending_q & partial_flit_cnt_q[1:0]==2'b11;

assign ill_rl_idle_replay = (is_replay | (~replay_pending_q & (is_idle_16 | is_idle_64))) & (rx_run_length[7:4]==4'h9 | rx_run_length[7:4]==4'hA | rx_run_length[7:4]==4'hB | rx_run_length[7:4]==4'hC | rx_run_length[7:4]==4'hD | rx_run_length[7:4]==4'hE | rx_run_length[7:4]==4'hF);
assign ill_rl_cntl = ~initial_replay_pending_q & flit_cnt_q[3:0]==4'b0000 & (rx_run_length[3:0]==4'h9 | rx_run_length[3:0]==4'hB | rx_run_length[3:0]==4'hC | rx_run_length[3:0]==4'hD | rx_run_length[3:0]==4'hE) & ~replay_pending_q & partial_flit_cnt_q[1:0]==2'b11;


assign rx_tx_ill_rl_dly_din = total_valid_q & (ill_rl_idle_replay | ill_rl_cntl); 
//assign rx_tx_ill_dly_din = total_valid_q & flit_cnt_q[3:0] == 4'b0000 & ((partial_flit_q[67:64] == 4'hF | partial_flit_q[67:64]==4'hA) & (partial_flit_q[71:68]==4'h9 | partial_flit_q[71:68]==4'hA | 
//11/1assign four_cycle_start = ~crc_nonzero_din & (is_idle_64 | is_cntl | is_replay);
assign four_cycle_start = ~crc_nonzero_q & (is_idle_64_dly_q | is_cntl_dly_q | is_replay_dly_q);
assign four_cycle_cnt_din[2:0] = four_cycle_start                                                                   ? 3'b001                      :
                              (((four_cycle_cnt_q[2:0] != 3'b000) & (four_cycle_cnt_q[2] != 1'b1)) & total_valid_q) ? four_cycle_cnt_q[2:0] + 3'b001 :
                              four_cycle_cnt_q[2:0] == 3'b100 & total_valid_q & ~four_cycle_start                   ? 3'b000                      :
                                                                                                                      four_cycle_cnt_q[2:0];                                   
assign four_cycle = (four_cycle_cnt_q[2:0] == 3'b001) |
                    (four_cycle_cnt_q[2:0] == 3'b010) |
                    (four_cycle_cnt_q[2:0] == 3'b011);


assign is_replay_perf_mon_din  = (is_replay_dly_q  & ~crc_nonzero_q) | (is_replay_perf_mon_q & four_cycle);
assign is_cntl_perf_mon_din    = (is_cntl_dly_q    & ~crc_nonzero_q) | (is_cntl_perf_mon_q & four_cycle);
assign is_idle_64_perf_mon_din = (is_idle_64_dly_q & ~crc_nonzero_q) | (is_idle_64_perf_mon_q & four_cycle);
assign is_idle_16_perf_mon_din = (is_idle_16_dly_q & ~crc_nonzero_q);



assign rx_tx_ill_rl_din = crc_init_q & ~crc_nonzero_q & rx_tx_ill_rl_dly_q;
assign turn_off_valid_ill_rl_din = (crc_init_q & ~crc_nonzero_q & rx_tx_ill_rl_dly_q) | turn_off_valid_ill_rl_q;
//Error Performance counter output assignmentms
assign rx_tx_mn_trn_in_replay = rx_tx_mn_trn_in_replay_q;
assign rx_tx_data_flt = rx_tx_data_flt_q;
assign rx_tx_ill_rl = rx_tx_ill_rl_q;

//Debug Bus Muxing                                 
assign rx_tx_dbg_rx_info[87:0] = dbg_0[87:0] & {88{(tx_rx_macro_dbg_sel[3:0] == 4'b0000)}} | 
                                 dbg_1[87:0] & {88{(tx_rx_macro_dbg_sel[3:0] == 4'b0001)}} | 
                                 dbg_2[87:0] & {88{(tx_rx_macro_dbg_sel[3:0] == 4'b0010)}} | 
                                 dbg_3[87:0] & {88{(tx_rx_macro_dbg_sel[3:0] == 4'b0011)}} | 
                                 dbg_4[87:0] & {88{(tx_rx_macro_dbg_sel[3:0] == 4'b0100)}} | 
                                 dbg_5[87:0] & {88{(tx_rx_macro_dbg_sel[3:0] == 4'b0101)}} | 
                                 dbg_6[87:0] & {88{(tx_rx_macro_dbg_sel[3:0] == 4'b0110)}} | 
                                 dbg_7[87:0] & {88{(tx_rx_macro_dbg_sel[3:0] == 4'b0111)}} | 
                                 dbg_8[87:0] & {88{(tx_rx_macro_dbg_sel[3:0] == 4'b1000)}} | 
                                 dbg_9[87:0] & {88{(tx_rx_macro_dbg_sel[3:0] == 4'b1001)}} | 
                                 dbg_A[87:0] & {88{(tx_rx_macro_dbg_sel[3:0] == 4'b1010)}} | 
                                dbg_B[87:0] & {88{(tx_rx_macro_dbg_sel[3:0] == 4'b1011)}} | 
                                dbg_C[87:0] & {88{(tx_rx_macro_dbg_sel[3:0] == 4'b1100)}} | 
                                dbg_D[87:0] & {88{(tx_rx_macro_dbg_sel[3:0] == 4'b1101)}} | 
                                 dbg_E[87:0] & {88{(tx_rx_macro_dbg_sel[3:0] == 4'b1110)}} | 
                                 dbg_F[87:0] & {88{(tx_rx_macro_dbg_sel[3:0] == 4'b1111)}} ;

//Miscellaneous (Orignal Trace Array)                          
assign dbg_0[87:0] =             {
                                  partial_flit_cnt_q[1:0],        //87:86
                                  partial_flit_enable_q,          //85
                                  partial_flit_q[67:64],          //84:81
                                  total_valid_q,                  //80
                                  next_idle16_q,                  //79
                                  idle_16_now_q,                  //78
                                  is_idle_64_dly_q,               //77
                                  is_cntl_dly_q,                  //76
                                  stalled_q,                      //75
                                  flit_cnt_q[3:0],                //74:71
                                  flit_cnt_enable_q,              //70
                                  is_replay_dly_q,                //69
                                  replay_pending_q,               //68
                                  replay_ip_q,                    //67
                                  replay_idles_seen_q,            //66
                                  replay_flit_cnt_q[3:0],         //65:62
                                  replay_duplicates_q,            //61
                                  initial_replay_done_q,          //60           
                                  replay_flit_cnt_enable_q,       //59
                                  imitation_data_q,                //58
                                  crc_init_q,                     //57
                                  crc_nonzero_q,                  //56
                                  flit_error_int_q,               //55
                                  flit_vld_int_q,                 //54 
                                  rx_tx_crc_error_q,              //53
                                  rx_tx_nack_q,                   //52
                                  rx_tx_rx_ack_inc_q[3:0],        //51:48
                                  rx_tx_tx_ack_rtn_q[4:0],        //47:43
                                  rx_tx_tx_ack_ptr_vld_q,         //42
                                  rx_tx_tx_ack_ptr_q[6:0],        //41:35
                                  rx_curr_ptr_q[6:0],             //34:28 
                                  rx_ack_ptr_q[6:0],              //27:21
                                  possible_ptr_q[3:0],            //20:17
                                  agn_mn_ln_swap_q,               //16
                                  agn_mn_x2_mode_q[1:0],          //15:14
                                  agn_mn_x4_mode_q[1:0],          //13:12
                                  trn_dly1_q,                     //11
                                  rx_tx_ill_rl_q,                 //10
                                  four_cycle_cnt_q[2:0],          //9:7
                                  rx_reset_n_q,                   //6
                                  omi_enable_q,                   //5
                                  dead_cycle_cnt_q[3:0],          //4:1
                                  turn_off_vld_dead_cycle_dly_q   //0               
                                  };                         
//TL Interface Part 0 
assign dbg_1[87:0] = {
                         flit_vld_int_q                , //-- bit 87 (one cycle delayed)
                         flit_error_int_q              , //-- bit 86 (one cycle delayed)
                         dl2tl_flit_badcrc_int         , //-- bit 85
                         dl2tl_flit_act_int            , //-- bit 84 
                         dl2tl_idle_transition_trace_q , //-- bit 83
                         11'b00000000000               , //-- bits 82:72
                         partial_flit_pty_q[15:8]      , //-- bits 71:64 (one cycle delayed)
                         partial_flit_q[127:64]          //-- bits 63:0 (one cycle delayed)
};                              

//TL Interface Part 1 
assign dbg_2[87:0] = {
                         flit_vld_int_q                , //-- bit 87 (one cycle delayed)
                         flit_error_int_q              , //-- bit 86 (one cycle delayed)
                         dl2tl_flit_badcrc_int         , //-- bit 85
                         dl2tl_flit_act_int            , //-- bit 84 
                         dl2tl_idle_transition_trace_q , //-- bit 83
                         11'b00000000000               , //-- bits 82:72
                         partial_flit_pty_q[7:0]       , //-- bits 71:64 (one cycle delayed)
                         partial_flit_q[63:0]          //-- bits 63:0 (one cycle delayed) 
}; 

//AGN/TRN Interface Part 0                             
assign dbg_3[87:0] = {  
                          trn_mn_retrain          , //-- bit 87
                          trn_mn_trained          , //-- bit 86
                          short_idle_enable_q     , //-- bit 85
                          rx_reset_n              , //-- bit 84
                          chip_reset              , //-- bit 83
                          global_reset_control    , //-- bit 82
                          omi_enable              , //-- bit 81
                          1'b0                    , //-- bit 80 
                          total_valid_q           , //-- bit 79 (one cycle delayed)
                          agn_mn_x2_mode_q[1:0]   , //-- bits 78:77
                          agn_mn_x4_mode_q[1:0]   , //-- bits 76:75
                          agn_mn_ln_swap          , //-- bit 74
                          dead_cycle_finished     , //-- bit 73
                          ln_all_valid            , //-- bit 72
                          partial_flit_pty_q[15:8] , //-- bits 71:64 (one cycle delayed)
                          partial_flit_q[127:64]    //-- bits 63:0 (one cycle delayed)
};                             

//AGN/TRN Interface Part 1                             
assign dbg_4[87:0] = {  
                          trn_mn_retrain          , //-- bit 87
                          trn_mn_trained          , //-- bit 86
                          short_idle_enable_q     , //-- bit 85
                          rx_reset_n              , //-- bit 84
                          chip_reset              , //-- bit 83
                          global_reset_control    , //-- bit 82
                          omi_enable              , //-- bit 81
                          1'b0                    , //-- bit 80 
                          total_valid_q           , //-- bit 79 (one cycle delayed)
                          agn_mn_x2_mode_q[1:0]   , //-- bits 78:77
                          agn_mn_x4_mode_q[1:0]   , //-- bits 76:75
                          agn_mn_ln_swap          , //-- bit 74
                          dead_cycle_finished     , //-- bit 73
                          ln_all_valid            , //-- bit 72
                          partial_flit_pty_q[7:0] , //-- bits 71:64 (one cycle delayed)
                          partial_flit_q[63:0]      //-- bits 63:0 (one cycle delayed)
};                             

//TX interface part 0
assign dbg_5[87:0] = { 
                            rx_tx_crc_error_q        , //-- bit 87
                            rx_tx_nack_q             , //-- bit 86
                            rx_tx_recal_status_q[1:0], //-- bits 85:84
                            rx_tx_pm_status_q[3:0]   , //-- bits 83:80
                            rx_tx_rx_ack_inc_q[3:0]  , //-- bits 79:76
                            rx_tx_tx_ack_rtn_q[4:0]  , //-- bits 75:71
                            rx_tx_tx_ack_ptr_vld_q   , //-- bit 70
                            rx_tx_tx_ack_ptr_q[11:0] , //-- bits 69:58
                            rx_tx_mn_trn_in_replay_q , //-- bit 57
                            rx_tx_ill_rl_q           , //-- bit 56
                            rx_tx_data_flt_q         , //-- bit 55
                            rx_tx_ctl_flt_int        , //-- bit 54
                            rx_tx_rpl_flt_int        , //-- bit 53
                            rx_tx_idle_flt_int       , //-- bit 52
                            tx_rx_tsm[2:0]           , //-- bits 51:49 
                            9'b000000000             , //-- bits 48:40
                            rx_tx_rmt_error_q[7:0]   , //-- bits 39:32 
                            rx_tx_rmt_message_q[63:32] //-- bits 31:0
};                           

//TX interface part 1
assign dbg_6[87:0] = { 
                            rx_tx_crc_error_q        , //-- bit 87
                            rx_tx_nack_q             , //-- bit 86
                            rx_tx_recal_status_q[1:0], //-- bits 85:84
                            rx_tx_pm_status_q[3:0]   , //-- bits 83:80
                            rx_tx_rx_ack_inc_q[3:0]  , //-- bits 79:76
                            rx_tx_tx_ack_rtn_q[4:0]  , //-- bits 75:71
                            rx_tx_tx_ack_ptr_vld_q   , //-- bit 70
                            rx_tx_tx_ack_ptr_q[11:0] , //-- bits 69:58
                            rx_tx_mn_trn_in_replay_q , //-- bit 57
                            rx_tx_ill_rl_q           , //-- bit 56
                            rx_tx_data_flt_q         , //-- bit 55
                            rx_tx_ctl_flt_int        , //-- bit 54
                            rx_tx_rpl_flt_int        , //-- bit 53
                            rx_tx_idle_flt_int       , //-- bit 52
                            tx_rx_tsm[2:0]           , //-- bits 51:49 
                            9'b000000000             , //-- bits 48:40
                            rx_tx_rmt_error_q[7:0]   , //-- bits 39:32 
                            rx_tx_rmt_message_q[31:0]  //-- bits 31:0
}; 
         
//DL Content                  
assign dbg_7[87:0] = { 
                              is_cntl                                                                                            , //-- bit 87
                              is_replay                                                                                          , //-- bit 86
                              is_idle_16                                                                                         , //-- bit 85
                              is_idle_64                                                                                         , //-- bit 84
                              partial_flit_q[127:92]                                                                             , //-- bits 83:48 (crc) (idle,replay,ctl)
                              partial_flit_q[91:87]                                                                              , //-- bits 47:43 (ack rtn) (idle,replay,ctl)
                              partial_flit_q[86:85]                                                                              , //-- bits 42:41 (recal info) (idle,replay,ctl)
                              partial_flit_q[84]                                                                                 , //-- bit 40 (nack) (replay)
                              partial_flit_q[83]                                                                                 , //-- bit 39 (stall) (idle,replay,ctl)
                              partial_flit_q[82]                                                                                 , //-- bit 38 (short_flit_next) (idle,replay,ctl)
                              pm_status_trace[3:0]                                                                               , //-- bits 37:34 (pm_status) (idle,replay)
                              partial_flit_q[71:68]                                                                              , //-- bits 33:30 (stall run length) (idle,replay)
                              partial_flit_q[67:64]                                                                              , //-- bits 29:26 (run length) (idle,replay,ctl)
                              partial_flit_q[59:48]                                                                              , //-- bits 25:14 (starting sequence number) (replay)
                              partial_flit_q[43:32]                                                                              , //-- bits 13:2 (ack sequence number) (replay) 
                              2'b00                                                                                                //-- bits 1:0
};                                                                                                                              
                                                                                                                                   
                                                                                                                                   
//Fast Act Data                                                                                                                                   
assign dbg_8[87:0] = {           
                               52'b0000000000000000000000000000000000000000000000000000                           , //-- bits 87:36
                               dl2tl_idle_transition_trace_q                                                      , //-- bit 35 (one cycle before fast act info due to latch)
                               partial_flit_q[67:33]                                                                //-- bits 34:0 (one cycle delayed compared to idle transition)
 }; 

//Pointers/Important counters                                                         
assign dbg_9[87:0] = { 
                                rx_tx_rx_ack_inc_q[3:0]   , //-- bits 87:84
                                rx_tx_tx_ack_ptr_vld_q    , //-- bits 83
                                rx_tx_tx_ack_ptr_q[11:0]  , //-- bits 82:71
                                rx_tx_tx_ack_rtn_q[4:0]   , //-- bits 70:66
                                ack_cnt_q[3:0]            , //-- bits 65:62
                                good_flits_rcvd_q[3:0]    , //-- bits 61:58
                                rx_curr_ptr_q[11:0]       , //-- bits 57:46
                                rx_ack_ptr_q[11:0]        , //-- bits 45:34
                                ptr_chk[11:0]             , //-- bits 33:22
                                tx_ack_inc[3:0]           , //-- bits 21:18
                                possible_ptr_q[3:0]       , //-- bits 17:14
                                partial_flit_cnt_q[1:0]   , //-- bits 13:12
                                flit_cnt_q[3:0]           , //-- bits 11:8 
                                replay_flit_cnt_q[3:0]    , //-- bits 7:4
                                dead_cycle_cnt_q[3:0]       //-- bits 3:0   
};

//Power Management                              
assign dbg_A[87:0] = { 
                                  total_valid_q,               //bit 87
                                  is_idle_16,                  //bit 86
                                  is_idle_64,                  //bit 85
                                  is_replay,                   //bit 84
                                  rx_tx_pm_status_q[3:0],      //bit 83:80
                                  rx_tx_recal_status_q[1:0],   //bit 79:78
                                  start_dead_cycle,            //bit 77
                                  dead_cycle_cnt_q[3:0],       //bit 76:73
                                  dead_cycle_crc_error,        //bit 72
                                  dead_cycle_finished,         //bit 71
                                  mode_x8,                     //bit 70
                                  mode_x4,                     //bit 69
                                  mode_x2,                     //bit 68
                                  turn_off_vld_dead_cycle,     //bit 67
                                  67'h0                        //bit 66:0 
};

//Replay                             
assign dbg_B[87:0] = { 
                                    total_valid_q,              //87
                                    replay_ip_q,                //86
                                    crc_init_q,                 //85
                                    crc_nonzero_q,              //84
                                    seen_first_replay,          //83
                                    replay_pending_q,           //82
                                    replay_idles_seen_q,        //81
                                    short_idle_enable_q,        //80
                                    crc_error_replay_q,         //79
                                    replay_flit_crc_error_q,    //78
                                    initial_replay_ip_q,        //77
                                    initial_replay_pending_q,   //76
                                    replay_flit_cnt_q[3:0],     //75:72
                                    imitation_data,             //71 
                                    is_replay,                  //70
                                    replay_duplicates_q,        //69
                                    rx_curr_ptr_q[11:0],        //68:57
                                    rx_ack_ptr_q[11:0],         //56:45
                                    partial_flit_q[84],         //44 (nack)
                                    early_replay_run_length,    //43
                                    43'h0                       //42:0
};  

                                   
                                  

//Reserved                            
assign dbg_C[87:0] = 88'h0;                             

//Reserved                            
assign dbg_D[87:0] = 88'h0;                             

//Reserved                            
assign dbg_E[87:0] = 88'h0;                             

//Reserved                            
assign dbg_F[87:0] = 88'h0;                             
                             
                             
                             
                             
                             
                             

//latch statements
//Enable signals for clock gating
//12/12assign cg_ena = trn_dly3_q & omi_enable; //if link is trained this is enabled
//12/12assign cg_short_idle_ena = trn_dly3_q & trn_mn_short_idle_enable & omi_enable;
//12/12assign cg_ena_trn = trn_mn_trained & omi_enable;

assign omi_enable_din = omi_enable;
//  fix for retrain, will need to reconsider clock gating
assign cg_ena            = omi_enable; //if link is trained this is enabled
assign cg_short_idle_ena =  omi_enable;
assign cg_ena_trn        = omi_enable;

assign reset = global_reset_control ? rx_reset_n_q : ~chip_reset; // 12/20 & trn_mn_trained; 
//Latch mode signals from rx_align for debug bus
assign agn_mn_x4_mode_din[1:0] = agn_mn_x4_mode[1:0];
assign agn_mn_ln_swap_din = agn_mn_ln_swap;
assign agn_mn_x2_mode_din[1:0] = agn_mn_x2_mode[1:0];
//Delayed train signals 
assign trn_dly1_din = ln_all_valid ? trn_mn_trained : trn_dly1_q;
assign trn_dly2_din = ln_all_valid ? trn_dly1_q : trn_dly2_q;
assign trn_dly3_din = ln_all_valid ? trn_dly2_q : trn_dly3_q;

//Latch Instantiations
dlc_ff #(.width(1)  ,.rstv(0))  ff_reset_n               (.clk(dl_clk)  ,.reset_n(1'b1)        ,.enable(omi_enable)        ,.din(rx_reset_n_din)                ,.q(rx_reset_n_q)          );
//dlc_ff #(.width(1)  ,.rstv(0))  ff_long_idle_stall      (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena_trn)        ,.din(long_idle_stall_din)          ,.q(long_idle_stall_q)          );
dlc_ff #(.width(5)  ,.rstv(0))  ff_ln_all_valid_cnt      (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena_trn)        ,.din(ln_all_valid_cnt_din)          ,.q(ln_all_valid_cnt_q)          );
dlc_ff #(.width(4)  ,.rstv(0))  ff_dead_cycle_cnt      (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena_trn)        ,.din(dead_cycle_cnt_din)          ,.q(dead_cycle_cnt_q)          );
dlc_ff #(.width(1)  ,.rstv(0))  ff_turn_off_vld_dead_cycle_dly      (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena_trn)        ,.din(turn_off_vld_dead_cycle_dly_din)          ,.q(turn_off_vld_dead_cycle_dly_q)          );
dlc_ff #(.width(1)  ,.rstv(0))  ff_turn_off_vld_dead_cycle_dly2      (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena_trn)        ,.din(turn_off_vld_dead_cycle_dly2_din)          ,.q(turn_off_vld_dead_cycle_dly2_q)          );
dlc_ff #(.width(2)  ,.rstv(0))  ff_rx_tx_recal_status    (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena_trn)        ,.din(rx_tx_recal_status_din)          ,.q(rx_tx_recal_status_q)          );
dlc_ff #(.width(4)  ,.rstv(0))  ff_rx_tx_pm_status      (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena_trn)        ,.din(rx_tx_pm_status_din)          ,.q(rx_tx_pm_status_q)          );
dlc_ff #(.width(1)  ,.rstv(0))  ff_dl2tl_flit_act (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena_trn)        ,.din(dl2tl_flit_act_din)          ,.q(dl2tl_flit_act_q)          );
dlc_ff #(.width(1)  ,.rstv(0))  ff_dl2tl_flit_act_scan (.clk(dl_clk)  ,.reset_n(1'b1)    ,.enable(cg_ena_trn)        ,.din(dl2tl_flit_act_scan_din)          ,.q(dl2tl_flit_act_scan_q)          );
dlc_ff #(.width(1)  ,.rstv(0))  ff_dl2tl_idle_transition (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena_trn)        ,.din(dl2tl_idle_transition_din)          ,.q(dl2tl_idle_transition_q)          );
dlc_ff #(.width(1)  ,.rstv(0))  ff_dl2tl_idle_transition_int (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena_trn)        ,.din(dl2tl_idle_transition_int_din)          ,.q(dl2tl_idle_transition_int_q)          );
dlc_ff #(.width(1)  ,.rstv(0))  ff_dl2tl_idle_transition_l (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena_trn)        ,.din(dl2tl_idle_transition_l_din)          ,.q(dl2tl_idle_transition_l_q)          );
dlc_ff #(.width(1)  ,.rstv(0))  ff_dl2tl_idle_transition_l_int (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena_trn)        ,.din(dl2tl_idle_transition_l_int_din)          ,.q(dl2tl_idle_transition_l_int_q)          );
dlc_ff #(.width(1)  ,.rstv(0))  ff_dl2tl_idle_transition_r (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena_trn)        ,.din(dl2tl_idle_transition_r_din)          ,.q(dl2tl_idle_transition_r_q)          );
dlc_ff #(.width(1)  ,.rstv(0))  ff_dl2tl_idle_transition_r_int (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena_trn)        ,.din(dl2tl_idle_transition_r_int_din)          ,.q(dl2tl_idle_transition_r_int_q)          );
dlc_ff #(.width(1)  ,.rstv(0))  ff_dl2tl_idle_transition_trace_int (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena_trn)        ,.din(dl2tl_idle_transition_trace_din)          ,.q(dl2tl_idle_transition_trace_q)          );
dlc_ff #(.width(1)  ,.rstv(0))  ff_turn_off_valid_ill_rl (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena_trn)        ,.din(turn_off_valid_ill_rl_din)          ,.q(turn_off_valid_ill_rl_q)          );
dlc_ff #(.width(1)  ,.rstv(0))  ff_crc_error_replay      (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena_trn)        ,.din(crc_error_replay_din)          ,.q(crc_error_replay_q)          );
dlc_ff #(.width(1)  ,.rstv(0))  ff_short_idle_enable         (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena_trn)        ,.din(short_idle_enable_din)          ,.q(short_idle_enable_q)          );
dlc_ff #(.width(4)  ,.rstv(0))  ff_good_flits_rcvd       (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena_trn)        ,.din(good_flits_rcvd_din)          ,.q(good_flits_rcvd_q)          );
dlc_ff #(.width(1)  ,.rstv(0))  ff_replay_flit_crc_error (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena_trn)        ,.din(replay_flit_crc_error_din)          ,.q(replay_flit_crc_error_q)          );
dlc_ff #(.width(1)  ,.rstv(0))  ff_agn_mn_ln_swap        (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena_trn)        ,.din(agn_mn_ln_swap_din)          ,.q(agn_mn_ln_swap_q)          );
dlc_ff #(.width(2)  ,.rstv(0))  ff_agn_mn_x2_mode        (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena_trn)        ,.din(agn_mn_x2_mode_din) ,.q(agn_mn_x2_mode_q) );
dlc_ff #(.width(2)  ,.rstv(0))  ff_agn_mn_x4_mode  (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena_trn)        ,.din(agn_mn_x4_mode_din)    ,.q(agn_mn_x4_mode_q)    );
dlc_ff #(.width(1)  ,.rstv(0))  ff_trn_dly1                  (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena_trn)        ,.din(trn_dly1_din)                ,.q(trn_dly1_q)                );
dlc_ff #(.width(1)  ,.rstv(0))  ff_trn_dly2                  (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena_trn)        ,.din(trn_dly2_din)                ,.q(trn_dly2_q)                );
dlc_ff #(.width(1)  ,.rstv(0))  ff_trn_dly3                  (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena_trn)        ,.din(trn_dly3_din)                ,.q(trn_dly3_q)                );
dlc_ff #(.width(4)  ,.rstv(0))  ff_ack_cnt               (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena)            ,.din(ack_cnt_din)                 ,.q(ack_cnt_q)                 );
dlc_ff #(.width(1)  ,.rstv(0))  ff_replay_pending        (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena)            ,.din(replay_pending_din)          ,.q(replay_pending_q)          );
dlc_ff #(.width(1)  ,.rstv(0))  ff_crc_init              (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena_trn)            ,.din(crc_init_din)                ,.q(crc_init_q)                );
dlc_ff #(.width(36) ,.rstv(0))  ff_crc_bits              (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena)            ,.din(crc_bits_din)                ,.q(crc_bits_q)                );
dlc_ff #(.width(128),.rstv(0))  ff_partial_flit          (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena)            ,.din(partial_flit_din)            ,.q(partial_flit_q)            );
dlc_ff #(.width(16) ,.rstv(0))  ff_partial_flit_pty      (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena)            ,.din(partial_flit_pty_din)            ,.q(partial_flit_pty_q)            );
dlc_ff #(.width(2)  ,.rstv(0))  ff_partial_flit_cnt      (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena)            ,.din(partial_flit_cnt_din)        ,.q(partial_flit_cnt_q)        );
dlc_ff #(.width(1)  ,.rstv(0))  ff_partial_flit_enable   (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena)            ,.din(partial_flit_enable_din)     ,.q(partial_flit_enable_q)        );
dlc_ff #(.width(1)  ,.rstv(0))  ff_replay_flit_cnt_enable   (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena)            ,.din(replay_flit_cnt_enable_din)     ,.q(replay_flit_cnt_enable_q)        );
dlc_ff #(.width(1)  ,.rstv(0))  ff_flit_cnt_enable       (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena)            ,.din(flit_cnt_enable_din)     ,.q(flit_cnt_enable_q)        );
dlc_ff #(.width(4)  ,.rstv(0))  ff_flit_cnt              (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena)            ,.din(flit_cnt_din)                ,.q(flit_cnt_q)                );
dlc_ff #(.width(1)  ,.rstv(0))  ff_next_idle16           (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena)            ,.din(next_idle16_din)             ,.q(next_idle16_q)             );
dlc_ff #(.width(1)  ,.rstv(0))  ff_rx_tx_crc_error       (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena)            ,.din(rx_tx_crc_error_din)         ,.q(rx_tx_crc_error_q)         );
dlc_ff #(.width(1)  ,.rstv(0))  ff_rx_tx_crc_error_dly       (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena)            ,.din(rx_tx_crc_error_dly_din)         ,.q(rx_tx_crc_error_dly_q)         );
dlc_ff #(.width(1)  ,.rstv(0))  ff_rx_tx_nack            (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena)            ,.din(rx_tx_nack_din)              ,.q(rx_tx_nack_q)              );
dlc_ff #(.width(4)  ,.rstv(0))  ff_rx_tx_rx_ack_inc      (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena)            ,.din(rx_tx_rx_ack_inc_din)        ,.q(rx_tx_rx_ack_inc_q)        );
dlc_ff #(.width(5)  ,.rstv(0))  ff_rx_tx_tx_ack_rtn      (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena)            ,.din(rx_tx_tx_ack_rtn_din)        ,.q(rx_tx_tx_ack_rtn_q)        );
dlc_ff #(.width(1)  ,.rstv(0))  ff_rx_tx_tx_ack_ptr_vld  (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena)            ,.din(rx_tx_tx_ack_ptr_vld_din)    ,.q(rx_tx_tx_ack_ptr_vld_q)    );
//-- 8/21 dlc_ff #(.width(7)  ,.rstv(0))  ff_rx_tx_tx_ack_ptr      (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena)            ,.din(rx_tx_tx_ack_ptr_din)        ,.q(rx_tx_tx_ack_ptr_q)        );
dlc_ff #(.width(12) ,.rstv(0))  ff_rx_tx_tx_ack_ptr      (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena)            ,.din(rx_tx_tx_ack_ptr_din)        ,.q(rx_tx_tx_ack_ptr_q)        );
dlc_ff #(.width(8)  ,.rstv(0))  ff_rx_tx_rmt_error       (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena)            ,.din(rx_tx_rmt_error_din)         ,.q(rx_tx_rmt_error_q)         );
dlc_ff #(.width(64) ,.rstv(0))  ff_rx_tx_rmt_message     (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena)            ,.din(rx_tx_rmt_message_din)       ,.q(rx_tx_rmt_message_q)       );
dlc_ff #(.width(8)  ,.rstv(0))  ff_rx_tx_rmt_error_dly       (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena)            ,.din(rx_tx_rmt_error_dly_din)         ,.q(rx_tx_rmt_error_dly_q)         );
dlc_ff #(.width(64) ,.rstv(0))  ff_rx_tx_rmt_message_dly     (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena)            ,.din(rx_tx_rmt_message_dly_din)       ,.q(rx_tx_rmt_message_dly_q)       );
dlc_ff #(.width(32) ,.rstv(0))  ff_third_beat_replay_msg (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena)            ,.din(third_beat_replay_msg_din)   ,.q(third_beat_replay_msg_q)   );
dlc_ff #(.width(4)  ,.rstv(0))  ff_replay_flit_cnt       (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena)            ,.din(replay_flit_cnt_din)         ,.q(replay_flit_cnt_q)         );
dlc_ff #(.width(1)  ,.rstv(0))  ff_replay_ip             (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena)            ,.din(replay_ip_din)               ,.q(replay_ip_q)               );
dlc_ff #(.width(1)  ,.rstv(0))  ff_replay_ip_dly             (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena)            ,.din(replay_ip_dly_din)               ,.q(replay_ip_dly_q)               );
dlc_ff #(.width(1)  ,.rstv(0))  ff_replay_ip_dly2             (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena)            ,.din(replay_ip_dly2_din)               ,.q(replay_ip_dly2_q)               );
//-- 8/21 dlc_ff #(.width(7)  ,.rstv(0))  ff_rx_curr_ptr           (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena)            ,.din(rx_curr_ptr_din)             ,.q(rx_curr_ptr_q)             );
//-- 8/21 dlc_ff #(.width(7)  ,.rstv(0))  ff_rx_ack_ptr            (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena)            ,.din(rx_ack_ptr_din)              ,.q(rx_ack_ptr_q)              );
dlc_ff #(.width(12)  ,.rstv(0))  ff_rx_curr_ptr           (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena)            ,.din(rx_curr_ptr_din)             ,.q(rx_curr_ptr_q)             );
dlc_ff #(.width(12)  ,.rstv(0))  ff_rx_ack_ptr            (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena)            ,.din(rx_ack_ptr_din)              ,.q(rx_ack_ptr_q)              );
dlc_ff #(.width(4)  ,.rstv(0))  ff_possible_ptr            (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena)            ,.din(possible_ptr_din)              ,.q(possible_ptr_q)              );
dlc_ff #(.width(1)  ,.rstv(0))  ff_replay_duplicate_turn_on   (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena)            ,.din(replay_duplicate_turn_on_din)              ,.q(replay_duplicate_turn_on_q)              );
dlc_ff #(.width(1)  ,.rstv(0))  ff_replay_duplicates            (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena)            ,.din(replay_duplicates_din)              ,.q(replay_duplicates_q)              );
dlc_ff #(.width(1)  ,.rstv(0))  ff_replay_duplicates2            (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena)            ,.din(replay_duplicates2_din)              ,.q(replay_duplicates2_q)              );
dlc_ff #(.width(1)  ,.rstv(0))  ff_replay_duplicates3            (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena)            ,.din(replay_duplicates3_din)              ,.q(replay_duplicates3_q)              );
dlc_ff #(.width(1)  ,.rstv(0))  ff_flit_error_int            (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena)            ,.din(flit_error_int_din)              ,.q(flit_error_int_q)              );
dlc_ff #(.width(1)  ,.rstv(0))  ff_flit_vld_int            (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena)            ,.din(flit_vld_int_din)              ,.q(flit_vld_int_q)              );


dlc_ff #(.width(1)  ,.rstv(0))  ff_initial_replay_ip     (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena)            ,.din(initial_replay_ip_din)       ,.q(initial_replay_ip_q)       );
dlc_ff #(.width(1)  ,.rstv(0))  ff_initial_replay_pending(.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena_trn)        ,.din(initial_replay_pending_din)  ,.q(initial_replay_pending_q)  );
dlc_ff #(.width(1)  ,.rstv(0))  ff_initial_replay_done   (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena)            ,.din(initial_replay_done_din)     ,.q(initial_replay_done_q)     );
dlc_ff #(.width(1)  ,.rstv(0))  ff_total_valid           (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena)            ,.din(total_valid_din)             ,.q(total_valid_q)             );
dlc_ff #(.width(1)  ,.rstv(0))  ff_total_valid2           (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena)            ,.din(total_valid2_din)             ,.q(total_valid2_q)             );
dlc_ff #(.width(1)  ,.rstv(0))  ff_crc_nonzero           (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena)            ,.din(crc_nonzero_din)             ,.q(crc_nonzero_q)             );
dlc_ff #(.width(1)  ,.rstv(0))  ff_replay_idles              (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_short_idle_ena) ,.din(replay_idles_seen_din)       ,.q(replay_idles_seen_q)       );
dlc_ff #(.width(3)  ,.rstv(0))  ff_four_cycle_counter        (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena)            ,.din(four_cycle_cnt_din)          ,.q(four_cycle_cnt_q)          );
dlc_ff #(.width(1)  ,.rstv(0))  ff_is_replay_perf_mon             (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena)            ,.din(is_replay_perf_mon_din)               ,.q(is_replay_perf_mon_q)               );
dlc_ff #(.width(1)  ,.rstv(0))  ff_is_cntl_perf_mon               (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena)            ,.din(is_cntl_perf_mon_din)                 ,.q(is_cntl_perf_mon_q)                 );
dlc_ff #(.width(1)  ,.rstv(0))  ff_is_idle_64_perf_mon            (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena)            ,.din(is_idle_64_perf_mon_din)              ,.q(is_idle_64_perf_mon_q)              );
dlc_ff #(.width(1)  ,.rstv(0))  ff_is_idle_16_perf_mon            (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena)            ,.din(is_idle_16_perf_mon_din)              ,.q(is_idle_16_perf_mon_q)              );

dlc_ff #(.width(1)  ,.rstv(0))  ff_is_cntl_dly            (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena)            ,.din(is_cntl_dly_din)              ,.q(is_cntl_dly_q)              );
dlc_ff #(.width(1)  ,.rstv(0))  ff_is_replay_dly            (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena)            ,.din(is_replay_dly_din)              ,.q(is_replay_dly_q)              );
dlc_ff #(.width(1)  ,.rstv(0))  ff_is_idle_64_dly            (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena)            ,.din(is_idle_64_dly_din)              ,.q(is_idle_64_dly_q)              );
dlc_ff #(.width(1)  ,.rstv(0))  ff_is_idle_16_dly            (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena)            ,.din(is_idle_16_dly_din)              ,.q(is_idle_16_dly_q)              );
dlc_ff #(.width(1)  ,.rstv(0))  ff_idle_16_now            (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena)            ,.din(idle_16_now_din)              ,.q(idle_16_now_q)              );
dlc_ff #(.width(1)  ,.rstv(0))  ff_stall            (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena)            ,.din(stalled_din)              ,.q(stalled_q)              );
//Performance Counter/Error Checker Lathces
dlc_ff #(.width(1)  ,.rstv(0))  ff_perf_in_replay            (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena)            ,.din(rx_tx_mn_trn_in_replay_din)  ,.q(rx_tx_mn_trn_in_replay_q)  );
dlc_ff #(.width(1)  ,.rstv(0))  ff_perf_data_flt             (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena)            ,.din(rx_tx_data_flt_din)          ,.q(rx_tx_data_flt_q)          );
dlc_ff #(.width(1)  ,.rstv(0))  ff_error_ill_rl              (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena)            ,.din(rx_tx_ill_rl_din)            ,.q(rx_tx_ill_rl_q)            );
dlc_ff #(.width(1)  ,.rstv(0))  ff_error_ill_rl_dly              (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena)            ,.din(rx_tx_ill_rl_dly_din)            ,.q(rx_tx_ill_rl_dly_q)            );
dlc_ff #(.width(1)  ,.rstv(0))  ff_imitation_data        (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena)            ,.din(imitation_data_din)            ,.q(imitation_data_q)            );
dlc_ff #(.width(1)  ,.rstv(0))  ff_omi_enable            (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena)            ,.din(omi_enable_din)            ,.q(omi_enable_q)            );
//Spare Latches
dlc_ff_spare #(.width(1)  ,.rstv(0))  ff_spare00               (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena)            ,.din(spare00_din)                 ,.q(spare00_q)                 );
dlc_ff_spare #(.width(1)  ,.rstv(0))  ff_spare01               (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena)            ,.din(spare01_din)                 ,.q(spare01_q)                 );
dlc_ff_spare #(.width(1)  ,.rstv(0))  ff_spare02               (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena)            ,.din(spare02_din)                 ,.q(spare02_q)                 );
dlc_ff_spare #(.width(1)  ,.rstv(0))  ff_spare03               (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena)            ,.din(spare03_din)                 ,.q(spare03_q)                 );
dlc_ff_spare #(.width(1)  ,.rstv(0))  ff_spare04               (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena)            ,.din(spare04_din)                 ,.q(spare04_q)                 );
dlc_ff_spare #(.width(1)  ,.rstv(0))  ff_spare05               (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena)            ,.din(spare05_din)                 ,.q(spare05_q)                 );
dlc_ff_spare #(.width(1)  ,.rstv(0))  ff_spare06               (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena)            ,.din(spare06_din)                 ,.q(spare06_q)                 );
dlc_ff_spare #(.width(1)  ,.rstv(0))  ff_spare07               (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena)            ,.din(spare07_din)                 ,.q(spare07_q)                 );
dlc_ff_spare #(.width(1)  ,.rstv(0))  ff_spare08               (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena)            ,.din(spare08_din)                 ,.q(spare08_q)                 );
dlc_ff_spare #(.width(1)  ,.rstv(0))  ff_spare09               (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena)            ,.din(spare09_din)                 ,.q(spare09_q)                 );
dlc_ff_spare #(.width(1)  ,.rstv(0))  ff_spare10               (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena)            ,.din(spare10_din)                 ,.q(spare10_q)                 );
dlc_ff_spare #(.width(1)  ,.rstv(0))  ff_spare11               (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena)            ,.din(spare11_din)                 ,.q(spare11_q)                 );
dlc_ff_spare #(.width(1)  ,.rstv(0))  ff_spare12               (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena)            ,.din(spare12_din)                 ,.q(spare12_q)                 );
dlc_ff_spare #(.width(1)  ,.rstv(0))  ff_spare13               (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena)            ,.din(spare13_din)                 ,.q(spare13_q)                 );
dlc_ff_spare #(.width(1)  ,.rstv(0))  ff_spare14               (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena)            ,.din(spare14_din)                 ,.q(spare14_q)                 );
dlc_ff_spare #(.width(1)  ,.rstv(0))  ff_spare15               (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena)            ,.din(spare15_din)                 ,.q(spare15_q)                 );
dlc_ff_spare #(.width(1)  ,.rstv(0))  ff_spare16               (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena)            ,.din(spare16_din)                 ,.q(spare16_q)                 );
dlc_ff_spare #(.width(1)  ,.rstv(0))  ff_spare17               (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena)            ,.din(spare17_din)                 ,.q(spare17_q)                 );
dlc_ff_spare #(.width(1)  ,.rstv(0))  ff_spare18               (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena)            ,.din(spare18_din)                 ,.q(spare18_q)                 );
dlc_ff_spare #(.width(1)  ,.rstv(0))  ff_spare19               (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena)            ,.din(spare19_din)                 ,.q(spare19_q)                 );


endmodule//--dlc_omi_rx_main
