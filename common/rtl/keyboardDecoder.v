module KeyboardDecoder(
	output reg [23:0] key_down,
	output wire [8:0] last_change,
	output reg key_valid,
	inout wire PS2_DATA,
	inout wire PS2_CLK,
	input wire rst,
	input wire clk
    );
    
    parameter [1:0] INIT			= 2'b00;
    parameter [1:0] WAIT_FOR_SIGNAL = 2'b01;
    parameter [1:0] GET_SIGNAL_DOWN = 2'b10;
    parameter [1:0] WAIT_RELEASE    = 2'b11;
    
	parameter [7:0] IS_INIT			= 8'hAA;
    parameter [7:0] IS_EXTEND		= 8'hE0;
    parameter [7:0] IS_BREAK		= 8'hF0;
    
	parameter l0 = 9'b0_0100_0101;
	parameter l1 = 9'b0_0001_0110;
	parameter l2 = 9'b0_0001_1110;
	parameter l3 = 9'b0_0010_0110;
	parameter l4 = 9'b0_0010_0101;
	parameter l5 = 9'b0_0010_1110;
	parameter l6 = 9'b0_0011_0110;
	parameter l7 = 9'b0_0011_1101;
	parameter l8 = 9'b0_0011_1110;
	parameter l9 = 9'b0_0100_0110;
	parameter r0 = 9'b0_0111_0000;
	parameter r1 = 9'b0_0110_1001;
	parameter r2 = 9'b0_0111_0010;
	parameter r3 = 9'b0_0111_1010;
	parameter r4 = 9'b0_0110_1011;
	parameter r5 = 9'b0_0111_0011;
	parameter r6 = 9'b0_0111_0100;
	parameter r7 = 9'b0_0110_1100;
	parameter r8 = 9'b0_0111_0101;
	parameter r9 = 9'b0_0111_1101;
	parameter enter_code = 9'b0_0101_1010;
	parameter space_code = 9'b0_0010_1001;

    reg [9:0] key;		// key = {been_extend, been_break, key_in}
    reg [1:0] state;
    reg been_ready, been_extend, been_break;
    
    wire [7:0] key_in;
    wire is_extend;
    wire is_break;
    wire valid;
    wire err;
    wire [4:0] move;
    wire [23:0] key_decode = 1 << move;
    assign last_change = {key[9], key[7:0]};
    assign move = (last_change == l0 ? 0 : (last_change == l1 ? 1 : (last_change == l2 ? 2 : (last_change == l3 ? 3 : (last_change == l4 ? 4 : (last_change == l5 ? 5 : (last_change == l6 ? 6 : (last_change == l7 ? 7 : (last_change == l8 ? 8 : (last_change == l9 ? 9 : (last_change == r0 ? 10 : (last_change == r1 ? 11 : (last_change == r2 ? 12 : (last_change == r3 ? 13 : (last_change == r4 ? 14 : (last_change == r5 ? 15 : (last_change == r6 ? 16 : (last_change == r7 ? 17 : (last_change == r8 ? 18 : (last_change == r9 ? 19 : (last_change == enter_code ? 20 : (last_change == space_code ? 21 : 22))))))))))))))))))))));

    KeyboardCtrl_0 inst (
		.key_in(key_in),
		.is_extend(is_extend),
		.is_break(is_break),
		.valid(valid),
		.err(err),
		.PS2_DATA(PS2_DATA),
		.PS2_CLK(PS2_CLK),
		.rst(rst),
		.clk(clk)
	);
	
	one_pulse op (
		.pb_out(pulse_been_ready),
		.pb_in(been_ready),
		.clk(clk)
	);
    
    always @ (posedge clk, posedge rst) begin
    	if (rst) begin
    		state <= INIT;
    		been_ready  <= 1'b0;
    		been_extend <= 1'b0;
    		been_break  <= 1'b0;
    		key <= 10'b0_0_0000_0000;
    	end else begin
    		state <= state;
			been_ready  <= been_ready;
			been_extend <= (is_extend) ? 1'b1 : been_extend;
			been_break  <= (is_break ) ? 1'b1 : been_break;
			key <= key;
    		case (state)
    			INIT : begin
    					if (key_in == IS_INIT) begin
    						state <= WAIT_FOR_SIGNAL;
    						been_ready  <= 1'b0;
							been_extend <= 1'b0;
							been_break  <= 1'b0;
							key <= 10'b0_0_0000_0000;
    					end else begin
    						state <= INIT;
    					end
    				end
    			WAIT_FOR_SIGNAL : begin
    					if (valid == 0) begin
    						state <= WAIT_FOR_SIGNAL;
    						been_ready <= 1'b0;
    					end else begin
    						state <= GET_SIGNAL_DOWN;
    					end
    				end
    			GET_SIGNAL_DOWN : begin
						state <= WAIT_RELEASE;
						key <= {been_extend, been_break, key_in};
						been_ready  <= 1'b1;
    				end
    			WAIT_RELEASE : begin
    					if (valid == 1) begin
    						state <= WAIT_RELEASE;
    					end else begin
    						state <= WAIT_FOR_SIGNAL;
    						been_extend <= 1'b0;
    						been_break  <= 1'b0;
    					end
    				end
    			default : begin
    					state <= INIT;
						been_ready  <= 1'b0;
						been_extend <= 1'b0;
						been_break  <= 1'b0;
						key <= 10'b0_0_0000_0000;
    				end
    		endcase
    	end
    end
    
    always @ (posedge clk, posedge rst) begin
    	if (rst) begin
    		key_valid <= 1'b0;
    		key_down <= 24'b0;
    	end else if (key_decode[move] && pulse_been_ready) begin
    		key_valid <= 1'b1;
    		if (key[8] == 0) begin
    			key_down <= key_down | key_decode;
    		end else begin
    			key_down <= key_down & (~key_decode);
    		end
    	end else begin
    		key_valid <= 1'b0;
			key_down <= key_down;
    	end
    end

endmodule