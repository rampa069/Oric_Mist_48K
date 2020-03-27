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
	input         SPI_SS4,
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
	"ORIC;;",
	"S0,IMG,Mount Drive A:;",
	"O3,ROM,Oric Atmos,Oric 1;",
	"O6,FDD Controller,Off,On;",
	"O7,Drive Write,Allow,Prohibit;",
	"O45,Scandoubler Fx,None,CRT 25%,CRT 50%,CRT 75%;",
	"O8,Stereo MOD,Off,On;",
	"T0,Reset;",
  	"V,v2.0.",`BUILD_DATE
};
wire        clk_72;
wire        clk_32;
wire        clk_24;
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

wire [9:0] psg_l;
wire [9:0] psg_r;

wire [7:0] joystick_0;
wire [7:0] joystick_1;



wire       tapebits;
wire 		  remote;
wire       reset;

wire        rom;
wire        old_rom;
wire        rom_changed;

wire        led_value;
reg         fdd_ready=0;
wire        fdd_busy;
reg         fdd_layout;
reg         fdd_reset = 0;


//assign 		AUDIO_R = AUDIO_L;
assign      disk_enable = ~status[6];
assign      reset = (!pll_locked | status[0] | buttons[1] | rom_changed);
assign      rom = ~status[3] ;
assign      stereo = status[8];

assign      LED = fdd_ready;




pll pll (
	.inclk0	 (CLOCK_27   ),
	.c0       (clk_24     ),
	.c1       (clk_72     ),
	.c2       (clk_32     ),
	.locked   (pll_locked )
	);





	
user_io #(
	.STRLEN				(($size(CONF_STR)>>3)))
user_io(
	.clk_sys        	(clk_24         	),
	.clk_sd           (clk_32           ),
	.conf_str       	(CONF_STR       	),
	.SPI_CLK        	(SPI_SCK        	),
	.SPI_SS_IO      	(CONF_DATA0     	),
	.SPI_MISO       	(SPI_DO        	),
	.SPI_MOSI       	(SPI_DI         	),
	.buttons        	(buttons        	),
	.switches       	(switches      	),
	.scandoubler_disable (scandoublerD	),
	.ypbpr          	(ypbpr          	),
	.key_strobe     	(key_strobe     	),
	.key_pressed    	(key_pressed    	),
	.key_extended   	(key_extended   	),
	.key_code       	(key_code       	),
	.joystick_0       ( joystick_0      ),
	.joystick_1       ( joystick_1      ),
	.status         	(status         	),
	// SD CARD
   .sd_lba                      (sd_lba        ),
	.sd_rd                       (sd_rd         ),
	.sd_wr                       (sd_wr         ),
	.sd_ack                      (sd_ack        ),
	.sd_ack_conf                 (sd_ack_conf   ),
	.sd_conf                     (sd_conf       ),
	.sd_sdhc                     (sd_sdhc       ),
	.sd_dout                     (sd_dout       ),
	.sd_dout_strobe              (sd_dout_strobe),
	.sd_din                      (sd_din        ),
	.sd_din_strobe               (sd_din_strobe ),
	.sd_buff_addr                (sd_buff_addr  ),
	.img_mounted                 (img_mounted   ),
	.img_size                    (img_size      )
);


	
mist_video #(.COLOR_DEPTH(1)) mist_video(
	.clk_sys      (clk_24     ),
	.SPI_SCK      (SPI_SCK    ),
	.SPI_SS3      (SPI_SS3    ),
	.SPI_DI       (SPI_DI     ),
	.R            ({r}    ),
	.G            ({g}    ),
	.B            ({b}    ),
	.HSync        (hs         ),
	.VSync        (vs         ),
	.VGA_R        (VGA_R      ),
	.VGA_G        (VGA_G      ),
	.VGA_B        (VGA_B      ),
	.VGA_VS       (VGA_VS     ),
	.VGA_HS       (VGA_HS     ),
	.ce_divider   (1'b0       ),
	.scandoubler_disable(scandoublerD	),
	.scanlines			(scandoublerD ? 2'b00 : status[5:4]),
	.ypbpr        (ypbpr      )
	);

oricatmos oricatmos(
	.clk_in           (clk_24       ),
	.clk_32           (clk_32       ),
	.RESET            (reset),
	.key_pressed      (key_pressed  ),
	.key_code         (key_code     ),
	.key_extended     (key_extended ),
	.key_strobe       (key_strobe   ),
	.PSG_OUT_L			(psg_l		),
	.PSG_OUT_R			(psg_r		),
	.STEREO           (stereo  ),
	.VIDEO_R				(r			   ),
	.VIDEO_G				(g				),
	.VIDEO_B				(b				),
	.VIDEO_HSYNC		(hs         ),
	.VIDEO_VSYNC		(vs         ),
	.K7_TAPEIN			(UART_RXD   ),
	.K7_TAPEOUT			(UART_TXD   ),
	.K7_REMOTE			(remote     ),
	.ram_ad           (ram_ad       ),
	.ram_d            (ram_d        ),
	.ram_q            (ram_cs ? ram_q : 8'd0 ),
	.ram_cs           (ram_cs_oric  ),
	.ram_oe           (ram_oe_oric  ),
	.ram_we           (ram_we       ),
	.joystick_0       ( joystick_0      ),
	.joystick_1       ( joystick_1      ),
	.fd_led           (led_value),
	.fdd_ready        (fdd_ready    ),
	.fdd_busy         (fdd_busy     ),
	.fdd_reset        (fdd_reset    ),
	.fdd_layout       (fdd_layout   ),
	.phi2             (phi2         ),
	.pll_locked       (pll_locked),
	.disk_enable      (disk_enable),
	.rom			      (rom),
	.img_mounted    ( img_mounted      ), // signaling that new image has been mounted
	.img_size       ( img_size         ), // size of image in bytes
	.img_wp         ( status[7]        ), // write protect
   .sd_lba         ( sd_lba           ),
	.sd_rd          ( sd_rd            ),
	.sd_wr          ( sd_wr            ),
	.sd_ack         ( sd_ack           ),
	.sd_buff_addr   ( sd_buff_addr     ),
	.sd_dout        ( sd_dout     ),
	.sd_din         ( sd_din      ),
	.sd_dout_strobe ( sd_dout_strobe   ),
	.sd_din_strobe  ( sd_din_strobe    )
	
);

reg         port1_req, port2_req;
wire [15:0] ram_ad;
wire  [7:0] ram_d;
wire  [7:0] ram_q;
wire        ram_cs_oric, ram_oe_oric, ram_we;
wire        ram_oe = ram_oe_oric;
wire        ram_cs = ram_cs_oric ;
reg         sdram_we;
reg  [15:0] sdram_ad;
wire        phi2;
wire        disk_enable;



always @(posedge clk_72) begin
	reg ram_we_old, ram_oe_old;
	reg[15:0] ram_ad_old;

	ram_we_old <= ram_cs & ram_we;
	ram_oe_old <= ram_cs & ram_oe;
	ram_ad_old <= ram_ad;

	old_rom <= rom;
	rom_changed <= 1'b0;
	
	if (rom != old_rom) begin
	  rom_changed <= 1'b1;
	end

	if ((ram_cs & ram_oe & ~ram_oe_old) || (ram_cs & ram_we & ~ram_we_old) || (ram_cs & ram_oe & ram_ad != ram_ad_old)) begin
		port1_req <= ~port1_req;
		port2_req <= ~port2_req;
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
		// port2 is wired to the FDC controller
	.port2_req     ( port2_req ),
	.port2_ack     ( ),
	.port2_a       ( ),
	.port2_ds      ( ),
	.port2_we      ( ),
	.port2_d       ( ),
	.port2_q       ( )

);


dac #(
   .c_bits				(11					))
audiodac_l(
   .clk_i				(clk_32				),
   .res_n_i				(1						),
   .dac_i				(psg_l				),
   .dac_o				(AUDIO_L				)
  );

dac #(
   .c_bits				(11				))
audiodac_r(
   .clk_i				(clk_32				),
   .res_n_i				(1						),
   .dac_i				(psg_r				),
   .dac_o				(AUDIO_R				)
  );
  ///////////////////   FDC   ///////////////////
wire [31:0] sd_lba;
wire        sd_rd;
wire        sd_wr;
wire        sd_ack;
wire        sd_ack_conf;
wire        sd_conf;
wire        sd_sdhc = 1'b1;
wire  [8:0] sd_buff_addr;
wire  [7:0] sd_dout;
wire  [7:0] sd_din;
wire        sd_buff_wr;
wire        img_mounted;
wire [31:0] img_size;
wire        sd_dout_strobe;
wire        sd_din_strobe;


wire        ioctl_wr;
wire [24:0] ioctl_addr;
wire  [7:0] ioctl_dout;
wire        ioctl_download;
wire  [7:0] ioctl_index;


assign fdd_reset =  status[1];
	
always @(posedge clk_32) begin
	reg old_mounted;

	old_mounted <= img_mounted;
	if(reset) begin 
          fdd_ready <= 0;
      end   

	else if(~old_mounted & img_mounted) begin
	     fdd_ready <= 1;
		  fdd_layout <= (ioctl_index[7:6] == 2);
   end
end


endmodule
