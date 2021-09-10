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

entity cb_tlxr_fastact_fifo_wrap is
  port (
    gckn                           : in STD_ULOGIC;
    syncr                          : in STD_ULOGIC;           --connect the latch version of syncr
    gnd                            : inout power_logic;
    vdd                            : inout power_logic;

    half_dimm_mode                 : in std_ulogic;

-- Configuration for the address translators from MCB
    mcb_tlxr_xlt_slot0_valid       : in std_ulogic;
    mcb_tlxr_xlt_slot1_valid       : in std_ulogic;
    mcb_tlxr_xlt_slot0_d_value     : in std_ulogic;
    mcb_tlxr_xlt_slot1_d_value     : in std_ulogic;
    mcb_tlxr_xlt_slot0_m0_valid    : in std_ulogic;
    mcb_tlxr_xlt_slot0_m1_valid    : in std_ulogic;
    mcb_tlxr_xlt_slot0_s0_valid    : in std_ulogic;
    mcb_tlxr_xlt_slot0_s1_valid    : in std_ulogic;
    mcb_tlxr_xlt_slot0_s2_valid    : in std_ulogic;
    mcb_tlxr_xlt_slot0_r15_valid   : in std_ulogic;
    mcb_tlxr_xlt_slot0_r16_valid   : in std_ulogic;
    mcb_tlxr_xlt_slot0_r17_valid   : in std_ulogic;
    mcb_tlxr_xlt_slot1_m0_valid    : in std_ulogic;
    mcb_tlxr_xlt_slot1_m1_valid    : in std_ulogic;
    mcb_tlxr_xlt_slot1_s0_valid    : in std_ulogic;
    mcb_tlxr_xlt_slot1_s1_valid    : in std_ulogic;
    mcb_tlxr_xlt_slot1_s2_valid    : in std_ulogic;
    mcb_tlxr_xlt_slot1_r15_valid   : in std_ulogic;
    mcb_tlxr_xlt_slot1_r16_valid   : in std_ulogic;
    mcb_tlxr_xlt_slot1_r17_valid   : in std_ulogic;
    mcb_tlxr_xlt_d_bit_map         : in std_ulogic_vector(0 to 4);
    mcb_tlxr_xlt_m0_bit_map        : in std_ulogic_vector(0 to 4);
    mcb_tlxr_xlt_m1_bit_map        : in std_ulogic_vector(0 to 4);
    mcb_tlxr_xlt_s0_bit_map        : in std_ulogic_vector(0 to 4);
    mcb_tlxr_xlt_s1_bit_map        : in std_ulogic_vector(0 to 4);
    mcb_tlxr_xlt_s2_bit_map        : in std_ulogic_vector(0 to 4);
    mcb_tlxr_xlt_r17_bit_map       : in std_ulogic_vector(0 to 4);
    mcb_tlxr_xlt_r16_bit_map       : in std_ulogic_vector(0 to 4);
    mcb_tlxr_xlt_r15_bit_map       : in std_ulogic_vector(0 to 4);
    mcb_tlxr_xlt_c3_bit_map        : in std_ulogic_vector(0 to 4);
    mcb_tlxr_xlt_c4_bit_map        : in std_ulogic_vector(0 to 4);
    mcb_tlxr_xlt_c5_bit_map        : in std_ulogic_vector(0 to 4);
    mcb_tlxr_xlt_c6_bit_map        : in std_ulogic_vector(0 to 4);
    mcb_tlxr_xlt_c7_bit_map        : in std_ulogic_vector(0 to 4);
    mcb_tlxr_xlt_c8_bit_map        : in std_ulogic_vector(0 to 4);
    mcb_tlxr_xlt_c9_bit_map        : in std_ulogic_vector(0 to 4);
    mcb_tlxr_xlt_b0_bit_map        : in std_ulogic_vector(0 to 4);
    mcb_tlxr_xlt_b1_bit_map        : in std_ulogic_vector(0 to 4);
    mcb_tlxr_xlt_bg0_bit_map       : in std_ulogic_vector(0 to 4);
    mcb_tlxr_xlt_bg1_bit_map       : in std_ulogic_vector(0 to 4);
    mcb_tlxr_enab_row_addr_hash    : in std_ulogic;

    --dlx/tlxr
    fast_act_fifo_wr               : in STD_ULOGIC;
    fast_act_fifo_addr             : in STD_ULOGIC_VECTOR(0 to 34);

    fast_xlat_error                : out STD_ULOGIC;

    --tlxr/srq
    tlxr_srq_fast_act_fifo_val     : out std_ulogic;
    tlxr_srq_fast_act_fifo_addr    : out std_ulogic_vector(0 to 26);
    tlxr_srq_fast_act_fifo_dimm    : out std_ulogic;
    tlxr_srq_fast_act_fifo_row_bank_par : out std_ulogic;
    tlxr_srq_fast_act_fifo_rank_par : out std_ulogic;

    tlxr_srq_fast_act_fifo_val_a   : out std_ulogic;
    tlxr_srq_fast_act_fifo_addr_a  : out std_ulogic_vector(0 to 26);
    tlxr_srq_fast_act_fifo_dimm_a  : out std_ulogic;
    tlxr_srq_fast_act_fifo_row_bank_par_a : out std_ulogic;
    tlxr_srq_fast_act_fifo_rank_par_a : out std_ulogic;

    tlxr_srq_fast_act_fifo_val_b   : out std_ulogic;
    tlxr_srq_fast_act_fifo_addr_b  : out std_ulogic_vector(0 to 26);
    tlxr_srq_fast_act_fifo_dimm_b  : out std_ulogic;
    tlxr_srq_fast_act_fifo_row_bank_par_b : out std_ulogic;
    tlxr_srq_fast_act_fifo_rank_par_b : out std_ulogic;

    --srq/tlxr
    srq_tlxr_fast_act_fifo_next    : in STD_ULOGIC;  -- pulse; shift fast act fifo; will only occur at most every other cycle; can mean either current address has been taken or not able to go out / undesireable
    srq_tlxr_fast_act_fifo_drain   : in STD_ULOGIC   -- level; drain & don't fill fast act fifo (doing writes, rrq has activates)


    );
  attribute BLOCK_TYPE of cb_tlxr_fastact_fifo_wrap : entity is LEAF;
  attribute btr_name of cb_tlxr_fastact_fifo_wrap : entity is "CB_TLXR_FASTACT_FIFO_WRAP";
  attribute PIN_DEFAULT_GROUND_DOMAIN of cb_tlxr_fastact_fifo_wrap : entity is "GND";
  attribute PIN_DEFAULT_POWER_DOMAIN of cb_tlxr_fastact_fifo_wrap : entity is "VDD";
  attribute RECURSIVE_SYNTHESIS of cb_tlxr_fastact_fifo_wrap : entity is 2;
  attribute PIN_DATA of gckn : signal is "PIN_FUNCTION=/G_CLK/";
  attribute GROUND_PIN of gnd : signal is 1;
  attribute POWER_PIN of vdd : signal is 1;
