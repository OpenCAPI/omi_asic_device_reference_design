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
//-- $Id: dlc_ecc_gen.vhdl 1 2017-03-15 01:13:23Z  $
//-- $URL: file:///
//-- 
//-- 
//-- 
//-- 
//-- 
//-- @(#)$Name: $
//--  -
//-- *!********************************************************************
//-- *!           
//-- *!********************************************************************
//-- *! FILENAME    : dlc_ecc_gen.vhdl
//-- *! TITLE       : ECC gen macro file
//-- *! DESCRIPTION : This macro contains the ECC generation logic
//-- *!
//-- *! OWNER NAME  :  
//-- *!  NAME :  
//-- *!
//-- *!********************************************************************
//-- *!
//-- *!
//-- *!           1         2         3         4         5         6          7           01234567
//-- *! 0123456789012345678901234567890123456789012345678901234567890123 45678901 23456789 cccccccc
//-- *!
//-- *! 1111111100000000000000001110100001000010001111000000111110011001 11110001 10100111 10000000
//-- *! 1001100111111111000000000000000011101000010000100011110000001111 11111000 11010011 01000000
//-- *! 0000111110011001111111110000000000000000111010000100001000111100 01111100 11101001 00100000
//-- *! 0011110000001111100110011111111100000000000000001110100001000010 00111110 11110100 00010000
//-- *! 0100001000111100000011111001100111111111000000000000000011101000 00011111 01111010 00001000
//-- *! 1110100001000010001111000000111110011001111111110000000000000000 10001111 00111101 00000100
//-- *! 0000000011101000010000100011110000001111100110011111111100000000 11000111 10011110 00000010
//-- *! 0000000000000000111010000100001000111100000011111001100111111111 11100011 01001111 00000001
//-- *!
//-- *! ECC Symetry
//-- *!
//-- *! 0-31                                                            64-67     72-75
//-- *!
//-- *! 11111111000000000000000011101000                                1111      1010      ecc(0-3)
//-- *! 10011001111111110000000000000000                                1111      1101
//-- *! 00001111100110011111111100000000                                0111      1110
//-- *! 00111100000011111001100111111111                                0011      1111
//-- *!                                            32-63                    68-71     76-79
//-- *!                                 11111111000000000000000011101000    1111      1010
//-- *!                                 10011001111111110000000000000000    1111      1101  ecc(4-7)
//-- *!                                 00001111100110011111111100000000    0111      1110
//-- *!                                 00111100000011111001100111111111    0011      1111
//-- *!
//-- *!***************************************************************************
//-- CHANGE HISTORY:
//--------------------------------------------------------------------------------
//-- Version:|Author: | Date:  | Comment:
//-- --------|--------|--------|--------------------------------------------------
//--         |
//--         |
//--         |
//--------------------------------------------------------------------------------

