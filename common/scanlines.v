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
// scanlines.v
// 


module scanlines
(
    // system interface
    input            clk_sys,

    // scanlines (00-none 01-25% 10-50% 11-75%)
    input      [1:0] scanlines,
    input            ce_x2,

    // shifter video interface
    input            hs_in,
    input            vs_in,
    input      [5:0] r_in,
    input      [5:0] g_in,
    input      [5:0] b_in,

    // output interface
    output reg [5:0] r_out,
    output reg [5:0] g_out,
    output reg [5:0] b_out
);

// --------------------- create output signals -----------------
// latch everything once more to make it glitch free and apply scanline effect
reg scanline;
reg       hs_out;
reg       vs_out;

always @(posedge clk_sys) begin
    if(ce_x2) begin
        hs_out <= hs_in;
        vs_out <= vs_in;

        // reset scanlines at every new screen
        if(!vs_in) scanline <= 0;

        // toggle scanlines at begin of every hsync
        if(hs_out && !hs_in) scanline <= !scanline;

        // if no scanlines or not a scanline
        if(!scanline || !scanlines) begin
            r_out <= r_in;
            g_out <= g_in;
            b_out <= b_in;
        end else begin
            case(scanlines)
                1: begin // reduce 25% = 1/2 + 1/4
                    r_out <= {1'b0, r_in[5:1]} + {2'b00, r_in[5:2] };
                    g_out <= {1'b0, g_in[5:1]} + {2'b00, g_in[5:2] };
                    b_out <= {1'b0, b_in[5:1]} + {2'b00, b_in[5:2] };
                end

                2: begin // reduce 50% = 1/2
                    r_out <= {1'b0, r_in[5:1]};
                    g_out <= {1'b0, g_in[5:1]};
                    b_out <= {1'b0, b_in[5:1]};
                end

                3: begin // reduce 75% = 1/4
                    r_out <= {2'b00, r_in[5:2]};
                    g_out <= {2'b00, g_in[5:2]};
                    b_out <= {2'b00, b_in[5:2]};
                end
            endcase
        end
    end
end



endmodule
