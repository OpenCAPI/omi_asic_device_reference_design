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
library ibm;
use ibm.synthesis_support.all;
use ibm.std_ulogic_support.all;
use ibm.std_ulogic_function_support.all;
use ibm.std_ulogic_mux_support.all;
use ibm.std_ulogic_unsigned.all;

package c_utilities_pkg is

  function bool2ulogic (condition : in boolean) return std_ulogic;

  procedure mark_unused(
    input : std_ulogic);

  procedure mark_unused(
    input : std_ulogic_vector);

  function log(
    base  : positive;
    value : natural)
    return natural;
  
  function num_blocks(
    width       : natural;
    block_width : positive)
    return natural;

  function encode(
    input : std_ulogic_vector)
    return std_ulogic_vector;

  function decode(
    input : std_ulogic_vector)
    return std_ulogic_vector;

  function pop_count(
    input : std_ulogic_vector)
    return natural;

  function find_leading_one(
    input : std_ulogic_vector)
    return std_ulogic_vector;

  function find_trailing_one(
    input : std_ulogic_vector)
    return std_ulogic_vector;

  function round_robin(
    request  : std_ulogic_vector;
    previous : std_ulogic_vector)
    return std_ulogic_vector;

  function gate_bool(
    condition : boolean;
    value     : natural)
    return natural;

  function select_1ofn(
    slice_sel : std_ulogic_vector;
    slices    : std_ulogic_vector)
    return std_ulogic_vector;

  function mux_nto1(
    code   : std_ulogic_vector;
    slices : std_ulogic_vector)
    return std_ulogic_vector;

  function insert_bits(
    input            : std_ulogic_vector;
    base             : std_ulogic_vector;
    constant pattern : std_ulogic_vector)
    return std_ulogic_vector;

  function spread_bits(
    input            : std_ulogic_vector;
    def_val          : std_ulogic;
    constant pattern : std_ulogic_vector)
    return std_ulogic_vector;

  function spread_bits(
    input            : std_ulogic_vector;
    constant pattern : std_ulogic_vector)
    return std_ulogic_vector;

  function extract_bits(
    input            : std_ulogic_vector;
    constant pattern : std_ulogic_vector)
    return std_ulogic_vector;

  function match(
    input : std_ulogic_vector;
    mask0 : std_ulogic_vector;
    mask1 : std_ulogic_vector)
    return std_ulogic;

  function interleave(
    input  : std_ulogic_vector;
    stride : positive)
    return std_ulogic_vector;
  
  function deinterleave(
    input  : std_ulogic_vector;
    stride : positive)
    return std_ulogic_vector;
  
end c_utilities_pkg;

