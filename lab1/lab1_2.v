`timescale 1ns/100ps
module lab1_2 (
    input wire [3:0] source_0,
    input wire [3:0] source_1,
    input wire [3:0] source_2,
    input wire [3:0] source_3,
    input wire [1:0] op_0,
    input wire [1:0] op_1,
    input wire [1:0] request,
    output reg [3:0] result
);
wire [3:0] tmp1, tmp2;
lab1_1 xx(.op(op_0), .a(source_0), .b(source_1), .d(tmp1));
lab1_1 yy(.op(op_1), .a(source_2), .b(source_3), .d(tmp2));
always @* begin
    case(request)
        2'b00: result = 4'b0;
        2'b01: result = tmp1;
        2'b10: result = tmp2;
        2'b11: result = tmp1;
        default: result = 4'b0;
    endcase
end
endmodule
