// sonic_top is the module to interface with sonic sensors
// clk = 100MHz
// <Trig> and <Echo> should connect to the sensor
// <distance> is the output distance in cm
module sonic_top(
    input clk, 
    input rst, 
    input Echo,
    output Trig, 
    output [19:0] distance, 
    output [15:0] _led, 
    output _en_left, 
    output _en_right, 
    input _start_move, 
    input _start_left_move, 
    input _start_right_move
);

	wire[19:0] dis;
    wire clk1M;
	wire clk_2_17;

    assign distance = dis;

    div clk1(clk ,clk1M);
	TrigSignal u1(.clk(clk), .rst(rst), .trig(Trig));
	PosCounter u2(
        .clk(clk1M), 
        .rst(rst), 
        .echo(Echo), 
        .distance_count(dis), 
        .led(_led), 
        .en_left(_en_left), 
        .en_right(_en_right), 
        .start_move(_start_move),
        .start_left_move(_start_left_move),
        .start_right_move(_start_right_move)
    );

endmodule

module PosCounter(clk, rst, echo, distance_count, led, en_left, en_right, start_move, start_left_move, start_right_move); 
    input clk, rst, echo;
    output[19:0] distance_count;
    output [15:0] led;
    output en_left, en_right;
    input start_move, start_left_move, start_right_move;

    parameter S0 = 2'b00;
    parameter S1 = 2'b01; 
    parameter S2 = 2'b10;
    
    wire start, finish;
    reg[1:0] curr_state, next_state;
    reg echo_reg1, echo_reg2;
    reg[19:0] count, distance_register;
    wire[19:0] distance_count; 
    wire en;

    always@(posedge clk) begin
        if(rst) begin
            echo_reg1 <= 0;
            echo_reg2 <= 0;
            count <= 0;
            distance_register  <= 0;
            curr_state <= S0;
        end
        else begin
            echo_reg1 <= echo;   
            echo_reg2 <= echo_reg1; 
            case(curr_state)
                S0:begin
                    if (start) curr_state <= next_state; //S1
                    else count <= 0;
                end
                S1:begin
                    if (finish) curr_state <= next_state; //S2
                    else count <= count + 1;
                end
                S2:begin
                    distance_register <= count;
                    count <= 0;
                    curr_state <= next_state; //S0
                end
            endcase
        end
    end

    always @(*) begin
        case(curr_state)
            S0:next_state = S1;
            S1:next_state = S2;
            S2:next_state = S0;
            default:next_state = S0;
        endcase
    end

    assign start = echo_reg1 & ~echo_reg2;  
    assign finish = ~echo_reg1 & echo_reg2;

    // TODO: trace the code and calculate the distance, output it to <distance_count>
    assign distance_count = (17 * distance_register) / 1024 ;
    assign led = (distance_count >= 0 && distance_count < 5) ? 16'b0000_0000_0000_0001:
                 (distance_count >= 5 && distance_count < 10) ? 16'b0000_0000_0000_0011:
                 (distance_count >= 10 && distance_count < 15) ? 16'b0000_0000_0000_0111:
                 (distance_count >= 15 && distance_count < 20) ? 16'b0000_0000_0000_1111:
                 (distance_count >= 20 && distance_count < 25) ? 16'b0000_0000_0001_1111:
                 (distance_count >= 25 && distance_count < 30) ? 16'b0000_0000_0011_1111:
                 (distance_count >= 30 && distance_count < 35) ? 16'b0000_0000_0111_1111:
                 (distance_count >= 35 && distance_count < 40) ? 16'b0000_0000_1111_1111:
                 (distance_count >= 40 && distance_count < 45) ? 16'b0000_0001_1111_1111:
                 (distance_count >= 45 && distance_count < 50) ? 16'b0000_0011_1111_1111 :
                 (distance_count >= 50 && distance_count < 55) ? 16'b0000_0111_1111_1111 :
                 (distance_count >= 55 && distance_count < 60) ? 16'b0000_1111_1111_1111 :
                 (distance_count >= 60 && distance_count < 65) ? 16'b0001_1111_1111_1111 :
                 (distance_count >= 65 && distance_count < 70) ? 16'b0011_1111_1111_1111 :
                 (distance_count >= 70 && distance_count < 75) ? 16'b0111_1111_1111_1111 : 16'b1111_1111_1111_1111;
    assign en_left = (distance_count <= 30 || (!start_move && !start_left_move)) ? 0 : 1;
    assign en_right = (distance_count <= 30 || (!start_move && !start_right_move)) ? 0 : 1;
endmodule

// send trigger signal to sensor
module TrigSignal(clk, rst, trig);
    input clk, rst;
    output trig;

    reg trig, next_trig;
    reg[23:0] count, next_count;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            count <= 0;
            trig <= 0;
        end
        else begin
            //count <= next_count;
            trig <= next_trig;
            if(count <= 24'd10000999) count <= next_count;
            else count <= 0;
        end
    end

    // count 10us to set <trig> high and wait for 100ms, then set <trig> back to low
    always @(*) begin
        //next_trig = trig;
        next_count = count + 1;   
        // TODO: set <next_trig> and <next_count> to let the sensor work properly
        
        if(count >= 0 && count <= 999) begin
            next_trig = 1;
        end else next_trig = 0;
    end
endmodule

// clock divider for T = 1us clock
module div(clk ,out_clk);
    input clk;
    output out_clk;
    reg out_clk;
    reg [6:0]cnt;
    
    always @(posedge clk) begin   
        if(cnt < 7'd50) begin
            cnt <= cnt + 1'b1;
            out_clk <= 1'b1;
        end 
        else if(cnt < 7'd100) begin
	        cnt <= cnt + 1'b1;
	        out_clk <= 1'b0;
        end
        else if(cnt == 7'd100) begin
            cnt <= 0;
            out_clk <= 1'b1;
        end
    end
endmodule