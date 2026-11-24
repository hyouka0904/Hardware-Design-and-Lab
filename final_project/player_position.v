module player_position #(
    parameter [9:0] START_VERTICAL = 10'd0
)(
    input clk,
    input reset_position,
    input paused,
    input [3:0] state,
    input [1:0] jump,
    input collision,
    output reg [9:0] horizontal = 10'd0,
    output reg [9:0] vertical = START_VERTICAL
);
    localparam [3:0] IDLE = 4'd6, RIGHT = 4'd7, LEFT = 4'd8, UP = 4'd9;
    localparam [1:0] GROUNDED = 2'd0, RISING = 2'd1, FALLING = 2'd2;
    localparam [24:0] HORIZONTAL_LIMIT = 25'd1500000;
    localparam [24:0] VERTICAL_LIMIT = 25'd2000000;
    localparam [9:0] MAX_HORIZONTAL = 10'd283;

    reg [24:0] horizontal_ticks = 25'd0;
    reg [24:0] vertical_ticks = 25'd0;
    reg [1:0] previous_jump = GROUNDED;
    wire airborne = jump == RISING || jump == FALLING;
    wire new_ascent = jump == RISING && previous_jump != RISING;

    always @(posedge clk) begin
        if (reset_position) begin
            horizontal <= 10'd0;
            horizontal_ticks <= 25'd0;
        end else if (!paused) begin
            if (state == IDLE || state == UP) begin
                horizontal_ticks <= 25'd0;
            end else if (state == LEFT || state == RIGHT) begin
                if (horizontal_ticks < HORIZONTAL_LIMIT) begin
                    horizontal_ticks <= horizontal_ticks + 1'b1;
                end else begin
                    horizontal_ticks <= 25'd0;
                    if (state == RIGHT && horizontal < MAX_HORIZONTAL && !collision)
                        horizontal <= horizontal + 1'b1;
                    else if (state == LEFT && horizontal != 10'd0 && !collision)
                        horizontal <= horizontal - 1'b1;
                end
            end
        end
    end

    always @(posedge clk) begin
        if (reset_position) begin
            vertical <= START_VERTICAL;
            vertical_ticks <= 25'd0;
            previous_jump <= GROUNDED;
        end else if (!paused) begin
            previous_jump <= jump;
            // A buffered landing can enter ascent without a grounded cycle.
            if (!airborne || new_ascent)
                vertical_ticks <= 25'd0;
            else if (state == UP || state == LEFT || state == RIGHT) begin
                if (vertical_ticks < VERTICAL_LIMIT)
                    vertical_ticks <= vertical_ticks + 1'b1;
                else begin
                    vertical_ticks <= 25'd0;
                    if (jump == RISING)
                        vertical <= vertical + 1'b1;
                    else if (vertical != 10'd0)
                        vertical <= vertical - 1'b1;
                end
            end
        end
    end
endmodule
