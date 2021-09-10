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




LIBRARY ieee,ibm,support,latches,clib;
USE ibm.std_ulogic_support.all;
USE ibm.std_ulogic_function_support.all;
USE ibm.synthesis_support.all;
USE ieee.std_logic_1164.all;
USE ibm.texsim_attributes.all;
USE support.logic_support_pkg.all;
use support.power_logic_pkg.all;


ENTITY c_direct_err_rpt_errin IS
PORT  
  ( err_in       : IN  std_ulogic  
  ; vdd           : inout power_logic  
  ; gnd           : inout power_logic  
  );

attribute power_pin of vdd : signal is 1;
attribute pin_default_power_domain of c_direct_err_rpt_errin : entity is "VDD";
attribute ground_pin of gnd : signal is 1;
attribute pin_default_ground_domain of c_direct_err_rpt_errin : entity is "GND";
ATTRIBUTE BTR_NAME OF c_direct_err_rpt_errin             : ENTITY IS "C_DIRECT_ERR_RPT_ERRIN";
ATTRIBUTE RECURSIVE_SYNTHESIS OF c_direct_err_rpt_errin  : ENTITY IS 2;
ATTRIBUTE BLOCK_TYPE of c_direct_err_rpt_errin : ENTITY IS leaf;
attribute BLOCK_DATA of c_direct_err_rpt_errin  : entity is "SCAN_FLATTEN=/NO/";
attribute ANALYSIS_NOT_REFERENCED of err_in : signal is "TRUE";

END c_direct_err_rpt_errin;


ARCHITECTURE c_direct_err_rpt_errin OF c_direct_err_rpt_errin IS


BEGIN




END c_direct_err_rpt_errin;
