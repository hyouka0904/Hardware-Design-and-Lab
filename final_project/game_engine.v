module map_switch(
    input clk,
    input rst,
    input invincible,
    input [9:0] key_down,
    input wire [9:0] vga_h, //640
    input wire [9:0] vga_v,  //480
    output reg [16:0] pixel_addr,
    output wire [15:0] led,
    output reg [2:0] select,
    output wire flag_alphabet,
    output wire game_clear, game_fail
);

    localparam [2:0] MAP_COUNT = 3'd4;
    localparam [1:0] IN_PROGRESS = 2'd0, CLEARED = 2'd1, FAILED = 2'd2;

    reg [2:0] map = 3'd1;
    reg en_key = 1'b1;
    reg [1:0] result;

    wire round_active = select != 0;
    wire map_valid = map >= 3'd1 && map <= MAP_COUNT;
    wire active_map = round_active && map_valid;
    wire [16:0] map_addr [1:MAP_COUNT];
    wire [MAP_COUNT:1] map_clear, map_fail;
    wire [MAP_COUNT:1] map_p1_collision, map_p2_collision;
    wire [MAP_COUNT:1] map_p1_land, map_p2_land;
    wire [MAP_COUNT:1] map_p1_drop, map_p2_drop;

    wire selected_clear = active_map && map_clear[map];
    wire selected_fail = active_map && map_fail[map];
    wire [3:0] player_state, player2_state;
    wire [1:0] player_jump, player2_jump;

    assign game_clear = result == CLEARED;
    assign game_fail = result == FAILED;
    assign led = game_clear ? 16'hffff : (game_fail ? 16'hf0f0 : 16'h000f);
    wire finished = result != IN_PROGRESS || selected_clear || selected_fail;

    //game end related variables
    wire [15:0] game_clear_scene_addr, game_fail_scene_addr;
    clear_scene game_clear_scene(
        .clk(clk), .vga_h(vga_h), .vga_v(vga_v),
        .addr(game_clear_scene_addr)
    );
    fail_scene game_fail_scene(
        .clk(clk), .vga_h(vga_h), .vga_v(vga_v),
        .addr(game_fail_scene_addr)
    );

    //cover related variables
    //cover_gen
    wire [15:0] cover_addr;
    game_cover escape_from_NTHU(
        .clk(clk),
        .vga_h(vga_h),
        .vga_v(vga_v),
        .addr(cover_addr)
    );

    reg flag_cover;
    reg enter_held;
    wire enter_pressed = key_down[8] && !enter_held;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            map <= 3'd1;
            select <= 3'd0;
            en_key <= 1'b1;
            flag_cover <= 1'b1;
            enter_held <= 1'b0;
        end else begin
            enter_held <= key_down[8];
            if (key_down[8:0] == 9'd0)
                en_key <= 1'b1;

            if (round_active) begin
                if (enter_pressed) begin
                    select <= 3'd0;
                    en_key <= 1'b0;
                end
            end else if (en_key) begin
                if (key_down[0] || key_down[4]) begin
                    if (map < MAP_COUNT)
                        map <= map + 1'b1;
                    en_key <= 1'b0;
                end else if (key_down[2] || key_down[6]) begin
                    if (map > 3'd1)
                        map <= map - 1'b1;
                    en_key <= 1'b0;
                end else if (enter_pressed) begin
                    if (flag_cover)
                        flag_cover <= 1'b0;
                    else
                        select <= 3'd1;
                    en_key <= 1'b0;
                end
            end
        end
    end

    // Keep the first result until reset or the player returns to the menu.
    always @(posedge clk or posedge rst) begin
        if (rst)
            result <= IN_PROGRESS;
        else if (!round_active || enter_pressed)
            result <= IN_PROGRESS;
        else if (result == IN_PROGRESS) begin
            if (selected_clear)
                result <= CLEARED;
            else if (selected_fail)
                result <= FAILED;
        end
    end

    player_motion player1_motion(
        .clk(clk), .rst(rst), .active(round_active),
        .finished(finished), .keys(key_down[7:4]),
        .collision(active_map && map_p1_collision[map]),
        .landed(active_map && map_p1_land[map]),
        .should_drop(active_map && map_p1_drop[map]),
        .state(player_state), .jump(player_jump)
    );

    player_motion player2_motion(
        .clk(clk), .rst(rst), .active(round_active),
        .finished(finished), .keys(key_down[3:0]),
        .collision(active_map && map_p2_collision[map]),
        .landed(active_map && map_p2_land[map]),
        .should_drop(active_map && map_p2_drop[map]),
        .state(player2_state), .jump(player2_jump)
    );
    wire [16:0] menu_addr;
    menu_pixel_addr #(.MAP_COUNT(MAP_COUNT)) menu(
        .h(vga_h >> 1), .v(vga_v >> 1), .map(map), .addr(menu_addr)
    );

    assign flag_alphabet = flag_cover || game_clear || game_fail;
    always @* begin
        if (flag_cover)
            pixel_addr = {1'b0, cover_addr};
        else if (game_clear)
            pixel_addr = {1'b0, game_clear_scene_addr};
        else if (game_fail)
            pixel_addr = {1'b0, game_fail_scene_addr};
        else if (round_active)
            pixel_addr = map_valid ? map_addr[map] : 17'd0;
        else
            pixel_addr = menu_addr;
    end

    // Original campaign maps.
    map1 Map1(
        .clk(clk),
        .rst(rst),
        .en(round_active && map == 3'd1),
        .paused(finished),
        .addr(map_addr[1]),
        .vga_h(vga_h),
        .vga_v(vga_v),
        .player_state(player_state),
        .player2_state(player2_state),
        .player_jump(player_jump),
        .player2_jump(player2_jump),
        .p1_collision(map_p1_collision[1]),
        .p2_collision(map_p2_collision[1]),
        .p1_land(map_p1_land[1]),
        .p2_land(map_p2_land[1]),
        .should_down(map_p1_drop[1]),
        .should_down2(map_p2_drop[1]),
        .button1_tounch(),
        .clear(map_clear[1]), .fail(map_fail[1]),
        .invincible(invincible)
    );

    map2 Map2(
        .clk(clk),
        .rst(rst),
        .en(round_active && map == 3'd2),
        .paused(finished),
        .addr(map_addr[2]),
        .vga_h(vga_h),
        .vga_v(vga_v),
        .player_state(player_state),
        .player2_state(player2_state),
        .player_jump(player_jump),
        .player2_jump(player2_jump),
        .p1_collision(map_p1_collision[2]),
        .p2_collision(map_p2_collision[2]),
        .p1_land(map_p1_land[2]),
        .p2_land(map_p2_land[2]),
        .should_down(map_p1_drop[2]),
        .should_down2(map_p2_drop[2]),
        .button1_tounch(),
        .clear(map_clear[2]), .fail(map_fail[2]),
        .invincible(invincible)
    );

    map3 Map3(
        .clk(clk),
        .rst(rst),
        .en(round_active && map == 3'd3),
        .paused(finished),
        .addr(map_addr[3]),
        .vga_h(vga_h),
        .vga_v(vga_v),
        .player_state(player_state),
        .player2_state(player2_state),
        .player_jump(player_jump),
        .player2_jump(player2_jump),
        .p1_collision(map_p1_collision[3]),
        .p2_collision(map_p2_collision[3]),
        .p1_land(map_p1_land[3]),
        .p2_land(map_p2_land[3]),
        .should_down(map_p1_drop[3]),
        .should_down2(map_p2_drop[3]),
        .button1_tounch(),
        .clear(map_clear[3]), .fail(map_fail[3]),
        .invincible(invincible)
    );

    practice_map Map4(
        .clk(clk),
        .rst(rst),
        .en(round_active && map == 3'd4),
        .paused(finished),
        .addr(map_addr[4]),
        .vga_h(vga_h),
        .vga_v(vga_v),
        .player_state(player_state),
        .player2_state(player2_state),
        .player_jump(player_jump),
        .player2_jump(player2_jump),
        .p1_collision(map_p1_collision[4]),
        .p2_collision(map_p2_collision[4]),
        .p1_land(map_p1_land[4]),
        .p2_land(map_p2_land[4]),
        .should_down(map_p1_drop[4]),
        .should_down2(map_p2_drop[4]),
        .clear(map_clear[4]), .fail(map_fail[4]),
        .invincible(invincible)
    );

endmodule

module player_motion(
    input clk,
    input rst,
    input active,
    input finished,
    input [3:0] keys,
    input collision,
    input landed,
    input should_drop,
    output reg [3:0] state,
    output reg [1:0] jump
);
    localparam [3:0] IDLE = 4'd6, RIGHT = 4'd7, LEFT = 4'd8, UP = 4'd9;
    localparam [1:0] GROUNDED = 2'd0, RISING = 2'd1, FALLING = 2'd2;
    localparam [27:0] RISE_LIMIT = 28'd70000000, FALL_LIMIT = 28'd240000000;

    reg [27:0] jump_ticks;
    // Only one horizontal direction can be active. Down is reserved.
    wire move_left = keys[1] && !keys[3];
    wire move_right = keys[3] && !keys[1];
    wire jump_requested = keys[0];

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            jump <= GROUNDED;
            jump_ticks <= 28'd0;
        end else if (!active) begin
            state <= IDLE;
            jump <= GROUNDED;
            jump_ticks <= 28'd0;
        end else if (!finished) begin
            if (move_left)
                state <= LEFT;
            else if (move_right)
                state <= RIGHT;
            else if (jump_requested || jump != GROUNDED || should_drop)
                state <= UP;
            else
                state <= IDLE;

            if (jump == GROUNDED && !jump_requested && !should_drop) begin
                jump_ticks <= 28'd0;
            end else if (!should_drop && jump != FALLING &&
                         !collision && jump_ticks < RISE_LIMIT) begin
                jump <= RISING;
                jump_ticks <= jump_ticks + 1'b1;
            end else if (!landed && jump_ticks < FALL_LIMIT) begin
                jump <= FALLING;
                jump_ticks <= jump_ticks + 1'b1;
            end else begin
                jump <= GROUNDED;
                jump_ticks <= 28'd0;
            end
        end
    end
endmodule
