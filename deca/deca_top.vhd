LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

-- -----------------------------------------------------------------------

ENTITY deca_top IS
	PORT (
		ADC_CLK_10 : IN STD_LOGIC;
		MAX10_CLK1_50 : IN STD_LOGIC;
		MAX10_CLK2_50 : IN STD_LOGIC;
		KEY : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		DRAM_CLK : OUT STD_LOGIC;
		DRAM_CKE : OUT STD_LOGIC;
		DRAM_ADDR : OUT STD_LOGIC_VECTOR(12 DOWNTO 0);
		DRAM_BA : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		DRAM_DQ : INOUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		DRAM_LDQM : OUT STD_LOGIC;
		DRAM_UDQM : OUT STD_LOGIC;
		DRAM_CS_N : OUT STD_LOGIC;
		DRAM_WE_N : OUT STD_LOGIC;
		DRAM_CAS_N : OUT STD_LOGIC;
		DRAM_RAS_N : OUT STD_LOGIC;
		VGA_HS : OUT STD_LOGIC;
		VGA_VS : OUT STD_LOGIC;
		VGA_R : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
		VGA_G : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
		VGA_B : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
		-- AUDIO
		SIGMA_R : OUT STD_LOGIC;
		SIGMA_L : OUT STD_LOGIC;
		-- PS2
		PS2_KEYBOARD_CLK : INOUT STD_LOGIC;
		PS2_KEYBOARD_DAT : INOUT STD_LOGIC;
		PS2_MOUSE_CLK : INOUT STD_LOGIC;
		PS2_MOUSE_DAT : INOUT STD_LOGIC;
		-- UART
		UART_RXD : IN STD_LOGIC;
		UART_TXD : OUT STD_LOGIC;
		-- SD Card
		sd_cs_n_o : OUT STD_LOGIC := '1';
		sd_sclk_o : OUT STD_LOGIC := '0';
		sd_mosi_o : OUT STD_LOGIC := '0';
		sd_miso_i : IN STD_LOGIC;
		SD_SEL : OUT STD_LOGIC := '0';
		SD_CMD_DIR : OUT STD_LOGIC := '1';
		SD_D0_DIR : OUT STD_LOGIC := '0';
		SD_D123_DIR : OUT STD_LOGIC;
		-- AUDIO CODEC  DECA 
		AUDIO_GPIO_MFP5 : INOUT STD_LOGIC;
		AUDIO_MISO_MFP4 : IN STD_LOGIC;
		AUDIO_RESET_n : INOUT STD_LOGIC;
		AUDIO_SCLK_MFP3 : OUT STD_LOGIC;
		AUDIO_SCL_SS_n : OUT STD_LOGIC;
		AUDIO_SDA_MOSI : INOUT STD_LOGIC;
		AUDIO_SPI_SELECT : OUT STD_LOGIC;
		i2sMck : OUT STD_LOGIC;
		i2sSck : OUT STD_LOGIC;
		i2sLr : OUT STD_LOGIC;
		i2sD : OUT STD_LOGIC
	);
END ENTITY;

