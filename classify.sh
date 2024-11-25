#!/bin/bash

# Check number of arguments
if [ "$#" -lt 2 ]; then
    echo "Usage: bash classify.sh <config-file> <dataset-folder>"
    exit 1
fi

CONFIG_FILE=$1
DATASET_FOLDER=$2

# Set PYTHONPATH to the current directory
export PYTHONPATH=$(pwd)

# Clear the predictions log file before starting
> predictions.log

# Loop through specific "images" directories in the dataset folder
for subdir in "test/images" "train/images" "valid/images"; do
    IMAGE_DIR="$DATASET_FOLDER/$subdir"
    if [ -d "$IMAGE_DIR" ]; then
        echo "Processing images in $IMAGE_DIR..."
        find "$IMAGE_DIR" -type f \( -iname '*.jpg' -o -iname '*.png' -o -iname '*.jpeg' \) | while read -r image; do
            echo "Processing $image..."
            python3 ./src/predict.py --config "$CONFIG_FILE" --input "$image"
        done
    else
        echo "Directory $IMAGE_DIR does not exist. Skipping..."
    fi
done
