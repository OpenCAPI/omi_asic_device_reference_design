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


--   bit        CAPI_address
--  BG1         5,7,9,11
--  BG0 6,8,10,12
--  BK1 7,9,11,13
--  BK0 8,10,12,14
--  DIMM        39-32,11
--  MRANK(0)  39-33     # only present if mrank(1) is
--  MRANK(1)  39-32,11
--  SRANK(0)  39-34     # only present if srank(1:2) are
--  SRANK(1)  39-33     # only present if srank(2) is
--  SRANK(2)  39-32,11
--  ROW(15)  39-32
--  ROW(16)  39-33              # only present if row(15) is
--  ROW(17)  39-34              # only present if row(15:16) are
--
--
--

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
    USE support.design_util_functions_pkg.all;
--@!@! LIB END

--******************************************************************************
-- 2.0  : entity definitions (with attributes)
--******************************************************************************


  ENTITY cb_tlxr_xlat IS
    generic (
    fast                           : boolean := true
    );
    PORT
  -----------------------------------------------------------------------------
  -- clock control
  -----------------------------------------------------------------------------
  ( vdd                            : inout power_logic
  ; gnd                            : inout power_logic
  -----------------------------------------------------------------------------
  -- inputs
  -----------------------------------------------------------------------------
  ; addr                           : in std_ulogic_vector(34 downto 0)
  ; addr4                          : in std_ulogic

  ; HALF_DIMM_MODE                 : in std_ulogic

  -- slot valids
  ; cfg_xlt_slot0_valid            : in std_ulogic                    -- mbxlt0q_q(0)             x
  ; cfg_xlt_slot1_valid            : in std_ulogic                    -- mbxlt0q_q(16)            x
  ; cfg_xlt_slot0_d_value          : in std_ulogic                    -- mbxlt0q_q(1)             x
  ; cfg_xlt_slot1_d_value          : in std_ulogic                    -- mbxlt0q_q(17)            x
                                                                   --
  -- slot0 per bit valids                                          --
  ; cfg_xlt_slot0_m0_valid         : in std_ulogic                    -- mbxlt0q_q(5)             x
  ; cfg_xlt_slot0_m1_valid         : in std_ulogic                    -- mbxlt0q_q(6)             x
  ; cfg_xlt_slot0_s0_valid         : in std_ulogic                    -- mbxlt0q_q(9)             x
  ; cfg_xlt_slot0_s1_valid         : in std_ulogic                    -- mbxlt0q_q(10)            x
  ; cfg_xlt_slot0_s2_valid         : in std_ulogic                    -- mbxlt0q_q(11)            x
  ; cfg_xlt_slot0_r15_valid        : in std_ulogic                    -- mbxlt0q_q(13);           x
  ; cfg_xlt_slot0_r16_valid        : in std_ulogic                    -- mbxlt0q_q(14)            x
  ; cfg_xlt_slot0_r17_valid        : in std_ulogic                    -- mbxlt0q_q(15);           x
                                                                   --
  -- slot1 per bit valids                                          --
  ; cfg_xlt_slot1_m0_valid         : in std_ulogic                    -- mbxlt0q_q(21)            x
  ; cfg_xlt_slot1_m1_valid         : in std_ulogic                    -- mbxlt0q_q(22)            x
  ; cfg_xlt_slot1_s0_valid         : in std_ulogic                    -- mbxlt0q_q(25);           x
  ; cfg_xlt_slot1_s1_valid         : in std_ulogic                    -- mbxlt0q_q(26);           x
  ; cfg_xlt_slot1_s2_valid         : in std_ulogic                    -- mbxlt0q_q(27);           x
  ; cfg_xlt_slot1_r15_valid        : in std_ulogic                    -- mbxlt0q_q(29);           x
  ; cfg_xlt_slot1_r16_valid        : in std_ulogic                    -- mbxlt0q_q(30);           x
  ; cfg_xlt_slot1_r17_valid        : in std_ulogic                    -- mbxlt0q_q(31);           x

  -- xlate bit map assignments
  ; cfg_xlt_d_bit_map              : in std_ulogic_vector(0 to 4)     -- mbxlt0q_q(33 to 37)
  ; cfg_xlt_m0_bit_map             : in std_ulogic_vector(0 to 4)     -- mbxlt0q_q(38 to 42)
  ; cfg_xlt_m1_bit_map             : in std_ulogic_vector(0 to 4)     -- mbxlt0q_q(43 to 47)
  ; cfg_xlt_s0_bit_map             : in std_ulogic_vector(0 to 4)     -- mbxlt1q_q(3 to 7)
  ; cfg_xlt_s1_bit_map             : in std_ulogic_vector(0 to 4)     -- mbxlt1q_q(11 to 15)
  ; cfg_xlt_s2_bit_map             : in std_ulogic_vector(0 to 4)     -- mbxlt1q_q(19 to 23)
  ; cfg_xlt_r17_bit_map            : in std_ulogic_vector(0 to 4)     -- mbxlt0q_q(49 to 53)
  ; cfg_xlt_r16_bit_map            : in std_ulogic_vector(0 to 4)     -- mbxlt0q_q(54 to 58)
  ; cfg_xlt_r15_bit_map            : in std_ulogic_vector(0 to 4)     -- mbxlt0q_q(59 to 63)
  ; cfg_xlt_c3_bit_map             : in std_ulogic_vector(0 to 4)     -- mbxlt1q_q(30 to 34)
  ; cfg_xlt_c4_bit_map             : in std_ulogic_vector(0 to 4)     -- mbxlt1q_q(35 to 39)
  ; cfg_xlt_c5_bit_map             : in std_ulogic_vector(0 to 4)     -- mbxlt1q_q(43 to 47)
  ; cfg_xlt_c6_bit_map             : in std_ulogic_vector(0 to 4)     -- mbxlt1q_q(51 to 55)
  ; cfg_xlt_c7_bit_map             : in std_ulogic_vector(0 to 4)     -- mbxlt1q_q(59 to 63)
  ; cfg_xlt_c8_bit_map             : in std_ulogic_vector(0 to 4)     -- mbxlt2q_q(3 to 7)
  ; cfg_xlt_c9_bit_map             : in std_ulogic_vector(0 to 4)     -- mbxlt2q_q(11 to 15)
  ; cfg_xlt_b0_bit_map             : in std_ulogic_vector(0 to 4)     -- mbxlt2q_q(19 to 23)
  ; cfg_xlt_b1_bit_map             : in std_ulogic_vector(0 to 4)     -- mbxlt2q_q(27 to 31)
  ; cfg_xlt_bg0_bit_map            : in std_ulogic_vector(0 to 4)     -- mbxlt2q_q(43 to 47)
  ; cfg_xlt_bg1_bit_map            : in std_ulogic_vector(0 to 4)     -- mbxlt2q_q(51 to 55)
  ; enable_row_addr_hash           : in std_ulogic                    -- mbxlt0q_q(32)
--; fast                        : in std_ulogic
  -----------------------------------------------------------------------------
  -- outputs
  -----------------------------------------------------------------------------
  ; dimm                           : out std_ulogic
  ; mrank                          : out std_ulogic_vector(0 to 1)
  ; srank                          : out std_ulogic_vector(0 to 2)
  ; bank                           : out std_ulogic_vector(0 to 1)
  ; bank_group                     : out std_ulogic_vector(0 to 1)
  ; row                            : out std_ulogic_vector(0 to 17)
  ; col                            : out std_ulogic_vector(2 to 9)

  ; addr_error                     : out std_ulogic
  ; fast_decode                    : out std_ulogic
  ; xlat_hole                      : out std_ulogic
  ; xlat_drop                      : out std_ulogic

  );

  ATTRIBUTE POWER_PIN                     OF VDD                      : SIGNAL  IS 1;
  ATTRIBUTE POWER_DOMAIN                  OF CB_TLXR_XLAT             : ENTITY  IS "vdd";
  ATTRIBUTE PIN_DEFAULT_POWER_DOMAIN      OF CB_TLXR_XLAT             : ENTITY  IS "VDD";
  ATTRIBUTE GROUND_PIN                    OF GND                      : SIGNAL  IS 1;
  ATTRIBUTE PIN_DEFAULT_GROUND_DOMAIN     OF CB_TLXR_XLAT             : ENTITY  IS "GND";
  ATTRIBUTE BTR_NAME                      OF CB_TLXR_XLAT             : ENTITY  IS "CB_TLXR_XLAT";
  ATTRIBUTE BLOCK_TYPE                    OF CB_TLXR_XLAT             : ENTITY  IS  LEAF;
  ATTRIBUTE RECURSIVE_SYNTHESIS           OF CB_TLXR_XLAT             : ENTITY  IS  2;

 END cb_tlxr_xlat;
--MR_B leaf
--MS_REC 2


--******************************************************************************
-- 3.0  : architecture definition
--******************************************************************************

 ARCHITECTURE cb_tlxr_xlat OF cb_tlxr_xlat IS


--@!@! SIGNAL START


-- Register signal declarations

-- Internal signal declarations
  SIGNAL dimm_comp_bit : std_ulogic;
  SIGNAL slot0_hit : std_ulogic;
  SIGNAL slot1_hit : std_ulogic;
  SIGNAL dimm_int : std_ulogic;
  SIGNAL m0_bit : std_ulogic;
  SIGNAL mrank_int : std_ulogic_vector(0 to 1);
  SIGNAL m1_bit : std_ulogic;
  SIGNAL s0_bit : std_ulogic;
  SIGNAL srank_int : std_ulogic_vector(0 to 2);
  SIGNAL s1_bit : std_ulogic;
  SIGNAL s2_bit : std_ulogic;
  SIGNAL bank_int : std_ulogic_vector(0 to 1);
  SIGNAL bank_group_int : std_ulogic_vector(0 to 1);
  SIGNAL col_int : std_ulogic_vector(2 to 9);
  SIGNAL row_int : std_ulogic_vector(0 to 17);
  SIGNAL r15_bit : std_ulogic;
  SIGNAL r16_bit : std_ulogic;
  SIGNAL r17_bit : std_ulogic;
  SIGNAL dimm_choice : std_ulogic_vector(8 downto 0);
  SIGNAL bg_row_hash : std_ulogic_vector(0 to 1);
  SIGNAL bk_row_hash : std_ulogic_vector(0 to 1);
  SIGNAL oc_addr : std_ulogic_vector(39 downto 5);
  SIGNAL oc_addr4 : std_ulogic;
  SIGNAL fast_act_decode : std_ulogic_vector(11 downto 0);
  SIGNAL low_addr_used : std_ulogic_vector(15 downto 6);
  SIGNAL xlate_usage_mask : std_ulogic_vector(39 downto 31);
  SIGNAL  both0_comp0,both0_comp1,both1_comp0,both1_comp1 : std_ulogic;
BEGIN

     oc_addr <= ADDR;  -- (39 downto 5) <=  (34 downto 0)
     oc_addr4 <= ADDR4;

