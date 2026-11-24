`define silence   32'd50000000
`define low_low_do   32'd66
`define low_low_re   32'd74
`define low_low_mi   32'd83
`define low_low_fa   32'd87
`define low_low_so   32'd98
`define low_low_la   32'd110
`define low_low_si   32'd124
`define low_do   32'd131
`define low_re   32'd147
`define low_mi   32'd165
`define low_fa   32'd174
`define low_so   32'd196
`define low_la   32'd220
`define low_si   32'd247
`define do   32'd262   
`define re   32'd294
`define mi   32'd330
`define fa   32'd349
`define so   32'd392   
`define la   32'd440
`define si   32'd494   
`define high_do  32'd524   
`define high_re  32'd588   
`define high_mi  32'd660   
`define high_fa  32'd698   
`define high_so  32'd784   
`define high_la  32'd880
`define high_si  32'd988

module lab7(
    input clk,
    input rst,        // BTNC: active high reset
    input _play,      // SW0: Play/Pause
    input _start,     // SW1: Start/Exit
    input _mute,      // SW14: Mute
    input _mode,      // SW15: Mode
    input _volUP,     // BTNU: Vol up
    input _volDOWN,   // BTND: Vol down
    inout PS2_DATA,   // Keyboard I/O
    inout PS2_CLK,    // Keyboard I/O
    output reg [15:0] _led,       // LED: [15:9] key & [4:0] volume
    output audio_mclk, // master clock
    output audio_lrck, // left-right clock
    output audio_sck,  // serial clock
    output audio_sdin, // serial audio data input
    output reg [6:0] DISPLAY,    
    output reg [3:0] DIGIT
    );        
    
    parameter minus = 10, C = 11, D = 12, E = 13, F = 14, G = 15, A = 16, B = 17, empty = 18;

    parameter [8:0] Q_code = 9'b0_0001_0101;
    parameter [8:0] W_code = 9'b0_0001_1101;
    parameter [8:0] E_code = 9'b0_0010_0100;
    parameter [8:0] R_code = 9'b0_0010_1101;
    parameter [8:0] T_code = 9'b0_0010_1100;
    parameter [8:0] Y_code = 9'b0_0011_0101;
    parameter [8:0] U_code = 9'b0_0011_1100;
    parameter [8:0] A_code = 9'b0_0001_1100;
    parameter [8:0] S_code = 9'b0_0001_1011;
    parameter [8:0] D_code = 9'b0_0010_0011;
    parameter [8:0] F_code = 9'b0_0010_1011;
    parameter [8:0] G_code = 9'b0_0011_0100;
    parameter [8:0] H_code = 9'b0_0011_0011;
    parameter [8:0] J_code = 9'b0_0011_1011;
    parameter [8:0] Z_code = 9'b0_0001_1010;
    parameter [8:0] X_code = 9'b0_0010_0010;
    parameter [8:0] C_code = 9'b0_0010_0001;
    parameter [8:0] V_code = 9'b0_0010_1010;
    parameter [8:0] B_code = 9'b0_0011_0010;
    parameter [8:0] N_code = 9'b0_0011_0001;
    parameter [8:0] M_code = 9'b0_0011_1010;
    
    // Modify these
    //assign _led = 16'b1110_0000_0001_1111;
    //assign DIGIT = 4'b0000;
    //assign DISPLAY = 7'b0111111;

    // Internal Signal
    wire [15:0] audio_in_left, audio_in_right;

    wire [11:0] ibeatNum;               // Beat counter
    wire [31:0] freqL, freqR, key_L, key_R;           // Raw frequency, produced by music module
    wire [21:0] freq_outL, freq_outR;    // Processed frequency, adapted to the clock rate of Basys3

    // clkDiv22
    wire clkDiv22, seven_segment_clk;
    wire [5:0] order;
    wire rst_onepulse, _volUP_onepulse, _volDOWN_onepulse, rst_debounced, volUP_debounced, volDOWN_debounced;
    wire been_ready;
    wire [4:0] move;
    wire [21:0] key_down;
    wire [8:0] last_change;
    wire [21:0] key_decode = 1 << move;
    assign move =   (last_change == Q_code) ? 0 :
	                (last_change == W_code) ? 1 :
				    (last_change == E_code) ? 2 :
					(last_change == R_code) ? 3 :
					(last_change == T_code) ? 4 :
					(last_change == Y_code) ? 5 :
					(last_change == U_code) ? 6 :
					(last_change == A_code) ? 7 :
					(last_change == S_code) ? 8 :
					(last_change == D_code) ? 9 :
					(last_change == F_code) ? 10 :
					(last_change == G_code) ? 11 :
					(last_change == H_code) ? 12 :
					(last_change == J_code) ? 13 :
					(last_change == Z_code) ? 14 :
					(last_change == X_code) ? 15 :
					(last_change == C_code) ? 16 :
					(last_change == V_code) ? 17 :
					(last_change == B_code) ? 18 :
					(last_change == N_code) ? 19 :
					(last_change == M_code) ? 20 : 21;
    clock_divider #(.n(22)) clock_22(.clk(clk), .clk_div(clkDiv22));    // for audio
    clock_divider #(.n(14)) clock_14(.clk(clk), .clk_div(seven_segment_clk));
    debounce d1(.clk(clk), .pb(rst), .pb_debounced(rst_debounced));
    onepulse o1(.clk(clk), .signal(rst_debounced), .op(rst_onepulse));
    debounce d2(.clk(clk), .pb(_volUP), .pb_debounced(volUP_debounced));
    onepulse o2(.clk(clk), .signal(volUP_debounced), .op(_volUP_onepulse));
    debounce d3(.clk(clk), .pb(_volDOWN), .pb_debounced(volDOWN_debounced));
    onepulse o3(.clk(clk), .signal(volDOWN_debounced), .op(_volDOWN_onepulse));

    reg [49:0] is_scored = 50'b0; 
    reg [19:0] nums;
    reg [4:0] display_num, score_units_digit = 5'b0, score_tens_digits = 5'b0, next_score_units_digit = 5'b0, next_score_tens_digits = 5'b0;
    reg [2:0] amplitude = 3'd3, pre_amplitude;
    reg refresh_vol = 1'b0, en = 1'b1, finish = 1'b0;
    
    // Player Control
    // [in]  reset, clock, _play, _slow, _music, and _mode
    // [out] beat number
    assign order =  (ibeatNum >= 0 && ibeatNum <= 6) ? 1 :
                    (ibeatNum >= 8 && ibeatNum <= 14) ? 2 :
                    (ibeatNum >= 16 && ibeatNum <= 30) ? 3 :
                    (ibeatNum >= 32 && ibeatNum <= 38) ? 4 :
                    (ibeatNum >= 40 && ibeatNum <= 46) ? 5 :
                    (ibeatNum >= 48 && ibeatNum <= 62) ? 6 :
                    (ibeatNum >= 64 && ibeatNum <= 71) ? 7 :
                    (ibeatNum >= 72 && ibeatNum <= 79) ? 8 :
                    (ibeatNum >= 80 && ibeatNum <= 87) ? 9 :
                    (ibeatNum >= 88 && ibeatNum <= 95) ? 10 :
                    (ibeatNum >= 96 && ibeatNum <= 127) ? 11 :
                    (ibeatNum >= 128 && ibeatNum <= 134) ? 12 :
                    (ibeatNum >= 136 && ibeatNum <= 142) ? 13 :
                    (ibeatNum >= 144 && ibeatNum <= 154) ? 14 :
                    (ibeatNum >= 156 && ibeatNum <= 158) ? 15 :
                    (ibeatNum >= 160 && ibeatNum <= 167) ? 16 :
                    (ibeatNum >= 168 && ibeatNum <= 174) ? 17 : 
                    (ibeatNum >= 176 && ibeatNum <= 186) ? 18 :
                    (ibeatNum >= 188 && ibeatNum <= 190) ? 19 :
                    (ibeatNum >= 192 && ibeatNum <= 199) ? 20 :
                    (ibeatNum >= 200 && ibeatNum <= 206) ? 21 :
                    (ibeatNum >= 208 && ibeatNum <= 215) ? 22 :
                    (ibeatNum >= 216 && ibeatNum <= 223) ? 23 :
                    (ibeatNum >= 224 && ibeatNum <= 239) ? 24 :
                    (ibeatNum >= 240 && ibeatNum <= 255) ? 25 :
                    (ibeatNum >= 256 && ibeatNum <= 262) ? 26 :
                    (ibeatNum >= 264 && ibeatNum <= 270) ? 27 :
                    (ibeatNum >= 272 && ibeatNum <= 286) ? 28 :
                    (ibeatNum >= 288 && ibeatNum <= 294) ? 29 :
                    (ibeatNum >= 296 && ibeatNum <= 302) ? 30 :
                    (ibeatNum >= 304 && ibeatNum <= 318) ? 31 :
                    (ibeatNum >= 320 && ibeatNum <= 327) ? 32 :
                    (ibeatNum >= 328 && ibeatNum <= 335) ? 33 :
                    (ibeatNum >= 336 && ibeatNum <= 343) ? 34 : 
                    (ibeatNum >= 344 && ibeatNum <= 351) ? 35 :
                    (ibeatNum >= 352 && ibeatNum <= 383) ? 36 :
                    (ibeatNum >= 384 && ibeatNum <= 390) ? 37 :
                    (ibeatNum >= 392 && ibeatNum <= 398) ? 38 :
                    (ibeatNum >= 400 && ibeatNum <= 410) ? 39 :
                    (ibeatNum >= 412 && ibeatNum <= 414) ? 40 :
                    (ibeatNum >= 416 && ibeatNum <= 423) ? 41 :
                    (ibeatNum >= 424 && ibeatNum <= 430) ? 42 :
                    (ibeatNum >= 432 && ibeatNum <= 442) ? 43 :
                    (ibeatNum >= 444 && ibeatNum <= 447) ? 44 :
                    (ibeatNum >= 448 && ibeatNum <= 454) ? 45 :
                    (ibeatNum >= 456 && ibeatNum <= 463) ? 46 :
                    (ibeatNum >= 464 && ibeatNum <= 471) ? 47 :
                    (ibeatNum >= 472 && ibeatNum <= 479) ? 48 :
                    (ibeatNum >= 480 && ibeatNum <= 512) ? 49 : 50;

    KeyboardDecoder k(
		.key_down(key_down),
		.last_change(last_change),
		.key_valid(been_ready),
		.PS2_DATA(PS2_DATA),
		.PS2_CLK(PS2_CLK),
		.rst(rst),
		.clk(clk)
	);

    player_control #(.LEN(512)) playerCtrl_00 ( 
        .clk(clkDiv22),
        .reset(rst_onepulse),
        ._start(_start),
        ._play(_play), 
        ._mode(_mode),
        .ibeat(ibeatNum)
    );
    // Music module
    // [in]  beat number and en
    // [out] left & right raw frequency
    /*cat_war music_00 (
        .ibeatNum(ibeatNum),
        .en(_mode && _play),
        .toneL(freqL),
        .toneR(freqR)
    );*/
    
    Jingle_Bells music_01 (
        .ibeatNum(ibeatNum),
        .en((_mode && _play) || (!_mode && _start)),
        .toneL(freqL),
        .toneR(freqR)
    );

    // freq_outL, freq_outR
    // Note gen makes no sound, if freq_out = 50000000 / `silence = 1
    assign freq_outL = (_mode == 1) ? 50000000 / freqL : 50000000 / key_L;
    assign freq_outR = (_mode == 1) ? 50000000 / freqR : 50000000 / key_R;
    assign key_L = (key_down == 22'b0 || (_led[15:9] == 7'b1111111)) ? `silence :
                    (key_down == 22'b00_0000_0000_0000_0000_0001 || (key_down[0] && move != 0)) ? `high_do :
                    (key_down == 22'b00_0000_0000_0000_0000_0010 || (key_down[1] && move != 1)) ? `high_re :
                    (key_down == 22'b00_0000_0000_0000_0000_0100 || (key_down[2] && move != 2)) ? `high_mi :
                    (key_down == 22'b00_0000_0000_0000_0000_1000 || (key_down[3] && move != 3)) ? `high_fa :
                    (key_down == 22'b00_0000_0000_0000_0001_0000 || (key_down[4] && move != 4)) ? `high_so :
                    (key_down == 22'b00_0000_0000_0000_0010_0000 || (key_down[5] && move != 5)) ? `high_la :
                    (key_down == 22'b00_0000_0000_0000_0100_0000 || (key_down[6] && move != 6)) ? `high_si :
                    (key_down == 22'b00_0000_0000_0000_1000_0000 || (key_down[7] && move != 7)) ? `do :
                    (key_down == 22'b00_0000_0000_0001_0000_0000 || (key_down[8] && move != 8)) ? `re :
                    (key_down == 22'b00_0000_0000_0010_0000_0000 || (key_down[9] && move != 9)) ? `mi :
                    (key_down == 22'b00_0000_0000_0100_0000_0000 || (key_down[10] && move != 10)) ? `fa :
                    (key_down == 22'b00_0000_0000_1000_0000_0000 || (key_down[11] && move != 11)) ? `so :
                    (key_down == 22'b00_0000_0001_0000_0000_0000 || (key_down[12] && move != 12)) ? `la :
                    (key_down == 22'b00_0000_0010_0000_0000_0000 || (key_down[13] && move != 13)) ? `si :
                    (key_down == 22'b00_0000_0100_0000_0000_0000 || (key_down[14] && move != 14)) ? `low_do :
                    (key_down == 22'b00_0000_1000_0000_0000_0000 || (key_down[15] && move != 15)) ? `low_re :
                    (key_down == 22'b00_0001_0000_0000_0000_0000 || (key_down[16] && move != 16)) ? `low_mi :
                    (key_down == 22'b00_0010_0000_0000_0000_0000 || (key_down[17] && move != 17)) ? `low_fa :
                    (key_down == 22'b00_0100_0000_0000_0000_0000 || (key_down[18] && move != 18)) ? `low_so :
                    (key_down == 22'b00_1000_0000_0000_0000_0000 || (key_down[19] && move != 19)) ? `low_la :
                    (key_down == 22'b01_0000_0000_0000_0000_0000 || (key_down[20] && move != 20)) ? `low_si : `silence;

    assign key_R = (key_down == 22'b0 || (_led[15:9] == 7'b1111111)) ? `silence :
                    (key_down == 22'b00_0000_0000_0000_0000_0001 || (key_down[0] && move != 0)) ? `high_do :
                    (key_down == 22'b00_0000_0000_0000_0000_0010 || (key_down[1] && move != 1)) ? `high_re :
                    (key_down == 22'b00_0000_0000_0000_0000_0100 || (key_down[2] && move != 2)) ? `high_mi :
                    (key_down == 22'b00_0000_0000_0000_0000_1000 || (key_down[3] && move != 3)) ? `high_fa :
                    (key_down == 22'b00_0000_0000_0000_0001_0000 || (key_down[4] && move != 4)) ? `high_so :
                    (key_down == 22'b00_0000_0000_0000_0010_0000 || (key_down[5] && move != 5)) ? `high_la :
                    (key_down == 22'b00_0000_0000_0000_0100_0000 || (key_down[6] && move != 6)) ? `high_si :
                    (key_down == 22'b00_0000_0000_0000_1000_0000 || (key_down[7] && move != 7)) ? `do :
                    (key_down == 22'b00_0000_0000_0001_0000_0000 || (key_down[8] && move != 8)) ? `re :
                    (key_down == 22'b00_0000_0000_0010_0000_0000 || (key_down[9] && move != 9)) ? `mi :
                    (key_down == 22'b00_0000_0000_0100_0000_0000 || (key_down[10] && move != 10)) ? `fa :
                    (key_down == 22'b00_0000_0000_1000_0000_0000 || (key_down[11] && move != 11)) ? `so :
                    (key_down == 22'b00_0000_0001_0000_0000_0000 || (key_down[12] && move != 12)) ? `la :
                    (key_down == 22'b00_0000_0010_0000_0000_0000 || (key_down[13] && move != 13)) ? `si :
                    (key_down == 22'b00_0000_0100_0000_0000_0000 || (key_down[14] && move != 14)) ? `low_do :
                    (key_down == 22'b00_0000_1000_0000_0000_0000 || (key_down[15] && move != 15)) ? `low_re :
                    (key_down == 22'b00_0001_0000_0000_0000_0000 || (key_down[16] && move != 16)) ? `low_mi :
                    (key_down == 22'b00_0010_0000_0000_0000_0000 || (key_down[17] && move != 17)) ? `low_fa :
                    (key_down == 22'b00_0100_0000_0000_0000_0000 || (key_down[18] && move != 18)) ? `low_so :
                    (key_down == 22'b00_1000_0000_0000_0000_0000 || (key_down[19] && move != 19)) ? `low_la :
                    (key_down == 22'b01_0000_0000_0000_0000_0000 || (key_down[20] && move != 20)) ? `low_si : `silence;
    // Note generation
    // [in]  processed frequency
    // [out] audio wave signal (using square wave here)
    note_gen noteGen_00(
        .clk(clk), 
        .rst(rst_onepulse), 
        .volume(amplitude),
        .note_div_left(freq_outL), 
        .note_div_right(freq_outR), 
        .audio_left(audio_in_left),     // left sound audio
        .audio_right(audio_in_right)    // right sound audio
    );

    // Speaker controller
    speaker_control sc(
        .clk(clk), 
        .rst(rst_onepulse), 
        .audio_in_left(audio_in_left),      // left channel audio data input
        .audio_in_right(audio_in_right),    // right channel audio data input
        .audio_mclk(audio_mclk),            // master clock
        .audio_lrck(audio_lrck),            // left-right clock
        .audio_sck(audio_sck),              // serial clock
        .audio_sdin(audio_sdin)             // serial audio data input
    );

    always @(posedge clk, posedge rst_onepulse) begin
        if(rst_onepulse) begin
            amplitude <= 3'd3;
            pre_amplitude <= 3'd3;
            refresh_vol <= 1'b0;
            en <= 1'b1;
        end
        else begin
            if(_mute) begin
                if(!refresh_vol) begin
                    pre_amplitude <= amplitude;
                    amplitude <= 3'd0;
                    refresh_vol <= 1'b1;
                    en <= en;
                end
                else begin
                    pre_amplitude <= pre_amplitude;
                    amplitude <= 3'd0;
                    refresh_vol <= 1'b1;
                    en <= en;
                end
            end else begin
                if(refresh_vol) begin
                    amplitude <= pre_amplitude;
                    refresh_vol <= 1'b0;
                    pre_amplitude <= amplitude;
                    en <= en;
                end
                else begin
                    if(_volDOWN_onepulse) begin
                        if(amplitude != 3'd1 && en) begin
                            en <= 1'b0;
                            amplitude <= amplitude - 1;
                        end
                        else begin
                            amplitude <= amplitude;
                            en <= 1'b0;
                        end
                    end
                    else if(_volUP_onepulse) begin
                        if(amplitude != 3'd5 && en) begin
                            en <= 1'b0;
                            amplitude <= amplitude + 1;
                        end
                        else begin
                            amplitude <= amplitude;
                            en <= 1'b0;
                        end
                    end
                    else begin
                        amplitude <= amplitude;
                        en <= 1'b1;
                    end
                end
            end
        end
    end

    always @(posedge clk, posedge rst_onepulse) begin
        if(rst_onepulse) begin
            _led <= 16'b0000_0000_0000_0111;
            finish <= 1'b0;
        end else begin
            if(!_mode) begin
                if(ibeatNum == 512) begin
                    if(_start) begin
                        _led[15:9] <= 7'b1111111;
                        _led[8:0] <= _led[8:0];    
                        finish <= 1'b1;
                    end
                    else if(!_start) begin
                        _led[15:9] <= 7'b0;
                        _led[8:0] <= _led[8:0];
                        finish <= 1'b0;
                    end
                end
                else begin
                    case(freqR)
                        `high_si, `si, `low_si, `low_low_si: begin
                            _led[15:9] <= 7'b0000001;
                            _led[4:0] <= (amplitude == 0) ? 5'b0 : 
                                        (amplitude == 1) ? 5'b00001 : 
                                        (amplitude == 2) ? 5'b00011 : 
                                        (amplitude == 3) ? 5'b00111 : 
                                        (amplitude == 4) ? 5'b01111 : 5'b11111;
                        end
                        `high_la, `la, `low_la, `low_low_la: begin
                            _led[15:9] <= 7'b0000010;
                            _led[4:0] <= (amplitude == 0) ? 5'b0 : 
                                        (amplitude == 1) ? 5'b00001 : 
                                        (amplitude == 2) ? 5'b00011 : 
                                        (amplitude == 3) ? 5'b00111 : 
                                        (amplitude == 4) ? 5'b01111 : 5'b11111;
                        end
                        `high_so, `so, `low_so, `low_low_so: begin
                            _led[15:9] <= 7'b0000100;
                            _led[4:0] <= (amplitude == 0) ? 5'b0 : 
                                        (amplitude == 1) ? 5'b00001 : 
                                        (amplitude == 2) ? 5'b00011 : 
                                        (amplitude == 3) ? 5'b00111 : 
                                        (amplitude == 4) ? 5'b01111 : 5'b11111;
                        end
                        `high_fa, `fa, `low_fa, `low_low_fa: begin
                            _led[15:9] <= 7'b0001000;
                            _led[4:0] <= (amplitude == 0) ? 5'b0 : 
                                        (amplitude == 1) ? 5'b00001 : 
                                        (amplitude == 2) ? 5'b00011 : 
                                        (amplitude == 3) ? 5'b00111 : 
                                        (amplitude == 4) ? 5'b01111 : 5'b11111;
                        end
                        `high_mi, `mi, `low_mi, `low_low_mi: begin
                            _led[15:9] <= 7'b0010000;
                            _led[4:0] <= (amplitude == 0) ? 5'b0 : 
                                        (amplitude == 1) ? 5'b00001 : 
                                        (amplitude == 2) ? 5'b00011 : 
                                        (amplitude == 3) ? 5'b00111 : 
                                        (amplitude == 4) ? 5'b01111 : 5'b11111;
                        end
                        `high_re, `re, `low_re, `low_low_re: begin
                            _led[15:9] <= 7'b0100000;
                            _led[4:0] <= (amplitude == 0) ? 5'b0 : 
                                        (amplitude == 1) ? 5'b00001 : 
                                        (amplitude == 2) ? 5'b00011 : 
                                        (amplitude == 3) ? 5'b00111 : 
                                        (amplitude == 4) ? 5'b01111 : 5'b11111;
                        end
                        `high_do, `do, `low_do, `low_low_do: begin
                            _led[15:9] <= 7'b1000000;
                            _led[4:0] <= (amplitude == 0) ? 5'b0 : 
                                        (amplitude == 1) ? 5'b00001 : 
                                        (amplitude == 2) ? 5'b00011 : 
                                        (amplitude == 3) ? 5'b00111 : 
                                        (amplitude == 4) ? 5'b01111 : 5'b11111;
                        end
                        `silence: begin
                            _led[15:9] <= 7'b0000000;
                            _led[4:0] <= (amplitude == 0) ? 5'b0 : 
                                        (amplitude == 1) ? 5'b00001 : 
                                        (amplitude == 2) ? 5'b00011 : 
                                        (amplitude == 3) ? 5'b00111 : 
                                        (amplitude == 4) ? 5'b01111 : 5'b11111;
                        end
                        default: _led <= _led;
                    endcase
                end
            end 
            else if(_mode) begin
                _led[15:5] <= 11'b0;
                _led[4:0] <= (amplitude == 0) ? 5'b0 : 
                            (amplitude == 1) ? 5'b00001 : 
                            (amplitude == 2) ? 5'b00011 : 
                            (amplitude == 3) ? 5'b00111 : 
                            (amplitude == 4) ? 5'b01111 : 5'b11111;
            end
        end
    end

    always @* begin
        if(!_play && _mode) nums = {5'd10, 5'd10, 5'd10, 5'd10};
        else begin
            if(_mode && _play) begin
                if(freqR == `do) nums = {5'd10, 5'd10, 5'd11, 5'd4};
                else if(freqR == `re) nums = {5'd10, 5'd10, 5'd12, 5'd4};
                else if(freqR == `mi) nums = {5'd10, 5'd10, 5'd13, 5'd4};
                else if(freqR == `fa) nums = {5'd10, 5'd10, 5'd14, 5'd4};
                else if(freqR == `so) nums = {5'd10, 5'd10, 5'd15, 5'd4};
                else if(freqR == `la) nums = {5'd10, 5'd10, 5'd16, 5'd4};
                else if(freqR == `si) nums = {5'd10, 5'd10, 5'd17, 5'd4};
                else if(freqR == `high_do) nums = {5'd10,5'd10, 5'd11, 5'd5};
                else if(freqR == `high_re) nums = {5'd10, 5'd10, 5'd12, 5'd5};
                else if(freqR == `high_mi) nums = {5'd10, 5'd10, 5'd13, 5'd5};
                else if(freqR == `high_fa) nums = {5'd10, 5'd10, 5'd14, 5'd5};
                else if(freqR == `high_so) nums = {5'd10, 5'd10, 5'd15, 5'd5};
                else if(freqR == `high_la) nums = {5'd10, 5'd10, 5'd16, 5'd5};
                else if(freqR == `high_si) nums = {5'd10, 5'd10, 5'd17, 5'd5};
                else if(freqR == `low_do) nums = {5'd10, 5'd10, 5'd11, 5'd3};
                else if(freqR == `low_re) nums = {5'd10, 5'd10, 5'd12, 5'd3};
                else if(freqR == `low_mi) nums = {5'd10, 5'd10, 5'd13, 5'd3};
                else if(freqR == `low_fa) nums = {5'd10, 5'd10, 5'd14, 5'd3};
                else if(freqR == `low_so) nums = {5'd10, 5'd10, 5'd15, 5'd3};
                else if(freqR == `low_la) nums = {5'd10, 5'd10, 5'd16, 5'd3};
                else if(freqR == `low_si) nums = {5'd10, 5'd10, 5'd17, 5'd3};
                else if(freqR == `silence) nums = {5'd10, 5'd10, 5'd10, 5'd10};
                else nums = {5'd10, 5'd10, 5'd10, 5'd10};
            end
            else if(!_mode)begin
                if(!_start) begin
                    nums[19:15] = 5'd10;
                    nums[14:10] = 5'd10;
                    if(key_R == `do) nums[9:0] = {5'd11, 5'd4};
                    else if(key_R == `re) nums[9:0] = {5'd12, 5'd4};
                    else if(key_R == `mi) nums[9:0] = {5'd13, 5'd4};
                    else if(key_R == `fa) nums[9:0] = {5'd14, 5'd4};
                    else if(key_R == `so) nums[9:0] = {5'd15, 5'd4};
                    else if(key_R == `la) nums[9:0] = {5'd16, 5'd4};
                    else if(key_R == `si) nums[9:0] = {5'd17, 5'd4};
                    else if(key_R == `high_do) nums[9:0] = {5'd11, 5'd5};
                    else if(key_R == `high_re) nums[9:0] = {5'd12, 5'd5};
                    else if(key_R == `high_mi) nums[9:0] = {5'd13, 5'd5};
                    else if(key_R == `high_fa) nums[9:0] = {5'd14, 5'd5};
                    else if(key_R == `high_so) nums[9:0] = {5'd15, 5'd5};
                    else if(key_R == `high_la) nums[9:0] = {5'd16, 5'd5};
                    else if(key_R == `high_si) nums[9:0] = {5'd17, 5'd5};
                    else if(key_R == `low_do) nums[9:0] = {5'd11, 5'd3};
                    else if(key_R == `low_re) nums[9:0] = {5'd12, 5'd3};
                    else if(key_R == `low_mi) nums[9:0] = {5'd13, 5'd3};
                    else if(key_R == `low_fa) nums[9:0] = {5'd14, 5'd3};
                    else if(key_R == `low_so) nums[9:0] = {5'd15, 5'd3};
                    else if(key_R == `low_la) nums[9:0] = {5'd16, 5'd3};
                    else if(key_R == `low_si) nums[9:0] = {5'd17, 5'd3};
                    else if(key_R == `silence) nums[9:0] = {5'd10, 5'd10};
                    else nums[9:0] = {5'd10, 5'd10};
                end else if(_start)begin
                    nums[19:15] = score_tens_digits;
                    nums[14:10] = score_units_digit;
                    if(freqR == `do) nums[9:0] = {5'd11, 5'd4};
                    else if(freqR == `re) nums[9:0] = {5'd12, 5'd4};
                    else if(freqR == `mi) nums[9:0] = {5'd13, 5'd4};
                    else if(freqR == `fa) nums[9:0] = {5'd14, 5'd4};
                    else if(freqR == `so) nums[9:0] = {5'd15, 5'd4};
                    else if(freqR == `la) nums[9:0] = {5'd16, 5'd4};
                    else if(freqR == `si) nums[9:0] = {5'd17, 5'd4};
                    else if(freqR == `high_do) nums[9:0] = {5'd11, 5'd5};
                    else if(freqR == `high_re) nums[9:0] = {5'd12, 5'd5};
                    else if(freqR == `high_mi) nums[9:0] = {5'd13, 5'd5};
                    else if(freqR == `high_fa) nums[9:0] = {5'd14, 5'd5};
                    else if(freqR == `high_so) nums[9:0] = {5'd15, 5'd5};
                    else if(freqR == `high_la) nums[9:0] = {5'd16, 5'd5};
                    else if(freqR == `high_si) nums[9:0] = {5'd17, 5'd5};
                    else if(freqR == `low_do) nums[9:0] = {5'd11, 5'd3};
                    else if(freqR == `low_re) nums[9:0] = {5'd12, 5'd3};
                    else if(freqR == `low_mi) nums[9:0] = {5'd13, 5'd3};
                    else if(freqR == `low_fa) nums[9:0] = {5'd14, 5'd3};
                    else if(freqR == `low_so) nums[9:0] = {5'd15, 5'd3};
                    else if(freqR == `low_la) nums[9:0] = {5'd16, 5'd3};
                    else if(freqR == `low_si) nums[9:0] = {5'd17, 5'd3};
                    else if(freqR == `silence) nums[9:0] = {5'd10, 5'd10};
                    else nums[9:0] = {5'd10, 5'd10};
                end
            end
        end
    end

    always @(posedge clk, posedge rst_onepulse) begin
        if(rst_onepulse) begin
            score_tens_digits <= 5'b0;
            score_units_digit <= 5'b0;
            is_scored <= 50'b0;
        end
        else begin
            if(!_mode && !_start) begin
                is_scored <= 50'b0;
                score_tens_digits <= 5'b0;
                score_units_digit <= 5'b0;
            end
            else if(!_mode && _start) begin
                if(key_R == `high_do) begin
                    if(nums[9:5] == 5'd11 && nums[4:0] == 5'd5 && !is_scored[order] && order != 50) begin
                        if(score_units_digit == 9 && score_tens_digits == 9) begin
                            score_tens_digits <= 9;
                            score_units_digit <= 9;
                            is_scored[order] <= 1'b1;
                        end
                        else if(score_units_digit == 9 && score_tens_digits != 9) begin
                            score_tens_digits <= score_tens_digits + 1;
                            score_units_digit <= 0;
                            is_scored[order] <= 1'b1;
                        end
                        else begin
                            score_units_digit <= score_units_digit + 1;
                            score_tens_digits <= score_tens_digits;
                            is_scored[order] <= 1'b1;
                        end
                    end
                    else begin
                        score_tens_digits <= score_tens_digits;
                        score_units_digit <= score_units_digit;
                        is_scored[order] <= is_scored[order];
                    end
                end
                else if(key_R == `high_re) begin
                    if(nums[9:5] == 5'd12 && nums[4:0] == 5'd5 && !is_scored[order] && order != 50) begin
                        if(score_units_digit == 9 && score_tens_digits == 9) begin
                            score_tens_digits <= 9;
                            score_units_digit <= 9;
                            is_scored[order] <= 1'b1;
                        end
                        else if(score_units_digit == 9 && score_tens_digits != 9) begin
                            score_tens_digits <= score_tens_digits + 1;
                            score_units_digit <= 0;
                            is_scored[order] <= 1'b1;
                        end
                        else begin
                            score_units_digit <= score_units_digit + 1;
                            score_tens_digits <= score_tens_digits;
                            is_scored[order] <= 1'b1;
                        end
                    end
                    else begin
                        score_tens_digits <= score_tens_digits;
                        score_units_digit <= score_units_digit;
                        is_scored[order] <= is_scored[order];
                    end
                end
                else if(key_R == `high_mi) begin
                    if(nums[9:5] == 5'd13 && nums[4:0] == 5'd5 && !is_scored[order] && order != 50) begin
                        if(score_units_digit == 9 && score_tens_digits == 9) begin
                            score_tens_digits <= 9;
                            score_units_digit <= 9;
                            is_scored[order] <= 1'b1;
                        end
                        else if(score_units_digit == 9 && score_tens_digits != 9) begin
                            score_tens_digits <= score_tens_digits + 1;
                            score_units_digit <= 0;
                            is_scored[order] <= 1'b1;
                        end
                        else begin
                            score_units_digit <= score_units_digit + 1;
                            score_tens_digits <= score_tens_digits;
                            is_scored[order] <= 1'b1;
                        end
                    end
                    else begin
                        score_tens_digits <= score_tens_digits;
                        score_units_digit <= score_units_digit;
                        is_scored[order] <= is_scored[order];
                    end
                end
                else if(key_R == `high_fa) begin
                    if(nums[9:5] == 5'd14 && nums[4:0] == 5'd5 && !is_scored[order] && order != 50) begin
                        if(score_units_digit == 9 && score_tens_digits == 9) begin
                            score_tens_digits <= 9;
                            score_units_digit <= 9;
                            is_scored[order] <= 1'b1;
                        end
                        else if(score_units_digit == 9 && score_tens_digits != 9) begin
                            score_tens_digits <= score_tens_digits + 1;
                            score_units_digit <= 0;
                            is_scored[order] <= 1'b1;
                        end
                        else begin
                            score_units_digit <= score_units_digit + 1;
                            score_tens_digits <= score_tens_digits;
                            is_scored[order] <= 1'b1;
                        end
                    end
                    else begin
                        score_tens_digits <= score_tens_digits;
                        score_units_digit <= score_units_digit;
                        is_scored[order] <= is_scored[order];
                    end
                end
                else if(key_R == `high_so) begin
                    if(nums[9:5] == 5'd15 && nums[4:0] == 5'd5 && !is_scored[order] && order != 50) begin
                        if(score_units_digit == 9 && score_tens_digits == 9) begin
                            score_tens_digits <= 9;
                            score_units_digit <= 9;
                            is_scored[order] <= 1'b1;
                        end
                        else if(score_units_digit == 9 && score_tens_digits != 9) begin
                            score_tens_digits <= score_tens_digits + 1;
                            score_units_digit <= 0;
                            is_scored[order] <= 1'b1;
                        end
                        else begin
                            score_units_digit <= score_units_digit + 1;
                            score_tens_digits <= score_tens_digits;
                            is_scored[order] <= 1'b1;
                        end
                    end
                    else begin
                        score_tens_digits <= score_tens_digits;
                        score_units_digit <= score_units_digit;
                        is_scored[order] <= is_scored[order];
                    end
                end
                else if(key_R == `high_la) begin
                    if(nums[9:5] == 5'd16 && nums[4:0] == 5'd5 && !is_scored[order] && order != 50) begin
                        if(score_units_digit == 9 && score_tens_digits == 9) begin
                            score_tens_digits <= 9;
                            score_units_digit <= 9;
                            is_scored[order] <= 1'b1;
                        end
                        else if(score_units_digit == 9 && score_tens_digits != 9) begin
                            score_tens_digits <= score_tens_digits + 1;
                            score_units_digit <= 0;
                            is_scored[order] <= 1'b1;
                        end
                        else begin
                            score_units_digit <= score_units_digit + 1;
                            score_tens_digits <= score_tens_digits;
                            is_scored[order] <= 1'b1;
                        end
                    end
                    else begin
                        score_tens_digits <= score_tens_digits;
                        score_units_digit <= score_units_digit;
                        is_scored[order] <= is_scored[order];
                    end
                end
                else if(key_R == `high_si) begin
                    if(nums[9:5] == 5'd17 && nums[4:0] == 5'd5 && !is_scored[order] && order != 50) begin
                        if(score_units_digit == 9 && score_tens_digits == 9) begin
                            score_tens_digits <= 5'd9;
                            score_units_digit <= 5'd9;
                            is_scored[order] <= 1'b1;
                        end
                        else if(score_units_digit == 9 && score_tens_digits != 9) begin
                            score_tens_digits <= score_tens_digits + 1;
                            score_units_digit <= 0;
                            is_scored[order] <= 1'b1;
                        end
                        else begin
                            score_units_digit <= score_units_digit + 1;
                            score_tens_digits <= score_tens_digits;
                            is_scored[order] <= 1'b1;
                        end
                    end
                    else begin
                        score_tens_digits <= score_tens_digits;
                        score_units_digit <= score_units_digit;
                        is_scored[order] <= is_scored[order];
                    end
                end
            end
            else begin
                score_tens_digits <= 5'b0;
                score_units_digit <= 5'b0;
                is_scored[order] <= is_scored[order];
            end
        end
    end

    always @ (posedge seven_segment_clk) begin
    	case (DIGIT)
    		4'b1110 : begin
    			    display_num <= nums[9:5];
    				DIGIT <= 4'b1101;
    			end
    		4'b1101 : begin
					display_num <= nums[14:10];
					DIGIT <= 4'b1011;
				end
    		4'b1011 : begin
					display_num <= nums[19:15];
					DIGIT <= 4'b0111;
				end
    		4'b0111 : begin
					display_num <= nums[4:0];
					DIGIT <= 4'b1110;
				end
    		default : begin
					display_num <= nums[4:0];
					DIGIT <= 4'b1110;
				end				
    	endcase
    end

    always @* begin
        case(display_num)
        	0 : DISPLAY = 7'b1000000;
			1 : DISPLAY = 7'b1111001;                                                  
			2 : DISPLAY = 7'b0100100;                                                   
			3 : DISPLAY = 7'b0110000;                                            
			4 : DISPLAY = 7'b0011001;                                                
			5 : DISPLAY = 7'b0010010;                                                 
			6 : DISPLAY = 7'b0000010;   
			7 : DISPLAY = 7'b1111000;   
			8 : DISPLAY = 7'b0000000;   
			9 : DISPLAY = 7'b0010000;	
            minus: DISPLAY = 7'b0111111;
            C: DISPLAY = 7'b1000110;
            D: DISPLAY = 7'b0100001;
            E: DISPLAY = 7'b0000110;
            F: DISPLAY = 7'b0001110;
            G: DISPLAY = 7'b0010000;
            A: DISPLAY = 7'b0001000;
            B: DISPLAY = 7'b0000011;
            empty: DISPLAY = 7'b1111111;
            default: DISPLAY = 7'b1111111;
        endcase
    end

endmodule