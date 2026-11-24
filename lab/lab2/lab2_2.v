module Encoder (
    input clk, 
    input rst_n, 
    input [3:0] max, 
    input [3:0] min, 
    input in_valid, 
    input [1:0] mode, 
    input [7:0] in_data, 
    output reg [11:0] out_data, 
    output reg [2:0] state, 
    output wire [3:0] counter_out,
    output wire direction
);

reg [2:0] nxt_state;
reg [3:0] offset_cnt, next_offset_cnt = 4'b0;
reg [11:0] output_tmp [7:0];
reg [11:0] next_output_tmp [7:0];
reg [2:0] x = 3'b000;
reg [7:0] record = 8'b0, store;

parameter INIT = 3'd0;
parameter GET_DATA = 3'd1;
parameter ENCRYPT_DATA = 3'd2;
parameter OUTPUT_DATA = 3'd3;


wire flip, enable;

assign flip = (mode == 2'b01)? 1'b1 : 1'b0;
assign enable = (mode == 2'b10)? 1'b0 : 1'b1;

Parameterized_Ping_Pong_Counter pppc(.clk(clk), .rst_n(rst_n), .enable(enable), .max(max), .min(min), .flip(flip), .direction(direction), .out(counter_out));

always@(posedge clk)begin
    if(!rst_n) begin
        state = INIT;
    end
    else begin
        state = nxt_state;
    end
end
always @* begin
    nxt_state = state;
    case (state)
        INIT: begin
            x = 3'd0;
            if(in_valid) nxt_state = GET_DATA;
            else nxt_state = INIT;
        end
        GET_DATA: begin
            if(!in_valid && mode == 2'b10) nxt_state = ENCRYPT_DATA;
            else nxt_state = GET_DATA;
        end
        ENCRYPT_DATA: begin
            if(offset_cnt == 4'd7)
                nxt_state = OUTPUT_DATA;
            else nxt_state = ENCRYPT_DATA;      
        end
        OUTPUT_DATA: begin
            if(offset_cnt == 4'd7)
                nxt_state = INIT;
            else nxt_state = OUTPUT_DATA;
        end
    endcase
end

always @(posedge clk) begin
    if(!rst_n) offset_cnt = 4'b0;
    else offset_cnt = next_offset_cnt;
end
always @(posedge clk) begin
    if((state == ENCRYPT_DATA || state == OUTPUT_DATA || state == GET_DATA)) begin
        if(next_offset_cnt != 4'b0111) next_offset_cnt = next_offset_cnt + 1;
        else next_offset_cnt = 4'b0;
    end
    else next_offset_cnt = 0;
end

always @(posedge clk) begin
    if(!rst_n) begin
        output_tmp[0] = 12'b0;
    end
    else begin
        output_tmp[offset_cnt] = next_output_tmp[offset_cnt];
    end
end

always @(posedge clk) begin
    case(state)
        GET_DATA: begin
            if(in_valid) begin
                next_output_tmp[offset_cnt][0] <= 0;
                next_output_tmp[offset_cnt][1] <= 0;
                next_output_tmp[offset_cnt][2] <= in_data[0];
                next_output_tmp[offset_cnt][3] <= 0;
                next_output_tmp[offset_cnt][4] <= in_data[1];
                next_output_tmp[offset_cnt][5] <= in_data[2];
                next_output_tmp[offset_cnt][6] <= in_data[3];
                next_output_tmp[offset_cnt][7] <= 0;
                next_output_tmp[offset_cnt][8] <= in_data[4];
                next_output_tmp[offset_cnt][9] <= in_data[5];
                next_output_tmp[offset_cnt][10] <= in_data[6];
                next_output_tmp[offset_cnt][11] <= in_data[7];
            end
            else begin
                next_output_tmp[offset_cnt] <= output_tmp[offset_cnt];
            end
        end
        ENCRYPT_DATA: begin
            store = {next_output_tmp[offset_cnt][11], next_output_tmp[offset_cnt][10], next_output_tmp[offset_cnt][9], next_output_tmp[offset_cnt][8]
            ,next_output_tmp[offset_cnt][6], next_output_tmp[offset_cnt][5], next_output_tmp[offset_cnt][4], next_output_tmp[offset_cnt][2]};
            record = (store + counter_out) % 256;
            next_output_tmp[offset_cnt][2] = record[0];
            next_output_tmp[offset_cnt][4] = record[1];
            next_output_tmp[(offset_cnt)][5] = record[2];
            next_output_tmp[(offset_cnt)][6] = record[3];
            next_output_tmp[(offset_cnt)][8] = record[4];
            next_output_tmp[(offset_cnt)][9] = record[5];
            next_output_tmp[(offset_cnt)][10] = record[6];
            next_output_tmp[(offset_cnt)][11] = record[7];
            next_output_tmp[(offset_cnt)][0] = (next_output_tmp[(offset_cnt)][2] ^ next_output_tmp[(offset_cnt)][4] ^ next_output_tmp[(offset_cnt)][6] ^ next_output_tmp[(offset_cnt)][8] ^ next_output_tmp[(offset_cnt)][10]);
            next_output_tmp[(offset_cnt)][1] = (next_output_tmp[(offset_cnt)][2] ^ next_output_tmp[(offset_cnt)][5] ^ next_output_tmp[(offset_cnt)][6] ^ next_output_tmp[(offset_cnt)][9] ^ next_output_tmp[(offset_cnt)][10]);
            next_output_tmp[(offset_cnt)][3] = (next_output_tmp[(offset_cnt)][4] ^ next_output_tmp[(offset_cnt)][5] ^ next_output_tmp[(offset_cnt)][6] ^ next_output_tmp[(offset_cnt)][11]);
            next_output_tmp[(offset_cnt)][7] = (next_output_tmp[(offset_cnt)][8] ^ next_output_tmp[(offset_cnt)][9] ^ next_output_tmp[(offset_cnt)][10] ^ next_output_tmp[(offset_cnt)][11]);
            
        end
        default:
            next_output_tmp[offset_cnt] = output_tmp[offset_cnt];
    endcase
    
end

always @(posedge clk) begin
    if (!rst_n) begin
        out_data = 12'b0;
    end
    else begin
        
        if(state == OUTPUT_DATA) begin
            out_data = output_tmp[x];
            if(x != 3'd7) x = x + 1;
            else x = 0;
        end
        else out_data = 12'd0;
    end
end
endmodule
