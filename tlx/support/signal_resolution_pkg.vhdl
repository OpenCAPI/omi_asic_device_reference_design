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




library ieee;
use ieee.std_logic_1164.all;
package signal_resolution_pkg is

  type srp_bit is ('0','1','Z','X');

  ATTRIBUTE logic_type_encoding : string ;
  ATTRIBUTE logic_type_encoding of srp_bit:type is
                    ('0','1','Z','X') ; 

  type srp_bit_vector is array(integer range <>) of srp_bit;

  function alleq_resolved(a:srp_bit_vector) return srp_bit;
  function and_resolved(a:std_ulogic_vector) return std_ulogic;
  function or_resolved(a:std_ulogic_vector) return std_ulogic;

  attribute resolutionfunc: string;
  attribute resolutionfunc of alleq_resolved:function is "ALLEQ";
  attribute resolutionfunc of and_resolved:function is "AND";
  attribute resolutionfunc of or_resolved:function is "OR";

  subtype std_logic_alleq is alleq_resolved  srp_bit;
  type std_logic_vector_alleq is array(integer range <>) of std_logic_alleq;

  subtype std_logic_and is and_resolved  std_ulogic;
  type std_logic_vector_and is array(integer range <>) of std_logic_and;

  subtype std_logic_or  is or_resolved  std_ulogic;
  type std_logic_vector_or  is array(integer range <>) of std_logic_or;

  attribute synthesis_return: string;

end package;

package body signal_resolution_pkg is


  function tconv  ( s : srp_bit_vector) return std_ulogic_vector is
    alias sv : srp_bit_vector( 1 to s'length ) is s;
    variable result : std_ulogic_vector ( 1 to s'length ) := (others => 'X');
    ATTRIBUTE synthesis_return OF result:VARIABLE IS "FEED_THROUGH" ;
  begin
    for i in result'range loop
      case sv(i) is
        when '0' => result(i) := '0';
        when '1' => result(i) := '1';
        when 'Z' => result(i) := 'Z';
        when 'X' => result(i) := 'X';
      end case;
    end loop;
    return result;
  end;

  function tconv  ( s : std_ulogic) return srp_bit is
    variable result : srp_bit;
    ATTRIBUTE synthesis_return OF result:VARIABLE IS "FEED_THROUGH" ;
  begin
      case s is
        when '0' => result := '0';
        when '1' => result := '1';
        when 'Z' => result := 'Z';
        when 'X' => result := 'X';
        when others => result := '0';
      end case;
    return result;
  end;

  TYPE srpbit_table IS ARRAY(srp_bit,srp_bit) OF srp_bit;
  CONSTANT srp_resolution_table : srpbit_table := (
    ('0', 'X', '0', 'X'),   
    ('X', '1', '1', 'X'),   
    ('0', '1', 'Z', 'X'),   
    ('X', 'X', 'X', 'X')    
  );

  FUNCTION alleq_resolved ( a :srp_bit_vector) return srp_bit is
      VARIABLE result : srp_bit ;  
  BEGIN
    for i in a'range loop
      if (a(i) = '1') then
         return '1';
      end if;
   end loop;
   return '0';
  END alleq_resolved;  

  function and_resolved(a:std_ulogic_vector) return std_ulogic is
    variable result: std_ulogic;
  begin
    result := '1';
    for i in a'range loop
      result := result and a(i);
    end loop;
        
    return result;
  end;

  function or_resolved(a:std_ulogic_vector) return std_ulogic is
    variable result: std_ulogic;
  begin
    result := '1';
    for i in a'range loop
      result := result or a(i);
    end loop;
        
    return result;
  end;

end package body;
