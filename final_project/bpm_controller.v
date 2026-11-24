module bpm_controller #(
    parameter BPM = 60
)(
    input clk,
    input rst,
    input restart,
    output beat_tick
);
    localparam integer BEAT_CYCLES = (64'd3000000000 / BPM) * 2;
    localparam integer COUNT_WIDTH = (BEAT_CYCLES > 1) ? $clog2(BEAT_CYCLES) : 1;
    localparam [COUNT_WIDTH-1:0] LAST_CYCLE = BEAT_CYCLES - 1;

    reg [COUNT_WIDTH-1:0] counter;
    assign beat_tick = !restart && counter == LAST_CYCLE;

    always @(posedge clk or posedge rst) begin
        if (rst)
            counter <= 0;
        else if (restart || beat_tick)
            counter <= 0;
        else
            counter <= counter + 1'b1;
    end
endmodule
