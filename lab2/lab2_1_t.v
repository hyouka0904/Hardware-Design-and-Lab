`timescale 1ns/1ps
module lab2_1_t;

    reg clk = 1'b0;
    reg rst_n = 1'b0;
    reg flip = 1'b0;
    reg enable = 1'b1;
    reg [3:0] max = 4'b0100;
    reg [3:0] min = 4'b0000;
    wire direction;
    wire [3:0] out;

    always #5 clk = ~clk;
    Parameterized_Ping_Pong_Counter test(
        .clk(clk), .rst_n(rst_n), .flip(flip), .enable(enable), .max(max), .min(min),
        .direction(direction), .out(out)
    );
    initial begin
        #10
        rst_n = 1'b1;
        #90
            max = 4'b1010;
            min = 4'b0011;
        
        #20
        rst_n = 1'b0;
        #10
        rst_n = 1'b1;
        #15
        flip = 1'b1;
        #10
        flip = 1'b0;
        #14
        flip = 1'b1;
        #10
        flip = 1'b0;
        #14
        flip = 1'b1;
        #10
        flip = 1'b0;
        #127
        enable = 1'b0;
        #20
        enable = 1'b1;
        #21
        flip = 1'b1;
        #10
        flip = 1'b0;
        #20
        flip = 1'b1;
        #10
        flip = 1'b0;
        #20
        @(negedge clk) 
            max = 4'b0;
            min = 4'b0011;
        #20
        $finish;
    end
endmodule