ARCHITECTURE RTL OF deca_top IS
	CONSTANT reset_cycles : INTEGER := 131071;

	-- System clocks

	SIGNAL locked : STD_LOGIC;
	SIGNAL reset_n : STD_LOGIC;

	-- SPI signals

	SIGNAL sd_clk : STD_LOGIC;
	SIGNAL sd_cs : STD_LOGIC;
	SIGNAL sd_mosi : STD_LOGIC;
	SIGNAL sd_miso : STD_LOGIC;

	-- internal SPI signals

	SIGNAL spi_toguest : STD_LOGIC;
	SIGNAL spi_fromguest : STD_LOGIC;
	SIGNAL spi_ss2 : STD_LOGIC;
	SIGNAL spi_ss3 : STD_LOGIC;
	SIGNAL spi_ss4 : STD_LOGIC;
	SIGNAL conf_data0 : STD_LOGIC;
	SIGNAL spi_clk_int : STD_LOGIC;

	-- PS/2 Keyboard socket - used for second mouse
	SIGNAL ps2_keyboard_clk_in : STD_LOGIC;
	SIGNAL ps2_keyboard_dat_in : STD_LOGIC;
	SIGNAL ps2_keyboard_clk_out : STD_LOGIC;
	SIGNAL ps2_keyboard_dat_out : STD_LOGIC;

	-- PS/2 Mouse
	SIGNAL ps2_mouse_clk_in : STD_LOGIC;
	SIGNAL ps2_mouse_dat_in : STD_LOGIC;
	SIGNAL ps2_mouse_clk_out : STD_LOGIC;
	SIGNAL ps2_mouse_dat_out : STD_LOGIC;
	-- Video
	SIGNAL vga_red : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL vga_green : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL vga_blue : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL vga_hsync : STD_LOGIC;
	SIGNAL vga_vsync : STD_LOGIC;

	-- RS232 serial
	SIGNAL rs232_rxd : STD_LOGIC;
	SIGNAL rs232_txd : STD_LOGIC;

	-- IO

	SIGNAL joya : STD_LOGIC_VECTOR(6 DOWNTO 0);
	SIGNAL joyb : STD_LOGIC_VECTOR(6 DOWNTO 0);
	SIGNAL joyc : STD_LOGIC_VECTOR(6 DOWNTO 0);
	SIGNAL joyd : STD_LOGIC_VECTOR(6 DOWNTO 0);

	COMPONENT Oric
		PORT (
			CLOCK_27 : IN STD_LOGIC;
			--RESET_N :   IN std_logic;
			SDRAM_DQ : INOUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			SDRAM_A : OUT STD_LOGIC_VECTOR(12 DOWNTO 0);
			SDRAM_DQML : OUT STD_LOGIC;
			SDRAM_DQMH : OUT STD_LOGIC;
			SDRAM_nWE : OUT STD_LOGIC;
			SDRAM_nCAS : OUT STD_LOGIC;
			SDRAM_nRAS : OUT STD_LOGIC;
			SDRAM_nCS : OUT STD_LOGIC;
			SDRAM_BA : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
			SDRAM_CLK : OUT STD_LOGIC;
			SDRAM_CKE : OUT STD_LOGIC;
			-- UART
			UART_TX : OUT STD_LOGIC;
			UART_RX : IN STD_LOGIC;
			SPI_DO : OUT STD_LOGIC;
			--		SPI_SD_DI	:	 IN STD_LOGIC;
			SPI_DI : IN STD_LOGIC;
			SPI_SCK : IN STD_LOGIC;
			SPI_SS2 : IN STD_LOGIC;
			SPI_SS3 : IN STD_LOGIC;
			--		SPI_SS4		:	 IN STD_LOGIC;
			CONF_DATA0 : IN STD_LOGIC;
			VGA_HS : OUT STD_LOGIC;
			VGA_VS : OUT STD_LOGIC;
			VGA_R : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
			VGA_G : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
			VGA_B : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
			AUDIO_L : OUT STD_LOGIC;
			AUDIO_R : OUT STD_LOGIC;
			DAC_L : OUT SIGNED(15 DOWNTO 0);
			DAC_R : OUT SIGNED(15 DOWNTO 0)
		);
	END COMPONENT;
	COMPONENT AUDIO_SPI_CTL_RD
		PORT (
			iRESET_n : IN STD_LOGIC;
			iCLK_50 : IN STD_LOGIC;
			oCS_n : OUT STD_LOGIC;
			oSCLK : OUT STD_LOGIC;
			oDIN : OUT STD_LOGIC;
			iDOUT : IN STD_LOGIC
		);
	END COMPONENT;

	SIGNAL RESET_DELAY_n : STD_LOGIC;

	COMPONENT i2s_transmitter
		GENERIC (
			sample_rate : POSITIVE
		);
		PORT (
			clock_i : IN STD_LOGIC;
			reset_i : IN STD_LOGIC;
			pcm_l_i : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
			pcm_r_i : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
			i2s_mclk_o : OUT STD_LOGIC;
			i2s_lrclk_o : OUT STD_LOGIC;
			i2s_bclk_o : OUT STD_LOGIC;
			i2s_d_o : OUT STD_LOGIC
		);
	END COMPONENT;
	-- DAC
	SIGNAL dac_l : signed(15 DOWNTO 0);
	SIGNAL dac_r : signed(15 DOWNTO 0);

	SIGNAL dac_l_s : signed(15 DOWNTO 0);
	SIGNAL dac_r_s : signed(15 DOWNTO 0);

