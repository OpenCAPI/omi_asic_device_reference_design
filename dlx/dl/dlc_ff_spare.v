// *!***************************************************************************
// *! Copyright 2019 International Business Machines
// *!
// *! Licensed under the Apache License, Version 2.0 (the "License");
// *! you may not use this file except in compliance with the License.
// *! You may obtain a copy of the License at
// *! http://www.apache.org/licenses/LICENSE-2.0 
// *!
// *! The patent license granted to you in Section 3 of the License, as applied
// *! to the "Work," hereby includes implementations of the Work in physical form.  
// *!
// *! Unless required by applicable law or agreed to in writing, the reference design
// *! distributed under the License is distributed on an "AS IS" BASIS,
// *! WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// *! See the License for the specific language governing permissions and
// *! limitations under the License.
// *! 
// *! The background Specification upon which this is based is managed by and available from
// *! the OpenCAPI Consortium.  More information can be found at https://opencapi.org. 
// *!***************************************************************************
`timescale 100ps/10ps
//-- *!********************************************************************
//-- *!           
//-- *!******************************************************************
module dlc_ff_spare #(
parameter             width = 1,
parameter [width-1:0] rstv  = 0
)
(
input 	              clk,
input 	              reset_n,
input 	              enable,
input  [width-1:0]    din,
output [width-1:0]    q
 );
   

wire               ena  ;
reg [width-1:0]    q_int;

// this assignment is needed for synthesis
assign ena = enable;

// *** async reset on flip flop ***   
// always@(posedge clk or negedge reset_n)
// begin
//   if (~reset_n) q_int <= rstv;
//   else if (ena) q_int <= din;
// end 

//  test // *** sync reset on flip flop ***   
//  test always@(posedge clk && ena)
//  test begin
//  test   if (~reset_n) q_int <= rstv;
//  test   else q_int <= din;
//  test end 
//  orig // *** sync reset on flip flop ***   
//  orig always@(posedge clk)
//  orig begin
//  orig   if (~reset_n) q_int <= rstv;
//  orig   else if (ena) q_int <= din;
//  orig end 
   
  
// *** sync reset on flip flop ***   
always@(posedge clk)
begin
  if (ena) begin
      if (~reset_n) q_int <= rstv;
      else q_int <= din;
  end
end 
   
// *** no reset on flip flop ***   
//always@(posedge clk)
//begin
//  if (ena) q_int <= din;
//end 
   
assign q = q_int;
   
endmodule // dlc_ff_spare
