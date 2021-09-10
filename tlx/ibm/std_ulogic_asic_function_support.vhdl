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





library IEEE,IBM;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IBM.std_ulogic_support.all;
use IBM.std_ulogic_function_support.all;
use IBM.synthesis_support.all;

package std_ulogic_asic_function_support is

  subtype std_return_2 is std_ulogic_vector(0 to 1);
  subtype std_return_3 is std_ulogic_vector(0 to 2);
  subtype std_return_4 is std_ulogic_vector(0 to 3);

  type SUV2    is array(natural range <>) of std_ulogic_vector(0 to 1);
  type SUV3    is array(natural range <>) of std_ulogic_vector(0 to 2);
  type SUV4    is array(natural range <>) of std_ulogic_vector(0 to 3);
  type SUV5    is array(natural range <>) of std_ulogic_vector(0 to 4);
  type SUV6    is array(natural range <>) of std_ulogic_vector(0 to 5);
  type SUV7    is array(natural range <>) of std_ulogic_vector(0 to 6);
  type SUV8    is array(natural range <>) of std_ulogic_vector(0 to 7);
  type SUV9    is array(natural range <>) of std_ulogic_vector(0 to 8);
  type SUV10   is array(natural range <>) of std_ulogic_vector(0 to 9);
  type SUV11   is array(natural range <>) of std_ulogic_vector(0 to 10);
  type SUV12   is array(natural range <>) of std_ulogic_vector(0 to 11);
  type SUV13   is array(natural range <>) of std_ulogic_vector(0 to 12);
  type SUV14   is array(natural range <>) of std_ulogic_vector(0 to 13);
  type SUV15   is array(natural range <>) of std_ulogic_vector(0 to 14);
  type SUV16   is array(natural range <>) of std_ulogic_vector(0 to 15);
  type SUV24   is array(natural range <>) of std_ulogic_vector(0 to 23);
  type SUV32   is array(natural range <>) of std_ulogic_vector(0 to 31);
  type SUV48   is array(natural range <>) of std_ulogic_vector(0 to 47);
  type SUV64   is array(natural range <>) of std_ulogic_vector(0 to 63);
  type SUV128  is array(natural range <>) of std_ulogic_vector(0 to 127);
  type SUV256  is array(natural range <>) of std_ulogic_vector(0 to 255);

  attribute ADDER_EXPANSION : STRING;
  attribute NOT_AN_ARRAY : BOOLEAN;

  function GAND (
                 g: std_ulogic;
                 a: std_ulogic_vector)           return std_ulogic_vector;
  function GNAND (
                  g: std_ulogic;
                  a: std_ulogic_vector)          return std_ulogic_vector;
  function GOR (
                g: std_ulogic;
                a: std_ulogic_vector)            return std_ulogic_vector;
  function GNOR (
                 g: std_ulogic;
                 a: std_ulogic_vector)           return std_ulogic_vector;
  function GXOR (
                 g: std_ulogic;
                 a: std_ulogic_vector)           return std_ulogic_vector;
  function GXNOR (
                  g: std_ulogic;
                  a: std_ulogic_vector)          return std_ulogic_vector;
  function VAND (a: std_ulogic_vector)           return std_ulogic;
  function VNAND (a: std_ulogic_vector)          return std_ulogic;
  function VOR (a: std_ulogic_vector)            return std_ulogic;
  function VNOR (a: std_ulogic_vector)           return std_ulogic;
  function VXOR (a: std_ulogic_vector)           return std_ulogic;
  function VXNOR (a: std_ulogic_vector)          return std_ulogic;

  function LOG2 (input: natural)                 return natural;
         attribute FUNCTIONALITY of LOG2 :        function is "LOG2";

  function LG2 (input: natural)                  return natural;

  function MINBITS (input: natural)              return natural;

  function ENCODE (data: std_ulogic_vector)      return std_ulogic_vector;
  function ENCODE_4TO2 (data: std_ulogic_vector(0 to 3))
                                             return std_return_2;
  function ENCODE_8TO3 (data: std_ulogic_vector(0 to 7))
                                             return std_return_3;
  function ENCODE_16TO4 (data: std_ulogic_vector(0 to 15))
                                             return std_return_4;

  function MAX (a,b: std_ulogic_vector)          return std_ulogic_vector;
  function MAX (a,b: natural)                    return natural;
  function SMALLEST (a,b: std_ulogic_vector)     return std_ulogic_vector;
  function SMALLEST (a,b: natural)               return natural;
  function MIN0 (a: std_ulogic_vector)           return std_ulogic_vector;

  function SIFT (data,comb: std_ulogic_vector)   return std_ulogic;

  function MUX2 (
                 s: std_ulogic;
                 in0:std_ulogic;
                 in1:std_ulogic)                 return std_ulogic;
  function MUX2 (
                 s: boolean;
                 in0:std_ulogic;
                 in1:std_ulogic)                 return std_ulogic;
  function MUX2 (
                 s: std_ulogic;
                 in0:std_ulogic_vector;
                 in1:std_ulogic_vector)          return std_ulogic_vector;
  function MUX2 (
                 s: boolean;
                 in0:std_ulogic_vector;
                 in1:std_ulogic_vector)          return std_ulogic_vector;

  function PDEC (a : std_ulogic_vector)          return std_ulogic_vector;

  function RRARB (
                  data_in : std_ulogic_vector;
                  last_in : std_ulogic_vector)   return std_ulogic_vector;

  function BSHIFT (
                   data_in : std_ulogic_vector;
                   count : natural)              return std_ulogic_vector;

  function UPDN_GREY (
                      grey_in   : std_ulogic_vector;
                      parity_in : std_ulogic;
                      updn      : std_ulogic)    return std_ulogic_vector;

  function GENPARITY (data_in : std_ulogic_vector) return std_ulogic_vector;
  function GENPARITY (
                      data_in :std_ulogic_vector;
                      w: natural)                return std_ulogic_vector;

  function ONLYONE(d: in std_ulogic_vector) return boolean;
  function ONLYONE(d: in std_ulogic_vector) return std_ulogic;
  function ONLYONE_ORZERO(d: in std_ulogic_vector) return boolean;
  function ONLYONE_ORZERO(d: in std_ulogic_vector) return std_ulogic;

