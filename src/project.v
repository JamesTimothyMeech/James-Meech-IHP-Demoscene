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
  reg hsync;
  reg vsync;
  reg [1:0] R;
  reg [1:0] G;
  reg [1:0] B;
  reg video_active;

  // TinyVGA PMOD
  always @ (posedge clk) 
	begin
    hsync = ui_in[0];
    B[0] = ui_in[1] + (B[0] + pcg_out[0]);
    G[0] = ui_in[2] + (G[0] + pcg_out[1]);
    R[0] = ui_in[3] + (R[0] + pcg_out[2]);
    vsync = ui_in[4];
    B[1] = ui_in[5] + (B[1] + pcg_out[3]);
    G[1] = ui_in[6] + (G[1] + pcg_out[4]);
    R[1] = ui_in[7] + (R[1] + pcg_out[5]);
  end

  assign uo_out = {hsync, B[0], G[0], R[0], vsync, B[1], G[1], R[1]};

  // Unused outputs assigned to 0.
  assign uio_out = 0;
  assign uio_oe  = 0;

  // Suppress unused signals warning
  wire _unused_ok = &{ena, uio_in};

  reg [15:0] pcg_out = 16'h0000;
  reg [15:0] xorshifted = 16'h0000;
	reg [15:0] rot = 16'h0000;
	reg [31:0] state = 32'h00000000; 

	always @ (posedge clk) 
	begin
		state = state * 32'h5851f42d + 32'h14057b7e;
		xorshifted = ((state >> 18) ^ state) >> 27;
		rot = state >> 27;
		pcg_out = (xorshifted >> rot) | (xorshifted << ((-rot) & 31));
	end
  
endmodule
