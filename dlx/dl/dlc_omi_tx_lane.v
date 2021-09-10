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
module dlc_omi_tx_lane (
// This macro receives 16 bits from the Align macro and inserts the sync headers and scrambles the data.   
// The output is 16 bits that are sent directly to the PHY.
// This macro also mux's in the training data from as directed by the training macro.
                        
// signal from align
  agn_ln_next_2B                //  input  [15:0]                       

// signals from training control
 ,trn_ln_scrambler              //  input  [15:0]                       
 ,trn_ln_train_data             //  input  [15:0]                       
 ,trn_ln_reverse                //  input                         
 ,trn_ln_disable                //  input
 ,trn_ln_phy_training           //  input                         
 ,trn_ln_dl_training            //  input                         
 ,trn_ln_tx_EDPL_ena            //  input
 ,trn_ln_tx_BEI_inject          //  input
//                        
// signals to the PHY
 ,dl_phy_lane                   //  output  [15:0]

 ,trn_reset_n                   //  input                         
 ,chip_reset                    //  input
 ,global_reset_control          //  input
 ,trn_enable                    //  input                         
 ,dl_clk                        //  input
);

input  [15:0]      agn_ln_next_2B;
input  [15:0]      trn_ln_scrambler;
input  [15:0]      trn_ln_train_data;
output [15:0]      dl_phy_lane;

input              trn_ln_reverse;
input              trn_ln_disable;
input              trn_ln_phy_training;
input              trn_ln_dl_training;
input              trn_ln_tx_EDPL_ena;
input              trn_ln_tx_BEI_inject;
input              trn_enable;
input              trn_reset_n;
input              dl_clk;
input              chip_reset;
input              global_reset_control;

wire               reset;
wire [15:0]        rev_data;
wire [15:0]        indata;
wire [15:0]        scram_data;
wire [15:0]        sync_hdr_insert;
wire [15:0]        align_data;
wire [15:0]        sync_header;

