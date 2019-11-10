module user_spaceship_t(KEY, clk, x_out, y_out, c_out);
    
    //User input from the board
    input [2:0] KEY;
    //input [0:0] SW;
    
    input clk;
    
    output wire [7:0] x_out;
    output wire [6:0] y_out;
    output wire [2:0] c_out;
    	 
    /*reg[7:0] x_coord;
    wire[6:0] y_coord;
    wire[3:0] c_coord;*/
    wire resetn, left_in, right_in, go_draw, move_left, move_right;
  //  wire[7:0] x_coord_beam;    
  //  reg[6:0] y_coord_beam; 
    //assign y_coord = 7'b1111000;
    //wire [2:0] user_colour;
    //assign user_colour = 3'b010;
    assign left_in = KEY[2];
    assign right_in = KEY[1];
    //assign x_coord_beam = x_out;
    assign resetn = KEY[0];
    control_user c0(clk, resetn, left_in, right_in, move_left, move_right);
    datapath_user d0(resetn, clk, go_draw, move_left, move_right, x_out, y_out, c_out);
 /*   square_coord sc1(
        .x_in(x_coord),
        .y_in(y_coord),
        .colour(user_colour),
        .resetn(resetn),
        .CLOCK_50(CLOCK_50),
        .go(go_draw),
        .wrieEn(writeEn),
        .x(x_out),
        .y(y_out),
        .c(c_out)
    ); */  
        
endmodule



module control_user(clk, resetn, left_in, right_in, move_left, move_right);
        input clk, resetn, left_in, right_in;

        output reg move_left, move_right;

        reg [3:0] current_state, next_state;

        localparam        U_START = 4'd0,
                          U_MOVE_RIGHT = 4'd1,
                          U_MOVE_LEFT = 4'd2,
                          U_STAY = 4'd3;
//                          U_AT_RIGHT_EDGE = 4'd4,
                          //U_AT_LEFT_EDGE = 4'd5;
              //            U_SHOOT_BEAM = 4'd6,
          

        always@(*)
        begin: state_table
            case (current_state)
            U_START: if (left_in && !right_in) 
                         next_state = U_MOVE_LEFT;
                     else if (right_in && !left_in) next_state = U_MOVE_RIGHT;
                     else next_state = U_STAY;
            //U_AT_RIGHT_EDGE: if (left_in && !right_in) next_state = U_MOVE_LEFT;
//                     else next_state = U_STAY;
//            U_AT_LEFT_EDGE: if (right_in && !left_in) next_state = U_MOVE_RIGHT;
//                     else next_state = U_STAY;
            U_MOVE_RIGHT: if (right_in && !left_in) next_state = U_MOVE_RIGHT;
			else next_state = U_STAY;
            U_MOVE_LEFT:  if (left_in && !right_in) next_state = U_MOVE_LEFT;
			else next_state = U_STAY;
            U_STAY: if (right_in && !left_in) next_state = U_MOVE_RIGHT; 
                    else if (left_in && !right_in) next_state = U_MOVE_LEFT;
                    else next_state = U_STAY;
        
            default: next_state = U_START;
            endcase
            
    end
    
    always @(*) begin : enable_signals
            move_right = 1'b0;
            move_left = 1'b0;
            case (current_state)
            U_MOVE_RIGHT: move_right = 1'b1;
            U_MOVE_LEFT: move_left = 1'b1;
            //U_STAY: move_right = 1'b0; move_left = 1'b0;  
            //U_AT_RIGHT_EDGE: move_right = 1'b0;
            //U_AT_LEFT_EDGE: move_left = 1'b0;
            endcase
    end

    always @(posedge clk)
    begin: state_FFs
        if (!resetn)
             current_state <= U_START;
        else 
             current_state <= next_state;
    end

endmodule

module datapath_user(resetn, clk, go_draw, move_left, move_right, x, y, c);

    input resetn, clk, move_left, move_right;
         
    output reg go_draw;
    output reg [7:0] x;
    output reg [6:0] y;
    output reg [2:0] c;
    wire [19:0] t;
    wire [3:0] f;

    time_counter t0(t, clk, resetn);
    frame_counter f0(f, clk, resetn, t == 20'b0);

    always@(posedge clk, negedge resetn)
        begin
            if (!resetn) begin
                x <= 8'b0;
                y <= 7'b1110100;
                c <= 3'b010;
                go_draw <= 1'b1;
            end                   
            else if (f == 4'b0) begin
                case ({move_right, move_left})
                    
                    2'b00: begin x <= x;
                           c <= 3'b010;
                           go_draw <= 1'b1;
                           end
                    2'b01: begin x <= x + 2'b10;
                           c <= 3'b010;
                           go_draw <= 1'b1;
                           end
                    2'b10: begin x <= x - 2'b10;
                           c <= 3'b010;
                           go_draw <= 1'b1;
                           end
                    2'b11: begin x <= x;
                           c <= 3'b010;
                           go_draw <= 1'b1;
                           end
                   default: x <= x;
                endcase
         end
         else begin
              x <= x;
              y <= y;
              c <= c; 
              go_draw <= 1'b0; 
         end
         end
 endmodule
    
   /* always@(posedge CLK)
        begin
            if (!resetn) 
                y_coord_beam <= 7'b1111000;
             else 
                case (KEY[3])
                    1'b0: if (y_coord_beam == 7'b0000000) 
                              y_coord_beam <= y_out;
                          else 
                              y_coord_beam <= y_coord_beam - 1'b1;
                      
                    1'b1: y_coord_beam <= y_coord_beam;
                    default : y_coord_beam <= y_coord_beam; 
                 
              endcase
           
    end*/



//endmodule
