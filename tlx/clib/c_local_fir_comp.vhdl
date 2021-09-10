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


ENTITY c_local_fir_comp IS
 GENERIC
  ( width              : POSITIVE := 64     
  ; use_l2_core_mode   : boolean := false   
  ; implement_mchk     : boolean := false  
  ; fir_actions        : integer range 0 to 2 := 2
  ; no_wof_mode        : boolean := false  
  ; use_recov_reset    : boolean := false  
  ; fir_mask_init         : std_ulogic_vector := "0000000000000000000000000000000000000000000000000000000000000000"  
  ; fir_mask_par_init     : std_ulogic_vector := "0"                                                                 
  ; fir_action0_init      : std_ulogic_vector := "0000000000000000000000000000000000000000000000000000000000000000"  
  ; fir_action0_par_init  : std_ulogic_vector := "0"                                                                 
  ; fir_action1_init      : std_ulogic_vector := "0000000000000000000000000000000000000000000000000000000000000000"  
  ; fir_action1_par_init  : std_ulogic_vector := "0"                                                                 

  ; use_wof_ctl        : boolean := false   
  ; apply_phase_hold   : boolean := false   
  ; apply_output_phase_hold : boolean := false 
  ; apply_scom_phase_hold   : boolean := false 
  ; use_external_fence : boolean := false  
  ; use_temp_mask      : boolean := false  
  ; fir_divide2        : boolean := false  

  ; secure_masks       : boolean := false  

  ; inline       : boolean := false 
  ; reset_hold   : boolean := false 
  ; mask_reset_value  : std_ulogic_vector := "000"
  );
  PORT
    (
      vdd                     : inout power_logic
    ; gnd                     : inout power_logic

   ; func_lckn               : in  std_ulogic := '1'
   ; func_out_lckn           : in  std_ulogic := '1'
   ; func2_lckn               : in  std_ulogic := '1'
    ; scom_lckn               : in  std_ulogic := '1'
    ; gen_lckn                : in  std_ulogic := '1'
    
   ; asyncr                  : in  std_ulogic :='0'
   ; syncr                   : in  std_ulogic :='0'  

   ; scom_e                  : in  std_ulogic :='1'
   ; func_e                  : in  std_ulogic :='1'
   ; func_out_e              : in  std_ulogic :='1'   
   ; func2_e                  : in  std_ulogic :='1'
   ; gen_e                   : in  std_ulogic :='1'

    ; error_in                : IN  std_ulogic_vector(0 to width-1)  
    ; xstop_err               : OUT std_ulogic                       
    ; recov_err               : OUT std_ulogic                       
    ; recov_int               : OUT std_ulogic                       
    ; mchk_out                : OUT std_ulogic                       

    ; trace_error             : OUT std_ulogic                       
    ; secure_enable           : in  std_ulogic := '0'                
    ; secure_xstop            : in  std_ulogic := '0'                

    ; sys_xstop_in            : IN  std_ulogic := '0' 
    ; wof_ctl                 : IN  std_ulogic := '0' 
    ; temp_mask_in            : IN  std_ulogic_vector(0 to width-1) := (others => '0')  
    ; fence_in                : IN  std_ulogic_vector(0 to width-1) := (others => '0')  
    ; fir_out                 : OUT std_ulogic_vector(0 to width-1) 
    ; fir_mask_out            : OUT std_ulogic_vector(0 to width-1) 

    ; recov_reset             : IN  std_ulogic := '0'               
    ; reset_err_rpt           : IN  std_ulogic := '0'               

    ; fir_parity_err          : OUT std_ulogic                      
    ; fir_active              : out std_ulogic                      

    ; addrv                   : in  std_ulogic_vector(0 to 11)       
    ; bus_r_nw                : in  std_ulogic                      
    ; bus_req                 : in  std_ulogic                      
    ; bus_wdata               : in  std_ulogic_vector(0 to width-1) 
    ; bus_wparity             : in  std_ulogic
    ; bus_ack                 : out std_ulogic                      
    ; bus_rdata               : out std_ulogic_vector(0 to width-1) 


    );

ATTRIBUTE BLOCK_TYPE OF c_local_fir_comp : ENTITY IS leaf;
attribute BLOCK_DATA of c_local_fir_comp  : entity is "SCAN_FLATTEN=/NO/";
ATTRIBUTE POWER_PIN of vdd : signal is 1;
ATTRIBUTE PIN_DEFAULT_POWER_DOMAIN of c_local_fir_comp : entity is "VDD";
ATTRIBUTE GROUND_PIN of gnd : signal is 1;
ATTRIBUTE PIN_DEFAULT_GROUND_DOMAIN of c_local_fir_comp : entity is "GND";

END c_local_fir_comp;

ARCHITECTURE c_local_fir_comp OF c_local_fir_comp IS

signal bogus : std_ulogic;
attribute analysis_not_referenced of bogus : signal is "true";

