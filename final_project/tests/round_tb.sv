// Run from repository root: iverilog -g2012 -s round_tb -o round.vvp final_project/*.v final_project/tests/round_tb.sv && vvp round.vvp
`timescale 1ns/1ps
module round_tb;
    reg clk=0, rst=0, invincible=0;
    reg [9:0] keys=0;
    always #5 clk=~clk;
    wire [2:0] selection;
    wire [15:0] led;
    wire cleared, failed, alphabet;
    wire [16:0] pixel;
    map_switch dut(.clk(clk), .rst(rst), .invincible(invincible), .key_down(keys),
        .vga_h(10'd150), .vga_v(10'd140), .select(selection), .led(led),
        .pixel_addr(pixel), .game_clear(cleared), .game_fail(failed), .flag_alphabet(alphabet));
    task enter;
        begin
            keys[8]=1;
            repeat (2) @(negedge clk);
            keys[8]=0;
            repeat (2) @(negedge clk);
        end
    endtask
    initial begin
        #1 rst=1;
        repeat (2) @(negedge clk);
        rst=0;
        enter;
        enter;
        if (selection !== 1) $fatal(1,"Could not start map 1");
        force dut.map2_fail=1;
        repeat (2) @(negedge clk);
        if ({cleared,failed} !== 0) $fatal(1,"Inactive map affected game");
        release dut.map2_fail;
        dut.Map1.player1_position.horizontal=10'd30;
        dut.Map1.player1_position.vertical=10'd48;
        dut.Map1.mech_cnt_v=25'd123;
        repeat (2) @(negedge clk);
        if ({cleared,failed} !== 2'b01 || led !== 16'hf0f0 ||
            !alphabet || pixel !== {1'b0,dut.game_fail_scene_addr})
            $fatal(1,"Map 1 hazard did not select failure scene");
        invincible=1;
        keys[7]=1;
        repeat (3) @(negedge clk);
        if (!failed || dut.Map1.fail !== 0 || dut.player_state !== 6 ||
            dut.Map1.mech_cnt_v !== 25'd123)
            $fatal(1,"Result or map state changed after failure");
        keys=0;
        enter;
        if (selection !== 0 || {cleared,failed} !== 0 || led !== 16'h000f ||
            dut.Map1.player_horizontal_displacement !== 0) $fatal(1,"Menu did not reset round");
        enter;
        force dut.map1_clear=1;
        force dut.map1_fail=1;
        @(negedge clk);
        if ({cleared,failed} !== 2'b10 || led !== 16'hffff ||
            pixel !== {1'b0,dut.game_clear_scene_addr}) $fatal(1,"Clear should take priority");
        release dut.map1_clear;
        release dut.map1_fail;
        repeat (3) @(negedge clk);
        if (!cleared) $fatal(1,"Clear result was not retained");
        enter;
        if ({cleared,failed} !== 0) $fatal(1,"New round inherited previous result");
        $display("PASS: first result held, map freezes, scene and LEDs agree, Enter resets");
        $finish;
    end
endmodule
