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

# Create a temporary file to store classification counts
CLASS_COUNTS_FILE="class_counts.log"
> "$CLASS_COUNTS_FILE"

# Loop through specific "images" directories in the dataset folder
for subdir in "test/images" "train/images" "valid/images"; do
    IMAGE_DIR="$DATASET_FOLDER/$subdir"
    if [ -d "$IMAGE_DIR" ]; then
        echo "Processing images in $IMAGE_DIR..."
        
        # Generate a valid temporary file name by replacing slashes with underscores
        TEMP_FOLDER_COUNTS="counts_$(echo $subdir | tr '/' '_').log"
        > "$TEMP_FOLDER_COUNTS"
        
        # Process each image in the folder
        find "$IMAGE_DIR" -type f \( -iname '*.jpg' -o -iname '*.png' -o -iname '*.jpeg' \) | while read -r image; do
            echo "Processing $image..."
            CLASS=$(python3 ./src/predict.py --config "$CONFIG_FILE" --input "$image")
            
            # Log prediction into the folder-specific counts file
            echo "$CLASS" >> "$TEMP_FOLDER_COUNTS"
        done

        # Count occurrences of each class in the current folder
        echo "Class counts for $subdir:" >> "$CLASS_COUNTS_FILE"
        sort "$TEMP_FOLDER_COUNTS" | uniq -c >> "$CLASS_COUNTS_FILE"
        echo >> "$CLASS_COUNTS_FILE"

        # Remove temporary file for the current folder
        rm "$TEMP_FOLDER_COUNTS"
    else
        echo "Directory $IMAGE_DIR does not exist. Skipping..."
    fi
done

# Display the overall class counts
echo "Class counts per folder:"
cat "$CLASS_COUNTS_FILE"

# Remove the class counts file if no longer needed
rm "$CLASS_COUNTS_FILE"