end entity;

architecture cb_tlxr_fastact_fifo_wrap of cb_tlxr_fastact_fifo_wrap is
 SIGNAL fifo_xlat_val : std_ulogic;
 SIGNAL fifo_xlat_info : std_ulogic_vector(0 to 34);
 SIGNAL fast_xlat_dimm : std_ulogic;
 SIGNAL fast_xlat_addr : std_ulogic_vector(0 to 26);
 SIGNAL fast_decode_d : std_ulogic;
 SIGNAL fast_decode_q : std_ulogic;
 SIGNAL fast_act_fifo_wr_gt : STD_ULOGIC;
 SIGNAL act : std_ulogic;
 SIGNAL fifo_xlat_val_a : std_ulogic;
 SIGNAL fifo_xlat_val_b : std_ulogic;
 SIGNAL fifo_xlat_info_a : std_ulogic_vector(0 to 34);
 SIGNAL fast_xlat_dimm_a : std_ulogic;
 SIGNAL fast_xlat_addr_a : std_ulogic_vector(0 to 26);
 SIGNAL fifo_xlat_info_b : std_ulogic_vector(0 to 34);
 SIGNAL fast_xlat_dimm_b : std_ulogic;
 SIGNAL fast_xlat_addr_b : std_ulogic_vector(0 to 26);
