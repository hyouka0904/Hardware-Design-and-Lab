module practice_map #(
    parameter integer GATE_SECOND_TICKS = 100_000_000
)(
    input clk, rst, en, paused, invincible,
    input [9:0] vga_h, vga_v,
    input [3:0] player_state, player2_state,
    input [1:0] player_jump, player2_jump,
    output reg [16:0] addr,
    output wire clear, fail,
    output wire p1_collision, p2_collision,
    output wire p1_land, p2_land,
    output wire should_down, should_down2
);
    localparam [9:0] FLOOR_Y = 10'd230, PLATFORM_Y = 10'd198;
    localparam [3:0] RIGHT = 4'd7, LEFT = 4'd8;
    localparam [1:0] GROUNDED = 2'd0, RISING = 2'd1, FALLING = 2'd2;
    localparam [9:0] CEILING_HEIGHT = 10'd10, PLATFORM_HEIGHT = 10'd8;
    localparam [9:0] PLATFORM_LEFT = 10'd10, PLATFORM_RIGHT = 10'd116;
    localparam [9:0] RED_RIVER_LEFT = 10'd150, BLUE_RIVER_LEFT = 10'd210;
    localparam [9:0] BRIDGE_SWITCH_LEFT = 10'd193, BRIDGE_SWITCH_WIDTH = 10'd14;
    localparam [9:0] SWITCH_Y = FLOOR_Y - 10'd4;
    localparam [16:0] SWITCH_ACTIVE = 17'd213, SWITCH_INACTIVE = 17'd1628;
    localparam [9:0] RED_PAD_LEFT = 10'd252, BLUE_PAD_LEFT = 10'd263;
    localparam [9:0] GATE_PAD_WIDTH = 10'd10, GATE_X = 10'd275;
    localparam [9:0] TIMER_LEFT = 10'd256, TIMER_Y = 10'd18;
    localparam integer GATE_OPEN_TICKS = 3 * GATE_SECOND_TICKS;
    localparam [16:0] RED_COLOR = 17'd19521, BLUE_COLOR = 17'd22470;
    localparam [9:0] RED_EXIT_LEFT = 10'd250, BLUE_EXIT_LEFT = 10'd280;
    localparam [9:0] RIVER_WIDTH = 10'd40, EXIT_WIDTH = 10'd23;
    localparam [9:0] PLAYER_HEIGHT = 10'd30, PLAYER_CENTER = 10'd19;

    wire [9:0] position_x1, position_y1, position_x2, position_y2;
    wire [9:0] center_x1 = position_x1 + PLAYER_CENTER;
    wire [9:0] center_x2 = position_x2 + PLAYER_CENTER;
    wire [9:0] feet_y1 = FLOOR_Y - position_y1;
    wire [9:0] feet_y2 = FLOOR_Y - position_y2;

    wire reset_position = rst || !en;
    wire gate_open;

    player_position player1_position(
        .clk(clk), .reset_position(reset_position), .paused(paused),
        .state(player_state), .jump(player_jump), .collision(p1_collision || gate_blocks(center_x1, player_state, gate_open)),
        .horizontal(position_x1), .vertical(position_y1)
    );

    player_position #(.START_VERTICAL(FLOOR_Y - PLATFORM_Y)) player2_position(
        .clk(clk), .reset_position(reset_position), .paused(paused),
        .state(player2_state), .jump(player2_jump), .collision(p2_collision || gate_blocks(center_x2, player2_state, gate_open)),
        .horizontal(position_x2), .vertical(position_y2)
    );

    function in_span;
        input [9:0] value, start, size;
        begin
            in_span = value >= start && value < start + size;
        end
    endfunction

    function gate_blocks;
        input [9:0] x;
        input [3:0] state;
        input open;
        begin
            gate_blocks = !open && ((state == RIGHT && x == GATE_X - 10'd1) ||
                                    (state == LEFT && x == GATE_X + 10'd1));
        end
    endfunction

    function [2:0] contacts;
        input [9:0] x, feet;
        input [1:0] jump;
        reg above_platform, supported, collision;
        begin
            above_platform = x >= PLATFORM_LEFT && x < PLATFORM_RIGHT;
            supported = feet == FLOOR_Y || (above_platform && feet == PLATFORM_Y);
            // Feet advance one pixel per step, so equality catches the top on descent.
            collision = jump == RISING && feet <= CEILING_HEIGHT + PLAYER_HEIGHT;
            contacts = {collision, jump == FALLING && supported, jump == GROUNDED && !supported};
        end
    endfunction

    assign {p1_collision, p1_land, should_down} = contacts(center_x1, feet_y1, player_jump);
    assign {p2_collision, p2_land, should_down2} = contacts(center_x2, feet_y2, player2_jump);

    wire p1_on_floor = feet_y1 == FLOOR_Y && player_jump != RISING;
    wire p2_on_floor = feet_y2 == FLOOR_Y && player2_jump != RISING;
    wire bridge_active =
        (p1_on_floor && in_span(center_x1, BRIDGE_SWITCH_LEFT, BRIDGE_SWITCH_WIDTH)) ||
        (p2_on_floor && in_span(center_x2, BRIDGE_SWITCH_LEFT, BRIDGE_SWITCH_WIDTH));

    wire red_pad_pressed = p1_on_floor && in_span(center_x1, RED_PAD_LEFT, GATE_PAD_WIDTH);
    wire blue_pad_pressed = p2_on_floor && in_span(center_x2, BLUE_PAD_LEFT, GATE_PAD_WIDTH);
    wire both_pads_pressed = red_pad_pressed && blue_pad_pressed;
    reg pads_held;
    reg [$clog2(GATE_OPEN_TICKS + 1)-1:0] gate_ticks;

    assign gate_open = gate_ticks != 0;
    always @(posedge clk) begin
        if (reset_position) begin
            pads_held <= 1'b0;
            gate_ticks <= 0;
        end else if (!paused) begin
            pads_held <= both_pads_pressed;
            if (both_pads_pressed && !pads_held)
                gate_ticks <= GATE_OPEN_TICKS;
            else if (gate_open)
                gate_ticks <= gate_ticks - 1'b1;
        end
    end

    // Players can cross the river that matches their color on foot.
    assign fail = !invincible &&
        ((!bridge_active && p1_on_floor && in_span(center_x1, BLUE_RIVER_LEFT, RIVER_WIDTH)) ||
         (p2_on_floor && in_span(center_x2, RED_RIVER_LEFT, RIVER_WIDTH)));
    assign clear = feet_y1 == FLOOR_Y && feet_y2 == FLOOR_Y &&
                   player_jump == GROUNDED && player2_jump == GROUNDED &&
                   in_span(center_x1, RED_EXIT_LEFT, EXIT_WIDTH) &&
                   in_span(center_x2, BLUE_EXIT_LEFT, EXIT_WIDTH);

    wire [9:0] h = vga_h >> 1;
    wire [9:0] v = vga_v >> 1;
    wire timer_first = in_span(h, TIMER_LEFT, 10'd5);
    wire timer_second = in_span(h, TIMER_LEFT + 10'd7, 10'd5);
    wire timer_third = in_span(h, TIMER_LEFT + 10'd14, 10'd5);
    wire timer_lit = (timer_first && gate_open) ||
                     (timer_second && gate_ticks > GATE_SECOND_TICKS) ||
                     (timer_third && gate_ticks > 2 * GATE_SECOND_TICKS);

    function [16:0] atlas;
        input [9:0] column, row;
        begin
            atlas = row * 17'd320 + column;
        end
    endfunction

    always @* begin
        if (h >= 10'd320 || v >= 10'd240)
            addr = 17'd0;
        else if (v < CEILING_HEIGHT)
            addr = atlas(h, v + 10'd220);
        else if (v >= FLOOR_Y && v < FLOOR_Y + 10'd6 && in_span(h, RED_RIVER_LEFT, RIVER_WIDTH))
            addr = RED_COLOR;
        else if (v >= FLOOR_Y && v < FLOOR_Y + 10'd6 && in_span(h, BLUE_RIVER_LEFT, RIVER_WIDTH))
            addr = bridge_active ? SWITCH_ACTIVE : BLUE_COLOR;
        else if (v >= FLOOR_Y)
            addr = atlas(h, v - 10'd10);
        else if (h < 10'd10)
            addr = atlas(h + 10'd305, v);
        else if (h >= 10'd310)
            addr = atlas(h - 10'd5, v);
        else if (!gate_open && h == GATE_X)
            addr = SWITCH_ACTIVE;
        else if (in_span(v, TIMER_Y, 10'd3) && (timer_first || timer_second || timer_third))
            addr = timer_lit ? SWITCH_ACTIVE : SWITCH_INACTIVE;
        else if (in_span(v, feet_y1 - PLAYER_HEIGHT, PLAYER_HEIGHT) &&
                 in_span(h, position_x1 + 10'd13, 10'd15))
            addr = atlas(h - position_x1 + 10'd40, v + PLAYER_HEIGHT - feet_y1);
        else if (in_span(v, feet_y2 - PLAYER_HEIGHT, PLAYER_HEIGHT) &&
                 in_span(h, position_x2 + 10'd13, 10'd14))
            addr = atlas(h - position_x2 + 10'd148, v + 10'd89 - feet_y2);
        else if (in_span(v, SWITCH_Y, 10'd4) && in_span(h, BRIDGE_SWITCH_LEFT, BRIDGE_SWITCH_WIDTH))
            addr = bridge_active ? SWITCH_ACTIVE : SWITCH_INACTIVE;
        else if (in_span(v, SWITCH_Y, 10'd4) && in_span(h, RED_PAD_LEFT, GATE_PAD_WIDTH))
            addr = red_pad_pressed ? SWITCH_ACTIVE : RED_COLOR;
        else if (in_span(v, SWITCH_Y, 10'd4) && in_span(h, BLUE_PAD_LEFT, GATE_PAD_WIDTH))
            addr = blue_pad_pressed ? SWITCH_ACTIVE : BLUE_COLOR;
        else if (in_span(v, 10'd201, 10'd29) && in_span(h, RED_EXIT_LEFT, EXIT_WIDTH))
            addr = atlas(h - RED_EXIT_LEFT, v - 10'd112);
        else if (in_span(v, 10'd201, 10'd29) && in_span(h, BLUE_EXIT_LEFT, EXIT_WIDTH))
            addr = atlas(h - BLUE_EXIT_LEFT + 10'd32, v - 10'd112);
        else if (h >= PLATFORM_LEFT && h < PLATFORM_RIGHT && in_span(v, PLATFORM_Y, PLATFORM_HEIGHT))
            addr = atlas(h + 10'd40, v + 10'd25);
        else
            addr = 17'd12900;
    end
endmodule
