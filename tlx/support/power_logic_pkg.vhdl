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




library ieee,support;
use ieee.std_logic_1164.all;
use support.signal_resolution_pkg.all;

package power_logic_pkg is

 
  subtype power_logic is std_logic_alleq;
  subtype power_logic_vector is std_logic_vector_alleq;
 
  function tconv( p : power_logic ) return  std_logic;
  function tconv( p : power_logic ) return  std_ulogic_vector;

  function tconv( s : std_logic   ) return  power_logic;

  attribute type_convert: boolean;
  attribute type_convert of tconv:function is true;

  attribute synthesis_return: string;
end package power_logic_pkg;

package body power_logic_pkg is


  function tconv ( p : power_logic ) return  std_logic is
     variable result: std_logic;
     ATTRIBUTE synthesis_return OF result:VARIABLE IS "FEED_THROUGH" ;
 
  begin
    case p is
      when '0' => result := '0';
      when '1' => result := '1';
      when 'Z' => result := 'Z';
      when 'X' => result := 'X';
    end case;
    return result;
  end tconv ;

  function tconv ( p : power_logic ) return  std_ulogic_vector is
     variable result: std_ulogic_vector(0 to 0);
     ATTRIBUTE synthesis_return OF result:VARIABLE IS "FEED_THROUGH" ;
 
  begin
    case p is
      when '0' => result := "0";
      when '1' => result := "1";
      when 'Z' => result := "Z";
      when 'X' => result := "X";
    end case;
    return result;
  end tconv ;




  function tconv ( s : std_logic   ) return  power_logic is
    variable result: power_logic;
     ATTRIBUTE synthesis_return OF result:VARIABLE IS "FEED_THROUGH" ;
  begin
    case s is
      when '0' => result := '0';
      when '1' => result := '1';
      when 'Z' => result := 'Z';
      when 'X' => result := 'X';
		when 'L' => result := '0';
		when 'H' => result := '1';
		when others => result := '0';
    end case;
    return result;
  end tconv ;




end power_logic_pkg;
