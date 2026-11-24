`timescale 1ns/1ps
module lab2_2_t;

    reg clk = 1'b0;
    reg rst_n = 1'b0;
    reg [3:0] max = 4'b0100;
    reg [3:0] min = 4'b0000;
    reg in_valid = 1'b0;
    reg [1:0] mode = 2'b00;
    reg [7:0] in_data = 8'b0;
    wire [11:0] out_data;
    wire [2:0] state;
    wire [3:0] counter_out;
    wire direction;

    always #5 clk = ~clk;
    Encoder test(.clk(clk), .rst_n(rst_n), .in_valid(in_valid), .in_data(in_data), .max(max), .min(min), .mode(mode), .out_data(out_data), .state(state), .counter_out(counter_out), .direction(direction));
    initial begin
        #10 rst_n = 1'b1;
        #10 
        in_valid = 1'b1;
        in_data = 8'b00000010;
        #10 in_data = 8'b00000100;
        #10 in_data = 8'b00000110;
        #10 in_data = 8'b00001000;
        #10 in_data = 8'b00001010;
        #10 in_data = 8'b00001100;
        #10 in_data = 8'b00001110;
        #10 in_data = 8'b00010000;
        #10
        in_valid = 1'b0;
        mode = 2'b10;
        #170
        in_valid = 1'b1;
        in_data = 8'b11100110;
        mode = 2'b00;
        #10
        in_data = 8'b11100111;
        max = 4'b1111;
        min = 4'b0010;
        #10
        in_data = 8'b11101000;
        #10
        in_data = 8'b11101001;
        #10
        in_data = 8'b11101010;
        #10
        in_data = 8'b11101011;
        #10
        in_data = 8'b11101100;
        #10
        in_data = 8'b11101101;
        #10
        in_valid = 1'b0;
        mode = 2'b10;
        #250
        $finish;
    end
endmodule