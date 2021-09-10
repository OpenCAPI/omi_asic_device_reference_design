-- *!***************************************************************************
-- *! Copyright 2019 International Business Machines
-- *!
-- *! Licensed under the Apache License, Version 2.0 (the "License");
-- *! you may not use this file except in compliance with the License.
-- *! You may obtain a copy of the License at
-- *! http://www.apache.org/licenses/LICENSE-2.0 
-- *!
-- *! The patent license granted to you in Section 3 of the License, as applied
-- *! to the "Work," hereby includes implementations of the Work in physical form.  
-- *!
-- *! Unless required by applicable law or agreed to in writing, the reference design
-- *! distributed under the License is distributed on an "AS IS" BASIS,
-- *! WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- *! See the License for the specific language governing permissions and
-- *! limitations under the License.
-- *! 
-- *! The background Specification upon which this is based is managed by and available from
-- *! the OpenCAPI Consortium.  More information can be found at https://opencapi.org. 
-- *!***************************************************************************

LIBRARY ieee,ibm,clib,latches,stdcell,support;
    USE ibm.std_ulogic_support.all;
    USE ibm.std_ulogic_unsigned.all;
    USE ibm.std_ulogic_function_support.all;
    USE ibm.synthesis_support.all;
    USE ieee.std_logic_1164.all;
    USE ieee.numeric_std.ALL;
    USE support.logic_support_pkg.all;
    USE ibm.std_ulogic_ao_support.ALL;
    USE support.power_logic_pkg.ALL;

--******************************************************************************
-- 2.0          : entity definitions (with attributes)
--******************************************************************************

ENTITY mc_8beccg_comp IS
  PORT (
    --inputs
    data_in                        : in std_ulogic_vector(0 to 64)   --  (0:63) = data, (64) = tag
  ; err_inj0                       : in std_ulogic                   --  invert data(0)
  ; err_inj1                       : in std_ulogic                   --  invert data(1)
  ; derr_in                        : in std_ulogic                   --  generate SUE code
    --outputs
   ;gnd                            : inout power_logic
   ;vdd                            : inout power_logic
  ; data_out                       : out std_ulogic_vector(0 to 72)   --
  );

  attribute BLOCK_TYPE of mc_8beccg_comp : entity is LEAF;
  attribute BTR_NAME of mc_8beccg_comp : entity is "MC_8BECCG_COMP";
  attribute RECURSIVE_SYNTHESIS of mc_8beccg_comp : entity is 2;
  attribute PIN_DEFAULT_GROUND_DOMAIN of mc_8beccg_comp : entity is "GND";
  attribute PIN_DEFAULT_POWER_DOMAIN of mc_8beccg_comp : entity is "VDD";
  attribute GROUND_PIN of gnd : signal is 1;
  attribute POWER_PIN of vdd : signal is 1;
END mc_8beccg_comp;

