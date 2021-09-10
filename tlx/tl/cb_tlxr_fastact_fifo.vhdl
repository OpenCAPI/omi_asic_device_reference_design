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
LIBRARY ieee,ibm,latches,stdcell,support;
    USE ibm.std_ulogic_asic_function_support.all;
    USE ibm.std_ulogic_support.all;
    USE ibm.std_ulogic_unsigned.all;
    USE ibm.std_ulogic_function_support.all;
    USE ibm.synthesis_support.all;
    USE ieee.std_logic_1164.all;
    USE ieee.numeric_std.ALL;
    USE ibm.std_ulogic_ao_support.ALL;
    USE support.logic_support_pkg.all;
    USE support.power_logic_pkg.ALL;
    USE support.design_util_functions_pkg.all;
    USE support.signal_resolution_pkg.all;
    use ibm.texsim_attributes.all;

LIBRARY work;
USE work.cb_func.ALL;

entity cb_tlxr_fastact_fifo is
  port (
    gckn                           : in STD_ULOGIC;
    syncr                          : in STD_ULOGIC;           --connect the latch version of syncr
    gnd                            : inout power_logic;
    vdd                            : inout power_logic;

    --dlx/tlxr
    fast_act_fifo_wr               : in STD_ULOGIC;
    fast_act_fifo_addr             : in STD_ULOGIC_VECTOR(0 to 34);

    fifo_xlat_val                  : out STD_ULOGIC;
    fifo_xlat_info                 : out STD_ULOGIC_VECTOR(0 to 34);  

    fifo_xlat_val_a                : out STD_ULOGIC;
    fifo_xlat_info_a               : out STD_ULOGIC_VECTOR(0 to 34);  

    fifo_xlat_val_b                : out STD_ULOGIC;
    fifo_xlat_info_b               : out STD_ULOGIC_VECTOR(0 to 34);  

    --srq/tlxr
    srq_tlxr_fast_act_fifo_next    : in STD_ULOGIC;  -- pulse; shift fast act fifo; will only occur at most every other cycle; can mean either current address has been taken or not able to go out / undesireable
    srq_tlxr_fast_act_fifo_drain   : in STD_ULOGIC   -- level; drain & don't fill fast act fifo (doing writes, rrq has activates)


    );
  attribute BLOCK_TYPE of cb_tlxr_fastact_fifo : entity is LEAF;
  attribute btr_name of cb_tlxr_fastact_fifo : entity is "CB_TLXR_FASTACT_FIFO";
  attribute PIN_DEFAULT_GROUND_DOMAIN of cb_tlxr_fastact_fifo : entity is "GND";
  attribute PIN_DEFAULT_POWER_DOMAIN of cb_tlxr_fastact_fifo : entity is "VDD";
  attribute RECURSIVE_SYNTHESIS of cb_tlxr_fastact_fifo : entity is 2;
  attribute PIN_DATA of gckn : signal is "PIN_FUNCTION=/G_CLK/";
  attribute GROUND_PIN of gnd : signal is 1;
  attribute POWER_PIN of vdd : signal is 1;
end entity;

architecture cb_tlxr_fastact_fifo of cb_tlxr_fastact_fifo is
 
SIGNAL wr : STD_ULOGIC;
SIGNAL rd : STD_ULOGIC;
SIGNAL drain : STD_ULOGIC;

