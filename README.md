# Interpreting neural decoding models of working memory load using grouped model reliance

## Organisation 
* EEG preprocessing and matlab-based analyses are provided in `EEG_scripts/`.
* The implementation of grouped model reliance is provided in `functions/model_reliance.py`. 
* Feature groups, provided as indices of columns of the data matrices, can be found in `feature_groups/`.  
* The script `compute_mr.py` computes model reliance scores for both frequency and regions of interest and saves them to the `results/` directory. For faster computation, consider lowering the number of trees for the Random Forest algorithm and/or the number of cross validation folds and random permutations. Running `python compute_mr.py` saves the results in `.csv` files to `results/`.
* Figures are generated in `Fig1.ipynb` and `Fig2A.ipynb`.  
* Supplementary analyses are provided in separate jupyter notebooks as `SX.ipynb`.  


## Data 
Preprocessed data matrices for each participant (with anonymised IDs) can be found under `data/`. Rows correspond to trials, and columns to power per frequency (in 1 Hz bins) per electrode location. Access to the raw data will be provided upon publication.
