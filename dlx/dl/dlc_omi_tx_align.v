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
module dlc_omi_tx_align #(
parameter             RX_EQ_TX_CLK = 0
) (

//-- data from flit
  flt_agn_data                  //-- input  [127:0]
                       
//-- control information
 ,trn_agn_train_done            //-- input
 ,trn_agn_half_width            //-- input
 ,trn_agn_ln_swap               //-- input
 ,trn_agn_x2_mode               //-- input  [1:0]
 ,trn_agn_x4_mode               //-- input  [1:0]
 ,trn_agn_training              //-- input  
 ,trn_agn_training_set          //-- input  [127:0]
 ,trn_agn_stall                 //-- input                         
 ,trn_agn_send_TS1              //-- input [7:0]
 ,trn_agn_PM_store_reset        //-- input
 ,trn_enable                    //-- input                           
 ,trn_reset_n                   //-- input                         
 ,chip_reset                    //-- input
 ,global_reset_control          //-- input
//-- signal to lane
 ,agn_ln7_next_2B               //-- output [15:0]
 ,agn_ln6_next_2B               //-- output [15:0]
 ,agn_ln5_next_2B               //-- output [15:0]
 ,agn_ln4_next_2B               //-- output [15:0]
 ,agn_ln3_next_2B               //-- output [15:0]
 ,agn_ln2_next_2B               //-- output [15:0]
 ,agn_ln1_next_2B               //-- output [15:0]
 ,agn_ln0_next_2B               //-- output [15:0]

 ,dl_clk                        //-- input
);

input  [127:0]    flt_agn_data;
input             trn_agn_train_done;   
input             trn_agn_half_width;
input             trn_agn_ln_swap;
input  [1:0]      trn_agn_x2_mode;
input  [1:0]      trn_agn_x4_mode;
input             trn_agn_training;
input  [127:0]    trn_agn_training_set;
input             trn_agn_stall;
input [7:0]       trn_agn_send_TS1;
input             trn_agn_PM_store_reset;
input             trn_enable;
input             trn_reset_n;
input             chip_reset;
input             global_reset_control;
output [15:0]     agn_ln7_next_2B;
output [15:0]     agn_ln6_next_2B;
output [15:0]     agn_ln5_next_2B;
output [15:0]     agn_ln4_next_2B;
output [15:0]     agn_ln3_next_2B;
output [15:0]     agn_ln2_next_2B;
output [15:0]     agn_ln1_next_2B;
output [15:0]     agn_ln0_next_2B;

input             dl_clk;

wire               reset;
wire [7:0]         mode_x8;
wire [7:0]         mode_x8_rev;
wire [7:0]         mode_degraded;
wire [127:0]       stored_data_din;
wire [127:0]       stored_data_q;
wire [127:0]       training_set_din;
wire [127:0]       training_set_q;
wire [7:0]         sel_TS;
wire [7:0]         sel_TS_dly_din;
wire [7:0]         sel_TS_dly_q;
wire [15:0]        x4_data_ln7_1;
wire [15:0]        x4_data_ln6_1;
wire [15:0]        x4_data_ln5_1;
wire [15:0]        x4_data_ln4_1;
wire [15:0]        x4_data_ln3_1;
wire [15:0]        x4_data_ln2_1;
wire [15:0]        x4_data_ln1_1;
wire [15:0]        x4_data_ln0_1;
wire [15:0]        x4_data_ln7_2;
wire [15:0]        x4_data_ln6_2;
wire [15:0]        x4_data_ln5_2;
wire [15:0]        x4_data_ln4_2;
wire [15:0]        x4_data_ln3_2;
wire [15:0]        x4_data_ln2_2;
wire [15:0]        x4_data_ln1_2;
wire [15:0]        x4_data_ln0_2;
wire [4:0]         modes_active;
wire               error_multiple_modes_active;
wire               reset_n_din;
wire               reset_n_q;
wire [127:0]       training_set;
wire [127:0]       x8_data;
wire [127:0]       x8_rev_data;
wire [127:0]       x4_sel_data;
wire [127:0]       x4_data_1;
wire [127:0]       x4_data_2;
wire [1:0]         sel_mode_0;
wire [1:0]         sel_mode_1;
wire [1:0]         sel_mode_2;
wire [1:0]         sel_mode_3;
wire [1:0]         sel_mode_4;
wire [1:0]         sel_mode_5;
wire [1:0]         sel_mode_6;
wire [1:0]         sel_mode_7;
wire               store_data_din;
wire               store_data_q;
wire               spare_00_din;
wire               spare_01_din;
wire               spare_02_din;
wire               spare_03_din;
wire               spare_04_din;
wire               spare_05_din;
wire               spare_06_din;
wire               spare_07_din;
wire               spare_00_q;
wire               spare_01_q;
wire               spare_02_q;
wire               spare_03_q;
wire               spare_04_q;
wire               spare_05_q;
wire               spare_06_q;
wire               spare_07_q;
wire [15:0]        x2_data_ln0_1;
wire [15:0]        x2_data_ln0_2;
wire [15:0]        x2_data_ln0_3;
wire [15:0]        x2_data_ln0_4;
wire [15:0]        x2_data_ln2_1;
wire [15:0]        x2_data_ln2_2;
wire [15:0]        x2_data_ln2_3;
wire [15:0]        x2_data_ln2_4;
wire [15:0]        x2_data_ln5_1;
wire [15:0]        x2_data_ln5_2;
wire [15:0]        x2_data_ln5_3;
wire [15:0]        x2_data_ln5_4;
wire [15:0]        x2_data_ln7_1;
wire [15:0]        x2_data_ln7_2;
wire [15:0]        x2_data_ln7_3;
wire [15:0]        x2_data_ln7_4;
wire               mode_x2;
wire               mode_x2_outer;
wire               mode_x2_outer_rev;
wire               mode_x2_inner;
wire               mode_x2_inner_rev;
wire [127:0]       degraded_data;
wire [127:0]       x2_sel_data;
wire [127:0]       x2_data_1;
wire [127:0]       x2_data_2;
wire [127:0]       x2_data_3;
wire [127:0]       x2_data_4;
wire [1:0]         x2_sel_din;
wire [1:0]         x2_sel_q;
wire               x2_inner_enable;
wire               x2_outer_enable;
wire               mode_x4;
wire               store_data_toggle;
wire               mode_x4_inner;
wire               mode_x4_outer;
wire               mode_x4_inner_rev;
wire               mode_x4_outer_rev;
wire               x4_inner_enable;
wire               x4_outer_enable;
wire               train_done;
wire               train_done_dly_din;
wire               train_done_dly_q;
wire               PM_store_reset;

//------------------------------
//-- Muxing Structure
//------------------------------
//--
//-- Training Set and x2/x4 data leave a cycle late.  x8/x8_rev data pass straight through
//--
//--                              --> stored_data_q[127:0] ---> x4_sel_data[127:0] --| degraded_data[127:0] -->
//--                             /                         \--> x2_sel_data[127:0] --|                         \__
//--                            /                                                                                 |
//--        flt_agn_data[127:0] -----------------------------------------------------------> x8_data[127:0]------>| agn_ln[0-7]_next_2B[15:0]
//--                            \------------------------------------------------------> x8_data_rev[127:0]------>|
//--                                                                                                            __|
//--                                                                                                           /
//-- trn_agn_training_set[127:0]----> training_set_q[127:0] -------------------------------------------------->


assign modes_active[4:0] = {4'b0000, (|mode_x8[7:0])} + {4'b0000, (|mode_x8_rev[7:0])}
                         + {4'b0000,   mode_x4_inner} + {4'b0000,   mode_x4_inner_rev} + {4'b0000, mode_x4_outer} + {4'b0000, mode_x4_outer_rev}
                         + {4'b0000,   mode_x2_inner} + {4'b0000,   mode_x2_inner_rev} + {4'b0000, mode_x2_outer} + {4'b0000, mode_x2_outer_rev};