---------
-- dimm
---------
dimm_choice(8) <= (cfg_xlt_d_bit_map="00110");
dimm_choice(7) <= (cfg_xlt_d_bit_map="01100");
dimm_choice(6) <= (cfg_xlt_d_bit_map="01101");
dimm_choice(5) <= (cfg_xlt_d_bit_map="01110");
dimm_choice(4) <= (cfg_xlt_d_bit_map="01111");
dimm_choice(3) <= (cfg_xlt_d_bit_map="10000");
dimm_choice(2) <= (cfg_xlt_d_bit_map="10001");
dimm_choice(1) <= (cfg_xlt_d_bit_map="10010");
dimm_choice(0) <= (cfg_xlt_d_bit_map="10011");

fast_act_decode(0) <= OR_REDUCE(dimm_choice);

dcf_gen: if fast = true generate
dimm_comp_bit <=      (oc_addr(11) AND dimm_choice(8))
              OR      (oc_addr(32) AND dimm_choice(7))
              OR      (oc_addr(33) AND dimm_choice(6))
              OR      (oc_addr(34) AND dimm_choice(5))
              OR      (oc_addr(35) AND dimm_choice(4))
              OR      (oc_addr(36) AND dimm_choice(3))
              OR      (oc_addr(37) AND dimm_choice(2))
              OR      (oc_addr(38) AND dimm_choice(1))
              OR      (oc_addr(39) AND dimm_choice(0));
end generate dcf_gen;

dcs_gen: if fast = false generate
dimm_comp_bit <=      (oc_addr(11) AND dimm_choice(8))
              OR      (oc_addr(32) AND dimm_choice(7))
              OR      (oc_addr(33) AND dimm_choice(6))
              OR      (oc_addr(34) AND dimm_choice(5))
              OR      (oc_addr(35) AND dimm_choice(4))
              OR      (oc_addr(36) AND dimm_choice(3))
              OR      (oc_addr(37) AND dimm_choice(2))
              OR      (oc_addr(38) AND dimm_choice(1))
              OR      (oc_addr(39) AND dimm_choice(0))
              OR      (oc_addr( 5) AND cfg_xlt_d_bit_map="00000")
              OR      (oc_addr( 6) AND cfg_xlt_d_bit_map="00001")
              OR      (oc_addr( 7) AND cfg_xlt_d_bit_map="00010")
              OR      (oc_addr( 8) AND cfg_xlt_d_bit_map="00011")
              OR      (oc_addr( 9) AND cfg_xlt_d_bit_map="00100")
              OR      (oc_addr(10) AND cfg_xlt_d_bit_map="00101")
              OR      (oc_addr(12) AND cfg_xlt_d_bit_map="00111")
              OR      (oc_addr(13) AND cfg_xlt_d_bit_map="01000")
              OR      (oc_addr(14) AND cfg_xlt_d_bit_map="01001")
              OR      (oc_addr(15) AND cfg_xlt_d_bit_map="01010")
              OR      (oc_addr(31) AND cfg_xlt_d_bit_map="01011");
end generate dcs_gen;


slot0_hit     <=     cfg_xlt_slot0_valid AND ((dimm_comp_bit=cfg_xlt_slot0_d_value) or not cfg_xlt_slot1_valid);

slot1_hit    <= (    dimm_comp_bit and (    cfg_xlt_slot1_d_value or not cfg_xlt_slot0_valid) and cfg_xlt_slot1_valid ) or
                (not dimm_comp_bit and (not cfg_xlt_slot1_d_value or not cfg_xlt_slot0_valid) and cfg_xlt_slot1_valid );
--

-- we detect zero or two slots detected in a timing friendly way and dispense with the redundant "valid" terms
--  addr_error    <=      not (slot0_hit XOR slot1_hit)
--                OR      (slot0_hit AND NOT cfg_xlt_slot0_valid)
--                OR      (slot1_hit AND NOT cfg_xlt_slot1_valid);


--                          A                        B                  C                          D
-- slot0_hit     <=      cfg_xlt_slot0_valid AND ((dimm_comp_bit=cfg_xlt_slot0_d_value) or not cfg_xlt_slot1_valid);
-- slot1_hit    <= (    dimm_comp_bit and (    cfg_xlt_slot1_d_value or not cfg_xlt_slot0_valid) and cfg_xlt_slot1_valid ) or
--              (not dimm_comp_bit and (not cfg_xlt_slot1_d_value or not cfg_xlt_slot0_valid) and cfg_xlt_slot1_valid );
--                        B                          E                             A                      D
--
--                A and ( B=C) or not D)
--

--     both1_comp1 <=   (    A  and (    C or not D))   and     ((    E or not A) and D );
    both1_comp1 <=  ( cfg_xlt_slot0_valid and ( cfg_xlt_slot0_d_value or not cfg_xlt_slot1_valid)) and ((  cfg_xlt_slot1_d_value or not cfg_xlt_slot0_valid) and cfg_xlt_slot1_valid );
    both1_comp0 <=  ( cfg_xlt_slot0_valid and (not cfg_xlt_slot0_d_value or not cfg_xlt_slot1_valid)) and ((not cfg_xlt_slot1_d_value or not cfg_xlt_slot0_valid) and cfg_xlt_slot1_valid );

    both0_comp1 <=  (not cfg_xlt_slot0_valid  or  (not cfg_xlt_slot0_d_value and cfg_xlt_slot1_valid)) and ((not cfg_xlt_slot1_d_value and cfg_xlt_slot0_valid) or not cfg_xlt_slot1_valid);
    both0_comp0 <=  (not cfg_xlt_slot0_valid  or  (    cfg_xlt_slot0_d_value and cfg_xlt_slot1_valid)) and ((    cfg_xlt_slot1_d_value and cfg_xlt_slot0_valid) or not cfg_xlt_slot1_valid);

    addr_error  <=  (    dimm_comp_bit and (both1_comp1 or both0_comp1 ))  or
                    (not dimm_comp_bit and (both1_comp0 or both0_comp0 ));

dimm_int      <=      slot1_hit;

  -- s0 valid   s1 valid  s0 hit  s1 hit               dimm
  --   0           0         0       0                  0
  --   0           0         0       1          e
  --   0           0         1       0          e
  --   0           0         1       1          e
  --   0           1         0       0                  n/a
  --   0           1         0       1
  --   0           1         1       0          e
  --   0           1         1       1          e
  --   1           0         0       0                 n/a
  --   1           0         0       1          e
  --   1           0         1       0
  --   1           0         1       1          e
  --   1           1         0       0
  --   1           1         0       1
  --   1           1         1       0
  --   1           1         1       1          e
---------
-- mrank 0
---------
m0f_gen: if fast = true generate

  m0_bit        <=      (oc_addr(33) AND cfg_xlt_m0_bit_map="01101")
                OR      (oc_addr(34) AND cfg_xlt_m0_bit_map="01110")
                OR      (oc_addr(35) AND cfg_xlt_m0_bit_map="01111")
                OR      (oc_addr(36) AND cfg_xlt_m0_bit_map="10000")
                OR      (oc_addr(37) AND cfg_xlt_m0_bit_map="10001")
                OR      (oc_addr(38) AND cfg_xlt_m0_bit_map="10010")
                OR      (oc_addr(39) AND cfg_xlt_m0_bit_map="10011");
end generate m0f_gen;

m0s_gen: if fast = false generate
  m0_bit        <=      (oc_addr(33) AND cfg_xlt_m0_bit_map="01101")
                OR      (oc_addr(34) AND cfg_xlt_m0_bit_map="01110")
                OR      (oc_addr(35) AND cfg_xlt_m0_bit_map="01111")
                OR      (oc_addr(36) AND cfg_xlt_m0_bit_map="10000")
                OR      (oc_addr(37) AND cfg_xlt_m0_bit_map="10001")
                OR      (oc_addr(38) AND cfg_xlt_m0_bit_map="10010")
                OR      (oc_addr(39) AND cfg_xlt_m0_bit_map="10011")
                OR      (oc_addr( 5) AND cfg_xlt_m0_bit_map="00000")
                OR      (oc_addr( 6) AND cfg_xlt_m0_bit_map="00001")
                OR      (oc_addr( 7) AND cfg_xlt_m0_bit_map="00010")
                OR      (oc_addr( 8) AND cfg_xlt_m0_bit_map="00011")
                OR      (oc_addr( 9) AND cfg_xlt_m0_bit_map="00100")
                OR      (oc_addr(10) AND cfg_xlt_m0_bit_map="00101")
                OR      (oc_addr(11) AND cfg_xlt_m0_bit_map="00110")
                OR      (oc_addr(12) AND cfg_xlt_m0_bit_map="00111")
                OR      (oc_addr(13) AND cfg_xlt_m0_bit_map="01000")
                OR      (oc_addr(14) AND cfg_xlt_m0_bit_map="01001")
                OR      (oc_addr(15) AND cfg_xlt_m0_bit_map="01010")
                OR      (oc_addr(31) AND cfg_xlt_m0_bit_map="01011")
                OR      (oc_addr(32) AND cfg_xlt_m0_bit_map="01100") ;
end generate m0s_gen;

fast_act_decode(1) <= (cfg_xlt_m0_bit_map="01101")  or
                      (cfg_xlt_m0_bit_map="01110")  or
                      (cfg_xlt_m0_bit_map="01111")  or
                      (cfg_xlt_m0_bit_map="10000")  or
                      (cfg_xlt_m0_bit_map="10001")  or
                      (cfg_xlt_m0_bit_map="10010")  or
                      (cfg_xlt_m0_bit_map="10011")  or
                      (not cfg_xlt_slot0_m0_valid and not cfg_xlt_slot1_m0_valid);

  mrank_int(0)  <=      m0_bit AND ((cfg_xlt_slot0_m0_valid AND slot0_hit) OR (cfg_xlt_slot1_m0_valid AND slot1_hit));

-- mrank1
m1f_gen: if fast = true generate

  m1_bit        <=      (oc_addr(11) AND cfg_xlt_m1_bit_map="00110")
                OR      (oc_addr(32) AND cfg_xlt_m1_bit_map="01100")
                OR      (oc_addr(33) AND cfg_xlt_m1_bit_map="01101")
                OR      (oc_addr(34) AND cfg_xlt_m1_bit_map="01110")
                OR      (oc_addr(35) AND cfg_xlt_m1_bit_map="01111")
                OR      (oc_addr(36) AND cfg_xlt_m1_bit_map="10000")
                OR      (oc_addr(37) AND cfg_xlt_m1_bit_map="10001")
                OR      (oc_addr(38) AND cfg_xlt_m1_bit_map="10010")
                OR      (oc_addr(39) AND cfg_xlt_m1_bit_map="10011");
end generate m1f_gen;