SIGNAL din : std_ulogic_vector(0 to 34);
SIGNAL dout : std_ulogic_vector(0 to 34);
SIGNAL dout_val : STD_ULOGIC;
SIGNAL next_entry : std_ulogic_vector(0 to 3);
SIGNAL entry_valid : std_ulogic_vector(0 to 3);
SIGNAL next_entry_shift : std_ulogic_vector(0 to 3);
SIGNAL wr_vec : std_ulogic_vector(0 to 3);
SIGNAL entry00_q : std_ulogic_vector(0 to 34);
SIGNAL entry00_shift : std_ulogic_vector(0 to 34);
SIGNAL entry01_q : std_ulogic_vector(0 to 34);
SIGNAL entry01_shift : std_ulogic_vector(0 to 34);
SIGNAL entry02_q : std_ulogic_vector(0 to 34);
SIGNAL entry02_shift : std_ulogic_vector(0 to 34);
SIGNAL entry03_q : std_ulogic_vector(0 to 34);
SIGNAL entry03_shift : std_ulogic_vector(0 to 34);
SIGNAL entry00_val_q : std_ulogic;
SIGNAL entry01_val_q : std_ulogic;
SIGNAL entry02_val_q : std_ulogic;
SIGNAL entry03_val_q : std_ulogic;
SIGNAL shift_entry : std_ulogic_vector(0 to 3);
SIGNAL act_cgt00 : std_ulogic;
SIGNAL act_cgt01 : std_ulogic;
SIGNAL act_cgt02 : std_ulogic;
SIGNAL act_cgt03 : std_ulogic;
SIGNAL entry00_cgt00_d : std_ulogic_vector(0 to 34);
SIGNAL entry01_cgt01_d : std_ulogic_vector(0 to 34);
SIGNAL entry02_cgt02_d : std_ulogic_vector(0 to 34);
SIGNAL entry03_cgt03_d : std_ulogic_vector(0 to 34);
SIGNAL entry00_val_shift : std_ulogic;
SIGNAL entry01_val_shift : std_ulogic;
SIGNAL entry02_val_shift : std_ulogic;
SIGNAL entry03_val_shift : std_ulogic;
SIGNAL act_valcgt00 : std_ulogic;
SIGNAL act_valcgt01 : std_ulogic;
SIGNAL act_valcgt02 : std_ulogic;
SIGNAL act_valcgt03 : std_ulogic;
SIGNAL entry00_val_valcgt00_d : std_ulogic;
SIGNAL entry01_val_valcgt01_d : std_ulogic;
SIGNAL entry02_val_valcgt02_d : std_ulogic;
SIGNAL entry03_val_valcgt03_d : std_ulogic;
SIGNAL dout_val_a : std_ulogic;
SIGNAL dout_a : std_ulogic_vector(0 to 34);
SIGNAL dout_val_b : std_ulogic;
SIGNAL dout_b : std_ulogic_vector(0 to 34);
SIGNAL entry00_a_cgt00_d : std_ulogic_vector(0 to 34);
SIGNAL entry00_b_cgt00_d : std_ulogic_vector(0 to 34);
SIGNAL entry00_a_q : std_ulogic_vector(0 to 34);
SIGNAL entry00_b_q : std_ulogic_vector(0 to 34);
SIGNAL entry00_val_a_valcgt00_d : std_ulogic;
SIGNAL entry00_val_b_valcgt00_d : std_ulogic;
SIGNAL entry00_val_a_q : std_ulogic;
SIGNAL entry00_val_b_q : std_ulogic;
 
begin

 
  -- no overflow/underflow check needed
  -- ignore wr if full
  -- no val if rd empty
  wr    <= fast_act_fifo_wr;               
  rd    <= srq_tlxr_fast_act_fifo_next;
  drain <= srq_tlxr_fast_act_fifo_drain;

  din(0 TO 34) <= fast_act_fifo_addr;            -- : in std_ulogic_vector(0 to 34);


  fifo_xlat_val            <= dout_val; -- : out std_ulogic;
  fifo_xlat_info(0 TO 34)  <= dout(0 TO 34); --: out std_ulogic_vector(0 to 26);

  fifo_xlat_val_a            <= dout_val_a; -- : out std_ulogic;
  fifo_xlat_info_a(0 TO 34)  <= dout_a(0 TO 34); --: out std_ulogic_vector(0 to 26);

  fifo_xlat_val_b            <= dout_val_b; -- : out std_ulogic;
  fifo_xlat_info_b(0 TO 34)  <= dout_b(0 TO 34); --: out std_ulogic_vector(0 to 26);


  next_entry(0 TO 3)        <= NOT entry_valid(0 TO 3) AND ('1' & entry_valid(0 TO 2));  --pick first available entry
  next_entry_shift(0 TO 3)  <= next_entry(1 TO 3) & '0';
  wr_vec(0 TO 3)            <= gate(next_entry(0 TO 3), wr AND NOT rd) OR
                               gate(next_entry_shift(0 TO 3), wr AND rd);




  entry00_shift(0 to 34) <= entry01_q(0 TO 34);
  entry01_shift(0 to 34) <= entry02_q(0 to 34);
  entry02_shift(0 to 34) <= entry03_q(0 to 34);
  entry03_shift(0 to 34) <= (OTHERS => '0');

  entry_valid(0)  <= entry00_val_q;
  entry_valid(1)  <= entry01_val_q;
  entry_valid(2)  <= entry02_val_q;
  entry_valid(3)  <= entry03_val_q;
       
  shift_entry(0 TO 3)       <= gate(entry_valid(0 TO 3), rd);                                            

  act_cgt00  <= (wr_vec(0)  or shift_entry(0)) AND NOT drain ;    --MR_DOM _cgt00  func_gate
  act_cgt01  <= (wr_vec(1)  or shift_entry(1)) AND NOT drain ;    --MR_DOM _cgt01  func_gate
  act_cgt02  <= (wr_vec(2)  or shift_entry(2)) AND NOT drain ;    --MR_DOM _cgt02  func_gate
  act_cgt03  <= (wr_vec(3)  or shift_entry(3)) AND NOT drain ;    --MR_DOM _cgt03  func_gate

  

  entry00_cgt00_d(0 to 34)     <= gate(din(0 to 34), wr_vec(0) ) or gate(entry00_shift, shift_entry(0) );
  entry00_a_cgt00_d(0 to 34)   <= gate(din(0 to 34), wr_vec(0) ) or gate(entry00_shift, shift_entry(0) );
  entry00_b_cgt00_d(0 to 34)   <= gate(din(0 to 34), wr_vec(0) ) or gate(entry00_shift, shift_entry(0) );

  entry01_cgt01_d(0 to 34)   <= gate(din(0 to 34), wr_vec(1) ) or gate(entry01_shift, shift_entry(1) );
  entry02_cgt02_d(0 to 34)   <= gate(din(0 to 34), wr_vec(2) ) or gate(entry02_shift, shift_entry(2) );
  entry03_cgt03_d(0 to 34)   <= gate(din(0 to 34), wr_vec(3) ) or gate(entry03_shift, shift_entry(3) );

  dout(0 TO 34)    <= entry00_q(0 TO 34);
  dout_a(0 TO 34)  <= entry00_a_q(0 TO 34);
  dout_b(0 TO 34)  <= entry00_b_q(0 TO 34);

  entry00_val_shift <= entry01_val_q;
  entry01_val_shift <= entry02_val_q;
  entry02_val_shift <= entry03_val_q;
  entry03_val_shift <= '0';

  act_valcgt00  <= wr_vec(0)  or shift_entry(0) or drain ;    --MR_DOM _valcgt00  func_gate
  act_valcgt01  <= wr_vec(1)  or shift_entry(1) or drain ;    --MR_DOM _valcgt01  func_gate
  act_valcgt02  <= wr_vec(2)  or shift_entry(2) or drain ;    --MR_DOM _valcgt02  func_gate
  act_valcgt03  <= wr_vec(3)  or shift_entry(3) or drain ;    --MR_DOM _valcgt03  func_gate

  entry00_val_valcgt00_d   <= (wr_vec(0) AND NOT drain ) or (entry00_val_shift and shift_entry(0) AND NOT drain );
  entry00_val_a_valcgt00_d   <= (wr_vec(0) AND NOT drain ) or (entry00_val_shift and shift_entry(0) AND NOT drain );
  entry00_val_b_valcgt00_d   <= (wr_vec(0) AND NOT drain ) or (entry00_val_shift and shift_entry(0) AND NOT drain );

  entry01_val_valcgt01_d   <= (wr_vec(1) AND NOT drain ) or (entry01_val_shift and shift_entry(1) AND NOT drain );
  entry02_val_valcgt02_d   <= (wr_vec(2) AND NOT drain ) or (entry02_val_shift and shift_entry(2) AND NOT drain );
  entry03_val_valcgt03_d   <= (wr_vec(3) AND NOT drain ) or (entry03_val_shift and shift_entry(3) AND NOT drain );

  dout_val    <= entry00_val_q;
  dout_val_a  <= entry00_val_a_q;
  dout_val_b  <= entry00_val_b_q;






