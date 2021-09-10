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




library ieee, ibm;
use     ieee.std_logic_1164.all;
use     ibm.std_ulogic_support.all;
use     ibm.std_ulogic_unsigned.all;
use     ibm.std_ulogic_function_support.all;

package design_util_functions_pkg is


  constant BYTE_WIDTH : positive := 8;

  type De_Search_Direction is (DE_LEFT_DIR, DE_RIGHT_DIR);

  function de_decoder(A: std_ulogic_vector) 
           return std_ulogic_vector;
  function de_decoder(A: std_ulogic_vector;
                      len: positive) 
           return std_ulogic_vector;
  function de_decoder_varidx(A: std_ulogic_vector)
           return std_ulogic_vector;
  function de_decoder_varidx(A: std_ulogic_vector;
                      len: positive) 
           return std_ulogic_vector;

  function de_encoder(onehot : std_ulogic_vector)
           return std_ulogic_vector;


  function  de_firstone(
               a: std_ulogic_vector)
            return std_ulogic_vector; 

  function  de_firstone_check(
               a: std_ulogic_vector)
            return std_ulogic_vector; 

  function  de_firstzero(
               a: std_ulogic_vector)
            return std_ulogic_vector; 

  function  de_firstone_onehot(
               a: std_ulogic_vector;
               direction: De_Search_Direction := DE_LEFT_DIR)
            return std_ulogic_vector; 

  function  de_firstzero_onehot(
               a: std_ulogic_vector;
               direction: De_Search_Direction := DE_LEFT_DIR)
            return std_ulogic_vector; 

  function de_countones(A:std_ulogic_vector)
           return std_ulogic_vector; 

  function de_countzeros(A:std_ulogic_vector)
           return std_ulogic_vector; 


  function de_oddparity(A: std_ulogic_vector)
               return std_ulogic;

  function de_oddparity(A: std_ulogic_vector;
                        w: positive := BYTE_WIDTH)
               return std_ulogic_vector;

  function de_evenparity(A: std_ulogic_vector)
               return std_ulogic;

  function de_evenparity(A: std_ulogic_vector;
                         w: positive := BYTE_WIDTH)
               return std_ulogic_vector;

  function de_inc_parity_flip(a: std_ulogic_vector)
           return std_ulogic;

  function de_dec_parity_flip(a: std_ulogic_vector)
           return std_ulogic;


  function de_increment(A: std_ulogic_vector;
                        B: natural := 1)
           return std_ulogic_vector;
  
  function de_decrement(A: std_ulogic_vector;
                        B: natural := 1)
           return std_ulogic_vector;

  function de_nextgrayvalue(A:std_ulogic_vector)
           return std_ulogic_vector;

  function de_prevgrayvalue(A:std_ulogic_vector)
           return std_ulogic_vector;

  function de_nextgrayvalue_bal(A:std_ulogic_vector)
           return std_ulogic_vector;

  function de_prevgrayvalue_bal(A:std_ulogic_vector)
           return std_ulogic_vector;

  function de_bin2gray(A:std_ulogic_vector)
           return std_ulogic_vector;
  
  function de_gray2bin(A:std_ulogic_vector)
           return std_ulogic_vector; 

  function  de_bin2therm(a: std_ulogic_vector; 
                       len: positive) 
            return std_ulogic_vector; 

  function  de_bin2therm(a: std_ulogic_vector)
            Return std_ulogic_vector; 

  function  de_therm2bin(a: std_ulogic_vector)
            Return std_ulogic_vector; 

  function  de_bin2therm_comp(a: std_ulogic_vector; 
                       len: positive) 
            return std_ulogic_vector; 

  function  de_bin2therm_comp(a: std_ulogic_vector)
            Return std_ulogic_vector; 

  function  de_therm2bin_comp(a: std_ulogic_vector)
            Return std_ulogic_vector; 


  function de_reverse(A: std_ulogic_vector)
           return std_ulogic_vector;
 
  function de_var_slice(A: std_ulogic_vector;
                        idx: natural;
                        width: natural)
           return std_ulogic_vector;
  function de_log2 (A : natural) return natural; 

end design_util_functions_pkg;


