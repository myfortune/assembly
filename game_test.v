`include "game_alien1.v"
`include "game_alien2.v"
`include "game_alien3.v"
`include "game_alien4.v"
`include "square_coord.v"
`include "test_counters.v"
`include "user_beam_test.v"
`include "beam_coord.v"
`include "user_spaceship_t.v"
module game_test(CLOCK_50, KEY, go);
	input CLOCK_50, go;
	input [3:0] KEY;

	wire resetn;
	assign resetn = KEY[0];
	wire [7:0] alien1_x, alien2_x, alien3_x, alien4_x, beam_x, ship_x, x_d;
	wire [6:0] alien1_y, alien2_y, alien3_y, alien4_y, beam_y, ship_y, y_d;
	wire [2:0] ship_c;
	reg [2:0] alien1_c, alien2_c, alien3_c, alien4_c, beam_c;
	reg hit;
	wire [2:0] c_d;
	wire [19:0] t_out;
	wire [3:0] f_out;
	wire [14:0] m_out;
	wire done1, done2, done3, done4, done9, done10, go1, go2, go3, go4, go9, go10, m_enable, beam_status;
	wire a1_status, a2_status, a3_status, a4_status;
	assign m_enable = (f_out == 4'b0001);

	reg [7:0] x;
	reg [6:0] y;
	reg [2:0] colour;
	reg writeEn;

	time_counter t_top(t_out, CLOCK_50, resetn);
	frame_counter f_top(f_out, CLOCK_50, resetn, t_out == 20'b0);
	memory_counter m_top(m_out, CLOCK_50, resetn, m_enable);
	game_alien1 a1(CLOCK_50, resetn, go, alien1_x, alien1_y);
	game_alien2 a2(CLOCK_50, resetn, go, alien2_x, alien2_y);
	game_alien3 a3(CLOCK_50, resetn, go, alien3_x, alien3_y);
	game_alien4 a4(CLOCK_50, resetn, go, alien4_x, alien4_y);
	user_spaceship_t a9(KEY[2:0], CLOCK_50, ship_x, ship_y, ship_c);
	user_beam a10(CLOCK_50, resetn, KEY[3], hit, ship_x + 1'b1, beam_x, beam_y, beam_status); //replace 8'b0 with user x

	control_top c_top(CLOCK_50, resetn, t_out == 20'b0 && f_out == 4'b1111, 
		done1, done2, done3, done4, done9, done10, 
		a1_status, a2_status, a3_status, a4_status, beam_status,
		go1, go2, go3, go4, go9, go10);
	datapath_top d_top(CLOCK_50, resetn, 
		alien1_x, alien2_x, alien3_x, alien4_x, ship_x, beam_x,
		alien1_y, alien2_y, alien3_y, alien4_y, ship_y, beam_y,
		alien1_c, alien2_c, alien3_c, alien4_c, ship_c, beam_c,
		go1, go2, go3, go4, go9, go10,
		done1, done2, done3, done4, done9, done10,
		x_d, y_d, c_d);

	always@(*) begin
		if (!resetn) begin
			alien1_c = 3'b100;
			alien2_c = 3'b100;
			alien3_c = 3'b100;
			alien4_c = 3'b100;
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
		end else begin
			hit = 1'b0;
		end
	end

	assign a1_status = alien1_c == 3'b100;
	assign a2_status = alien2_c == 3'b100;
	assign a3_status = alien3_c == 3'b100;
	assign a4_status = alien4_c == 3'b100;

	always@(posedge CLOCK_50)
		if (!resetn) begin
			x <= 8'b0;
			y <= 7'b0;
			colour <= 3'b0;
			writeEn <= 1'b0;
		end else if (f_out == 4'b1110 || f_out == 4'b1101 || f_out == 4'b1100) begin
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

module control_top(clk, resetn, go, done1, done2, done3, done4, done9, done10, 
	a1_status, a2_status, a3_status, a4_status, beam_status, 
	go1, go2, go3, go4, go9, go10);
	input clk, resetn, go, done1, done2, done3, done4, done9, done10, a1_status, a2_status, a3_status, a4_status, beam_status;
	output reg go1, go2, go3, go4, go9, go10;

	reg [4:0] current_state, next_state;

	localparam	G_START = 5'd0,
			G_DRAW_1 = 5'd1,
			G_DRAW_2 = 5'd2,
			G_DRAW_3 = 5'd3,
			G_DRAW_4 = 5'd4,
			G_DRAW_SHIP = 5'd9,
			G_DRAW_BEAM = 5'd10,
			G_END = 5'd11,
			G_DRAW_1_LOAD = 5'd12,
			G_DRAW_2_LOAD = 5'd13,
			G_DRAW_3_LOAD = 5'd14,
			G_DRAW_4_LOAD = 5'd15,
			G_DRAW_SHIP_LOAD = 5'd20,
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
		G_DRAW_4_LOAD: next_state = a4_status ? G_DRAW_4: G_DRAW_BEAM_LOAD;
		G_DRAW_4: next_state = done4 ? G_DRAW_SHIP_LOAD: G_DRAW_4;
		G_DRAW_SHIP_LOAD: next_state = G_DRAW_SHIP;
		G_DRAW_SHIP: next_state = done9 ? G_DRAW_BEAM_LOAD: G_DRAW_SHIP;
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
		go9 = 1'b0;
		go10 = 1'b0;
		case (current_state)
		G_DRAW_1: go1 = 1'b1;
		G_DRAW_2: go2 = 1'b1;
		G_DRAW_3: go3 = 1'b1;
		G_DRAW_4: go4 = 1'b1;
		G_DRAW_SHIP: go9 = 1'b1;
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

module datapath_top(clk, resetn, 
	alien1_x, alien2_x, alien3_x, alien4_x, ship_x, beam_x,
	alien1_y, alien2_y, alien3_y, alien4_y, ship_y, beam_y,
	alien1_c, alien2_c, alien3_c, alien4_c, ship_c, beam_c,
	go1, go2, go3, go4, go9, go10, 
	done1, done2, done3, done4, done9, done10, 
	x, y, colour);
	input clk, resetn, go1, go2, go3, go4, go9, go10;
	input [7:0] alien1_x, alien2_x, alien3_x, alien4_x, ship_x, beam_x;
	input [6:0] alien1_y, alien2_y, alien3_y, alien4_y, ship_y, beam_y;
	input [2:0] alien1_c, alien2_c, alien3_c, alien4_c, ship_c, beam_c;

	output reg [7:0] x;
	output reg [6:0] y;
	output reg [2:0] colour;
	output wire done1, done2, done3, done4, done9, done10;

	wire wren1, wren2, wren3, wren4, wren9, wren10;
	wire [7:0] a1x, a2x, a3x, a4x, a9x, a10x;
	wire [6:0] a1y, a2y, a3y, a4y, a9y, a10y;
	wire [2:0] a1c, a2c, a3c, a4c, a9c, a10c;

	square_coord s1(alien1_x, alien1_y, alien1_c, resetn, clk, go1, wren1, done1, a1x, a1y, a1c);
	square_coord s2(alien2_x, alien2_y, alien2_c, resetn, clk, go2, wren2, done2, a2x, a2y, a2c);
	square_coord s3(alien3_x, alien3_y, alien3_c, resetn, clk, go3, wren3, done3, a3x, a3y, a3c);
	square_coord s4(alien4_x, alien4_y, alien4_c, resetn, clk, go4, wren4, done4, a4x, a4y, a4c);
	square_coord s9(ship_x, ship_y, ship_c, resetn, clk, go9, wren9, done9, a9x, a9y, a9c);
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
		end else if (go9) begin
			x = a9x;
			y = a9y;
			colour = a10c;		
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
		if (!resetn) out <= 15'b000000000000111; //15'b111111111111111;
		else if (out == 15'b0) out <= 15'b000000000000111; //15'b111111111111111;
		else if (enable) out <= out - 1'b1;
		else out <= out;
	end
endmodule
