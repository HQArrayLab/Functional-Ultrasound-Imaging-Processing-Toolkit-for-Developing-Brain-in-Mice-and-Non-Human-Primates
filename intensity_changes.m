% Clear workspace and command window
clear; clc;

% Load ultrasound data file containing fusplane structure
load('D:\2345Downloads\free_moving\code\data\zhaojj-250119-p5-mousesound_224900_FusPlane.mat');

% Extract ultrasound data matrix
data1 = fusplane.Data;

% Define color codes for different ROIs (Black, Red, Green, Yellow, Blue)
color = ['k','r','g','y','b'];
save color.mat color; % Save color codes for later use

% Set frame rate and create time vector
frame = 2; % Frame rate in Hz
times = [1/frame:1/frame:size(fusplane.Data,3)/frame]; % Time points for each frame

% Set number of ROIs to analyze
roi_num = 5;

% Get dimensions of ultrasound data
k = size(fusplane.Data,3); % Number of frames
dimension_x = 0.1*size(fusplane.Data,2); % Horizontal dimension in mm (0.1mm/pixel)
dimension_z = 0.075*size(fusplane.Data,1); % Vertical dimension in mm (0.075mm/pixel)

%% Create and display average image
figure;
Im_average = mean(fusplane.Data,3); % Temporal average
Im_average2 = Im_average.^0.25; % Apply gamma correction for better visualization
imagesc(Im_average2)
title('Temporal Average of Ultrasound Data')
colormap hot; % Use hot color map

%% Create output directory for results
foldername = '.\intensity\1\';
mkdir(foldername); % Create directory if it doesn't exist
filename = 'average.fig'; 
saveas(gca, fullfile(foldername, filename), 'fig'); % Save average image

%% ROI Selection Process
rect = 2; % Size parameter for rectangular ROIs
for n = 1:roi_num
    % Initialize mask matrix
    mask = zeros(size(data1(:,:,1)));
    
    % Get user input for ROI center
    [x,z] = ginput(1); % User clicks to select ROI center
    
    % Create rectangular ROI mask
    mask(round(z)-rect:round(z)+rect, round(x)-rect:round(x)+rect) = 1;
    
    % Store ROI mask
    roi_mask(:,:,n) = mask;
    
    % Create contour for visualization (phi matrix)
    phi(:,:,n) = 2 * 2*(0.5-roi_mask(:,:,n));
    
    % Display average image with current ROIs
    imagesc(Im_average2);
    colormap('hot')
    hold on
    
    % Draw contours for all selected ROIs
    for k = 1:n
        [c,h] = contour(phi(:,:,k),[0 0],color(k),"LineWidth",2);
    end
end 

% Save ROI selection figure
filename = 'mask'; 
cd(foldername);
saveas(gca, filename, 'fig')
saveas(gca, filename, 'tif')
hold off;

%% Calculate and plot raw intensity data for each ROI
figure;
hold on
for i = 1:roi_num
    % Extract current ROI
    roi_mask_temp = roi_mask(:,:,i);
    
    % Calculate mean intensity within ROI for each frame
    dd2 = data1.*roi_mask_temp;
    roi_average = squeeze(sum(sum(dd2,1),2))./sum(roi_mask_temp(:));
    
    % Plot time series
    plot(times, roi_average, color(i));
end
title('Raw Intensity Time Series for Each ROI')
hold off

% Save raw data plot
filename = 'raw_data.fig'; 
saveas(gca, filename, 'fig')

%% Calculate and plot normalized intensity changes (ΔF/F)
new_fig = figure;
hold on;

% Add stimulus timing markers
% First stimulus period (gray box)
x_box1 = [15, 30, 30, 15];
y_box1 = [0, 0, 6, 6];
fill(x_box1, y_box1, [0.8, 0.8, 0.8], 'EdgeColor', 'none', 'FaceAlpha', 1, 'DisplayName', 'First stimulus');

% Second stimulus period (blue box)
x_box2 = [60, 75, 75, 60];
y_box2 = [0, 0, 6, 6];
fill(x_box2, y_box2, [0.5, 0.5, 1], 'EdgeColor', 'none', 'FaceAlpha', 1, 'DisplayName', 'Second stimulus');

% Ensure axes are on top of the stimulus markers
ax = gca;
ax.Layer = 'top';

% Plot normalized data for each ROI
for i = 1:roi_num
    roi_mask_temp = roi_mask(:,:,i);
    dd2 = data1.*roi_mask_temp;
    roi_average = squeeze(sum(sum(dd2,1),2))./sum(roi_mask_temp(:));
    
    % Calculate baseline (F0) as mean of first 160 frames
    F0 = mean(roi_average(1:160));
    
    % Calculate normalized intensity change (ΔF/F)
    roi_average2 = (roi_average-F0)./F0;
    
    % Plot with vertical offset for clarity
    plot(times, roi_average2+i, color(i));
end

% Format plot
title('Normalized Intensity Changes (ΔF/F)')
xlabel('Time (s)')
ylabel('\DeltaF/F')
ylim([0, 6]);
yticks(0:1:6);
grid on;
legend({'First stimulus', 'Second stimulus'}, 'Location', 'northeast');
hold off;

% Save normalized data plot
filename = 'growth_data'; 
saveas(gca, filename, 'fig');
saveas(gca, filename, 'tif');