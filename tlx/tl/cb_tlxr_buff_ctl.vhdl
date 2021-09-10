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

LIBRARY ieee,ibm,latches,stdcell,support,work;
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
    use work.cb_func.ALL;
    use work.cb_tlxr_pkg.ALL;


entity cb_tlxr_buff_ctl is

  port (
    gckn                           : in std_ulogic;
    gnd                            : inout power_logic;
    vdd                            : inout power_logic;
    syncr                          : in std_ulogic;  -- synchronous reset
    link_up                        : in std_ulogic;         -- aka reset_n
    half_dimm_mode                 : in std_ulogic;
          -- write side signals
    first_tag                      : in std_ulogic_vector(5 downto 0);
    second_tag                     : in std_ulogic_vector(5 downto 0);  --   0        1         2   3
    format                         : in std_ulogic_vector(3 downto 0);  -- nothing 32 (or less) 64 128
                                                          --
                                                          --  format3  2 1 0
                                                          --        0  0 0 0  nothing
                                                          --        0  0 0 1  32 on 64 boundary  (mem)
                                                          --        0  1 0 1  32 on odd 32 boundary (mem)
                                                          --        0  0 1 0  64
                                                          --        0  0 1 1  128
                                                          --        0  1 0 0  256
                                                          --        0  1 1 0  32 on 64 boundary  (not mem)
                                                          --        0  1 1 1  32 on odd 32 boundary (not mem)
                                                          --        1  1 0 1  pad pattern write (anomalous that translating = '1' look at pop)
          -- read side signals
    read_32b                       : in std_ulogic;
    read_48b                       : in std_ulogic;
    read_64b                       : in std_ulogic;
    good_control_flit              : in std_ulogic;
    backup                         : in std_ulogic;

    bi_flit_buffer                 : out std_ulogic;
    last_wdf_phase_7a              : out std_ulogic;
    last_wdf_phase_df              : out std_ulogic;
    force_buf_63                   : out std_ulogic;
    tlxr_wdf_wrbuf_wr              : out std_ulogic;
    tlxr_wdf_wrbuf_pointer         : out std_ulogic_vector(0 to 5);
    tlxr_wdf_wrbuf_woffset         : out std_ulogic_vector(0 to 1);
    TLXR_WDF_WRBUF_WR_PAR          : out std_ulogic;
    EMPTY                          : out std_ulogic;
    insane                         : out std_ulogic_vector(5 downto 0)   -- Houston we have a problem
    );

  ATTRIBUTE POWER_PIN                     OF VDD                       : SIGNAL  IS 1;
  ATTRIBUTE POWER_DOMAIN                  OF CB_TLXR_BUFF_CTL          : ENTITY  IS "VDD";
  ATTRIBUTE PIN_DEFAULT_POWER_DOMAIN      OF CB_TLXR_BUFF_CTL          : ENTITY  IS "VDD";
  ATTRIBUTE GROUND_PIN                    OF GND                       : SIGNAL  IS 1;
  ATTRIBUTE PIN_DEFAULT_GROUND_DOMAIN     OF CB_TLXR_BUFF_CTL          : ENTITY  IS "GND";
  ATTRIBUTE BTR_NAME                      OF CB_TLXR_BUFF_CTL          : ENTITY  IS "CB_TLXR_BUFF_CTL";
  ATTRIBUTE BLOCK_TYPE                    OF CB_TLXR_BUFF_CTL          : ENTITY  IS  LEAF;
  ATTRIBUTE RECURSIVE_SYNTHESIS           OF CB_TLXR_BUFF_CTL          : ENTITY  IS  2;

  attribute PIN_DATA of gckn : signal is "PIN_FUNCTION=/G_CLK/";
 END cb_tlxr_buff_ctl;


 ARCHITECTURE cb_tlxr_buff_ctl OF cb_tlxr_buff_ctl IS
     signal act                           : std_ulogic;
     signal array_data_ecc_in             : std_ulogic_vector(25 downto 0);
     signal array_data_in                 : std_ulogic_vector(19 downto 0);
     signal array_dout                    : std_ulogic_vector(19 downto 0);
     signal array_dout_raw                : std_ulogic_vector(25 downto 0);
     signal array_read                    : std_ulogic;
     signal array_wr                      : std_ulogic;
     signal backup_delayed_d              : std_ulogic_vector(2 downto 0);
     signal backup_delayed_q              : std_ulogic_vector(2 downto 0);
     signal bi_flit_buffer_d              : std_ulogic;
     signal bi_flit_buffer_q              : std_ulogic;
     signal corr                          : std_ulogic_vector(21 downto 0);
     signal ddr                           : std_ulogic;
     signal delayed_good_c_flit_d         : std_ulogic_vector(2 downto 0);
     signal delayed_good_c_flit_q         : std_ulogic_vector(2 downto 0);
     signal discard_count_d               : std_ulogic_vector(1 downto 0);
     signal discard_count_q               : std_ulogic_vector(1 downto 0);
     signal empty_i                       : std_ulogic;
     signal fifo_empty                    : std_ulogic;
     signal fifo_full                     : std_ulogic;
     signal first_half_we                 : std_ulogic;
     signal full                          : std_ulogic;
     signal inreg_d                       : std_ulogic_vector(9 downto 0);
     signal inreg_full_d                  : std_ulogic;
     signal inreg_full_q                  : std_ulogic;
     signal inreg_q                       : std_ulogic_vector(9 downto 0);
     signal insane_d                      : std_ulogic_vector(5 downto 0);
     signal insane_q                      : std_ulogic_vector(5 downto 0);
     signal last_allowed_d                : std_ulogic_vector(1 downto 0);
     signal last_allowed_q                : std_ulogic_vector(1 downto 0);
     signal last_good_discard_count_d     : std_ulogic_vector(1 downto 0);
     signal last_good_discard_count_q     : std_ulogic_vector(1 downto 0);
     signal last_good_output_odd_tag_d    : std_ulogic;
     signal last_good_output_odd_tag_q    : std_ulogic;
     signal last_good_read_ptr_d          : std_ulogic_vector(5 downto 0);
     signal last_good_read_ptr_q          : std_ulogic_vector(5 downto 0);
     signal lte_32,A5                     : std_ulogic;
     signal mux_a_hi                      : std_ulogic;
     signal mux_a_lo                      : std_ulogic;
     signal mux_ireg                      : std_ulogic;
     signal mux_raw                       : std_ulogic;
     signal next_tag                      : std_ulogic;
     signal one_done                      : std_ulogic;
     signal output_odd_tag_d              : std_ulogic;
     signal output_odd_tag_q              : std_ulogic;
     signal outreg_d                      : std_ulogic_vector(9 downto 0);
     signal outreg_q                      : std_ulogic_vector(9 downto 0);
     signal oversized                     : std_ulogic;
     signal read_32b_d                    : std_ulogic_vector(2 downto 0);
     signal read_32b_q                    : std_ulogic_vector(2 downto 0);
     signal read_48b_q,read_48b_d         : std_ulogic_vector(2 downto 0);
     signal read_64b_d,read_64b_q         : std_ulogic_vector(3 downto 0);
     signal read_ptr_d                    : std_ulogic_vector(5 downto 0);
     signal read_ptr_q                    : std_ulogic_vector(5 downto 0);
     signal read_strobe                   : std_ulogic;
     signal second_half_we                : std_ulogic;
     signal syndrome                      : std_ulogic_vector(5 downto 0);
     signal tag_off_out                   : std_ulogic_vector(9 downto 0);
     signal third_quarter_we              : std_ulogic;
     signal tlxr_wdf_wrbuf_woffset_i      : std_ulogic_vector(1 downto 0);
     signal tlxr_wdf_wrbuf_wr_i           : std_ulogic;
     signal unc                           : std_ulogic;
     signal unsafe_d,unsafe_q             : std_ulogic;
     signal wr_one_tag                    : std_ulogic;
     signal write_ptr_d                   : std_ulogic_vector(5 downto 0);
     signal write_ptr_q                   : std_ulogic_vector(5 downto 0);

