// This module take "mode" input and control two motors accordingly.
// clk should be 100MHz for PWM_gen module to work correctly.
// You can modify / add more inputs and outputs by yourself.
module motor(
    input clk,
    input rst,
    input [1:0]mode,
    input en_left,
    input en_right,
    input [1:0]pre_mode,
    input out_of_control,
    output [1:0]pwm,
    output [1:0]r_IN,
    output [1:0]l_IN
);

    reg [9:0]left_motor, right_motor;
    wire left_pwm, right_pwm;
    wire [9:0] left_duty, right_duty;
    motor_pwm m0(
        .clk(clk), 
        .reset(rst), 
        .duty(700),
        .pmod_1(left_pwm), 
        .en((en_left && mode[1]))
    );
    motor_pwm m1(
        .clk(clk), 
        .reset(rst), 
        .duty(700), 
        .pmod_1(right_pwm), 
        .en((en_right && mode[0]))
    );

    assign pwm = {left_pwm,right_pwm};
    assign r_IN = (out_of_control) ? 2'b01 : 2'b10;
    assign l_IN = (out_of_control) ? 2'b01 : 2'b10;
    //assign r_IN = 2'b10;
    //assign l_IN = 2'b10;
    // TODO: trace the rest of motor.v and control the speed and direction of the two motors
    

endmodule

module motor_pwm (
    input clk,
    input reset,
    input [9:0] duty,
	output pmod_1, //PWM
    input en
);
        
    PWM_gen pwm_0 (
        .clk(clk), 
        .reset(reset), 
        .freq(32'd25000),
        .duty(duty), 
        .PWM(pmod_1),
        .en(en)
    );

endmodule

//generte PWM by input frequency & duty cycle
module PWM_gen(
    input wire clk,
    input wire reset,
	input [31:0] freq,
    input [9:0] duty,
    output reg PWM,
    input en
);
    wire [31:0] count_max = 100_000_000 / freq;
    wire [31:0] count_duty = count_max * duty / 1024;
    reg [31:0] count;
        
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            count <= 0;
            PWM <= 0;
        end else if (count < count_max) begin
            count <= count + 1;
            // TODO: set <PWM> accordingly
            if(count < count_duty && en) begin
                PWM <= 1;
            end
            else PWM <= 0;
        end else begin
            count <= 0;
            PWM <= 0;
        end
    end
endmodule

