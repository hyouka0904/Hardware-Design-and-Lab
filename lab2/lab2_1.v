`timescale 1ns/1ps
module Parameterized_Ping_Pong_Counter (
    input clk, 
    input rst_n, 
    input enable, 
    input flip,
    input [3:0] max, 
    input [3:0] min, 
    output reg direction, 
    output reg[3:0] out
);
    reg tmp = 1'b1, flag = 1'b0, test = 1'b0;
    reg [3:0] store = 4'b0;
    always @* begin
        direction = tmp;
    end
    always @(posedge clk) begin
        if(flip) tmp = (tmp == 1) ? 0 : 1;
        else tmp = tmp;
    end
    always @(posedge clk) begin
        test = 1'b0;
        if(flag) store = 4'b0;
        if(!rst_n) begin
            out = min;
            tmp = 1'b1;
            test = 1'b1;
        end
        if(tmp == 1 && !test) begin
            if(enable == 1) begin
                if((out == max && out == min) || min >= max || out < min || out > max) begin
                    tmp = tmp;
                    out = out;
                end
                else if(out == max && min < max) tmp = 0;
                else out = out + 1;
            end
            else out = out;
        end
        if(tmp == 0 && !test) begin
            if(enable == 1) begin
                if((out == max && out == min) || min >= max || out < min || out > max) begin    
                    tmp = tmp;
                    out = out;
                end
                else if(out == min && max > min) begin
                    tmp = 1;
                    out = out + 1;
                end
                else out = out - 1;
            end
            else out = out;       
        end
    end

endmodule