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

library IEEE;
use IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_1164.all;
library ibm;
use ibm.std_ulogic_support.all;
use ibm.std_ulogic_unsigned.all;
use ibm.std_ulogic_function_support.all;

package cb_func is

  -- 
  --
  procedure cb_term (in0 : in std_ulogic);
  procedure cb_term (in0 : in std_ulogic_vector);
  function CB_GENPARITY_EVEN( data_in :std_ulogic_vector; w: natural) return std_ulogic_vector;
  function CB_GENPARITY_EVEN(data_in : std_ulogic_vector) return std_ulogic_vector;
  --
  --
  function switch_endian (vec_in : in std_ulogic_vector) return std_ulogic_vector;
  


end cb_func;


package body cb_func is




  -- ************************************************************************
  --  Generic Terminator
  -- ************************************************************************
  procedure cb_term
    (in0 : in std_ulogic)
  is
    variable result : std_ulogic;
    attribute ANALYSIS_NOT_REFERENCED : string;
    attribute ANALYSIS_NOT_REFERENCED of result : variable is "TRUE";
  begin
    result := in0;
  end cb_term;

  procedure cb_term
    (in0 : in std_ulogic_vector)
  is
    variable result : std_ulogic_vector(0 to in0'length-1);
    attribute ANALYSIS_NOT_REFERENCED : string;
    attribute ANALYSIS_NOT_REFERENCED of result : variable is "TRUE";
  begin
    result := in0;
  end cb_term;
  -- ************************************************************************
  -- Generate odd byte wide even parity with pad to 8-bit boundary on the RIGHT
  -- w : byte width (normally 8)
  function CB_GENPARITY_EVEN( data_in :std_ulogic_vector; w: natural) return std_ulogic_vector is
    variable data : std_ulogic_vector(0 to  ((data_in'length-1)/w+1)*w -1);
    variable z    : std_ulogic_vector(0 to  ( data_in'length-1)/w        );
  begin

    data := (others => '0');
    data(0 to data_in'length-1)  := data_in;  -- normalize to left'=0, and even multiple of w.
    for i in 0 to data'length/w -1 loop
      z(i) := xor_reduce(data(w*i to w*(i+1)-1));
    end loop;
    return z;
  end CB_GENPARITY_EVEN;

  function CB_GENPARITY_even(data_in : std_ulogic_vector) return std_ulogic_vector is
    variable z    : std_ulogic_vector(0 to (data_in'length-1)/8);
  begin
    z := CB_GENPARITY_EVEN(data_in,8);
    return z;
  end CB_GENPARITY_EVEN;
  -- ************************************************************************


  -----------------------------------------------------------------------------
  --Function to Switch Endianness of Logic vectors
  --USAGE:
  --
  --    BE_vector_out(0 to n) <= switch_endian( LE_vetor_in(n downto 0) );
  --
  --                                    OR
  --
  --    LE_vector_out(n downto 0) <= switch_endian( BE_vector_in(0 to n) );
  --
  -----------------------------------------------------------------------------
  function switch_endian (vec_in : in std_ulogic_vector) return std_ulogic_vector is
    variable result : std_ulogic_vector(vec_in'REVERSE_RANGE);
  begin
   for i in vec_in'RANGE loop
     result(i) := vec_in((vec_in'LENGTH-1) - i);
   end loop;  -- i
   return result;
  end switch_endian; 
  
end cb_func;

