% 1. Load .mat file
load('E:\4D_view\M2_2_112551_FusPlane.mat');  
data1 = fusplane.Data;  
x_image = 0.1 * [1:1:size(data1, 2)];  
z_image = 0.075 * [1:1:size(data1, 1)]; 
data = data1.^0.25;  

% 2. Calculate L2 norm for each frame
frameNorms = squeeze(sqrt(sum(sum(data.^2, 1), 2)));  
% 2. Calculate L2 norm for each frame

% 3. Identify potential outlier frames using direct thresholding
thresh = [];  % Use automatic threshold range if empty
outlierSel = 'direct';  % Use 'direct' method for outlier detection
Nthresh = 100;  % Number of threshold levels to consider
[potentialOutlierIDs, initialThresh] = directOutlierThresholding(frameNorms, thresh, outlierSel, Nthresh);

% 4. Select thresholds interactively using histograms --------------------------------------------
hFigHist = figure('Position', [100, 100, 800, 600]);
histogram(frameNorms, 50, 'Normalization', 'probability');
xlabel('L2 Norm');
ylabel('Probability');
title('Frame Norm Distribution - Click to Set Threshold (Press Enter to Confirm)');

% 5. Draw the initial threshold line (the best threshold found is used by default)
% initialThresh = median(frameNorms) + 3*std(frameNorms);
hLine = xline(initialThresh, 'r', 'LineWidth', 2);
legend('Norm Distribution', 'Threshold', 'Location', 'northwest');

% 6. Allow users to click on the histogram to adjust the threshold
disp('Click on the histogram to adjust the threshold line. Press Enter to confirm.');
[x, ~] = ginput(1);  % Waiting for user click
while ~isempty(x)
    delete(hLine);  % Delete old threshold line
    hLine = xline(x(1), 'r', 'LineWidth', 2);  % Draw a new threshold line
    title(sprintf('Current Threshold: %.2f (Press Enter to Confirm)', x(1)));
    [x, ~] = ginput(1);  
end
bestThresh = hLine.Value;
close(hFigHist);

% 7. Mark potential abnormal frames based on thresholds
potentialOutlierIDs = frameNorms > bestThresh;
fprintf('Selected threshold: %.2f\n', bestThresh);
fprintf('Potential outliers detected: %d frames\n', sum(potentialOutlierIDs));

% 8. Interactive outlier confirmation 
disp('Starting interactive outlier frame confirmation...');
disp('For each frame, press "y" to confirm as outlier, "n" to reject, or "q" to quit early.');

confirmedOutlierIDs = false(size(potentialOutlierIDs)); 
outlierFrames = find(potentialOutlierIDs); 

hFig = figure('Position', [100, 100, 1200, 1000]); 

for i = 1:length(outlierFrames)
    t = outlierFrames(i);
    frame = data(:, :, t);
    
    clf(hFig); 
    Im2_norm = mat2gray(frame);
    imagesc(x_image, z_image, Im2_norm);
    caxis([0, 1]);
    colormap('hot');
    colorbar;
    title(sprintf('Potential Outlier Frame %d (Norm: %.2f)\nPress "y"=outlier, "n"=normal, "q"=quit', t, frameNorms(t)));
    
    waitforbuttonpress;
    key = get(gcf, 'CurrentCharacter');
    
    if lower(key) == 'y'
        confirmedOutlierIDs(t) = true;
        fprintf('Frame %d confirmed as outlier.\n', t);
    elseif lower(key) == 'n'
        fprintf('Frame %d marked as normal.\n', t);
    elseif lower(key) == 'q'
        fprintf('Early termination selected. %d frames remaining unconfirmed.\n', length(outlierFrames)-i);
        break;
    else
        fprintf('Invalid key pressed. Frame %d skipped.\n', t);
    end
end
close(hFig); 

% 9. Visualize and save results 
outputDir = 'D:\peitai\code4\removeburst6\';
if ~exist(outputDir, 'dir')
    mkdir(outputDir);  
end

for t = 1:size(data, 3)
    if confirmedOutlierIDs(t)
        frame = data(:, :, t);
        figure('Visible', 'off');  
        Im2_norm = mat2gray(frame);
        imagesc(x_image, z_image, Im2_norm);
        caxis([0, 1]);
        colormap('hot');
        colorbar;
        title(sprintf('Confirmed Outlier Frame %d (Norm: %.2f)', t, frameNorms(t)));
        saveas(gcf, fullfile(outputDir, sprintf('confirmed_outlier_frame_%01d.png', t)));
        close;
    end
end

% 10. Plot final norm histogram with confirmed outliers
figure;
histogram(frameNorms, 50);
hold on;
xline(bestThresh, 'r', 'LineWidth', 2);
plot(frameNorms(confirmedOutlierIDs), zeros(sum(confirmedOutlierIDs),1), 'rx', 'MarkerSize', 10, 'LineWidth', 2);
xlabel('L2 Norm');
ylabel('Frequency');
title(sprintf('Frame Norm Distribution (Threshold: %.2f)', bestThresh));
legend('Norm Distribution', 'Manual Threshold', 'Confirmed Outliers');
hold off;
saveas(gcf, fullfile(outputDir, 'norm_distribution_with_confirmed.png'));

% 11. Remove outliers and interpolate 
goodFrames = find(~confirmedOutlierIDs);  
badFrames = find(confirmedOutlierIDs);    

cleanedData = zeros(size(data));
for x = 1:size(data1, 1)
    for y = 1:size(data1, 2)
        pixelSeries = squeeze(data1(x, y, :));
        cleanedPixelSeries = interp1(goodFrames, pixelSeries(goodFrames), 1:size(data1, 3), 'linear', 'extrap');
        cleanedData(x, y, :) = cleanedPixelSeries;
    end
end

% 8. Save cleaned data
fusplane.Data = cleanedData;  
save('\\10.6.21.11\share\fUS_data\Auditory—embryo2\ctrladded\M3-LPS_122445_FusPlane_removeburst.mat', 'fusplane');




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
