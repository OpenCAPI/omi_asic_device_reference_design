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


entity c_serial_scom_wolcb is
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
    lckn                 : in  std_ulogic ;  

    vdd                   : inout power_logic ;  
    gnd                   : inout power_logic;  

    dcfg_lckn            : in  std_ulogic; 
    syncr                : in  std_ulogic := '0'; 
    asyncr               : in  std_ulogic := '0'; 

    scom_local_act       : out std_ulogic; 
    local_act_int       : out std_ulogic; 

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

attribute block_type of c_serial_scom_wolcb          : entity is leaf;
attribute BLOCK_DATA of c_serial_scom_wolcb  : entity is "SCAN_FLATTEN=/NO/";

attribute power_pin of vdd : signal is 1;
attribute pin_default_power_domain of c_serial_scom_wolcb : entity is "VDD";
attribute ground_pin of gnd : signal is 1;
attribute pin_default_ground_domain of c_serial_scom_wolcb : entity is "GND";

attribute analysis_not_referenced of dcfg_lckn : signal is "true";  
end c_serial_scom_wolcb;


architecture c_serial_scom_wolcb of c_serial_scom_wolcb is

signal scom_local_act_int        : std_ulogic;




begin
 
  scom_local_act <= scom_local_act_int;
  




  scomsat: entity clib.c_serial_scom_comp
     generic map
     ( width                => width
     , internal_addr_decode => internal_addr_decode
     , use_addr             => use_addr
     , addr_is_rdable       => addr_is_rdable
     , addr_is_wrable       => addr_is_wrable
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

     , lckn                    => lckn
     , local_act_int           => local_act_int

     , scom_local_act          => scom_local_act_int

    , dcfg_lckn               => '0'  
    , syncr                   => syncr
    , asyncr                  => asyncr
    
     , sat_id                  => sat_id

     , scom_dch_in             => scom_dch_in
     , scom_cch_in             => scom_cch_in
     , scom_dch_out            => scom_dch_out
     , scom_cch_out            => scom_cch_out

     , sc_req                  => sc_req
     , sc_ack                  => sc_ack
     , sc_ack_info             => sc_ack_info
     , sc_r_nw                 => sc_r_nw
     , sc_addr                 => sc_addr
     , addr_v                  => addr_v
     , sc_rdata                => sc_rdata
     , sc_wdata                => sc_wdata
     , sc_wparity              => sc_wparity
     , scom_err                => scom_err
     , fsm_reset               => fsm_reset
    );
  

end c_serial_scom_wolcb;
