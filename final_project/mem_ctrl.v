module mem_ctrl(
    input clk,
    input rst,
    input pixel_tick,
    input flag_alphabet,
    input [16:0] pixel_addr,
    output [11:0] pixel
);
    wire [11:0] alphabet_pixel, background_pixel;
    reg alphabet_selected;

    always @(posedge clk)
        if (rst)
            alphabet_selected <= 1'b0;
        else if (pixel_tick)
            alphabet_selected <= flag_alphabet;

    assign pixel = alphabet_selected ? alphabet_pixel : background_pixel;

    blk_mem_gen_1 alphabet(
        .clka(clk),
        .ena(pixel_tick),
        .addra(pixel_addr[15:0]),
        .douta(alphabet_pixel)
    );

    blk_mem_gen_0 background(
        .clka(clk),
        .ena(pixel_tick),
        .addra(pixel_addr),
        .douta(background_pixel)
    );
endmodule
