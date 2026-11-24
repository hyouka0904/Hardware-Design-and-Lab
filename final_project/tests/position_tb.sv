// Run from the repository root with Icarus Verilog:
// iverilog -g2012 -s position_tb -o position.vvp final_project/player_position.v final_project/tests/position_tb.sv
// vvp position.vvp
`timescale 1ns/1ps
module position_tb;
    localparam [3:0] RIGHT = 4'd7, LEFT = 4'd8, UP = 4'd9;
    localparam [1:0] RISING = 2'd1;

    reg clk = 0;
    reg reset_position = 1, paused = 0;
    reg [3:0] state = RIGHT;
    reg [1:0] jump = RISING;
    wire [9:0] horizontal, vertical;

    always #5 clk = ~clk;

    player_position dut(
        .clk(clk), .reset_position(reset_position), .paused(paused),
        .state(state), .jump(jump), .collision(1'b0),
        .horizontal(horizontal), .vertical(vertical)
    );

    initial begin
        @(negedge clk);
        reset_position = 0;
        // Start one tick before a step so the test can exercise the real divider.
        dut.horizontal = 10'd20;
        dut.horizontal_ticks = 25'd1500000;
        dut.vertical_ticks = 25'd2000000;

        state = UP;
        @(negedge clk);
        if (horizontal !== 10'd20 || vertical !== 10'd1)
            $fatal(1, "Neutral horizontal input must still allow the jump to advance");

        state = LEFT;
        @(negedge clk);
        if (horizontal !== 10'd20)
            $fatal(1, "Horizontal step used ticks collected before releasing the direction");

        dut.horizontal_ticks = 25'd1500000;
        paused = 1;
        @(negedge clk);
        if (horizontal !== 10'd20)
            $fatal(1, "Pause must freeze position");

        paused = 0;
        @(negedge clk);
        if (horizontal !== 10'd19)
            $fatal(1, "Held direction must step when its own interval elapses");

        $display("PASS: airborne neutral resets horizontal step timing");
        $finish;
    end
endmodule
