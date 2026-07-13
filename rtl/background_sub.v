module background_sub(
    input clk,
    input ce,
    input [7:0] current_pixel,
    input [7:0] background_pixel,
    input [7:0] threshold,
    output reg is_motion
);
    reg [7:0] diff;
    always @(posedge clk) begin
     if (ce) begin
        if (current_pixel > background_pixel) diff <= current_pixel - background_pixel;
        else diff <= background_pixel - current_pixel;
        is_motion <= (diff > threshold) ? 1'b1 : 1'b0;
    end
    end
endmodule