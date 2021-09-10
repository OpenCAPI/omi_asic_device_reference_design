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


ENTITY c_local_fir_wolcb IS
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
     func2_lckn        		: in  std_ulogic := '1'
    ;func_lckn        		: in  std_ulogic := '1'
    ;func_out_lckn    		: in  std_ulogic := '1'
    ;scom_lckn        		: in  std_ulogic := '1'
    ;gen_lckn         		: in  std_ulogic := '1'

                
    ; asyncr                  : in  std_ulogic :='0'
    ; syncr                   : in  std_ulogic :='0'  
    
    ; scom_e                  : in  std_ulogic :='1'
    ; func_e                  : in  std_ulogic :='1'
    ; func_out_e              : in  std_ulogic :='1'   
    ; func2_e                  : in  std_ulogic :='1'
    ; gen_e                   : in  std_ulogic :='1'
   
    ; vdd                     : inout power_logic
    ; gnd                     : inout power_logic

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
    ; bus_act                 : in  std_ulogic := '1'               

    );

ATTRIBUTE BLOCK_TYPE OF c_local_fir_wolcb : ENTITY IS leaf;
attribute BLOCK_DATA of c_local_fir_wolcb  : entity is "SCAN_FLATTEN=/NO/";
ATTRIBUTE POWER_PIN of vdd : signal is 1;
ATTRIBUTE PIN_DEFAULT_POWER_DOMAIN of c_local_fir_wolcb : entity is "VDD";
ATTRIBUTE GROUND_PIN of gnd : signal is 1;
ATTRIBUTE PIN_DEFAULT_GROUND_DOMAIN of c_local_fir_wolcb : entity is "GND";


END c_local_fir_wolcb;

ARCHITECTURE c_local_fir_wolcb OF c_local_fir_wolcb IS





  signal unused                               : std_logic;
  attribute analysis_not_referenced of unused : signal is "true";  
BEGIN
 




fir: entity clib.c_local_fir_comp
  generic map
   ( width                   => width
   , apply_phase_hold        => apply_phase_hold
   , use_wof_ctl             => use_wof_ctl
   , apply_output_phase_hold => apply_output_phase_hold
   , apply_scom_phase_hold   => apply_scom_phase_hold
   , fir_divide2             => fir_divide2
   , use_external_fence      => use_external_fence
   , use_temp_mask           => use_temp_mask
   , fir_actions             => fir_actions
   , no_wof_mode             => no_wof_mode
   , fir_mask_init           => fir_mask_init
   , fir_mask_par_init       => fir_mask_par_init
   , fir_action0_init        => fir_action0_init
   , fir_action0_par_init    => fir_action0_par_init
   , fir_action1_init        => fir_action1_init
   , fir_action1_par_init    => fir_action1_par_init
   , use_recov_reset         => use_recov_reset
   , use_l2_core_mode        => use_l2_core_mode
   , implement_mchk          => implement_mchk
   , inline                  => inline
   , reset_hold              => reset_hold
   , mask_reset_value        => mask_reset_value
   )
   port map (
       vdd                    => vdd
     , gnd                    => gnd
      
     , func_lckn              => func_lckn 
     , func_out_lckn          => func_out_lckn 
     , func2_lckn              => func2_lckn 
     , scom_lckn              => scom_lckn 
     , gen_lckn               => gen_lckn

     , asyncr                => asyncr
     , syncr                 => syncr 

     , scom_e                => scom_e
     , func_e                => func_e
     , func_out_e            => func_out_e
     , func2_e                => func2_e
     , gen_e                => gen_e


     , sys_xstop_in           => sys_xstop_in
     , error_in               => error_in
     , xstop_err              => xstop_err
     , recov_err              => recov_err
     , recov_int              => recov_int
     , mchk_out               => mchk_out
     , trace_error            => trace_error
     , secure_enable          => secure_enable

     , temp_mask_in           => temp_mask_in
     , fence_in               => fence_in
     , wof_ctl                => wof_ctl

     , fir_out                => fir_out
     , fir_mask_out           => fir_mask_out

     , recov_reset            => recov_reset
     , reset_err_rpt          => reset_err_rpt

     , fir_parity_err         => fir_parity_err
     , fir_active             => fir_active
     , secure_xstop           => secure_xstop

     , addrv                  => addrv
     , bus_r_nw               => bus_r_nw
     , bus_req                => bus_req
     , bus_wdata              => bus_wdata
     , bus_wparity            => bus_wparity
     , bus_ack                => bus_ack
     , bus_rdata              => bus_rdata

    );

 unused <=  bus_act ;

END c_local_fir_wolcb;
