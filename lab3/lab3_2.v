`timescale 1ns / 1ps
module clock_divider(clk,clk_div);
    input clk;
    output clk_div;
    parameter n = 25;
    reg[n-1:0]num = 0;
    wire[n-1:0]next_num;
    always@(posedge clk)begin
        num <= next_num;
    end
    assign next_num = num + 1;
    assign clk_div = num[n-1];
endmodule

module lab3_2(
    input clk,
    input rst,
    input en,
    input speed,
    input dir,
    output [15:0] led
);
    wire clk_div24, clk_div26,  clk_div0,  clk_div1;
    reg [2:0] cnt = 3'b0, nxt_cnt = 3'b0;
    reg [3:0] cnt_on_of = 4'b0, nxt_cnt_on_of = 4'b0;
    reg [2-1: 0] counter;
    reg [15:0] LED = 16'b0;
    reg [2:0] state, nxt_state;
    reg flag = 1'b0, judge = 1'b0, clear = 1'b0;
    parameter regular_mode = 3'd0;
    parameter escape_mode = 3'd1;
    parameter shining_mode = 3'd2;

    clock_divider #(24) div1(.clk(clk), .clk_div(clk_div24));
    always@(posedge clk_div24)begin
        counter <= counter+1;
    end
    assign clk_div26 = counter[1]; 
    assign clk_div0 = (speed) ? clk_div26 : clk_div24;
    assign clk_div1 = (speed) ? clk_div24 : clk_div26;
    

    always @(posedge clk_div1, posedge rst) begin
        if(rst) state = regular_mode;
        else state = nxt_state;
    end

    always @* begin
        nxt_state = state;
        if(rst) nxt_state = regular_mode;
        case (state)
            regular_mode: begin
                if(clear && LED == 16'b0) clear = 1'b0;
                else if(judge) begin
                    nxt_state = escape_mode;
                end
                else nxt_state = regular_mode;
            end
            escape_mode: begin
                if(LED == 16'b1111111111111111 && dir) begin
                    nxt_state = regular_mode;
                    clear = 1'b1;
                end
                else if(LED == 16'b0 && flag) nxt_state = shining_mode;
                else nxt_state = escape_mode;
            end
            shining_mode: begin
                if(cnt_on_of == 4'd9) begin
                    nxt_state = regular_mode;
                end
                else nxt_state = shining_mode;
            end
        endcase
    end

    always @* begin
        if(rst) begin
            cnt = 3'b0;
            cnt_on_of = 4'b0;
        end
        else begin
            cnt = nxt_cnt;
            cnt_on_of = nxt_cnt_on_of;
            if(state == regular_mode) cnt_on_of = 4'b0;
            else if(state == escape_mode) begin
                cnt_on_of = 4'b0;
                cnt = 3'b0;
            end
            else if(state == shining_mode) cnt = 3'b0;
        end
    end

    always @(posedge clk_div1, posedge rst) begin
        if(rst) begin
            nxt_cnt = 3'b0;
            nxt_cnt_on_of = 4'b0;            
        end 
        else if(state == regular_mode && LED == 16'b1111111111111111 && !clear) begin
            nxt_cnt_on_of = 4'b0;
            if(nxt_cnt != 3'd4) nxt_cnt = nxt_cnt + 1;
            else nxt_cnt = 3'b0;                
        end else if(state == regular_mode && clear) begin
            nxt_cnt = nxt_cnt;
        end else if(state == shining_mode) begin
            nxt_cnt = 3'b0;
            if(en) begin
                if(nxt_cnt_on_of != 4'd10) nxt_cnt_on_of = nxt_cnt_on_of + 1;
                else nxt_cnt_on_of = 4'b0;
            end
            else nxt_cnt_on_of = nxt_cnt_on_of;
        end else if(state == escape_mode) begin
            nxt_cnt = 3'b0;
            nxt_cnt_on_of = 4'b0;
        end else begin
            nxt_cnt = nxt_cnt;
            nxt_cnt_on_of = nxt_cnt_on_of;    
        end
    end

    always @(posedge clk_div1, posedge rst) begin
        if(rst) begin
            LED = 16'b0;
            flag = 0;
            judge = 0;
        end else begin
            case (state)
                regular_mode: begin
                    flag = 0;
                    if(en && !judge && !clear) begin
                        if(LED == 16'b1111111111111111) LED = 16'b0;
                        else if(LED == 16'b0) begin
                            LED = 16'b1000100010001000;
                        end else if(LED == 16'b1000100010001000) begin
                            LED = 16'b1100110011001100;
                        end else if(LED == 16'b1100110011001100) begin
                            LED = 16'b1110111011101110;
                        end else if(LED == 16'b1110111011101110) begin
                            LED = 16'b1111111111111111;
                            if(cnt == 3'd2) judge = 1;
                        end
                    end
                    else if(en && !judge && clear) begin
                        LED = 16'b0;
                    end
                    else LED = LED;
                end
                escape_mode: begin
                    judge = 0;
                    flag = 0;
                    if(en && !dir) begin
                        if(LED[15]) begin
                            LED[15] = 0;
                            LED[14] = 0;
                        end else if(LED[13]) begin
                            LED[13] = 0;
                            LED[12] = 0;
                        end else if(LED[11]) begin
                            LED[11] = 0;
                            LED[10] = 0;
                        end else if(LED[9]) begin
                            LED[9] = 0;
                            LED[8] = 0;
                        end else if(LED[7]) begin
                            LED[7] = 0;
                            LED[6] = 0;
                        end else if(LED[5]) begin
                            LED[5] = 0;
                            LED[4] = 0;
                        end else if(LED[3]) begin
                            LED[3] = 0;
                            LED[2] = 0;
                        end else if(LED[1]) begin
                            LED[1] = 0;
                            LED[0] = 0;
                            flag = 1;
                        end else LED = LED;
                    end else if(en && dir) begin
                        if(!LED[0]) begin
                            LED[0] = 1;
                            LED[1] = 1;
                        end else if(!LED[2]) begin
                            LED[2] = 1;
                            LED[3] = 1;
                        end else if(!LED[4]) begin
                            LED[4] = 1;
                            LED[5] = 1;
                        end else if(!LED[6]) begin
                            LED[6] = 1;
                            LED[7] = 1;
                        end else if(!LED[8]) begin
                            LED[8] = 1;
                            LED[9] = 1;
                        end else if(!LED[10]) begin
                            LED[10] = 1;
                            LED[11] = 1;
                        end else if(!LED[12]) begin
                            LED[12] = 1;
                            LED[13] = 1;
                        end else if(!LED[14]) begin
                            LED[14] = 1;
                            LED[15] = 1;
                            flag = 1;
                        end else begin
                            LED = LED;
                        end
                    end else LED = LED;
                end
                shining_mode: begin
                    flag = 0;
                    if(en) begin
                        if(LED == 16'b1111111111111111) LED = 16'b0;
                        else if(LED == 16'b0) LED = 16'b1111111111111111;
                    end else LED = LED;
                end
                default: LED = LED;
            endcase
        end

    end
    assign led = LED;
endmodule