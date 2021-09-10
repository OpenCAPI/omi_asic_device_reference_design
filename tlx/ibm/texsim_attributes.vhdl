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





package texsim_attributes is

  type texsim_latch_type is (master_latch, L1,
                             slave_latch,  L2,
                             flush_latch,  L4 );

  type texsim_array_update_policy is (RW, WR);

  subtype texsim_array_bounds_check  is integer range 0 to 30;

  attribute latch_type         : texsim_latch_type;
  attribute array_update       : texsim_array_update_policy;
  attribute array_bounds_check : texsim_array_bounds_check;
  attribute texsim_tristate    : boolean;

end texsim_attributes;
