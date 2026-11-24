// The campaign maps share geometry, with their switches selecting active surfaces.
module campaign_contacts(
    input [9:0] x, height,
    input [3:0] state,
    input [1:0] jump,
    input button1, button2,
    output wire hit_wall, hit_ceiling, landed, should_drop
);
    localparam [3:0] RIGHT = 4'd7, LEFT = 4'd8;
    localparam [1:0] GROUNDED = 2'd0, RISING = 2'd1, FALLING = 2'd2;
    wire [9:0] feet = 10'd230 - height;
    wire [9:0] head = 10'd199 - height;
    wire [9:0] left_edge = x + 10'd13;
    wire [9:0] right_edge = x + 10'd28;

    assign hit_wall =
        (state == RIGHT && right_edge >= 275 && feet >= 220) ||
        (button1 && state == LEFT && x + 10 <= 40 && feet >= 165 && feet <= 182) ||
        (state == RIGHT && button2 && right_edge >= 295 && feet >= 130);

    assign hit_ceiling = jump == RISING && (
        (head == 190 && x + 10 < 240) ||
        (head == 147 && x + 10 >= 90) ||
        (!button1 && x + 10 < 40 && head >= 139 && head <= 147) ||
        (head == 104 && x + 10 >= 75 && x + 10 < 270) ||
        (head == 56 && x + 10 >= 100) ||
        head == 9
    );

    // Use the same surface test for touchdown and walking off an edge.
    wire supported =
        feet == 230 ||
        (feet == 210 && left_edge >= 274 && right_edge <= 320) ||
        (feet == 182 && x + 25 < 255) ||
        (feet == 161 && button1 && x + 8 <= 40) ||
        (feet == 139 && left_edge >= 80 && left_edge < 310) ||
        (feet == 124 && button2 && right_edge >= 295) ||
        (feet == 96 && left_edge >= 85 && left_edge < 270) ||
        (feet == 71 && left_edge <= 65) ||
        (feet == 48 && right_edge >= 110);

    assign landed = jump == FALLING && supported;
    assign should_drop = jump == GROUNDED && !supported;
endmodule
