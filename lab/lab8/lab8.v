module Lab8(
    input clk,
    input rst,
    input echo,
    input left_track,
    input right_track,
    input mid_track,
    input start_move,    // if (start == 1) both engines can move
    input start_left_move, // only left engine can move
    input start_right_move, // onle right engine can move
    output trig,
    output IN1,
    output IN2,
    output IN3, 
    output IN4,
    output left_pwm,
    output right_pwm,
    output [15:0] _led,
    output wire [6:0] DISPLAY,    
    output wire [3:0] DIGIT
    // You may modify or add more input/ouput yourself.
);
    // We have connected the motor and sonic_top modules in the template file for you.
    // TODO: control the motors with the information you get from ultrasonic sensor and 3-way track sensor.
    wire [1:0] mode, pre_mode;
    
    sonic_top B(
        .clk(clk), 
        .rst(rst), 
        .Echo(echo), 
        .Trig(trig),
        .distance(distance),
        ._led(_led),
        ._en_left(en_left),
        ._en_right(en_right),
        ._start_move(start_move),
        ._start_left_move(start_left_move),
        ._start_right_move(start_right_move)
    );
    

    motor A(
        .clk(clk),
        .rst(rst),
        .mode(mode),
        .pwm({left_pwm, right_pwm}),
        .l_IN({IN1, IN2}),
        .r_IN({IN3, IN4}),
        .en_left(en_left),
        .en_right(en_right),
        .pre_mode(pre_mode),
        .out_of_control(out_of_control)
    );

    tracker_sensor T(
        .clk(clk),
        .reset(rst),
        .left_track(left_track),
        .right_track(right_track),
        .mid_track(mid_track),
        .state(mode),
        .DISPLAY(DISPLAY),
        .DIGIT(DIGIT),
        .pre_state(pre_mode),
        .start_move(start_move),
        .out_of_control(out_of_control)
    );

endmodule

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
	reg ninety_left = 0, flag_ninety_left = 0;
	reg[29:0] cnt = 30'b0;
	reg big_turn_right = 0, flag_big_turn_right = 0;
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

module motor(
    input clk,
    input rst,
    input [1:0]mode,
    input en_left,
    input en_right,
    input [1:0]pre_mode,
    input out_of_control,
    output [1:0]pwm,
    output [1:0]r_IN,
    output [1:0]l_IN
);

    reg [9:0]left_motor, right_motor;
    wire left_pwm, right_pwm;
    wire [9:0] left_duty, right_duty;
    motor_pwm m0(
        .clk(clk), 
        .reset(rst), 
        .duty(700),
        .pmod_1(left_pwm), 
        .en((en_left && mode[1]))
    );
    motor_pwm m1(
        .clk(clk), 
        .reset(rst), 
        .duty(700), 
        .pmod_1(right_pwm), 
        .en((en_right && mode[0]))
    );

    assign pwm = {left_pwm,right_pwm};
    assign r_IN = (out_of_control) ? 2'b01 : 2'b10;
    assign l_IN = (out_of_control) ? 2'b01 : 2'b10;
    //assign r_IN = 2'b10;
    //assign l_IN = 2'b10;
    // TODO: trace the rest of motor.v and control the speed and direction of the two motors
    

endmodule

