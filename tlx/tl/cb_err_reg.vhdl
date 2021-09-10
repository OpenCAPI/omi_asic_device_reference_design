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
entity cb_err_reg is
  generic
  (
      error_out_latch                : boolean := False;  -- Latch err_in then ADD with err_mask
      -------------------------------------------------------------------------
      addr_bit_index                 : natural := 0;    --address index of the Mask register
      num_addr_bits                  : natural := 54;   --address width
      -------------------------------------------------------------------------
      -- Register Definition Setup
      -------------------------------------------------------------------------
      --Making config reg width configurable in case you don't want to use a
      --full 8 Bytes
      err_mask_width                      : natural := 64;    --Width of register in bits

      --The following is the reset value for the instantiated register and are
      --hard-coded to 64 bit vectors, which sets the max err_mask_width value at 64.
      --This is done to conincide with the default SCOM register width of 64 bits.
      --If the user implements err_mask_width < 64, the default reset value for the
      --register below will come from the range (0 to ((err_mask_width) - 1)) and the
      --lower order values will be ingnored.
      err_mask_reset_value                : std_ulogic_vector(0 to 63) := X"0000000000000000"

      );
  port
    (
      --CLOCKS
      gckn                           : in std_ulogic;
      gnd                            : inout power_logic;
      vdd                            : inout power_logic;
      syncr                          : in STD_ULOGIC := '0';  --connect the latch version of syncr

      sc_addr_v                      : in std_ulogic_vector(0 to (num_addr_bits - 1));
      --If the user implements err_mask_width < 64, the scom write data for the
      --register will come from the range (0 to ((err_mask_width) - 1)) and the
      --lower order values will be ingnored.
      sc_wdata                       : in std_ulogic_vector(0 to 63);  --  Write data delivered from SCOM satellite for a write request
      sc_wparity                     : in std_ulogic;                             --  Write data parity bit over sc_wdata
      sc_wr                          : in std_ulogic;       -- write pulse

      err_mask                       : out std_ulogic_vector(0 to (err_mask_width - 1));  --error mask  register output value
      err_mask_p                     : out std_ulogic;  -- error mask even parity
      err_mask_perr                  : out std_ulogic;  --internal parity error reporting for this register instantiation
      sc_wr_pulse                    : out std_ulogic;  -- single-cycle pulse indicating this reg is being written (address hit, etc.)


      --ERROR input bus
      err_in                         : in std_ulogic_vector(0 to ((err_mask_width) - 1)); 
      --ERROR output bus ANDed with err_mask
      err_out                        : out std_ulogic_vector(0 to ((err_mask_width) - 1)); 
      --ERROR accumulation REGISTER
      --This register is NOT Masked with err_mask
      --This register updates when any bit on err_in is active 
      err_acum                        : out std_ulogic_vector(0 to ((err_mask_width) - 1)); 
      err_acum_p                      : out std_ulogic;  -- err_acum even parity
      err_acum_perr                   : out std_ulogic;  --internal parity error reporting for this register instantiation

      --This input will cause the err_acum to stop accumulating error bits when bit on err_in is active
      stop                            : in STD_ULOGIC := '0';
      --This input will clear the err_acum register 
      clear                           : in std_ulogic := '0'
      );

  attribute BLOCK_TYPE of cb_err_reg : entity is LEAF;
  attribute BTR_NAME of cb_err_reg : entity is "CB_ERR_REG";
  attribute PIN_DEFAULT_GROUND_DOMAIN of cb_err_reg : entity is "GND";
  attribute PIN_DEFAULT_POWER_DOMAIN of cb_err_reg : entity is "VDD";
  attribute RECURSIVE_SYNTHESIS of cb_err_reg : entity is 2;
  attribute PIN_DATA of gckn : signal is "PIN_FUNCTION=/G_CLK/";
  attribute GROUND_PIN of gnd : signal is 1;
  attribute POWER_PIN of vdd : signal is 1;
end cb_err_reg;


