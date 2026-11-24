module clock_divider #(parameter n = 27)(
    input wire  clk,
    output wire clk_div  
);
    reg [n-1:0] num;
    wire [n-1:0] next_num;

    always @(posedge clk) begin
        num <= next_num;
    end

    assign next_num = num + 1;
    assign clk_div = num[n-1];
endmodule

module Lab5(
	output reg [6:0] display,
	output reg [3:0] digit,
	output reg [15:0] LED,
	inout wire PS2_DATA,
	inout wire PS2_CLK,
	input wire rst,
	input wire clk,
	input wire btnL,
	input wire btnR
	);

	parameter IDLE = 0;
    parameter SET = 1;
    parameter PAYMENT = 2;
    parameter BUY = 3;
    parameter CHANGE = 4;
    parameter minus = 10;
    parameter empty = 11;
    parameter [8:0] enter_code = 9'b0_0101_1010, space_code = 9'b0_0010_1001;
    parameter [8:0] KEY_CODES [0:19] = {
		9'b0_0100_0101,	// 0 => 45
		9'b0_0001_0110,	// 1 => 16
		9'b0_0001_1110,	// 2 => 1E
		9'b0_0010_0110,	// 3 => 26
		9'b0_0010_0101,	// 4 => 25
		9'b0_0010_1110,	// 5 => 2E
		9'b0_0011_0110,	// 6 => 36
		9'b0_0011_1101,	// 7 => 3D
		9'b0_0011_1110,	// 8 => 3E
		9'b0_0100_0110,	// 9 => 46
		
		9'b0_0111_0000, // right_0 => 70
		9'b0_0110_1001, // right_1 => 69
		9'b0_0111_0010, // right_2 => 72
		9'b0_0111_1010, // right_3 => 7A
		9'b0_0110_1011, // right_4 => 6B
		9'b0_0111_0011, // right_5 => 73
		9'b0_0111_0100, // right_6 => 74
		9'b0_0110_1100, // right_7 => 6C
		9'b0_0111_0101, // right_8 => 75
		9'b0_0111_1101  // right_9 => 7D
	};
    wire btnL_debounced, btnL_onepulse, btnR_debounced, btnR_onepulse;
    wire space_onepulse, enter_onepulse;
    wire [8:0] last_change;
    reg [2:0] state = 3'b0, next_state = 3'b0, cnt_on_of = 3'b0, next_cnt_on_of = 3'b0;
    reg [3:0] key_num, display_num, tens_digit, units_digit, next_tens_digit, next_units_digit, amount, how_many_can_you_buy;
    reg [3:0] money_you_actually_spend_tens_digit = 4'b0, money_you_actually_spend_units_digit = 4'b0;
    reg [3:0] change_money_tens_digit = 4'b0, change_money_units_digit = 4'b0, unit_price_tens_digit = 4'b0, unit_price_units_digit = 4'b0;
    reg [9:0] unit_price = 10'd10, money_you_pay = 10'd0, money_you_actually_spend = 10'd0, change_money = 10'b0;
    reg [15:0] nums;
    reg [27:0] cnt_clk = 28'b0, next_cnt_clk = 28'b0;
    reg is_money_enough = 1'b0, set_money = 1'b0, have_rst_set_init = 1'b0, have_rst_payment_init = 1'b0, flag = 1'b0, first_time = 1'b1;
    wire [4:0] move;
    wire [23:0] key_down;
    wire [23:0] key_decode = 1 << move;
    assign move = (last_change == KEY_CODES[0] ? 0 : (last_change == KEY_CODES[1] ? 1 : (last_change == KEY_CODES[2] ? 2 : (last_change == KEY_CODES[3] ? 3 : (last_change == KEY_CODES[4] ? 4 : (last_change == KEY_CODES[5] ? 5 : (last_change == KEY_CODES[6] ? 6 : (last_change == KEY_CODES[7] ? 7 : (last_change == KEY_CODES[8] ? 8 : (last_change == KEY_CODES[9] ? 9 : (last_change == KEY_CODES[10] ? 10 : (last_change == KEY_CODES[11] ? 11 : (last_change == KEY_CODES[12] ? 12 : (last_change == KEY_CODES[13] ? 13 : (last_change == KEY_CODES[14] ? 14 : (last_change == KEY_CODES[15] ? 15 : (last_change == KEY_CODES[16] ? 16 : (last_change == KEY_CODES[17] ? 17 : (last_change == KEY_CODES[18] ? 18 : (last_change == KEY_CODES[19] ? 19 : (last_change == enter_code ? 20 : (last_change == space_code ? 21 : 22))))))))))))))))))))));
    wire been_ready, enter, space, seven_segment_clk;
    wire zero, one, two, three, four, five, six, seven, eight, nine;
    wire zero_onepulse, one_onepulse, two_onepulse, three_onepulse, four_onepulse, five_onepulse, six_onepulse,
    seven_onepulse, eight_onepulse, nine_onepulse;

    assign enter = (key_down[20] == 1'b1) ? 1'b1 : 1'b0;
    assign space = (key_down[21] == 1'b1) ? 1'b1 : 1'b0;
    assign zero = (key_down[0] || key_down[10]) ? 1'b1 : 1'b0;  
    assign one = (key_down[1] || key_down[11]) ? 1'b1 : 1'b0;  
    assign two = (key_down[2] || key_down[12]) ? 1'b1 : 1'b0;  
    assign three = (key_down[3] || key_down[13]) ? 1'b1 : 1'b0;
    assign four = (key_down[4] || key_down[14]) ? 1'b1 : 1'b0;  
    assign five = (key_down[5] || key_down[15]) ? 1'b1 : 1'b0; 
    assign six = (key_down[6] || key_down[16]) ? 1'b1 : 1'b0;  
    assign seven = (key_down[7] || key_down[17]) ? 1'b1 : 1'b0; 
    assign eight = (key_down[8] || key_down[18]) ? 1'b1 : 1'b0;  
    assign nine = (key_down[9] || key_down[19]) ? 1'b1 : 1'b0;

    clock_divider #(14) div2(.clk(clk), .clk_div(seven_segment_clk));
    debounce d1(.clk(clk), .pb(btnL), .pb_debounced(btnL_debounced));
    one_pulse o1(.clk(clk), .pb_in(btnL_debounced), .pb_out(btnL_onepulse));
    debounce d2(.clk(clk), .pb(btnR), .pb_debounced(btnR_debounced));
    one_pulse o2(.clk(clk), .pb_in(btnR_debounced), .pb_out(btnR_onepulse));
    one_pulse o3(.clk(clk), .pb_in(space), .pb_out(space_onepulse));
    one_pulse o4(.clk(clk), .pb_in(enter), .pb_out(enter_onepulse));
    one_pulse o5(.clk(clk), .pb_in(zero), .pb_out(zero_onepulse));  
    one_pulse o6(.clk(clk), .pb_in(one), .pb_out(one_onepulse));
    one_pulse o7(.clk(clk), .pb_in(two), .pb_out(two_onepulse));
    one_pulse o8(.clk(clk), .pb_in(three), .pb_out(three_onepulse));
    one_pulse o9(.clk(clk), .pb_in(four), .pb_out(four_onepulse));
    one_pulse o10(.clk(clk), .pb_in(five), .pb_out(five_onepulse));
    one_pulse o11(.clk(clk), .pb_in(six), .pb_out(six_onepulse));
    one_pulse o12(.clk(clk), .pb_in(seven), .pb_out(seven_onepulse));
    one_pulse o13(.clk(clk), .pb_in(eight), .pb_out(eight_onepulse));
    one_pulse o14(.clk(clk), .pb_in(nine), .pb_out(nine_onepulse));

    always @ (posedge seven_segment_clk) begin
    	case (digit)
    		4'b1110 : begin
    			    display_num <= nums[7:4];
    				digit <= 4'b1101;
    			end
    		4'b1101 : begin
					display_num <= nums[11:8];
					digit <= 4'b1011;
				end
    		4'b1011 : begin
					display_num <= nums[15:12];
					digit <= 4'b0111;
				end
    		4'b0111 : begin
					display_num <= nums[3:0];
					digit <= 4'b1110;
				end
    		default : begin
					display_num <= nums[3:0];
					digit <= 4'b1110;
				end				
    	endcase
    end

    always @* begin
    	case (display_num)
    		0 : display = 7'b1000000;	//0000
			1 : display = 7'b1111001;   //0001                                                
			2 : display = 7'b0100100;   //0010                                                
			3 : display = 7'b0110000;   //0011                                             
			4 : display = 7'b0011001;   //0100                                               
			5 : display = 7'b0010010;   //0101                                               
			6 : display = 7'b0000010;   //0110
			7 : display = 7'b1111000;   //0111
			8 : display = 7'b0000000;   //1000
			9 : display = 7'b0010000;	//1001
            minus: display = 7'b0111111;
            empty: display = 7'b1111111;
			default : display = 7'b1111111;
    	endcase
    end

    KeyboardDecoder k(
		.key_down(key_down),
		.last_change(last_change),
		.key_valid(been_ready),
		.PS2_DATA(PS2_DATA),
		.PS2_CLK(PS2_CLK),
		.rst(rst),
		.clk(clk)
	);

    always @(posedge clk, posedge rst) begin
        if(rst)
            state <= IDLE;
        else
            state <= next_state;
    end

    always @* begin
        next_state = state;
        case (state)
            IDLE: begin
                if(btnL_onepulse) begin
                    next_state = SET;
                end
                else if(btnR_onepulse) begin
                    next_state = PAYMENT;
                end
                else next_state = IDLE;
            end
            SET: begin
                if(enter_onepulse) begin
                    next_state = IDLE;
                end
                else next_state = SET;
            end
            PAYMENT: begin         
                if(enter_onepulse && is_money_enough) begin
                    next_state = BUY;
                end
                else if(enter_onepulse && !is_money_enough) begin
                    next_state = CHANGE;
                end
                else next_state = PAYMENT;
            end
            BUY: begin
                if(cnt_on_of == 6) begin
                    next_state = CHANGE;
                end
                else next_state = BUY;
            end
            CHANGE: begin
                if(cnt_clk == 28'd149999999)
                    next_state = IDLE;
                else next_state = CHANGE;
            end
        endcase
    end
    
    always @(posedge clk, posedge rst) begin
        if(rst) begin
            LED <= 16'b0000_0000_0000_0000;
            nums <= 16'b1010_1010_1010_1010;
            have_rst_set_init <= 1'b0;
            have_rst_payment_init <= 1'b0;
            money_you_pay <= 10'b0;
            unit_price <= 10'd10;
            unit_price_tens_digit <= 4'd1;
            unit_price_units_digit <= 4'd0;
            amount <= 4'd9;
            first_time <= 1'b1;
        end
        else begin
            case (state)
                IDLE: begin
                    nums <= 16'b1010_1010_1010_1010;
                    LED <= 16'b0000_0000_0000_0000;
                    have_rst_set_init <= 1'b0;
                    have_rst_payment_init <= 1'b0;
                    flag <= 1'b0;
                    tens_digit <= 4'b0;
                    units_digit <= 4'b0;
                    money_you_pay <= 10'b0;
                    is_money_enough <= 1'b0;
                    amount <= (amount - how_many_can_you_buy);
                end

                SET: begin
                    if(!have_rst_set_init) begin
                        if(first_time) begin
                            amount <= 4'd9;
                            nums <= {amount, 12'b1010_0001_0000};
                            unit_price <= 10'd10;
                            unit_price_tens_digit <= 4'd1;
                            unit_price_units_digit <= 4'd0;
                            first_time <= 1'b0;
                        end
                        else begin
                            nums <= {amount, 4'b1010, unit_price_tens_digit, unit_price_units_digit};
                        end
                        have_rst_set_init <= 1'b1;
                        have_rst_payment_init <= 1'b0;
                        LED <= 16'b1111_1111_0000_0000;                                    
                        set_money <= 1'b0;
                        flag <= 1'b0;
                    end
                    else begin
                        if(space_onepulse && ((key_decode | key_down) == key_decode)) begin
                            if(set_money == 1'b1) begin
                                set_money <= 1'b0;
                                LED <= 16'b1111_1111_0000_0000;
                            end
                            else begin
                                set_money <= 1'b1;
                                LED <= 16'b0000_0000_1111_1111;
                            end
                        end
                        else begin
                            if(((key_decode | key_down) == key_decode)) begin
                                if(key_num != 4'b1111) begin
                                    if(!set_money) begin
                                        if(zero_onepulse) nums <= {4'b0000, nums[11:0]};
                                        else if(one_onepulse) nums <= {4'b0001, nums[11:0]};
                                        else if(two_onepulse) nums <= {4'b0010, nums[11:0]};
                                        else if(three_onepulse) nums <= {4'b0011, nums[11:0]};
                                        else if(four_onepulse) nums <= {4'b0100, nums[11:0]};
                                        else if(five_onepulse) nums <= {4'b0101, nums[11:0]};
                                        else if(six_onepulse) nums <= {4'b0110, nums[11:0]};
                                        else if(seven_onepulse) nums <= {4'b0111, nums[11:0]};
                                        else if(eight_onepulse) nums <= {4'b1000, nums[11:0]};
                                        else if(nine_onepulse) nums <= {4'b1001, nums[11:0]};
                                        else nums <= nums;
                                        amount <= nums[15:12];
                                    end
                                    else begin
                                        if(zero_onepulse) nums <= {nums[15:8], nums[3:0], 4'b0000};
                                        else if(one_onepulse) nums <= {nums[15:8], nums[3:0], 4'b0001};
                                        else if(two_onepulse) nums <= {nums[15:8], nums[3:0], 4'b0010};
                                        else if(three_onepulse) nums <= {nums[15:8], nums[3:0], 4'b0011};
                                        else if(four_onepulse) nums <= {nums[15:8], nums[3:0], 4'b0100};
                                        else if(five_onepulse) nums <= {nums[15:8], nums[3:0], 4'b0101};
                                        else if(six_onepulse) nums <= {nums[15:8], nums[3:0], 4'b0110};
                                        else if(seven_onepulse) nums <= {nums[15:8], nums[3:0], 4'b0111};
                                        else if(eight_onepulse) nums <= {nums[15:8], nums[3:0], 4'b1000};
                                        else if(nine_onepulse) nums <= {nums[15:8], nums[3:0], 4'b1001};
                                        else nums <= nums;
                                        unit_price <= 10 * nums[7:4] + nums[3:0];
                                        if(unit_price >= 0 && unit_price < 10) unit_price_tens_digit <= 0;
                                        else if(unit_price >= 10 && unit_price < 20) unit_price_tens_digit <= 1;
                                        else if(unit_price >= 20 && unit_price < 30) unit_price_tens_digit <= 2;
                                        else if(unit_price >= 30 && unit_price < 40) unit_price_tens_digit <= 3;
                                        else if(unit_price >= 40 && unit_price < 50) unit_price_tens_digit <= 4;
                                        else if(unit_price >= 50 && unit_price < 60) unit_price_tens_digit <= 5;
                                        else if(unit_price >= 60 && unit_price < 70) unit_price_tens_digit <= 6;
                                        else if(unit_price >= 70 && unit_price < 80) unit_price_tens_digit <= 7;
                                        else if(unit_price >= 80 && unit_price < 90) unit_price_tens_digit <= 8;
                                        else if(unit_price >= 90 && unit_price < 100) unit_price_tens_digit <= 9;
                                        unit_price_units_digit <= (unit_price - unit_price_tens_digit - unit_price_tens_digit - unit_price_tens_digit - unit_price_tens_digit - unit_price_tens_digit - unit_price_tens_digit - unit_price_tens_digit - unit_price_tens_digit - unit_price_tens_digit - unit_price_tens_digit);
                                    end 
                                end                                
                            end else begin
                                nums <= nums;
                                amount <= amount;  
                                unit_price <= unit_price;
                            end
                        end
                    end
                end

                PAYMENT: begin
                    if(!have_rst_payment_init) begin
                        nums <= 16'b1010_1010_0000_0000;
                        LED <= 16'b0;
                        money_you_pay <= 10'b0;
                        tens_digit <= 4'b0;
                        units_digit <= 4'b0;
                        have_rst_payment_init <= 1'b1;
                    end
                    else begin
                        units_digit <= next_units_digit;
                        tens_digit <= next_tens_digit;
                        money_you_pay <= ((tens_digit) * 10 + units_digit);
                        nums <= {8'b1010_1010, tens_digit, units_digit};
                        if(money_you_pay >= unit_price && amount != 0)
                            is_money_enough <= 1'b1;
                        else is_money_enough <= 1'b0;
                    end
                end

                BUY: begin
                    if(!flag) begin
                        LED <= 16'b1111_1111_1111_1111;
                        flag <= 1'b1;
                    end
                    else begin
                        if(cnt_on_of == 0 && cnt_clk < 24999999)
                            nums <= {how_many_can_you_buy, 4'b1010, money_you_actually_spend_tens_digit, money_you_actually_spend_units_digit};
                        else begin
                            if(cnt_clk == 24999999) begin
                                if(LED == 16'b1111_1111_1111_1111) begin
                                    LED <= 16'b0;
                                    nums <= 16'b1011_1011_1011_1011;
                                end
                                else begin
                                    LED <= 16'b1111_1111_1111_1111;
                                    nums <= {how_many_can_you_buy, 4'b1010, money_you_actually_spend_tens_digit, money_you_actually_spend_units_digit};
                                end
                            end
                        end
                    end
                end

                CHANGE: begin
                    nums <= {how_many_can_you_buy, 4'b1010, change_money_tens_digit, change_money_units_digit};
                    LED <= 16'b1111_1111_1111_1111;
                end
            endcase
        end
    end

    always @(posedge clk, posedge rst) begin
        if(rst) begin
            how_many_can_you_buy <= 4'b0;
            money_you_actually_spend <= 10'b0;
            money_you_actually_spend_units_digit <= 4'b0;
            money_you_actually_spend_tens_digit <= 4'b0;
            change_money <= 10'b0;
            change_money_tens_digit <= 4'b0;
            change_money_units_digit <= 4'b0;
        end
        else begin
            if(state == BUY) begin
                if((unit_price <= money_you_pay) && (unit_price * 2 > money_you_pay)) begin
                    if(amount >= 1) how_many_can_you_buy <= 4'd1;
                    else how_many_can_you_buy <= amount;
                end
                else if((unit_price * 2 <= money_you_pay) && (unit_price * 3 > money_you_pay)) begin
                    if(amount >= 2) how_many_can_you_buy <= 4'd2;
                    else how_many_can_you_buy <= amount;
                end
                else if((unit_price * 3 <= money_you_pay) && (unit_price * 4 > money_you_pay)) begin
                    if(amount >= 3) how_many_can_you_buy <= 4'd3;
                    else how_many_can_you_buy <= amount;
                end
                else if((unit_price * 4 <= money_you_pay) && (unit_price * 5 > money_you_pay)) begin
                    if(amount >= 4) how_many_can_you_buy <= 4'd4;
                    else how_many_can_you_buy <= amount;
                    end
                else if((unit_price * 5 <= money_you_pay) && (unit_price * 6 > money_you_pay)) begin
                    if(amount >= 5) how_many_can_you_buy <= 4'd5;
                    else how_many_can_you_buy <= amount;
                end
                else if((unit_price * 6 <= money_you_pay) && (unit_price * 7 > money_you_pay)) begin
                    if(amount >= 6) how_many_can_you_buy <= 4'd6;
                    else how_many_can_you_buy <= amount;
                end
                else if((unit_price * 7 <= money_you_pay) && (unit_price * 8 > money_you_pay)) begin
                    if(amount >= 7) how_many_can_you_buy <= 4'd7;
                    else how_many_can_you_buy <= amount;
                end
                else if((unit_price * 8 <= money_you_pay) && (unit_price * 9 > money_you_pay)) begin
                    if(amount >= 8) how_many_can_you_buy <= 4'd8;
                    else how_many_can_you_buy <= amount;
                end
                else if((unit_price * 9 <= money_you_pay) && (unit_price * 10 > money_you_pay)) begin
                    if(amount >= 9) how_many_can_you_buy <= 4'd9;
                    else how_many_can_you_buy <= amount;
                end

                if(how_many_can_you_buy == 4'd1) money_you_actually_spend <= unit_price;
                else if(how_many_can_you_buy == 4'd2) money_you_actually_spend <= (unit_price * 2);
                else if(how_many_can_you_buy == 4'd3) money_you_actually_spend <= (unit_price * 3);
                else if(how_many_can_you_buy == 4'd4) money_you_actually_spend <= (unit_price * 4);
                else if(how_many_can_you_buy == 4'd5) money_you_actually_spend <= (unit_price * 5);
                else if(how_many_can_you_buy == 4'd6) money_you_actually_spend <= (unit_price * 6);        
                else if(how_many_can_you_buy == 4'd7) money_you_actually_spend <= (unit_price * 7);                           
                else if(how_many_can_you_buy == 4'd8) money_you_actually_spend <= (unit_price * 8);  
                else if(how_many_can_you_buy == 4'd9) money_you_actually_spend <= (unit_price * 9);

                
                if(money_you_actually_spend >= 0 && money_you_actually_spend < 10) 
                    money_you_actually_spend_tens_digit <= 4'd0;
                else if(money_you_actually_spend >= 10 && money_you_actually_spend < 20)
                    money_you_actually_spend_tens_digit <= 4'd1;
                else if(money_you_actually_spend >= 20 && money_you_actually_spend < 30)
                    money_you_actually_spend_tens_digit <= 4'd2;
                else if(money_you_actually_spend >= 30 && money_you_actually_spend < 40)
                    money_you_actually_spend_tens_digit <= 4'd3;
                else if(money_you_actually_spend >= 40 && money_you_actually_spend < 50)
                    money_you_actually_spend_tens_digit <= 4'd4;
                else if(money_you_actually_spend >= 50 && money_you_actually_spend < 60)
                    money_you_actually_spend_tens_digit <= 4'd5;
                else if(money_you_actually_spend >= 60 && money_you_actually_spend < 70)
                    money_you_actually_spend_tens_digit <= 4'd6;
                else if(money_you_actually_spend >= 70 && money_you_actually_spend < 80)
                    money_you_actually_spend_tens_digit <= 4'd7;
                else if(money_you_actually_spend >= 80 && money_you_actually_spend < 90)
                    money_you_actually_spend_tens_digit <= 4'd8;
                else if(money_you_actually_spend >= 90 && money_you_actually_spend < 100)
                    money_you_actually_spend_tens_digit <= 4'd9;
                
                money_you_actually_spend_units_digit <= (money_you_actually_spend - money_you_actually_spend_tens_digit - money_you_actually_spend_tens_digit - money_you_actually_spend_tens_digit - money_you_actually_spend_tens_digit - money_you_actually_spend_tens_digit - money_you_actually_spend_tens_digit - money_you_actually_spend_tens_digit - money_you_actually_spend_tens_digit - money_you_actually_spend_tens_digit - money_you_actually_spend_tens_digit);

            end
            else if (state == IDLE) begin
                how_many_can_you_buy <= 4'b0;
                money_you_actually_spend <= 10'b0;
                money_you_actually_spend_units_digit <= 4'b0;
                money_you_actually_spend_tens_digit <= 4'b0;
            end
            else if(state == CHANGE) begin
                if(is_money_enough) change_money <= (money_you_pay - money_you_actually_spend);
                else change_money <= money_you_pay;
                if(change_money >= 0 && change_money < 10) change_money_tens_digit <= 4'd0;
                else if(change_money >= 10 && change_money < 20) change_money_tens_digit <= 4'd1;
                else if(change_money >= 20 && change_money < 30) change_money_tens_digit <= 4'd2;
                else if(change_money >= 30 && change_money < 40) change_money_tens_digit <= 4'd3;
                else if(change_money >= 40 && change_money < 50) change_money_tens_digit <= 4'd4;
                else if(change_money >= 50 && change_money < 60) change_money_tens_digit <= 4'd5;
                else if(change_money >= 60 && change_money < 70) change_money_tens_digit <= 4'd6;
                else if(change_money >= 70 && change_money < 80) change_money_tens_digit <= 4'd7;
                else if(change_money >= 80 && change_money < 90) change_money_tens_digit <= 4'd8;
                else if(change_money >= 90 && change_money < 100) change_money_tens_digit <= 4'd9;
                change_money_units_digit <= (change_money - change_money_tens_digit - change_money_tens_digit - change_money_tens_digit - change_money_tens_digit - change_money_tens_digit - change_money_tens_digit - change_money_tens_digit - change_money_tens_digit - change_money_tens_digit - change_money_tens_digit);
            end
            else begin
                how_many_can_you_buy <= how_many_can_you_buy;
                money_you_actually_spend <= money_you_actually_spend;
                money_you_actually_spend_tens_digit <= money_you_actually_spend_tens_digit;
                money_you_actually_spend_units_digit <= money_you_actually_spend_units_digit;
                change_money <= change_money;
                change_money_tens_digit <= change_money_tens_digit;
                change_money_units_digit <= change_money_units_digit;
            end
        end  
    end

    always @(posedge clk, posedge rst) begin
        if(rst) begin
            cnt_clk <= 28'b0;
            cnt_on_of <= 3'b0;
        end 
        else begin
            if(state == BUY) begin
                cnt_clk <= next_cnt_clk;
                cnt_on_of <= next_cnt_on_of;
            end
            else if(state == CHANGE) begin
                cnt_clk <= next_cnt_clk;
            end
            else begin
                cnt_clk <= 0;
                cnt_on_of <= 0;            
            end
        end
    end

    always @(posedge clk, posedge rst) begin
        if(rst) begin
            next_cnt_clk <= 28'b0;
            next_cnt_on_of <= 3'b0;
        end 
        else begin
            if(state == BUY) begin
                if(next_cnt_clk != 28'd24999999)
                    next_cnt_clk <= cnt_clk + 1;
                else begin
                    next_cnt_clk <= 0;
                    if(next_cnt_on_of != 3'd6)
                        next_cnt_on_of <= cnt_on_of + 1;
                    else begin
                        next_cnt_on_of <= 0;
                        next_cnt_clk <= 0;
                    end
                end
            end
            else if(state == CHANGE) begin
                if(next_cnt_clk != 28'd149999999) begin
                    next_cnt_clk <= cnt_clk + 1;
                end
                else next_cnt_clk <= 0;
            end
            else begin
                next_cnt_on_of <= 0;
                next_cnt_clk <= 0;
            end
        end
    end

    always @(posedge clk, posedge rst) begin
        if(rst) begin
            next_tens_digit <= 0;
            next_units_digit <= 0;
        end else begin
            if(state == PAYMENT) begin
                if(((key_decode | key_down) == key_decode)) begin
                    if(key_num != 4'b1111) begin
                        if(zero_onepulse) begin
                            next_tens_digit <= 4'b0;
                            next_units_digit <= 4'b0;
                        end
                        else if(one_onepulse) begin
                            if(next_tens_digit == 9 && next_units_digit == 9) begin
                                next_tens_digit <= tens_digit;
                                next_units_digit <= units_digit;
                            end
                            else begin
                                if(next_units_digit != 9) begin
                                    next_units_digit <= units_digit + 1;
                                    next_tens_digit <= tens_digit;
                                end
                                else begin
                                    next_units_digit <= 0;
                                    next_tens_digit <= tens_digit + 1;
                                end
                            end
                        end
                        else if(two_onepulse) begin
                            if(next_tens_digit == 9 && next_units_digit >= 4) begin
                                next_tens_digit <= tens_digit;
                                next_units_digit <= 9;
                            end 
                            else begin
                                if(next_units_digit < 4) begin
                                    next_tens_digit <= tens_digit;
                                    next_units_digit <= units_digit + 5;
                                end
                                else if(next_units_digit == 5) begin
                                    next_tens_digit <= tens_digit + 1;
                                    next_units_digit <= 0;
                                end
                                else if(next_units_digit == 6) begin
                                    next_tens_digit <= tens_digit + 1;
                                    next_units_digit <= 1;
                                end
                                else if(next_units_digit == 7) begin
                                    next_tens_digit <= tens_digit + 1;
                                    next_units_digit <= 2;
                                end
                                else if(next_units_digit == 8) begin
                                    next_tens_digit <= tens_digit + 1;
                                    next_units_digit <= 3;
                                end
                                else if(next_units_digit == 9) begin
                                    next_tens_digit <= tens_digit + 1;
                                    next_units_digit <= 4;
                                end
                            end
                        end        
                        else if(three_onepulse) begin
                            if((next_tens_digit == 8 && next_units_digit == 9) || next_tens_digit == 9) begin
                                next_tens_digit <= 9;
                                next_units_digit <= 9;
                            end
                            else begin
                                next_tens_digit <= tens_digit + 1;
                                next_units_digit <= units_digit;
                            end
                        end
                        else if(four_onepulse) begin
                            if((next_tens_digit == 4 && next_units_digit == 9) || next_tens_digit >= 5) begin
                                next_tens_digit <= 9;
                                next_units_digit <= 9;
                            end
                            else begin
                                next_tens_digit <= tens_digit + 5;
                                next_units_digit <= units_digit;
                            end           
                        end
                    end 
                    else begin
                        next_units_digit <= units_digit;
                        next_tens_digit <= tens_digit;
                    end
                end
            end
            else if(state == IDLE) begin
                next_units_digit <= 0;
                next_tens_digit <= 0; 
            end
            else begin
                next_units_digit <= units_digit;
                next_tens_digit <= tens_digit;
            end
        end
    end

    always @* begin
		case (last_change)
			KEY_CODES[00] : key_num = 4'b0000;
			KEY_CODES[01] : key_num = 4'b0001;
			KEY_CODES[02] : key_num = 4'b0010;
			KEY_CODES[03] : key_num = 4'b0011;
			KEY_CODES[04] : key_num = 4'b0100;
			KEY_CODES[05] : key_num = 4'b0101;
			KEY_CODES[06] : key_num = 4'b0110;
			KEY_CODES[07] : key_num = 4'b0111;
			KEY_CODES[08] : key_num = 4'b1000;
			KEY_CODES[09] : key_num = 4'b1001;
			KEY_CODES[10] : key_num = 4'b0000;
			KEY_CODES[11] : key_num = 4'b0001;
			KEY_CODES[12] : key_num = 4'b0010;
			KEY_CODES[13] : key_num = 4'b0011;
			KEY_CODES[14] : key_num = 4'b0100;
			KEY_CODES[15] : key_num = 4'b0101;
			KEY_CODES[16] : key_num = 4'b0110;
			KEY_CODES[17] : key_num = 4'b0111;
			KEY_CODES[18] : key_num = 4'b1000;
			KEY_CODES[19] : key_num = 4'b1001;
			default		  : key_num = 4'b1111;
		endcase
	end
endmodule