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

library ieee, ibm, latches, stdcell, support;
use ibm.std_ulogic_asic_function_support.all;
use ibm.std_ulogic_support.all;
use ibm.std_ulogic_unsigned.all;
use ibm.std_ulogic_function_support.all;
use ibm.synthesis_support.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ibm.std_ulogic_ao_support.all;
use support.logic_support_pkg.all;
use support.power_logic_pkg.all;
use support.design_util_functions_pkg.all;
use support.signal_resolution_pkg.all;
use ibm.texsim_attributes.all;
library work;
use work.cb_func.cb_term;
use work.cb_tlxt_pkg.INCP;              

entity cb_tlxt_crd_mgmt_rlm is
  port (
    gckn                           : in std_ulogic;
    syncr                          : in std_ulogic;

    cfg_half_dimm_mode            : in STD_ULOGIC;
    -------------------------------------------------------------------------------------
    -- TLX Credit management
    -- From return TLX Credit TL command
    tlxr_tlxt_return_val           : in std_ulogic;
    tlxr_tlxt_return_vc0           : in std_ulogic_vector(3 downto 0);
    tlxr_tlxt_return_vc3           : in std_ulogic_vector(3 downto 0);
    tlxr_tlxt_return_dcp0          : in std_ulogic_vector(5 downto 0);
    tlxr_tlxt_return_dcp3          : in std_ulogic_vector(5 downto 0);
    -- tlxt uses credits
    tlxt_tlxc_consume_val          : in std_ulogic;
    tlxt_tlxc_consume_vc0          : in std_ulogic_vector(3 downto 0);
    tlxt_tlxc_consume_vc3          : in std_ulogic_vector(3 downto 0);
    tlxt_tlxc_consume_dcp0         : in std_ulogic_vector(3 downto 0);
    tlxt_tlxc_consume_dcp3         : in std_ulogic_vector(3 downto 0);
    -- tlxt credit available       :
    tlxc_tlxt_avail_vc0            : out std_ulogic_vector(3 downto 0);
    tlxc_tlxt_avail_vc3            : out std_ulogic_vector(3 downto 0);
    tlxc_tlxt_avail_dcp0           : out std_ulogic_vector(3 downto 0);
    tlxc_tlxt_avail_dcp3           : out std_ulogic_vector(3 downto 0);

    --------------------------------------------------------------------------------------
    -- TL credit management
    --------------------------------------------------------------------------------------
    tlxr_tlxt_consume_vc0          : in std_ulogic;                     -- error checking
    tlxr_tlxt_consume_vc1          : in std_ulogic;                     -- error checking
    tlxr_tlxt_consume_dcp1         : in std_ulogic_vector(2 downto 0);  -- error checking

    -- Free one TL credit
    srq_tlxt_cmdq_release          : in std_ulogic;                     --vc1 release pulse
    tlxr_tlxt_vc1_release          : in std_ulogic;                     --vc1 release pulse set pad mem
    tlxr_tlxt_vc0_release          : in std_ulogic_vector(1 downto 0);  --vc0 release pulse memctrl and int_resp
    tlxr_tlxt_dcp1_release         : in std_ulogic_vector(2 downto 0);  --dcp1 release pulse 
    --
    tlxc_tlxt_crd_ret_val          : out std_ulogic;
    tlxc_tlxt_vc0_credits          : out std_ulogic_vector(3 downto 0);
    tlxc_tlxt_vc1_credits          : out std_ulogic_vector(3 downto 0);
    tlxc_tlxt_dcp1_credits         : out std_ulogic_vector(5 downto 0);
    tlxc_tlxt_vc0_credits_p        : out std_ulogic;
    tlxc_tlxt_vc1_credits_p        : out std_ulogic;
    tlxc_tlxt_dcp1_credits_p       : out std_ulogic;
    tlxt_tlxc_crd_ret_taken        : in std_ulogic;

    
    tlxc_dbg_a_debug_bus           : out std_ulogic_vector(0 to 43);
    tlxc_dbg_b_debug_bus           : out std_ulogic_vector(0 to 87);

    dbg_tlxt_wat_event             : in std_ulogic_vector(0 to 3);

    tlxc_wat_en_reg                : in std_ulogic_vector(0 to 23);
    tlxc_crd_cfg_reg               : in std_ulogic_vector(0 to 63);
    tlxc_crd_status_reg            : out std_ulogic_vector(0 to 127);
    tlxc_errors                    : out std_ulogic_vector(0 to 15);
    tlxc_perrors                   : out std_ulogic_vector(0 to 7);

    gnd                            : inout power_logic;
    vdd                            : inout power_logic
    );

  attribute BLOCK_TYPE of cb_tlxt_crd_mgmt_rlm : entity is LEAF;
  attribute BTR_NAME of cb_tlxt_crd_mgmt_rlm : entity is "CB_TLXT_CRD_MGMT_RLM";
  attribute PIN_DEFAULT_GROUND_DOMAIN of cb_tlxt_crd_mgmt_rlm : entity is "GND";
  attribute PIN_DEFAULT_POWER_DOMAIN of cb_tlxt_crd_mgmt_rlm : entity is "VDD";
  attribute RECURSIVE_SYNTHESIS of cb_tlxt_crd_mgmt_rlm : entity is 2;
  attribute GROUND_PIN of gnd : signal is 1;
  attribute POWER_PIN of vdd : signal is 1;
  attribute PIN_DATA of gckn : signal is "PIN_FUNCTION=/G_CLK/";
end cb_tlxt_crd_mgmt_rlm;

