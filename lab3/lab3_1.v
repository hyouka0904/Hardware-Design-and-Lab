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

module lab3_1(
input clk,
input rst,
input en,
input speed,
output [15:0] led
);
    wire clk_div25, clk_div27,  clk_div0,  clk_div1;
    reg flag = 1'b1;
    reg [1:0] cnt = 2'b0;
    reg [2-1: 0] counter;
    reg [15:0] LED;
    integer i;
    clock_divider #(25) div1(.clk(clk), .clk_div(clk_div25));
    always@(posedge clk_div25)begin
        counter <= counter+1;
    end
    assign clk_div27 = counter[1]; 
    assign clk_div0 = (speed) ? clk_div27 : clk_div25;
    assign clk_div1 = (speed) ? clk_div25 : clk_div27;

    always @(posedge clk_div1 or posedge rst) begin
        if(rst) begin
            LED <= 16'b0;
        end else if (en) begin
            if(LED == 16'b0) 
                LED = 16'b1000100010001000;
            else if(LED == 16'b1000100010001000)
                LED = 16'b1100110011001100;
            else if(LED == 16'b1100110011001100)
                LED = 16'b1110111011101110;
            else if(LED == 16'b1110111011101110)
                LED = 16'b1111111111111111;
            else LED = 16'b0;
        end else LED = LED;
    end
    assign led = LED;
endmodule 