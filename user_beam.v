module user_beam(clk, resetn, shoot, hit, x_in, x, y, mv_u);
	input clk, resetn, shoot, hit;
	input [7:0] x_in;

	output wire [7:0] x;
	output wire [6:0] y;
	output wire mv_u;

	wire done, ld_x;

	control_beam c10(clk, resetn, shoot, hit, done, ld_x, mv_u);
	datapath_beam d10(clk, resetn, x_in, ld_x, mv_u, done, x, y);
endmodule

module control_beam(clk, resetn, shoot, hit, done, ld_x, mv_u);
	input clk, resetn, shoot, hit, done;
	output reg ld_x, mv_u;

	reg [1:0] current_state, next_state;

	localparam	B_START = 2'd0,
			B_LOAD_X = 2'd1,
			B_UP = 2'd2,
			B_END = 2'd3;

	// Next state logic aka state table
	always@(*)
	begin: state_table
		case (current_state)
		B_START: next_state = shoot ? B_LOAD_X: B_START;
		B_LOAD_X: next_state = B_UP;
		B_UP: next_state = (hit || done) ? B_END: B_UP;
		B_END: next_state = B_START;
		default: next_state = B_START;
		endcase
	end

	always @(*)
	begin: enable_signals
		mv_u = 1'b0;
		ld_x = 1'b0;
		case (current_state)
		B_LOAD_X: ld_x = 1'b1;
		B_UP: mv_u = 1'b1;
		endcase
	end

	// current_state registers
	always@(posedge clk)
	begin: state_FFs
		if(!resetn)
			current_state <= B_START;
		else
			current_state <= next_state;
	end
endmodule

module datapath_beam(clk, resetn, x_in, ld_x, mv_u, done, x, y);
	input clk, resetn, ld_x, mv_u;
	input [7:0] x_in;
	output reg done;
	output reg [7:0] x;
	output reg [6:0] y;

	wire [19:0] t;
	wire [3:0] f;

	time_counter t10(t, clk, resetn);
	frame_counter f10(f, clk, resetn, t == 20'b0);

	always@(posedge clk) begin
		if (!resetn) done <= 1'b0;
		else if (y == 7'b0) done <= 1'b1;
		else done <= 1'b0;
	end

	always@(posedge clk) begin
		if (!resetn) begin
			x <= 8'b0;
			y <= 7'b1110000;
		end else if (ld_x) begin
			x <= x_in;
			y <= 7'b1110000;
		end else if (f == 4'b0 && mv_u) begin
			y <= y - 3'b100;
		end else begin
			y <= y;
		end
	end
endmodule