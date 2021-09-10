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





library clib, ibm, ieee, latches, support;
 use ibm.std_ulogic_function_support.all;
 use ibm.std_ulogic_support.all;
 use ibm.synthesis_support.all;
 use ibm.texsim_attributes.all;
 use ieee.std_logic_1164.all;
 use support.logic_support_pkg.all;
 use support.power_logic_pkg.all;
 use support.signal_resolution_pkg.all;
entity c_err_rpt_wolcb is

generic
  ( width               : positive := 1    
  ; mask_reset_value    : std_ulogic_vector := "" 
  ; inline              : boolean := false 
  ; share_mask          : boolean := false 
  ; use_slat_mask       : boolean := false 

  ; reset_hold          : boolean := false 
  ; keeper              : boolean := false 
  ; share_keeper        : boolean := false 
  ; share_reset         : boolean := false 
  ; reset_dominant      : boolean := false 
  ; use_ext_mask        : boolean := false 
  ; encode_mask         : boolean := false 
  ; scan_keeper         : integer := 1     
  );
port
  ( 
    vdd            : inout power_logic
  ; gnd            : inout power_logic

  ; err_e          : in  std_ulogic :='1'
  ; asyncr         : in  std_ulogic :='0'
  ; syncr          : in  std_ulogic :='0'  

  ; err_lckn     : in  std_ulogic :='1'


  ; err_in        : in  std_ulogic_vector(0 to width-1)
  ; err_out       : out std_ulogic_vector(0 to width-1)

  ; hold_out      : out std_ulogic_vector(0 to width-1) 
  ; mask_out      : out std_ulogic_vector(0 to width-1)

  ;  hreset_timed : in  std_ulogic :='0'
  ;  err_trace_shift_in : in  std_ulogic :='0'
  ;  err_trace_shift_out: out  std_ulogic
  ;  reset        : IN  std_ulogic_vector(0 to width-1) := (others =>'0') 
  ;  reset_shared : IN  std_ulogic  := '0' 
  ;  ext_mask     : IN  std_ulogic_vector(0 to width-1) := (others =>'0') 
  ;  reset_keeper : IN  std_ulogic := '0'  


);

attribute power_pin of vdd : signal is 1;
attribute pin_default_power_domain of c_err_rpt_wolcb : entity is "VDD";
attribute ground_pin of gnd : signal is 1;
attribute pin_default_ground_domain of c_err_rpt_wolcb : entity is "GND";
attribute generic_port_list of c_err_rpt_wolcb : entity is "inline";
attribute block_type        of c_err_rpt_wolcb : entity is leaf;

attribute BLOCK_DATA of c_err_rpt_wolcb : ENTITY IS "SCAN_FLATTEN=/NO/";

attribute PIN_DATA   of err_trace_shift_in  : signal is "PIN_FUNCTION=/ERR_SHIFT_IN/";
attribute PIN_DATA   of err_trace_shift_out : signal is "PIN_FUNCTION=/ERR_SHIFT_OUT/";

end c_err_rpt_wolcb;


architecture c_err_rpt_wolcb of c_err_rpt_wolcb is

signal bogus : std_ulogic;
attribute analysis_not_referenced of bogus : signal is "true";

SIGNAL khold_in, khold_lt  : std_ulogic_vector(0 to width-1);
SIGNAL hold_int, hold_out_int, hold_in, hold_lt : std_ulogic_vector(0 to width-1);
SIGNAL mask_int, mask_out_int, mask_lt : std_ulogic_vector(0 to width-1);
SIGNAL err_in_sim_rename        : std_ulogic_vector(0 to width-1);
SIGNAL err_out_sim_rename       : std_ulogic_vector(0 to width-1);
SIGNAL reset_sim_rename         : std_ulogic_vector(0 to width-1);
SIGNAL share_keeper_int  : boolean;

constant zero_init      : std_ulogic_vector(0 to 63) := (others => '0');



begin
 
  bogus   <= OR_reduce(reset & ext_mask & hold_in & hold_lt & 
                       reset_shared & mask_lt &
                       err_trace_shift_in & hreset_timed &
                       khold_in & khold_lt & 
                       err_lckn & 
                       reset_keeper & reset_sim_rename);

noreset: if (reset_hold = false) GENERATE
  reset_sim_rename <= (others => '0');  
END GENERATE noreset;

