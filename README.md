# Functional Ultrasound (fUS) Imaging Processing Toolkit for Developing Brain in Mice and Non-Human Primates

## Overview
This MATLAB-based toolkit provides a comprehensive pipeline for processing and analyzing functional ultrasound (fUS) imaging data from developing brains in mice and non-human primates. The package includes specialized tools for visualization, artifact removal, motion correction, spatiotemporal analysis, and neurovascular coupling studies.

## Module Descriptions

### 1. fUS Data Visualization (`fUS_Visualization.m`)
Converts 3D ultrasound timeseries data into enhanced video visualizations for observing spatiotemporal dynamics in biological tissue. Features include:
- Gamma correction for improved contrast
- Custom colormap optimization
- Frame-by-frame navigation
- Video export capabilities

### 2. Burst Frame Removal (`removeBurstframe.m`)
Automatic detection and removal of abrupt artifacts with linear interpolation:
- L2-norm based outlier detection
- Otsu's algorithm for adaptive thresholding
- Frame-by-frame quality assessment
- Seamless interpolation of corrupted frames

### 3. Motion Correction (`motion_correction.m`)
Implementation of NoRMCorre algorithm for non-rigid motion correction:
- Online piecewise rigid motion correction
- Supports both 2D (planar) and 3D (volumetric) data
- Parameter optimization for developmental brain imaging
- GUI for interactive parameter tuning and visualization

### 4. Rate-of-Change Visualization (`intensity_changes_visualization.m`)
Spatio-temporal correlation analysis of fUS signals with stimuli:
- Normalized correlation mapping
- Sliding window averaging
- Dynamic visualization with brain region alignment
- Automatic stimulus-response pattern identification
- Quantitative neurovascular coupling analysis

### 5. ROI Analysis & CBV Calculation (`intensity_changes.m`)
Spatio-temporal analysis of fUS hemodynamic responses:
- Multi-ROI selection and management
- Raw and normalized intensity change calculations (ΔF/F)
- Stimulus diachronic analysis (multiple time windows can be set)
- Automated contour mapping and curve generation
- Batch processing capabilities

### 6. Signal Deconvolution (`Deconvolution.m`)
Advanced signal processing to isolate neural activity:
- Cardiac signal separation in developing brains
- Hemodynamic response function estimation
- Pseudo-signal reduction from blood flow pulsations
- Post-deconvolution signal enhancement

### 7. Statistical Analysis
Comprehensive data analysis toolkit:
- Population-level response statistics
- Between-group comparisons
- Time-series statistical modeling
- Result visualization and export

## Usage Guidelines

### Basic Workflow(Note: Set your data path in the script before running):
1. Visualize with `fUS_Visualization.m` for quality control
2. Preprocess with `removeBurstframe.m` for artifact removal
3. Apply `motion_correction.m` for motion stabilization
4. Analyze stimulus responses with `intensity_changes_visualization.m`
5. Perform ROI-based quantification with `intensity_changes.m`
6. Apply `Deconvolution.m` for signal purification when needed

### System Requirements:
- Minimum: 16GB RAM, 4-core CPU
- Recommended: 32+ GB RAM, GPU acceleration
- Storage: SSD recommended for large datasets

## References

[1] Macé, Emilie, et al. "Functional ultrasound imaging of the brain." Nature methods 8.8 (2011): 662-664.

[2] Brunner, Clément, et al. "Whole-brain functional ultrasound imaging in awake head-fixed mice." Nature Protocols 16.7 (2021): 3547-3571.

[3] Pnevmatikakis, Eftychios A., and Andrea Giovannucci. "NoRMCorre: An online algorithm for piecewise rigid motion correction of calcium imaging data." Journal of neuroscience methods 291 (2017): 83-94.

[4] El Hady, Ahmed, et al. "Chronic brain functional ultrasound imaging in freely moving rodents performing cognitive tasks." Journal of neuroscience methods 403 (2024): 110033.

## License
This software is available for academic use under the MIT License. For commercial applications, please contact the developers.

## Support
For technical assistance or feature requests, please open an issue on our GitHub repository or contact the development team at heweizhen@gdiist.cn.
