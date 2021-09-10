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




library ibm,ieee ;
use ibm.synthesis_support.all ;
use ibm.std_ulogic_support.all ;
use ieee.std_logic_1164.all ;

package logic_support_pkg is



  function vtiming( s:std_ulogic ) return std_ulogic;
  function vtiming( s:std_ulogic_vector ) return std_ulogic;
  function vtiming( s:std_ulogic; n: natural ) return std_ulogic;
  function vtiming( s:std_ulogic_vector; n: natural ) return std_ulogic;
  function vtiming( n: natural ) return std_ulogic;


  function delay_element( s:std_ulogic; n:natural ) return std_ulogic;
  function delay_element( s:std_ulogic_vector; n:natural ) return std_ulogic_vector;
  constant delay_element_max: natural := 50;
  constant delay_element_step: natural := 5;


  function orthogonal( s:std_ulogic_vector ) return boolean;
  function orthogonal_extended( s:std_ulogic_vector ) return boolean;



  ATTRIBUTE generic_port_list: STRING;

  ATTRIBUTE buffer_type: STRING;

  TYPE latch_version is (dynamic, static);
  TYPE scan_type is (normal, interleaved, reversed, reverse_interleaved);

  TYPE block_type_type is (
    chip,
    core,
    unit,
    chiplet,
    mixed,
    soft,
    superrlm,
    analog,
    ary_t,
    custom,
    io,
    regfile,
    rlm,
    custom_10t,
    clock_10t,
    book,
    leaf,
    lcb,
    latch,
    mem_t,
    simonly,
    testonly,
    fence_t
    );
  ATTRIBUTE block_type : block_type_type;
  ATTRIBUTE IS_INSTANTIATED : boolean;
  ATTRIBUTE CLK_ENABLE : string;
  ATTRIBUTE EQUIV_PINCLASS : string;



  function tconv( s : std_ulogic       ) return  std_ulogic;
  function tconv( s : std_ulogic_vector) return  std_ulogic_vector;

  attribute type_convert: boolean;
  attribute type_convert of tconv: function is TRUE;


  attribute cannotevaluate : boolean;
  attribute functionality  : string;

  function vdd_array return std_ulogic;
  attribute cannotevaluate of vdd_array: function is true;
  attribute functionality  of vdd_array: function is "ARRAY_POWER_SUPPLY";

  function vdd_ios return std_ulogic;
  attribute cannotevaluate of vdd_ios: function is true;
  attribute functionality  of vdd_ios: function is "IO_POWER_SUPPLY";

  function vdd_sb return std_ulogic;
  attribute cannotevaluate of vdd_sb: function is true;
  attribute functionality  of vdd_sb: function is "SB_POWER_SUPPLY";

  type power_supply_level_type is  ('1',
                                    vdd_array_enum,
                                    vdd_ios_enum,
                                    vdd_sb_enum);
  attribute power_supply_level: power_supply_level_type;


  attribute actual_power_domain       : string;   
  attribute power_domain              : string;   
  type pin_domain_crossing_type is (vdd2vdx, vdx2vdd, cross_all);
  attribute pin_domain_crossing       : pin_domain_crossing_type; 

  attribute pin_default_power_domain  : string;
  attribute pin_default_ground_domain : string;
  attribute pin_power_domain          : string;
  attribute pin_ground_domain         : string;
  attribute power_pin                 : integer;
  attribute ground_pin                : integer;
  attribute virtual_power_pin         : integer;
  attribute virtual_ground_pin        : integer;

  attribute pg_domain                 : string;   
  attribute pg_default_domain         : string;   
  attribute pg_fence_domain           : string;   
  attribute pg_fence_active           : string;   


  attribute SynthClonedLatch    : string;


  attribute figtree_traceback   : string;


  attribute clkgatedomain      : string;
  attribute refreshportdomain  : string;
  attribute pwrgatedomain      : string;
  attribute rdportdomain       : string;
  attribute rdlateportdomain   : string;
  attribute wrportdomain       : string;
  attribute wrlateportdomain   : string;
  attribute camportdomain      : string;
  attribute clrportdomain      : string;
  attribute camlateportdomain  : string;
  attribute rdhalfportdomain   : string;
  attribute rdtargethalfportdomain : string;
  attribute wrhalfportdomain   : string;
  attribute rdtargetportdomain   : string;
  attribute datagatedomain   : string;

  TYPE timing_type_type is (
    normal              , 
    async_point2point   , 
    async_glitchless    , 
    async_gated         , 
    async_qualified     , 
    async_array         , 
    async_reset         , 
    async_other         , 
    untimed             , 
    test_only           , 
    multicycle_x           , 
    multicycle_2           , 
    multicycle_4           , 
    multicycle_8           , 
    multicycle_16           , 
    multicycle_2r          , 
    multicycle_4r          , 
    multicycle_8r          , 
    multicycle_16r          , 
    p1to1hold           , 
    p2to1hold           ,
    p3to1hold           ,
    p4to1hold           ,
    p5to1hold           ,
    p6to1hold           ,
    p8to1hold           ,
    p2to1ihold          ,
    p4to1ihold
  );

  ATTRIBUTE timing_type : timing_type_type;

  ATTRIBUTE arctic_phase : string;

  ATTRIBUTE arctic_mode  : string;

  ATTRIBUTE async_group  : string;

  ATTRIBUTE async_group_defs : string;

  ATTRIBUTE geyzer_clock       : string;
  ATTRIBUTE geyzer_clock_defs  : string;
  ATTRIBUTE geyzer_clocks      : string; 
  ATTRIBUTE geyzer_mode        : string;
  ATTRIBUTE geyzer_mode_assert : string;
  ATTRIBUTE geyzer_mode_defs   : string;
  ATTRIBUTE geyzer_parms       : string;
  ATTRIBUTE geyzer_phase       : string;
  ATTRIBUTE geyzer_phase_default_for_bidis   : string;
  ATTRIBUTE geyzer_phase_default_for_inputs  : string;
  ATTRIBUTE geyzer_phase_default_for_outputs : string;
  ATTRIBUTE geyzer_waive       : string;

  ATTRIBUTE NOBUFFER        : string; 
  ATTRIBUTE INV_ONLY        : string; 
  ATTRIBUTE TRIPLE_INV_ONLY : string; 
  ATTRIBUTE DIFFERENTIAL    : string; 
  ATTRIBUTE CML             : string; 
  ATTRIBUTE LENGTH_MATCH    : string; 
  ATTRIBUTE POINT_TO_POINT  : string; 
  ATTRIBUTE SHIELDED        : string; 
  ATTRIBUTE ESD_PROTECT     : string; 
  ATTRIBUTE SCAN_AT_SPEED_LOGIC  : string; 
  ATTRIBUTE RESISTANCE      : string; 
  ATTRIBUTE SLEW_LIMIT      : string; 
  ATTRIBUTE INTERNAL_PULLUP_1P5K : string; 

  ATTRIBUTE PIA : string; 
  ATTRIBUTE THOLD_PNTO1_RATIOS : string; 
  ATTRIBUTE DO_NOT_ROUTE : string; 
  ATTRIBUTE NOLATCH : string; 
  ATTRIBUTE MAX_RESISTANCE      : string; 
  ATTRIBUTE TARGET_RESISTANCE   : string; 
  attribute ep_block_type : block_type_type;


  ATTRIBUTE OUTPUT_POWER_PIN  : integer;

  attribute morph_blackbox : boolean;