m1s_gen: if fast = false generate
  m1_bit        <=      (oc_addr(11) AND cfg_xlt_m1_bit_map="00110")
                OR      (oc_addr(32) AND cfg_xlt_m1_bit_map="01100")
                OR      (oc_addr(33) AND cfg_xlt_m1_bit_map="01101")
                OR      (oc_addr(34) AND cfg_xlt_m1_bit_map="01110")
                OR      (oc_addr(35) AND cfg_xlt_m1_bit_map="01111")
                OR      (oc_addr(36) AND cfg_xlt_m1_bit_map="10000")
                OR      (oc_addr(37) AND cfg_xlt_m1_bit_map="10001")
                OR      (oc_addr(38) AND cfg_xlt_m1_bit_map="10010")
                OR      (oc_addr(39) AND cfg_xlt_m1_bit_map="10011")
                OR      (oc_addr( 5) AND cfg_xlt_m1_bit_map="00000")
                OR      (oc_addr( 6) AND cfg_xlt_m1_bit_map="00001")
                OR      (oc_addr( 7) AND cfg_xlt_m1_bit_map="00010")
                OR      (oc_addr( 8) AND cfg_xlt_m1_bit_map="00011")
                OR      (oc_addr( 9) AND cfg_xlt_m1_bit_map="00100")
                OR      (oc_addr(10) AND cfg_xlt_m1_bit_map="00101")
                OR      (oc_addr(12) AND cfg_xlt_m1_bit_map="00111")
                OR      (oc_addr(13) AND cfg_xlt_m1_bit_map="01000")
                OR      (oc_addr(14) AND cfg_xlt_m1_bit_map="01001")
                OR      (oc_addr(15) AND cfg_xlt_m1_bit_map="01010")
                OR      (oc_addr(31) AND cfg_xlt_m1_bit_map="01011");
end generate m1s_gen;


fast_act_decode(2) <= (cfg_xlt_m1_bit_map="00110") or
                      (cfg_xlt_m1_bit_map="01100") or
                      (cfg_xlt_m1_bit_map="01101") or
                      (cfg_xlt_m1_bit_map="01110") or
                      (cfg_xlt_m1_bit_map="01111") or
                      (cfg_xlt_m1_bit_map="10000") or
                      (cfg_xlt_m1_bit_map="10001") or
                      (cfg_xlt_m1_bit_map="10010") or
                      (cfg_xlt_m1_bit_map="10011") or
                      (not cfg_xlt_slot0_m1_valid and not cfg_xlt_slot1_m1_valid);

  mrank_int(1)  <=      m1_bit AND ((cfg_xlt_slot0_m1_valid AND slot0_hit) OR (cfg_xlt_slot1_m1_valid AND slot1_hit));

---------
-- srank
---------

-- srank0

s0f_gen: if fast = true generate
  s0_bit        <=      (oc_addr(34) AND cfg_xlt_s0_bit_map="01110")
                OR      (oc_addr(35) AND cfg_xlt_s0_bit_map="01111")
                OR      (oc_addr(36) AND cfg_xlt_s0_bit_map="10000")
                OR      (oc_addr(37) AND cfg_xlt_s0_bit_map="10001")
                OR      (oc_addr(38) AND cfg_xlt_s0_bit_map="10010")
                OR      (oc_addr(39) AND cfg_xlt_s0_bit_map="10011");

end generate s0f_gen;
s0s_gen: if fast = false generate
  s0_bit        <=      (oc_addr(34) AND cfg_xlt_s0_bit_map="01110")
                OR      (oc_addr(35) AND cfg_xlt_s0_bit_map="01111")
                OR      (oc_addr(36) AND cfg_xlt_s0_bit_map="10000")
                OR      (oc_addr(37) AND cfg_xlt_s0_bit_map="10001")
                OR      (oc_addr(38) AND cfg_xlt_s0_bit_map="10010")
                OR      (oc_addr(39) AND cfg_xlt_s0_bit_map="10011")
                OR      (oc_addr( 5) AND cfg_xlt_s0_bit_map="00000")
                OR      (oc_addr( 6) AND cfg_xlt_s0_bit_map="00001")
                OR      (oc_addr( 7) AND cfg_xlt_s0_bit_map="00010")
                OR      (oc_addr( 8) AND cfg_xlt_s0_bit_map="00011")
                OR      (oc_addr( 9) AND cfg_xlt_s0_bit_map="00100")
                OR      (oc_addr(10) AND cfg_xlt_s0_bit_map="00101")
                OR      (oc_addr(11) AND cfg_xlt_s0_bit_map="00110")
                OR      (oc_addr(12) AND cfg_xlt_s0_bit_map="00111")
                OR      (oc_addr(13) AND cfg_xlt_s0_bit_map="01000")
                OR      (oc_addr(14) AND cfg_xlt_s0_bit_map="01001")
                OR      (oc_addr(15) AND cfg_xlt_s0_bit_map="01010")
                OR      (oc_addr(31) AND cfg_xlt_s0_bit_map="01011")
                OR      (oc_addr(32) AND cfg_xlt_s0_bit_map="01100")
                OR      (oc_addr(33) AND cfg_xlt_s0_bit_map="01101");
end generate s0s_gen;

fast_act_decode(3)  <=  (cfg_xlt_s0_bit_map="01110") or
                        (cfg_xlt_s0_bit_map="01111") or
                        (cfg_xlt_s0_bit_map="10000") or
                        (cfg_xlt_s0_bit_map="10001") or
                        (cfg_xlt_s0_bit_map="10010") or
                        (cfg_xlt_s0_bit_map="10011") or
                        (not cfg_xlt_slot0_s0_valid and not cfg_xlt_slot1_s0_valid );

  srank_int(0)  <=      s0_bit AND ((cfg_xlt_slot0_s0_valid AND slot0_hit) OR (cfg_xlt_slot1_s0_valid AND slot1_hit));

-- srank1

s1f_gen: if fast = true generate
  s1_bit        <=      (oc_addr(33) AND cfg_xlt_s1_bit_map="01101")
                OR      (oc_addr(34) AND cfg_xlt_s1_bit_map="01110")
                OR      (oc_addr(35) AND cfg_xlt_s1_bit_map="01111")
                OR      (oc_addr(36) AND cfg_xlt_s1_bit_map="10000")
                OR      (oc_addr(37) AND cfg_xlt_s1_bit_map="10001")
                OR      (oc_addr(38) AND cfg_xlt_s1_bit_map="10010")
                OR      (oc_addr(39) AND cfg_xlt_s1_bit_map="10011");
end generate s1f_gen;

s1s_gen: if fast = false generate
  s1_bit        <=      (oc_addr(33) AND cfg_xlt_s1_bit_map="01101")
                OR      (oc_addr(34) AND cfg_xlt_s1_bit_map="01110")
                OR      (oc_addr(35) AND cfg_xlt_s1_bit_map="01111")
                OR      (oc_addr(36) AND cfg_xlt_s1_bit_map="10000")
                OR      (oc_addr(37) AND cfg_xlt_s1_bit_map="10001")
                OR      (oc_addr(38) AND cfg_xlt_s1_bit_map="10010")
                OR      (oc_addr(39) AND cfg_xlt_s1_bit_map="10011")
                OR      (oc_addr( 5) AND cfg_xlt_s1_bit_map="00000")
                OR      (oc_addr( 6) AND cfg_xlt_s1_bit_map="00001")
                OR      (oc_addr( 7) AND cfg_xlt_s1_bit_map="00010")
                OR      (oc_addr( 8) AND cfg_xlt_s1_bit_map="00011")
                OR      (oc_addr( 9) AND cfg_xlt_s1_bit_map="00100")
                OR      (oc_addr(10) AND cfg_xlt_s1_bit_map="00101")
                OR      (oc_addr(11) AND cfg_xlt_s1_bit_map="00110")
                OR      (oc_addr(12) AND cfg_xlt_s1_bit_map="00111")
                OR      (oc_addr(13) AND cfg_xlt_s1_bit_map="01000")
                OR      (oc_addr(14) AND cfg_xlt_s1_bit_map="01001")
                OR      (oc_addr(15) AND cfg_xlt_s1_bit_map="01010")
                OR      (oc_addr(31) AND cfg_xlt_s1_bit_map="01011")
                OR      (oc_addr(32) AND cfg_xlt_s1_bit_map="01100");
end generate s1s_gen;

    fast_act_decode(4)  <= (cfg_xlt_s1_bit_map="01101") or
                           (cfg_xlt_s1_bit_map="01110") or
                           (cfg_xlt_s1_bit_map="01111") or
                           (cfg_xlt_s1_bit_map="10000") or
                           (cfg_xlt_s1_bit_map="10001") or
                           (cfg_xlt_s1_bit_map="10010") or
                           (cfg_xlt_s1_bit_map="10011") or
                           (not cfg_xlt_slot0_s1_valid and not cfg_xlt_slot1_s1_valid);

    srank_int(1)  <=      s1_bit AND ((cfg_xlt_slot0_s1_valid AND slot0_hit) OR (cfg_xlt_slot1_s1_valid AND slot1_hit));

s2f_gen: if fast = true generate
  s2_bit        <=      (oc_addr(11) AND cfg_xlt_s2_bit_map="00110")
                OR      (oc_addr(32) AND cfg_xlt_s2_bit_map="01100")
                OR      (oc_addr(33) AND cfg_xlt_s2_bit_map="01101")
                OR      (oc_addr(34) AND cfg_xlt_s2_bit_map="01110")
                OR      (oc_addr(35) AND cfg_xlt_s2_bit_map="01111")
                OR      (oc_addr(36) AND cfg_xlt_s2_bit_map="10000")
                OR      (oc_addr(37) AND cfg_xlt_s2_bit_map="10001")
                OR      (oc_addr(38) AND cfg_xlt_s2_bit_map="10010")
                OR      (oc_addr(39) AND cfg_xlt_s2_bit_map="10011");
end generate s2f_gen;

s2s_gen: if fast = false generate
  s2_bit        <=      (oc_addr(11) AND cfg_xlt_s2_bit_map="00110")
                OR      (oc_addr(32) AND cfg_xlt_s2_bit_map="01100")
                OR      (oc_addr(33) AND cfg_xlt_s2_bit_map="01101")
                OR      (oc_addr(34) AND cfg_xlt_s2_bit_map="01110")
                OR      (oc_addr(35) AND cfg_xlt_s2_bit_map="01111")
                OR      (oc_addr(36) AND cfg_xlt_s2_bit_map="10000")
                OR      (oc_addr(37) AND cfg_xlt_s2_bit_map="10001")
                OR      (oc_addr(38) AND cfg_xlt_s2_bit_map="10010")
                OR      (oc_addr(39) AND cfg_xlt_s2_bit_map="10011")
                OR      (oc_addr( 5) AND cfg_xlt_s2_bit_map="00000")
                OR      (oc_addr( 6) AND cfg_xlt_s2_bit_map="00001")
                OR      (oc_addr( 7) AND cfg_xlt_s2_bit_map="00010")
                OR      (oc_addr( 8) AND cfg_xlt_s2_bit_map="00011")
                OR      (oc_addr( 9) AND cfg_xlt_s2_bit_map="00100")
                OR      (oc_addr(10) AND cfg_xlt_s2_bit_map="00101")
                OR      (oc_addr(12) AND cfg_xlt_s2_bit_map="00111")
                OR      (oc_addr(13) AND cfg_xlt_s2_bit_map="01000")
                OR      (oc_addr(14) AND cfg_xlt_s2_bit_map="01001")
                OR      (oc_addr(15) AND cfg_xlt_s2_bit_map="01010")
                OR      (oc_addr(31) AND cfg_xlt_s2_bit_map="01011");
