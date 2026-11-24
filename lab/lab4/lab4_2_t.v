`timescale 1 ms/10 ns

module lab4_2_tb;


    reg clk = 0;
    reg rst = 0;
    reg Digit_1 = 0;
    reg Digit_2 = 0;
    reg Digit_3 = 0;
    reg stop = 0;
    reg start = 0;
    reg increase = 0;
    reg decrease = 0;
    reg direction = 1;
    reg [9:0] init = 10'b0;
    reg [9:0] number = 10'b0;

    wire [3:0] DIGIT;
    wire [6:0] DISPLAY;
    wire [15:0] led;

    lab4_2 t (
        .clk(clk),
        .rst(rst),
        .Digit_1(Digit_1),
        .Digit_2(Digit_2),
        .Digit_3(Digit_3),
        .stop(stop),
        .start(start),
        .increase(increase),
        .decrease(decrease),
        .direction(direction),
        .DIGIT(DIGIT),
        .DISPLAY(DISPLAY),
        .led(led)
    );

    always begin
        #0.5 clk = ~clk;
    end

    always @(posedge clk, posedge rst) begin
        if(rst) begin
            number = 10'b0;
        end
        else if(start) begin
            if(direction) begin
                if(number != 10'd999) number = number + 1;
                else number = 10'b0;
            end
            else if(!direction) begin
                if(number != 10'b0) number = number - 1;
                else number = 10'd999;
            end
        end
        else begin
            if(direction) number = 10'b0;
            else number = 10'd999;
        end
    end
    
    initial begin
        @(negedge clk) init = 10'd100;
    end

    always @(posedge clk) begin
        $display("Time=%0t DIGIT=%b DISPLAY=%b led=%b", $time, DIGIT, DISPLAY, led);
    end
    

endmodule