architecture cb_err_reg of cb_err_reg is
  SIGNAL update  : std_ulogic;
  SIGNAL act           : std_ulogic;
  SIGNAL act_acum      : std_ulogic;
  SIGNAL act_mask      : std_ulogic;
  SIGNAL err_in_d      : std_ulogic_vector(0 to err_mask_width-1);
  SIGNAL err_in_q      : std_ulogic_vector(0 to err_mask_width-1);
  SIGNAL err_acum_p_d  : std_ulogic;
  SIGNAL err_acum_p_q  : std_ulogic;
  SIGNAL err_acum_d    : std_ulogic_vector(0 to err_mask_width-1);
  SIGNAL err_acum_q    : std_ulogic_vector(0 to err_mask_width-1);
  signal err_mask_d    : std_ulogic_vector(0 to err_mask_width-1);  --MASK register output value
  SIGNAL err_mask_p_d  : std_ulogic;
  signal err_mask_q    : std_ulogic_vector(0 to ((ERR_MASK_WIDTH)-1));  --MASK register output value
  SIGNAL err_mask_p_q  : std_ulogic;
  SIGNAL err_mask_wr   : std_ulogic;
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
  act_acum   <= update OR clear;

  update         <= vor(err_in) AND NOT stop; 
  err_acum_d     <= gate(err_in OR err_acum_q,     NOT clear);

  err_acum_p_d   <= xor_reduce(err_acum_d);
                    

  err_acum_perr       <= xor_reduce(err_acum_q) XOR err_acum_p_q;
  err_acum            <= err_acum_q;
  err_acum_p          <= err_acum_p_q;


  err_outq: IF error_out_latch  GENERATE
    err_in_d         <= err_in;
    err_out          <= err_in_q AND NOT err_mask_q;
    err_inq: entity latches.c_morph_dff
    generic map (width => 64, offset => 0)
    port map(gckn                 => gckn,
    	     syncr                => syncr,
             e                    => act,
             vdd                  => vdd,
             vss                  => gnd,
             d                    => err_in_d(0 to 63),
             q                    => err_in_q(0 to 63));

  END GENERATE err_outq;


  err_outd: IF NOT error_out_latch  GENERATE

    err_out          <= err_in AND NOT err_mask_q;

    err_in_d <= (OTHERS => '0');
    err_in_q <= (OTHERS => '0');
    cb_term(err_in_d);
    cb_term(err_in_q);

  END GENERATE err_outd;



  act_mask    <= err_mask_wr;
  err_mask_wr <= sc_wr AND sc_addr_v(addr_bit_index);

 genP64 : IF ERR_MASK_WIDTH = 64 GENERATE
     err_mask_d  <= gate(sc_wdata, err_mask_wr) OR
                    gate(err_mask_q, NOT err_mask_wr);
     err_mask_p_d <= (sc_wparity AND err_mask_wr) OR (err_mask_p_q and NOT err_mask_wr);
  END GENERATE genP64;
    
  genP_not64 : IF ERR_MASK_WIDTH < 64 GENERATE
     err_mask_d    <= gate(sc_wdata(0 TO ERR_MASK_WIDTH-1), err_mask_wr) OR
                     gate(err_mask_q(0 TO ERR_MASK_WIDTH-1), NOT err_mask_wr);
     err_mask_p_d <= ((sc_wparity XOR xor_reduce(sc_wdata(ERR_MASK_WIDTH TO 63))) AND err_mask_wr) OR (err_mask_p_q and NOT err_mask_wr);
     cb_term(sc_wdata(ERR_MASK_WIDTH TO 63));
  END GENERATE genP_not64;

  err_mask_perr <= xor_reduce(err_mask_q) XOR err_mask_p_q;

  err_mask   <= err_mask_q;
  err_mask_p <= err_mask_p_q;

  
  sc_wr_pulse   <= sc_wr_pulse_q;
  sc_wr_pulse_d <= err_mask_wr;


err_maskq : entity latches.c_morph_dff
  generic map (width => err_mask_width, offset => 0, init => ERR_MASK_RESET_VALUE(0 TO (err_mask_width-1)))
  port map(gckn => gckn,
	   syncr => syncr,
           e    => act_mask,
           vdd  => vdd,
           vss  => gnd,
           d    => err_mask_d(0 to err_mask_width-1),
           q    => err_mask_q(0 to err_mask_width-1));

err_mask_pq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
	   syncr                => syncr,
           e                    => act_mask,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(err_mask_p_d),
           Tconv(q)             => err_mask_p_q);


sc_wr_pulseq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
	   syncr                => syncr,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(sc_wr_pulse_d),
           Tconv(q)             => sc_wr_pulse_q);

err_acumq: entity latches.c_morph_dff
generic map (width => err_mask_width, offset => 0)
port map(gckn                 => gckn,
	   syncr                => syncr,
         e                    => act_acum,
         vdd                  => vdd,
         vss                  => gnd,
         d                    => err_acum_d(0 to err_mask_width-1),
         q                    => err_acum_q(0 to err_mask_width-1));

err_acum_pq: entity latches.c_morph_dff
generic map (width => 1, offset => 0)
port map(gckn                 => gckn,
	 syncr                => syncr,
         e                    => act_acum,
         vdd                  => vdd,
         vss                  => gnd,
         d                    => Tconv(err_acum_p_d),
         Tconv(q)             => err_acum_p_q);


end cb_err_reg;
