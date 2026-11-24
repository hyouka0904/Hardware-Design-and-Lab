`timescale 1ns/100ps
module test;
    reg [2:0] count;
    wire out;
    majority m(out, count[0], count[1], count[2]);
    initial begin
        count = 3'b000;
        repeat (8) begin
            #10
            $display("in = %b, out = %b", count, out);
            count = count + 3'b001;
        end
    end
endmodule