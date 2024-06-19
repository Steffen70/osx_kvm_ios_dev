#!/bin/bash

# Define a black list of files that should not be synchronized
black_list=(
  "sync_with_osx_kvm_master.sh"
  "OpenCore-Boot.sh"
  "OVMF_VARS-1920x1080.fd"
  "OpenCore/OpenCore.qcow2"
)

# Check remote osx_kvm exists - if not, prompt to the user to add it
if ! git remote | grep -q osx_kvm; then
  echo "Remote osx_kvm not found. Please add osx_kvm as a remote repository."
  exit 1
fi

# Fetch the latest changes from the remote repository
git fetch osx_kvm

# List all files in the current branch
for file in $(git ls-files); do
  # Skip the file if it is a directory
  if [ -d "$file" ]; then
      continue
  fi

  # Check if the file exists in osx_kvm/master
  if ! git cat-file -e osx_kvm/master:"$file" 2>/dev/null; then
    # If the file does not exist in osx_kvm/master, delete it
    echo "Deleting $file"
    rm "$file"
  fi
done

# Checkout the latest files from osx_kvm/master
git checkout osx_kvm/master -- .

# Unstage all changes
git reset HEAD

# Restore files from the black list
for file in "${black_list[@]}"; do
  git checkout -- "$file"
done

# Stage all changes
#git add --all

# Commit the changes
# git commit -m "Synchronized with osx_kvm/master, including deletions"

# Get the latest commit message from osx_kvm/master and prompt the user to use it
latest_commit_message=$(git log -1 --pretty=%B osx_kvm/master)

echo "The latest commit message from osx_kvm/master is:"
echo "$latest_commit_message"

echo "Go through the changes and commit them manually."
echo "If there are files you never want to sync, add them to the black list in sync_with_osx_kvm_master.sh."