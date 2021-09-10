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
USE ibm.std_ulogic_unsigned.all;
use ieee.numeric_std.std_match;

package cb_tlxt_pkg  is

  function ECCGEN_6(d:std_ulogic_vector(5 downto 0)) return std_ulogic_vector;
  function ECCCORR_6(en  : in  std_ulogic;syn  : in  std_ulogic_vector(4 downto 0)) return std_ulogic_vector;

  function ECCGEN_21(d:std_ulogic_vector(20 downto 0)) return std_ulogic_vector;
  function ECCCORR_21(en  : in  std_ulogic;syn  : in  std_ulogic_vector(5 downto 0)) return std_ulogic_vector;

  function ECCGEN_32(d:std_ulogic_vector(31 downto 0)) return std_ulogic_vector;
  function ECCCORR_32(en  : in  std_ulogic;syn  : in  std_ulogic_vector(7 downto 0)) return std_ulogic_vector;

  function INCP(x:std_ulogic_vector) return std_ulogic;

end cb_tlxt_pkg ;


package body cb_tlxt_pkg is

  type EccMatrices_6 is array (10 downto 0) of std_ulogic_vector(4 downto 0);
  constant eccmatrix_6 : EccMatrices_6 :=
    ( "10000", "01000",
      "00100", "00010",
      "00001", "11010",
      "11001", "00111", "10110",        --Data 5:
      "10101", "10011");                --Data 1:0

  type EccMatrices_21 is ARRAY(26 downto 0) of std_ulogic_vector(5 downto 0);
   constant eccmatrix_21:EccMatrices_21 :=
     ( "100000","010000","001000",
       "000100","000010","000001",
       "011010","011100","100011",     --           20 18
       "000111","100101","100110",     -- p(5) data 17-15
       "001011","101001","101010",     -- p(4) data 14-12
       "101100","001101","001110",     -- p(3) data 11-9
       "010011","110001","110010",     -- p(2) data  8-6
       "010101","010110","110100",     -- p(1) data  5-3
       "011001","111000","111011");    -- p(0) data  2-0


  type EccMatrices_32 is array (39 downto 0) of std_ulogic_vector(7 downto 0);
  constant eccmatrix_32 : EccMatrices_32 :=
    ("10000000","01000000","00100000","00010000","00001000","00000100","00000010","00000001",  -- Ecc bits
     "10111111","00111110","00111101","10111100","00111011","10111010","10111001","00111000",  -- Byte 31:24
     "00110111","10110110","10110101","00110100","10110011","00110010","00110001","10110000",  -- Byte 23:16
     "00101111","10101110","10101101","00101100","10101011","00101010","00101001","10101000",  -- Byte 15:8
     "00011111","10011110","10011101","00011100","10011011","00011010","00011001","10011000"); -- Byte 7:0


  function ECCGEN_6(d:std_ulogic_vector(5 downto 0)) return std_ulogic_vector is
      variable ecc:std_ulogic_vector(4 downto 0);
   begin
      ecc:="00000";
      for i in 0 to 5 loop
         for j in 0 to 4 loop
            ecc(j):=ecc(j) xor (eccmatrix_6(i)(j) and d(i));
         end loop;
      end loop;
      return ecc;
   end function ECCGEN_6;

  function ECCCORR_6(en  : in  std_ulogic;syn  : in  std_ulogic_vector(4 downto 0)) return std_ulogic_vector is
      variable dcorr : std_ulogic_vector(5 downto 0);
      variable ecorr : std_ulogic_vector(4 downto 0);
      variable unc, corrected   : std_ulogic;
      variable corr  : std_ulogic_vector(7 downto 0);
   begin
      L1:for i in 0 to 5 loop               -- data bit correction
            if en='1' and syn(4 downto 0)=eccmatrix_6(i) then
               dcorr(i):='1';
            else
               dcorr(i):='0';
            end if;
         end loop L1;

      L2:for i in 0 to 4 loop                -- ecc bit correction
            if en='1' and syn(4 downto 0)=eccmatrix_6(6+i) then
               ecorr(i):='1';
            else
               ecorr(i):='0';
            end if;
         end loop L2;

     if en='0' or syn="00000" or (dcorr = (5 downto 0 => '0') and ecorr = "00000") then
        corrected:='0';
     else
        corrected:='1';
     end if;

     if en='0' or syn="00000" or ecorr/="00000" or dcorr/=(5 downto 0 => '0') then
        unc:='0';
     else
        unc:='1';
     end if;
     corr := corrected & unc & dcorr;
  return(corr);
  end function ECCCORR_6;

  function ECCGEN_21(d:std_ulogic_vector(20 downto 0)) return std_ulogic_vector is
      variable ecc:std_ulogic_vector(5 downto 0);
   begin
      ecc:="000000";
      for i in 0 to 20 loop
         for j in 0 to 5 loop
            ecc(j):=ecc(j) xor (eccmatrix_21(i)(j) and d(i));
         end loop;
      end loop;
      return ecc;
   end function ECCGEN_21;

  function ECCCORR_21(en  : in  std_ulogic;syn  : in  std_ulogic_vector(5 downto 0)) return std_ulogic_vector is
      variable dcorr : std_ulogic_vector(20 downto 0);               -- return (18) uncorrrectable
      variable ecorr : std_ulogic_vector(5 downto 0);                -- 23:18 ecc corrrection
      variable unc, corrected   : std_ulogic;
      variable corr  : std_ulogic_vector(22 downto 0);
   begin                                                             -- 17:0 data correction
      L1:for i in 0 to 20 loop               -- data bit correction
            if en='1' and syn(5 downto 0)=eccmatrix_21(i) then
               dcorr(i):='1';
            else
               dcorr(i):='0';
            end if;
         end loop L1;

      L2:for i in 0 to 5 loop                -- ecc bit correction
            if en='1' and syn(5 downto 0)=eccmatrix_21(21+i) then
               ecorr(i):='1';
            else
               ecorr(i):='0';
            end if;
         end loop L2;

     if en='0' or syn="000000" or (dcorr = (20 downto 0 => '0') and ecorr = "000000") then
        corrected:='0';
     else
        corrected:='1';
     end if;

     if en='0' or syn="000000" or ecorr/="000000" or dcorr/=(20 downto 0 => '0') then
        unc:='0';
     else
        unc:='1';
     end if;
      corr := corrected & unc & dcorr;
  return(corr);
  end function ECCCORR_21;

  function ECCGEN_32(d:std_ulogic_vector(31 downto 0)) return std_ulogic_vector is
    variable ecc:std_ulogic_vector(7 downto 0);
  begin
    ecc:="00000000";
    for i in 0 to 31 loop
      for j in 0 to 7 loop
        ecc(j):=ecc(j) xor (eccmatrix_32(i)(j) and d(i));
      end loop;
    end loop;
    return ecc;
  end function ECCGEN_32;

  function ECCCORR_32(en   : in  std_ulogic; syn  : in  std_ulogic_vector(7 downto 0)) return std_ulogic_vector is
    variable dcorr:std_ulogic_vector(31 downto 0);
    variable ecorr:std_ulogic_vector(7 downto 0);
    variable unc, corrected  : std_ulogic;
    variable corr : std_ulogic_vector(33 downto 0); -- corrected, unc, 48 data
  begin
  L1:for i in 0 to 31 loop               -- data bit correction
    if en='1' and syn(7 downto 0)=eccmatrix_32(i) then
      dcorr(i):='1';
    else
      dcorr(i):='0';
    end if;
  end loop L1;
  L2:for i in 0 to 7 loop                -- ecc bit correction
    if en='1' and syn(7 downto 0)=eccmatrix_32(32+i) then
      ecorr(i):='1';
    else
      ecorr(i):='0';
    end if;
  end loop L2;

  if en='0' or syn="00000000" or (dcorr = (31 downto 0 => '0') and ecorr = "00000000") then
    corrected:='0';
  else
    corrected:='1';
  end if;

  if en='0' or syn="00000000" or dcorr/= (31 downto 0 => '0') or ecorr /= "00000000" then
    unc:='0';
  else
    unc:='1';
  end if;

  corr := corrected & unc & dcorr;
  return(corr);
  end function ECCCORR_32;


  -- Compute delta to parity bit when a binary counter value is incremented
  -- Can use for decrement too (feed in NOT countervalue)
  -- Works equally well for odd or even parity
  -- Note: This has been honed over 20 years to work with a variety of vhdl tools!
  function INCP(x:std_ulogic_vector) return std_ulogic is
  alias    xv:std_ulogic_vector(x'length-1 downto 0) is x;
  variable deltap,term:std_ulogic;
  variable unused:std_ulogic_vector(x'length-1 downto 0);
  attribute ANALYSIS_NOT_CHECKED of unused:variable is "TRUE";
  begin
    unused := x;
    if x'low=x'high then
      return '1';                                          -- Special case 1 bit
    end if;
    deltap:='0';
    for i in xv'low to xv'high loop
    if (i>=xv'low) and (i<=xv'high-1) then                 -- Loop LOW to HIGH-1
      if (((i-xv'low) mod 2)=0) or (i=xv'high-1) then
        term:='1';
        for j in xv'low to xv'high loop
        if (j>=xv'low) and (j<=i) then                     -- Loop LOW to I
          if (((j-xv'low) mod 2)=1)
            then term:=term and xv(j);                     -- '1' term
          elsif (j=i)
            then term:=term and not xv(j);                 -- '0' term
          end if;
        end if;
        end loop;
        deltap:=deltap or term;
      end if;
    end if;
    end loop;
    return deltap;
  end INCP;






end cb_tlxt_pkg;