entry00_aq: entity latches.c_morph_dff
  generic map (width => 35, offset => 0)
  port map(gckn                 => gckn,
           e                    => act_cgt00,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => entry00_a_cgt00_d(0 to 34),
           syncr                => syncr,
           q                    => entry00_a_q(0 to 34));

entry00_bq: entity latches.c_morph_dff
  generic map (width => 35, offset => 0)
  port map(gckn                 => gckn,
           e                    => act_cgt00,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => entry00_b_cgt00_d(0 to 34),
           syncr                => syncr,
           q                    => entry00_b_q(0 to 34));

entry00q: entity latches.c_morph_dff
  generic map (width => 35, offset => 0)
  port map(gckn                 => gckn,
           e                    => act_cgt00,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => entry00_cgt00_d(0 to 34),
           syncr                => syncr,
           q                    => entry00_q(0 to 34));

entry00_val_aq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act_valcgt00,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(entry00_val_a_valcgt00_d),
           syncr                => syncr,
           Tconv(q)             => entry00_val_a_q);

entry00_val_bq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act_valcgt00,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(entry00_val_b_valcgt00_d),
           syncr                => syncr,
           Tconv(q)             => entry00_val_b_q);

entry00_valq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act_valcgt00,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(entry00_val_valcgt00_d),
           syncr                => syncr,
           Tconv(q)             => entry00_val_q);

entry01q: entity latches.c_morph_dff
  generic map (width => 35, offset => 0)
  port map(gckn                 => gckn,
           e                    => act_cgt01,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => entry01_cgt01_d(0 to 34),
           syncr                => syncr,
           q                    => entry01_q(0 to 34));

entry01_valq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act_valcgt01,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(entry01_val_valcgt01_d),
           syncr                => syncr,
           Tconv(q)             => entry01_val_q);

entry02q: entity latches.c_morph_dff
  generic map (width => 35, offset => 0)
  port map(gckn                 => gckn,
           e                    => act_cgt02,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => entry02_cgt02_d(0 to 34),
           syncr                => syncr,
           q                    => entry02_q(0 to 34));

entry02_valq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act_valcgt02,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(entry02_val_valcgt02_d),
           syncr                => syncr,
           Tconv(q)             => entry02_val_q);

entry03q: entity latches.c_morph_dff
  generic map (width => 35, offset => 0)
  port map(gckn                 => gckn,
           e                    => act_cgt03,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => entry03_cgt03_d(0 to 34),
           syncr                => syncr,
           q                    => entry03_q(0 to 34));

entry03_valq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act_valcgt03,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(entry03_val_valcgt03_d),
           syncr                => syncr,
           Tconv(q)             => entry03_val_q);

end architecture;