SIGNAL gate_action0     : std_ulogic;
SIGNAL gate_action1     : std_ulogic;

SIGNAL data_ones        : std_ulogic_vector(0 to width-1);
SIGNAL or_fir           : std_ulogic_vector(0 to width-1);
SIGNAL and_fir          : std_ulogic_vector(0 to width-1);
SIGNAL or_mask          : std_ulogic_vector(0 to width-1);
SIGNAL and_mask         : std_ulogic_vector(0 to width-1);
SIGNAL fir_action0_in   : std_ulogic_vector(0 to width-1);
SIGNAL fir_action0_lt   : std_ulogic_vector(0 to width-1);
SIGNAL fir_action0_par_in  : std_ulogic                  ;
SIGNAL fir_action0_par_lt  : std_ulogic                  ;
SIGNAL fir_action0_par_err : std_ulogic                  ;
SIGNAL fir_action1_in   : std_ulogic_vector(0 to width-1);
SIGNAL fir_action1_lt   : std_ulogic_vector(0 to width-1);
SIGNAL fir_action1_par_in  : std_ulogic                  ;
SIGNAL fir_action1_par_lt  : std_ulogic                  ;
SIGNAL fir_action1_par_err : std_ulogic                  ;
SIGNAL fir_output       : std_ulogic_vector(0 to width-1);
SIGNAL fir_masked       : std_ulogic_vector(0 to width-1);
SIGNAL fir_mask_lt      : std_ulogic_vector(0 to width-1);
SIGNAL fir_mask_in      : std_ulogic_vector(0 to width-1);
SIGNAL fir_mask_par_in  : std_ulogic                     ;
SIGNAL fir_mask_par_lt  : std_ulogic                     ;
SIGNAL gen_fir_mask_par_in  : std_ulogic                 ;
SIGNAL gen_fir_mask_par_lt  : std_ulogic                 ;
SIGNAL fir_mask_par_err : std_ulogic                     ;
SIGNAL fir_reset        : std_ulogic_vector(0 to width-1);
SIGNAL error_input      : std_ulogic_vector(0 to width-1);
SIGNAL fir_error_in_reef: std_ulogic_vector(0 to width-1);
SIGNAL fir_in           : std_ulogic_vector(0 to width-1);
SIGNAL fir_lt           : std_ulogic_vector(0 to width-1);
SIGNAL wof_in           : std_ulogic_vector(0 to width-1);
SIGNAL wof_lt           : std_ulogic_vector(0 to width-1);
SIGNAL wofb_lt          : std_ulogic_vector(0 to width-1);
SIGNAL sys_xstop_lt     : std_ulogic                     ;

SIGNAL block_fir        : std_ulogic;
SIGNAL block_wof        : std_ulogic;
SIGNAL or_fir_load      : std_ulogic;
SIGNAL and_fir_ones     : std_ulogic;
SIGNAL and_fir_load     : std_ulogic;
SIGNAL or_mask_load     : std_ulogic;
SIGNAL and_mask_ones    : std_ulogic;
SIGNAL and_mask_load    : std_ulogic;
SIGNAL recov_in         : std_ulogic;
SIGNAL recov_lt         : std_ulogic;
SIGNAL recov_int_in     : std_ulogic;
SIGNAL recov_int_lt     : std_ulogic;
SIGNAL xstop_in         : std_ulogic;
SIGNAL xstop_lt         : std_ulogic;
SIGNAL trace_error_in   : std_ulogic;
SIGNAL trace_error_lt   : std_ulogic;
SIGNAL wof_freeze_mode_lt : std_ulogic;

SIGNAL scwrite_in       : std_ulogic;
SIGNAL scwrite_lt       : std_ulogic;
SIGNAL scwrite_lt2      : std_ulogic;

constant err_rpt_width : integer := 3;
SIGNAL par_err_in       : std_ulogic_vector(0 TO err_rpt_width-1);
SIGNAL par_err_out      : std_ulogic_vector(0 TO err_rpt_width-1);
SIGNAL reset            : std_ulogic_vector(0 to err_rpt_width-1);
SIGNAL reset_or_hold    : std_ulogic_vector(0 to err_rpt_width-1);
SIGNAL reset_hold_latch   : std_ulogic_vector(0 to 63);
signal err_hold_lat     : std_ulogic_vector(0 to 63);
signal err_mask_in      : std_ulogic_vector(0 to 63);
signal err_mask_lat     : std_ulogic_vector(0 to 63);

SIGNAL bus_req_int         : std_ulogic;
SIGNAL bus_ack_latch_in    : std_ulogic;
SIGNAL bus_ack_latch_lt    : std_ulogic;

SIGNAL tiedn            : std_ulogic;
SIGNAL tieup            : std_ulogic;

signal fir_active_int       : std_ulogic;
signal secure_xstop_int     : std_ulogic;

