module game_cover(
    input clk, 
    input wire [9:0] vga_h, 
    input wire [9:0] vga_v, 
    output reg [15:0] addr
);

    wire en_e, en_s, en_c, en_a, en_p, en_e2, en_f, en_r, en_o, en_m, en_n, en_t, en_h, en_u;
    wire [15:0] addr_e, addr_s, addr_c, addr_a, addr_p, addr_e2, addr_f, addr_r, addr_o, addr_m;
    wire [15:0] addr_n, addr_t, addr_h, addr_u;

    abc  u(
        .addr(addr_u), 
        .en(en_u),
        .vga_h(vga_h), 
        .vga_v(vga_v), 
        .mem_pivot_h(10'd55),
        .mem_pivot_v(10'd90),
        .pivot_h(10'd145),
        .pivot_v(10'd120),
        .width(10'd25),
        .height(10'd40)
    );

    abc  h(
        .addr(addr_h), 
        .en(en_h),
        .vga_h(vga_h), 
        .vga_v(vga_v), 
        .mem_pivot_h(10'd185),
        .mem_pivot_v(10'd7),
        .pivot_h(10'd120),
        .pivot_v(10'd120),
        .width(10'd25),
        .height(10'd40)
    );

    abc  t(
        .addr(addr_t), 
        .en(en_t),
        .vga_h(vga_h), 
        .vga_v(vga_v), 
        .mem_pivot_h(10'd30),
        .mem_pivot_v(10'd90),
        .pivot_h(10'd95),
        .pivot_v(10'd120),
        .width(10'd25),
        .height(10'd40)
    );

    abc  n(
        .addr(addr_n), 
        .en(en_n),
        .vga_h(vga_h), 
        .vga_v(vga_v), 
        .mem_pivot_h(10'd108),
        .mem_pivot_v(10'd50),
        .pivot_h(10'd70),
        .pivot_v(10'd120),
        .width(10'd25),
        .height(10'd40)
    );

    abc m (
        .addr(addr_m), 
        .en(en_m),
        .vga_h(vga_h), 
        .vga_v(vga_v), 
        .mem_pivot_h(10'd78),
        .mem_pivot_v(10'd50),
        .pivot_h(10'd145),
        .pivot_v(10'd63),
        .width(10'd30),
        .height(10'd40)
    );

    abc  o(
        .addr(addr_o), 
        .en(en_o),
        .vga_h(vga_h), 
        .vga_v(vga_v), 
        .mem_pivot_h(10'd135),
        .mem_pivot_v(10'd50),
        .pivot_h(10'd120),
        .pivot_v(10'd62),
        .width(10'd25),
        .height(10'd40)
    );

    abc  r(
        .addr(addr_r), 
        .en(en_r),
        .vga_h(vga_h), 
        .vga_v(vga_v), 
        .mem_pivot_h(10'd210),
        .mem_pivot_v(10'd50),
        .pivot_h(10'd95),
        .pivot_v(10'd62),
        .width(10'd25),
        .height(10'd40)
    );

    abc  f(
        .addr(addr_f), 
        .en(en_f),
        .vga_h(vga_h), 
        .vga_v(vga_v), 
        .mem_pivot_h(10'd133),
        .mem_pivot_v(10'd5),
        .pivot_h(10'd70),
        .pivot_v(10'd60),
        .width(10'd25),
        .height(10'd40)
    );

    abc  e2(
        .addr(addr_e2), 
        .en(en_e2),
        .vga_h(vga_h), 
        .vga_v(vga_v), 
        .mem_pivot_h(10'd108),
        .mem_pivot_v(10'd5),
        .pivot_h(10'd170),
        .pivot_v(10'd5),
        .width(10'd25),
        .height(10'd40)
    );

    abc  p(
        .addr(addr_p), 
        .en(en_p),
        .vga_h(vga_h), 
        .vga_v(vga_v), 
        .mem_pivot_h(10'd159),
        .mem_pivot_v(10'd50),
        .pivot_h(10'd145),
        .pivot_v(10'd10),
        .width(10'd25),
        .height(10'd40)
    );

    abc  a(
        .addr(addr_a), 
        .en(en_a),
        .vga_h(vga_h), 
        .vga_v(vga_v), 
        .mem_pivot_h(10'd5),
        .mem_pivot_v(10'd5),
        .pivot_h(10'd120),
        .pivot_v(10'd5),
        .width(10'd25),
        .height(10'd40)
    );

    abc  c(
        .addr(addr_c), 
        .en(en_c),
        .vga_h(vga_h), 
        .vga_v(vga_v), 
        .mem_pivot_h(10'd55),
        .mem_pivot_v(10'd5),
        .pivot_h(10'd95),
        .pivot_v(10'd5),
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
        .pivot_h(10'd70),
        .pivot_v(10'd8),
        .width(10'd23),
        .height(10'd40)
    );

    abc  e(
        .addr(addr_e), 
        .en(en_e),
        .vga_h(vga_h), 
        .vga_v(vga_v), 
        .mem_pivot_h(10'd108),
        .mem_pivot_v(10'd5),
        .pivot_h(10'd45),
        .pivot_v(10'd5),
        .width(10'd25),
        .height(10'd40)
    );

    /*
    abc  (
        .addr(addr_), 
        .en(en_),
        .vga_h(vga_h), 
        .vga_v(vga_v), 
        .mem_pivot_h(), 
        .mem_pivot_v(),
        .pivot_h(),
        .pivot_v(),
        .width(10'd25),
        .height(10'd40)
    );
    */

    always @* begin
        if(en_e) addr = addr_e;
        else if(en_s) addr = addr_s;
        else if(en_c) addr = addr_c;
        else if(en_a) addr = addr_a;
        else if(en_p) addr = addr_p;
        else if(en_e2) addr = addr_e2;
        else if(en_f) addr = addr_f;
        else if(en_r) addr = addr_r;
        else if(en_o) addr = addr_o;
        else if(en_m) addr = addr_m;
        else if(en_n) addr = addr_n;
        else if(en_t) addr = addr_t;
        else if(en_h) addr = addr_h;
        else if(en_u) addr = addr_u;
        else addr = 0 ;
    end
endmodule