architecture cb_tlxt_crd_mgmt_rlm of cb_tlxt_crd_mgmt_rlm is
  SIGNAL act : std_ulogic;
  SIGNAL tlxr_tlxt_return_val_d : std_ulogic;
  SIGNAL tlxr_tlxt_return_vc0_d : std_ulogic_vector(3 downto 0);
  SIGNAL tlxr_tlxt_return_vc3_d : std_ulogic_vector(3 downto 0);
  SIGNAL tlxr_tlxt_return_dcp0_d : std_ulogic_vector(5 downto 0);
  SIGNAL tlxr_tlxt_return_dcp3_d : std_ulogic_vector(5 downto 0);
  SIGNAL tlxr_tlxt_consume_vc0_d : std_ulogic;
  SIGNAL tlxr_tlxt_consume_vc1_d : std_ulogic;
  SIGNAL tlxr_tlxt_consume_dcp1_d : std_ulogic_vector(2 downto 0);
  SIGNAL srq_tlxt_cmdq_release_d : std_ulogic;
  SIGNAL tlxr_tlxt_vc1_release_d : std_ulogic;
  SIGNAL tlxr_tlxt_vc0_release_d : std_ulogic_vector(1 downto 0);
  SIGNAL tlxr_tlxt_dcp1_release_d : std_ulogic_vector(2 downto 0);
  SIGNAL tlxr_tlxt_return_vc0_gt : std_ulogic_vector(3 downto 0);
  SIGNAL tlxr_tlxt_return_vc0_q : std_ulogic_vector(3 downto 0);
  SIGNAL tlxr_tlxt_return_val_q : std_ulogic;
  SIGNAL tlxr_tlxt_return_vc3_gt : std_ulogic_vector(3 downto 0);
  SIGNAL tlxr_tlxt_return_vc3_q : std_ulogic_vector(3 downto 0);
  SIGNAL tlxr_tlxt_return_dcp0_gt : std_ulogic_vector(5 downto 0);
  SIGNAL tlxr_tlxt_return_dcp0_q : std_ulogic_vector(5 downto 0);
  SIGNAL tlxr_tlxt_return_dcp3_gt : std_ulogic_vector(5 downto 0);
  SIGNAL tlxr_tlxt_return_dcp3_q : std_ulogic_vector(5 downto 0);
  SIGNAL act_cgt1 : std_ulogic;
  SIGNAL tlxc_tlxt_avail_credit_count_vc0_a : std_ulogic_vector(15 downto 0);
  SIGNAL tlxc_tlxt_avail_credit_count_vc0_q : std_ulogic_vector(15 downto 0);
  SIGNAL tlxc_tlxt_avail_credit_count_vc0_b : std_ulogic_vector(15 downto 0);
  SIGNAL tlxc_tlxt_avail_credit_count_vc0_a_p : std_ulogic;
  SIGNAL tlxc_tlxt_avail_credit_count_vc0_b_p : std_ulogic;
  SIGNAL tlxc_tlxt_avail_credit_count_vc0_cgt1_d : std_ulogic_vector(15 downto 0);
  SIGNAL tlxc_tlxt_avail_credit_count_vc0_p_cgt1_d : std_ulogic;
  SIGNAL tlxc_tlxt_avail_vc0_d : std_ulogic;
  SIGNAL tlxc_tlxt_avail_vc0_q : std_ulogic;
  SIGNAL tlxc_tlxt_avail_credit_count_vc3_a : std_ulogic_vector(15 downto 0);
  SIGNAL tlxc_tlxt_avail_credit_count_vc3_q : std_ulogic_vector(15 downto 0);
  SIGNAL tlxc_tlxt_avail_credit_count_vc3_b : std_ulogic_vector(15 downto 0);
  SIGNAL tlxc_tlxt_avail_credit_count_vc3_a_p : std_ulogic;
  SIGNAL tlxc_tlxt_avail_credit_count_vc3_b_p : std_ulogic;
  SIGNAL tlxc_tlxt_avail_credit_count_vc3_cgt1_d : std_ulogic_vector(15 downto 0);
  SIGNAL tlxc_tlxt_avail_credit_count_vc3_p_cgt1_d : std_ulogic;
  SIGNAL tlxc_tlxt_avail_vc3_d : std_ulogic;
  SIGNAL tlxc_tlxt_avail_vc3_q : std_ulogic;
  SIGNAL tlxc_tlxt_avail_credit_count_dcp0_a : std_ulogic_vector(15 downto 0);
  SIGNAL tlxc_tlxt_avail_credit_count_dcp0_q : std_ulogic_vector(15 downto 0);
  SIGNAL tlxc_tlxt_avail_credit_count_dcp0_b : std_ulogic_vector(15 downto 0);
  SIGNAL tlxc_tlxt_avail_credit_count_dcp0_a_p : std_ulogic;
  SIGNAL tlxc_tlxt_avail_credit_count_dcp0_b_p : std_ulogic;
  SIGNAL tlxc_tlxt_avail_credit_count_dcp0_cgt1_d : std_ulogic_vector(15 downto 0);
  SIGNAL tlxc_tlxt_avail_credit_count_dcp0_p_cgt1_d : std_ulogic;
  SIGNAL tlxc_tlxt_avail_dcp0_d : std_ulogic;
  SIGNAL tlxc_tlxt_avail_dcp0_q : std_ulogic;
  SIGNAL tlxc_tlxt_avail_credit_count_dcp3_a : std_ulogic_vector(15 downto 0);
  SIGNAL tlxc_tlxt_avail_credit_count_dcp3_q : std_ulogic_vector(15 downto 0);
  SIGNAL tlxc_tlxt_avail_credit_count_dcp3_b : std_ulogic_vector(15 downto 0);
  SIGNAL tlxc_tlxt_avail_credit_count_dcp3_a_p : std_ulogic;
  SIGNAL tlxc_tlxt_avail_credit_count_dcp3_b_p : std_ulogic;
  SIGNAL tlxc_tlxt_avail_credit_count_dcp3_cgt1_d : std_ulogic_vector(15 downto 0);
  SIGNAL tlxc_tlxt_avail_credit_count_dcp3_p_cgt1_d : std_ulogic;
  SIGNAL tlxc_tlxt_avail_dcp3_d : std_ulogic;
  SIGNAL tlxc_tlxt_avail_dcp3_q : std_ulogic;
  SIGNAL dcp1_credit_return_pause : std_ulogic;
  SIGNAL dcp1_credit_return_pause_wat : std_ulogic;
  SIGNAL dcp1_credit_update_val : std_ulogic;
  SIGNAL dcp1_credit_update_val_wat : std_ulogic;
  SIGNAL vc0_credit_return_pause : std_ulogic;
  SIGNAL vc0_credit_return_pause_wat : std_ulogic;
  SIGNAL vc0_credit_update_val : std_ulogic;
  SIGNAL vc0_credit_update_val_wat : std_ulogic;
  SIGNAL vc1_credit_return_pause : std_ulogic;
  SIGNAL vc1_credit_return_pause_wat : std_ulogic;
  SIGNAL vc1_credit_update_val : std_ulogic;
  SIGNAL vc1_credit_update_val_wat : std_ulogic;
  SIGNAL dbg_tlxt_wat_event_d : std_ulogic_vector(0 to 3);
  SIGNAL dbg_tlxt_wat_event_q : std_ulogic_vector(0 to 3);
  SIGNAL dcp1_credits_init : std_ulogic_vector(15 downto 0);
  SIGNAL vc0_credits_init : std_ulogic_vector(15 downto 0);
  SIGNAL vc1_credits_init : std_ulogic_vector(15 downto 0);
  SIGNAL tlxc_tlxt_vc0_credits_d : std_ulogic_vector(15 downto 0);
  SIGNAL tlxc_tlxt_vc0_credits_q : std_ulogic_vector(15 downto 0);
  SIGNAL tlxr_tlxt_vc0_release_q : std_ulogic_vector(1 downto 0);
  SIGNAL tlxc_tlxt_vc0_credits_release_q : std_ulogic_vector(3 downto 0);
  SIGNAL tlxc_tlxt_vc1_credits_d : std_ulogic_vector(15 downto 0);
  SIGNAL tlxc_tlxt_vc1_credits_q : std_ulogic_vector(15 downto 0);
  SIGNAL srq_tlxt_cmdq_release_q : std_ulogic;
  SIGNAL tlxr_tlxt_vc1_release_q : std_ulogic;
  SIGNAL tlxc_tlxt_vc1_credits_release_q : std_ulogic_vector(3 downto 0);
  SIGNAL syncr_falling_d : std_ulogic;
  SIGNAL tlxc_tlxt_dcp1_credits_d : std_ulogic_vector(15 downto 0);
  signal tlxc_tlxt_dcp1_credits_reset_value : std_ulogic_vector(15 downto 0);
  signal tlxc_tlxt_dcp1_credits_running_value : std_ulogic_vector(15 downto 0);
  SIGNAL dcp1_sel : std_ulogic_vector(0 TO 1);
  SIGNAL syncr_falling_q : std_ulogic;
  SIGNAL tlxc_tlxt_dcp1_credits_q : std_ulogic_vector(15 downto 0);
  SIGNAL tlxr_tlxt_dcp1_release_q : std_ulogic_vector(2 downto 0);
  SIGNAL tlxc_tlxt_dcp1_credits_release_q : std_ulogic_vector(5 downto 0);
  SIGNAL tlxc_tlxt_vc0_credits_p_d : std_ulogic;
  SIGNAL tlxc_tlxt_vc1_credits_p_d : std_ulogic;
  SIGNAL tlxc_tlxt_dcp1_credits_p_d : std_ulogic;
  SIGNAL tlxc_tlxt_vc0_credits_release_d : std_ulogic_vector(3 downto 0);
  SIGNAL tlxc_tlxt_vc1_credits_release_d : std_ulogic_vector(3 downto 0);
  SIGNAL tlxc_tlxt_dcp1_credits_release_d : std_ulogic_vector(5 downto 0);
  SIGNAL tlxc_tlxt_vc0_credits_release_p_d : std_ulogic;
  SIGNAL tlxc_tlxt_vc1_credits_release_p_d : std_ulogic;
  SIGNAL tlxc_tlxt_dcp1_credits_release_p_d : std_ulogic;
  SIGNAL tlxc_tlxt_vc0_credits_release_p_q : std_ulogic;
  SIGNAL tlxc_tlxt_vc1_credits_release_p_q : std_ulogic;
  SIGNAL tlxc_tlxt_dcp1_credits_release_p_q : std_ulogic;
  SIGNAL tlxc_tlxt_crd_ret_val_d : std_ulogic;
  SIGNAL tlxc_tlxt_crd_ret_val_q : std_ulogic;
  SIGNAL tlxt_tlxc_crd_ret_taken_q : std_ulogic;
  SIGNAL tlxt_tlxc_crd_ret_taken_d : std_ulogic;
  SIGNAL tlxr_tlxt_consume_vc0_cnt_d : std_ulogic_vector(15 downto 0);
  SIGNAL tlxr_tlxt_consume_vc0_cnt_q : std_ulogic_vector(15 downto 0);
  SIGNAL tlxr_tlxt_consume_vc0_q : std_ulogic;
  SIGNAL tlxr_tlxt_consume_vc1_cnt_d : std_ulogic_vector(15 downto 0);
  SIGNAL tlxr_tlxt_consume_vc1_cnt_q : std_ulogic_vector(15 downto 0);
  SIGNAL tlxr_tlxt_consume_vc1_q : std_ulogic;
  SIGNAL tlxr_tlxt_consume_dcp1_cnt_d : std_ulogic_vector(15 downto 0);
  SIGNAL tlxr_tlxt_consume_dcp1_cnt_q : std_ulogic_vector(15 downto 0);
  SIGNAL tlxr_tlxt_consume_dcp1_q : std_ulogic_vector(2 downto 0);
  SIGNAL tlx_vc0_max_crd_error_q : std_ulogic;
  SIGNAL tlx_vc3_max_crd_error_q : std_ulogic;
  SIGNAL tlx_dcp0_max_crd_error_q : std_ulogic;
  SIGNAL tlx_dcp3_max_crd_error_q : std_ulogic;
  SIGNAL vc0_cnt_underflow_error_q : std_ulogic;
  SIGNAL vc1_cnt_underflow_error_q : std_ulogic;
  SIGNAL dcp1_cnt_underflow_error_q : std_ulogic;
  SIGNAL vc0_max_crd_error_q : std_ulogic;
  SIGNAL vc1_max_crd_error_q : std_ulogic;
  SIGNAL dcp1_max_crd_error_q : std_ulogic;
  SIGNAL tlxc_tlxt_avail_credit_count_vc0_perror_q : std_ulogic;
  SIGNAL tlxc_tlxt_avail_credit_count_vc3_perror_q : std_ulogic;
  SIGNAL tlxc_tlxt_avail_credit_count_dcp0_perror_q : std_ulogic;
  SIGNAL tlxc_tlxt_avail_credit_count_dcp3_perror_q : std_ulogic;
  SIGNAL tlxc_tlxt_vc0_credits_perror_q : std_ulogic;
  SIGNAL tlxc_tlxt_vc1_credits_perror_q : std_ulogic;
  SIGNAL tlxc_tlxt_dcp1_credits_perror_q : std_ulogic;
  SIGNAL tlx_vc0_max_crd_overflow_bit : std_ulogic_vector(4 downto 0);
  SIGNAL tlx_vc3_max_crd_overflow_bit : std_ulogic_vector(4 downto 0);
  SIGNAL tlx_dcp0_max_crd_overflow_bit : std_ulogic_vector(6 downto 0);
  SIGNAL tlx_dcp3_max_crd_overflow_bit : std_ulogic_vector(6 downto 0);
  SIGNAL tlx_vc0_max_crd_error_d : std_ulogic;
  SIGNAL tlx_vc3_max_crd_error_d : std_ulogic;
  SIGNAL tlx_dcp0_max_crd_error_d : std_ulogic;
  SIGNAL tlx_dcp3_max_crd_error_d : std_ulogic;
  SIGNAL vc0_max_crd_error_d : std_ulogic;
  SIGNAL vc1_max_crd_error_d : std_ulogic;
  SIGNAL dcp1_max_crd_error_d : std_ulogic;
  SIGNAL vc0_cnt_underflow_error_d : std_ulogic;
  SIGNAL vc1_cnt_underflow_error_d : std_ulogic;
  SIGNAL dcp1_cnt_underflow_error_d : std_ulogic;
  SIGNAL tlxc_tlxt_avail_credit_count_vc0_perror_d : std_ulogic;
  SIGNAL tlxc_tlxt_avail_credit_count_vc0_p_q : std_ulogic;
  SIGNAL tlxc_tlxt_avail_credit_count_vc3_perror_d : std_ulogic;
  SIGNAL tlxc_tlxt_avail_credit_count_vc3_p_q : std_ulogic;
  SIGNAL tlxc_tlxt_avail_credit_count_dcp0_perror_d : std_ulogic;
  SIGNAL tlxc_tlxt_avail_credit_count_dcp0_p_q : std_ulogic;
  SIGNAL tlxc_tlxt_avail_credit_count_dcp3_perror_d : std_ulogic;
  SIGNAL tlxc_tlxt_avail_credit_count_dcp3_p_q : std_ulogic;
  SIGNAL tlxc_tlxt_vc0_credits_perror_d : std_ulogic;
  SIGNAL tlxc_tlxt_vc0_credits_p_q : std_ulogic;
  SIGNAL tlxc_tlxt_vc1_credits_perror_d : std_ulogic;
  SIGNAL tlxc_tlxt_vc1_credits_p_q : std_ulogic;
  SIGNAL tlxc_tlxt_dcp1_credits_perror_d : std_ulogic;
  SIGNAL tlxc_tlxt_dcp1_credits_p_q : std_ulogic;
  SIGNAL tlxc_tlxt_vc0_credits_ret_taken_par : std_ulogic;
  SIGNAL tlxc_tlxt_vc0_credits_ret_not_taken_par : std_ulogic;
  SIGNAL tlxc_tlxt_vc1_credits_ret_taken_par : std_ulogic;
  SIGNAL tlxc_tlxt_vc1_credits_ret_not_taken_par : std_ulogic;
  SIGNAL tlxc_tlxt_dcp1_credits_ret_taken_par : std_ulogic;
  SIGNAL tlxc_tlxt_dcp1_credits_ret_not_taken_par : std_ulogic;
  signal cfg_half_dimm_mode_d                            : std_ulogic;
  signal cfg_half_dimm_mode_q                            : std_ulogic;
  signal cfg_half_dimm_mode_rising_or_falling            : std_ulogic;

  
  begin

    act                                 <= '1';

