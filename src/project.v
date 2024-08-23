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
  assign uo_out = {hsync, B[0], G[0], R[0], vsync, B[1], G[1], R[1]};

  // Unused outputs assigned to 0.
  assign uio_out = 0;
  assign uio_oe  = 0;

  // Suppress unused signals warning
  wire _unused_ok = &{ena};

  reg [9:0] counter;

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

  hvsync_generator hvsync_gen(
    .clk(clk),
    .reset(~rst_n),
    .hsync(hsync),
    .vsync(vsync),
    .display_on(video_active),
    .hpos(pix_x),
    .vpos(pix_y)
  );
  
  wire [9:0] moving_x = pix_x + counter + (ui_in & pcg_out[7:0]);
  wire [9:0] noisy_pix_y = pix_y + (uio_in & pcg_out[7:0]); 

  assign R = video_active ? {moving_x[5], noisy_pix_y[2]} : 2'b00;
  assign G = video_active ? {moving_x[6], noisy_pix_y[2]} : 2'b00;
  assign B = video_active ? {moving_x[7], noisy_pix_y[5]} : 2'b00;
  
  always @(posedge vsync) begin
    if (~rst_n) begin
      counter <= 0;
    end else begin
      counter <= counter + 1;
    end
  end
  
endmodule