end std_ulogic_asic_function_support;

package body std_ulogic_asic_function_support is

  function GAND (
                 g : std_ulogic;
                 a : std_ulogic_vector) return std_ulogic_vector is
  begin
    return gate_and(g, a);
  end GAND;

  function GNAND (
                  g : std_ulogic;
                  a : std_ulogic_vector) return std_ulogic_vector is
  begin
    return gate_nand(g, a);
  end GNAND;

  function GOR (
                g : std_ulogic;
                a : std_ulogic_vector) return std_ulogic_vector is
  begin
    return gate_or(g, a);
  end GOR;

  function GNOR (
                 g : std_ulogic;
                 a : std_ulogic_vector) return std_ulogic_vector is
  begin
    return gate_nor(g, a);
  end GNOR;

  function GXOR (
                 g : std_ulogic;
                 a : std_ulogic_vector) return std_ulogic_vector is
  begin
    return gate_xor(g, a);
  end GXOR;

  function GXNOR (
                 g : std_ulogic;
                 a : std_ulogic_vector) return std_ulogic_vector is
  begin
    return gate_xnor(g, a);
  end GXNOR;

  function VAND (a : std_ulogic_vector) return std_ulogic is
  begin
    return and_reduce(a);
  end VAND;

  function VNAND (a : std_ulogic_vector) return std_ulogic is
  begin
    return nand_reduce(a);
  end VNAND;

  function VOR (a : std_ulogic_vector) return std_ulogic is
  begin
    return or_reduce(a);
  end VOR;

  function VNOR (a : std_ulogic_vector) return std_ulogic is
  begin
    return nor_reduce(a);
  end VNOR;

  function VXOR (a : std_ulogic_vector) return std_ulogic is
  begin
    return xor_reduce(a);
  end VXOR;

  function VXNOR (a : std_ulogic_vector) return std_ulogic is
  begin
    return xnor_reduce(a);
  end VXNOR;

  function LOG2(input : natural) return natural is
    variable z: natural;
  begin
    z:=32;
    for i in 0 to 30 loop
      if 2**i=input then z:=i; end if;
    end loop;
    assert  z <32
      report "Log2 illegal"
      severity error;
    return z;
  end LOG2;

  function LG2 (input : natural) return natural is
  begin
    case (input) is
      when 0              => return 0;
      when 1 to 2         => return 1;
      when 3 to 4         => return 2;
      when 5 to 8         => return 3;
      when 9 to 16        => return 4;
      when 17 to 32       => return 5;
      when 33 to 64       => return 6;
      when 65 to 128      => return 7;
      when 129 to 256     => return 8;
      when 257 to 512     => return 9;
      when 513 to 1024    => return 10;
      when 1025 to 2048   => return 11;
      when 2049 to 4096   => return 12;
      when 4097 to 8192   => return 13;
      when 8193 to 16384  => return 14;
      when 16385 to 32768 => return 15;
      when others      => return 0;
    end case;
  end LG2;

  function MINBITS(input : natural) return natural is
    variable z: natural := 0;
    variable t: std_ulogic_vector(0 to 31);
  begin
    z := 0;
    t := tconv(input,32);
    for i in 0 to 31 loop
      if t(i)='1' then
         z:= (32 - i);
         exit;
      end if;
    end loop;
    assert z /= 0
      report "MINBITS Illegal"
      severity error;
    return z;
  end MINBITS;

  function ENCODE(data : std_ulogic_vector) return std_ulogic_vector is
    variable a : std_ulogic_vector(1 to data'length-1);
    variable z : std_ulogic_vector(0 to log2(data'length)-1);
    variable N : natural;
  begin
    N := log2(data'length);
    assert  N > 2
      report "ENCODE illegal"
      severity error;
    a := data(data'left+1 to data'right);
    for i in 0 to N-1 loop
      z(i) := '0';
      for j in 1 to 2**(N-1-i) loop   
        for k in 1 to 2**i loop             
          z(i) := z(i) or a( k*2**(N-i)-j);
        end loop;
      end loop;
    end loop;
    return z;
  end ENCODE;

  function ENCODE_4TO2(data : std_ulogic_vector(0 to 3))
                       return std_return_2 is
    variable a : std_ulogic_vector(1 to 3);
    variable z : std_ulogic_vector(0 to 1);
  begin
    a := data(data'left+1 to data'right);
    z(0) := a(2) or a(3);
    z(1) := a(1) or a(3);
    return z;
  end ENCODE_4TO2;

  function ENCODE_8TO3(data : std_ulogic_vector(0 to 7))
                       return std_return_3 is
    variable a : std_ulogic_vector(1 to 7);
    variable z : std_ulogic_vector(0 to 2);
  begin
    a := data(data'left+1 to data'right);
    z(0) := a(4) or a(5) or a(6) or a(7);
    z(1) := a(2) or a(3) or a(6) or a(7);
    z(2) := a(1) or a(3) or a(5) or a(7);
    return z;
  end ENCODE_8TO3;

  function ENCODE_16TO4(data : std_ulogic_vector(0 to 15))
                        return std_return_4 is
    variable a : std_ulogic_vector(1 to 15);
    variable z : std_ulogic_vector(0 to 3);
  begin
    a := data(data'left+1 to data'right);
    z(0) := a(8) or a(9) or a(10) or a(11) or a(12) or a(13) or a(14) or a(15);
    z(1) := a(4) or a(5) or a(6) or a(7) or a(12) or a(13) or a(14) or a(15);
    z(2) := a(2) or a(3) or a(6) or a(7) or a(10) or a(11) or a(14) or a(15);
    z(3) := a(1) or a(3) or a(5) or a(7) or a(9) or a(11) or a(13) or a(15);
    return z;
  end ENCODE_16TO4;

  function MUX2(
                s: std_ulogic;
                in0: std_ulogic;
                in1: std_ulogic) return std_ulogic is
    variable z: std_ulogic;
  begin
    if (s='1')
      then
        z:=in0;
      else
        z:=in1;
    end if;
    return z;
  end MUX2;

  function MUX2(
                s: boolean;
                in0: std_ulogic;
                in1: std_ulogic) return std_ulogic is
    variable z: std_ulogic;
  begin
    if (s)
      then
        z:=in0;
      else
        z:=in1;
    end if;
    return z;
  end MUX2;

  function MUX2(
                s: std_ulogic;
                in0: std_ulogic_vector;
                in1: std_ulogic_vector) return std_ulogic_vector is
    variable z: std_ulogic_vector(0 to in0'length-1);
    variable tmp0: std_ulogic_vector(0 to in0'length-1);
    variable tmp1: std_ulogic_vector(0 to in1'length-1);
  begin
    tmp0 := in0;
    tmp1 := in1;
    if (s='1')
      then
        z:=tmp0;
      else
        z:=tmp1;
    end if;
    return z;
  end MUX2;

  function MUX2(
                s: boolean;
                in0: std_ulogic_vector;
                in1: std_ulogic_vector) return std_ulogic_vector is
    variable z: std_ulogic_vector(0 to in0'length-1);
    variable tmp0: std_ulogic_vector(0 to in0'length-1);
    variable tmp1: std_ulogic_vector(0 to in1'length-1);
  begin
    tmp0 := in0;
    tmp1 := in1;
    if (s)
      then
        z:=tmp0;
      else
        z:=tmp1;
    end if;
    return z;
  end MUX2;


  function MAX (a,b: std_ulogic_vector) return std_ulogic_vector is
    variable z: std_ulogic_vector(a'range);
    variable atmp: std_ulogic_vector(0 to a'length-1);
    variable btmp: std_ulogic_vector(0 to b'length-1);
  begin
    atmp := a;
    btmp := b;
    if (atmp > btmp)
      then
        z:=atmp;
      else
        z:=btmp;
    end if;
    return z;
  end MAX;

  function MAX (a,b: natural) return natural is
    variable z: natural;
  begin
    if (a>b)
      then
        z:=a;
      else
        z:=b;
    end if;
    return z;
  end MAX;

  function SMALLEST (a,b: std_ulogic_vector) return std_ulogic_vector is
    variable z: std_ulogic_vector(a'range);
    variable atmp: std_ulogic_vector(0 to a'length-1);
    variable btmp: std_ulogic_vector(0 to b'length-1);
  begin
    atmp := a;
    btmp := b;
    if (atmp < btmp)
      then
        z:=atmp;
      else
        z:=btmp;
    end if;
    return z;
  end SMALLEST;

  function SMALLEST (a,b: natural) return natural is
    variable z: natural;
  begin
    if (a<b)
      then
        z:=a;
      else
        z:=b;
    end if;
    return z;
  end SMALLEST;

  function MIN0 (a: std_ulogic_vector) return std_ulogic_vector is
    variable tmp: std_ulogic_vector(0 to a'length -1);
    variable z: std_ulogic_vector(0 to a'length-2);  
  begin
    tmp := a;
    if tmp(0)='1'
      then
        z:= (others => '0');
      else
        z := tmp(1 to tmp'length-1);
    end if;
    return z;
  end MIN0;

  function SIFT  (data,comb: std_ulogic_vector) return std_ulogic is
    variable z: std_ulogic;
    variable dtmp: std_ulogic_vector(0 to data'length -1);
    variable ctmp: std_ulogic_vector(0 to comb'length -1);
  begin
    dtmp := data;
    ctmp := comb;
    if or_reduce(dtmp and ctmp) = '1'
      then
        z:='1';
      else
        z:='0';
    end if;
    return z;
  end SIFT;

  function PDEC(a : std_ulogic_vector) return std_ulogic_vector is
    variable tmp,z : std_ulogic_vector(0 to a'length-1);
  begin
    tmp := a;
    z(0) := tmp(0);
    if tmp(0) = '1'
      then
        z(1) := '0';
      else
        z(1) := tmp(1);
    end if;
    for i in 2 to a'length-1 loop
      if or_reduce( tmp(0 to i-1) ) ='1'
        then
          z(i) := '0';
        else
          z(i) := tmp(i);
      end if;
    end loop;
    return z;
  end PDEC;

  function RRARB(
                 data_in: std_ulogic_vector;
                 last_in : std_ulogic_vector) return std_ulogic_vector is
    variable d,l,z : std_ulogic_vector(0 to data_in'length -1);
    variable x,t   : std_ulogic;   
    variable n     : natural;

  begin
    d := data_in;
    l := last_in;
    n := data_in'length;
    for i in 0 to n-1 loop
      x := l(i);                 
      for j in 1 to n-1 loop
        t := l( (n-j+i) mod n );  
        for k in 0 to j-1 loop
          t := t and not d( (n-j+i+k) mod n );
        end loop;
        x := x or t;
      end loop;
      z(i) := d(i) and x;
    end loop;
    return z;
  end RRARB;

  function BSHIFT(
                  data_in : std_ulogic_vector;
                  count : natural) return std_ulogic_vector is
    variable a,z : std_ulogic_vector(0 to data_in'length-1);
    variable index : natural;
  begin
    a := data_in;
    for i in 0 to a'length-1 loop
      index := (i+count) mod a'length;
      z(i) := a(index);
    end loop;
    return z;
  end BSHIFT;

  function UPDN_GREY (
                      grey_in   : std_ulogic_vector;
                      parity_in : std_ulogic;
                      updn      : std_ulogic) return std_ulogic_vector is
    constant width : positive := grey_in'length;
    variable tmp : std_ulogic_vector(0 to width);
    variable grey_out : std_ulogic_vector(0 to width-1);
  begin
    tmp := grey_in & (parity_in xor not updn);
    grey_out(0) := tmp(0) xor nor_reduce(tmp(2 to width));
    if (width > 2)
      then
        for i in 1 to width-2 loop
          if (i+2 = width)
            then
              grey_out(i) := tmp(i) xor (tmp(i+1) and not(tmp(i+2)));
            else
              grey_out(i) := tmp(i) xor
                             (tmp(i+1) and nor_reduce(tmp(i+2 to width)));
          end if;
        end loop;
    end if;
    grey_out(width-1) := tmp(width-1) xor tmp(width);
    return grey_out;
  end function UPDN_GREY;

  function GENPARITY(
                     data_in :std_ulogic_vector;
                     w: natural) return std_ulogic_vector is
    variable data : std_ulogic_vector(0 to data_in'length-1);
    variable z    : std_ulogic_vector(0 to (data_in'length/w)-1);
  begin
    assert (data_in'length mod w) = 0
      report "unsupported data length in GenParity"
      severity error;

    data := data_in;  
    for i in 0 to data'length/w -1 loop
      z(i) := xnor_reduce(data(w*i to w*(i+1)-1));
    end loop;
    return z;
  end GENPARITY;

  function GENPARITY(data_in : std_ulogic_vector) return std_ulogic_vector is
    variable data : std_ulogic_vector(0 to data_in'length-1);
    variable z    : std_ulogic_vector(0 to (data_in'length/8)-1);
  begin
    data := data_in;
    z := genparity(data,8);
    return z;
  end GENPARITY;

  function ONLYONE(d: in std_ulogic_vector) return boolean is
    variable result : boolean;
    variable result_vec: std_ulogic_vector(0 to d'length-1);
    variable data: std_ulogic_vector(0 to d'length-1);
    variable data_vec: std_ulogic_vector(0 to (d'length * d'length)-1);
  begin
    data := d;
    result:=false;

    for i in 0 to d'length-1 loop
      for j in 0 to d'length-1 loop
        if i=j
          then
            data_vec((i*d'length)+j) := not(data(j));
          else
            data_vec((i*d'length)+j) := data(j);
        end if;
      end loop;
    end loop;

    for k in 0 to d'length-1 loop
      result_vec(k) := not(or_reduce(data_vec((k*d'length) to ((k*d'length)+d'length-1))));
    end loop;

    if (or_reduce(result_vec(0 to d'length-1)) = '1')
      then
        result := true;
    end if;

    return result;
  end ONLYONE;

  function ONLYONE(d: in std_ulogic_vector) return std_ulogic is
    variable result : std_ulogic;
    variable result_vec: std_ulogic_vector(0 to d'length-1);
    variable data: std_ulogic_vector(0 to d'length-1);
    variable data_vec: std_ulogic_vector(0 to (d'length * d'length)-1);
  begin
    data := d;

    for i in 0 to d'length-1 loop
      for j in 0 to d'length-1 loop
        if i=j
          then
            data_vec((i*d'length)+j) := not(data(j));
          else
            data_vec((i*d'length)+j) := data(j);
        end if;
      end loop;
    end loop;

    for k in 0 to d'length-1 loop
      result_vec(k) := not(or_reduce(data_vec((k*d'length) to ((k*d'length)+d'length-1))));
    end loop;

    result := or_reduce(result_vec(0 to d'length-1));

    return result;
  end ONLYONE;

  function ONLYONE_ORZERO(d: in std_ulogic_vector) return boolean is
    variable result : boolean;
    variable result_vec: std_ulogic_vector(0 to d'length-1);
    variable data: std_ulogic_vector(0 to d'length-1);
    variable data_vec: std_ulogic_vector(0 to (d'length * d'length)-1);
  begin
    data := d;
    result:=false;

    for i in 0 to d'length-1 loop
      for j in 0 to d'length-1 loop
        if i=j
          then
            data_vec((i*d'length)+j) := not(data(j));
          else
            data_vec((i*d'length)+j) := data(j);
        end if;
      end loop;
    end loop;

    for k in 0 to d'length-1 loop
      result_vec(k) := not(or_reduce(data_vec((k*d'length) to ((k*d'length)+d'length-1))));
    end loop;

    if ((or_reduce(result_vec(0 to d'length-1)) = '1') or
        (not(or_reduce(data(0 to d'length-1))) = '1'))
      then
        result := true;
    end if;

    return result;
  end ONLYONE_ORZERO;

  function ONLYONE_ORZERO(d: in std_ulogic_vector) return std_ulogic is
    variable result : std_ulogic;
    variable result_vec: std_ulogic_vector(0 to d'length-1);
    variable data: std_ulogic_vector(0 to d'length-1);
    variable data_vec: std_ulogic_vector(0 to (d'length * d'length)-1);
  begin
    data := d;

    for i in 0 to d'length-1 loop
      for j in 0 to d'length-1 loop
        if i=j
          then
            data_vec((i*d'length)+j) := not(data(j));
          else
            data_vec((i*d'length)+j) := data(j);
        end if;
      end loop;
    end loop;

    for k in 0 to d'length-1 loop
      result_vec(k) := not(or_reduce(data_vec((k*d'length) to ((k*d'length)+d'length-1))));
    end loop;

    result := or_reduce(result_vec(0 to d'length-1)) or
              not(or_reduce(data(0 to d'length-1)));

    return result;
  end ONLYONE_ORZERO;

end std_ulogic_asic_function_support;
