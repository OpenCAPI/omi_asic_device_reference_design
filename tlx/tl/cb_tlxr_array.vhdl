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
    USE ibm.std_ulogic_unsigned.all;           -- To_Std_Ulogic_Vector
    USE ibm.std_ulogic_function_support.all;   -- Gate
    USE ibm.synthesis_support.all;             -- Attributes
    USE support.logic_support_pkg.all;         -- Attributes
    USE support.power_logic_pkg.ALL;           -- power_logic

entity cb_tlxr_array is
  generic (
    width                          : natural := 146;
    depth                          : natural := 4;
    addr_width                     : natural := 2
    );
  port (
    gckn                           : in std_ulogic;                            -- edge clock

    din                            : in std_ulogic_vector(0 to (width - 1));
    bein                           : in std_ulogic_vector(0 to (width - 1)) := (others=>'1');
    wr                             : in std_ulogic;                            -- +wr enable
    wr_ptr                         : in std_ulogic_vector(0 to depth-1); -- wr address is now one hot
    rd                             : in std_ulogic;                            -- +rd enable
    rd_ptr                         : in std_ulogic_vector(0 to (addr_width - 1)); -- rd address
    gnd                            : inout power_logic;
    vdd                            : inout power_logic;
    dout                           : out std_ulogic_vector(0 to (width - 1))
    );
  attribute BLOCK_TYPE of cb_tlxr_array : entity is LEAF;
  attribute btr_name of cb_tlxr_array : entity is "CB_TLXR_ARRAY";
  attribute PIN_DEFAULT_GROUND_DOMAIN of cb_tlxr_array : entity is "GND";
  attribute PIN_DEFAULT_POWER_DOMAIN of cb_tlxr_array : entity is "VDD";
  attribute RECURSIVE_SYNTHESIS of cb_tlxr_array : entity is 2;
  attribute PIN_DATA of gckn : signal is "PIN_FUNCTION=/G_CLK/";
  attribute GROUND_PIN of gnd : signal is 1;
  attribute POWER_PIN of vdd : signal is 1;
end entity;

architecture cb_tlxr_array of cb_tlxr_array is

  type mem146 is array(NATURAL range<>) of std_ulogic_vector(0 to width-1);

  function vec_to_mem146( vec:in std_ulogic_vector ) return mem146 is
    variable gv: mem146(0 to vec'length/width-1);
  begin
    for i in 0 to gv'length-1 loop
      gv(i) := vec(vec'left + i*width to vec'left+i*width+width-1);
    end loop;
    return gv;
  end function vec_to_mem146;

  function mem146_to_vec( mem:in mem146 ) return std_ulogic_vector is
    variable v: std_ulogic_vector(0 to mem'length*width-1);
  begin
    for i in 0 to mem'length-1 loop
      v(i*width to i*width+width-1) := mem(i + mem'left);
    end loop;
    return v;
  end;

  signal mem_blocki     : mem146(0 TO depth-1);
  signal mem_blocko     : mem146(0 TO depth-1);
  signal mem_block_d    : std_ulogic_vector(0 TO depth*width-1);
  signal mem_block_q    : std_ulogic_vector(0 TO depth*width-1);
  signal rd_ptr_d       : std_ulogic_vector(0 TO addr_width-1);
  signal rd_ptr_q       : std_ulogic_vector(0 TO addr_width-1);

  SIGNAL act_rd : std_ulogic;

begin

  -- Map 2-D array view to/from 1-D vector view (2D view assists aet viewing)

  mem_block_d <= mem146_to_vec(mem_blocki);
  mem_blocko  <= vec_to_mem146(mem_block_q);

  -- Loop to generate each storage word, with clock gating

  WD_G:for wd in 0 to depth-1 generate
   signal wd_Act : std_ulogic;
  begin

    wd_act <= wr and wr_ptr((depth-1) - wd);

    mem_blocki(wd) <= (      bein  and din                                       )
                   or ( (not bein) and mem_blocko(wd)                            );

    MEM: entity latches.c_morph_dff
    generic map (width => width, offset => 0, INIT => (0 to width-1=>'X'))
    port map(gckn                 => gckn,
             e                    => wd_act,
             vdd                  => vdd,
             vss                  => gnd,
             d                    => mem_block_d(wd*width to wd*width + width-1),
             q                    => mem_block_q(wd*width to wd*width + width-1));

  end generate WD_G;

  -- Latch read address

  act_rd   <= rd;
  rd_ptr_d <= rd_ptr;

  rd_ptrq: entity latches.c_morph_dff
    generic map (width => addr_width, offset => 0, INIT => (0 to addr_width-1=>'X'))
    port map(gckn                 => gckn,
             e                    => act_rd,
             vdd                  => vdd,
             vss                  => gnd,
             d                    => rd_ptr_d(0 to addr_width-1),
             q                    => rd_ptr_q(0 to addr_width-1));

  -- Read combinatorial process.

  R_PROC:process(mem_block_q,rd_ptr_q)
  variable muxd_data:std_ulogic_vector(0 to width-1);
  begin
    muxd_data := (others=>'0');
    for wd in 0 to depth-1 loop
      muxd_data := muxd_data
                or GATE( mem_block_q(wd*width to wd*width + width-1) , not OR_REDUCE(rd_ptr_q xor To_Std_Ulogic_Vector(wd,addr_width)) );
    end loop;
    dout <= muxd_data;
  end process R_PROC;


end architecture cb_tlxr_array;
