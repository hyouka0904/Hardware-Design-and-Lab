`timescale 1ns / 1ps
module clock_divider(clk,clk_div);
    input clk;
    output clk_div;
    parameter n = 25;
    reg[n-1:0]num = 0;
    wire[n-1:0]next_num;
    always@(posedge clk)begin
        num <= next_num;
    end
    assign next_num = num + 1;
    assign clk_div = num[n-1];
endmodule

module lab3_2 (
    input clk,
    input rst,
    input speed,
    output led0,
    output led1
    );
    reg LD0,LD1;
    wire clk_div1,clk_div2,clk_div23,clk_div25;
	
    //directly use two clock in our mudule
	clock_divider #(25) div1(.clk(clk), .clk_div(clk_div25));
    clock_divider #(23) div2(.clk(clk), .clk_div(clk_div23));

    //change speed by switch    
    assign clk_div0 = (speed)?clk_div25 : clk_div23;
	assign clk_div1 = (speed)?clk_div23 : clk_div25;
    
    always@(posedge clk_div0 or posedge rst)begin
        if(rst) begin
            LD0 <= 1;//reset the led
        end else begin
            LD0 <= ~LD0;//toggle the led
        end
    end
    
    always@(posedge clk_div1 or posedge rst)begin
        if(rst) begin
            LD1 <= 1;
        end else begin
            LD1 <= ~LD1;
        end
    end

    //connect the register to wire
    assign led0 = LD0;
    assign led1 = LD1;
endmodule

/*
`timescale 1ns / 1ps
module clock_divider(clk,clk_div);
    input clk;
    output clk_div;
    parameter n = 25;
    reg[n-1:0]num;
    wire[n-1:0]next_num;
    always@(posedge clk)begin
        num <= next_num;
    end
    assign next_num = num + 1;
    assign clk_div = num[n-1];
endmodule

module lab3_2 (
    input clk,
    input rst,
    input speed,
    output led0,
    output led1
    );
    reg LD0,LD1;
    reg[2-1:0] counter;
    wire clk_div1,clk_div2,clk_div23,clk_div25;
	
    //only use the faster clock
	clock_divider #(23) div1(.clk(clk), .clk_div(clk_div23));

    //change speed by switch      
    assign clk_div0 = (speed)?clk_div25 : clk_div23;
	assign clk_div1 = (speed)?clk_div23 : clk_div25;
    
    //use a counter in our module to build another clock
    always@(posedge clk_div23)begin
        counter <= counter+1;
    end
    assign clk_div25 = counter[1]; 

    always@(posedge clk_div0 or posedge rst)begin
        if(rst) begin
            LD0 <= 1;//reset the led
        end else begin
            LD0 <= ~LD0;//toggle the led
        end
    end
    
    always@(posedge clk_div1 or posedge rst)begin
        if(rst) begin
            LD1 <= 1;
        end else begin
            LD1 <= ~LD1;
        end
    end

    //connect the register to wire
    assign led0 = LD0;
    assign led1 = LD1;
endmodule

*/