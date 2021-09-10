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
LIBRARY ieee,ibm,latches,support;
    USE ieee.std_logic_1164.all;
    USE ibm.std_ulogic_support.all;                 -- Tconv
    USE ibm.std_ulogic_unsigned.all;                -- +1,-1
    USE ibm.std_ulogic_function_support.all;        -- Gate, _Reduce
    USE ibm.synthesis_support.all;                  -- Attributes
    USE ieee.numeric_std.ALL;                       -- Unsigned()
    USE support.logic_support_pkg.all;              -- Attributes
    USE support.power_logic_pkg.ALL;
    USE work.cb_tlxt_pkg.INCP;                      -- Parity for counters

LIBRARY work;

entity cb_gp_fifo is
  generic (
    width                          : natural := 72;
    depth                          : natural := 4;
    addr_width                     : natural := 2
    );
  port (
    gckn                           : in std_ulogic;
    syncr                          : in STD_ULOGIC := '0'; -- Leave unconnected if no reset required

    din                            : in std_ulogic_vector(0 to (width - 1));
    wr                             : in std_ulogic;
    rd                             : in std_ulogic;
    dout                           : out std_ulogic_vector(0 to (width - 1));

    empty                          : out std_ulogic;
    full                           : out std_ulogic;
    gnd                            : inout power_logic;
    vdd                            : inout power_logic;
    fifo_err                       : out std_ulogic_vector(0 to 1);
    count                          : out std_ulogic_vector(0 to addr_width)  -- used count (not wrcount / freecount)
    );
  attribute BLOCK_TYPE of cb_gp_fifo : entity is LEAF;
  attribute btr_name of cb_gp_fifo : entity is "CB_GP_FIFO";
  attribute PIN_DEFAULT_GROUND_DOMAIN of cb_gp_fifo : entity is "GND";
  attribute PIN_DEFAULT_POWER_DOMAIN of cb_gp_fifo : entity is "VDD";
  attribute RECURSIVE_SYNTHESIS of cb_gp_fifo : entity is 2;
  attribute PIN_DATA of gckn : signal is "PIN_FUNCTION=/G_CLK/";
  attribute GROUND_PIN of gnd : signal is 1;
  attribute POWER_PIN of vdd : signal is 1;
end entity;

architecture cb_gp_fifo of cb_gp_fifo is

type mem is array(NATURAL range<>) of std_ulogic_vector(0 to width-1);

  SIGNAL rd_ptr_d        : std_ulogic_vector(0 to addr_width-1);
  SIGNAL rd_ptr_q        : std_ulogic_vector(0 to addr_width-1);
  SIGNAL wr_ptr_d        : std_ulogic_vector(0 to addr_width-1);
  SIGNAL wr_ptr_q        : std_ulogic_vector(0 to addr_width-1);
  SIGNAL word_count_d    : std_ulogic_vector(0 to addr_width);
  SIGNAL word_count_q    : std_ulogic_vector(0 to addr_width);
  SIGNAL wr_ptr_p_d : std_ulogic;
  SIGNAL rd_ptr_p_d : std_ulogic;
  SIGNAL wr_ptr_p_q : std_ulogic;
  SIGNAL rd_ptr_p_q : std_ulogic;
  SIGNAL word_count_p_d : std_ulogic;
  SIGNAL word_count_p_q : std_ulogic;
  SIGNAL dout_d : std_ulogic_vector(0 to width-1);
  SIGNAL dout_q : std_ulogic_vector(0 to width-1);

  SIGNAL act : std_ulogic;
  SIGNAL act_dout : std_ulogic;
  SIGNAL act_cgt : std_ulogic_vector(0 TO depth-2);

  SIGNAL entry_q : mem(0 TO depth-2);

  SIGNAL wr_to_array : std_ulogic;
  SIGNAL rd_from_array : std_ulogic;
  SIGNAL arr_muxd : std_ulogic_vector(0 to width-1);
  SIGNAL rd_inc : std_ulogic;
  SIGNAL rd_wrp : std_ulogic;
  SIGNAL wr_inc : std_ulogic;
  SIGNAL wr_wrp : std_ulogic;
  SIGNAL addr_start     : std_ulogic_vector(0 to addr_width-1);
  SIGNAL full_int : std_ulogic;
  SIGNAL empty_int : std_ulogic;
  SIGNAL one_int : std_ulogic;
  SIGNAL overflow_e : std_ulogic;
  SIGNAL underflow_e : std_ulogic;
  SIGNAL ctrl_perr : std_ulogic;

begin
  act <= '1';

  --  Pointers

  addr_start <= (OTHERS => '0');
  wr_inc   <= wr and wr_to_array;
  wr_wrp   <= (wr_ptr_q = tconv(depth-2,addr_width));
  wr_ptr_d <= gate(wr_ptr_q+1, wr_inc AND NOT wr_wrp)
           or gate(addr_start, wr_inc AND     wr_wrp)
           or gate(wr_ptr_q,   not wr_inc           );

