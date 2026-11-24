`timescale 1ns/100ps
module lab1_1 (
    input wire [1:0] op,
    input wire [3:0] a,
    input wire [3:0] b,
    output reg [3:0] d
);
always @* begin
    d = 4'b0;
    case(op)
        2'b00: d = a & b;
        2'b01: d = a << b;
        2'b10: d = a | b;
        2'b11: d = a >> b;
    endcase
end
endmodule