module game_alien7(clk, resetn, go, x, y);
	input clk, resetn, go;
	output wire [7:0] x;
	output wire [6:0] y;

	wire down, done, mv_r, mv_l, mv_d;

	control_alien7 c7(clk, resetn, go, down, done, mv_r, mv_l, mv_d);
	datapath_alien7 d7(clk, resetn, mv_r, mv_l, mv_d, down, done, x, y);
endmodule

module control_alien7(clk, resetn, go, down, done, mv_r, mv_l, mv_d);
	input clk, resetn, go, down, done;
	output reg mv_r, mv_l, mv_d;

	reg [2:0] current_state, next_state;

	localparam	A_START = 3'd0,
			A_RIGHT = 3'd1,
			A_DOWN_LEFT = 3'd2,
			A_LEFT = 3'd3,
			A_DOWN_RIGHT = 3'd4,
			A_END = 3'd5;

	// Next state logic aka state table
	always@(*)
	begin: state_table
		case (current_state)
		A_START: next_state = go ? A_RIGHT: A_START;
		A_RIGHT: next_state = down ? A_DOWN_LEFT: A_RIGHT;
		A_DOWN_LEFT: next_state = done ? A_END: A_LEFT;
		A_LEFT: next_state = down ? A_DOWN_RIGHT: A_LEFT;
		A_DOWN_RIGHT: next_state = done ? A_END: A_RIGHT;
		A_END: next_state = A_START;
		default: next_state = A_START;
		endcase
	end

	always @(*)
	begin: enable_signals
		mv_r = 1'b0;
		mv_l = 1'b0;
		mv_d = 1'b0;
		case (current_state) 
		A_RIGHT: mv_r = 1'b1;
		A_DOWN_LEFT: mv_d = 1'b1;
		A_LEFT: mv_l = 1'b1;
		A_DOWN_RIGHT: mv_d = 1'b1;
		endcase
	end

	// current_state registers
	always@(posedge clk)
	begin: state_FFs
		if(!resetn)
			current_state <= A_START;
		else
			current_state <= next_state;
	end
endmodule

module datapath_alien7(clk, resetn, mv_r, mv_l, mv_d, down, done, x, y);
	input clk, resetn, mv_r, mv_l, mv_d;
	output reg down, done;
	output reg [7:0] x;
	output reg [6:0] y;

	wire [19:0] t;
	wire [3:0] f;

	time_counter t7(t, clk, resetn);
	frame_counter f7(f, clk, resetn, t == 20'b0);

	always@(posedge clk) begin
		if(!resetn) begin
			down = 1'b0;
			done = 1'b0;
		end else begin
			if (y > 7'b1101111) begin
				done = 1'b1;
			end else if (x == 8'b01101010 && mv_r) begin //106
				down = 1'b1;
			end else if (x == 8'b01100010 && mv_l) begin //98
				down = 1'b1;
			end else begin
				down = 1'b0;
				done = 1'b0;
			end
		end
	end

	always@(posedge clk) begin
		if (!resetn) begin
			x <= 8'b01100010; //98
			y <= 7'b0001111;
		end else if (f == 4'b0 && mv_r) begin
			x <= x + 1'b1;
		end else if (f == 4'b0 && mv_l) begin
			x <= x - 1'b1;
		end else if (mv_d) begin
			y <= y + 3'b100;
		end else begin
			x <= x;
		end
	end
endmodule