nosharedreset: if (reset_hold = true AND share_reset = false) GENERATE
  reset_sim_rename <= reset;
END GENERATE nosharedreset;

nosharedreset_b: if (reset_hold = true AND share_reset = true) GENERATE
  reset_sim_rename <= (others => reset_shared);
END GENERATE nosharedreset_b;

share_keeper_int <= share_keeper;

assert not ((width = 1) and (share_keeper_int = true)) report "width must be greater than 1 when using share_keeper" severity failure;

err_in_sim_rename <= err_in ;
err_out    <= err_out_sim_rename when hreset_timed = '0' else
              (others=>'0');
erpt: BLOCK
BEGIN

k: IF (((inline = false) AND (reset_hold = false)) OR (keeper = true)) AND
        (share_keeper = false) GENERATE 

  hold : entity latches.c_morph_dff
    generic map (
    width => width,
    init  => zero_init(0 to width-1)
    )
    port map (
       gckn      => err_lckn
     ,    e      => err_e
     , asyncr    => asyncr
     , syncr     => syncr
     , d      => khold_in
     , q        => khold_lt
     , vdd        => vdd
     , vss        => gnd
   );

  khold_in  <= err_in_sim_rename OR gate_and(not reset_keeper, khold_lt);

END GENERATE k;

sk: IF (keeper = true) AND (share_keeper = true) AND (width > 1) GENERATE

  hold : entity latches.c_morph_dff
    generic map (
    width => width,
    init  => zero_init(0 to width-1)
    )
    port map (
       gckn      => err_lckn
     ,    e      => err_e
     , asyncr    => asyncr
     , syncr     => syncr       
     , d(0)      => khold_in(0)
     , q(0)        => khold_lt(0)
     , vdd        => vdd
     , vss        => gnd
   );

   khold_in(0) <= or_reduce(err_in_sim_rename) OR gate_and(not reset_keeper, khold_lt(0));
   
   khold_in(1 to width-1) <= (others => '0');
   khold_lt(1 to width-1) <= khold_in(1 to width-1);


END GENERATE sk;


r: IF (inline = false) AND (reset_hold = true) AND (reset_dominant = false)  GENERATE 

  hold : entity latches.c_morph_dff
    generic map (
    width => width,
    init  => zero_init(0 to width-1)
    )
    port map (
       gckn      => err_lckn
     ,    e      => err_e
     , asyncr    => asyncr
     , syncr     => syncr              
     , d         => hold_in
     , q         => hold_lt
     , vdd       => vdd
     , vss       => gnd
   );
  
  width_0:IF (width = 1)  GENERATE
   hold_in(0) <= (not hreset_timed and  (err_in_sim_rename(0) OR (hold_lt(0) AND NOT reset_sim_rename(0)) )) or
                   ( hreset_timed and err_trace_shift_in ) ;
  err_trace_shift_out <= ( hreset_timed and hold_lt(0));
   END GENERATE width_0;
   
  width_1:IF (width > 1)  GENERATE
    hold_in(0)  <= (not hreset_timed and (err_in_sim_rename(0) OR (hold_lt(0) AND NOT reset_sim_rename(0)) )) or
                   ( hreset_timed and err_trace_shift_in ) ;
               
    err_shift: FOR i IN 1 to width-1 GENERATE
    hold_in(i)  <= (not hreset_timed and (err_in_sim_rename(i) OR (hold_lt(i) AND NOT reset_sim_rename(i)) )) or      
                   ( hreset_timed and hold_lt(i-1));
   END GENERATE err_shift;
   
    err_trace_shift_out <= ( hreset_timed and hold_lt(width-1));
   END GENERATE width_1;
   
END GENERATE r;