begin

  act <= '1';

  fast_act_fifo_wr_gt <= fast_act_fifo_wr AND fast_decode_q;

  fastact_fifo: entity work.cb_tlxr_fastact_fifo
    PORT MAP (
      gckn  => gckn,                    -- [in  STD_ULOGIC]
      syncr => syncr,                   -- [in  STD_ULOGIC] connect the latch version of syncr
      gnd   => gnd,                     -- [inout power_logic]
      vdd   => vdd,                     -- [inout power_logic]

      --dlx/tlxr
      fast_act_fifo_wr   => fast_act_fifo_wr_gt,        -- [in  STD_ULOGIC] pulse;
      fast_act_fifo_addr => fast_act_fifo_addr,

      fifo_xlat_val     => fifo_xlat_val,        -- [out  STD_ULOGIC] pulse;
      fifo_xlat_info    => fifo_xlat_info,  -- [out STD_ULOGIC_VECTOR(0 TO 30)]

      fifo_xlat_val_a     => fifo_xlat_val_a,        -- [out  STD_ULOGIC] pulse;
      fifo_xlat_info_a    => fifo_xlat_info_a,  -- [out STD_ULOGIC_VECTOR(0 TO 30)]

      fifo_xlat_val_b     => fifo_xlat_val_b,        -- [out  STD_ULOGIC] pulse;
      fifo_xlat_info_b    => fifo_xlat_info_b,  -- [out STD_ULOGIC_VECTOR(0 TO 30)]

      --srq/tlxr
      srq_tlxr_fast_act_fifo_next  => srq_tlxr_fast_act_fifo_next,  -- [in  STD_ULOGIC] pulse; shift fast act fifo; will only occur at most every other cycle; can mean either current address has been taken or not able to go out / undesireable
      srq_tlxr_fast_act_fifo_drain => srq_tlxr_fast_act_fifo_drain);  -- [in STD_ULOGIC] level; drain & don't fill fast act fifo (doing writes, rrq has activates)