wire               spare00_din;
wire               spare00_q;
wire               spare01_din;
wire               spare01_q;
wire               spare02_din;
wire               spare02_q;
wire               spare03_din;
wire               spare03_q;
wire               spare04_din;
wire               spare04_q;
wire               spare05_din;
wire               spare05_q;
wire               spare06_din;
wire               spare06_q;
wire               spare07_din;
wire               spare07_q;
wire               spare08_din;
wire               spare08_q;
wire               spare09_din;
wire               spare09_q;
wire               spare10_din;
wire               spare10_q;
wire               spare11_din;
wire               spare11_q;
wire               spare12_din;
wire               spare12_q;
wire               spare13_din;
wire               spare13_q;
wire               spare14_din;
wire               spare14_q;
wire               spare15_din;
wire               spare15_q;
wire               spare16_din;
wire               spare16_q;
wire               spare17_din;
wire               spare17_q;
wire               spare18_din;
wire               spare18_q;
wire               spare19_din;
wire               spare19_q;
wire [15:0]        prev_2b_din;
wire [15:0]        prev_2b_q;
wire [5:0]         outmux_din;
wire [5:0]         outmux_q;
wire               cg_ena;
wire               reset_n_din;
wire               reset_n_q;
wire               parity_in;
wire               calc_parity_din;
wire               calc_parity_q;
wire               parity_toggle_din;
wire               parity_toggle_q;
wire [1:0]         tx_parity;
wire [1:0]         tx_edpl;
wire               inj_err;
wire               BEI_inject_dly_din;
wire               BEI_inject_dly_q;
wire               act_EDPL;   
wire [15:0]        parity_bits_din;
wire [15:0]        parity_bits_q;
wire               is_odd_par;
// tying spare latches to random data to ensure synthesis keeps them close  -- None of these connections are functionally used.
//-- reduce fanout on critical datapath
//--  11/16 assign spare00_din           = indata[0];                    // currently unused functionally
//--  11/16 assign spare01_din           = indata[1];                    // currently unused functionally
//--  11/16 assign spare02_din           = indata[2];                    // currently unused functionally
//--  11/16 assign spare03_din           = indata[3];                    // currently unused functionally
//--  11/16 assign spare04_din           = indata[4];                    // currently unused functionally
//--  11/16 assign spare05_din           = indata[5];                    // currently unused functionally
//--  11/16 assign spare06_din           = indata[6];                    // currently unused functionally
//--  11/16 assign spare07_din           = indata[7];                    // currently unused functionally
//--  11/16 assign spare08_din           = indata[8];                    // currently unused functionally
//--  11/16 assign spare09_din           = indata[9];                    // currently unused functionally
//--  11/16 assign spare10_din           = indata[10];                   // currently unused functionally
//--  11/16 assign spare11_din           = indata[11];                   // currently unused functionally
//--  11/16 assign spare12_din           = indata[12];                   // currently unused functionally
//--  11/16 assign spare13_din           = indata[13];                   // currently unused functionally
//--  11/16 assign spare14_din           = indata[14];                   // currently unused functionally
//--  11/16 assign spare15_din           = indata[15];                   // currently unused functionally
//--  11/16 assign spare16_din           = spare15_q | spare19_q;        // currently unused functionally
//--  11/16 assign spare17_din           = spare16_q;                    // currently unused functionally
//--  11/16 assign spare18_din           = spare17_q;                    // currently unused functionally
//--  11/16 assign spare19_din           = spare18_q;                    // currently unused functionally
assign spare00_din           = BEI_inject_dly_q;             // currently unused functionally
assign spare01_din           = spare00_q;                    // currently unused functionally
assign spare02_din           = spare01_q;                    // currently unused functionally
assign spare03_din           = spare02_q;                    // currently unused functionally
assign spare04_din           = spare03_q;                    // currently unused functionally
assign spare05_din           = spare04_q;                    // currently unused functionally
assign spare06_din           = spare05_q;                    // currently unused functionally
assign spare07_din           = spare06_q;                    // currently unused functionally
assign spare08_din           = spare07_q;                    // currently unused functionally
assign spare09_din           = spare08_q;                    // currently unused functionally
assign spare10_din           = spare09_q;                    // currently unused functionally
assign spare11_din           = spare10_q;                    // currently unused functionally
assign spare12_din           = spare11_q;                    // currently unused functionally
assign spare13_din           = spare12_q;                    // currently unused functionally
assign spare14_din           = spare13_q;                    // currently unused functionally
assign spare15_din           = spare14_q;                    // currently unused functionally
assign spare16_din           = spare15_q | spare19_q;        // currently unused functionally
assign spare17_din           = spare16_q;                    // currently unused functionally
assign spare18_din           = spare17_q;                    // currently unused functionally
assign spare19_din           = spare18_q;                    // currently unused functionally

// Need to reverse the bits since the PHY transmits from left to right, and Open CAPI is defined to send right most bit first
assign rev_data[15:0]        = {agn_ln_next_2B[0] ,agn_ln_next_2B[1] ,agn_ln_next_2B[2] ,agn_ln_next_2B[3] ,agn_ln_next_2B[4] ,agn_ln_next_2B[5] ,agn_ln_next_2B[6] ,agn_ln_next_2B[7],
                                agn_ln_next_2B[8] ,agn_ln_next_2B[9] ,agn_ln_next_2B[10],agn_ln_next_2B[11],agn_ln_next_2B[12],agn_ln_next_2B[13],agn_ln_next_2B[14],agn_ln_next_2B[15]};
//-- 5/15assign rev_data[15:0]        = {agn_ln_next_2B[8] ,agn_ln_next_2B[9] ,agn_ln_next_2B[10],agn_ln_next_2B[11],agn_ln_next_2B[12],agn_ln_next_2B[13],agn_ln_next_2B[14],agn_ln_next_2B[15],
//-- 5/15                                agn_ln_next_2B[0] ,agn_ln_next_2B[1] ,agn_ln_next_2B[2] ,agn_ln_next_2B[3] ,agn_ln_next_2B[4] ,agn_ln_next_2B[5] ,agn_ln_next_2B[6] ,agn_ln_next_2B[7]};
  
   
// configuration setting to choose which bits are transmitted first since we are not allows connected to IBM PHY
assign indata[15:0]          = trn_ln_reverse  ?  agn_ln_next_2B[15:0] : rev_data[15:0];

