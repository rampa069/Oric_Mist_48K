module Oric_tap_player(
	input         clk,
	input         ce, // 1 usec
	input         reset,
	input         motor_on,
	input         playstop,
	output reg    byte_req,
	input         byte_ack,
	output [23:0] byte_addr,
	input   [7:0] byte_in,
	output        running,
	output reg    tape_out
);

wire [15:0] pulse_hi_len = 16'd208;
wire [15:0] pulse_lo_len = 16'd416;

reg         playing;
reg  [23:0] ad;
reg         playstop_last;
reg   [3:0] bit_cnt;
reg  [15:0] pulse_hi, pulse_lo;
reg         parity;
reg   [7:0] sync_bytes;
wire        actual_bit = byte_in[bit_cnt - 1'd1];

assign byte_addr = ad;
assign running = motor_on & playing;

always @(posedge clk) begin
	if (reset) begin
		byte_req <= byte_ack;
		ad <= 0;
		playing <= 0;
		bit_cnt <= 0;
		tape_out <= 0;
		pulse_hi <= 0;
		pulse_lo <= 0;
		sync_bytes <= 255;
	end else begin
		playstop_last <= playstop;
		if (~playstop_last & playstop)
			playing <= ~playing;

		if (!motor_on) sync_bytes <= 255;

		if (running && pulse_hi == 0 && pulse_lo == 0) begin
			case(bit_cnt)
				0: // start bit (0)
				begin
					byte_req <= ~byte_req;
					pulse_hi <= pulse_hi_len;
					pulse_lo <= pulse_lo_len;
					parity <= 1;
					bit_cnt <= bit_cnt + 1'd1;
				end
				1, 2, 3, 4, 5, 6, 7, 8:
				if (byte_req == byte_ack) begin
					parity <= parity ^ actual_bit;
					pulse_hi <= pulse_hi_len;
					pulse_lo <= actual_bit ? pulse_hi_len : pulse_lo_len;
					bit_cnt <= bit_cnt + 1'd1;
				end
				9: // parity
				begin
					pulse_hi <= pulse_hi_len;
					pulse_lo <= parity ? pulse_hi_len : pulse_lo_len;
					bit_cnt <= bit_cnt + 1'd1;
				end
				10, 11, 12: // stop bits (1)
				begin
					pulse_hi <= pulse_hi_len;
					pulse_lo <= pulse_hi_len;
					bit_cnt <= bit_cnt + 1'd1;
				end
				default: ;
			endcase
			if (bit_cnt == 12) begin
				bit_cnt <= 0;
				if (byte_in == 8'h16 && sync_bytes != 0)
					sync_bytes <= sync_bytes - 1'd1; // repeat the first sync byte a number of times
				else
					ad <= ad + 1'd1;
			end
		end

		if (ce) begin
			if (pulse_hi != 0) begin
				tape_out <= 1;
				pulse_hi <= pulse_hi - 1'd1;
			end else if (pulse_lo != 0) begin
				tape_out <= 0;
				pulse_lo <= pulse_lo - 1'd1;
			end
		end

	end
end

endmodule
