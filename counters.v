module time_counter(out, clk, resetn);
	input clk, resetn;
	output reg [19:0] out;

	always@(posedge clk) begin
	if (!resetn)
		out <= 20'b11001011011100110110;
	else if (out == 20'b0)
		out <= 20'b11001011011100110110;
	else
		out <= out - 1'b1;
	end
endmodule

module frame_counter(out, clk, resetn, enable);
	input clk, resetn, enable;
	output reg [3:0] out;

	always@(posedge clk) begin
	if (!resetn)
		out <= 4'b1111;
	else if (out == 4'b0)
		out <= 4'b1111;
	else if (enable)
		out <= out - 1'b1;
	else
		out <= out;
	end
endmodule