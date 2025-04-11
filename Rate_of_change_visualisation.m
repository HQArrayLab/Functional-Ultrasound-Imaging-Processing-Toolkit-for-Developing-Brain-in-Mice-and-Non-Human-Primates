%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Correlation Analysis Between Doppler Signal and Stimulus %%
% This script analyzes the correlation between Doppler ultrasound signals
% and auditory stimuli in free-moving mice experiments.
% Author: Qiulab
% Date: 2025.4.7
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all, clc


%% Load experimental data
% Load Doppler ultrasound data (Power Doppler Acquisition)
load 'D:\2345Downloads\free_moving\code\zhaojj-250118-1-mousesound-second_141844_FusPlane.mat'



% Extract Doppler data matrix
Doppler = fusplane.Data;

%% Temporal Normalization of Doppler Data
% Calculate mean Doppler signal across time
DopplerM = mean(Doppler,3);
% Subtract mean (center data)
DopplerN = bsxfun(@minus,Doppler, DopplerM);
% Normalize by standard deviation (z-score normalization)
DopplerN = bsxfun(@rdivide,DopplerN, sqrt(mean(DopplerN.^2,3)));
% Handle zero values in mean image
DopplerM(find((DopplerM==0)))=NaN;

%% Initialize Correlation Map Calculation
Map = DopplerN;

%% Setup Visualization
% Create black background figure without menus/toolbars
figure('Color',[0 0 0],'menubar','none','toolbar','none')

% Define spatial coordinates
X = (-size(Map,2)/2+0.5:size(Map,2)/2-0.5)*0.1;  % Horizontal axis (mm)
Z = (0:size(Map,1)-1)*0.075;  % Depth axis (mm)

% Visualization parameters
slice = 163;  % Reference slice for brain atlas alignment
bin = 2;      % Temporal bin size (smaller = more detail but noisier)
step = 2;     % Frame step size (larger = faster changes but noisier)
colorbarmin = 0;  % Minimum value for color scale
colorbarmax = 6;  % Maximum value for color scale

% Video output settings
v = VideoWriter('D:\2345Downloads\free_moving\code\video\zhaojj-250118-1-mousesound-second_141844_FusPlane_jet_line11.mp4','MPEG-4');
v.Quality = 95;
v.FrameRate = 2;
open(v);  % Initialize video file

% Region of interest boundaries
qqqzmin = 15;  % Minimum depth (mm)
qqqzmax = 80;  % Maximum depth (mm)
qqqxmin = 20;  % Minimum horizontal position (mm)
qqxmax = 128;  % Maximum horizontal position (mm)

% Create tissue mask
mask = getmask(DopplerM);
figure;

%% Main Processing Loop
for k = 1+bin:step:size(DopplerN,3)-bin
    % Calculate temporal average of correlation map
    Mapsum = sum(Map(:,:,k-bin:k+bin),3)./bin;
    
    %% Prepare Background Image
    % Process mean Doppler image for background
    DopplerFrame = sqrt(DopplerM);  % Apply sqrt for better contrast
    DopplerFrame = DopplerFrame-min(DopplerFrame(:));
    DopplerFrame = DopplerFrame./max(DopplerFrame(:));
    DopplerFrame(find(isnan(DopplerFrame))) = 0;
    
    % Apply mask to remove unwanted regions
    DopplerFrame(find(mask==0)) = 0;
    Mapsum(find(mask==0)) = 0;
    
    %% Create Composite Visualization
    % Convert background to RGB
    VesselsRGB = ind2rgb(1+floor(127*DopplerFrame),gray(128));
    
    % Display background
    bg = imagesc(X,Z,VesselsRGB);
    hold on
    
    % Display correlation map with transparency
    fg = imagesc(X,Z,Mapsum);
    alpha(fg,abs(Mapsum)./max(abs(Mapsum),[],"all")*0.6);  % Adjust transparency
    colormap jet;
    
    %% Figure Formatting
    set(gcf,'color','black');
    colorbar('Color',[1 1 1]);
    title(['Activation map - slice ' num2str(k)],'Color',[1 1 1]);
    set(gca,'XColor',[1 1 1],'YColor',[1 1 1],'ZColor',[1 1 1],'Color',[0 0 0]);
    axis equal tight
    
    %% Add Stimulus Frequency Labels
    % Label 1 kHz stimulus periods
    if (k >= 20 && k <= 50) || ...
       (k >= 964 && k <= 1089) || ...
       (k >= 1415 && k <= 1535)
        text(X(1), Z(1), '1 khz', 'Color', 'white', 'FontSize', 16, ...
             'FontWeight', 'bold', 'HorizontalAlignment', 'left', ...
             'VerticalAlignment', 'top');
    
    % Label 10 kHz stimulus periods
    elseif (k >= 1907 && k <= 2029) || ...
           (k >= 2338 && k <= 2462) || ...
           (k >= 2860 && k <= 2985)
        text(X(1), Z(1), '10 khz', 'Color', 'white', 'FontSize', 16, ...
             'FontWeight', 'bold', 'HorizontalAlignment', 'left', ...
             'VerticalAlignment', 'top');
    
    % Label 16 kHz stimulus periods
    elseif (k >= 3329 && k <= 3449) || ...
           (k >= 3818 && k <= 3942) || ...
           (k >= 4445 && k <= 4568)
        text(X(1), Z(1), '16 khz', 'Color', 'white', 'FontSize', 16, ...
             'FontWeight', 'bold', 'HorizontalAlignment', 'left', ...
             'VerticalAlignment', 'top');
    end
    
    %% Add Brain Atlas Registration
    % Prepare Doppler frame for registration
    doppler = repmat(DopplerFrame,[1,1,100]);
    doppler = permute(doppler,[3,1,2]);
    
    % Register brain atlas (see addLines.m for parameters)
    
    hold off
    
    %% Capture Output
    frame = getframe(gcf);  % Capture current frame
    writeVideo(v, frame);    % Write to video file
end

% Save final frame and close video
saveas(gca,'end.png');
close(v);

%% Helper Function: Create Tissue Mask
function mask = getmask(DopplerM)
    figure;
    % Prepare Doppler image for manual masking
    DopplerFrame = sqrt(DopplerM);
    DopplerFrame = DopplerFrame-min(DopplerFrame(:));
    DopplerFrame = DopplerFrame./max(DopplerFrame(:));
    DopplerFrame(find(isnan(DopplerFrame))) = 0;

    % Display image for manual ROI selection
    bg = imagesc(DopplerFrame);
    hold on
    
    % Interactive polygon drawing
    [x,y,flag] = ginput(1);
    m(1) = x;
    n(1) = y;
    k = 2;
    
    while(flag == 1)
        [x1,y1,flag1] = ginput(1);
        if flag1 == 1
            m(k) = x1;
            n(k) = y1;
            line([m(k-1) m(k)],[n(k-1) n(k)],'color','r');
            k = k+1;
            flag = flag1;
        else
            break
        end
    end
    
    % Complete polygon and create mask
    line([m(k-1) m(1)],[n(k-1) n(1)],'color','r');
    BW = roipoly(DopplerFrame,m,n); 
    mask = uint8(BW);
    
    % Display resulting mask
    figure;
    imagesc(mask);
end