end generate s2s_gen;

    fast_act_decode(5)  <= (cfg_xlt_s2_bit_map="00110") or
                           (cfg_xlt_s2_bit_map="01100") or
                           (cfg_xlt_s2_bit_map="01101") or
                           (cfg_xlt_s2_bit_map="01110") or
                           (cfg_xlt_s2_bit_map="01111") or
                           (cfg_xlt_s2_bit_map="10000") or
                           (cfg_xlt_s2_bit_map="10001") or
                           (cfg_xlt_s2_bit_map="10010") or
                           (cfg_xlt_s2_bit_map="10011") or
                           (not cfg_xlt_slot0_s2_valid and not cfg_xlt_slot1_s2_valid);

   srank_int(2)  <=      s2_bit AND ((cfg_xlt_slot0_s2_valid AND slot0_hit) OR (cfg_xlt_slot1_s2_valid AND slot1_hit));

---------
-- bank
---------

-- bank 0

b0f_gen: if fast = true generate
 bank_int(0)    <=      (oc_addr( 8) AND cfg_xlt_b0_bit_map="00011")
                OR      (oc_addr(10) AND cfg_xlt_b0_bit_map="00101")
                OR      (oc_addr(12) AND cfg_xlt_b0_bit_map="00111")
                OR      (oc_addr(14) AND cfg_xlt_b0_bit_map="01001");
end generate b0f_gen;

b0s_gen: if fast = false generate
 bank_int(0)    <=      (oc_addr( 8) AND cfg_xlt_b0_bit_map="00011")
                OR      (oc_addr(10) AND cfg_xlt_b0_bit_map="00101")
                OR      (oc_addr(12) AND cfg_xlt_b0_bit_map="00111")
                OR      (oc_addr(14) AND cfg_xlt_b0_bit_map="01001")
                OR      (oc_addr( 5) AND cfg_xlt_b0_bit_map="00000")
                OR      (oc_addr( 6) AND cfg_xlt_b0_bit_map="00001")
                OR      (oc_addr( 7) AND cfg_xlt_b0_bit_map="00010")
                OR      (oc_addr( 9) AND cfg_xlt_b0_bit_map="00100")
                OR      (oc_addr(11) AND cfg_xlt_b0_bit_map="00110")
                OR      (oc_addr(13) AND cfg_xlt_b0_bit_map="01000")
                OR      (oc_addr(15) AND cfg_xlt_b0_bit_map="01010")
                OR      (oc_addr(31) AND cfg_xlt_b0_bit_map="01011")
                OR      (oc_addr(32) AND cfg_xlt_b0_bit_map="01100")
                OR      (oc_addr(33) AND cfg_xlt_b0_bit_map="01101")
                OR      (oc_addr(34) AND cfg_xlt_b0_bit_map="01110")
                OR      (oc_addr(35) AND cfg_xlt_b0_bit_map="01111")
                OR      (oc_addr(36) AND cfg_xlt_b0_bit_map="10000")
                OR      (oc_addr(37) AND cfg_xlt_b0_bit_map="10001")
                OR      (oc_addr(38) AND cfg_xlt_b0_bit_map="10010")
                OR      (oc_addr(39) AND cfg_xlt_b0_bit_map="10011");
end generate b0s_gen;

    fast_act_decode(6)  <= (cfg_xlt_b0_bit_map="00011") or
                           (cfg_xlt_b0_bit_map="00101") or
                           (cfg_xlt_b0_bit_map="00111") or
                           (cfg_xlt_b0_bit_map="01001");

b1f_gen: if fast = true generate
 bank_int(1)    <=      (oc_addr( 7) AND cfg_xlt_b1_bit_map="00010")
                OR      (oc_addr( 9) AND cfg_xlt_b1_bit_map="00100")
                OR      (oc_addr(11) AND cfg_xlt_b1_bit_map="00110")
                OR      (oc_addr(13) AND cfg_xlt_b1_bit_map="01000");
end generate b1f_gen;

b1s_gen: if fast = false generate
 bank_int(1)    <=      (oc_addr( 7) AND cfg_xlt_b1_bit_map="00010")
                OR      (oc_addr( 9) AND cfg_xlt_b1_bit_map="00100")
                OR      (oc_addr(11) AND cfg_xlt_b1_bit_map="00110")
                OR      (oc_addr(13) AND cfg_xlt_b1_bit_map="01000")
                OR      (oc_addr( 5) AND cfg_xlt_b1_bit_map="00000")
                OR      (oc_addr( 6) AND cfg_xlt_b1_bit_map="00001")
                OR      (oc_addr( 8) AND cfg_xlt_b1_bit_map="00011")
                OR      (oc_addr(10) AND cfg_xlt_b1_bit_map="00101")
                OR      (oc_addr(12) AND cfg_xlt_b1_bit_map="00111")
                OR      (oc_addr(14) AND cfg_xlt_b1_bit_map="01001")
                OR      (oc_addr(15) AND cfg_xlt_b1_bit_map="01010")
                OR      (oc_addr(31) AND cfg_xlt_b1_bit_map="01011")
                OR      (oc_addr(32) AND cfg_xlt_b1_bit_map="01100")
                OR      (oc_addr(33) AND cfg_xlt_b1_bit_map="01101")
                OR      (oc_addr(34) AND cfg_xlt_b1_bit_map="01110")
                OR      (oc_addr(35) AND cfg_xlt_b1_bit_map="01111")
                OR      (oc_addr(36) AND cfg_xlt_b1_bit_map="10000")
                OR      (oc_addr(37) AND cfg_xlt_b1_bit_map="10001")
                OR      (oc_addr(38) AND cfg_xlt_b1_bit_map="10010")
                OR      (oc_addr(39) AND cfg_xlt_b1_bit_map="10011");
end generate b1s_gen;

-- bank group 0

bg0f_gen: if fast = true  generate
 bank_group_int(0)  <=  (oc_addr( 6) AND cfg_xlt_bg0_bit_map="00001")
                OR      (oc_addr( 8) AND cfg_xlt_bg0_bit_map="00011")
                OR      (oc_addr(10) AND cfg_xlt_bg0_bit_map="00101")
                OR      (oc_addr(12) AND cfg_xlt_bg0_bit_map="00111");
end generate bg0f_gen;

bg0s_gen: if fast = false generate
 bank_group_int(0)  <=  (oc_addr( 6) AND cfg_xlt_bg0_bit_map="00001")
                OR      (oc_addr( 8) AND cfg_xlt_bg0_bit_map="00011")
                OR      (oc_addr(10) AND cfg_xlt_bg0_bit_map="00101")
                OR      (oc_addr(12) AND cfg_xlt_bg0_bit_map="00111")
                OR      (oc_addr( 5) AND cfg_xlt_bg0_bit_map="00000")
                OR      (oc_addr( 7) AND cfg_xlt_bg0_bit_map="00010")
                OR      (oc_addr( 9) AND cfg_xlt_bg0_bit_map="00100")
                OR      (oc_addr(11) AND cfg_xlt_bg0_bit_map="00110")
                OR      (oc_addr(13) AND cfg_xlt_bg0_bit_map="01000")
                OR      (oc_addr(14) AND cfg_xlt_bg0_bit_map="01001")
                OR      (oc_addr(15) AND cfg_xlt_bg0_bit_map="01010")
                OR      (oc_addr(31) AND cfg_xlt_bg0_bit_map="01011")
                OR      (oc_addr(32) AND cfg_xlt_bg0_bit_map="01100")
                OR      (oc_addr(33) AND cfg_xlt_bg0_bit_map="01101")
                OR      (oc_addr(34) AND cfg_xlt_bg0_bit_map="01110")
                OR      (oc_addr(35) AND cfg_xlt_bg0_bit_map="01111")
                OR      (oc_addr(36) AND cfg_xlt_bg0_bit_map="10000")
                OR      (oc_addr(37) AND cfg_xlt_bg0_bit_map="10001")
                OR      (oc_addr(38) AND cfg_xlt_bg0_bit_map="10010")
                OR      (oc_addr(39) AND cfg_xlt_bg0_bit_map="10011");
end generate bg0s_gen;

    fast_act_decode(7) <= (cfg_xlt_bg0_bit_map="00001") or
                          (cfg_xlt_bg0_bit_map="00011") or
                          (cfg_xlt_bg0_bit_map="00101") or
                          (cfg_xlt_bg0_bit_map="00111");


-- bank group 1

bg1f_gen: if fast = true generate
 bank_group_int(1)  <=  (oc_addr( 5) AND cfg_xlt_bg1_bit_map="00000")
                OR      (oc_addr( 7) AND cfg_xlt_bg1_bit_map="00010")
                OR      (oc_addr( 9) AND cfg_xlt_bg1_bit_map="00100")
                OR      (oc_addr(11) AND cfg_xlt_bg1_bit_map="00110");
end generate bg1f_gen;
--
bg1s_gen: if fast = false generate
 bank_group_int(1)  <=  (oc_addr( 5) AND cfg_xlt_bg1_bit_map="00000")
                OR      (oc_addr( 7) AND cfg_xlt_bg1_bit_map="00010")
                OR      (oc_addr( 9) AND cfg_xlt_bg1_bit_map="00100")
                OR      (oc_addr(11) AND cfg_xlt_bg1_bit_map="00110")
                OR      (oc_addr( 6) AND cfg_xlt_bg1_bit_map="00001")
                OR      (oc_addr( 8) AND cfg_xlt_bg1_bit_map="00011")
                OR      (oc_addr(10) AND cfg_xlt_bg1_bit_map="00101")
                OR      (oc_addr(12) AND cfg_xlt_bg1_bit_map="00111")
                OR      (oc_addr(13) AND cfg_xlt_bg1_bit_map="01000")
                OR      (oc_addr(14) AND cfg_xlt_bg1_bit_map="01001")
                OR      (oc_addr(15) AND cfg_xlt_bg1_bit_map="01010")
                OR      (oc_addr(31) AND cfg_xlt_bg1_bit_map="01011")
                OR      (oc_addr(32) AND cfg_xlt_bg1_bit_map="01100")
                OR      (oc_addr(33) AND cfg_xlt_bg1_bit_map="01101")
                OR      (oc_addr(34) AND cfg_xlt_bg1_bit_map="01110")
                OR      (oc_addr(35) AND cfg_xlt_bg1_bit_map="01111")
                OR      (oc_addr(36) AND cfg_xlt_bg1_bit_map="10000")
                OR      (oc_addr(37) AND cfg_xlt_bg1_bit_map="10001")
                OR      (oc_addr(38) AND cfg_xlt_bg1_bit_map="10010")
                OR      (oc_addr(39) AND cfg_xlt_bg1_bit_map="10011");
