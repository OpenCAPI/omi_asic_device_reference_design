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
    USE ibm.std_ulogic_asic_function_support.all;
    USE ibm.std_ulogic_support.all;
    USE ibm.std_ulogic_unsigned.all;
    USE ibm.std_ulogic_function_support.all;
    USE ibm.synthesis_support.all;
    USE ieee.std_logic_1164.all;
    USE ieee.numeric_std.ALL;
    USE support.logic_support_pkg.all;
    USE ibm.std_ulogic_ao_support.ALL;
    USE support.power_logic_pkg.ALL;

LIBRARY work;
USE work.cb_func.cb_term;



--******************************************************************************
-- 2.0          : entity definitions (with attributes)
--******************************************************************************
ENTITY cb_tlxt_dbg IS
  PORT (
    gckn                           : in std_ulogic;
    gnd                            : inout power_logic;
    vdd                            : inout power_logic;
    syncr                          : in std_ulogic;

    tlxt_debug_bus                 : out std_ulogic_vector(0 to 87);

    tlxt_dbg_a_debug_bus           : in std_ulogic_vector(0 to 87); -- currently not all used
    tlxt_dbg_b_debug_bus           : in std_ulogic_vector(0 to 87); -- currently not all used
    tlxt_dbg_c_debug_bus           : in std_ulogic_vector(0 to 87);
    tlxt_dbg_d_debug_bus           : in std_ulogic_vector(0 to 87);

    tlxt_dbg_mode                  : in std_ulogic_vector(0 to 15)


  );

  attribute BLOCK_TYPE of cb_tlxt_dbg : entity is LEAF;
  attribute BTR_NAME of cb_tlxt_dbg : entity is "CB_TLXT_DBG";
  attribute PIN_DEFAULT_GROUND_DOMAIN of cb_tlxt_dbg : entity is "GND";
  attribute PIN_DEFAULT_POWER_DOMAIN of cb_tlxt_dbg : entity is "VDD";
  attribute RECURSIVE_SYNTHESIS of cb_tlxt_dbg : entity is 2;
  attribute GROUND_PIN of gnd : signal is 1;
  attribute PIN_DATA of gckn : signal is "PIN_FUNCTION=/G_CLK/";
  attribute POWER_PIN of vdd : signal is 1;
END cb_tlxt_dbg;


--******************************************************************************
-- 3.0          : architecture definition
--******************************************************************************

ARCHITECTURE cb_tlxt_dbg OF cb_tlxt_dbg IS


-- Register signal declarations
  SIGNAL act : std_ulogic;
  SIGNAL cfg_dbg_sel0 : std_ulogic_vector(0 to 1);
  SIGNAL cfg_dbg_sel1 : std_ulogic_vector(0 to 1);
  SIGNAL cfg_dbg_sel2 : std_ulogic_vector(0 to 1);
  SIGNAL cfg_dbg_sel3 : std_ulogic_vector(0 to 1);
  SIGNAL cfg_dbg_setup0_flip : std_ulogic;
  SIGNAL cfg_dbg_setup1_flip : std_ulogic;
  SIGNAL cfg_dbg_setup2_flip : std_ulogic;
  SIGNAL cfg_dbg_setup3_flip : std_ulogic;
  SIGNAL cfg_dbg_enable : std_ulogic;
  SIGNAL setup0_pre_flip : std_ulogic_vector(0 to 87);
  SIGNAL setup1_pre_flip : std_ulogic_vector(0 to 87);
  SIGNAL setup2_pre_flip : std_ulogic_vector(0 to 87);
  SIGNAL setup3_pre_flip : std_ulogic_vector(0 to 87);
  SIGNAL setup0 : std_ulogic_vector(0 to 87);
  SIGNAL setup1 : std_ulogic_vector(0 to 87);
  SIGNAL setup2 : std_ulogic_vector(0 to 87);
  SIGNAL setup3 : std_ulogic_vector(0 to 87);
  SIGNAL debug_bus : std_ulogic_vector(0 to 87);
  SIGNAL act_dbg : std_ulogic;
  SIGNAL debug_bus_dbg_d : std_ulogic_vector(0 to 87);
  SIGNAL debug_bus_q : std_ulogic_vector(0 to 87);

