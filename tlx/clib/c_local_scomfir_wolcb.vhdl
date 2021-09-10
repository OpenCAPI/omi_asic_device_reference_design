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




library ieee,ibm,latches,clib, support;
use ieee.std_logic_1164.all;
use ibm.synthesis_support.all;
use ibm.std_ulogic_support.all;
use ibm.std_ulogic_function_support.all;
use support.power_logic_pkg.all;
use support.logic_support_pkg.all;
use work.c_utilities_pkg.all;


ENTITY c_local_scomfir_wolcb IS
 GENERIC
  ( fir_width                   : positive := 62    
  ; scom_width                  : positive := 64    
  ; ratio                       : std_ulogic := '0' 
  ; apply_scom_reg_phase_hold   : boolean := false
  ; apply_fir_phase_hold        : boolean := false  
  ; apply_fir_output_phase_hold : boolean := false  
  ; fir_divide2                 : boolean := false  
  ; use_wof_ctl                 : boolean := false  
  ; use_temp_mask               : boolean := false  
  ; use_external_fence          : boolean := false  
  ; use_l2_core_mode            : boolean := false  
  ; use_recov_reset             : boolean := false  
  ; fir_actions                 : integer range 0 to 2 := 2
  ; no_wof_mode                 : boolean := false  
  ; fir_mask_init               : std_ulogic_vector := "00000000000000000000000000000000000000000000000000000000000000"  
  ; fir_mask_par_init           : std_ulogic_vector := "0"                                                                
  ; fir_action0_init            : std_ulogic_vector := "00000000000000000000000000000000000000000000000000000000000000"  
  ; fir_action0_par_init        : std_ulogic_vector := "0"                                                             
  ; fir_action1_init            : std_ulogic_vector := "00000000000000000000000000000000000000000000000000000000000000"  
  ; fir_action1_par_init        : std_ulogic_vector := "0"                                                             
  ; implement_mchk              : boolean := false   
  ; use_addr             : std_ulogic_vector :=             "0" 
  ; addr_is_rdable       : std_ulogic_vector :=             "0" 
  ; addr_is_wrable       : std_ulogic_vector :=             "0" 
  ; pipeline_addr_v      : std_ulogic_vector := "000000000000" 
  ; pipeline_paritychk   : boolean  := false 
  ; satid_nobits         : positive := 4     
  ; indirect_address     : std_ulogic := '0' 
  ; monitor_user_status  : std_ulogic := '0' 
  ; lfir_inline                 : boolean := false 
  ; lfir_reset_hold             : boolean := false 
  ; lfir_mask_reset_value       : std_ulogic_vector := "000"
  );
  PORT
    ( 
     vdd                     : inout power_logic
    ; gnd                     : inout power_logic

	 ; func2_lckn			  : in std_ulogic := '1'
	 ; func_lckn			  : in std_ulogic := '1' 
	 ; func_out_lckn		  : in std_ulogic := '1'
	 ; scom_lckn			  : in std_ulogic := '1'
	 ; gen_lckn				  : in std_ulogic := '1'

    ; asyncr                  : in  std_ulogic :='0'
    ; syncr                   : in  std_ulogic :='0'

    ; scom_e                  : in  std_ulogic :='1'
    ; func_e                  : in  std_ulogic :='1'
    ; func_out_e              : in  std_ulogic :='1'   
    ; func2_e                 : in  std_ulogic :='1'
    ; gen_e                   : in  std_ulogic :='1'

    ; sys_xstop_in            : IN  std_ulogic := '0'
    ; error_in                : IN  std_ulogic_vector(0 to fir_width-1) 
    ; xstop_err               : OUT std_ulogic                          
    ; recov_err               : OUT std_ulogic                          
    ; recov_int               : OUT std_ulogic                          
    ; mchk_out                : OUT std_ulogic                          

    ; trace_error             : OUT std_ulogic                          
    ; secure_enable           : in  std_ulogic := '0'

    ; fir_out                 : OUT std_ulogic_vector(0 to fir_width-1) 
    ; fir_mask_out            : OUT std_ulogic_vector(0 to fir_width-1) 

    ; wof_ctl                 : IN  std_ulogic := '0'
    ; recov_reset             : IN  std_ulogic := '0'                   
    ; reset_err_rpt           : IN  std_ulogic := '0'                   
    ; fence_in                : IN  std_ulogic_vector(0 to fir_width-1) := (others => '0')  
    ; temp_mask_in            : IN  std_ulogic_vector(0 to fir_width-1) := (others => '0')  
    ; sat_id                  : in  std_ulogic_vector(0 to satid_nobits-1)

    ; scom_dch_in             : in  std_ulogic
    ; scom_cch_in             : in  std_ulogic
    ; scom_dch_out            : out std_ulogic
    ; scom_cch_out            : out std_ulogic



    ; scactive               : out std_ulogic                  
    ; scom_local_clk_gate    : out std_ulogic                  
    ; sc_req                 : out std_ulogic
    ; sc_ack                 : in  std_ulogic
    ; sc_ack_info            : in  std_ulogic_vector(0 to 1) := "00"  
    ; sc_r_nw                : out std_ulogic
    ; sc_addr_v              : out std_ulogic_vector(12 to 11+ use_addr'length) 
    ; sc_rdata               : in  std_ulogic_vector(0 to scom_width-1)
    ; sc_wdata               : out std_ulogic_vector(0 to scom_width-1)
    ; sc_wparity             : out std_ulogic

    ; sc_addr                : out std_ulogic_vector(0 to 19) 
    );



ATTRIBUTE BLOCK_TYPE OF c_local_scomfir_wolcb : ENTITY IS leaf;
attribute BLOCK_DATA of c_local_scomfir_wolcb  : entity is "SCAN_FLATTEN=/NO/";

ATTRIBUTE POWER_PIN of vdd : signal is 1;
ATTRIBUTE PIN_DEFAULT_POWER_DOMAIN of c_local_scomfir_wolcb : entity is "VDD";
ATTRIBUTE GROUND_PIN of gnd : signal is 1;
ATTRIBUTE PIN_DEFAULT_GROUND_DOMAIN of c_local_scomfir_wolcb : entity is "GND";

END c_local_scomfir_wolcb;


ARCHITECTURE c_local_scomfir_wolcb OF c_local_scomfir_wolcb IS

CONSTANT use_addr_int_short : std_ulogic_vector  := "111111" & bool2ulogic(fir_actions>1) & bool2ulogic(fir_actions>0) & bool2ulogic(no_wof_mode=false) & bool2ulogic(use_l2_core_mode=true) & "11" & use_addr;
CONSTANT use_addr_int       : std_ulogic_vector  := use_addr_int_short                                           & (11 to 63 => '0');
CONSTANT addr_is_rdable_int : std_ulogic_vector  := "100100" & bool2ulogic(fir_actions>1) & bool2ulogic(fir_actions>0) & bool2ulogic(no_wof_mode=false) & bool2ulogic(use_l2_core_mode=true) & "11" & addr_is_rdable  & (13 to 63 => '0');
CONSTANT addr_is_wrable_int : std_ulogic_vector  := "111111" & bool2ulogic(fir_actions>1) & bool2ulogic(fir_actions>0) & bool2ulogic(no_wof_mode=false) & bool2ulogic(use_l2_core_mode=true) & "11" & addr_is_wrable  & (13 to 63 => '0');
constant addr_width         : integer := use_addr_int_short'length-1 + tconv(indirect_address)*(64-use_addr_int_short'length);
constant regid_nobits       : integer := 10 - satid_nobits;