end generate bg1s_gen;

    fast_act_decode(8) <= (cfg_xlt_bg1_bit_map="00000") or
                          (cfg_xlt_bg1_bit_map="00010") or
                          (cfg_xlt_bg1_bit_map="00100") or
                          (cfg_xlt_bg1_bit_map="00110");

---------
-- col    !!!!  BITS ARE LS downto MS !!!
---------

fast_col2_gen: if fast = true generate
 col_int(2)     <=    oc_addr(5);
end generate fast_col2_gen;

slow_col2_gen: if fast = false generate
 col_int(2)     <=      (oc_addr(5) AND    NOT HALF_DIMM_MODE)
                OR      (oc_addr4   AND        HALF_DIMM_MODE);
end generate slow_col2_gen;

 col_int(3)     <=      (oc_addr( 5) AND (cfg_xlt_c3_bit_map="00000"))
                OR      (oc_addr( 6) AND (cfg_xlt_c3_bit_map="00001"))
                OR      (oc_addr( 7) AND (cfg_xlt_c3_bit_map="00010"))
                OR      (oc_addr( 8) AND (cfg_xlt_c3_bit_map="00011"))
                OR      (oc_addr( 9) AND (cfg_xlt_c3_bit_map="00100"))
                OR      (oc_addr(10) AND (cfg_xlt_c3_bit_map="00101"))
                OR      (oc_addr(11) AND (cfg_xlt_c3_bit_map="00110"))
                OR      (oc_addr(12) AND (cfg_xlt_c3_bit_map="00111"))
                OR      (oc_addr(13) AND (cfg_xlt_c3_bit_map="01000"))
                OR      (oc_addr(14) AND (cfg_xlt_c3_bit_map="01001"))
                OR      (oc_addr(15) AND (cfg_xlt_c3_bit_map="01010"))
                OR      (oc_addr(31) AND (cfg_xlt_c3_bit_map="01011"))
                OR      (oc_addr(32) AND (cfg_xlt_c3_bit_map="01100"))
                OR      (oc_addr(33) AND (cfg_xlt_c3_bit_map="01101"))
                OR      (oc_addr(34) AND (cfg_xlt_c3_bit_map="01110"))
                OR      (oc_addr(35) AND (cfg_xlt_c3_bit_map="01111"))
                OR      (oc_addr(36) AND (cfg_xlt_c3_bit_map="10000"))
                OR      (oc_addr(37) AND (cfg_xlt_c3_bit_map="10001"))
                OR      (oc_addr(38) AND (cfg_xlt_c3_bit_map="10010"))
                OR      (oc_addr(39) AND (cfg_xlt_c3_bit_map="10011"));

 col_int(4)     <=      (oc_addr( 5) AND (cfg_xlt_c4_bit_map="00000"))
                OR      (oc_addr( 6) AND (cfg_xlt_c4_bit_map="00001"))
                OR      (oc_addr( 7) AND (cfg_xlt_c4_bit_map="00010"))
                OR      (oc_addr( 8) AND (cfg_xlt_c4_bit_map="00011"))
                OR      (oc_addr( 9) AND (cfg_xlt_c4_bit_map="00100"))
                OR      (oc_addr(10) AND (cfg_xlt_c4_bit_map="00101"))
                OR      (oc_addr(11) AND (cfg_xlt_c4_bit_map="00110"))
                OR      (oc_addr(12) AND (cfg_xlt_c4_bit_map="00111"))
                OR      (oc_addr(13) AND (cfg_xlt_c4_bit_map="01000"))
                OR      (oc_addr(14) AND (cfg_xlt_c4_bit_map="01001"))
                OR      (oc_addr(15) AND (cfg_xlt_c4_bit_map="01010"))
                OR      (oc_addr(31) AND (cfg_xlt_c4_bit_map="01011"))
                OR      (oc_addr(32) AND (cfg_xlt_c4_bit_map="01100"))
                OR      (oc_addr(33) AND (cfg_xlt_c4_bit_map="01101"))
                OR      (oc_addr(34) AND (cfg_xlt_c4_bit_map="01110"))
                OR      (oc_addr(35) AND (cfg_xlt_c4_bit_map="01111"))
                OR      (oc_addr(36) AND (cfg_xlt_c4_bit_map="10000"))
                OR      (oc_addr(37) AND (cfg_xlt_c4_bit_map="10001"))
                OR      (oc_addr(38) AND (cfg_xlt_c4_bit_map="10010"))
                OR      (oc_addr(39) AND (cfg_xlt_c4_bit_map="10011"));

 col_int(5)     <=      (oc_addr( 5) AND (cfg_xlt_c5_bit_map="00000"))
                OR      (oc_addr( 6) AND (cfg_xlt_c5_bit_map="00001"))
                OR      (oc_addr( 7) AND (cfg_xlt_c5_bit_map="00010"))
                OR      (oc_addr( 8) AND (cfg_xlt_c5_bit_map="00011"))
                OR      (oc_addr( 9) AND (cfg_xlt_c5_bit_map="00100"))
                OR      (oc_addr(10) AND (cfg_xlt_c5_bit_map="00101"))
                OR      (oc_addr(11) AND (cfg_xlt_c5_bit_map="00110"))
                OR      (oc_addr(12) AND (cfg_xlt_c5_bit_map="00111"))
                OR      (oc_addr(13) AND (cfg_xlt_c5_bit_map="01000"))
                OR      (oc_addr(14) AND (cfg_xlt_c5_bit_map="01001"))
                OR      (oc_addr(15) AND (cfg_xlt_c5_bit_map="01010"))
                OR      (oc_addr(31) AND (cfg_xlt_c5_bit_map="01011"))
                OR      (oc_addr(32) AND (cfg_xlt_c5_bit_map="01100"))
                OR      (oc_addr(33) AND (cfg_xlt_c5_bit_map="01101"))
                OR      (oc_addr(34) AND (cfg_xlt_c5_bit_map="01110"))
                OR      (oc_addr(35) AND (cfg_xlt_c5_bit_map="01111"))
                OR      (oc_addr(36) AND (cfg_xlt_c5_bit_map="10000"))
                OR      (oc_addr(37) AND (cfg_xlt_c5_bit_map="10001"))
                OR      (oc_addr(38) AND (cfg_xlt_c5_bit_map="10010"))
                OR      (oc_addr(39) AND (cfg_xlt_c5_bit_map="10011"));

 col_int(6)     <=      (oc_addr( 5) AND (cfg_xlt_c6_bit_map="00000"))
                OR      (oc_addr( 6) AND (cfg_xlt_c6_bit_map="00001"))
                OR      (oc_addr( 7) AND (cfg_xlt_c6_bit_map="00010"))
                OR      (oc_addr( 8) AND (cfg_xlt_c6_bit_map="00011"))
                OR      (oc_addr( 9) AND (cfg_xlt_c6_bit_map="00100"))
                OR      (oc_addr(10) AND (cfg_xlt_c6_bit_map="00101"))
                OR      (oc_addr(11) AND (cfg_xlt_c6_bit_map="00110"))
                OR      (oc_addr(12) AND (cfg_xlt_c6_bit_map="00111"))
                OR      (oc_addr(13) AND (cfg_xlt_c6_bit_map="01000"))
                OR      (oc_addr(14) AND (cfg_xlt_c6_bit_map="01001"))
                OR      (oc_addr(15) AND (cfg_xlt_c6_bit_map="01010"))
                OR      (oc_addr(31) AND (cfg_xlt_c6_bit_map="01011"))
                OR      (oc_addr(32) AND (cfg_xlt_c6_bit_map="01100"))
                OR      (oc_addr(33) AND (cfg_xlt_c6_bit_map="01101"))
                OR      (oc_addr(34) AND (cfg_xlt_c6_bit_map="01110"))
                OR      (oc_addr(35) AND (cfg_xlt_c6_bit_map="01111"))
                OR      (oc_addr(36) AND (cfg_xlt_c6_bit_map="10000"))
                OR      (oc_addr(37) AND (cfg_xlt_c6_bit_map="10001"))
                OR      (oc_addr(38) AND (cfg_xlt_c6_bit_map="10010"))
                OR      (oc_addr(39) AND (cfg_xlt_c6_bit_map="10011"));

 col_int(7)     <=      (oc_addr( 5) AND (cfg_xlt_c7_bit_map="00000"))
                OR      (oc_addr( 6) AND (cfg_xlt_c7_bit_map="00001"))
                OR      (oc_addr( 7) AND (cfg_xlt_c7_bit_map="00010"))
                OR      (oc_addr( 8) AND (cfg_xlt_c7_bit_map="00011"))
                OR      (oc_addr( 9) AND (cfg_xlt_c7_bit_map="00100"))
                OR      (oc_addr(10) AND (cfg_xlt_c7_bit_map="00101"))
                OR      (oc_addr(11) AND (cfg_xlt_c7_bit_map="00110"))
                OR      (oc_addr(12) AND (cfg_xlt_c7_bit_map="00111"))
                OR      (oc_addr(13) AND (cfg_xlt_c7_bit_map="01000"))
                OR      (oc_addr(14) AND (cfg_xlt_c7_bit_map="01001"))
                OR      (oc_addr(15) AND (cfg_xlt_c7_bit_map="01010"))
                OR      (oc_addr(31) AND (cfg_xlt_c7_bit_map="01011"))
                OR      (oc_addr(32) AND (cfg_xlt_c7_bit_map="01100"))
                OR      (oc_addr(33) AND (cfg_xlt_c7_bit_map="01101"))
                OR      (oc_addr(34) AND (cfg_xlt_c7_bit_map="01110"))
                OR      (oc_addr(35) AND (cfg_xlt_c7_bit_map="01111"))
                OR      (oc_addr(36) AND (cfg_xlt_c7_bit_map="10000"))
                OR      (oc_addr(37) AND (cfg_xlt_c7_bit_map="10001"))
                OR      (oc_addr(38) AND (cfg_xlt_c7_bit_map="10010"))
                OR      (oc_addr(39) AND (cfg_xlt_c7_bit_map="10011"));

 col_int(8)     <=      (oc_addr( 5) AND (cfg_xlt_c8_bit_map="00000"))
                OR      (oc_addr( 6) AND (cfg_xlt_c8_bit_map="00001"))
                OR      (oc_addr( 7) AND (cfg_xlt_c8_bit_map="00010"))
                OR      (oc_addr( 8) AND (cfg_xlt_c8_bit_map="00011"))
                OR      (oc_addr( 9) AND (cfg_xlt_c8_bit_map="00100"))
                OR      (oc_addr(10) AND (cfg_xlt_c8_bit_map="00101"))
                OR      (oc_addr(11) AND (cfg_xlt_c8_bit_map="00110"))
                OR      (oc_addr(12) AND (cfg_xlt_c8_bit_map="00111"))
                OR      (oc_addr(13) AND (cfg_xlt_c8_bit_map="01000"))
                OR      (oc_addr(14) AND (cfg_xlt_c8_bit_map="01001"))
                OR      (oc_addr(15) AND (cfg_xlt_c8_bit_map="01010"))
                OR      (oc_addr(31) AND (cfg_xlt_c8_bit_map="01011"))
                OR      (oc_addr(32) AND (cfg_xlt_c8_bit_map="01100"))
                OR      (oc_addr(33) AND (cfg_xlt_c8_bit_map="01101"))
                OR      (oc_addr(34) AND (cfg_xlt_c8_bit_map="01110"))
                OR      (oc_addr(35) AND (cfg_xlt_c8_bit_map="01111"))
                OR      (oc_addr(36) AND (cfg_xlt_c8_bit_map="10000"))
                OR      (oc_addr(37) AND (cfg_xlt_c8_bit_map="10001"))
                OR      (oc_addr(38) AND (cfg_xlt_c8_bit_map="10010"))
                OR      (oc_addr(39) AND (cfg_xlt_c8_bit_map="10011"));

 col_int(9)     <=      (oc_addr( 5) AND (cfg_xlt_c9_bit_map="00000"))
                OR      (oc_addr( 6) AND (cfg_xlt_c9_bit_map="00001"))
                OR      (oc_addr( 7) AND (cfg_xlt_c9_bit_map="00010"))
                OR      (oc_addr( 8) AND (cfg_xlt_c9_bit_map="00011"))
                OR      (oc_addr( 9) AND (cfg_xlt_c9_bit_map="00100"))
                OR      (oc_addr(10) AND (cfg_xlt_c9_bit_map="00101"))
                OR      (oc_addr(11) AND (cfg_xlt_c9_bit_map="00110"))
                OR      (oc_addr(12) AND (cfg_xlt_c9_bit_map="00111"))
                OR      (oc_addr(13) AND (cfg_xlt_c9_bit_map="01000"))
                OR      (oc_addr(14) AND (cfg_xlt_c9_bit_map="01001"))
                OR      (oc_addr(15) AND (cfg_xlt_c9_bit_map="01010"))
                OR      (oc_addr(31) AND (cfg_xlt_c9_bit_map="01011"))
                OR      (oc_addr(32) AND (cfg_xlt_c9_bit_map="01100"))
                OR      (oc_addr(33) AND (cfg_xlt_c9_bit_map="01101"))
                OR      (oc_addr(34) AND (cfg_xlt_c9_bit_map="01110"))
                OR      (oc_addr(35) AND (cfg_xlt_c9_bit_map="01111"))
                OR      (oc_addr(36) AND (cfg_xlt_c9_bit_map="10000"))
                OR      (oc_addr(37) AND (cfg_xlt_c9_bit_map="10001"))
                OR      (oc_addr(38) AND (cfg_xlt_c9_bit_map="10010"))
                OR      (oc_addr(39) AND (cfg_xlt_c9_bit_map="10011"));