module motor_pwm (
    input clk,
    input reset,
    input [9:0] duty,
	output pmod_1, //PWM
    input en
);
        
    PWM_gen pwm_0 (
        .clk(clk), 
        .reset(reset), 
        .freq(32'd25000),
        .duty(duty), 
        .PWM(pmod_1),
        .en(en)
    );

endmodule

//generte PWM by input frequency & duty cycle
module PWM_gen(
    input wire clk,
    input wire reset,
	input [31:0] freq,
    input [9:0] duty,
    output reg PWM,
    input en
);
    wire [31:0] count_max = 100_000_000 / freq;
    wire [31:0] count_duty = count_max * duty / 1024;
    reg [31:0] count;
        
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            count <= 0;
            PWM <= 0;
        end else if (count < count_max) begin
            count <= count + 1;
            // TODO: set <PWM> accordingly
            if(count < count_duty && en) begin
                PWM <= 1;
            end
            else PWM <= 0;
        end else begin
            count <= 0;
            PWM <= 0;
        end
    end
endmodule

module sonic_top(
    input clk, 
    input rst, 
    input Echo,
    output Trig, 
    output [19:0] distance, 
    output [15:0] _led, 
    output _en_left, 
    output _en_right, 
    input _start_move, 
    input _start_left_move, 
    input _start_right_move
);

	wire[19:0] dis;
    wire clk1M;
	wire clk_2_17;

    assign distance = dis;

    div clk1(clk ,clk1M);
	TrigSignal u1(.clk(clk), .rst(rst), .trig(Trig));
	PosCounter u2(
        .clk(clk1M), 
        .rst(rst), 
        .echo(Echo), 
        .distance_count(dis), 
        .led(_led), 
        .en_left(_en_left), 
        .en_right(_en_right), 
        .start_move(_start_move),
        .start_left_move(_start_left_move),
        .start_right_move(_start_right_move)
    );

endmodule

module PosCounter(clk, rst, echo, distance_count, led, en_left, en_right, start_move, start_left_move, start_right_move); 
    input clk, rst, echo;
    output[19:0] distance_count;
    output [15:0] led;
    output en_left, en_right;
    input start_move, start_left_move, start_right_move;

    parameter S0 = 2'b00;
    parameter S1 = 2'b01; 
    parameter S2 = 2'b10;
    
    wire start, finish;
    reg[1:0] curr_state, next_state;
    reg echo_reg1, echo_reg2;
    reg[19:0] count, distance_register;
    wire[19:0] distance_count; 
    wire en;

    always@(posedge clk) begin
        if(rst) begin
            echo_reg1 <= 0;
            echo_reg2 <= 0;
            count <= 0;
            distance_register  <= 0;
            curr_state <= S0;
        end
        else begin
            echo_reg1 <= echo;   
            echo_reg2 <= echo_reg1; 
            case(curr_state)
                S0:begin
                    if (start) curr_state <= next_state; //S1
                    else count <= 0;
                end
                S1:begin
                    if (finish) curr_state <= next_state; //S2
                    else count <= count + 1;
                end
                S2:begin
                    distance_register <= count;
                    count <= 0;
                    curr_state <= next_state; //S0
                end
            endcase
        end
    end

    always @(*) begin
        case(curr_state)
            S0:next_state = S1;
            S1:next_state = S2;
            S2:next_state = S0;
            default:next_state = S0;
        endcase
    end

    assign start = echo_reg1 & ~echo_reg2;  
    assign finish = ~echo_reg1 & echo_reg2;

    // TODO: trace the code and calculate the distance, output it to <distance_count>
    assign distance_count = (17 * distance_register) / 1024 ;
    assign led = (distance_count >= 0 && distance_count < 5) ? 16'b0000_0000_0000_0001:
                 (distance_count >= 5 && distance_count < 10) ? 16'b0000_0000_0000_0011:
                 (distance_count >= 10 && distance_count < 15) ? 16'b0000_0000_0000_0111:
                 (distance_count >= 15 && distance_count < 20) ? 16'b0000_0000_0000_1111:
                 (distance_count >= 20 && distance_count < 25) ? 16'b0000_0000_0001_1111:
                 (distance_count >= 25 && distance_count < 30) ? 16'b0000_0000_0011_1111:
                 (distance_count >= 30 && distance_count < 35) ? 16'b0000_0000_0111_1111:
                 (distance_count >= 35 && distance_count < 40) ? 16'b0000_0000_1111_1111:
                 (distance_count >= 40 && distance_count < 45) ? 16'b0000_0001_1111_1111:
                 (distance_count >= 45 && distance_count < 50) ? 16'b0000_0011_1111_1111 :
                 (distance_count >= 50 && distance_count < 55) ? 16'b0000_0111_1111_1111 :
                 (distance_count >= 55 && distance_count < 60) ? 16'b0000_1111_1111_1111 :
                 (distance_count >= 60 && distance_count < 65) ? 16'b0001_1111_1111_1111 :
                 (distance_count >= 65 && distance_count < 70) ? 16'b0011_1111_1111_1111 :
                 (distance_count >= 70 && distance_count < 75) ? 16'b0111_1111_1111_1111 : 16'b1111_1111_1111_1111;
    assign en_left = (distance_count <= 30 || (!start_move && !start_left_move)) ? 0 : 1;
    assign en_right = (distance_count <= 30 || (!start_move && !start_right_move)) ? 0 : 1;
endmodule

// send trigger signal to sensor
module TrigSignal(clk, rst, trig);
    input clk, rst;
    output trig;

    reg trig, next_trig;
    reg[23:0] count, next_count;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            count <= 0;
            trig <= 0;
        end
        else begin
            //count <= next_count;
            trig <= next_trig;
            if(count <= 24'd10000999) count <= next_count;
            else count <= 0;
        end
    end

    // count 10us to set <trig> high and wait for 100ms, then set <trig> back to low
    always @(*) begin
        //next_trig = trig;
        next_count = count + 1;   
        // TODO: set <next_trig> and <next_count> to let the sensor work properly
        
        if(count >= 0 && count <= 999) begin
            next_trig = 1;
        end else next_trig = 0;
    end
endmodule

// clock divider for T = 1us clock
module div(clk ,out_clk);
    input clk;
    output out_clk;
    reg out_clk;
    reg [6:0]cnt;
    
    always @(posedge clk) begin   
        if(cnt < 7'd50) begin
            cnt <= cnt + 1'b1;
            out_clk <= 1'b1;
        end 
        else if(cnt < 7'd100) begin
	        cnt <= cnt + 1'b1;
	        out_clk <= 1'b0;
        end
        else if(cnt == 7'd100) begin
            cnt <= 0;
            out_clk <= 1'b1;
        end
    end
endmodule