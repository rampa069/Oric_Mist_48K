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
	"ORICATMOS;;",
	"S0,DSK,Mount Drive A:;",
	"S1,DSK,Mount Drive B:;",
	"O3,ROM,Oric Atmos,Oric 1;",
	"O6,FDD Controller,Off,On;",
	"O7,Drive Write,Prohibit,Allow;",
	"O45,Scandoubler Fx,None,CRT 25%,CRT 50%,CRT 75%;",
	"T0,Reset;",
	"V,v1.20.",`BUILD_DATE
};
wire        clk_24;
wire        clk_72;
wire        clk_32;
wire        pll_locked;

wire 			r, g, b; 
wire 			hs, vs;

wire  [1:0] buttons, switches;
wire			ypbpr;
wire        scandoublerD;
wire [31:0] status;
wire [15:0] audio;
wire [7:0] joystick_0;
wire [7:0] joystick_1;

wire [10:0]ps2_key;
wire 		  ps2_kbd_clk, ps2_kbd_data;

wire       tapebits;
wire 		  remote;
wire       reset;

wire [1:0] fdc_A;
wire       fdc_nCS;
wire       fdc_nRE;
wire       fdc_nWE;
wire       fdc_CLK;
wire [7:0] fdc_DALin;
wire [7:0] fdc_DALout;
wire       fdc_sel;
wire       fdc_DRQ;
wire       fdc_IRQ;

wire [1:0] cont_DSEL;
wire       cont_SSEL;

//assign 		LED = 1'b0;
assign 		AUDIO_R = AUDIO_L;
assign      rom = ~status[3] ;
//assign      LED=!remote;
assign      LED = fdc_IRQ;
assign      disk_enable = ~status[6];
assign      reset = (status[0] | buttons[1] | rom_changed);

pll pll (
	.inclk0	 (CLOCK_27   ),
	.c0       (clk_24     ),
	.c1       (clk_72     ),
	.c2       (clk_32     ),
	.locked   (pll_locked )
	);



mist_io #(.STRLEN($size(CONF_STR)>>3)) user_io
(
	.*,
	.clk_sys        	(clk_24         	),
	.scandoubler_disable (scandoublerD	),	
   
	.conf_str(CONF_STR),
	
	.sd_conf(0),
	.sd_sdhc(1),
	.ioctl_ce(1),

	// unused
	.ps2_mouse_clk(),
	.ps2_mouse_data(),
	.ps2_mouse(),
	.joystick_analog_0(),
	.joystick_analog_1(),
	.sd_ack_conf()
);	

reg init_reset = 1;
always @(posedge clk_24) begin
	reg old_download;
	old_download <= ioctl_download;
	if(~ioctl_download & old_download & !ioctl_index) init_reset <= 0;
end
	
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
	.clk_microdisc    (clk_32       ),
	.RESET            (status[0] | buttons[1] | rom_changed),
	.ps2_key          (ps2_key     ),
	.PSG_OUT				(audio		),
	.VIDEO_R				(r			   ),
	.VIDEO_G				(g				),
	.VIDEO_B				(b				),
	.VIDEO_HSYNC		(hs         ),
	.VIDEO_VSYNC		(vs         ),
	.K7_TAPEIN			(UART_RXD   ),
	.K7_TAPEOUT			(UART_TXD   ),
	.K7_REMOTE			(remote     ),
	.rom			      (rom),
	.ram_ad           (ram_ad       ),
	.ram_d            (ram_d        ),
	.ram_q            (ram_cs ? ram_q : 8'd0 ),
	.ram_cs           (ram_cs_oric  ),
	.ram_oe           (ram_oe_oric  ),
	.ram_we           (ram_we       ),
	.joystick_0       ( joystick_0      ),
	.joystick_1       ( joystick_1      ),
	.phi2             (phi2         ),
	.pll_locked       (pll_locked),
	.disk_enable      (disk_enable),
	.fdc_A             (fdc_A),
   .fdc_nCS				 (fdc_nCS),
	.fdc_nRE				 (fdc_nRE),
	.fdc_nWE           (fdc_nWE),
	.fdc_CLK           (fdc_CLK),
	.fdc_DRQ           (fdc_DRQ),
	.fdc_IRQ           (fdc_IRQ),
	.fdc_DALin         (fdc_DALin),
	.fdc_DALout        (fdc_DALout),
	.fdc_sel           (fdc_sel),
	.cont_DSEL         (cont_DSEL),
	.cont_SSEL         (cont_SSEL)
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
wire        rom;
wire        old_rom;
wire        rom_changed;
wire        disk_enable;



always @(posedge clk_72) begin
	reg ram_we_old, ram_oe_old;
	reg[15:0] ram_ad_old;

	ram_we_old <= ram_cs & ram_we;
	ram_oe_old <= ram_cs & ram_oe;
	ram_ad_old <= ram_ad;
	old_rom <= rom;
	rom_changed <= 1'b0;

	if ((ram_cs & ram_oe & ~ram_oe_old) || (ram_cs & ram_we & ~ram_we_old) || (ram_cs & ram_oe & ram_ad != ram_ad_old)) begin
		port1_req <= ~port1_req;
		sdram_ad <= ram_ad;
		sdram_we <= ram_we;
	end
	
	if (rom != old_rom) begin
	  rom_changed <= 1'b1;
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



  
  ///////////////////   FDC   ///////////////////
wire [31:0] sd_lba;
wire  [1:0] sd_rd;
wire  [1:0] sd_wr;
wire        sd_ack;
wire  [8:0] sd_buff_addr;
wire  [7:0] sd_buff_dout;
wire  [7:0] sd_buff_din;
wire        sd_buff_wr;
wire  [1:0] img_mounted;
wire [31:0] img_size;

wire        ioctl_wr;
wire [24:0] ioctl_addr;
wire  [7:0] ioctl_dout;
wire        ioctl_download;
wire  [7:0] ioctl_index;

//wire       fdc_sel  = &cpu_ad[7:5] & ~cpu_ad[3]; // 224-231(E0-E7), 240-247(F0-F7)
//wire       fdc_sel = '&cpu_ad[7:4] & ~cpu_ad[3:2];

always @(posedge clk_24) begin
	if(sd_rd[1]|sd_wr[1]) cont_DSEL <= 1;
	if(sd_rd[0]|sd_wr[0]) cont_DSEL <= 0;
end

//assign sd_buff_din = fdd_num ? fdd2_buf_dout : fdd1_buf_dout;
//assign sd_lba      = fdd_num ? fdd2_lba      : fdd1_lba;

assign sd_buff_din = fdd1_buf_dout;
assign sd_lba      = fdd1_lba;


// FDD1
wire        fdd1_busy;
reg         fdd1_ready;
wire        fdd1_io   = fdc_sel;// & ~fdc_IRQ ;//& nM1;
wire        fdd1_side;

//wire  [7:0] fdd1_dout;
wire  [7:0] fdd1_buf_dout;
wire [31:0] fdd1_lba;

always @(posedge clk_24) begin
	reg old_wr;
	reg old_mounted;

	old_wr <= fdc_nWE;
	if(old_wr & ~fdc_nWE & fdd1_io)  fdd1_side <= cont_SSEL;

	old_mounted <= img_mounted[0];
	if(reset) fdd1_ready <= 0;
		else if(~old_mounted & img_mounted[0]) fdd1_ready <= 1;
end

wd1793 #(1) fdd1
(
	.clk_sys(clk_24),
	.ce(fdc_CLK),
	.reset(reset),
	.io_en(fdd1_io & fdd1_ready),
	.rd(fdc_nRE),
	.wr(fdc_nWE),
	.addr(fdc_A),
	.din(fdc_DALin),
	.dout(fdc_DALout),
	
	.intrq(fdc_IRQ),
	.drq(fdc_DRQ),

	.img_mounted(img_mounted[0]),
	.img_size(img_size[19:0]),
	.sd_lba(fdd1_lba),
	.sd_rd(sd_rd[0]),
	.sd_wr(sd_wr[0]),
	.sd_ack(sd_ack),
	.sd_buff_addr(sd_buff_addr),
	.sd_buff_dout(sd_buff_dout),
	.sd_buff_din(fdd1_buf_dout),
	.sd_buff_wr(sd_buff_wr),

	.wp(~status[7]),

	.size_code(4),
	.layout(ioctl_index[7:6] == 2),
	.side(fdd1_side),
	.ready(fdd1_ready),
	.prepare(fdd1_busy),

	.input_active(0),
	.input_addr(0),
	.input_data(0),
	.input_wr(0),
	.buff_din(0)
);


//// FDD2
//reg         fdd2_ready;
//reg         fdd2_side;
//wire        fdd2_io   = fdc_sel & cpu_ad[4] & ~fdc_IRQ ;//& nM1;
//wire  [7:0] fdd2_dout;
//wire  [7:0] fdd2_buf_dout;
//wire [31:0] fdd2_lba;
//
//always @(posedge clk_24) begin
//	reg old_wr;
//	reg old_mounted;
//
//	old_wr <= fdc_nWE;
//	if(old_wr & ~fdc_nWE & fdd2_io) fdd2_side <= fdc_A[1];
//
//	old_mounted <= img_mounted[1];
//	if(reset) fdd2_ready <= 0;
//		else if(~old_mounted & img_mounted[1]) fdd2_ready <= 1;
//end
//
//wd1793 #(1) fdd2
//(
//	.clk_sys(clk_24),
//	.ce(fdc_nCS),
//	.reset(reset),
//	.io_en(fdd2_io & fdd2_ready),
//	.rd(~fdc_nRE),
//	.wr(~fdc_nWE),
//	.addr(fdc_A[1:0]),
//	.din(fdc_DALin),
//	.dout(fdc_DALout),
//
//	.img_mounted(img_mounted[1]),
//	.img_size(img_size[19:0]),
//	.sd_lba(fdd2_lba),
//	.sd_rd(sd_rd[1]),
//	.sd_wr(sd_wr[1]),
//	.sd_ack(sd_ack),
//	.sd_buff_addr(sd_buff_addr),
//	.sd_buff_dout(sd_buff_dout),
//	.sd_buff_din(fdd2_buf_dout),
//	.sd_buff_wr(sd_buff_wr),
//
//	.wp(~status[4]),
//
//	.size_code(4),
//	.layout(ioctl_index[7:6] == 2),
//	.side(fdd2_side),
//	.ready(fdd2_ready),
//
//	.input_active(0),
//	.input_addr(0),
//	.input_data(0),
//	.input_wr(0),
//	.buff_din(0)
//);


endmodule
