module lab6_2(
    input clk,
    input rst,
    inout wire PS2_DATA,
    inout wire PS2_CLK,
    input hint,
    output [3:0] vgaRed,
    output [3:0] vgaGreen,
    output [3:0] vgaBlue,
    output hsync,
    output vsync,
    output reg pass
    );
    
    parameter [8:0] one_code = 9'b0_0001_0110;
    parameter [8:0] two_code = 9'b0_0001_1110;
    parameter [8:0] three_code = 9'b0_0010_0110;
    parameter [8:0] four_code = 9'b0_0010_0101;
    parameter [8:0] Q_code = 9'b0_0001_0101;
    parameter [8:0] W_code = 9'b0_0001_1101;
    parameter [8:0] E_code = 9'b0_0010_0100;
    parameter [8:0] R_code = 9'b0_0010_1101;
    parameter [8:0] A_code = 9'b0_0001_1100;
    parameter [8:0] S_code = 9'b0_0001_1011;
    parameter [8:0] D_code = 9'b0_0010_0011;
    parameter [8:0] F_code = 9'b0_0010_1011;
    parameter [8:0] Z_code = 9'b0_0001_1010;
    parameter [8:0] X_code = 9'b0_0010_0010;
    parameter [8:0] C_code = 9'b0_0010_0001;
    parameter [8:0] V_code = 9'b0_0010_1010;
    parameter [8:0] shift_code = 9'b0_0001_0010;
    parameter HD = 640;
    parameter HF = 16;
    parameter HS = 96;
    parameter HB = 48;
    parameter HT = 800; 
    parameter VD = 480;
    parameter VF = 10;
    parameter VS = 2;
    parameter VB = 33;
    parameter VT = 525;
    parameter hsync_default = 1'b1;
    parameter vsync_default = 1'b1;

    wire been_ready;
    wire [4:0] move;
    wire [17:0] key_down;
    wire [8:0] last_change;
    wire [17:0] key_decode = 1 << move;
    assign move = (last_change == one_code ? 0 : (last_change == two_code ? 1 : (last_change == three_code ? 2 : (last_change == four_code ? 3 : (last_change == Q_code ? 4 : (last_change == W_code ? 5 : (last_change == E_code ? 6 : (last_change == R_code ? 7 : (last_change == A_code ? 8 : (last_change == S_code ? 9 : (last_change == D_code ? 10 : (last_change == F_code ? 11 : (last_change == Z_code ? 12 : (last_change == X_code ? 13 : (last_change == C_code ? 14 : (last_change == V_code ? 15 : (last_change == shift_code ? 16 : 17)))))))))))))))));
    wire rst_onepulse, valid;
    wire clk_25MHz;
    wire [9:0] h_cnt; //640
    wire [9:0] v_cnt;  //480
    wire [11:0] pixel;
    wire [11:0] data;
    wire [4:0] order, trans;
    wire is_pass;

    assign order = (((h_cnt >> 1) >= 0 && (h_cnt >> 1) <= 79 && (v_cnt >> 1) >= 0 && (v_cnt >> 1) <= 59) ? 1 :
    (((h_cnt >> 1) >= 80 && (h_cnt >> 1) <= 159 && (v_cnt >> 1) >= 0 && (v_cnt >> 1) <= 59) ? 2 :
    ((((h_cnt >> 1) >= 160 && (h_cnt >> 1) <= 239 && (v_cnt >> 1) >= 0 && (v_cnt >> 1) <= 59) ? 3 :
    ((((h_cnt >> 1) >= 240 && (h_cnt >> 1) <= 319 && (v_cnt >> 1) >= 0 && (v_cnt >> 1) <= 59) ? 4 : 
    ((((h_cnt >> 1) >= 0 && (h_cnt >> 1) <= 79 && (v_cnt >> 1) >= 60 && (v_cnt >> 1) <= 119)) ? 5 :
    ((((h_cnt >> 1) >= 80 && (h_cnt >> 1) <= 159 && (v_cnt >> 1) >= 60 && (v_cnt >> 1) <= 119) ? 6 :
    ((((h_cnt >> 1) >= 160 && (h_cnt >> 1) <= 239 && (v_cnt >> 1) >= 60 && (v_cnt >> 1) <= 119)) ? 7 :
    ((((h_cnt >> 1) >= 240 && (h_cnt >> 1) <= 319 && (v_cnt >> 1) >= 60 && (v_cnt >> 1) <= 119)) ? 8 :
    ((((h_cnt >> 1) >= 0 && (h_cnt >> 1) <= 79 && (v_cnt >> 1) >= 120 && (v_cnt >> 1) <= 179)) ? 9 :
    ((((h_cnt >> 1) >= 80 && (h_cnt >> 1) <= 159 && (v_cnt >> 1) >= 120 && (v_cnt >> 1) <= 179)) ? 10 :
    ((((h_cnt >> 1) >= 160 && (h_cnt >> 1) <= 239 && (v_cnt >> 1) >= 120 && (v_cnt >> 1) <= 179)) ? 11 :
    ((((h_cnt >> 1) >= 240 && (h_cnt >> 1) <= 319 && (v_cnt >> 1) >= 120 && (v_cnt >> 1) <= 179)) ? 12 :
    ((((h_cnt >> 1) >= 0 && (h_cnt >> 1) <= 79 && (v_cnt >> 1) >= 180 && (v_cnt >> 1) <= 239)) ? 13 :
    ((((h_cnt >> 1) >= 80 && (h_cnt >> 1) <= 159 && (v_cnt >> 1) >= 180 && (v_cnt >> 1) <= 239)) ? 14 :
    ((((h_cnt >> 1) >= 160 && (h_cnt >> 1) <= 239 && (v_cnt >> 1) >= 180 && (v_cnt >> 1) <= 239)) ? 15 :
    ((((h_cnt >> 1) >= 240 && (h_cnt >> 1) <= 319 && (v_cnt >> 1) >= 180 && (v_cnt >> 1) <= 239)) ? 16 : 17)))))))))))))))))));

    assign trans = ((key_down == 18'b01_0000_0000_0000_0001) ? 1 :
    ((key_down == 18'b01_0000_0000_0000_0010) ? 2 : 
    ((key_down == 18'b01_0000_0000_0000_0100) ? 3 :
    ((key_down == 18'b01_0000_0000_0000_1000) ? 4 :
    ((key_down == 18'b01_0000_0000_0001_0000) ? 5 :
    ((key_down == 18'b01_0000_0000_0010_0000) ? 6 :
    ((key_down == 18'b01_0000_0000_0100_0000) ? 7 :
    ((key_down == 18'b01_0000_0000_1000_0000) ? 8 :
    ((key_down == 18'b01_0000_0001_0000_0000) ? 9 :
    ((key_down == 18'b01_0000_0010_0000_0000) ? 10 :
    ((key_down == 18'b01_0000_0100_0000_0000) ? 11 :
    ((key_down == 18'b01_0000_1000_0000_0000) ? 12 :
    ((key_down == 18'b01_0001_0000_0000_0000) ? 13 :
    ((key_down == 18'b01_0010_0000_0000_0000) ? 14 :
    ((key_down == 18'b01_0100_0000_0000_0000) ? 15 :
    ((key_down == 18'b01_1000_0000_0000_0000) ? 16 : 17))))))))))))))));

    clock_divider #(2) div2(.clk(clk), .clk_div(clk_25MHz));
    one_pulse o1(.clk(clk), .pb_in(rst), .pb_out(rst_onepulse));

    reg [16:0] pixel_addr;
    reg [9:0] pixel_cnt;
    reg [9:0] line_cnt;
    reg hsync_i,vsync_i;
    reg ok = 1'b0, en = 1'b1;
    reg [4:0] key_1 = 5'd17, key_2 = 5'd17;
    reg [4:0] change [0:16] = {
        5'd0, 5'd3, 5'd16, 5'd1, 5'd10, 5'd12, 5'd6, 5'd8, 5'd14,
        5'd15, 5'd4, 5'd13, 5'd5, 5'd11, 5'd7, 5'd9, 5'd2
    };
    reg [8:0] v [0:16] = {
        9'd0, 9'd0, 9'd0, 9'd0, 9'd0, 9'd60, 9'd119, 9'd60, 9'd60,
        9'd120, 9'd179, 9'd120, 9'd120, 9'd180, 9'd239, 9'd180, 9'd180
    };
    reg [8:0] h [0:16] = {
        9'd0, 9'd0, 9'd80, 9'd160, 9'd240, 9'd0, 9'd80, 9'd160, 9'd240,
        9'd0, 9'd80, 9'd160, 9'd240, 9'd0, 9'd80, 9'd160, 9'd240
    };
    reg [8:0] oh[0:16] = {
        9'd0, 9'd0, 9'd80, 9'd160, 9'd240, 9'd0, 9'd80, 9'd160, 9'd240, 9'd0, 9'd80, 9'd160, 9'd240, 9'd0, 9'd80, 9'd160, 9'd240
    };
    reg [8:0] ov[0:16] = {
        9'd0, 9'd0, 9'd0, 9'd0, 9'd0, 9'd60, 9'd60, 9'd60, 9'd60, 9'd120, 9'd120, 9'd120, 9'd120, 9'd180, 9'd180, 9'd180, 9'd180
    };
    reg [1:0] rotate[0:16] = {
        2'd0, 2'd0, 2'd0, 2'd0, 2'd0, 2'd0, 2'd1, 2'd0, 2'd0, 2'd0, 2'd1, 2'd0, 2'd0, 2'd0, 2'd1, 2'd0, 2'd0
    };

    assign is_pass = ((change[1] == 1 && change[2] == 2 && change[3] == 3 && change[4] == 4 && change[5] == 5
    && change[6] == 6 && change[7] == 7 && change[8] == 8 && change[9] ==9 && change[10] == 10 && change[11] == 11
    && change[12] == 12 && change[13] == 13 && change[14] == 14 && change[15] == 15 && change[16] == 16
    && rotate[1] == 0 && rotate[2] == 0 && rotate[3] == 0 && rotate[4] == 0 && rotate[5] == 0 && rotate[6] == 0
    && rotate[7] == 0 && rotate[8] == 0 && rotate[9] == 0 && rotate[10] == 0 && rotate[11] == 0 && rotate[12] == 0
    && rotate[13] == 0 && rotate[14] == 0 && rotate[15] == 0 && rotate[16] == 0) ? 1 : 0);
    assign {vgaRed, vgaGreen, vgaBlue} = (valid==1'b1) ? pixel:12'h0;

    blk_mem_gen_0 blk_mem_gen_0_inst(
        .clka(clk_25MHz),
        .wea(0),
        .addra(pixel_addr),
        .dina(data[11:0]),
        .douta(pixel)
    ); 

    KeyboardDecoder k(
		.key_down(key_down),
		.last_change(last_change),
		.key_valid(been_ready),
		.PS2_DATA(PS2_DATA),
		.PS2_CLK(PS2_CLK),
		.rst(rst),
		.clk(clk)
	);
    
    // vga controller start
    always @(posedge clk_25MHz, posedge rst_onepulse) begin
        if (rst_onepulse)
            pixel_cnt <= 0;
        else begin
            if (pixel_cnt < (HT - 1))
                pixel_cnt <= pixel_cnt + 1;
            else
                pixel_cnt <= 0;
        end
    end

    always @(posedge clk_25MHz, posedge rst_onepulse) begin
        if (rst_onepulse)
            hsync_i <= hsync_default;
        else begin
            if ((pixel_cnt >= (HD + HF - 1)) && (pixel_cnt < (HD + HF + HS - 1)))
                hsync_i <= ~hsync_default;
            else
                hsync_i <= hsync_default; 
        end
    end

    always @(posedge clk_25MHz, posedge rst_onepulse) begin
        if (rst_onepulse)
            line_cnt <= 0;
        else begin
            if (pixel_cnt == (HT -1)) begin
                if (line_cnt < (VT - 1))
                    line_cnt <= line_cnt + 1;
                else
                    line_cnt <= 0;
            end
        end
    end

    always @(posedge clk_25MHz, posedge rst_onepulse) begin
        if (rst_onepulse)
            vsync_i <= vsync_default; 
        else if ((line_cnt >= (VD + VF - 1)) && (line_cnt < (VD + VF + VS - 1)))
            vsync_i <= ~vsync_default; 
        else
            vsync_i <= vsync_default; 
    end

    assign hsync = hsync_i;
    assign vsync = vsync_i;
    assign valid = ((pixel_cnt < HD) && (line_cnt < VD));

    assign h_cnt = (pixel_cnt < HD) ? pixel_cnt : 10'd0;
    assign v_cnt = (line_cnt < VD) ? line_cnt : 10'd0;
    // vga controller end

    always @(posedge clk, posedge rst_onepulse) begin
        if(rst_onepulse) begin
            if((h_cnt >> 1) <= 159 && (h_cnt >> 1) >= 80 && ((v_cnt >> 1) <= 119) && ((v_cnt >> 1) >= 60))
                pixel_addr <= ((h_cnt >> 1)) + 320 * (179 - (v_cnt >> 1));
            else if((h_cnt >> 1) <= 159 && (h_cnt >> 1) >= 80 && ((v_cnt >> 1) <= 59) && ((v_cnt >> 1) >= 0))
                pixel_addr <= ((h_cnt >> 1) + 160) + 320 * ((v_cnt >> 1) + 180);
            else if((h_cnt >> 1) <= 319 && (h_cnt >> 1) >= 240 && ((v_cnt >> 1) <= 239) && ((v_cnt >> 1) >= 180))
                pixel_addr <= ((h_cnt >> 1) - 160) + 320 * ((v_cnt >> 1) - 180);
            else if((h_cnt >> 1) <= 159 && (h_cnt >> 1) >= 80 && ((v_cnt >> 1) <= 179) && ((v_cnt >> 1) >= 120))
                pixel_addr <= ((h_cnt >> 1) + 160) + 320 * ((v_cnt >> 1) - 120);
            else if((h_cnt >> 1) <= 319 && (h_cnt >> 1) >= 240 && ((v_cnt >> 1) <= 59) && ((v_cnt >> 1) >= 0))
                pixel_addr <= ((h_cnt >> 1) - 160) + 320 * (179 - (v_cnt >> 1));
            else if((h_cnt >> 1) <= 319 && (h_cnt >> 1) >= 240 && ((v_cnt >> 1) <= 179) && ((v_cnt >> 1) >= 120))
                pixel_addr <= ((h_cnt >> 1) - 240) + 320 * ((v_cnt >> 1) - 60);
            else if((h_cnt >> 1) <= 79 && (h_cnt >> 1) >= 0 && ((v_cnt >> 1) <= 119) && ((v_cnt >> 1) >= 60))
                pixel_addr <= ((h_cnt >> 1) + 240) + 320 * ((v_cnt >> 1) + 60);
            else if((h_cnt >> 1) <= 239 && (h_cnt >> 1) >= 160 && ((v_cnt >> 1) <= 119) && ((v_cnt >> 1) >= 60))
                pixel_addr <= ((h_cnt >> 1) + 80) + 320 * ((v_cnt >> 1));
            else if((h_cnt >> 1) <= 159 && (h_cnt >> 1) >= 80 && ((v_cnt >> 1) <= 239) && ((v_cnt >> 1) >= 180))
                pixel_addr <= ((h_cnt >> 1) + 80) + 320 * ((v_cnt >> 1) - 120);
            else if((h_cnt >> 1) <= 319 && (h_cnt >> 1) >= 240 && ((v_cnt >> 1) <= 119) && ((v_cnt >> 1) >= 60))
                pixel_addr <= ((h_cnt >> 1) - 160) + 320 * (299 - (v_cnt >> 1));
            else if((h_cnt >> 1) <= 79 && (h_cnt >> 1) >= 0 && ((v_cnt >> 1) <= 179) && ((v_cnt >> 1) >= 120)) begin
                pixel_addr <= ((h_cnt >> 1) + 160) + 320 * ((v_cnt >> 1) + 60);
            end
            else if((h_cnt >> 1) <= 239 && (h_cnt >> 1) >= 160 && ((v_cnt >> 1) <= 239) && ((v_cnt >> 1) >= 180)) begin
                pixel_addr <= ((h_cnt >> 1) - 160) + 320 * ((v_cnt >> 1) - 60);
            end
            else if((h_cnt >> 1) <= 239 && (h_cnt >> 1) >= 160 && ((v_cnt >> 1) <= 179) && ((v_cnt >> 1) >= 120)) begin
                pixel_addr <= ((h_cnt >> 1) - 160) + 320 * ((v_cnt >> 1) + 60);
            end
            else if((h_cnt >> 1) <= 79 && (h_cnt >> 1) >= 0 && ((v_cnt >> 1) <= 239) && ((v_cnt >> 1) >= 180)) begin
                pixel_addr <= ((h_cnt >> 1) + 160) + 320 * ((v_cnt >> 1) - 60);
            end
            else if((h_cnt >> 1) <= 239 && (h_cnt >> 1) >= 160 && ((v_cnt >> 1) <= 59) && ((v_cnt >> 1) >= 0)) begin
                pixel_addr <= ((h_cnt >> 1) - 160) + 320 * ((v_cnt >> 1));
            end
            else if((h_cnt >> 1) <= 79 && (h_cnt >> 1) >= 0 && ((v_cnt >> 1) <= 59) && ((v_cnt >> 1) >= 0)) begin
                pixel_addr <= ((h_cnt >> 1) + 160) + 320 * ((v_cnt >> 1));
            end
            else pixel_addr <= (h_cnt >> 1) + 320 * (v_cnt >> 1);
        end else begin
            if(hint) begin
                pixel_addr <= (h_cnt >> 1) + 320 * (v_cnt >> 1);
            end else begin
                if(!rotate[change[order]])
                    pixel_addr <= ((h_cnt >> 1) + h[change[order]] - oh[order]) + 320 * ((v_cnt >> 1) + v[change[order]] - ov[order]);
                else
                    pixel_addr <= ((h_cnt >> 1) + h[change[order]] - oh[order]) + 320 * (ov[order] + v[change[order]] - (v_cnt >> 1));
            end
        end
    end

    always @(posedge clk, posedge rst_onepulse) begin
        if(rst_onepulse) begin
            pass <= 1'b0;
            change[0] <= 5'd0;
            change[1] <= 5'd3;
            change[2] <= 5'd16;
            change[3] <= 5'd1;
            change[4] <= 5'd10;
            change[5] <= 5'd12;
            change[6] <= 5'd6;
            change[7] <= 5'd8;
            change[8] <= 5'd14;
            change[9] <= 5'd15;
            change[10] <= 5'd4;
            change[11] <= 5'd13;
            change[12] <= 5'd5;
            change[13] <= 5'd11;
            change[14] <= 5'd7;
            change[15] <= 5'd9;
            change[16] <= 5'd2;
            rotate[0] <= 2'd0;
            rotate[1] <= 2'd0;
            rotate[2] <= 2'd0;
            rotate[3] <= 2'd0;
            rotate[4] <= 2'd0;
            rotate[5] <= 2'd0;
            rotate[6] <= 2'd1;
            rotate[7] <= 2'd0;
            rotate[8] <= 2'd0;
            rotate[9] <= 2'd0;
            rotate[10] <= 2'd1;
            rotate[11] <= 2'd0;
            rotate[12] <= 2'd0;
            rotate[13] <= 2'd0;
            rotate[14] <= 2'd1;
            rotate[15] <= 2'd0;
            rotate[16] <= 2'd0;
            h[0] <= 9'd0;
            h[1] <= 9'd0;
            h[2] <= 9'd80;
            h[3] <= 9'd160;
            h[4] <= 9'd240;
            h[5] <= 9'd0;
            h[6] <= 9'd80;
            h[7] <= 9'd160;
            h[8] <= 9'd240;
            h[9] <= 9'd0;
            h[10] <= 9'd80;
            h[11] <= 9'd160;
            h[12] <= 9'd240;
            h[13] <= 9'd0;
            h[14] <= 9'd80;
            h[15] <= 9'd160;
            h[16] <= 9'd240;
            v[0] <= 9'd0;
            v[1] <= 9'd0;
            v[2] <= 9'd0;
            v[3] <= 9'd0;
            v[4] <= 9'd0;
            v[5] <= 9'd60;
            v[6] <= 9'd119;
            v[7] <= 9'd60;
            v[8] <= 9'd60;
            v[9] <= 9'd120;
            v[10] <= 9'd179;
            v[11] <= 9'd120;
            v[12] <= 9'd120;
            v[13] <= 9'd180;
            v[14] <= 9'd239;
            v[15] <= 9'd180;
            v[16] <= 9'd180;
            en <= 1'b1;
            pass <= 1'b0;
        end else begin
            if(key_down == 0) en <= 1;
            else begin
                if(is_pass) begin
                    pass <= 1'b1;
                end else begin
                    if(been_ready && key_down[move] == 1 && !hint && en) begin
                        if(key_down == 18'b00_0000_0000_0000_0011) begin
                            change[1] <= change[2];
                            change[2] <= change[1];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_0000_0000_0000_0101) begin
                            change[1] <= change[3];
                            change[3] <= change[1];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_0000_0000_0000_1001) begin
                            change[1] <= change[4];
                            change[4] <= change[1];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_0000_0000_0001_0001) begin
                            change[1] <= change[5];
                            change[5] <= change[1];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_0000_0000_0010_0001) begin
                            change[1] <= change[6];
                            change[6] <= change[1];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_0000_0000_0100_0001) begin
                            change[1] <= change[7];
                            change[7] <= change[1];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_0000_0000_1000_0001) begin
                            change[1] <= change[8];
                            change[8] <= change[1];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_0000_0001_0000_0001) begin
                            change[1] <= change[9];
                            change[9] <= change[1];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_0000_0010_0000_0001) begin
                            change[1] <= change[10];
                            change[10] <= change[1];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_0000_0100_0000_0001) begin
                            change[1] <= change[11];
                            change[11] <= change[1];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_0000_1000_0000_0001) begin
                            change[1] <= change[12];
                            change[12] <= change[1];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_0001_0000_0000_0001) begin
                            change[1] <= change[13];
                            change[13] <= change[1];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_0010_0000_0000_0001) begin
                            change[1] <= change[14];
                            change[14] <= change[1];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_0100_0000_0000_0001) begin
                            change[1] <= change[15];
                            change[15] <= change[1];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_1000_0000_0000_0001) begin
                            change[1] <= change[16];
                            change[16] <= change[1];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_1000_0000_0000_0001) begin
                            change[1] <= change[16];
                            change[16] <= change[1];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_0000_0000_0000_0110) begin
                            change[2] <= change[3];
                            change[3] <= change[2];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_0000_0000_0000_1010) begin
                            change[2] <= change[4];
                            change[4] <= change[2];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_0000_0000_0001_0010) begin
                            change[2] <= change[5];
                            change[5] <= change[2];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_0000_0000_0010_0010) begin
                            change[2] <= change[6];
                            change[6] <= change[2];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_0000_0000_0100_0010) begin
                            change[2] <= change[7];
                            change[7] <= change[2];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_0000_0000_1000_0010) begin
                            change[2] <= change[8];
                            change[8] <= change[2];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_0000_0001_0000_0010) begin
                            change[2] <= change[9];
                            change[9] <= change[2];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_0000_0010_0000_0010) begin
                            change[2] <= change[10];
                            change[10] <= change[2];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_0000_0100_0000_0010) begin
                            change[2] <= change[11];
                            change[11] <= change[2];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_0000_1000_0000_0010) begin
                            change[2] <= change[12];
                            change[12] <= change[2];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_0001_0000_0000_0010) begin
                            change[2] <= change[13];
                            change[13] <= change[2];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_0010_0000_0000_0010) begin
                            change[2] <= change[14];
                            change[14] <= change[2];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_0100_0000_0000_0010) begin
                            change[2] <= change[15];
                            change[15] <= change[2];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_1000_0000_0000_0010) begin
                            change[2] <= change[16];
                            change[16] <= change[2];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_0000_0000_0000_1100) begin
                            change[3] <= change[4];
                            change[4] <= change[3];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_0000_0000_0001_0100) begin
                            change[3] <= change[5];
                            change[5] <= change[3];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_0000_0000_0010_0100) begin
                            change[3] <= change[6];
                            change[6] <= change[3];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_0000_0000_0100_0100) begin
                            change[3] <= change[7];
                            change[7] <= change[3];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_0000_0000_1000_0100) begin
                            change[3] <= change[8];
                            change[8] <= change[3];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_0000_0001_0000_0100) begin
                            change[3] <= change[9];
                            change[9] <= change[3];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_0000_0010_0000_0100) begin
                            change[3] <= change[10];
                            change[10] <= change[3];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_0000_0100_0000_0100) begin
                            change[3] <= change[11];
                            change[11] <= change[3];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_0000_1000_0000_0100) begin
                            change[3] <= change[12];
                            change[12] <= change[3];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_0001_0000_0000_0100) begin
                            change[3] <= change[13];
                            change[13] <= change[3];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_0010_0000_0000_0100) begin
                            change[3] <= change[14];
                            change[14] <= change[3];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_0100_0000_0000_0100) begin
                            change[3] <= change[15];
                            change[15] <= change[3];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_1000_0000_0000_0100) begin
                            change[3] <= change[16];
                            change[16] <= change[3];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_0000_0000_0001_1000) begin
                            change[4] <= change[5];
                            change[5] <= change[4];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_0000_0000_0010_1000) begin
                            change[4] <= change[6];
                            change[6] <= change[4];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_0000_0000_0100_1000) begin
                            change[4] <= change[7];
                            change[7] <= change[4];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_0000_0000_1000_1000) begin
                            change[4] <= change[8];
                            change[8] <= change[4];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_0000_0001_0000_1000) begin
                            change[4] <= change[9];
                            change[9] <= change[4];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_0000_0010_0000_1000) begin
                            change[4] <= change[10];
                            change[10] <= change[4];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_0000_0100_0000_1000) begin
                            change[4] <= change[11];
                            change[11] <= change[4];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_0000_1000_0000_1000) begin
                            change[4] <= change[12];
                            change[12] <= change[4];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_0001_0000_0000_1000) begin
                            change[4] <= change[13];
                            change[13] <= change[4];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_0010_0000_0000_1000) begin
                            change[4] <= change[14];
                            change[14] <= change[4];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_0100_0000_0000_1000) begin
                            change[4] <= change[15];
                            change[15] <= change[4];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_1000_0000_0000_1000) begin
                            change[4] <= change[16];
                            change[16] <= change[4];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_0000_0000_0011_0000) begin
                            change[5] <= change[6];
                            change[6] <= change[5];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_0000_0000_0101_0000) begin
                            change[5] <= change[7];
                            change[7] <= change[5];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_0000_0000_1001_0000) begin
                            change[5] <= change[8];
                            change[8] <= change[5];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_0000_0001_0001_0000) begin
                            change[5] <= change[9];
                            change[9] <= change[5];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_0000_0010_0001_0000) begin
                            change[5] <= change[10];
                            change[10] <= change[5];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_0000_0100_0001_0000) begin
                            change[5] <= change[11];
                            change[11] <= change[5];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_0000_1000_0001_0000) begin
                            change[5] <= change[12];
                            change[12] <= change[5];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_0001_0000_0001_0000) begin
                            change[5] <= change[13];
                            change[13] <= change[5];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_0010_0000_0001_0000) begin
                            change[5] <= change[14];
                            change[14] <= change[5];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_0100_0000_0001_0000) begin
                            change[5] <= change[15];
                            change[15] <= change[5];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_1000_0000_0001_0000) begin
                            change[5] <= change[16];
                            change[16] <= change[5];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_0000_0000_0110_0000) begin
                            change[6] <= change[7];
                            change[7] <= change[6];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_0000_0000_1010_0000) begin
                            change[6] <= change[8];
                            change[8] <= change[6];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_0000_0001_0010_0000) begin
                            change[6] <= change[9];
                            change[9] <= change[6];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_0000_0010_0010_0000) begin
                            change[6] <= change[10];
                            change[10] <= change[6];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_0000_0100_0010_0000) begin
                            change[6] <= change[11];
                            change[11] <= change[6];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_0000_1000_0010_0000) begin
                            change[6] <= change[12];
                            change[12] <= change[6];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_0001_0000_0010_0000) begin
                            change[6] <= change[13];
                            change[13] <= change[6];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_0010_0000_0010_0000) begin
                            change[6] <= change[14];
                            change[14] <= change[6];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_0100_0000_0010_0000) begin
                            change[6] <= change[15];
                            change[15] <= change[6];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_1000_0000_0010_0000) begin
                            change[6] <= change[16];
                            change[16] <= change[6];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_0000_0000_1100_0000) begin
                            change[7] <= change[8];
                            change[8] <= change[7];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_0000_0001_0100_0000) begin
                            change[7] <= change[9];
                            change[9] <= change[7];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_0000_0010_0100_0000) begin
                            change[7] <= change[10];
                            change[10] <= change[7];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_0000_0100_0100_0000) begin
                            change[7] <= change[11];
                            change[11] <= change[7];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_0000_1000_0100_0000) begin
                            change[7] <= change[12];
                            change[12] <= change[7];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_0001_0000_0100_0000) begin
                            change[7] <= change[13];
                            change[13] <= change[7];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_0010_0000_0100_0000) begin
                            change[7] <= change[14];
                            change[14] <= change[7];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_0100_0000_0100_0000) begin
                            change[7] <= change[15];
                            change[15] <= change[7];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_1000_0000_0100_0000) begin
                            change[7] <= change[16];
                            change[16] <= change[7];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_0000_0001_1000_0000) begin
                            change[8] <= change[9];
                            change[9] <= change[8];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_0000_0010_1000_0000) begin
                            change[8] <= change[10];
                            change[10] <= change[8];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_0000_0100_1000_0000) begin
                            change[8] <= change[11];
                            change[11] <= change[8];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_0000_1000_1000_0000) begin
                            change[8] <= change[12];
                            change[12] <= change[8];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_0001_0000_1000_0000) begin
                            change[8] <= change[13];
                            change[13] <= change[8];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_0010_0000_1000_0000) begin
                            change[8] <= change[14];
                            change[14] <= change[8];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_0100_0000_1000_0000) begin
                            change[8] <= change[15];
                            change[15] <= change[8];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_1000_0000_1000_0000) begin
                            change[8] <= change[16];
                            change[16] <= change[8];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_0000_0011_0000_0000) begin
                            change[9] <= change[10];
                            change[10] <= change[9];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_0000_0101_0000_0000) begin
                            change[9] <= change[11];
                            change[11] <= change[9];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_0000_1001_0000_0000) begin
                            change[9] <= change[12];
                            change[12] <= change[9];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_0001_0001_0000_0000) begin
                            change[9] <= change[13];
                            change[13] <= change[9];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_0010_0001_0000_0000) begin
                            change[9] <= change[14];
                            change[14] <= change[9];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_0100_0001_0000_0000) begin
                            change[9] <= change[15];
                            change[15] <= change[9];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_1000_0001_0000_0000) begin
                            change[9] <= change[16];
                            change[16] <= change[9];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_0000_0110_0000_0000) begin
                            change[10] <= change[11];
                            change[11] <= change[10];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_0000_1010_0000_0000) begin
                            change[10] <= change[12];
                            change[12] <= change[10];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_0001_0010_0000_0000) begin
                            change[10] <= change[13];
                            change[13] <= change[10];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_0010_0010_0000_0000) begin
                            change[10] <= change[14];
                            change[14] <= change[10];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_0100_0010_0000_0000) begin
                            change[10] <= change[15];
                            change[15] <= change[10];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_1000_0010_0000_0000) begin
                            change[10] <= change[16];
                            change[16] <= change[10];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_0000_1100_0000_0000) begin
                            change[11] <= change[12];
                            change[12] <= change[11];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_0001_0100_0000_0000) begin
                            change[11] <= change[13];
                            change[13] <= change[11];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_0010_0100_0000_0000) begin
                            change[11] <= change[14];
                            change[14] <= change[11];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_0100_0100_0000_0000) begin
                            change[11] <= change[15];
                            change[15] <= change[11];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_1000_0100_0000_0000) begin
                            change[11] <= change[16];
                            change[16] <= change[11];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_0001_1000_0000_0000) begin
                            change[12] <= change[13];
                            change[13] <= change[12];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_0010_1000_0000_0000) begin
                            change[12] <= change[14];
                            change[14] <= change[12];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_0100_1000_0000_0000) begin
                            change[12] <= change[15];
                            change[15] <= change[12];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_1000_1000_0000_0000) begin
                            change[12] <= change[16];
                            change[16] <= change[12];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_0011_0000_0000_0000) begin
                            change[13] <= change[14];
                            change[14] <= change[13];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_0101_0000_0000_0000) begin
                            change[13] <= change[15];
                            change[15] <= change[13];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_1001_0000_0000_0000) begin
                            change[13] <= change[16];
                            change[16] <= change[13];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_0110_0000_0000_0000) begin
                            change[14] <= change[15];
                            change[15] <= change[14];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_1010_0000_0000_0000) begin
                            change[14] <= change[16];
                            change[16] <= change[14];
                            en <= 1'b0; 
                        end
                        else if(key_down == 18'b00_1100_0000_0000_0000) begin
                            change[15] <= change[16];
                            change[16] <= change[15];
                            en <= 1'b0; 
                        end
                        else if(key_down[16] == 1 && key_down != 18'b01_0000_0000_0000_0000 && trans != 17) begin
                                if(rotate[change[trans]]) begin
                                    rotate[change[trans]] <= 0;
                                    v[change[trans]] <= v[change[trans]] - 59;
                                    en <= 1'b0;
                                end
                                else begin
                                    rotate[change[trans]] <= 1;
                                    v[change[trans]] <= v[change[trans]] + 59;
                                    en <= 1'b0;
                                end
                        end
                        else begin
                            change[0] <= change[0];
                            change[1] <= change[1];
                            change[2] <= change[2];
                            change[3] <= change[3];
                            change[4] <= change[4];
                            change[5] <= change[5];
                            change[6] <= change[6];
                            change[7] <= change[7];
                            change[8] <= change[8];
                            change[9] <= change[9];
                            change[10] <= change[10];
                            change[11] <= change[11];
                            change[12] <= change[12];
                            change[13] <= change[13];
                            change[14] <= change[14];
                            change[15] <= change[15];
                            change[16] <= change[16];
                            rotate[0] <= rotate[0];
                            rotate[1] <= rotate[1];
                            rotate[2] <= rotate[2];
                            rotate[3] <= rotate[3];
                            rotate[4] <= rotate[4];
                            rotate[5] <= rotate[5];
                            rotate[6] <= rotate[6];
                            rotate[7] <= rotate[7];
                            rotate[8] <= rotate[8];
                            rotate[9] <= rotate[9];
                            rotate[10] <= rotate[10];
                            rotate[11] <= rotate[11];
                            rotate[12] <= rotate[12];
                            rotate[13] <= rotate[13];
                            rotate[14] <= rotate[14];
                            rotate[15] <= rotate[15];
                            rotate[16] <= rotate[16];
                            h[0] <= h[0];
                            h[1] <= h[1];
                            h[2] <= h[2];
                            h[3] <= h[3];
                            h[4] <= h[4];
                            h[5] <= h[5];
                            h[6] <= h[6];
                            h[7] <= h[7];
                            h[8] <= h[8];
                            h[9] <= h[9];
                            h[10] <= h[10];
                            h[11] <= h[11];
                            h[12] <= h[12];
                            h[13] <= h[13];
                            h[14] <= h[14];
                            h[15] <= h[15];
                            h[16] <= h[16];
                            v[0] <= v[0];
                            v[1] <= v[1];
                            v[2] <= v[2];
                            v[3] <= v[3];
                            v[4] <= v[4];
                            v[5] <= v[5];
                            v[6] <= v[6];
                            v[7] <= v[7];
                            v[8] <= v[8];
                            v[9] <= v[9];
                            v[10] <= v[10];
                            v[11] <= v[11];
                            v[12] <= v[12];
                            v[13] <= v[13];
                            v[14] <= v[14];
                            v[15] <= v[15];
                            v[16] <= v[16];
                        end
                    end
                end
            end
        end
    end

endmodule