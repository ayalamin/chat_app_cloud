#!/bin/bash

version=$1
commit_hash=$2

if [[ -z $version && -z $commit_hash ]]; then
    echo "missing parameters"
    exit 1
fi

Check if commit hash is provided
if [ $# -eq 0 ]; then
  echo "Error: Please provide a commit hash."
  exit 1
fi

image_exists=$(docker images -q chatapp:$version)

if [ -z "$image_exists" ]; then
  echo "Docker image does not exist. Building a new one..."
  docker build -t chatapp:$version .
else
  read -p "Docker image already exists. Do you want to rebuild it? (y/n): " 
  rebuild_choice
  if [[ $rebuild_choice == "y" || $rebuild_choice == "Y" ]]; then
    echo "Deleting existing image..."
    docker rmi chatapp:$version
    echo "Building a new image..."
    docker build -t chatapp:$version .
  else
    echo "Using existing image."
  fi
fi


# Check if commit hash exists
if ! git rev-parse --verify "$commit_hash" >/dev/null 2>&1; then
  echo "Error: Provided commit hash does not exist."
  exit 1
fi

# Optional: Tagging and pushing to GitHub repo
if [ $# -eq 2 ] && [ "$2" == "--tag-push" ]; then
  # Tag the commit with a version number
  git tag "$version" "$commit_hash"

  # Push the commit and tags to the remote repository
  git push origin "$commit_hash" "$version"

  echo "Tagged commit $commit_hash as $version and pushed to GitHub repository."
else
  echo "Skipping tagging and pushing to GitHub repository."
fi


echo "Deployment completed successfully."