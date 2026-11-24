`timescale 1ns / 1ps

module Five_Counters (
    input clock1,
    input Da,
    output wire Qa,
    output wire Qb,
    output wire Qc
);

    wire rst;
    wire Db = 1'b0, Dc = 1'b0;
    reg A_out = 0 , B_out = 1, C_out = 0;
    always @(posedge clock1, posedge rst) begin
        if(rst) A_out <= 0;
        else A_out <= Da;
    end

    assign Da = ~A_out;

    always @(posedge A_out, posedge rst) begin
        if(rst) B_out <= 0;
        else B_out <= Db;
    end
    assign Db = ~B_out;

    always @(posedge B_out, posedge rst) begin
        if(rst) C_out <= 0;
        else C_out <= Dc;
    end
    assign Dc = ~C_out;
    assign rst = (~A_out && B_out && ~C_out);
    assign Qa = ~A_out;
    assign Qb = ~B_out;
    assign Qc = ~C_out;

endmodule