--timing latch
    tlxr_tlxt_return_val_d              <= tlxr_tlxt_return_val;   --           : in std_ulogic;
    tlxr_tlxt_return_vc0_d(3 DOWNTO 0)  <= tlxr_tlxt_return_vc0;   --          : in std_ulogic_vector(3 downto 0);
    tlxr_tlxt_return_vc3_d(3 DOWNTO 0)  <= tlxr_tlxt_return_vc3;   --          : in std_ulogic_vector(3 downto 0);
    tlxr_tlxt_return_dcp0_d(5 DOWNTO 0) <= tlxr_tlxt_return_dcp0;  --          : in std_ulogic_vector(5 downto 0);
    tlxr_tlxt_return_dcp3_d(5 DOWNTO 0) <= tlxr_tlxt_return_dcp3;  --          : in std_ulogic_vector(5 downto 0);

    -----------------------------    --------------------------------------------------------------------------------------
    -- TL credit management          -- TL credit management
    -----------------------------    --------------------------------------------------------------------------------------
    tlxr_tlxt_consume_vc0_d              <= tlxr_tlxt_consume_vc0;  --          : in std_ulogic;                     -- error checking
    tlxr_tlxt_consume_vc1_d              <= tlxr_tlxt_consume_vc1;  --          : in std_ulogic;                     -- error checking
    tlxr_tlxt_consume_dcp1_d(2 DOWNTO 0) <= tlxr_tlxt_consume_dcp1;  --         : in std_ulogic_vector(2 downto 0);  -- error checking

    -- Free one TL credit            -- Free one TL credit
    srq_tlxt_cmdq_release_d              <= srq_tlxt_cmdq_release;  --          : in std_ulogic;                     --vc1 release pulse
    tlxr_tlxt_vc1_release_d              <= tlxr_tlxt_vc1_release;  --          : in std_ulogic;                     --vc1 release pulse set pad mem
    tlxr_tlxt_vc0_release_d(1 DOWNTO 0)  <= tlxr_tlxt_vc0_release;  --          : in std_ulogic_vector(1 downto 0);  --vc0 release pulse memctrl and int_resp
    tlxr_tlxt_dcp1_release_d(2 DOWNTO 0) <= tlxr_tlxt_dcp1_release;  --        : in std_ulogic_vector(2 downto 0);  --dcp1 release pulse 
    --

