module player_control #(
    parameter LEN = 14656
)(
    input clk,
    input rst,
    input en,
    input beat_tick,
    output reg [13:0] ibeat
);
    localparam [13:0] LAST_BEAT = LEN - 1;

    always @(posedge clk or posedge rst) begin
        if (rst)
            ibeat <= 14'd0;
        else if (!en)
            ibeat <= 14'd0;
        else if (beat_tick)
            ibeat <= (ibeat == LAST_BEAT) ? 14'd0 : ibeat + 1'b1;
    end
endmodule
