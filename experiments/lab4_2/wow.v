module clock_divider #(
    parameter n = 27
)(
    input wire  clk,
    output wire clk_div  
);

    reg [n-1:0] num;
    wire [n-1:0] next_num;

    always @(posedge clk) begin
        num <= next_num;
    end

    assign next_num = num + 1;
    assign clk_div = num[n-1];
endmodule
module clock_100Hz(input wire clk, output wire clk_100Hz);
    reg[23:0] Q;
    reg ms;
    always @(posedge clk) begin
        ms <= 0;
        if(Q == 24'd499999) begin
            Q<=0;
            ms<=!clk_100Hz;
        end else begin
            Q<=Q+1'b1;
            ms<=clk_100Hz;
        end
    end
    assign clk_100Hz = ms;
endmodule
module debounce (
	input wire clk,
	input wire pb, 
	output wire pb_debounced 
);
	reg [10:0] shift_reg; 

	always @(posedge clk) begin
		shift_reg[10:1] <= shift_reg[9:0];
		shift_reg[0] <= pb;
	end

	assign pb_debounced = ((shift_reg == 11'b11111111111) ? 1'b1 : 1'b0);

endmodule
module one_pulse (
    input wire clk,
    input wire pb_in,
    output reg pb_out
);

	reg pb_in_delay;

	always @(posedge clk) begin
		if (pb_in == 1'b1 && pb_in_delay == 1'b0) begin
			pb_out <= 1'b1;
		end else begin
			pb_out <= 1'b0;
		end
	end
	
	always @(posedge clk) begin
		pb_in_delay <= pb_in;
	end
endmodule
module lab4_2 ( 
    input wire clk,
    input wire rst,
    input wire Digit_1,
    input wire Digit_2,
    input wire Digit_3,
    input wire stop,
    input wire start,
    input wire increase,
    input wire decrease,
    input wire direction,
    output reg [3:0] DIGIT,
    output reg [6:0] DISPLAY,
    output reg [15:0] led
); 
    /* Note that output ports can be either reg or wire. 
    * It depends on how you design your module. */
    // add your design here

    //declaration
    wire increase_deb, increase_one_pulse;
    wire decrease_deb, decrease_one_pulse;
    wire stop_deb, stop_one_pulse;
    wire start_deb, start_one_pulse;
    wire direction_deb, direction_one_pulse;
    wire clk_100Hz, clk_div15;

    reg dir = 1'b1;
    reg [3:0] next_digit=0;
    reg [3:0] next_display=0;
    reg [15:0] next_led=0;
    reg [1:0] state=0, next_state=0;

    integer target=0, next_target=0, next_target_digit1=0, next_target_digit2=0, next_target_digit3=0;
    integer val=0, next_val=0;
    integer diff_val_target=0;
    integer next_led_flash_cnt=0, led_flash_cnt=0;

    parameter init = 2'b00;
    parameter counting = 2'b01;
    parameter fail = 2'b10;
    parameter success = 2'b11;
    parameter zero = 7'b1000000;
    parameter one = 7'b1111001;
    parameter two = 7'b0100100;
    parameter three = 7'b0110000;
    parameter four = 7'b0011001;
    parameter five = 7'b0010010;
    parameter six = 7'b0000010;
    parameter seven = 7'b1111000;
    parameter eight = 7'b0;
    parameter nine = 7'b0010000;
    parameter up = 7'b1011100;//10
    parameter down = 7'b1100011;//11
    parameter dash = 7'b0111111;//12
    parameter S = 7'b0010010;//13
    parameter F = 7'b0001110;//14
    parameter Void = 7'b1111111;//15
    parameter led_all_on  = 16'b1111111111111111;
    parameter led_all_off = 16'b0;
    //module inplementation
    clock_divider #(15) div1(.clk(clk), .clk_div(clk_div15));
    clock_100Hz clock1(.clk(clk), .clk_100Hz(clk_100Hz));
    debounce stop_debounce(.clk(clk_100Hz), .pb(stop), .pb_debounced(stop_deb));
    one_pulse one_pulse_stop(.clk(clk_100Hz), .pb_in(stop_deb), .pb_out(stop_one_pulse));
    debounce start_debounce(.clk(clk_100Hz), .pb(start), .pb_debounced(start_deb));
    one_pulse one_pulse_start(.clk(clk_100Hz), .pb_in(start_deb), .pb_out(start_one_pulse));
    debounce increase_debounce(.clk(clk_100Hz), .pb(increase), .pb_debounced(increase_deb));
    one_pulse one_pulse_increase(.clk(clk_100Hz), .pb_in(increase_deb), .pb_out(increase_one_pulse));
    debounce decrease_debounce(.clk(clk_100Hz), .pb(decrease), .pb_debounced(decrease_deb));
    one_pulse one_pulse_decrease(.clk(clk_100Hz), .pb_in(decrease_deb), .pb_out(decrease_one_pulse));
    debounce direction_debounce(.clk(clk_100Hz), .pb(direction), .pb_debounced(direction_deb));
    one_pulse one_pulse_direction(.clk(clk_100Hz), .pb_in(direction_deb), .pb_out(direction_one_pulse));

    //direction
    always @(posedge direction_one_pulse or posedge rst) begin
        if(rst) dir <= 1;
        else if(state == init)   dir <= ~dir;
        else dir <= dir;
    end

    //digit
    always @(posedge clk_div15) begin
        DIGIT <= next_digit;
    end
    always @(posedge clk_div15) begin
        case(DIGIT)
        4'b1110: next_digit <= 4'b1101;
        4'b1101: next_digit <= 4'b1011;
        4'b1011: next_digit <= 4'b0111;
        4'b0111: next_digit <= 4'b1110;
        default: next_digit <= 4'b1110;    
        endcase
    end

    //display
    always @(*) begin
        case(next_display)
        4'd0: DISPLAY <= zero;
        4'd1: DISPLAY <= one;
        4'd2: DISPLAY <= two;
        4'd3: DISPLAY <= three;
        4'd4: DISPLAY <= four;
        4'd5: DISPLAY <= five;
        4'd6: DISPLAY <= six;
        4'd7: DISPLAY <= seven;
        4'd8: DISPLAY <= eight;
        4'd9: DISPLAY <= nine;
        4'd10: DISPLAY <= up;
        4'd11: DISPLAY <= down;
        4'd12: DISPLAY <= dash;
        4'd13: DISPLAY <= S;
        4'd14: DISPLAY <= F;
        4'd15: DISPLAY <= Void;
        default: DISPLAY <= Void;
        endcase
    end
    always @(posedge clk_div15, posedge rst) begin
        if(rst) begin
            case(DIGIT)
            4'b1110: next_display = 0;
            4'b1101: next_display = 0;  
            4'b1011: next_display = 10;
            4'b0111: next_display = 0;  
            default: next_display = 15;  
            endcase
        end else begin
            case(state)
            init: begin
                case(DIGIT)
                4'b1110: next_display = (target%100)/10;
                4'b1101: next_display = target/100;
                4'b1011: next_display = (dir) ? 10 : 11;
                4'b0111: next_display = target%10;
                default: next_display = 15;  
                endcase
            end 
            counting: begin
                if((dir && val>299) || (!dir && val<700)) next_display = (DIGIT == 4'b1011)?(dir)?10:11:12;
                else begin
                    case(DIGIT)
                    4'b1110: next_display = ((val%100)/10);
                    4'b1101: next_display = val/100;
                    4'b1011: next_display = (dir) ? 10 : 11;
                    4'b0111: next_display = val%10;
                    default: next_display = 15;  
                endcase
                end       
            end
            fail: begin
                case(DIGIT)
                4'b1110: next_display = (val%100)/10;
                4'b1101: next_display = val/100;
                4'b1011: next_display = 14;
                4'b0111: next_display = val%10;
                default: next_display = Void;  
                endcase
            end
            success: begin
                case(DIGIT)
                4'b1110: next_display = (val%100)/10;
                4'b1101: next_display = val/100;
                4'b1011: next_display = 13;
                4'b0111: next_display = val%10;
                default: next_display = Void;  
                endcase
            end
            default: next_display = Void;  
            endcase
        end
    end

    //target
    always @(posedge clk_100Hz or posedge rst) begin
        if(rst) target <= 0;
        else target <= 100*(next_target_digit3%10) + 10*(next_target_digit2%10) + next_target_digit1%10;
    end

    always @(posedge clk_100Hz or posedge rst)begin
        if(rst) begin
            next_target_digit1 <= 0;
            next_target_digit2 <= 0;
            next_target_digit3 <= 0;
        end
        else begin
            case(state)
            init: begin
                if(Digit_1 || Digit_2 || Digit_3) begin
                    if(increase_one_pulse) begin
                        if(Digit_1) next_target_digit1 <= (target%10 == 9) ? 0 : (target%10)+1;
                        else next_target_digit1 <= target%10;
                        if(Digit_2) next_target_digit2 <= ((target%100)/10 == 9) ? 0 : (target%100)/10+1;
                        else next_target_digit2 <= (target%100)/10;
                        if(Digit_3) next_target_digit3 <= (target/100 == 9) ? 0 : (target/100)+1;
                        else next_target_digit3 <= target/100;
                    end else if(decrease_one_pulse) begin
                        if(Digit_1) next_target_digit1 <= (target%10 == 0) ? 9 : (target%10)-1;
                        else next_target_digit1 <= target%10;
                        if(Digit_2) next_target_digit2 <= ((target%100)/10 == 0) ? 9 : (target%100)/10-1;
                        else next_target_digit2 <= (target%100)/10;
                        if(Digit_3) next_target_digit3 <= (target/100 == 0) ? 9 : (target/100)-1;
                        else next_target_digit3 <= target/100;
                    end else begin
                        next_target_digit1 <= target%10;
                        next_target_digit2 <= (target%100)/10;
                        next_target_digit3 <= target/100;
                    end
                end
            end
            default: begin
                next_target_digit1 <= target%10;
                next_target_digit2 <= (target%100)/10;
                next_target_digit3 <= target/100;
            end
            endcase        
        end

    end

    //val
    always @(posedge clk_100Hz) begin
        val <= next_val;
    end
    always @* begin
        if(rst) next_val = 0;
        else begin
            case(state)
            init: next_val = (dir) ? 0 : 999;
            counting: begin
                if(dir) next_val = (val == 999) ? val : val+1;
                else next_val = (val == 0) ? val : val-1;
            end
            default: next_val = val;
            endcase
        end
    end

    //state
    always @(posedge clk) begin
        state <= next_state;
        diff_val_target <= val>target ? val-target : target-val;
    end
    always @* begin
        if(rst) next_state = init;
        else begin
            case(state)
            init: begin
                if(start_one_pulse) next_state = counting;
                else next_state = state;
            end
            counting: begin
                if(stop_one_pulse) begin
                    if(diff_val_target <= 100) next_state = success;
                    else next_state = fail;
                end else begin
                    if((dir && val == 999) || (!dir && val == 0)) next_state = fail;
                    else next_state = state;
                end
            end
            fail: begin
                if(start_one_pulse) next_state = init;
                else next_state = state;
            end
            success: begin
                if(start_one_pulse) next_state = init;
                else next_state = state;
            end
            default: next_state = init;
            endcase
        end
    end

    //led
    always @(posedge clk_100Hz) begin
        led <= next_led;
        led_flash_cnt  <= next_led_flash_cnt;
    end
    always @* begin
        case(state)
        init: begin
            next_led = led_all_on;
            next_led_flash_cnt = 0;
        end
        counting: begin
            if(dir) next_led = (val<=299) ? led_all_on : led_all_off;
            else next_led = (val>=700) ? led_all_on : led_all_off;
            next_led_flash_cnt = 0;
        end
        fail: begin
            if(led_flash_cnt%100 == 0 && led_flash_cnt <= 500) begin
                next_led = (led_flash_cnt%200 == 0) ? led_all_on : led_all_off;
                next_led_flash_cnt = led_flash_cnt +1;
            end else begin
                next_led = led;
                next_led_flash_cnt = led_flash_cnt + 1;
            end
        end
        success: begin
            if(led_flash_cnt%100 == 0 && led_flash_cnt < 500) begin
                next_led = (led_flash_cnt%200 == 0) ? led_all_on : led_all_off;
                next_led_flash_cnt = led_flash_cnt +1;
            end else begin
                next_led = led;
                next_led_flash_cnt = led_flash_cnt + 1;
            end
        end
        default: begin
            next_led = led_all_on;
            next_led_flash_cnt = 0;
        end
        endcase
    end
endmodule 