-----------------------------------------------------------------------------------------------------------------------------------------------------------
--TLXT transmit credits
-- This is the credit where upstream advertises and TLXT uses to send upstream packets
-----------------------------------------------------------------------------------------------------------------------------------------------------------
    tlxr_tlxt_return_vc0_gt(3 downto 0)       <= gate(tlxr_tlxt_return_vc0_q(3 DOWNTO 0) , tlxr_tlxt_return_val_q);
    tlxr_tlxt_return_vc3_gt(3 downto 0)       <= gate(tlxr_tlxt_return_vc3_q(3 DOWNTO 0) , tlxr_tlxt_return_val_q);
    tlxr_tlxt_return_dcp0_gt(5 downto 0)      <= gate(tlxr_tlxt_return_dcp0_q(5 DOWNTO 0), tlxr_tlxt_return_val_q);
    tlxr_tlxt_return_dcp3_gt(5 downto 0)      <= gate(tlxr_tlxt_return_dcp3_q(5 DOWNTO 0), tlxr_tlxt_return_val_q);

    cb_term(tlxt_tlxc_consume_vc0(3 downto 1));
    cb_term(tlxt_tlxc_consume_vc3(3 downto 1));
    cb_term(tlxt_tlxc_consume_dcp0(3 downto 1));
    cb_term(tlxt_tlxc_consume_dcp3(3 downto 1));
    act_cgt1 <= tlxr_tlxt_return_val_q OR tlxt_tlxc_consume_val;

    --VC0
    -------------------------------------------------------------------------------------------------------------------------------------------------------
    tlxc_tlxt_avail_credit_count_vc0_a(15 downto 0)  <= tlxc_tlxt_avail_credit_count_vc0_q(15 downto 0)  + tlxr_tlxt_return_vc0_gt;
    tlxc_tlxt_avail_credit_count_vc0_b(15 downto 0)  <= tlxc_tlxt_avail_credit_count_vc0_q(15 downto 0)  + tlxr_tlxt_return_vc0_gt  - x"0001";
    tlxc_tlxt_avail_credit_count_vc0_a_p             <= xor_reduce(tlxc_tlxt_avail_credit_count_vc0_a);
    tlxc_tlxt_avail_credit_count_vc0_b_p             <= tlxc_tlxt_avail_credit_count_vc0_a_p XOR INCP(NOT tlxc_tlxt_avail_credit_count_vc0_a);  


    tlxc_tlxt_avail_credit_count_vc0_cgt1_d(15 downto 0)  <= gate(tlxc_tlxt_avail_credit_count_vc0_a,   NOT tlxt_tlxc_consume_vc0(0)) OR
                                                             gate(tlxc_tlxt_avail_credit_count_vc0_b,       tlxt_tlxc_consume_vc0(0));--MR_DOM _cgt1  func_gate
    tlxc_tlxt_avail_credit_count_vc0_p_cgt1_d             <= (tlxc_tlxt_avail_credit_count_vc0_a_p and NOT tlxt_tlxc_consume_vc0(0)) OR
                                                             (tlxc_tlxt_avail_credit_count_vc0_b_p and    tlxt_tlxc_consume_vc0(0));--MR_DOM _cgt1  func_gate

    tlxc_tlxt_avail_vc0_d             <=   (or_reduce(tlxc_tlxt_avail_credit_count_vc0_q(15 downto 0)) AND NOT tlxt_tlxc_consume_vc0(0)) OR
                                           (tlxc_tlxt_avail_credit_count_vc0_q( 15 downto 0) > x"0001");
    tlxc_tlxt_avail_vc0(3 downto 0)   <= "000"&tlxc_tlxt_avail_vc0_q;

    --VC3
    -------------------------------------------------------------------------------------------------------------------------------------------------------
    tlxc_tlxt_avail_credit_count_vc3_a(15 downto 0)  <= tlxc_tlxt_avail_credit_count_vc3_q(15 downto 0)  + tlxr_tlxt_return_vc3_gt;
    tlxc_tlxt_avail_credit_count_vc3_b(15 downto 0)  <= tlxc_tlxt_avail_credit_count_vc3_q(15 downto 0)  + tlxr_tlxt_return_vc3_gt  - x"0001";
    tlxc_tlxt_avail_credit_count_vc3_a_p             <= xor_reduce(tlxc_tlxt_avail_credit_count_vc3_a);
    tlxc_tlxt_avail_credit_count_vc3_b_p             <= tlxc_tlxt_avail_credit_count_vc3_a_p XOR INCP(NOT tlxc_tlxt_avail_credit_count_vc3_a);  


    tlxc_tlxt_avail_credit_count_vc3_cgt1_d(15 downto 0)  <= gate(tlxc_tlxt_avail_credit_count_vc3_a,   NOT tlxt_tlxc_consume_vc3(0)) OR
                                                             gate(tlxc_tlxt_avail_credit_count_vc3_b,       tlxt_tlxc_consume_vc3(0));--MR_DOM _cgt1  func_gate
    tlxc_tlxt_avail_credit_count_vc3_p_cgt1_d             <= (tlxc_tlxt_avail_credit_count_vc3_a_p and NOT tlxt_tlxc_consume_vc3(0)) OR
                                                             (tlxc_tlxt_avail_credit_count_vc3_b_p and     tlxt_tlxc_consume_vc3(0));--MR_DOM _cgt1  func_gate

    
    tlxc_tlxt_avail_vc3_d             <=   (or_reduce(tlxc_tlxt_avail_credit_count_vc3_q(15 downto 0)) AND NOT tlxt_tlxc_consume_vc3(0)) OR
                                           (tlxc_tlxt_avail_credit_count_vc3_q( 15 downto 0) > x"0001");
    tlxc_tlxt_avail_vc3(3 downto 0)   <= "000"&tlxc_tlxt_avail_vc3_q;

    --dcp0
    -------------------------------------------------------------------------------------------------------------------------------------------------------
    tlxc_tlxt_avail_credit_count_dcp0_a(15 downto 0)  <= tlxc_tlxt_avail_credit_count_dcp0_q(15 downto 0)  + tlxr_tlxt_return_dcp0_gt;
    tlxc_tlxt_avail_credit_count_dcp0_b(15 downto 0)  <= tlxc_tlxt_avail_credit_count_dcp0_q(15 downto 0)  + tlxr_tlxt_return_dcp0_gt  - x"0001";
    tlxc_tlxt_avail_credit_count_dcp0_a_p             <= xor_reduce(tlxc_tlxt_avail_credit_count_dcp0_a);
    tlxc_tlxt_avail_credit_count_dcp0_b_p             <= tlxc_tlxt_avail_credit_count_dcp0_a_p XOR INCP(NOT tlxc_tlxt_avail_credit_count_dcp0_a);  


    tlxc_tlxt_avail_credit_count_dcp0_cgt1_d(15 downto 0)  <= gate(tlxc_tlxt_avail_credit_count_dcp0_a,   NOT tlxt_tlxc_consume_dcp0(0)) OR
                                                             gate(tlxc_tlxt_avail_credit_count_dcp0_b,       tlxt_tlxc_consume_dcp0(0));--MR_DOM _cgt1  func_gate
    tlxc_tlxt_avail_credit_count_dcp0_p_cgt1_d             <= (tlxc_tlxt_avail_credit_count_dcp0_a_p AND NOT  tlxt_tlxc_consume_dcp0(0)) OR
                                                             (tlxc_tlxt_avail_credit_count_dcp0_b_p AND      tlxt_tlxc_consume_dcp0(0));--MR_DOM _cgt1  func_gate

    tlxc_tlxt_avail_dcp0_d             <=   (or_reduce(tlxc_tlxt_avail_credit_count_dcp0_q(15 downto 0)) AND NOT tlxt_tlxc_consume_dcp0(0)) OR
                                           (tlxc_tlxt_avail_credit_count_dcp0_q( 15 downto 0) > x"0001");
    tlxc_tlxt_avail_dcp0(3 downto 0)   <= "000"&tlxc_tlxt_avail_dcp0_q;

    --dcp3
    -------------------------------------------------------------------------------------------------------------------------------------------------------
    tlxc_tlxt_avail_credit_count_dcp3_a(15 downto 0)  <= tlxc_tlxt_avail_credit_count_dcp3_q(15 downto 0)  + tlxr_tlxt_return_dcp3_gt;
    tlxc_tlxt_avail_credit_count_dcp3_b(15 downto 0)  <= tlxc_tlxt_avail_credit_count_dcp3_q(15 downto 0)  + tlxr_tlxt_return_dcp3_gt  - x"0001";
    tlxc_tlxt_avail_credit_count_dcp3_a_p             <= xor_reduce(tlxc_tlxt_avail_credit_count_dcp3_a);
    tlxc_tlxt_avail_credit_count_dcp3_b_p             <= tlxc_tlxt_avail_credit_count_dcp3_a_p XOR INCP(NOT tlxc_tlxt_avail_credit_count_dcp3_a);  


    tlxc_tlxt_avail_credit_count_dcp3_cgt1_d(15 downto 0)  <= gate(tlxc_tlxt_avail_credit_count_dcp3_a,   NOT tlxt_tlxc_consume_dcp3(0)) OR
                                                              gate(tlxc_tlxt_avail_credit_count_dcp3_b,       tlxt_tlxc_consume_dcp3(0));--MR_DOM _cgt1  func_gate
    tlxc_tlxt_avail_credit_count_dcp3_p_cgt1_d             <= (tlxc_tlxt_avail_credit_count_dcp3_a_p and NOT tlxt_tlxc_consume_dcp3(0)) OR
                                                              (tlxc_tlxt_avail_credit_count_dcp3_b_p and     tlxt_tlxc_consume_dcp3(0));--MR_DOM _cgt1  func_gate

    tlxc_tlxt_avail_dcp3_d             <=   (or_reduce(tlxc_tlxt_avail_credit_count_dcp3_q(15 downto 0)) AND NOT tlxt_tlxc_consume_dcp3(0)) OR
                                           (tlxc_tlxt_avail_credit_count_dcp3_q( 15 downto 0) > x"0001");
    tlxc_tlxt_avail_dcp3(3 downto 0)   <= "000"&tlxc_tlxt_avail_dcp3_q;

    
                                                                       
