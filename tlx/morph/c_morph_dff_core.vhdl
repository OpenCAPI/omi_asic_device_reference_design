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

library ieee, support;
use ieee.std_logic_1164.all;
use support.power_logic_pkg.all;

library latches;
use latches.c_latch_init_pkg.all;

entity c_morph_dff_core is
  GENERIC ( width            : natural range 1 to 65535 := 1 ;
            offset           : natural range 0 to 65535 := 0 ;
            init             : std_ulogic_vector
          );
  port (
    d           : in  std_ulogic_vector(offset to (offset + width - 1));       
    gckn        : in  std_ulogic;       
    asyncr      : in  std_ulogic := '0';  
    asyncd      : in  std_ulogic_vector(offset to (offset + width - 1)); 
    syncr       : in  std_ulogic := '0';  
    syncd       : in  std_ulogic_vector(offset to (offset + width - 1)); 
    e           : in  std_ulogic := '1';       
    q           : out std_ulogic_vector(offset to (offset + width -1));     
    qn          : out std_ulogic_vector(offset to (offset + width -1))
    );

end c_morph_dff_core;


architecture c_morph_dff_core of c_morph_dff_core is
  constant initv : std_ulogic_vector(0 to width) := init & (0 to (width - init'length) => init_value);
  signal l2 : std_ulogic_vector(offset to offset+width-1) := initv(0 to width-1);


begin
  process(gckn,asyncr, asyncd)
  begin
    if (asyncr = '1') then
      l2 <= asyncd;
    elsif (rising_edge(gckn)) then
      if (syncr='1') then
        l2 <= syncd;
      elsif (e = '1') then
        l2 <= d;
      end if;
    end if;
  end process;

  q <= l2;
  qn <= not(l2);


end c_morph_dff_core;

