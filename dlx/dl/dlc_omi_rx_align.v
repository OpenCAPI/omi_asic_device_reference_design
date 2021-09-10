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
module dlc_omi_rx_align (
//-- interface to the phy lanes
  ln_all_valid                   //--  input
 ,ln0_data                       //--  input  [15:0]
 ,ln1_data                       //--  input  [15:0]
 ,ln2_data                       //--  input  [15:0]
 ,ln3_data                       //--  input  [15:0]
 ,ln4_data                       //--  input  [15:0]
 ,ln5_data                       //--  input  [15:0]
 ,ln6_data                       //--  input  [15:0]
 ,ln7_data                       //--  input  [15:0]
 ,ln2_data_clone_l                 //--  input  [15:0]
 ,ln3_data_clone_l                 //--  input  [15:0]
 ,ln4_data_clone_l                 //--  input  [15:0]
 ,ln5_data_clone_l                 //--  input  [15:0]
 ,ln2_data_clone_r                 //--  input  [15:0]
 ,ln3_data_clone_r                 //--  input  [15:0]
 ,ln4_data_clone_r                 //--  input  [15:0]
 ,ln5_data_clone_r                 //--  input  [15:0]
 ,ln2_data_clone_c                 //--  input  [15:0]
 ,ln3_data_clone_c                 //--  input  [15:0]
 ,ln4_data_clone_c                 //--  input  [15:0]
 ,ln5_data_clone_c                 //--  input  [15:0]
 ,ln0_parity                     //--  input  [1:0]
 ,ln1_parity                     //--  input  [1:0]
 ,ln2_parity                     //--  input  [1:0]
 ,ln3_parity                     //--  input  [1:0]
 ,ln4_parity                     //--  input  [1:0]
 ,ln5_parity                     //--  input  [1:0]
 ,ln6_parity                     //--  input  [1:0]
 ,ln7_parity                     //--  input  [1:0]
 //Outputs to Rx main
 ,agn_mn_flit			 //--  output [127:0]
 ,agn_mn_flit_vld	         //--  output
 ,agn_mn_flit_pty                //--  output [15:0]
 ,agn_mn_ln_swap                 //--  output
 ,agn_mn_x4_mode                 //--  output [4:0]
 ,agn_mn_x2_mode                 //--  output [2:0]
 ,mn_agn_dead_cycle_reset        //-- input 
 ,dl2tl_fast_act_info            //-- output [34:0]
 ,dl2tl_fast_act_info_l          //-- output [34:0]
 ,dl2tl_fast_act_info_r          //-- output [34:0]
 ,dl_clk			 //--  input (clk)
 ,rx_reset_n			 //--  input
 ,chip_reset                     //--  Input
 ,global_reset_control           //--  Input
 ,trn_agn_trained                //--  input 
 ,trn_agn_retrain                //--  input 
 ,trn_agn_ln_swap		 //--  input    --Reverse Mode
 ,trn_agn_x2_mode                //--  input[1:0] 1: Outer 0: Inner
 ,trn_agn_x4_mode                //--  input[1:0] 1: Outer 0: Inner
 ,omi_enable                     //--  input
 ,tx_rx_tsm                      //-- input [2:0]
 ,tx_rx_inj_pty_err              //--  input  

);

//I/O declarations
input           ln_all_valid;
input  [15:0]   ln0_data;
input  [15:0]   ln1_data;
input  [15:0]   ln2_data;
input  [15:0]   ln3_data;
input  [15:0]   ln4_data;
input  [15:0]   ln5_data;
input  [15:0]   ln6_data;
input  [15:0]   ln7_data;
input  [15:0]   ln2_data_clone_l;
input  [15:0]   ln3_data_clone_l;
input  [15:0]   ln4_data_clone_l;
input  [15:0]   ln5_data_clone_l;
input  [15:0]   ln2_data_clone_r;
input  [15:0]   ln3_data_clone_r;
input  [15:0]   ln4_data_clone_r;
input  [15:0]   ln5_data_clone_r;
input  [15:0]   ln2_data_clone_c;
input  [15:0]   ln3_data_clone_c;
input  [15:0]   ln4_data_clone_c;
input  [15:0]   ln5_data_clone_c;
input  [1:0]    ln0_parity;
input  [1:0]    ln1_parity;
input  [1:0]    ln2_parity;
input  [1:0]    ln3_parity;
input  [1:0]    ln4_parity;
input  [1:0]    ln5_parity;
input  [1:0]    ln6_parity;
input  [1:0]    ln7_parity;
input 		dl_clk;
input 		rx_reset_n;
input           chip_reset;
input           global_reset_control;
input           trn_agn_trained;
input           trn_agn_retrain;
input 		trn_agn_ln_swap;
input  [1:0]    trn_agn_x2_mode;
input  [1:0]    trn_agn_x4_mode;
input           omi_enable;
output [34:0]   dl2tl_fast_act_info;
output [34:0]   dl2tl_fast_act_info_l;
output [34:0]   dl2tl_fast_act_info_r;
output [127:0]  agn_mn_flit;
output 		agn_mn_flit_vld;
output [15:0]   agn_mn_flit_pty;
output          agn_mn_ln_swap;                 
output [1:0]    agn_mn_x2_mode;           
output [1:0]    agn_mn_x4_mode;        
input           mn_agn_dead_cycle_reset;
input           tx_rx_inj_pty_err;
input [2:0]     tx_rx_tsm;



wire              tx_rx_inj_pty_err_din;
wire              tx_rx_inj_pty_err_q;
wire              slot6_parity_inj_din;
wire              slot6_parity_inj_q;
//Delayed Training Signal Wires
wire trn_dly1_din;
wire trn_dly1_q;
wire trn_dly2_din;
wire trn_dly2_q;
wire trn_dly3_din;
wire trn_dly3_q;
wire trn_dly4_din;
wire trn_dly4_q;
wire trn_dly5_din;
wire trn_dly5_q;
wire trn_dly6_din;
wire trn_dly6_q;
wire trn_dly7_din;
wire trn_dly7_q;
wire trn_dly8_din;
wire trn_dly8_q;
wire trn_dly9_din;
wire trn_dly9_q;
wire trn_dly10_din;
wire trn_dly10_q;
wire trn_dly11_din;
wire trn_dly11_q;
wire trn_dly12_din;
wire trn_dly12_q;
wire trn_dly13_din;
wire trn_dly13_q;
wire trn_dly14_din;
wire trn_dly14_q;
wire trn_dly15_din;
wire trn_dly15_q;
wire trn_dly16_din;
wire trn_dly16_q;
//Latch enable signals for clock gating
wire   cg_ena_trn;

//Latch wires
wire 		cg_ena;
wire 	[63:0]  x4_flit_din;
wire    [63:0]  x4_flit_q;
wire    [7:0]   x4_flit_pty_din;
wire    [7:0]   x4_flit_pty_q;		
wire    	odd_beat_din;
wire		odd_beat_q;
//internal Signals
wire   [15:0]   slot_7;
wire   [15:0]   slot_6;
wire   [15:0]   slot_5;
wire   [15:0]   slot_4;
wire   [15:0]   slot_3;
wire   [15:0]   slot_2;
wire   [15:0]   slot_1;
wire   [15:0]   slot_0;

//Fast act, take data from lanes before some of the muxing 
wire   [3:0]    fast_act_hi;
wire   [14:0]   fast_act_lo;
wire   [15:0]   fast_act_md;

wire   [3:0]    fast_act_hi_l;
wire   [14:0]   fast_act_lo_l;
wire   [15:0]   fast_act_md_l;

wire   [3:0]    fast_act_hi_r;
wire   [14:0]   fast_act_lo_r;
wire   [15:0]   fast_act_md_r;
//Parity Slots
wire   [1:0]    slot_7_pty;
wire   [1:0]    slot_6_pty;
wire   [1:0]    slot_5_pty;
wire   [1:0]    slot_4_pty;
wire   [1:0]    slot_3_pty;
wire   [1:0]    slot_2_pty;
wire   [1:0]    slot_1_pty;
wire   [1:0]    slot_0_pty;
wire 		total_valid;
// 4/10wire		beat_valid_din;
// 4/10wire		beat_valid_q;

