function motion_correction_gui()
    % GUI for enhanced motion correction based on uploaded file
    
    % Add NoRMCorre toolbox path
    normcorre_path = 'D:\window-to-the-brain-main\third-party\NoRMCorre';
    addpath(genpath(normcorre_path));  % Recursively add all subfolders

    % Initialize GUI figure window
    hFig = figure('Name', 'Motion Correction GUI', 'NumberTitle', 'off', 'Position', [100, 100, 1400, 800]);

    % Create control buttons
    uicontrol(hFig, 'Style', 'pushbutton', 'String', 'Load Data', ...
        'Position', [10, 750, 120, 30], 'Callback', @load_data);
    uicontrol(hFig, 'Style', 'pushbutton', 'String', 'Run Motion Correction', ...
        'Position', [140, 750, 150, 30], 'Callback', @run_motion_correction, 'Enable', 'off');
    uicontrol(hFig, 'Style', 'pushbutton', 'String', 'Save Corrected Data', ...
        'Position', [300, 750, 150, 30], 'Callback', @save_corrected_data, 'Enable', 'off');
    uicontrol(hFig, 'Style', 'pushbutton', 'String', 'Exit', ...
        'Position', [460, 750, 100, 30], 'Callback', @(~, ~) close(hFig));

    % Create axes for image display
    hAxesOriginal = axes('Parent', hFig, 'Position', [0.05, 0.4, 0.4, 0.5]);
    title(hAxesOriginal, 'Original Frame');
    hAxesCorrected = axes('Parent', hFig, 'Position', [0.55, 0.4, 0.4, 0.5]);
    title(hAxesCorrected, 'Corrected Frame');

    % Create frame navigation slider
    hSlider = uicontrol(hFig, 'Style', 'slider', 'Min', 1, 'Max', 100, 'Value', 1, ...
        'Position', [400, 100, 600, 30], 'Callback', @slider_callback, 'Enable', 'off');
    addlistener(hSlider, 'ContinuousValueChange', @slider_callback);

    % Create frame number display text
    hFrameText = uicontrol(hFig, 'Style', 'text', 'Position', [600, 130, 200, 20], 'String', 'Frame: 1', 'FontSize', 12);

    % Initialize data storage variables
    raw_data = [];          % Stores original image data
    corrected_data = [];    % Stores motion-corrected data
    num_frames = 0;        % Total number of frames in loaded data

    % Callback function for loading data
    function load_data(~, ~)
        % Open file selection dialog for MAT files
        [file, path] = uigetfile('*.mat', 'Select MAT File');
        if isequal(file, 0)  % User cancelled selection
            return;
        end
        fullPath = fullfile(path, file);
        disp(['Loading data from ', fullPath]);

        % Load data from selected file
        data = load(fullPath);
        if isfield(data, 'fusplane')  % Check if data contains required field
            raw_data = data.fusplane.Data;
            num_frames = size(raw_data, 3);  % Get number of frames
            % Configure slider for frame navigation
            set(hSlider, 'Max', num_frames, 'Value', 1, 'Enable', 'on');
            disp('Data loaded successfully.');
            % Enable motion correction button
            set(findobj(hFig, 'String', 'Run Motion Correction'), 'Enable', 'on');
            update_frame(1);  % Display first frame
        else
            errordlg('Selected file does not contain valid fusplane data.', 'Error');
        end
    end

    % Callback function for running motion correction
    function run_motion_correction(~, ~)
        if isempty(raw_data)  % Check if data is loaded
            errordlg('No data loaded. Please load data first.', 'Error');
            return;
        end

        disp('Running enhanced motion correction...');
        % Set parameters for rigid motion correction
        options_rigid = NoRMCorreSetParms('d1', size(raw_data, 1), 'd2', size(raw_data, 2), ...
            'grid_size', [128, 128], 'mot_uf', 4, 'bin_width', 50, 'max_shift', 15, 'us_fac', 50);

        % Apply motion correction using NoRMCorre
        [corrected_data, ~, ~] = normcorre(raw_data, options_rigid);
        disp('Motion correction completed successfully.');
        % Enable save button after correction
        set(findobj(hFig, 'String', 'Save Corrected Data'), 'Enable', 'on');
    end

    % Callback function for saving corrected data
    function save_corrected_data(~, ~)
        if isempty(corrected_data)  % Check if correction was performed
            errordlg('No corrected data to save.', 'Error');
            return;
        end

        % Open file save dialog
        [file, path] = uiputfile('*.mat', 'Save Corrected Data');
        if isequal(file, 0)  % User cancelled save
            return;
        end
        fullPath = fullfile(path, file);

        % Save corrected data in MAT file
        fusplane.Data = corrected_data;
        save(fullPath, 'fusplane', '-v7.3');  % Use version 7.3 format for large files
        disp(['Corrected data saved to ', fullPath]);
    end

    % Callback function for slider navigation
    function slider_callback(~, ~)
        frame_idx = round(get(hSlider, 'Value'));  % Get current slider position
        update_frame(frame_idx);  % Update displayed frame
    end

    % Helper function to update frame display
    function update_frame(frame_idx)
        if isempty(raw_data)  % Check if data is loaded
            return;
        end

        % Display original frame with gamma correction (0.4)
        axes(hAxesOriginal);
        imagesc(raw_data(:, :, frame_idx).^0.4);
        colormap hot;
        colorbar;
        title('Original Frame');
        axis off;

        % Display corrected frame if available
        axes(hAxesCorrected);
        if ~isempty(corrected_data)
            imagesc(abs(corrected_data(:, :, frame_idx)).^0.4);
            title('Corrected Frame');
        else
            cla;  % Clear axes if no corrected data
            title('Corrected Frame');
        end
        colormap hot;
        colorbar;
        axis off;

        % Update frame number display
        set(hFrameText, 'String', sprintf('Frame: %d', frame_idx));
    end
end