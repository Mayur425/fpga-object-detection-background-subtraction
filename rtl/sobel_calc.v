module sobel_calc(
    input clk,
    input ce,
    input [7:0] row0_in, row1_in, row2_in,
    input [10:0] threshold,
    output reg [7:0] edge_out
);
    reg [7:0] p00, p01, p02, p10, p11, p12, p20, p21, p22;
    reg [11:0] gx, gy, abs_gx, abs_gy, abs_g;
    always @(posedge clk) begin
      if (ce) begin
        p02 <= p01; p01 <= p00; p00 <= row0_in;
        p12 <= p11; p11 <= p10; p10 <= row1_in;
        p22 <= p21; p21 <= p20; p20 <= row2_in;

        gx <= (p00 + (p10<<1) + p20) - (p02 + (p12<<1) + p22);
        gy <= (p00 + (p01<<1) + p02) - (p20 + (p21<<1) + p22);

        abs_gx <= (gx[11]) ? (~gx + 1'b1) : gx;
        abs_gy <= (gy[11]) ? (~gy + 1'b1) : gy;
        abs_g  <= abs_gx + abs_gy;

        edge_out <= (abs_g > threshold) ? 8'hFF : 8'h00;
    end
    end
endmodule