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
  
*///============================================================================
//
//  Copyright (C) 2017-2019 Sorgelig
//
//============================================================================

//////////////////////////////////////////////////////////
// DW:
//  6 : 2R 2G 2B
//  8 : 3R 3G 2B
//  9 : 3R 3G 3B
// 12 : 4R 4G 4B

module arcade_rotate_fx #(parameter WIDTH=320, HEIGHT=240, DW=8, CCW=0, GAMMA=1)
(
	input         clk_video,
	input         ce_pix,

	input[DW-1:0] RGB_in,
	input         HBlank,
	input         VBlank,
	input         HSync,
	input         VSync,
	
	

	output        VGA_CLK,
	output        VGA_CE,
	output  [7:0] VGA_R,
	output  [7:0] VGA_G,
	output  [7:0] VGA_B,
	output        VGA_HS,
	output        VGA_VS,
	output        VGA_DE,

	output        HDMI_CLK,
	output        HDMI_CE,
	output  [7:0] HDMI_R,
	output  [7:0] HDMI_G,
	output  [7:0] HDMI_B,
	output        HDMI_HS,
	output        HDMI_VS,
	output        HDMI_DE,
	output  [1:0] HDMI_SL,
	
	input   [2:0] fx,
	input         forced_scandoubler,
	input         no_rotate,
	input         direct_video,
	inout  [21:0] gamma_bus
);

wire [7:0] R,G,B;
wire       CE,HS,VS,HBL,VBL;

wire [DW-1:0] RGB_fix;
wire VGA_HBL, VGA_VBL;
arcade_vga #(DW) vga
(
	.clk_video(clk_video),
	.ce_pix(ce_pix),

	.RGB_in(RGB_in),
	.HBlank(HBlank),
	.VBlank(VBlank),
	.HSync(HSync),
	.VSync(VSync),

	.RGB_out(RGB_fix),
	.VGA_CLK(VGA_CLK),
	.VGA_CE(CE),
	.VGA_R(R),
	.VGA_G(G),
	.VGA_B(B),
	.VGA_HS(HS),
	.VGA_VS(VS),
	.VGA_HBL(HBL),
	.VGA_VBL(VBL)
);

wire [DW-1:0] RGB_out;
wire rhs,rvs,rhblank,rvblank;

screen_rotate #(WIDTH,HEIGHT,DW,4,CCW) rotator
(
	.clk(VGA_CLK),
	.ce(CE),

	.video_in(RGB_fix),
	.hblank(HBL),
	.vblank(VBL),

	.ce_out(CE | (~scandoubler & ~gamma_bus[19])),
	.video_out(RGB_out),
	.hsync(rhs),
	.vsync(rvs),
	.hblank_out(rhblank),
	.vblank_out(rvblank)
);

wire [3:0] Rr,Gr,Br;

generate
	if(DW == 6) begin
		assign Rr = {RGB_out[5:4],RGB_out[5:4]};
		assign Gr = {RGB_out[3:2],RGB_out[3:2]};
		assign Br = {RGB_out[1:0],RGB_out[1:0]};
	end
	else if(DW == 8) begin
		assign Rr = {RGB_out[7:5],RGB_out[7]};
		assign Gr = {RGB_out[4:2],RGB_out[4]};
		assign Br = {RGB_out[1:0],RGB_out[1:0]};
	end
	else if(DW == 9) begin
		assign Rr = {RGB_out[8:6],RGB_out[8]};
		assign Gr = {RGB_out[5:3],RGB_out[5]};
		assign Br = {RGB_out[2:0],RGB_out[2]};
	end
	else begin
		assign Rr = RGB_out[11:8];
		assign Gr = RGB_out[7:4];
		assign Br = RGB_out[3:0];
	end
endgenerate

reg norot;
always @(posedge VGA_CLK) norot <= no_rotate | direct_video;

assign HDMI_CLK = VGA_CLK;
assign HDMI_SL  = (no_rotate & ~direct_video) ? 2'd0 : sl[1:0];
wire [2:0] sl = fx ? fx - 1'd1 : 3'd0;
wire scandoubler = fx || forced_scandoubler;

video_mixer #(WIDTH+4, 1, GAMMA) video_mixer
(
	.clk_vid(HDMI_CLK),
	.ce_pix(CE | (~scandoubler & ~gamma_bus[19] & ~direct_video)),
	.ce_pix_out(HDMI_CE),

	.scandoubler(scandoubler),
	.hq2x(fx==1),
	.gamma_bus(gamma_bus),

	.R(norot ? R[7:4] : Rr),
	.G(norot ? G[7:4] : Gr),
	.B(norot ? B[7:4] : Br),

	.HSync (norot ? HS  : rhs),
	.VSync (norot ? VS  : rvs),
	.HBlank(norot ? HBL : rhblank),
	.VBlank(norot ? VBL : rvblank),

	.VGA_R(HDMI_R),
	.VGA_G(HDMI_G),
	.VGA_B(HDMI_B),
	.VGA_VS(HDMI_VS),
	.VGA_HS(HDMI_HS),
	.VGA_DE(HDMI_DE)
);

