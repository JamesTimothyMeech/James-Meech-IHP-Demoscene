/*
 * Copyright (c) 2024 James Meech
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_crispy_vga(
  input  wire [7:0] ui_in,    // Dedicated inputs
  output wire [7:0] uo_out,   // Dedicated outputs
  input  wire [7:0] uio_in,   // IOs: Input path
  output wire [7:0] uio_out,  // IOs: Output path
  output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
  input  wire       ena,      // always 1 when the design is powered, so you can ignore it
  input  wire       clk,      // clock
  input  wire       rst_n     // reset_n - low to reset
);

 
  assign uo_out = pcg_out;
  
 
  assign uio_out[7] = 1'b0;
  assign uio_out[6] = 1'b0;
  assign uio_out[5] = 1'b0;
  assign uio_out[4] = 1'b0;
  assign uio_out[3] = 1'b0;
  assign uio_out[2] = 1'b0;
  assign uio_out[1] = 1'b0;
  assign uio_out[0] = 1'b0;
  
  assign uio_oe[7]  = 1'b1;
  assign uio_oe[6]  = 1'b0;
  assign uio_oe[5]  = 1'b0;
  assign uio_oe[4]  = 1'b0;
  assign uio_oe[3]  = 1'b0;
  assign uio_oe[2]  = 1'b0;
  assign uio_oe[1]  = 1'b0;
  assign uio_oe[0]  = 1'b0;

  // Suppress unused signals warning
  wire _unused_ok = &{ena};
  
  reg [7:0] pcg_out = 8'h00;
  reg [15:0] state = 16'h0000; 

  always @ (posedge clk) begin
    if(~rst_n) begin
      pcg_out <= 8'h00;
      state <= 16'd4356;
    end else begin
        state <= state * 16'd12829 + 16'd47989;
        pcg_out <= (((state >> ((state >> 13) + 3)) ^ state) * 62169) >> 8;
    end
  end
endmodule
