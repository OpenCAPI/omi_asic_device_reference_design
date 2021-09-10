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

library ieee, ibm, latches, stdcell, support;
use ibm.std_ulogic_asic_function_support.all;
use ibm.std_ulogic_support.all;
use ibm.std_ulogic_unsigned.all;
use ibm.std_ulogic_function_support.all;
use ibm.synthesis_support.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ibm.std_ulogic_ao_support.all;
use support.logic_support_pkg.all;
use support.power_logic_pkg.all;
use support.design_util_functions_pkg.all;
use support.signal_resolution_pkg.all;
use ibm.texsim_attributes.all;
library work;
use work.cb_func.cb_term;
entity cb_trap_reg is
  generic
    (
      --Making config reg width configurable in case you don't want to use a
      --full 8 Bytes
     reg_width                      : natural := 64    --Width of register in bits
      );
  port
    (
      --CLOCKS
      gckn                           : in std_ulogic;
      gnd                            : inout power_logic;
      vdd                            : inout power_logic;
      syncr                          : in STD_ULOGIC := '0';  --connect the latch version of syncr


      --STATUS Inputs
      trap_input_bus                 : in std_ulogic_vector(0 to reg_width - 1);

      --This input will cause the trap register value to grab the value on
      --trap_input_bus when asserted.
      trap_update                    : in STD_ULOGIC := '1';
      --clear trap
      trap_clear                     : in std_ulogic := '0';

      --REGISTER OUTPUTS
      trap_reg                       : out std_ulogic_vector(0 to reg_width-1);  --trap register output value
      trap_reg_p                     : out std_ulogic;
      trap_reg_perr                  : out std_ulogic  --internal parity error reporting for this register instantiation
 
      );

  attribute BLOCK_TYPE of cb_trap_reg : entity is LEAF;
  attribute BTR_NAME of cb_trap_reg : entity is "CB_TRAP_REG";
  attribute PIN_DEFAULT_GROUND_DOMAIN of cb_trap_reg : entity is "GND";
  attribute PIN_DEFAULT_POWER_DOMAIN of cb_trap_reg : entity is "VDD";
  attribute RECURSIVE_SYNTHESIS of cb_trap_reg : entity is 2;
  attribute PIN_DATA of gckn : signal is "PIN_FUNCTION=/G_CLK/";
  attribute GROUND_PIN of gnd : signal is 1;
  attribute POWER_PIN of vdd : signal is 1;
end cb_trap_reg;


architecture cb_trap_reg of cb_trap_reg is
  SIGNAL act_trap : std_ulogic;
  SIGNAL trap_reg_p_d : std_ulogic;
  SIGNAL trap_reg_p_q : std_ulogic;
  SIGNAL trap_reg_d : std_ulogic_vector(0 to reg_width-1);
  SIGNAL trap_reg_q : std_ulogic_vector(0 to reg_width-1);

begin  

  act_trap        <= trap_update OR trap_clear;

  trap_reg_d          <= gate(trap_input_bus,    trap_update AND NOT trap_clear) OR
                         gate(trap_reg_q,    NOT trap_update AND NOT trap_clear);

  trap_reg_p_d        <= (xor_reduce(trap_input_bus) AND trap_update AND NOT trap_clear) OR
                         (trap_reg_p_q AND           NOT trap_update AND NOT trap_clear); 

  trap_reg_perr       <= xor_reduce(trap_reg_q) XOR trap_reg_p_q;
  trap_reg            <= trap_reg_q;
  trap_reg_p          <= trap_reg_p_q;


trap_regq: entity latches.c_morph_dff
generic map (width => reg_width , offset => 0)
port map(gckn                 => gckn,
         syncr                => syncr,
         e                    => act_trap,
         vdd                  => vdd,
         vss                  => gnd,
         d                    => trap_reg_d,
         q                    => trap_reg_q);

trap_reg_pq: entity latches.c_morph_dff
generic map (width => 1, offset => 0)
port map(gckn                 => gckn,
         syncr                => syncr,
         e                    => act_trap,
         vdd                  => vdd,
         vss                  => gnd,
         d                    => Tconv(trap_reg_p_d),
         Tconv(q)             => trap_reg_p_q);

end cb_trap_reg;