SIGNAL sc_r_nw_int      : std_ulogic;
SIGNAL sc_req_ext_int   : std_ulogic;
SIGNAL sc_req_scom_int  : std_ulogic;
SIGNAL sc_req_fir_int   : std_ulogic;
SIGNAL sc_ack_int       : std_ulogic;
SIGNAL scactive_int     : std_ulogic;
SIGNAL addr_v_int       : std_ulogic_vector(0 to addr_width);
SIGNAL sc_addr_int      : std_ulogic_vector(0 to ((regid_nobits-1) + ( tconv(indirect_address) * (20 - regid_nobits)))); 

SIGNAL sc_rdata_int     : std_ulogic_vector(0 to scom_width-1);
SIGNAL sc_wdata_int     : std_ulogic_vector(0 to scom_width-1);
SIGNAL fir_sc_rdata     : std_ulogic_vector(0 to fir_width+1);
SIGNAL sc_wparity_int   : std_ulogic;
SIGNAL sc_wparity_fir_int: std_ulogic;

SIGNAL fir_sc_ack       : std_ulogic;
SIGNAL scom_err         : std_ulogic;

SIGNAL fence_in_int     : std_ulogic_vector(0 TO fir_width+1);
SIGNAL temp_mask_in_int : std_ulogic_vector(0 TO fir_width+1);

