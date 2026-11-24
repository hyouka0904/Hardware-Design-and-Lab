module fail_scene(
    input clk, 
    input wire [9:0] vga_h, 
    input wire [9:0] vga_v, 
    output reg [15:0] addr
);
    wire en_l, en_o, en_s, en_s2;
    wire [15:0] addr_l, addr_o, addr_s, addr_s2;

    abc  l(
        .addr(addr_l), 
        .en(en_l),
        .vga_h(vga_h), 
        .vga_v(vga_v), 
        .mem_pivot_h(10'd55),
        .mem_pivot_v(10'd50),
        .pivot_h(10'd70),
        .pivot_v(10'd60),
        .width(10'd23),
        .height(10'd40)
    );

    abc  o(
        .addr(addr_o), 
        .en(en_o),
        .vga_h(vga_h), 
        .vga_v(vga_v), 
        .mem_pivot_h(10'd135),
        .mem_pivot_v(10'd50),
        .pivot_h(10'd95),
        .pivot_v(10'd62),
        .width(10'd25),
        .height(10'd40)
    );

    abc  s(
        .addr(addr_s), 
        .en(en_s),
        .vga_h(vga_h), 
        .vga_v(vga_v), 
        .mem_pivot_h(10'd5),
        .mem_pivot_v(10'd90),
        .pivot_h(10'd120),
        .pivot_v(10'd60),
        .width(10'd23),
        .height(10'd40)
    );

    abc  s2(
        .addr(addr_s2), 
        .en(en_s2),
        .vga_h(vga_h), 
        .vga_v(vga_v), 
        .mem_pivot_h(10'd5),
        .mem_pivot_v(10'd90),
        .pivot_h(10'd145),
        .pivot_v(10'd60),
        .width(10'd23),
        .height(10'd40)
    );

    always @* begin
        if(en_l)  addr = addr_l;
        else if(en_o) addr = addr_o;
        else if(en_s) addr = addr_s;
        else if(en_s2) addr = addr_s2;
        else addr = 0;
    end

endmodule