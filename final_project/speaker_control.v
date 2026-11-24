module speaker_control(
    input clk,
    input rst,
    input [15:0] audio_in_left,
    input [15:0] audio_in_right,
    output audio_mclk,
    output audio_lrck,
    output audio_sck,
    output reg audio_sdin
);
    reg [8:0] clock_count;
    reg [15:0] audio_left, audio_right;
    wire [4:0] slot = clock_count[8:4];
    wire [3:0] bit_index = 4'd0 - slot[3:0];

    assign audio_mclk = clock_count[1];
    assign audio_lrck = clock_count[8];
    assign audio_sck = 1'b1; // Codec internal serial clock mode.

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            clock_count <= 9'd0;
            audio_left <= 16'd0;
            audio_right <= 16'd0;
        end else begin
            clock_count <= clock_count + 1'b1;
            // Load both channels as slot 1 begins, after the prior right LSB.
            if (clock_count == 9'd15) begin
                audio_left <= audio_in_left;
                audio_right <= audio_in_right;
            end
        end
    end

    always @* begin
        // In I2S the WS transition precedes the next channel MSB by one slot.
        case (slot)
            5'd0:  audio_sdin = audio_right[0];
            5'd16: audio_sdin = audio_left[0];
            default: audio_sdin = slot[4] ? audio_right[bit_index] : audio_left[bit_index];
        endcase
    end
endmodule
