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

library ieee, ibm, work;
use ieee.std_logic_1164.all;
use ibm.std_ulogic_function_support.all;
use ibm.synthesis_support.all;
USE ibm.std_ulogic_support.all;
USE ibm.std_ulogic_unsigned.all;
use ieee.numeric_std.std_match;

package cb_tlxr_pkg is

-- given a suv 63 downto 0, return suv(5 downto 0) that points to the rightmost 0
-- in the string for find_first and the leftmost 0 for find_last
  function find_first_0( ib:in std_ulogic_vector(63 downto 0)) return std_ulogic_vector;
  function find_last_0 ( ib:in std_ulogic_vector(63 downto 0)) return std_ulogic_vector;

-- given a tag from srq, generate a one hot 64 bit bus to clear a buffer_busy bit
  function dec_6_64(T: in std_ulogic_vector(0 to 5)) return std_ulogic_vector;
-- given a tag from srq, generate a one hot 68 bit bus to clear a buffer_busy bit
  function dec_7_68(T: in std_ulogic_vector(0 to 6)) return std_ulogic_vector;

-- return 6 bit pointer given a one_hot bus
  function enc_64_6(T: in std_ulogic_vector(63 downto 0)) return std_ulogic_vector;
-- return 7 bit pointer given a one_hot bus
  function enc_68_7(T: in std_ulogic_vector(67 downto 0)) return std_ulogic_vector;

-- Do combinatoral part of Palmer Patent fairness algorithm

   procedure PP_FAIRNESS(signal req    :in  std_ulogic_vector;   -- Current requests
                         signal oldtt  :in  std_ulogic_vector;   -- TT latch outputs
                         signal winner :out std_ulogic_vector;   -- 1-hot winner
                         signal newtt  :out std_ulogic_vector);  -- value to load into TT latches


-- make 64 byte enables from the 6 bit address and three bit length of pr_wr_mem command
   function make_bes(T: in std_ulogic_vector(8 downto 0)) return std_ulogic_vector;
   function make_ecc(T: in std_ulogic_vector(8 downto 0)) return std_ulogic_vector;

   function errcode_extract(J: in std_ulogic_vector(5 downto 0); B: in std_ulogic_vector) return std_ulogic_vector;

-- take 64 bit vector and return rightmost / leftmost bit that is 0 as a one_hot vector

   function T1_ONE_HOT(J: in std_ulogic_vector) return std_ulogic_vector;
   function T2_ONE_HOT(J: in std_ulogic_vector) return std_ulogic_vector;

   function ECCGEN(dd:std_ulogic_vector) return std_ulogic_vector;     -- was 17 downto 0
   function ECCCORR(en  : in  std_ulogic;syn  : in  std_ulogic_vector(5 downto 0)) return std_ulogic_vector;
   function ECCCORR_MAX( en : in  std_ulogic;syn  : in  std_ulogic_vector(5 downto 0); l : in integer) return std_ulogic_vector;   -- as above with added correctable output
   function ECCGEN_48(d:std_ulogic_vector(47 downto 0)) return std_ulogic_vector;
   function ECCCORR_48(en  : in  std_ulogic;syn  : in  std_ulogic_vector(7 downto 0)) return std_ulogic_vector;
-- combinatorial control for the tlxr_tlxt write reponse interface
   function resp_cntl(insigs : std_ulogic_vector(4 downto 0)) return std_ulogic_vector;
   function invalid_opcode(opcode : in std_ulogic_vector(7 downto 0);mode : in integer) return std_ulogic;
   function recode_opcode(opcode : in std_ulogic_vector(7 downto 0)) return std_ulogic_vector;
   function unknown_opcode(opcode : in std_ulogic_vector(7 downto 0)) return std_ulogic;
  end cb_tlxr_pkg;

-----------------------------------------------------------------------------------------------------

package body cb_tlxr_pkg is
   type EccMatrices is ARRAY(26 downto 0) of std_ulogic_vector(5 downto 0);
   constant eccmatrix:EccMatrices :=
     ( "100000","010000","001000",
       "000100","000010","000001",
       "011010","011100","100011",     --           20 18
       "000111","100101","100110",     -- p(5) data 17-15
       "001011","101001","101010",     -- p(4) data 14-12
       "101100","001101","001110",     -- p(3) data 11-9
       "010011","110001","110010",     -- p(2) data  8-6
       "010101","010110","110100",     -- p(1) data  5-3
       "011001","111000","111011");    -- p(0) data  2-0

