module KeyboardDecoder(
	input wire rst,
	input wire clk,
	inout wire PS2_DATA,
	inout wire PS2_CLK,
	output reg [21:0] key_down,
	output wire [8:0] last_change,
	output reg key_valid
    );
    
    parameter [1:0] INIT			= 2'b00;
    parameter [1:0] WAIT_FOR_SIGNAL = 2'b01;
    parameter [1:0] GET_SIGNAL_DOWN = 2'b10;
    parameter [1:0] WAIT_RELEASE    = 2'b11;
    
	parameter [7:0] IS_INIT			= 8'hAA;
    parameter [7:0] IS_EXTEND		= 8'hE0;
    parameter [7:0] IS_BREAK		= 8'hF0;
    
	parameter [8:0] Q_code = 9'b0_0001_0101;
    parameter [8:0] W_code = 9'b0_0001_1101;
    parameter [8:0] E_code = 9'b0_0010_0100;
    parameter [8:0] R_code = 9'b0_0010_1101;
    parameter [8:0] T_code = 9'b0_0010_1100;
    parameter [8:0] Y_code = 9'b0_0011_0101;
    parameter [8:0] U_code = 9'b0_0011_1100;
    parameter [8:0] A_code = 9'b0_0001_1100;
    parameter [8:0] S_code = 9'b0_0001_1011;
    parameter [8:0] D_code = 9'b0_0010_0011;
    parameter [8:0] F_code = 9'b0_0010_1011;
    parameter [8:0] G_code = 9'b0_0011_0100;
    parameter [8:0] H_code = 9'b0_0011_0011;
    parameter [8:0] J_code = 9'b0_0011_1011;
    parameter [8:0] Z_code = 9'b0_0001_1010;
    parameter [8:0] X_code = 9'b0_0010_0010;
    parameter [8:0] C_code = 9'b0_0010_0001;
    parameter [8:0] V_code = 9'b0_0010_1010;
    parameter [8:0] B_code = 9'b0_0011_0010;
    parameter [8:0] N_code = 9'b0_0011_0001;
    parameter [8:0] M_code = 9'b0_0011_1010;

    reg [9:0] key;		// key = {been_extend, been_break, key_in}
    reg [1:0] state;
    reg been_ready, been_extend, been_break;
    
    wire [7:0] key_in;
    wire is_extend;
    wire is_break;
    wire valid;
    wire err;
    wire [4:0] move;

    wire [21:0] key_decode = 1 << move;
    assign last_change = {key[9], key[7:0]};
    assign move =   (last_change == Q_code) ? 0 :
	                (last_change == W_code) ? 1 :
				    (last_change == E_code) ? 2 :
					(last_change == R_code) ? 3 :
					(last_change == T_code) ? 4 :
					(last_change == Y_code) ? 5 :
					(last_change == U_code) ? 6 :
					(last_change == A_code) ? 7 :
					(last_change == S_code) ? 8 :
					(last_change == D_code) ? 9 :
					(last_change == F_code) ? 10 :
					(last_change == G_code) ? 11 :
					(last_change == H_code) ? 12 :
					(last_change == J_code) ? 13 :
					(last_change == Z_code) ? 14 :
					(last_change == X_code) ? 15 :
					(last_change == C_code) ? 16 :
					(last_change == V_code) ? 17 :
					(last_change == B_code) ? 18 :
					(last_change == N_code) ? 19 :
					(last_change == M_code) ? 20 : 21;

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
	
	onepulse op (
		.signal(been_ready),
		.clk(clk),
		.op(pulse_been_ready)
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
    		key_down <= 511'b0;
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