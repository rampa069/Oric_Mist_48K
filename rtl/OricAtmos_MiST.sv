module OricAtmos_MiST(
   input         CLOCK_27,
   output  [5:0] VGA_R,
   output  [5:0] VGA_G,
   output  [5:0] VGA_B,
   output        VGA_HS,
   output        VGA_VS,
   output        LED,
   input         UART_RXD,
   output        UART_TXD,
   output        AUDIO_L,
   output        AUDIO_R,
   input         SPI_SCK,
   output        SPI_DO,
   input         SPI_DI,
   input         SPI_SS2,
   input         SPI_SS3,
   input         CONF_DATA0,
	output [12:0] SDRAM_A,
	inout  [15:0] SDRAM_DQ,
	output        SDRAM_DQML,
	output        SDRAM_DQMH,
	output        SDRAM_nWE,
	output        SDRAM_nCAS,
	output        SDRAM_nRAS,
	output        SDRAM_nCS,
	output  [1:0] SDRAM_BA,
	output        SDRAM_CLK,
	output        SDRAM_CKE
	);

`include "build_id.v"
localparam CONF_STR = {
	"OricAtmos;;",
	"O23,Scandoubler Fx,None,CRT 25%,CRT 50%,CRT 75%;",
	"T0,Reset;",
	"V,v1.00.",`BUILD_DATE
};
wire        clk_24;
wire        clk_72;
wire        pll_locked;
wire        key_pressed;
wire [7:0]  key_code;
wire        key_strobe;
wire        key_extended;
wire 			r, g, b; 
wire 			hs, vs;
wire  [1:0] buttons, switches;
wire			ypbpr;
wire        scandoublerD;
wire [31:0] status;
wire [15:0] audio;
//assign 		LED = 1'b0;
assign 		AUDIO_R = AUDIO_L;
//assign LED=UART_RXD;

pll pll (
	.inclk0		(CLOCK_27   ),
	.c0       (clk_24     ),
	.c1       (clk_72     ),
	.locked   (pll_locked )
	);

user_io #(
	.STRLEN				(($size(CONF_STR)>>3)))
user_io(
	.clk_sys        	(clk_24         	),
	.conf_str       	(CONF_STR       	),
	.SPI_CLK        	(SPI_SCK        	),
	.SPI_SS_IO      	(CONF_DATA0     	),
	.SPI_MISO       	(SPI_DO         	),
	.SPI_MOSI       	(SPI_DI         	),
	.buttons        	(buttons        	),
	.switches       	(switches      	),
	.scandoubler_disable (scandoublerD	),
	.ypbpr          	(ypbpr          	),
	.key_strobe     	(key_strobe     	),
	.key_pressed    	(key_pressed    	),
	.key_extended   	(key_extended   	),
	.key_code       	(key_code       	),
	.status         	(status         	)
	);
	
mist_video #(.COLOR_DEPTH(1)) mist_video(
	.clk_sys      (clk_24     ),
	.SPI_SCK      (SPI_SCK    ),
	.SPI_SS3      (SPI_SS3    ),
	.SPI_DI       (SPI_DI     ),
	.R            (r          ),
	.G            (g          ),
	.B            (b          ),
	.HSync        (hs         ),
	.VSync        (vs         ),
	.VGA_R        (VGA_R      ),
	.VGA_G        (VGA_G      ),
	.VGA_B        (VGA_B      ),
	.VGA_VS       (VGA_VS     ),
	.VGA_HS       (VGA_HS     ),
	.ce_divider   (1'b0       ),
	.scandoubler_disable(scandoublerD	),
	.scanlines    (status[4:3]),
	.ypbpr        (ypbpr      )
	);

oricatmos oricatmos(
	.clk_in         (clk_24       ),
	.RESET          (status[0] | buttons[1]),
	.key_pressed    (key_pressed  ),
	.key_code       (key_code     ),
	.key_extended   (key_extended ),
	.key_strobe     (key_strobe   ),
	.PSG_OUT				(audio				),
	.VIDEO_R				(r						),
	.VIDEO_G				(g						),
	.VIDEO_B				(b						),
	.VIDEO_HSYNC		(hs           ),
	.VIDEO_VSYNC		(vs           ),
	.K7_TAPEIN			(UART_RXD			),
	.K7_TAPEOUT			(UART_TXD			),
	.ram_ad         (ram_ad       ),
	.ram_d          (ram_d        ),
	.ram_q          (ram_cs ? ram_q : 8'd0 ),
	.ram_cs         (ram_cs_oric  ),
	.ram_oe         (ram_oe_oric  ),
	.ram_we         (ram_we       ),
	.phi2           (phi2         )
	);

reg         port1_req, port2_req;
wire [15:0] ram_ad;
wire  [7:0] ram_d;
wire  [7:0] ram_q;
wire        ram_cs_oric, ram_oe_oric, ram_we;
wire        ram_oe = ram_oe_oric;
wire        ram_cs = ram_ad[15:14] == 2'b11 ? 1'b0 : ram_cs_oric;
reg         sdram_we;
reg  [15:0] sdram_ad;
wire        phi2;

always @(posedge clk_72) begin
	reg ram_we_old, ram_oe_old;
	reg[15:0] ram_ad_old;

	ram_we_old <= ram_cs & ram_we;
	ram_oe_old <= ram_cs & ram_oe;
	ram_ad_old <= ram_ad;

	if ((ram_cs & ram_oe & ~ram_oe_old) || (ram_cs & ram_we & ~ram_we_old) || (ram_cs & ram_oe & ram_ad != ram_ad_old)) begin
		port1_req <= ~port1_req;
		sdram_ad <= ram_ad;
		sdram_we <= ram_we;
	end
end

assign      SDRAM_CLK = clk_72;
assign      SDRAM_CKE = 1;

sdram sdram(
	.*,
	.init_n        ( pll_locked     ),
	.clk           ( clk_72         ),
	.clkref        ( phi2           ),

	.port1_req     ( port1_req      ),
	.port1_ack     ( ),
	.port1_a       ( ram_ad         ),
	.port1_ds      ( ram_we ? (sdram_ad[0] ? 2'b10 : 2'b01) : 2'b11 ),
	.port1_we      ( sdram_we       ),
	.port1_d       ( {ram_d, ram_d} ),
	.port1_q       ( ram_q          ),


	// port2 is unused currently. Can be useful e.g. for TAP files
	.port2_req     ( port2_req ),
	.port2_ack     ( ),
	.port2_a       ( ),
	.port2_ds      ( ),
	.port2_we      ( ),
	.port2_d       ( ),
	.port2_q       ( )
);


dac #(
   .c_bits				(16					))
audiodac(
   .clk_i				(clk_24				),
   .res_n_i				(1						),
   .dac_i				(audio				),
   .dac_o				(AUDIO_L				)
  );


endmodule