r1: IF (inline = false) AND (reset_hold = true) AND (reset_dominant = true) GENERATE 

  hold : entity latches.c_morph_dff
    generic map (
    width => width,
    init  => zero_init(0 to width-1)
    )
    port map (
       gckn      => err_lckn
     ,    e      => err_e
     , asyncr    => asyncr
     , syncr     => syncr          
     , d         => hold_in
     , q         => hold_lt
     , vdd       => vdd
     , vss       => gnd
   );
  
  width_0:IF (width = 1)  GENERATE
   hold_in(0) <= (not hreset_timed and ( (err_in_sim_rename(0) OR hold_lt(0)) AND NOT reset_sim_rename(0))) or
                   ( hreset_timed and err_trace_shift_in ) ;
  err_trace_shift_out <= ( hreset_timed and hold_lt(0));
   END GENERATE width_0;
   
  width_1:IF (width > 1)  GENERATE
    hold_in(0)  <= (not hreset_timed and ((err_in_sim_rename(0) OR hold_lt(0)) AND NOT reset_sim_rename(0)))  or
                   ( hreset_timed and  err_trace_shift_in ) ;
               
    err_shift: FOR i IN 1 to width-1 GENERATE
    hold_in(i)  <= (not hreset_timed and( (err_in_sim_rename(i) OR hold_lt(i)) AND NOT reset_sim_rename(i)))  or      
                   ( hreset_timed and hold_lt(i-1));
   END GENERATE err_shift;
   
    err_trace_shift_out <= ( hreset_timed and hold_lt(width-1));
   END GENERATE width_1;

END GENERATE r1;

x: IF (inline = true) AND (reset_hold = false) GENERATE 

  hold : entity latches.c_morph_dff
    generic map (
    width => width,
    init  => zero_init(0 to width-1)    
    )
    port map (
       gckn      => err_lckn
     ,    e      => err_e
     , asyncr    => asyncr
     , syncr     => syncr            
     , d         => hold_in
     , q         => hold_lt
     , vdd       => vdd
     , vss       => gnd
   );

  
  width_0:IF (width = 1)  GENERATE
   hold_in(0) <= (not hreset_timed and  (err_in_sim_rename(0) OR hold_lt(0))) or
                   ( hreset_timed and  err_trace_shift_in ) ;
  err_trace_shift_out <= ( hreset_timed and hold_lt(0));
   END GENERATE width_0;
   
  width_1:IF (width > 1)  GENERATE
    hold_in(0)  <= (not hreset_timed and (err_in_sim_rename(0) OR hold_lt(0))) or
                   ( hreset_timed and  err_trace_shift_in ) ;
               
    err_shift: FOR i IN 1 to width-1 GENERATE
    hold_in(i)  <= (not hreset_timed and (err_in_sim_rename(i) OR hold_lt(i)))  or      
                   ( hreset_timed and hold_lt(i-1));
   END GENERATE err_shift;
   
    err_trace_shift_out <= ( hreset_timed and hold_lt(width-1));
   END GENERATE width_1;

END GENERATE x;

i: IF (inline = true) AND (reset_hold = true) AND (reset_dominant = false)  GENERATE 

  hold : entity latches.c_morph_dff
    generic map (
    width => width,
    init  => zero_init(0 to width-1)        
    )
    port map (
       gckn      => err_lckn
     ,    e      => err_e
     , asyncr    => asyncr
     , syncr     => syncr          
     , d         => hold_in
     , q         => hold_lt
     , vdd       => vdd
     , vss       => gnd
   );
  
  width_0:IF (width = 1)  GENERATE
   hold_in(0) <= (not hreset_timed and (err_in_sim_rename(0) OR (hold_lt(0) AND NOT reset_sim_rename(0))))  or
                   ( hreset_timed and  err_trace_shift_in ) ;
  err_trace_shift_out <= ( hreset_timed and hold_lt(0));
   END GENERATE width_0;
   
  width_1:IF (width > 1)  GENERATE
    hold_in(0)  <= (not hreset_timed and ( err_in_sim_rename(0) OR (hold_lt(0) AND NOT reset_sim_rename(0))))  or
                   ( hreset_timed and  err_trace_shift_in ) ;
               
    err_shift: FOR i IN 1 to width-1 GENERATE
    hold_in(i)  <= (not hreset_timed and ( err_in_sim_rename(i) OR (hold_lt(i) AND NOT reset_sim_rename(i))))  or      
                   ( hreset_timed and hold_lt(i-1));
   END GENERATE err_shift;
   
    err_trace_shift_out <= ( hreset_timed and hold_lt(width-1));
   END GENERATE width_1;

     

END GENERATE i;