XLAT_FAST: entity work.cb_tlxr_xlat
 GENERIC MAP( fast => true)
 PORT MAP(
      vdd                            =>  vdd,                                     --   : inout power_logic
      gnd                            =>  gnd,                                     --   : inout power_logic
      addr                           =>  fifo_xlat_info(0 TO 34),                   --   : IN   std_ulogic_vector(34 downto 0)
      addr4                          =>  '0',                                       --   : IN   std_ulogic
--    fast                           => '1',                                      --   set to 1 for reduced (faster) translate
      HALF_DIMM_MODE                 => HALF_DIMM_MODE,
      cfg_xlt_slot0_valid            =>  MCB_TLXR_xlt_slot0_valid,
      cfg_xlt_slot1_valid            =>  MCB_TLXR_xlt_slot1_valid,
      cfg_xlt_slot0_d_value          =>  MCB_TLXR_xlt_slot0_d_value,
      cfg_xlt_slot1_d_value          =>  MCB_TLXR_xlt_slot1_d_value,
      cfg_xlt_slot0_m0_valid         =>  MCB_TLXR_xlt_slot0_m0_valid,             --   : IN   std_ulogic    1
      cfg_xlt_slot0_m1_valid         =>  MCB_TLXR_xlt_slot0_m1_valid,             --   : IN   std_ulogic    1
      cfg_xlt_slot0_s0_valid         =>  MCB_TLXR_xlt_slot0_s0_valid,             --   : IN   std_ulogic    0
      cfg_xlt_slot0_s1_valid         =>  MCB_TLXR_xlt_slot0_s1_valid,             --   : IN   std_ulogic    0
      cfg_xlt_slot0_s2_valid         =>  MCB_TLXR_xlt_slot0_s2_valid,             --   : IN   std_ulogic    0
      cfg_xlt_slot0_r15_valid        =>  MCB_TLXR_xlt_slot0_r15_valid,            --   : IN   std_ulogic    0
      cfg_xlt_slot0_r16_valid        =>  MCB_TLXR_xlt_slot0_r16_valid,            --   : IN   std_ulogic    0         0
      cfg_xlt_slot0_r17_valid        =>  MCB_TLXR_xlt_slot0_r17_valid,            --   : IN   std_ulogic    0
      cfg_xlt_slot1_m0_valid         =>  MCB_TLXR_xlt_slot1_m0_valid,
      cfg_xlt_slot1_m1_valid         =>  MCB_TLXR_xlt_slot1_m1_valid,
      cfg_xlt_slot1_s0_valid         =>  MCB_TLXR_xlt_slot1_s0_valid,
      cfg_xlt_slot1_s1_valid         =>  MCB_TLXR_xlt_slot1_s1_valid,
      cfg_xlt_slot1_s2_valid         =>  MCB_TLXR_xlt_slot1_s2_valid,
      cfg_xlt_slot1_r15_valid        =>  MCB_TLXR_xlt_slot1_r15_valid,
      cfg_xlt_slot1_r16_valid        =>  MCB_TLXR_xlt_slot1_r16_valid,
      cfg_xlt_slot1_r17_valid        =>  MCB_TLXR_xlt_slot1_r17_valid,
      cfg_xlt_d_bit_map              =>  MCB_TLXR_xlt_d_bit_map,
      cfg_xlt_m0_bit_map             =>  MCB_TLXR_xlt_m0_bit_map,                 --   : IN   std_ulogic_vector(0 to  2)    111       37
      cfg_xlt_m1_bit_map             =>  MCB_TLXR_xlt_m1_bit_map,                 --   : IN   std_ulogic_vector(0 to  4)     0011 0    master rank 1 =a6
      cfg_xlt_s0_bit_map             =>  MCB_TLXR_xlt_s0_bit_map,                 --   : IN   std_ulogic_vector(0 to  4)    111 11
      cfg_xlt_s1_bit_map             =>  MCB_TLXR_xlt_s1_bit_map,                 --   : IN   std_ulogic_vector(0 to  4)    11 111
      cfg_xlt_s2_bit_map             =>  MCB_TLXR_xlt_s2_bit_map,                 --   : IN   std_ulogic_vector(0 to  4)    1 1111    37FFF
      cfg_xlt_r17_bit_map            =>  MCB_TLXR_xlt_r17_bit_map,                --   : IN   std_ulogic_vector(0 to  2)    111
      cfg_xlt_r16_bit_map            =>  MCB_TLXR_xlt_r16_bit_map,                --   : IN   std_ulogic_vector(0 to  2)    1 11
      cfg_xlt_r15_bit_map            =>  MCB_TLXR_xlt_r15_bit_map,                --   : IN   std_ulogic_vector(0 to  2)    11 1
      cfg_xlt_c3_bit_map             =>  MCB_TLXR_xlt_c3_bit_map,                 --   : IN   std_ulogic_vector(0 to  4)     001 11 col4 = a27 = oc12
      cfg_xlt_c4_bit_map             =>  MCB_TLXR_xlt_c4_bit_map,                 --   : IN   std_ulogic_vector(0 to  4)     001 11 col4 = a27 = oc12
      cfg_xlt_c5_bit_map             =>  MCB_TLXR_xlt_c5_bit_map,                 --   : IN   std_ulogic_vector(0 to  4)     00 111 col5 = a26 = oc13
      cfg_xlt_c6_bit_map             =>  MCB_TLXR_xlt_c6_bit_map,                 --   : IN   std_ulogic_vector(0 to  4)     0 0111 col6 = a25 = oc14   ff9ce7
      cfg_xlt_c7_bit_map             =>  MCB_TLXR_xlt_c7_bit_map,                 --   : IN   std_ulogic_vector(0 to  4)     0011 1 col7 = a24 = oc15
      cfg_xlt_c8_bit_map             =>  MCB_TLXR_xlt_c8_bit_map,                 --   : IN   std_ulogic_vector(0 to  4)     001 11 col8 = a23 =oc16
      cfg_xlt_c9_bit_map             =>  MCB_TLXR_xlt_c9_bit_map,                 --   : IN   std_ulogic_vector(0 to  4)     00 111 col9 = a7 = oc32
      cfg_xlt_b0_bit_map             =>  MCB_TLXR_xlt_b0_bit_map,                 --   : IN   std_ulogic_vector(0 to  4)      0 0101 bank0 = 29 10      39ce5
      cfg_xlt_b1_bit_map             =>  MCB_TLXR_xlt_b1_bit_map,                 --   : IN   std_ulogic_vector(0 to  4)      0010 1 bank1 = 30 = oc 9
      cfg_xlt_bg0_bit_map            =>  MCB_TLXR_xlt_bg0_bit_map,                --   : IN   std_ulogic_vector(0 to  4)      000 11 bg0= 31 = oc 8
      cfg_xlt_bg1_bit_map            =>  MCB_TLXR_xlt_bg1_bit_map,                --   : IN   std_ulogic_vector(0 to  4)      00 010 bg1= 32 = oc7
      enable_row_addr_hash           =>  mcb_tlxr_enab_row_addr_hash,             --   : IN   std_ulogic
-- outputs                                                                        --
      fast_decode                    =>  fast_decode_d,                            -- output from cb_tlxr_xlat
      dimm                           =>  fast_xlat_dimm,
      addr_error                     =>  fast_xlat_error,
      mrank                          =>  fast_xlat_addr(4 to 5),            --   : OUT  std_ulogic_vector(0 to 1)
      srank                          =>  fast_xlat_addr(6 to 8),            --   : OUT  std_ulogic_vector(0 to 2)
      bank                           =>  fast_xlat_addr(2 to 3),            --   : OUT  std_ulogic_vector(0 to 1)
      bank_group                     =>  fast_xlat_addr(0 to 1),            --   : OUT  std_ulogic_vector(0 to 1)
      row                            =>  fast_xlat_addr(9 to 26)            --   : OUT  std_ulogic_vector(0 to 17)
);

