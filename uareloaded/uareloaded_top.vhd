LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

-- -----------------------------------------------------------------------

ENTITY uareloaded_top IS
	PORT (
		CLOCK_50 : IN STD_LOGIC;
		LED : OUT STD_LOGIC;
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
		VGA_R : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		VGA_G : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		VGA_B : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		VGA_BLANK : OUT STD_LOGIC;
		VGA_CLOCK : OUT STD_LOGIC;
		-- AUDIO
		SIGMA_R : OUT STD_LOGIC;
		SIGMA_L : OUT STD_LOGIC;
		-- PS2
		PS2_KEYBOARD_CLK : INOUT STD_LOGIC;
		PS2_KEYBOARD_DAT : INOUT STD_LOGIC;
		PS2_MOUSE_CLK : INOUT STD_LOGIC;
		PS2_MOUSE_DAT : INOUT STD_LOGIC;
		-- UART
		AUDIO_IN : IN STD_LOGIC;
		--STM32
		STM_RST : OUT STD_LOGIC := 'Z'; -- '0' to hold the microcontroller reset line, to free the SD card
		-- I2S
		SCLK : OUT STD_LOGIC;
		SDIN : OUT STD_LOGIC;
		MCLK : OUT STD_LOGIC := 'Z';
		LRCLK : OUT STD_LOGIC;
		-- SD Card
		SD_CS : OUT STD_LOGIC := '1';
		SD_SCK : OUT STD_LOGIC := '0';
		SD_MOSI : OUT STD_LOGIC := '0';
		SD_MISO : IN STD_LOGIC

	);
END ENTITY;

ARCHITECTURE RTL OF uareloaded_top IS
	CONSTANT reset_cycles : INTEGER := 131071;

	-- System clocks

	SIGNAL locked : STD_LOGIC;
	SIGNAL reset_n : STD_LOGIC;

	-- SPI signals

	--	signal sd_clk : std_logic;
	--	signal sd_cs : std_logic;
	--	signal sd_mosi : std_logic;
	--	signal sd_miso : std_logic;

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
	-- DAC
	SIGNAL dac_l : signed(15 DOWNTO 0);
	SIGNAL dac_r : signed(15 DOWNTO 0);

	SIGNAL dac_l_s : signed(15 DOWNTO 0);
	SIGNAL dac_r_s : signed(15 DOWNTO 0);

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

BEGIN
	-- SPI


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

	STM_RST <= '0';
	LED <= AUDIO_IN; --not ps2_keyboard_clk;
	pll_vga : ENTITY work.pll_vga
		PORT MAP(
			inclk0 => CLOCK_50,
			c0 => VGA_CLOCK,
			locked => OPEN
		);

	--process(clk_sys)
	--begin
	--	if rising_edge(clk_sys) then
	VGA_R <= vga_red;
	VGA_G <= vga_green;
	VGA_B <= vga_blue;
	VGA_HS <= vga_hsync;
	VGA_VS <= vga_vsync;
	VGA_BLANK <= '1';

	--	end if;
	--end process;

	---- I2S out

	i2s : ENTITY work.audio_top
		PORT MAP(
			clk_50MHz => clock_50,
			dac_MCLK => MCLK,
			dac_SCLK => SCLK,
			dac_SDIN => SDIN,
			dac_LRCK => LRCLK,
			L_data => STD_LOGIC_VECTOR (dac_l_s),
			R_data => STD_LOGIC_VECTOR (dac_r_s)
		);

	dac_l_s <= dac_l;
	dac_r_s <= dac_r;

	guest : COMPONENT Oric
		PORT MAP
		(
			CLOCK_27 => CLOCK_50,
			--RESET_N => reset_n,
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

			UART_TX => OPEN,
			UART_RX => NOT AUDIO_IN,

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
		sd_sck <= spi_clk_int;

		controller : ENTITY work.substitute_mcu
			GENERIC MAP(
				sysclk_frequency => 500,
				debug => false,
				jtag_uart => false

			)
			PORT MAP(
				clk => CLOCK_50,
				reset_in => '1',
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

				buttons => (OTHERS => '1'),

				-- UART
				rxd => rs232_rxd,
				txd => rs232_txd
			);

	END rtl;