//One Hot Latch wires
wire slot7_ln7_din;
wire slot7_ln7_q;
wire slot7_ln0_din;
wire slot7_ln0_q;
wire slot7_ln6_din;
wire slot7_ln6_q;
wire slot7_ln1_din;
wire slot7_ln1_q;
wire slot7_ln5_din;
wire slot7_ln5_q;
wire slot7_ln2_din;
wire slot7_ln2_q;

wire slot6_ln6_din;
wire slot6_ln6_q;
wire slot6_ln1_din;
wire slot6_ln1_q;
wire slot6_x4_63_48_din;
wire slot6_x4_63_48_q;
wire slot6_x4_15_0_din;
wire slot6_x4_15_0_q;
wire slot6_x2_31_16_din;
wire slot6_x2_31_16_q;
wire slot6_x2_15_0_din;
wire slot6_x2_15_0_q;

wire slot5_ln5_din;
wire slot5_ln5_q;
wire slot5_ln2_din;
wire slot5_ln2_q;
wire slot5_ln4_din;
wire slot5_ln4_q;
wire slot5_ln3_din;
wire slot5_ln3_q;
wire slot5_x4_63_48_din;
wire slot5_x4_63_48_q;
wire slot5_x4_31_16_din;
wire slot5_x4_31_16_q;

wire slot4_ln4_din;
wire slot4_ln4_q;
wire slot4_ln4_clone_l_din;
wire slot4_ln4_clone_l_q;
wire slot4_ln4_clone_r_din;
wire slot4_ln4_clone_r_q;
wire slot4_ln4_clone_c_din;
wire slot4_ln4_clone_c_q;
wire slot4_ln3_din;
wire slot4_ln3_q;
wire slot4_x4_47_32_din;
wire slot4_x4_47_32_q;
wire slot4_x4_31_16_din;
wire slot4_x4_31_16_q;
wire slot4_x4_15_0_din;
wire slot4_x4_15_0_q;

wire slot3_ln3_din;
wire slot3_ln3_q;
wire slot3_ln3_clone_l_din;
wire slot3_ln3_clone_l_q;
wire slot3_ln3_clone_r_din;
wire slot3_ln3_clone_r_q;
wire slot3_ln3_clone_c_din;
wire slot3_ln3_clone_c_q;
wire slot3_ln4_din;
wire slot3_ln4_q;
wire slot3_ln2_din;
wire slot3_ln2_q;
wire slot3_ln5_din;
wire slot3_ln5_q;
wire slot3_ln0_din;
wire slot3_ln0_q;
wire slot3_ln7_din;
wire slot3_ln7_q;

wire slot2_ln2_din;
wire slot2_ln2_q;
wire slot2_ln2_clone_l_din;
wire slot2_ln2_clone_l_q;
wire slot2_ln2_clone_r_din;
wire slot2_ln2_clone_r_q;
wire slot2_ln2_clone_c_din;
wire slot2_ln2_clone_c_q;
wire slot2_ln5_din;
wire slot2_ln5_q;
wire slot2_x4_47_32_din;
wire slot2_x4_47_32_q;
wire slot2_x4_31_16_din;
wire slot2_x4_31_16_q;
wire slot2_x2_31_16_din;
wire slot2_x2_31_16_q;
wire slot2_x2_15_0_din;
wire slot2_x2_15_0_q;

wire slot1_ln1_din;
wire slot1_ln1_q;
wire slot1_ln6_din;
wire slot1_ln6_q;
wire slot1_ln0_din;
wire slot1_ln0_q;
wire slot1_ln7_din;
wire slot1_ln7_q;
wire slot1_x4_63_48_din;
wire slot1_x4_63_48_q;
wire slot1_x4_31_16_din;
wire slot1_x4_31_16_q;

wire slot0_ln0_din;
wire slot0_ln0_q;
wire slot0_ln7_din;
wire slot0_ln7_q;
wire slot0_x4_63_48_din;
wire slot0_x4_63_48_q;
wire slot0_x4_47_32_din;
wire slot0_x4_47_32_q;
wire slot0_x4_15_0_din;
wire slot0_x4_15_0_q;



//Mode Signals
//x8 modes
wire mode_x8;
wire mode_x8_rev;

//X2/x4 New Modes
wire mode_x4;
wire mode_x2;
wire mode_x2_outer;
wire mode_x2_outer_rev;
wire mode_x2_inner;
wire mode_x2_inner_rev;
wire mode_x4_outer;
wire mode_x4_outer_rev;
wire mode_x4_inner;
wire mode_x4_inner_rev;
wire x4_flit_ln7520_din;
wire x4_flit_ln7520_q;
wire x4_flit_ln6431_din;
wire x4_flit_ln6431_q;
wire x2_flit_ln70_din;
wire x2_flit_ln70_q;
wire x2_flit_ln52_din;
wire x2_flit_ln52_q;
wire x2_x4_select;
wire x2_beat0;
wire x2_beat1;
wire x2_beat2;
wire x2_beat0_ln70;
wire x2_beat1_ln70;
wire x2_beat0_ln52;
wire x2_beat1_ln52;
wire [31:0] x2_beat2_data_din;
wire [31:0] x2_beat2_data_q;
wire [3:0]  x2_beat2_pty_din;
wire [3:0]  x2_beat2_pty_q;
wire [1:0]  x2_beat_cnt_din;
wire [1:0]  x2_beat_cnt_q;

wire odd_4thbeat_or_x8_din;
wire odd_4thbeat_or_x8_q;

wire rx_reset_n_din;
wire rx_reset_n_q;
wire reset_train;
wire reset;

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

assign spare00_din = |tx_rx_tsm[2:0];  
assign spare01_din = spare00_q;  
assign spare02_din = spare01_q;  
assign spare03_din = spare02_q;  
assign spare04_din = spare03_q;  
assign spare05_din = spare04_q;  
assign spare06_din = spare05_q;  
assign spare07_din = spare06_q;
  
assign rx_reset_n_din = rx_reset_n;

assign tx_rx_inj_pty_err_din = tx_rx_inj_pty_err;

//Mode Control Logic
//--  11/13 assign x4_neighbor_first = ~trn_agn_x4_spare_mode[3] & trn_agn_x4_odd_even_mode[2];
assign mode_x8           = trn_agn_x2_mode[1:0] == 2'b00 & trn_agn_x4_mode[1:0] == 2'b00 & ~trn_agn_ln_swap;
assign mode_x8_rev       = trn_agn_x2_mode[1:0] == 2'b00 & trn_agn_x4_mode[1:0] == 2'b00 &  trn_agn_ln_swap;
assign mode_x2_outer     = trn_agn_x2_mode[1:0] == 2'b10 & trn_agn_x4_mode[1:0] == 2'b00 & ~trn_agn_ln_swap;
assign mode_x2_outer_rev = trn_agn_x2_mode[1:0] == 2'b10 & trn_agn_x4_mode[1:0] == 2'b00 &  trn_agn_ln_swap;
assign mode_x2_inner     = trn_agn_x2_mode[1:0] == 2'b01 & trn_agn_x4_mode[1:0] == 2'b00 & ~trn_agn_ln_swap;
assign mode_x2_inner_rev = trn_agn_x2_mode[1:0] == 2'b01 & trn_agn_x4_mode[1:0] == 2'b00 &  trn_agn_ln_swap;
assign mode_x4_outer     = trn_agn_x2_mode[1:0] == 2'b00 & trn_agn_x4_mode[1:0] == 2'b10 & ~trn_agn_ln_swap;
assign mode_x4_outer_rev = trn_agn_x2_mode[1:0] == 2'b00 & trn_agn_x4_mode[1:0] == 2'b10 &  trn_agn_ln_swap;
assign mode_x4_inner     = trn_agn_x2_mode[1:0] == 2'b00 & trn_agn_x4_mode[1:0] == 2'b01 & ~trn_agn_ln_swap;
assign mode_x4_inner_rev = trn_agn_x2_mode[1:0] == 2'b00 & trn_agn_x4_mode[1:0] == 2'b01 &  trn_agn_ln_swap;

