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

module lab4_1 ( 
    input wire clk,
    input wire rst,
    input wire stop,
    input wire start,
    input wire direction,
    output reg [3:0] DIGIT,
    output reg [6:0] DISPLAY,
    output reg [9:0] led
); 
    parameter initial_state = 3'd0;
    parameter prepare_state = 3'd1;
    parameter counting_state = 3'd2;
    parameter result_state = 3'd3;
    parameter UP = 4'd10, DOWN = 4'd11, MINUS = 4'd12, P = 4'd13, EMPTY = 4'd14;
    reg [3:0] value = 4'd0, set_value_3 = MINUS, set_value_2 = UP, set_value_1 = MINUS, set_value_0 = MINUS;
    reg [3:0] dir = 4'd10;
    reg [2:0] state = 3'd0, next_state = 3'd0, cnt_on_of = 3'd0;
    reg [1:0] cnt = 2'b0;
    reg [9:0] cnt_number = 10'b0, cnt_1_sec = 10'b0, cnt_3_sec = 10'b0;
    reg finish_cnt_number = 1'b0, have_rst_the_cnt_num = 1'b0;
    
    reg [3:0] hundreds_digit = 4'b0, tens_digit = 4'b0, units_digit = 4'b0;
    wire direction_debounced, seven_segment_clk, start_debounced, stop_debounced, clk_001_sec;
    wire direction_onepulse, start_onepulse, stop_onepulse;
    
    clock_divider_001_sec div1(clk, clk_001_sec);
    clock_divider #(14) div2(.clk(clk), .clk_div(seven_segment_clk));
    debounce d1(clk_001_sec, direction, direction_debounced);
    debounce d2(clk_001_sec, start, start_debounced);
    debounce d3(clk_001_sec, stop, stop_debounced);
    one_pulse o1(clk_001_sec, direction_debounced, direction_onepulse);
    one_pulse o2(clk_001_sec, start_debounced, start_onepulse);
    one_pulse o3(clk_001_sec, stop_debounced, stop_onepulse);

    always @(posedge clk_001_sec, posedge rst) begin
        if(rst || state != prepare_state) begin
            cnt_3_sec = 10'b0;
        end
        else if(state == prepare_state) begin
            if(cnt_3_sec != 10'd299) cnt_3_sec = cnt_3_sec + 1'b1;
            else cnt_3_sec = 10'b0;
        end
    end

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
            P: DISPLAY = 7'b0001100;
            EMPTY: DISPLAY = 7'b1111111;
            default: DISPLAY = 7'b1111111;
        endcase
    end

    always @(posedge clk_001_sec, posedge rst) begin
        if(rst) begin
            state <= initial_state;
        end
        else begin
            state <= next_state;
        end
    end

    always @* begin
        next_state = state;
        if(rst) next_state = initial_state;
        case(state)
            initial_state: begin
                if(start_onepulse)
                    next_state = prepare_state;
                else next_state = initial_state;
            end
            prepare_state: begin
                if(cnt_3_sec == 10'd299)
                    next_state = counting_state;
                else next_state = prepare_state;
            end
            counting_state: begin
                if(led == 10'b1111111111)
                    next_state = result_state;
                else next_state = counting_state;
            end
            result_state: begin
                if(cnt_on_of == 3'd5 || (cnt_on_of == 3'd4 && start_onepulse))
                    next_state = initial_state;
                else next_state = result_state;
            end
        endcase
    end
    
    always @(posedge clk_001_sec, posedge rst) begin
        if(rst) begin
            dir = UP;
            set_value_0 <= MINUS;
            set_value_1 <= MINUS;
            set_value_2 <= UP;
            set_value_3 <= MINUS;
            hundreds_digit <= 4'b0;
            tens_digit <= 4'b0;
            units_digit <= 4'b0;
        end
        else begin
            case(state)
                initial_state: begin
                    set_value_1 <= MINUS;
                    set_value_3 <= MINUS;
                    set_value_0 <= MINUS;
                    if(direction_onepulse) begin
                        if(dir == UP) begin
                            dir <= DOWN;
                            set_value_2 <= DOWN;
                        end
                        else if(dir == DOWN) begin
                            dir <= UP;
                            set_value_2 <= UP;
                        end
                    end
                    else dir <= dir;
                end
                prepare_state: begin
                    set_value_2 <= P;
                    set_value_3 <= EMPTY;
                    set_value_1 <= EMPTY;
                    set_value_0 <= EMPTY;
                end
                counting_state: begin
                    hundreds_digit <= cnt_number / 100;
                    units_digit <= cnt_number % 10;
                    tens_digit <= ((cnt_number % 100) - units_digit) / 10;
                    set_value_1 <= hundreds_digit;
                    set_value_0 <= tens_digit;
                    set_value_3 <= units_digit;
                    if(dir == UP) set_value_2 <= UP;
                    else if(dir == DOWN) set_value_2 <= DOWN;
                end
            endcase
        end
    end

    always @(posedge clk_001_sec, posedge rst) begin
        if(rst || state == initial_state) begin
            cnt_number = 10'b0;
            finish_cnt_number = 1'b0;
            have_rst_the_cnt_num = 1'b0;
            led = 10'b1111111111;
            cnt_on_of = 3'd0;
            cnt_1_sec = 10'b0;
        end
        else begin
            if(state == counting_state) begin
                if(dir == UP) begin
                    if(!have_rst_the_cnt_num) begin
                        cnt_number = 10'd0;
                        have_rst_the_cnt_num = 1'b1;
                    end
                    if(cnt_number != 10'd999) cnt_number = cnt_number + 1'b1;
                    else finish_cnt_number = 1'b1;
                end
                else if(dir == DOWN) begin
                    if(!have_rst_the_cnt_num) begin
                        cnt_number = 10'd999;
                        have_rst_the_cnt_num = 1'b1;
                    end
                    if(cnt_number != 10'd0) cnt_number = cnt_number - 1'b1;
                    else finish_cnt_number = 1'b1;
                end
                if(stop_onepulse || finish_cnt_number) led = 10'b1111111111;
                else if(cnt_number >= 10'd0 && cnt_number < 10'd100 && led != 10'b1111111111) led = 10'b0000000001;
                else if(cnt_number >= 10'd100 && cnt_number < 10'd200 && led != 10'b1111111111) led = 10'b0000000010;
                else if(cnt_number >= 10'd200 && cnt_number < 10'd300 && led != 10'b1111111111) led = 10'b0000000100;
                else if(cnt_number >= 10'd300 && cnt_number < 10'd400 && led != 10'b1111111111) led = 10'b0000001000;
                else if(cnt_number >= 10'd400 && cnt_number < 10'd500 && led != 10'b1111111111) led = 10'b0000010000;
                else if(cnt_number >= 10'd500 && cnt_number < 10'd600 && led != 10'b1111111111) led = 10'b0000100000;
                else if(cnt_number >= 10'd600 && cnt_number < 10'd700 && led != 10'b1111111111) led = 10'b0001000000;
                else if(cnt_number >= 10'd700 && cnt_number < 10'd800 && led != 10'b1111111111) led = 10'b0010000000;
                else if(cnt_number >= 10'd800 && cnt_number < 10'd900 && led != 10'b1111111111) led = 10'b0100000000;
                else if(cnt_number >= 10'd900 && cnt_number <= 10'd999 && led != 10'b1111111111) led = 10'b1000000000;
            end
            else if(state == prepare_state) begin
                led = 10'b0;
                finish_cnt_number = 1'b0;
            end
            else if(state == result_state) begin
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
            else begin
                finish_cnt_number = 1'b0;
                have_rst_the_cnt_num = 1'b0;
                cnt_number = cnt_number;
            end
        end
    end

endmodule 