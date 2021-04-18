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
  
*/// Composite-like horizontal blending by Kitrinx

module cofi (
    input wire       clk,
    input wire       pix_ce,
    input wire       enable,

    input wire       hblank,
    input wire       vblank,
    input wire       hs,
    input wire       vs,
    input wire [5:0] red,
    input wire [5:0] green,
    input wire [5:0] blue,

    output reg       hblank_out,
    output reg       vblank_out,
    output reg       hs_out,
    output reg       vs_out,
    output reg [5:0] red_out,
    output reg [5:0] green_out,
    output reg [5:0] blue_out
);

    function  [5:0] color_blend (
        input [5:0] color_prev,
        input [5:0] color_curr,
        input blank_last
    );
    begin
        color_blend = blank_last ? color_curr : (color_prev >> 1) + (color_curr >> 1);
    end
    endfunction

reg [5:0] red_last;
reg [5:0] green_last;
reg [5:0] blue_last;

wire      ce = enable ? pix_ce : 1'b1;
always @(posedge clk) if (ce) begin
    hblank_out <= hblank;
    vblank_out <= vblank;
    vs_out     <= vs;
    hs_out     <= hs;

    red_last   <= red;
    blue_last  <= blue;
    green_last <= green;

    red_out    <= enable ? color_blend(red_last,   red,   hblank_out) : red;
    blue_out   <= enable ? color_blend(blue_last,  blue,  hblank_out) : blue;
    green_out  <= enable ? color_blend(green_last, green, hblank_out) : green;
end

endmodule
