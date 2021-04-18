/*
  
   Multicore 2 / Multicore 2+
  
   Copyright (c) 2017-2020 - Victor Trucco

  
   All rights reserved
  
   Redistribution and use in source and synthezised forms, with or without
   modification, are permitted provided that the following conditions are met:
  
   Redistributions of source code must retain the above copyright notice,
   this list of conditions and the following disclaimer.
  
   Redistributions in synthesized form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.
  
   Neither the name of the author nor the names of other contributors may
   be used to endorse or promote products derived from this software without
   specific prior written permission.
  
   THIS CODE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
   AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
   THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
   PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE
   LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
   CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
   SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
   INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
   CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
   ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
   POSSIBILITY OF SUCH DAMAGE.
  
   You are responsible for any legal issues arising from your use of this code.
  
*///
//
// Copyright (c) 2017 Sorgelig
//
// This program is GPL Licensed. See COPYING for the full license.
//
//
////////////////////////////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

//
// LINE_LENGTH: Length of  display line in pixels
//              Usually it's length from HSync to HSync.
//              May be less if line_start is used.
//
// HALF_DEPTH:  If =1 then color dept is 4 bits per component
//              For half depth 8 bits monochrome is available with
//              mono signal enabled and color = {G, R}
//
// altera message_off 10720 
// altera message_off 12161

module video_mixer
#(
	parameter LINE_LENGTH  = 768,
	parameter HALF_DEPTH   = 0,
	parameter GAMMA        = 0
)
(
	// video clock
	// it should be multiple by (ce_pix*4).
	input            clk_vid,

	// Pixel clock or clock_enable (both are accepted).
	input            ce_pix,
	output           ce_pix_out,

	input            scandoubler,

	// scanlines (00-none 01-25% 10-50% 11-75%)
	input      [1:0] scanlines,

	// High quality 2x scaling
	input            hq2x,
	
	input            blend,

	// color
	input [DWIDTH:0] R,
	input [DWIDTH:0] G,
	input [DWIDTH:0] B,

	// Monochrome mode (for HALF_DEPTH only)
	input            mono,

	inout     [21:0] gamma_bus,

	// Positive pulses.
	input            HSync,
	input            VSync,
	input            HBlank,
	input            VBlank,

	// video output signals
	output reg [7:0] VGA_R,
	output reg [7:0] VGA_G,
	output reg [7:0] VGA_B,
	output reg       VGA_VS,
	output reg       VGA_HS,
	output reg       VGA_DE
);

localparam DWIDTH = HALF_DEPTH ? 3 : 7;
localparam DWIDTH_SD = GAMMA ? 7 : DWIDTH;
localparam HALF_DEPTH_SD = GAMMA ? 0 : HALF_DEPTH;

generate
	if(GAMMA && HALF_DEPTH) begin
		wire [7:0] R_in  = mono ? {G,R} : {R,R};
		wire [7:0] G_in  = mono ? {G,R} : {G,G};
		wire [7:0] B_in  = mono ? {G,R} : {B,B};
	end else begin
		wire [DWIDTH:0] R_in  = R;
		wire [DWIDTH:0] G_in  = G;
		wire [DWIDTH:0] B_in  = B;
	end
endgenerate


wire hs_g, vs_g;
wire hb_g, vb_g;
wire [DWIDTH_SD:0] R_gamma, G_gamma, B_gamma;

generate
	if(GAMMA) begin
		assign gamma_bus[21] = 1;
		gamma_corr gamma(
			.clk_sys(gamma_bus[20]),
			.clk_vid(clk_vid),
			.ce_pix(ce_pix),

			.gamma_en(gamma_bus[19]),
			.gamma_wr(gamma_bus[18]),
			.gamma_wr_addr(gamma_bus[17:8]),
			.gamma_value(gamma_bus[7:0]),

			.HSync(HSync),
			.VSync(VSync),
			.HBlank(HBlank),
			.VBlank(VBlank),
			.RGB_in({R_in,G_in,B_in}),

			.HSync_out(hs_g),
			.VSync_out(vs_g),
			.HBlank_out(hb_g),
			.VBlank_out(vb_g),
			.RGB_out({R_gamma,G_gamma,B_gamma})
		);
	end else begin
		assign gamma_bus[21] = 0;
		assign {R_gamma,G_gamma,B_gamma} = {R_in,G_in,B_in};
		assign {hs_g, vs_g, hb_g, vb_g} = {HSync, VSync, HBlank, VBlank};
	end
