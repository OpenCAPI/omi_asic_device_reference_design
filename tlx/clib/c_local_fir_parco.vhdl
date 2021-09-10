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


ENTITY c_local_fir_parco IS
 GENERIC
  ( scom_width : integer := 64;
    fir_width  : integer := 64
  );
  PORT
    ( 
      vdd                     : inout power_logic
    ; gnd                     : inout power_logic
    ; bus_wdata               : in  std_ulogic_vector(0 to scom_width-1)
    ; bus_wparity             : in  std_ulogic
    ; fir_wparity             : out std_ulogic
    );



ATTRIBUTE BLOCK_TYPE OF c_local_fir_parco : ENTITY IS leaf;
attribute BLOCK_DATA of c_local_fir_parco  : entity is "SCAN_FLATTEN=/NO/";
ATTRIBUTE POWER_PIN of vdd : signal is 1;
ATTRIBUTE PIN_DEFAULT_POWER_DOMAIN of c_local_fir_parco : entity is "VDD";
ATTRIBUTE GROUND_PIN of gnd : signal is 1;
ATTRIBUTE PIN_DEFAULT_GROUND_DOMAIN of c_local_fir_parco : entity is "GND";

END c_local_fir_parco;


ARCHITECTURE c_local_fir_parco OF c_local_fir_parco IS

BEGIN
  same_width: if scom_width = fir_width generate
     fir_wparity <= bus_wparity;
  end generate same_width;
  different_size: if fir_width < scom_width generate
      fir_wparity <= bus_wparity xor  xor_reduce(bus_wdata(fir_width to scom_width-1));  
  end generate different_size;

END c_local_fir_parco;
