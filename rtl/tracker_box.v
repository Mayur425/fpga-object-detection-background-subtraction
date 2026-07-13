module tracker_box #(parameter WIDTH = 160, parameter HEIGHT = 120)(
    input clk,
    input ce, // <-- Added Clock Enable Port
    input [7:0] edge_pixel,
    output reg [7:0] box_min_x, box_max_x,
    output reg [6:0] box_min_y, box_max_y
);

    reg [7:0] x_c = 0;
    reg [6:0] y_c = 0;
    reg [7:0] mn_x = 255; reg [7:0] mx_x = 0;
    reg [6:0] mn_y = 127; reg [6:0] mx_y = 0;

    // Gated Pipeline Delay: 2 rows (320 pixels) + 3 Sobel calculation steps = 323
    reg [9:0] pixel_delay_count = 0;
    reg pipeline_ready = 0;

    always @(posedge clk) begin
        if (ce) begin // <-- GATES THE ENTIRE TRACKER TO PIXEL RATE
            if (!pipeline_ready) begin
                if (pixel_delay_count == 323) begin
                    pipeline_ready <= 1;
                end else begin
                    pixel_delay_count <= pixel_delay_count + 1;
                end
            end 
            else begin
                // 1. ACTIVE TRACKING LOGIC
                if (edge_pixel == 8'hFF) begin
                    if (x_c < mn_x) mn_x <= x_c;
                    if (x_c > mx_x) mx_x <= x_c;
                    if (y_c < mn_y) mn_y <= y_c;
                    if (y_c > mx_y) mx_y <= y_c;
                end

                // 2. TIMING & FRAME RESET LOGIC
                if (x_c == WIDTH - 1) begin
                    x_c <= 0;
                    if (y_c == HEIGHT - 1) begin
                        y_c <= 0;
                        
                        // Latch valid coordinates to output ports
                        box_min_x <= mn_x; 
                        box_max_x <= mx_x;
                        box_min_y <= mn_y; 
                        box_max_y <= mx_y;
                        
                        // Reset for next frame
                        mn_x <= 255; 
                        mx_x <= 0; 
                        mn_y <= 127; 
                        mx_y <= 0;
                    end else begin
                        y_c <= y_c + 1;
                    end
                end else begin
                    x_c <= x_c + 1;
                end
            end
        end
    end
endmodule