-- ribute ANALYSIS_NOT_REFERENCED of CORR:signal is "<17:16>TRUE";

BEGIN

     act <= '1';

    -- bodge parity for now - checked on every clock

    TLXR_WDF_WRBUF_WR_PAR    <= XOR_REDUCE(tlxr_wdf_wrbuf_wr_i & tag_off_out(9 downto 4) & tlxr_wdf_wrbuf_woffset_i);



TAG_ARRAY: ENTITY work.cb_tlxr_ra
    GENERIC MAP (
      width      => 26,          -- tag1 tag2
      depth      => 32,
      addr_width => 5)
    PORT MAP (
      GCKN   => GCKN,

      din    => array_data_ecc_in,
      wr     => array_wr,
      wr_ptr => write_ptr_q(4 downto 0),
      rd_ptr => read_ptr_q(4 downto 0),
      GND    => GND,
      VDD    => VDD,
      dout   => array_dout_raw); -- raw means with ecc


                                    -------------------------
                                    -- input data steering --
                                    -------------------------


      wr_one_tag <=  FORMAT(2) or (FORMAT(1) xor FORMAT(0));  -- 011 = 128

      inreg_full_d <= '0'                     when LINK_UP = '0'         else -- aka write_ptr lsb
                       not inreg_full_q       when wr_one_tag = '1'      else -- toggles when we write 32
                       inreg_full_q;

      array_data_in(19 downto 10) <=  FIRST_TAG & FORMAT(3 downto 0) when (inreg_full_q = '0' and  FORMAT = "0011") -- 128
                           else      inreg_q ;                     --


      array_data_ecc_in <= ECCGEN(array_data_in(19 downto 0)) &  array_data_in(19 downto 0);



      array_data_in(9 downto 0) <=  SECOND_TAG & "0010" when (inreg_full_q = '0' and  FORMAT = "0011")
                           else     FIRST_TAG & FORMAT(3 downto 0);


      inreg_d <=  FIRST_TAG & FORMAT(3 downto 0) when (inreg_full_q = '0' and  wr_one_tag = '1') else
                  SECOND_TAG & "0010"  when (inreg_full_q = '1' and  FORMAT = "0011") else
                  inreg_q;

      write_ptr_d <= write_ptr_q + "00001" when array_wr = '1' else
                     write_ptr_q;

      array_wr <=  (FORMAT = "0011") or (wr_one_tag and inreg_full_q );

                                        --------------------------------------
                                        -- output data steering and control --
                                        --------------------------------------
      output_odd_tag_d <= '0'                           when  LINK_UP = '0' else    -- aka lsb of read ptr
                             last_good_output_odd_tag_q when backup_delayed_q(2) = '1'   else
                             not output_odd_tag_q       when next_tag = '1' else
                             output_odd_tag_q;

      read_ptr_d <= last_good_read_ptr_q when backup_delayed_q(2) = '1'               else
                    read_ptr_q + "000001" when (next_tag and output_odd_tag_q ) = '1' else
                    read_ptr_q;

      fifo_empty   <= '1' when (read_ptr_q = write_ptr_q) else '0';
      fifo_full    <= '1' when (read_ptr_q(4 downto 0) = write_ptr_q(4 downto 0)) and (read_ptr_q(5) /= write_ptr_q(5)) else '0';

      empty_i <= fifo_empty and not(output_odd_tag_q xor inreg_full_q);
      EMPTY   <= empty_i;
      full  <= fifo_full and inreg_full_q ;

      delayed_good_c_flit_d <= delayed_good_c_flit_q(1 downto 0) & GOOD_CONTROL_FLIT;
      backup_delayed_d <= backup_delayed_q(1 downto 0) & BACKUP;

      last_good_read_ptr_d           <= read_ptr_q        when delayed_good_c_flit_q(2) = '1' else last_good_read_ptr_q;
      last_good_output_odd_tag_d     <= output_odd_tag_q  when delayed_good_c_flit_q(2) = '1' else last_good_output_odd_tag_q;
      last_good_discard_count_d      <= discard_count_q   when delayed_good_c_flit_q(2) = '1' else last_good_discard_count_q;


      LAST_WDF_PHASE_7A <= (third_quarter_we  or
      ((read_32b_q(1) or read_48b_q(1)) and (lte_32 or bi_flit_buffer_q)) ) and last_allowed_q(0);

      LAST_WDF_PHASE_DF <= read_64b_q(3) and last_allowed_q(1);

                                        --------------------
                                        -- ecc correction --
                                        --------------------

      syndrome   <= ECCGEN( array_dout_raw(19 downto 0)) xor array_dout_raw(25 downto 20);
      corr       <= ECCCORR_MAX('1',syndrome,20);
      unc        <= corr(20);
      array_dout <= array_dout_raw(19 downto 0) xor corr(19 downto 0);


                                        ---------------------
                                        -- output register --
                                        ---------------------


      read_strobe <= READ_32B or READ_64B or READ_48B;
                                                                                  -- inreg always has the even tags
      mux_raw  <= read_strobe and empty_i;                                        -- bypass the fifo and use the raw tag/format/offset
      mux_a_hi <= read_strobe and not fifo_empty and     output_odd_tag_q ;
      mux_a_lo <= read_strobe and not fifo_empty and not output_odd_tag_q ;
      mux_ireg <= read_strobe and     fifo_empty and inreg_full_q and not output_odd_tag_q;

      outreg_d <= GATE(FIRST_TAG & FORMAT(3 downto 0),mux_raw)   or
                  GATE(array_dout(9 downto 0),mux_a_hi)          or
                  GATE(array_dout(19 downto 10),mux_a_lo)        or
                  GATE(inreg_q,mux_ireg)                         or
                  GATE(outreg_q,not read_strobe);

                                     ------------------
                                     -- Make Outputs --
                                     ------------------

      oversized   <= outreg_q(2) and not outreg_q(1) and not outreg_q(0); --- FORMAT "100" is 256 byte length
      tag_off_out <=  outreg_q;
      force_buf_63 <= tag_off_out(3);
      tlxr_wdf_wrbuf_pointer(0 to 5) <= tag_off_out(9 downto 4);
      TLXR_WDF_WRBUF_WOFFSET(0 to 1) <=   tlxr_wdf_wrbuf_woffset_i(1 downto 0);
      tlxr_wdf_wrbuf_wr_i <= (first_half_we or second_half_we or third_quarter_we) and not unsafe_q;
      TLXR_WDF_WRBUF_WR   <= tlxr_wdf_wrbuf_wr_i;

                                 -- generate read_next
      read_32b_d(2 downto 0) <=  read_32b_q(1 downto 0) & READ_32B;        -- tag_off_out(0) is a5
      read_48b_d(2 downto 0) <=  read_48b_q(1 downto 0) & READ_48B;        -- tag_off_out(1) is small op (<33)
      read_64b_d(3 downto 0) <=  read_64b_q(2 downto 0) & READ_64B;
      array_read             <=  read_strobe and not fifo_empty;


      lte_32 <= '1' when  tag_off_out(1 downto 0) = "01" or tag_off_out(2 downto 1) = "11" else '0';

      one_done <= ((read_32b_q(1) or read_48b_q(1)) and (bi_flit_buffer_q or lte_32)) = '1'
                  or read_64b_q(1) or
                  (read_48b_q(1) and tag_off_out(1 downto 0) = "01" and half_dimm_mode) ;


      next_tag <=  one_done and  (not oversized or AND_REDUCE(discard_count_q));

      last_allowed_d(1 downto 0) <= last_allowed_q(0) & (not oversized or AND_REDUCE(discard_count_q));

      discard_count_d <= last_good_discard_count_q when backup_delayed_q(2)    = '1' else
                         discard_count_q + "01" when (oversized and one_done) = '1' else
                         discard_count_q;

          -- if we write 64B buffer with two template 7 32B's we need to force the starting offset high for the second half

      bi_flit_buffer_d <= not bi_flit_buffer_q when ((read_32b_q(2) or read_48b_q(2)) and not lte_32) = '1' else
                          bi_flit_buffer_q;

      BI_FLIT_BUFFER <=  bi_flit_buffer_q;

      a5 <= '1' when tag_off_out(2 downto 0) = "111" or tag_off_out(2 downto 0) = "101" else '0';

      DDR <= '1' when  tag_off_out(2 downto 0) = "001" else '0'; -- in half dimm mode all ddr is 32 64 aligned

      tlxr_wdf_wrbuf_woffset_i(0) <=  read_32b_q(1) or read_64b_q(1) or read_48b_q(1) or read_64b_q(3);

      tlxr_wdf_wrbuf_woffset_i(1) <= ( read_32b_q(0) and A5 ) or read_64b_q(2) or read_64b_q(3) or
                                       read_64b_q(2) or read_64b_q(3) or (read_48b_q(2) and tag_off_out(2 downto 0) /= "110")  or
                                     ((read_48b_q(0) or read_48b_q(1)) and tag_off_out(2 downto 0) = "111") or   -- using mmio using template_a
                                     ((read_48b_q(0) or read_48b_q(1)) and (bi_flit_buffer_q or (A5 and not half_dimm_mode)) ) or
                                     ((read_32b_q(0) or read_32b_q(1)) and (bi_flit_buffer_q or A5) );

      first_half_we    <= read_32b_q(0) or read_32b_q(1) or read_64b_q(0) or read_64b_q(1) or read_48b_q(0) or read_48b_q(1);
      second_half_we   <= read_64b_q(2) or read_64b_q(3);
      third_quarter_we <= read_48b_q(2) and half_dimm_mode  and tag_off_out(1 downto 0) = "01";         -- 1/2 dimm memory or pattern write only

      insane_d(0) <= READ_64B and bi_flit_buffer_q ;                                                      -- read64 when template7 read32 is expected
      insane_d(1) <= not(inreg_full_q xor output_odd_tag_q) and fifo_empty and read_strobe and not or_reduce(format);
      insane_d(2) <= (FORMAT(2) or FORMAT(1) or FORMAT(0)) and full and not read_strobe;  -- attempt write when full
      insane_d(3) <= unc and array_read;                                                  -- uncorrectable ecc on array
      insane_d(4) <= corr(21) and array_read;                                             -- correctable ecc on array
      insane_d(5) <= read_32b_q(0) and DDR;                                               -- DDR with flit or t7 (error in half dimm mode)

      INSANE <= insane_q;

      unsafe_d <= (unc and array_read) or unsafe_q;

