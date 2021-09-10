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
//-- $Id: dlc_ecc_chk.vhdl 1 2017-03-15 01:13:23Z  $
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
//-- *! FILENAME    : dlc_ecc_chk.vhdl
//-- *! TITLE       : ECC Checking macro file
//-- *! DESCRIPTION : This macro contains the ECC checking logic
//-- *!               We are generating here the 8 syndrome bits, CE, UE, and SUE bits.
//-- *!               This macro does not include any latches
//-- *!
//-- *! OWNER NAME  :  
//-- *!  NAME :  
//-- *!
//-- *!********************************************************************
//-- *!
//-- *!
//-- *!             1         2         3         4         5         6          7           01234567
//-- *!   01234567890123456789012345678901234567890123456789012345678901234 5678901 23456789 cccccccc
//-- *!
//-- *!   11111111000000000000000011101000010000100011110000001111100110011 1110001 10100111 10000000
//-- *!   10011001111111110000000000000000111010000100001000111100000011111 1111000 11010011 01000000
//-- *!   00001111100110011111111100000000000000001110100001000010001111000 1111100 11101001 00100000
//-- *!   00111100000011111001100111111111000000000000000011101000010000100 0111110 11110100 00010000
//-- *!   01000010001111000000111110011001111111110000000000000000111010000 0011111 01111010 00001000
//-- *!   11101000010000100011110000001111100110011111111100000000000000001 0001111 00111101 00000100
//-- *!   00000000111010000100001000111100000011111001100111111111000000001 1000111 10011110 00000010
//-- *!   00000000000000001110100001000010001111000000111110011001111111111 1100011 01001111 00000001
//-- *!
//--    CHANGE HISTORY:
//--------------------------------------------------------------------------------
//-- Version:|Author: | Date:  | Comment:
//-- --------|--------|--------|--------------------------------------------------
//--         |
//--         |
//--------------------------------------------------------------------------------
//-- Log history:: $

