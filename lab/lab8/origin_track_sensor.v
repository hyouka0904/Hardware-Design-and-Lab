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
	output reg out_of_control
);

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
	reg direction, ninety_left_0 = 0, ninety_right_0 = 0, ninety_right_1 = 0, ninety_left_1 = 0;
	reg[29:0] cnt = 30'b0, cnt_left_turn_0 = 30'b0, cnt_right_turn_0 = 30'b0, cnt_calibrate = 30'b0, cnt_left_turn_1 = 30'b0, cnt_right_turn_1 = 30'b0;
	reg flag_0 = 0, calibrate_0 = 0, flag_1 = 0, calibrate_1 = 0;
	wire out_the_track = 0;
    reg [29:0]cnt_out_of_control = 0;


	always @(posedge clk, posedge reset) begin
		if(reset) begin
			cnt_out_of_control <= 0;
			out_of_control <= 0;
		end
		else begin
			if(start_move) begin
				if({left_track, mid_track, right_track} == 3'b111) begin
					if(cnt_out_of_control < 30'd330000000) begin
						cnt_out_of_control <= cnt_out_of_control + 1;
						out_of_control <= 0;
					end
					else begin
						out_of_control <= 1;
						cnt_out_of_control <= 30'd330000001;
					end
				end
				else begin
					cnt_out_of_control <= 0;
					out_of_control <= 0;
				end
			end
			else begin
				cnt_out_of_control <= 0;
				out_of_control <= 0;
			end
		end
	end

    always @(posedge clk, posedge reset) begin
        if(reset) begin
			state <= go_straight;
			direction <= 0;
			ninety_left_0 <= 0;
			ninety_right_0 <= 0;
			flag_0 <= 0;
			cnt_left_turn_0 <= 0;
			cnt <= 0;
			calibrate_0 <= 0;
			calibrate_1 <= 0;
			cnt_calibrate <= 0;
			cnt_right_turn_0 <= 0;
			cnt_left_turn_1 <= 0;
			cnt_right_turn_1 <= 0;
		end
		else if(out_of_control) begin
			/*if({left_track, mid_track, right_track} == 3'b111) state <= go_straight;
			else begin
				if(direction) state <= turn_left;
				else state <= turn_right;
			end*/
			state <= go_straight;
		end
		else if(!start_move) begin
			if({left_track, mid_track, right_track} == 3'b110 || {left_track, mid_track, right_track} == 3'b100)
				direction <= 0;
			else if({left_track, mid_track, right_track} == 3'b011 || {left_track, mid_track, right_track} == 3'b001)
				direction <= 1;
			else direction <= 0;
		end 
		else begin
			if(ninety_left_0) begin
				flag_0 <= 1'b0;
				if(cnt != 30'd30000000 && cnt_left_turn_0 == 0) begin
					cnt <= cnt + 1;
					state <= go_straight;
				end
				else begin
					cnt <= 0;
					if(cnt_left_turn_0 != 30'd100000000 && {left_track, mid_track, right_track} != 3'b110) begin
						cnt_left_turn_0 <= cnt_left_turn_0 + 1;
						state <= turn_left;
					end
					else begin
						state <= go_straight;
						cnt_left_turn_0 <= 0;
						ninety_left_0 <= 0;
					end
				end
			end else if(ninety_right_0) begin
				if(cnt_right_turn_0 != 30'd100000000 && {right_track, mid_track, left_track} != 3'b011) begin
					cnt_right_turn_0 <= cnt_right_turn_0 + 1;
					state <= turn_right;
				end
				else begin
					state <= go_straight;
					cnt_right_turn_0 <= 0;
					ninety_right_0 <= 0;
				end
			end
			else if(ninety_right_1) begin
				flag_1 <= 0;
				if(cnt != 30'd30000000 && cnt_right_turn_1 == 0) begin
					cnt <= cnt + 1;
					state <= go_straight;
				end
				else begin
					cnt <= 0;
					if(cnt_right_turn_1 != 30'd100000000 && {right_track, mid_track, left_track} != 3'b110) begin
						cnt_right_turn_1 <= cnt_right_turn_1 + 1;
						state <= turn_right;
					end
					else begin
						state <= go_straight;
						cnt_right_turn_1 <= 0;
						ninety_right_1 <= 0;
					end
				end
			end
			else if(ninety_left_1) begin
				if(cnt_left_turn_1 != 30'd100000000 && {right_track, mid_track, left_track} == 3'b111) begin
					cnt_left_turn_1 <= cnt_left_turn_1 + 1;
					state <= turn_left;
				end
				else begin
					state <= go_straight;
					cnt_left_turn_1 <= 0;
					ninety_left_1 <= 0;
				end
			end
			else begin
				if(direction == 0) begin
					if(state == turn_left || state == turn_right) pre_state <= state;
					case({left_track, mid_track, right_track})
						3'b010, 3'b110: begin
							if({left_track, mid_track, right_track} == 3'b110) begin
								direction <= 1;
								calibrate_0 <= 1;
							end
							else calibrate_0 <= 0;
							state <= go_straight;
							cnt_right_turn_0 <= 0;
						end
						3'b001, 3'b011, 3'b101, 3'b100: begin
							state <= turn_left;
							calibrate_0 <= 0;
							cnt_right_turn_0 <= 0;
						end
						3'b000: begin
							state <= turn_right;
							flag_0 <= 1'b1;
							calibrate_0 <= 0;
							cnt_right_turn_0 <= 0;
						end
						3'b111: begin
							if(flag_0) begin
								ninety_left_0 <= 1;
								ninety_right_0 <= 0;
								calibrate_0 <= 0;
								cnt_right_turn_0 <= 0;
							end
							else begin
								ninety_left_0 <= 1'b0; 
								if(cnt_right_turn_0 != 30'd30000000) begin
									cnt_right_turn_0 <= cnt_right_turn_0 + 1;
									if(calibrate_0) state <= turn_right;
									else state <= go_straight;									
								end
								else begin
									ninety_right_0 <= 1;
									cnt_right_turn_0 <= 0;
								end
							end
						end
						default: begin
							state <= go_straight;
						end
					endcase			
				end
				else begin
					case({left_track, mid_track, right_track})
						3'b010, 3'b011: begin
							if({left_track, mid_track, right_track} == 3'b011) begin
								direction <= 0;
								calibrate_1 <= 1;
							end
							else calibrate_1 <= 0;
							state <= go_straight;
							cnt_left_turn_1 <= 0;
						end
						3'b100, 3'b101, 3'b110, 3'b001: begin
							state <= turn_right;
							cnt_left_turn_1 <= 0;
							calibrate_1 <= 0;
						end
						3'b000: begin
							state <= turn_left;
							flag_1 <= 1;
							cnt_left_turn_1 <= 0;
							calibrate_1 <= 0;
						end
						3'b111: begin
							if(flag_1) begin
								ninety_right_1 <= 1;
								ninety_left_1 <= 0;
								calibrate_1 <= 0;
								cnt_left_turn_1 <= 0;
							end
							else begin
								ninety_right_1 <= 0;
								if(cnt_left_turn_1 != 30'd30000000) begin
									cnt_left_turn_1 <= cnt_left_turn_1 + 1;
									if(calibrate_1) state <= turn_left;
									else state <= go_straight;
								end
								else begin
									ninety_left_1 <= 1;
									cnt_left_turn_1 <= 0;
								end
							end
						end
						default: state <= go_straight;
					endcase			
				end
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