backup_delayedq: entity latches.c_morph_dff
  generic map (width => 3, offset => 0)
  port map(gckn                 => gckn,
           syncr                => syncr,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => backup_delayed_d(2 downto 0),
           q                    => backup_delayed_q(2 downto 0));

unsafeq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           syncr                => syncr,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(unsafe_d),
           Tconv(q)             => unsafe_q);

read_ptrq: entity latches.c_morph_dff
  generic map (width => 6, offset => 0)
  port map(gckn                 => gckn,
           syncr                => syncr,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => read_ptr_d(5 downto 0),
           q                    => read_ptr_q(5 downto 0));

write_ptrq: entity latches.c_morph_dff
  generic map (width => 6, offset => 0)
  port map(gckn                 => gckn,
           syncr                => syncr,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => write_ptr_d(5 downto 0),
           q                    => write_ptr_q(5 downto 0));

inregq: entity latches.c_morph_dff
  generic map (width => 10, offset => 0)
  port map(gckn                 => gckn,
           syncr                => syncr,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => inreg_d(9 downto 0),
           q                    => inreg_q(9 downto 0));

inreg_fullq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           syncr                => syncr,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(inreg_full_d),
           Tconv(q)             => inreg_full_q);

output_odd_tagq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           syncr                => syncr,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(output_odd_tag_d),
           Tconv(q)             => output_odd_tag_q);

