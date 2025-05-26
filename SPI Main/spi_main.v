`timescale 1us / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.05.2025 10:25:33
// Design Name: 
// Module Name: spi_main
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module spi_main(
	input i_clk, i_com_start, i_mode_sel,
	input [1:0] i_mode,
	input [7:0] i_tx_byte,
	input i_miso,
	output o_mosi,
	output o_cs_n, o_clk, o_tx_done, o_rx_done,							
	output reg [7:0] o_rx_byte
	);
		localparam mode0 = 2'd0;
		localparam mode1 = 2'd1;
		localparam mode2 = 2'd2;
		localparam mode3 = 2'd3;
		
		reg [7:0] r_rx_byte = 0;
		reg [7:0] r_tx_byte = 0;
		reg [1:0] r_mode = 0;
		reg [3:0] r_bit_index_tx = 0, r_bit_index_rx = 0;
		reg r_cs_n, r_clk, r_tx_done = 0, r_rx_done = 0;
		wire w_clk;
		//
		///////////////////////////////////Output Assignments/////////////////////////////////
		//
		
		assign o_cs_n = r_cs_n;
		assign o_clk = r_clk;
		assign o_tx_done = r_tx_done;
		assign o_rx_done = r_rx_done;
		assign w_clk = i_clk;
		//
		///////////////////////Latching the Input Byte Data for Transmission//////////////////
		//
		always @(posedge r_tx_done) begin
			r_tx_byte <= i_tx_byte;
		end
		//
		////////////////////////////Latching the Received Byte Data///////////////////////////
		//
		always @(posedge r_rx_done) begin
			o_rx_byte <= r_rx_byte;
		end
		//
		/////////////////Posedge Shifting and Sampling based on Mode Selected////////////////
		//
		reg r_clk_pe, r_cs_n_pe = 1'b1, r_rx_done_pe = 0, r_tx_done_pe = 0, r_mosi_pe;
		reg [3:0] r_bit_index_rx_pe = 0;
		reg [3:0] r_bit_index_tx_pe = 0;
		reg [7:0] r_rx_byte_pe = 0;
		
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
						if(i_com_start) 										    ////sampling
							begin
								//r_clk_pe <= w_clk;
								r_cs_n_pe <= 0;
								r_rx_byte_pe[r_bit_index_rx_pe] <= i_miso;
								if(r_bit_index_rx_pe < 7)
									begin
										r_bit_index_rx_pe <= r_bit_index_rx_pe + 1;
										r_rx_done_pe <= 0;								
									end
								else
									begin
										r_rx_done_pe <= 1;								
										r_bit_index_rx_pe <= 0;
									end
							end
						else 
							begin
								r_clk_pe <= 0;
								r_cs_n_pe <= 1;
								r_tx_done_pe <= 0;
							end
					end
				mode1:
					begin															////shifting
						if(i_com_start) 
							begin
								//r_clk_pe <= w_clk;
								r_cs_n_pe <= 0;
								r_mosi_pe <= r_tx_byte[r_bit_index_tx_pe];		
								if(r_bit_index_tx_pe < 7)
									begin
										r_bit_index_tx_pe <= r_bit_index_tx_pe + 1;
										r_tx_done_pe <= 0;
									end
								else 
									begin
										r_bit_index_tx_pe <= 0;
										r_tx_done_pe <= 1;
									end
							end
						else 
							begin
								r_clk_pe <= 0;
								r_cs_n_pe <= 1;
								r_rx_done_pe <= 0;
							end
					end
				mode2:
					begin															////shifting
						if(i_com_start) 
							begin
								//r_clk_pe <= w_clk;
								r_cs_n_pe <= 0;
								r_mosi_pe <= r_tx_byte[r_bit_index_tx_pe];		
								if(r_bit_index_tx_pe < 7)
									begin
										r_bit_index_tx_pe <= r_bit_index_tx_pe + 1;
										r_tx_done_pe <= 0;
									end
								else 
									begin
										r_bit_index_tx_pe <= 0;
										r_tx_done_pe <= 1;
									end
							end
						else 
							begin
								r_clk_pe <= 1;
								r_cs_n_pe <= 1;
								r_rx_done_pe <= 0;
							end
					end
				mode3:
					begin
						if(i_com_start) 										    ////sampling
							begin
								//r_clk_pe <= w_clk;
								r_cs_n_pe <= 0;
								r_rx_byte_pe[r_bit_index_rx_pe] <= i_miso;
								if(r_bit_index_rx_pe < 7)
									begin
										r_bit_index_rx_pe <= r_bit_index_rx_pe + 1;
										r_rx_done_pe <= 0;								
									end
								else
									begin
										r_rx_done_pe <= 1;								
										r_bit_index_rx_pe <= 0;
									end
							end
						else 
							begin
								r_clk_pe <= 1;
								r_cs_n_pe <= 1;
								r_tx_done_pe <= 0;
							end
					end			
			endcase			
		end
		//
		/////////////////Negedge Shifting and Sampling based on Mode Selected////////////////
		//
		reg r_clk_ne, r_cs_n_ne = 1'b1, r_rx_done_ne = 0, r_tx_done_ne = 0, r_mosi_ne;
		reg [3:0] r_bit_index_rx_ne = 0;
		reg [3:0] r_bit_index_tx_ne = 0;
		reg [7:0] r_rx_byte_ne = 0;
		
		always @(negedge i_clk) begin
			case(r_mode)
				mode0:
					begin
						if(i_com_start) 
							begin
								//r_clk_ne <= w_clk;
								r_cs_n_ne <= 0;
								r_mosi_ne <= r_tx_byte[r_bit_index_tx_ne];			/////shifting
								if(r_bit_index_tx_ne < 7)
									begin
										r_bit_index_tx_ne <= r_bit_index_tx_ne + 1;
										r_tx_done_ne <= 0;
									end
								else 
									begin
										r_bit_index_tx_ne <= 0;
										r_tx_done_ne <= 1;
									end
							end
						else 
							begin
								r_clk_ne <= 0;
								r_cs_n_ne <= 1;
								r_rx_done_ne <= 0;
							end
					end
				mode1:
					begin
						if(i_com_start) 
							begin
								//r_clk_ne <= w_clk;
								r_cs_n_ne <= 0;
								r_rx_byte_ne[r_bit_index_rx_ne] <= i_miso;				/////sampling
								if(r_bit_index_rx_ne < 7)
									begin
										r_bit_index_rx_ne <= r_bit_index_rx_ne + 1;
										r_rx_done_ne <= 0;								
									end
								else
									begin
										r_rx_done_ne <= 1;								
										r_bit_index_rx_ne <= 0;
									end
							end
						else 
							begin
								r_clk_ne <= 0;
								r_cs_n_ne <= 1;
								r_tx_done_ne <= 0;
							end
					end
				mode2:
					begin
						if(i_com_start) 
							begin
								//r_clk_ne <= w_clk;
								r_cs_n_ne <= 0;
								r_rx_byte_ne[r_bit_index_rx_ne] <= i_miso;				/////sampling
								if(r_bit_index_rx_ne < 7)
									begin
										r_bit_index_rx_ne <= r_bit_index_rx_ne + 1;
										r_rx_done_ne <= 0;								
									end
								else
									begin
										r_rx_done_ne <= 1;								
										r_bit_index_rx_ne <= 0;
									end
							end
						else 
							begin
								r_clk_ne <= 1;
								r_cs_n_ne <= 1;
								r_tx_done_ne <= 0;
							end
					end
				mode3:
					begin
						if(i_com_start) 
							begin
								//r_clk_ne <= w_clk;
								r_cs_n_ne <= 0;
								r_mosi_ne <= r_tx_byte[r_bit_index_tx_ne];				/////shifting
								if(r_bit_index_tx_ne < 7)
									begin
										r_bit_index_tx_ne <= r_bit_index_tx_ne + 1;
										r_tx_done_ne <= 0;
									end
								else 
									begin
										r_bit_index_tx_ne <= 0;
										r_tx_done_ne <= 1;
									end
							end
						else 
							begin
								r_clk_ne <= 1;
								r_cs_n_ne <= 1;
								r_rx_done_ne <= 0;
							end
					end
			endcase
		end
		
		assign o_mosi = ((r_mode == 1) | (r_mode == 2)) ? r_mosi_pe : r_mosi_ne;
		always @(*) begin
		  r_cs_n = r_cs_n_pe | r_cs_n_ne;
		  r_clk = i_com_start ? w_clk : (r_clk_pe | r_clk_ne);
		  r_tx_done = ((r_mode == 1) | (r_mode == 2)) ? r_tx_done_pe : r_tx_done_ne;
		  r_rx_done = ((r_mode == 1) | (r_mode == 2)) ? r_rx_done_ne : r_rx_done_pe;
		  r_rx_byte = ((r_mode == 1) | (r_mode == 2)) ? r_rx_byte_ne : r_rx_byte_pe;
		end
		
endmodule
