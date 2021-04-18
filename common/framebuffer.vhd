--
-- Multicore 2 / Multicore 2+
--
-- Copyright (c) 2017-2020 - Victor Trucco
--
-- All rights reserved
--
-- Redistribution and use in source and synthezised forms, with or without
-- modification, are permitted provided that the following conditions are met:
--
-- Redistributions of source code must retain the above copyright notice,
-- this list of conditions and the following disclaimer.
--
-- Redistributions in synthesized form must reproduce the above copyright
-- notice, this list of conditions and the following disclaimer in the
-- documentation and/or other materials provided with the distribution.
--
-- Neither the name of the author nor the names of other contributors may
-- be used to endorse or promote products derived from this software without
-- specific prior written permission.
--
-- THIS CODE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
-- AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
-- THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
-- PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE
-- LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
-- CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
-- SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
-- INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
-- CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
-- ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
-- POSSIBILITY OF SUCH DAMAGE.
--
-- You are responsible for any legal issues arising from your use of this code.
--
        
--------------------------------------------------------------------------------
--
-- Framebuffer for VGA , SVGA or XGA output
-- Hold an entire screen (before scandoubler)
-- Can be used for screen rotation by hardware or
-- to provide standard times for HDMI
--
-- Attention: requires a huge amount of BRAM!
--
-- Victor Trucco - 2020
--
-- Double Frame Buffer by Oduvaldo Pavan Junior ( ducasp@gmail.com )
-- Avoids tearing, but costs the double amount of BRAM :P
-- To activate it, fourth option should be different than 0 and can
-- be disabled on the fly through dis_db_i
--
-- Rev 2021 01 31 - Oduvaldo
--
-- Removed the delayed clock sys driving the memory buffer write operation,
-- Pixel clock driving it and write enable cleared at the beginning of the
-- pixel clock process is more than enough and simplifies design and do not
-- cause dependencies on system clock being x times faster than pixel clock
--
-- Now it is possible to use just pixel clock to drive input and memory buffer
-- writes, this fixes Donkey Kong missing the last line. On the other hand, a
-- few cores (at least Galaga) do not work with this approach, so it is through
-- SYSCLK configuration that you can use the new behavior if wanted
--
-- clk_vga_i must follow these rules:
--    * For no rotation:
--     - If EVGA is not set, if WIDTH is up to 320 and HEIGHT up to 240, 25M2
--     - If EVGA is set, if WIDTH is up to 360 and HEIGHT up to 240, 27M
--     - If WIDTH up to 400 and HEIGHT up to 300, 40M
--     - If WIDTH larger than 400 or HEIGHT larger than 300, 25M2 (won't scale)
--    * For rotation:
--     - If WIDTH is up to 300 and HEIGHT up to 400, 40M
--     - If WIDTH is up to 384 and HEIGHT up to 512, 65M
--     - If WIDTH larger than 384 or HEIGHT larger than 512, 25M2 (won't scale)
--
-- Rev 2021 02 06 - Oduvaldo
--
-- Fixed logic so it can handle 512 or more pixels and more than 255 lines
--------------------------------------------------------------------------------

library IEEE; 
use IEEE.std_logic_1164.all; 
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;
use ieee.math_real.all;
    
entity framebuffer is
    generic
    (
        WIDHT  : integer := 320;
        HEIGHT : integer := 240;
        DW     : integer := 8;
        DOUBLE : integer := 0;
        SYSCLK : integer := 1;
        EVGA   : integer := 0
    );
    port 
    (
        clk_sys     : in  std_logic;
        clk_i       : in  std_logic; -- pixel clock
        RGB_i       : in  std_logic_vector (DW-1 downto 0);
        hblank_i    : in  std_logic;
        vblank_i    : in  std_logic;
        rotate_i    : in  std_logic_vector (1 downto 0);
        
        clk_vga_i   : in  std_logic;
        RGB_o       : out std_logic_vector (DW-1 downto 0);
        hsync_o     : out std_logic;
        vsync_o     : out std_logic;
        blank_o     : out std_logic;
        dis_db_i    : in  std_logic := '0';
        odd_line_o  : out std_logic
    );
end framebuffer;

architecture rtl of framebuffer is
    constant AW : positive := positive(ceil(log2(real(WIDHT*HEIGHT)))); -- Minimum width needed to address the number of pixels for a given framebuffer
    signal buffer1_ready     : std_logic := '1'; -- Indicates Buffer 1 is filled
    signal buffer2_ready     : std_logic := '0'; -- Indicates Buffer 2 is filled
    signal buffer1_writing   : std_logic := '0'; -- Indicates it is writting to Buffer 1
    signal buffer2_writing   : std_logic := '1'; -- Indicates it is writting to Buffer 2
    signal buffer1_active    : std_logic := '1'; -- Indicates which buffer is being used to output video currently
    signal clr_buffer1       : std_logic := '0'; -- Used to signal the proper process that Buffer 1 has been fully used and can be re-used
    signal clr_buffer2       : std_logic := '0'; -- Used to signal the proper process that Buffer 2 has been fully used and can be re-used
    signal pixel_out1        : std_logic_vector(DW-1 downto 0); -- Data out from the first buffer
    signal pixel_out2        : std_logic_vector(DW-1 downto 0); -- Data out from the second buffer
    signal addr_rd           : std_logic_vector(AW-1 downto 0); -- Driven by the output video process to get the proper pixel data
    signal addr_wr           : std_logic_vector(AW-1 downto 0); -- Driven by the input video process to write the pixel data in the proper place
    signal wren1             : std_logic; -- Ready to write in buffer 1
    signal wren2             : std_logic; -- Ready to write in buffer 2
    signal picture           : std_logic; -- output video process is in the output picture area
    signal window_hcnt       : std_logic_vector( 9 downto 0) := (others => '0'); -- Current H pixel being output in the window, up to 1024 pixels wide
    signal window_vcnt       : std_logic_vector( 9 downto 0) := (others => '0'); -- Current line being output, up to 1024 lines
    signal hcnt              : std_logic_vector( 10 downto 0) := (others => '0'); -- Real output pixel count (including non visible ones), up to 2048 pixels (count also non visible pixels)
    signal vcnt              : std_logic_vector( 10 downto 0) := (others => '0'); -- Real output line count (including non visible ones), up to 2048 lines (count also non visible lines)

    -- Horizontal Timing constants  
    signal h_pixels_across   : integer;
    signal h_sync_on         : integer;
    signal h_sync_off        : integer;
    signal h_end_count       : integer;
    -- Vertical Timing constants
    signal v_pixels_down     : integer;
    signal v_sync_on         : integer;
    signal v_sync_off        : integer;
    signal v_end_count       : integer;
    -- Our output factors
    signal h_scale           : integer;
    signal v_scale           : integer;
    signal scaler_h_count    : integer;
    signal scaler_v_count    : integer;

    -- In
    constant hc_max          : integer := WIDHT;  -- Number of horizontal visible pixels (before scandoubler)
    constant vc_max          : integer := HEIGHT; -- Number of vertical visible pixels   (before scandoubler)

        -- VGA positioning
    signal h_start           : integer; -- initial X position on Output Screen
    signal h_end             : integer; -- final X position on Output Screen
    signal v_start           : integer; -- initial Y position on Output Screen
    signal v_end             : integer; -- final Y position on Output Screen

    signal I_HCNT            : std_logic_vector( 9 downto 0) := (others => '0'); -- Input pixel count, up to 1024 pixels
    signal I_VCNT            : std_logic_vector( 8 downto 0) := (others => '0'); -- Input line count, up to 512 lines
    signal iClk              : std_logic;

begin

iClk <= clk_sys when SYSCLK = 1 else clk_i;

    -- This process is to control buffer writing and horizontal/vertical count in relation to pixel clock and blank signals
    -- And it also will calculate the address of memory to write the next pixel from input
    process (iClk)
    variable edge_hs         : std_logic_vector(1 downto 0);
    variable edge_vs         : std_logic_vector(1 downto 0);
    variable edge_cb1        : std_logic_vector(1 downto 0) := (others => '0');
    variable edge_cb2        : std_logic_vector(1 downto 0) := (others => '0');
    variable edge_clk_ena    : std_logic_vector(1 downto 0);
    variable wr_result_v     : std_logic_vector(18 downto 0);
    begin
        if rising_edge(iClk) then

            -- Write is just a pulse when pixel arrives, so always reset every clk_i
            wren1 <= '0';
            wren2 <= '0';

            -- We deal with the "buffer clear" on the same proccess that indicates it is filled
            -- Thus, the proccess that "clears" the buffer, that is the output process and running
            -- on a different clock, will warn through a signal, and we want to detect that the signal
            -- has changed
            edge_cb1 := edge_cb1(0) & clr_buffer1;
            edge_cb2 := edge_cb2(0) & clr_buffer2;
            if edge_cb1 = "01" then buffer1_ready <= '0'; end if; -- Output is done with buffer 1, can be used to write new data
            if edge_cb2 = "01" then buffer2_ready <= '0'; end if; -- Output is done with buffer 2, can be used to write new data

            edge_clk_ena := edge_clk_ena(0) & clk_i;
            if edge_clk_ena = "01" or SYSCLK = 0 then -- New pixel

                -- new pixel, so, let's start getting the memory address on our register before we update counters
                wr_result_v := std_logic_vector((unsigned(I_VCNT) * to_unsigned(hc_max, 10)) + unsigned(I_HCNT));
                -- and move that value to the address vector of framebuffers write operation
                addr_wr <= wr_result_v(AW-1 downto 0); --wr_result_v(15 downto 0);

                edge_hs := edge_hs(0) & hblank_i; -- Are we on Hblank?
                edge_vs := edge_vs(0) & vblank_i; -- or on Vblank?

                I_HCNT <= I_HCNT + 1; -- Update horizontal input counter

                if edge_vs = "01" then
                    -- Vertical Blanking started, that means, frame is done
                    -- Let's mark as ready any buffer that was being written
                    if buffer2_writing = '1' then
                        buffer2_writing <= '0';
                        buffer2_ready <= '1';
                    elsif buffer1_writing = '1' then
                        buffer1_writing <= '0';
                        buffer1_ready <= '1';
                    end if;
                end if;

                if edge_vs = "10" then
                    -- Vertical Blanking finished
                    -- And here, we request to write to the buffer that is empty, if any
                    -- We will write to a give buffer if:
                    --    1 - It is not being used by the display output ( buffer1_active high means 1 is being used by it, low, that 2 is being used by it)
                    --    2 - It is not being written to (remember the flag set above will take effect only on the next edge, not this one)
                    --    3 - It is not marked as ready (this is cleared by display output through clear buffer when it switches, to avoid tearing)
                    if buffer1_ready = '0' and buffer1_writing = '0' then
                        buffer1_writing <= '1';
                    elsif buffer2_ready = '0' and buffer2_writing = '0' then
                        buffer2_writing <= '1';
                    end if;
                end if;

                if hblank_i = '1' then
                    I_HCNT <= (others => '0'); -- Horizontal Blank, so after blank is finished, horizontal counter is back to 0
                end if;

                if vblank_i = '1' then
                    I_VCNT <= (others => '0'); -- Vertical Blank, so after blank is finished, vertical input counter is back to 0
                end if;

                if edge_hs = "01" then
                    -- Horizontal Blanking started, so this line is finished and we are count to the next one
                    I_VCNT <= I_VCNT + 1; -- update vertical input count
                end if;

                if hblank_i = '0' and vblank_i = '0' then -- Ok, it is not on any blank period, so we should write pixel to buffer
                    if dis_db_i = '0' and DOUBLE /= 0 then -- If using double frame buffer
                        if buffer1_writing = '1' then -- Check if we are writing to the first buffer
                            wren1 <= '1'; -- If so, enable memory buffer 1 to receive the pixel
                            wren2 <= '0'; -- And make sure memory buffer 2 is not written
                        elsif buffer2_writing = '1' then -- otherwise, check if we are writing to buffer 2
                            wren1 <= '0'; -- Make sure memory buffer 1 is not written
                            wren2 <= '1'; -- And enable memory buffer 2 to receive the pixel
                        else -- Ok, both buffers are not ready to be used, that is unfortunate, data will be discarded
                            wren1 <= '0';
                            wren2 <= '0';
                        end if;
                    else -- Using just a single buffer, and there is no sync, so we are always writing to the buffer number 1
                        wren1           <= '1'; -- Write to Buffer 1
                        buffer1_ready   <= '1'; -- Buffer 1 is always ready to be exhibited in single buffer mode
                        buffer2_ready   <= '0'; -- And buffer 2 is not used at all
                        buffer1_writing <= '0';
                        buffer2_writing <= '1'; -- This is mostly just in case we have a double framebuffer, it has been disabled, and is later re-enabled, so the logic won't get stuck
                    end if;
                else -- if on any blank period, nothing to write to any memory buffer
                    wren1 <= '0';
                    wren2 <= '0';
                end if;
            end if;

        end if;
    end process;

-- ModeLine " 640x 480@60Hz"  25.20  640  656  752  800  480  490  492  525 -HSync -VSync
-- ModeLine " 720x 480@60Hz"  27.00  720  736  798  858  480  489  495  525 -HSync -VSync
-- Modeline " 800x 600@60Hz"  40.00  800  840  968 1056  600  601  605  628 +HSync +VSync
-- ModeLine "1024x 768@60Hz"  65.00 1024 1048 1184 1344  768  771  777  806 -HSync -VSync
-- ModeLine "1920x1080@60Hz" 148.50 1920 2008 2052 2200 1080 1084 1089 1125 +HSync +Vsync
-- This process will update the output parameters based on the rotation and input information
-- Driven by the output pixel clock
    process (clk_vga_i, vcnt, v_end_count, rotate_i, h_start, v_start)
    begin
        if rising_edge(clk_vga_i) and (vcnt = v_end_count) and rotate_i(0) = '0' then
            -- Time to check for non-rotated resolution we should be using....
            if (hc_max <= 320) and (vc_max <= 240) and (EVGA = 0) then
                --  Will use 640x480
                h_pixels_across <= 640 - 1; -- Visible from pixel 0 to pixel 639
                h_sync_on       <= 656 - 1; -- Start HSYNC pulse on pixel 656
                h_sync_off      <= 752 - 1; -- End HSYNC pulse on pixel 752
                h_end_count     <= 800 - 1; -- And a full line is 800 pixels long

                v_pixels_down   <= 480 - 1; -- Visible from line 0 to line 479
                v_sync_on       <= 490 - 1; -- Start VSYNC pulse on line 490
                v_sync_off      <= 492 - 1; -- End VSYNC pulse on line 492
                v_end_count     <= 525 - 1; -- And a full screen is 525 lines long

                h_start         <= (640 - (WIDHT*2))/2; -- initial X position on VGA Visible Area to center image, as we actually just double the input pixels, so we can only support up to 320 pixels in input
                h_end           <= h_start + (hc_max * 2); -- Final X position on VGA Visible Area
                h_scale         <= 2;
                v_start         <= (480 - (HEIGHT*2))/2; -- initial Y position on VGA Visible Area to center image, as we actually just double the input lines, so we can only support up to 240 lines in input
                v_end           <= v_start + (vc_max * 2); --  Final Y position on VGA Visible Area
                v_scale         <= 2;
            elsif (hc_max <= 360) and (vc_max <= 240) and (EVGA = 1) then
                --  Will use 720x480
                h_pixels_across <= 720 - 1;  -- Visible from pixel 0 to pixel 719
                h_sync_on       <= 736 - 1;  -- Start HSYNC pulse on pixel 736
                h_sync_off      <= 798 - 1;  -- End HSYNC pulse on pixel 798
                h_end_count     <= 858 - 1;  -- And a full line is 858 pixels long;
             
                v_pixels_down   <= 480 - 1; -- Visible from line 0 to line 479
                v_sync_on       <= 489 - 1; -- Start VSYNC pulse on line 489
                v_sync_off      <= 495 - 1; -- End VSYNC pulse on line 495
                v_end_count     <= 525 - 1; -- And a full screen is 525 lines long
                      
                h_start         <= (720 - (WIDHT*2))/2; -- initial Y position on EVGA Visible Area to center image, as we actually just double the input pixels, so we can only support up to 400 lines in input
                h_end           <= h_start + (hc_max * 2); -- Final Y position on EVGA Visible Area
                h_scale         <= 2;
                v_start         <= (480 - (HEIGHT*2))/2;  -- initial X position on EVGA Visible Area to center image, as we actually just double the input lines, so we can only support up to 300 pixels in input
                v_end           <= v_start + (vc_max * 2); --  Final X position on EVGA Visible Area
                v_scale         <= 2;
            elsif (hc_max <= 400) and (vc_max <= 300) then
                --  Will use 800x600
                h_pixels_across <= 800 - 1; -- Visible from pixel 0 to pixel 639
                h_sync_on       <= 840 - 1; -- Start HSYNC pulse on pixel 656
                h_sync_off      <= 968 - 1; -- End HSYNC pulse on pixel 752
                h_end_count     <= 1056 - 1; -- And a full line is 800 pixels long

                v_pixels_down   <= 600 - 1; -- Visible from line 0 to line 479
                v_sync_on       <= 601 - 1; -- Start VSYNC pulse on line 490
                v_sync_off      <= 605 - 1; -- End VSYNC pulse on line 492
                v_end_count     <= 628 - 1; -- And a full screen is 525 lines long

                h_start         <= (800 - (WIDHT*2))/2; -- initial X position on VGA Visible Area to center image, as we actually just double the input pixels, so we can only support up to 320 pixels in input
                h_end           <= h_start + (hc_max * 2); -- Final X position on VGA Visible Area
                h_scale         <= 2;
                v_start         <= (600 - (HEIGHT*2))/2; -- initial Y position on VGA Visible Area to center image, as we actually just double the input lines, so we can only support up to 240 lines in input
                v_end           <= v_start + (vc_max * 2); --  Final Y position on VGA Visible Area
                v_scale         <= 2;
            else -- Large resolution, won't scale
                --  Will use 640x480
                h_pixels_across <= 640 - 1; -- Visible from pixel 0 to pixel 639
                h_sync_on       <= 656 - 1; -- Start HSYNC pulse on pixel 656
                h_sync_off      <= 752 - 1; -- End HSYNC pulse on pixel 752
                h_end_count     <= 800 - 1; -- And a full line is 800 pixels long

                v_pixels_down   <= 480 - 1; -- Visible from line 0 to line 479
                v_sync_on       <= 490 - 1; -- Start VSYNC pulse on line 490
                v_sync_off      <= 492 - 1; -- End VSYNC pulse on line 492
                v_end_count     <= 525 - 1; -- And a full screen is 525 lines long

                h_start         <= (640 - WIDHT)/2; -- initial X position on VGA Visible Area to center image, as we actually just double the input pixels, so we can only support up to 320 pixels in input
                h_end           <= h_start + hc_max; -- Final X position on VGA Visible Area
                h_scale         <= 1;
                v_start         <= (480 - HEIGHT)/2; -- initial Y position on VGA Visible Area to center image, as we actually just double the input lines, so we can only support up to 240 lines in input
                v_end           <= v_start + vc_max; --  Final Y position on VGA Visible Area
                v_scale         <= 1;
            end if;
        elsif rising_edge(clk_vga_i) and (vcnt = v_end_count) and rotate_i(0) = '1' then
            -- Time to check for rotated resolution we should be using....
            if (vc_max <= 400) and (hc_max <= 300) then
            --  Will use 800x600
                h_pixels_across <= 800 - 1;  -- Visible from pixel 0 to pixel 799
                h_sync_on       <= 840 - 1;  -- Start HSYNC pulse on pixel 840
                h_sync_off      <= 968 - 1;  -- End HSYNC pulse on pixel 968
                h_end_count     <= 1056 - 1; -- And a full line is 1056 pixels long;

                v_pixels_down   <= 600 - 1; -- Visible from line 0 to line 599
                v_sync_on       <= 601 - 1; -- Start VSYNC pulse on line 601
                v_sync_off      <= 605 - 1; -- End VSYNC pulse on line 605
                v_end_count     <= 628 - 1; -- And a full screen is 627 lines long

                h_start         <= (800 - (HEIGHT*2))/2; -- initial Y position on SVGA Visible Area to center image, as we actually just double the input pixels, so we can only support up to 400 lines in input
                h_end           <= h_start + (vc_max * 2); -- Final Y position on SVGA Visible Area
                h_scale         <= 2;
                v_start         <= (600 - (WIDHT*2))/2;  -- initial X position on SVGA Visible Area to center image, as we actually just double the input lines, so we can only support up to 300 pixels in input
                v_end           <= v_start + (hc_max * 2); --  Final X position on SVGA Visible Area
                v_scale         <= 2;
            elsif (vc_max <= 512) and (hc_max <= 384) then
            --  Will use 1024x768
                h_pixels_across <= 1024 - 1;  -- Visible from pixel 0 to pixel 799
                h_sync_on       <= 1048 - 1;  -- Start HSYNC pulse on pixel 840
                h_sync_off      <= 1184 - 1;  -- End HSYNC pulse on pixel 968
                h_end_count     <= 1344 - 1; -- And a full line is 1056 pixels long;

                v_pixels_down   <= 768 - 1; -- Visible from line 0 to line 599
                v_sync_on       <= 771 - 1; -- Start VSYNC pulse on line 601
                v_sync_off      <= 777 - 1; -- End VSYNC pulse on line 605
                v_end_count     <= 806 - 1; -- And a full screen is 627 lines long

                h_start         <= (1024 - (HEIGHT*2))/2; -- initial Y position on SVGA Visible Area to center image, as we actually just double the input pixels, so we can only support up to 400 lines in input
                h_end           <= h_start + (vc_max * 2); -- Final Y position on SVGA Visible Area
                h_scale         <= 2;
                v_start         <= (768 - (WIDHT*2))/2;  -- initial X position on SVGA Visible Area to center image, as we actually just double the input lines, so we can only support up to 300 pixels in input
                v_end           <= v_start + (hc_max * 2); --  Final X position on SVGA Visible Area
                v_scale         <= 2;
            else -- Large resolution, won't scale
                --  Will use 800x600
                h_pixels_across <= 800 - 1;  -- Visible from pixel 0 to pixel 799
                h_sync_on       <= 840 - 1;  -- Start HSYNC pulse on pixel 840
                h_sync_off      <= 968 - 1;  -- End HSYNC pulse on pixel 968
                h_end_count     <= 1056 - 1; -- And a full line is 1056 pixels long;

                v_pixels_down   <= 600 - 1; -- Visible from line 0 to line 599
                v_sync_on       <= 601 - 1; -- Start VSYNC pulse on line 601
                v_sync_off      <= 605 - 1; -- End VSYNC pulse on line 605
                v_end_count     <= 628 - 1; -- And a full screen is 627 lines long

                h_start         <= (800 - HEIGHT)/2; -- initial Y position on SVGA Visible Area to center image, as we actually just double the input pixels, so we can only support up to 400 lines in input
                h_end           <= h_start + vc_max; -- Final Y position on SVGA Visible Area
                h_scale         <= 1;
                v_start         <= (600 - WIDHT)/2;  -- initial X position on SVGA Visible Area to center image, as we actually just double the input lines, so we can only support up to 300 pixels in input
                v_end           <= v_start + hc_max; --  Final X position on SVGA Visible Area
                v_scale         <= 1;
            end if;
        end if;
    end process;

    -- First Frame Buffer
    framebuffer1: entity work.buffer_ram
    generic map 
    (
        addr_width_g    => AW,
        data_width_g    => DW
    )
    port map
    (
        clk_a_i     => iClk,
        data_a_i    => RGB_i,
        addr_a_i    => addr_wr,
        we_i        => wren1,
        data_a_o    => open,
        --
        clk_b_i     => clk_vga_i,
        addr_b_i    => addr_rd,
        data_b_o    => pixel_out1
    );

G1: if DOUBLE /= 0 generate
    -- When using double Frame Buffer, second Frame Buffer
    framebuffer2: entity work.buffer_ram
    generic map 
    (
        addr_width_g    => AW,
        data_width_g    => DW
    )
    port map
    (
        clk_a_i     => iClk,
        data_a_i    => RGB_i,
        addr_a_i    => addr_wr,
        we_i        => wren2,
        data_a_o    => open,
        --
        clk_b_i     => clk_vga_i,
        addr_b_i    => addr_rd,
        data_b_o    => pixel_out2
    );
end generate G1;

    -- This process keep the pixel and line count, as well keep our internal window count
    process (clk_vga_i)
    begin
        if rising_edge(clk_vga_i) then 
            if hcnt = h_end_count then
                hcnt <= (others => '0'); -- We went through all pixels in that line, so cycle back to 0
            else
                hcnt <= hcnt + 1; -- not in the last pixel, so next pixel
                if hcnt = h_start then
                    window_hcnt <= (others => '0'); -- start of visible area that we are going to draw, our window
                    scaler_h_count <= 1;
                else
                    if (scaler_h_count = h_scale) then
                        window_hcnt <= window_hcnt + 1; -- not the start, just keep increasing it
                        scaler_h_count <= 1;
                    else
                        scaler_h_count <= scaler_h_count + 1;
                    end if;
                end if;
            end if;

            if hcnt = h_sync_on then -- Time to make horizontal sync?
                if vcnt = v_end_count then
                    vcnt <= (others => '0'); -- If last line, then back to first line
                    scaler_v_count <= 1;
                else
                    vcnt <= vcnt + 1; -- not first line, so increase line count
                    if vcnt = v_start then
                        window_vcnt <= (others => '0'); -- start of visible area that we are going to draw, our window
                        scaler_v_count <= 1;
                    else
                        if (scaler_v_count = v_scale) then
                            window_vcnt <= window_vcnt + 1; -- not the start, just keep increasing it
                            scaler_v_count <= 1;
                        else
                            scaler_v_count <= scaler_v_count + 1;
                        end if;
                    end if;
                end if;
            end if;
        end if;
    end process;

    -- This process will calculate the adress of memory to be read from buffer to the output
    -- It assumes that both v and h window counts are doubled in relation to the memory count
    -- So the output will get from the same place in buffer twice effectively doubling both horizontal as well as vertical resolution
    process (clk_vga_i)
        variable rd_result_v : std_logic_vector(18 downto 0);
    begin
        if rising_edge(clk_vga_i) then 
            if (rotate_i = "00") then -- no rotation
                -- Just the number of pixel being written in the window, so (vcount * number of pixels in line) + hcount
                rd_result_v := std_logic_vector((unsigned(window_vcnt(8 downto 0)) * to_unsigned(hc_max, 10)) + unsigned(window_hcnt(9 downto 0)));
            elsif (rotate_i = "01") then  -- 90o CW: 
                rd_result_v := std_logic_vector
                (
                    -- Will calculate as:
                    -- pixel 0 and line 0 means the pixel 0 of the last line
                    -- pixel 0 and line 1 means the pixel 1 of the second to last line
                    -- pixel 1 and line 0 means the pixel 0 of the last line
                    -- pixel 1 and line 1 means the pixel 1 of second to last line
                    -- So we want to get the pixel data from (Line (total lines - hcount) * number of pixels in line) + line number
                    (((to_unsigned(vc_max, 9) -1) - (unsigned(window_hcnt(9 downto 0)))) * to_unsigned(hc_max, 9)) + 
                    (unsigned(window_vcnt(8 downto 0)))
                );
            elsif (rotate_i = "10") then -- 180o CW:
                rd_result_v := std_logic_vector
                (
                    -- Will calculate as:
                    -- pixel 0 and line 0 means the last pixel of the last line
                    -- pixel 0 and line 1 means the last pixel of the second to last line
                    -- pixel 1 and line 0 means the second to last pixel of the last line
                    -- pixel 1 and line 1 means the second to last pixel of second to last line
                    -- So we want to get the pixel data from Line (total lines - vcount) - (max pixels in line - hcount)
                   (((to_unsigned(vc_max, 9) - (unsigned(window_vcnt(8 downto 0)))) * to_unsigned(hc_max, 10)) - 
                    (unsigned(window_hcnt(9 downto 0)))-2)
                );
            else -- 90o CCW  (( h *16 + (16-v)-1) ));
                rd_result_v := std_logic_vector
                (
                    -- Will calculate as:
                    -- pixel 0 and line 0 means the last pixel of line 0
                    -- pixel 0 and line 1 means the second to last pixel of line 0
                    -- pixel 1 and line 0 means the last pixel of line 1
                    -- pixel 1 and line 1 means the second to last pixel of line 1
                    -- So we want to get the pixel data from (Line (hcount) * number of pixels in line) + (number of pixels in line - vcount)
                    (to_unsigned(hc_max, 9) * (unsigned(window_hcnt(9 downto 0)))) + 
                    (to_unsigned(hc_max, 9) - (unsigned(window_vcnt(8 downto 0)))) - 1
                );
            end if;
            -- Assign the calculated address position to the buffer read address vector
            addr_rd <= rd_result_v(AW-1 downto 0);
        end if;
    end process;

    -- This process will:
    --  1 - Check if it is end of output VBLANK, and if so, check if need to change the buffer being displayed and request the other buffer to be freed for input use
    --  2 - Auto clear the clear request after a few lines have been outputed
    --  3 - Determine the RGB output, 0 if in output blank period or not in the window picture area, otherwise, assign the output of the proper frame buffer to it
    process (clk_vga_i)
    begin
        if rising_edge(clk_vga_i) then 

            -- General output signals assignments

            -- Blank when finished writing the visible pixels of a given line OR we are after the last visible line
            if (hcnt > h_pixels_across) or (vcnt > v_pixels_down) then blank_o <= '1'; else blank_o <= '0'; end if;
            -- Picture means that we are getting data from buffer memory, that means, in the visible window area
            if (hcnt > h_start+1 and hcnt <= h_end) and (vcnt > v_start and vcnt <= v_end) then picture <= '1'; else picture <= '0'; end if;
            -- Pulse HSYNC in the proper pixel area as defined
            if (hcnt <= h_sync_on) or (hcnt > h_sync_off) then hsync_o <= '1'; else hsync_o <= '0'; end if;
            -- Pulse VSYNC in the proper line area as defined
            if (vcnt <= v_sync_on) or (vcnt > v_sync_off) then vsync_o <= '1'; else vsync_o <= '0'; end if;
            -- an odd line detector
            odd_line_o <= vcnt(0);

            if vcnt = v_end_count then
                -- End of output VBLANK
                -- Switch buffers as needed so the next output uses the proper buffer
                if dis_db_i = '1' or DOUBLE = 0 then
                    -- Not using double framebuffer, so it is always buffer1, no buffer to clear
                    buffer1_active  <= '1';
                    clr_buffer1     <= '0';
                    clr_buffer2     <= '0';
                elsif buffer1_active = '1' and buffer2_ready = '1' then
                    -- Buffer 1 was being used to output AND lucky us, buffer 2 is ready to be used
                    -- So indicate buffer 1 is not being used to output (so 2 is) and request buffer 1 to be freed for use in the next input frame
                    buffer1_active  <= '0';
                    clr_buffer1     <= '1';
                elsif buffer1_active = '0' and buffer1_ready = '1' then
                    -- Buffer 2 was being used to output AND lucky us, buffer 1 is ready to be used
                    -- So indicate buffer 1 is now being used to output (so 2 is not) and request buffer 2 to be freed for use in the next input frame
                    buffer1_active  <= '1';
                    clr_buffer2     <= '1';
                end if;
                -- If none of those cases, we want to keep everything as is
            end if;

            -- Auto clear the clr_buffer request after a few lines have been outputed
            if vcnt = 30 then
                clr_buffer1 <= '0';
                clr_buffer2 <= '0';
            end if;

            if picture = '1' and (hcnt <= h_pixels_across) and (vcnt <= v_pixels_down) then
                -- "Beam" is on a visible area and blank is not active
                -- So redirect the proper buffer memory to the output 
                if buffer1_active = '1' then
                    RGB_o <=  pixel_out1;
                else
                    RGB_o <= pixel_out2;
                end if;
            else
                -- blank period or "Beam" is not on a visible area
                -- So just output black, 0
                RGB_o <=  (others => '0');
            end if;
        end if;
    end process;
end rtl;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity buffer_ram is
  generic (
    addr_width_g : integer := 8;
    data_width_g : integer := 8
  );
  port (
    clk_a_i  : in  std_logic;
    we_i     : in  std_logic;
    addr_a_i : in  std_logic_vector(addr_width_g-1 downto 0);
    data_a_i : in  std_logic_vector(data_width_g-1 downto 0);
    data_a_o : out std_logic_vector(data_width_g-1 downto 0);
    clk_b_i  : in  std_logic;
    addr_b_i : in  std_logic_vector(addr_width_g-1 downto 0);
    data_b_o : out std_logic_vector(data_width_g-1 downto 0)
  );
end entity;


library ieee;
use ieee.numeric_std.all;

architecture rtl_ram of buffer_ram is

  type   ram_t      is array (natural range 2**addr_width_g-1 downto 0) of
    std_logic_vector(data_width_g-1 downto 0);
  signal ram_q      : ram_t;
 
begin

    mem_a: process (clk_a_i)
        variable read_addr_v    : unsigned(addr_width_g-1 downto 0);
    begin
        if rising_edge(clk_a_i) then
            read_addr_v := unsigned(addr_a_i);
            if we_i = '1' then
                ram_q(to_integer(read_addr_v)) <= data_a_i;
            end if;
            data_a_o <= ram_q(to_integer(read_addr_v));
        end if;
    end process mem_a;

    mem_b: process (clk_b_i)
        variable read_addr_v    : unsigned(addr_width_g-1 downto 0);
    begin
        if rising_edge(clk_b_i) then
            read_addr_v := unsigned(addr_b_i);
            data_b_o <= ram_q(to_integer(read_addr_v));
        end if;
    end process mem_b;

end rtl_ram;