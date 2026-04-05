#!/bin/bash
set -e

DATASET_DIR="/workspace/datasets"
R2R_DIR="${DATASET_DIR}/R2R"

echo "=== Downloading R2R dataset ==="

echo "Downloading from Dropbox..."
wget -O /tmp/r2r_data.zip "https://www.dropbox.com/sh/i8ng3iq5kpa68nu/AAB53bvCFY_ihYx1mkLlOB-ea?dl=1"
mkdir -p "${R2R_DIR}"
unzip -o /tmp/r2r_data.zip -d "${R2R_DIR}"
rm /tmp/r2r_data.zip

# Download connectivity data if not included
if [ ! -d "${R2R_DIR}/connectivity" ]; then
    echo "Downloading connectivity data from Matterport3DSimulator..."
    git clone --depth 1 https://github.com/peteanderson80/Matterport3DSimulator /tmp/mp3dsim
    cp -r /tmp/mp3dsim/connectivity "${R2R_DIR}/connectivity"
    rm -rf /tmp/mp3dsim
fi

echo ""
echo "=== Verifying dataset ==="
for dir in annotations connectivity navigable observations_list_summarized observations_summarized objects_list; do
    path="${R2R_DIR}/${dir}"
    if [ -d "$path" ]; then
        count=$(ls "$path" | wc -l)
        echo "  [OK] ${dir} (${count} files)"
    else
        echo "  [MISSING] ${dir}"
    fi
done

echo ""
echo "Dataset preparation complete."
