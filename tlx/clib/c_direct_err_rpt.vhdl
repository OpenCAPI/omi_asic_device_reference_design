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

ENTITY c_direct_err_rpt IS

GENERIC
  ( width            : POSITIVE := 1        
  );
PORT
  ( err_in        : IN  std_ulogic_vector(0 to width-1)
  ; err_out       : OUT std_ulogic_vector(0 to width-1)
  ; vdd            : inout power_logic
  ; gnd            : inout power_logic
);
attribute power_pin of vdd : signal is 1;
attribute pin_default_power_domain of c_direct_err_rpt : entity is "VDD";
attribute ground_pin of gnd : signal is 1;
attribute pin_default_ground_domain of c_direct_err_rpt : entity is "GND";
ATTRIBUTE GENERIC_PORT_LIST OF c_direct_err_rpt: ENTITY IS "WIDTH";
ATTRIBUTE BLOCK_TYPE of c_direct_err_rpt : ENTITY IS leaf;

END c_direct_err_rpt;


ARCHITECTURE c_direct_err_rpt OF c_direct_err_rpt IS

SIGNAL direct_err_in_sim_rename : std_ulogic_vector(0 to width-1);

BEGIN

bs: FOR i in 0 to width-1 GENERATE

 direct: ENTITY clib.c_direct_err_rpt_errin PORT MAP
    ( err_in       => direct_err_in_sim_rename(i),
      vdd => vdd,
      gnd => gnd
    );
END GENERATE bs;

   direct_err_in_sim_rename <= err_in;
   err_out <= direct_err_in_sim_rename;

END c_direct_err_rpt;
