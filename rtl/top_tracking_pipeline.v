module top_tracking_pipeline(
    input clk,
    input ce,
    input [7:0] current_pixel,
    input [7:0] background_pixel,
    input [7:0] sub_threshold,
    input [10:0] sobel_threshold,
    output [7:0] final_edge_out,
    output [7:0] box_min_x,
    output [7:0] box_max_x,
    output [6:0] box_min_y,
    output [6:0] box_max_y
   
);
    wire is_motion_bit;
    wire [7:0] motion_8bit, tap0, tap1, tap2;

    background_sub U_SUB (.clk(clk), .ce(ce), .current_pixel(current_pixel), .background_pixel(background_pixel), 
                         .threshold(sub_threshold), .is_motion(is_motion_bit));
    
    assign motion_8bit = is_motion_bit ? 8'hFF : 8'h00;

    // CHANGE THIS BLOCK IN YOUR TOP FILE
    line_buffer #(.WIDTH(160)) U_BUF (
        .clk(clk), 
        .ce(ce),
        .data_in(current_pixel), // <-- CHANGE THIS from 'motion_8bit' to 'current_pixel'
        .tap0(tap0), 
        .tap1(tap1), 
        .tap2(tap2)
    );

    sobel_calc U_SOB (.clk(clk), .ce(ce),  .row0_in(tap2), .row1_in(tap1), .row2_in(tap0), 
                     .threshold(sobel_threshold), .edge_out(final_edge_out));

    tracker_box #(.WIDTH(160), .HEIGHT(120)) U_TRK (
        .clk(clk), 
        .ce(ce), // <-- MAKE SURE THIS LINE IS HERE
        .edge_pixel(final_edge_out), 
        .box_min_x(box_min_x), 
        .box_max_x(box_max_x), 
        .box_min_y(box_min_y), 
        .box_max_y(box_max_y)
    );
endmodule