assign VGA_CE = direct_video ? HDMI_CE : CE;
assign VGA_R  = direct_video ? HDMI_R  : R;
assign VGA_G  = direct_video ? HDMI_G  : G;
assign VGA_B  = direct_video ? HDMI_B  : B;
assign VGA_HS = direct_video ? HDMI_HS : HS;
assign VGA_VS = direct_video ? HDMI_VS : VS;
assign VGA_DE = direct_video ? HDMI_DE : ~(HBL | VBL);

endmodule

//////////////////////////////////////////////////////////
// DW:
//  6 : 2R 2G 2B
//  8 : 3R 3G 2B
//  9 : 3R 3G 3B
// 12 : 4R 4G 4B

module arcade_fx #(parameter WIDTH=320, DW=8, GAMMA=1)
(
	input         clk_video,
	input         ce_pix,

	input[DW-1:0] RGB_in,
	input         HBlank,
	input         VBlank,
	input         HSync,
	input         VSync,
	
	input				SPI_DI,
	input				SPI_SCK,
	input				SPI_SS3,
	
	input  [1:0] osd_rotate, //[0] - rotate [1] - left or right

	output        VGA_CLK,
	output        VGA_CE,
	output  [7:0] VGA_R,
	output  [7:0] VGA_G,
	output  [7:0] VGA_B,
	output        VGA_HS,
	output        VGA_VS,
	output        VGA_DE,

	output        HDMI_CLK,
	output        HDMI_CE,
	output  [7:0] HDMI_R,
	output  [7:0] HDMI_G,
	output  [7:0] HDMI_B,
	output        HDMI_HS,
	output        HDMI_VS,
	output        HDMI_DE,
	output  [1:0] HDMI_SL,

	input   [2:0] fx,
	input 			blend,
	input         forced_scandoubler,
	inout  [21:0] gamma_bus
);

wire [7:0] R,G,B;
wire       CE,HS,VS,HBL,VBL;

wire VGA_HBL, VGA_VBL;
arcade_vga #(DW) vga
(
	.clk_video(clk_video),
	.ce_pix(ce_pix),

	.RGB_in(RGB_in),
	.HBlank(HBlank),
	.VBlank(VBlank),
	.HSync(HSync),
	.VSync(VSync),

	.VGA_CLK(VGA_CLK),
	.VGA_CE(CE),
	.VGA_R(R),
	.VGA_G(G),
	.VGA_B(B),
	.VGA_HS(HS),
	.VGA_VS(VS),
	.VGA_HBL(HBL),
	.VGA_VBL(VBL)
);

assign HDMI_CLK = VGA_CLK;
assign HDMI_SL  = sl[1:0];
wire [2:0] sl = fx ? fx - 1'd1 : 3'd0;
wire scandoubler = fx || forced_scandoubler;

video_mixer #(WIDTH+4, 1, GAMMA) video_mixer
(
	.clk_vid(HDMI_CLK),
	.ce_pix(CE),
	.ce_pix_out(HDMI_CE),

	.scandoubler(scandoubler),
	.hq2x(fx==1),
	.scanlines(sl),
	.blend(blend),
	.gamma_bus(gamma_bus),

	.R(R[7:4]),
	.G(G[7:4]),
	.B(B[7:4]),

	.HSync(HS),
	.VSync(VS),
	.HBlank(HBL),
	.VBlank(VBL),

	.VGA_R(video_r_s),
	.VGA_G(video_g_s),
	.VGA_B(video_b_s),
	.VGA_VS(HDMI_VS),
	.VGA_HS(HDMI_HS),
	.VGA_DE(HDMI_DE)
);

wire [7:0] video_r_s;
wire [7:0] video_g_s;
wire [7:0] video_b_s;

osd #(.OSD_COLOR(3'b001)) osd
(
	.clk_sys ( clk_video ),
	.rotate  ( osd_rotate  ),
	.ce      ( HDMI_CE ),
	.SPI_DI  ( SPI_DI  ),
	.SPI_SCK ( SPI_SCK ),
	.SPI_SS3 ( SPI_SS3 ),
	.R_in    ( video_r_s ),
	.G_in    ( video_g_s ),
	.B_in    ( video_b_s ),
	.HSync   ( HDMI_HS ),
	.VSync   ( HDMI_VS ),
	.R_out   ( HDMI_R ),
	.G_out   ( HDMI_G ),
	.B_out   ( HDMI_B )
);

