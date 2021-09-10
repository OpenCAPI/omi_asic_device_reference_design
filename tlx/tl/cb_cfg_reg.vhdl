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
entity cb_cfg_reg is
  generic
    (

      -------------------------------------------------------------------------
      addr_bit_index                 : natural := 0;    --address index of the register
      num_addr_bits                  : natural := 54;   --address width
      -------------------------------------------------------------------------
      -- Register Definition Setup
      -------------------------------------------------------------------------
      --Making config reg width configurable in case you don't want to use a
      --full 8 Bytes
      reg_width                      : natural := 64;    --Width of register in bits

      --The following is the reset value for the instantiated register and are
      --hard-coded to 64 bit vectors, which sets the max reg_width value at 64.
      --This is done to conincide with the default SCOM register width of 64 bits.
      --If the user implements reg_width < 64, the default reset value for the
      --register below will come from the range (0 to ((reg_width) - 1)) and the
      --lower order values will be ingnored.
      reg_reset_value                : std_ulogic_vector(0 to 63) := X"0000000000000000"

      );
  port
    (
      --CLOCKS
      gckn                           : in std_ulogic;
      gnd                            : inout power_logic;
      vdd                            : inout power_logic;
      syncr                          : in STD_ULOGIC := '0';  --connect the latch version of syncr


      sc_addr_v                      : in std_ulogic_vector(0 to (num_addr_bits - 1));
      --If the user implements reg_width < 64, the scom write data for the
      --register will come from the range (0 to ((reg_width) - 1)) and the
      --lower order values will be ingnored.
      sc_wdata                       : in std_ulogic_vector(0 to 63);  --  Write data delivered from SCOM satellite for a write request
      sc_wparity                     : in std_ulogic;                             --  Write data parity bit over sc_wdata
      sc_wr                          : in std_ulogic;       -- write pulse


      --REGISTER OUTPUTS
      cfg_reg                        : out std_ulogic_vector(0 to ((reg_width) - 1));  --configuration register output value
      cfg_reg_p                      : out std_ulogic;
      cfg_reg_perr                   : out std_ulogic;                                 --internal parity error reporting for this register instantiation
      sc_wr_pulse                    : out std_ulogic   -- single-cycle pulse indicating this reg is being written (address hit, etc.)
      );
  attribute BLOCK_TYPE of cb_cfg_reg : entity is LEAF;
  attribute BTR_NAME of cb_cfg_reg : entity is "CB_CFG_REG";
  attribute PIN_DEFAULT_GROUND_DOMAIN of cb_cfg_reg : entity is "GND";
  attribute PIN_DEFAULT_POWER_DOMAIN of cb_cfg_reg : entity is "VDD";
  attribute RECURSIVE_SYNTHESIS of cb_cfg_reg : entity is 2;
  attribute PIN_DATA of gckn : signal is "PIN_FUNCTION=/G_CLK/";
  attribute GROUND_PIN of gnd : signal is 1;
  attribute POWER_PIN of vdd : signal is 1;
end cb_cfg_reg;


architecture cb_cfg_reg of cb_cfg_reg is

signal cfg_reg_d   : std_ulogic_vector(0 to reg_width-1);  --configuration register output value
SIGNAL cfg_reg_p_d : std_ulogic;

signal cfg_reg_q   : std_ulogic_vector(0 to ((REG_WIDTH)-1));  --configuration register output value
SIGNAL cfg_reg_p_q : std_ulogic;
SIGNAL act : std_ulogic;
SIGNAL act_cfg : std_ulogic;
SIGNAL cfg_reg_wr : std_ulogic;
SIGNAL sc_wr_pulse_q : std_ulogic;
SIGNAL sc_wr_pulse_d : std_ulogic;
 
begin  

  gentermL: IF addr_bit_index = 0 GENERATE
      cb_term(sc_addr_v(1 TO num_addr_bits -1));
  END GENERATE gentermL;

  gentermM: IF addr_bit_index > 0 and addr_bit_index < num_addr_bits -1 GENERATE
      cb_term(sc_addr_v(0 TO addr_bit_index-1));
      cb_term(sc_addr_v(addr_bit_index +1 TO num_addr_bits -1));
  END GENERATE gentermM;

  gentermR: IF addr_bit_index = num_addr_bits -1 GENERATE
      cb_term(sc_addr_v(0 TO addr_bit_index-1));
  END GENERATE gentermR;

  act        <= '1';
  act_cfg    <= cfg_reg_wr;
  cfg_reg_wr <= sc_wr AND sc_addr_v(addr_bit_index);

  genP64 : IF reg_width = 64 GENERATE
      cfg_reg_d  <= gate(sc_wdata, cfg_reg_wr) OR
                    gate(cfg_reg_q, NOT cfg_reg_wr);
      cfg_reg_p_d <= (sc_wparity  AND cfg_reg_wr) OR (cfg_reg_p_q and NOT cfg_reg_wr);

  END GENERATE genP64;
    
  genP_not64 : IF reg_width < 64 GENERATE
      cfg_reg_d  <= gate(sc_wdata(0 TO reg_width-1),      cfg_reg_wr) OR
                    gate(cfg_reg_q(0 TO reg_width-1), NOT cfg_reg_wr);
      cfg_reg_p_d <= ((sc_wparity XOR xor_reduce(sc_wdata(reg_width TO 63))) AND cfg_reg_wr) OR (cfg_reg_p_q and NOT cfg_reg_wr);
      cb_term(sc_wdata(reg_width TO 63));
  END GENERATE genP_not64;

  cfg_reg_perr <= xor_reduce(cfg_reg_q) XOR cfg_reg_p_q;

  cfg_reg   <= cfg_reg_q;
  cfg_reg_p <= cfg_reg_p_q;

  
  sc_wr_pulse   <= sc_wr_pulse_q;
  sc_wr_pulse_d <= cfg_reg_wr;


  cfg_regq : entity latches.c_morph_dff
  generic map (width => reg_width, offset => 0, init => REG_RESET_VALUE(0 TO (reg_width-1)))
  port map(gckn => gckn,
           syncr => syncr,
           e    => act_cfg,
           vdd  => vdd,
           vss  => gnd,
           d    => cfg_reg_d(0 to reg_width-1),
           q    => cfg_reg_q(0 to reg_width-1));

 cfg_reg_pq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           syncr                => syncr,
           e                    => act_cfg,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(cfg_reg_p_d),
           Tconv(q)             => cfg_reg_p_q);


sc_wr_pulseq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           syncr                => syncr,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(sc_wr_pulse_d),
           Tconv(q)             => sc_wr_pulse_q);
end cb_cfg_reg;