---------
-- row 0 - 14
---------
 row_int( 0)    <=   oc_addr(16);
 row_int( 1)    <=   oc_addr(17);
 row_int( 2)    <=   oc_addr(18);
 row_int( 3)    <=   oc_addr(19);
 row_int( 4)    <=   oc_addr(20);
 row_int( 5)    <=   oc_addr(21);
 row_int( 6)    <=   oc_addr(22);
 row_int( 7)    <=   oc_addr(23);
 row_int( 8)    <=   oc_addr(24);
 row_int( 9)    <=   oc_addr(25);
 row_int(10)    <=   oc_addr(26);
 row_int(11)    <=   oc_addr(27);
 row_int(12)    <=   oc_addr(28);
 row_int(13)    <=   oc_addr(29);
 row_int(14)    <=   oc_addr(30);

r15f_gen: if fast = true generate
  r15_bit       <=      (oc_addr(32) AND cfg_xlt_r15_bit_map="01100")
                OR      (oc_addr(33) AND cfg_xlt_r15_bit_map="01101")
                OR      (oc_addr(34) AND cfg_xlt_r15_bit_map="01110")
                OR      (oc_addr(35) AND cfg_xlt_r15_bit_map="01111")
                OR      (oc_addr(36) AND cfg_xlt_r15_bit_map="10000")
                OR      (oc_addr(37) AND cfg_xlt_r15_bit_map="10001")
                OR      (oc_addr(38) AND cfg_xlt_r15_bit_map="10010")
                OR      (oc_addr(39) AND cfg_xlt_r15_bit_map="10011");
end generate r15f_gen;

r15s_gen: if fast = false generate
  r15_bit       <=      (oc_addr(32) AND cfg_xlt_r15_bit_map="01100")
                OR      (oc_addr(33) AND cfg_xlt_r15_bit_map="01101")
                OR      (oc_addr(34) AND cfg_xlt_r15_bit_map="01110")
                OR      (oc_addr(35) AND cfg_xlt_r15_bit_map="01111")
                OR      (oc_addr(36) AND cfg_xlt_r15_bit_map="10000")
                OR      (oc_addr(37) AND cfg_xlt_r15_bit_map="10001")
                OR      (oc_addr(38) AND cfg_xlt_r15_bit_map="10010")
                OR      (oc_addr(39) AND cfg_xlt_r15_bit_map="10011")
                OR      (oc_addr(31) AND cfg_xlt_r15_bit_map="01011");
end generate r15s_gen;

    fast_act_decode(9) <= (cfg_xlt_r15_bit_map="01100") or
                          (cfg_xlt_r15_bit_map="01101") or
                          (cfg_xlt_r15_bit_map="01110") or
                          (cfg_xlt_r15_bit_map="01111") or
                          (cfg_xlt_r15_bit_map="10000") or
                          (cfg_xlt_r15_bit_map="10001") or
                          (cfg_xlt_r15_bit_map="10010") or
                          (cfg_xlt_r15_bit_map="10011") or
                          (not cfg_xlt_slot0_r15_valid);

  row_int(15)   <=      r15_bit AND ((cfg_xlt_slot0_r15_valid AND slot0_hit) OR (cfg_xlt_slot1_r15_valid AND slot1_hit));

r16f_gen: if fast = true generate

  r16_bit       <=      (oc_addr(33) AND cfg_xlt_r16_bit_map="01101")
                OR      (oc_addr(34) AND cfg_xlt_r16_bit_map="01110")
                OR      (oc_addr(35) AND cfg_xlt_r16_bit_map="01111")
                OR      (oc_addr(36) AND cfg_xlt_r16_bit_map="10000")
                OR      (oc_addr(37) AND cfg_xlt_r16_bit_map="10001")
                OR      (oc_addr(38) AND cfg_xlt_r16_bit_map="10010")
                OR      (oc_addr(39) AND cfg_xlt_r16_bit_map="10011");
end generate r16f_gen;

r16s_gen: if fast = false generate
  r16_bit       <=      (oc_addr(33) AND cfg_xlt_r16_bit_map="01101")
                OR      (oc_addr(34) AND cfg_xlt_r16_bit_map="01110")
                OR      (oc_addr(35) AND cfg_xlt_r16_bit_map="01111")
                OR      (oc_addr(36) AND cfg_xlt_r16_bit_map="10000")
                OR      (oc_addr(37) AND cfg_xlt_r16_bit_map="10001")
                OR      (oc_addr(38) AND cfg_xlt_r16_bit_map="10010")
                OR      (oc_addr(39) AND cfg_xlt_r16_bit_map="10011")
                OR      (oc_addr(31) AND cfg_xlt_r16_bit_map="01011")
                OR      (oc_addr(32) AND cfg_xlt_r16_bit_map="01100");
end generate r16s_gen;

    fast_act_decode(10) <= (cfg_xlt_r16_bit_map="01101") or
                          (cfg_xlt_r16_bit_map="01110") or
                          (cfg_xlt_r16_bit_map="01111") or
                          (cfg_xlt_r16_bit_map="10000") or
                          (cfg_xlt_r16_bit_map="10001") or
                          (cfg_xlt_r16_bit_map="10010") or
                          (cfg_xlt_r16_bit_map="10011") or
                          (not cfg_xlt_slot0_r16_valid);

  row_int(16)   <=      r16_bit AND ((cfg_xlt_slot0_r16_valid AND slot0_hit) OR (cfg_xlt_slot1_r16_valid AND slot1_hit));

r17f_gen: if fast = true generate
  r17_bit       <=      (oc_addr(34) AND cfg_xlt_r17_bit_map="01110")
                OR      (oc_addr(35) AND cfg_xlt_r17_bit_map="01111")
                OR      (oc_addr(36) AND cfg_xlt_r17_bit_map="10000")
                OR      (oc_addr(37) AND cfg_xlt_r17_bit_map="10001")
                OR      (oc_addr(38) AND cfg_xlt_r17_bit_map="10010")
                OR      (oc_addr(39) AND cfg_xlt_r17_bit_map="10011");
end generate r17f_gen;

r17s_gen: if fast = false generate
  r17_bit       <=      (oc_addr(34) AND cfg_xlt_r17_bit_map="01110")
                OR      (oc_addr(35) AND cfg_xlt_r17_bit_map="01111")
                OR      (oc_addr(36) AND cfg_xlt_r17_bit_map="10000")
                OR      (oc_addr(37) AND cfg_xlt_r17_bit_map="10001")
                OR      (oc_addr(38) AND cfg_xlt_r17_bit_map="10010")
                OR      (oc_addr(39) AND cfg_xlt_r17_bit_map="10011")
                OR      (oc_addr(31) AND cfg_xlt_r17_bit_map="01011")
                OR      (oc_addr(32) AND cfg_xlt_r17_bit_map="01100")
                OR      (oc_addr(33) AND cfg_xlt_r17_bit_map="01101");
end generate r17s_gen;

    fast_act_decode(11) <= (cfg_xlt_r17_bit_map="01110") or
                           (cfg_xlt_r17_bit_map="01111") or
                           (cfg_xlt_r17_bit_map="10000") or
                           (cfg_xlt_r17_bit_map="10001") or
                           (cfg_xlt_r17_bit_map="10010") or
                           (cfg_xlt_r17_bit_map="10011") or
                           (not cfg_xlt_slot0_r17_valid);

  row_int(17)   <=      r17_bit AND ((cfg_xlt_slot0_r17_valid AND slot0_hit) OR (cfg_xlt_slot1_r17_valid AND slot1_hit));

        bg_row_hash(0) <= XOR_REDUCE(row_int(0) & row_int(4) & row_int(8) & row_int(12))  and enable_row_addr_hash;  -- bg0
        bg_row_hash(1) <= XOR_REDUCE(row_int(3) & row_int(7) & row_int(11) & row_int(13)) and enable_row_addr_hash;  -- bg1
        bk_row_hash(0) <= XOR_REDUCE(row_int(2) & row_int(6) & row_int(10))               and enable_row_addr_hash;  -- bk0
        bk_row_hash(1) <= XOR_REDUCE(row_int(1) & row_int(5) & row_int(9) & row_int(14))  and enable_row_addr_hash;  -- bk1