package body design_util_functions_pkg is
  function de_decoder(A: std_ulogic_vector) 
           return std_ulogic_vector is
    variable result: std_ulogic_vector(0 to 2**A'length - 1);
  begin
    for i in result'range loop
      result(i) := A = i;
    end loop;
    return result;
  end;

  function de_decoder_varidx(A: std_ulogic_vector) 
           return std_ulogic_vector is
    variable result: std_ulogic_vector(0 to 2**A'length - 1);
  begin
    result := (others => '0');
    result(tconv(A)) := '1';
    return result;
  end;

  function de_decoder(A: std_ulogic_vector;
                      len: positive) 
           return std_ulogic_vector is
    variable result: std_ulogic_vector(0 to len - 1);
  begin
    for i in result'range loop
      result(i) := A = i;
    end loop;
    return result;
  end;

  function de_decoder_varidx(A: std_ulogic_vector;
                             len: positive) 
           return std_ulogic_vector is
    variable result: std_ulogic_vector(0 to len - 1);
  begin
    result := (others => '0');
    result(tconv(A)) := '1';
    return result;
  end;

  function de_log2 (A : natural) return natural is
     variable val   : integer;
     variable width : natural;

  begin
    if (A = 0) then
       return 0;
    elsif (A = 1) then
       return 1; 
    else
      val := A-1;
    end if;
    width := 0;
    while val > 0  loop
      val   := val/2;
      width :=  width + 1;
    end loop;
    return width;
  end;

  function de_encoder(onehot : std_ulogic_vector)
           return std_ulogic_vector is
    constant size: natural := de_log2(onehot'length);
    variable binvec : std_ulogic_vector(size-1 downto 0);
    alias onehot_alias: std_ulogic_vector(0 to onehot'length - 1) is onehot;
  begin
    binvec := (others => '0');
    for I in binvec'range loop
      for J in onehot_alias'range loop
        if (((J / (2**I)) mod 2) = 1) then
          binvec(I) := binvec(I) or onehot_alias(J);
        end if;
      end loop;
    end loop;

    return binvec;
  end function;

  function de_rmcommonfact(i: integer; j: integer; size: integer) 
           return integer is
    variable result: integer;
  begin
    result := 0;
    for k in j-1 downto 0 loop
        if (((k / (2**(size-1-I))) mod 2) = 1) then
           result := result+1;
        else
           exit;
        end if;
    end loop;   
    return result;
  end;

  function  de_firstone(
               a: std_ulogic_vector)
            return std_ulogic_vector is
    constant size: natural := de_log2(a'length);
    variable binvec : std_ulogic_vector(0 to size - 1);
    alias a_alias: std_ulogic_vector(0 to a'length-1) is a;
    variable tmp : std_ulogic_vector(0 to a'length-1);

  begin
     tmp (0) := not a_alias(0);
     for i in 1 to a'length-1 loop
          tmp(i) := (not a_alias(i)) and tmp(i-1);
     end loop;
     binvec := (others => '0');
     for I in binvec'range loop
        for J in a_alias'range loop
          if (((J / (2**(size-1-I))) mod 2) = 1) then
            binvec(I) := binvec(I) or (a_alias(J) and tmp(J-1-
                     de_rmcommonfact(i,j,size)));
          end if;
        end loop;
      end loop;

   return binvec;
  end;

  function  de_firstone_check(
               a: std_ulogic_vector)
            return std_ulogic_vector is
    constant size: natural := de_log2(a'length);
    variable binvec : std_ulogic_vector(0 to size - 1);
    alias a_alias: std_ulogic_vector(0 to a'length-1) is a;
    variable tmp : std_ulogic_vector(0 to a'length-1);
    variable allzeros: std_ulogic;
  begin
     allzeros := not or_reduce(a_alias);
     tmp (0) := not a_alias(0);
     for i in 1 to a'length-1 loop
          tmp(i) := (not a_alias(i)) and tmp(i-1);
     end loop;
     binvec := (others => allzeros);
     for I in binvec'range loop
        for J in a_alias'range loop
          if (((J / (2**(size-1-I))) mod 2) = 1) then
            binvec(I) := binvec(I) or (a_alias(J) and tmp(J-1-
                     de_rmcommonfact(i,j,size)));
          end if;
        end loop;
      end loop;

   return allzeros & binvec;
  end;

  function  de_firstzero(
               a: std_ulogic_vector)
            return std_ulogic_vector is
    constant size: natural := de_log2(a'length);
    variable binvec : std_ulogic_vector(0 to size - 1);
    alias a_alias: std_ulogic_vector(0 to a'length-1) is a;
    variable tmp : std_ulogic_vector(0 to a'length-1);

  begin
     tmp (0) :=  a_alias(0);
     for i in 1 to a'length-1 loop
          tmp(i) := (a_alias(i)) and tmp(i-1);
     end loop;
     binvec := (others => '0');
     for I in binvec'range loop
        for J in a_alias'range loop
          if (((J / (2**(size-1-I))) mod 2) = 1) then
            binvec(I) := binvec(I) or (not a_alias(J) and tmp(J-1));
          end if;
        end loop;
      end loop;

   return binvec;
  end;

  function  de_firstone_onehot(
               a: std_ulogic_vector;
               direction: De_Search_Direction := DE_LEFT_DIR)
            return std_ulogic_vector is
     constant len: natural := A'length;
     alias a_val: std_ulogic_vector(0 to len -1)
                       is A;
     variable tmp: std_ulogic_vector(0 to len - 1);
  begin
    if (direction = DE_RIGHT_DIR) then
       tmp(len-1) := '0';
       for i in len-2 downto 0 loop
          tmp(i) := tmp(i+1) or a_val(i+1);
       end loop;
    else
       tmp(0) := '0';
       for i in 1 to len - 1  loop
          tmp(i) := tmp(i-1) or a_val(i-1);
       end loop;
    end if;
    return a_val and not tmp;
  end;

  function  de_firstzero_onehot(
               a: std_ulogic_vector;
               direction: De_Search_Direction := DE_LEFT_DIR)
            return std_ulogic_vector is
     constant len: natural := A'length;
     alias a_val: std_ulogic_vector(0 to len -1)
                       is A;
     variable tmp: std_ulogic_vector(0 to len - 1);
  begin
    if (direction = DE_RIGHT_DIR) then
       tmp(len-1) := '1';
       for i in len-2 downto 0 loop
          tmp(i) := tmp(i+1) and a_val(i+1);
       end loop;
    else
       tmp(0) := '1';
       for i in 1 to len - 1  loop
          tmp(i) := tmp(i-1) and a_val(i-1);
       end loop;
    end if;
    return not a_val and tmp;
  end;

  function  de_bin2therm(a: std_ulogic_vector; 
                       len: positive) 
            return std_ulogic_vector is
    variable result: std_ulogic_vector(0 to len-1);
  begin
     for i in result'range loop
       result(i) := a >= len-1-i;
     end loop;
     return result;
  end;

  function  de_bin2therm(a: std_ulogic_vector)
            return std_ulogic_vector is
    constant len: natural := 2**a'length-1;
    variable result: std_ulogic_vector(0 to len-1);
  begin
     for i in result'range loop
       result(i) := a >= len-i;
     end loop;
     return result;
  end;

  function  de_therm2bin(a: std_ulogic_vector)
            return std_ulogic_vector is
    constant len: natural := de_log2(a'length+1);
    variable result: std_ulogic_vector(0 to len-1);
  begin
     if (a = (a'range => '1')) then
        result :=  tconv(a'length, result'length); 
     else
        result := de_firstzero(de_reverse(a)); 
     end if;
     return result;
  end;

  function  de_bin2therm_comp(a: std_ulogic_vector; 
                              len: positive) 
            return std_ulogic_vector is
    variable result: std_ulogic_vector(0 to len-1);
  begin
     for i in result'range loop
       result(i) := i >= a;
     end loop;
     return result;
  end;

  function  de_bin2therm_comp(a: std_ulogic_vector)
            return std_ulogic_vector is
    constant len: natural := 2**a'length;
    variable result: std_ulogic_vector(0 to len-1);
  begin
     for i in result'range loop
       result(i) := i >= a;
     end loop;
     return result;
  end;

  function  de_therm2bin_comp(a: std_ulogic_vector)
            return std_ulogic_vector is
    constant len: natural := de_log2(a'length+1);
    variable result: std_ulogic_vector(0 to len-1);
  begin
     result := de_firstone(a); 
     return result;
  end;

  function de_util(len: natural) return natural is
  begin
     if len = 0 then
        return 0;
     else
        return de_log2(len-len/2+1);
     end if;
  end;

  function de_countones(A:std_ulogic_vector)
           return std_ulogic_vector is
    constant len: natural := A'length;
    variable result: std_ulogic_vector(0 to de_log2(len + 1) -1); 
    alias B : std_ulogic_vector(0 to len-1) is A;  
    variable tmp: std_ulogic_vector(0 to de_util(len));
  begin
      if len = 0 then
         result := (others => '0');
      elsif len = 1 then
         result := (others => B(0));  
      elsif len = 2 then
        result(0) := B(0) and B(1);
        result(1) := B(0) xor B(1);
      else
        tmp := ('0' & de_countones(B(0 to len/2 - 1))) +
                  ('0' & de_countones(B(len/2 to len-1))); 
        result := tmp (tmp'length-result'length to
                      tmp'right);
      end if;
      return result;
  end;

  function de_countzeros(A:std_ulogic_vector)
           return std_ulogic_vector is
    constant len: natural := A'length;
    variable result: std_ulogic_vector(0 to de_log2(len + 1) -1); 
    alias B : std_ulogic_vector(0 to len-1) is A;  
    variable tmp: std_ulogic_vector(0 to de_util(len));
  begin
      if len = 0 then
         result := (others => '0');
      elsif len = 1 then
         result := (others => not B(0));  
      elsif len = 2 then
        result(0) := not (B(0) or B(1));
        result(1) := B(0) xor B(1);
      else
        tmp := ('0' & de_countzeros(B(0 to len/2 - 1))) +
                  ('0' & de_countzeros(B(len/2 to len-1))); 
        result := tmp (tmp'length-result'length to
                      tmp'right);
      end if;
      return result;
  end;

  function de_oddparity(A: std_ulogic_vector)
               return std_ulogic is
     variable result, lh, rh: std_ulogic;
     constant len: natural := A'length;
     alias B : std_ulogic_vector(0 to len-1) is A;
  begin
    if (len = 0) then
       result := '0';
    elsif (len = 1) then
       result := B(0);
    elsif (len = 2) then
       result := B(0) xor B(1);
    elsif (len = 3) then
       result := B(0) xor (B(1) xor B(2));
    elsif (len = 4) then
       result := (B(0) xor B(1)) xor (B(2) xor B(3));
    else
      lh := de_oddparity(B(0 to len/2 - 1));
      rh := de_oddparity(B(len/2 to len-1));
      result := lh xor rh;
    end if;
    return result;
  end;

  function de_evenparity(A: std_ulogic_vector)
               return std_ulogic is
  begin
    return not de_oddparity(A);
  end;

  function de_oddparity(A: std_ulogic_vector;
                        w: positive := BYTE_WIDTH)
               return std_ulogic_vector is
    constant len: natural := A'length;
    alias val: std_ulogic_vector(0 to (len/w)*w -1) 
                                   is A;
    variable result: std_ulogic_vector(0 to len/w - 1);
  begin
     for i in result'range loop
       result(i) := de_oddparity(val(w*i to w*(i+1) - 1));
     end loop;
     return result;
  end;

  function de_evenparity(A: std_ulogic_vector;
                        w: positive := BYTE_WIDTH)
               return std_ulogic_vector is
    constant len: natural := A'length;
    alias val: std_ulogic_vector(0 to (len/w)*w -1) 
                                   is A;
    variable result: std_ulogic_vector(0 to len/w - 1);
  begin
     for i in result'range loop
       result(i) := de_evenparity(val(w*i to w*(i+1) - 1));
     end loop;
     return result;
  end;

  function de_increment(A: std_ulogic_vector;
                        B: natural := 1)
           return std_ulogic_vector is
  begin
    return A + B;
  end;

  function de_decrement(A: std_ulogic_vector;
                        B: natural := 1)
           return std_ulogic_vector is
  begin
     return A - B;
  end;
 
  function de_reverse(A: std_ulogic_vector)
           return std_ulogic_vector is
    variable result: std_ulogic_vector(A'reverse_range);
  begin
    for i in A'range loop
       result(i) := A(i);
    end loop;
    return result;
  end;

  function de_nextgrayvalue(A:std_ulogic_vector)
           return std_ulogic_vector is
     constant len: positive := A'length;
     alias currentval: std_ulogic_vector(0 to len -1)
                       is A;
     variable changes_a, nochanges_b: 
                      std_ulogic_vector(0 to len - 1);
     variable parities: std_ulogic_vector(1 to len - 1);

  begin
    parities(1) := currentval(0);
    for i in 2 to len-1 loop
        parities(i) := parities(i-1) xor currentval(i-1); 
    end loop;

    changes_a := '1' &((parities xnor currentval(parities'range)));

    nochanges_b(len-1) := '0';               
    for i in len-2 downto 0 loop
       nochanges_b(i) := nochanges_b(i+1) or changes_a(i+1);
    end loop;

    return (changes_a and not nochanges_b) xor currentval;
  end;

  function de_nextgrayvalue_bal(A:std_ulogic_vector)
           return std_ulogic_vector is
     constant len: positive := A'length;
     alias currentval: std_ulogic_vector(0 to len -1)
                       is A;
     variable changes_a, nochanges_b: 
                      std_ulogic_vector(0 to len - 1);
     variable result, tmp: std_ulogic_vector(0 to len - 1);

  begin
    if (de_oddparity(currentval) = '1') then
       tmp := de_firstone_onehot(currentval, DE_RIGHT_DIR);
       tmp := (tmp(0) or tmp(1)) & tmp(2 to len-1) & '0';
       result := tmp xor currentval;
    else
       result := currentval(0 to len - 2) & not currentval(len-1);
    end if;      

    return result;
  end;

  function de_prevgrayvalue_bal(A:std_ulogic_vector)
           return std_ulogic_vector is
     constant len: positive := A'length;
     alias currentval: std_ulogic_vector(0 to len -1)
                       is A;
     variable changes_a, nochanges_b: 
                      std_ulogic_vector(0 to len - 1);
     variable result, tmp: std_ulogic_vector(0 to len - 1);

  begin
    if (de_oddparity(currentval) = '1') then
       result := currentval(0 to len - 2) & not currentval(len-1);
    else
       tmp := de_firstone_onehot(currentval, DE_RIGHT_DIR);
       tmp := ((tmp = (tmp'range => '0')) or tmp(1)) & tmp(2 to len-1) & '0';
       result := tmp xor currentval;
    end if;      

    return result;
  end;

  function de_prevgrayvalue(A:std_ulogic_vector)
           return std_ulogic_vector is
     constant len: positive := A'length;
     alias currentval: std_ulogic_vector(0 to len -1)
                       is A;
     variable changes_a, changes_b: 
                      std_ulogic_vector(0 to len - 1);
     variable parities: std_ulogic_vector(1 to len - 1);

  begin
    parities(1) := currentval(0);
    for i in 2 to len-1 loop
        parities(i) := parities(i-1) xor currentval(i-1); 
    end loop;

    changes_a := '0' &((parities xnor currentval(parities'range)));

    changes_b(len-1) := '1';               
    for i in len-2 downto 0 loop
       changes_b(i) := changes_b(i+1) and changes_a(i+1);
    end loop;

    return (not changes_a and  changes_b) xor currentval;
  end;
  
  function de_bin2gray(A:std_ulogic_vector)
           return std_ulogic_vector is
    constant len: positive := A'length;
    alias binval: std_ulogic_vector(0 to len -1)
                       is A;
    variable grayval: std_ulogic_vector(0 to len - 1);
  
  begin
     grayval(0) := binval(0);
     for i in 1 to len-1 loop
        grayval(i) := binval(i-1)  
                              xor binval(i);   
     end loop;
     return grayval;
  end;
  
  function de_gray2bin(A:std_ulogic_vector)
           return std_ulogic_vector is
    constant len: positive := A'length;
    alias grayval: std_ulogic_vector(0 to len -1)
                       is A;
    variable binval: std_ulogic_vector(0 to len - 1);
  begin
    binval(0) := grayval(0);
     for i in 1 to len-1 loop
        binval(i) := binval(i-1)
                              xor grayval(i);
     end loop;
     return binval;
  end;

  function de_inc_parity_flip(a: std_ulogic_vector)
           return std_ulogic is
    constant len: natural := a'length;
    alias d: std_ulogic_vector(len-1 downto 0) is a;
    variable tmp, result: std_ulogic;
  begin
     result := '0';
     for i in d'range loop
        if (i mod 2) = 1 then
           result := result and  d(i);
        else
           result := result or (not d(i));
        end if;
     end loop;
     return result;
  end;

  function de_dec_parity_flip(a: std_ulogic_vector)
           return std_ulogic is
    constant len: natural := a'length;
    alias d: std_ulogic_vector(len-1 downto 0) is a;
    variable tmp, result: std_ulogic;
  begin
     result := '0';
     for i in d'range loop
        if (i mod 2) = 1 then
           result := result and (not d(i));
        else
           result := result or d(i);
        end if;
     end loop;
     return result;
  end;

  function de_var_slice(A: std_ulogic_vector;
                        idx: natural;
                        width: natural)
           return std_ulogic_vector is
     variable result: std_ulogic_vector(0 to width - 1);
  begin
     for i in A'range loop
        if (idx = i) then
           result := A(i to i+width -1);
        end if;
     end loop;
     return result;
  end;


end design_util_functions_pkg;