end logic_support_pkg ;

library ibm,ieee ;
use ibm.std_ulogic_unsigned.all ;
use ieee.std_logic_1164.all ;

package body logic_support_pkg is


   FUNCTION TB2Bin( Input : std_ulogic_vector ) RETURN std_ulogic_vector IS
      ALIAS    in_val  : std_ulogic_vector(0 TO Input'length-1) IS Input;
      VARIABLE ret_val : std_ulogic_vector(0 TO Input'length/2-1);
   BEGIN
      FOR i IN 0 TO Input'length/4-1 LOOP
         IF in_val(i*4 TO i*4+4-1) = "0001" THEN
            ret_val(i*2 TO i*2+2-1) := "00";
         ELSIF in_val(i*4 TO i*4+4-1) = "0010" THEN
            ret_val(i*2 TO i*2+2-1) := "01";
         ELSIF in_val(i*4 TO i*4+4-1) = "0100" THEN
            ret_val(i*2 TO i*2+2-1) := "10";
         ELSIF in_val(i*4 TO i*4+4-1) = "1000" THEN
            ret_val(i*2 TO i*2+2-1) := "11";
         ELSE
            ret_val(i*2 TO i*2+2-1) := "00";
         END IF;
      END LOOP;
      RETURN ret_val;
   END TB2Bin;


   FUNCTION Bin2TB( Input : std_ulogic_vector ) RETURN std_ulogic_vector IS
      ALIAS    in_val  : std_ulogic_vector(0 TO Input'length-1) IS Input;
      VARIABLE ret_val : std_ulogic_vector(0 TO Input'length*2-1);
   BEGIN
      FOR i IN 0 TO Input'length/2-1 LOOP
         IF in_val(i*2 TO i*2+2-1) = "00" THEN
            ret_val(i*4 TO i*4+4-1) := "0001";
         ELSIF in_val(i*2 TO i*2+2-1) = "01" THEN
            ret_val(i*4 TO i*4+4-1) := "0010";
         ELSIF in_val(i*2 TO i*2+2-1) = "10" THEN
            ret_val(i*4 TO i*4+4-1) := "0100";
         ELSIF in_val(i*2 TO i*2+2-1) = "11" THEN
            ret_val(i*4 TO i*4+4-1) := "1000";
         ELSE
            ret_val(i*4 TO i*4+4-1) := "0000";
         END IF;
      END LOOP;
      RETURN ret_val;
   END Bin2TB;




  function vtiming( s:std_ulogic ) return std_ulogic is
  begin
    return '0';
  end vtiming;

  function vtiming( s:std_ulogic_vector ) return std_ulogic is
  begin
    return '0';
  end vtiming;

  function vtiming( s:std_ulogic; n: natural ) return std_ulogic is
  begin
    return '0';
  end vtiming;

  function vtiming( s:std_ulogic_vector; n: natural ) return std_ulogic is
  begin
    return '0';
  end vtiming;

  function vtiming( n:natural ) return std_ulogic is
  begin
    return '0';
  end vtiming;


  function delay_element( s:std_ulogic; n:natural ) return std_ulogic is
  begin
    return tconv(delay_element((0 to 0 => s), n));
  end delay_element;

  function delay_element( s:std_ulogic_vector; n:natural ) return std_ulogic_vector is
    function delay_element( s:std_ulogic_vector; n:string ) return std_ulogic_vector;
    function delay_element( s:std_ulogic_vector; n:string ) return std_ulogic_vector is
      function delay_element( s:std_ulogic_vector ) return std_ulogic_vector;
      attribute btr_name of delay_element : function is "cs_delay_element"&n;
      attribute recursive_synthesis of delay_element : function is 0;
      attribute pin_bit_information of delay_element : function is
         (1 => ("   ","a       ","SAME","PIN_BIT_VECTOR"),
          2 => ("   ","y       ","SAME","PIN_BIT_VECTOR"));
      function delay_element( s:std_ulogic_vector) return std_ulogic_vector is
      begin
        return (s);
      end delay_element;
    begin
      return delay_element(s);
    end delay_element;
    variable result : std_ulogic_vector(s'low to s'high);
  begin
    result := s;
    if (n >= delay_element_max) then
      for i in 1 to (n/delay_element_max) loop
        result := delay_element(result, tconv(delay_element_max));
      end loop;
    end if;
    if ((n mod delay_element_max) > 0) then
      result := delay_element(result, tconv(((n mod delay_element_max)/delay_element_step)*delay_element_step));
    end if;
    return result;
  end delay_element;


  function orthogonal (s: std_ulogic_vector) RETURN boolean is
  variable result: boolean;
  variable z: std_ulogic_vector(1 to s'length);
  begin
     z := (others => '0');
     result := ((s and (s - "1")) = z)
               and (s /= z);
     return result;
  end orthogonal;

  function orthogonal_extended (s: std_ulogic_vector) RETURN boolean is
  variable result: boolean;
  variable z: std_ulogic_vector(1 to s'length);
  begin
     z := (others => '0');
     result := ((s and (s - "1")) = z);
     return result;
  end orthogonal_extended;



  function tconv( s : std_ulogic) return  std_ulogic is
     begin
        return s;
     end tconv;
  function tconv( s : std_ulogic_vector) return  std_ulogic_vector is
     begin
        return s;
     end tconv;



  function vdd_array return std_ulogic is
     begin
        return '1';
     end vdd_array;

  function vdd_ios return std_ulogic is
     begin
        return '1';
     end vdd_ios;

  function vdd_sb return std_ulogic is
     begin
        return '1';
     end vdd_sb;

end logic_support_pkg ;