`timescale 100ps/10ps

module dlc_ecc_gen  (
   input  [63:0]  datain
  ,input          derrin
  ,output [7:0]   ecc_out
);

wire [63:0]  din;

wire [7:0] lev10;
wire [7:0] lev11;
wire [7:0] lev12;
wire [7:0] lev13;
wire [7:0] lev14;
wire [7:0] lev15;
wire [7:0] lev16;
wire [7:0] lev17;

wire [1:0] lev20;
wire [1:0] lev21;
wire [1:0] lev22;
wire [1:0] lev23;
wire [1:0] lev24;
wire [1:0] lev25;
wire [1:0] lev26;
wire [1:0] lev27;


wire do_sue;


assign do_sue = derrin;


assign din[63:0] =   datain[63:0];

//-- First ECC bit

//-- [odd -> XOR tree, Not odd -> XOR tree + output INV]
//-- Note: a NOT XOR can be replaced by an XNOR

assign lev10[7] = din[63] ^ din[62] ^ din[61] ^ din[60];
assign lev10[6] = din[59] ^ din[58] ^ din[57] ^ din[56];
assign lev10[5] = din[39] ^ din[38] ^ din[37] ^ din[35];
assign lev10[4] = din[30] ^ din[25];
assign lev10[3] = din[21] ^ din[20] ^ din[19] ^ din[18];
assign lev10[2] = din[11] ^ din[10] ^ din[9] ^ din[8];
assign lev10[1] = din[7] ^ din[4] ^ din[3] ^ din[0];

assign lev20[1] = lev10[7] ^ lev10[6] ^ lev10[5];
assign lev20[0] = lev10[3] ^ lev10[2] ^ lev10[1] ^ lev10[4];

assign ecc_out[7] = lev20[1] ^ lev20[0] ^ do_sue;

//-- Second ECC bit

assign lev11[7] = din[63] ^ din[60] ^ din[59] ^ din[56];
assign lev11[6] = din[55] ^ din[54] ^ din[53] ^ din[52];
assign lev11[5] = din[51] ^ din[50] ^ din[49] ^ din[48];
assign lev11[4] = din[31] ^ din[30] ^ din[29] ^ din[27];
assign lev11[3] = din[22] ^ din[17];
assign lev11[2] = din[13] ^ din[12] ^ din[11] ^ din[10];
assign lev11[1] = din[3] ^ din[2] ^ din[1] ^ din[0];

assign lev21[1] = lev11[7] ^ lev11[6] ^ lev11[5];
assign lev21[0] = lev11[3] ^ lev11[2] ^ lev11[1] ^ lev11[4];

assign ecc_out[6] = lev21[1] ^ lev21[0] ^ do_sue;

//-- Third ECC bit

assign lev12[7] = lev10[6];
assign lev12[6] = din[55] ^ din[52] ^ din[51] ^ din[48];
assign lev12[5] = din[47] ^ din[46] ^ din[45] ^ din[44];
assign lev12[4] = din[43] ^ din[42] ^ din[41] ^ din[40];
assign lev12[3] = din[23] ^ din[22] ^ din[21] ^ din[19];
assign lev12[2] = din[14] ^ din[9];
assign lev12[1] = din[5] ^ din[4] ^ din[3] ^ din[2];

assign lev22[1] = lev12[7] ^ lev12[6] ^ lev12[5] ^ lev12[4];
assign lev22[0] = lev12[3] ^ lev12[2] ^ lev12[1];

assign ecc_out[5] = lev22[1] ^ lev22[0] ^ do_sue;

//-- Fourth ECC bit

assign lev13[7] = din[61] ^ din[60] ^ din[59] ^ din[58];
assign lev13[6] = lev11[5];
assign lev13[5] = din[47] ^ din[44] ^ din[43] ^ din[40];
assign lev13[4] = din[39] ^ din[38] ^ din[37] ^ din[36];
assign lev13[3] = din[35] ^ din[34] ^ din[33] ^ din[32];
assign lev13[2] = din[15] ^ din[14] ^ din[13] ^ din[11];
assign lev13[1] = din[6] ^ din[1];

assign lev23[1] = lev13[7] ^ lev13[6] ^ lev13[5] ^ lev13[4];
assign lev23[0] = lev13[3] ^ lev13[2] ^ lev13[1];

assign ecc_out[4] = lev23[1] ^ lev23[0] ^ do_sue;

//-- Fifth ECC bit

assign lev14[7] = din[62] ^ din[57];
assign lev14[6] = din[53] ^ din[52] ^ din[51] ^ din[50];
assign lev14[5] = lev12[4];
assign lev14[4] = din[39] ^ din[36] ^ din[35] ^ din[32];
assign lev14[3] = din[31] ^ din[30] ^ din[29] ^ din[28];
assign lev14[2] = din[27] ^ din[26] ^ din[25] ^ din[24];
assign lev14[1] = din[7] ^ din[6] ^ din[5] ^ din[3];

assign lev24[1] = lev14[7] ^ lev14[6] ^ lev14[5] ^ lev14[4];
assign lev24[0] = lev14[3] ^ lev14[2] ^ lev14[1];

assign ecc_out[3] = lev24[1] ^ lev24[0] ^ do_sue;

//-- Sixth ECC bit

assign lev15[7] = din[63] ^ din[62] ^ din[61] ^ din[59];
assign lev15[6] = din[54] ^ din[49];
assign lev15[5] = din[45] ^ din[44] ^ din[43] ^ din[42];
assign lev15[4] = lev13[3];
assign lev15[3] = din[31] ^ din[28] ^ din[27] ^ din[24];
assign lev15[2] = din[23] ^ din[22] ^ din[21] ^ din[20];
assign lev15[1] = din[19] ^ din[18] ^ din[17] ^ din[16];

assign lev25[1] = lev15[7] ^ lev15[6] ^ lev15[5];
assign lev25[0] = lev15[3] ^ lev15[2] ^ lev15[1] ^ lev15[4];

assign ecc_out[2] = lev25[1] ^ lev25[0] ^ do_sue;

//-- Seventh ECC bit

assign lev16[7] = din[55] ^ din[54] ^ din[53] ^ din[51];
assign lev16[6] = din[46] ^ din[41];
assign lev16[5] = din[37] ^ din[36] ^ din[35] ^ din[34];
assign lev16[4] = lev14[2];
assign lev16[3] = din[23] ^ din[20] ^ din[19] ^ din[16];
assign lev16[2] = din[15] ^ din[14] ^ din[13] ^ din[12];
assign lev16[1] = lev10[2];

assign lev26[1] = lev16[7] ^ lev16[6] ^ lev16[5];
assign lev26[0] = lev16[3] ^ lev16[2] ^ lev16[1] ^ lev16[4];

assign ecc_out[1] = lev26[1] ^ lev26[0] ^ do_sue;

//-- Eigth ECC bit

assign lev17[7] = din[47] ^ din[46] ^ din[45] ^ din[43];
assign lev17[6] = din[38] ^ din[33];
assign lev17[5] = din[29] ^ din[28] ^ din[27] ^ din[26];
assign lev17[4] = lev15[1];
assign lev17[3] = din[15] ^ din[12] ^ din[11] ^ din[8];
assign lev17[2] = din[7] ^ din[6] ^ din[5] ^ din[4];
assign lev17[1] = lev11[1];

assign lev27[1] = lev17[7] ^ lev17[6] ^ lev17[5];
assign lev27[0] = lev17[3] ^ lev17[2] ^ lev17[1] ^ lev17[4];

assign ecc_out[0] = lev27[1] ^ lev27[0];



//-- MAKEREGS REGISTER INSTANTIATIONS START
//---------------------------------------------------------------
//-- Register instantiations auto-generated by MAKEREGS v 1.88 --
//---------------------------------------------------------------
//-- No latches found in this VHDL!
//-- MAKEREGS REGISTER INSTANTIATIONS END
endmodule  //-- dlc_ecc_gen;

