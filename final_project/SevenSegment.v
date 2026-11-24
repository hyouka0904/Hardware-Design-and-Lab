module T(
    input clk,
    input rst,
    input game_clear,
    input game_fail,
    input select,
    output wire [6:0] DISPLAY,
    output wire [3:0] DIGIT
);

    reg [3:0] minute = 4'b0, second_TensDigit = 4'b0, second_UnitsDigit = 4'b0;
    reg [26:0] cnt = 27'd0;

    SevenSegment S(
        .clk(clk),
        .rst(rst),
        .nums({minute, 4'b1011, second_TensDigit, second_UnitsDigit}),
        .display(DISPLAY),
        .digit(DIGIT)
    );

    always @(posedge clk, posedge rst) begin
        if(rst) begin
            minute <= 0;
            second_TensDigit <= 0;
            second_UnitsDigit <= 0;
            cnt <= 0;
        end else begin
            if(!select) begin
                minute <= 0;
                second_TensDigit <= 0;
                second_UnitsDigit <= 0;
                cnt <= 0;
            end else if(game_clear || game_fail) begin
                minute <= minute;
                second_TensDigit <= second_TensDigit;
                second_UnitsDigit <= second_UnitsDigit;
                cnt <= 0;
            end
            else begin
                if(cnt < 27'd99999999) begin
                    cnt <= cnt + 1;
                end
                else begin
                    if(second_TensDigit == 4'd5 && second_UnitsDigit == 4'd9) begin
                        if(minute == 4'd9) begin
                            second_TensDigit <= 4'd5;
                            second_UnitsDigit <= 4'd9;
                            minute <= minute;
                            cnt <= 0;
                        end
                        else begin
                            second_TensDigit <= 0;
                            second_UnitsDigit <= 0;
                            minute <= minute + 1;
                            cnt <= 0;
                        end
                    end
                    else if(second_TensDigit != 4'd5 && second_UnitsDigit == 4'd9) begin
                        second_UnitsDigit <= 0;
                        second_TensDigit <= second_TensDigit + 1;
                        minute <= minute;
                        cnt <= 0;
                    end
                    else begin
                        second_UnitsDigit <= second_UnitsDigit + 1;
                        second_TensDigit <= second_TensDigit;
                        minute <= minute;
                        cnt <= 0;
                    end
                end
            end
        end
    end


endmodule

module SevenSegment(
    output reg [6:0] display,
    output reg [3:0] digit,
    input wire [15:0] nums,
    input wire rst,
    input wire clk
);

    reg [15:0] clk_divider;
    reg [3:0] display_num;

    always @ (posedge clk, posedge rst) begin
        if (rst) begin
            clk_divider <= 16'd0;
        end else begin
            clk_divider <= clk_divider + 1'b1;
        end
    end

    always @ (posedge clk, posedge rst) begin
        if (rst) begin
            display_num <= 4'b0000;
            digit <= 4'b1111;
        end else if (clk_divider == 16'h7fff) begin
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
    end

    always @ (*) begin
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
            10: display = 7'b0111111;   //minus
            11: display = 7'b0111111;
            default : display = 7'b1111111;
        endcase
    end

endmodule
