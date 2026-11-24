module menu_pixel_addr #(
    parameter [2:0] MAP_COUNT = 3'd4
)(
    input [9:0] h, v,
    input [2:0] map,
    output reg [16:0] addr
);
    localparam [9:0] BOTTOM_ROW_Y = 10'd200;
    localparam [9:0] ROW_SPACING = 10'd40;
    localparam [9:0] ROW_HEIGHT = 10'd25;

    integer item;
    reg [9:0] row_y;
    reg highlighted;

    always @* begin
        addr = 17'd0;
        for (item = 1; item <= MAP_COUNT; item = item + 1) begin
            row_y = BOTTOM_ROW_Y - (item - 1) * ROW_SPACING;
            highlighted = map == item;
            if (map >= 3'd1 && map <= MAP_COUNT && v >= row_y && v < row_y + ROW_HEIGHT && h < 10'd170 &&
                h >= (highlighted ? 10'd148 : 10'd150)) begin
                addr = (v - row_y + 17'd1) * 17'd320
                       + h - (highlighted ? 17'd127 : 17'd150);
            end
        end
    end
endmodule