-----------------------------------------------------------------------------------------------------------------------------------------------------------    
--TL transmit credits
-- This is credit where MB advertises and upstream uses to send downstream packets 
-----------------------------------------------------------------------------------------------------------------------------------------------------------    


    --VC0 credits

    cb_term(tlxc_crd_cfg_reg(0 TO 9));

    dcp1_credit_return_pause <= tlxc_crd_cfg_reg(10) OR dcp1_credit_return_pause_wat;
    dcp1_credit_update_val   <= tlxc_crd_cfg_reg(11) OR dcp1_credit_update_val_wat;

    vc0_credit_return_pause  <= tlxc_crd_cfg_reg(12) OR vc0_credit_return_pause_wat;
    vc0_credit_update_val    <= tlxc_crd_cfg_reg(13) OR vc0_credit_update_val_wat;

    vc1_credit_return_pause  <= tlxc_crd_cfg_reg(14) OR vc1_credit_return_pause_wat;
    vc1_credit_update_val    <= tlxc_crd_cfg_reg(15) OR vc1_credit_update_val_wat;

    dbg_tlxt_wat_event_d(0 to 3)   <=  dbg_tlxt_wat_event(0 TO 3);

    dcp1_credit_return_pause_wat <=
                                    (tlxc_wat_en_reg(0) AND dbg_tlxt_wat_event_q(0)) or
                                    (tlxc_wat_en_reg(1) AND dbg_tlxt_wat_event_q(1)) or
                                    (tlxc_wat_en_reg(2) AND dbg_tlxt_wat_event_q(2)) or
                                    (tlxc_wat_en_reg(3) AND dbg_tlxt_wat_event_q(3)) ;

    vc0_credit_return_pause_wat  <= 
                                    (tlxc_wat_en_reg(4) AND dbg_tlxt_wat_event_q(0)) or
                                    (tlxc_wat_en_reg(5) AND dbg_tlxt_wat_event_q(1)) or
                                    (tlxc_wat_en_reg(6) AND dbg_tlxt_wat_event_q(2)) or
                                    (tlxc_wat_en_reg(7) AND dbg_tlxt_wat_event_q(3)) ;

    vc1_credit_return_pause_wat  <= 
                                    (tlxc_wat_en_reg(8) AND dbg_tlxt_wat_event_q(0)) or
                                    (tlxc_wat_en_reg(9) AND dbg_tlxt_wat_event_q(1)) or
                                    (tlxc_wat_en_reg(10) AND dbg_tlxt_wat_event_q(2)) or
                                    (tlxc_wat_en_reg(11) AND dbg_tlxt_wat_event_q(3)) ;

    dcp1_credit_update_val_wat   <= 
                                    (tlxc_wat_en_reg(12) AND dbg_tlxt_wat_event_q(0)) or
                                    (tlxc_wat_en_reg(13) AND dbg_tlxt_wat_event_q(1)) or
                                    (tlxc_wat_en_reg(14) AND dbg_tlxt_wat_event_q(2)) or
                                    (tlxc_wat_en_reg(15) AND dbg_tlxt_wat_event_q(3)) ;
    vc0_credit_update_val_wat    <= 
                                    (tlxc_wat_en_reg(16) AND dbg_tlxt_wat_event_q(0)) or
                                    (tlxc_wat_en_reg(17) AND dbg_tlxt_wat_event_q(1)) or
                                    (tlxc_wat_en_reg(18) AND dbg_tlxt_wat_event_q(2)) or
                                    (tlxc_wat_en_reg(19) AND dbg_tlxt_wat_event_q(3)) ;
    vc1_credit_update_val_wat    <= 
                                    (tlxc_wat_en_reg(20) AND dbg_tlxt_wat_event_q(0)) or
                                    (tlxc_wat_en_reg(21) AND dbg_tlxt_wat_event_q(1)) or
                                    (tlxc_wat_en_reg(22) AND dbg_tlxt_wat_event_q(2)) or
                                    (tlxc_wat_en_reg(23) AND dbg_tlxt_wat_event_q(3)) ;


    


    dcp1_credits_init(15 DOWNTO 0)         <= tlxc_crd_cfg_reg(16 TO 31);    
    vc0_credits_init(15 DOWNTO 0)          <= tlxc_crd_cfg_reg(32 TO 47);    
    vc1_credits_init(15 DOWNTO 0)          <= tlxc_crd_cfg_reg(48 TO 63);    


    
    --VC0 credits
    tlxc_tlxt_vc0_credits_d(15 downto 0)        <=  gate(tlxc_tlxt_vc0_credits_q(15 downto 0),               NOT vc0_credit_update_val)                              +
                                                    gate(x"000"&"00"& tlxr_tlxt_vc0_release_q(1 DOWNTO 0),     NOT vc0_credit_update_val )   -
                                                    gate(x"000"&tlxc_tlxt_vc0_credits_release_q(3 downto 0), NOT vc0_credit_update_val AND tlxt_tlxc_crd_ret_taken ) + 
                                                    gate(vc0_credits_init(15 DOWNTO 0),                          vc0_credit_update_val)                              ;   -- MR_ADD init => x"0004"

    tlxc_tlxt_vc0_credits_ret_taken_par        <=   xor_reduce(gate(tlxc_tlxt_vc0_credits_q(15 downto 0),               NOT vc0_credit_update_val)                              +
                                                               gate(x"000"&"00"& tlxr_tlxt_vc0_release_q(1 DOWNTO 0),   NOT vc0_credit_update_val )                             -
                                                               gate(x"000"&tlxc_tlxt_vc0_credits_release_q(3 downto 0), NOT vc0_credit_update_val )                             +
                                                               gate(vc0_credits_init(15 DOWNTO 0),                          vc0_credit_update_val)  );                            

    tlxc_tlxt_vc0_credits_ret_not_taken_par     <=   xor_reduce(gate(tlxc_tlxt_vc0_credits_q(15 downto 0),               NOT vc0_credit_update_val)                              +
                                                               gate(x"000"&"00"& tlxr_tlxt_vc0_release_q(1 DOWNTO 0),   NOT vc0_credit_update_val )                             +
                                                               gate(vc0_credits_init(15 DOWNTO 0),                          vc0_credit_update_val)  );                            

    
    tlxc_tlxt_vc0_credits_p_d                   <= (tlxc_tlxt_vc0_credits_ret_taken_par        AND     tlxt_tlxc_crd_ret_taken) OR
                                                   (tlxc_tlxt_vc0_credits_ret_not_taken_par    AND not tlxt_tlxc_crd_ret_taken); -- MR_ADD init => "1"

    --VC1 credits
    tlxc_tlxt_vc1_credits_d(15 downto 0)        <=  gate(tlxc_tlxt_vc1_credits_q(15 downto 0),               NOT vc1_credit_update_val)                              +
                                                    gate(x"0001",                                            NOT vc1_credit_update_val AND srq_tlxt_cmdq_release_q )   +
                                                    gate(x"0001",                                            NOT vc1_credit_update_val AND tlxr_tlxt_vc1_release_q )   -
                                                    gate(x"000"&tlxc_tlxt_vc1_credits_release_q(3 downto 0), NOT vc1_credit_update_val AND tlxt_tlxc_crd_ret_taken ) +  
                                                    gate(vc1_credits_init(15 DOWNTO 0),                          vc1_credit_update_val)                              ;  -- MR_ADD init => x"001E"
                        --NCF has total of 32 entries. Two entries are reserved for MCB. Therefore, 30 credits are aviable for VC.1 commands. However, only
                        --one Maint cmd from MCB can be outstanding at a time during mainline operation. Therefore, we can never fill NCF during mainline
                        --When running MCBIST command where two entries can be used, 30 credits can be used for MMIO/CFG

    tlxc_tlxt_vc1_credits_ret_taken_par        <=  xor_reduce(gate(tlxc_tlxt_vc1_credits_q(15 downto 0),               NOT vc1_credit_update_val)                              +
                                                              gate(x"0001",                                            NOT vc1_credit_update_val AND srq_tlxt_cmdq_release_q )   +
                                                              gate(x"0001",                                            NOT vc1_credit_update_val AND tlxr_tlxt_vc1_release_q )   -
                                                              gate(x"000"&tlxc_tlxt_vc1_credits_release_q(3 downto 0), NOT vc1_credit_update_val ) +  
                                                              gate(vc1_credits_init(15 DOWNTO 0),                          vc1_credit_update_val));  

    tlxc_tlxt_vc1_credits_ret_not_taken_par    <=  xor_reduce(gate(tlxc_tlxt_vc1_credits_q(15 downto 0),               NOT vc1_credit_update_val)                              +
                                                              gate(x"0001",                                            NOT vc1_credit_update_val AND srq_tlxt_cmdq_release_q )   +
                                                              gate(x"0001",                                            NOT vc1_credit_update_val AND tlxr_tlxt_vc1_release_q )   +
                                                              gate(vc1_credits_init(15 DOWNTO 0),                          vc1_credit_update_val));  

    tlxc_tlxt_vc1_credits_p_d                  <= (tlxc_tlxt_vc1_credits_ret_taken_par     AND     tlxt_tlxc_crd_ret_taken) OR
                                                  (tlxc_tlxt_vc1_credits_ret_not_taken_par AND NOT tlxt_tlxc_crd_ret_taken);  -- MR_ADD init => "0"

  
    syncr_falling_d                              <= '0';  -- MR_ADD init => "1"
    --DCP1 credits

   tlxc_tlxt_dcp1_credits_reset_value(15 DOWNTO 0) <= gate(x"003F",     cfg_half_dimm_mode) OR
                                                      gate(x"0040", NOT cfg_half_dimm_mode);

   tlxc_tlxt_dcp1_credits_running_value(15 DOWNTO 0) <= tlxc_tlxt_dcp1_credits_q + (x"000"&'0'&tlxr_tlxt_dcp1_release_q(2 DOWNTO 0)) - gate(tlxc_tlxt_dcp1_credits_release_q(5 DOWNTO 0), tlxt_tlxc_crd_ret_taken);

   ----take reset value during rising and falling edge of cfg_half_dimm_mode as well
   -- this is assume that link is down and no credit has been exchanged
   -- if cfg_half_dimm_mode switched while link is up, then unexpected error will occur
   cfg_half_dimm_mode_rising_or_falling <= cfg_half_dimm_mode XOR cfg_half_dimm_mode_q;
   dcp1_sel(0 TO 1) <= (syncr_falling_q OR cfg_half_dimm_mode_rising_or_falling) & dcp1_credit_update_val;

   WITH dcp1_sel(0 TO 1) SELECT
     tlxc_tlxt_dcp1_credits_d(15 DOWNTO 0) <= 
                                             tlxc_tlxt_dcp1_credits_reset_value           WHEN "10" | "11",
                                             dcp1_credits_init                            WHEN "01",    
                                             tlxc_tlxt_dcp1_credits_running_value         WHEN others;

   WITH dcp1_sel(0 TO 1) SELECT
     tlxc_tlxt_dcp1_credits_ret_taken_par        <= 
                                             xor_reduce(tlxc_tlxt_dcp1_credits_reset_value)           WHEN "10" | "11",
                                             xor_reduce(dcp1_credits_init)                            WHEN "01",    
                                             xor_reduce(tlxc_tlxt_dcp1_credits_q + (x"000"&'0'&tlxr_tlxt_dcp1_release_q(2 DOWNTO 0)) - tlxc_tlxt_dcp1_credits_release_q) WHEN others;

   WITH dcp1_sel(0 TO 1) SELECT
    tlxc_tlxt_dcp1_credits_ret_not_taken_par     <= 
                                             xor_reduce(tlxc_tlxt_dcp1_credits_reset_value)           WHEN "10" | "11",
                                             xor_reduce(dcp1_credits_init)                            WHEN "01",    
                                             xor_reduce(tlxc_tlxt_dcp1_credits_q + (x"000"&'0'&tlxr_tlxt_dcp1_release_q(2 DOWNTO 0))) WHEN others;


    tlxc_tlxt_dcp1_credits_p_d                   <= (tlxc_tlxt_dcp1_credits_ret_taken_par AND tlxt_tlxc_crd_ret_taken) OR (tlxc_tlxt_dcp1_credits_ret_not_taken_par AND NOT tlxt_tlxc_crd_ret_taken); -- MR_ADD init => "0"

-- crd_ret_taken is timing critical.

    --release credit used latch version of credit count update to avoid timing issue on crd_ret_taken path
    tlxc_tlxt_vc0_credits_release_d(3 downto 0)   <= gate("1111", or_reduce(tlxc_tlxt_vc0_credits_q(15 downto 4)) AND NOT vc0_credit_return_pause) OR
                                                     gate(tlxc_tlxt_vc0_credits_q(3 downto 0), NOT vc0_credit_return_pause);

    tlxc_tlxt_vc1_credits_release_d(3 downto 0)   <= gate("1111", or_reduce(tlxc_tlxt_vc1_credits_q(15 downto 4)) AND NOT vc1_credit_return_pause) or
                                                     gate(tlxc_tlxt_vc1_credits_q(3 downto 0), NOT vc1_credit_return_pause);


    tlxc_tlxt_dcp1_credits_release_d(5 downto 0)  <= gate("111111", or_reduce(tlxc_tlxt_dcp1_credits_q(15 downto 6)) AND NOT dcp1_credit_return_pause) OR
                                                     gate(tlxc_tlxt_dcp1_credits_q(5 downto 0), NOT dcp1_credit_return_pause);

    tlxc_tlxt_vc0_credits_release_p_d   <= xor_reduce(tlxc_tlxt_vc0_credits_q(3 downto 0))  and NOT vc0_credit_return_pause  AND NOT or_reduce(tlxc_tlxt_vc0_credits_q(15 DOWNTO 4));
    tlxc_tlxt_vc1_credits_release_p_d   <= xor_reduce(tlxc_tlxt_vc1_credits_q(3 downto 0))  and NOT vc1_credit_return_pause  AND NOT or_reduce(tlxc_tlxt_vc1_credits_q(15 DOWNTO 4));
    tlxc_tlxt_dcp1_credits_release_p_d  <= xor_reduce(tlxc_tlxt_dcp1_credits_q(5 downto 0)) AND NOT dcp1_credit_return_pause AND NOT or_reduce(tlxc_tlxt_dcp1_credits_q(15 DOWNTO 6));

    
    --during the release credit out a cycle later
    --to ensure the latest credit value is accounted, ret_val has to drop the cycle after ret_take to give a cycle for credits to update after taken
    tlxc_tlxt_vc0_credits                       <= tlxc_tlxt_vc0_credits_release_q(3 DOWNTO 0);
    tlxc_tlxt_vc1_credits                       <= tlxc_tlxt_vc1_credits_release_q(3 DOWNTO 0);
    tlxc_tlxt_dcp1_credits                      <= tlxc_tlxt_dcp1_credits_release_q(5 DOWNTO 0);
    tlxc_tlxt_vc0_credits_p                     <= tlxc_tlxt_vc0_credits_release_p_q;
    tlxc_tlxt_vc1_credits_p                     <= tlxc_tlxt_vc1_credits_release_p_q;
    tlxc_tlxt_dcp1_credits_p                    <= tlxc_tlxt_dcp1_credits_release_p_q;

    tlxc_tlxt_crd_ret_val_d                     <= or_reduce(tlxc_tlxt_vc0_credits_release_d & tlxc_tlxt_vc1_credits_release_d & tlxc_tlxt_dcp1_credits_release_d);
    tlxc_tlxt_crd_ret_val                       <= tlxc_tlxt_crd_ret_val_q AND NOT tlxt_tlxc_crd_ret_taken_q;

    tlxt_tlxc_crd_ret_taken_d                   <= tlxt_tlxc_crd_ret_taken;

