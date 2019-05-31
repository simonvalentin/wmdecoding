#!/usr/bin/env python

import pandas as pd
import scipy.io as io
import json
import functions.model_reliance as mr
from sklearn.ensemble import RandomForestClassifier
from functions.helpers import *

# Load indices
with open('feature_groups/allelecs_allfreq_roi.json') as f:
    allelecs_allfreq_roi = json.load(f)
with open('feature_groups/allelecs_allfreq_freq.json') as f:
    allelecs_allfreq_freq = json.load(f)

# Set parameters
k = 10 # cross validation folds
p = 10 # number of random permutations per fold
n_trees = 5000 # number of trees for Random Forest
normalise_mr = True # Whether to compute average MR for group of predictor variables

# Set up data structures
roi_results = []
freq_results = []

# Iterate through list of subjects
for subj in subjects:
    print('Computing model reliance on subject ' + subj)

    # Load data
    datapath = inputdirectory + subj + '/' + 'Xallelecs_allfreq.mat'
    data = io.loadmat(datapath)
    y = data['y'].flatten()
    X = data['X']

    # Initialise classifier
    clf = RandomForestClassifier(n_estimators=n_trees, n_jobs=-1)

    # Compute and store MR for ROI
    res = mr.model_reliance_cv(
        clf, X, y, perm_groups=allelecs_allfreq_roi, p=p, cv=k, normalise=normalise_mr)
    roi_results.append(pd.DataFrame(pd.concat(res).mean()).transpose())

    # Compute and store MR for frequency groups
    res = mr.model_reliance_cv(
        clf, X, y, perm_groups=allelecs_allfreq_freq, p=p, cv=k, normalise=normalise_mr)
    freq_results.append(pd.DataFrame(pd.concat(res).mean()).transpose())

# ROI - reshape data
roi_results = pd.concat(roi_results)
roi_mr = roi_results.copy()
roi_mr['id'] = subjects
roi_mr.reset_index(drop=True, inplace=True)
roi_mr = roi_mr[['leftocci', 'rightocci', 'occipitocentral',
                 'central', 'leftcentral', 'rightcentral',
                            'frontocentral', 'leftfrontal', 'rightfrontal', 'id']]
# Freq - reshape data
freq_results = pd.concat(freq_results)
freq_mr = freq_results.copy()
freq_mr['id'] = subjects
freq_mr.reset_index(drop=True, inplace=True)

# Store model reliances as csv for figures
roi_mr.to_csv('results/roi_mr.csv', index=False)
freq_mr.to_csv('results/freq_mr.csv', index=False)
