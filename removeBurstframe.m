% 1. Load .mat file
load('D:\2345Downloads\free_moving\code\zhaojj-250119-p2-step1-dark_152641_FusPlane.mat');  % Replace with your .mat file path

data1 = fusplane.Data;  % Replace with your actual variable name
x_image = 0.1 * [1:1:size(data1, 2)];  % x-axis coordinates (scaled by 0.1)
z_image = 0.075 * [1:1:size(data1, 1)]; % z-axis coordinates (scaled by 0.075)
data = data1.^0.25;  % Apply gamma correction to enhance low-intensity features

% 2. Calculate L2 norm for each frame
frameNorms = squeeze(sqrt(sum(sum(data.^2, 1), 2)));  % Calculate L2 norm for each frame

% 3. Identify outlier frames using direct thresholding
thresh = [];  % Use automatic threshold range if empty
outlierSel = 'direct';  % Use 'direct' method for outlier detection
Nthresh = 100;  % Number of threshold levels to consider
[errIDs, bestThresh] = directOutlierThresholding(frameNorms, thresh, outlierSel, Nthresh);

% 4. Visualize and save outlier frames
outputDir = 'D:\2345Downloads\free_moving\code\output_images8\';
if ~exist(outputDir, 'dir')
    mkdir(outputDir);  % Create directory if it doesn't exist
end

% Create and save figures for outlier frames
for t = 1:size(data, 3)
    if errIDs(t)
        frame = data(:, :, t);
        figure('Visible', 'off');  % Create invisible figure for faster processing
        Im2_norm = mat2gray(frame);
        imagesc(x_image, z_image, Im2_norm);
        caxis([0, 1]);
        colormap('hot');
        colorbar;
        title(sprintf('Outlier Frame %d (Norm: %.2f)', t, frameNorms(t)));
        saveas(gcf, fullfile(outputDir, sprintf('outlier_frame_%01d.png', t)));
        close;
    end
end

% 5. Plot norm histogram with threshold
figure;
histogram(frameNorms, 50);
hold on;
xline(bestThresh, 'r', 'LineWidth', 2);
xlabel('L2 Norm');
ylabel('Frequency');
title(sprintf('Frame Norm Distribution (Threshold: %.2f)', bestThresh));
legend('Norm Distribution', 'Best Threshold');
hold off;
saveas(gcf, fullfile(outputDir, 'norm_distribution.png'));

% 6. Remove outliers and perform linear interpolation
goodFrames = find(~errIDs);  % Indices of valid frames
badFrames = find(errIDs);    % Indices of outlier frames

% Initialize cleaned data matrix
cleanedData = zeros(size(data));

% Process each pixel location
for x = 1:size(data, 1)
    for y = 1:size(data, 2)
        % Extract time series for this pixel
        pixelSeries = squeeze(data(x, y, :));
        
        % Replace outliers using linear interpolation
        cleanedPixelSeries = interp1(goodFrames, pixelSeries(goodFrames), 1:size(data, 3), 'linear', 'extrap');
        
        % Store cleaned data
        cleanedData(x, y, :) = cleanedPixelSeries;
    end
end

% 7. Save cleaned data as new .mat file

fusplane.Data = cleanedData;  % Replace with cleaned data
save('D:\2345Downloads\free_moving\code\zhaojj-250119-p2-step1-dark_152641_FusPlane_cleaned.mat', 'fusplane');

% Helper function for outlier detection
function [errIDs, bestThresh] = directOutlierThresholding(frameNorms, thresh, outlierSel, Nthresh)
    if isempty(thresh)
        thresh = [min(frameNorms), max(frameNorms)];  % Use full range if no threshold specified
    end
    
    if strcmpi(outlierSel, 'direct')
        if numel(thresh) == 1
            errIDs = frameNorms > thresh;
            bestThresh = thresh;
        elseif numel(thresh) == 2
            valid_norms = frameNorms(frameNorms >= thresh(1) & frameNorms <= thresh(2));
            if isempty(valid_norms)
                error('No valid norms within specified threshold range');
            end
            normalized_norms = (valid_norms - min(valid_norms)) / (max(valid_norms) - min(valid_norms));
            otsu_thresh = graythresh(normalized_norms);
            bestThresh = otsu_thresh * (max(valid_norms) - min(valid_norms)) + min(valid_norms);
            errIDs = frameNorms > bestThresh;
        else
            error('Threshold should be scalar or 2-element vector');
        end
    else
        error('Only ''direct'' method is supported');
    end
end