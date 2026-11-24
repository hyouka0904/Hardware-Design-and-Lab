module map_and_menu_addr_gen(
    input [9:0] h, v,
    input [2:0] select, map,
    input [16:0] map1_addr, map2_addr, map3_addr, map4_addr,
    output reg [16:0] map_and_menu_addr
);
    reg [9:0] row_start;
    reg [2:0] menu_row;
    reg highlighted;

    always @* begin
        row_start = 10'd0;
        menu_row = 3'd0;
        if (v >= 10'd80 && v < 10'd105) begin
            row_start = 10'd80;
            menu_row = 3'd1;
        end else if (v >= 10'd120 && v < 10'd145) begin
            row_start = 10'd120;
            menu_row = 3'd2;
        end else if (v >= 10'd160 && v < 10'd185) begin
            row_start = 10'd160;
            menu_row = 3'd3;
        end else if (v >= 10'd200 && v < 10'd225) begin
            row_start = 10'd200;
            menu_row = 3'd4;
        end

        // The artwork highlights items in reverse order relative to map IDs.
        highlighted = menu_row != 0 && menu_row == 3'd5 - map;
        map_and_menu_addr = 17'd0;
        if (select != 0) begin
            case (map)
                3'd1: map_and_menu_addr = map1_addr;
                3'd2: map_and_menu_addr = map2_addr;
                3'd3: map_and_menu_addr = map3_addr;
                3'd4: map_and_menu_addr = map4_addr;
                default: ;
            endcase
        end else if (map >= 1 && map <= 4 && menu_row != 0 &&
                     h < 10'd170 && h >= (highlighted ? 10'd148 : 10'd150)) begin
            map_and_menu_addr = (v - row_start + 17'd1) * 17'd320
                + h - (highlighted ? 17'd127 : 17'd150);
        end
    end
endmodule
