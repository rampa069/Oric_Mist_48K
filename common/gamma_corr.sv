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
  
*/module gamma_corr
(
	input             clk_sys,
	input             clk_vid,
	input             ce_pix,
	input             gamma_en,
	input             gamma_wr,
	input       [9:0] gamma_wr_addr,
	input       [7:0] gamma_value,
	input             HSync,
	input             VSync,
	input             HBlank,
	input             VBlank,
	input      [23:0] RGB_in,
	output reg        HSync_out,
	output reg        VSync_out,
	output reg        HBlank_out,
	output reg        VBlank_out,
	output reg [23:0] RGB_out
);

(* ramstyle="no_rw_check" *) reg [7:0] gamma_curve[768];

always @(posedge clk_sys) if (gamma_wr) gamma_curve[gamma_wr_addr] <= gamma_value;
always @(posedge clk_vid) gamma <= gamma_curve[gamma_index];

reg [9:0] gamma_index;
reg [7:0] gamma;

always @(posedge clk_vid) begin
	reg [7:0] R_in, G_in, B_in;
	reg [7:0] R_gamma, G_gamma;
	reg       hs,vs,hb,vb;
	reg [1:0] ctr = 0;

	if(ce_pix) begin
		{R_in,G_in,B_in} <= RGB_in;
		hs <= HSync; vs <= VSync;
		hb <= HBlank; vb <= VBlank;

		RGB_out  <= gamma_en ? {R_gamma,G_gamma,gamma} : {R_in,G_in,B_in};
		HSync_out <= hs; VSync_out <= vs;
		HBlank_out <= hb; VBlank_out <= vb;

		ctr <= 1;
		gamma_index <= {2'b00,RGB_in[23:16]};
	end

	if (|ctr) ctr <= ctr + 1'd1;

	case(ctr)
		1: begin                   gamma_index <= {2'b01,G_in}; end
		2: begin R_gamma <= gamma; gamma_index <= {2'b10,B_in}; end
		3: begin G_gamma <= gamma; end
	endcase
end

endmodule

module gamma_fast
(
	input             clk_vid,
	input             ce_pix,

	inout      [21:0] gamma_bus,

	input             HSync,
	input             VSync,
	input             HBlank,
	input             VBlank,
	input             DE,
	input      [23:0] RGB_in,

	output reg        HSync_out,
	output reg        VSync_out,
	output reg        HBlank_out,
	output reg        VBlank_out,
	output reg        DE_out,
	output reg [23:0] RGB_out
);

(* ramstyle="no_rw_check" *) reg [7:0] gamma_curve_r[256];
(* ramstyle="no_rw_check" *) reg [7:0] gamma_curve_g[256];
(* ramstyle="no_rw_check" *) reg [7:0] gamma_curve_b[256];

assign     gamma_bus[21] = 1;
wire       clk_sys = gamma_bus[20];
wire       gamma_en = gamma_bus[19];
wire       gamma_wr = gamma_bus[18];
wire [9:0] gamma_wr_addr = gamma_bus[17:8];
wire [7:0] gamma_value = gamma_bus[7:0];

always @(posedge clk_sys) if (gamma_wr) begin
	case(gamma_wr_addr[9:8])
		0: gamma_curve_r[gamma_wr_addr[7:0]] <= gamma_value;
		1: gamma_curve_g[gamma_wr_addr[7:0]] <= gamma_value;
		2: gamma_curve_b[gamma_wr_addr[7:0]] <= gamma_value;
	endcase
end

reg [7:0] gamma_index_r,gamma_index_g,gamma_index_b;

always @(posedge clk_vid) begin
	reg [7:0] R_in, G_in, B_in;
	reg [7:0] R_gamma, G_gamma;
	reg       hs,vs,hb,vb,de;

	if(ce_pix) begin
		{gamma_index_r,gamma_index_g,gamma_index_b} <= RGB_in;
		hs <= HSync; vs <= VSync;
		hb <= HBlank; vb <= VBlank;
		de <= DE;

		RGB_out  <= gamma_en ? {gamma_curve_r[gamma_index_r],gamma_curve_g[gamma_index_g],gamma_curve_b[gamma_index_b]}
	                        : {gamma_index_r,gamma_index_g,gamma_index_b};
		HSync_out <= hs; VSync_out <= vs;
		HBlank_out <= hb; VBlank_out <= vb;
		DE_out <= de;
	end
end

endmodule
