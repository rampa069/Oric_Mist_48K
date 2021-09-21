LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

-- -----------------------------------------------------------------------

ENTITY neptuno_top IS
	PORT (
		clock_50_i : IN STD_LOGIC;
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
		VGA_R : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
		VGA_G : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
		VGA_B : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
		-- AUDIO
		SIGMA_R : OUT STD_LOGIC;
		SIGMA_L : OUT STD_LOGIC;
		-- I2S audio		
		I2S_BCLK : OUT STD_LOGIC := '0';
		I2S_LRCLK : OUT STD_LOGIC := '0';
		I2S_DATA : OUT STD_LOGIC := '0';

		-- JOYSTICK 
		JOY_CLK : OUT STD_LOGIC;
		JOY_LOAD : OUT STD_LOGIC;
		JOY_DATA : IN STD_LOGIC;
		joyP7_o : OUT STD_LOGIC := '1';

		-- PS2
		PS2_KEYBOARD_CLK : INOUT STD_LOGIC;
		PS2_KEYBOARD_DAT : INOUT STD_LOGIC;
		PS2_MOUSE_CLK : INOUT STD_LOGIC;
		PS2_MOUSE_DAT : INOUT STD_LOGIC;
		-- UART
		AUDIO_INPUT : IN STD_LOGIC;
		--STM32
		stm_rx_o : OUT STD_LOGIC := 'Z'; -- stm RX pin, so, is OUT on the slave
		stm_tx_i : IN STD_LOGIC := 'Z'; -- stm TX pin, so, is IN on the slave
		stm_rst_o : OUT STD_LOGIC := 'Z'; -- '0' to hold the microcontroller reset line, to free the SD card

		-- SD Card
		sd_cs_n_o : OUT STD_LOGIC := '1';
		sd_sclk_o : OUT STD_LOGIC := '0';
		sd_mosi_o : OUT STD_LOGIC := '0';
		sd_miso_i : IN STD_LOGIC

	);
END ENTITY;

