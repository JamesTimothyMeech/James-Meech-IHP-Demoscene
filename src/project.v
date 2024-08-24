/*
 * Copyright (c) 2024 Uri Shaked
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

  // VGA signals
  wire hsync;
  wire vsync;
  wire [1:0] R;
  wire [1:0] G;
  wire [1:0] B;
  wire video_active;

  // TinyVGA PMOD
  assign hsync = ui_in[0];
  assign B[0] = ui_in[1] + (B[0] + pcg_out[0]);
  assign G[0] = ui_in[2] + (G[0] + pcg_out[1]);
  assign R[0] = ui_in[3] + (R[0] + pcg_out[2]);
  assign vsync = ui_in[4];
  assign B[1] = ui_in[5] + (B[1] + pcg_out[3]);
  assign G[1] = ui_in[6] + (G[1] + pcg_out[4]);
  assign R[1] = ui_in[7] + (R[1] + pcg_out[5]);
  assign uo_out = {hsync, B[0], G[0], R[0], vsync, B[1], G[1], R[1]};

  assign R = video_active ? (R & pcg_out[0:1]) : 2'b00;
  assign G = video_active ? (G & pcg_out[2:3]) : 2'b00;
  assign B = video_active ? (B & pcg_out[4:5]) : 2'b00;

  // Unused outputs assigned to 0.
  assign uio_out = 0;
  assign uio_oe  = 0;

  // Suppress unused signals warning
  wire _unused_ok = &{ena, uio_in};

  reg [31:0] pcg_out = 32'h00000000;
  reg [31:0] xorshifted = 32'h00000000;
	reg [31:0] rot = 32'h00000000;
	reg [63:0] state = 64'h0000000000000000; 

	always @ (posedge clk) 
	begin
		state = state * 64'h5851f42d4c957 + 64'h14057b7ef767814;
		xorshifted = ((state >> 18) ^ state) >> 27;
		rot = state >> 59;
		pcg_out = (xorshifted >> rot) | (xorshifted << ((-rot) & 31));
	end
  
endmodule
