module tracker_sensor(
    input clk, 
    input reset, 
    input left_track, 
    input right_track, 
    input mid_track,
	input start_move,
    output reg [1:0] state, 
    output wire [6:0] DISPLAY, 
    output wire [3:0] DIGIT,
	output reg [1:0] pre_state,
	output wire out_of_control
);

	assign out_of_control = 0;
    // TODO: Receive three tracks and make your own policy.
    // Hint: You can use output state to change your action.
    SevenSegment S(
        .display(DISPLAY),
        .digit(DIGIT),
        .nums({2'b00, state , 3'b000, left_track, 3'b000, mid_track, 3'b000, right_track}),
        .rst(reset),
        .clk(clk)
    );
	parameter turn_left = 2'b10 ;
    parameter go_straight = 2'b11;
    parameter turn_right = 2'b01;
    parameter stop = 2'b00;
	reg direction, ninety_left = 0, ninety_right = 0, flag_ninety_left = 0;
	reg[29:0] cnt = 30'b0, cnt_left_turn = 30'b0, cnt_right_turn = 30'b0, cnt_calibrate = 30'b0;
	reg flag = 0, calibrate = 0, big_turn_right = 0, flag_big_turn_right = 0;
	wire out_the_track = 0;
    wire [2:0] sensor = {left_track, mid_track, right_track};
    //state
    always @(posedge clk, posedge reset) begin
        if(reset) begin
			state <= go_straight;
			pre_state <= go_straight;
			big_turn_right <= 0;
			flag_big_turn_right <= 0;
			cnt <= 0;
		end
        else begin
			if(big_turn_right) begin
				flag_big_turn_right <= 0;
				if(cnt < 30'd35000000) begin
					cnt <= cnt + 1;
					state <= go_straight;
				end
				else begin
					if(sensor != 3'b101 && sensor != 3'b011) begin
						state <= turn_right;
					end
					else begin
						state <= go_straight;
						cnt <= 0;
						big_turn_right <= 0;
					end
				end
			end
			else if(ninety_left) begin
				flag_ninety_left <= 0;
				if(cnt < 30'd35000000) begin
					cnt <= cnt + 1;
					state <= go_straight;
				end
				else begin
					if(sensor != 3'b101 && sensor != 3'b110) state <= turn_left;
					else begin
						state <= go_straight;
						cnt <= 0;
						ninety_left <= 0;
					end
				end
			end
			else begin
				case(state)
				go_straight: begin
					if(sensor == 3'b101 || (!left_track && !right_track)) begin
						state <= state;
						pre_state <= pre_state;
					end
					else if(!left_track) begin
						state <= turn_left;
						pre_state <= pre_state;
						if(sensor == 3'b001) flag_ninety_left <= 1;
						else flag_ninety_left <= flag_ninety_left;
					end
					else if(!right_track) begin
						state <= turn_right;
						pre_state <= pre_state;
						if(sensor == 3'b100) flag_big_turn_right <= 1;
						else flag_big_turn_right <= flag_big_turn_right;
					end
					else begin
						if(flag_big_turn_right) begin
							big_turn_right <= 1;
						end
						else if(flag_ninety_left) begin
							ninety_left <= 1;
						end
						else begin
							state <= (pre_state == turn_left) ? turn_right :
									(pre_state == turn_right) ? turn_left : go_straight; 
						end
					end
				end
				turn_left: begin
					if(!mid_track) begin
						state <= go_straight;
						pre_state <= turn_left;
						if(sensor == 3'b100) flag_big_turn_right <= 1;
						else flag_big_turn_right <= flag_big_turn_right;
						if(sensor == 3'b001) flag_ninety_left <= 1;
						else flag_ninety_left <= flag_ninety_left;
					end
					else if(!left_track) begin
						state <= turn_left;
						pre_state <= pre_state;
					end
					else if(!right_track) begin
						state <= turn_right;
						pre_state <= turn_left;
					end
					else begin
						if(flag_big_turn_right) begin
							big_turn_right <= 1;
						end
						else if(flag_ninety_left) begin
							ninety_left <= 1;
						end
						else begin
							state <= (pre_state == turn_left) ? turn_right :
									(pre_state == turn_right) ? turn_left : go_straight; 
						end
					end
				end
				turn_right: begin
					if(!mid_track) begin
						state <= go_straight;
						pre_state <= turn_right;
						if(sensor == 3'b100) flag_big_turn_right <= 1;
						else flag_big_turn_right <= flag_big_turn_right;
						if(sensor == 3'b001) flag_ninety_left <= 1;
						else flag_ninety_left <= flag_ninety_left;
					end
					else if(!left_track) begin
						state <= turn_left;
						pre_state <= turn_right;
					end
					else if(!right_track) begin
						state <= turn_right;
						pre_state <= pre_state;
					end
					else begin
						if(flag_big_turn_right) begin
							big_turn_right <= 1;
						end
						else if(flag_ninety_left) begin
							ninety_left <= 1;
						end
						else begin
							state <= (pre_state == turn_left) ? turn_right :
									(pre_state == turn_right) ? turn_left : go_straight; 
						end
					end
				end
				default: state <= state;
				endcase
			end

        end
    end
    
endmodule

module SevenSegment(
	output reg [6:0] display,
	output reg [3:0] digit,
	input wire [15:0] nums,
	input wire rst,
	input wire clk
    );
    
    reg [15:0] clk_divider;
    reg [3:0] display_num;
    
    always @ (posedge clk, posedge rst) begin
    	if (rst) begin
    		clk_divider <= 15'b0;
    	end else begin
    		clk_divider <= clk_divider + 15'b1;
    	end
    end
    
    always @ (posedge clk_divider[15], posedge rst) begin
    	if (rst) begin
    		display_num <= 4'b0000;
    		digit <= 4'b1111;
    	end else begin
    		case (digit)
    			4'b1110 : begin
    					display_num <= nums[7:4];
    					digit <= 4'b1101;
    				end
    			4'b1101 : begin
						display_num <= nums[11:8];
						digit <= 4'b1011;
					end
    			4'b1011 : begin
						display_num <= nums[15:12];
						digit <= 4'b0111;
					end
    			4'b0111 : begin
						display_num <= nums[3:0];
						digit <= 4'b1110;
					end
    			default : begin
						display_num <= nums[3:0];
						digit <= 4'b1110;
					end				
    		endcase
    	end
    end
    
    always @ (*) begin
    	case (display_num)
    		0 : display = 7'b1000000;	//0000
			1 : display = 7'b1111001;   //0001                                                
			2 : display = 7'b0100100;   //0010                                                
			3 : display = 7'b0110000;   //0011                                             
			4 : display = 7'b0011001;   //0100                                               
			5 : display = 7'b0010010;   //0101                                               
			6 : display = 7'b0000010;   //0110
			7 : display = 7'b1111000;   //0111
			8 : display = 7'b0000000;   //1000
			9 : display = 7'b0010000;	//1001
            10: display = 7'b0111111;   //minus
			default : display = 7'b1111111;
    	endcase
    end
    
endmodule