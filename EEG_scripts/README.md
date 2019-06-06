# EEG Preprocessing and analysis 
## General information 
EEG preprocessing, cluster based permutation statistics and plotting of Figure 2B, 3 and S5 uses the Matlab based *Fieldtrip Toolbox* (Oostenveld, Fries, Maris, & Schoffelen, 2011). 

Plotting of powerspectra uses the *boundedline function* (Kearney, 2018), which can be downloaded from https://de.mathworks.com/matlabcentral/fileexchange/27485-boundedline-m.

## File structure 
- `EEG_prepro.m`
    - Reads in raw data from all three sessions for all subjects
    - Computes independent component analysis and removes cardiac and blink artifacts
    - Computes frequency analysis
- `generate_matrices.m` creates matrices containing preprocessed data that is used to train models and estimate model values
- `Fig2B.m`generates Figure 2B using the Fieldtrip `ft_topoplotER` function and model reliance values from `mr_roi_alpha.mat`
- `cluster_statistics.m`computes cluster-based permutation analysis as implemented in the Fieldtrip toolbox for each subject
- `Fig3.m`generates Figure 3 A and B 
- `S5` contains supplementary cluster-based permutation analysis across subjects and code for plotting supplementary Figure 5
