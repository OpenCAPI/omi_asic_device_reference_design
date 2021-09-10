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




library ieee, clib;
 use ieee.std_logic_1164.all ;

library ibm;
 use ibm.synthesis_support.all;
 use ibm.std_ulogic_support.all;
 use ibm.std_ulogic_function_support.all;
 use ibm.texsim_attributes.all;
 use ieee.numeric_std.all;  
 use ibm.std_ulogic_unsigned.all;

library latches;

library support;
use support.power_logic_pkg.all;
use support.logic_support_pkg.all;


entity c_serial_scom_comp is
  generic(
    width               : positive := 64;    
    internal_addr_decode: boolean := true;  
    
    use_addr            : std_ulogic_vector := "1000000000000000000000000000000000000000000000000000000000000001"; 
    addr_is_rdable      : std_ulogic_vector := "1000000000000000000000000000000000000000000000000000000000000001"; 
    addr_is_wrable      : std_ulogic_vector := "1000000000000000000000000000000000000000000000000000000000000001"; 
    pipeline_addr_v     : std_ulogic_vector := "0000000000000000000000000000000000000000000000000000000000000000"; 
    indirect_address    : std_ulogic := '0';  
    monitor_user_status : std_ulogic := '0';  
    pipeline_paritychk  : boolean  := false;  
    satid_nobits        : positive := 4;      
    regid_nobits        : positive := 6;      
    ratio               : std_ulogic := '0'   
    ); 

  port  (
    vdd                   : inout power_logic ;  
    gnd                   : inout power_logic;  

    lckn                 : in  std_ulogic;
    local_act_int        : out std_ulogic;

    dcfg_lckn            : in  std_ulogic := '0'; 
    asyncr               : in  std_ulogic := '0'; 
    syncr                : in  std_ulogic := '0'; 

  

    scom_local_act       : out std_ulogic; 

    sat_id                 : in std_ulogic_vector(0 to satid_nobits-1);  
    scom_dch_in            : in  std_ulogic;  
    scom_cch_in            : in  std_ulogic;  
    scom_dch_out           : out std_ulogic;  
    scom_cch_out           : out std_ulogic;  

    sc_req                 : out std_ulogic;  
    sc_ack                 : in  std_ulogic;  
    sc_ack_info            : in  std_ulogic_vector(0 to 1);  
    sc_r_nw                : out std_ulogic;  

    sc_addr                : out std_ulogic_vector(0 to ((regid_nobits-1) + ( tconv(indirect_address) * (20 - regid_nobits))) );
    addr_v                 : out std_ulogic_vector(0 to use_addr'high);  
    sc_rdata               : in  std_ulogic_vector(0 to width-1);  
    sc_wdata               : out std_ulogic_vector(0 to width-1);  
    sc_wparity             : out std_ulogic;  

    scom_err       : out std_ulogic;

    fsm_reset            : in  std_ulogic

    ); 

attribute block_type of c_serial_scom_comp          : entity is leaf;
attribute BLOCK_DATA of c_serial_scom_comp  : entity is "SCAN_FLATTEN=/NO/";

attribute power_pin of vdd : signal is 1;
attribute pin_default_power_domain of c_serial_scom_comp : entity is "VDD";
attribute ground_pin of gnd : signal is 1;
attribute pin_default_ground_domain of c_serial_scom_comp : entity is "GND";
end c_serial_scom_comp;


architecture c_serial_scom_comp of c_serial_scom_comp is
constant state_width : positive := 5 ;
constant i_width     : positive := (((width+15)/16)*16);  
constant par_nobits  : positive:= (i_width-1)/16+1;

constant reg_nobits         : positive := regid_nobits;  
constant satid_regid_nobits : positive := satid_nobits + regid_nobits;  
constant rw_bit_index       : positive := satid_regid_nobits + 1;  
constant parbit_index       : positive := rw_bit_index + 1;  
constant head_width         : positive := parbit_index + 1;  
constant head_init          : std_ulogic_vector( 0 to head_width-1) := "0000000000000";

constant idle         : std_ulogic_vector(0 to state_width-1) := "00000";  
constant rec_head     : std_ulogic_vector(0 to state_width-1) := "00011";  
constant check_before : std_ulogic_vector(0 to state_width-1) := "00101";  
constant rec_wdata    : std_ulogic_vector(0 to state_width-1) := "00110";  
constant rec_wpar     : std_ulogic_vector(0 to state_width-1) := "01001";  
constant exe_cmd_0    : std_ulogic_vector(0 to state_width-1) := "01010";  
constant filler0      : std_ulogic_vector(0 to state_width-1) := "01100";  
constant filler1      : std_ulogic_vector(0 to state_width-1) := "01111";  
constant gen_ulinfo   : std_ulogic_vector(0 to state_width-1) := "10001";  
constant send_ulinfo  : std_ulogic_vector(0 to state_width-1) := "10010";  
constant send_rdata   : std_ulogic_vector(0 to state_width-1) := "10100";  
constant send_0       : std_ulogic_vector(0 to state_width-1) := "10111";  
constant send_1       : std_ulogic_vector(0 to state_width-1) := "11000";  
constant check_wpar   : std_ulogic_vector(0 to state_width-1) := "11011";  
constant exe_cmd_1    : std_ulogic_vector(0 to state_width-1) := "11101";  
constant not_selected : std_ulogic_vector(0 to state_width-1) := "11110";  

constant eof_wdata : positive := parbit_index-1+64; 
constant eof_wpar  : positive := eof_wdata + 4;

constant eof_wdata_n : positive := parbit_index-1 + i_width;
constant eof_wpar_m  : positive := eof_wdata + par_nobits;

signal chksw_HW040380      : std_ulogic;  
signal chksw_HW042465      : std_ulogic;  
signal chksw_HW012345      : std_ulogic;  
signal chksw_q             : std_ulogic_vector(0 to 2);
signal internal_addr_decode_signal      : std_ulogic;  
signal use_addr_signal                  : std_ulogic_vector(use_addr'range);  
signal addr_is_rdable_signal            : std_ulogic_vector(addr_is_rdable'range);  
signal addr_is_wrable_signal            : std_ulogic_vector(addr_is_wrable'range);  
signal indirect_address_signal          : std_ulogic;  
signal monitor_user_status_signal       : std_ulogic;  
signal sc_r_nw_i_head                   : std_ulogic;


signal is_idle        : std_ulogic;
signal is_rec_head    : std_ulogic;
signal is_check_before: std_ulogic;
signal is_rec_wdata   : std_ulogic;
signal is_rec_wpar    : std_ulogic;
signal is_check_wpar  : std_ulogic;
signal is_exe_cmd_0   : std_ulogic;
signal is_exe_cmd_1   : std_ulogic;
signal is_gen_ulinfo  : std_ulogic;
signal is_send_ulinfo : std_ulogic;
signal is_send_rdata  : std_ulogic;
signal is_send_0      : std_ulogic;
signal is_send_1      : std_ulogic;
signal is_filler_0    : std_ulogic;
signal is_filler_1    : std_ulogic;
signal is_not_selected : std_ulogic;

signal next_state, state_in, state_lt : std_ulogic_vector(0 to state_width-1);

signal dch_lt           : std_ulogic;
signal cch_in, cch_lt   : std_ulogic_vector(0 to 1);

signal reset                                                     : std_ulogic;
signal got_head, got_eofwdata, got_eofwpar, sent_rdata, got_ulhead, do_send_par
       ,cntgtheadpluswidth, cntgteofwdataplusparity                      : std_ulogic;
signal p0_err, any_ack_error, match   : std_ulogic;
signal p0_err_in, p0_err_lt           : std_ulogic;
signal do_write, do_read              : std_ulogic;
signal enable_cnt                     : std_ulogic;
signal cnt_in, cnt_lt                 : std_ulogic_vector(0 to 6);
signal head_in, head_lt               : std_ulogic_vector(0 to head_width-1);
signal tail_in, tail_lt               : std_ulogic_vector(0 to 4);
signal sc_ack_info_in, sc_ack_info_lt : std_ulogic_vector(0 to 1);
signal sc_ack_info_i                  : std_ulogic_vector(0 to 1);  
signal sc_ack_info_sat                : std_ulogic_vector(0 to 1);  
signal ext_error_enable_q             : std_ulogic;
signal head_mux                       : std_ulogic;
signal sc_req_i                       : std_ulogic;
signal sc_ack_i                       : std_ulogic;   
signal sc_ack_sat                     : std_ulogic;   
signal sc_r_nw_i                      : std_ulogic;   
signal sc_wparity_i                   : std_ulogic;   
signal sc_addr_i                      : std_ulogic_vector(0 to regid_nobits-1); 
signal sc_wdata_i                     : std_ulogic_vector(0 to width-1);  
signal sc_wdata_mux                   : std_ulogic_vector(0 to width-1);  

signal data_shifter_in, data_shifter_lt : std_ulogic_vector(0 to i_width-1);
signal data_shifter_lt_tmp              : std_ulogic_vector(0 to 63);

signal datapar_shifter_in, datapar_shifter_lt   : std_ulogic_vector(0 to par_nobits-1);
signal data_mux, par_mux                        : std_ulogic;
signal dch_out_internal_in, dch_out_internal_lt : std_ulogic;
signal parity_satid_regaddr_in                  : std_ulogic;
signal parity_satid_regaddr_lt                  : std_ulogic;
signal local_act                 : std_ulogic;
signal scom_err_in, scom_err_lt                 : std_ulogic;
signal scom_local_act_in, scom_local_act_lt     : std_ulogic;
signal any_cmd_err, any_cmd_err_s, any_cmd_err_q  : std_ulogic;

signal set_indirect_data_s                 : std_ulogic;
signal wpar_err                 : std_ulogic;
signal wpar_err_in, wpar_err_lt : std_ulogic;
signal par_data_in, par_data_lt : std_ulogic_vector(0 to par_nobits-1);
signal sc_rparity               : std_ulogic_vector(0 to par_nobits-1);

signal read_valid, write_valid  : std_ulogic;
signal dec_addr_in,  dec_addr_q : std_ulogic_vector(use_addr'range);
signal addr_v_i                 : std_ulogic_vector(0 to use_addr'high);
signal addr_nvld                : std_ulogic;
signal write_nvld, read_nvld    : std_ulogic;
signal state_par_error          : std_ulogic;
signal sat_id_net               : std_ulogic_vector(0 to satid_nobits-1);

signal unused                   : std_ulogic_vector(0 to 1);


signal scom_cch_in_int          : std_ulogic;
signal scom_dch_in_int          : std_ulogic;
signal scom_cch_out_int         : std_ulogic;
signal scom_dch_out_int         : std_ulogic;
signal scom_cch_input_s, scom_cch_input_q   : std_ulogic;
signal scom_dch_input_s, scom_dch_input_q   : std_ulogic;

signal spare_latch_d   : std_ulogic_vector(0 to 4);
signal spare_latch_q   : std_ulogic_vector(0 to 4);

signal indirect_addr_s, indirect_addr_q : std_ulogic_vector(0 to 19);  
signal indirect_data_s, indirect_data_q : std_ulogic_vector(0 to 31);  
signal cmd_addr_q   : std_ulogic_vector(0 to regid_nobits-1);  
signal indirect_rd_cmd, indirect_wr_cmd         : std_ulogic;  
signal read_indirect_reg                        : std_ulogic;  
signal indirect_rd_cmd_s, indirect_rd_cmd_q     : std_ulogic;  
signal indirect_wr_cmd_s, indirect_wr_cmd_q     : std_ulogic;  
signal indirect_access_overrun_s, indirect_access_overrun_q       : std_ulogic;  
signal indirect_addr_write      : std_ulogic;  
signal indirect_addr_reg_wr     : std_ulogic;  
signal init_pcb_user_status     : std_ulogic;  
signal indirect_acc             : std_ulogic;  
signal posted_indirect_access_s, posted_indirect_access_q : std_ulogic;  
signal any_posted_indirect_access : std_ulogic;  
signal any_indirect_access_overrun : std_ulogic;  
signal sc_rdata_i       : std_ulogic_vector(0 to width-1);  
signal sc_rdata_tx      : std_ulogic_vector(0 to width-1);  
signal fill_zero_11     : std_ulogic_vector(0 to 10);  
signal fill_zero_8      : std_ulogic_vector(0 to 7);  

signal rrfa_test_a      : std_ulogic;
signal rrfa_test_b      : std_ulogic;

signal unused_signals   : std_ulogic;
attribute analysis_not_referenced of unused_signals : signal is "true";
attribute analysis_not_referenced of unused : signal is "true";

constant VERSION_TAG          : std_ulogic_vector(0 to 23)  := x"151216";
signal   serial_scom_version  : std_ulogic_vector(0 to 23);
attribute analysis_not_referenced of serial_scom_version : signal is "true";




begin
 

   assert (or_reduce(use_addr)='1')
     report "pcb if component must use at least one address, generic use_addr is all zeroes"
     severity error;

   assert (use_addr'length<=2**reg_nobits) 
     report "use_addr is larger than 2^reg_nobits"
     severity error;


   assert (i_width > 0)
     report "has to be in the range of 1..64"
     severity error;

   assert (i_width < 65)
     report "has to be in the range of 1..64"
     severity error;
   

   parity_err : entity clib.c_direct_err_rpt
       generic map (
                  width           => 1     
                   )                                   
        port map (
                  vdd             => vdd,
                  gnd             => gnd,
                  err_in (0)     => state_par_error,
                  err_out(0)     => scom_err_in
               );

   scom_err <= scom_err_lt;    



  chksw_HW040380 <= chksw_q(0);  
  chksw_HW042465 <= chksw_q(1);  
  chksw_HW012345 <= chksw_q(2);  
  serial_scom_version <= VERSION_TAG;

  indirect_address_signal <= indirect_address;
  internal_addr_decode_signal <= tconv(internal_addr_decode);
  use_addr_signal <= use_addr;
  addr_is_rdable_signal <= addr_is_rdable;
  addr_is_wrable_signal <= addr_is_wrable;
  monitor_user_status_signal <= monitor_user_status;
  fill_zero_11 <= (others => '0'); 
  fill_zero_8 <= (others => '0'); 
   
  scom_cch_input_s <= scom_cch_in;
  scom_cch_in_int <= scom_cch_input_q;
  scom_dch_input_s <= scom_dch_in;
  scom_dch_in_int <= scom_dch_input_q;
  scom_cch_out <= scom_cch_out_int;
  scom_dch_out <= scom_dch_out_int;
  sc_ack_i <= sc_ack;
   
  cch_in    <= scom_cch_in_int & cch_lt(0);


  reset     <= (cch_lt(0) and not scom_cch_in_int)   
               or fsm_reset                          
               or scom_err_lt;                       
   
  local_act <= or_reduce (scom_cch_input_s & cch_lt & posted_indirect_access_q);

  local_act_int <= local_act or scom_local_act_lt or reset;    

  scom_local_act_in <= local_act;       
  scom_local_act <= scom_local_act_lt;

  scom_cch_out_int <= cch_lt(0);

  dch_out_internal_in <= head_lt(0)            when is_send_ulinfo='1' else
                         '0'                   when is_send_0    ='1' else
                         '1'                   when is_send_1    ='1' else
                         data_shifter_lt(0)    when (is_send_rdata and not do_send_par)='1' else
                         datapar_shifter_lt(0) when (is_send_rdata and     do_send_par)='1' else
                         dch_lt;

  scom_dch_out_int <= dch_out_internal_lt;

   sc_req_i  <= (is_exe_cmd_1 and (not read_indirect_reg) and (not any_cmd_err) and (not wpar_err))
                 or posted_indirect_access_q;
   
   sc_req    <= sc_req_i;
   sc_addr_i    <= head_lt(satid_nobits+1 to satid_regid_nobits);
   
   not_indirect_address_1: if (indirect_address = '0')  generate
      sc_wdata_mux(0 to (width-1)) <= sc_wdata_i(0 to (width-1));
   end generate not_indirect_address_1;

   is_indirect_address_1: if indirect_address = '1' generate
      sc_wdata_mux(0 to 47) <= sc_wdata_i(0 to 47);
      sc_wdata_mux(48 to 63) <= gate_and ((not indirect_wr_cmd_q), sc_wdata_i(48 to 63))
                                or
                                gate_and ((    indirect_wr_cmd_q), indirect_data_q(16 to 31));
   end generate is_indirect_address_1;
 
   sc_wdata <= sc_wdata_mux;
   
   sat_id_net <= sat_id;
  
   sc_r_nw_i_head <= head_lt(rw_bit_index);
   sc_r_nw <= sc_r_nw_i;
   
           
   not_indirect_address_0: if indirect_address = '0' generate
      sc_r_nw_i <= sc_r_nw_i_head;
      cmd_addr_q <= head_lt(satid_nobits+1 to satid_regid_nobits);
      sc_ack_sat <= sc_ack_i;
      indirect_acc <= '0';
      read_indirect_reg <= '0';
      indirect_rd_cmd  <= '0';
      indirect_wr_cmd  <= '0';
      init_pcb_user_status <= '0';
      sc_addr      <= sc_addr_i;
      indirect_addr_s <= (others => '0'); 
      indirect_data_s <= (others => '0');
      indirect_addr_write <=  '0';
      indirect_addr_reg_wr <=  '0';
      posted_indirect_access_s <= '0';
      indirect_rd_cmd_s   <= '0';
      indirect_rd_cmd_q   <= indirect_rd_cmd_s;
      indirect_wr_cmd_s   <= '0';
      indirect_wr_cmd_q   <= indirect_wr_cmd_s;
      indirect_access_overrun_s <= '0';
      any_posted_indirect_access <= '0';
      any_indirect_access_overrun <= '0';
      set_indirect_data_s  <= '0';
   end generate not_indirect_address_0;

   is_indirect_address_0: if indirect_address = '1' generate
      sc_ack_sat <= sc_ack_i or (addr_v_i(63) and do_read and is_exe_cmd_1);
      indirect_acc <= '1' when ((addr_v_i(63) = '1') and ((is_exe_cmd_0 or is_exe_cmd_1) = '1'))
                          else '0';
      read_indirect_reg <= addr_v_i(63) and      sc_r_nw_i_head  and (is_exe_cmd_0 or is_exe_cmd_1);
      indirect_rd_cmd   <= addr_v_i(63) and (not sc_r_nw_i_head) and (is_exe_cmd_0 or is_exe_cmd_1) and sc_wdata_i(0);
      indirect_wr_cmd   <= addr_v_i(63) and (not sc_r_nw_i_head) and (is_exe_cmd_0 or is_exe_cmd_1) and (not sc_wdata_i(0));
      indirect_rd_cmd_s <= (addr_v_i(63) and (not sc_r_nw_i_head) and is_exe_cmd_0 and      sc_wdata_i(0))
                           or
                           (indirect_rd_cmd_q and posted_indirect_access_q); 
      indirect_wr_cmd_s <= (addr_v_i(63) and (not sc_r_nw_i_head) and is_exe_cmd_0 and (not sc_wdata_i(0)))
                           or
                           (indirect_wr_cmd_q and posted_indirect_access_q);
      set_indirect_data_s <= (sc_r_nw_i_head and is_check_before and (not posted_indirect_access_q))
                             or
                             indirect_rd_cmd; 
      indirect_data_s(0) <= (set_indirect_data_s)
                            or
                            (indirect_data_q(0) and ((not is_idle) or posted_indirect_access_q));
      sc_r_nw_i <= indirect_data_q(0);
      init_pcb_user_status <= (indirect_rd_cmd or indirect_wr_cmd) and is_exe_cmd_0 and (not posted_indirect_access_q);
      indirect_addr_write <= addr_v_i(63) and  (not sc_r_nw_i_head) and is_exe_cmd_0 ;
      indirect_addr_s <= (sc_wdata_i(12 to 31)) when indirect_addr_write = '1'
                                                else indirect_addr_q;  
      indirect_addr_reg_wr <= addr_v_i(63) and is_exe_cmd_1 and sc_ack_i and (not sc_r_nw_i_head) and sc_wdata_i(0);
      indirect_data_s(16 to 31) <= sc_rdata_i(48 to 63) when ((posted_indirect_access_q or posted_indirect_access_s) and indirect_rd_cmd_q and sc_ack_i) = '1'
                                   else sc_wdata_i(48 to 63) when indirect_wr_cmd = '1' 
                                   else indirect_data_q(16 to 31);  
      indirect_data_s(1 to 3) <= sc_rdata_i(33 to 35) when (sc_ack_i and posted_indirect_access_q) = '1'   
                                 else ("001") when init_pcb_user_status = '1'
                                 else ("000") when (indirect_access_overrun_q and is_send_0) = '1' 
                                 else indirect_data_q(1 to 3);  
      indirect_data_s(4 to 7) <= (others => '0') when init_pcb_user_status = '1'
                                 else sc_rdata_i(36 to 39) when ((sc_ack_i or monitor_user_status_signal) and posted_indirect_access_q) = '1' 
                                 else indirect_data_q(4 to 7);  
      indirect_data_s(8 to 13) <= head_lt(satid_nobits+1 to satid_regid_nobits) when is_check_before = '1'
                                  else  indirect_data_q(8 to 13);
      cmd_addr_q <= head_lt(satid_nobits+1 to satid_regid_nobits) when is_check_before = '1'
                    else indirect_data_q(8 to 13);
      indirect_data_s(14) <= indirect_rd_cmd_s;
      indirect_rd_cmd_q   <= indirect_data_q(14);
      indirect_data_s(15) <= indirect_wr_cmd_s;
      indirect_wr_cmd_q   <= indirect_data_q(15);
      sc_addr      <= indirect_addr_q;
      posted_indirect_access_s <= ( indirect_addr_write  
                                    or posted_indirect_access_q )  
                                  and (not (indirect_addr_write and posted_indirect_access_q ))  
                                  and (not (sc_ack_i));  
      any_posted_indirect_access <= 
                                    indirect_rd_cmd_q or
                                    indirect_wr_cmd_q;
      any_indirect_access_overrun <= any_posted_indirect_access and is_exe_cmd_0
                                     and (indirect_rd_cmd or indirect_wr_cmd)
                                     and (not read_indirect_reg);
      indirect_access_overrun_s <=  any_indirect_access_overrun  
                                    or (is_exe_cmd_0 and sc_ack_i)  
                                    or (indirect_access_overrun_q and (not is_idle));  
   end generate is_indirect_address_0;
  
   sc_rdata_i <= sc_rdata;              
   
   not_indirect_address_2: if indirect_address = '0' generate
      sc_rdata_tx <= sc_rdata_i;
   end generate not_indirect_address_2;
   
   is_indirect_address_2: if indirect_address = '1' generate  
   sc_rdata_tx <= ('1' & fill_zero_11 & indirect_addr_q & (not posted_indirect_access_q) & indirect_data_q(1 to 7)
                  & fill_zero_8 & indirect_data_q(16 to 31)) when (addr_v_i(63) and do_read) = '1' 
                  else
                  sc_rdata_i;
   end generate is_indirect_address_2;  

   copy2sc_wdata_i: if width<64 generate
     copy2sc_wdata_i_loop_1: for i in 0 to width-1 generate
       sc_wdata_i(i) <= data_shifter_lt(i);
     end generate copy2sc_wdata_i_loop_1;
   end generate copy2sc_wdata_i;

   copy2sc_wdata_i_all: if width=64 generate
     sc_wdata_i     <= data_shifter_lt;
   end generate copy2sc_wdata_i_all;

   sc_wparity_i <= xor_reduce(datapar_shifter_lt);
   sc_wparity   <= sc_wparity_i;

   fsm_transition: process (state_lt, got_head, got_eofwdata, got_eofwpar,
                            got_ulhead, sent_rdata, p0_err, any_ack_error,
                            match, do_write, do_read,
                            cch_lt(0), dch_lt, sc_ack_sat, wpar_err, read_nvld, write_nvld, 
                            indirect_address_signal,
                            sc_ack_i,
                            chksw_HW042465, chksw_HW012345,
                            posted_indirect_access_q,
                            any_cmd_err,
                            indirect_access_overrun_q)

      begin
        next_state <= state_lt;
        case state_lt is
          when idle             => if dch_lt='1' then
                                      next_state <= rec_head;
                                   end if;
          when rec_head         => if (got_head)='1' then
                                     next_state <= check_before;
                                   end if;
          when check_before     => if match='0' then
                                     next_state <= not_selected;
                                   elsif ( (read_nvld or p0_err) and do_read)='1' then
                                     next_state <= filler0;
                                   elsif (not p0_err and not read_nvld and do_read)='1'  then
                                     next_state <= exe_cmd_1;
                                   else
                                     next_state <= rec_wdata;
                                   end if;
          when rec_wdata        => if got_eofwdata='1' then
                                     next_state <= rec_wpar;
                                   end if;
   
          when rec_wpar         => if (got_eofwpar and not p0_err and not write_nvld)='1' then
                                     next_state <= check_wpar;
                                   elsif (got_eofwpar and (p0_err or write_nvld))='1' then
                                     next_state <= filler0;
                                   end if;

          when check_wpar       => if ((wpar_err='0') and (indirect_address_signal ='0') and (sc_ack_i = '0') and (any_cmd_err='0')) then
                                        next_state <= exe_cmd_1;
                                     elsif ((wpar_err='0') and (indirect_address_signal ='1')  and (any_cmd_err='0')) then
                                        next_state <= exe_cmd_0;
                                   else
                                     next_state <= filler1;
                                   end if;
          when exe_cmd_0          => next_state <= exe_cmd_1;  
          when exe_cmd_1          => if (sc_ack_sat and (not posted_indirect_access_q)) ='1' then
                                        next_state <= filler1;
                                     elsif (posted_indirect_access_q) ='1' then
                                        next_state <= filler1;
                                     elsif (indirect_access_overrun_q) ='1' then
                                        next_state <= filler1;
                                     elsif (any_cmd_err or wpar_err or p0_err) ='1' then
                                        next_state <= filler1;
                                     end if;
          when filler0          => next_state <= filler1;
          when filler1          => next_state <= gen_ulinfo;
          when gen_ulinfo       => next_state <= send_ulinfo;
          when send_ulinfo      => if (chksw_HW012345='1') then  
                                     if (got_ulhead and (do_write or (do_read and any_ack_error)))='1' then
                                       next_state <= send_0;
                                     elsif (got_ulhead and do_read and not any_ack_error and chksw_HW042465)='1' then
                                       next_state <= send_rdata;
                                     elsif (got_ulhead and do_read and not chksw_HW042465)='1' then
                                       next_state <= send_rdata;
                                     end if;
                                   elsif (chksw_HW012345='0') then   
                                     if (got_ulhead and do_write)='1' then
                                       next_state <= send_0;
                                     elsif (got_ulhead and do_read)='1' then
                                       next_state <= send_rdata;
                                     end if;
                                   end if;
          when send_rdata       => if sent_rdata='1' then
                                     next_state <= send_0;
                                   end if;
          when send_0           => next_state <= send_1;
          when send_1           => next_state <= idle;

          when not_selected     => if cch_lt(0)='0' then
                                     next_state <= idle;
                                   end if;

          when others          => next_state <= idle;

        end case;

      end process fsm_transition;

      state_in <= state_lt when local_act='0' else
                  idle     when reset='1' else
                  next_state;

      state_par_error <= xor_reduce(state_lt);

      is_idle         <= (state_lt=idle);
      is_rec_head     <= (state_lt=rec_head);
      is_check_before <= (state_lt=check_before);
      is_rec_wdata    <= (state_lt=rec_wdata);
      is_rec_wpar     <= (state_lt=rec_wpar);
      is_check_wpar   <= (state_lt=check_wpar);
      is_exe_cmd_0    <= (state_lt=exe_cmd_0);
      is_exe_cmd_1    <= (state_lt=exe_cmd_1) xor rrfa_test_b;
      is_gen_ulinfo   <= (state_lt=gen_ulinfo);
      is_send_ulinfo  <= (state_lt=send_ulinfo);
      is_send_rdata   <= (state_lt=send_rdata);
      is_send_0       <= (state_lt=send_0);
      is_send_1       <= (state_lt=send_1);
      is_filler_0     <= (state_lt=filler0);
      is_filler_1     <= (state_lt=filler1);
      is_not_selected <= (state_lt=not_selected);

      enable_cnt <= is_rec_head
                    or is_check_before
                    or is_rec_wdata
                    or is_rec_wpar
                    or is_send_ulinfo
                    or is_send_rdata
                    or is_send_0
                    or is_send_1
                    ;
      cnt_in <= (others=>'0')      when ((is_idle or is_gen_ulinfo) = '1') else
                cnt_lt + "0000001" when (enable_cnt = '1') else
                cnt_lt;

      got_head      <= (cnt_lt = (1+satid_nobits+regid_nobits));

      got_ulhead    <= (cnt_lt = (1+satid_nobits+regid_nobits+4));

      got_eofwdata  <= (cnt_lt = eof_wdata);
      got_eofwpar   <= (cnt_lt = eof_wpar);

      sent_rdata    <= (cnt_lt=tconv(83,7));

      cntgtheadpluswidth   <= (cnt_lt > eof_wdata_n);
      cntgteofwdataplusparity <= (cnt_lt > eof_wpar_m);

      do_send_par   <= (cnt_lt > 79); 

      head_in(head_width-2 to head_width-1) <= head_lt(head_width-1) & dch_lt when (is_rec_head or (is_idle and dch_lt))='1' else
                           head_lt(head_width-2 to head_width-1);

      head_in(0 to satid_regid_nobits)  <= head_lt(1 to satid_regid_nobits) & head_mux when (is_rec_head or is_send_ulinfo)='1' else
                           head_lt(0 to satid_regid_nobits);

      head_mux <= head_lt(rw_bit_index) when is_rec_head='1' else
                  tail_lt(0);

      sc_ack_info_sat <=  (((write_nvld or read_nvld) & addr_nvld )
                            or sc_ack_info_lt(0 to 1)
                            or gate_and (ext_error_enable_q, sc_ack_info_lt(0 to 1))
                          );

      tail_in(4) <= xor_reduce ( parity_satid_regaddr_lt & tail_lt(0) & (tail_lt(1)) & sc_ack_info_lt(0 to 1))
                                                                    when is_gen_ulinfo='1'and (internal_addr_decode=false) else
                    xor_reduce ( parity_satid_regaddr_lt & tail_lt(0) & (tail_lt(1)) & sc_ack_info_sat )
                                                                    when is_gen_ulinfo='1'and (internal_addr_decode=true)
                    else tail_lt(4);



      tail_in(2 to 3) <= sc_ack_info_lt  when is_gen_ulinfo='1' and internal_addr_decode=false else
                         sc_ack_info_sat when is_gen_ulinfo='1' and internal_addr_decode=true else
                         tail_lt(3 to 4)              when is_send_ulinfo='1' else 
                         tail_lt(2 to 3); 





      tail_in(1)      <= tail_lt(2) when is_send_ulinfo='1' else  
                         '0'        when is_filler_1='1' else  
                         tail_lt(1);  

      tail_in(0)      <= p0_err                              when is_check_before='1' else 
                         ((wpar_err and do_write) or p0_err) when is_filler_1 ='1'    else 
                         tail_lt(1)                          when is_send_ulinfo='1'  else 
                         tail_lt(0);

      sc_ack_info_i <= sc_ack_info;
      sc_ack_info_in <= sc_ack_info_i when (is_exe_cmd_1 and sc_ack_i)='1' else
                        "00" when is_idle='1' else
                        sc_ack_info_lt;


      do_write <= not do_read;
      do_read  <= head_lt(rw_bit_index);
      match    <= (head_lt(1 to satid_nobits)=sat_id_net);

      p0_err_in <= '0' when (is_idle = '1') else
                   p0_err_lt xor head_in(parbit_index) when (is_rec_head = '1') else
                   p0_err_lt ;
      p0_err <= p0_err_lt;
      parity_satid_regaddr_in   <= xor_reduce (sat_id_net & head_lt(satid_nobits+1 to satid_regid_nobits)); 

      any_ack_error <= or_reduce(sc_ack_info_lt);


      data_mux <= dch_lt when (is_check_before or is_rec_wdata)='1' else
                  '0';

      data_shifter_in <= data_shifter_lt(1 to i_width-1) & data_mux when (is_check_before or
                                                                         (is_rec_wdata and not cntgtheadpluswidth) or
                                                                          is_send_rdata)='1' else
                         (sc_rdata_tx(0 to width-1) & (width to i_width-1 =>'0')) when (is_exe_cmd_1 and sc_ack_sat and do_read)='1' else
                         data_shifter_lt;
      par_mux <= dch_lt when (is_rec_wpar)='1' else
                 '0';

      datapar_shifter_in <= datapar_shifter_lt(1 to par_nobits-1) & par_mux when ((is_rec_wpar and not cntgteofwdataplusparity)or
                                                                                  (is_send_rdata and do_send_par))='1' else
                            sc_rparity when (is_filler_1 ='1') else  
                            datapar_shifter_lt;


      data_shifter_move_1: if (width = i_width) generate  
         data_shifter_lt_tmp (0 to width-1) <= data_shifter_lt;
         data_shifter_padding_1: if width < 64 generate
            data_shifter_lt_tmp(width to 63) <= (others=>'0');
         end generate data_shifter_padding_1;
      end generate data_shifter_move_1;

      data_shifter_move_2: if (width < i_width) generate
          data_shifter_lt_tmp(0 to width-1) <= data_shifter_lt(0 to width-1);
          data_shifter_lt_tmp(width to i_width-1) <= gate_and(    chksw_HW040380, (width to i_width-1 => '0')) or
                                                     gate_and(not chksw_HW040380, data_shifter_lt(width to i_width-1));
          data_shifter_padding_1: if i_width < 64 generate
             data_shifter_lt_tmp(i_width to 63) <= (others=>'0');
          end generate data_shifter_padding_1;
      end generate data_shifter_move_2;

      wdata_par_check: for i in 0 to par_nobits-1 generate
        par_data_in(i) <= xor_reduce(data_shifter_lt_tmp(16*i to 16*(i+1)-1));
      end generate wdata_par_check;

      wdata_par_check_pipe: if pipeline_paritychk=true generate
  state : entity latches.c_morph_dff
    generic map (
    width => par_nobits
    )
    port map (
       gckn      => lckn
     ,    e      => '1'
     , syncr      => syncr
     , asyncr      => asyncr
     , d      => par_data_in
     , q        => par_data_lt
     , vdd        => vdd
     , vss        => gnd
   );
      end generate wdata_par_check_pipe;

      wdata_par_check_nopipe: if pipeline_paritychk=false generate
        par_data_lt <= par_data_in;

      end generate wdata_par_check_nopipe;

      wpar_err_in   <= (or_reduce(par_data_in xor datapar_shifter_in)) when (is_check_wpar = '1')
                       else wpar_err_lt ; 
      wpar_err <= wpar_err_lt;

      rdata_parity_gen: for i in 0 to par_nobits-1 generate
        sc_rparity(i) <= xor_reduce(data_shifter_lt_tmp(16*i to 16*(i+1)-1));
      end generate rdata_parity_gen;
      
      
   internal_addr_decoding: if internal_addr_decode=true generate
     foralladdresses : for i in use_addr'range generate
       addr_bit_set : if (use_addr(i) = '1') generate
         dec_addr_in(i) <= (cmd_addr_q = tconv(i, reg_nobits));

         latch_for_onehot : if pipeline_addr_v(i) = '1' generate
  dec_addr : entity latches.c_morph_dff
    port map (
       gckn      => lckn
     ,    e      => '1'
     ,  syncr    => syncr
     ,  asyncr   => asyncr
      , d(0)      => dec_addr_in(i)
     , q(0)        => dec_addr_q(i)
     , vdd        => vdd
     , vss        => gnd
   );
         end generate latch_for_onehot;

         no_latch_for_onehot : if pipeline_addr_v(i) = '0' generate
           dec_addr_q(i) <= dec_addr_in(i);
         end generate no_latch_for_onehot;

       end generate addr_bit_set;
       addr_bit_notset : if (use_addr(i) /= '1') generate  
         dec_addr_in(i)                                     <= '0';
         dec_addr_q(i)                                      <= dec_addr_in(i);
       end generate addr_bit_notset;
     end generate foralladdresses;
     read_valid    <=  or_reduce(dec_addr_in and addr_is_rdable);
     write_valid   <=  or_reduce(dec_addr_in and addr_is_wrable);
     addr_nvld     <=  not or_reduce(dec_addr_in);
     write_nvld    <= (not write_valid and not addr_nvld) and do_write;  
     read_nvld     <= (not read_valid  and not addr_nvld) and do_read;  

     unused <= "00";
   end generate internal_addr_decoding;

   external_addr_decoding: if internal_addr_decode=false generate
     foralladdresses : for i in use_addr'range generate
         dec_addr_in(i)                                     <= '0';
         dec_addr_q(i)                                      <= dec_addr_in(i);
     end generate foralladdresses;
   read_valid <= '1';
   write_valid<= '1';
   addr_nvld <= '0';
   write_nvld <= '0';
   read_nvld  <= '0';

   unused <= write_valid & read_valid;
   end generate external_addr_decoding;
   any_cmd_err_s <= ( (is_check_before and (addr_nvld or write_nvld or read_nvld or p0_err)) or
                      (is_check_wpar and (wpar_err)) or
                      any_cmd_err_q
                    ) and (not is_idle);
   any_cmd_err <= any_cmd_err_s or any_cmd_err_q;

   short_unused_addr_range: for i in use_addr'high+1 to 63 generate
   end generate short_unused_addr_range;

   addr_v_i <= dec_addr_q(0 to use_addr'high);
   forward_addr_v_notindirect: if (indirect_address = '0') GENERATE
      addr_v <= addr_v_i;
   end GENERATE forward_addr_v_notindirect;
   
   forward_addr_v_indirect: if (indirect_address = '1') GENERATE
      addr_v(0 to 62) <= addr_v_i(0 to 62);
      addr_v(63) <= (addr_v_i(63) and (indirect_wr_cmd_s or indirect_wr_cmd_q or indirect_rd_cmd_s or indirect_rd_cmd_q))
                    xor rrfa_test_a;
   end GENERATE forward_addr_v_indirect; 
   


  state : entity latches.c_morph_dff
    generic map (
    width => state_width
    ,init => idle
    )
    port map (
       gckn      => lckn
     ,    e      => '1'
     ,  syncr    => syncr
     ,  asyncr   => asyncr
      , d      => state_in
     , q        => state_lt
     , vdd        => vdd
     , vss        => gnd
   );

  counter : entity latches.c_morph_dff
    generic map (
    width => 7
    ,init => "0000000"
    )
    port map (
       gckn      => lckn
     ,    e      => '1'
     ,  syncr    => syncr
     ,  asyncr   => asyncr
      , d      => cnt_in
     , q        => cnt_lt
     , vdd        => vdd
     , vss        => gnd
   );

  data_shifter : entity latches.c_morph_dff
    generic map (
    width => i_width
    )
    port map (
       gckn      => lckn
     ,    e      => '1'
     ,  syncr    => syncr
     ,  asyncr   => asyncr
      , d      => data_shifter_in
     , q        => data_shifter_lt
     , vdd        => vdd
     , vss        => gnd
   );

  datapar_shifter : entity latches.c_morph_dff
    generic map (
    width => par_nobits
    )
    port map (
       gckn      => lckn
     ,    e      => '1'
     ,  syncr    => syncr
     ,  asyncr   => asyncr
      , d      => datapar_shifter_in
     , q        => datapar_shifter_lt
     , vdd        => vdd
     , vss        => gnd
   );

  head_lat : entity latches.c_morph_dff
    generic map (
    width => head_width
    ,init => head_init
    )
    port map (
       gckn      => lckn
     ,    e      => '1'
     ,  syncr    => syncr
     ,  asyncr   => asyncr
      , d      => head_in
     , q        => head_lt
     , vdd        => vdd
     , vss        => gnd
   );

  tail_lat : entity latches.c_morph_dff
    generic map (
    width => 5
    ,init => "00000"
    )
    port map (
       gckn      => lckn
     ,    e      => '1'
     ,  syncr    => syncr
     ,  asyncr   => asyncr
      , d      => tail_in
     , q        => tail_lt
     , vdd        => vdd
     , vss        => gnd
   );

  dch_inlatch : entity latches.c_morph_dff
    port map (
       gckn      => lckn
     ,    e      => '1'
     ,  syncr    => syncr
     ,  asyncr   => asyncr
      , d(0)      => scom_dch_in_int
     , q(0)        => dch_lt
     , vdd        => vdd
     , vss        => gnd
   );


  ack_info : entity latches.c_morph_dff
    generic map (
    width => 2
    )
    port map (
       gckn      => lckn
     ,    e      => '1'
     ,  syncr    => syncr
     ,  asyncr   => asyncr
      , d      => sc_ack_info_in
     , q        => sc_ack_info_lt
     , vdd        => vdd
     , vss        => gnd
   );

  dch_outlatch : entity latches.c_morph_dff
    port map (
       gckn      => lckn
     ,    e      => '1'
     ,  syncr    => syncr
     ,  asyncr   => asyncr
      , d(0)      => dch_out_internal_in
     , q(0)        => dch_out_internal_lt
     , vdd        => vdd
     , vss        => gnd
   );

  cch_latches : entity latches.c_morph_dff
    generic map (
    width => 2
    )
    port map (
       gckn      => lckn
     ,    e      => '1'
     ,  syncr    => syncr
     ,  asyncr   => asyncr
      , d      => cch_in
     , q        => cch_lt
     , vdd        => vdd
     , vss        => gnd
   );

  scom_err_latch : entity latches.c_morph_dff
    port map (
       gckn      => lckn
     ,    e      => '1'
     ,  syncr    => syncr
     ,  asyncr   => asyncr
      , d(0)      => scom_err_in
     , q(0)        => scom_err_lt
     , vdd        => vdd
     , vss        => gnd
   );

  scom_local_act_latch : entity latches.c_morph_dff
    port map (
       gckn      => lckn
     ,    e      => '1'
     ,  syncr    => syncr
     ,  asyncr   => asyncr
      , d(0)      => scom_local_act_in
     , q(0)        => scom_local_act_lt
     , vdd        => vdd
     , vss        => gnd
   );

  spare_latch : entity latches.c_morph_dff
    generic map (
    width => 10
    ,init => "0000000000"
    )
    port map (
       gckn      => lckn
     ,    e      => '1'
     ,  syncr    => syncr
     ,  asyncr   => asyncr
      , d(0)      => spare_latch_d(0)
     , d(1)      => any_cmd_err_s
     , d(2)      => indirect_access_overrun_s
     , d(3)      => posted_indirect_access_s
     , d(4)      => spare_latch_d(1)
     , d(5)      => spare_latch_d(2)
     , d(6)      => spare_latch_d(3)
     , d(7)      => spare_latch_d(4)
     , d(8)      => '0'
     , d(9)      => '0'
     , q(0)        => spare_latch_q(0)
     , q(1)        => any_cmd_err_q
     , q(2)        => indirect_access_overrun_q
     , q(3)        => posted_indirect_access_q
     , q(4)        => spare_latch_q(1)
     , q(5)        => spare_latch_q(2)
     , q(6)        => spare_latch_q(3)
     , q(7)        => spare_latch_q(4)
     , q(8)        => rrfa_test_a
     , q(9)        => rrfa_test_b
     , vdd        => vdd
     , vss        => gnd
   );
   spare_latch_d(0 to 4) <= (others => '0');

  scom_cch_input_latch : entity latches.c_morph_dff
    port map (
       gckn      => lckn
     ,    e      => '1'
     ,  syncr    => syncr
     ,  asyncr   => asyncr
      , d(0)      => scom_cch_input_s
     , q(0)        => scom_cch_input_q
     , vdd        => vdd
     , vss        => gnd
   );

  scom_dch_input_latch : entity latches.c_morph_dff
    port map (
       gckn      => lckn
     ,    e      => '1'
     ,  syncr    => syncr
     ,  asyncr   => asyncr
      , d(0)      => scom_dch_input_s
     , q(0)        => scom_dch_input_q
     , vdd        => vdd
     , vss        => gnd
   );

  parity_reg1 : entity latches.c_morph_dff
    port map (
       gckn      => lckn
     ,    e      => '1'
     ,  syncr    => syncr
     ,  asyncr   => asyncr
      , d(0)      => parity_satid_regaddr_in
     , q(0)        => parity_satid_regaddr_lt
     , vdd        => vdd
     , vss        => gnd
   );

  p0_err_latch : entity latches.c_morph_dff
    port map (
       gckn      => lckn
     ,    e      => '1'
     ,  syncr    => syncr
     ,  asyncr   => asyncr
      , d(0)      => p0_err_in
     , q(0)        => p0_err_lt
     , vdd        => vdd
     , vss        => gnd
   );

  wpar_err_latch : entity latches.c_morph_dff
    port map (
       gckn      => lckn
     ,    e      => '1'
     ,  syncr    => syncr
     ,  asyncr   => asyncr
      , d(0)      => wpar_err_in
     , q(0)        => wpar_err_lt
     , vdd        => vdd
     , vss        => gnd
   );


  indirect_addressing_used: if (indirect_address = '1') GENERATE
  indirect_address_latch : entity latches.c_morph_dff
    generic map (
    width => 20 + 32
    )
    port map (
       gckn      => lckn
     ,    e      => '1'
     ,  syncr    => syncr
     ,  asyncr   => asyncr
     , d(0 to 19)      => indirect_addr_s
     , d(20 to 51)      => indirect_data_s
     , q(0 to 19)        => indirect_addr_q
     , q(20 to 51)        => indirect_data_q
     , vdd        => vdd
     , vss        => gnd
   );
  end GENERATE indirect_addressing_used;
   
  indirect_addressing_not_used: if (indirect_address = '0') GENERATE
      indirect_addr_q <= indirect_addr_s;
      indirect_data_q <= indirect_data_s;
   end GENERATE indirect_addressing_not_used;  

   

   chksw_q <= "000";

   ext_error_enable_q <= '1';


   unused_signals <= or_reduce ( is_filler_0 & is_filler_1
                     & spare_latch_q
                     &  internal_addr_decode_signal
                     & use_addr_signal
                     & addr_is_rdable_signal
                     & addr_is_wrable_signal
                     & par_data_lt
                     & chksw_HW040380
                     & indirect_address_signal
                     & sc_addr_i
                     & indirect_addr_q
                     & data_shifter_lt_tmp
                     & indirect_rd_cmd
                     & indirect_wr_cmd
                     & fill_zero_11
                     & fill_zero_8
                     & indirect_data_q
                     & indirect_addr_write
                     & indirect_addr_reg_wr
                     & is_exe_cmd_0
                     & posted_indirect_access_q
                     & indirect_rd_cmd_q
                     & indirect_wr_cmd_q
                     & init_pcb_user_status
                     & read_indirect_reg
                     & monitor_user_status_signal
                     & any_posted_indirect_access
                     & any_indirect_access_overrun
                     & is_not_selected
                     & set_indirect_data_s
                     & sc_r_nw_i_head
                     & indirect_acc
                     & rrfa_test_a
                     & dcfg_lckn) ;


end c_serial_scom_comp;
