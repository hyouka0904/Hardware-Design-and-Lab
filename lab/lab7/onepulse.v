/*module onepulse(
    input signal, 
    input clk, 
    output reg op
    );
    
    reg delay;
    
    always @(posedge clk) begin
        if((signal == 1) & (delay == 0)) op <= 1;
        else op <= 0; 
        delay <= signal;
    end
endmodule*/
module onepulse (
    input clk,
    input signal,
    output reg op
);

	reg pb_in_delay;

	always @(posedge clk) begin
		if (signal == 1'b1 && pb_in_delay == 1'b0) begin
			op <= 1'b1;
		end else begin
			op <= 1'b0;
		end
	end
	
	always @(posedge clk) begin
		pb_in_delay <= signal;
	end
endmodule