assign VGA_CE = HDMI_CE;
assign VGA_R  = HDMI_R;
assign VGA_G  = HDMI_G;
assign VGA_B  = HDMI_B;
assign VGA_HS = HDMI_HS;
assign VGA_VS = HDMI_VS;
assign VGA_DE = HDMI_DE;

endmodule

//////////////////////////////////////////////////////////

module arcade_vga #(parameter DW)
(
	input          clk_video,
	input          ce_pix,

	input [DW-1:0] RGB_in,
	input          HBlank,
	input          VBlank,
	input          HSync,
	input          VSync,

	output[DW-1:0] RGB_out,
	output         VGA_CLK,
	output reg     VGA_CE,
	output  [7:0]  VGA_R,
	output  [7:0]  VGA_G,
	output  [7:0]  VGA_B,
	output reg     VGA_HS,
	output reg     VGA_VS,
	output reg     VGA_HBL,
	output reg     VGA_VBL
);

assign VGA_CLK = clk_video;

wire hs_fix,vs_fix;
sync_fix sync_v(VGA_CLK, HSync, hs_fix);
sync_fix sync_h(VGA_CLK, VSync, vs_fix);

reg [DW-1:0] RGB_fix;

always @(posedge VGA_CLK) begin
	reg old_ce;
	old_ce <= ce_pix;
	VGA_CE <= 0;
	if(~old_ce & ce_pix) begin
		VGA_CE <= 1;
		VGA_HS <= hs_fix;
		if(~VGA_HS & hs_fix) VGA_VS <= vs_fix;

		RGB_fix <= RGB_in;
		VGA_HBL <= HBlank;
		if(VGA_HBL & ~HBlank) VGA_VBL <= VBlank;
	end
end

assign RGB_out = RGB_fix;

generate
	if(DW == 6) begin
		assign VGA_R = {RGB_fix[5:4],RGB_fix[5:4],RGB_fix[5:4],RGB_fix[5:4]};
		assign VGA_G = {RGB_fix[3:2],RGB_fix[3:2],RGB_fix[3:2],RGB_fix[3:2]};
		assign VGA_B = {RGB_fix[1:0],RGB_fix[1:0],RGB_fix[1:0],RGB_fix[1:0]};
	end
	else if(DW == 8) begin
		assign VGA_R = {RGB_fix[7:5],RGB_fix[7:5],RGB_fix[7:6]};
		assign VGA_G = {RGB_fix[4:2],RGB_fix[4:2],RGB_fix[4:3]};
		assign VGA_B = {RGB_fix[1:0],RGB_fix[1:0],RGB_fix[1:0],RGB_fix[1:0]};
	end
	else if(DW == 9) begin
		assign VGA_R = {RGB_fix[8:6],RGB_fix[8:6],RGB_fix[8:7]};
		assign VGA_G = {RGB_fix[5:3],RGB_fix[5:3],RGB_fix[5:4]};
		assign VGA_B = {RGB_fix[2:0],RGB_fix[2:0],RGB_fix[2:1]};
	end
	else begin
		assign VGA_R = {RGB_fix[11:8],RGB_fix[11:8]};
		assign VGA_G = {RGB_fix[7:4],RGB_fix[7:4]};
		assign VGA_B = {RGB_fix[3:0],RGB_fix[3:0]};
	end
endgenerate

endmodule

//============================================================================
//
//  Screen +90/-90 deg. rotation
//  Copyright (C) 2017-2019 Sorgelig
//
//  This program is free software; you can redistribute it and/or modify it
//  under the terms of the GNU General Public License as published by the Free
//  Software Foundation; either version 2 of the License, or (at your option)
//  any later version.
//
//  This program is distributed in the hope that it will be useful, but WITHOUT
//  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
//  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
//  more details.
//
//  You should have received a copy of the GNU General Public License along
//  with this program; if not, write to the Free Software Foundation, Inc.,
//  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
//============================================================================

//
// Output timings are incompatible with any TV/VGA mode.
// The output is supposed to be send to scaler input.
//
module screen_rotate #(parameter WIDTH=320, HEIGHT=240, DEPTH=8, MARGIN=4, CCW=0)
(
	input              clk,
	input              ce,

	input  [DEPTH-1:0] video_in,
	input              hblank,
	input              vblank,

	input              ce_out,
	output [DEPTH-1:0] video_out,
	output reg         hsync,
	output reg         vsync,
	output reg         hblank_out,
	output reg         vblank_out
);

