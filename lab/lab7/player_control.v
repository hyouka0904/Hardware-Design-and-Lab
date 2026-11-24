module player_control (
	input clk, 
	input reset, 
	input _start,
	input _play, 
	input _slow, 
	input _mode, 
	output reg [11:0] ibeat
);
	parameter LEN = 4095;
    //reg [11:0] next_ibeat;
	reg [11:0] next_play_ibeat, next_demo_ibeat, pre_demo_ibeat;
	reg state = 1'b0, flag = 1'b1, flag_1 = 1'b1;

	always @(posedge clk, posedge reset) begin
		if(reset) begin
			ibeat <= 0;
			flag <= 1'b1;
			flag_1 <= 1'b1;
			pre_demo_ibeat <= 0;
		end
		else begin
			if(state == 0) begin
				if(flag_1) begin
					ibeat <= pre_demo_ibeat;
					flag_1 <= 1'b0;
					flag <= 1'b1;
				end
				else begin
					if(ibeat == LEN) ibeat <= 0;
					else ibeat <= next_demo_ibeat;
					pre_demo_ibeat <= ibeat;
				end
			end
			else begin
				if(flag) begin
					ibeat <= 0;
					flag <= 1'b0;
					flag_1 <= 1'b1;
				end
				else begin
					flag <= 0;
					flag_1 <= 1'b1;
		        	ibeat <= next_play_ibeat;
				end
			end
		end
	end

	always @* begin
		if(!_mode && _start && !_play) state = 1;    //play mode
		else state = 0;    //demo mode
	end

	always @* begin
		if(state == 0 && ibeat != LEN) begin
			if(_play && _mode) begin
				if(ibeat + 1 < LEN) next_demo_ibeat = ibeat + 1;
				else next_demo_ibeat = 0;
			end
			else if(!_play && _mode) next_demo_ibeat = ibeat;
			else next_demo_ibeat = ibeat;
		end
		else next_demo_ibeat = 0;
	end

	always @* begin
		if(state == 1) begin
			if(_start && !_mode) begin
				if(ibeat + 1 < LEN) next_play_ibeat = ibeat + 1;
				else next_play_ibeat = LEN;		
			end
			else if(!_mode && !_start) next_play_ibeat = 0;
			else next_play_ibeat = ibeat;
		end
		else next_play_ibeat = 0;
	end
endmodule
