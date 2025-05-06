% Clear workspace and command window
clear; clc;


% Define the file path and filename for loading the .mat data
filepath = '\\10.6.21.11\share\Embryo_fUS_data\20250501_alcohol_new\04-16\';  
filename = 'NaCl-1_201545_FusPlane';  

% Load the data from the .mat file
load([filepath, filename, '.mat']);  
% Extract ultrasound data matrix
data1 = fusplane.Data;

% Define color codes for different ROIs (Black, Red, Green, Yellow, Blue)
color = ['k','r','g','y','b'];


% Set frame rate and create time vector
frame = 2; % Frame rate in Hz
times = [1/frame:1/frame:size(fusplane.Data,3)/frame]; % Time points for each frame

% Set number of ROIs to analyze
roi_num = 5;

% Calculate baseline (F0) as mean of first index frames
index=500;

% Get dimensions of ultrasound data
k = size(fusplane.Data,3); % Number of frames
dimension_x = 0.1*size(fusplane.Data,2); % Horizontal dimension in mm (0.1mm/pixel)
dimension_z = 0.075*size(fusplane.Data,1); % Vertical dimension in mm (0.075mm/pixel)

%% Create and display average image
figure;
Im_average = mean(fusplane.Data,3); % Temporal average
Im_average2 = Im_average.^0.4; % Apply gamma correction for better visualization
imagesc(Im_average2)
title('Temporal Average of Ultrasound Data')
colormap hot; % Use hot color map

for n=1:roi_num
    roi_mask(:,:,n)=roipoly;
    phi(:,:,n)=2*2*(0.5-roi_mask(:,:,n));
    figure;
    imagesc(Im_average2);
    colormap('hot')
    daspect([dimension_x,dimension_z*1,1])
    text(100,10,'roi regions','FontSize',24,'Color','black');
    hold on
    for k=1:n
        [c,h]=contour(phi(:,:,k),[0 0],'Color',color(k));
        % 获取 ROI 的质心坐标，用于标注数字
        roi_props = regionprops(roi_mask(:,:,k), 'Centroid');
        centroid = roi_props.Centroid;
        % 在质心位置标注 ROI 编号
        text(centroid(1), centroid(2), num2str(k), 'FontSize', 18, 'Color', 'white', 'FontWeight', 'bold');
    end
end 
saveas(gca,[filepath,filename,'_roi.fig']);
save([filepath,filename,'_roi_mark.mat'],'roi_mask'); %% save roi mask


%% ROI Selection Process
% rect = 2; % Size parameter for rectangular ROIs
% for n = 1:roi_num
%     % Initialize mask matrix
%     mask = zeros(size(data1(:,:,1)));
% 
%     % Get user input for ROI center
%     [x,z] = ginput(1); % User clicks to select ROI center
% 
%     % Create rectangular ROI mask
%     mask(round(z)-rect:round(z)+rect, round(x)-rect:round(x)+rect) = 1;
% 
%     % Store ROI mask
%     roi_mask(:,:,n) = mask;
% 
%     % Create contour for visualization (phi matrix)
%     phi(:,:,n) = 2 * 2*(0.5-roi_mask(:,:,n));
% 
%     % Display average image with current ROIs
%     imagesc(Im_average2);
%     colormap('hot')
%     hold on
    
%     % Draw contours for all selected ROIs
%     for k = 1:n
%         [c,h] = contour(phi(:,:,k),[0 0],color(k),"LineWidth",2);
%     end
% end 
% % Save ROI selection figure
% saveas(gca,[filepath,filename,'_roi.fig']);
% save([filepath,filename,'_roi_mark.mat'],'roi_mask'); %% save roi mask
% hold off;

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
filename2 = 'raw_data.fig'; 
saveas(gca, [filepath,filename2], 'fig')

%% Calculate and plot normalized intensity changes (ΔF/F)
% Create a figure for each ROI
for i = 1:roi_num
    new_fig = figure;
    hold on;
    
    % Add stimulus timing markers
    % First stimulus period (gray box)
    x_box1 = [15, 30, 30, 15];
    y_box1 = [0, 0, 1.5, 1.5];
    fill(x_box1, y_box1, [0.8, 0.8, 0.8], 'EdgeColor', 'none', 'FaceAlpha', 1, 'DisplayName', 'First stimulus');
    
    % Second stimulus period (blue box)
    x_box2 = [60, 75, 75, 60];
    y_box2 = [0, 0, 1.5, 1.5];
    fill(x_box2, y_box2, [0.5, 0.5, 1], 'EdgeColor', 'none', 'FaceAlpha', 1, 'DisplayName', 'Second stimulus');
    
    % Process current ROI data
    roi_mask_temp = roi_mask(:,:,i);
    dd2 = data1.*roi_mask_temp;
    roi_average = squeeze(sum(sum(dd2,1),2))./sum(roi_mask_temp(:));
    roi_average = filloutliers(roi_average, "nearest", "mean");
    roi_average = smooth(roi_average, 10);
    
    % Calculate baseline (F0) as mean of first index frames
    F0 = mean(roi_average(1:index));
    
    % Calculate normalized intensity change (ΔF/F)
    roi_average2 = (roi_average-F0)./F0;
    
    % Plot the data
    plot(times, roi_average2, color(i), 'LineWidth', 1.5);
    
    % Format plot
    title(['ROI ' num2str(i) ' ΔF/F']);
    xlabel('Time (s)');
    ylabel('\DeltaF/F');
    ylim([min(roi_average2)-0.1, max(roi_average2)+0.1]);
    grid on;
    legend({'First stimulus', 'Second stimulus'}, 'Location', 'northeast');
    
    % Ensure axes are on top of the stimulus markers
    ax = gca;
    ax.Layer = 'top';
    
    hold off;
    
    % Save normalized data plot
    filename1 = ['ROI_' num2str(i)]; 
    saveas(gca, [filepath,filename1], 'fig');
end