-----------------------------------------------------------------------------------------------------------------------------------------------------------
-- credit counter underflow check
-- This is for error checking only
-- consume = upstream uses MB resources
-- release = MB frees up the resources
-- underflow happens if MB frees more than upstream consumed
-----------------------------------------------------------------------------------------------------------------------------------------------------------

    tlxr_tlxt_consume_vc0_cnt_d(15 DOWNTO 0)         <= tlxr_tlxt_consume_vc0_cnt_q(15 DOWNTO 0) + (x"000"&"000"&tlxr_tlxt_consume_vc0_q) - (x"000"&"00"&tlxr_tlxt_vc0_release_q);


    tlxr_tlxt_consume_vc1_cnt_d(15 DOWNTO 0)         <= tlxr_tlxt_consume_vc1_cnt_q(15 DOWNTO 0) + (x"000"&"000"&tlxr_tlxt_consume_vc1_q) - (x"000"&"000"&srq_tlxt_cmdq_release_q) -(x"000"&"000"&tlxr_tlxt_vc1_release_q) ;


    tlxr_tlxt_consume_dcp1_cnt_d(15 DOWNTO 0)        <= tlxr_tlxt_consume_dcp1_cnt_q(15 DOWNTO 0) + (x"000"&'0'&tlxr_tlxt_consume_dcp1_q(2 DOWNTO 0)) - (x"000"&'0'&tlxr_tlxt_dcp1_release_q);


----------------------------------------------------------------------------------------------------------------------------------------------------------
--Errors and Parity Errors
----------------------------------------------------------------------------------------------------------------------------------------------------------

        tlxc_errors(0 TO 15) <=  
                  tlx_vc0_max_crd_error_q
                & tlx_vc3_max_crd_error_q
                & tlx_dcp0_max_crd_error_q
                & tlx_dcp3_max_crd_error_q
                & vc0_cnt_underflow_error_q 
                & vc1_cnt_underflow_error_q 
                & dcp1_cnt_underflow_error_q 
                & vc0_max_crd_error_q       
                & vc1_max_crd_error_q      
                & dcp1_max_crd_error_q   
                & (10 TO 15 => '0') ;

        tlxc_perrors(0 TO 7) <= '0'
                          & tlxc_tlxt_avail_credit_count_vc0_perror_q    
                          & tlxc_tlxt_avail_credit_count_vc3_perror_q    
                          & tlxc_tlxt_avail_credit_count_dcp0_perror_q   
                          & tlxc_tlxt_avail_credit_count_dcp3_perror_q   
                                                                         
                          & tlxc_tlxt_vc0_credits_perror_q               
                          & tlxc_tlxt_vc1_credits_perror_q               
                          & tlxc_tlxt_dcp1_credits_perror_q;              
    --Errors
    --MAX CREDIT exceeded


    cb_term(tlx_vc0_max_crd_overflow_bit(3 DOWNTO 0));
    cb_term(tlx_vc3_max_crd_overflow_bit(3 DOWNTO 0));
    cb_term(tlx_dcp0_max_crd_overflow_bit(5 DOWNTO 0));
    cb_term(tlx_dcp3_max_crd_overflow_bit(5 DOWNTO 0));
    

    tlx_vc0_max_crd_overflow_bit(4 DOWNTO 0)   <= ('0' & tlxc_tlxt_avail_credit_count_vc0_q(3 downto 0))  + ('0' & tlxr_tlxt_return_vc0_gt(3 DOWNTO 0))  ;
    tlx_vc3_max_crd_overflow_bit(4 DOWNTO 0)   <= ('0' & tlxc_tlxt_avail_credit_count_vc3_q(3 downto 0))  + ('0' & tlxr_tlxt_return_vc3_gt(3 DOWNTO 0))  ;  
    tlx_dcp0_max_crd_overflow_bit(6 DOWNTO 0)  <= ('0' & tlxc_tlxt_avail_credit_count_dcp0_q(5 downto 0)) + ('0' & tlxr_tlxt_return_dcp0_gt(5 DOWNTO 0)) ; 
    tlx_dcp3_max_crd_overflow_bit(6 DOWNTO 0)  <= ('0' & tlxc_tlxt_avail_credit_count_dcp3_q(5 downto 0)) + ('0' & tlxr_tlxt_return_dcp3_gt( 5 DOWNTO 0)) ; 


    tlx_vc0_max_crd_error_d   <= and_reduce(tlxc_tlxt_avail_credit_count_vc0_q(15 downto 4))  AND tlx_vc0_max_crd_overflow_bit(4); 
    tlx_vc3_max_crd_error_d   <= and_reduce(tlxc_tlxt_avail_credit_count_vc3_q(15 downto 4))  AND tlx_vc3_max_crd_overflow_bit(4);
    tlx_dcp0_max_crd_error_d  <= and_reduce(tlxc_tlxt_avail_credit_count_dcp0_q(15 downto 6)) AND tlx_dcp0_max_crd_overflow_bit(6);
    tlx_dcp3_max_crd_error_d  <= and_reduce(tlxc_tlxt_avail_credit_count_dcp3_q(15 downto 6)) AND tlx_dcp3_max_crd_overflow_bit(6);

    vc0_max_crd_error_d                              <= (tlxc_tlxt_vc0_credits_q > x"0004");
    vc1_max_crd_error_d                              <= (tlxc_tlxt_vc1_credits_q > x"001F");
    --no max crd check during rising or falling of cfg_half_dimm_mode since credit is reseting this cycle
    dcp1_max_crd_error_d                             <= ((tlxc_tlxt_dcp1_credits_q > x"0040") AND NOT cfg_half_dimm_mode AND NOT cfg_half_dimm_mode_q) or
                                                        ((tlxc_tlxt_dcp1_credits_q > x"003F") AND     cfg_half_dimm_mode AND     cfg_half_dimm_mode_q);

    --same cycle consumed and release is allowed for vc0 and vc1
    vc0_cnt_underflow_error_d                        <=  NOT or_reduce(tlxr_tlxt_consume_vc0_cnt_q(15 DOWNTO 2)) AND
                                                            ((('0'&tlxr_tlxt_consume_vc0_cnt_q(1 DOWNTO 0)) + ("00"&tlxr_tlxt_consume_vc0_q)) < ('0'&tlxr_tlxt_vc0_release_q(1 DOWNTO 0))) AND NOT vc0_credit_update_val;
    vc1_cnt_underflow_error_d                        <=  NOT or_reduce(tlxr_tlxt_consume_vc1_cnt_q(15 DOWNTO 2)) AND
                                                            ((('0'&tlxr_tlxt_consume_vc1_cnt_q(1 DOWNTO 0)) + ("00"&tlxr_tlxt_consume_vc1_q)) < (("00"&srq_tlxt_cmdq_release_q) + ("00"&tlxr_tlxt_vc1_release_q))) AND NOT vc1_credit_update_val;
    dcp1_cnt_underflow_error_d                       <=  NOT or_reduce(tlxr_tlxt_consume_dcp1_cnt_q(15 DOWNTO 3)) AND (tlxr_tlxt_consume_dcp1_cnt_q(2 DOWNTO 0) < tlxr_tlxt_dcp1_release_q(2 DOWNTO 0)) AND NOT dcp1_credit_update_val;
    
    --Parity Errors
    tlxc_tlxt_avail_credit_count_vc0_perror_d        <= xor_reduce(tlxc_tlxt_avail_credit_count_vc0_p_q  & tlxc_tlxt_avail_credit_count_vc0_q);    
    tlxc_tlxt_avail_credit_count_vc3_perror_d        <= xor_reduce(tlxc_tlxt_avail_credit_count_vc3_p_q  & tlxc_tlxt_avail_credit_count_vc3_q); 
    tlxc_tlxt_avail_credit_count_dcp0_perror_d       <= xor_reduce(tlxc_tlxt_avail_credit_count_dcp0_p_q & tlxc_tlxt_avail_credit_count_dcp0_q);
    tlxc_tlxt_avail_credit_count_dcp3_perror_d       <= xor_reduce(tlxc_tlxt_avail_credit_count_dcp3_p_q & tlxc_tlxt_avail_credit_count_dcp3_q);

    tlxc_tlxt_vc0_credits_perror_d                   <= xor_reduce(tlxc_tlxt_vc0_credits_p_q  & tlxc_tlxt_vc0_credits_q) or
                                                        xor_reduce(tlxc_tlxt_vc0_credits_release_q(3 DOWNTO 0)  & tlxc_tlxt_vc0_credits_release_p_q );
    tlxc_tlxt_vc1_credits_perror_d                   <= xor_reduce(tlxc_tlxt_vc1_credits_p_q  & tlxc_tlxt_vc1_credits_q) or          
                                                        xor_reduce(tlxc_tlxt_vc1_credits_release_q(3 DOWNTO 0)  & tlxc_tlxt_vc1_credits_release_p_q );
    tlxc_tlxt_dcp1_credits_perror_d                  <= xor_reduce(tlxc_tlxt_dcp1_credits_p_q & tlxc_tlxt_dcp1_credits_q) or          
                                                        xor_reduce(tlxc_tlxt_dcp1_credits_release_q(5 DOWNTO 0) & tlxc_tlxt_dcp1_credits_release_p_q);

    

