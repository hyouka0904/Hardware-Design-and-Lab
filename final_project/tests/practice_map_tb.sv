`timescale 1ns/1ps
module practice_map_tb;
    reg clk = 0;
    reg rst = 0, invincible = 0;
    reg [9:0] keys = 0;
    reg [9:0] h = 10'd296, v = 10'd160;
    wire [2:0] selection;
    wire [16:0] pixel;
    wire cleared, failed;

    always #5 clk = ~clk;

    map_switch dut(
        .clk(clk), .rst(rst), .invincible(invincible), .key_down(keys),
        .vga_h(h), .vga_v(v), .select(selection), .led(),
        .pixel_addr(pixel), .game_clear(cleared), .game_fail(failed), .flag_alphabet()
    );

    defparam dut.Map4.GATE_SECOND_TICKS = 4;

    task tap(input [9:0] key);
        begin
            keys = key;
            repeat (2) @(negedge clk);
            keys = 0;
            repeat (2) @(negedge clk);
        end
    endtask

    initial begin
        #1 rst = 1;
        repeat (2) @(negedge clk);
        rst = 0;
        tap(10'h100);
        repeat (4) tap(10'h010);
        if (dut.map !== 3'd4 || selection !== 0 || pixel !== 17'd341)
            $fatal(1, "Fourth menu entry should be reachable and highlighted");

        tap(10'h100);
        if (selection !== 1 || dut.Map4.feet_y1 !== 10'd230 || dut.Map4.feet_y2 !== 10'd198)
            $fatal(1, "Practice map did not start on the original floor and platform");
        h = 10'd320;
        v = 10'd460;
        #1;
        if (pixel !== 17'd19521)
            $fatal(1, "Selected map should render the red river");

        h = 10'd799;
        v = 10'd524;
        #1;
        if (pixel !== 17'd0)
            $fatal(1, "Blanking should use a valid background ROM address");

        @(negedge clk);
        keys = 10'h020;
        dut.player1_motion.state = 4'd8;
        dut.player1_motion.jump = 2'd1;
        dut.Map4.player1_position.previous_jump = 2'd1;
        dut.Map4.player1_position.horizontal = 10'd97;
        dut.Map4.player1_position.vertical = 10'd31;
        dut.Map4.player1_position.horizontal_ticks = 25'd1500000;
        dut.Map4.player1_position.vertical_ticks = 25'd2000000;
        @(negedge clk);
        if (dut.Map4.position_x1 !== 10'd96 || dut.Map4.feet_y1 !== 10'd198 ||
            dut.player_jump !== 2'd1 || dut.Map4.p1_land)
            $fatal(1, "The one-way platform must allow ascent and side entry");
        dut.Map4.player1_position.vertical_ticks = 25'd2000000;
        @(negedge clk);
        if (dut.Map4.feet_y1 !== 10'd197)
            $fatal(1, "The player should rise above the platform");
        dut.player1_motion.jump = 2'd2;
        dut.Map4.player1_position.vertical_ticks = 25'd2000000;
        @(negedge clk);
        if (!dut.Map4.p1_land || dut.Map4.feet_y1 !== 10'd198)
            $fatal(1, "Descending feet should detect the platform surface");
        @(negedge clk);
        if (dut.player_jump !== 2'd0 || dut.Map4.feet_y1 !== 10'd198)
            $fatal(1, "The player should stop on the platform");

        tap(10'h100);
        tap(10'h100);
        @(negedge clk);
        dut.Map4.player1_position.horizontal = 10'd141;
        @(negedge clk);
        if (failed !== 0)
            $fatal(1, "Red player should be safe in the red river");
        dut.Map4.player2_position.horizontal = 10'd181;
        dut.Map4.player2_position.vertical = 0;
        dut.Map4.player2_position.vertical_ticks = 0;
        dut.player2_motion.jump = 0;
        dut.Map4.player1_position.horizontal = 10'd201;
        h = 10'd440;
        v = 10'd460;
        @(negedge clk);
        if (failed || !dut.Map4.bridge_active || pixel !== 17'd213)
            $fatal(1, "Holding the switch should render a bridge and protect the other player");
        tap(10'h001);
        if (!failed || dut.Map4.bridge_active)
            $fatal(1, "Jumping off the switch should retract the bridge and expose the river");

        tap(10'h100);
        tap(10'h100);
        dut.Map4.player1_position.horizontal = 10'd201;
        dut.Map4.player1_position.vertical = 10'd25;
        dut.player1_motion.jump = 2'd1;
        @(negedge clk);
        if (!failed)
            $fatal(1, "The inactive bridge field must prevent an airborne shortcut");
        tap(10'h100);
        tap(10'h100);

        invincible = 1;
        dut.Map4.player2_position.horizontal = 10'd141;
        dut.Map4.player2_position.vertical = 0;
        @(negedge clk);
        if (failed !== 0)
            $fatal(1, "Invincibility should suppress river failure");
        invincible = 0;
        dut.Map4.player1_position.horizontal = 10'd236; // Red pad at x=255.
        dut.Map4.player2_position.horizontal = 10'd255; // One step before the gate.
        keys = 10'h008;
        @(negedge clk);
        dut.Map4.player2_position.horizontal_ticks = 25'd1500000;
        @(negedge clk);
        if (dut.Map4.gate_open || dut.Map4.center_x2 !== 10'd274)
            $fatal(1, "A single pad cannot open the gate or let a player through");

        keys = 0;
        dut.Map4.player2_position.horizontal = 10'd247; // Blue pad at x=266.
        @(negedge clk);
        if (!dut.Map4.gate_open || dut.Map4.gate_ticks !== 12)
            $fatal(1, "Both colored pads should open the gate for three seconds");
        h = 10'd542;
        v = 10'd36;
        #1;
        if (pixel !== 17'd213)
            $fatal(1, "The third timer light should start lit");
        repeat (4) @(negedge clk);
        if (dut.Map4.gate_ticks !== 8 || pixel !== 17'd1628)
            $fatal(1, "The third timer light should turn off with two seconds left");
        repeat (8) @(negedge clk);
        if (dut.Map4.gate_open)
            $fatal(1, "Keeping both pads held should not renew the gate timer");

        dut.Map4.player2_position.horizontal = 10'd254;
        @(negedge clk);
        dut.Map4.player2_position.horizontal = 10'd247;
        @(negedge clk);
        if (dut.Map4.gate_ticks !== 12)
            $fatal(1, "Stepping off and back on should rearm the gate");

        dut.Map4.player2_position.horizontal = 10'd255;
        keys = 10'h008;
        @(negedge clk);
        dut.Map4.player2_position.horizontal_ticks = 25'd1500000;
        @(negedge clk);
        if (dut.Map4.center_x2 !== 10'd275 || !dut.Map4.gate_open)
            $fatal(1, "The gate should remain open after leaving the pad");
        repeat (12) @(negedge clk);
        dut.Map4.player2_position.horizontal_ticks = 25'd1500000;
        @(negedge clk);
        if (dut.Map4.gate_open || dut.Map4.center_x2 !== 10'd275)
            $fatal(1, "A player on the threshold cannot advance after the gate closes");
        keys = 10'h002;
        @(negedge clk);
        dut.Map4.player2_position.horizontal_ticks = 25'd1500000;
        @(negedge clk);
        if (dut.Map4.center_x2 !== 10'd274)
            $fatal(1, "A player on the threshold must be able to retreat");

        keys = 0;
        dut.Map4.player2_position.horizontal = 10'd247;
        @(negedge clk);
        keys = 0;
        dut.Map4.player2_position.horizontal = 10'd266;
        @(negedge clk);
        if ({cleared, failed} !== 2'b10)
            $fatal(1, "Both players reaching their exits should clear the map");
        repeat (12) @(negedge clk);
        if (!dut.Map4.gate_open)
            $fatal(1, "The timer should freeze with the finished round");

        tap(10'h100);
        if (selection !== 0 || {cleared, failed} !== 0 ||
            dut.Map4.feet_y2 !== 10'd198 || dut.Map4.gate_open)
            $fatal(1, "Returning to menu should reset the practice map");
        $display("PASS: fourth map selection, one-way platform, bridge, timed gate, exits, and round reset");
        $finish;
    end
endmodule
