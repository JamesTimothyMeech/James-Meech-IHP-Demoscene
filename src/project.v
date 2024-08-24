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
  wire [9:0] pix_x;
  wire [9:0] pix_y;

  // TinyVGA PMOD
  assign uo_out = {hsync + (pcg_out[0] & ui_in[0]), B[0] + (pcg_out[1] & ui_in[1]), G[0] + (pcg_out[2] & ui_in[2]), R[0] + (pcg_out[3] & ui_in[3]), vsync + (pcg_out[4] & ui_in[4]), B[1] + (pcg_out[5] & ui_in[5]), G[1] + (pcg_out[6] & ui_in[6]), R[1] + (pcg_out[7] & ui_in[7])};

  // Unused outputs assigned to 0.
  assign uio_out = 0;
  assign uio_oe  = 0;

  // Suppress unused signals warning
  wire _unused_ok = &{ena, ui_in, uio_in};

  reg [9:0] counter;

  hvsync_generator hvsync_gen(
    .clk(clk),
    .reset(~rst_n),
    .hsync(hsync),
    .vsync(vsync),
    .display_on(video_active),
    .hpos(pix_x),
    .vpos(pix_y)
  );

  reg [7:0] pcg_out = 8'h00;
  reg [7:0] xorshifted = 8'h00;
	reg [7:0] rot = 8'h00;
	reg [15:0] state = 16'h0000; 

	always @ (posedge clk) 
	begin
		state = state * 16'h5851 + 16'h1405;
		xorshifted = ((state >> 2) ^ state) >> 3;
		rot = state >> 3;
		pcg_out = (xorshifted >> rot) | (xorshifted << ((-rot) & 15));
	end
  
  wire [9:0] moving_x = pix_x + counter;

  assign R = video_active ? {moving_x[5], pix_y[2]} : 2'b00;
  assign G = video_active ? {moving_x[6], pix_y[2]} : 2'b00;
  assign B = video_active ? {moving_x[7], pix_y[5]} : 2'b00;
  
  always @(posedge vsync) begin
    if (~rst_n) begin
      counter <= 0;
    end else begin
      counter <= counter + 1;
    end
  end
  
endmodule