BEGIN

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------------------------------------------------------------
  act <= '1';



  cb_term(tlxt_dbg_mode(13 TO 15));
  ---------------------------------------------------------------
  --
  --  Config facilities
  --
  ---------------------------------------------------------------


  cfg_dbg_sel0( 0 to  1)        <=  tlxt_dbg_mode( 0 to  1);
  cfg_dbg_sel1( 0 to  1)        <=  tlxt_dbg_mode( 2 to  3);
  cfg_dbg_sel2( 0 to  1)        <=  tlxt_dbg_mode( 4 to  5);
  cfg_dbg_sel3( 0 to  1)        <=  tlxt_dbg_mode( 6 to  7);

  cfg_dbg_setup0_flip           <=  tlxt_dbg_mode(      8);
  cfg_dbg_setup1_flip           <=  tlxt_dbg_mode(      9);
  cfg_dbg_setup2_flip           <=  tlxt_dbg_mode(      10);
  cfg_dbg_setup3_flip           <=  tlxt_dbg_mode(      11);
  cfg_dbg_enable                <=  tlxt_dbg_mode(      12);

  setup0_pre_flip(0 TO 87)      <=  tlxt_dbg_a_debug_bus(0 to 87);
  setup1_pre_flip(0 TO 87)      <=  tlxt_dbg_b_debug_bus(0 to 87);
  setup2_pre_flip(0 TO 87)      <=  tlxt_dbg_c_debug_bus(0 to 87);
  setup3_pre_flip(0 TO 87)      <=  tlxt_dbg_d_debug_bus(0 to 87);

  setup0(0 to 87)           <=      gate(setup0_pre_flip(0 to 87),                                  NOT cfg_dbg_setup0_flip)
                                OR  gate(setup0_pre_flip(44 to 87) & setup0_pre_flip(0 to 43),          cfg_dbg_setup0_flip);
  setup1(0 to 87)           <=      gate(setup1_pre_flip(0 to 87),                                  NOT cfg_dbg_setup1_flip)
                                OR  gate(setup1_pre_flip(44 to 87) & setup1_pre_flip(0 to 43),          cfg_dbg_setup1_flip);
  setup2(0 to 87)           <=      gate(setup2_pre_flip(0 to 87),                                  NOT cfg_dbg_setup2_flip)
                                OR  gate(setup2_pre_flip(44 to 87) & setup2_pre_flip(0 to 43),          cfg_dbg_setup2_flip);
  setup3(0 to 87)           <=      gate(setup3_pre_flip(0 to 87),                                  NOT cfg_dbg_setup3_flip)
                                OR  gate(setup3_pre_flip(44 to 87) & setup3_pre_flip(0 to 43),          cfg_dbg_setup3_flip);

  debug_bus( 0 to 21)           <=      gate(setup0( 0 to 21),              cfg_dbg_sel0="00")
                                    OR  gate(setup1( 0 to 21),              cfg_dbg_sel0="01")
                                    OR  gate(setup2( 0 to 21),              cfg_dbg_sel0="10")
                                    OR  gate(setup3( 0 to 21),              cfg_dbg_sel0="11");

  debug_bus(22 to 43)           <=      gate(setup0(22 to 43),              cfg_dbg_sel1="00")
                                    OR  gate(setup1(22 to 43),              cfg_dbg_sel1="01")
                                    OR  gate(setup2(22 to 43),              cfg_dbg_sel1="10")
                                    OR  gate(setup3(22 to 43),              cfg_dbg_sel1="11");


  debug_bus(44 to 65)           <=      gate(setup0(44 to 65),              cfg_dbg_sel2="00")
                                    OR  gate(setup1(44 to 65),              cfg_dbg_sel2="01")
                                    OR  gate(setup2(44 to 65),              cfg_dbg_sel2="10")
                                    OR  gate(setup3(44 to 65),              cfg_dbg_sel2="11");


  debug_bus(66 to 87)           <=      gate(setup0(66 to 87),              cfg_dbg_sel3="00")
                                    OR  gate(setup1(66 to 87),              cfg_dbg_sel3="01")
                                    OR  gate(setup2(66 to 87),              cfg_dbg_sel3="10")
                                    OR  gate(setup3(66 to 87),              cfg_dbg_sel3="11");

--MR_DOM _dbg
  act_dbg <= cfg_dbg_enable;

  debug_bus_dbg_d( 0 to 87)     <=  debug_bus(0 TO 87);
  tlxt_debug_bus                <=  debug_bus_q(0 TO 87);

debug_busq: entity latches.c_morph_dff
  generic map (width => 88, offset => 0)
  port map(gckn                 => gckn,
           e                    => act_dbg,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => debug_bus_dbg_d(0 to 87),
           syncr                => syncr,
           q                    => debug_bus_q(0 to 87));


END cb_tlxt_dbg;
