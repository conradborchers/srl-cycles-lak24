#!/usr/bin/env bash

error=0

# Handle extra parmeters necessary for other operating systems
extraParams=''

unameSystem=`uname -s`
case "$unameSystem" in
    Darwin*)
        # Use -E here to allow all extended regex support on macOS
        extraParams='-E'
        ;;
    *)
        ;;
esac

if [[ -n `eval "find $extraParams . -regex '\./ds[0-9]+_tx_[A-Za-z_]+_[0-9]+\.txt'"` ]]; then
    # The file has already been processed
    echo 'Transaction file already has its timestamp stripped, skipping...'
elif [[ -n `eval "find $extraParams . -regex '\./ds[0-9]+_tx_[A-Za-z_]+_[0-9]+_[0-9_]+\.txt'"` ]]; then
    # The file hasn't been processed yet

    ## Rename the transactional file to parse out the timestamp
    ## Retains directory information
    for file in ds*.txt; do
        mv $file `printf "$file" | eval "sed $extraParams 's/\(\(.*\/\)\?ds[0-9]\+_tx_[A-Za-z_]\+_[0-9]\+\)_[0-9_]\+\.txt/\1\.txt/'"`
    done
    echo 'Renamed transactional file!'
else
    echo 'Could not find transactional file.'
    error=1
fi

if [[ -f './d_analysis.csv' ]]; then
    # The setup script in R has already been ran
    echo 'Setup script already run, skipping...'
elif [[ -n `eval "find $extraParams . -regex '\./ds[0-9]+_tx_[A-Za-z_]+_[0-9]+\.txt'"` && -f './lak24-coded-utterances.csv' && -f './transcripts-with-logdata-reference-lak24.csv' ]]; then
    # The setup script in R has not been ran yet

    ## Construct the dataset to run the other R scripts
    echo 'Running setup R script, please wait for a few minutes...'
    Rscript ./setup-lak24.R
    echo 'Constructed missing datasets!'
else
    echo 'Missing one or more dataset files.'
    error=1
fi

if [ $error -ne 0 ]; then
    # Report error
    echo "Please follow the steps under 'Setup' in the README to get started. Then run this script again."
else
    echo "Setup successfully finished! You can now run 'main-lak24.R' and 'rq3-analysis.ipynb'."
fi