localparam bufsize = WIDTH*HEIGHT;
localparam memsize = bufsize*2;
localparam aw = $clog2(memsize); // resolutions up to ~ 512x256

reg [aw-1:0] addr_in, addr_out;
reg we_in;
reg buff = 0;

(* ramstyle="no_rw_check" *) reg [DEPTH-1:0] ram[memsize];
always @ (posedge clk) if (en_we) ram[addr_in] <= video_in;
always @ (posedge clk) out <= ram[addr_out];

reg [DEPTH-1:0] out; 
reg [DEPTH-1:0] vout;

assign video_out = vout;

wire en_we = ce & ~blank & en_x & en_y;
wire en_x = (xpos<WIDTH);
wire en_y = (ypos<HEIGHT);
integer xpos, ypos;

wire blank = hblank | vblank;
always @(posedge clk) begin
	reg old_blank, old_vblank;
	reg [aw-1:0] addr_row;

	if(en_we) begin
		addr_in <= CCW ? addr_in-HEIGHT[aw-1:0] : addr_in+HEIGHT[aw-1:0];
		xpos <= xpos + 1;
	end

	old_blank <= blank;
	old_vblank <= vblank;
	if(~old_blank & blank) begin
		xpos <= 0;
		ypos <= ypos + 1;
		addr_in  <= CCW ? addr_row + 1'd1 : addr_row - 1'd1;
		addr_row <= CCW ? addr_row + 1'd1 : addr_row - 1'd1;
	end

	if(~old_vblank & vblank) begin
		if(buff) begin
			addr_in  <= CCW ? bufsize[aw-1:0]-HEIGHT[aw-1:0] : HEIGHT[aw-1:0]-1'd1;
			addr_row <= CCW ? bufsize[aw-1:0]-HEIGHT[aw-1:0] : HEIGHT[aw-1:0]-1'd1;
		end else begin
			addr_in  <= CCW ? bufsize[aw-1:0]+bufsize[aw-1:0]-HEIGHT[aw-1:0] : bufsize[aw-1:0]+HEIGHT[aw-1:0]-1'd1;
			addr_row <= CCW ? bufsize[aw-1:0]+bufsize[aw-1:0]-HEIGHT[aw-1:0] : bufsize[aw-1:0]+HEIGHT[aw-1:0]-1'd1;
		end
		buff <= ~buff;
		ypos <= 0;
		xpos <= 0;
	end
end

always @(posedge clk) begin
	reg old_buff;
	reg hs;
	reg ced;

	integer vbcnt;
	integer xposo, yposo, xposd, yposd;
	
	ced <= 0;
	if(ce_out) begin
		ced <= 1;

		xposd <= xposo;
		yposd <= yposo;

		if(xposo == (HEIGHT + 8))  hsync <= 1;
		if(xposo == (HEIGHT + 10)) hsync <= 0;

		if((yposo>=MARGIN) && (yposo<WIDTH+MARGIN)) begin
			if(xposo < HEIGHT) addr_out <= addr_out + 1'd1;
		end

		xposo <= xposo + 1;
		if(xposo > (HEIGHT + 16)) begin
			xposo  <= 0;
			
			if(yposo >= (WIDTH+MARGIN+MARGIN)) begin
				vblank_out <= 1;
				vbcnt <= vbcnt + 1;
				if(vbcnt == 10	) vsync <= 1;
				if(vbcnt == 12) vsync <= 0;
			end
			else yposo <= yposo + 1;
			
			old_buff <= buff;
			if(old_buff != buff) begin
				addr_out <= buff ? {aw{1'b0}} : bufsize[aw-1:0];
				yposo <= 0;
				vsync <= 0;
				vbcnt <= 0;
				vblank_out <= 0;
			end
		end
	end
	
	if(ced) begin
		if((yposd<MARGIN) || (yposd>=WIDTH+MARGIN)) begin
			vout <= 0;
		end else begin
			vout <= out;
		end
		if(xposd == 0)       hblank_out <= 0;
		if(xposd == HEIGHT)  hblank_out <= 1;
	end
end

endmodule


module sync_fix
(
	input clk,
	
	input sync_in,
	output sync_out
);

assign sync_out = sync_in ^ pol;

reg pol;
always @(posedge clk) begin
	integer pos = 0, neg = 0, cnt = 0;
	reg s1,s2;

	s1 <= sync_in;
	s2 <= s1;

	if(~s2 & s1) neg <= cnt;
	if(s2 & ~s1) pos <= cnt;

	cnt <= cnt + 1;
	if(s2 != s1) cnt <= 0;

	pol <= pos > neg;
end

endmodule
