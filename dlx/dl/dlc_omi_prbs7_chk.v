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
module  dlc_omi_prbs7_chk (
//-- Clock
  phy_dl_clock        //-- input
 ,omi_enable          //-- input
 ,omi_reset_n         //-- input
//-- Control bit
 ,rx_bist_reset       //-- input

//-- PRBS Input
 ,data_in             //-- input [15:0]
//-- PRBS Outputs
 ,prbs_error_out      //-- output
 ,chip_reset          //-- input
 ,global_reset_control//-- input
);

input        phy_dl_clock;
input        omi_enable;
input        omi_reset_n;
input        rx_bist_reset;
input [15:0] data_in;
input        chip_reset;
input        global_reset_control;
output       prbs_error_out;

wire         reset;
wire [15:0]  b1_prbs_data_in;
wire [15:0]  b1_data_odd_inv;
wire [15:0]  b1_data_even_inv;
wire         b1_odd_inv_is_prbs7;
wire         b1_even_inv_is_prbs7;
wire [15:0]  b2_prbs_data_in;
wire [15:0]  b2_data_odd_inv;
wire [15:0]  b2_data_even_inv;
wire         b2_odd_inv_is_prbs7;
wire         b2_even_inv_is_prbs7;
wire         rx_bist_reset_din;
wire         rx_bist_reset_q;
wire [1:0]   reset_control;
wire [7:0]   rx_bist_data_din;
wire [7:0]   rx_bist_data_q;
wire         error_detected;
wire         prbs_error_din;
wire         prbs_error_q;
wire         omi_reset_n_din;
wire         omi_reset_n_q;


assign rx_bist_data_din       = data_in[7:0];

assign b1_prbs_data_in[15:0] = {rx_bist_data_q[7:0], data_in[15:8]};

//-- prbs7 = x^7 + x^6 + 1
//--  probably have to reverse xor constant
assign b1_data_odd_inv       = b1_prbs_data_in[15:0] ^ 16'b1010101010101010;  //-- Creates either PRBS7 or the complement
assign b1_data_even_inv      = b1_prbs_data_in[15:0] ^ 16'b0101010101010101;

assign b1_odd_inv_is_prbs7   = ((b1_data_odd_inv[15]  ^ b1_data_odd_inv[14])  ~^ b1_data_odd_inv[ 8])  &
                               ((b1_data_odd_inv[14]  ^ b1_data_odd_inv[13])  ~^ b1_data_odd_inv[ 7])  &
                               ((b1_data_odd_inv[13]  ^ b1_data_odd_inv[12])  ~^ b1_data_odd_inv[ 6])  &
                               ((b1_data_odd_inv[12]  ^ b1_data_odd_inv[11])  ~^ b1_data_odd_inv[ 5])  &
                               ((b1_data_odd_inv[11]  ^ b1_data_odd_inv[10])  ~^ b1_data_odd_inv[ 4])  &
                               ((b1_data_odd_inv[10]  ^ b1_data_odd_inv[ 9])  ~^ b1_data_odd_inv[ 3])  &
                               ((b1_data_odd_inv[ 9]  ^ b1_data_odd_inv[ 8])  ~^ b1_data_odd_inv[ 2])  &
                               ((b1_data_odd_inv[ 8]  ^ b1_data_odd_inv[ 7])  ~^ b1_data_odd_inv[ 1])  &
                               ((b1_data_odd_inv[ 7]  ^ b1_data_odd_inv[ 6])  ~^ b1_data_odd_inv[ 0]);

assign b1_even_inv_is_prbs7 =  ((b1_data_even_inv[15] ^ b1_data_even_inv[14]) ~^ b1_data_even_inv[ 8]) &
                               ((b1_data_even_inv[14] ^ b1_data_even_inv[13]) ~^ b1_data_even_inv[ 7]) &
                               ((b1_data_even_inv[13] ^ b1_data_even_inv[12]) ~^ b1_data_even_inv[ 6]) &
                               ((b1_data_even_inv[12] ^ b1_data_even_inv[11]) ~^ b1_data_even_inv[ 5]) &
                               ((b1_data_even_inv[11] ^ b1_data_even_inv[10]) ~^ b1_data_even_inv[ 4]) &
                               ((b1_data_even_inv[10] ^ b1_data_even_inv[ 9]) ~^ b1_data_even_inv[ 3]) &
                               ((b1_data_even_inv[ 9] ^ b1_data_even_inv[ 8]) ~^ b1_data_even_inv[ 2]) &
                               ((b1_data_even_inv[ 8] ^ b1_data_even_inv[ 7]) ~^ b1_data_even_inv[ 1]) &
                               ((b1_data_even_inv[ 7] ^ b1_data_even_inv[ 6]) ~^ b1_data_even_inv[ 0]); 

assign b2_prbs_data_in[15:0] = data_in[15:0];
//--  probably have to reverse xor constant
assign b2_data_odd_inv       = b2_prbs_data_in ^ 16'b1010101010101010;  //-- Creates either PRBS7 or the complement
assign b2_data_even_inv      = b2_prbs_data_in ^ 16'b0101010101010101;

