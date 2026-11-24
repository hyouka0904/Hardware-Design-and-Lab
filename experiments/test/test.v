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
module test(
    input clk,
    output reg[15:0] led
);
    integer i;
    wire clk_div27;
    clock_divider #(27) div2(.clk(clk), .clk_div(clk_div27));
    always @(posedge clk_div27) begin
        led = (led[0] == 1) ? 16'b0000000000000000 : 16'b1111111111111111;
    end
endmodule