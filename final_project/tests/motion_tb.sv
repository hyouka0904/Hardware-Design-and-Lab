// Run from repository root: iverilog -g2012 -s motion_tb -o motion.vvp final_project/game_engine.v final_project/campaign_contacts.v final_project/tests/motion_tb.sv && vvp motion.vvp
`timescale 1ns/1ps
module motion_tb;
    reg clk = 0, rst = 0, active = 1, finished = 0;
    reg collision = 0, landed = 0, should_drop = 0;
    reg [3:0] keys = 0;
    wire [3:0] state;
    wire [1:0] jump;

    always #5 clk = ~clk;
    player_motion #(
        .COYOTE_TICKS(3), .BUFFER_TICKS(3), .MIN_RISE_TICKS(2), .MAX_RISE_TICKS(5)
    ) dut(.clk(clk), .rst(rst), .active(active), .finished(finished),
        .keys(keys), .collision(collision), .landed(landed), .should_drop(should_drop),
        .state(state), .jump(jump));

    task expect_motion(input [3:0] expected_state, input [1:0] expected_jump);
        begin
            @(negedge clk);
            if (state !== expected_state || jump !== expected_jump)
                $fatal(1, "keys=%b expected state/jump=%d/%d, got %d/%d",
                    keys, expected_state, expected_jump, state, jump);
        end
    endtask

    reg [9:0] contact_x, contact_height;
    reg [3:0] contact_state;
    reg [1:0] contact_jump;
    wire hit_wall, hit_ceiling, campaign_landed, campaign_drop;
    campaign_contacts contacts(
        .x(contact_x), .height(contact_height), .state(contact_state), .jump(contact_jump),
        .button1(1'b1), .button2(1'b1),
        .hit_wall(hit_wall), .hit_ceiling(hit_ceiling),
        .landed(campaign_landed), .should_drop(campaign_drop)
    );

    initial begin
        contact_x = 247;
        contact_height = 4;
        contact_state = 7;
        contact_jump = 1;
        #1;
        if ({hit_wall, hit_ceiling} !== 2'b10)
            $fatal(1, "Side contact must not end ascent");
        contact_x = 100;
        contact_height = 9;
        #1;
        if ({hit_wall, hit_ceiling} !== 2'b01)
            $fatal(1, "Upward contact must detect the underside of a platform");
        contact_x = 261;
        contact_height = 20;
        contact_state = 8;
        contact_jump = 0;
        #1;
        if (campaign_drop !== 0)
            $fatal(1, "Facing outward must not drop a player still supported by a ledge");
        contact_x = 260;
        contact_state = 6;
        #1;
        if (campaign_drop !== 1)
            $fatal(1, "Walking off the ledge must drop the player even after releasing movement");
        contact_x = 261;
        contact_jump = 2;
        #1;
        if ({campaign_landed, campaign_drop} !== 2'b10)
            $fatal(1, "Landing must use the same support geometry");
    end

    initial begin
        #1 rst = 1;
        expect_motion(6, 0);
        rst = 0;
        keys = 4'b1000;
        expect_motion(7, 0);
        keys = 4'b1010;
        expect_motion(6, 0);
        keys = 4'b0010;
        expect_motion(8, 0);
        keys = 4'b0100;
        expect_motion(6, 0);
        keys = 4'b1001;
        expect_motion(7, 1);
        keys = 0;
        expect_motion(9, 1);
        keys = 1;
        expect_motion(9, 1);
        expect_motion(9, 2); // Repressing before the minimum height still cuts ascent.
        landed = 1;
        expect_motion(9, 1); // The second press was buffered during ascent.
        collision = 1;
        landed = 0;
        expect_motion(9, 2);
        collision = 0;
        landed = 1;
        expect_motion(9, 0);
        expect_motion(6, 0); // A held key cannot start another jump.

        landed = 0;
        keys = 0;
        should_drop = 1;
        expect_motion(9, 2);
        should_drop = 0;
        expect_motion(9, 2);
        keys = 1;
        expect_motion(9, 1); // Coyote jump after walking off a ledge.
        repeat (5) expect_motion(9, 1);
        expect_motion(9, 2); // Holding reaches the full height.
        landed = 1;
        expect_motion(9, 0);

        keys = 0;
        landed = 0;
        should_drop = 1;
        expect_motion(9, 2);
        should_drop = 0;
        repeat (3) expect_motion(9, 2);
        keys = 1;
        expect_motion(9, 2); // The coyote window has expired.
        keys = 0;
        repeat (3) expect_motion(9, 2);
        landed = 1;
        expect_motion(9, 0); // The buffered press has also expired.
        landed = 0;
        should_drop = 1;
        expect_motion(9, 2);
        should_drop = 0;
        finished = 1;
        keys = 4'b0010;
        expect_motion(9, 2);
        active = 0;
        expect_motion(6, 0);
        $display("PASS: movement, jump height, coyote time, buffering, and restart");
        $finish;
    end
endmodule
