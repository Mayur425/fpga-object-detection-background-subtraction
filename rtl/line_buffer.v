module line_buffer #(parameter WIDTH = 160)(
    input clk,
    input ce,
    input [7:0] data_in,
    output [7:0] tap0, tap1, tap2
);
    reg [7:0] mem1 [0:WIDTH-1];
    reg [7:0] mem2 [0:WIDTH-1];
    assign tap0 = data_in;
    assign tap1 = mem1[WIDTH-1];
    assign tap2 = mem2[WIDTH-1];
    integer i;
    always @(posedge clk) begin
      if (ce) begin
        for (i = WIDTH-1; i > 0; i = i - 1) begin
            mem1[i] <= mem1[i-1];
            mem2[i] <= mem2[i-1];
        end
        mem1[0] <= tap0;
        mem2[0] <= tap1;
    end
    end
endmodule