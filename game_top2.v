`include "part2/vga_adapter/vga_adapter.v"
`include "part2/vga_adapter/vga_address_translator.v"
`include "part2/vga_adapter/vga_controller.v"
`include "part2/vga_adapter/vga_pll.v"
`include "game_alien1.v"
`include "game_alien2.v"
`include "game_alien3.v"
`include "game_alien4.v"
`include "game_alien5.v"
`include "game_alien6.v"
`include "game_alien7.v"
`include "game_alien8.v"
`include "square_coord.v"
`include "counters.v"
`include "user_beam.v"
`include "beam_coord.v"
module game_top2(CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
        KEY, SW,
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]
	);

	input			CLOCK_50;				//	50 MHz
	input   [3:0]   KEY;
	input [0:0] SW;

	// Declare your inputs and outputs here
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]

	wire resetn;
	assign resetn = KEY[0];
	wire go;
	assign go = SW[0];
	wire [7:0] alien1_x, alien2_x, alien3_x, alien4_x, alien5_x, alien6_x, alien7_x, alien8_x, beam_x, x_d;
	wire [6:0] alien1_y, alien2_y, alien3_y, alien4_y, alien5_y, alien6_y, alien7_y, alien8_y, beam_y, y_d;
	reg [2:0] alien1_c, alien2_c, alien3_c, alien4_c, alien5_c, alien6_c, alien7_c, alien8_c, beam_c;
	wire [2:0] c_d;
	reg hit;
	wire [19:0] t_out;
	wire [3:0] f_out;
	wire [14:0] m_out;
	wire done1, done2, done3, done4, done5, done6, done7, done8, done10, go1, go2, go3, go4, go5, go6, go7, go8, go10, m_enable;
	wire a1_status, a2_status, a3_status, a4_status, a5_status, a6_status, a7_status, a8_status, beam_status;
	assign m_enable = (f_out == 4'b0001);
	reg [3:0] num_hits;

	reg [7:0] x;
	reg [6:0] y;
	reg [2:0] colour;
	reg writeEn;

	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "black.mif";

	time_counter t_top(t_out, CLOCK_50, resetn);
	frame_counter f_top(f_out, CLOCK_50, resetn, t_out == 20'b0);
	memory_counter m_top(m_out, CLOCK_50, resetn, m_enable);
	game_alien1 a1(CLOCK_50, resetn, go, alien1_x, alien1_y);
	game_alien2 a2(CLOCK_50, resetn, go, alien2_x, alien2_y);
	game_alien3 a3(CLOCK_50, resetn, go, alien3_x, alien3_y);
	game_alien4 a4(CLOCK_50, resetn, go, alien4_x, alien4_y);
	game_alien5 a5(CLOCK_50, resetn, go, alien5_x, alien5_y);
	game_alien6 a6(CLOCK_50, resetn, go, alien6_x, alien6_y);
	game_alien7 a7(CLOCK_50, resetn, go, alien7_x, alien7_y);
	game_alien8 a8(CLOCK_50, resetn, go, alien8_x, alien8_y);
	user_beam a10(CLOCK_50, resetn, KEY[3], hit, 8'b00110010 + 1'b1, beam_x, beam_y, beam_status); //replace 8'b0 with user x

	control_top c_top(CLOCK_50, resetn, t_out == 20'b0 && f_out == 4'b1111, 
		done1, done2, done3, done4, done5, done6, done7, done8, done10,
		a1_status, a2_status, a3_status, a4_status, a5_status, a6_status, a7_status, a8_status, beam_status,
		go1, go2, go3, go4, go5, go6, go7, go8, go10);
	datapath_top d_top(CLOCK_50, resetn, 
		alien1_x, alien2_x, alien3_x, alien4_x, alien5_x, alien6_x, alien7_x, alien8_x, beam_x,  
		alien1_y, alien2_y, alien3_y, alien4_y, alien5_y, alien6_y, alien7_y, alien8_y, beam_y,
		alien1_c, alien2_c, alien3_c, alien4_c, alien5_c, alien6_c, alien7_c, alien8_c, beam_c,
		go1, go2, go3, go4, go5, go6, go7, go8, go10,
		done1, done2, done3, done4, done5, done6, done7, done8, done10,
		x_d, y_d, c_d);

	always@(*) begin
		if (!resetn) begin
			alien1_c = 3'b100;
			alien2_c = 3'b100;
			alien3_c = 3'b100;
			alien4_c = 3'b100;
			alien5_c = 3'b100;
			alien6_c = 3'b100;
			alien7_c = 3'b100;
			alien8_c = 3'b100;
			beam_c = 3'b111;
			hit = 1'b0;
		end else if (a1_status && (beam_y == alien1_y - 3'b100 || beam_y == alien1_y - 2'b11) && (beam_x == alien1_x || beam_x == alien1_x + 1'b1 || beam_x == alien1_x + 2'b10 || beam_x == alien1_x + 2'b11)) begin
			hit = 1'b1;
			alien1_c = 3'b0;
		end else if (a2_status && (beam_y == alien2_y - 3'b100 || beam_y == alien2_y - 2'b11) && (beam_x == alien2_x || beam_x == alien2_x + 1'b1 || beam_x == alien2_x + 2'b10 || beam_x == alien2_x + 2'b11)) begin
			hit = 1'b1;
			alien2_c = 3'b0;
		end else if (a3_status && (beam_y == alien3_y - 3'b100 || beam_y == alien3_y - 2'b11) && (beam_x == alien3_x || beam_x == alien3_x + 1'b1 || beam_x == alien3_x + 2'b10 || beam_x == alien3_x + 2'b11)) begin
			hit = 1'b1;
			alien3_c = 3'b0;
		end else if (a4_status && (beam_y == alien4_y - 3'b100 || beam_y == alien4_y - 2'b11) && (beam_x == alien4_x || beam_x == alien4_x + 1'b1 || beam_x == alien4_x + 2'b10 || beam_x == alien4_x + 2'b11)) begin
			hit = 1'b1;
			alien4_c = 3'b0;
		end else if (a5_status && (beam_y == alien5_y - 3'b100 || beam_y == alien5_y - 2'b11) && (beam_x == alien5_x || beam_x == alien5_x + 1'b1 || beam_x == alien5_x + 2'b10 || beam_x == alien5_x + 2'b11)) begin
			hit = 1'b1;
			alien5_c = 3'b0;
		end else if (a6_status && (beam_y == alien6_y - 3'b100 || beam_y == alien6_y - 2'b11) && (beam_x == alien6_x || beam_x == alien6_x + 1'b1 || beam_x == alien6_x + 2'b10 || beam_x == alien6_x + 2'b11)) begin
			hit = 1'b1;
			alien6_c = 3'b0;
		end else if (a7_status && (beam_y == alien7_y - 3'b100 || beam_y == alien7_y - 2'b11) && (beam_x == alien7_x || beam_x == alien7_x + 1'b1 || beam_x == alien7_x + 2'b10 || beam_x == alien7_x + 2'b11)) begin
			hit = 1'b1;
			alien7_c = 3'b0;
		end else if (a8_status && (beam_y == alien8_y - 3'b100 || beam_y == alien8_y - 2'b11) && (beam_x == alien8_x || beam_x == alien8_x + 1'b1 || beam_x == alien8_x + 2'b10 || beam_x == alien8_x + 2'b11)) begin
			hit = 1'b1;
			alien8_c = 3'b0;
		end else begin
			hit = 1'b0;
		end
	end

	assign a1_status = alien1_c == 3'b100;
	assign a2_status = alien2_c == 3'b100;
	assign a3_status = alien3_c == 3'b100;
	assign a4_status = alien4_c == 3'b100;
	assign a5_status = alien5_c == 3'b100;
	assign a6_status = alien6_c == 3'b100;
	assign a7_status = alien7_c == 3'b100;
	assign a8_status = alien8_c == 3'b100;
	
	always@(posedge CLOCK_50) begin
		if (!resetn)
			num_hits <= 4'b0;
		else if (hit)
			num_hits <= num_hits + 1'b1;
		else
			num_hits <= num_hits;
	end

	always@(posedge CLOCK_50)
		if (!resetn) begin
			x <= 8'b0;
			y <= 7'b0;
			colour <= 3'b0;
			writeEn <= 1'b0;
		end else if (f_out == 4'b1110) begin
			x <= x_d;
			y <= y_d;
			colour <= c_d;
			writeEn <= 1'b1;
		end else if (f_out == 4'b0001) begin
			x <= m_out[14:7];
			y <= m_out[6:0];
			colour <= 3'b0;
			writeEn <= 1'b1;
		end else begin
			writeEn <= 1'b0;
		end
endmodule

module control_top(clk, resetn, go, 
	done1, done2, done3, done4, done5, done6, done7, done8, done10,
	a1_status, a2_status, a3_status, a4_status, a5_status, a6_status, a7_status, a8_status, beam_status,
	go1, go2, go3, go4, go5, go6, go7, go8, go10);

	input clk, resetn, go, done1, done2, done3, done4, done5, done6, done7, done8, done10;
	input a1_status, a2_status, a3_status, a4_status, a5_status, a6_status, a7_status, a8_status, beam_status;
	output reg go1, go2, go3, go4, go5, go6, go7, go8, go10;

	reg [4:0] current_state, next_state;

	localparam	G_START = 5'd0,
			G_DRAW_1 = 5'd1,
			G_DRAW_2 = 5'd2,
			G_DRAW_3 = 5'd3,
			G_DRAW_4 = 5'd4,
			G_DRAW_5 = 5'd5,
			G_DRAW_6 = 5'd6,
			G_DRAW_7 = 5'd7,
			G_DRAW_8 = 5'd8,
			G_DRAW_BEAM = 5'd10,
			G_END = 5'd11,
			G_DRAW_1_LOAD = 5'd12,
			G_DRAW_2_LOAD = 5'd13,
			G_DRAW_3_LOAD = 5'd14,
			G_DRAW_4_LOAD = 5'd15,
			G_DRAW_5_LOAD = 5'd16,
			G_DRAW_6_LOAD = 5'd17,
			G_DRAW_7_LOAD = 5'd18,
			G_DRAW_8_LOAD = 5'd19,
			G_DRAW_BEAM_LOAD = 5'd21;

	always@(*)
	begin: state_table
		case (current_state)
		G_START: next_state = go ? G_DRAW_1_LOAD: G_START;
		G_DRAW_1_LOAD: next_state = a1_status ? G_DRAW_1: G_DRAW_2_LOAD;
		G_DRAW_1: next_state = done1 ? G_DRAW_2_LOAD: G_DRAW_1;
		G_DRAW_2_LOAD: next_state = a2_status ? G_DRAW_2: G_DRAW_3_LOAD;
		G_DRAW_2: next_state = done2 ? G_DRAW_3_LOAD: G_DRAW_2;
		G_DRAW_3_LOAD: next_state = a3_status ? G_DRAW_3: G_DRAW_4_LOAD;
		G_DRAW_3: next_state = done3 ? G_DRAW_4_LOAD: G_DRAW_3;
		G_DRAW_4_LOAD: next_state = a4_status ? G_DRAW_4: G_DRAW_5_LOAD;
		G_DRAW_4: next_state = done4 ? G_DRAW_5_LOAD: G_DRAW_4;
		G_DRAW_5_LOAD: next_state = a5_status ? G_DRAW_5: G_DRAW_6_LOAD;
		G_DRAW_5: next_state = done1 ? G_DRAW_6_LOAD: G_DRAW_5;
		G_DRAW_6_LOAD: next_state = a6_status ? G_DRAW_6: G_DRAW_7_LOAD;
		G_DRAW_6: next_state = done2 ? G_DRAW_7_LOAD: G_DRAW_6;
		G_DRAW_7_LOAD: next_state = a7_status ? G_DRAW_7: G_DRAW_8_LOAD;
		G_DRAW_7: next_state = done3 ? G_DRAW_8_LOAD: G_DRAW_7;
		G_DRAW_8_LOAD: next_state = a8_status ? G_DRAW_8: G_DRAW_BEAM_LOAD;
		G_DRAW_8: next_state = done4 ? G_DRAW_BEAM_LOAD: G_DRAW_8;
		G_DRAW_BEAM_LOAD: next_state = beam_status ? G_DRAW_BEAM: G_END;
		G_DRAW_BEAM: next_state =  done10 ? G_END: G_DRAW_BEAM;
		default: next_state = G_START;
		endcase
	end

	always @(*)
	begin: enable_signals
		go1 = 1'b0;
		go2 = 1'b0;
		go3 = 1'b0;
		go4 = 1'b0;
		go5 = 1'b0;
		go6 = 1'b0;
		go7 = 1'b0;
		go8 = 1'b0;
		go10 = 1'b0;
		case (current_state)
		G_DRAW_1: go1 = 1'b1;
		G_DRAW_2: go2 = 1'b1;
		G_DRAW_3: go3 = 1'b1;
		G_DRAW_4: go4 = 1'b1;
		G_DRAW_5: go5 = 1'b1;
		G_DRAW_6: go6 = 1'b1;
		G_DRAW_7: go7 = 1'b1;
		G_DRAW_8: go8 = 1'b1;
		G_DRAW_BEAM: go10 = 1'b1;
		endcase
	end

	// current_state registers
	always@(posedge clk)
	begin: state_FFs
		if(!resetn)
			current_state <= G_START;
		else
			current_state <= next_state;
	end
endmodule

module datapath_top(clk, resetn, alien1_x, alien2_x, alien3_x, alien4_x, alien5_x, alien6_x, alien7_x, alien8_x, beam_x,
		alien1_y, alien2_y, alien3_y, alien4_y, alien5_y, alien6_y, alien7_y, alien8_y, beam_y,
		alien1_c, alien2_c, alien3_c, alien4_c, alien5_c, alien6_c, alien7_c, alien8_c, beam_c,
		go1, go2, go3, go4, go5, go6, go7, go8, go10,
		done1, done2, done3, done4, done5, done6, done7, done8, done10,
		x, y, colour);

	input clk, resetn, go1, go2, go3, go4, go5, go6, go7, go8, go10;
	input [7:0] alien1_x, alien2_x, alien3_x, alien4_x, alien5_x, alien6_x, alien7_x, alien8_x, beam_x;
	input [6:0] alien1_y, alien2_y, alien3_y, alien4_y, alien5_y, alien6_y, alien7_y, alien8_y, beam_y;
	input [2:0] alien1_c, alien2_c, alien3_c, alien4_c, alien5_c, alien6_c, alien7_c, alien8_c, beam_c;

	output reg [7:0] x;
	output reg [6:0] y;
	output reg [2:0] colour;
	output wire done1, done2, done3, done4, done5, done6, done7, done8, done10;

	wire wren1, wren2, wren3, wren4, wren5, wren6, wren7, wren8, wren10;
	wire [7:0] a1x, a2x, a3x, a4x, a5x, a6x, a7x, a8x, a10x;
	wire [6:0] a1y, a2y, a3y, a4y, a5y, a6y, a7y, a8y, a10y;
	wire [2:0] a1c, a2c, a3c, a4c, a5c, a6c, a7c, a8c, a10c;

	square_coord s1(alien1_x, alien1_y, alien1_c, resetn, clk, go1, wren1, done1, a1x, a1y, a1c);
	square_coord s2(alien2_x, alien2_y, alien2_c, resetn, clk, go2, wren2, done2, a2x, a2y, a2c);
	square_coord s3(alien3_x, alien3_y, alien3_c, resetn, clk, go3, wren3, done3, a3x, a3y, a3c);
	square_coord s4(alien4_x, alien4_y, alien4_c, resetn, clk, go4, wren4, done4, a4x, a4y, a4c);
	square_coord s5(alien5_x, alien5_y, alien5_c, resetn, clk, go5, wren5, done5, a5x, a5y, a5c);
	square_coord s6(alien6_x, alien6_y, alien6_c, resetn, clk, go6, wren6, done6, a6x, a6y, a6c);
	square_coord s7(alien7_x, alien7_y, alien7_c, resetn, clk, go7, wren7, done7, a7x, a7y, a7c);
	square_coord s8(alien8_x, alien8_y, alien8_c, resetn, clk, go8, wren8, done8, a8x, a8y, a8c);
	beam_coord s10(beam_x, beam_y, beam_c, resetn, clk, go10, wren10, done10, a10x, a10y, a10c);

	always@(*) begin
		if (!resetn) begin
			x = 8'b0;
			y = 7'b0;
			colour = 3'b0;
		end else if (go1) begin
			x = a1x;
			y = a1y;
			colour = a1c;
		end else if (go2) begin
			x = a2x;
			y = a2y;
			colour = a2c;
		end else if (go3) begin
			x = a3x;
			y = a3y;
			colour = a3c;
		end else if (go4) begin
			x = a4x;
			y = a4y;
			colour = a4c;
		end else if (go5) begin
			x = a5x;
			y = a5y;
			colour = a5c;
		end else if (go6) begin
			x = a6x;
			y = a6y;
			colour = a6c;
		end else if (go7) begin
			x = a7x;
			y = a7y;
			colour = a7c;
		end else if (go8) begin
			x = a8x;
			y = a8y;
			colour = a8c;
		end else if (go10) begin
			x = a10x;
			y = a10y;
			colour = a10c;
		end else begin
			x = x;
		end
	end

//	assign done1 = (!wren1);
//	assign done2 = (!wren2);
//	assign done3 = (!wren3);
//	assign done4 = (!wren4);

//	always@(negedge wren1, wren2, wren3, wren4)	begin
//		if (!resetn) 
//			done1 = 1'b0;
//		else if (wren1 == 1'b0)	
//			done1 = 1'b1;
//		else
//			done1 = 1'b0;
//	end
//
//	always@(negedge wren1, wren2, wren3, wren4)	begin
//		if (!resetn) 
//			done2 = 1'b0;
//		else if (wren2 == 1'b0)	
//			done2 = 1'b1;
//		else
//			done2 = 1'b0;
//	end
//
//	always@(negedge wren1, wren2, wren3, wren4)	begin
//		if (!resetn) 
//			done3 = 1'b0;
//		else if (wren3 == 1'b0)	
//			done3 = 1'b1;
//		else
//			done3 = 1'b0;
//	end
//
//	always@(negedge wren1, wren2, wren3, wren4)	begin
//		if (!resetn) 
//			done4 = 1'b0;
//		else if (wren4 == 1'b0)	
//			done4 = 1'b1;
//		else
//			done4 = 1'b0;
//	end
endmodule

module memory_counter(out, clk, resetn, enable);
	input clk, resetn, enable;
	output reg [14:0] out;

	always@(posedge clk) begin
		if (!resetn) out <= 15'b111111111111111;
		else if (out == 15'b0) out <= 15'b111111111111111;
		else if (enable) out <= out - 1'b1;
		else out <= out;
	end
endmodule