XLAT_FAST_a: entity work.cb_tlxr_xlat
 GENERIC MAP( fast => true)
 PORT MAP(
      vdd                            =>  vdd,                                     --   : inout power_logic
      gnd                            =>  gnd,                                     --   : inout power_logic
      addr                           =>  fifo_xlat_info_a(0 TO 34),                   --   : IN   std_ulogic_vector(34 downto 0)
      addr4                          =>  '0',                                       --   : IN   std_ulogic
--    fast                           => '1',                                      --   set to 1 for reduced (faster) translate
      HALF_DIMM_MODE                 => HALF_DIMM_MODE,
      cfg_xlt_slot0_valid            =>  MCB_TLXR_xlt_slot0_valid,
      cfg_xlt_slot1_valid            =>  MCB_TLXR_xlt_slot1_valid,
      cfg_xlt_slot0_d_value          =>  MCB_TLXR_xlt_slot0_d_value,
      cfg_xlt_slot1_d_value          =>  MCB_TLXR_xlt_slot1_d_value,
      cfg_xlt_slot0_m0_valid         =>  MCB_TLXR_xlt_slot0_m0_valid,             --   : IN   std_ulogic    1
      cfg_xlt_slot0_m1_valid         =>  MCB_TLXR_xlt_slot0_m1_valid,             --   : IN   std_ulogic    1
      cfg_xlt_slot0_s0_valid         =>  MCB_TLXR_xlt_slot0_s0_valid,             --   : IN   std_ulogic    0
      cfg_xlt_slot0_s1_valid         =>  MCB_TLXR_xlt_slot0_s1_valid,             --   : IN   std_ulogic    0
      cfg_xlt_slot0_s2_valid         =>  MCB_TLXR_xlt_slot0_s2_valid,             --   : IN   std_ulogic    0
      cfg_xlt_slot0_r15_valid        =>  MCB_TLXR_xlt_slot0_r15_valid,            --   : IN   std_ulogic    0
      cfg_xlt_slot0_r16_valid        =>  MCB_TLXR_xlt_slot0_r16_valid,            --   : IN   std_ulogic    0         0
      cfg_xlt_slot0_r17_valid        =>  MCB_TLXR_xlt_slot0_r17_valid,            --   : IN   std_ulogic    0
      cfg_xlt_slot1_m0_valid         =>  MCB_TLXR_xlt_slot1_m0_valid,
      cfg_xlt_slot1_m1_valid         =>  MCB_TLXR_xlt_slot1_m1_valid,
      cfg_xlt_slot1_s0_valid         =>  MCB_TLXR_xlt_slot1_s0_valid,
      cfg_xlt_slot1_s1_valid         =>  MCB_TLXR_xlt_slot1_s1_valid,
      cfg_xlt_slot1_s2_valid         =>  MCB_TLXR_xlt_slot1_s2_valid,
      cfg_xlt_slot1_r15_valid        =>  MCB_TLXR_xlt_slot1_r15_valid,
      cfg_xlt_slot1_r16_valid        =>  MCB_TLXR_xlt_slot1_r16_valid,
      cfg_xlt_slot1_r17_valid        =>  MCB_TLXR_xlt_slot1_r17_valid,
      cfg_xlt_d_bit_map              =>  MCB_TLXR_xlt_d_bit_map,
      cfg_xlt_m0_bit_map             =>  MCB_TLXR_xlt_m0_bit_map,                 --   : IN   std_ulogic_vector(0 to  2)    111       37
      cfg_xlt_m1_bit_map             =>  MCB_TLXR_xlt_m1_bit_map,                 --   : IN   std_ulogic_vector(0 to  4)     0011 0    master rank 1 =a6
      cfg_xlt_s0_bit_map             =>  MCB_TLXR_xlt_s0_bit_map,                 --   : IN   std_ulogic_vector(0 to  4)    111 11
      cfg_xlt_s1_bit_map             =>  MCB_TLXR_xlt_s1_bit_map,                 --   : IN   std_ulogic_vector(0 to  4)    11 111
      cfg_xlt_s2_bit_map             =>  MCB_TLXR_xlt_s2_bit_map,                 --   : IN   std_ulogic_vector(0 to  4)    1 1111    37FFF
      cfg_xlt_r17_bit_map            =>  MCB_TLXR_xlt_r17_bit_map,                --   : IN   std_ulogic_vector(0 to  2)    111
      cfg_xlt_r16_bit_map            =>  MCB_TLXR_xlt_r16_bit_map,                --   : IN   std_ulogic_vector(0 to  2)    1 11
      cfg_xlt_r15_bit_map            =>  MCB_TLXR_xlt_r15_bit_map,                --   : IN   std_ulogic_vector(0 to  2)    11 1
      cfg_xlt_c3_bit_map             =>  MCB_TLXR_xlt_c3_bit_map,                 --   : IN   std_ulogic_vector(0 to  4)     001 11 col4 = a27 = oc12
      cfg_xlt_c4_bit_map             =>  MCB_TLXR_xlt_c4_bit_map,                 --   : IN   std_ulogic_vector(0 to  4)     001 11 col4 = a27 = oc12
      cfg_xlt_c5_bit_map             =>  MCB_TLXR_xlt_c5_bit_map,                 --   : IN   std_ulogic_vector(0 to  4)     00 111 col5 = a26 = oc13
      cfg_xlt_c6_bit_map             =>  MCB_TLXR_xlt_c6_bit_map,                 --   : IN   std_ulogic_vector(0 to  4)     0 0111 col6 = a25 = oc14   ff9ce7
      cfg_xlt_c7_bit_map             =>  MCB_TLXR_xlt_c7_bit_map,                 --   : IN   std_ulogic_vector(0 to  4)     0011 1 col7 = a24 = oc15
      cfg_xlt_c8_bit_map             =>  MCB_TLXR_xlt_c8_bit_map,                 --   : IN   std_ulogic_vector(0 to  4)     001 11 col8 = a23 =oc16
      cfg_xlt_c9_bit_map             =>  MCB_TLXR_xlt_c9_bit_map,                 --   : IN   std_ulogic_vector(0 to  4)     00 111 col9 = a7 = oc32
      cfg_xlt_b0_bit_map             =>  MCB_TLXR_xlt_b0_bit_map,                 --   : IN   std_ulogic_vector(0 to  4)      0 0101 bank0 = 29 10      39ce5
      cfg_xlt_b1_bit_map             =>  MCB_TLXR_xlt_b1_bit_map,                 --   : IN   std_ulogic_vector(0 to  4)      0010 1 bank1 = 30 = oc 9
      cfg_xlt_bg0_bit_map            =>  MCB_TLXR_xlt_bg0_bit_map,                --   : IN   std_ulogic_vector(0 to  4)      000 11 bg0= 31 = oc 8
      cfg_xlt_bg1_bit_map            =>  MCB_TLXR_xlt_bg1_bit_map,                --   : IN   std_ulogic_vector(0 to  4)      00 010 bg1= 32 = oc7
      enable_row_addr_hash           =>  mcb_tlxr_enab_row_addr_hash,             --   : IN   std_ulogic
-- outputs                                                                        --
--      fast_decode                    =>  fast_decode_a_d,                            -- output from cb_tlxr_xlat
      dimm                           =>  fast_xlat_dimm_a,
--      addr_error                     =>  fast_xlat_error,
      mrank                          =>  fast_xlat_addr_a(4 to 5),            --   : OUT  std_ulogic_vector(0 to 1)
      srank                          =>  fast_xlat_addr_a(6 to 8),            --   : OUT  std_ulogic_vector(0 to 2)
      bank                           =>  fast_xlat_addr_a(2 to 3),            --   : OUT  std_ulogic_vector(0 to 1)
      bank_group                     =>  fast_xlat_addr_a(0 to 1),            --   : OUT  std_ulogic_vector(0 to 1)
      row                            =>  fast_xlat_addr_a(9 to 26)            --   : OUT  std_ulogic_vector(0 to 17)
);

