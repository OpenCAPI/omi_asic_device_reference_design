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
//-- $Id: dlc_ecc_cor.vhdl 1 2017-03-15 01:13:23Z  $
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
//-- *! FILENAME    : dlc_ecc_cor.vhdl
//-- *! TITLE       : ECC correction file
//-- *! DESCRIPTION : This macro contains both the ECC correction logic 
//-- *!               This macro does not include latches...
//-- *!
//-- *! OWNER NAME  :  
//-- *!  NAME :  
//-- *!
//-- *!********************************************************************
//-- *!
//-- *!
//-- *!            1         2         3         4         5         6          7          01234567
//-- *! 01234567890123456789012345678901234567890123456789012345678901234 5678901 23456789 cccccccc
//-- *!
//-- *! 11111111000000000000000011101000010000100011110000001111100110011 1110001 10100111 10000000
//-- *! 10011001111111110000000000000000111010000100001000111100000011111 1111000 11010011 01000000
//-- *! 00001111100110011111111100000000000000001110100001000010001111000 1111100 11101001 00100000
//-- *! 00111100000011111001100111111111000000000000000011101000010000100 0111110 11110100 00010000
//-- *! 01000010001111000000111110011001111111110000000000000000111010000 0011111 01111010 00001000
//-- *! 11101000010000100011110000001111100110011111111100000000000000001 0001111 00111101 00000100
//-- *! 00000000111010000100001000111100000011111001100111111111000000001 1000111 10011110 00000010
//-- *! 00000000000000001110100001000010001111000000111110011001111111111 1100011 01001111 00000001
//-- *!
//-- ***************************************************************************
//--    CHANGE HISTORY:
//--------------------------------------------------------------------------------
//-- Version:|Author: | Date:  | Comment:
//-- --------|--------|--------|--------------------------------------------------
//--         |
//--         |
//--------------------------------------------------------------------------------
//-- Log history:: $
`timescale 100ps/10ps

module dlc_ecc_cor (
   input  [63:0]  data
  ,input  [7:0]   syn 
  ,output [63:0]  out_data  
);


wire [63:0] error_bit;

//-- Correction Phase: (read per column... 0 => NOT syndrome, 1 => syndrome)

//--   0 1100 0100
//--   1 1000 1100
//--   2 1001 0100
//--   3 1101 0000
//--   4 1111 0100
//--   5 1011 0000
//--   6 1010 1000
//--   7 1110 0000
//--   8 0110 0010
//--   9 0100 0110
//--  10 0100 1010
//--  11 0110 1000
//--  12 0111 1010
//--  13 0101 1000
//--  14 0101 0100
//--  15 0111 0000
//--  16 0011 0001
//--  17 0010 0011
//--  18 0010 0101
//--  19 0011 0100
//--  20 0011 1101
//--  21 0010 1100
//--  22 0010 1010
//--  23 0011 1000
//--  24 1001 1000
//--  25 1001 0001
//--  26 1001 0010
//--  27 0001 1010
//--  28 1001 1110
//--  29 0001 0110
//--  30 0001 0101
//--  31 0001 1100
//--  32 0100 1100
//--  33 1100 1000
//--  34 0100 1001
//--  35 0000 1101
//--  36 0100 1111
//--  37 0000 1011
//--  38 1000 1010
//--  39 0000 1110
//--  40 0010 0110
//--  41 0110 0100
//--  42 1010 0100
//--  43 1000 0110
//--  44 1010 0111
//--  45 1000 0101
//--  46 0100 0101
//--  47 0000 0111
//--  48 0001 0011
//--  49 0011 0010
//--  50 0101 0010
//--  51 0100 0011
//--  52 1101 0011
//--  53 1100 0010
//--  54 1010 0010
//--  55 1000 0011
//--  56 1000 1001
//--  57 0001 1001
//--  58 0010 1001
//--  59 1010 0001
//--  60 1110 1001
//--  61 0110 0001
//--  62 0101 0001
//--  63 1100 0001
//--  64 1100 0111
//--  65 1110 0011
//--  66 1111 0001
//--  67 1111 1000
//--  68 0111 1100
//--  69 0011 1110
//--  70 0001 1111
//--  71 1000 1111
//--  72 1111 0010
//--  73 0111 1001
//--  74 1011 1100
//--  75 0101 1110
//--  76 0010 1111
//--  77 1001 0111
//--  78 1100 1011
//--  79 1110 0101


assign error_bit[63] =     syn[7] &&
                           syn[6] &&
                          ~syn[5] &&
                          ~syn[4] &&
                          ~syn[3] &&
                           syn[2] &&
                          ~syn[1] &&
                          ~syn[0];

assign error_bit[62] =     syn[7] &&
                          ~syn[6] &&
                          ~syn[5] &&
                          ~syn[4] &&
                           syn[3] &&
                           syn[2] &&
                          ~syn[1] &&
                          ~syn[0];

assign error_bit[61] =     syn[7] &&
                          ~syn[6] &&
                          ~syn[5] &&
                           syn[4] &&
                          ~syn[3] &&
                           syn[2] &&
                          ~syn[1] &&
                          ~syn[0];

assign error_bit[60] =     syn[7] &&
                           syn[6] &&
                          ~syn[5] &&
                           syn[4] &&
                          ~syn[3] &&
                          ~syn[2] &&
                          ~syn[1] &&
                          ~syn[0];

assign error_bit[59] =     syn[7] &&
                           syn[6] &&
                           syn[5] &&
                           syn[4] &&
                          ~syn[3] &&
                           syn[2] &&
                          ~syn[1] &&
                          ~syn[0];

assign error_bit[58] =     syn[7] &&
                          ~syn[6] &&
                           syn[5] &&
                           syn[4] &&
                          ~syn[3] &&
                          ~syn[2] &&
                          ~syn[1] &&
                          ~syn[0];

assign error_bit[57] =     syn[7] &&
                          ~syn[6] &&
                           syn[5] &&
                          ~syn[4] &&
                           syn[3] &&
                          ~syn[2] &&
                          ~syn[1] &&
                          ~syn[0];

assign error_bit[56] =     syn[7] &&
                           syn[6] &&
                           syn[5] &&
                          ~syn[4] &&
                          ~syn[3] &&
                          ~syn[2] &&
                          ~syn[1] &&
                          ~syn[0];

assign error_bit[55] =    ~syn[7] &&
                           syn[6] &&
                           syn[5] &&
                          ~syn[4] &&
                          ~syn[3] &&
                          ~syn[2] &&
                           syn[1] &&
                          ~syn[0];

assign error_bit[54] =    ~syn[7] &&
                           syn[6] &&
                          ~syn[5] &&
                          ~syn[4] &&
                          ~syn[3] &&
                           syn[2] &&
                           syn[1] &&
                          ~syn[0];

assign error_bit[53] =    ~syn[7] &&
                           syn[6] &&
                          ~syn[5] &&
                          ~syn[4] &&
                           syn[3] &&
                          ~syn[2] &&
                           syn[1] &&
                          ~syn[0];

assign error_bit[52] =    ~syn[7] &&
                           syn[6] &&
                           syn[5] &&
                          ~syn[4] &&
                           syn[3] &&
                          ~syn[2] &&
                          ~syn[1] &&
                          ~syn[0];

assign error_bit[51] =    ~syn[7] &&
                           syn[6] &&
                           syn[5] &&
                           syn[4] &&
                           syn[3] &&
                          ~syn[2] &&
                           syn[1] &&
                          ~syn[0];

assign error_bit[50] =    ~syn[7] &&
                           syn[6] &&
                          ~syn[5] &&
                           syn[4] &&
                           syn[3] &&
                          ~syn[2] &&
                          ~syn[1] &&
                          ~syn[0];

assign error_bit[49] =    ~syn[7] &&
                           syn[6] &&
                          ~syn[5] &&
                           syn[4] &&
                          ~syn[3] &&
                           syn[2] &&
                          ~syn[1] &&
                          ~syn[0];

assign error_bit[48] =    ~syn[7] &&
                           syn[6] &&
                           syn[5] &&
                           syn[4] &&
                          ~syn[3] &&
                          ~syn[2] &&
                          ~syn[1] &&
                          ~syn[0];

assign error_bit[47] =    ~syn[7] &&
                          ~syn[6] &&
                           syn[5] &&
                           syn[4] &&
                          ~syn[3] &&
                          ~syn[2] &&
                          ~syn[1] &&
                           syn[0];

assign error_bit[46] =    ~syn[7] &&
                          ~syn[6] &&
                           syn[5] &&
                          ~syn[4] &&
                          ~syn[3] &&
                          ~syn[2] &&
                           syn[1] &&
                           syn[0];

assign error_bit[45] =    ~syn[7] &&
                          ~syn[6] &&
                           syn[5] &&
                          ~syn[4] &&
                          ~syn[3] &&
                           syn[2] &&
                          ~syn[1] &&
                           syn[0];

assign error_bit[44] =    ~syn[7] &&
                          ~syn[6] &&
                           syn[5] &&
                           syn[4] &&
                          ~syn[3] &&
                           syn[2] &&
                          ~syn[1] &&
                          ~syn[0];

assign error_bit[43] =    ~syn[7] &&
                          ~syn[6] &&
                           syn[5] &&
                           syn[4] &&
                           syn[3] &&
                           syn[2] &&
                          ~syn[1] &&
                           syn[0];

assign error_bit[42] =    ~syn[7] &&
                          ~syn[6] &&
                           syn[5] &&
                          ~syn[4] &&
                           syn[3] &&
                           syn[2] &&
                          ~syn[1] &&
                          ~syn[0];

assign error_bit[41] =    ~syn[7] &&
                          ~syn[6] &&
                           syn[5] &&
                          ~syn[4] &&
                           syn[3] &&
                          ~syn[2] &&
                           syn[1] &&
                          ~syn[0];

assign error_bit[40] =    ~syn[7] &&
                          ~syn[6] &&
                           syn[5] &&
                           syn[4] &&
                           syn[3] &&
                          ~syn[2] &&
                          ~syn[1] &&
                          ~syn[0];

assign error_bit[39] =     syn[7] &&
                          ~syn[6] &&
                          ~syn[5] &&
                           syn[4] &&
                           syn[3] &&
                          ~syn[2] &&
                          ~syn[1] &&
                          ~syn[0];

assign error_bit[38] =     syn[7] &&
                          ~syn[6] &&
                          ~syn[5] &&
                           syn[4] &&
                          ~syn[3] &&
                          ~syn[2] &&
                          ~syn[1] &&
                           syn[0];

assign error_bit[37] =     syn[7] &&
                          ~syn[6] &&
                          ~syn[5] &&
                           syn[4] &&
                          ~syn[3] &&
                          ~syn[2] &&
                           syn[1] &&
                          ~syn[0];

assign error_bit[36] =    ~syn[7] &&
                          ~syn[6] &&
                          ~syn[5] &&
                           syn[4] &&
                           syn[3] &&
                          ~syn[2] &&
                           syn[1] &&
                          ~syn[0];

assign error_bit[35] =     syn[7] &&
                          ~syn[6] &&
                          ~syn[5] &&
                           syn[4] &&
                           syn[3] &&
                           syn[2] &&
                           syn[1] &&
                          ~syn[0];

assign error_bit[34] =    ~syn[7] &&
                          ~syn[6] &&
                          ~syn[5] &&
                           syn[4] &&
                          ~syn[3] &&
                           syn[2] &&
                           syn[1] &&
                          ~syn[0];

assign error_bit[33] =    ~syn[7] &&
                          ~syn[6] &&
                          ~syn[5] &&
                           syn[4] &&
                          ~syn[3] &&
                           syn[2] &&
                          ~syn[1] &&
                           syn[0];

assign error_bit[32] =    ~syn[7] &&
                          ~syn[6] &&
                          ~syn[5] &&
                           syn[4] &&
                           syn[3] &&
                           syn[2] &&
                          ~syn[1] &&
                          ~syn[0];

assign error_bit[31] =    ~syn[7] &&
                           syn[6] &&
                          ~syn[5] &&
                          ~syn[4] &&
                           syn[3] &&
                           syn[2] &&
                          ~syn[1] &&
                          ~syn[0];

assign error_bit[30] =     syn[7] &&
                           syn[6] &&
                          ~syn[5] &&
                          ~syn[4] &&
                           syn[3] &&
                          ~syn[2] &&
                          ~syn[1] &&
                          ~syn[0];

assign error_bit[29] =    ~syn[7] &&
                           syn[6] &&
                          ~syn[5] &&
                          ~syn[4] &&
                           syn[3] &&
                          ~syn[2] &&
                          ~syn[1] &&
                           syn[0];

assign error_bit[28] =    ~syn[7] &&
                          ~syn[6] &&
                          ~syn[5] &&
                          ~syn[4] &&
                           syn[3] &&
                           syn[2] &&
                          ~syn[1] &&
                           syn[0];

assign error_bit[27] =    ~syn[7] &&
                           syn[6] &&
                          ~syn[5] &&
                          ~syn[4] &&
                           syn[3] &&
                           syn[2] &&
                           syn[1] &&
                           syn[0];

assign error_bit[26] =    ~syn[7] &&
                          ~syn[6] &&
                          ~syn[5] &&
                          ~syn[4] &&
                           syn[3] &&
                          ~syn[2] &&
                           syn[1] &&
                           syn[0];

assign error_bit[25] =     syn[7] &&
                          ~syn[6] &&
                          ~syn[5] &&
                          ~syn[4] &&
                           syn[3] &&
                          ~syn[2] &&
                           syn[1] &&
                          ~syn[0];

assign error_bit[24] =    ~syn[7] &&
                          ~syn[6] &&
                          ~syn[5] &&
                          ~syn[4] &&
                           syn[3] &&
                           syn[2] &&
                           syn[1] &&
                          ~syn[0];

assign error_bit[23] =    ~syn[7] &&
                          ~syn[6] &&
                           syn[5] &&
                          ~syn[4] &&
                          ~syn[3] &&
                           syn[2] &&
                           syn[1] &&
                          ~syn[0];

assign error_bit[22] =    ~syn[7] &&
                           syn[6] &&
                           syn[5] &&
                          ~syn[4] &&
                          ~syn[3] &&
                           syn[2] &&
                          ~syn[1] &&
                          ~syn[0];

assign error_bit[21] =     syn[7] &&
                          ~syn[6] &&
                           syn[5] &&
                          ~syn[4] &&
                          ~syn[3] &&
                           syn[2] &&
                          ~syn[1] &&
                          ~syn[0];

assign error_bit[20] =     syn[7] &&
                          ~syn[6] &&
                          ~syn[5] &&
                          ~syn[4] &&
                          ~syn[3] &&
                           syn[2] &&
                           syn[1] &&
                          ~syn[0];

assign error_bit[19] =     syn[7] &&
                          ~syn[6] &&
                           syn[5] &&
                          ~syn[4] &&
                          ~syn[3] &&
                           syn[2] &&
                           syn[1] &&
                           syn[0];

assign error_bit[18] =     syn[7] &&
                          ~syn[6] &&
                          ~syn[5] &&
                          ~syn[4] &&
                          ~syn[3] &&
                           syn[2] &&
                          ~syn[1] &&
                           syn[0];

assign error_bit[17] =    ~syn[7] &&
                           syn[6] &&
                          ~syn[5] &&
                          ~syn[4] &&
                          ~syn[3] &&
                           syn[2] &&
                          ~syn[1] &&
                           syn[0];

assign error_bit[16] =    ~syn[7] &&
                          ~syn[6] &&
                          ~syn[5] &&
                          ~syn[4] &&
                          ~syn[3] &&
                           syn[2] &&
                           syn[1] &&
                           syn[0];

assign error_bit[15] =    ~syn[7] &&
                          ~syn[6] &&
                          ~syn[5] &&
                           syn[4] &&
                          ~syn[3] &&
                          ~syn[2] &&
                           syn[1] &&
                           syn[0];

assign error_bit[14] =    ~syn[7] &&
                          ~syn[6] &&
                           syn[5] &&
                           syn[4] &&
                          ~syn[3] &&
                          ~syn[2] &&
                           syn[1] &&
                          ~syn[0];

assign error_bit[13] =    ~syn[7] &&
                           syn[6] &&
                          ~syn[5] &&
                           syn[4] &&
                          ~syn[3] &&
                          ~syn[2] &&
                           syn[1] &&
                          ~syn[0];

assign error_bit[12] =    ~syn[7] &&
                           syn[6] &&
                          ~syn[5] &&
                          ~syn[4] &&
                          ~syn[3] &&
                          ~syn[2] &&
                           syn[1] &&
                           syn[0];

assign error_bit[11] =     syn[7] &&
                           syn[6] &&
                          ~syn[5] &&
                           syn[4] &&
                          ~syn[3] &&
                          ~syn[2] &&
                           syn[1] &&
                           syn[0];

assign error_bit[10] =     syn[7] &&
                           syn[6] &&
                          ~syn[5] &&
                          ~syn[4] &&
                          ~syn[3] &&
                          ~syn[2] &&
                           syn[1] &&
                          ~syn[0];

assign error_bit[9]  =     syn[7] &&
                          ~syn[6] &&
                           syn[5] &&
                          ~syn[4] &&
                          ~syn[3] &&
                          ~syn[2] &&
                           syn[1] &&
                          ~syn[0];

assign error_bit[8]  =     syn[7] &&
                          ~syn[6] &&
                          ~syn[5] &&
                          ~syn[4] &&
                          ~syn[3] &&
                          ~syn[2] &&
                           syn[1] &&
                           syn[0];

assign error_bit[7]  =     syn[7] &&
                          ~syn[6] &&
                          ~syn[5] &&
                          ~syn[4] &&
                           syn[3] &&
                          ~syn[2] &&
                          ~syn[1] &&
                           syn[0];

assign error_bit[6]  =    ~syn[7] &&
                          ~syn[6] &&
                          ~syn[5] &&
                           syn[4] &&
                           syn[3] &&
                          ~syn[2] &&
                          ~syn[1] &&
                           syn[0];

assign error_bit[5]  =    ~syn[7] &&
                          ~syn[6] &&
                           syn[5] &&
                          ~syn[4] &&
                           syn[3] &&
                          ~syn[2] &&
                          ~syn[1] &&
                           syn[0];

assign error_bit[4]  =     syn[7] &&
                          ~syn[6] &&
                           syn[5] &&
                          ~syn[4] &&
                          ~syn[3] &&
                          ~syn[2] &&
                          ~syn[1] &&
                           syn[0];

assign error_bit[3]  =     syn[7] &&
                           syn[6] &&
                           syn[5] &&
                          ~syn[4] &&
                           syn[3] &&
                          ~syn[2] &&
                          ~syn[1] &&
                           syn[0];

assign error_bit[2]  =    ~syn[7] &&
                           syn[6] &&
                           syn[5] &&
                          ~syn[4] &&
                          ~syn[3] &&
                          ~syn[2] &&
                          ~syn[1] &&
                           syn[0];

assign error_bit[1]  =    ~syn[7] &&
                           syn[6] &&
                          ~syn[5] &&
                           syn[4] &&
                          ~syn[3] &&
                          ~syn[2] &&
                          ~syn[1] &&
                           syn[0];

assign error_bit[0]  =     syn[7] &&
                           syn[6] &&
                          ~syn[5] &&
                          ~syn[4] &&
                          ~syn[3] &&
                          ~syn[2] &&
                          ~syn[1] &&
                           syn[0];


//-- Corrected data signal generation

assign out_data[63:0] = error_bit[63:0] ^ data[63:0];


endmodule //-- dlc_ecc_cor;