assign error_multiple_modes_active = (modes_active[4:0] > 5'b00001);

//-- disable is unique to a given lane
assign mode_x8[7:0]       = (~sel_TS[7:0]) & {8{~(mode_x4 | mode_x2    ) & ~trn_agn_ln_swap}};
assign mode_x8_rev[7:0]   = (~sel_TS[7:0]) & {8{~(mode_x4 | mode_x2    ) &  trn_agn_ln_swap}};
assign mode_degraded[7:0] = (~sel_TS[7:0]) &    ~(mode_x8[7:0] | mode_x8_rev[7:0]);

//------------------------------
//-- Transmit Mode Decodes from tx_train.v
//------------------------------
//--
assign x4_inner_enable    =  trn_agn_x4_mode[0] & trn_agn_half_width; //-- Lanes 1, 3, 4, 6
assign x4_outer_enable    =  trn_agn_x4_mode[1] & trn_agn_half_width; //-- Lanes 0, 2, 5, 7
assign mode_x4            =  x4_inner_enable | x4_outer_enable;

assign mode_x4_inner      = ~trn_agn_ln_swap & x4_inner_enable;
assign mode_x4_outer      = ~trn_agn_ln_swap & x4_outer_enable;
assign mode_x4_inner_rev  =  trn_agn_ln_swap & x4_inner_enable;
assign mode_x4_outer_rev  =  trn_agn_ln_swap & x4_outer_enable;


assign x2_inner_enable    =  trn_agn_x2_mode[0]; //-- Lanes 0 and 7
assign x2_outer_enable    =  trn_agn_x2_mode[1]; //-- Lanes 2 and 5
assign mode_x2            =  x2_inner_enable | x2_outer_enable;

assign mode_x2_inner      = ~trn_agn_ln_swap & x2_inner_enable;
assign mode_x2_outer      = ~trn_agn_ln_swap & x2_outer_enable;
assign mode_x2_inner_rev  =  trn_agn_ln_swap & x2_inner_enable;
assign mode_x2_outer_rev  =  trn_agn_ln_swap & x2_outer_enable;


//------------------------------
//-- Degraded Mode Mux Controls
//------------------------------
//--

//-- x4/x2 data is sent out the following cycle for timing; whereas, x8 passes straight through
//-- x4 stores data once every other cycle.  x2 stores new data once every 4 cycles
assign stored_data_din[127:0] = store_data_q   ? flt_agn_data[127:0] : stored_data_q[127:0];

//-- 4/25 assign store_data_din         =  trn_agn_training                   ? 1'b0 :              //-- reset to 0
//-- 4/25                                 ~trn_agn_stall & trn_agn_train_done ? store_data_toggle : //-- link is up.  Store data on correct cycle
//-- 4/25                                                                       store_data_q;       //-- hold when receiving a stall
//-- 4/25 
//-- 4/25 //-- invert store_data_q latch every other cycle when in x4 or every 4 cycles when in x2
//-- 4/25 assign store_data_toggle      = ~trn_agn_stall & trn_agn_train_done & 
//-- 4/25                                  ( ((mode_x2 & (x2_sel_q[1:0] == 2'b10)) & ~store_data_q) | 
//-- 4/25                                     (mode_x4                             & ~store_data_q) );
//-- 4/25 
//-- 4/25 assign x2_sel_din[1:0]        = trn_agn_training                   ?  2'b10 :                  //-- reset to 2
//-- 4/25                                ~trn_agn_stall & trn_agn_train_done ? (x2_sel_q[1:0] + 2'b01) : //-- link is up, send data every other cycle unless a stall happened
//-- 4/25                                                                       x2_sel_q[1:0];           //-- hold when receiving a stall
assign PM_store_reset         = trn_agn_PM_store_reset;
assign train_done             = trn_agn_train_done;
assign train_done_dly_din     = train_done;
assign init_train_done        = train_done & ~train_done_dly_q;

assign store_data_din         =  init_train_done | PM_store_reset ? 1'b1 :              //-- Store data right after initial linkup and on a stall
                                ~train_done                       ? 1'b0 :              //-- reset to 0
                                ~trn_agn_stall & train_done       ? store_data_toggle : //-- link is up.  Store data on correct cycle
                                                                    store_data_q;       //-- hold when receiving a stall

//-- invert store_data_q latch every other cycle when in x4 or every 4 cycles when in x2
assign store_data_toggle      = ~trn_agn_stall & train_done & 
                                 ( ((mode_x2 & (x2_sel_q[1:0] == 2'b10)) & ~store_data_q) | 
                                    (mode_x4                             & ~store_data_q) );

assign x2_sel_din[1:0]        = init_train_done | PM_store_reset     ?  2'b11 :                  //-- reset to 2
                               ~trn_agn_stall & train_done & mode_x2 ? (x2_sel_q[1:0] + 2'b01) : //-- link is up, send data every other cycle unless a stall happened
                                                                        x2_sel_q[1:0];           //-- hold when receiving a stall


//------------------------------
//-- Training Data
//------------------------------
//--
//-- TSX and Deskew Patterns
//--

//-- select mux to transmit training data.  Delay training signal a cycle to allow the TSX data to propagate through the training_set latch
assign sel_TS[7:0]             = {8{trn_agn_training}} | trn_agn_send_TS1[7:0];
assign sel_TS_dly_din[7:0]     = sel_TS[7:0];

assign training_set[127:0]     = trn_agn_training_set[127:0];
assign training_set_din[127:0] = training_set[127:0];


//------------------------------
//-- Aligned Data to Transmit
//------------------------------
//--

//-- Send flit x8 and x8_rev straight to output mux
assign x8_data[127:0]        =  flt_agn_data[127:0];
assign x8_rev_data[127:0]    = {flt_agn_data[15:0], flt_agn_data[31:16], flt_agn_data[47:32], flt_agn_data[63:48], flt_agn_data[79:64], flt_agn_data[95:80], flt_agn_data[111:96], flt_agn_data[127:112]};

//-- Piece the x4 chunks together to transmit
assign x4_data_1[127:0]      = {x4_data_ln7_1[15:0], x4_data_ln6_1[15:0], x4_data_ln5_1[15:0], x4_data_ln4_1[15:0], x4_data_ln3_1[15:0], x4_data_ln2_1[15:0], x4_data_ln1_1[15:0], x4_data_ln0_1[15:0]};
assign x4_data_2[127:0]      = {x4_data_ln7_2[15:0], x4_data_ln6_2[15:0], x4_data_ln5_2[15:0], x4_data_ln4_2[15:0], x4_data_ln3_2[15:0], x4_data_ln2_2[15:0], x4_data_ln1_2[15:0], x4_data_ln0_2[15:0]};
assign x4_sel_data[127:0]    = store_data_q ? x4_data_2[127:0] : x4_data_1[127:0];

//-- Piece the x2 chunks together to transmit
assign x2_data_1[127:0]      = {x2_data_ln7_1[15:0], 16'h0000, x2_data_ln5_1[15:0], 16'h0000, 16'h0000, x2_data_ln2_1[15:0], 16'h0000, x2_data_ln0_1[15:0]};
assign x2_data_2[127:0]      = {x2_data_ln7_2[15:0], 16'h0000, x2_data_ln5_2[15:0], 16'h0000, 16'h0000, x2_data_ln2_2[15:0], 16'h0000, x2_data_ln0_2[15:0]};
assign x2_data_3[127:0]      = {x2_data_ln7_3[15:0], 16'h0000, x2_data_ln5_3[15:0], 16'h0000, 16'h0000, x2_data_ln2_3[15:0], 16'h0000, x2_data_ln0_3[15:0]};
assign x2_data_4[127:0]      = {x2_data_ln7_4[15:0], 16'h0000, x2_data_ln5_4[15:0], 16'h0000, 16'h0000, x2_data_ln2_4[15:0], 16'h0000, x2_data_ln0_4[15:0]};

assign x2_sel_data[127:0]    = (x2_data_1[127:0] & {128{x2_sel_q[1:0] == 2'b00}}) |
                               (x2_data_2[127:0] & {128{x2_sel_q[1:0] == 2'b01}}) |
                               (x2_data_3[127:0] & {128{x2_sel_q[1:0] == 2'b10}}) |
                               (x2_data_4[127:0] & {128{x2_sel_q[1:0] == 2'b11}});

assign degraded_data[127:0]  = mode_x2 ? x2_sel_data[127:0] : x4_sel_data[127:0];

//-- output mux encode
assign sel_mode_0[1:0]       = (2'b00 & {2{mode_x8[0]      }}) |
                               (2'b01 & {2{mode_x8_rev[0]  }}) |
                               (2'b10 & {2{mode_degraded[0]}}) |
                               (2'b11 & {2{sel_TS_dly_q[0] }});
assign sel_mode_1[1:0]       = (2'b00 & {2{mode_x8[1]      }}) |
                               (2'b01 & {2{mode_x8_rev[1]  }}) |
                               (2'b10 & {2{mode_degraded[1]}}) |
                               (2'b11 & {2{sel_TS_dly_q[1] }});
assign sel_mode_2[1:0]       = (2'b00 & {2{mode_x8[2]      }}) |
                               (2'b01 & {2{mode_x8_rev[2]  }}) |
                               (2'b10 & {2{mode_degraded[2]}}) |
                               (2'b11 & {2{sel_TS_dly_q[2] }});
assign sel_mode_3[1:0]       = (2'b00 & {2{mode_x8[3]      }}) |
                               (2'b01 & {2{mode_x8_rev[3]  }}) |
                               (2'b10 & {2{mode_degraded[3]}}) |
                               (2'b11 & {2{sel_TS_dly_q[3] }});
assign sel_mode_4[1:0]       = (2'b00 & {2{mode_x8[4]      }}) |
                               (2'b01 & {2{mode_x8_rev[4]  }}) |
                               (2'b10 & {2{mode_degraded[4]}}) |
                               (2'b11 & {2{sel_TS_dly_q[4] }});
assign sel_mode_5[1:0]       = (2'b00 & {2{mode_x8[5]      }}) |
                               (2'b01 & {2{mode_x8_rev[5]  }}) |
                               (2'b10 & {2{mode_degraded[5]}}) |
                               (2'b11 & {2{sel_TS_dly_q[5] }});
assign sel_mode_6[1:0]       = (2'b00 & {2{mode_x8[6]      }}) |
                               (2'b01 & {2{mode_x8_rev[6]  }}) |
                               (2'b10 & {2{mode_degraded[6]}}) |
                               (2'b11 & {2{sel_TS_dly_q[6] }});
assign sel_mode_7[1:0]       = (2'b00 & {2{mode_x8[7]      }}) |
                               (2'b01 & {2{mode_x8_rev[7]  }}) |
                               (2'b10 & {2{mode_degraded[7]}}) |
                               (2'b11 & {2{sel_TS_dly_q[7] }});

generate 
if (RX_EQ_TX_CLK == 1) // OCMB Needs tx lane reversal taken out,  does not 
   begin
   assign agn_ln7_next_2B[15:0] = (       x8_data[127:112] & {16{sel_mode_0[1:0] == 2'b00}}) |
//                                (   x8_rev_data[127:112] & {16{sel_mode_0[1:0] == 2'b01}}) |
                                  ( degraded_data[127:112] & {16{sel_mode_0[1:0] == 2'b10}}) |
                                  (training_set_q[127:112] & {16{sel_mode_0[1:0] == 2'b11}});
   assign agn_ln6_next_2B[15:0] = (       x8_data[111: 96] & {16{sel_mode_1[1:0] == 2'b00}}) |
//                                (   x8_rev_data[111: 96] & {16{sel_mode_1[1:0] == 2'b01}}) |
                                  ( degraded_data[111: 96] & {16{sel_mode_1[1:0] == 2'b10}}) |
                                  (training_set_q[111: 96] & {16{sel_mode_1[1:0] == 2'b11}});
   assign agn_ln5_next_2B[15:0] = (       x8_data[ 95: 80] & {16{sel_mode_2[1:0] == 2'b00}}) |
//                                (   x8_rev_data[ 95: 80] & {16{sel_mode_2[1:0] == 2'b01}}) |
                                  ( degraded_data[ 95: 80] & {16{sel_mode_2[1:0] == 2'b10}}) |
                                  (training_set_q[ 95: 80] & {16{sel_mode_2[1:0] == 2'b11}});
   assign agn_ln4_next_2B[15:0] = (       x8_data[ 79: 64] & {16{sel_mode_3[1:0] == 2'b00}}) |
//                                (   x8_rev_data[ 79: 64] & {16{sel_mode_3[1:0] == 2'b01}}) |
                                  ( degraded_data[ 79: 64] & {16{sel_mode_3[1:0] == 2'b10}}) |
                                  (training_set_q[ 79: 64] & {16{sel_mode_3[1:0] == 2'b11}});
   assign agn_ln3_next_2B[15:0] = (       x8_data[ 63: 48] & {16{sel_mode_4[1:0] == 2'b00}}) |
//                                (   x8_rev_data[ 63: 48] & {16{sel_mode_4[1:0] == 2'b01}}) |
                                  ( degraded_data[ 63: 48] & {16{sel_mode_4[1:0] == 2'b10}}) |
                                  (training_set_q[ 63: 48] & {16{sel_mode_4[1:0] == 2'b11}});
   assign agn_ln2_next_2B[15:0] = (       x8_data[ 47: 32] & {16{sel_mode_5[1:0] == 2'b00}}) |
//                                (   x8_rev_data[ 47: 32] & {16{sel_mode_5[1:0] == 2'b01}}) |
                                  ( degraded_data[ 47: 32] & {16{sel_mode_5[1:0] == 2'b10}}) |
                                  (training_set_q[ 47: 32] & {16{sel_mode_5[1:0] == 2'b11}});
   assign agn_ln1_next_2B[15:0] = (       x8_data[ 31: 16] & {16{sel_mode_6[1:0] == 2'b00}}) |
//                                (   x8_rev_data[ 31: 16] & {16{sel_mode_6[1:0] == 2'b01}}) |
                                  ( degraded_data[ 31: 16] & {16{sel_mode_6[1:0] == 2'b10}}) |
                                  (training_set_q[ 31: 16] & {16{sel_mode_6[1:0] == 2'b11}});
   assign agn_ln0_next_2B[15:0] = (       x8_data[ 15:  0] & {16{sel_mode_7[1:0] == 2'b00}}) |
//                                (   x8_rev_data[ 15:  0] & {16{sel_mode_7[1:0] == 2'b01}}) |
                                  ( degraded_data[ 15:  0] & {16{sel_mode_7[1:0] == 2'b10}}) |
                                  (training_set_q[ 15:  0] & {16{sel_mode_7[1:0] == 2'b11}});

   //------------------------------
   //-- x4 Muxing
   //------------------------------
   //--
   //-- x4_data_ln[0-7]_[2B chunk]
   //--
   //-- Supported x4 modes
   //-- 1. mode_x4_inner    
   //-- 2. mode_x4_outer    
   //-- 3. mode_x4_inner_rev
   //-- 4. mode_x4_outer_rev
   //-- x4_inner_enable = Lanes 1, 3, 4, 6
   //-- x4_outer_enable = Lanes 0, 2, 5, 7

   //-- LANE 0
   assign x4_data_ln0_1[15:0] = stored_data_q[127:112] & {16{1'b0             }} |
//                              stored_data_q[111: 96] & {16{mode_x4_outer_rev}} |  
                                stored_data_q[ 95: 80] & {16{1'b0             }} |
                                stored_data_q[ 79: 64] & {16{1'b0             }} |
                                stored_data_q[ 63: 48] & {16{1'b0             }} |
                                stored_data_q[ 47: 32] & {16{1'b0             }} |
                                stored_data_q[ 31: 16] & {16{1'b0             }} |
                                stored_data_q[ 15:  0] & {16{mode_x4_outer    }};

   assign x4_data_ln0_2[15:0] = //stored_data_q[127:112] & {16{mode_x4_outer_rev}} |
                                stored_data_q[111: 96] & {16{1'b0             }} |  
                                stored_data_q[ 95: 80] & {16{1'b0             }} |
                                stored_data_q[ 79: 64] & {16{1'b0             }} |
                                stored_data_q[ 63: 48] & {16{1'b0             }} |
                                stored_data_q[ 47: 32] & {16{1'b0             }} |
                                stored_data_q[ 31: 16] & {16{mode_x4_outer    }} |
                                stored_data_q[ 15:  0] & {16{1'b0             }};

   //-- LANE 1
   assign x4_data_ln1_1[15:0] = stored_data_q[127:112] & {16{1'b0             }} |
//                              stored_data_q[111: 96] & {16{mode_x4_inner_rev}} |  
                                stored_data_q[ 95: 80] & {16{1'b0             }} |
                                stored_data_q[ 79: 64] & {16{1'b0             }} |
                                stored_data_q[ 63: 48] & {16{1'b0             }} |
                                stored_data_q[ 47: 32] & {16{1'b0             }} |
                                stored_data_q[ 31: 16] & {16{1'b0             }} |
                                stored_data_q[ 15:  0] & {16{mode_x4_inner    }};

   assign x4_data_ln1_2[15:0] = //stored_data_q[127:112] & {16{mode_x4_inner_rev}} |
                                stored_data_q[111: 96] & {16{1'b0             }} |  
                                stored_data_q[ 95: 80] & {16{1'b0             }} |
                                stored_data_q[ 79: 64] & {16{1'b0             }} |
                                stored_data_q[ 63: 48] & {16{1'b0             }} |
                                stored_data_q[ 47: 32] & {16{1'b0             }} |
                                stored_data_q[ 31: 16] & {16{mode_x4_inner    }} |
                                stored_data_q[ 15:  0] & {16{1'b0             }};

   //-- LANE 2
   assign x4_data_ln2_1[15:0] = stored_data_q[127:112] & {16{1'b0             }} |
                                stored_data_q[111: 96] & {16{1'b0             }} |  
                                stored_data_q[ 95: 80] & {16{1'b0             }} |
//                              stored_data_q[ 79: 64] & {16{mode_x4_outer_rev}} |
                                stored_data_q[ 63: 48] & {16{1'b0             }} |
                                stored_data_q[ 47: 32] & {16{mode_x4_outer    }} |
                                stored_data_q[ 31: 16] & {16{1'b0             }} |
                                stored_data_q[ 15:  0] & {16{1'b0             }};

   assign x4_data_ln2_2[15:0] = stored_data_q[127:112] & {16{1'b0             }} |
                                stored_data_q[111: 96] & {16{1'b0             }} |  
//                              stored_data_q[ 95: 80] & {16{mode_x4_outer_rev}} |
                                stored_data_q[ 79: 64] & {16{1'b0             }} |
                                stored_data_q[ 63: 48] & {16{mode_x4_outer    }} |
                                stored_data_q[ 47: 32] & {16{1'b0             }} |
                                stored_data_q[ 31: 16] & {16{1'b0             }} |
                                stored_data_q[ 15:  0] & {16{1'b0             }};

   //-- LANE 3
   assign x4_data_ln3_1[15:0] = stored_data_q[127:112] & {16{1'b0             }} |
                                stored_data_q[111: 96] & {16{1'b0             }} |  
                                stored_data_q[ 95: 80] & {16{1'b0             }} |
//                              stored_data_q[ 79: 64] & {16{mode_x4_inner_rev}} |
                                stored_data_q[ 63: 48] & {16{1'b0             }} |
                                stored_data_q[ 47: 32] & {16{mode_x4_inner    }} |
                                stored_data_q[ 31: 16] & {16{1'b0             }} |
                                stored_data_q[ 15:  0] & {16{1'b0             }};

   assign x4_data_ln3_2[15:0] = stored_data_q[127:112] & {16{1'b0             }} |
                                stored_data_q[111: 96] & {16{1'b0             }} |  
//                              stored_data_q[ 95: 80] & {16{mode_x4_inner_rev}} |
                                stored_data_q[ 79: 64] & {16{1'b0             }} |
                                stored_data_q[ 63: 48] & {16{mode_x4_inner    }} |
                                stored_data_q[ 47: 32] & {16{1'b0             }} |
                                stored_data_q[ 31: 16] & {16{1'b0             }} |
                                stored_data_q[ 15:  0] & {16{1'b0             }};

   //-- LANE 4
   assign x4_data_ln4_1[15:0] = stored_data_q[127:112] & {16{1'b0             }} |
                                stored_data_q[111: 96] & {16{1'b0             }} |  
                                stored_data_q[ 95: 80] & {16{1'b0             }} |
                                stored_data_q[ 79: 64] & {16{mode_x4_inner    }} |
                                stored_data_q[ 63: 48] & {16{1'b0             }} |
//                              stored_data_q[ 47: 32] & {16{mode_x4_inner_rev}} |
                                stored_data_q[ 31: 16] & {16{1'b0             }} |
                                stored_data_q[ 15:  0] & {16{1'b0             }};

   assign x4_data_ln4_2[15:0] = stored_data_q[127:112] & {16{1'b0             }} |
                                stored_data_q[111: 96] & {16{1'b0             }} |  
                                stored_data_q[ 95: 80] & {16{mode_x4_inner    }} |
                                stored_data_q[ 79: 64] & {16{1'b0             }} |
//                              stored_data_q[ 63: 48] & {16{mode_x4_inner_rev}} |
                                stored_data_q[ 47: 32] & {16{1'b0             }} |
                                stored_data_q[ 31: 16] & {16{1'b0             }} |
                                stored_data_q[ 15:  0] & {16{1'b0             }};

   //-- LANE 5
   assign x4_data_ln5_1[15:0] = stored_data_q[127:112] & {16{1'b0             }} |
                                stored_data_q[111: 96] & {16{1'b0             }} |  
                                stored_data_q[ 95: 80] & {16{1'b0             }} |
                                stored_data_q[ 79: 64] & {16{mode_x4_outer    }} |
                                stored_data_q[ 63: 48] & {16{1'b0             }} |
//                              stored_data_q[ 47: 32] & {16{mode_x4_outer_rev}} |
                                stored_data_q[ 31: 16] & {16{1'b0             }} |
                                stored_data_q[ 15:  0] & {16{1'b0             }};

   assign x4_data_ln5_2[15:0] = stored_data_q[127:112] & {16{1'b0             }} |
                                stored_data_q[111: 96] & {16{1'b0             }} |  
                                stored_data_q[ 95: 80] & {16{mode_x4_outer    }} |
                                stored_data_q[ 79: 64] & {16{1'b0             }} |
//                              stored_data_q[ 63: 48] & {16{mode_x4_outer_rev}} |
                                stored_data_q[ 47: 32] & {16{1'b0             }} |
                                stored_data_q[ 31: 16] & {16{1'b0             }} |
                                stored_data_q[ 15:  0] & {16{1'b0             }};

   //-- LANE 6
   assign x4_data_ln6_1[15:0] = stored_data_q[127:112] & {16{1'b0             }} |
                                stored_data_q[111: 96] & {16{mode_x4_inner    }} |  
                                stored_data_q[ 95: 80] & {16{1'b0             }} |
                                stored_data_q[ 79: 64] & {16{1'b0             }} |
                                stored_data_q[ 63: 48] & {16{1'b0             }} |
                                stored_data_q[ 47: 32] & {16{1'b0             }} |
                                stored_data_q[ 31: 16] & {16{1'b0             }} ;
//                              stored_data_q[ 15:  0] & {16{mode_x4_inner_rev}};
           
   assign x4_data_ln6_2[15:0] = stored_data_q[127:112] & {16{mode_x4_inner    }} |
                 stored_data_q[111: 96] & {16{1'b0             }} |  
                 stored_data_q[ 95: 80] & {16{1'b0             }} |
                 stored_data_q[ 79: 64] & {16{1'b0             }} |
                 stored_data_q[ 63: 48] & {16{1'b0             }} |
                 stored_data_q[ 47: 32] & {16{1'b0             }} |
//               stored_data_q[ 31: 16] & {16{mode_x4_inner_rev}} |
                 stored_data_q[ 15:  0] & {16{1'b0             }};

   //-- LANE 7
   assign x4_data_ln7_1[15:0] = stored_data_q[127:112] & {16{1'b0             }} |
                                stored_data_q[111: 96] & {16{mode_x4_outer    }} |  
                                stored_data_q[ 95: 80] & {16{1'b0             }} |
                                stored_data_q[ 79: 64] & {16{1'b0             }} |
                                stored_data_q[ 63: 48] & {16{1'b0             }} |
                                stored_data_q[ 47: 32] & {16{1'b0             }} |
                                stored_data_q[ 31: 16] & {16{1'b0             }} ;
//                              stored_data_q[ 15:  0] & {16{mode_x4_outer_rev}};

   assign x4_data_ln7_2[15:0] = stored_data_q[127:112] & {16{mode_x4_outer    }} |
                                stored_data_q[111: 96] & {16{1'b0             }} |  
                                stored_data_q[ 95: 80] & {16{1'b0             }} |
                                stored_data_q[ 79: 64] & {16{1'b0             }} |
                                stored_data_q[ 63: 48] & {16{1'b0             }} |
                                stored_data_q[ 47: 32] & {16{1'b0             }} |
//                              stored_data_q[ 31: 16] & {16{mode_x4_outer_rev}} |
                                stored_data_q[ 15:  0] & {16{1'b0             }};



   //------------------------------
   //-- x2 Muxing
   //------------------------------
   //--
   //-- In x2 mode, data can only be sent out on lanes 0 & 7 (a) or lanes 2 & 5 (b); therefore, lanes 1, 3, 4, and 6 are not used in x2.
   //-- Depending on the x2 mode, (a) or (b), lane 2 sends in the same order as lane 0 and lane 5 sends in the same order as lane 7
   //--
   //-- EG: lane 0 or 2 should transmit
   //-- beat 1 --> [15:0]; beat 2 --> [31:16]; beat 3 --> [47:32]; beat 4 --> [63:48]

   //-- Lane 0
   assign x2_data_ln0_1[15:0] = stored_data_q[127:112] & {16{1'b0             }} |
                                stored_data_q[111: 96] & {16{1'b0             }} |
                                stored_data_q[ 95: 80] & {16{1'b0             }} |
//                              stored_data_q[ 79: 64] & {16{mode_x2_outer_rev}} |
                                stored_data_q[ 63: 48] & {16{1'b0             }} |
                                stored_data_q[ 47: 32] & {16{1'b0             }} |
                                stored_data_q[ 31: 16] & {16{1'b0             }} |
                                stored_data_q[ 15:  0] & {16{mode_x2_outer    }} ;

   assign x2_data_ln0_2[15:0] = stored_data_q[127:112] & {16{1'b0             }} | 
                                stored_data_q[111: 96] & {16{1'b0             }} | 
//                              stored_data_q[ 95: 80] & {16{mode_x2_outer_rev}} | 
                                stored_data_q[ 79: 64] & {16{1'b0             }} | 
                                stored_data_q[ 63: 48] & {16{1'b0             }} | 
                                stored_data_q[ 47: 32] & {16{1'b0             }} | 
                                stored_data_q[ 31: 16] & {16{mode_x2_outer    }} | 
                                stored_data_q[ 15:  0] & {16{1'b0             }} ;

   assign x2_data_ln0_3[15:0] = stored_data_q[127:112] & {16{1'b0             }} | 
//                              stored_data_q[111: 96] & {16{mode_x2_outer_rev}} | 
                                stored_data_q[ 95: 80] & {16{1'b0             }} | 
                                stored_data_q[ 79: 64] & {16{1'b0             }} | 
                                stored_data_q[ 63: 48] & {16{1'b0             }} | 
                                stored_data_q[ 47: 32] & {16{mode_x2_outer    }} | 
                                stored_data_q[ 31: 16] & {16{1'b0             }} | 
                                stored_data_q[ 15:  0] & {16{1'b0             }} ;

   assign x2_data_ln0_4[15:0] = //stored_data_q[127:112] & {16{mode_x2_outer_rev}} | 
                                stored_data_q[111: 96] & {16{1'b0             }} | 
                                stored_data_q[ 95: 80] & {16{1'b0             }} | 
                                stored_data_q[ 79: 64] & {16{1'b0             }} | 
                                stored_data_q[ 63: 48] & {16{mode_x2_outer    }} | 
                                stored_data_q[ 47: 32] & {16{1'b0             }} | 
                                stored_data_q[ 31: 16] & {16{1'b0             }} | 
                                stored_data_q[ 15:  0] & {16{1'b0             }} ;

   //-- Lane 7
   assign x2_data_ln7_1[15:0] = stored_data_q[127:112] & {16{1'b0             }} |
                                stored_data_q[111: 96] & {16{1'b0             }} |
                                stored_data_q[ 95: 80] & {16{1'b0             }} |
                                stored_data_q[ 79: 64] & {16{mode_x2_outer    }} |
                                stored_data_q[ 63: 48] & {16{1'b0             }} |
                                stored_data_q[ 47: 32] & {16{1'b0             }} |
                                stored_data_q[ 31: 16] & {16{1'b0             }} ;
//                              stored_data_q[ 15:  0] & {16{mode_x2_outer_rev}} ;

   assign x2_data_ln7_2[15:0] = stored_data_q[127:112] & {16{1'b0             }} | 
                                stored_data_q[111: 96] & {16{1'b0             }} | 
                                stored_data_q[ 95: 80] & {16{mode_x2_outer    }} | 
                                stored_data_q[ 79: 64] & {16{1'b0             }} | 
                                stored_data_q[ 63: 48] & {16{1'b0             }} | 
                                stored_data_q[ 47: 32] & {16{1'b0             }} | 
//                              stored_data_q[ 31: 16] & {16{mode_x2_outer_rev}} | 
                                stored_data_q[ 15:  0] & {16{1'b0             }} ;

   assign x2_data_ln7_3[15:0] = stored_data_q[127:112] & {16{1'b0             }} | 
                                stored_data_q[111: 96] & {16{mode_x2_outer    }} | 
                                stored_data_q[ 95: 80] & {16{1'b0             }} | 
                                stored_data_q[ 79: 64] & {16{1'b0             }} | 
                                stored_data_q[ 63: 48] & {16{1'b0             }} | 
//                              stored_data_q[ 47: 32] & {16{mode_x2_outer_rev}} | 
                                stored_data_q[ 31: 16] & {16{1'b0             }} | 
                                stored_data_q[ 15:  0] & {16{1'b0             }} ;

   assign x2_data_ln7_4[15:0] = stored_data_q[127:112] & {16{mode_x2_outer    }} | 
                                stored_data_q[111: 96] & {16{1'b0             }} | 
                                stored_data_q[ 95: 80] & {16{1'b0             }} | 
                                stored_data_q[ 79: 64] & {16{1'b0             }} | 
//                              stored_data_q[ 63: 48] & {16{mode_x2_outer_rev}} | 
                                stored_data_q[ 47: 32] & {16{1'b0             }} | 
                                stored_data_q[ 31: 16] & {16{1'b0             }} | 
                                stored_data_q[ 15:  0] & {16{1'b0             }} ;

   //-- Lane 2
   assign x2_data_ln2_1[15:0] = stored_data_q[127:112] & {16{1'b0             }} | 
                                stored_data_q[111: 96] & {16{1'b0             }} | 
                                stored_data_q[ 95: 80] & {16{1'b0             }} | 
//                              stored_data_q[ 79: 64] & {16{mode_x2_inner_rev}} | 
                                stored_data_q[ 63: 48] & {16{1'b0             }} | 
                                stored_data_q[ 47: 32] & {16{1'b0             }} | 
                                stored_data_q[ 31: 16] & {16{1'b0             }} | 
                                stored_data_q[ 15:  0] & {16{mode_x2_inner    }} ;

   assign x2_data_ln2_2[15:0] = stored_data_q[127:112] & {16{1'b0             }} | 
                                stored_data_q[111: 96] & {16{1'b0             }} | 
//                              stored_data_q[ 95: 80] & {16{mode_x2_inner_rev}} | 
                                stored_data_q[ 79: 64] & {16{1'b0             }} | 
                                stored_data_q[ 63: 48] & {16{1'b0             }} | 
                                stored_data_q[ 47: 32] & {16{1'b0             }} | 
                                stored_data_q[ 31: 16] & {16{mode_x2_inner    }} | 
                                stored_data_q[ 15:  0] & {16{1'b0             }} ;

   assign x2_data_ln2_3[15:0] = stored_data_q[127:112] & {16{1'b0             }} | 
//                              stored_data_q[111: 96] & {16{mode_x2_inner_rev}} | 
                                stored_data_q[ 95: 80] & {16{1'b0             }} | 
                                stored_data_q[ 79: 64] & {16{1'b0             }} | 
                                stored_data_q[ 63: 48] & {16{1'b0             }} | 
                                stored_data_q[ 47: 32] & {16{mode_x2_inner    }} | 
                                stored_data_q[ 31: 16] & {16{1'b0             }} | 
                                stored_data_q[ 15:  0] & {16{1'b0             }} ;
    
   assign x2_data_ln2_4[15:0] = //stored_data_q[127:112] & {16{mode_x2_inner_rev}} | 
                                stored_data_q[111: 96] & {16{1'b0             }} | 
                                stored_data_q[ 95: 80] & {16{1'b0             }} | 
                                stored_data_q[ 79: 64] & {16{1'b0             }} | 
                                stored_data_q[ 63: 48] & {16{mode_x2_inner    }} | 
                                stored_data_q[ 47: 32] & {16{1'b0             }} | 
                                stored_data_q[ 31: 16] & {16{1'b0             }} | 
                                stored_data_q[ 15:  0] & {16{1'b0             }} ;

   //-- Lane 5
   assign x2_data_ln5_1[15:0] = stored_data_q[127:112] & {16{1'b0             }} | 
                                stored_data_q[111: 96] & {16{1'b0             }} | 
                                stored_data_q[ 95: 80] & {16{1'b0             }} | 
                                stored_data_q[ 79: 64] & {16{mode_x2_inner    }} | 
                                stored_data_q[ 63: 48] & {16{1'b0             }} | 
                                stored_data_q[ 47: 32] & {16{1'b0             }} | 
                                stored_data_q[ 31: 16] & {16{1'b0             }} ; 
//                              stored_data_q[ 15:  0] & {16{mode_x2_inner_rev}} ;
    
   assign x2_data_ln5_2[15:0] = stored_data_q[127:112] & {16{1'b0             }} | 
                                stored_data_q[111: 96] & {16{1'b0             }} | 
                                stored_data_q[ 95: 80] & {16{mode_x2_inner    }} | 
                                stored_data_q[ 79: 64] & {16{1'b0             }} | 
                                stored_data_q[ 63: 48] & {16{1'b0             }} | 
                                stored_data_q[ 47: 32] & {16{1'b0             }} | 
//                              stored_data_q[ 31: 16] & {16{mode_x2_inner_rev}} | 
                                stored_data_q[ 15:  0] & {16{1'b0             }} ;

   assign x2_data_ln5_3[15:0] = stored_data_q[127:112] & {16{1'b0             }} | 
                                stored_data_q[111: 96] & {16{mode_x2_inner    }} | 
                                stored_data_q[ 95: 80] & {16{1'b0             }} | 
                                stored_data_q[ 79: 64] & {16{1'b0             }} | 
                                stored_data_q[ 63: 48] & {16{1'b0             }} | 
//                              stored_data_q[ 47: 32] & {16{mode_x2_inner_rev}} | 
                                stored_data_q[ 31: 16] & {16{1'b0             }} | 
                                stored_data_q[ 15:  0] & {16{1'b0             }} ;

   assign x2_data_ln5_4[15:0] = stored_data_q[127:112] & {16{mode_x2_inner    }} | 
                                stored_data_q[111: 96] & {16{1'b0             }} | 
                                stored_data_q[ 95: 80] & {16{1'b0             }} | 
                                stored_data_q[ 79: 64] & {16{1'b0             }} | 
//                              stored_data_q[ 63: 48] & {16{mode_x2_inner_rev}} | 
                                stored_data_q[ 47: 32] & {16{1'b0             }} | 
                                stored_data_q[ 31: 16] & {16{1'b0             }} | 
                                stored_data_q[ 15:  0] & {16{1'b0             }} ;
      end 
else
      begin
   assign agn_ln7_next_2B[15:0] = (       x8_data[127:112] & {16{sel_mode_0[1:0] == 2'b00}}) |
                                  (   x8_rev_data[127:112] & {16{sel_mode_0[1:0] == 2'b01}}) |
                                  ( degraded_data[127:112] & {16{sel_mode_0[1:0] == 2'b10}}) |
                                  (training_set_q[127:112] & {16{sel_mode_0[1:0] == 2'b11}});
   assign agn_ln6_next_2B[15:0] = (       x8_data[111: 96] & {16{sel_mode_1[1:0] == 2'b00}}) |
                                  (   x8_rev_data[111: 96] & {16{sel_mode_1[1:0] == 2'b01}}) |
                                  ( degraded_data[111: 96] & {16{sel_mode_1[1:0] == 2'b10}}) |
                                  (training_set_q[111: 96] & {16{sel_mode_1[1:0] == 2'b11}});
   assign agn_ln5_next_2B[15:0] = (       x8_data[ 95: 80] & {16{sel_mode_2[1:0] == 2'b00}}) |
                                  (   x8_rev_data[ 95: 80] & {16{sel_mode_2[1:0] == 2'b01}}) |
                                  ( degraded_data[ 95: 80] & {16{sel_mode_2[1:0] == 2'b10}}) |
                                  (training_set_q[ 95: 80] & {16{sel_mode_2[1:0] == 2'b11}});
   assign agn_ln4_next_2B[15:0] = (       x8_data[ 79: 64] & {16{sel_mode_3[1:0] == 2'b00}}) |
                                  (   x8_rev_data[ 79: 64] & {16{sel_mode_3[1:0] == 2'b01}}) |
                                  ( degraded_data[ 79: 64] & {16{sel_mode_3[1:0] == 2'b10}}) |
                                  (training_set_q[ 79: 64] & {16{sel_mode_3[1:0] == 2'b11}});
   assign agn_ln3_next_2B[15:0] = (       x8_data[ 63: 48] & {16{sel_mode_4[1:0] == 2'b00}}) |
                                  (   x8_rev_data[ 63: 48] & {16{sel_mode_4[1:0] == 2'b01}}) |
                                  ( degraded_data[ 63: 48] & {16{sel_mode_4[1:0] == 2'b10}}) |
                                  (training_set_q[ 63: 48] & {16{sel_mode_4[1:0] == 2'b11}});
   assign agn_ln2_next_2B[15:0] = (       x8_data[ 47: 32] & {16{sel_mode_5[1:0] == 2'b00}}) |
                                  (   x8_rev_data[ 47: 32] & {16{sel_mode_5[1:0] == 2'b01}}) |
                                  ( degraded_data[ 47: 32] & {16{sel_mode_5[1:0] == 2'b10}}) |
                                  (training_set_q[ 47: 32] & {16{sel_mode_5[1:0] == 2'b11}});
   assign agn_ln1_next_2B[15:0] = (       x8_data[ 31: 16] & {16{sel_mode_6[1:0] == 2'b00}}) |
                                  (   x8_rev_data[ 31: 16] & {16{sel_mode_6[1:0] == 2'b01}}) |
                                  ( degraded_data[ 31: 16] & {16{sel_mode_6[1:0] == 2'b10}}) |
                                  (training_set_q[ 31: 16] & {16{sel_mode_6[1:0] == 2'b11}});
   assign agn_ln0_next_2B[15:0] = (       x8_data[ 15:  0] & {16{sel_mode_7[1:0] == 2'b00}}) |
                                  (   x8_rev_data[ 15:  0] & {16{sel_mode_7[1:0] == 2'b01}}) |
                                  ( degraded_data[ 15:  0] & {16{sel_mode_7[1:0] == 2'b10}}) |
                                  (training_set_q[ 15:  0] & {16{sel_mode_7[1:0] == 2'b11}});

   //------------------------------
   //-- x4 Muxing
   //------------------------------
   //--
   //-- x4_data_ln[0-7]_[2B chunk]
   //--
   //-- Supported x4 modes
   //-- 1. mode_x4_inner    
   //-- 2. mode_x4_outer    
   //-- 3. mode_x4_inner_rev
   //-- 4. mode_x4_outer_rev
   //-- x4_inner_enable = Lanes 1, 3, 4, 6
   //-- x4_outer_enable = Lanes 0, 2, 5, 7

   //-- LANE 0
   assign x4_data_ln0_1[15:0] = stored_data_q[127:112] & {16{1'b0             }} |
                                stored_data_q[111: 96] & {16{mode_x4_outer_rev}} |  
                                stored_data_q[ 95: 80] & {16{1'b0             }} |
                                stored_data_q[ 79: 64] & {16{1'b0             }} |
                                stored_data_q[ 63: 48] & {16{1'b0             }} |
                                stored_data_q[ 47: 32] & {16{1'b0             }} |
                                stored_data_q[ 31: 16] & {16{1'b0             }} |
                                stored_data_q[ 15:  0] & {16{mode_x4_outer    }};

   assign x4_data_ln0_2[15:0] = stored_data_q[127:112] & {16{mode_x4_outer_rev}} |
                                stored_data_q[111: 96] & {16{1'b0             }} |  
                                stored_data_q[ 95: 80] & {16{1'b0             }} |
                                stored_data_q[ 79: 64] & {16{1'b0             }} |
                                stored_data_q[ 63: 48] & {16{1'b0             }} |
                                stored_data_q[ 47: 32] & {16{1'b0             }} |
                                stored_data_q[ 31: 16] & {16{mode_x4_outer    }} |
                                stored_data_q[ 15:  0] & {16{1'b0             }};

   //-- LANE 1
   assign x4_data_ln1_1[15:0] = stored_data_q[127:112] & {16{1'b0             }} |
                                stored_data_q[111: 96] & {16{mode_x4_inner_rev}} |  
                                stored_data_q[ 95: 80] & {16{1'b0             }} |
                                stored_data_q[ 79: 64] & {16{1'b0             }} |
                                stored_data_q[ 63: 48] & {16{1'b0             }} |
                                stored_data_q[ 47: 32] & {16{1'b0             }} |
                                stored_data_q[ 31: 16] & {16{1'b0             }} |
                                stored_data_q[ 15:  0] & {16{mode_x4_inner    }};

   assign x4_data_ln1_2[15:0] = stored_data_q[127:112] & {16{mode_x4_inner_rev}} |
                                stored_data_q[111: 96] & {16{1'b0             }} |  
                                stored_data_q[ 95: 80] & {16{1'b0             }} |
                                stored_data_q[ 79: 64] & {16{1'b0             }} |
                                stored_data_q[ 63: 48] & {16{1'b0             }} |
                                stored_data_q[ 47: 32] & {16{1'b0             }} |
                                stored_data_q[ 31: 16] & {16{mode_x4_inner    }} |
                                stored_data_q[ 15:  0] & {16{1'b0             }};

   //-- LANE 2
   assign x4_data_ln2_1[15:0] = stored_data_q[127:112] & {16{1'b0             }} |
                                stored_data_q[111: 96] & {16{1'b0             }} |  
                                stored_data_q[ 95: 80] & {16{1'b0             }} |
                                stored_data_q[ 79: 64] & {16{mode_x4_outer_rev}} |
                                stored_data_q[ 63: 48] & {16{1'b0             }} |
                                stored_data_q[ 47: 32] & {16{mode_x4_outer    }} |
                                stored_data_q[ 31: 16] & {16{1'b0             }} |
                                stored_data_q[ 15:  0] & {16{1'b0             }};

   assign x4_data_ln2_2[15:0] = stored_data_q[127:112] & {16{1'b0             }} |
                                stored_data_q[111: 96] & {16{1'b0             }} |  
                                stored_data_q[ 95: 80] & {16{mode_x4_outer_rev}} |
                                stored_data_q[ 79: 64] & {16{1'b0             }} |
                                stored_data_q[ 63: 48] & {16{mode_x4_outer    }} |
                                stored_data_q[ 47: 32] & {16{1'b0             }} |
                                stored_data_q[ 31: 16] & {16{1'b0             }} |
                                stored_data_q[ 15:  0] & {16{1'b0             }};

   //-- LANE 3
   assign x4_data_ln3_1[15:0] = stored_data_q[127:112] & {16{1'b0             }} |
                                stored_data_q[111: 96] & {16{1'b0             }} |  
                                stored_data_q[ 95: 80] & {16{1'b0             }} |
                                stored_data_q[ 79: 64] & {16{mode_x4_inner_rev}} |
                                stored_data_q[ 63: 48] & {16{1'b0             }} |
                                stored_data_q[ 47: 32] & {16{mode_x4_inner    }} |
                                stored_data_q[ 31: 16] & {16{1'b0             }} |
                                stored_data_q[ 15:  0] & {16{1'b0             }};

   assign x4_data_ln3_2[15:0] = stored_data_q[127:112] & {16{1'b0             }} |
                                stored_data_q[111: 96] & {16{1'b0             }} |  
                                stored_data_q[ 95: 80] & {16{mode_x4_inner_rev}} |
                                stored_data_q[ 79: 64] & {16{1'b0             }} |
                                stored_data_q[ 63: 48] & {16{mode_x4_inner    }} |
                                stored_data_q[ 47: 32] & {16{1'b0             }} |
                                stored_data_q[ 31: 16] & {16{1'b0             }} |
                                stored_data_q[ 15:  0] & {16{1'b0             }};

   //-- LANE 4
   assign x4_data_ln4_1[15:0] = stored_data_q[127:112] & {16{1'b0             }} |
                                stored_data_q[111: 96] & {16{1'b0             }} |  
                                stored_data_q[ 95: 80] & {16{1'b0             }} |
                                stored_data_q[ 79: 64] & {16{mode_x4_inner    }} |
                                stored_data_q[ 63: 48] & {16{1'b0             }} |
                                stored_data_q[ 47: 32] & {16{mode_x4_inner_rev}} |
                                stored_data_q[ 31: 16] & {16{1'b0             }} |
                                stored_data_q[ 15:  0] & {16{1'b0             }};

   assign x4_data_ln4_2[15:0] = stored_data_q[127:112] & {16{1'b0             }} |
                                stored_data_q[111: 96] & {16{1'b0             }} |  
                                stored_data_q[ 95: 80] & {16{mode_x4_inner    }} |
                                stored_data_q[ 79: 64] & {16{1'b0             }} |
                                stored_data_q[ 63: 48] & {16{mode_x4_inner_rev}} |
                                stored_data_q[ 47: 32] & {16{1'b0             }} |
                                stored_data_q[ 31: 16] & {16{1'b0             }} |
                                stored_data_q[ 15:  0] & {16{1'b0             }};

   //-- LANE 5
   assign x4_data_ln5_1[15:0] = stored_data_q[127:112] & {16{1'b0             }} |
                                stored_data_q[111: 96] & {16{1'b0             }} |  
                                stored_data_q[ 95: 80] & {16{1'b0             }} |
                                stored_data_q[ 79: 64] & {16{mode_x4_outer    }} |
                                stored_data_q[ 63: 48] & {16{1'b0             }} |
                                stored_data_q[ 47: 32] & {16{mode_x4_outer_rev}} |
                                stored_data_q[ 31: 16] & {16{1'b0             }} |
                                stored_data_q[ 15:  0] & {16{1'b0             }};

   assign x4_data_ln5_2[15:0] = stored_data_q[127:112] & {16{1'b0             }} |
                                stored_data_q[111: 96] & {16{1'b0             }} |  
                                stored_data_q[ 95: 80] & {16{mode_x4_outer    }} |
                                stored_data_q[ 79: 64] & {16{1'b0             }} |
                                stored_data_q[ 63: 48] & {16{mode_x4_outer_rev}} |
                                stored_data_q[ 47: 32] & {16{1'b0             }} |
                                stored_data_q[ 31: 16] & {16{1'b0             }} |
                                stored_data_q[ 15:  0] & {16{1'b0             }};

   //-- LANE 6
   assign x4_data_ln6_1[15:0] = stored_data_q[127:112] & {16{1'b0             }} |
                                stored_data_q[111: 96] & {16{mode_x4_inner    }} |  
                                stored_data_q[ 95: 80] & {16{1'b0             }} |
                                stored_data_q[ 79: 64] & {16{1'b0             }} |
                                stored_data_q[ 63: 48] & {16{1'b0             }} |
                                stored_data_q[ 47: 32] & {16{1'b0             }} |
                                stored_data_q[ 31: 16] & {16{1'b0             }} |
                                stored_data_q[ 15:  0] & {16{mode_x4_inner_rev}};
           
   assign x4_data_ln6_2[15:0] = stored_data_q[127:112] & {16{mode_x4_inner    }} |
                                stored_data_q[111: 96] & {16{1'b0             }} |  
                                stored_data_q[ 95: 80] & {16{1'b0             }} |
                                stored_data_q[ 79: 64] & {16{1'b0             }} |
                                stored_data_q[ 63: 48] & {16{1'b0             }} |
                                stored_data_q[ 47: 32] & {16{1'b0             }} |
                                stored_data_q[ 31: 16] & {16{mode_x4_inner_rev}} |
                                stored_data_q[ 15:  0] & {16{1'b0             }};

   //-- LANE 7
   assign x4_data_ln7_1[15:0] = stored_data_q[127:112] & {16{1'b0             }} |
                                stored_data_q[111: 96] & {16{mode_x4_outer    }} |  
                                stored_data_q[ 95: 80] & {16{1'b0             }} |
                                stored_data_q[ 79: 64] & {16{1'b0             }} |
                                stored_data_q[ 63: 48] & {16{1'b0             }} |
                                stored_data_q[ 47: 32] & {16{1'b0             }} |
                                stored_data_q[ 31: 16] & {16{1'b0             }} |
                                stored_data_q[ 15:  0] & {16{mode_x4_outer_rev}};

   assign x4_data_ln7_2[15:0] = stored_data_q[127:112] & {16{mode_x4_outer    }} |
                                stored_data_q[111: 96] & {16{1'b0             }} |  
                                stored_data_q[ 95: 80] & {16{1'b0             }} |
                                stored_data_q[ 79: 64] & {16{1'b0             }} |
                                stored_data_q[ 63: 48] & {16{1'b0             }} |
                                stored_data_q[ 47: 32] & {16{1'b0             }} |
                                stored_data_q[ 31: 16] & {16{mode_x4_outer_rev}} |
                                stored_data_q[ 15:  0] & {16{1'b0             }};



   //------------------------------
   //-- x2 Muxing
   //------------------------------
   //--
   //-- In x2 mode, data can only be sent out on lanes 0 & 7 (a) or lanes 2 & 5 (b); therefore, lanes 1, 3, 4, and 6 are  in x2.
   //-- Depending on the x2 mode, (a) or (b), lane 2 sends in the same order as lane 0 and lane 5 sends in the same order as lane 7
   //--
   //-- EG: lane 0 or 2 should transmit
   //-- beat 1 --> [15:0]; beat 2 --> [31:16]; beat 3 --> [47:32]; beat 4 --> [63:48]

   //-- Lane 0
   assign x2_data_ln0_1[15:0] = stored_data_q[127:112] & {16{1'b0             }} |
                                stored_data_q[111: 96] & {16{1'b0             }} |
                                stored_data_q[ 95: 80] & {16{1'b0             }} |
                                stored_data_q[ 79: 64] & {16{mode_x2_outer_rev}} |
                                stored_data_q[ 63: 48] & {16{1'b0             }} |
                                stored_data_q[ 47: 32] & {16{1'b0             }} |
                                stored_data_q[ 31: 16] & {16{1'b0             }} |
                                stored_data_q[ 15:  0] & {16{mode_x2_outer    }} ;

   assign x2_data_ln0_2[15:0] = stored_data_q[127:112] & {16{1'b0             }} | 
                                stored_data_q[111: 96] & {16{1'b0             }} | 
                                stored_data_q[ 95: 80] & {16{mode_x2_outer_rev}} | 
                                stored_data_q[ 79: 64] & {16{1'b0             }} | 
                                stored_data_q[ 63: 48] & {16{1'b0             }} | 
                                stored_data_q[ 47: 32] & {16{1'b0             }} | 
                                stored_data_q[ 31: 16] & {16{mode_x2_outer    }} | 
                                stored_data_q[ 15:  0] & {16{1'b0             }} ;

   assign x2_data_ln0_3[15:0] = stored_data_q[127:112] & {16{1'b0             }} | 
                                stored_data_q[111: 96] & {16{mode_x2_outer_rev}} | 
                                stored_data_q[ 95: 80] & {16{1'b0             }} | 
                                stored_data_q[ 79: 64] & {16{1'b0             }} | 
                                stored_data_q[ 63: 48] & {16{1'b0             }} | 
                                stored_data_q[ 47: 32] & {16{mode_x2_outer    }} | 
                                stored_data_q[ 31: 16] & {16{1'b0             }} | 
                                stored_data_q[ 15:  0] & {16{1'b0             }} ;

   assign x2_data_ln0_4[15:0] = stored_data_q[127:112] & {16{mode_x2_outer_rev}} | 
                                stored_data_q[111: 96] & {16{1'b0             }} | 
                                stored_data_q[ 95: 80] & {16{1'b0             }} | 
                                stored_data_q[ 79: 64] & {16{1'b0             }} | 
                                stored_data_q[ 63: 48] & {16{mode_x2_outer    }} | 
                                stored_data_q[ 47: 32] & {16{1'b0             }} | 
                                stored_data_q[ 31: 16] & {16{1'b0             }} | 
                                stored_data_q[ 15:  0] & {16{1'b0             }} ;

   //-- Lane 7
   assign x2_data_ln7_1[15:0] = stored_data_q[127:112] & {16{1'b0             }} |
                                stored_data_q[111: 96] & {16{1'b0             }} |
                                stored_data_q[ 95: 80] & {16{1'b0             }} |
                                stored_data_q[ 79: 64] & {16{mode_x2_outer    }} |
                                stored_data_q[ 63: 48] & {16{1'b0             }} |
                                stored_data_q[ 47: 32] & {16{1'b0             }} |
                                stored_data_q[ 31: 16] & {16{1'b0             }} |
                                stored_data_q[ 15:  0] & {16{mode_x2_outer_rev}} ;

   assign x2_data_ln7_2[15:0] = stored_data_q[127:112] & {16{1'b0             }} | 
                                stored_data_q[111: 96] & {16{1'b0             }} | 
                                stored_data_q[ 95: 80] & {16{mode_x2_outer    }} | 
                                stored_data_q[ 79: 64] & {16{1'b0             }} | 
                                stored_data_q[ 63: 48] & {16{1'b0             }} | 
                                stored_data_q[ 47: 32] & {16{1'b0             }} | 
                                stored_data_q[ 31: 16] & {16{mode_x2_outer_rev}} | 
                                stored_data_q[ 15:  0] & {16{1'b0             }} ;

   assign x2_data_ln7_3[15:0] = stored_data_q[127:112] & {16{1'b0             }} | 
                                stored_data_q[111: 96] & {16{mode_x2_outer    }} | 
                                stored_data_q[ 95: 80] & {16{1'b0             }} | 
                                stored_data_q[ 79: 64] & {16{1'b0             }} | 
                                stored_data_q[ 63: 48] & {16{1'b0             }} | 
                                stored_data_q[ 47: 32] & {16{mode_x2_outer_rev}} | 
                                stored_data_q[ 31: 16] & {16{1'b0             }} | 
                                stored_data_q[ 15:  0] & {16{1'b0             }} ;

   assign x2_data_ln7_4[15:0] = stored_data_q[127:112] & {16{mode_x2_outer    }} | 
                                stored_data_q[111: 96] & {16{1'b0             }} | 
                                stored_data_q[ 95: 80] & {16{1'b0             }} | 
                                stored_data_q[ 79: 64] & {16{1'b0             }} | 
                                stored_data_q[ 63: 48] & {16{mode_x2_outer_rev}} | 
                                stored_data_q[ 47: 32] & {16{1'b0             }} | 
                                stored_data_q[ 31: 16] & {16{1'b0             }} | 
                                stored_data_q[ 15:  0] & {16{1'b0             }} ;

   //-- Lane 2
   assign x2_data_ln2_1[15:0] = stored_data_q[127:112] & {16{1'b0             }} | 
                                stored_data_q[111: 96] & {16{1'b0             }} | 
                                stored_data_q[ 95: 80] & {16{1'b0             }} | 
                                stored_data_q[ 79: 64] & {16{mode_x2_inner_rev}} | 
                                stored_data_q[ 63: 48] & {16{1'b0             }} | 
                                stored_data_q[ 47: 32] & {16{1'b0             }} | 
                                stored_data_q[ 31: 16] & {16{1'b0             }} | 
                                stored_data_q[ 15:  0] & {16{mode_x2_inner    }} ;

   assign x2_data_ln2_2[15:0] = stored_data_q[127:112] & {16{1'b0             }} | 
                                stored_data_q[111: 96] & {16{1'b0             }} | 
                                stored_data_q[ 95: 80] & {16{mode_x2_inner_rev}} | 
                                stored_data_q[ 79: 64] & {16{1'b0             }} | 
                                stored_data_q[ 63: 48] & {16{1'b0             }} | 
                                stored_data_q[ 47: 32] & {16{1'b0             }} | 
                                stored_data_q[ 31: 16] & {16{mode_x2_inner    }} | 
                                stored_data_q[ 15:  0] & {16{1'b0             }} ;

   assign x2_data_ln2_3[15:0] = stored_data_q[127:112] & {16{1'b0             }} | 
                                stored_data_q[111: 96] & {16{mode_x2_inner_rev}} | 
                                stored_data_q[ 95: 80] & {16{1'b0             }} | 
                                stored_data_q[ 79: 64] & {16{1'b0             }} | 
                                stored_data_q[ 63: 48] & {16{1'b0             }} | 
                                stored_data_q[ 47: 32] & {16{mode_x2_inner    }} | 
                                stored_data_q[ 31: 16] & {16{1'b0             }} | 
                                stored_data_q[ 15:  0] & {16{1'b0             }} ;
    
   assign x2_data_ln2_4[15:0] = stored_data_q[127:112] & {16{mode_x2_inner_rev}} | 
                                stored_data_q[111: 96] & {16{1'b0             }} | 
                                stored_data_q[ 95: 80] & {16{1'b0             }} | 
                                stored_data_q[ 79: 64] & {16{1'b0             }} | 
                                stored_data_q[ 63: 48] & {16{mode_x2_inner    }} | 
                                stored_data_q[ 47: 32] & {16{1'b0             }} | 
                                stored_data_q[ 31: 16] & {16{1'b0             }} | 
                                stored_data_q[ 15:  0] & {16{1'b0             }} ;

   //-- Lane 5
   assign x2_data_ln5_1[15:0] = stored_data_q[127:112] & {16{1'b0             }} | 
                                stored_data_q[111: 96] & {16{1'b0             }} | 
                                stored_data_q[ 95: 80] & {16{1'b0             }} | 
                                stored_data_q[ 79: 64] & {16{mode_x2_inner    }} | 
                                stored_data_q[ 63: 48] & {16{1'b0             }} | 
                                stored_data_q[ 47: 32] & {16{1'b0             }} | 
                                stored_data_q[ 31: 16] & {16{1'b0             }} | 
                                stored_data_q[ 15:  0] & {16{mode_x2_inner_rev}} ;
    
   assign x2_data_ln5_2[15:0] = stored_data_q[127:112] & {16{1'b0             }} | 
                                stored_data_q[111: 96] & {16{1'b0             }} | 
                                stored_data_q[ 95: 80] & {16{mode_x2_inner    }} | 
                                stored_data_q[ 79: 64] & {16{1'b0             }} | 
                                stored_data_q[ 63: 48] & {16{1'b0             }} | 
                                stored_data_q[ 47: 32] & {16{1'b0             }} | 
                                stored_data_q[ 31: 16] & {16{mode_x2_inner_rev}} | 
                                stored_data_q[ 15:  0] & {16{1'b0             }} ;

   assign x2_data_ln5_3[15:0] = stored_data_q[127:112] & {16{1'b0             }} | 
                                stored_data_q[111: 96] & {16{mode_x2_inner    }} | 
                                stored_data_q[ 95: 80] & {16{1'b0             }} | 
                                stored_data_q[ 79: 64] & {16{1'b0             }} | 
                                stored_data_q[ 63: 48] & {16{1'b0             }} | 
                                stored_data_q[ 47: 32] & {16{mode_x2_inner_rev}} | 
                                stored_data_q[ 31: 16] & {16{1'b0             }} | 
                                stored_data_q[ 15:  0] & {16{1'b0             }} ;

   assign x2_data_ln5_4[15:0] = stored_data_q[127:112] & {16{mode_x2_inner    }} | 
                                stored_data_q[111: 96] & {16{1'b0             }} | 
                                stored_data_q[ 95: 80] & {16{1'b0             }} | 
                                stored_data_q[ 79: 64] & {16{1'b0             }} | 
                                stored_data_q[ 63: 48] & {16{mode_x2_inner_rev}} | 
                                stored_data_q[ 47: 32] & {16{1'b0             }} | 
                                stored_data_q[ 31: 16] & {16{1'b0             }} | 
                                stored_data_q[ 15:  0] & {16{1'b0             }} ;
      end 
endgenerate
//------------------------------
//-- Spare Latches
//------------------------------
//--

assign spare_00_din = spare_07_q | error_multiple_modes_active;
assign spare_01_din = spare_00_q;
assign spare_02_din = spare_01_q;
assign spare_03_din = spare_02_q;
assign spare_04_din = spare_03_q;
assign spare_05_din = spare_04_q;
assign spare_06_din = spare_05_q;
assign spare_07_din = spare_06_q;

assign reset_n_din  = trn_reset_n;
assign reset        = global_reset_control ? reset_n_q : ~chip_reset;
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_reset_n                         (.clk(dl_clk)  ,.reset_n(1'b1 )  ,.enable(trn_enable)  ,.din(reset_n_din                         ) ,.q(reset_n_q                          ) );
dlc_ff       #(.width(128) ,.rstv({128{1'b0}})) ff_training_set                    (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(trn_enable)  ,.din(training_set_din                    ) ,.q(training_set_q                     ) );
dlc_ff       #(.width(128) ,.rstv({128{1'b0}})) ff_stored_data                     (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(trn_enable)  ,.din(stored_data_din                     ) ,.q(stored_data_q                      ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_store_data                      (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(trn_enable)  ,.din(store_data_din                      ) ,.q(store_data_q                       ) );
dlc_ff       #(.width(  8) ,.rstv({  8{1'b0}})) ff_sel_TS_dly                      (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(trn_enable)  ,.din(sel_TS_dly_din                      ) ,.q(sel_TS_dly_q                       ) );
dlc_ff       #(.width(  1) ,.rstv({  1{1'b0}})) ff_train_done_dly                  (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(trn_enable)  ,.din(train_done_dly_din                  ) ,.q(train_done_dly_q                   ) );
dlc_ff_spare #(.width(  1) ,.rstv({  1{1'b0}})) ff_spare_00                        (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(trn_enable)  ,.din(spare_00_din                        ) ,.q(spare_00_q                         ) );
dlc_ff_spare #(.width(  1) ,.rstv({  1{1'b0}})) ff_spare_01                        (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(trn_enable)  ,.din(spare_01_din                        ) ,.q(spare_01_q                         ) );
dlc_ff_spare #(.width(  1) ,.rstv({  1{1'b0}})) ff_spare_02                        (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(trn_enable)  ,.din(spare_02_din                        ) ,.q(spare_02_q                         ) );
dlc_ff_spare #(.width(  1) ,.rstv({  1{1'b0}})) ff_spare_03                        (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(trn_enable)  ,.din(spare_03_din                        ) ,.q(spare_03_q                         ) );
dlc_ff_spare #(.width(  1) ,.rstv({  1{1'b0}})) ff_spare_04                        (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(trn_enable)  ,.din(spare_04_din                        ) ,.q(spare_04_q                         ) );
dlc_ff_spare #(.width(  1) ,.rstv({  1{1'b0}})) ff_spare_05                        (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(trn_enable)  ,.din(spare_05_din                        ) ,.q(spare_05_q                         ) );
dlc_ff_spare #(.width(  1) ,.rstv({  1{1'b0}})) ff_spare_06                        (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(trn_enable)  ,.din(spare_06_din                        ) ,.q(spare_06_q                         ) );
dlc_ff_spare #(.width(  1) ,.rstv({  1{1'b0}})) ff_spare_07                        (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(trn_enable)  ,.din(spare_07_din                        ) ,.q(spare_07_q                         ) );
dlc_ff       #(.width(  2) ,.rstv({  2{1'b0}})) ff_x2_sel                          (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(trn_enable)  ,.din(x2_sel_din                          ) ,.q(x2_sel_q                           ) );


endmodule  //-- dlc_omi_tx_align

