module majority (out, a, b, c);
    output out;
    input a, b, c;
    wire out;
    assign out = (a & b) | (a & c) | (b & c);
endmodule