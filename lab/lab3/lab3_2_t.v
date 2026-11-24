`timescale 1ns / 1ps
module lab3_2_t;
    reg clk;
    reg rst;
    reg en = 1;
    reg speed = 1;
    reg dir = 0;
    wire [15:0] led = 16'b0;
    always #5 clk = ~clk;
    lab3_2 test(.clk(clk), .rst(rst), .en(en), .speed(speed), .dir(dir), .led(led));
    initial begin
        #100 speed = 0;
        #300 @(posedge clk) dir = 1;
        #300 $finish;
    end
endmodule