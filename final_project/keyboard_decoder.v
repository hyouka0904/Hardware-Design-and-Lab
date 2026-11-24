module KeyboardDecoder(
    input rst,
    input clk,
    inout PS2_DATA,
    inout PS2_CLK,
    output reg [9:0] key_down,
    output reg [8:0] last_change,
    output reg key_valid
);
    wire [7:0] key_in;
    wire is_extend, is_break, valid, err;
    wire [8:0] scan_code = {is_extend, key_in};
    reg [3:0] key_index;

    KeyboardCtrl controller(
        .key_in(key_in), .is_extend(is_extend), .is_break(is_break),
        .valid(valid), .err(err), .PS2_DATA(PS2_DATA), .PS2_CLK(PS2_CLK),
        .rst(rst), .clk(clk)
    );

    always @* begin
        case (scan_code)
            9'h01d: key_index = 4'd0; // W
            9'h01c: key_index = 4'd1; // A
            9'h01b: key_index = 4'd2; // S
            9'h023: key_index = 4'd3; // D
            9'h175: key_index = 4'd4; // Up
            9'h16b: key_index = 4'd5; // Left
            9'h172: key_index = 4'd6; // Down
            9'h174: key_index = 4'd7; // Right
            9'h05a: key_index = 4'd8; // Enter
            default: key_index = 4'd9;
        endcase
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            key_down <= 10'd0;
            last_change <= 9'd0;
            key_valid <= 1'b0;
        end else begin
            key_valid <= 1'b0;
            if (err) begin
                key_down <= 10'd0;
            end else if (valid && key_index < 4'd9) begin
                key_down[key_index] <= !is_break;
                last_change <= scan_code;
                key_valid <= 1'b1;
            end
        end
    end
endmodule