ARCHITECTURE mc_8beccg_comp OF mc_8beccg_comp IS

  SIGNAL din : std_ulogic_vector(0 to 64);
  SIGNAL derr : std_ulogic;
  SIGNAL lev10 : std_ulogic_vector(0 to 6);
  SIGNAL lev20 : std_ulogic_vector(0 to 1);
  SIGNAL lev30 : std_ulogic;
  SIGNAL eccgn : std_ulogic_vector(0 to 7);
  SIGNAL lev11 : std_ulogic_vector(0 to 6);
  SIGNAL lev21 : std_ulogic_vector(0 to 1);
  SIGNAL lev31 : std_ulogic;
  SIGNAL lev12 : std_ulogic_vector(0 to 6);
  SIGNAL lev22 : std_ulogic_vector(0 to 1);
  SIGNAL lev32 : std_ulogic;
  SIGNAL lev13 : std_ulogic_vector(0 to 6);
  SIGNAL lev23 : std_ulogic_vector(0 to 1);
  SIGNAL lev33 : std_ulogic;
  SIGNAL lev14 : std_ulogic_vector(0 to 6);
  SIGNAL lev24 : std_ulogic_vector(0 to 1);
  SIGNAL lev34 : std_ulogic;
  SIGNAL lev15 : std_ulogic_vector(0 to 6);
  SIGNAL lev25 : std_ulogic_vector(0 to 1);
  SIGNAL lev35 : std_ulogic;
  SIGNAL lev16 : std_ulogic_vector(0 to 6);
  SIGNAL lev26 : std_ulogic_vector(0 to 1);
  SIGNAL lev36 : std_ulogic;
  SIGNAL lev17 : std_ulogic_vector(0 to 6);
  SIGNAL lev27 : std_ulogic_vector(0 to 1);
  SIGNAL lev37 : std_ulogic;

  ATTRIBUTE NET_DATA         of lev30   : SIGNAL IS "EDFI=/DUPLICATE/";
  ATTRIBUTE NO_MODIFICATION  of lev30   : SIGNAL IS "TRUE";
  ATTRIBUTE NET_DATA         of lev31   : SIGNAL IS "EDFI=/DUPLICATE/";
  ATTRIBUTE NO_MODIFICATION  of lev31   : SIGNAL IS "TRUE";
  ATTRIBUTE NET_DATA         of lev32   : SIGNAL IS "EDFI=/DUPLICATE/";
  ATTRIBUTE NO_MODIFICATION  of lev32   : SIGNAL IS "TRUE";
  ATTRIBUTE NET_DATA         of lev33   : SIGNAL IS "EDFI=/DUPLICATE/";
  ATTRIBUTE NO_MODIFICATION  of lev33   : SIGNAL IS "TRUE";
  ATTRIBUTE NET_DATA         of lev34   : SIGNAL IS "EDFI=/DUPLICATE/";
  ATTRIBUTE NO_MODIFICATION  of lev34   : SIGNAL IS "TRUE";
  ATTRIBUTE NET_DATA         of lev35   : SIGNAL IS "EDFI=/DUPLICATE/";
  ATTRIBUTE NO_MODIFICATION  of lev35   : SIGNAL IS "TRUE";
  ATTRIBUTE NET_DATA         of lev36   : SIGNAL IS "EDFI=/DUPLICATE/";
  ATTRIBUTE NO_MODIFICATION  of lev36   : SIGNAL IS "TRUE";
  ATTRIBUTE NET_DATA         of lev37   : SIGNAL IS "EDFI=/DUPLICATE/";
  ATTRIBUTE NO_MODIFICATION  of lev37   : SIGNAL IS "TRUE";


BEGIN

  --------------------------------------------------------------------------------
  -- 8Byte (65/73) ECC Matrix
  --
  -- 65/73 SEC/DED code is constructed and specified by the H-matrix shown below:
  --
  --                                                                  S
  --           1         2         3         4         5         6    U 12345678
  -- 01234567890123456789012345678901234567890123456789012345678901234E cccccccc
  --                                                                    
  -- 111111110000000000000000111010000100001000111100000011111001100111 10000000
  -- 100110011111111100000000000000001110100001000010001111000000111111 01000000
  -- 000011111001100111111111000000000000000011101000010000100011110001 00100000
  -- 001111000000111110011001111111110000000000000000111010000100001001 00010000
  -- 010000100011110000001111100110011111111100000000000000001110100001 00001000
  -- 111010000100001000111100000011111001100111111111000000000000000011 00000100
  -- 000000001110100001000010001111000000111110011001111111110000000011 00000010
  -- 000000000000000011101000010000100011110000001111100110011111111110 00000001
  --
  --
  -- NOTE:  A UE is detected on when the syndrome is non-zero
  --        AND the syndrome does not match any of the matrix columns.
  --
  --------------------------------------------------------------------------------

  --****************************************************************************
  -- 3.2        : architecture body
  --****************************************************************************

  din(0 to 64)  <= data_in;
  derr          <= derr_in;

