#!/bin/bash

part_dir="."

# Wildcard pattern to match the parts
part_pattern="mac_hdd_ng.img.tar.gz.part-*"

# Find all parts matching the pattern
parts=($(ls $part_dir/$part_pattern))

# Loop through each part
for part in "${parts[@]}"; do
  echo "Adding $part..."
  git add "$part"
  
  echo "Committing $part..."
  part_name=$(basename "$part")
  git commit -m "Added part ${part_name##*-} of mac_hdd_ng.img"
  
  echo "Pushing $part..."
  git push
  if [ $? -eq 0 ]; then
    echo "$part pushed successfully."
  else
    echo "Failed to push $part. Exiting."
    exit 1
  fi
done

echo "All parts added, committed, and pushed successfully."
