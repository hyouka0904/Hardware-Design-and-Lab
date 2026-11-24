module clock_divider(
    input clk,
    input rst,
    output pixel_tick
);
    reg [1:0] counter;

    always @(posedge clk) begin
        if (rst)
            counter <= 2'd0;
        else
            counter <= counter + 1'b1;
    end

    assign pixel_tick = !rst && counter == 2'd3;
endmodule