package body c_utilities_pkg is

  function bool2ulogic (condition : in boolean) return std_ulogic is
  begin
    if condition then
      return '1';
    else
      return '0';
    end if;
  end bool2ulogic;

  procedure mark_unused(
    input : std_ulogic) is

    variable unused : std_ulogic;

    attribute ANALYSIS_NOT_REFERENCED of unused : variable is "TRUE";
    
  begin
    unused := input;
  end mark_unused;
  
  procedure mark_unused(
    input : std_ulogic_vector) is

    variable unused : std_ulogic_vector(input'low to input'high + 1);

    attribute ANALYSIS_NOT_REFERENCED of unused : variable is "TRUE";
    
  begin
    unused := input & '0';
  end mark_unused;
  
  function log(
    base  : positive;
    value : natural)
    return natural is
    variable result : natural;
  begin
    result := 0;
    for i in 0 to 31 loop
      if base**i >= value then
        result := i;
        exit;
      end if;
    end loop;
    return result;
  end log;

  function num_blocks(
    width       : natural;
    block_width : positive)
    return natural is
  begin
    return (width + block_width - 1) / block_width;
  end num_blocks;

  function encode(
    input : std_ulogic_vector)
    return std_ulogic_vector is
    variable result : std_ulogic_vector(0 to log(2, input'high + 1));
  begin
    result := (result'range => '0');
    for i in input'range loop
      if input(i) = '1' then
        result := result or to_std_ulogic_vector(i, result'length);
        exit;
      end if;
    end loop;
    mark_unused(result(0));
    return result(1 to result'high);
  end encode;

  function decode(
    input : std_ulogic_vector)
    return std_ulogic_vector is
    variable result : std_ulogic_vector(0 to 2 ** input'length);
  begin
    result                    := (result'range => '0');
    result(to_integer(input)) := '1';
    mark_unused(result(result'high));
    return result(0 to 2 ** input'length - 1);
  end decode;

  function pop_count(
    input : std_ulogic_vector)
    return natural is
    variable result : natural;
  begin
    result := 0;
    for i in input'range loop
      result := result + to_integer((0 => input(i)));
    end loop;
    return result;
  end pop_count;

  function find_leading_one(
    input : std_ulogic_vector)
    return std_ulogic_vector is
    variable reverse_input  : std_ulogic_vector(input'low to input'high + 1);
    variable reverse_result : std_ulogic_vector(input'low to input'high + 1);
    variable result         : std_ulogic_vector(input'low to input'high + 1);
  begin

    reverse_input := reverse(input) & '0';

    reverse_result := find_trailing_one(reverse_input(input'range)) & '0';

    result := reverse(reverse_result(input'range)) & '0';

    mark_unused(reverse_input(reverse_input'high));
    mark_unused(reverse_result(reverse_result'high));
    mark_unused(result(result'high));

    return result(input'range);
    
  end find_leading_one;
  
  function find_trailing_one(
    input : std_ulogic_vector)
    return std_ulogic_vector is
    variable minus_input : std_ulogic_vector(input'low to input'high + 1);
    variable result      : std_ulogic_vector(input'low to input'high + 1);
  begin

    minus_input := ((input'range => '0') - input) & '0';

    result := (input and minus_input(input'range)) & '0';

    mark_unused(minus_input(minus_input'high));
    mark_unused(result(result'high));

    return result(input'range);
    
  end find_trailing_one;

  function round_robin(
    request  : std_ulogic_vector;
    previous : std_ulogic_vector)
    return std_ulogic_vector is

    constant len : positive := request'length;

    variable mask             : std_ulogic_vector(0 to len);
    variable request_masked   : std_ulogic_vector(0 to len);
    variable request_extended : std_ulogic_vector(0 to 2 * len);
    variable grant_extended   : std_ulogic_vector(0 to 2 * len);

    variable grant : std_ulogic_vector(request'low to request'high + 1);

  begin

    mask           := (not (previous or (previous - '1'))) & '0';
    request_masked := (request and mask(0 to len-1)) & '0';

    request_extended := request & request_masked(0 to len-1) & '0';

    grant_extended := find_trailing_one(request_extended(0 to 2*len-1)) & '0';

    grant := (grant_extended(0 to len-1) or
              grant_extended(len to 2 * len-1)) & '0';

    mark_unused(mask(mask'high));
    mark_unused(request_masked(request_masked'high));
    mark_unused(request_extended(request_extended'high));
    mark_unused(grant_extended(grant_extended'high));
    mark_unused(grant(grant'high));

    return grant(request'range);
    
  end round_robin;
  
  function gate_bool(
    condition : boolean;
    value     : natural)
    return natural is
    variable result : natural;
  begin
    if condition then
      result := value;
    else
      result := 0;
    end if;
    return result;
  end gate_bool;

  function select_1ofn(
    slice_sel : std_ulogic_vector;
    slices    : std_ulogic_vector)
    return std_ulogic_vector is
    constant num_slices  : positive := slice_sel'length;
    constant slice_width : natural  := slices'length / num_slices;
    variable sel         : std_ulogic_vector(0 to num_slices - 1);
    variable result      : std_ulogic_vector(0 to slice_width);
  begin
    sel := slice_sel;
    if num_slices = 1 then
      result := gate_and(sel(0), slices) & "0";
    elsif num_slices = 2 then
      result := select_1of2(sel(0),
                            slices(0 * slice_width to 1 * slice_width - 1),
                            sel(1),
                            slices(1 * slice_width to 2 * slice_width - 1)) &
                "0";
    elsif num_slices = 4 then
      result := select_1of4(sel(0),
                            slices(0 * slice_width to 1 * slice_width - 1),
                            sel(1),
                            slices(1 * slice_width to 2 * slice_width - 1),
                            sel(2),
                            slices(2 * slice_width to 3 * slice_width - 1),
                            sel(3),
                            slices(3 * slice_width to 4 * slice_width - 1)) &
                "0";
    elsif num_slices = 8 then
      result := select_1of8(sel(0),
                            slices(0 * slice_width to 1 * slice_width - 1),
                            sel(1),
                            slices(1 * slice_width to 2 * slice_width - 1),
                            sel(2),
                            slices(2 * slice_width to 3 * slice_width - 1),
                            sel(3),
                            slices(3 * slice_width to 4 * slice_width - 1),
                            sel(4),
                            slices(4 * slice_width to 5 * slice_width - 1),
                            sel(5),
                            slices(5 * slice_width to 6 * slice_width - 1),
                            sel(6),
                            slices(6 * slice_width to 7 * slice_width - 1),
                            sel(7),
                            slices(7 * slice_width to 8 * slice_width - 1)) &
                "0";
    else
      result := (result'range => '0');
      for i in 0 to num_slices - 1 loop
        result := result or gate_and(sel(i),
                                     slices(i * slice_width to
                                            (i + 1) * slice_width - 1)) &
                  "0";
      end loop;
    end if;
    mark_unused(result(slice_width));
    return result(0 to slice_width - 1);
  end select_1ofn;

  function mux_nto1(
    code   : std_ulogic_vector;
    slices : std_ulogic_vector)
    return std_ulogic_vector is

    constant num_slices  : positive := 2 ** code'length;
    constant slice_width : natural  := slices'length / num_slices;
    variable result      : std_ulogic_vector(0 to slice_width);
  begin
    if num_slices = 1 then
      result := slices & "0";
    elsif num_slices = 2 then
      result := mux_2to1(code(0),
                         slices(0 * slice_width to 1 * slice_width - 1),
                         slices(1 * slice_width to 2 * slice_width - 1)) & "0";
    elsif num_slices = 4 then
      result := mux_4to1(code,
                         slices(0 * slice_width to 1 * slice_width - 1),
                         slices(1 * slice_width to 2 * slice_width - 1),
                         slices(2 * slice_width to 3 * slice_width - 1),
                         slices(3 * slice_width to 4 * slice_width - 1)) & "0";
    elsif num_slices = 8 then
      result := mux_8to1(code,
                         slices(0 * slice_width to 1 * slice_width - 1),
                         slices(1 * slice_width to 2 * slice_width - 1),
                         slices(2 * slice_width to 3 * slice_width - 1),
                         slices(3 * slice_width to 4 * slice_width - 1),
                         slices(4 * slice_width to 5 * slice_width - 1),
                         slices(5 * slice_width to 6 * slice_width - 1),
                         slices(6 * slice_width to 7 * slice_width - 1),
                         slices(7 * slice_width to 8 * slice_width - 1)) & "0";
    else
      result := (result'range => '0');
      for i in 0 to num_slices - 1 loop
        result := result or
                  gate_and(compare(code, to_std_ulogic_vector(i, code'length)),
                           slices(i * slice_width to
                                  (i + 1) * slice_width - 1)) & "0";
      end loop;
    end if;
    mark_unused(result(slice_width));
    return result(0 to slice_width - 1);
  end mux_nto1;

  function insert_bits(
    input            : std_ulogic_vector;
    base             : std_ulogic_vector;
    constant pattern : std_ulogic_vector)
    return std_ulogic_vector is
    variable src_idx : natural;
    variable result  : std_ulogic_vector(pattern'low to pattern'high + 1);
  begin
    result  := (result'range => '0');
    src_idx := input'low;
    for dst_idx in pattern'low to pattern'high loop
      if pattern(dst_idx) = '1' then
        result(dst_idx) := input(src_idx);
        src_idx         := src_idx + 1;
      else
        result(dst_idx) := base(dst_idx);
      end if;
    end loop;
    mark_unused(result(pattern'high + 1));
    return result(pattern'low to pattern'high);
  end insert_bits;
  
  function spread_bits(
    input            : std_ulogic_vector;
    def_val          : std_ulogic;
    constant pattern : std_ulogic_vector)
    return std_ulogic_vector is
  begin
    return insert_bits(input, (pattern'range => def_val), pattern);
  end spread_bits;
  
  function spread_bits(
    input            : std_ulogic_vector;
    constant pattern : std_ulogic_vector)
    return std_ulogic_vector is
  begin
    return spread_bits(input, '0', pattern);
  end spread_bits;

  function extract_bits(
    input            : std_ulogic_vector;
    constant pattern : std_ulogic_vector)
    return std_ulogic_vector is
    constant width   : positive := pop_count(pattern);
    variable dst_idx : natural;
    variable src_idx : natural;
    variable result  : std_ulogic_vector(0 to width);
  begin
    result  := (result'range => '0');
    dst_idx := 0;
    for pat_idx in pattern'low to pattern'high loop
      src_idx := input'low + pat_idx - pattern'low;
      if pattern(pat_idx) = '1' then
        result(dst_idx) := input(src_idx);
        dst_idx         := dst_idx + 1;
      end if;
    end loop;
    mark_unused(result(width));
    return result(0 to width - 1);
  end extract_bits;
  
  function match(
    input : std_ulogic_vector;
    mask0 : std_ulogic_vector;
    mask1 : std_ulogic_vector)
    return std_ulogic is
    variable match_vec : std_ulogic_vector(input'low to input'high + 1);
    variable result    : std_ulogic;
  begin
    match_vec := ((input and not mask0) or
                  (not input and not mask1) or
                  (not mask0 and not mask1)) & "1";
    result := or_reduce(match_vec);
    return result;
  end match;
  
  function interleave(
    input  : std_ulogic_vector;
    stride : positive)
    return std_ulogic_vector is
    variable a      : natural;
    variable b      : natural;
    variable y      : std_ulogic_vector(0 to input'length - 1);
    variable result : std_ulogic_vector(0 to input'length - 1);
  begin
    a := 0;
    b := 0;
    y := input;
    for i in result'range loop
      result(i) := y(a * stride + b);
      if (a + 1) * stride + b > y'high then
        a := 0;
        b := b + 1;
      else
        a := a + 1;
      end if;
    end loop;
    return result;
  end interleave;
  
  function deinterleave(
    input  : std_ulogic_vector;
    stride : positive)
    return std_ulogic_vector is
    variable a      : natural;
    variable b      : natural;
    variable y      : std_ulogic_vector(0 to input'length - 1);
    variable result : std_ulogic_vector(0 to input'length - 1);
  begin
    a := 0;
    b := 0;
    y := input;
    for i in result'range loop
      result(a * stride + b) := y(i);
      if (a + 1) * stride + b > result'high then
        a := 0;
        b := b + 1;
      else
        a := a + 1;
      end if;
    end loop;
    return result;
  end deinterleave;

end c_utilities_pkg;
