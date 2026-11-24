module music_ctrl(
    input clk,
    input rst,
    input is_menu,
    output audio_mclk,
    output audio_lrck,
    output audio_sck,
    output audio_sdin
);
    wire beat_tick;
    wire [13:0] menu_beat, game_beat;
    wire [21:0] menu_left, menu_right, game_left, game_right;
    wire [15:0] sample_left, sample_right;
    reg previous_menu;

    always @(posedge clk or posedge rst) begin
        if (rst)
            previous_menu <= 1'b1;
        else
            previous_menu <= is_menu;
    end

    wire track_changed = previous_menu != is_menu;
    bpm_controller #(.BPM(16 * 180)) tempo(
        .clk(clk), .rst(rst), .restart(track_changed), .beat_tick(beat_tick)
    );

    player_control #(.LEN(3840)) menu_position(
        .clk(clk), .rst(rst), .en(is_menu), .beat_tick(beat_tick), .ibeat(menu_beat)
    );
    player_control #(.LEN(5760)) game_position(
        .clk(clk), .rst(rst), .en(!is_menu), .beat_tick(beat_tick), .ibeat(game_beat)
    );

    music_viyella menu_song(.ibeatNum(menu_beat), .toneL(menu_left), .toneR(menu_right));
    music_unwelcome_school game_song(.ibeatNum(game_beat), .toneL(game_left), .toneR(game_right));

    note_gen notes(
        .clk(clk), .rst(rst), .volume(3'd3),
        .note_div_left(is_menu ? menu_left : game_left),
        .note_div_right(is_menu ? menu_right : game_right),
        .audio_left(sample_left), .audio_right(sample_right)
    );

    speaker_control speaker(
        .clk(clk), .rst(rst), .audio_in_left(sample_left), .audio_in_right(sample_right),
        .audio_mclk(audio_mclk), .audio_lrck(audio_lrck),
        .audio_sck(audio_sck), .audio_sdin(audio_sdin)
    );
endmodule
