
module spi_main(
	input i_clk, i_com_start, i_mode_sel,
	input [1:0] i_mode,
	input [7:0] i_tx_byte,
	input i_miso,
	output reg o_mosi,
	output o_cs_n, o_clk, o_done,
	output [7:0] rx_byte
	);
		localparam mode0 = 0;
		localparam mode1 = 1;
		localparam mode2 = 2;
		localparam mode3 = 3;
		
		reg [7:0] r_rx_byte = 0;
		reg [7:0] r_tx_byte = 0;
		reg [1:0] r_mode = 0;
		reg [3:0] r_bit_index_tx = 0, r_bit_index_rx = 0;
		reg r_cs_n = 1'b1, r_clk, r_done;
		
		assign o_cs_n = r_cs_n;
		assign o_clk = r_clk;
		assign o_done = r_done;
		
		always @(posedge i_clk) begin
			if(r_cs_n) begin
				if(i_mode_sel)
					r_mode <= i_mode;
				else
					r_mode <= r_mode;
			end
			
			case(r_mode)
				mode0:
					begin
						if(i_com_start) 											////sampling
							begin
								r_clk <= i_clk;
								r_cs_n <= 0;
								r_rx_byte[r_bit_index_rx] <= i_miso;
								if(r_bit_index_rx < 7)
									r_bit_index_rx <= r_bit_index_rx + 1;
									r_done <= 0;///////////////////////
								else
									r_done <= 1;//////////////////////
									r_bit_index_rx <= 0;
							end
						else 
							begin
								r_clk <= 0;
								r_cs_n <= 1;
							end
					end
				mode1:
					begin															////shifting
						if(i_com_start) 
							begin
								r_clk <= i_clk;
								r_cs_n <= 0;
								o_mosi <= r_tx_byte[r_bit_index_tx];		
								if(r_bit_index_tx < 7)
									r_bit_index_tx <= r_bit_index_tx + 1;
								else
									r_bit_index_tx <= 0;
							end
						else 
							begin
								r_clk <= 0;
								r_cs_n <= 1;
							end
					end
				mode2:
					begin															////shifting
						if(i_com_start) 
							begin
								r_clk <= i_clk;
								r_cs_n <= 0;
								o_mosi <= r_tx_byte[r_bit_index_tx];		
								if(r_bit_index_tx < 7)
									r_bit_index_tx <= r_bit_index_tx + 1;
								else
									r_bit_index_tx <= 0;
							end
						else 
							begin
								r_clk <= 1;
								r_cs_n <= 1;
							end
					end
				mode3:
					begin
						if(i_com_start) 											////sampling
							begin
								r_clk <= i_clk;
								r_cs_n <= 0;
								r_rx_byte[r_bit_index_rx] <= i_miso;
								if(r_bit_index_rx < 7)
									r_bit_index_rx <= r_bit_index_rx + 1;
								else
									r_bit_index_rx <= 0;
							end
						else 
							begin
								r_clk <= 1;
								r_cs_n <= 1;
							end
					end			
			endcase			
		end
	
		always @(negedge i_clk) begin
			case(r_mode)
				mode0:
					begin
						if(i_com_start) 
							begin
								r_clk <= i_clk;
								r_cs_n <= 0;
								o_mosi <= r_tx_byte[r_bit_index_tx];				/////shifting
								if(r_bit_index_tx < 7)
									r_bit_index_tx <= r_bit_index_tx + 1;
								else
									r_bit_index_tx <= 0;
							end
						else 
							begin
								r_clk <= 0;
								r_cs_n <= 1;
							end
					end
				mode1:
					begin
						if(i_com_start) 
							begin
								r_clk <= i_clk;
								r_cs_n <= 0;
								r_rx_byte[r_bit_index_rx] <= i_miso;				/////sampling
								if(r_bit_index_rx < 7)
									r_bit_index_rx <= r_bit_index_rx + 1;
								else
									r_bit_index_rx <= 0;
									r_cs_n <= 1;
							end
						else 
							begin
								r_clk <= 0;
								r_cs_n <= 1;
							end
					end
				mode2:
					begin
						if(i_com_start) 
							begin
								r_clk <= i_clk;
								r_cs_n <= 0;
								r_rx_byte[r_bit_index_rx] <= i_miso;				/////sampling
								if(r_bit_index_rx < 7)
									r_bit_index_rx <= r_bit_index_rx + 1;
								else
									r_bit_index_rx <= 0;
							end
						else 
							begin
								r_clk <= 1;
								r_cs_n <= 1;
							end
					end
				mode3:
					begin
						if(i_com_start) 
							begin
								r_clk <= i_clk;
								r_cs_n <= 0;
								o_mosi <= r_tx_byte[r_bit_index_tx];				/////shifting
								if(r_bit_index_tx < 7)
									r_bit_index_tx <= r_bit_index_tx + 1;
								else
									r_bit_index_tx <= 0;
							end
						else 
							begin
								r_clk <= 1;
								r_cs_n <= 1;
							end
					end
			endcase
		end