assign b2_odd_inv_is_prbs7   = ((b2_data_odd_inv[15]  ^ b2_data_odd_inv[14])  ~^ b2_data_odd_inv[ 8]) &
                               ((b2_data_odd_inv[14]  ^ b2_data_odd_inv[13])  ~^ b2_data_odd_inv[ 7]) &
                               ((b2_data_odd_inv[13]  ^ b2_data_odd_inv[12])  ~^ b2_data_odd_inv[ 6]) &
                               ((b2_data_odd_inv[12]  ^ b2_data_odd_inv[11])  ~^ b2_data_odd_inv[ 5]) &
                               ((b2_data_odd_inv[11]  ^ b2_data_odd_inv[10])  ~^ b2_data_odd_inv[ 4]) &
                               ((b2_data_odd_inv[10]  ^ b2_data_odd_inv[ 9])  ~^ b2_data_odd_inv[ 3]) &
                               ((b2_data_odd_inv[ 9]  ^ b2_data_odd_inv[ 8])  ~^ b2_data_odd_inv[ 2]) &
                               ((b2_data_odd_inv[ 8]  ^ b2_data_odd_inv[ 7])  ~^ b2_data_odd_inv[ 1]) &
                               ((b2_data_odd_inv[ 7]  ^ b2_data_odd_inv[ 6])  ~^ b2_data_odd_inv[ 0]);

assign b2_even_inv_is_prbs7  = ((b2_data_even_inv[15] ^ b2_data_even_inv[14]) ~^ b2_data_even_inv[ 8]) &
                               ((b2_data_even_inv[14] ^ b2_data_even_inv[13]) ~^ b2_data_even_inv[ 7]) &
                               ((b2_data_even_inv[13] ^ b2_data_even_inv[12]) ~^ b2_data_even_inv[ 6]) &
                               ((b2_data_even_inv[12] ^ b2_data_even_inv[11]) ~^ b2_data_even_inv[ 5]) &
                               ((b2_data_even_inv[11] ^ b2_data_even_inv[10]) ~^ b2_data_even_inv[ 4]) &
                               ((b2_data_even_inv[10] ^ b2_data_even_inv[ 9]) ~^ b2_data_even_inv[ 3]) &
                               ((b2_data_even_inv[ 9] ^ b2_data_even_inv[ 8]) ~^ b2_data_even_inv[ 2]) &
                               ((b2_data_even_inv[ 8] ^ b2_data_even_inv[ 7]) ~^ b2_data_even_inv[ 1]) &
                               ((b2_data_even_inv[ 7] ^ b2_data_even_inv[ 6]) ~^ b2_data_even_inv[ 0]); 


assign error_detected     = (b1_odd_inv_is_prbs7 ~^ b1_even_inv_is_prbs7) | (b2_odd_inv_is_prbs7 ~^ b2_even_inv_is_prbs7);

assign rx_bist_reset_din  = rx_bist_reset;

assign reset_control[1:0] = {rx_bist_reset_q, rx_bist_reset_din};                               //-- current state, next state 

assign prbs_error_din     = ((1'b0                         ) & (reset_control[1:0] == 2'b10)) | //-- Falling edge,   clear 
                            ((error_detected | prbs_error_q) & (reset_control[1:0] == 2'b00)) | //-- Deasserted (0), capture
                            ((prbs_error_q                 ) & (reset_control[1:0] == 2'b01)) | //-- Asserted (1),   hold 
                            ((prbs_error_q                 ) & (reset_control[1:0] == 2'b11));  //-- Asserted (1),   hold 

assign prbs_error_out     = prbs_error_q;

assign omi_reset_n_din    = omi_reset_n;
assign reset = global_reset_control ? omi_reset_n_q : ~chip_reset;
dlc_ff #(.width(  1) ,.rstv({  1{1'b0}})) ff_omi_reset_n   (.clk(phy_dl_clock) ,.reset_n(1'b1         ) ,.enable(omi_enable) ,.din(omi_reset_n_din  ) ,.q(omi_reset_n_q  ));
dlc_ff #(.width(  8) ,.rstv({  8{1'b0}})) ff_rx_bist_data  (.clk(phy_dl_clock) ,.reset_n(reset) ,.enable(omi_enable) ,.din(rx_bist_data_din ) ,.q(rx_bist_data_q ));
dlc_ff #(.width(  1) ,.rstv({  1{1'b0}})) ff_rx_bist_reset (.clk(phy_dl_clock) ,.reset_n(reset) ,.enable(omi_enable) ,.din(rx_bist_reset_din) ,.q(rx_bist_reset_q));
dlc_ff #(.width(  1) ,.rstv({  1{1'b0}})) ff_prbs_error    (.clk(phy_dl_clock) ,.reset_n(reset) ,.enable(omi_enable) ,.din(prbs_error_din   ) ,.q(prbs_error_q   ));
  

endmodule //-- dlc_omi_prbs7_chk