bi_flit_bufferq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           syncr                => syncr,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(bi_flit_buffer_d),
           Tconv(q)             => bi_flit_buffer_q);

last_good_output_odd_tagq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           syncr                => syncr,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(last_good_output_odd_tag_d),
           Tconv(q)             => last_good_output_odd_tag_q);


insaneq: entity latches.c_morph_dff
  generic map (width => 6, offset => 0)
  port map(gckn                 => gckn,
           syncr                => syncr,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => insane_d(5 downto 0),
           q                    => insane_q(5 downto 0));

read_32bq: entity latches.c_morph_dff
  generic map (width => 3, offset => 0)
  port map(gckn                 => gckn,
           syncr                => syncr,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => read_32b_d(2 downto 0),
           q                    => read_32b_q(2 downto 0));

read_48bq: entity latches.c_morph_dff
  generic map (width => 3, offset => 0)
  port map(gckn                 => gckn,
           syncr                => syncr,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => read_48b_d(2 downto 0),
           q                    => read_48b_q(2 downto 0));

read_64bq: entity latches.c_morph_dff
  generic map (width => 4, offset => 0)
  port map(gckn                 => gckn,
           syncr                => syncr,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => read_64b_d(3 downto 0),
           q                    => read_64b_q(3 downto 0));