-- First ECC bit

  lev10(0) <= din( 0)   XOR din( 1)     XOR din( 2)     XOR din( 3);
  lev10(1) <= din( 4)   XOR din( 5)     XOR din( 6)     XOR din( 7);
  lev10(2) <= din(24)   XOR din(25)     XOR din(26)     XOR din(28);
  lev10(3) <= din(33)   XOR din(38)     XOR din(64)     XOR    derr;
  lev10(4) <= din(42)   XOR din(43)     XOR din(44)     XOR din(45);
  lev10(5) <= din(52)   XOR din(53)     XOR din(54)     XOR din(55);
  lev10(6) <= din(56)   XOR din(59)     XOR din(60)     XOR din(63);

-- din(64) is the Tag bit (bit 65)

  lev20(0) <= lev10(0)  XOR lev10(1)    XOR lev10(2)                ;
  lev20(1) <= lev10(4)  XOR lev10(5)    XOR lev10(6)    XOR lev10(3);

  lev30    <= lev20(0)  XOR lev20(1) ;

  eccgn(0) <= lev30;


-- Second ECC bit

  lev11(0) <= din( 0)   XOR din( 3)     XOR din( 4)     XOR din( 7);
  lev11(1) <= din( 8)   XOR din( 9)     XOR din(10)     XOR din(11);
  lev11(2) <= din(12)   XOR din(13)     XOR din(14)     XOR din(15);
  lev11(3) <= din(32)   XOR din(33)     XOR din(34)     XOR din(36);
  lev11(4) <= din(41)   XOR din(46)     XOR din(64)     XOR derr;
  lev11(5) <= din(50)   XOR din(51)     XOR din(52)     XOR din(53);
  lev11(6) <= din(60)   XOR din(61)     XOR din(62)     XOR din(63);

  lev21(0) <= lev11(0)  XOR lev11(1)    XOR lev11(2)                ;
  lev21(1) <= lev11(4)  XOR lev11(5)    XOR lev11(6)    XOR lev11(3);

  lev31    <= lev21(0)  XOR lev21(1) ;

  eccgn(1) <= lev31;


-- Third ECC bit

  lev12(0) <= din( 4)   XOR din( 5)     XOR din( 6)     XOR din( 7);
  lev12(1) <= din( 8)   XOR din(11)     XOR din(12)     XOR din(15);
  lev12(2) <= din(16)   XOR din(17)     XOR din(18)     XOR din(19);
  lev12(3) <= din(20)   XOR din(21)     XOR din(22)     XOR din(23);
  lev12(4) <= din(40)   XOR din(41)     XOR din(42)     XOR din(44);
  lev12(5) <= din(49)   XOR din(54)     XOR derr;
  lev12(6) <= din(58)   XOR din(59)     XOR din(60)     XOR din(61);

  lev22(0) <= lev12(0)  XOR lev12(1)    XOR lev12(2)    XOR lev12(3);
  lev22(1) <= lev12(4)  XOR lev12(5)    XOR lev12(6);

  lev32    <= lev22(0)  XOR lev22(1) ;

  eccgn(2) <= lev32     ;


-- Fourth ECC bit

  lev13(0) <= din( 2)   XOR din( 3)     XOR din( 4)     XOR din( 5);
  lev13(1) <= din(12)   XOR din(13)     XOR din(14)     XOR din(15);
  lev13(2) <= din(16)   XOR din(19)     XOR din(20)     XOR din(23);
  lev13(3) <= din(24)   XOR din(25)     XOR din(26)     XOR din(27);
  lev13(4) <= din(28)   XOR din(29)     XOR din(30)     XOR din(31);
  lev13(5) <= din(48)   XOR din(49)     XOR din(50)     XOR din(52);
  lev13(6) <= din(57)   XOR din(62)     XOR derr;

  lev23(0) <= lev13(0)  XOR lev13(1)    XOR lev13(2)    XOR lev13(3);
  lev23(1) <= lev13(4)  XOR lev13(5)    XOR lev13(6);

  lev33    <= lev23(0)  XOR lev23(1) ;

  eccgn(3) <= lev33;