----------------------------------------------------------------------------------------------------------------------------------------------------------
--Debug and trap
----------------------------------------------------------------------------------------------------------------------------------------------------------
    
    tlxc_crd_status_reg(0 TO 63)  <=   (0 TO 15 => '0')
                                    & tlxc_tlxt_dcp1_credits_q
                                    & tlxc_tlxt_vc0_credits_q 
                                    & tlxc_tlxt_vc1_credits_q;

    tlxc_crd_status_reg(64 TO 127) <=
                                      tlxc_tlxt_avail_credit_count_vc0_q(15 downto 0)  
                                    & tlxc_tlxt_avail_credit_count_vc3_q(15 downto 0) 
                                    & tlxc_tlxt_avail_credit_count_dcp0_q(15 downto 0)
                                    & tlxc_tlxt_avail_credit_count_dcp3_q(15 downto 0);




   tlxc_dbg_a_debug_bus(0 TO 43)     <= 

                                      tlxc_tlxt_dcp1_credits_q(15 DOWNTO 0)
                                    & tlxr_tlxt_dcp1_release_q(2 DOWNTO 0)
                                    & dcp1_credit_update_val 
                                    & dcp1_credit_return_pause

                                    & tlxc_tlxt_vc1_credits_q(15 DOWNTO 0)
                                    & srq_tlxt_cmdq_release_q 
                                    & tlxr_tlxt_vc1_release_q  
                                    & vc1_credit_update_val 
                                    & vc1_credit_return_pause

                                    & tlxt_tlxc_crd_ret_taken 

                                    & syncr_falling_q 
                                    & cfg_half_dimm_mode;

   tlxc_dbg_b_debug_bus(0 TO 87)     <= 
                                      --0:33
                                      (0 TO 11 => '0')
                                    & tlxc_tlxt_vc0_credits_q(15 DOWNTO 0) 
                                    & tlxr_tlxt_vc0_release_q(1 DOWNTO 0)
                                    & vc0_credit_update_val  
                                    & vc0_credit_return_pause
                                    & tlxt_tlxc_crd_ret_taken 
                                    & cfg_half_dimm_mode

                                    --34:87

                                     & tlxr_tlxt_return_val_q
                                     & '0'
                                     & tlxr_tlxt_return_vc0_gt(3 downto 0)      
                                     & tlxr_tlxt_return_vc3_gt(3 downto 0)     
                                     & tlxr_tlxt_return_dcp0_gt(5 downto 0)    
                                     & tlxr_tlxt_return_dcp3_gt(5 downto 0)    

                                     & tlxt_tlxc_consume_vc0(0)    
                                     & tlxt_tlxc_consume_vc3(0)    
                                     & tlxt_tlxc_consume_dcp0(0)   
                                     & tlxt_tlxc_consume_dcp3(0)   
                                     & x"000"

                                     & tlxc_tlxt_avail_vc0_q     
                                     & tlxc_tlxt_avail_vc3_q
                                     & tlxc_tlxt_avail_dcp0_q
                                     & tlxc_tlxt_avail_dcp3_q
                                     & x"000";
    

  cfg_half_dimm_mode_d <= cfg_half_dimm_mode; 

    
cfg_half_dimm_modeq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(cfg_half_dimm_mode_d),
           Tconv(q)             => cfg_half_dimm_mode_q);



dbg_tlxt_wat_eventq: entity latches.c_morph_dff
  generic map (width => 4, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => dbg_tlxt_wat_event_d(0 to 3),
           syncr                => syncr,
           q                    => dbg_tlxt_wat_event_q(0 to 3));

dcp1_cnt_underflow_errorq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(dcp1_cnt_underflow_error_d),
           syncr                => syncr,
           Tconv(q)             => dcp1_cnt_underflow_error_q);

dcp1_max_crd_errorq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(dcp1_max_crd_error_d),
           syncr                => syncr,
           Tconv(q)             => dcp1_max_crd_error_q);

srq_tlxt_cmdq_releaseq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(srq_tlxt_cmdq_release_d),
           syncr                => syncr,
           Tconv(q)             => srq_tlxt_cmdq_release_q);

syncr_fallingq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0, init => "1")
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(syncr_falling_d),
           syncr                => syncr,
           Tconv(q)             => syncr_falling_q);

tlx_dcp0_max_crd_errorq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(tlx_dcp0_max_crd_error_d),
           syncr                => syncr,
           Tconv(q)             => tlx_dcp0_max_crd_error_q);

tlx_dcp3_max_crd_errorq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(tlx_dcp3_max_crd_error_d),
           syncr                => syncr,
           Tconv(q)             => tlx_dcp3_max_crd_error_q);

tlx_vc0_max_crd_errorq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(tlx_vc0_max_crd_error_d),
           syncr                => syncr,
           Tconv(q)             => tlx_vc0_max_crd_error_q);

tlx_vc3_max_crd_errorq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(tlx_vc3_max_crd_error_d),
           syncr                => syncr,
           Tconv(q)             => tlx_vc3_max_crd_error_q);

tlxc_tlxt_avail_credit_count_dcp0q: entity latches.c_morph_dff
  generic map (width => 16, offset => 0)
  port map(gckn                 => gckn,
           e                    => act_cgt1,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => tlxc_tlxt_avail_credit_count_dcp0_cgt1_d(15 downto 0),
           syncr                => syncr,
           q                    => tlxc_tlxt_avail_credit_count_dcp0_q(15 downto 0));

tlxc_tlxt_avail_credit_count_dcp0_pq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act_cgt1,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(tlxc_tlxt_avail_credit_count_dcp0_p_cgt1_d),
           syncr                => syncr,
           Tconv(q)             => tlxc_tlxt_avail_credit_count_dcp0_p_q);

tlxc_tlxt_avail_credit_count_dcp0_perrorq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(tlxc_tlxt_avail_credit_count_dcp0_perror_d),
           syncr                => syncr,
           Tconv(q)             => tlxc_tlxt_avail_credit_count_dcp0_perror_q);

tlxc_tlxt_avail_credit_count_dcp3q: entity latches.c_morph_dff
  generic map (width => 16, offset => 0)
  port map(gckn                 => gckn,
           e                    => act_cgt1,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => tlxc_tlxt_avail_credit_count_dcp3_cgt1_d(15 downto 0),
           syncr                => syncr,
           q                    => tlxc_tlxt_avail_credit_count_dcp3_q(15 downto 0));

tlxc_tlxt_avail_credit_count_dcp3_pq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act_cgt1,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(tlxc_tlxt_avail_credit_count_dcp3_p_cgt1_d),
           syncr                => syncr,
           Tconv(q)             => tlxc_tlxt_avail_credit_count_dcp3_p_q);

tlxc_tlxt_avail_credit_count_dcp3_perrorq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(tlxc_tlxt_avail_credit_count_dcp3_perror_d),
           syncr                => syncr,
           Tconv(q)             => tlxc_tlxt_avail_credit_count_dcp3_perror_q);

tlxc_tlxt_avail_credit_count_vc0q: entity latches.c_morph_dff
  generic map (width => 16, offset => 0)
  port map(gckn                 => gckn,
           e                    => act_cgt1,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => tlxc_tlxt_avail_credit_count_vc0_cgt1_d(15 downto 0),
           syncr                => syncr,
           q                    => tlxc_tlxt_avail_credit_count_vc0_q(15 downto 0));

tlxc_tlxt_avail_credit_count_vc0_pq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act_cgt1,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(tlxc_tlxt_avail_credit_count_vc0_p_cgt1_d),
           syncr                => syncr,
           Tconv(q)             => tlxc_tlxt_avail_credit_count_vc0_p_q);

tlxc_tlxt_avail_credit_count_vc0_perrorq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(tlxc_tlxt_avail_credit_count_vc0_perror_d),
           syncr                => syncr,
           Tconv(q)             => tlxc_tlxt_avail_credit_count_vc0_perror_q);

tlxc_tlxt_avail_credit_count_vc3q: entity latches.c_morph_dff
  generic map (width => 16, offset => 0)
  port map(gckn                 => gckn,
           e                    => act_cgt1,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => tlxc_tlxt_avail_credit_count_vc3_cgt1_d(15 downto 0),
           syncr                => syncr,
           q                    => tlxc_tlxt_avail_credit_count_vc3_q(15 downto 0));

tlxc_tlxt_avail_credit_count_vc3_pq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act_cgt1,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(tlxc_tlxt_avail_credit_count_vc3_p_cgt1_d),
           syncr                => syncr,
           Tconv(q)             => tlxc_tlxt_avail_credit_count_vc3_p_q);

tlxc_tlxt_avail_credit_count_vc3_perrorq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(tlxc_tlxt_avail_credit_count_vc3_perror_d),
           syncr                => syncr,
           Tconv(q)             => tlxc_tlxt_avail_credit_count_vc3_perror_q);