SIGNAL fir_out_int      : std_ulogic_vector(0 to fir_width+1);
SIGNAL fir_mask_out_int : std_ulogic_vector(0 to fir_width+1);

SIGNAL error_in_int     : std_ulogic_vector(0 TO fir_width+1);
SIGNAL fir_parity_err   : std_ulogic;

SIGNAL bogus : std_ulogic;
ATTRIBUTE analysis_not_referenced of bogus : signal is "true";



BEGIN

  ASSERT (((fir_width + 1) <= scom_width ) AND (fir_width > 1))
    REPORT "SCOM Data width error, component instantiation must have width > 1 AND <= scom_width"
    SEVERITY ERROR;

  verify: if (((fir_width + 1) > scom_width) OR (fir_width < 1)) GENERATE
    sc_rdata_int(0 to 0) <= sc_wdata_int(0 to scom_width);
  END GENERATE verify;




lem_fir: entity clib.c_local_fir_wolcb
  generic map
   ( width                   => fir_width + 2
   , apply_phase_hold        => apply_fir_phase_hold
   , use_wof_ctl             => use_wof_ctl
   , apply_output_phase_hold => apply_fir_output_phase_hold
   , apply_scom_phase_hold   => apply_scom_reg_phase_hold
   , fir_divide2             => fir_divide2
   , use_external_fence      => use_external_fence
   , use_temp_mask           => use_temp_mask
   , fir_actions             => fir_actions
   , no_wof_mode             => no_wof_mode
   , fir_mask_init           => fir_mask_init & "11"
   , fir_mask_par_init       => fir_mask_par_init
   , fir_action0_init        => fir_action0_init & "00"
   , fir_action0_par_init    => fir_action0_par_init
   , fir_action1_init        => fir_action1_init & "00"
   , fir_action1_par_init    => fir_action1_par_init
   , use_recov_reset         => use_recov_reset
   , use_l2_core_mode        => use_l2_core_mode
   , implement_mchk          => implement_mchk
   , inline                  => lfir_inline
   , reset_hold              => lfir_reset_hold
   , mask_reset_value        => lfir_mask_reset_value
   )
   port map (

      vdd                    => vdd
     , gnd                    => gnd

	 , func2_lckn			  => func2_lckn
	 , func_lckn			  => func_lckn
	 , func_out_lckn		  => func_out_lckn
	 , scom_lckn			  => scom_lckn
	 , gen_lckn				  => gen_lckn
     , asyncr    => asyncr
     , syncr     => syncr

    , scom_e       =>  scom_e         
    , func_e       =>  func_e         
    , func_out_e   =>  func_out_e            
    , func2_e      =>  func2_e         
    , gen_e        =>  gen_e           

     , sys_xstop_in           => sys_xstop_in
     , error_in               => error_in_int
     , xstop_err              => xstop_err
     , recov_err              => recov_err
     , recov_int              => recov_int
     , mchk_out               => mchk_out
     , trace_error            => trace_error
     , secure_enable          => secure_enable

     , temp_mask_in           => temp_mask_in_int
     , fence_in               => fence_in_int
     , wof_ctl                => wof_ctl

     , fir_out                => fir_out_int
     , fir_mask_out           => fir_mask_out_int

     , recov_reset            => recov_reset
     , reset_err_rpt          => reset_err_rpt

     , fir_parity_err         => fir_parity_err

     , addrv                  => addr_v_int(0 to 11)
     , bus_r_nw               => sc_r_nw_int
     , bus_req                => sc_req_fir_int
     , bus_wdata              => sc_wdata_int(0 to fir_width+1)
     , bus_wparity            => sc_wparity_fir_int
     , bus_ack                => fir_sc_ack
     , bus_rdata              => fir_sc_rdata(0 to fir_width+1)

     , bus_act                => scactive_int
    );


  parco: entity clib.c_local_fir_parco
    generic map(
      scom_width => scom_width,
      fir_width  => fir_width + 2
    )
    port map (
      vdd            => vdd,
      gnd            => gnd,
      bus_wdata      => sc_wdata_int,
      bus_wparity    => sc_wparity_int,
      fir_wparity    => sc_wparity_fir_int
    );

 

  scomsat: entity clib.c_serial_scom_wolcb
     generic map
     ( width                => scom_width
     , internal_addr_decode => true
     , use_addr             => use_addr_int      (0 to addr_width)
     , addr_is_rdable       => addr_is_rdable_int(0 to addr_width)
     , addr_is_wrable       => addr_is_wrable_int(0 to addr_width)
     , pipeline_addr_v      => pipeline_addr_v
     , pipeline_paritychk   => pipeline_paritychk
     , satid_nobits         => satid_nobits
     , regid_nobits         => regid_nobits
     , indirect_address     => indirect_address
     , monitor_user_status  => monitor_user_status
     , ratio                => ratio
     )
     port map (
      vdd                      => vdd
     , gnd                      => gnd
     , lckn					   => func_lckn
     , scom_local_act          => scactive_int
	, local_act_int			   => open

     , dcfg_lckn               => func2_lckn

     , asyncr    => asyncr
     , syncr     => syncr 
     , sat_id                  => sat_id

     , scom_dch_in             => scom_dch_in
     , scom_cch_in             => scom_cch_in
     , scom_dch_out            => scom_dch_out
     , scom_cch_out            => scom_cch_out

     , sc_req                  => sc_req_scom_int
     , sc_ack                  => sc_ack_int
     , sc_ack_info             => sc_ack_info
     , sc_r_nw                 => sc_r_nw_int
     , sc_addr                 => sc_addr_int
     , addr_v                  => addr_v_int
     , sc_rdata                => sc_rdata_int
     , sc_wdata                => sc_wdata_int
     , sc_wparity              => sc_wparity_int
     , scom_err                => scom_err
     , fsm_reset               => '0'
    );

  scactive          <= scactive_int;
  scom_local_clk_gate <= not scactive_int;

  sc_req_fir_int    <= sc_req_scom_int and or_reduce(addr_v_int(0 to 11));                  
  sc_req_ext_int    <= sc_req_scom_int and or_reduce('0'& addr_v_int(12 to use_addr'length+11)); 
  sc_req            <= sc_req_ext_int;
  sc_r_nw           <= sc_r_nw_int;
  sc_addr_v         <= addr_v_int(12 to use_addr'length+11);
  sc_wdata          <= sc_wdata_int;
  sc_wparity        <= sc_wparity_int;

  sc_ack_int        <= sc_ack      or fir_sc_ack;

  sc_rdata_int(0 to fir_width+1) <= gate(fir_sc_rdata(0 to fir_width+1) , sc_req_fir_int)
                                 or gate(sc_rdata(0 to fir_width+1)     , sc_req_ext_int);
  remaining_data: if (fir_width+2 < scom_width) generate
      sc_rdata_int(fir_width+2 to scom_width-1) <= gate(sc_rdata(fir_width+2 to scom_width-1),sc_req_ext_int);
  end generate remaining_data;

  sc_addr_direct: if (not tconv(indirect_address)) generate
    sc_addr  <= (others => '0');
  end generate sc_addr_direct;

  sc_addr_indirect: if (tconv(indirect_address)) generate
    sc_addr  <= sc_addr_int;
  end generate sc_addr_indirect;

  error_in_int      <= error_in & fir_parity_err & scom_err ;

  fir_out           <= fir_out_int(0 to fir_width-1);

  temp_mask_in_int  <= temp_mask_in & "00";
  fence_in_int      <= fence_in     & "00";

  fir_mask_out      <= fir_mask_out_int(0 TO fir_width-1);
  bogus             <= OR_reduce(fir_out_int(fir_width to fir_width+1) & fir_mask_out_int(fir_width to fir_width+1) & addr_v_int & sc_addr_int & fir_sc_rdata(fir_width+1));


END c_local_scomfir_wolcb;