-- construct a usage vector for oversize checking
  xlate_usage_mask(39) <= dimm_choice(0) or (cfg_xlt_m0_bit_map="10011") or (cfg_xlt_m1_bit_map="10011") or
                          (cfg_xlt_s0_bit_map="10011")  or (cfg_xlt_s1_bit_map="10011") or (cfg_xlt_s2_bit_map="10011")  or
                          (cfg_xlt_b0_bit_map="10011")  or (cfg_xlt_b1_bit_map="10011") or (cfg_xlt_bg0_bit_map="10011") or
                          (cfg_xlt_bg1_bit_map="10011") or (cfg_xlt_c3_bit_map="10011") or (cfg_xlt_c4_bit_map="10011")  or
                          (cfg_xlt_c5_bit_map="10011")  or (cfg_xlt_c6_bit_map="10011") or (cfg_xlt_c7_bit_map="10011")  or
                          (cfg_xlt_c8_bit_map="10011")  or (cfg_xlt_c9_bit_map="10011") or (cfg_xlt_r15_bit_map="10011") or
                          (cfg_xlt_r16_bit_map="10011") or (cfg_xlt_r17_bit_map="10011");

  xlate_usage_mask(38) <= dimm_choice(1) or (cfg_xlt_m0_bit_map="10010") or (cfg_xlt_m1_bit_map="10010") or
                          (cfg_xlt_s0_bit_map="10010")  or (cfg_xlt_s1_bit_map="10010")  or (cfg_xlt_s2_bit_map="10010")  or
                          (cfg_xlt_b0_bit_map="10010")  or (cfg_xlt_b1_bit_map="10010")  or (cfg_xlt_bg0_bit_map="10010") or
                          (cfg_xlt_bg1_bit_map="10010") or (cfg_xlt_c3_bit_map="10010")  or (cfg_xlt_c4_bit_map="10010")  or
                          (cfg_xlt_c5_bit_map="10010")  or (cfg_xlt_c6_bit_map="10010")  or (cfg_xlt_c7_bit_map="10010")  or
                          (cfg_xlt_c8_bit_map="10010")  or (cfg_xlt_c9_bit_map="10010")  or (cfg_xlt_r15_bit_map="10010") or
                          (cfg_xlt_r16_bit_map="10010") or (cfg_xlt_r17_bit_map="10010");

  xlate_usage_mask(37) <= dimm_choice(2) or (cfg_xlt_m0_bit_map="10001") or (cfg_xlt_m1_bit_map="10001") or
                          (cfg_xlt_s0_bit_map="10001")  or (cfg_xlt_s1_bit_map="10001")  or (cfg_xlt_s2_bit_map="10001")  or
                          (cfg_xlt_b0_bit_map="10001")  or (cfg_xlt_b1_bit_map="10001")  or (cfg_xlt_bg0_bit_map="10001") or
                          (cfg_xlt_bg1_bit_map="10001") or (cfg_xlt_c3_bit_map="10001")  or (cfg_xlt_c4_bit_map="10001")  or
                          (cfg_xlt_c5_bit_map="10001")  or (cfg_xlt_c6_bit_map="10001")  or (cfg_xlt_c7_bit_map="10001")  or
                          (cfg_xlt_c8_bit_map="10001")  or (cfg_xlt_c9_bit_map="10001")  or (cfg_xlt_r15_bit_map="10001") or
                          (cfg_xlt_r16_bit_map="10001") or (cfg_xlt_r17_bit_map="10001");

  xlate_usage_mask(36) <= dimm_choice(3) or (cfg_xlt_m0_bit_map="10000") or (cfg_xlt_m1_bit_map="10000") or
                          (cfg_xlt_s0_bit_map="10000")  or (cfg_xlt_s1_bit_map="10000")  or (cfg_xlt_s2_bit_map="10000")  or
                          (cfg_xlt_b0_bit_map="10000")  or (cfg_xlt_b1_bit_map="10000")  or (cfg_xlt_bg0_bit_map="10000") or
                          (cfg_xlt_bg1_bit_map="10000") or (cfg_xlt_c3_bit_map="10000")  or (cfg_xlt_c4_bit_map="10000")  or
                          (cfg_xlt_c5_bit_map="10000")  or (cfg_xlt_c6_bit_map="10000")  or (cfg_xlt_c7_bit_map="10000")  or
                          (cfg_xlt_c8_bit_map="10000")  or (cfg_xlt_c9_bit_map="10000")  or (cfg_xlt_r15_bit_map="10000") or
                          (cfg_xlt_r16_bit_map="10000") or (cfg_xlt_r17_bit_map="10000");

  xlate_usage_mask(35) <= dimm_choice(4) or (cfg_xlt_m0_bit_map="01111") or (cfg_xlt_m1_bit_map="01111") or
                          (cfg_xlt_s0_bit_map="01111")  or (cfg_xlt_s1_bit_map="01111")  or (cfg_xlt_s2_bit_map="01111")  or
                          (cfg_xlt_b0_bit_map="01111")  or (cfg_xlt_b1_bit_map="01111")  or (cfg_xlt_bg0_bit_map="01111") or
                          (cfg_xlt_bg1_bit_map="01111") or (cfg_xlt_c3_bit_map="01111")  or (cfg_xlt_c4_bit_map="01111")  or
                          (cfg_xlt_c5_bit_map="01111")  or (cfg_xlt_c6_bit_map="01111")  or (cfg_xlt_c7_bit_map="01111")  or
                          (cfg_xlt_c8_bit_map="01111")  or (cfg_xlt_c9_bit_map="01111")  or (cfg_xlt_r15_bit_map="01111") or
                          (cfg_xlt_r16_bit_map="01111") or (cfg_xlt_r17_bit_map="01111");

  xlate_usage_mask(34) <= dimm_choice(5) or (cfg_xlt_m0_bit_map="01110") or (cfg_xlt_m1_bit_map="01110") or
                          (cfg_xlt_s0_bit_map="01110")  or (cfg_xlt_s1_bit_map="01110")  or (cfg_xlt_s2_bit_map="01110")  or
                          (cfg_xlt_b0_bit_map="01110")  or (cfg_xlt_b1_bit_map="01110")  or (cfg_xlt_bg0_bit_map="01110") or
                          (cfg_xlt_bg1_bit_map="01110") or (cfg_xlt_c3_bit_map="01110")  or (cfg_xlt_c4_bit_map="01110")  or
                          (cfg_xlt_c5_bit_map="01110")  or (cfg_xlt_c6_bit_map="01110")  or (cfg_xlt_c7_bit_map="01110")  or
                          (cfg_xlt_c8_bit_map="01110")  or (cfg_xlt_c9_bit_map="01110")  or (cfg_xlt_r15_bit_map="01110") or
                          (cfg_xlt_r16_bit_map="01110") or (cfg_xlt_r17_bit_map="01110");

  xlate_usage_mask(33) <= dimm_choice(6) or (cfg_xlt_m0_bit_map="01101") or (cfg_xlt_m1_bit_map="01101") or
                          (cfg_xlt_s0_bit_map="01101")  or (cfg_xlt_s1_bit_map="01101")  or (cfg_xlt_s2_bit_map="01101")  or
                          (cfg_xlt_b0_bit_map="01101")  or (cfg_xlt_b1_bit_map="01101")  or (cfg_xlt_bg0_bit_map="01101") or
                          (cfg_xlt_bg1_bit_map="01101") or (cfg_xlt_c3_bit_map="01101")  or (cfg_xlt_c4_bit_map="01101")  or
                          (cfg_xlt_c5_bit_map="01101")  or (cfg_xlt_c6_bit_map="01101")  or (cfg_xlt_c7_bit_map="01101")  or
                          (cfg_xlt_c8_bit_map="01101")  or (cfg_xlt_c9_bit_map="01101")  or (cfg_xlt_r15_bit_map="01101") or
                          (cfg_xlt_r16_bit_map="01101") or (cfg_xlt_r17_bit_map="01101");

  xlate_usage_mask(32) <= dimm_choice(7) or (cfg_xlt_m0_bit_map="01100") or (cfg_xlt_m1_bit_map="01100") or
                          (cfg_xlt_s0_bit_map="01100")  or (cfg_xlt_s1_bit_map="01100")  or (cfg_xlt_s2_bit_map="01100")  or
                          (cfg_xlt_b0_bit_map="01100")  or (cfg_xlt_b1_bit_map="01100")  or (cfg_xlt_bg0_bit_map="01100") or
                          (cfg_xlt_bg1_bit_map="01100") or (cfg_xlt_c3_bit_map="01100")  or (cfg_xlt_c4_bit_map="01100")  or
                          (cfg_xlt_c5_bit_map="01100")  or (cfg_xlt_c6_bit_map="01100")  or (cfg_xlt_c7_bit_map="01100")  or
                          (cfg_xlt_c8_bit_map="01100")  or (cfg_xlt_c9_bit_map="01100")  or (cfg_xlt_r15_bit_map="01100") or
                          (cfg_xlt_r16_bit_map="01100") or (cfg_xlt_r17_bit_map="01100");

  xlate_usage_mask(31) <= (cfg_xlt_d_bit_map="01011")   or (cfg_xlt_m0_bit_map="01011")  or (cfg_xlt_m1_bit_map="01011")  or
                          (cfg_xlt_s0_bit_map="01011")  or (cfg_xlt_s1_bit_map="01011")  or (cfg_xlt_s2_bit_map="01011")  or
                          (cfg_xlt_b0_bit_map="01011")  or (cfg_xlt_b1_bit_map="01011")  or (cfg_xlt_bg0_bit_map="01011") or
                          (cfg_xlt_bg1_bit_map="01011") or (cfg_xlt_c3_bit_map="01011")  or (cfg_xlt_c4_bit_map="01011")  or
                          (cfg_xlt_c5_bit_map="01011")  or (cfg_xlt_c6_bit_map="01011")  or (cfg_xlt_c7_bit_map="01011")  or
                          (cfg_xlt_c8_bit_map="01011")  or (cfg_xlt_c9_bit_map="01011")  or (cfg_xlt_r15_bit_map="01011") or
                          (cfg_xlt_r16_bit_map="01011") or (cfg_xlt_r17_bit_map="01011");


  XLAT_DROP <= OR_REDUCE(addr(34 downto 26) and not xlate_usage_mask);

  XLAT_HOLE <= (xlate_usage_mask(39) and not xlate_usage_mask(38)) or
               (xlate_usage_mask(38) and not xlate_usage_mask(37)) or
               (xlate_usage_mask(37) and not xlate_usage_mask(36)) or
               (xlate_usage_mask(36) and not xlate_usage_mask(35)) or
               (xlate_usage_mask(35) and not xlate_usage_mask(34)) or
               (xlate_usage_mask(34) and not xlate_usage_mask(33)) or
               (xlate_usage_mask(33) and not xlate_usage_mask(32)) or
               (xlate_usage_mask(32) and not xlate_usage_mask(31)) or     -- then (30 downto 16) are hardcoded ras bits
               (not AND_REDUCE(low_addr_used(15 downto 6)));              -- we assume that addresses 15 downto 5 must all be used


  low_addr_used(15) <= (cfg_xlt_d_bit_map="01010")   or (cfg_xlt_m0_bit_map="01010")  or (cfg_xlt_m1_bit_map="01010")  or
                       (cfg_xlt_s0_bit_map="01010")  or (cfg_xlt_s1_bit_map="01010")  or (cfg_xlt_s2_bit_map="01010")  or
                       (cfg_xlt_b0_bit_map="01010")  or (cfg_xlt_b1_bit_map="01010")  or (cfg_xlt_bg0_bit_map="01010") or
                       (cfg_xlt_bg1_bit_map="01010") or (cfg_xlt_c3_bit_map="01010")  or (cfg_xlt_c4_bit_map="01010")  or
                       (cfg_xlt_c5_bit_map="01010")  or (cfg_xlt_c6_bit_map="01010")  or (cfg_xlt_c7_bit_map="01010")  or
                       (cfg_xlt_c8_bit_map="01010")  or (cfg_xlt_c9_bit_map="01010");

  low_addr_used(14) <= (cfg_xlt_d_bit_map="01001")   or (cfg_xlt_m0_bit_map="01001")  or (cfg_xlt_m1_bit_map="01001")  or
                       (cfg_xlt_s0_bit_map="01001")  or (cfg_xlt_s1_bit_map="01001")  or (cfg_xlt_s2_bit_map="01001")  or
                       (cfg_xlt_b0_bit_map="01001")  or (cfg_xlt_b1_bit_map="01001")  or (cfg_xlt_bg0_bit_map="01001") or
                       (cfg_xlt_bg1_bit_map="01001") or (cfg_xlt_c3_bit_map="01001")  or (cfg_xlt_c4_bit_map="01001")  or
                       (cfg_xlt_c5_bit_map="01001")  or (cfg_xlt_c6_bit_map="01001")  or (cfg_xlt_c7_bit_map="01001")  or
                       (cfg_xlt_c8_bit_map="01001")  or (cfg_xlt_c9_bit_map="01001");

  low_addr_used(13) <= (cfg_xlt_d_bit_map="01000")   or (cfg_xlt_m0_bit_map="01000")  or (cfg_xlt_m1_bit_map="01000")  or
                       (cfg_xlt_s0_bit_map="01000")  or (cfg_xlt_s1_bit_map="01000")  or (cfg_xlt_s2_bit_map="01000")  or
                       (cfg_xlt_b0_bit_map="01000")  or (cfg_xlt_b1_bit_map="01000")  or (cfg_xlt_bg0_bit_map="01000") or
                       (cfg_xlt_bg1_bit_map="01000") or (cfg_xlt_c3_bit_map="01000")  or (cfg_xlt_c4_bit_map="01000")  or
                       (cfg_xlt_c5_bit_map="01000")  or (cfg_xlt_c6_bit_map="01000")  or (cfg_xlt_c7_bit_map="01000")  or
                       (cfg_xlt_c8_bit_map="01000")  or (cfg_xlt_c9_bit_map="01000");

  low_addr_used(12) <= (cfg_xlt_d_bit_map="00111")   or (cfg_xlt_m0_bit_map="00111")  or (cfg_xlt_m1_bit_map="00111")  or
                       (cfg_xlt_s0_bit_map="00111")  or (cfg_xlt_s1_bit_map="00111")  or (cfg_xlt_s2_bit_map="00111")  or
                       (cfg_xlt_b0_bit_map="00111")  or (cfg_xlt_b1_bit_map="00111")  or (cfg_xlt_bg0_bit_map="00111") or
                       (cfg_xlt_bg1_bit_map="00111") or (cfg_xlt_c3_bit_map="00111")  or (cfg_xlt_c4_bit_map="00111")  or
                       (cfg_xlt_c5_bit_map="00111")  or (cfg_xlt_c6_bit_map="00111")  or (cfg_xlt_c7_bit_map="00111")  or
                       (cfg_xlt_c8_bit_map="00111")  or (cfg_xlt_c9_bit_map="00111");

  low_addr_used(11) <= dimm_choice(8) or (cfg_xlt_m0_bit_map="00110") or (cfg_xlt_m1_bit_map="00110")                  or
                       (cfg_xlt_s0_bit_map="00110")  or (cfg_xlt_s1_bit_map="00110")  or (cfg_xlt_s2_bit_map="00110")  or
                       (cfg_xlt_b0_bit_map="00110")  or (cfg_xlt_b1_bit_map="00110")  or (cfg_xlt_bg0_bit_map="00110") or
                       (cfg_xlt_bg1_bit_map="00110") or (cfg_xlt_c3_bit_map="00110")  or (cfg_xlt_c4_bit_map="00110")  or
                       (cfg_xlt_c5_bit_map="00110")  or (cfg_xlt_c6_bit_map="00110")  or (cfg_xlt_c7_bit_map="00110")  or
                       (cfg_xlt_c8_bit_map="00110")  or (cfg_xlt_c9_bit_map="00110");

  low_addr_used(10) <= (cfg_xlt_d_bit_map="00101")   or (cfg_xlt_m0_bit_map="00101") or (cfg_xlt_m1_bit_map="00101")   or
                       (cfg_xlt_s0_bit_map="00101")  or (cfg_xlt_s1_bit_map="00101") or (cfg_xlt_s2_bit_map="00101")  or
                       (cfg_xlt_b0_bit_map="00101")  or (cfg_xlt_b1_bit_map="00101") or (cfg_xlt_bg0_bit_map="00101") or
                       (cfg_xlt_bg1_bit_map="00101") or (cfg_xlt_c3_bit_map="00101") or (cfg_xlt_c4_bit_map="00101")  or
                       (cfg_xlt_c5_bit_map="00101")  or (cfg_xlt_c6_bit_map="00101") or (cfg_xlt_c7_bit_map="00101")  or
                       (cfg_xlt_c8_bit_map="00101")  or (cfg_xlt_c9_bit_map="00101");

  low_addr_used(9)  <= (cfg_xlt_d_bit_map="00100")   or (cfg_xlt_m0_bit_map="00100") or (cfg_xlt_m1_bit_map="00100")  or
                       (cfg_xlt_s0_bit_map="00100")  or (cfg_xlt_s1_bit_map="00100") or (cfg_xlt_s2_bit_map="00100")  or
                       (cfg_xlt_b0_bit_map="00100")  or (cfg_xlt_b1_bit_map="00100") or (cfg_xlt_bg0_bit_map="00100") or
                       (cfg_xlt_bg1_bit_map="00100") or (cfg_xlt_c3_bit_map="00100") or (cfg_xlt_c4_bit_map="00100")  or
                       (cfg_xlt_c5_bit_map="00100")  or (cfg_xlt_c6_bit_map="00100") or (cfg_xlt_c7_bit_map="00100")  or
                       (cfg_xlt_c8_bit_map="00100")  or (cfg_xlt_c9_bit_map="00100");

  low_addr_used(8)  <= (cfg_xlt_d_bit_map="00011")   or (cfg_xlt_m0_bit_map="00011") or (cfg_xlt_m1_bit_map="00011")   or
                       (cfg_xlt_s0_bit_map="00011")  or (cfg_xlt_s1_bit_map="00011") or (cfg_xlt_s2_bit_map="00011")  or
                       (cfg_xlt_b0_bit_map="00011")  or (cfg_xlt_b1_bit_map="00011") or (cfg_xlt_bg0_bit_map="00011") or
                       (cfg_xlt_bg1_bit_map="00011") or (cfg_xlt_c3_bit_map="00011") or (cfg_xlt_c4_bit_map="00011")  or
                       (cfg_xlt_c5_bit_map="00011")  or (cfg_xlt_c6_bit_map="00011") or (cfg_xlt_c7_bit_map="00011")  or
                       (cfg_xlt_c8_bit_map="00011")  or (cfg_xlt_c9_bit_map="00011");

  low_addr_used(7)  <= (cfg_xlt_d_bit_map="00010")   or (cfg_xlt_m0_bit_map="00010") or (cfg_xlt_m1_bit_map="00010")   or
                       (cfg_xlt_s0_bit_map="00010")  or (cfg_xlt_s1_bit_map="00010") or (cfg_xlt_s2_bit_map="00010")  or
                       (cfg_xlt_b0_bit_map="00010")  or (cfg_xlt_b1_bit_map="00010") or (cfg_xlt_bg0_bit_map="00010") or
                       (cfg_xlt_bg1_bit_map="00010") or (cfg_xlt_c3_bit_map="00010") or (cfg_xlt_c4_bit_map="00010")  or
                       (cfg_xlt_c5_bit_map="00010")  or (cfg_xlt_c6_bit_map="00010") or (cfg_xlt_c7_bit_map="00010")  or
                       (cfg_xlt_c8_bit_map="00010")  or (cfg_xlt_c9_bit_map="00010");


  low_addr_used(6)  <= (cfg_xlt_d_bit_map="00001")   or (cfg_xlt_m0_bit_map="00001") or (cfg_xlt_m1_bit_map="00001")   or
                       (cfg_xlt_s0_bit_map="00001")  or (cfg_xlt_s1_bit_map="00001") or (cfg_xlt_s2_bit_map="00001")  or
                       (cfg_xlt_b0_bit_map="00001")  or (cfg_xlt_b1_bit_map="00001") or (cfg_xlt_bg0_bit_map="00001") or
                       (cfg_xlt_bg1_bit_map="00001") or (cfg_xlt_c3_bit_map="00001") or (cfg_xlt_c4_bit_map="00001")  or
                       (cfg_xlt_c5_bit_map="00001")  or (cfg_xlt_c6_bit_map="00001") or (cfg_xlt_c7_bit_map="00001")  or
                       (cfg_xlt_c8_bit_map="00001")  or (cfg_xlt_c9_bit_map="00001");

-- column bit 2 is ALWAYS OC addr 5


  dimm          <=      dimm_int;
  mrank         <=      mrank_int;
  srank         <=      srank_int;
  bank          <=      bank_int(0 to 1) xor bk_row_hash(0 to 1);
  bank_group    <=      bank_group_int(0 to 1) xor bg_row_hash(0 to 1);
  row           <=      row_int;
  col           <=      col_int;
  fast_decode   <=      AND_REDUCE(fast_act_decode);

 END cb_tlxr_xlat;