-- Fifth ECC bit

  lev14(0) <= din( 1)   XOR din( 6)     XOR derr;
  lev14(1) <= din(10)   XOR din(11)     XOR din(12)     XOR din(13);
  lev14(2) <= din(20)   XOR din(21)     XOR din(22)     XOR din(23);
  lev14(3) <= din(24)   XOR din(27)     XOR din(28)     XOR din(31);
  lev14(4) <= din(32)   XOR din(33)     XOR din(34)     XOR din(35);
  lev14(5) <= din(36)   XOR din(37)     XOR din(38)     XOR din(39);
  lev14(6) <= din(56)   XOR din(57)     XOR din(58)     XOR din(60);

  lev24(0) <= lev14(0)  XOR lev14(1)    XOR lev14(2)    XOR lev14(3);
  lev24(1) <= lev14(4)  XOR lev14(5)    XOR lev14(6);

  lev34    <= lev24(0)  XOR lev24(1) ;

  eccgn(4) <= lev34;

-- Sixth ECC bit

  lev15(0) <= din( 0)   XOR din( 1)     XOR din( 2)     XOR din( 4);
  lev15(1) <= din( 9)   XOR din(14)     XOR din(64)     XOR derr   ;
  lev15(2) <= din(18)   XOR din(19)     XOR din(20)     XOR din(21);
  lev15(3) <= din(28)   XOR din(29)     XOR din(30)     XOR din(31);
  lev15(4) <= din(32)   XOR din(35)     XOR din(36)     XOR din(39);
  lev15(5) <= din(40)   XOR din(41)     XOR din(42)     XOR din(43);
  lev15(6) <= din(44)   XOR din(45)     XOR din(46)     XOR din(47);

  lev25(0) <= lev15(0)  XOR lev15(1)    XOR lev15(2)                ;
  lev25(1) <= lev15(4)  XOR lev15(5)    XOR lev15(6)    XOR lev15(3);

  lev35    <= lev25(0)  XOR lev25(1) ;

  eccgn(5) <= lev35     ;


-- Seventh ECC bit

  lev16(0) <= din( 8)   XOR din( 9)     XOR din(10)     XOR din(12);
  lev16(1) <= din(17)   XOR din(22)     XOR din(64)     XOR derr   ;
  lev16(2) <= din(26)   XOR din(27)     XOR din(28)     XOR din(29);
  lev16(3) <= din(36)   XOR din(37)     XOR din(38)     XOR din(39);
  lev16(4) <= din(40)   XOR din(43)     XOR din(44)     XOR din(47);
  lev16(5) <= din(48)   XOR din(49)     XOR din(50)     XOR din(51);
  lev16(6) <= din(52)   XOR din(53)     XOR din(54)     XOR din(55);

  lev26(0) <= lev16(0)  XOR lev16(1)    XOR lev16(2)                ;
  lev26(1) <= lev16(4)  XOR lev16(5)    XOR lev16(6)    XOR lev16(3);

  lev36    <= lev26(0)  XOR lev26(1) ;

  eccgn(6) <= lev36;


-- Eigth ECC bit

  lev17(0) <= din(16)   XOR din(17)     XOR din(18)     XOR din(20);
  lev17(1) <= din(25)   XOR din(30)     XOR din(64);
  lev17(2) <= din(34)   XOR din(35)     XOR din(36)     XOR din(37);
  lev17(3) <= din(44)   XOR din(45)     XOR din(46)     XOR din(47);
  lev17(4) <= din(48)   XOR din(51)     XOR din(52)     XOR din(55);
  lev17(5) <= din(56)   XOR din(57)     XOR din(58)     XOR din(59);
  lev17(6) <= din(60)   XOR din(61)     XOR din(62)     XOR din(63);

  lev27(0) <= lev17(0)  XOR lev17(1)    XOR lev17(2)                ;
  lev27(1) <= lev17(4)  XOR lev17(5)    XOR lev17(6)    XOR lev17(3);

  lev37    <= lev27(0)  XOR lev27(1);

  eccgn(7) <= lev37;


-- Output

  data_out(0)        <= data_in(0) XOR err_inj0;
  data_out(1)        <= data_in(1) XOR err_inj1;
  data_out(2 to 64)  <= data_in(2 to 64);
  data_out(65 to 72) <= eccgn;

END mc_8beccg_comp;
