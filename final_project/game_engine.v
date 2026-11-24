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

    //map
    reg [2:0] map = 1;
    reg en_key = 1;
    wire [3:0] player_state, player2_state;
    wire [1:0] player_jump, player2_jump;

    //map1 wires
    wire map1_p1_collision, map1_p2_collision;
    wire map1_p1_land, map1_p2_land;
    wire map1_should_down, map1_should_down2;

    //map2 wires
    wire map2_p1_collision, map2_p2_collision;
    wire map2_p1_land, map2_p2_land;
    wire map2_should_down, map2_should_down2;

    //map3 wires
    wire map3_p1_collision, map3_p2_collision;
    wire map3_p1_land, map3_p2_land;
    wire map3_should_down, map3_should_down2;

    wire map4_p1_collision, map4_p2_collision;
    wire map4_p1_land, map4_p2_land;
    wire map4_should_down, map4_should_down2;
    wire map4_clear, map4_fail;

    //wires of maps
    //using selector to choose the final output
    reg p1_collision, p2_collision;
    reg p1_land, p2_land;
    reg should_down, should_down2;

    wire [16:0] map1_addr, map2_addr, map3_addr, map4_addr;
    wire map1_clear, map2_clear, map3_clear;
    wire map1_fail, map2_fail, map3_fail;
    localparam [1:0] IN_PROGRESS = 2'd0, CLEARED = 2'd1, FAILED = 2'd2;
    reg [1:0] result;
    reg selected_clear, selected_fail;

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

            if (select != 0) begin
                if (enter_pressed) begin
                    select <= 3'd0;
                    en_key <= 1'b0;
                end
            end else if (en_key) begin
                if (key_down[0] || key_down[4]) begin
                    if (map < 3'd4)
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
        else if (select == 0 || enter_pressed)
            result <= IN_PROGRESS;
        else if (result == IN_PROGRESS) begin
            if (selected_clear)
                result <= CLEARED;
            else if (selected_fail)
                result <= FAILED;
        end
    end

    player_motion player1_motion(
        .clk(clk), .rst(rst), .active(select != 0),
        .finished(finished), .keys(key_down[7:4]),
        .collision(p1_collision), .landed(p1_land), .should_drop(should_down),
        .state(player_state), .jump(player_jump)
    );

    player_motion player2_motion(
        .clk(clk), .rst(rst), .active(select != 0),
        .finished(finished), .keys(key_down[3:0]),
        .collision(p2_collision), .landed(p2_land), .should_drop(should_down2),
        .state(player2_state), .jump(player2_jump)
    );
    wire [9:0] h, v;
    assign h = vga_h >> 1;
    assign v = vga_v >> 1;

    wire [16:0] map_and_menu_addr;
    map_and_menu_addr_gen MAMAG(
        .h(h), .v(v), .select(select), .map(map),
        .map1_addr(map1_addr),
        .map2_addr(map2_addr),
        .map3_addr(map3_addr), .map4_addr(map4_addr),
        .map_and_menu_addr(map_and_menu_addr)
    );

    //indicate which blk_mem to connect
    assign flag_alphabet = flag_cover || game_clear || game_fail;
    always @* begin
        if(flag_cover) pixel_addr = {1'b0, cover_addr};
        else if(game_clear) pixel_addr = {1'b0, game_clear_scene_addr};
        else if(game_fail) pixel_addr = {1'b0, game_fail_scene_addr};
        else pixel_addr = map_and_menu_addr;
    end

    // Original campaign maps.
    map1 Map1(
        .clk(clk),
        .rst(rst),
        .en((map == 1) && select),
        .paused(finished),
        .addr(map1_addr),
        .vga_h(vga_h),
        .vga_v(vga_v),
        .player_state(player_state),
        .player2_state(player2_state),
        .player_jump(player_jump),
        .player2_jump(player2_jump),
        .p1_collision(map1_p1_collision),
        .p2_collision(map1_p2_collision),
        .p1_land(map1_p1_land),
        .p2_land(map1_p2_land),
        .should_down(map1_should_down),
        .should_down2(map1_should_down2),
        .button1_tounch(),
        .clear(map1_clear), .fail(map1_fail),
        .invincible(invincible)
    );

    map2 Map2(
        .clk(clk),
        .rst(rst),
        .en((map == 2) && select),
        .paused(finished),
        .addr(map2_addr),
        .vga_h(vga_h),
        .vga_v(vga_v),
        .player_state(player_state),
        .player2_state(player2_state),
        .player_jump(player_jump),
        .player2_jump(player2_jump),
        .p1_collision(map2_p1_collision),
        .p2_collision(map2_p2_collision),
        .p1_land(map2_p1_land),
        .p2_land(map2_p2_land),
        .should_down(map2_should_down),
        .should_down2(map2_should_down2),
        .button1_tounch(),
        .clear(map2_clear), .fail(map2_fail),
        .invincible(invincible)
    );

    map3 Map3(
        .clk(clk),
        .rst(rst),
        .en((map == 3) && select),
        .paused(finished),
        .addr(map3_addr),
        .vga_h(vga_h),
        .vga_v(vga_v),
        .player_state(player_state),
        .player2_state(player2_state),
        .player_jump(player_jump),
        .player2_jump(player2_jump),
        .p1_collision(map3_p1_collision),
        .p2_collision(map3_p2_collision),
        .p1_land(map3_p1_land),
        .p2_land(map3_p2_land),
        .should_down(map3_should_down),
        .should_down2(map3_should_down2),
        .button1_tounch(),
        .clear(map3_clear), .fail(map3_fail),
        .invincible(invincible)
    );

    practice_map Map4(
        .clk(clk),
        .rst(rst),
        .en((map == 4) && select),
        .paused(finished),
        .addr(map4_addr),
        .vga_h(vga_h),
        .vga_v(vga_v),
        .player_state(player_state),
        .player2_state(player2_state),
        .player_jump(player_jump),
        .player2_jump(player2_jump),
        .p1_collision(map4_p1_collision),
        .p2_collision(map4_p2_collision),
        .p1_land(map4_p1_land),
        .p2_land(map4_p2_land),
        .should_down(map4_should_down),
        .should_down2(map4_should_down2),
        .clear(map4_clear), .fail(map4_fail),
        .invincible(invincible)
    );

    always @* begin
        {selected_clear, selected_fail, p1_collision, p2_collision, p1_land, p2_land, should_down, should_down2}
            = 8'b0;
        if (select != 0) begin
            case (map)
                3'd1: {selected_clear, selected_fail, p1_collision, p2_collision, p1_land, p2_land, should_down, should_down2}
                    = {map1_clear, map1_fail, map1_p1_collision, map1_p2_collision, map1_p1_land,
                       map1_p2_land, map1_should_down, map1_should_down2};
                3'd2: {selected_clear, selected_fail, p1_collision, p2_collision, p1_land, p2_land, should_down, should_down2}
                    = {map2_clear, map2_fail, map2_p1_collision, map2_p2_collision, map2_p1_land,
                       map2_p2_land, map2_should_down, map2_should_down2};
                3'd3: {selected_clear, selected_fail, p1_collision, p2_collision, p1_land, p2_land, should_down, should_down2}
                    = {map3_clear, map3_fail, map3_p1_collision, map3_p2_collision, map3_p1_land,
                       map3_p2_land, map3_should_down, map3_should_down2};
                3'd4: {selected_clear, selected_fail, p1_collision, p2_collision, p1_land, p2_land, should_down, should_down2}
                    = {map4_clear, map4_fail, map4_p1_collision, map4_p2_collision, map4_p1_land,
                       map4_p2_land, map4_should_down, map4_should_down2};
                default: ;
            endcase
        end
    end
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
