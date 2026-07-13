clear; clc;
fprintf('===================================================\n');
fprintf('    HIGH-RES SINGLE-OBJECT TRACKER (CO-DESIGN)     \n');
fprintf('===================================================\n');

% CHANGE THIS to the exact filename of your original high-quality video
HIGH_RES_VIDEO = 'D:\minorproj2\videos\video2.mp4'; 

MOTION_THRESHOLD = 15; 
MIN_EDGE_PIXELS  = 10; 

% 1. Verify files exist
if ~exist('output_edges.txt', 'file') || ~exist('input_video.txt', 'file')
    error('Missing required simulation text files!');
end
if ~exist(HIGH_RES_VIDEO, 'file')
    error('High-resolution video file not found! Check the filename.');
end

% 2. Load Hardware Data (Safely split to avoid indexing error)
fprintf('Loading hardware edge map...\n');
fid = fopen('output_edges.txt', 'r');
raw_edges = textscan(fid, '%s');
fclose(fid);
edge_pixels = double(hex2dec(raw_edges{1}));

fprintf('Loading original low-res reference stream...\n');
fid = fopen('input_video.txt', 'r');
raw_in = textscan(fid, '%s');
fclose(fid);
display_pixels = double(hex2dec(raw_in{1}));

hr_reader = VideoReader(HIGH_RES_VIDEO);

% 3. Establish Dimensions & Calculate Scaling Factors
lr_height = 120;
lr_width = 160;
pixels_per_frame = lr_height * lr_width; 
total_frames = min(floor(length(edge_pixels) / pixels_per_frame), hr_reader.NumFrames); 

hr_width = hr_reader.Width;
hr_height = hr_reader.Height;

% Calculate the resolution multiplier
scale_x = hr_width / lr_width;
scale_y = hr_height / lr_height;

fprintf('Low-Res Hardware: %dx%d | High-Res Output: %dx%d\n', lr_width, lr_height, hr_width, hr_height);
fprintf('Scaling Multipliers -> X: %.2f, Y: %.2f\n', scale_x, scale_y);

% 4. Initialize High-Res Video Writer
v = VideoWriter('final_1080p_single_tracked.mp4', 'MPEG-4');
v.FrameRate = hr_reader.FrameRate; 
open(v);

prev_frame_matrix = zeros(lr_height, lr_width);
tracked_frames_count = 0;

fprintf('Compiling %d HD frames with scaled tracking envelopes...\n', total_frames);

for f = 1:total_frames
    frame_start = (f-1) * pixels_per_frame + 1;
    frame_end = f * pixels_per_frame;
    
    % Read the crisp, original high-res frame
    img_hr = read(hr_reader, f);
    
    % Reconstruct low-res data for logic processing
    disp_matrix = double(reshape(display_pixels(frame_start:frame_end), [lr_width, lr_height])'); 
    edge_matrix = reshape(edge_pixels(frame_start:frame_end), [lr_width, lr_height])';
    binary_edges = edge_matrix > 128;
    
    % Low-res motion mask calculation
    if f > 1
        motion_mask = abs(disp_matrix - prev_frame_matrix) > MOTION_THRESHOLD;
    else
        motion_mask = zeros(lr_height, lr_width);
    end
    prev_frame_matrix = disp_matrix;
    
    gated_tracked_edges = binary_edges & motion_mask;
    [row_indices, col_indices] = find(gated_tracked_edges);
    
    if length(row_indices) > MIN_EDGE_PIXELS
        min_x = min(col_indices); max_x = max(col_indices);
        min_y = min(row_indices); max_y = max(row_indices);
        
        % Scale coordinates to high-res layer
        hr_min_x = min_x * scale_x;
        hr_min_y = min_y * scale_y;
        hr_box_w = (max_x - min_x) * scale_x;
        hr_box_h = (max_y - min_y) * scale_y;
        
        if hr_box_w > 0 && hr_box_h > 0
            bbox_position = [hr_min_x, hr_min_y, hr_box_w, hr_box_h];
            img_hr = insertShape(img_hr, 'Rectangle', bbox_position, ...
                                 'Color', 'red', 'LineWidth', 5, 'SmoothEdges', true);
            tracked_frames_count = tracked_frames_count + 1;
        end
    end
    
    img_hr = insertText(img_hr, [20 20], sprintf('Frame: %d | FPGA Accelerated Global Track', f), ...
                         'FontSize', 24, 'BoxColor', 'black', 'TextColor', 'white');
    
    writeVideo(v, img_hr);
end

close(v);
fprintf('\n===================================================\n');
fprintf('--> SUCCESS! 1080p Single-Object Video Created!\n');
fprintf('===================================================\n');