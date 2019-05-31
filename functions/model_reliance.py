import numpy as np
import pandas as pd
from sklearn.model_selection import StratifiedKFold, LeaveOneGroupOut


def model_reliance(model, X, y, perm_groups=None, keep_idc=False, p=1, normalise=True):
    """
    Compute p-times repeated grouped model reliance for sklearn model.

    Args:
        model: Fitted sklearn model.
        X: Data frame with validation/test features.
        y: Series with validation/test labels.
        perm_groups: Dict with lists of indices or names of featurs to
        permute in groups.
        keep_idc: Logical whether column names of X should be kept or set
        according to column indices.
        p: The number of times the permutation should be repeated.
        normalise: Whether to normalise model reliance according to the size of the feature group.

    Returns:
        A pandas data frame with (grouped) features as columns and
        model reliances in p rows.
    """
    # generate permuation dictionary, if not provided
    if not perm_groups:
        if isinstance(X, pd.DataFrame):
            perm_groups = dict(enumerate(map(str, X.columns.values)))
            # name columns as strings of initial indices

    if not keep_idc:
        X.columns = list(map(str, X.columns.values))

    # compute baseline score
    bl_score = model.score(X, y)
    mr = {}  # data structure for saving model reliances
    for i in range(0, p):
        for group, cols in perm_groups.items():
            X_perm = X.copy()  # needed?

            if isinstance(cols, list):
                cols = list(map(str, cols))
            else:
                cols = [str(cols)]

            X_perm[cols] = np.random.permutation(X_perm[cols])  # permute

            # Compute model reliance
            mr_score = (1 - model.score(X_perm, y)) / (1 - bl_score) - 1
            if normalise:
                mr_score /= len(cols)

            # save mr
            if mr.get(group, None) is None:
                mr[group] = [mr_score]
            else:
                mr[group].append(mr_score)
    mr = pd.DataFrame(mr)
    return(mr)


def model_reliance_cv(model, X, y, perm_groups=None, keep_idc=False, p=1, cv=5, cv_groups=None, normalise=True,
                      rseed=None):
    """
    Compute cross validated permutation model reliance.

    Args:
        model: Sklearn model to fit.
        X: Data frame with validation/test features.
        y: Series with validation/test labels.
        perm_groups: Dict with lists of indices or names of featurs to
        permute in groups.
        keep_idc: Logical whether column names of X should be kept or set
        according to column indices.
        p: The number of times the permutation should be repeated.
        cv: Number of stratified cross-validation folds.
        cv_groups: Vector of indices for groups of observations.
        rseed: Seed for random number generator.
        normalise: Whether to normalise model reliance according to the size of the feature group.


    Returns:
        A pandas data frame with (grouped) features as columns and
        permutation model reliances in p*cv rows.

    """
    model_reliances = []
    for train_idx, test_idx in get_splits(X, y, cv=cv, cv_groups=cv_groups):
        X_train, X_test = X[train_idx], X[test_idx]
        y_train, y_test = y[train_idx], y[test_idx]

        X_train = pd.DataFrame(X_train)
        y_train = pd.Series(y_train)
        X_test = pd.DataFrame(X_test)
        y_test = pd.Series(y_test)

        model.fit(X_train, y_train)

        # Save model reliances
        model_reliances.append(model_reliance(model, X_test, y_test,
                                              perm_groups=perm_groups,
                                              keep_idc=keep_idc, p=p, normalise=normalise))

    return(model_reliances)


def get_splits(X, y, cv=5, cv_groups=None, rseed=None):
    """
    Helper function to set up cross-validation folds and get arrays of training and test set indices.

    Args:
        X: Data frame with validation/test features.
        y: Series with validation/test labels.
        cv: Number of stratified cross-validation folds.
        cv_groups: Vector of indices for groups of observations.
        rseed: Seed for random number generator.

    Returns:
        np.arrays of training and test indices.
    """
    if cv_groups is not None:
        cv = LeaveOneGroupOut()
        return cv.split(X, y, cv_groups)
    else:
        cv = StratifiedKFold(n_splits=cv, shuffle=True, random_state=rseed)
        return cv.split(X, y)
