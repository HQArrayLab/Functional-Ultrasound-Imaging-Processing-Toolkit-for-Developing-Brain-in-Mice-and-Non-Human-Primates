% Clear the workspace and command window to ensure a clean environment
clear;  
clc;  

% Define the file path and filename for loading the .mat data
filepath = 'D:\2345Downloads\free_moving\code\';  
filename = 'zhaojj-250118-1-guassionsound-third_143017_FusPlane';  

% Load the data from the .mat file
load([filepath, filename, '.mat']);  

% Extract the 3D matrix containing the image sequence (FusPlane data)
F = fusplane.Data;  

% Get the number of frames (third dimension of F)
k = size(F, 3);  

% Define x and z coordinates for the image (scaled by 0.1 and 0.075, respectively)
x_image = 0.1 * [1:1:size(F, 2)];  % x-axis in physical units (e.g., mm)  
z_image = 0.075 * [1:1:size(F, 1)]; % z-axis in physical units (e.g., mm)  

% Initialize a video file for saving the output
video = VideoWriter([filepath, filename, '_video.mp4'], 'MPEG-4');  
video.FrameRate = 20;  % Set frame rate to 20 frames per second
video.Quality = 95;    % Set video quality to 95% (max: 100)
open(video);  % Open the video file for writing

% Create a visible figure for displaying frames
figure('Visible', 'on');  

% Loop through each frame in the 3D matrix F
for i = 1:k  
    % Process the i-th frame:
    % 1. Apply gamma correction (Im^0.4) to enhance low-intensity features
    % 2. Normalize the image to [0, 1] using mat2gray for consistent scaling
    Im = F(:, :, i).^0.4;  
    Im_norm = mat2gray(Im);  % Normalize to [0, 1] based on min/max values

    % Display the processed image with scaled x and z axes
    imagesc(x_image, z_image, Im_norm);  
    
    % Add a title showing the frame number (time step)
    title(['t = ', num2str(i)]);  

    % Set axis properties: equal aspect ratio and tight scaling
    axis('equal', 'tight');  

    % Fix the color axis limits to [0, 1] for consistent intensity scaling
    caxis([0, 1]);  

    % Use the 'hot' colormap (black-red-yellow-white) for better contrast
    colormap hot;  

    % Add a colorbar to show intensity values
    colorbar;  

    % Pause briefly (0.01s) to allow visualization (optional)
    pause(0.01);  

    % Capture the current figure as a video frame
    frame = getframe(gcf);  

    % Write the frame to the video file
    writeVideo(video, frame);  
end  

% Close the video file after writing all frames
close(video);  
