module final_project(
    input clk,
    input rst,
    input invincible,
    output [3:0] vgaRed,
    output [3:0] vgaGreen,
    output [3:0] vgaBlue,
    output hsync,
    output vsync,
    output wire [6:0] DISPLAY,
    output wire [3:0] DIGIT,
    inout PS2_DATA,
    inout PS2_CLK,
    output [15:0] led,
    output audio_mclk, // master clock
    output audio_lrck, // left-right clock
    output audio_sck,  // serial clock
    output audio_sdin // serial audio data input
);
    //vga variables
    wire pixel_tick;
    wire [16:0] pixel_addr;
    wire [11:0] pixel;
    wire valid;
    wire [9:0] h_cnt; //640
    wire [9:0] v_cnt;  //480


    wire flag_alphabet;//to show cover or not

    wire hsync_raw, vsync_raw;
    wire game_clear, game_fail;
    reg pixel_valid, pixel_hsync, pixel_vsync;

    // Match the one-cycle read latency of the video memories.
    always @(posedge clk) begin
        if (rst) begin
            pixel_valid <= 1'b0;
            pixel_hsync <= 1'b1;
            pixel_vsync <= 1'b1;
        end else if (pixel_tick) begin
            pixel_valid <= valid;
            pixel_hsync <= hsync_raw;
            pixel_vsync <= vsync_raw;
        end
    end

    assign hsync = pixel_hsync;
    assign vsync = pixel_vsync;
    assign {vgaRed, vgaGreen, vgaBlue} = pixel_valid ? pixel : 12'h000;
    wire [9:0] key_down;


    clock_divider pixel_clock_enable(
        .clk(clk),
        .rst(rst),
        .pixel_tick(pixel_tick)
    );

    KeyboardDecoder k(
		.key_down(key_down),
		.last_change(),
		.key_valid(),
		.PS2_DATA(PS2_DATA),
		.PS2_CLK(PS2_CLK),
		.rst(rst),
		.clk(clk)
	);

    mem_ctrl MC(
        .clk(clk), .pixel_tick(pixel_tick), .rst(rst), .flag_alphabet(flag_alphabet),
        .pixel_addr(pixel_addr), .pixel(pixel)
    );

    vga_controller   vga_inst(
        .pclk(clk),
        .pixel_tick(pixel_tick),
        .reset(rst),
        .hsync(hsync_raw),
        .vsync(vsync_raw),
        .valid(valid),
        .h_cnt(h_cnt),
        .v_cnt(v_cnt)
    );

    wire [2:0] select;

    T TT(
        .clk(clk),
        .rst(rst),
        .DISPLAY(DISPLAY),
        .DIGIT(DIGIT),
        .game_clear(game_clear),
        .game_fail(game_fail),
        .select(select != 3'd0)
    );

    //music choose

    music_ctrl MusicControl(
        .clk(clk), .rst(rst), .is_menu(select == 0),
        .audio_mclk(audio_mclk), .audio_lrck(audio_lrck),
        .audio_sck(audio_sck), .audio_sdin(audio_sdin)
    );

    map_switch Map_switch(
        .clk(clk),
        .rst(rst),
        .key_down(key_down),
        .vga_h(h_cnt),
        .vga_v(v_cnt),
        .pixel_addr(pixel_addr),
        .led(led),
        .select(select),
        .flag_alphabet(flag_alphabet),
        .invincible(invincible),
        .game_clear(game_clear),
        .game_fail(game_fail)
    );

endmodule
