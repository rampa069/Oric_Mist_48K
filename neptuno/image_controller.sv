//-------------------------------------------------------------------------------
//--
//-- Image reader for the Amstrad FPGA
//--
//-- 2019 - Victor Trucco
//-- 
//-------------------------------------------------------------------------------



module image_controller 
(
    
	input						clk_i,
	input						reset_i,
                       
	input			[31:0]	sd_lba,
	input			[ 1:0]	sd_rd, 
	input			[ 1:0]	sd_wr, 
                                
	output reg				sd_ack,
	output reg 	[ 8:0]	sd_buff_addr,
	output reg 	[ 7:0]	sd_buff_dout,
	input			[ 7:0]	sd_buff_din,
	output reg				sd_buff_wr,
		                        
	output reg 	[19:0]	sram_addr_o,
	input			[ 7:0]	sram_data_i,
	output		[ 7:0]	sram_data_o,
	output               sram_we_o

);




typedef enum
{
		IDLE,
		P0,
		R1,
		R2,
		R3,
		R4,
		R5,
		W1,
		W2,
		W3
} states_t;

states_t state_s ;

reg [19:0] sram_addr_s;
reg [16:0] sd_addr;

assign	sd_buff_addr = sram_addr_s[8:0];
assign	sram_addr_o = sram_addr_s; 



	always @(posedge clk_i)
	begin
		 	if (reset_i)
			begin
				
					state_s <= P0;
					sd_ack <= 1'b0;
					sd_buff_wr <= 1'b0;
			end
			else
			begin
		 

			
					case (state_s)
					
						IDLE: state_s <= IDLE;
 
						 P0:
							 begin

									if ( sd_rd[0] )
									begin
										sd_ack <= 1'b1;
										state_s <= R1;																		
										sd_addr = sd_lba[16:0]; //(sd_lba[16:0] > 9'd256)? sd_lba[16:0] - 9'd256 : sd_lba[16:0]; // ATTENTION blocking assignment
										sram_addr_s[19:9] =  sd_addr[10:0];
										sram_addr_s[8:0] = 9'b000000000;
									end
									if ( sd_wr[0] )
									begin
										sd_ack <= 1'b1;
										state_s <= W1;																		
										sd_addr = sd_lba[16:0]; //(sd_lba[16:0] > 9'd256)? sd_lba[16:0] - 9'd256 : sd_lba[16:0]; // ATTENTION blocking assignment
										sram_addr_s[19:9] =  sd_addr[10:0];
										sram_addr_s[8:0] = 9'b000000000;						
									end
							end
						
						R1:
							begin
									sd_buff_dout<= sram_data_i;
									state_s <= R2;
							end	
						
						R2:
							begin			
									sd_buff_wr <= 1'b1;
									state_s <= R3;
							end	
						
						R3:	
							begin		
									sd_buff_wr <= 1'b0;
									state_s <= R4;
							end	
						
						R4:
							begin
									sram_addr_s <= sram_addr_s + 1;
									if (sram_addr_s[8:0] != 9'b111111111)
										state_s <= R1;
									else
										state_s <= R5;
							end
								
						R5:
							begin
									sd_ack <= 1'b0;
									state_s <= P0;
							end		

						W1:
							begin
									sram_data_o <= sd_buff_din;
									sram_we_o   <= 1'b1;
									state_s <= W2;
							end	

						W2:
							begin
									sram_addr_s <= sram_addr_s + 1;
									sram_we_o   <= 1'b0;
									if (sram_addr_s[8:0] != 9'b111111111)
										state_s <= W1;
									else
										state_s <= W3;		
							end

						W3:
							begin
									sd_ack <= 1'b0;
									state_s <= P0;
							end		
						
							  
					endcase;
				


				
			end
	end


endmodule


