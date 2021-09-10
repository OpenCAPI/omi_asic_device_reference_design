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





package SYNTHESIS_SUPPORT is

   type SYNTHESIS_VALUES is ('0',   
                             '1',   
                             '-',   
                             'Z',   
                             'z',   
                             'H',   
                             'h',   
                             'L',   
                             'l',   
                             'W',   
                             'w',   
                             'E',   
                             'e');  

   type ENUMERATION_TRANSLATION is array
         (POSITIVE range<>, POSITIVE range <>) of SYNTHESIS_VALUES;

   type state_enumeration_values IS ('0',   
                                     '1',   
                                     '-');  

   type state_enumeration_translation IS ARRAY
        (POSITIVE RANGE<>, POSITIVE RANGE <>) OF state_enumeration_values;

   attribute ENUMERATION_SYNTHESIS : ENUMERATION_TRANSLATION;
   attribute ENUM_ENCODING         : STATE_ENUMERATION_TRANSLATION;

   subtype LIMIT7  is POSITIVE range 1 to 7;
   subtype LIMIT8  is POSITIVE range 1 to 8;
   subtype LIMIT10 is POSITIVE range 1 to 10;

   type SYN_CHARACTER is
     ('a','b','c','d','e','f','g','h','i','j','k','l','m',
      'n','o','p','q','r','s','t','u','v','w','x','y','z',
      'A','B','C','D','E','F','G','H','I','J','K','L','M',
      'N','O','P','Q','R','S','T','U','V','W','X','Y','Z',
      '0','1','2','3','4','5','6','7','8','9',' ','_',
      '/','\','#','@','$','=','-','+','*','<','>');

   type SYN_CHARACTERS is array (POSITIVE range <>) of SYN_CHARACTER;

   subtype SYN_NUMBER is SYN_CHARACTER range '0' to '9';
   type SYN_NUMBERS is array (POSITIVE range <>) of SYN_NUMBER;

   subtype SYN_ALPHANUMERIC is SYN_CHARACTER range 'a' to '9';
   type SYN_ALPHANUMERICS is array (POSITIVE range <>) of SYN_ALPHANUMERIC;

   subtype SYN_ALPHANUMERIC_W_SPACE is SYN_CHARACTER range 'a' to '_';
   type SYN_ALPHANUMERICS_W_SPACE is array (POSITIVE range <>) of
                                                 SYN_ALPHANUMERIC_W_SPACE;
   subtype SYN_LETTER is SYN_CHARACTER range 'a' to 'Z';
   type SYN_LETTERS is array (POSITIVE range <>) of SYN_LETTER;

   type PN_STRING  is array (LIMIT7  range <>) of CHARACTER;
   type CPN_STRING is array (LIMIT10 range <>) of CHARACTER;


   type MULTI_BLOCK_PIN_INFO is
     record
       BLOCK_PORTION : SYN_ALPHANUMERICS_W_SPACE(1 to 3);
       PIN_START     : STRING(1 to 8);
       PIN_START_MODE: STRING(1 to 4);
       PIN_BIT_MODE  : STRING(1 to 14);
     end record;

   type PIN_INTERFACE_LIST is array (POSITIVE range <>) of
                                              MULTI_BLOCK_PIN_INFO;
   type PINS_BIT_ARRAY is array (POSITIVE range <>, POSITIVE range <>) of
             STRING(1 to 8);

   type TYPE_CONV is (STRAIGHT_THRU, PAD_WITH_ZEROS, PAD_WITH_ONES);

   attribute PN: PN_STRING;

   attribute CPN: CPN_STRING;

   attribute BTR_NAME: STRING;

   attribute PIN_BIT_INFORMATION: PIN_INTERFACE_LIST;

   attribute PINS_BIT_DETAIL: PINS_BIT_ARRAY;


   attribute PHYSICAL_PINS: BOOLEAN;

   attribute LIKE_BUILTIN: BOOLEAN;

   attribute TYPE_CONVERSION: TYPE_CONV;

   type LSSD_CLOCK_OR_SCAN is (A_CLK, B_CLK, C_CLK,
                               P_CLK, SCN_IN, SCN_OUT);

   type SYN_LATCH_CLOCK is (GATED_CLOCK, FREE_RUNNING_CLOCK, GATED_CLOCK_INTERNAL,GATED_CLOCK_AND,GATED_CLOCK_OR);

   attribute LSSD_FLAG: LSSD_CLOCK_OR_SCAN;

   attribute CLOCK_IMPLEMENTATION: SYN_LATCH_CLOCK;

   attribute DC_INITIALIZE: BOOLEAN;

   type PHYSICAL_DESCRIPTION_OF_IO is (MULTI_SOURCE_BUFFER, BI_DIRECTIONAL);

   attribute NO_MODIFICATION: STRING;

   attribute IO_PHYSICAL_DESCRIPTION: PHYSICAL_DESCRIPTION_OF_IO;

   attribute BOOLEAN_EXPRESSION: BOOLEAN;

   attribute BLOCK_DATA: STRING;

   attribute PIN_DATA: STRING;

   attribute NET_DATA: STRING;

   attribute DROP_OPEN_PINS: BOOLEAN;

   attribute STOP_HIER_WALK: BOOLEAN;

   attribute DYNAMIC_BLOCK_DATA: STRING;


   attribute ANALYSIS_UNSET_OUT_PORT_SEVERITY : string;

   attribute ANALYSIS_NOT_REFERENCED : string;

   attribute ANALYSIS_NOT_ASSIGNED : string;

   attribute ANALYSIS_HIER_REFERENCED : string;

   attribute ANALYSIS_HIER_ASSIGNED : string;

   attribute ANALYSIS_HIER_CHECKED : string;

   attribute ANALYSIS_SET_NOT_CHECKED : string;
   attribute ANALYSIS_REF_NOT_CHECKED : string;
   attribute ANALYSIS_NOT_CHECKED : string;
   attribute ANALYSIS_NOT_USED : string;
   attribute ANALYSIS_NO_LSSD_CHECKS: boolean;

   type MULTI_BLOCK_PORT_INFO is
     record
       BLOCK_PORTION : SYN_ALPHANUMERICS_W_SPACE(1 to 3);
       PIN_START     : STRING(1 to 4);
     end record;
   type PORT_INTERFACE_LIST is array (POSITIVE range <>) of
                                              MULTI_BLOCK_PORT_INFO;

   attribute PIN_INFORMATION: PORT_INTERFACE_LIST;

   type PINS_ARRAY is array (POSITIVE range <>, POSITIVE range <>) of
                                            STRING(1 to 4);

   attribute PINS_DETAIL: PINS_ARRAY;


   attribute dc_allow : boolean;

   ATTRIBUTE hls_equiv_type : STRING;

   ATTRIBUTE type_convert   : BOOLEAN;

   ATTRIBUTE pseudo_fun     : BOOLEAN;
   ATTRIBUTE functionality  : STRING;

   ATTRIBUTE no_synthesis   : BOOLEAN;

   ATTRIBUTE recursive_synthesis : INTEGER;

   ATTRIBUTE sgroup : integer ;

   ATTRIBUTE dont_initialize : boolean;

   attribute unbundled_def_pins : integer;

   type direction is ( right, left );
   attribute scan_direction : direction;


   ATTRIBUTE port_mode      : STRING;
   ATTRIBUTE signal_mode    : STRING;

   ATTRIBUTE lssd_type      : STRING;

   ATTRIBUTE system_clocks  : STRING;


   ATTRIBUTE funits         : STRING;

   ATTRIBUTE fumerge        : STRING;

   ATTRIBUTE min_saving     : INTEGER;

   ATTRIBUTE seq_mod        : BOOLEAN;

   ATTRIBUTE fsm_clock      : BOOLEAN;



   ATTRIBUTE fsm_process         : BOOLEAN;

   ATTRIBUTE state_register      : BOOLEAN;

   ATTRIBUTE state_register_name : STRING;

   ATTRIBUTE insert_state_cut    : BOOLEAN;

   ATTRIBUTE unroll_loop    : BOOLEAN;

end;