assign mode_x4 = mode_x4_outer | mode_x4_outer_rev | mode_x4_inner | mode_x4_inner_rev;

//Pass mode info to rx_main to be added to trace bus
assign agn_mn_x2_mode[1:0] = trn_agn_x2_mode[1:0];
assign agn_mn_x4_mode[1:0] = trn_agn_x4_mode[1:0];
assign agn_mn_ln_swap      = trn_agn_ln_swap;

// 4/10 assign beat_valid_din = total_valid ? ~trn_agn_x4_spare_mode[3] : beat_valid_q;
// 4/10 Do I use anywhere? assign beat_valid_din = total_valid ? ~(mode_x8 | mode_x8_rev) : beat_valid_q;
// 11/14assign odd_beat_din = beat_valid_q & ~odd_beat_q;
//-- 11/15 assign odd_beat_din = total_valid ? (beat_valid_q & ~odd_beat_q) : odd_beat_q; 
assign odd_beat_din = ~trn_agn_trained | mn_agn_dead_cycle_reset ? 1'b0          : 
                      total_valid                                ? (~odd_beat_q) : 
                                                                   odd_beat_q;
 
assign x2_beat_cnt_din[1:0] = ~trn_agn_trained | mn_agn_dead_cycle_reset ? 2'b00                  :
                              total_valid                                ? x2_beat_cnt_q[1:0] + 2'b01 :
                                                                           x2_beat_cnt_q[1:0]; 

//--  11/15 ignore 1 cycle of garbage data in x4 mode
//--  11/15 assign total_valid = ((trn_dly3_q & trn_agn_x4_spare_mode[3]) | (trn_dly7_q & ~trn_agn_x4_spare_mode[3])) & ln_all_valid;
//--  4/10 assign total_valid = ((trn_dly3_q & trn_agn_x4_spare_mode[3]) | (~mode_x2 & trn_dly8_q & ~trn_agn_x4_spare_mode[3]) | (trn_dly16_q & mode_x2)) & ln_all_valid;
assign total_valid = ((trn_dly3_q & (mode_x8 | mode_x8_rev)) | (~mode_x2 & trn_dly7_q & mode_x4) | (trn_dly15_q & mode_x2 & ~mode_x4)) & ln_all_valid;

