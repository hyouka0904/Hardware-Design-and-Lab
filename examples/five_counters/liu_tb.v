`timescale 1ns / 1ps
module tb_Five_Counters;

    reg clock1, Da;
    wire Qa, Qb, Qc;
    
    initial begin
        clock1 = 1'b0; 
        Da = 1'b1;
        #180 $finish;
    end

    always #10 clock1 = ~clock1; 

    Five_Counters dut (clock1, Da, Qa, Qb, Qc);
endmodule