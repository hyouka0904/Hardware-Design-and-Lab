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

module lab3_3(
    input clk,
    input rst,
    input en,
    output [15:0] led
);
    wire clk_div24, clk_div25, clk_div26;
    parameter snake_1_init = 16'b1000000000000000, snake_11_init = 16'b0000110000000000, snake_111_init = 16'b0000000000000111;
    parameter static = 2'd0, left = 2'd1, right = 2'd2;
    integer i;  
    clock_divider #(24) div1(.clk(clk), .clk_div(clk_div24));
    clock_divider #(25) div2(.clk(clk), .clk_div(clk_div25));
    clock_divider #(26) div3(.clk(clk), .clk_div(clk_div26));

    reg [15:0] snake_1 = snake_1_init, snake_11 = snake_11_init, snake_111 = snake_111_init;
    reg [1:0] snake_1_dir = right, snake_11_dir = right, snake_111_dir = left;
    reg [15:0] snake_1_tmp_pos = snake_11_init, snake_11_tmp_pos = snake_11_init, snake_111_tmp_pos = snake_111_init;
    reg [15:0] tmp1, tmp2, tmp3, tmp4;
    reg snake_1_have_to_change_dir = 1'b0, snake_111_have_to_change_dir = 1'b0;
    reg flag_1 = 1'b0, flag_2 = 1'b0, flag_3 = 1'b0;
    reg snake_1_hit_snake_11 = 1'b0, snake_111_hit_snake_11 = 1'b0;


    always @(posedge clk_div24, posedge rst) begin
        if(rst) begin
            snake_1 = snake_1_init;
            snake_1_dir = right;
        end else begin
            if(en) begin 
                if(snake_1_have_to_change_dir && !flag_1) begin
                    if(snake_1_dir == right) snake_1_dir = left;
                    else snake_1_dir = right;
                    flag_1 = 1;
                end
                if(flag_1) flag_1 = 0;
                case (snake_1_dir)
                    right: tmp1 = snake_1 >> 1;
                    left: begin
                        if(snake_1 == snake_1_init) begin
                            tmp1 = snake_1 >> 1;
                            snake_1_dir = right;
                        end
                        else tmp1 = snake_1 << 1;
                    end
                endcase
                if((tmp1 & snake_11) != 0 && !snake_1[15]) begin
                    snake_1_dir = left;
                    snake_1 = tmp1 << 2;
                    snake_1_hit_snake_11 = 1;
                end else if((tmp1 & snake_11) != 0 && snake_1[15]) begin
                    snake_1_dir = right;
                    snake_1 = snake_1;
                    snake_1_hit_snake_11 = 1;
                end
                else begin
                    snake_1 = tmp1;
                    snake_1_hit_snake_11 = 0;
                end
            end
            else snake_1 = snake_1;
        end
    end 

    always @(posedge clk_div26, posedge rst) begin
        if(rst) begin
            snake_111 = snake_111_init;
            snake_111_dir = left;
        end else begin
            if(en) begin
                if(snake_111_have_to_change_dir && !flag_3) begin
                    if(snake_111_dir == right) snake_111_dir = left;
                    else snake_111_dir = right;
                    flag_3 = 1;
                end
                if(flag_3) flag_3 = 0;
                case (snake_111_dir)
                    left: tmp3 = snake_111 << 1;
                    right: begin
                        if(snake_111 == snake_111_init) begin
                            snake_111_dir = left;
                            tmp3 = snake_111 << 1;
                        end
                        else tmp3 = snake_111 >> 1;
                    end
                    default: tmp3 = snake_111;
                endcase
                if((tmp3 & snake_11) != 0 && !snake_111[0]) begin
                    snake_111_dir = right;
                    snake_111_hit_snake_11 = 1;
                    if(snake_111 == 16'b0000000000001110) snake_111 = snake_111_init;
                    else snake_111 = tmp3 >> 2;
                end else if((tmp3 & snake_11) != 0 && snake_111[0]) begin
                    snake_111_hit_snake_11 = 1;
                    snake_111_dir = left;
                    snake_111 = snake_111;
                end
                else begin
                    snake_111 = tmp3;
                    snake_111_hit_snake_11 = 0;
                end
            end
            else snake_111 = snake_111;
        end
    end

    always @(posedge clk_div25, posedge rst) begin
        if(rst) begin
            snake_11 = snake_11_init;
            snake_11_dir = right;
        end
        else begin
            if(en) begin
                if((snake_1_hit_snake_11 || snake_111_hit_snake_11) && !flag_2) begin
                    if(snake_11_dir == right) snake_11_dir = left;
                    else snake_11_dir = right;
                    flag_2 = 1;
                end
                if(flag_2) flag_2 = 0;
                case (snake_11_dir)
                    left: begin
                        if(snake_11 == 16'b0110000000000000) begin
                            snake_11_dir = right;
                            tmp2 = snake_11 >> 1;
                        end
                        else tmp2 = snake_11 << 1;
                    end
                    right: begin
                        if(snake_11 == 16'b0000000000011000) begin
                            snake_11_dir = left;
                            tmp2 = snake_11 << 1;
                        end
                        else tmp2 = snake_11 >> 1;
                    end
                    default: snake_11 = snake_11;
                endcase
                if((tmp2 & snake_1) != 0 && (tmp2 & snake_111) != 0) begin
                    snake_1_have_to_change_dir = 1;
                    snake_111_have_to_change_dir = 1;
                    snake_11 = snake_11;
                    snake_11_dir = snake_11_dir;
                end
                else if((tmp2 & snake_1) == 0 && (tmp2 & snake_111) == 0)begin
                    snake_11 = tmp2;
                    snake_1_have_to_change_dir = 0;
                    snake_111_have_to_change_dir = 0;
                end
                else if((tmp2 & snake_1) != 0 && (tmp2 & snake_111) == 0) begin
                    snake_1_have_to_change_dir = 1;
                    snake_111_have_to_change_dir = 0;
                    snake_11_dir = right;
                    snake_11 = snake_11 >> 1;
                end            
                else if((tmp2 & snake_1) == 0 && (tmp2 & snake_111) != 0) begin
                    snake_111_have_to_change_dir = 1;
                    snake_1_have_to_change_dir = 0;
                    snake_11_dir = left;
                    snake_11 = snake_11 << 1;
                end
            end 
            else snake_11 = snake_11;
        end
    end

    assign led = snake_1 + snake_11 + snake_111;
endmodule