XLAT_FAST_b: entity work.cb_tlxr_xlat
 GENERIC MAP( fast => true)
 PORT MAP(
      vdd                            =>  vdd,                                     --   : inout power_logic
      gnd                            =>  gnd,                                     --   : inout power_logic
      addr                           =>  fifo_xlat_info_b(0 TO 34),                   --   : IN   std_ulogic_vector(34 downto 0)
      addr4                          =>  '0',                                       --   : IN   std_ulogic
--    fast                           => '1',                                      --   set to 1 for reduced (faster) translate
      HALF_DIMM_MODE                 => HALF_DIMM_MODE,
      cfg_xlt_slot0_valid            =>  MCB_TLXR_xlt_slot0_valid,
      cfg_xlt_slot1_valid            =>  MCB_TLXR_xlt_slot1_valid,
      cfg_xlt_slot0_d_value          =>  MCB_TLXR_xlt_slot0_d_value,
      cfg_xlt_slot1_d_value          =>  MCB_TLXR_xlt_slot1_d_value,
      cfg_xlt_slot0_m0_valid         =>  MCB_TLXR_xlt_slot0_m0_valid,             --   : IN   std_ulogic    1
      cfg_xlt_slot0_m1_valid         =>  MCB_TLXR_xlt_slot0_m1_valid,             --   : IN   std_ulogic    1
      cfg_xlt_slot0_s0_valid         =>  MCB_TLXR_xlt_slot0_s0_valid,             --   : IN   std_ulogic    0
      cfg_xlt_slot0_s1_valid         =>  MCB_TLXR_xlt_slot0_s1_valid,             --   : IN   std_ulogic    0
      cfg_xlt_slot0_s2_valid         =>  MCB_TLXR_xlt_slot0_s2_valid,             --   : IN   std_ulogic    0
      cfg_xlt_slot0_r15_valid        =>  MCB_TLXR_xlt_slot0_r15_valid,            --   : IN   std_ulogic    0
      cfg_xlt_slot0_r16_valid        =>  MCB_TLXR_xlt_slot0_r16_valid,            --   : IN   std_ulogic    0         0
      cfg_xlt_slot0_r17_valid        =>  MCB_TLXR_xlt_slot0_r17_valid,            --   : IN   std_ulogic    0
      cfg_xlt_slot1_m0_valid         =>  MCB_TLXR_xlt_slot1_m0_valid,
      cfg_xlt_slot1_m1_valid         =>  MCB_TLXR_xlt_slot1_m1_valid,
      cfg_xlt_slot1_s0_valid         =>  MCB_TLXR_xlt_slot1_s0_valid,
      cfg_xlt_slot1_s1_valid         =>  MCB_TLXR_xlt_slot1_s1_valid,
      cfg_xlt_slot1_s2_valid         =>  MCB_TLXR_xlt_slot1_s2_valid,
      cfg_xlt_slot1_r15_valid        =>  MCB_TLXR_xlt_slot1_r15_valid,
      cfg_xlt_slot1_r16_valid        =>  MCB_TLXR_xlt_slot1_r16_valid,
      cfg_xlt_slot1_r17_valid        =>  MCB_TLXR_xlt_slot1_r17_valid,
      cfg_xlt_d_bit_map              =>  MCB_TLXR_xlt_d_bit_map,
      cfg_xlt_m0_bit_map             =>  MCB_TLXR_xlt_m0_bit_map,                 --   : IN   std_ulogic_vector(0 to  2)    111       37
      cfg_xlt_m1_bit_map             =>  MCB_TLXR_xlt_m1_bit_map,                 --   : IN   std_ulogic_vector(0 to  4)     0011 0    master rank 1 =a6
      cfg_xlt_s0_bit_map             =>  MCB_TLXR_xlt_s0_bit_map,                 --   : IN   std_ulogic_vector(0 to  4)    111 11
      cfg_xlt_s1_bit_map             =>  MCB_TLXR_xlt_s1_bit_map,                 --   : IN   std_ulogic_vector(0 to  4)    11 111
      cfg_xlt_s2_bit_map             =>  MCB_TLXR_xlt_s2_bit_map,                 --   : IN   std_ulogic_vector(0 to  4)    1 1111    37FFF
      cfg_xlt_r17_bit_map            =>  MCB_TLXR_xlt_r17_bit_map,                --   : IN   std_ulogic_vector(0 to  2)    111
      cfg_xlt_r16_bit_map            =>  MCB_TLXR_xlt_r16_bit_map,                --   : IN   std_ulogic_vector(0 to  2)    1 11
      cfg_xlt_r15_bit_map            =>  MCB_TLXR_xlt_r15_bit_map,                --   : IN   std_ulogic_vector(0 to  2)    11 1
      cfg_xlt_c3_bit_map             =>  MCB_TLXR_xlt_c3_bit_map,                 --   : IN   std_ulogic_vector(0 to  4)     001 11 col4 = a27 = oc12
      cfg_xlt_c4_bit_map             =>  MCB_TLXR_xlt_c4_bit_map,                 --   : IN   std_ulogic_vector(0 to  4)     001 11 col4 = a27 = oc12
      cfg_xlt_c5_bit_map             =>  MCB_TLXR_xlt_c5_bit_map,                 --   : IN   std_ulogic_vector(0 to  4)     00 111 col5 = a26 = oc13
      cfg_xlt_c6_bit_map             =>  MCB_TLXR_xlt_c6_bit_map,                 --   : IN   std_ulogic_vector(0 to  4)     0 0111 col6 = a25 = oc14   ff9ce7
      cfg_xlt_c7_bit_map             =>  MCB_TLXR_xlt_c7_bit_map,                 --   : IN   std_ulogic_vector(0 to  4)     0011 1 col7 = a24 = oc15
      cfg_xlt_c8_bit_map             =>  MCB_TLXR_xlt_c8_bit_map,                 --   : IN   std_ulogic_vector(0 to  4)     001 11 col8 = a23 =oc16
      cfg_xlt_c9_bit_map             =>  MCB_TLXR_xlt_c9_bit_map,                 --   : IN   std_ulogic_vector(0 to  4)     00 111 col9 = a7 = oc32
      cfg_xlt_b0_bit_map             =>  MCB_TLXR_xlt_b0_bit_map,                 --   : IN   std_ulogic_vector(0 to  4)      0 0101 bank0 = 29 10      39ce5
      cfg_xlt_b1_bit_map             =>  MCB_TLXR_xlt_b1_bit_map,                 --   : IN   std_ulogic_vector(0 to  4)      0010 1 bank1 = 30 = oc 9
      cfg_xlt_bg0_bit_map            =>  MCB_TLXR_xlt_bg0_bit_map,                --   : IN   std_ulogic_vector(0 to  4)      000 11 bg0= 31 = oc 8
      cfg_xlt_bg1_bit_map            =>  MCB_TLXR_xlt_bg1_bit_map,                --   : IN   std_ulogic_vector(0 to  4)      00 010 bg1= 32 = oc7
      enable_row_addr_hash           =>  mcb_tlxr_enab_row_addr_hash,             --   : IN   std_ulogic
-- outputs                                                                        --
--      fast_decode                    =>  fast_decode_b_d,                            -- output from cb_tlxr_xlat
      dimm                           =>  fast_xlat_dimm_b,
--      addr_error                     =>  fast_xlat_error,
      mrank                          =>  fast_xlat_addr_b(4 to 5),            --   : OUT  std_ulogic_vector(0 to 1)
      srank                          =>  fast_xlat_addr_b(6 to 8),            --   : OUT  std_ulogic_vector(0 to 2)
      bank                           =>  fast_xlat_addr_b(2 to 3),            --   : OUT  std_ulogic_vector(0 to 1)
      bank_group                     =>  fast_xlat_addr_b(0 to 1),            --   : OUT  std_ulogic_vector(0 to 1)
      row                            =>  fast_xlat_addr_b(9 to 26)            --   : OUT  std_ulogic_vector(0 to 17)
);


  --tlxr/srq
    tlxr_srq_fast_act_fifo_val           <= fifo_xlat_val;
    tlxr_srq_fast_act_fifo_addr          <= fast_xlat_addr(0 TO 26);
    tlxr_srq_fast_act_fifo_dimm          <= fast_xlat_dimm;
    tlxr_srq_fast_act_fifo_row_bank_par  <= xor_reduce(fast_xlat_addr(0 to 3) & fast_xlat_addr(9 to 26));
    tlxr_srq_fast_act_fifo_rank_par      <= xor_reduce(fast_xlat_dimm & fast_xlat_addr(4 to 8));

    tlxr_srq_fast_act_fifo_val_a           <= fifo_xlat_val_a;
    tlxr_srq_fast_act_fifo_addr_a          <= fast_xlat_addr_a(0 TO 26);
    tlxr_srq_fast_act_fifo_dimm_a          <= fast_xlat_dimm_a;
    tlxr_srq_fast_act_fifo_row_bank_par_a  <= xor_reduce(fast_xlat_addr_a(0 to 3) & fast_xlat_addr_a(9 to 26));
    tlxr_srq_fast_act_fifo_rank_par_a      <= xor_reduce(fast_xlat_dimm & fast_xlat_addr_a(4 to 8));

    tlxr_srq_fast_act_fifo_val_b           <= fifo_xlat_val_b;
    tlxr_srq_fast_act_fifo_addr_b          <= fast_xlat_addr_b(0 TO 26);
    tlxr_srq_fast_act_fifo_dimm_b          <= fast_xlat_dimm_b;
    tlxr_srq_fast_act_fifo_row_bank_par_b  <= xor_reduce(fast_xlat_addr_b(0 to 3) & fast_xlat_addr_b(9 to 26));
    tlxr_srq_fast_act_fifo_rank_par_b      <= xor_reduce(fast_xlat_dimm & fast_xlat_addr_b(4 to 8));

fast_decodeq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(fast_decode_d),
           syncr                => syncr,
           Tconv(q)             => fast_decode_q);

end architecture;
