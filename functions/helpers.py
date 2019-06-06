"""
Setup for analyses.
"""
import os

# Seed for random number generator
rseed = 42

# Set path for input directory automatically from current working directory
inputdirectory = os.path.abspath("data/") + '/'

# List of subjects, in non-ascending order of classification performance
subjects = ['S01',
            'S02',
            'S03',
            'S04',
            'S05',
            'S06',
            'S07',
            'S08',
            'S09',
            'S10']
