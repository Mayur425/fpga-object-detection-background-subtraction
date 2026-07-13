% --- SETTINGS ---
video_path = 'D:\minorproj2\videos\video2.mp4';
output_txt = 'D:\minorproj2\input_video.txt';
width = 160;
height = 120;
% ----------------

v = VideoReader(video_path);
fileID = fopen(output_txt, 'w');

disp('Converting video to hex text...');

while hasFrame(v)
    frame = readFrame(v);
    
    % Resize and Grayscale
    frame_resized = imresize(frame, [height, width]);
    gray_frame = rgb2gray(frame_resized);
    
    % Write pixels in Hex (Vectorized for speed)
    % Transpose to write row-by-row
    gray_transposed = gray_frame';
    fprintf(fileID, '%02x\n', gray_transposed(:));
end

fclose(fileID);
disp(['Done! Created ', output_txt]);