-- This matrix is a Hamming code (on ECC(5:0)), correcting all 1-bit errors.

type EccMatrix_t48 is ARRAY(55 downto 0) of std_ulogic_vector(7 downto 0);
constant eccmatrix_48:EccMatrix_t48 :=

  ("10000000","01000000","00100000","00010000","00001000","00000100","00000010","00000001",  -- Ecc bits
   "01010111","11010110","11010101","01010100","11010011","01010010","01010001","11010000",  -- Byte 47:40
   "01001111","11001110","11001101","01001100","11001011","01001010","01001001","11001000",  -- Byte 39:32
   "10111111","00111110","00111101","10111100","00111011","10111010","10111001","00111000",  -- Byte 31:24
   "00110111","10110110","10110101","00110100","10110011","00110010","00110001","10110000",  -- Byte 23:16
   "00101111","10101110","10101101","00101100","10101011","00101010","00101001","10101000",  -- Byte 15:8
   "00011111","10011110","10011101","00011100","10011011","00011010","00011001","10011000"); -- Byte 7:0


  function find_first_0( ib:in std_ulogic_vector(63 downto 0)) return std_ulogic_vector is

     variable ret : std_ulogic_vector(5 downto 0) := (others => '1');
     variable bit : integer;
     variable v3suv : std_ulogic_vector (2 downto 0) := (others => '0');
     variable v4suv : std_ulogic_vector (3 downto 0) := (others => '0');
     variable v5suv : std_ulogic_vector (4 downto 0) := (others => '0');
    begin
     assert ib'high = 63 and ib'low = 0 report "bad input range" severity error;
     ret := (others => '0');
     ret(5) := AND_REDUCE(ib(31 downto 0));

     ret(4) := (not ret(5) and AND_REDUCE(ib(15 downto  0))) or
               (    ret(5) and AND_REDUCE(ib(47 downto 32)));

     ret(3) := ret(3) or (not ret(5) and not ret(4) and AND_REDUCE(ib(7  downto  0))) or
                         (not ret(5) and     ret(4) and AND_REDUCE(ib(23 downto 16))) or
                         (    ret(5) and not ret(4) and AND_REDUCE(ib(39 downto 32))) or
                         (    ret(5) and     ret(4) and AND_REDUCE(ib(55 downto 48)));

     for i in 0 to 7 loop
        bit := i*8;
        ret(2) := ret(2) or (not or_reduce( v3suv xor ret(5 downto 3)) and AND_REDUCE(ib(bit+3 downto bit))   );
        v3suv := v3suv + "001";
     end loop;

     for i in 0 to 15 loop
        bit := i*4;
        ret(1) := ret(1) or (not or_reduce( v4suv xor ret(5 downto 2)) and AND_REDUCE(ib(bit+1 downto bit))   );
        v4suv := v4suv + "0001";
     end loop;

     for i in 0 to 31 loop
        bit := i*2;
        ret(0) := ret(0) or (not or_reduce( v5suv xor ret(5 downto 1)) and ib(bit)   );
        v5suv := v5suv + "00001";
     end loop;
     return ret;
   end;

  function find_last_0( ib:in std_ulogic_vector(63 downto 0)) return std_ulogic_vector is
     variable ret : std_ulogic_vector(5 downto 0) := (others => '1');
     variable bit : integer;
     variable v3suv : std_ulogic_vector (2 downto 0) := (others => '0');
     variable v4suv : std_ulogic_vector (3 downto 0) := (others => '0');
     variable v5suv : std_ulogic_vector (4 downto 0) := (others => '0');
    begin
     assert ib'high = 63 and ib'low = 0 report "bad input range" severity error;
     ret := (others => '0');

     ret(5) := not AND_REDUCE(ib(63 downto 32));

     ret(4) := (not ret(5) and not AND_REDUCE(ib(31 downto 16))) or
               (    ret(5) and not AND_REDUCE(ib(63 downto 48)));

     ret(3) := ret(3) or (not ret(5) and not ret(4) and not AND_REDUCE(ib(15 downto  8))) or
                         (not ret(5) and     ret(4) and not AND_REDUCE(ib(31 downto 24))) or
                         (    ret(5) and not ret(4) and not AND_REDUCE(ib(47 downto 40))) or
                         (    ret(5) and     ret(4) and not AND_REDUCE(ib(63 downto 56)));
     for i in 0 to 7 loop
        bit := i*8;
        ret(2) := ret(2) or (not or_reduce( v3suv xor ret(5 downto 3)) and not and_reduce(ib(bit+7 downto bit+4))   );
        v3suv := v3suv + "001";
     end loop;

     for i in 0 to 15 loop
        bit := i*4;
        ret(1) := ret(1) or (not or_reduce( v4suv xor ret(5 downto 2)) and not and_reduce(ib(bit+3 downto bit+2))   );
        v4suv := v4suv + "0001";
     end loop;

     for i in 0 to 31 loop
        bit := i*2;
        ret(0) := ret(0) or (not or_reduce( v5suv xor ret(5 downto 1)) and not ib(bit+1)   );
        v5suv := v5suv + "00001";
     end loop;
     return ret;
   end;

  function dec_6_64(T: in std_ulogic_vector(0 to 5)) return std_ulogic_vector is
     variable count : std_ulogic_vector(5 downto 0) := (others => '0');
     variable ret : std_ulogic_vector(63 downto 0) := (others => '0');
    begin
     for i in 0 to 63 loop
        if T = count then ret(i) := '1'; end if;
        count := count + "000001";
     end loop;
     return(ret);
  end function dec_6_64;

  function dec_7_68(T: in std_ulogic_vector(0 to 6)) return std_ulogic_vector is
     variable count : std_ulogic_vector(6 downto 0) := (others => '0');
     variable ret : std_ulogic_vector(67 downto 0) := (others => '0');
    begin
     for i in 0 to 67 loop
        if T = count then ret(i) := '1'; end if;
        count := count + "0000001";
     end loop;
     return(ret);
  end function dec_7_68;

  function enc_64_6(T: in std_ulogic_vector(63 downto 0)) return std_ulogic_vector is  --  NO LONGER USED
     variable count : std_ulogic_vector(5 downto 0) := (others => '0');                --  NO LONGER USED
     variable ret : std_ulogic_vector(5 downto 0) := (others => '0');                  --  NO LONGER USED
     variable mask : std_ulogic_vector(63 downto 0) := x"0000000000000001";            --  NO LONGER USED
    begin                                                                              --  NO LONGER USED
     for i in 0 to 63 loop                                                             --  NO LONGER USED
        if T = mask then ret := count; end if;                                         --  NO LONGER USED
        count := count + "000001";                                                     --  NO LONGER USED
        mask(63 downto 0) := mask(62 downto 0) & '0';                                  --  NO LONGER USED
     end loop;                                                                         --  NO LONGER USED
     return(ret);                                                                      --  NO LONGER USED
  end function enc_64_6;                                                               --  NO LONGER USED


  function enc_68_7(T: in std_ulogic_vector(67 downto 0)) return std_ulogic_vector is
     variable count : std_ulogic_vector(6 downto 0) := (others => '0');
     variable ret : std_ulogic_vector(6 downto 0) := (others => '0');
     variable mask : std_ulogic_vector(67 downto 0) := x"00000000000000001";
    begin
     for i in 0 to 67 loop
        if T = mask then ret := count; end if;                                         -- same sort OF THINGHERE
        count := count + "0000001";
        mask(67 downto 0) := mask(66 downto 0) & '0';
     end loop;
     return(ret);
  end function enc_68_7;

  -- Palmer Patent fairness algorithm (combinatorial part)

   procedure PP_FAIRNESS(signal req    :in  std_ulogic_vector; -- Current requests
                         signal oldtt  :in  std_ulogic_vector; -- TT latch outputs
                         signal winner :out std_ulogic_vector; -- 1-hot winner
                         signal newtt  :out std_ulogic_vector  -- value to load into TT latches
                        ) is
   variable req_not_tt,req2,tt,win:std_ulogic_vector(0 to req'length-1);
   variable req_cumul:std_ulogic_vector(0 to req'length-2);
   begin
   req_not_tt := req and not oldtt;                -- Those that have not yet had a turn
   if req_not_tt = (0 to req'length-1 => '0') then
     req2:=req;                                    -- All turn taken
     tt:=oldtt and not req;                        -- So clr turn taken on all requesters
   else
     req2:=req_not_tt;                             -- Only consider those which haven't had their turn
     tt:=oldtt;
   end if;
   req_cumul(0) := req2(0);
   for i in 1 to req'length-2 loop
     req_cumul(i) := req2(i) or req_cumul(i-1);
   end loop;
   win       := req2 and not ('0' & req_cumul);
   newtt  <= tt or win;
   winner <= win;
   end procedure PP_FAIRNESS;

   function make_bes(T: in std_ulogic_vector(8 downto 0)) return std_ulogic_vector is
     variable ret : std_ulogic_vector(63 downto 0) := (others => '0');
     variable startt,endd,position : std_ulogic_vector(5 downto 0);
   begin
      startt := T(8 downto 3);
      if T(2 downto 0) = "101" then          -- length 32 can only go at address 0 or 32
         if startt = "000000" then return(x"00000000FFFFFFFF" );
            else                   return(x"FFFFFFFF00000000" );
         end if;
      end if;
      if T(2 downto 0) = "100" then endd := startt + "001111"; end if;        --           16
      if T(2 downto 0) = "011" then endd := startt + "000111"; end if;        --           8
      if T(2 downto 0) = "010" then endd := startt + "000011"; end if;        --           4
      if T(2 downto 0) = "001" then endd := startt + "000001"; end if;        --           2
      if T(2 downto 0) = "000" then endd := startt + "000000"; end if;        -- length is 1 byte
      position := (others => '0');
      for i in 0 to 63  loop
         if position <= endd and position >= startt then ret(i) := '1'; else ret(i) := '0'; end if;
         position := position + "000001";
      end loop;
     return(ret) ;
   end function make_bes;

   function make_ecc(T: in std_ulogic_vector(8 downto 0)) return std_ulogic_vector is
   -- function returns 8 bit ecc for wdf be delivery given flit offset and length bits
      variable ret : std_ulogic_vector(7 downto 0) := (others => '0');
   begin
      ret := GATE(x"C1",T= '0' & x"00") or GATE(x"4F",T= '0' & x"D8") or GATE(x"46",T= '1' & x"B0") or GATE(x"88",T= '1' & x"11") or
             GATE(x"51",T= '0' & x"08") or GATE(x"0D",T= '0' & x"E0") or GATE(x"62",T= '1' & x"B8") or GATE(x"88",T= '1' & x"21") or
             GATE(x"61",T= '0' & x"10") or GATE(x"49",T= '0' & x"E8") or GATE(x"E0",T= '1' & x"C0") or GATE(x"09",T= '1' & x"31") or
             GATE(x"E9",T= '0' & x"18") or GATE(x"C8",T= '0' & x"F0") or GATE(x"A8",T= '1' & x"C8") or GATE(x"12",T= '1' & x"41") or
             GATE(x"A1",T= '0' & x"20") or GATE(x"4C",T= '0' & x"F8") or GATE(x"B0",T= '1' & x"D0") or GATE(x"11",T= '1' & x"51") or
             GATE(x"29",T= '0' & x"28") or GATE(x"1C",T= '1' & x"00") or GATE(x"F4",T= '1' & x"D8") or GATE(x"11",T= '1' & x"61") or
             GATE(x"19",T= '0' & x"30") or GATE(x"15",T= '1' & x"08") or GATE(x"D0",T= '1' & x"E0") or GATE(x"12",T= '1' & x"71") or
             GATE(x"89",T= '0' & x"38") or GATE(x"16",T= '1' & x"10") or GATE(x"94",T= '1' & x"E8") or GATE(x"24",T= '1' & x"81") or
             GATE(x"83",T= '0' & x"40") or GATE(x"9E",T= '1' & x"18") or GATE(x"8C",T= '1' & x"F0") or GATE(x"22",T= '1' & x"91") or
             GATE(x"A2",T= '0' & x"48") or GATE(x"1A",T= '1' & x"20") or GATE(x"C4",T= '1' & x"F8") or GATE(x"22",T= '1' & x"A1") or
             GATE(x"C2",T= '0' & x"50") or GATE(x"92",T= '1' & x"28") or GATE(x"90",T= '0' & x"01") or GATE(x"24",T= '1' & x"B1") or
             GATE(x"D3",T= '0' & x"58") or GATE(x"91",T= '1' & x"30") or GATE(x"88",T= '0' & x"11") or GATE(x"48",T= '1' & x"C1") or
             GATE(x"43",T= '0' & x"60") or GATE(x"98",T= '1' & x"38") or GATE(x"88",T= '0' & x"21") or GATE(x"44",T= '1' & x"D1") or
             GATE(x"52",T= '0' & x"68") or GATE(x"38",T= '1' & x"40") or GATE(x"90",T= '0' & x"31") or GATE(x"44",T= '1' & x"E1") or
             GATE(x"32",T= '0' & x"70") or GATE(x"2A",T= '1' & x"48") or GATE(x"21",T= '0' & x"41") or GATE(x"48",T= '1' & x"F1") or
             GATE(x"13",T= '0' & x"78") or GATE(x"2C",T= '1' & x"50") or GATE(x"11",T= '0' & x"51") or GATE(x"18",T= '0' & x"02") or
             GATE(x"07",T= '0' & x"80") or GATE(x"3D",T= '1' & x"58") or GATE(x"11",T= '0' & x"61") or GATE(x"18",T= '0' & x"22") or
             GATE(x"45",T= '0' & x"88") or GATE(x"34",T= '1' & x"60") or GATE(x"21",T= '0' & x"71") or GATE(x"30",T= '0' & x"42") or
             GATE(x"85",T= '0' & x"90") or GATE(x"25",T= '1' & x"68") or GATE(x"42",T= '0' & x"81") or GATE(x"30",T= '0' & x"62") or
             GATE(x"A7",T= '0' & x"98") or GATE(x"23",T= '1' & x"70") or GATE(x"22",T= '0' & x"91") or GATE(x"60",T= '0' & x"82") or
             GATE(x"86",T= '0' & x"A0") or GATE(x"31",T= '1' & x"78") or GATE(x"22",T= '0' & x"A1") or GATE(x"60",T= '0' & x"A2") or
             GATE(x"A4",T= '0' & x"A8") or GATE(x"70",T= '1' & x"80") or GATE(x"42",T= '0' & x"B1") or GATE(x"C0",T= '0' & x"C2") or
             GATE(x"64",T= '0' & x"B0") or GATE(x"54",T= '1' & x"88") or GATE(x"84",T= '0' & x"C1") or GATE(x"C0",T= '0' & x"E2") or
             GATE(x"26",T= '0' & x"B8") or GATE(x"58",T= '1' & x"90") or GATE(x"44",T= '0' & x"D1") or GATE(x"81",T= '1' & x"02") or
             GATE(x"0E",T= '0' & x"C0") or GATE(x"7A",T= '1' & x"98") or GATE(x"44",T= '0' & x"E1") or GATE(x"81",T= '1' & x"22") or
             GATE(x"8A",T= '0' & x"C8") or GATE(x"68",T= '1' & x"A0") or GATE(x"84",T= '0' & x"F1") or GATE(x"03",T= '1' & x"42") or
             GATE(x"0B",T= '0' & x"D0") or GATE(x"4A",T= '1' & x"A8") or GATE(x"09",T= '1' & x"01") or GATE(x"03",T= '1' & x"62") or
             GATE(x"06",T= '1' & x"A2") or GATE(x"0C",T= '1' & x"C2") or GATE(x"06",T= '1' & x"82") or GATE(x"0C",T= '1' & x"E2");
      return(ret);
   end function make_ecc;

   function errcode_extract(J: in std_ulogic_vector(5 downto 0); B: in std_ulogic_vector) return std_ulogic_vector is
    variable R : std_ulogic_vector(3 downto 0);
    variable w : integer;
   begin
     R := "0000";
     W := (B'length)/64;
     for i in 0 to 63 loop
        r := r or GATE(B(i*W+3 downto i*W),not OR_REDUCE( J xor To_Std_Ulogic_Vector(i,6)));
     end loop;
     if R = "1101" then R(2) := '0'; end if; 
     return(R);
   end function errcode_extract;

   function T1_ONE_HOT(J: in std_ulogic_vector) return std_ulogic_vector is
      variable R : std_ulogic_vector(J'range);
      alias JJ  : std_ulogic_vector(J'length-1 downto 0) is J ;
   begin
      assert j = jj report " T1_one_hot: bus in should be DOWNTO !!!" severity error;
      R := (others => '0');
      R(0) := not J(0);
      R(1) := not J(1) and J(0);

      for i in 2 to J'high loop
         R(i) := not J(i) and AND_REDUCE(J(i-1 downto 0));
      end loop;
     return(R);        -- return rightmost bit
   end function T1_ONE_HOT;


   function T2_ONE_HOT(J: in std_ulogic_vector) return std_ulogic_vector is
      variable R : std_ulogic_vector(J'range);
   begin
      R := (others => '0');
      R(R'high)   := not J(R'high);
      R(R'high-1) := not J(R'high-1) and J(R'high);
      for i in  J'high-2 downto 0 loop
         R(i) := not J(i) and AND_REDUCE(J(J'high downto i+1));
      end loop;
      return(R);        -- return leftmost bit
   end function T2_ONE_HOT;

   function ECCGEN(dd:std_ulogic_vector) return std_ulogic_vector is
      alias    d : std_ulogic_vector(dd'length-1 downto 0) is dd;
      variable ecc:std_ulogic_vector(5 downto 0);
   begin
      ecc:="000000";
      for i in 0 to dd'length - 1 loop
         for j in 0 to 5 loop
            ecc(j):=ecc(j) xor (eccmatrix(i)(j) and d(i));
         end loop;
      end loop;
      return ecc;
   end function ECCGEN;

   function ECCCORR(en  : in  std_ulogic;syn  : in  std_ulogic_vector(5 downto 0)) return std_ulogic_vector is
      variable dcorr : std_ulogic_vector(17 downto 0);               -- return (18) uncorrrectable
      variable ecorr : std_ulogic_vector(5 downto 0);                -- 23:18 ecc corrrection
      variable unc   : std_ulogic;
      variable corr  : std_ulogic_vector(18 downto 0);
   begin                                                             -- 17:0 data correction
      L1:for i in 0 to 17 loop               -- data bit correction
            if en='1' and syn(5 downto 0)=eccmatrix(i) then
               dcorr(i):='1';
            else
               dcorr(i):='0';
            end if;
         end loop L1;

      L2:for i in 0 to 5 loop                -- ecc bit correction
            if en='1' and syn(5 downto 0)=eccmatrix(21+i) then
               ecorr(i):='1';
            else
               ecorr(i):='0';
            end if;
         end loop L2;

     if en='0' or syn="000000" or ecorr/="000000" or dcorr/=(17 downto 0 => '0') then
        unc:='0';
     else
        unc:='1';
     end if;

     corr := unc & dcorr;
-- mesa translate_off
-- synopsys translate_off
--   if en='1' and Is_X(syn) then
--      corr:=(others=>'X');
--   end if;
-- synopsys translate_on
-- mesa translate_on
     return(corr);
   end function ECCCORR;

   function ECCCORR_MAX(en  : in  std_ulogic;syn  : in  std_ulogic_vector(5 downto 0); l : in integer) return std_ulogic_vector is
      variable dcorr : std_ulogic_vector(l-1 downto 0);              -- return (l+1) uncorrectable
      variable ecorr : std_ulogic_vector(5 downto 0);                -- 23:18 ecc corrrection
      variable unc, corrected : std_ulogic;
      variable corr  : std_ulogic_vector(l+1 downto 0);              -- l is the number of bits of data we correct
   begin                                                             -- 17:0 data correction
      L1:for i in 0 to l-1 loop                                      -- data bit correction
            if en='1' and syn(5 downto 0)=eccmatrix(i) then
               dcorr(i):='1';
            else
               dcorr(i):='0';
            end if;
         end loop L1;

      L2:for i in 0 to 5 loop                -- ecc bit correction
            if en='1' and syn(5 downto 0)=eccmatrix(21+i) then
               ecorr(i):='1';
            else
               ecorr(i):='0';
            end if;
         end loop L2;

     if en='0' or syn="000000" or (dcorr = (l-1 downto 0 => '0') and ecorr = "000000") then
       corrected:='0';
     else
       corrected:='1';
     end if;

     if en='0' or syn="000000" or ecorr/="000000" or dcorr/=(l-1 downto 0 => '0') then
        unc:='0';
     else
        unc:='1';
     end if;

     corr := corrected & unc & dcorr;
-- mesa translate_off
-- synopsys translate_off
--   if en='1' and Is_X(syn) then
--      corr:=(others=>'X');
--   end if;
-- synopsys translate_on
-- mesa translate_on
     return(corr);
   end function ECCCORR_MAX;

  function ECCGEN_48(d:std_ulogic_vector(47 downto 0)) return std_ulogic_vector is
  variable ecc:std_ulogic_vector(7 downto 0);
  begin
  ecc:="00000000";
  for i in 0 to 47 loop
    for j in 0 to 7 loop
      ecc(j):=ecc(j) xor (eccmatrix_48(i)(j) and d(i));
    end loop;
  end loop;
  return ecc;
  end function ECCGEN_48;


function ECCCORR_48(en   : in  std_ulogic; syn  : in  std_ulogic_vector(7 downto 0)) return std_ulogic_vector is
  variable dcorr:std_ulogic_vector(47 downto 0);
  variable ecorr:std_ulogic_vector(7 downto 0);
  variable unc,corrected  : std_ulogic;
  variable corr : std_ulogic_vector(49 downto 0); -- corrected, unc, 48 data
  begin
  L1:for i in 0 to 47 loop               -- data bit correction
    if en='1' and syn(7 downto 0)=eccmatrix_48(i) then
      dcorr(i):='1';
    else
      dcorr(i):='0';
    end if;
  end loop L1;
  L2:for i in 0 to 7 loop                -- ecc bit correction
    if en='1' and syn(7 downto 0)=eccmatrix_48(48+i) then
      ecorr(i):='1';
    else
      ecorr(i):='0';
    end if;
  end loop L2;


  if en='0' or syn="00000000" or (dcorr = (47 downto 0 => '0') and ecorr = "00000000") then
    corrected:='0';
  else
    corrected:='1';
  end if;

  if en='0' or syn="00000000" or dcorr/= (47 downto 0 => '0') or ecorr /= "00000000" then
    unc:='0';
  else
    unc:='1';
  end if;

  corr := corrected & unc & dcorr;
  return(corr);
  end function ECCCORR_48;


function resp_cntl(insigs : std_ulogic_vector(4 downto 0)) return std_ulogic_vector is
  variable i : std_ulogic_vector(4 downto 0);
  variable o : std_ulogic_vector(7 downto 0);
  begin
    i:=insigs;
    o:="00000000";
         --                                 choose
         --                       reset_candidate|    -- reset candidate is also array_read
         --               full          op_latch||
         --           cndddts:      early_valid|||
         --                 ::                ||||
         --              SSS::            PSSS||||
         --              |||::             |||||||
         if std_match(i,"0000-") then o:="00000000"  or o; end if;  -- Nothing to do
         if std_match(i,"00010") then o:="10010001"  or o; end if;  -- choose a candidate
         if std_match(i,"00011") then o:="00000000"  or o; end if;  -- full - can't do anything
--
         if std_match(i,"001--") then o:="10100010"  or o; end if;
--
         if std_match(i,"0100-") then o:="00111100"  or o; end if;
         if std_match(i,"0101-") then o:="11001101"  or o; end if;
--
         if std_match(i,"01101") then o:="00111000"  or o; end if;
         if std_match(i,"01100") then o:="00000000"  or o; end if;
         if std_match(i,"01111") then o:="11001001"  or o; end if;
         if std_match(i,"01110") then o:="10010001"  or o; end if;
--
         if std_match(i,"100-1") then o:="11001000"  or o; end if;
         if std_match(i,"100-0") then o:="10010000"  or o; end if;
     return(o(7 downto 0));
  end function resp_cntl;

-- take an opcode plus a mode, and test the opcode. Include pad_mem
-- mode 0 = return 1 if it is a valid opcode but too big for 4/8/12 T1/T4 or 0 T1 or 12 T7/TA   T0 takes care of itself
-- mode 1 = return 1 if it is a valid opcode but too big for 10 T7 or 0 T4
function invalid_opcode( opcode : in std_ulogic_vector(7 downto 0);mode : in integer) return std_ulogic is
   begin
      if (mode = 1 and (opcode=x"E0" or opcode=x"E1" or opcode=x"EF" or opcode=x"80" or opcode=x"28" or
             opcode=x"86" or opcode=x"20" or opcode=x"81")) or
         (mode = 0 and opcode = x"82") then
       return('1');
      else
        return('0');
      end if;
   end function invalid_opcode;
--
-- function recode_opcode(opcode : in std_ulogic_vector(7 downto 0)) return std_ulogic_vector is
--    begin
--     if (opcode = x"00") then return "0001"; end if;     -- nop
--     if (opcode = x"01") then return "0010"; end if;     -- return_tlx_credits
--     if (opcode = x"0C") then return "0011"; end if;     -- intrp_resp
--     if (opcode = x"20") then return "0100"; end if;     -- rd_mem
--     if (opcode = x"1A") then return "0101"; end if;     -- intrp_rdy
--     if (opcode = x"28") then return "0110"; end if;     -- pr_rd_mem
--     if (opcode = x"80") then return "0111"; end if;     -- pd_mem
--     if (opcode = x"81") then return "1000"; end if;     -- write_mem
--     if (opcode = x"82") then return "1001"; end if;     -- write_mem.be
--     if (opcode = x"86") then return "1010"; end if;     -- pr_wr_mem
--     if (opcode = x"E0") then return "1011"; end if;     -- config_read
--     if (opcode = x"E1") then return "1100"; end if;     -- config_write
--     if (opcode = x"EF") then return "1101";  end if;     -- memctl
--     return("0000");
-- end function recode_opcode;
--
function recode_opcode(opcode : in std_ulogic_vector(7 downto 0)) return std_ulogic_vector is
   variable o : std_ulogic_vector(3 downto 0);
   begin
    o := (others => '0');
    if (opcode = x"00") then o := o or "0001"; end if;     -- nop
    if (opcode = x"01") then o := o or "0010"; end if;     -- return_tlx_credits
    if (opcode = x"0C") then o := o or "0011"; end if;     -- intrp_resp
    if (opcode = x"20") then o := o or "0100"; end if;     -- rd_mem
    if (opcode = x"1A") then o := o or "0101"; end if;     -- intrp_rdy
    if (opcode = x"28") then o := o or "0110"; end if;     -- pr_rd_mem
    if (opcode = x"80") then o := o or "0111"; end if;     -- pd_mem
    if (opcode = x"81") then o := o or "1000"; end if;     -- write_mem
    if (opcode = x"82") then o := o or "1001"; end if;     -- write_mem.be
    if (opcode = x"86") then o := o or "1010"; end if;     -- pr_wr_mem
    if (opcode = x"E0") then o := o or "1011"; end if;     -- config_read
    if (opcode = x"E1") then o := o or "1100"; end if;     -- config_write
    if (opcode = x"EF") then o := o or "1101"; end if;     -- memctl
    if (opcode = x"22") then o := o or "1110"; end if;     -- mem_pfch
    return(o);
end function recode_opcode;

function unknown_opcode(opcode : in std_ulogic_vector(7 downto 0)) return std_ulogic is
   begin
    if ((opcode = x"00") or      -- nop
        (opcode = x"01") or      -- return_tlx_credits
        (opcode = x"0C") or      -- intrp_resp
        (opcode = x"20") or      -- rd_mem
        (opcode = x"1A") or      -- intrp_rdy
        (opcode = x"28") or      -- pr_rd_mem
        (opcode = x"80") or      -- pd_mem
        (opcode = x"81") or      -- write_mem
        (opcode = x"82") or      -- write_mem.be
        (opcode = x"86") or      -- pr_wr_mem
        (opcode = x"E0") or      -- config_read
        (opcode = x"E1") or      -- config_write
        (opcode = x"EF") or      -- memctl
        (opcode = x"22")) then   -- mem_pfch
        return('0');
    else
       return('1');
    end if;
end function unknown_opcode;
end package body cb_tlxr_pkg;








