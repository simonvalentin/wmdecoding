# Interpreting neural decoding models using grouped model reliance
This repository provides code and preprocessed data for the analyses presented in [Valentin, Harkotte and Popov (2020)](https://journals.plos.org/ploscompbiol/article?id=10.1371/journal.pcbi.1007148).

## Structure
* EEG preprocessing and matlab-based analyses are provided in `EEG_scripts/`.
* The implementation of grouped model reliance is provided in `functions/model_reliance.py`. 
* Feature groups, provided as indices of columns of the data matrices, can be found in `feature_groups/`.  
* The script `compute_mr.py` computes model reliance scores for both frequency and regions of interest and saves them to the `results/` directory. For faster computation, consider lowering the number of trees for the Random Forest algorithm and/or the number of cross validation folds and random permutations. Running `python compute_mr.py` saves the results in `.csv` files to `results/`.
* The main figures are generated in `Fig2.ipynb` and `Fig3A.ipynb`.  
* Analyses for supplementary figures are provided in separate notebooks as `SX.ipynb`.  


## Data 
Preprocessed data matrices for each participant (with anonymised IDs) can be found under `data/`. Rows correspond to trials, and columns to power per frequency (in 1 Hz bins) per electrode location. 