//--  4/10assign odd_4thbeat_or_x8_din = (((~mode_x2 & odd_beat_din) | (mode_x2 & x2_beat_cnt_din==2'b11)) & ~trn_agn_retrain) | trn_agn_x4_spare_mode[3];
assign odd_4thbeat_or_x8_din = (((~mode_x2 & odd_beat_din) | (mode_x2 & x2_beat_cnt_din==2'b11)) & ~trn_agn_retrain) | (mode_x8 | mode_x8_rev);
//*****************Rx flit_out assignments*****************************

//--------------Important Information--------------

//Flit_out Bit Position: [127:112] [111:96] [95:80] [79:64] [63:48] [47:32] [31:16] [15:0]
//Slot Number:               7 	       6       5       4       3       2       1       0









//------Slot Muxing-------

//One hot latch assignments
//Slot 7 
assign slot7_ln7_din      = mode_x8 | mode_x4_outer | mode_x2_outer;
assign slot7_ln0_din      = mode_x8_rev | mode_x4_outer_rev | mode_x2_outer_rev;
assign slot7_ln6_din      = mode_x4_inner;
assign slot7_ln1_din      = mode_x4_inner_rev; 
assign slot7_ln5_din      = mode_x2_inner;
assign slot7_ln2_din      = mode_x2_inner_rev;

assign slot_7[15:0] =  (ln7_data[15:0]   & {16{slot7_ln7_q}})      | 
		       (ln0_data[15:0]   & {16{slot7_ln0_q}})      |
		       (ln6_data[15:0]   & {16{slot7_ln6_q}})      |
		       (ln1_data[15:0]   & {16{slot7_ln1_q}})      |
                       (ln5_data[15:0]   & {16{slot7_ln5_q}})      |
                       (ln2_data[15:0]   & {16{slot7_ln2_q}})      ;

assign slot_7_pty[1:0] = (ln7_parity[1:0]  & {2{slot7_ln7_q}})     | 		 
		         (ln0_parity[1:0]  & {2{slot7_ln0_q}})     |  		
		         (ln6_parity[1:0]  & {2{slot7_ln6_q}})     | 
		         (ln1_parity[1:0]  & {2{slot7_ln1_q}})     |
                         (ln5_parity[1:0]  & {2{slot7_ln5_q}})     | 
                         (ln2_parity[1:0]  & {2{slot7_ln2_q}})     ; 



//Slot 6
assign slot6_ln6_din      =mode_x8;
assign slot6_ln1_din      = mode_x8_rev;
assign slot6_x4_63_48_din = mode_x4_outer | mode_x4_inner;
assign slot6_x4_15_0_din  = mode_x4_outer_rev | mode_x4_inner_rev;
assign slot6_x2_31_16_din = mode_x2_outer | mode_x2_inner;
assign slot6_x2_15_0_din  = mode_x2_outer_rev | mode_x2_inner_rev;
assign slot6_parity_inj_din = (~tx_rx_inj_pty_err_q & tx_rx_inj_pty_err_din) | (slot6_parity_inj_q & ~total_valid); 


assign slot_6[15:0] = (ln6_data[15:0]         & {16{slot6_ln6_q}})      |
		      (ln1_data[15:0]         & {16{slot6_ln1_q}})      |
                      (x2_beat2_data_q[31:16] & {16{slot6_x2_31_16_q}}) |
		      (x2_beat2_data_q[15:0]  & {16{slot6_x2_15_0_q}})  |
                      (x4_flit_q[63:48]       & {16{slot6_x4_63_48_q}}) |
		      (x4_flit_q[15:0]        &  {16{slot6_x4_15_0_q}}); 

assign slot_6_pty[1:0] = (ln6_parity[1:0]     & {2{slot6_ln6_q}})      |
		         (ln1_parity[1:0]     & {2{slot6_ln1_q}})      |
                         (x2_beat2_pty_q[3:2] & {2{slot6_x2_31_16_q}}) |
                         (x2_beat2_pty_q[1:0] & {2{slot6_x2_15_0_q}})  |
		         (x4_flit_pty_q[7:6]  & {2{slot6_x4_63_48_q}}) |
 		         (x4_flit_pty_q[1:0]  & {2{slot6_x4_15_0_q}})  |
                         (ln2_parity[1:0]     &  {2{slot6_parity_inj_q}});  //Parity Error injection, takes wrong lanes parity bits

//Slot 5 
assign slot5_ln5_din      = mode_x8 | mode_x4_outer;
assign slot5_ln2_din      = mode_x8_rev | mode_x4_outer_rev;
assign slot5_ln4_din      = mode_x4_inner;
assign slot5_ln3_din      = mode_x4_inner_rev;
assign slot5_x4_63_48_din = mode_x2_outer | mode_x2_inner;
assign slot5_x4_31_16_din  = mode_x2_outer_rev | mode_x2_inner_rev;

assign slot_5[15:0] = (ln5_data[15:0]   & {16{slot5_ln5_q}})      |
		      (ln2_data[15:0]   & {16{slot5_ln2_q}})      |
                      (x4_flit_q[63:48] & {16{slot5_x4_63_48_q}}) |
		      (x4_flit_q[31:16]  & {16{slot5_x4_31_16_q}})  |
		      (ln4_data[15:0]   & {16{slot5_ln4_q}})      |
		      (ln3_data[15:0]   & {16{slot5_ln3_q}})      ;

assign slot_5_pty[1:0]  = (ln5_parity[1:0]    & {2{slot5_ln5_q}})      |
		          (ln2_parity[1:0]    & {2{slot5_ln2_q}})      | 
                          (x4_flit_pty_q[7:6] & {2{slot5_x4_63_48_q}}) |
		          (x4_flit_pty_q[3:2] & {2{slot5_x4_31_16_q}})  |
		          (ln4_parity[1:0]    & {2{slot5_ln4_q}})      |
		          (ln3_parity[1:0]    & {2{slot5_ln3_q}})      ;



//Slot 4 
assign slot4_ln4_din      = mode_x8;
assign slot4_ln4_clone_l_din      = mode_x8;
assign slot4_ln4_clone_r_din      = mode_x8;
assign slot4_ln4_clone_c_din      = mode_x8;
assign slot4_ln3_din      = mode_x8_rev;
assign slot4_x4_47_32_din = mode_x4_outer | mode_x2_outer | mode_x2_inner | mode_x4_inner;
//--  6/14assign slot4_x4_31_16_din = mode_x4_outer_rev | mode_x2_outer_rev | mode_x2_inner_rev | mode_x4_inner_rev;
assign slot4_x4_31_16_din = mode_x4_outer_rev | mode_x4_inner_rev;
assign slot4_x4_15_0_din  = mode_x2_outer_rev | mode_x2_inner_rev;
assign slot_4[15:0] = (ln4_data[15:0]    & {16{slot4_ln4_q}})      |
		      (ln3_data[15:0]    & {16{slot4_ln3_q}})      |
		      (x4_flit_q[47:32]  & {16{slot4_x4_47_32_q}}) |
		      (x4_flit_q[31:16]  & {16{slot4_x4_31_16_q}}) |
                      (x4_flit_q[15:0]   & {16{slot4_x4_15_0_q}}); 


assign slot_4_pty[1:0] = (ln4_parity[1:0]    & {2{slot4_ln4_q}})      |
		         (ln3_parity[1:0]    & {2{slot4_ln3_q}})      |
		         (x4_flit_pty_q[5:4] & {2{slot4_x4_47_32_q}}) |
		         (x4_flit_pty_q[3:2] & {2{slot4_x4_31_16_q}}) |
                         (x4_flit_pty_q[1:0] & {2{slot4_x4_15_0_q}}); 
//Slot 3 

assign slot3_ln3_din      = mode_x8 | mode_x4_inner;
assign slot3_ln3_clone_l_din      = mode_x8 | mode_x4_inner;
assign slot3_ln3_clone_r_din      = mode_x8 | mode_x4_inner;
assign slot3_ln3_clone_c_din      = mode_x8 | mode_x4_inner;
assign slot3_ln4_din      = mode_x8_rev | mode_x4_inner_rev;
assign slot3_ln2_din      = mode_x4_outer | mode_x2_inner;
assign slot3_ln5_din      = mode_x4_outer_rev | mode_x2_inner_rev;
assign slot3_ln0_din      = mode_x2_outer;
assign slot3_ln7_din      = mode_x2_outer_rev;

assign slot_3[15:0] = (ln3_data[15:0] & {16{slot3_ln3_q}}) |
		      (ln4_data[15:0] & {16{slot3_ln4_q}}) |
		      (ln2_data[15:0] & {16{slot3_ln2_q}}) |
		      (ln5_data[15:0] & {16{slot3_ln5_q}}) |
		      (ln0_data[15:0] & {16{slot3_ln0_q}}) |
		      (ln7_data[15:0] & {16{slot3_ln7_q}}) ;

assign slot_3_pty[1:0] = (ln3_parity[1:0] & {2{slot3_ln3_q}}) |
		         (ln4_parity[1:0] & {2{slot3_ln4_q}}) |
		         (ln2_parity[1:0] & {2{slot3_ln2_q}}) |
		         (ln5_parity[1:0] & {2{slot3_ln5_q}}) |
		         (ln0_parity[1:0] & {2{slot3_ln0_q}}) |
		         (ln7_parity[1:0] & {2{slot3_ln7_q}}) ;

//Slot 2 
assign slot2_ln2_din      = mode_x8; 
assign slot2_ln2_clone_l_din      = mode_x8; 
assign slot2_ln2_clone_r_din      = mode_x8; 
assign slot2_ln2_clone_c_din      = mode_x8; 
assign slot2_ln5_din      = mode_x8_rev; 
assign slot2_x2_31_16_din = mode_x2_outer_rev | mode_x2_inner_rev;
assign slot2_x2_15_0_din  = mode_x2_inner | mode_x2_outer;
assign slot2_x4_31_16_din = mode_x4_outer | mode_x4_inner;
assign slot2_x4_47_32_din = mode_x4_outer_rev | mode_x4_inner_rev;

assign slot_2[15:0] = (ln2_data[15:0]         & {16{slot2_ln2_q}})      |
		      (ln5_data[15:0]         & {16{slot2_ln5_q}})      |
		      (x4_flit_q[47:32]       & {16{slot2_x4_47_32_q}}) |
                      (x4_flit_q[31:16]       & {16{slot2_x4_31_16_q}}) |
		      (x2_beat2_data_q[31:16] & {16{slot2_x2_31_16_q}}) |
		      (x2_beat2_data_q[15:0]  & {16{slot2_x2_15_0_q}});  

assign slot_2_pty[1:0]  = (ln2_parity[1:0]      & {2{slot2_ln2_q}})      |
		          (ln5_parity[1:0]      & {2{slot2_ln5_q}})      |
		          (x4_flit_pty_q[5:4]   & {2{slot2_x4_47_32_q}}) |
                          (x4_flit_pty_q[3:2]   & {2{slot2_x4_31_16_q}}) |
		          (x2_beat2_pty_q[3:2] & {2{slot2_x2_31_16_q}}) |
		          (x2_beat2_pty_q[1:0] & {2{slot2_x2_15_0_q}}); 


//Slot 1
assign slot1_ln1_din      = mode_x8 | mode_x4_inner;
assign slot1_ln6_din      = mode_x8_rev | mode_x4_inner_rev;
assign slot1_ln0_din      = mode_x4_outer;
assign slot1_ln7_din      = mode_x4_outer_rev;
assign slot1_x4_63_48_din = mode_x2_inner_rev | mode_x2_outer_rev;
assign slot1_x4_31_16_din = mode_x2_inner | mode_x2_outer;

assign slot_1[15:0] = (ln1_data[15:0]   & {16{slot1_ln1_q}})      |
		      (ln6_data[15:0]   & {16{slot1_ln6_q}})      |
                      (ln0_data[15:0]   & {16{slot1_ln0_q}})      |
                      (ln7_data[15:0]   & {16{slot1_ln7_q}})      |
		      (x4_flit_q[63:48] & {16{slot1_x4_63_48_q}}) |
		      (x4_flit_q[31:16] & {16{slot1_x4_31_16_q}}) ;

assign slot_1_pty[1:0] = (ln1_parity[1:0]    & {2{slot1_ln1_q}})      |
		         (ln6_parity[1:0]    & {2{slot1_ln6_q}})      |
                         (ln0_parity[1:0]    & {2{slot1_ln0_q}})      |
                         (ln7_parity[1:0]    & {2{slot1_ln7_q}})      |
		         (x4_flit_pty_q[7:6] & {2{slot1_x4_63_48_q}}) |
		         (x4_flit_pty_q[3:2] & {2{slot1_x4_31_16_q}}) ;



//Slot 0
assign slot0_ln0_din      = mode_x8; 
assign slot0_ln7_din      = mode_x8_rev;

assign slot0_x4_15_0_din  = mode_x4_outer | mode_x4_inner | mode_x2_inner | mode_x2_outer;
//-- 6/19assign slot0_x4_63_48_din = mode_x4_outer_rev | mode_x4_inner_rev | mode_x2_inner_rev | mode_x2_outer_rev;
assign slot0_x4_63_48_din = mode_x4_outer_rev | mode_x4_inner_rev;
assign slot0_x4_47_32_din = mode_x2_outer_rev | mode_x2_inner_rev;


assign slot_0[15:0]=  (ln0_data[15:0]   & {16{slot0_ln0_q}})      |
		      (ln7_data[15:0]   & {16{slot0_ln7_q}})      |
		      (x4_flit_q[63:48] & {16{slot0_x4_63_48_q}}) |
		      (x4_flit_q[47:32] & {16{slot0_x4_47_32_q}}) |
		      (x4_flit_q[15:0]  & {16{slot0_x4_15_0_q}})  ;

assign slot_0_pty[1:0]  = (ln0_parity[1:0]    & {2{slot0_ln0_q}})      |
		          (ln7_parity[1:0]    & {2{slot0_ln7_q}})      |
		          (x4_flit_pty_q[7:6] & {2{slot0_x4_63_48_q}}) |
		          (x4_flit_pty_q[5:4] & {2{slot0_x4_47_32_q}}) |
		          (x4_flit_pty_q[1:0] & {2{slot0_x4_15_0_q}})  ;

//-- fast activate fast path
//---- only valid in x8 or x8 lane reversal
assign dl2tl_fast_act_info_l[34:0]   = {fast_act_hi_l[3:0], fast_act_md_l[15:0], fast_act_lo_l[14:0]};
assign dl2tl_fast_act_info_r[34:0]   = {fast_act_hi_r[3:0], fast_act_md_r[15:0], fast_act_lo_r[14:0]};
assign dl2tl_fast_act_info[34:0]   = {fast_act_hi[3:0], fast_act_md[15:0], fast_act_lo[14:0]};

assign fast_act_hi_l[3:0]  = slot4_ln4_clone_l_q ? ln4_data_clone_l[3:0]  : ln3_data_clone_l[3:0];
assign fast_act_md_l[15:0] = slot3_ln3_clone_l_q ? ln3_data_clone_l[15:0] : ln4_data_clone_l[15:0];
assign fast_act_lo_l[14:0] = slot2_ln2_clone_l_q ? ln2_data_clone_l[15:1] : ln5_data_clone_l[15:1];

assign fast_act_hi_r[3:0]  = slot4_ln4_clone_r_q ? ln4_data_clone_r[3:0]  : ln3_data_clone_r[3:0];
assign fast_act_md_r[15:0] = slot3_ln3_clone_r_q ? ln3_data_clone_r[15:0] : ln4_data_clone_r[15:0];
assign fast_act_lo_r[14:0] = slot2_ln2_clone_r_q ? ln2_data_clone_r[15:1] : ln5_data_clone_r[15:1];

assign fast_act_hi[3:0]  = slot4_ln4_clone_c_q ? ln4_data_clone_c[3:0]  : ln3_data_clone_c[3:0];
assign fast_act_md[15:0] = slot3_ln3_clone_c_q ? ln3_data_clone_c[15:0] : ln4_data_clone_c[15:0];
assign fast_act_lo[14:0] = slot2_ln2_clone_c_q ? ln2_data_clone_c[15:1] : ln5_data_clone_c[15:1];

//X4 Latch- Stores data on even beat of x4 modes. Below chart explains which slot's data is present in this latch on even beats (x4) or after the first two beats (x2) in each mode (number inside is slot number)		

//			  Bit [63:48]		[47:32]		[31:16]		[15:0]	
//MODES			 	
//x4                            6                  4               2               0 
//x4_rev                        0                  2               4               6 
//x2 (After First 2 Beats)      5                  4               1               0
//x2_rev (After first 2 beats)  0                  1               5		   4
 
assign x4_flit_ln7520_din = mode_x4_outer | mode_x4_outer_rev;
assign x4_flit_ln6431_din = mode_x4_inner | mode_x4_inner_rev;
assign x2_flit_ln70_din   = mode_x2_outer | mode_x2_outer_rev;
assign x2_flit_ln52_din   = mode_x2_inner | mode_x2_inner_rev;

assign mode_x2 = x2_flit_ln70_q | x2_flit_ln52_q;
assign x2_x4_select = mode_x2 ? ~x2_beat_cnt_q[1] : ~odd_beat_q;
assign x2_beat0 = x2_beat_cnt_q[1:0] == 2'b00;
assign x2_beat1 = x2_beat_cnt_q[1:0] == 2'b01;
assign x2_beat2 = x2_beat_cnt_q[1:0] == 2'b10;
assign x2_beat0_ln70 = x2_beat0 & x2_flit_ln70_q;
assign x2_beat1_ln70 = x2_beat1 & x2_flit_ln70_q;
assign x2_beat0_ln52 = x2_beat0 & x2_flit_ln52_q;
assign x2_beat1_ln52 = x2_beat1 & x2_flit_ln52_q;
//This x2 latch contains the third beat of x2 data (first two beats are stored in 64 bit x4 latch)
//Based off of the mode, the latch contains the following slot data
//                      Bits [31:16]           [15:0]
//Modes
//x2                     slot 6                  slot 2
//x2 rev                 slot 2                  slot 6

assign x2_beat2_data_din[31:0] = x2_beat2 ? 
                                 (({ln7_data[15:0] ,ln0_data[15:0]}  & {32{x2_flit_ln70_q}}) |
                                  ({ln5_data[15:0] ,ln2_data[15:0]}  & {32{x2_flit_ln52_q}})) : x2_beat2_data_q[31:0];

assign x2_beat2_pty_din[3:0]   = x2_beat2 ? 
                                 (({ln7_parity[1:0],ln0_parity[1:0]} & {4{x2_flit_ln70_q}})  |
                                  ({ln5_parity[1:0],ln2_parity[1:0]} & {4{x2_flit_ln52_q}})) : x2_beat2_pty_q[3:0];
//-- 4/3 adding x2 select logic assign x4_flit_din[63:0] = ~odd_beat_q ?
assign x4_flit_din[63:0] = x2_x4_select ?
                           (({ln7_data[15:0]  ,ln5_data[15:0]  ,ln2_data[15:0]  ,ln0_data[15:0]}    & {64{x4_flit_ln7520_q}})  |                             //x4, x4rev (power down lns 7,5,2,0)
                           ({ln6_data[15:0]  ,ln4_data[15:0]  ,ln3_data[15:0]  ,ln1_data[15:0]}    & {64{x4_flit_ln6431_q}})  |                             //x4, x4rev (power down lns 7,5,2,0)
                           ({x4_flit_q[63:48],ln7_data[15:0]  ,x4_flit_q[31:16]  ,ln0_data[15:0]}   & {64{x2_beat0_ln70}})          |                             //x2 beat0 (lns 7,0)
                           ({ln7_data[15:0]  ,x4_flit_q[47:32],ln0_data[15:0],x4_flit_q[15:0]}    & {64{x2_beat1_ln70}})          |                             //x2 beat1 (lns 7,0)
                           ({x4_flit_q[63:48],ln5_data[15:0]  ,x4_flit_q[31:16]  ,ln2_data[15:0]}   & {64{x2_beat0_ln52}})          |                             //x2 beat0 (lns 5,2)
                           ({ln5_data[15:0]  ,x4_flit_q[47:32],ln2_data[15:0],x4_flit_q[15:0]}    & {64{x2_beat1_ln52}}))        : x4_flit_q[63:0];             //x2 beat1 (lns 5,2)
                           
//-- 4/3 adding x2 select logic assign x4_flit_pty_din[7:0] = ~odd_beat_q ?
assign x4_flit_pty_din[7:0] = x2_x4_select ?
                           (({ln7_parity[1:0]   ,ln5_parity[1:0]   ,ln2_parity[1:0]   ,ln0_parity[1:0]}      & {8{x4_flit_ln7520_q}})  |                             //x4, rev (power down lns 7,5,2,0)
                           ({ln6_parity[1:0]   ,ln4_parity[1:0]   ,ln3_parity[1:0]   ,ln1_parity[1:0]}      & {8{x4_flit_ln6431_q}})  |                             //x4, x4rev (power down lns 6,4,3,1)
                           ({x4_flit_pty_q[7:6],ln7_parity[1:0]   ,x4_flit_pty_q[3:2]   ,ln0_parity[1:0]}   & {8{x2_beat0_ln70}})     |                             //x2 beat0 (lns 7,0)
                           ({ln7_parity[1:0]   ,x4_flit_pty_q[5:4],ln0_parity[1:0],x4_flit_pty_q[1:0]}      & {8{x2_beat1_ln70}})     |                             //x2 beat1 (lns 7,0) 
                           ({x4_flit_pty_q[7:6],ln5_parity[1:0]   ,x4_flit_pty_q[3:2]   ,ln2_parity[1:0]}   & {8{x2_beat0_ln52}})     |                             //x2 beat0 (lns 5,2)
                           ({ln5_parity[1:0]   ,x4_flit_pty_q[5:4],ln2_parity[1:0],x4_flit_pty_q[1:0]}      & {8{x2_beat1_ln52}}))    : x4_flit_pty_q[7:0];           //x2 beat1 (lns 5,2) 



assign agn_mn_flit[127:0] = {slot_7[15:0],slot_6[15:0],slot_5[15:0],slot_4[15:0],slot_3[15:0],slot_2[15:0],slot_1[15:0],slot_0[15:0]};
assign agn_mn_flit_pty[15:0] = {slot_7_pty[1:0],slot_6_pty[1:0],slot_5_pty[1:0],slot_4_pty[1:0],slot_3_pty[1:0],slot_2_pty[1:0],slot_1_pty[1:0],slot_0_pty[1:0]};
//11/3  assign agn_mn_flit_vld = trn_agn_x4_spare_mode[3] ? total_valid : odd_beat_q & total_valid;
assign agn_mn_flit_vld = odd_4thbeat_or_x8_q & total_valid;

assign cg_ena_trn = omi_enable;
assign cg_ena = omi_enable;
assign reset_train = rx_reset_n_q & trn_agn_trained;
assign reset = global_reset_control ? reset_train : ~chip_reset;
//Delayed train signals 
assign trn_dly1_din = ln_all_valid ? trn_agn_trained : trn_dly1_q; 
assign trn_dly2_din = ln_all_valid ? trn_dly1_q : trn_dly2_q;
assign trn_dly3_din = ln_all_valid ? trn_dly2_q : trn_dly3_q;
assign trn_dly4_din = ln_all_valid ? trn_dly3_q : trn_dly4_q;
assign trn_dly5_din = ln_all_valid ? trn_dly4_q : trn_dly5_q;
assign trn_dly6_din = ln_all_valid ? trn_dly5_q : trn_dly6_q;
assign trn_dly7_din = ln_all_valid ? trn_dly6_q : trn_dly7_q;
assign trn_dly8_din = ln_all_valid ? trn_dly7_q : trn_dly8_q;
assign trn_dly9_din = ln_all_valid ? trn_dly8_q : trn_dly9_q;
assign trn_dly10_din = ln_all_valid ? trn_dly9_q : trn_dly10_q;
assign trn_dly11_din = ln_all_valid ? trn_dly10_q : trn_dly11_q;
assign trn_dly12_din = ln_all_valid ? trn_dly11_q : trn_dly12_q;
assign trn_dly13_din = ln_all_valid ? trn_dly12_q : trn_dly13_q;
assign trn_dly14_din = ln_all_valid ? trn_dly13_q : trn_dly14_q;
assign trn_dly15_din = ln_all_valid ? trn_dly14_q : trn_dly15_q;
assign trn_dly16_din = ln_all_valid ? trn_dly15_q : trn_dly16_q;

//Latch Instantiations
dlc_ff #(.width(1)  ,.rstv(0))  ff_reset_n              (.clk(dl_clk)  ,.reset_n(1'b1)    ,.enable(omi_enable)     ,.din(rx_reset_n_din)                     ,.q(rx_reset_n_q)                     );
dlc_ff #(.width(1)  ,.rstv(0))  ff_trn_dly1              (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena_trn)     ,.din(trn_dly1_din)                     ,.q(trn_dly1_q)                     );
dlc_ff #(.width(1)  ,.rstv(0))  ff_trn_dly2              (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena_trn)     ,.din(trn_dly2_din)                     ,.q(trn_dly2_q)                     );
dlc_ff #(.width(1)  ,.rstv(0))  ff_trn_dly3              (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena_trn)     ,.din(trn_dly3_din)                     ,.q(trn_dly3_q)                     );
dlc_ff #(.width(1)  ,.rstv(0))  ff_trn_dly4              (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena_trn)     ,.din(trn_dly4_din)                     ,.q(trn_dly4_q)                     );
dlc_ff #(.width(1)  ,.rstv(0))  ff_trn_dly5              (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena_trn)     ,.din(trn_dly5_din)                     ,.q(trn_dly5_q)                     );
dlc_ff #(.width(1)  ,.rstv(0))  ff_trn_dly6              (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena_trn)     ,.din(trn_dly6_din)                     ,.q(trn_dly6_q)                     );
dlc_ff #(.width(1)  ,.rstv(0))  ff_trn_dly7              (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena_trn)     ,.din(trn_dly7_din)                     ,.q(trn_dly7_q)                     );
dlc_ff #(.width(1)  ,.rstv(0))  ff_trn_dly8              (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena_trn)     ,.din(trn_dly8_din)                     ,.q(trn_dly8_q)                     );
dlc_ff #(.width(1)  ,.rstv(0))  ff_trn_dly9              (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena_trn)     ,.din(trn_dly9_din)                     ,.q(trn_dly9_q)                     );
dlc_ff #(.width(1)  ,.rstv(0))  ff_trn_dly10             (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena_trn)     ,.din(trn_dly10_din)                     ,.q(trn_dly10_q)                     );
dlc_ff #(.width(1)  ,.rstv(0))  ff_trn_dly11             (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena_trn)     ,.din(trn_dly11_din)                     ,.q(trn_dly11_q)                     );
dlc_ff #(.width(1)  ,.rstv(0))  ff_trn_dly12             (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena_trn)     ,.din(trn_dly12_din)                     ,.q(trn_dly12_q)                     );
dlc_ff #(.width(1)  ,.rstv(0))  ff_trn_dly13             (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena_trn)     ,.din(trn_dly13_din)                     ,.q(trn_dly13_q)                     );
dlc_ff #(.width(1)  ,.rstv(0))  ff_trn_dly14             (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena_trn)     ,.din(trn_dly14_din)                     ,.q(trn_dly14_q)                     );
dlc_ff #(.width(1)  ,.rstv(0))  ff_trn_dly15             (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena_trn)     ,.din(trn_dly15_din)                     ,.q(trn_dly15_q)                     );
dlc_ff #(.width(1)  ,.rstv(0))  ff_trn_dly16             (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena_trn)     ,.din(trn_dly16_din)                     ,.q(trn_dly16_q)                     );

dlc_ff #(.width(2)  ,.rstv(0))  ff_x2_beat_cnt             (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena_trn)     ,.din(x2_beat_cnt_din)                     ,.q(x2_beat_cnt_q)                     );

dlc_ff #(.width(64)  ,.rstv(0))  ff_x4_flit_stg      		(.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena)    	,.din(x4_flit_din[63:0])            	        ,.q(x4_flit_q[63:0])                 	   );
dlc_ff #(.width(8)  ,.rstv(0))  ff_x4_flit_pty      		(.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena)    	,.din(x4_flit_pty_din[7:0])            	        ,.q(x4_flit_pty_q[7:0])                 	   );
dlc_ff #(.width(32)  ,.rstv(0))  ff_x2_beat2_data      		(.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena)    	,.din(x2_beat2_data_din[31:0])            	        ,.q(x2_beat2_data_q[31:0])                 	   );
dlc_ff #(.width(4)  ,.rstv(0))  ff_x2_beat2_pty      		(.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena)    	,.din(x2_beat2_pty_din[3:0])            	        ,.q(x2_beat2_pty_q[3:0])                 	   );
dlc_ff #(.width(1)  ,.rstv(0))  ff_odd_beat      		(.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena)    	,.din(odd_beat_din)            	        ,.q(odd_beat_q)                 	   );
//dlc_ff #(.width(1)  ,.rstv(0))  beat_valid      	(.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena)    	,.din(beat_valid_din)            	        ,.q(beat_valid_q)                 	   );

//One Hot Latches
dlc_ff #(.width(1)  ,.rstv(0))  ff_slot7_ln7      	(.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena_trn)    	,.din(slot7_ln7_din)            	        ,.q(slot7_ln7_q)                 	   );
dlc_ff #(.width(1)  ,.rstv(0))  ff_slot7_ln0      	(.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena_trn)    	,.din(slot7_ln0_din)            	        ,.q(slot7_ln0_q)                 	   );
dlc_ff #(.width(1)  ,.rstv(0))  ff_slot7_ln6      	(.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena_trn)    	,.din(slot7_ln6_din)            	        ,.q(slot7_ln6_q)                 	   );
dlc_ff #(.width(1)  ,.rstv(0))  ff_slot7_ln1      	(.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena_trn)    	,.din(slot7_ln1_din)            	        ,.q(slot7_ln1_q)                 	   );
dlc_ff #(.width(1)  ,.rstv(0))  ff_slot7_ln5      	(.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena_trn)    	,.din(slot7_ln5_din)            	        ,.q(slot7_ln5_q)                 	   );
dlc_ff #(.width(1)  ,.rstv(0))  ff_slot7_ln2      	(.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena_trn)    	,.din(slot7_ln2_din)            	        ,.q(slot7_ln2_q)                 	   );

dlc_ff #(.width(1)  ,.rstv(0))  ff_slot6_ln6      	(.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena_trn)    	,.din(slot6_ln6_din)            	        ,.q(slot6_ln6_q)                 	   );
dlc_ff #(.width(1)  ,.rstv(0))  ff_slot6_ln1      	(.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena_trn)    	,.din(slot6_ln1_din)            	        ,.q(slot6_ln1_q)                 	   );
dlc_ff #(.width(1)  ,.rstv(0))  ff_slot6_x4_63_48      	(.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena_trn)    	,.din(slot6_x4_63_48_din)            	        ,.q(slot6_x4_63_48_q)                 	   );
dlc_ff #(.width(1)  ,.rstv(0))  ff_slot6_x4_15_0      	(.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena_trn)    	,.din(slot6_x4_15_0_din)            	        ,.q(slot6_x4_15_0_q)                 	   );
dlc_ff #(.width(1)  ,.rstv(0))  ff_slot6_x2_31_16      	(.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena_trn)    	,.din(slot6_x2_31_16_din)            	        ,.q(slot6_x2_31_16_q)                 	   );
dlc_ff #(.width(1)  ,.rstv(0))  ff_slot6_x2_15_0      	(.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena_trn)    	,.din(slot6_x2_15_0_din)            	        ,.q(slot6_x2_15_0_q)                 	   );

dlc_ff #(.width(1)  ,.rstv(0))  ff_slot5_ln5      	(.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena_trn)    	,.din(slot5_ln5_din)            	        ,.q(slot5_ln5_q)                 	   );
dlc_ff #(.width(1)  ,.rstv(0))  ff_slot5_ln2      	(.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena_trn)    	,.din(slot5_ln2_din)            	        ,.q(slot5_ln2_q)                 	   );
dlc_ff #(.width(1)  ,.rstv(0))  ff_slot5_ln4      	(.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena_trn)    	,.din(slot5_ln4_din)            	        ,.q(slot5_ln4_q)                 	   );
dlc_ff #(.width(1)  ,.rstv(0))  ff_slot5_ln3      	(.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena_trn)    	,.din(slot5_ln3_din)            	        ,.q(slot5_ln3_q)                 	   );
dlc_ff #(.width(1)  ,.rstv(0))  ff_slot5_x4_63_48  (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena_trn)    	,.din(slot5_x4_63_48_din)            	        ,.q(slot5_x4_63_48_q)                 	   );
dlc_ff #(.width(1)  ,.rstv(0))  ff_slot5_x4_31_16  (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena_trn)    	,.din(slot5_x4_31_16_din)            	        ,.q(slot5_x4_31_16_q)                 	   );


dlc_ff #(.width(1)  ,.rstv(0))  ff_slot4_ln4      	(.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena_trn)    	,.din(slot4_ln4_din)            	        ,.q(slot4_ln4_q)                 	   );
dlc_ff #(.width(1)  ,.rstv(0))  ff_slot4_ln4_clone_l    (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena_trn)    	,.din(slot4_ln4_clone_l_din)            	,.q(slot4_ln4_clone_l_q)                   );
dlc_ff #(.width(1)  ,.rstv(0))  ff_slot4_ln4_clone_r    (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena_trn)    	,.din(slot4_ln4_clone_r_din)            	,.q(slot4_ln4_clone_r_q)                   );
dlc_ff #(.width(1)  ,.rstv(0))  ff_slot4_ln4_clone_c    (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena_trn)    	,.din(slot4_ln4_clone_c_din)            	,.q(slot4_ln4_clone_c_q)                   );
dlc_ff #(.width(1)  ,.rstv(0))  ff_slot4_ln3      	(.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena_trn)    	,.din(slot4_ln3_din)            	        ,.q(slot4_ln3_q)                 	   );
dlc_ff #(.width(1)  ,.rstv(0))  ff_slot4_x4_47_32      	(.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena_trn)    	,.din(slot4_x4_47_32_din)            	        ,.q(slot4_x4_47_32_q)                 	   );
dlc_ff #(.width(1)  ,.rstv(0))  ff_slot4_x4_31_16      	(.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena_trn)    	,.din(slot4_x4_31_16_din)            	        ,.q(slot4_x4_31_16_q)                 	   );
dlc_ff #(.width(1)  ,.rstv(0))  ff_slot4_x4_15_0      	(.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena_trn)    	,.din(slot4_x4_15_0_din)            	        ,.q(slot4_x4_15_0_q)                 	   );


dlc_ff #(.width(1)  ,.rstv(0))  ff_slot3_ln3      	(.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena_trn)    	,.din(slot3_ln3_din)            	        ,.q(slot3_ln3_q)                 	   );
dlc_ff #(.width(1)  ,.rstv(0))  ff_slot3_ln3_clone_l    (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena_trn)    	,.din(slot3_ln3_clone_l_din)            	,.q(slot3_ln3_clone_l_q)                   );
dlc_ff #(.width(1)  ,.rstv(0))  ff_slot3_ln3_clone_r    (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena_trn)    	,.din(slot3_ln3_clone_r_din)            	,.q(slot3_ln3_clone_r_q)                   );
dlc_ff #(.width(1)  ,.rstv(0))  ff_slot3_ln3_clone_c    (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena_trn)    	,.din(slot3_ln3_clone_c_din)            	,.q(slot3_ln3_clone_c_q)                   );
dlc_ff #(.width(1)  ,.rstv(0))  ff_slot3_ln4      	(.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena_trn)    	,.din(slot3_ln4_din)            	        ,.q(slot3_ln4_q)                 	   );
dlc_ff #(.width(1)  ,.rstv(0))  ff_slot3_ln2      	(.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena_trn)    	,.din(slot3_ln2_din)            	        ,.q(slot3_ln2_q)                 	   );
dlc_ff #(.width(1)  ,.rstv(0))  ff_slot3_ln5      	(.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena_trn)    	,.din(slot3_ln5_din)            	        ,.q(slot3_ln5_q)                 	   );
dlc_ff #(.width(1)  ,.rstv(0))  ff_slot3_ln0      	(.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena_trn)    	,.din(slot3_ln0_din)            	        ,.q(slot3_ln0_q)                 	   );
dlc_ff #(.width(1)  ,.rstv(0))  ff_slot3_ln7      	(.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena_trn)    	,.din(slot3_ln7_din)            	        ,.q(slot3_ln7_q)                 	   );

dlc_ff #(.width(1)  ,.rstv(0))  ff_slot2_ln2      	(.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena_trn)    	,.din(slot2_ln2_din)            	        ,.q(slot2_ln2_q)                 	   );
dlc_ff #(.width(1)  ,.rstv(0))  ff_slot2_ln2_clone_l    (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena_trn)    	,.din(slot2_ln2_clone_l_din)            	,.q(slot2_ln2_clone_l_q)                   );
dlc_ff #(.width(1)  ,.rstv(0))  ff_slot2_ln2_clone_r    (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena_trn)    	,.din(slot2_ln2_clone_r_din)            	,.q(slot2_ln2_clone_r_q)                   );
dlc_ff #(.width(1)  ,.rstv(0))  ff_slot2_ln2_clone_c    (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena_trn)    	,.din(slot2_ln2_clone_c_din)            	,.q(slot2_ln2_clone_c_q)                   );
dlc_ff #(.width(1)  ,.rstv(0))  ff_slot2_ln5       (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena_trn)    	,.din(slot2_ln5_din)            	        ,.q(slot2_ln5_q)                 	   );
dlc_ff #(.width(1)  ,.rstv(0))  ff_slot2_x4_47_32  (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena_trn)    	,.din(slot2_x4_47_32_din)            	        ,.q(slot2_x4_47_32_q)                 	   );
dlc_ff #(.width(1)  ,.rstv(0))  ff_slot2_x4_31_16  (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena_trn)    	,.din(slot2_x4_31_16_din)            	        ,.q(slot2_x4_31_16_q)                 	   );
dlc_ff #(.width(1)  ,.rstv(0))  ff_slot2_x2_31_16  (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena_trn)    	,.din(slot2_x2_31_16_din)            	        ,.q(slot2_x2_31_16_q)                 	   );
dlc_ff #(.width(1)  ,.rstv(0))  ff_slot2_x2_15_10  (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena_trn)    	,.din(slot2_x2_15_0_din)            	        ,.q(slot2_x2_15_0_q)                 	   );

dlc_ff #(.width(1)  ,.rstv(0))  ff_slot1_ln1      	(.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena_trn)    	,.din(slot1_ln1_din)            	        ,.q(slot1_ln1_q)                 	   );
dlc_ff #(.width(1)  ,.rstv(0))  ff_slot1_ln6      	(.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena_trn)    	,.din(slot1_ln6_din)            	        ,.q(slot1_ln6_q)                 	   );
dlc_ff #(.width(1)  ,.rstv(0))  ff_slot1_ln0      	(.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena_trn)    	,.din(slot1_ln0_din)            	        ,.q(slot1_ln0_q)                 	   );
dlc_ff #(.width(1)  ,.rstv(0))  ff_slot1_ln7      	(.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena_trn)    	,.din(slot1_ln7_din)            	        ,.q(slot1_ln7_q)                 	   );
dlc_ff #(.width(1)  ,.rstv(0))  ff_slot1_x4_63_48     	(.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena_trn)    	,.din(slot1_x4_63_48_din)            	        ,.q(slot1_x4_63_48_q)                 	   );
dlc_ff #(.width(1)  ,.rstv(0))  ff_slot1_x4_31_16    	(.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena_trn)    	,.din(slot1_x4_31_16_din)            	        ,.q(slot1_x4_31_16_q)                 	   );

dlc_ff #(.width(1)  ,.rstv(0))  ff_slot0_ln0      	(.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena_trn)    	,.din(slot0_ln0_din)            	        ,.q(slot0_ln0_q)                 	   );
dlc_ff #(.width(1)  ,.rstv(0))  ff_slot0_ln7      	(.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena_trn)    	,.din(slot0_ln7_din)            	        ,.q(slot0_ln7_q)                 	   );
dlc_ff #(.width(1)  ,.rstv(0))  ff_slot0_x4_63_48      	(.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena_trn)    	,.din(slot0_x4_63_48_din)            	        ,.q(slot0_x4_63_48_q)                 	   );
dlc_ff #(.width(1)  ,.rstv(0))  ff_slot0_x4_47_32      	(.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena_trn)    	,.din(slot0_x4_47_32_din)            	        ,.q(slot0_x4_47_32_q)                 	   );
dlc_ff #(.width(1)  ,.rstv(0))  ff_slot0_x4_15_0      	(.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena_trn)    	,.din(slot0_x4_15_0_din)            	        ,.q(slot0_x4_15_0_q)                 	   );

dlc_ff #(.width(1)  ,.rstv(0))  ff_x4_flit_ln7520      	(.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena_trn)    	,.din(x4_flit_ln7520_din)            	        ,.q(x4_flit_ln7520_q)                 	   );
dlc_ff #(.width(1)  ,.rstv(0))  ff_x4_flit_ln6431      	(.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena_trn)    	,.din(x4_flit_ln6431_din)            	        ,.q(x4_flit_ln6431_q)                 	   );
dlc_ff #(.width(1)  ,.rstv(0))  ff_x2_flit_ln70      	(.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena_trn)    	,.din(x2_flit_ln70_din)            	        ,.q(x2_flit_ln70_q)                 	   );
dlc_ff #(.width(1)  ,.rstv(0))  ff_x2_flit_ln52      	(.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena_trn)    	,.din(x2_flit_ln52_din)            	        ,.q(x2_flit_ln52_q)                 	   );

//Parity Injectors

dlc_ff #(.width(1)  ,.rstv(0))  ff_inj_pty_err     	(.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena_trn)    	,.din(tx_rx_inj_pty_err_din)            	        ,.q(tx_rx_inj_pty_err_q)                 	   );
dlc_ff #(.width(1)  ,.rstv(0))  ff_slot6_parity_inj    	(.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena_trn)    	,.din(slot6_parity_inj_din)            	        ,.q(slot6_parity_inj_q)                 	   );
dlc_ff #(.width(1)  ,.rstv(0))  ff_odd_4thbeat_or_x8               (.clk(dl_clk)  ,.reset_n(reset)     ,.enable(cg_ena_trn)        ,.din(odd_4thbeat_or_x8_din)                            ,.q(odd_4thbeat_or_x8_q)                         );
//Spare Latches
//Spare Latches
dlc_ff_spare #(.width(1)  ,.rstv(0))  ff_spare00               (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena)            ,.din(spare00_din)                 ,.q(spare00_q)                 );
dlc_ff_spare #(.width(1)  ,.rstv(0))  ff_spare01               (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena)            ,.din(spare01_din)                 ,.q(spare01_q)                 );
dlc_ff_spare #(.width(1)  ,.rstv(0))  ff_spare02               (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena)            ,.din(spare02_din)                 ,.q(spare02_q)                 );
dlc_ff_spare #(.width(1)  ,.rstv(0))  ff_spare03               (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena)            ,.din(spare03_din)                 ,.q(spare03_q)                 );
dlc_ff_spare #(.width(1)  ,.rstv(0))  ff_spare04               (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena)            ,.din(spare04_din)                 ,.q(spare04_q)                 );
dlc_ff_spare #(.width(1)  ,.rstv(0))  ff_spare05               (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena)            ,.din(spare05_din)                 ,.q(spare05_q)                 );
dlc_ff_spare #(.width(1)  ,.rstv(0))  ff_spare06               (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena)            ,.din(spare06_din)                 ,.q(spare06_q)                 );
dlc_ff_spare #(.width(1)  ,.rstv(0))  ff_spare07               (.clk(dl_clk)  ,.reset_n(reset)    ,.enable(cg_ena)            ,.din(spare07_din)                 ,.q(spare07_q)                 );

endmodule //dlc_omi_rx_align