i1: IF (inline = true) AND (reset_hold = true) AND (reset_dominant = true) GENERATE 

  hold : entity latches.c_morph_dff
    generic map (
    width => width,
    init  => zero_init(0 to width-1)        
    )
    port map (
       gckn      => err_lckn
     ,    e      => err_e
     , asyncr    => asyncr
     , syncr     => syncr             
     , d         => hold_in
     , q         => hold_lt
     , vdd       => vdd
     , vss       => gnd
   );

  
  width_0:IF (width = 1)  GENERATE
   hold_in(0) <= (not hreset_timed and( (err_in_sim_rename(0) OR hold_lt(0)) AND NOT reset_sim_rename(0))) or
                   ( hreset_timed and err_trace_shift_in ) ;
  err_trace_shift_out <= ( hreset_timed and hold_lt(0));
   END GENERATE width_0;
   
  width_1:IF (width > 1)  GENERATE
    hold_in(0)  <= (not hreset_timed and ((err_in_sim_rename(0) OR hold_lt(0)) AND NOT reset_sim_rename(0)))  or
                   ( hreset_timed and err_trace_shift_in ) ;
               
    err_shift: FOR i IN 1 to width-1 GENERATE
    hold_in(i)  <= (not hreset_timed and( (err_in_sim_rename(i) OR hold_lt(i)) AND NOT reset_sim_rename(i)))  or      
                   ( hreset_timed and hold_lt(i-1));
   END GENERATE err_shift;
   
    err_trace_shift_out <= ( hreset_timed and hold_lt(width-1));
   END GENERATE width_1;
 
END GENERATE i1;


m: IF (use_ext_mask = false) AND (encode_mask = false) AND (share_mask = false) GENERATE

  es1: if (use_slat_mask = false) generate
  mask : entity latches.c_morph_dff
    generic map (
    width => width
    ,init => mask_reset_value
    )
    port map (
       gckn      => err_lckn
     ,    e      => err_e
     , asyncr    => asyncr
     , syncr     => syncr          
     , d         => mask_lt
     , q         => mask_lt
     , vdd       => vdd
     , vss       => gnd
   );
  
end generate es1;

  s1: if (use_slat_mask = true) generate
  mask_lt <= mask_reset_value;
end generate s1;

  mask_int <= mask_lt;

END GENERATE m;

assert not ((width = 1) and (use_ext_mask = false) and (encode_mask = false) and (share_mask = true)) report "width must be > 1 for share_mask" severity error;
sm: IF (use_ext_mask = false) AND (encode_mask = false) AND (share_mask = true) GENERATE

  es1: if (use_slat_mask = false) generate
  mask : entity latches.c_morph_dff
    generic map (
    init => mask_reset_value
    )
    port map (
       gckn      => err_lckn
     ,    e      => err_e
     , asyncr    => asyncr
     , syncr     => syncr         
     , d         => mask_lt(0 to 0)
     , q         => mask_lt(0 to 0)
     , vdd       => vdd
     , vss       => gnd
   );
end generate es1;

  s1: if (use_slat_mask = true) generate
   mask_lt <= mask_reset_value;
end generate s1;

  mask_int <= (others => mask_lt(0));  
  mask_lt(1 to width-1) <= (others => '0');

END GENERATE sm;

xm: IF (use_ext_mask = true) AND (encode_mask = false) AND (share_mask = false) GENERATE

  mask_int <= ext_mask;
  mask_lt <= (others => '0');

END GENERATE xm;






END BLOCK erpt;


mask_out <= mask_out_int;
hold_out <= hold_out_int;
mask_out_int <= mask_int;               
hold_out_int <= hold_int;               

inline_hold: IF (inline = true) GENERATE
  err_out_sim_rename <= hold_int AND NOT mask_int;  
END GENERATE inline_hold;

side_hold: IF (inline = false) GENERATE
  err_out_sim_rename <= err_in_sim_rename AND NOT mask_int; 
END GENERATE side_hold;

keeper_as_hold: IF (keeper = false) AND (inline = false) AND (reset_hold = false) GENERATE
  hold_int <= khold_lt;
  hold_in <= (others => '0');
  hold_lt <= (others => '0');
  err_trace_shift_out <= '0';

END GENERATE keeper_as_hold;

no_keeper: IF (keeper = false) AND ((inline = true) OR (reset_hold = true)) GENERATE
  hold_int <= hold_lt;
  khold_in <= (others => '0');
  khold_lt <= (others => '0');

END GENERATE no_keeper;

keeper_on_the_side: IF (keeper = true) GENERATE
  hold_int <= hold_lt; 
END GENERATE keeper_on_the_side;



end c_err_rpt_wolcb;