tlxc_tlxt_avail_dcp0q: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(tlxc_tlxt_avail_dcp0_d),
           syncr                => syncr,
           Tconv(q)             => tlxc_tlxt_avail_dcp0_q);

tlxc_tlxt_avail_dcp3q: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(tlxc_tlxt_avail_dcp3_d),
           syncr                => syncr,
           Tconv(q)             => tlxc_tlxt_avail_dcp3_q);

tlxc_tlxt_avail_vc0q: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(tlxc_tlxt_avail_vc0_d),
           syncr                => syncr,
           Tconv(q)             => tlxc_tlxt_avail_vc0_q);

tlxc_tlxt_avail_vc3q: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(tlxc_tlxt_avail_vc3_d),
           syncr                => syncr,
           Tconv(q)             => tlxc_tlxt_avail_vc3_q);

tlxc_tlxt_crd_ret_valq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(tlxc_tlxt_crd_ret_val_d),
           syncr                => syncr,
           Tconv(q)             => tlxc_tlxt_crd_ret_val_q);

tlxc_tlxt_dcp1_creditsq: entity latches.c_morph_dff
  generic map (width => 16, offset => 0, init => x"0000")
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => tlxc_tlxt_dcp1_credits_d(15 downto 0),
           syncr                => syncr,
           q                    => tlxc_tlxt_dcp1_credits_q(15 downto 0));

tlxc_tlxt_dcp1_credits_pq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0, init => "0")
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(tlxc_tlxt_dcp1_credits_p_d),
           syncr                => syncr,
           Tconv(q)             => tlxc_tlxt_dcp1_credits_p_q);

tlxc_tlxt_dcp1_credits_perrorq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(tlxc_tlxt_dcp1_credits_perror_d),
           syncr                => syncr,
           Tconv(q)             => tlxc_tlxt_dcp1_credits_perror_q);

tlxc_tlxt_dcp1_credits_releaseq: entity latches.c_morph_dff
  generic map (width => 6, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => tlxc_tlxt_dcp1_credits_release_d(5 downto 0),
           syncr                => syncr,
           q                    => tlxc_tlxt_dcp1_credits_release_q(5 downto 0));

tlxc_tlxt_dcp1_credits_release_pq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(tlxc_tlxt_dcp1_credits_release_p_d),
           syncr                => syncr,
           Tconv(q)             => tlxc_tlxt_dcp1_credits_release_p_q);

tlxc_tlxt_vc0_creditsq: entity latches.c_morph_dff
  generic map (width => 16, offset => 0, init => x"0004")
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => tlxc_tlxt_vc0_credits_d(15 downto 0),
           syncr                => syncr,
           q                    => tlxc_tlxt_vc0_credits_q(15 downto 0));

tlxc_tlxt_vc0_credits_pq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0, init => "1")
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(tlxc_tlxt_vc0_credits_p_d),
           syncr                => syncr,
           Tconv(q)             => tlxc_tlxt_vc0_credits_p_q);

tlxc_tlxt_vc0_credits_perrorq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(tlxc_tlxt_vc0_credits_perror_d),
           syncr                => syncr,
           Tconv(q)             => tlxc_tlxt_vc0_credits_perror_q);

tlxc_tlxt_vc0_credits_releaseq: entity latches.c_morph_dff
  generic map (width => 4, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => tlxc_tlxt_vc0_credits_release_d(3 downto 0),
           syncr                => syncr,
           q                    => tlxc_tlxt_vc0_credits_release_q(3 downto 0));

tlxc_tlxt_vc0_credits_release_pq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(tlxc_tlxt_vc0_credits_release_p_d),
           syncr                => syncr,
           Tconv(q)             => tlxc_tlxt_vc0_credits_release_p_q);

tlxc_tlxt_vc1_creditsq: entity latches.c_morph_dff
  generic map (width => 16, offset => 0, init => x"001E")
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => tlxc_tlxt_vc1_credits_d(15 downto 0),
           syncr                => syncr,
           q                    => tlxc_tlxt_vc1_credits_q(15 downto 0));

tlxc_tlxt_vc1_credits_pq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0, init => "0")
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(tlxc_tlxt_vc1_credits_p_d),
           syncr                => syncr,
           Tconv(q)             => tlxc_tlxt_vc1_credits_p_q);

tlxc_tlxt_vc1_credits_perrorq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(tlxc_tlxt_vc1_credits_perror_d),
           syncr                => syncr,
           Tconv(q)             => tlxc_tlxt_vc1_credits_perror_q);

tlxc_tlxt_vc1_credits_releaseq: entity latches.c_morph_dff
  generic map (width => 4, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => tlxc_tlxt_vc1_credits_release_d(3 downto 0),
           syncr                => syncr,
           q                    => tlxc_tlxt_vc1_credits_release_q(3 downto 0));

tlxc_tlxt_vc1_credits_release_pq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(tlxc_tlxt_vc1_credits_release_p_d),
           syncr                => syncr,
           Tconv(q)             => tlxc_tlxt_vc1_credits_release_p_q);

tlxr_tlxt_consume_dcp1_cntq: entity latches.c_morph_dff
  generic map (width => 16, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => tlxr_tlxt_consume_dcp1_cnt_d(15 downto 0),
           syncr                => syncr,
           q                    => tlxr_tlxt_consume_dcp1_cnt_q(15 downto 0));

tlxr_tlxt_consume_dcp1q: entity latches.c_morph_dff
  generic map (width => 3, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => tlxr_tlxt_consume_dcp1_d(2 downto 0),
           syncr                => syncr,
           q                    => tlxr_tlxt_consume_dcp1_q(2 downto 0));

tlxr_tlxt_consume_vc0_cntq: entity latches.c_morph_dff
  generic map (width => 16, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => tlxr_tlxt_consume_vc0_cnt_d(15 downto 0),
           syncr                => syncr,
           q                    => tlxr_tlxt_consume_vc0_cnt_q(15 downto 0));

tlxr_tlxt_consume_vc0q: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(tlxr_tlxt_consume_vc0_d),
           syncr                => syncr,
           Tconv(q)             => tlxr_tlxt_consume_vc0_q);

tlxr_tlxt_consume_vc1_cntq: entity latches.c_morph_dff
  generic map (width => 16, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => tlxr_tlxt_consume_vc1_cnt_d(15 downto 0),
           syncr                => syncr,
           q                    => tlxr_tlxt_consume_vc1_cnt_q(15 downto 0));

tlxr_tlxt_consume_vc1q: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(tlxr_tlxt_consume_vc1_d),
           syncr                => syncr,
           Tconv(q)             => tlxr_tlxt_consume_vc1_q);

tlxr_tlxt_dcp1_releaseq: entity latches.c_morph_dff
  generic map (width => 3, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => tlxr_tlxt_dcp1_release_d(2 downto 0),
           syncr                => syncr,
           q                    => tlxr_tlxt_dcp1_release_q(2 downto 0));

tlxr_tlxt_return_dcp0q: entity latches.c_morph_dff
  generic map (width => 6, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => tlxr_tlxt_return_dcp0_d(5 downto 0),
           syncr                => syncr,
           q                    => tlxr_tlxt_return_dcp0_q(5 downto 0));

tlxr_tlxt_return_dcp3q: entity latches.c_morph_dff
  generic map (width => 6, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => tlxr_tlxt_return_dcp3_d(5 downto 0),
           syncr                => syncr,
           q                    => tlxr_tlxt_return_dcp3_q(5 downto 0));

tlxr_tlxt_return_valq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(tlxr_tlxt_return_val_d),
           syncr                => syncr,
           Tconv(q)             => tlxr_tlxt_return_val_q);

tlxr_tlxt_return_vc0q: entity latches.c_morph_dff
  generic map (width => 4, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => tlxr_tlxt_return_vc0_d(3 downto 0),
           syncr                => syncr,
           q                    => tlxr_tlxt_return_vc0_q(3 downto 0));

tlxr_tlxt_return_vc3q: entity latches.c_morph_dff
  generic map (width => 4, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => tlxr_tlxt_return_vc3_d(3 downto 0),
           syncr                => syncr,
           q                    => tlxr_tlxt_return_vc3_q(3 downto 0));

tlxr_tlxt_vc0_releaseq: entity latches.c_morph_dff
  generic map (width => 2, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => tlxr_tlxt_vc0_release_d(1 downto 0),
           syncr                => syncr,
           q                    => tlxr_tlxt_vc0_release_q(1 downto 0));

tlxr_tlxt_vc1_releaseq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(tlxr_tlxt_vc1_release_d),
           syncr                => syncr,
           Tconv(q)             => tlxr_tlxt_vc1_release_q);

tlxt_tlxc_crd_ret_takenq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(tlxt_tlxc_crd_ret_taken_d),
           syncr                => syncr,
           Tconv(q)             => tlxt_tlxc_crd_ret_taken_q);

vc0_cnt_underflow_errorq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(vc0_cnt_underflow_error_d),
           syncr                => syncr,
           Tconv(q)             => vc0_cnt_underflow_error_q);

vc0_max_crd_errorq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(vc0_max_crd_error_d),
           syncr                => syncr,
           Tconv(q)             => vc0_max_crd_error_q);

vc1_cnt_underflow_errorq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(vc1_cnt_underflow_error_d),
           syncr                => syncr,
           Tconv(q)             => vc1_cnt_underflow_error_q);

vc1_max_crd_errorq: entity latches.c_morph_dff
  generic map (width => 1, offset => 0)
  port map(gckn                 => gckn,
           e                    => act,
           vdd                  => vdd,
           vss                  => gnd,
           d                    => Tconv(vc1_max_crd_error_d),
           syncr                => syncr,
           Tconv(q)             => vc1_max_crd_error_q);

end cb_tlxt_crd_mgmt_rlm;