// Each lane receives its scrambling pattern from the training leaf to ensure each lane is changing at different times but using the same prbs23 pattern.
assign scram_data[15:0]      = (indata[15:0] ^ trn_ln_scrambler[15:0]) ^ {{8{1'b0}}, inj_err, {7{1'b0}}};

//-- inject error on next cycle if inject was supposed to happen on the stall cycle
assign inj_err               = BEI_inject_dly_q | (~BEI_inject_dly_q & ~outmux_q[5] & trn_ln_tx_BEI_inject);
assign BEI_inject_dly_din    = trn_ln_tx_BEI_inject & outmux_q[5];

// when the sync header is inserted,  we need to save the bits that couldn't be sent.  These need to the the next bits that are transmitted.
assign prev_2b_din[15:0]     = ({scram_data[1:0] ,14'b00000000000000}   & {16{outmux_q[5:2]==4'h0}}) |
                               ({scram_data[3:0] ,12'b000000000000}     & {16{outmux_q[5:2]==4'h1}}) |
                               ({scram_data[5:0] ,10'b0000000000}       & {16{outmux_q[5:2]==4'h2}}) |
                               ({scram_data[7:0] , 8'b00000000}         & {16{outmux_q[5:2]==4'h3}}) |
                               ({scram_data[9:0] , 6'b000000}           & {16{outmux_q[5:2]==4'h4}}) |
                               ({scram_data[11:0], 4'b0000}             & {16{outmux_q[5:2]==4'h5}}) |
                               ({scram_data[13:0], 2'b00}               & {16{outmux_q[5:2]==4'h6}}) |
                               ({scram_data[15:0]                     } & {16{outmux_q[5:2]==4'h7}}) |
                               ({                 16'b0000000000000000} & {16{outmux_q[5]  ==1'b1}});     // outmux = 8-15


//-- latch incoming 16 bits to determine parity next cycle.  Data during stall is garbage
assign parity_bits_din[15:0] = (outmux_q[5]) ? parity_bits_q[15:0] : agn_ln_next_2B[15:0];

//-- determine the parity of the incoming 16 bits
assign parity_in             = (^parity_bits_q[15:0]);    //-- xor reduce of the 16 bits
assign is_odd_par            = parity_in ^ calc_parity_q; //-- calc_parity_q is prev cycle's parity
                               
// store the parity and use the following cycles since it takes 4 cycles to receive the entire block. '1' is odd number of ones detected
assign calc_parity_din       = (outmux_q[5  ] == 1'b1 ) ? calc_parity_q : //-- hold    parity on stall
                               (outmux_q[1:0] == 2'b01) ? parity_in     : //-- restart parity calculation
                                                          is_odd_par;

// when the parity is odd, we need to transmit "00" and "11" alternately to maintain the DC balance on the link.
assign parity_toggle_din     = ((outmux_q[1:0] == 2'b00) & ~(outmux_q[5:0] == 6'b100000) & is_odd_par) ? ~parity_toggle_q : parity_toggle_q;

// Determine which encoding to transmit
assign tx_parity[1:0]        = (is_odd_par == 1'b0) ? 2'b01 :
                                parity_toggle_q     ? 2'b11 :
                                                      2'b00;

// When enabled, transmit the EDPL for this lane.calculate per lane parity for this lane.
assign tx_edpl[1:0]          = trn_ln_tx_EDPL_ena ? tx_parity[1:0] : 2'b01;

// different sync header based on if we are sending training blocks are flits.
assign sync_header[15:0]     = trn_ln_dl_training ? 16'hAAAA : {tx_edpl[1:0],tx_edpl[1:0],tx_edpl[1:0],tx_edpl[1:0],tx_edpl[1:0],tx_edpl[1:0],tx_edpl[1:0],tx_edpl[1:0]};  


// Only need to send the sync headers every fourth cycle  
assign sync_hdr_insert[15:0] = (outmux_q[1:0] == 2'b00) ? sync_header[15:0] : prev_2b_q[15:0];
 
// Actual data to be sent out for training states 4-7 - state 7 in transmission of flits
assign align_data[15:0]      = ({                  sync_hdr_insert[15:14], scram_data[15: 2]} & {16{outmux_q[5:2]==4'h0}}) | 
                               ({prev_2b_q[15:14], sync_hdr_insert[13:12], scram_data[15: 4]} & {16{outmux_q[5:2]==4'h1}}) |
                               ({prev_2b_q[15:12], sync_hdr_insert[11:10], scram_data[15: 6]} & {16{outmux_q[5:2]==4'h2}}) |
                               ({prev_2b_q[15:10], sync_hdr_insert[ 9: 8], scram_data[15: 8]} & {16{outmux_q[5:2]==4'h3}}) |
                               ({prev_2b_q[15: 8], sync_hdr_insert[ 7: 6], scram_data[15:10]} & {16{outmux_q[5:2]==4'h4}}) |
                               ({prev_2b_q[15: 6], sync_hdr_insert[ 5: 4], scram_data[15:12]} & {16{outmux_q[5:2]==4'h5}}) |
                               ({prev_2b_q[15: 4], sync_hdr_insert[ 3: 2], scram_data[15:14]} & {16{outmux_q[5:2]==4'h6}}) |
                               ({prev_2b_q[15: 2], sync_hdr_insert[ 1: 0]                   } & {16{outmux_q[5:2]==4'h7}}) |
                               ({prev_2b_q[15: 0]                                           } & {16{outmux_q[5]  ==1'b1}});   // outmux = 8-15
   

// during training states 1-3,  the training leaf dictates what is being sent on each lane. 
assign dl_phy_lane[15:0]     = (trn_ln_disable | trn_ln_phy_training) ? trn_ln_train_data[15:0] : align_data[15:0];

// counter to know how much left over data we need to send out.
assign outmux_din[5:0]       = (trn_ln_phy_training | (outmux_q[5] == 1'b1)) ? 6'b000000 : (outmux_q[5:0] + 6'b000001);

// clock gating for flip flops (of of 90% of flip flops functionally clock gated and 100% clock gated if unused.
assign cg_ena                = trn_enable;
assign act_EDPL              = cg_ena & (trn_ln_tx_EDPL_ena | ~reset);
// flip flop reset signal.  latch to reduce fanout
assign reset_n_din           = trn_reset_n;
assign reset                 = global_reset_control ? reset_n_q : ~chip_reset;
// latch modules, In order to work with different technologies, we can call in a modl
dlc_ff_spare #(.width(  1) ,.rstv({   {1'b0}})) ff_spare00                         (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(cg_ena    )  ,.din(spare00_din                         )  ,.q(spare00_q                         ) );
dlc_ff_spare #(.width(  1) ,.rstv({   {1'b0}})) ff_spare01                         (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(cg_ena    )  ,.din(spare01_din                         )  ,.q(spare01_q                         ) );
dlc_ff_spare #(.width(  1) ,.rstv({   {1'b0}})) ff_spare02                         (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(cg_ena    )  ,.din(spare02_din                         )  ,.q(spare02_q                         ) );
dlc_ff_spare #(.width(  1) ,.rstv({   {1'b0}})) ff_spare03                         (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(cg_ena    )  ,.din(spare03_din                         )  ,.q(spare03_q                         ) );
dlc_ff_spare #(.width(  1) ,.rstv({   {1'b0}})) ff_spare04                         (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(cg_ena    )  ,.din(spare04_din                         )  ,.q(spare04_q                         ) );
dlc_ff_spare #(.width(  1) ,.rstv({   {1'b0}})) ff_spare05                         (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(cg_ena    )  ,.din(spare05_din                         )  ,.q(spare05_q                         ) );
dlc_ff_spare #(.width(  1) ,.rstv({   {1'b0}})) ff_spare06                         (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(cg_ena    )  ,.din(spare06_din                         )  ,.q(spare06_q                         ) );
dlc_ff_spare #(.width(  1) ,.rstv({   {1'b0}})) ff_spare07                         (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(cg_ena    )  ,.din(spare07_din                         )  ,.q(spare07_q                         ) );
dlc_ff_spare #(.width(  1) ,.rstv({   {1'b0}})) ff_spare08                         (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(cg_ena    )  ,.din(spare08_din                         )  ,.q(spare08_q                         ) );
dlc_ff_spare #(.width(  1) ,.rstv({   {1'b0}})) ff_spare09                         (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(cg_ena    )  ,.din(spare09_din                         )  ,.q(spare09_q                         ) );
dlc_ff_spare #(.width(  1) ,.rstv({   {1'b0}})) ff_spare10                         (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(cg_ena    )  ,.din(spare10_din                         )  ,.q(spare10_q                         ) );
dlc_ff_spare #(.width(  1) ,.rstv({   {1'b0}})) ff_spare11                         (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(cg_ena    )  ,.din(spare11_din                         )  ,.q(spare11_q                         ) );
dlc_ff_spare #(.width(  1) ,.rstv({   {1'b0}})) ff_spare12                         (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(cg_ena    )  ,.din(spare12_din                         )  ,.q(spare12_q                         ) );
dlc_ff_spare #(.width(  1) ,.rstv({   {1'b0}})) ff_spare13                         (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(cg_ena    )  ,.din(spare13_din                         )  ,.q(spare13_q                         ) );
dlc_ff_spare #(.width(  1) ,.rstv({   {1'b0}})) ff_spare14                         (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(cg_ena    )  ,.din(spare14_din                         )  ,.q(spare14_q                         ) );
dlc_ff_spare #(.width(  1) ,.rstv({   {1'b0}})) ff_spare15                         (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(cg_ena    )  ,.din(spare15_din                         )  ,.q(spare15_q                         ) );
dlc_ff_spare #(.width(  1) ,.rstv({   {1'b0}})) ff_spare16                         (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(cg_ena    )  ,.din(spare16_din                         )  ,.q(spare16_q                         ) );
dlc_ff_spare #(.width(  1) ,.rstv({   {1'b0}})) ff_spare17                         (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(cg_ena    )  ,.din(spare17_din                         )  ,.q(spare17_q                         ) );
dlc_ff_spare #(.width(  1) ,.rstv({   {1'b0}})) ff_spare18                         (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(cg_ena    )  ,.din(spare18_din                         )  ,.q(spare18_q                         ) );
dlc_ff_spare #(.width(  1) ,.rstv({   {1'b0}})) ff_spare19                         (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(cg_ena    )  ,.din(spare19_din                         )  ,.q(spare19_q                         ) );
dlc_ff       #(.width(  1) ,.rstv({   {1'b0}})) ff_parity_toggle                   (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(act_EDPL  )  ,.din(parity_toggle_din                   )  ,.q(parity_toggle_q                   ) );
dlc_ff       #(.width(  1) ,.rstv({   {1'b0}})) ff_calc_parity                     (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(act_EDPL  )  ,.din(calc_parity_din                     )  ,.q(calc_parity_q                     ) );
dlc_ff       #(.width( 16) ,.rstv({ 16{1'b0}})) ff_prev_2b                         (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(cg_ena    )  ,.din(prev_2b_din                         )  ,.q(prev_2b_q                         ) );
dlc_ff       #(.width( 16) ,.rstv({ 16{1'b0}})) ff_parity_bits                     (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(cg_ena    )  ,.din(parity_bits_din                     )  ,.q(parity_bits_q                     ) );
dlc_ff       #(.width(  6) ,.rstv({  6{1'b0}})) ff_outmux                          (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(cg_ena    )  ,.din(outmux_din                          )  ,.q(outmux_q                          ) );
dlc_ff       #(.width(  1) ,.rstv({   {1'b0}})) ff_BEI_inject_dly                  (.clk(dl_clk)  ,.reset_n(reset)  ,.enable(cg_ena    )  ,.din(BEI_inject_dly_din                  )  ,.q(BEI_inject_dly_q                  ) );
dlc_ff       #(.width(  1) ,.rstv({   {1'b0}})) ff_reset_n                         (.clk(dl_clk)  ,.reset_n(1'b1 )  ,.enable(cg_ena    )  ,.din(reset_n_din                         )  ,.q(reset_n_q                         ) );

endmodule  // dlc_omi_tx_lane
