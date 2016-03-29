// Copyright 2016 by the authors
//
// Copyright and related rights are licensed under the Solderpad
// Hardware License, Version 0.51 (the "License"); you may not use
// this file except in compliance with the License. You may obtain a
// copy of the License at http://solderpad.org/licenses/SHL-0.51.
// Unless required by applicable law or agreed to in writing,
// software, hardware and materials distributed under this License is
// distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS
// OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the
// License.
//
// Authors:
//    Stefan Wallentowitz <stefan@wallentowitz.de>

module osim
  #(parameter FREQ = 32'hx,
    parameter UART_BASE = 32'hx,
    parameter UART_IRQ = 32'hx,
    parameter DRAM_BASE = 32'hx,
    parameter DRAM_SIZE = 32'hx)
   (
    input         clk,
    input         rst,

    input [4:0]   adr_i,
    input [31:0]  dat_i,
    input         cyc_i,
    input         stb_i,
    input         we_i,
    input [3:0]   sel_i,
    output        ack_o,
    output        rty_o,
    output        err_o,
    output [31:0] dat_o
    );

   localparam REG_FREQ = 0;
   localparam REG_UART_BASE = 1;
   localparam REG_UART_IRQ = 2;
   localparam REG_DRAM_BASE = 3;
   localparam REG_DRAM_SIZE = 4;
   
   reg                                   ack, err;
   logic                                 access_err;

   always @(*) begin
      access_err = we_i | (|adr_i[1:0]) | (adr_i[4:2] > REG_DRAM_SIZE);
      
      case (adr_i[4:2])
         REG_FREQ:      dat_o = FREQ;
         REG_UART_BASE: dat_o = UART_BASE;
         REG_UART_IRQ:  dat_o = UART_IRQ;
         REG_DRAM_BASE: dat_o = DRAM_BASE;
         REG_DRAM_SIZE: dat_o = DRAM_SIZE;
         default:       dat_o = 32'hx;
      endcase
   end
   
   always @(posedge clk) begin
      if (rst) begin
         ack <= 0;
         err <= 0;
      end else begin
         ack <= cyc_i & stb_i & !access_err;
         err <= cyc_i & stb_i & access_err;
      end
   end

endmodule // osim