`timescale 100ps/10ps


module dlc_ecc_chk (
   input  [63:0] data                           // in std_ulogic_vector (0 to 63);
  ,input  [7:0]  ecc                            // in std_ulogic_vector (0 to 7);
  ,input         dval                           // in std_ulogic;
  ,input         ecc_cor_disable                // in std_ulogic;
  ,output [7:0]  syn                            // out std_ulogic_vector (0 to 7);
  ,output        ce                             // out std_ulogic;
  ,output        sue                            // out std_ulogic;
  ,output        ue                             // out std_ulogic
);

  wire [63:0] din;
  wire [7:0]  in_ecc;
  wire [7:0]  lev10;
  wire [1:0]  lev20;
  wire [7:0]  syn_out;
  wire [7:0]  lev11;
  wire [1:0]  lev21;
  wire [7:0]  lev12;
  wire [1:0]  lev22;
  wire [7:0]  lev13;
  wire [1:0]  lev23;
  wire [7:0]  lev14;
  wire [1:0]  lev24;
  wire [7:0]  lev15;
  wire [1:0]  lev25;
  wire [7:0]  lev16;
  wire [1:0]  lev26;
  wire [7:0]  lev17;
  wire [1:0]  lev27;
  wire        data_valid;
  wire        s_nz;
  wire        s_sue;
  wire        s_even;
  wire        s_ue;


assign din[63:0]     =  data[63:0];
assign in_ecc[7:0]   =  ecc[7:0];

//--****************************************************************************
//--****************************************************************************
//--****************************************************************************
//-- Checking Phase: syndrone generation
//--****************************************************************************
//--****************************************************************************
//--****************************************************************************

//-- Syndrome 0

assign lev10[7] = din[63] ^ din[62] ^ din[61] ^ din[60];
assign lev10[6] = din[59] ^ din[58] ^ din[57] ^ din[56];
assign lev10[5] = din[39] ^ din[38] ^ din[37] ^ din[35];
assign lev10[4] = din[30] ^ din[25];
assign lev10[3] = din[21] ^ din[20] ^ din[19] ^ din[18];
assign lev10[2] = din[11] ^ din[10] ^ din[9] ^ din[8];
assign lev10[1] = din[7] ^ din[4] ^ din[3] ^ din[0];
assign lev10[0] = in_ecc[7];

assign lev20[1] = lev10[7] ^ lev10[6] ^ lev10[5] ^ lev10[0];   
assign lev20[0] = lev10[3] ^ lev10[2] ^ lev10[1] ^ lev10[4];
 
assign syn_out[7] = lev20[1] ^ lev20[0];

//-- Syndrome 1

assign lev11[7] = din[63] ^ din[60] ^ din[59] ^ din[56];
assign lev11[6] = din[55] ^ din[54] ^ din[53] ^ din[52];
assign lev11[5] = din[51] ^ din[50] ^ din[49] ^ din[48];
assign lev11[4] = din[31] ^ din[30] ^ din[29] ^ din[27];
assign lev11[3] = din[22] ^ din[17];
assign lev11[2] = din[13] ^ din[12] ^ din[11] ^ din[10];
assign lev11[1] = din[3] ^ din[2] ^ din[1] ^ din[0];
assign lev11[0] = in_ecc[6];

assign lev21[1] = lev11[7] ^ lev11[6] ^ lev11[5] ^ lev11[0];   
assign lev21[0] = lev11[3] ^ lev11[2] ^ lev11[1] ^ lev11[4];   

assign syn_out[6] = lev21[1] ^ lev21[0];

//-- Syndrome 2

assign lev12[7] = lev10[6];
assign lev12[6] = din[55] ^ din[52] ^ din[51] ^ din[48];
assign lev12[5] = din[47] ^ din[46] ^ din[45] ^ din[44];
assign lev12[4] = din[43] ^ din[42] ^ din[41] ^ din[40];
assign lev12[3] = din[23] ^ din[22] ^ din[21] ^ din[19];
assign lev12[2] = din[14] ^ din[9];
assign lev12[1] = din[5] ^ din[4] ^ din[3] ^ din[2];
assign lev12[0] = in_ecc[5];

assign lev22[1] = lev12[7] ^ lev12[6] ^ lev12[5] ^ lev12[4];
assign lev22[0] = lev12[3] ^ lev12[2] ^ lev12[1] ^ lev12[0];

assign syn_out[5] = lev22[1] ^ lev22[0];

//-- Syndrome 3

assign lev13[7] = din[61] ^ din[60] ^ din[59] ^ din[58];
assign lev13[6] = lev11[5];
assign lev13[5] = din[47] ^ din[44] ^ din[43] ^ din[40];
assign lev13[4] = din[39] ^ din[38] ^ din[37] ^ din[36];
assign lev13[3] = din[35] ^ din[34] ^ din[33] ^ din[32];
assign lev13[2] = din[15] ^ din[14] ^ din[13] ^ din[11];
assign lev13[1] = din[6] ^ din[1];
assign lev13[0] = in_ecc[4];

assign lev23[1] = lev13[7] ^ lev13[6] ^ lev13[5] ^ lev13[4];
assign lev23[0] = lev13[3] ^ lev13[2] ^ lev13[1] ^ lev13[0];

assign syn_out[4] = lev23[1] ^ lev23[0];

//-- Syndrome 4

assign lev14[7] = din[62] ^ din[57];
assign lev14[6] = din[53] ^ din[52] ^ din[51] ^ din[50];
assign lev14[5] = lev12[4];
assign lev14[4] = din[39] ^ din[36] ^ din[35] ^ din[32];
assign lev14[3] = din[31] ^ din[30] ^ din[29] ^ din[28];
assign lev14[2] = din[27] ^ din[26] ^ din[25] ^ din[24];
assign lev14[1] = din[7] ^ din[6] ^ din[5] ^ din[3];
assign lev14[0] = in_ecc[3];

assign lev24[1] = lev14[7] ^ lev14[6] ^ lev14[5] ^ lev14[4];
assign lev24[0] = lev14[3] ^ lev14[2] ^ lev14[1] ^ lev14[0];

assign syn_out[3] = lev24[1] ^ lev24[0];

//-- Syndrome 5

assign lev15[7] = din[63] ^ din[62] ^ din[61] ^ din[59];
assign lev15[6] = din[54] ^ din[49];
assign lev15[5] = din[45] ^ din[44] ^ din[43] ^ din[42];
assign lev15[4] = lev13[3];
assign lev15[3] = din[31] ^ din[28] ^ din[27] ^ din[24];
assign lev15[2] = din[23] ^ din[22] ^ din[21] ^ din[20];
assign lev15[1] = din[19] ^ din[18] ^ din[17] ^ din[16];
assign lev15[0] = in_ecc[2];

assign lev25[1] = lev15[7] ^ lev15[6] ^ lev15[5] ^ lev15[0];   
assign lev25[0] = lev15[3] ^ lev15[2] ^ lev15[1] ^ lev15[4];   

assign syn_out[2] = lev25[1] ^ lev25[0];

//-- Syndrome 6

assign lev16[7] = din[55] ^ din[54] ^ din[53] ^ din[51];
assign lev16[6] = din[46] ^ din[41];
assign lev16[5] = din[37] ^ din[36] ^ din[35] ^ din[34];
assign lev16[4] = lev14[2];
assign lev16[3] = din[23] ^ din[20] ^ din[19] ^ din[16];
assign lev16[2] = din[15] ^ din[14] ^ din[13] ^ din[12];
assign lev16[1] = lev10[2];
assign lev16[0] = in_ecc[1];

assign lev26[1] = lev16[7] ^ lev16[6] ^ lev16[5] ^ lev16[0];   
assign lev26[0] = lev16[3] ^ lev16[2] ^ lev16[1] ^ lev16[4];   

assign syn_out[1] = lev26[1] ^ lev26[0];

//-- Syndrome 7

assign lev17[7] = din[47] ^ din[46] ^ din[45] ^ din[43];
assign lev17[6] = din[38] ^ din[33];
assign lev17[5] = din[29] ^ din[28] ^ din[27] ^ din[26];
assign lev17[4] = lev15[1];
assign lev17[3] = din[15] ^ din[12] ^ din[11] ^ din[8];
assign lev17[2] = din[7] ^ din[6] ^ din[5] ^ din[4];
assign lev17[1] = lev11[1];
assign lev17[0] = in_ecc[0];



assign lev27[1] = lev17[7] ^ lev17[6] ^ lev17[5] ^ lev17[0];   
assign lev27[0] = lev17[3] ^ lev17[2] ^ lev17[1] ^ lev17[4];   

assign syn_out[0] = lev27[1] ^ lev27[0];

//--****************************************************************************
//--****************************************************************************
//--****************************************************************************
//-- Error bit generation:
//--****************************************************************************
//--****************************************************************************
//--****************************************************************************

//----------------------------------------------------------------------------------
//-- if all syndromes are not 0 there is an error
//----------------------------------------------------------------------------------

assign data_valid = dval && ~ecc_cor_disable;

assign s_nz     = (syn_out[7] || syn_out[6] || //--syndrome is non-zero
                   syn_out[5] || syn_out[4] ||
                   syn_out[3] || syn_out[2] ||
                   syn_out[1] || syn_out[0]) && data_valid;

//----------------------------------------------------------------------------------
//-- Special UE detection logic [yyyJSD 08/19/98]
//--   A 'special UE' occurs when the first 7 out of 8 syndromes are all 1's.
//----------------------------------------------------------------------------------

assign s_sue = (syn_out[7] && syn_out[6] && syn_out[5] &&  syn_out[4] &&
                syn_out[3] && syn_out[2] && syn_out[1] && ~syn_out[0]) && data_valid;

assign sue = s_sue;

//----------------------------------------------------------------------------------
//-- UE signal generation  
//----------------------------------------------------------------------------------

//-- ** All even syndrone are UE. **

//-- All these are valid syndrones.             These odd syndrone are UE.  Need to feed this into 

//-- 0000 0000   -
//-- 0000 0001  79
//-- 0000 0010  78
//-- 0000 0100  77
//-- 0000 1000  76
//-- 0000 0111  47
//-- 0000 1011  37
//-- 0000 1101  35
//-- 0000 1110  39

//-- 0001 0000  75
//-- 0001 0011  48
//-- 0001 0101  30
//-- 0001 0110  29
//-- 0001 1001  57
//-- 0001 1010  27
//-- 0001 1100  31
//-- 0001 1111  70

//-- 0010 0000  74
//-- 0010 0011  17
//-- 0010 0101  18
//-- 0010 0110  40
//-- 0010 1001  58
//-- 0010 1010  22
//-- 0010 1100  21                                    
//-- 0010 1111  76

//-- 0011 0001  16                                    -- 0011 0111
//-- 0011 0010  49                                    -- 0011 1011
//-- 0011 0100  19
//-- 0011 1000  23
//-- 0011 1101  20
//-- 0011 1110  69

//-- 0100 0000  73
//-- 0100 0011  51
//-- 0100 0101  46
//-- 0100 0110   9
//-- 0100 1001  34
//-- 0100 1010  10
//-- 0100 1100  32
//-- 0100 1111  36

//-- 0101 0001  62                                   -- 0101 0111
//-- 0101 0010  50                                   -- 0101 1011
//-- 0101 0100  14                                   -- 0101 1101
//-- 0101 1000  13                                   
//-- 0101 1110  75

//-- 0110 0001  61                                   -- 0110 0111
//-- 0110 0010   8                                   -- 0110 1011
//-- 0110 0100  41                                   -- 0110 1101
//-- 0110 1000  11                                   -- 0110 1110

//-- 0111 0000  15                                   -- 0111 0011
//-- 0111 1010  12                                   -- 0111 0101
//-- 0111 1100  68                                   -- 0111 0110
//-- 0111 1001  73                                   -- 0111 1111

//-- 1000 0000  72
//-- 1000 0011  55
//-- 1000 0101  45
//-- 1000 0110  43
//-- 1000 1001  56
//-- 1000 1010  38
//-- 1000 1100   1
//-- 1000 1111  71

//-- 1001 0001  25                                   
//-- 1001 0010  26                                   -- 1001 1011
//-- 1001 0100   2                                   -- 1001 1101
//-- 1001 1000  24
//-- 1001 1110  28
//-- 1001 0111  77

//-- 1010 0001  59                                   -- 1010 1011
//-- 1010 0010  54                                   -- 1010 1101
//-- 1010 0100  42                                   -- 1010 1110
//-- 1010 1000   6
//-- 1010 0111  44

//-- 1011 0000   5                                   -- 1011 0011
//-- 1011 1100  74                                   -- 1011 0101
//                                                   -- 1011 0110
//                                                   -- 1011 1001
//                                                   -- 1011 1010
//                                                   -- 1011 1111


//-- 1100 0001  63                                   
//-- 1100 0010  53                                   -- 1100 1101
//-- 1100 0100   0                                   -- 1100 1110
//-- 1100 1000  33
//-- 1100 0111  64
//-- 1100 1011  78

//-- 1101 0000   3                                   -- 1101 0101
//-- 1101 0011  52                                   -- 1101 0110
//                                                   -- 1101 1001
//                                                   -- 1101 1010
//                                                   -- 1101 1100
//                                                   -- 1101 1111

//-- 1110 0000   7                                   -- 1110 0110
//-- 1110 0011  65                                   -- 1110 1010
//-- 1110 1001  60                                   -- 1110 1100
//-- 1110 0101  79                                   -- 1110 1111
                                                   



//-- 1111 0001  66                                   -- 1111 0111
//-- 1111 0100   4                                   -- 1111 1011
//-- 1111 1000  67                                   -- 1111 1101
//-- 1111 0010  72                                   -- 1111 1110  this is SUE,  should not be set to '1'
                                                   


assign s_even   = ~(syn_out[7] ^ syn_out[6] ^ syn_out[5] ^ syn_out[4] ^ syn_out[3] ^ syn_out[2] ^ syn_out[1] ^ syn_out[0]);

//--  reduction
assign s_ue = ((s_even && s_nz) ||                                                                                                 //-- 01234567
 ( syn_out[7] &&  syn_out[6] && ~syn_out[5] &&  syn_out[4] &&  syn_out[1] && ~syn_out[0]) ||//-- 1101--10
 ( syn_out[5] && ~syn_out[4] &&  syn_out[3] &&  syn_out[2] && ~syn_out[1] &&  syn_out[0]) ||//-- --101101
 (~syn_out[7] &&  syn_out[6] &&  syn_out[3] && ~syn_out[2] &&  syn_out[1] &&  syn_out[0]) ||//-- 01--1011
 ( syn_out[7] && ~syn_out[6] &&  syn_out[5] &&  syn_out[4] && ~syn_out[3] &&  syn_out[2]) ||//-- 101101--
 ( syn_out[5] &&  syn_out[4] &&  syn_out[1] &&  syn_out[0]  )                             ||//-- --11--11
 ( syn_out[6] &&  syn_out[4] &&  syn_out[2] &&  syn_out[0]  )                             ||//-- -1-1-1-1
 ( syn_out[7] &&  syn_out[4] &&  syn_out[3] &&  syn_out[0]  )                             ||//-- 1--11--1
 ( syn_out[6] &&  syn_out[5] &&  syn_out[2] &&  syn_out[1]  )                             ||//-- -11--11-
 ( syn_out[7] &&  syn_out[5] &&  syn_out[3] &&  syn_out[1]  )                             ||//-- 1-1-1-1-
 ( syn_out[7] &&  syn_out[6] &&  syn_out[3] &&  syn_out[2]  )                               //-- 11--11--
 ) &&
data_valid && ~s_sue;

//-- this solution with S_UE gate inside
//-- ---11011 1
//-- 101--101 1
//-- 1--10110 1
//-- --101110 1
//-- 01101--1 1
//-- -11-011- 1
//-- 1--11--1 1
//-- 1-1-101- 1
//-- 11011--- 1
//-- 11-011-- 1
//-- --11--11 1
//-- -1-1-1-1 1


assign ue = s_ue;

assign ce =   s_nz && ~s_sue && ~s_ue;

assign syn[7:0] = ecc_cor_disable ? 8'b00000000 : syn_out[7:0];

endmodule //-- dlc_ecc_chk

