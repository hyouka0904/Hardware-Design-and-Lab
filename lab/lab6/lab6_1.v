module lab6_1(
    input clk,
    input rst,
    input en,
    input dir,
    input vmir,
    input hmir,
    input enlarge,
    output [3:0] vgaRed,
    output [3:0] vgaGreen,
    output [3:0] vgaBlue,
    output hsync,
    output vsync
);

    wire clk_22;
    wire clk_25MHz;
    wire [11:0] data;
    reg [16:0] pixel_addr;
    wire [11:0] pixel;
    wire valid;
    wire rst_onepulse;
    wire [9:0] h_cnt; //640
    wire [9:0] v_cnt;  //480
    reg [8:0] position;
    reg [9:0]pixel_cnt;
    reg [9:0]line_cnt;
    reg hsync_i,vsync_i;
    reg [16:0] next_addr;
    reg [9:0] tmp_v, tmp_h, tmp1, tmp2;

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
    clock_divider #(22) div1(.clk(clk), .clk_div(clk_22));
    clock_divider #(2) div2(.clk(clk), .clk_div(clk_25MHz));
    one_pulse o1(.clk(clk_22), .pb_in(rst), .pb_out(rst_onepulse));
    wire [3:0]tmp_vgaRed, tmp_vgaGreen, tmp_vgaBlue;
    
    assign {vgaRed, vgaGreen, vgaBlue} = (valid==1'b1) ? pixel:12'h0;
    //assign {tmp_vgaRed, tmp_vgaGreen, tmp_vgaBlue} = (valid==1'b1) ? pixel:12'hfff;
    //assign vgaRed = 4'hf - tmp_vgaRed;
    //assign vgaGreen = 4'hf - tmp_vgaGreen;
    //assign vgaBlue = 4'hf - tmp_vgaBlue;

    blk_mem_gen_0 blk_mem_gen_0_inst(
      .clka(clk_25MHz),
      .wea(0),
      .addra(pixel_addr),
      .dina(data[11:0]),
      .douta(pixel)
    ); 


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

    always @ (posedge clk_22, posedge rst_onepulse) begin
        if(rst_onepulse)
            position <= 0;
        else begin
            if(!en) position <= position;
            else begin
                if(dir == 0) begin
                    if(position < 319)
                        position <= position + 1;
                    else
                        position <= 0;
                end
                else begin
                    if(position > 0)
                        position <= position - 1;
                    else
                        position <= 319;
                end
            end
        end
    end

    always @* begin
        if((h_cnt >> 1) + position > 319) begin
            pixel_addr <= (320 * (v_cnt >> 1)) + position - 320 + (h_cnt >> 1);
            tmp_h <= position - 320 + (h_cnt >> 1);
        end
        else begin
            pixel_addr <= (h_cnt>>1)+320*(v_cnt>>1) + position;
            tmp_h <= position + (h_cnt>>1);
        end
        if((h_cnt >> 2) + position > 319)
                tmp1 <= position - 320 + (h_cnt >> 2) + 80;
        else
                tmp1 <= position + (h_cnt >> 2) + 80;

        if(vmir && !hmir && !enlarge)
            pixel_addr <= tmp_h + 320 * (239 - (v_cnt >> 1));
        else if(hmir && !vmir && !enlarge)
            pixel_addr <= (319 - tmp_h) + 320 * (v_cnt >> 1);
        else if(!vmir && !hmir && enlarge)
            pixel_addr <= tmp1 + 320 * ((v_cnt >> 2) + 60);
        else if(vmir && hmir && !enlarge)
            pixel_addr <= (319 - tmp_h) + 320 * (239 - (v_cnt >> 1));
        else if(vmir && !hmir && enlarge)
            pixel_addr <= tmp1 + 320 * (((239 - (v_cnt >> 1)) >> 1) + 60);    
        else if(!vmir && hmir && enlarge)
            pixel_addr <= (319 - tmp1) + 320 * ((v_cnt >> 2) + 60);
        else if(vmir && hmir && enlarge)
            pixel_addr <= (319 - tmp1) + 320 * (((239 - (v_cnt >> 1)) >> 1) + 60);         
    end 

    assign hsync = hsync_i;
    assign vsync = vsync_i;
    assign valid = ((pixel_cnt < HD) && (line_cnt < VD));

    assign h_cnt = (pixel_cnt < HD) ? pixel_cnt : 10'd0;
    assign v_cnt = (line_cnt < VD) ? line_cnt : 10'd0;
    
endmodule