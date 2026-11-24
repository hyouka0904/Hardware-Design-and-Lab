module player_position(
    input clk,
    input reset_position,
    input paused,
    input [3:0] state,
    input [1:0] jump,
    input collision,
    output reg [9:0] horizontal = 10'd0,
    output reg [9:0] vertical = 10'd0
);
    localparam [3:0] IDLE = 4'd6, RIGHT = 4'd7, LEFT = 4'd8, UP = 4'd9;
    localparam [1:0] GROUNDED = 2'd0, RISING = 2'd1, FALLING = 2'd2;
    localparam [24:0] HORIZONTAL_LIMIT = 25'd1500000;
    localparam [24:0] VERTICAL_LIMIT = 25'd2000000;
    localparam [9:0] MAX_HORIZONTAL = 10'd283;

    reg [24:0] horizontal_ticks = 25'd0;
    reg [24:0] vertical_ticks = 25'd0;

    always @(posedge clk) begin
        if (reset_position) begin
            horizontal <= 10'd0;
            horizontal_ticks <= 25'd0;
        end else if (!paused) begin
            if (state == IDLE) begin
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
            vertical <= 10'd0;
            vertical_ticks <= 25'd0;
        end else if (!paused && (state == UP || state == LEFT || state == RIGHT)) begin
            if (jump == GROUNDED) begin
                vertical_ticks <= 25'd0;
            end else if (jump == RISING || jump == FALLING) begin
                if (vertical_ticks < VERTICAL_LIMIT) begin
                    vertical_ticks <= vertical_ticks + 1'b1;
                end else begin
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