BEGIN
	-- SPI

	sd_cs_n_o <= sd_cs;
	sd_mosi_o <= sd_mosi;
	sd_miso <= sd_miso_i;
	sd_sclk_o <= sd_clk;

	-- External devices tied to GPIOs

	ps2_mouse_dat_in <= ps2_mouse_dat;
	ps2_mouse_dat <= '0' WHEN ps2_mouse_dat_out = '0' ELSE
		'Z';
	ps2_mouse_clk_in <= ps2_mouse_clk;
	ps2_mouse_clk <= '0' WHEN ps2_mouse_clk_out = '0' ELSE
		'Z';

	ps2_keyboard_dat_in <= ps2_keyboard_dat;
	ps2_keyboard_dat <= '0' WHEN ps2_keyboard_dat_out = '0' ELSE
		'Z';
	ps2_keyboard_clk_in <= ps2_keyboard_clk;
	ps2_keyboard_clk <= '0' WHEN ps2_keyboard_clk_out = '0' ELSE
		'Z';
	joya <= (OTHERS => '1');
	joyb <= (OTHERS => '1');
	joyc <= (OTHERS => '1');
	joyd <= (OTHERS => '1');
	SD_SEL <= '0'; -- 0 = 3.3V at sdcard   
	SD_CMD_DIR <= '1'; -- MOSI FPGA output
	SD_D0_DIR <= '0'; -- MISO FPGA input     
	SD_D123_DIR <= '1'; -- CS FPGA output  


	VGA_R <= vga_red(7 DOWNTO 5);
	VGA_G <= vga_green(7 DOWNTO 5);
	VGA_B <= vga_blue(7 DOWNTO 5);
	VGA_HS <= vga_hsync;
	VGA_VS <= vga_vsync;

	-- DECA AUDIO CODEC
	RESET_DELAY_n <= reset_n;

	-- Audio DAC DECA Output assignments
	AUDIO_GPIO_MFP5 <= '1'; -- GPIO
	AUDIO_SPI_SELECT <= '1'; -- SPI mode
	AUDIO_RESET_n <= RESET_DELAY_n;

	-- DECA AUDIO CODEC SPI CONFIG
	AUDIO_SPI_CTL_RD_inst : AUDIO_SPI_CTL_RD
	PORT MAP(
		iRESET_n => RESET_DELAY_n,
		iCLK_50 => MAX10_CLK1_50,
		oCS_n => AUDIO_SCL_SS_n,
		oSCLK => AUDIO_SCLK_MFP3,
		oDIN => AUDIO_SDA_MOSI,
		iDOUT => AUDIO_MISO_MFP4
	);

	-- AUDIO CODEC

	i2s_transmitter_inst : i2s_transmitter
	GENERIC MAP(
		sample_rate => 48000
	)
	PORT MAP(
		clock_i => MAX10_CLK1_50,
		reset_i => '0',
		pcm_l_i => STD_LOGIC_VECTOR(dac_l_s),
		pcm_r_i => STD_LOGIC_VECTOR(dac_r_s),
		i2s_mclk_o => i2sMck,
		i2s_lrclk_o => i2sLr,
		i2s_bclk_o => i2sSck,
		i2s_d_o => i2sD
	);

	dac_l_s <= dac_l;
	dac_r_s <= dac_r;


	guest : COMPONENT Oric
		PORT MAP
		(
			CLOCK_27 => MAX10_CLK1_50,
			-- clocks
			SDRAM_DQ => DRAM_DQ,
			SDRAM_A => DRAM_ADDR,
			SDRAM_DQML => DRAM_LDQM,
			SDRAM_DQMH => DRAM_UDQM,
			SDRAM_nWE => DRAM_WE_N,
			SDRAM_nCAS => DRAM_CAS_N,
			SDRAM_nRAS => DRAM_RAS_N,
			SDRAM_nCS => DRAM_CS_N,
			SDRAM_BA => DRAM_BA,
			SDRAM_CLK => DRAM_CLK,
			SDRAM_CKE => DRAM_CKE,

			UART_TX => UART_TXD,
			UART_RX => UART_RXD,

			--		SPI_SD_DI => sd_miso,
			SPI_DO => spi_fromguest,
			SPI_DI => spi_toguest,
			SPI_SCK => spi_clk_int,
			SPI_SS2 => spi_ss2,
			SPI_SS3 => spi_ss3,
			--		SPI_SS4	=> spi_ss4,

			CONF_DATA0 => conf_data0,

			VGA_HS => vga_hsync,
			VGA_VS => vga_vsync,
			VGA_R => vga_red(7 DOWNTO 2),
			VGA_G => vga_green(7 DOWNTO 2),
			VGA_B => vga_blue(7 DOWNTO 2),
			AUDIO_L => sigma_l,
			AUDIO_R => sigma_r,
			DAC_L => dac_l,
			DAC_R => dac_r

		);

		-- Pass internal signals to external SPI interface
		sd_clk <= spi_clk_int;

		controller : ENTITY work.substitute_mcu
			GENERIC MAP(
				sysclk_frequency => 500,
				debug => false,
				jtag_uart => false

			)
			PORT MAP(
				clk => MAX10_CLK1_50,
				reset_in => KEY(0),
				reset_out => reset_n,

				-- SPI signals
				spi_miso => sd_miso,
				spi_mosi => sd_mosi,
				spi_clk => spi_clk_int,
				spi_cs => sd_cs,
				spi_fromguest => spi_fromguest,
				spi_toguest => spi_toguest,
				spi_ss2 => spi_ss2,
				spi_ss3 => spi_ss3,
				spi_ss4 => spi_ss4,
				conf_data0 => conf_data0,

				-- PS/2 signals
				ps2k_clk_in => ps2_keyboard_clk_in,
				ps2k_dat_in => ps2_keyboard_dat_in,
				ps2k_clk_out => ps2_keyboard_clk_out,
				ps2k_dat_out => ps2_keyboard_dat_out,
				ps2m_clk_in => ps2_mouse_clk_in,
				ps2m_dat_in => ps2_mouse_dat_in,
				ps2m_clk_out => ps2_mouse_clk_out,
				ps2m_dat_out => ps2_mouse_dat_out,

				buttons => (0 => KEY(0), 1 => KEY(1), OTHERS => '1'),

				-- UART
				rxd => rs232_rxd,
				txd => rs232_txd
			);

	END rtl;