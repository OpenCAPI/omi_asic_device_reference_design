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

library ieee;
  use ieee.std_logic_1164.all;
library support;
  use support.power_logic_pkg.all;
  use support.signal_resolution_pkg.all;

library latches;
  use latches.c_latch_init_pkg.all;

library ibm;
  USE ibm.synthesis_support.all; 
  use ibm.std_ulogic_function_support.all;
  USE ibm.std_ulogic_support.all;

entity c_morph_dff is
  GENERIC ( width            : natural range 1 to 65535 := 1;
            offset           : natural range 0 to 65535 := 0 ;
            init             : std_ulogic_vector :=""
          );
  port (
    vdd      : inout power_logic := '1';
    vss      : inout power_logic := '0';
    d           : in  std_ulogic_vector(offset to offset + width - 1);       
    gckn        : in  std_ulogic;       
    asyncr      : in  std_ulogic := '0';  
   asyncd      : in  std_ulogic_vector(offset to (offset + width - 1)) := (others => '0');
    syncr       : in  std_ulogic := '0';  
    syncd       : in  std_ulogic_vector(offset to (offset + width - 1)) := (others => '0');
    e           : in  std_ulogic := '1';       
    edis        : in  std_ulogic := '0';       
    hldn        : in std_ulogic := '1';  
    q           : out std_ulogic_vector(offset to (offset + width -1));     
    qn          : out std_ulogic_vector(offset to (offset + width -1))     
    );


end c_morph_dff;


architecture c_morph_dff of c_morph_dff is

   constant initv : std_ulogic_vector (0 to width) := init & (init'length to width => init_value);
  signal dff_e : std_ulogic;
  signal morph_ck : std_ulogic;
  signal asyncd_int : std_ulogic_vector(offset to (offset + width - 1));
  signal syncd_int : std_ulogic_vector(offset to (offset + width - 1));

begin
  dff_e <= e or edis;

  morph_ck <= not(gckn) and hldn;


  gen00 : if width = 1 generate
    gen01 : if init'length > 0 generate
      asyncd_int(offset) <= init(0);
      syncd_int(offset) <= init(0);
    end generate gen01;
    gen02 : if init'length = 0 generate
      asyncd_int(offset) <= init_value;
      syncd_int(offset) <= init_value;
    end generate gen02;
  end generate gen00;
  gen10 : if width /= 1 generate
    asyncd_int <= init & (init'length to width-1 => init_value);
    syncd_int <= init & (init'length to width-1 => init_value);
  end generate gen10;

  latc: entity latches.c_morph_dff_core
    generic map (width => width, offset => offset, init => initv(0 to width-1))
    port map(gckn         => morph_ck,
             e            => dff_e,
             d            => d,
             asyncr => asyncr,
             asyncd => asyncd_int,
             syncr => syncr,
             syncd => syncd_int,
             q     => q,
             qn   => qn );

end c_morph_dff;