endgenerate


wire [DWIDTH_SD:0] R_sd;
wire [DWIDTH_SD:0] G_sd;
wire [DWIDTH_SD:0] B_sd;
wire hs_sd, vs_sd, hb_sd, vb_sd, ce_pix_sd;

wire ce_pix_outx4;

scandoubler #(.LENGTH(LINE_LENGTH), .HALF_DEPTH(HALF_DEPTH_SD)) sd
(
	.*,
	.hs_in(hs_g),
	.vs_in(vs_g),
	.hb_in(hb_g),
	.vb_in(vb_g),
	.r_in(R_gamma),
	.g_in(G_gamma),
	.b_in(B_gamma),

	.ce_pix_out(ce_pix_sd),
	.ce_pix_outx4(ce_pix_outx4),
	.hs_out(hs_sd),
	.vs_out(vs_sd),
	.hb_out(hb_sd),
	.vb_out(vb_sd),
	.r_out(R_sd),
	.g_out(G_sd),
	.b_out(B_sd)
);

wire [DWIDTH_SD:0] rt  = (scandoubler ? R_sd : R_gamma);
wire [DWIDTH_SD:0] gt  = (scandoubler ? G_sd : G_gamma);
wire [DWIDTH_SD:0] bt  = (scandoubler ? B_sd : B_gamma);

generate
	if(!GAMMA && HALF_DEPTH) begin
		wire [7:0] r  = mono ? {gt,rt} : {rt,rt};
		wire [7:0] g  = mono ? {gt,rt} : {gt,gt};
		wire [7:0] b  = mono ? {gt,rt} : {bt,bt};
	end else begin
		wire [7:0] r  = rt;
		wire [7:0] g  = gt;
		wire [7:0] b  = bt;
	end
endgenerate

wire hs = (scandoubler ? hs_sd : hs_g);
wire vs = (scandoubler ? vs_sd : vs_g);

assign ce_pix_out = scandoubler ? ce_pix_sd : ce_pix;

wire [7:0] cofi_r;
wire [7:0] cofi_g;
wire [7:0] cofi_b;

cofi cofi (
	.clk     ( clk_vid ),
	.pix_ce  ( ce_pix_outx4 ),
	.enable  ( blend   ),
	
	.red     ( r ),
	.green   ( g ),
	.blue    ( b ),
	
	.red_out  ( cofi_r  ),
	.green_out( cofi_g ),
	.blue_out ( cofi_b  )
);



reg scanline = 0;
always @(posedge clk_vid) begin
	reg old_hs, old_vs;
	
	old_hs <= hs;
	old_vs <= vs;
	
	if(old_hs && ~hs) scanline <= ~scanline;
	if(old_vs && ~vs) scanline <= 0;
end

wire hde = scandoubler ? ~hb_sd : ~hb_g;
wire vde = scandoubler ? ~vb_sd : ~vb_g;

always @(posedge clk_vid) begin
	reg old_hde;

	case(scanlines & {scanline, scanline})
		1: begin // reduce 25% = 1/2 + 1/4
			VGA_R <= {1'b0, cofi_r[7:1]} + {2'b00, cofi_r[7:2]};
			VGA_G <= {1'b0, cofi_g[7:1]} + {2'b00, cofi_g[7:2]};
			VGA_B <= {1'b0, cofi_b[7:1]} + {2'b00, cofi_b[7:2]};
		end

		2: begin // reduce 50% = 1/2
			VGA_R <= {1'b0, cofi_r[7:1]};
			VGA_G <= {1'b0, cofi_g[7:1]};
			VGA_B <= {1'b0, cofi_b[7:1]};
		end

		3: begin // reduce 75% = 1/4
			VGA_R <= {2'b00, cofi_r[7:2]};
			VGA_G <= {2'b00, cofi_g[7:2]};
			VGA_B <= {2'b00, cofi_b[7:2]};
		end

		default: begin
			VGA_R <= cofi_r;
			VGA_G <= cofi_g;
			VGA_B <= cofi_b;
		end
	endcase

	VGA_VS <= vs;
	VGA_HS <= hs;

	old_hde <= hde;
	if(~old_hde && hde) VGA_DE <= vde;
	if(old_hde && ~hde) VGA_DE <= 0;
end

endmodule