SIGNAL unused           : std_ulogic;
  attribute analysis_not_referenced of unused : signal is "true";
SIGNAL unused_errors    : std_ulogic;
  attribute analysis_not_referenced of unused_errors : signal is "true";

constant zero_init      : std_ulogic_vector(0 to 63) := (others => '0');





BEGIN
 
  tiedn <= '0';
  tieup <= '1';
  data_ones <= (others => '1');
  bogus   <= OR_reduce(fir_action0_par_lt & fir_action1_par_lt & recov_reset
                       & wof_freeze_mode_lt & temp_mask_in & block_wof & tiedn
                       & wof_in & fence_in & tieup & scwrite_lt & wof_ctl
                       & fir_output & fir_active_int
                       & err_mask_in(err_rpt_width to 63)
                       & reset_hold_latch(err_rpt_width to 63));

  fir_active_int <= OR_REDUCE(addrv(6 to 11)) and scwrite_lt;
  fir_active     <= fir_active_int;


  ASSERT NOT (implement_mchk AND (fir_actions /= 2))
    REPORT "fir_actions error, must be set to 2 if implement_mchk is specified"
    SEVERITY ERROR;

  ASSERT ((width > 5) AND (width <= 64))
    REPORT "SCOM Data width error, component instantiation must have width > 5 OR <= 64"
    SEVERITY ERROR;

  ASSERT (fir_mask_init'length = width)
   REPORT "fir_mask_init width error, fir_mask_init must be same width as the component instantiation"
   SEVERITY ERROR;

  ASSERT (fir_action0_init'length = width)
   REPORT "fir_action0_init width error, fir_action0_init must be same width as the component instantiation"
   SEVERITY ERROR;

  ASSERT (fir_action1_init'length = width)
   REPORT "fir_action1_init width error, fir_action1_init must be same width as the component instantiation"
   SEVERITY ERROR;                                                     

  verify: if ((width <= 5) OR (width >64)) GENERATE
    fir_in(0 to 95) <= fir_lt(0 to width);
  END GENERATE verify;

  verify_mask: if (fir_mask_init'length /= width) GENERATE   
    fir_in(0 to 95) <= fir_lt(0 to width);
  END GENERATE verify_mask;

  verify_action0: if (fir_action0_init'length /= width) GENERATE   
    fir_in(0 to 95) <= fir_lt(0 to width);
  END GENERATE verify_action0;

  verify_action1: if (fir_action1_init'length /= width) GENERATE   
    fir_in(0 to 95) <= fir_lt(0 to width);
  END GENERATE verify_action1;

  fir_out      <= fir_lt;
  fir_mask_out <= fir_mask_lt;

  do_action0: IF (fir_actions = 2) GENERATE
  fir_action0 : entity latches.c_morph_dff
    generic map (
    width => width
    ,init => fir_action0_init
    )
    port map (
       gckn      => scom_lckn
     ,    e      => scom_e
     , asyncr    => asyncr
     , syncr     => syncr 
     , d      => fir_action0_in
     , q        => fir_action0_lt
     , vdd        => vdd
     , vss        => gnd
   );

  fir_action0_par : entity latches.c_morph_dff
    generic map (
    init => fir_action0_par_init
    )
    port map (
       gckn      => scom_lckn
     ,    e      => scom_e
     , asyncr    => asyncr
     , syncr     => syncr   
     , d(0)      => fir_action0_par_in
     , q(0)        => fir_action0_par_lt
     , vdd        => vdd
     , vss        => gnd
   );
  END GENERATE do_action0;

  do_action1: IF (fir_actions > 0) GENERATE
  fir_action1 : entity latches.c_morph_dff
    generic map (
    width => width
    ,init => fir_action1_init
    )
    port map (
       gckn      => scom_lckn
     ,    e      => scom_e
     , asyncr    => asyncr
     , syncr     => syncr   
     , d      => fir_action1_in
     , q        => fir_action1_lt
     , vdd        => vdd
     , vss        => gnd
   );

  fir_action1_par : entity latches.c_morph_dff
    generic map (
    init => fir_action1_par_init
    )
    port map (
       gckn      => scom_lckn
     ,    e      => scom_e
     , asyncr    => asyncr
     , syncr     => syncr   
     , d(0)      => fir_action1_par_in
     , q(0)        => fir_action1_par_lt
     , vdd        => vdd
     , vss        => gnd
   );
  END GENERATE do_action1;

  fix_action1: IF (fir_actions = 0) GENERATE

    fir_action0_in                      <= (others => '0');
    fir_action0_lt                      <= fir_action0_in;
    fir_action0_par_in                  <= '0';
    fir_action0_par_lt                  <= fir_action0_par_in;
    fir_action0_par_err                 <= '0';

    fir_action1_in                      <= (others => '1');
    fir_action1_lt                      <= fir_action1_in;
    fir_action1_par_in                  <= '0';
    fir_action1_par_lt                  <= fir_action1_par_in;
    fir_action1_par_err                 <= '0';
  END GENERATE fix_action1;

  fix_action0: IF (fir_actions = 1) GENERATE
    fir_action0_in                      <= (others => '0');
    fir_action0_lt                      <= fir_action0_in;
    fir_action0_par_in                  <= '0';
    fir_action0_par_lt                  <= fir_action0_par_in;
    fir_action0_par_err                 <= '0';
  END GENERATE fix_action0;

  fir_mask : entity latches.c_morph_dff
    generic map (
    width => width
    ,init => fir_mask_init
    )
    port map (
       gckn      => scom_lckn
     ,    e      => scom_e
     , asyncr    => asyncr
     , syncr     => syncr   
     , d      => fir_mask_in
     , q        => fir_mask_lt
     , vdd        => vdd
     , vss        => gnd
   );

  fir_mask_par : entity latches.c_morph_dff
    generic map (
    init => fir_mask_par_init
    )
    port map (
       gckn      => scom_lckn
     ,    e      => scom_e
     , asyncr    => asyncr
     , syncr     => syncr 
     , d(0)      => fir_mask_par_in
     , q(0)        => fir_mask_par_lt
     , vdd        => vdd
     , vss        => gnd
   );

  gen_fir_mask_par : entity latches.c_morph_dff
    generic map (
    init => fir_mask_par_init
    )
    port map (
       gckn      => gen_lckn
     ,    e      => gen_e
     , asyncr    => asyncr
     , syncr     => syncr   
     , d(0)      => gen_fir_mask_par_in
     , q(0)        => gen_fir_mask_par_lt
     , vdd        => vdd
     , vss        => gnd
   );


  fir : entity latches.c_morph_dff
    generic map (
    width => width,
    init  => zero_init(0 to width-1)
    )
    port map (
       gckn      => func2_lckn
     ,    e      => func2_e
     , asyncr    => asyncr
     , syncr     => syncr   
     , d      => fir_in
     , q        => fir_lt
     , vdd        => vdd
     , vss        => gnd
   );

  wof_lat_yes: IF (no_wof_mode = false) GENERATE
  wof : entity latches.c_morph_dff
    generic map (
    width => width,
    init  => zero_init(0 to width-1)
    )
    port map (
       gckn      => func2_lckn
     ,    e      => func2_e
     , asyncr    => asyncr
     , syncr     => syncr 
     , d      => wof_in
     , q        => wof_lt
     , vdd        => vdd
     , vss        => gnd
   );
  END GENERATE wof_lat_yes;

  sys_xstop : entity latches.c_morph_dff
    generic map (
       init  => "0"
    )
    port map (
       gckn      => func_lckn
     ,    e      => func_e
     , asyncr    => asyncr
     , syncr     => syncr   
     , d(0)      => sys_xstop_in
     , q(0)        => sys_xstop_lt
     , vdd        => vdd
     , vss        => gnd
   );

  recov : entity latches.c_morph_dff
    generic map (
       init  => "0"
    )
    port map (
       gckn      => func_out_lckn
     ,    e      => func_out_e
     , asyncr    => asyncr
     , syncr     => syncr          
     , d(0)      => recov_in
     , q(0)        => recov_lt
     , vdd        => vdd
     , vss        => gnd
   );

  recovint : entity latches.c_morph_dff
    generic map (
       init  => "0"
    )
    port map (
       gckn      => func_out_lckn
     ,    e      => func_out_e
     , asyncr    => asyncr
     , syncr     => syncr   
     , d(0)      => recov_int_in
     , q(0)        => recov_int_lt
     , vdd        => vdd
     , vss        => gnd
   );

  xstop : entity latches.c_morph_dff
    generic map (
       init  => "0"
    )    
    port map (
       gckn      => func_out_lckn
     ,    e      => func_out_e
     , asyncr    => asyncr
     , syncr     => syncr              
     , d(0)      => xstop_in
     , q(0)        => xstop_lt
     , vdd        => vdd
     , vss        => gnd
   );

  trace_err : entity latches.c_morph_dff
    generic map (
       init  => "0"
    )
    port map (
       gckn      => func_lckn
     ,    e      => func_out_e
     , asyncr    => asyncr
     , syncr     => syncr          
     , d(0)      => trace_error_in
     , q(0)        => trace_error_lt
     , vdd        => vdd
     , vss        => gnd
   );

  firdivide_latch: if (fir_divide2 = true) GENERATE
  bus_ack_latch : entity latches.c_morph_dff
    generic map (
       init  => "0"
    )
    port map (
       gckn      => func_lckn
     ,    e      => func_e
     , asyncr    => asyncr
     , syncr     => syncr          
     , d(0)      => bus_ack_latch_in
     , q(0)        => bus_ack_latch_lt
     , vdd        => vdd
     , vss        => gnd
   );
  END GENERATE firdivide_latch;


  no_wof_mode_false: IF (no_wof_mode = false) GENERATE
   wof_freeze_mode_lt <= '0';
  END GENERATE no_wof_mode_false;

  fir_output   <= fir_lt AND NOT fir_masked;

  l2_core_mode_no: if ((use_l2_core_mode = false) AND (no_wof_mode = false)) GENERATE
   n: block
   SIGNAL wof_hold         : std_ulogic_vector(0 to width-1);
   SIGNAL wof_set_in       : std_ulogic;
   SIGNAL wof_set_lt       : std_ulogic;
   SIGNAL auto_hold_in     : std_ulogic;
   SIGNAL auto_hold_lt     : std_ulogic;

   BEGIN

   block_wof    <= wof_set_lt;
   wof_set_in   <= OR_reduce(wof_lt);
   auto_hold_in <= OR_reduce(fir_output);  

   wof_in  <= gate_AND(NOT (addrv(8) AND scwrite_lt), gate_AND(NOT block_wof, fir_output) OR wof_hold);

   wof_hold <= gate_AND((wof_freeze_mode_lt OR auto_hold_lt), wof_lt);

   wofb_lt <= (others => '0');

  auto_hold : entity latches.c_morph_dff
    generic map (
       init  => "0"
    )
    port map (
       gckn      => func_lckn
     ,    e      => func_e
     , asyncr    => asyncr
     , syncr     => syncr         
     , d(0)      => auto_hold_in
     , q(0)        => auto_hold_lt
     , vdd        => vdd
     , vss        => gnd
   );

  wof_set : entity latches.c_morph_dff
    generic map (
       init  => "0"
    )
    port map (
       gckn      => func_lckn
     ,    e      => func_e
     , asyncr    => asyncr
     , syncr     => syncr           
     , d(0)      => wof_set_in
     , q(0)        => wof_set_lt
     , vdd        => vdd
     , vss        => gnd
   );

   END BLOCK n;
  END GENERATE l2_core_mode_no;

  l2_core_mode_yes: if ((use_l2_core_mode = true)) GENERATE
   y: BLOCK
   SIGNAL block_wofb       : std_ulogic;
   SIGNAL wof_select_in    : std_ulogic;
   SIGNAL wof_select_lt    : std_ulogic;
   SIGNAL wofb_in          : std_ulogic_vector(0 to width-1);
   SIGNAL clear_wofa       : std_ulogic;
   SIGNAL clear_wofb       : std_ulogic;
   SIGNAL recoverable_errs : std_ulogic_vector(0 to width-1);
   SIGNAL wof_ctl_clear    : std_ulogic;
   SIGNAL wof_ctl_tedge    : std_ulogic;
   SIGNAL wof_ctl_stg_lt   : std_ulogic;

   BEGIN

   wofctl_yes : IF ((use_wof_ctl = true)) GENERATE
    y: BLOCK
    SIGNAL wof_ctl_stg_in       : std_ulogic;
    SIGNAL wof_ctl_stg2_in      : std_ulogic;
    SIGNAL wof_ctl_stg2_lt      : std_ulogic;

    BEGIN

  wof_ctl_stg : entity latches.c_morph_dff
    generic map (
       init  => "0"
    )
    port map (
       gckn      => func_lckn
     ,    e      => func_e
     , asyncr    => asyncr
     , syncr     => syncr           
     , d(0)      => wof_ctl_stg_in
     , q(0)        => wof_ctl_stg_lt
     , vdd        => vdd
     , vss        => gnd
   );

  wof_ctl_stg2 : entity latches.c_morph_dff
     generic map (
       init  => "0"
    )
    port map (
       gckn      => func_lckn
     ,    e      => func_e
     , asyncr    => asyncr
     , syncr     => syncr           
     , d(0)      => wof_ctl_stg2_in
     , q(0)        => wof_ctl_stg2_lt
     , vdd        => vdd
     , vss        => gnd
   );

     wof_ctl_stg_in     <= wof_ctl;
     wof_ctl_stg2_in    <= wof_ctl_stg_lt;

     wof_ctl_tedge      <= wof_ctl_stg2_lt AND NOT wof_ctl_stg_lt;
    END BLOCK y;
   END GENERATE wofctl_yes;
   wofctl_no : IF ((use_wof_ctl = false)) GENERATE
    wof_ctl_stg_lt      <= '0';
    wof_ctl_tedge       <= '0';
   END GENERATE wofctl_no;

   wof_ctl_clear <= wof_ctl_tedge;

   clear_wofa <= (addrv(8) AND scwrite_lt) OR wof_ctl_clear;
   clear_wofb <= (addrv(9) AND scwrite_lt) OR wof_ctl_clear;

   wofs: FOR I IN 0 TO width-1 GENERATE
    wof_in(i)  <= NOT clear_wofa AND (wof_lt(i) OR  (NOT block_wof  AND NOT wof_select_lt AND recoverable_errs(i)));
    wofb_in(i) <= NOT clear_wofb AND (wofb_lt(i) OR (NOT block_wofb AND     wof_select_lt AND recoverable_errs(i)));
   END GENERATE wofs;

   block_wof    <= OR_reduce(wof_lt) OR wof_ctl_stg_lt;
   block_wofb   <= OR_reduce(wofb_lt);

   wof_select_in <= '0' WHEN (NOT block_wof                ) = '1' ELSE
                    '1' WHEN (    block_wof AND recov_reset) = '1' ELSE
                    wof_select_lt;

   recoverable_errs <= fir_lt AND NOT fir_action0_lt AND fir_action1_lt AND NOT fir_masked;
   fir_reset        <= NOT gate_AND(recov_reset, NOT fir_action0_lt AND fir_action1_lt AND NOT fir_masked);

  wof_select : entity latches.c_morph_dff
    generic map (
       init  => "0"
    )
    port map (
       gckn      => func_lckn
     ,    e      => func_e
     , asyncr    => asyncr
     , syncr     => syncr           
     , d(0)      => wof_select_in
     , q(0)        => wof_select_lt
     , vdd        => vdd
     , vss        => gnd
   );

  wofb : entity latches.c_morph_dff
    generic map (
    width => width,
    init  => zero_init(0 to width-1)    
    )
    port map (
       gckn      => func2_lckn
     ,    e      => func2_e
     , asyncr    => asyncr
     , syncr     => syncr           
     , d      => wofb_in
     , q        => wofb_lt
     , vdd        => vdd
     , vss        => gnd
   );

    END BLOCK y;
  END GENERATE l2_core_mode_yes;

 use_recov_reset_yes: if ((use_l2_core_mode = false) AND (use_recov_reset = true)) GENERATE
  fir_reset        <= (others => NOT recov_reset) ;
 END GENERATE use_recov_reset_yes;

 use_recov_reset_no: if ((use_l2_core_mode = false) AND (use_recov_reset = false)) GENERATE
  fir_reset        <= (others => '1') ;
 END GENERATE use_recov_reset_no;

 no_wof_mode_scan: if ((use_l2_core_mode = false) AND (no_wof_mode = true)) GENERATE
 END GENERATE no_wof_mode_scan;

  temp_mask_yes: if (use_temp_mask = true) GENERATE
   fir_masked   <= fir_mask_lt OR temp_mask_in;
  END GENERATE temp_mask_yes;

  temp_mask_no: if (use_temp_mask /= true) GENERATE
   fir_masked   <= fir_mask_lt;
  END GENERATE temp_mask_no;

  no_wof_mode_true: IF ((no_wof_mode = true))  GENERATE
    wof_freeze_mode_lt <= tiedn;
    wof_in             <= (others => '0');
    wof_lt             <= (others => '0');
    wofb_lt            <= (others => '0');
     block_wof         <= '0';
  END GENERATE no_wof_mode_true;


   or_fir_load  <=     (addrv(0) OR addrv(2)) AND scwrite_lt;
   and_fir_ones <= NOT((addrv(0) OR addrv(1)) AND scwrite_lt);
   and_fir_load <=                  addrv(1)  AND scwrite_lt;

   or_fir  <= gate_AND( or_fir_load, bus_wdata);

   and_fir <= gate_AND(and_fir_load, bus_wdata) OR
              gate_AND(and_fir_ones, data_ones   );

   fir_in      <= gate_AND(NOT block_fir, error_input) OR or_fir OR (fir_lt AND and_fir AND fir_reset);

  ext_fence_yes: if (use_external_fence = true) GENERATE
    error_input <= fir_error_in_reef AND NOT fence_in;
  END GENERATE ext_fence_yes;

  ext_fence_no: if (use_external_fence /= true) GENERATE
    error_input <= fir_error_in_reef;
  END GENERATE ext_fence_no;

  fir_error_in_reef <= error_in; 


   or_mask_load  <=     (addrv(3) OR addrv(5)) AND scwrite_lt;
   and_mask_ones <= NOT((addrv(3) OR addrv(4)) AND scwrite_lt);
   and_mask_load <=                  addrv(4)  AND scwrite_lt;

   or_mask  <= gate_AND( or_mask_load, bus_wdata);

   and_mask <= gate_AND(and_mask_load, bus_wdata) OR
               gate_AND(and_mask_ones, data_ones   );

   fir_mask_in <= or_mask OR (fir_mask_lt AND and_mask);

   fir_mask_par_in <= bus_wparity         WHEN (scwrite_lt2 AND addrv(3)) = '1'                 ELSE
                      gen_fir_mask_par_in WHEN (scwrite_lt2 AND OR_reduce(addrv(4 TO 5))) = '1' ELSE
                      fir_mask_par_lt;

   gen_fir_mask_par_in <= XOR_reduce(fir_mask_lt);

   fir_mask_par_err <= gen_fir_mask_par_lt XOR fir_mask_par_lt;


   noact1: IF (fir_actions > 0) GENERATE
     fir_action1_in      <= bus_wdata   WHEN (addrv(7) AND scwrite_lt) = '1' ELSE
                            fir_action1_lt;
     fir_action1_par_in  <= bus_wparity WHEN (addrv(7) AND scwrite_lt) = '1' ELSE
                            fir_action1_par_lt;
     fir_action1_par_err <= XOR_reduce(fir_action1_lt) XOR fir_action1_par_lt;
     noact0: IF (fir_actions > 1) GENERATE
       fir_action0_in      <= bus_wdata   WHEN (addrv(6) AND scwrite_lt) = '1' ELSE
                              fir_action0_lt;
       fir_action0_par_in  <= bus_wparity WHEN (addrv(6) AND scwrite_lt) = '1' ELSE
                              fir_action0_par_lt;
       fir_action0_par_err <= XOR_reduce(fir_action0_lt) XOR fir_action0_par_lt;

     END GENERATE noact0;
   END GENERATE noact1;

   gate0: IF (fir_actions = 0) GENERATE
     gate_action1 <= tiedn;
     gate_action0 <= tiedn;
   END GENERATE gate0;
   gate1: if (fir_actions = 1) GENERATE
     gate_action1 <= tieup;
     gate_action0 <= tiedn;
   END GENERATE gate1;
   gate2: IF (fir_actions = 2) GENERATE
     gate_action1 <= tieup;
     gate_action0 <= tieup;
   END GENERATE gate2;
   xstop_in     <= (gate_action1 AND OR_reduce(fir_lt AND NOT fir_masked AND NOT fir_action0_lt AND NOT fir_action1_lt))  
                or (secure_xstop_int);
   recov_in     <=                  OR_reduce(fir_lt AND NOT fir_masked AND NOT fir_action0_lt AND     fir_action1_lt); 
   recov_int_in <= gate_action0 AND OR_reduce(fir_lt AND NOT fir_masked AND     fir_action0_lt AND NOT fir_action1_lt); 


   block_fir   <= xstop_lt OR sys_xstop_lt;
   xstop_err   <= xstop_lt;
   recov_err   <= recov_lt;
   recov_int   <= recov_int_lt;
   trace_error <= trace_error_lt;



  firdivide_latchack: if (fir_divide2 = true) GENERATE
    bus_ack_latch_in   <= (bus_r_nw AND bus_req_int AND OR_reduce(addrv(0) & addrv(3) & addrv(6 to 11)))   
                          OR scwrite_lt2;                                                             
    bus_ack            <= bus_ack_latch_lt;
    unused             <= '0';
  END GENERATE firdivide_latchack;

  firdivide_nolatchack: if (fir_divide2 = false) GENERATE
    bus_ack   <= (bus_r_nw AND bus_req_int AND OR_reduce(addrv(0) & addrv(3) & addrv(6 to 11)))   
                 OR scwrite_lt2;                                                             
    bus_ack_latch_in <= '0';
    bus_ack_latch_lt <= '0';
    unused <= bus_ack_latch_in or bus_ack_latch_lt;
  END GENERATE firdivide_nolatchack;

  bus_rdata <= gate_AND(addrv(0), fir_lt        ) OR
               gate_AND(addrv(3), fir_mask_lt   ) OR
               gate_AND(gate_action0 AND addrv(6), fir_action0_lt) OR
               gate_AND(gate_action1 AND addrv(7), fir_action1_lt) OR
               gate_AND(addrv(8), wof_lt        ) OR
               gate_AND(addrv(9), wofb_lt       ) OR
               gate_AND(addrv(10), err_mask_lat(0 to bus_rdata'length-1)) OR
               gate_AND(addrv(11), err_hold_lat(0 to bus_rdata'length-1));


  scwrite_in  <= (NOT bus_r_nw AND bus_req_int) and OR_reduce(addrv);  

  scwrite_lat : entity latches.c_morph_dff
    generic map (
       init  => "0"
    )
    port map (
       gckn      => scom_lckn
     ,    e      => scom_e
     , asyncr    => asyncr
     , syncr     => syncr         
     , d(0)      => scwrite_in
     , q(0)        => scwrite_lt
     , vdd        => vdd
     , vss        => gnd
   );

  scwrite_lat2 : entity latches.c_morph_dff
    generic map (
       init  => "0"
    )
    port map (
       gckn      => scom_lckn
     ,    e      => scom_e
     , asyncr    => asyncr
     , syncr     => syncr         
     , d(0)      => scwrite_lt
     , q(0)        => scwrite_lt2
     , vdd        => vdd
     , vss        => gnd
   );


  mchkgen: IF (implement_mchk = true) GENERATE
   yes: BLOCK
   SIGNAL mchk_in         : std_ulogic;
   SIGNAL mchk_lt         : std_ulogic;
   BEGIN

   mchk_in  <= OR_reduce(fir_lt AND NOT fir_masked AND fir_action0_lt AND fir_action1_lt); 
   mchk_out <= mchk_lt;

   trace_error_in <= xstop_in OR recov_in OR recov_int_in OR mchk_in;

  mchk : entity latches.c_morph_dff
    generic map (
       init  => "0"
    )
    port map (
       gckn      => func_out_lckn
     ,    e      => func_out_e
     , asyncr    => asyncr
     , syncr     => syncr           
     , d(0)      => mchk_in
     , q(0)        => mchk_lt
     , vdd        => vdd
     , vss        => gnd
   );
   END BLOCK yes;
  END GENERATE mchkgen;

  nomchk: IF (implement_mchk = false) GENERATE
    trace_error_in <= xstop_in OR recov_in OR recov_int_in;
    mchk_out       <= '0';
  END GENERATE nomchk;


  par_err_in <= fir_mask_par_err & fir_action0_par_err & fir_action1_par_err;

  par_err_action0: IF (fir_actions = 0) GENERATE
    fir_parity_err <= par_err_out(0);
    unused_errors  <= or_reduce(par_err_out(1 to 2));
  END GENERATE par_err_action0;

  par_err_action1: IF (fir_actions = 1) GENERATE
    fir_parity_err <= par_err_out(0) or par_err_out(1);
    unused_errors  <= par_err_out(2);
  END GENERATE par_err_action1;

  par_err_action2: IF (fir_actions = 2) GENERATE
    fir_parity_err <= or_reduce(par_err_out(0 to 2));
    unused_errors  <= '0';
  END GENERATE par_err_action2;

  reset <= (others => reset_err_rpt);
  reset_or_hold <= reset or reset_hold_latch(0 to err_rpt_width-1);

  par_err : entity clib.c_err_rpt_wolcb
     generic map
      (  width            => err_rpt_width
       , inline           => inline
       , reset_hold       => true
       , mask_reset_value => mask_reset_value
       , use_ext_mask     => true
      ) 
     port map (
        vdd            => vdd
      , gnd            => gnd
      , err_lckn      => func2_lckn
      , asyncr        => asyncr
      , syncr         => syncr
      , err_in        => par_err_in
      , err_out       => par_err_out
      , ext_mask      => err_mask_lat(0 to err_rpt_width-1)
      , hold_out      => err_hold_lat(0 to err_rpt_width-1)
      , reset         => reset_or_hold
    );
    err_hold_lat(err_rpt_width to 63) <= (others => '0');


  err_mask_latch : entity latches.c_morph_dff
    generic map (
    width => err_rpt_width,
    init  => mask_reset_value    
    )
    port map (
       gckn      => scom_lckn
     ,    e      => scom_e
     , asyncr    => asyncr
     , syncr     => syncr           
     , d         => err_mask_in(0 to err_rpt_width-1)
     , q         => err_mask_lat(0 to err_rpt_width-1)
     , vdd        => vdd
     , vss        => gnd
   );
  
   err_mask_in(err_rpt_width to 63)         <= (others => '0');
   err_mask_lat(err_rpt_width to 63)        <= (others => '0');
   reset_hold_latch(err_rpt_width to 63)    <= (others => '0');

   err_mask_in(0 to err_rpt_width-1)        <= bus_wdata(0 to err_rpt_width-1)   WHEN (addrv(10) AND scwrite_lt) = '1' ELSE
                                               err_mask_lat(0 to err_rpt_width-1);
   reset_hold_latch(0 to err_rpt_width-1)   <= bus_wdata(0 to err_rpt_width-1)   WHEN (addrv(11) AND scwrite_lt) = '1' ELSE
                                               (others => '0');


  secure_masks_true: if (secure_masks = true) GENERATE    
    secure_xstop_int <= ( ((NOT bus_r_nw AND bus_req) and or_reduce(addrv(3 to 7))) or secure_xstop) and secure_enable;  
    bus_req_int      <= bus_req and not ((NOT bus_r_nw AND bus_req) and or_reduce(addrv(3 to 7)));                       
  END GENERATE secure_masks_true;

  secure_masks_false: if (secure_masks = false) GENERATE  
    secure_xstop_int <= secure_xstop and secure_enable;   
    bus_req_int      <= bus_req;
  END GENERATE secure_masks_false;


  firdivide_active: if (fir_divide2 = true) GENERATE
  END GENERATE firdivide_active;

  firdivide_passive: if (fir_divide2 = false) GENERATE
  END GENERATE firdivide_passive;




END c_local_fir_comp;


  
