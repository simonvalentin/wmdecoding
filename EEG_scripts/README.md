# EEG Preprocessing and analysis 
## General information 
EEG preprocessing, cluster based permutation statistics and plotting of Figure 3B and 4 uses the Matlab based *Fieldtrip Toolbox* (Oostenveld, Fries, Maris, & Schoffelen, 2011). 

The raw data can be retrieved from the [OSF repository](https://osf.io/w6d92/) associated with this project. 

Plotting of powerspectra uses the [*boundedline function*](https://de.mathworks.com/matlabcentral/fileexchange/27485-boundedline-m) (Kearney, 2018).

## File structure 
- `EEG_prepro.m`
    - Reads in raw data from all three sessions for all subjects. *Note: The recording of the first session for subject S01 is currently split into two files, due to technical reasons. These can simply be concatenated during preprocessing.*
    - Computes independent component analysis and removes cardiac and blink artifacts
    - Computes frequency analysis
- `generate_matrices.m` creates matrices containing preprocessed data that is used to train models and estimate model values
- `Fig3B.m`generates Figure 3B using the Fieldtrip `ft_topoplotER` function and model reliance values from `mr_roi.mat`
- `cluster_statistics.m`computes cluster-based permutation analysis as implemented in the Fieldtrip toolbox for each subject
- `Fig4.m`generates Figure 4 A and B 
