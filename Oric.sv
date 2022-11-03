module Oric(
   input         CLOCK_27,
	
   output  [5:0] VGA_R,
   output  [5:0] VGA_G,
   output  [5:0] VGA_B,
   output        VGA_HS,
   output        VGA_VS,
   output        LED,
	
   input         TAPE_IN,
	
   input         UART_RX,
   output        UART_TX,
	
   output        AUDIO_L,
   output        AUDIO_R,
	
   output [15:0] DAC_L,
   output [15:0] DAC_R,
	
   input         SPI_SCK,
   output        SPI_DO,
   input         SPI_DI,
   input         SPI_SS2,
   input         SPI_SS3,
   //input         SPI_SS4,
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
	"ORIC;ROM;",
	"S0U,DSK,Mount Drive A:;",
	"F,TAP,Load;",
	"T1,Tape Play/Stop;",
	"O2,Tape Sounds,Off,On;",
	"O3,ROM,Oric Atmos,Oric 1;",
	"O6,FDD Controller,Off,On;",
	"O7,Drive Write,Allow,Prohibit;",
	"O45,Scandoubler Fx,None,CRT 25%,CRT 50%,CRT 75%;",
	"O89,Stereo,Off,ABC (West Europe),ACB (East Europe);",
	"T0,Reset;",
  	"V,v2.2-EDSK.",`BUILD_DATE
};
wire        clk_72;
wire        clk_24;
wire        pll_locked;

wire        key_pressed;
wire [7:0]  key_code;
wire        key_strobe;
wire        key_extended;
wire        r, g, b; 
wire        hs, vs;

wire  [1:0] buttons, switches;
wire			ypbpr;
wire        scandoublerD;
wire [31:0] status;

wire [13:0]  psg_out;
wire [11:0]  psg_a;
wire [11:0]  psg_b;
wire [11:0]  psg_c;

wire [7:0]  joystick_0;
wire [7:0]  joystick_1;

wire        tapebits;
wire        remote;
reg         reset;

wire        rom;
wire        old_rom;

wire        led_value;
reg         fdd_ready=0;
wire        fdd_led;
reg         fdd_layout = 0;

wire        disk_enable;
reg         old_disk_enable;

assign      disk_enable = status[6];
assign      rom = ~status[3] ;
wire [1:0]  stereo = status[9:8];
wire        tap_play = status[1];
wire        tap_sound = status[2];

assign      LED = ~fdd_led & ~ioctl_downl; // negative active

always @(posedge clk_24) begin
	old_rom <= rom;
	old_disk_enable <= disk_enable;
	reset <= (!pll_locked | status[0] | buttons[1] | old_rom != rom | old_disk_enable != disk_enable | rom_downl);
end

pll pll (
	.inclk0	 (CLOCK_27   ),
	.c0       (clk_24     ),
	.c1       (clk_72     ),
	.locked   (pll_locked )
	);
	
user_io #(
	.STRLEN				(($size(CONF_STR)>>3)))
user_io(
	.clk_sys        	(clk_24         	),
	.clk_sd           (clk_24           ),
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
	
mist_video #(.COLOR_DEPTH(1), .SD_HCNT_WIDTH(10)) mist_video(
	.clk_sys      (clk_24     ),
	.SPI_SCK      (SPI_SCK    ),
	.SPI_SS3      (SPI_SS3    ),
	.SPI_DI       (SPI_DI     ),
	.R            (r | progress ),
	.G            (g | progress ),
	.B            (b | progress ),
	.HSync        (hs         ),
	.VSync        (vs         ),
	.VGA_R        (VGA_R      ),
	.VGA_G        (VGA_G      ),
	.VGA_B        (VGA_B      ),
	.VGA_VS       (VGA_VS     ),
	.VGA_HS       (VGA_HS     ),
	.ce_divider   (1'b0       ),
	.scandoubler_disable(scandoublerD	),
	.scanlines    (status[5:4]),
	.ypbpr        (ypbpr      )
	);

oricatmos oricatmos(
	.clk_in           (clk_24       ),
	.RESET            (reset),
	.key_pressed      (key_pressed  ),
	.key_code         (key_code     ),
	.key_extended     (key_extended ),
	.key_strobe       (key_strobe   ),
	.PSG_OUT	  (psg_out      ),
	.PSG_OUT_A	  (psg_a	),
	.PSG_OUT_B	  (psg_b	),
	.PSG_OUT_C	  (psg_c	),
	.VIDEO_R	  (r	        ),
	.VIDEO_G	  (g		),
	.VIDEO_B	  (b		),
	.VIDEO_HSYNC	  (hs           ),
	.VIDEO_VSYNC	  (vs           ),
	.K7_TAPEIN        (tap_running ? tap_out : TAPE_IN),
	.K7_TAPEOUT       (tap_in       ),
	.K7_REMOTE        (remote       ),
	.ram_ad           (ram_ad       ),
	.ram_d            (ram_d        ),
	.ram_q            (ram_cs ? ram_q : 8'd0 ),
	.ram_cs           (ram_cs_oric  ),
	.ram_oe           (ram_oe_oric  ),
	.ram_we           (ram_we       ),
	.rom_ad           (rom_ad       ),
	.rom_q            (ram_q        ),
	.rom_cs           (rom_cs       ),
	.rom_ext_cs       (rom_ext_cs   ),
	.joystick_0       (joystick_0   ),
	.joystick_1       (joystick_1   ),
	.fd_led           (fdd_led      ),
	.fdd_ready        (fdd_ready    ),
	.fdd_layout       (fdd_layout   ),
	.phi2             (phi2         ),
	.pll_locked       (pll_locked   ),
	.disk_enable      (disk_enable  ),
	.rom	          (rom          ),
	.img_mounted    ( img_mounted   ), // signaling that new image has been mounted
	.img_size       ( img_size      ), // size of image in bytes
	.img_wp         ( status[7]     ), // write protect
        .sd_lba         ( sd_lba        ),
	.sd_rd          ( sd_rd         ),
	.sd_wr          ( sd_wr         ),
	.sd_ack         ( sd_ack        ),
	.sd_buff_addr   ( sd_buff_addr  ),
	.sd_dout        ( sd_dout       ),
	.sd_din         ( sd_din        ),
	.sd_dout_strobe ( sd_dout_strobe),
	.sd_din_strobe  ( sd_din_strobe )
	
);

wire        ioctl_downl;
wire  [7:0] ioctl_index;
wire        ioctl_wr;
wire [24:0] ioctl_addr;
wire  [7:0] ioctl_dout;

wire        rom_downl = ioctl_downl & (ioctl_index == 0 || ioctl_index == 1);
wire        tap_downl = ioctl_downl & ioctl_index == 3;

data_io data_io(
	.clk_sys       ( clk_72      ),
	.SPI_SCK       ( SPI_SCK      ),
	.SPI_SS2       ( SPI_SS2      ),
	.SPI_DI        ( SPI_DI       ),
	.clkref_n      ( 1'b0         ),
	.ioctl_download( ioctl_downl  ),
	.ioctl_index   ( ioctl_index  ),
	.ioctl_wr      ( ioctl_wr     ),
	.ioctl_addr    ( ioctl_addr   ),
	.ioctl_dout    ( ioctl_dout   )
);

reg         sdram_we;
reg  [16:0] sdram_ad;
reg   [7:0] sdram_din;
wire [15:0] sdram_dout;
wire        phi2;

reg         port1_req, port2_req;
wire        port2_ack;
wire [15:0] ram_ad;
wire  [7:0] ram_d;
wire  [7:0] ram_q = sdram_ad[0] ? sdram_dout[15:8] : sdram_dout[7:0];
wire        ram_cs_oric, ram_oe_oric, ram_we;
wire        ram_oe = ram_oe_oric;
wire        ram_cs = ram_cs_oric ;

wire [15:0] rom_ad;
wire        rom_cs;
wire        rom_ext_cs;

// 0000-7FFF - Oric-1 / Atmos
// 8000-9FFF - Microdisk
wire [15:0] rom_sd_addr = rom_cs ? {rom, rom_ad[13:0]} : // Oric-1 or Atmos
                          {3'b100, rom_ad[12:0]}; // Microdisk

always @(posedge clk_72) begin
	reg ram_we_old, ram_oe_old;
	reg[15:0] ram_ad_old;

	reg rom_cs_old, rom_ext_cs_old;
	reg[15:0] rom_ad_old;

	ram_we_old <= ram_cs & ram_we;
	ram_oe_old <= ram_cs & ram_oe;
	ram_ad_old <= ram_ad;

	rom_cs_old <= rom_cs;
	rom_ext_cs_old <= rom_ext_cs;
	rom_ad_old <= rom_ad;

	if (rom_downl) begin
		// ROM download
		if (ioctl_wr) begin
			port1_req <= ~port1_req;
			sdram_ad <= ioctl_addr[16:0];
			sdram_we <= 1;
			sdram_din <= ioctl_dout;
		end
	end else begin
		if ((ram_cs & ram_oe & ~ram_oe_old) || (ram_cs & ram_we & ~ram_we_old) || (ram_cs & ram_oe & ram_ad != ram_ad_old)) begin
			port1_req <= ~port1_req;
			sdram_ad <= {1'b1, ram_ad};
			sdram_we <= ram_we;
			sdram_din <= ram_d;
		end

		if ((rom_cs & ~rom_cs_old) || (rom_ext_cs & ~rom_ext_cs_old) || ((rom_cs | rom_ext_cs ) & rom_ad != rom_ad_old)) begin
			port1_req <= ~port1_req;
			sdram_we <= 0;
			sdram_ad <= rom_sd_addr;
		end
	end
end

reg         tap_we;
wire [23:0] tap_ad;
reg  [23:0] tap_last = 0;
wire [15:0] tap_dout;
wire        tap_in;
wire        tap_out;
wire        tap_req;
reg         tap_ack;
reg         tap_state;
wire        tap_running;

always @(posedge clk_72) begin
	if (tap_downl) begin
		// TAP download
		tap_state <= 0;
		if (ioctl_wr) begin
			port2_req <= ~port2_req;
			tap_last <= ioctl_addr[23:0];
			tap_we <= 1;
		end
	end else begin
		tap_we <= 0;
		if (tap_req ^ tap_ack && port2_req == port2_ack) begin
			if (!tap_state) begin
				if (tap_ad <= tap_last) begin
					port2_req <= ~port2_req;
					tap_state <= 1;
				end
			end else begin
				tap_ack <= tap_req;
				tap_state <= 0;
			end
		end
	end
end

reg   [4:0] tap_ce_cnt;
reg         tap_ce;
always @(posedge clk_24) begin
	tap_ce_cnt <= tap_ce_cnt + 1'd1;
	tap_ce <= 0;
	if (tap_ce_cnt == 23) begin
		tap_ce_cnt <= 0;
		tap_ce <= 1;
	end
end

Oric_tap_player tap_player (
	.clk(clk_24),
	.ce(tap_ce),
	.reset(tap_downl),
	.motor_on(remote),
	.playstop(tap_play),
	.byte_req(tap_req),
	.byte_ack(tap_ack),
	.byte_addr(tap_ad),
	.byte_in(tap_ad[0] ? tap_dout[15:8] : tap_dout[7:0]),
	.running(tap_running),
	.tape_out(tap_out)
);

wire progress;

progressbar #(.X_OFFSET(66), .Y_OFFSET(36)) progressbar (
	.clk(clk_24),
	.ce_pix(tap_ce_cnt[1:0] == 0),
	.hblank(~hs),
	.vblank(~vs),
	.enable(tap_running),
	.current(tap_ad),
	.max(tap_last),
	.pix(progress)
);

assign      SDRAM_CLK = clk_72;
assign      SDRAM_CKE = 1;

sdram #(72) sdram(
	.*,
	.init_n        ( pll_locked     ),
	.clk           ( clk_72         ),
	.clkref        ( phi2           ),

	.port1_req     ( port1_req      ),
	.port1_ack     ( ),
	.port1_a       ( sdram_ad[16:1] ),
	.port1_ds      ( sdram_we ? (sdram_ad[0] ? 2'b10 : 2'b01) : 2'b11 ),
	.port1_we      ( sdram_we       ),
	.port1_d       ( {sdram_din, sdram_din} ),
	.port1_q       ( sdram_dout     ),
	// port2 is for TAP playback
	.port2_req     ( port2_req ),
	.port2_ack     ( port2_ack ),
	.port2_a       ( tap_we ? ioctl_addr[23:1] : tap_ad[23:1] ),
	.port2_ds      ( tap_we ? (ioctl_addr[0] ? 2'b10 : 2'b01) : 2'b11 ),
	.port2_we      ( tap_we    ),
	.port2_d       ( {ioctl_dout, ioctl_dout} ),
	.port2_q       ( tap_dout  )
);

///////////////////////////////////////////////////

wire [15:0] psg_l;
wire [15:0] psg_r;

always @ (psg_a,psg_b,psg_c,psg_out,stereo) begin
                case (stereo)
			2'b01  : {psg_l,psg_r} <= {{{2'b0,psg_a} + {2'b0,psg_b}},2'b0,{{2'b0,psg_c} + {2'b0,psg_b}},2'b0};
			2'b10  : {psg_l,psg_r} <= {{{2'b0,psg_a} + {2'b0,psg_c}},2'b0,{{2'b0,psg_c} + {2'b0,psg_b}},2'b0};
			default: {psg_l,psg_r} <= {psg_out,2'b0,psg_out,2'b0};

                endcase
end

wire [15:0] dac_in_l = psg_l + { tap_sound & (tap_running ? tap_out : TAPE_IN), tap_sound & tap_in, 9'd0 };
wire [15:0] dac_in_r = psg_r + { tap_sound & (tap_running ? tap_out : TAPE_IN), tap_sound & tap_in, 9'd0 };

dac #(
   .c_bits	(16))
audiodac_l(
   .clk_i	(clk_24	),
   .res_n_i	(1	),
   .dac_i	(dac_in_l),
   .dac_o	(AUDIO_L)
  );

dac #(
   .c_bits	(16))
audiodac_r(
   .clk_i	(clk_24	),
   .res_n_i	(1	),
   .dac_i	(dac_in_r),
   .dac_o	(AUDIO_R)
  );

assign DAC_L =  psg_l;
assign DAC_R =  psg_r;
 
assign UART_TX = tap_in;
  
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

always @(posedge clk_24) begin
	reg old_mounted;

	old_mounted <= img_mounted;
	if(~old_mounted & img_mounted) begin
		fdd_ready <= |img_size;
	end
end

endmodule