last_good_read_ptrq: entity latches.c_morph_dff
  generic map (width => 6, offset => 0)
  port map(gckn                 => gckn,
           syncr                => syncr,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => last_good_read_ptr_d(5 downto 0),
           q                    => last_good_read_ptr_q(5 downto 0));

outregq: entity latches.c_morph_dff
  generic map (width => 10, offset => 0)
  port map(gckn                 => gckn,
           syncr                => syncr,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => outreg_d(9 downto 0),
           q                    => outreg_q(9 downto 0));

delayed_good_c_flitq: entity latches.c_morph_dff
  generic map (width => 3, offset => 0)
  port map(gckn                 => gckn,
           syncr                => syncr,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => delayed_good_c_flit_d(2 downto 0),
           q                    => delayed_good_c_flit_q(2 downto 0));

discard_countq: entity latches.c_morph_dff
  generic map (width => 2, offset => 0)
  port map(gckn                 => gckn,
           syncr                => syncr,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => discard_count_d(1 downto 0),
           q                    => discard_count_q(1 downto 0));

last_good_discard_countq: entity latches.c_morph_dff
  generic map (width => 2, offset => 0)
  port map(gckn                 => gckn,
           syncr                => syncr,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => last_good_discard_count_d(1 downto 0),
           q                    => last_good_discard_count_q(1 downto 0));

last_allowedq: entity latches.c_morph_dff
  generic map (width => 2, offset => 0)
  port map(gckn                 => gckn,
           syncr                => syncr,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => last_allowed_d(1 downto 0),
           q                    => last_allowed_q(1 downto 0));

 END cb_tlxr_buff_ctl;
