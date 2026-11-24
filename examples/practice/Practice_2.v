`timescale 1ns/1ps
module FSM_Practice(
    input clk, 
    input rst_n, 
    input [5:0] in_data, 
    input in_valid, 
    output reg [5:0] out_data, 
    output reg [2:0] state, 
    output reg [3:0] offset_cnt
);

parameter INIT = 3'd0;
parameter GET_DATA = 3'd1;
parameter PROCESS_DATA = 3'd2;
parameter OUTPUT_DATA = 3'd3;

reg [2:0] next_state;
reg [3:0] next_offset_cnt; // counter that helps countrol the state transition
reg [5:0] output_tmp [7:0], next_output_tmp [7:0];

/* state transition */
always@(posedge clk)begin
    if(!rst_n) begin
        state <= INIT;
    end
    else begin
        state <= next_state;
    end
end
always@(*) begin
    case(state)
    INIT: begin
        if(in_valid) next_state = GET_DATA;
        else next_state = INIT;
    end
    GET_DATA: begin
        /* determine the next state */
    end
    PROCESS_DATA: begin
        if(offset_cnt == 4'd7) next_state = OUTPUT_DATA;
        else next_state = PROCESS_DATA;
    end
    OUTPUT_DATA: begin
        /* determine the next state */
    end
    default: begin
        next_state = state;
    end
    endcase
end

/* offset_cnt */
always@(posedge clk) begin
    if (!rst_n) begin
        offset_cnt <= 4'd0;
    end
    else begin
        offset_cnt <= next_offset_cnt;
    end
end
/* determine the next_offset_cnt value base on the current state */
always@(*) begin
    case(state)
    INIT:
    GET_DATA:
    PROCESS_DATA: 
    OUTPUT_DATA:
    default: begin
        next_offset_cnt = offset_cnt;
    end
    endcase
end

/* output_tmp */
always@(posedge clk) begin
    if(!rst_n) begin
        output_tmp[0] <= 6'b0;
    end
    else begin
        output_tmp[offset_cnt] <= next_output_tmp[offset_cnt];
    end
end
/* determine the next_output_tmp value base on the current state */
/* You can store the in_data in the next_output_tmp (by using the value of offset_cnt reg)
    and then process these data in the PROCESS_DATA state */
always@(*) begin
    case(state)
    INIT: begin
        if(in_valid) 
        else 
    end
    GET_DATA: begin
        if(in_valid) 
        else 
    end
    PROCESS_DATA: begin
    end
    default: begin
        next_output_tmp[offset_cnt] = output_tmp[offset_cnt];
    end
    endcase
end
/* output data */
always @(posedge clk) begin
    if (!rst_n) begin
        out_data <= 6'b0;
    end
    else begin
        /* determine the value of out_data under different circumstances */
    end
end

endmodule