--wr_ptr_p_d           <= xor_reduce(wr_ptr_d(0 TO addr_width-1));
  wr_ptr_p_d <= ((wr_ptr_p_q xor INCP(wr_ptr_q)) AND wr_inc AND NOT wr_wrp)
             or ('0'                             AND wr_inc AND     wr_wrp)
             or (wr_ptr_p_q                      AND not wr_inc           );

  rd_inc   <= rd and rd_from_array;
  rd_wrp   <= (rd_ptr_q = tconv(depth-2,addr_width));
  rd_ptr_d <= gate(rd_ptr_q+1, rd_inc AND NOT rd_wrp)
           or gate(addr_start, rd_inc AND rd_wrp    )
           or gate(rd_ptr_q,   not rd_inc           );

--rd_ptr_p_d           <= xor_reduce(rd_ptr_d(0 TO addr_width-1));
  rd_ptr_p_d <= ((rd_ptr_p_q xor INCP(rd_ptr_q)) AND rd_inc AND NOT rd_wrp)
             or ('0'                             AND rd_inc AND rd_wrp    )
             or (rd_ptr_p_q                      AND not rd_inc           );

  -- Word counter (overall words including dout_q), not just those in the storage array

  word_count_d <= gate(word_count_q + 1, wr AND NOT rd) OR
                  gate(word_count_q - 1, rd AND NOT wr) OR
                  gate(word_count_q,     wr XNOR rd   );


--word_count_p_d       <= xor_reduce(word_count_d(0 TO addr_width));
  word_count_p_d <= ((word_count_p_q xor INCP(word_count_q))     AND wr AND NOT rd) OR
                    ((word_count_p_q xor INCP(not word_count_q)) AND rd AND NOT wr) OR
                    (word_count_p_q                              AND (wr XNOR rd) );

  count      <= word_count_q;
  empty_int  <= NOT or_reduce(word_count_q);
  one_int    <= (word_count_q = tconv(1    ,addr_width+1));
  full_int   <= (word_count_q = tconv(depth,addr_width+1));
  empty      <= empty_int;
  full       <= full_int;

  -- Storage array

  WR_GEN:for i in 0 to depth-2 GENERATE

     act_cgt(i)  <= wr AND (tconv(i,addr_width) = wr_ptr_q(0 TO addr_width-1));

     entryq: entity latches.c_morph_dff
     generic map (width => width, offset => 0)
     port map(gckn                 => gckn,
              e                    => act_cgt(i),
              vdd                  => vdd,
              vss                  => gnd,
              d                    => din,
              syncr                => syncr,
              q                    => entry_q(i));

  END GENERATE wr_gen;

  arr_muxd <= entry_q(to_integer(unsigned(rd_ptr_q)));

  -- Output register.
  -- If empty, or one (held in dout_q) and reading, then writes go into dout_q
  -- If one (held in dout_q) and not reading, or more than one, writes go into array
  -- If more than one and reading, load dout_q from array

  wr_to_array   <= not empty_int and not (one_int and rd);
  rd_from_array <= not empty_int and not  one_int;
  act_dout      <= (wr and not wr_to_array) or (rd and rd_from_array);

  dout_d   <= GATE( din,           empty_int or one_int )
           or GATE( arr_muxd, not (empty_int or one_int));

  dout     <= dout_q;

  -- Error checking: Bit 0: FIFO overflow, -- Bit 1: FIFO underflow. Parity error sets both

  overflow_e   <= wr and full_int;
  underflow_e  <= rd and empty_int;
  ctrl_perr    <= xor_reduce(wr_ptr_q(0 TO addr_width-1)     & wr_ptr_p_q) OR
                  xor_reduce(rd_ptr_q(0 TO addr_width-1)     & rd_ptr_p_q) or
                  xor_reduce(word_count_q(0 TO addr_width)   & word_count_p_q);

  fifo_err(0) <= overflow_e  OR ctrl_perr;
  fifo_err(1) <= underflow_e OR ctrl_perr;

  -- Latches

doutq: entity latches.c_morph_dff
  generic map (width => width, offset => 0)
  port map(gckn                 => gckn,
           syncr                => syncr,
           e                    => act_dout,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => dout_d(0 to width-1),
           q                    => dout_q(0 to width-1));

rd_ptrq: entity latches.c_morph_dff
  generic map (width => addr_width, offset => 0, init => (0 TO addr_width-1 => '0'))
  port map(gckn                 => gckn,
           syncr        => syncr,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => rd_ptr_d(0 to addr_width-1),
           q                    => rd_ptr_q(0 to addr_width-1));

rd_ptr_pq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(rd_ptr_p_d),
           syncr                => syncr,
           Tconv(q)             => rd_ptr_p_q);

word_countq: entity latches.c_morph_dff
  generic map (width => addr_width+1, offset => 0)
  port map(gckn                 => gckn,
           syncr        => syncr,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => word_count_d(0 to addr_width),
           q                    => word_count_q(0 to addr_width));

word_count_pq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(word_count_p_d),
           syncr                => syncr,
           Tconv(q)             => word_count_p_q);
wr_ptrq: entity latches.c_morph_dff
  generic map (width => addr_width, offset => 0,init => (0 TO addr_width-1 => '0'))
  port map(gckn                 => gckn,
           syncr        => syncr,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => wr_ptr_d(0 to addr_width-1),
           q                    => wr_ptr_q(0 to addr_width-1));

wr_ptr_pq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(wr_ptr_p_d),
           syncr                => syncr,
           Tconv(q)             => wr_ptr_p_q);

end architecture;
