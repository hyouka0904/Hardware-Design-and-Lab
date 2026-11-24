`timescale 1ns/1ps
module clock_divider_001_sec (
    input wire clk,
    output reg clk_div
);
    reg [19:0] cnt;
    always @(posedge clk) begin
        if(cnt == 20'd499999) begin
            cnt = 0;
            clk_div = ~clk_div;
        end
        else cnt = cnt + 1;
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
    parameter initial_state = 3'd0;
    parameter counting_state = 3'd1;
    parameter fail_state = 3'd2;
    parameter success_state = 3'd3;
    parameter UP = 4'd10, DOWN = 4'd11, MINUS = 4'd12, S = 4'd13, F = 4'd14;
    wire clk_001_sec, seven_segment_clk;
    wire start_debounced, stop_debounced, direction_debounced, increase_debounced, decrease_debounced;
    reg [3:0] value = 4'd0, set_value_3 = MINUS, set_value_2 = UP, set_value_1 = MINUS, set_value_0 = MINUS;
    reg [2:0] state = 3'd0, next_state = 3'd0, cnt_on_of = 3'd0, cnt_on_of_f = 3'd0;
    reg [3:0] dir = 4'd10, hundreds_digit = 4'b0, tens_digit = 4'b0, units_digit = 4'b0;
    reg [3:0] hundreds_digit_you_set = 4'b0, tens_digit_you_set = 4'b0, units_digit_you_set = 4'b0;
    reg [9:0] cnt_number = 10'b0, cnt_1_sec = 10'b0, distance = 10'b0;
    reg have_rst_the_cnt_num = 1'b0, finish_cnt_number = 1'b0, judge = 1'b0, stop_to_cnt = 1'b0;

    wire start_onepulse, stop_onepulse, direction_onepulse, increase_onepulse, decrease_onepulse;
    clock_divider_001_sec div1(clk, clk_001_sec);
    clock_divider #(14) div2(.clk(clk), .clk_div(seven_segment_clk));

    debounce d1(clk_001_sec, direction, direction_debounced);
    debounce d2(clk_001_sec, start, start_debounced);
    debounce d3(clk_001_sec, stop, stop_debounced);
    debounce d4(clk_001_sec, increase, increase_debounced);
    debounce d5(clk_001_sec, decrease, decrease_debounced);

    one_pulse o1(clk_001_sec, direction_debounced, direction_onepulse);
    one_pulse o2(clk_001_sec, start_debounced, start_onepulse);
    one_pulse o3(clk_001_sec, stop_debounced, stop_onepulse);
    one_pulse o4(clk_001_sec, increase_debounced, increase_onepulse);
    one_pulse o5(clk_001_sec, decrease_debounced, decrease_onepulse);

    always @(posedge seven_segment_clk) begin
        case (DIGIT)
            4'b1110: begin
                value = set_value_0;
                DIGIT = 4'b1101;
            end
            4'b1101: begin
                value = set_value_1;
                DIGIT = 4'b1011;
            end
            4'b1011: begin
                value = set_value_2;
                DIGIT = 4'b0111;
            end
            4'b0111: begin
                value = set_value_3;
                DIGIT = 4'b1110;
            end
            default: begin
                value = set_value_0;
                DIGIT = 4'b1110;
            end
        endcase
    end

    always @* begin
        case (value)
            4'd0: DISPLAY = 7'b1000000;
            4'd1: DISPLAY = 7'b1111001;
            4'd2: DISPLAY = 7'b0100100;
            4'd3: DISPLAY = 7'b0110000;
            4'd4: DISPLAY = 7'b0011001;
            4'd5: DISPLAY = 7'b0010010;
            4'd6: DISPLAY = 7'b0000010;
            4'd7: DISPLAY = 7'b1111000;
            4'd8: DISPLAY = 7'b0000000;
            4'd9: DISPLAY = 7'b0010000;
            UP: DISPLAY = 7'b1011100;
            DOWN: DISPLAY = 7'b1100011;
            MINUS: DISPLAY = 7'b0111111;
            S: DISPLAY = 7'b0010010;
            F: DISPLAY = 7'b0001110;
            default: DISPLAY = 7'b1111111;
        endcase
    end

    always @(posedge clk_001_sec, posedge rst) begin
        if(rst) begin
            state = initial_state;
        end
        else state = next_state;
    end

    always @* begin
        next_state = state;
        if(rst) next_state = initial_state;
        case (state)
            initial_state: begin
                if(start_onepulse) next_state = counting_state;
                else next_state = initial_state;
            end
            counting_state: begin
                if(finish_cnt_number) begin
                    next_state = fail_state;
                end
                else if(judge && led == 16'b1111111111111111) begin
                    if(distance <= 100) next_state = success_state;
                    else next_state = fail_state;
                end
                else next_state = counting_state;
            end
            fail_state: begin
                if((cnt_on_of_f == 3'd5 && start_onepulse) || cnt_on_of_f == 3'd6)
                    next_state = initial_state;
                else next_state = fail_state;
            end
            success_state: begin
                if((cnt_on_of == 3'd4 && start_onepulse) || cnt_on_of == 3'd5)
                    next_state = initial_state;
                else next_state = success_state;
            end
        endcase
    end

    always @(posedge clk_001_sec, posedge rst) begin
        if(rst) begin
            dir = UP;
            set_value_0 = 0;
            set_value_1 = 0;
            set_value_2 = UP;
            set_value_3 = 0;
            hundreds_digit_you_set = 4'b0;
            tens_digit_you_set = 4'b0;
            units_digit_you_set = 4'b0;
            have_rst_the_cnt_num = 1'b0;
            cnt_number = 10'b0;
            finish_cnt_number = 1'b0;
            led = 16'b1111111111111111;
            cnt_on_of = 3'b0;
            cnt_on_of_f = 3'b0;
            cnt_1_sec = 10'd0;
        end
        else begin
            case (state)
                initial_state: begin
                    cnt_number = 10'b0;
                    cnt_on_of = 3'b0;
                    cnt_on_of_f = 3'b0;
                    have_rst_the_cnt_num = 1'b0;
                    led = 16'b1111111111111111;
                    finish_cnt_number = 1'b0;
                    cnt_1_sec = 10'b0;
                    if(direction_onepulse) begin
                        if(dir == UP) begin
                            dir = DOWN;
                            set_value_2 = DOWN;
                        end
                        else if(dir == DOWN) begin
                            dir = UP;
                            set_value_2 = UP;
                        end
                    end
                    else dir = dir;
                    if(Digit_1 || Digit_2 || Digit_3) begin
                        if(increase_onepulse) begin
                            if(Digit_1) begin
                                if(units_digit_you_set != 4'd9) units_digit_you_set = units_digit_you_set + 1'b1;
                                else units_digit_you_set = 4'b0;
                            end
                            if(Digit_2) begin
                                if(tens_digit_you_set != 4'd9) tens_digit_you_set = tens_digit_you_set + 1'b1;
                                else tens_digit_you_set = 4'b0;
                            end
                            if(Digit_3) begin
                                if(hundreds_digit_you_set != 4'd9) hundreds_digit_you_set = hundreds_digit_you_set + 1'b1;
                                else hundreds_digit_you_set = 4'b0;
                            end
                        end
                        else if(decrease_onepulse) begin
                            if(Digit_1) begin
                                if(units_digit_you_set != 4'b0) units_digit_you_set = units_digit_you_set - 1'b1;
                                else units_digit_you_set = 4'd9;                                
                            end
                            if(Digit_2) begin
                                if(tens_digit_you_set != 4'b0) tens_digit_you_set = tens_digit_you_set - 1'b1;
                                else tens_digit_you_set = 4'd9;    
                            end
                            if(Digit_3) begin
                                if(hundreds_digit_you_set != 4'b0) hundreds_digit_you_set = hundreds_digit_you_set - 1'b1;
                                else hundreds_digit_you_set = 4'd9;    
                            end
                        end
                        else begin
                            hundreds_digit_you_set = hundreds_digit_you_set;
                            tens_digit_you_set = tens_digit_you_set;
                            units_digit_you_set = units_digit_you_set;
                        end
                    end
                    else begin
                        hundreds_digit_you_set = hundreds_digit_you_set;
                        tens_digit_you_set = tens_digit_you_set;
                        units_digit_you_set = units_digit_you_set;
                    end
                    set_value_1 = hundreds_digit_you_set;
                    set_value_0 = tens_digit_you_set;
                    set_value_3 = units_digit_you_set;
                    set_value_2 = dir;
                end

                counting_state: begin
                    cnt_on_of = 3'b0;
                    cnt_on_of_f = 3'b0;
                    if(stop_onepulse) begin
                        led = 16'b1111111111111111;
                        if((dir == UP && cnt_number >= 10'd299) || (dir == DOWN && cnt_number <= 10'd700)) begin
                            set_value_1 = hundreds_digit;
                            set_value_0 = tens_digit;
                            set_value_3 = units_digit;
                        end
                    end
                    if(dir == UP) begin
                        set_value_2 = UP;
                        if(!have_rst_the_cnt_num) begin
                            cnt_number = 10'b0;
                            have_rst_the_cnt_num = 1'b1;
                        end
                        if(cnt_number != 10'd999 && !stop_to_cnt) cnt_number = cnt_number + 1'b1;
                        else if(cnt_number != 10'd999 && stop_to_cnt) cnt_number = cnt_number;
                        else begin
                            led = 16'b1111111111111111;
                            finish_cnt_number = 1'b1;
                        end
                        if(cnt_number >= 10'd299 && !judge && !finish_cnt_number) begin
                            led = 16'b0;
                            set_value_1 = MINUS;
                            set_value_0 = MINUS;
                            set_value_3 = MINUS;
                        end
                        else begin
                            led = 16'b1111111111111111;
                            set_value_1 = hundreds_digit;
                            set_value_0 = tens_digit;
                            set_value_3 = units_digit;
                        end
                    end
                    else if(dir == DOWN) begin
                        set_value_2 = DOWN;
                        if(!have_rst_the_cnt_num) begin
                            cnt_number = 10'd999;
                            have_rst_the_cnt_num = 1'b1;
                        end
                        if(cnt_number != 10'd0 && !stop_to_cnt) cnt_number = cnt_number - 1'b1;
                        else if(cnt_number != 10'd0 && stop_to_cnt) cnt_number = cnt_number;
                        else begin
                            led = 16'b1111111111111111;
                            finish_cnt_number = 1'b1;
                        end
                        if(cnt_number <= 10'd700 && !judge && !finish_cnt_number) begin
                            led = 16'b0;
                            set_value_1 = MINUS;
                            set_value_0 = MINUS;
                            set_value_3 = MINUS;
                        end
                        else begin
                            led = 16'b1111111111111111;
                            set_value_1 = hundreds_digit;
                            set_value_0 = tens_digit;
                            set_value_3 = units_digit;
                        end
                    end
                end

                success_state: begin
                    set_value_2 = S;
                    set_value_1 = hundreds_digit;
                    set_value_0 = tens_digit;
                    set_value_3 = units_digit;
                    if(start_onepulse && cnt_on_of != 3'd4) cnt_on_of = 3'd5;
                    if(cnt_1_sec != 10'd99) cnt_1_sec = cnt_1_sec + 1;
                    else cnt_1_sec = 10'b0;
                    if(cnt_on_of != 3'd4) begin
                        if(cnt_1_sec == 10'd99) begin
                            led = ~led;
                            cnt_on_of = cnt_on_of + 1;
                        end
                        else led = led;
                    end
                    else led = led;
                end

                fail_state: begin
                    set_value_2 = F;
                    set_value_1 = hundreds_digit;
                    set_value_0 = tens_digit;
                    set_value_3 = units_digit;
                    if(start_onepulse && cnt_on_of_f != 3'd5) cnt_on_of_f = 3'd6;
                    if(cnt_1_sec != 10'd99) cnt_1_sec = cnt_1_sec + 1;
                    else cnt_1_sec = 10'b0;
                    if(cnt_on_of_f != 3'd5) begin
                        if(cnt_1_sec == 10'd99) begin
                            led = ~led;
                            cnt_on_of_f = cnt_on_of_f + 1;
                        end
                        else led = led;
                    end
                    else led = led;
                end
            endcase
        end
    end

    always @(posedge clk_001_sec, posedge rst) begin
        if(rst) begin
            hundreds_digit = 4'b0;
            tens_digit = 4'b0;
            units_digit = 4'b0;
            judge = 1'b0;
            distance = 10'b0;
            stop_to_cnt = 1'b0;
        end
        else begin
            if(stop_onepulse) begin
                stop_to_cnt = 1'b1;
                if(dir == UP) begin
                    if(cnt_number >= (hundreds_digit_you_set * 100 + tens_digit_you_set * 10 + units_digit_you_set) + 1)
                        distance = cnt_number - (hundreds_digit_you_set * 100 + tens_digit_you_set * 10 + units_digit_you_set) - 1;
                    else
                        distance = (hundreds_digit_you_set * 100 + tens_digit_you_set * 10 + units_digit_you_set) - cnt_number + 1;
                end
                else if(dir == DOWN) begin
                    if(cnt_number >= (hundreds_digit_you_set * 100 + tens_digit_you_set * 10 + units_digit_you_set) - 1)
                        distance = cnt_number - (hundreds_digit_you_set * 100 + tens_digit_you_set * 10 + units_digit_you_set) + 1;
                    else
                        distance = (hundreds_digit_you_set * 100 + tens_digit_you_set * 10 + units_digit_you_set) - cnt_number - 1;
                end
                judge = 1'b1;
            end
            if(state == initial_state) begin
                judge = 1'b0; 
                distance = 10'b0;
                hundreds_digit = 4'b0;
                tens_digit = 4'b0;
                units_digit = 4'b0;
                stop_to_cnt = 1'b0;
            end
            if(state == counting_state && !stop_to_cnt) begin
                hundreds_digit = cnt_number / 100;
                units_digit = cnt_number % 10;
                tens_digit = ((cnt_number % 100) - units_digit) / 10;
            end
            else begin
                hundreds_digit = hundreds_digit;
                tens_digit = tens_digit;
                units_digit = units_digit;
            end
        end
    end

endmodule 