ARCHITECTURE RTL OF neptuno_top IS
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

	SIGNAL joya : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL joyb : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL joyc : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL joyd : STD_LOGIC_VECTOR(7 DOWNTO 0);

	SIGNAL DAC_L : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL DAC_R : STD_LOGIC_VECTOR(15 DOWNTO 0);

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
			DAC_L : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			DAC_R : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)

		);
	END COMPONENT;
	COMPONENT audio_top IS
		PORT (
			clk_50MHz : IN STD_LOGIC; -- system clock (50 MHz)
			dac_MCLK : OUT STD_LOGIC; -- outputs to PMODI2L DAC
			dac_LRCK : OUT STD_LOGIC;
			dac_SCLK : OUT STD_LOGIC;
			dac_SDIN : OUT STD_LOGIC;
			L_data : IN STD_LOGIC_VECTOR(15 DOWNTO 0); -- LEFT data (15-bit signed)
			R_data : IN STD_LOGIC_VECTOR(15 DOWNTO 0) -- RIGHT data (15-bit signed) 
		);
	END COMPONENT;
	SIGNAL audio_l_s : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL audio_r_s : STD_LOGIC_VECTOR(15 DOWNTO 0);
	COMPONENT joydecoder IS
		PORT (
			clk : IN STD_LOGIC;
			joy_data : IN STD_LOGIC;
			joy_clk : OUT STD_LOGIC;
			joy_load_n : OUT STD_LOGIC;
			joy1up : OUT STD_LOGIC;
			joy1down : OUT STD_LOGIC;
			joy1left : OUT STD_LOGIC;
			joy1right : OUT STD_LOGIC;
			joy1fire1 : OUT STD_LOGIC;
			joy1fire2 : OUT STD_LOGIC;
			joy2up : OUT STD_LOGIC;
			joy2down : OUT STD_LOGIC;
			joy2left : OUT STD_LOGIC;
			joy2right : OUT STD_LOGIC;
			joy2fire1 : OUT STD_LOGIC;
			joy2fire2 : OUT STD_LOGIC
		);
	END COMPONENT;

	-- JOYSTICKS
	SIGNAL joy1up : STD_LOGIC := '1';
	SIGNAL joy1down : STD_LOGIC := '1';
	SIGNAL joy1left : STD_LOGIC := '1';
	SIGNAL joy1right : STD_LOGIC := '1';
	SIGNAL joy1fire1 : STD_LOGIC := '1';
	SIGNAL joy1fire2 : STD_LOGIC := '1';
	SIGNAL joy2up : STD_LOGIC := '1';
	SIGNAL joy2down : STD_LOGIC := '1';
	SIGNAL joy2left : STD_LOGIC := '1';
	SIGNAL joy2right : STD_LOGIC := '1';
	SIGNAL joy2fire1 : STD_LOGIC := '1';
	SIGNAL joy2fire2 : STD_LOGIC := '1';
	SIGNAL clk_sys_out : STD_LOGIC;
	-- i2s 
	SIGNAL i2s_mclk : STD_LOGIC;

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

	joya <= "11" & joy1fire2 & joy1fire1 & joy1right & joy1left & joy1down & joy1up;
	joyb <= "11" & joy2fire2 & joy2fire1 & joy2right & joy2left & joy2down & joy2up;

	stm_rst_o <= '0';
	LED <= AUDIO_INPUT;

	--process(clk_sys)
	--begin
	--	if rising_edge(clk_sys) then
	VGA_R <= vga_red(7 DOWNTO 3);
	VGA_G <= vga_green(7 DOWNTO 3);
	VGA_B <= vga_blue(7 DOWNTO 3);
	VGA_HS <= vga_hsync;
	VGA_VS <= vga_vsync;
	--	end if;
	--end process;

	-- I2S audio

	audio_i2s : ENTITY work.audio_top
		PORT MAP(
			clk_50MHz => clock_50_i,
			dac_MCLK => I2S_MCLK,
			dac_LRCK => I2S_LRCLK,
			dac_SCLK => I2S_BCLK,
			dac_SDIN => I2S_DATA,
			L_data => STD_LOGIC_VECTOR(audio_l_s),
			R_data => STD_LOGIC_VECTOR(audio_r_s)
		);

	audio_l_s <= DAC_L;
	audio_r_s <= DAC_R;

	-- JOYSTICKS
	joy : joydecoder
	PORT MAP(
		clk => clock_50_i,
		joy_clk => JOY_CLK,
		joy_load_n => JOY_LOAD,
		joy_data => JOY_DATA,
		joy1up => joy1up,
		joy1down => joy1down,
		joy1left => joy1left,
		joy1right => joy1right,
		joy1fire1 => joy1fire1,
		joy1fire2 => joy1fire2,
		joy2up => joy2up,
		joy2down => joy2down,
		joy2left => joy2left,
		joy2right => joy2right,
		joy2fire1 => joy2fire1,
		joy2fire2 => joy2fire2
	);

	guest : COMPONENT Oric
		PORT MAP
		(
			CLOCK_27 => clock_50_i,
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
			UART_RX => AUDIO_INPUT,

			SPI_DO => spi_fromguest,
			SPI_DI => spi_toguest,
			SPI_SCK => spi_clk_int,
			SPI_SS2 => spi_ss2,
			SPI_SS3 => spi_ss3,
			CONF_DATA0 => conf_data0,

			VGA_HS => vga_hsync,
			VGA_VS => vga_vsync,
			VGA_R => vga_red(7 DOWNTO 2),
			VGA_G => vga_green(7 DOWNTO 2),
			VGA_B => vga_blue(7 DOWNTO 2),
			AUDIO_L => sigma_l,
			AUDIO_R => sigma_r,
			DAC_L => DAC_L,
			DAC_R => DAC_R
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
				clk => clock_50_i,
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

				-- JOYSTICKS
				joy1 => joya,
				joy2 => joyb,

				-- UART
				rxd => rs232_rxd,
				txd => rs232_txd
			);

	END rtl;