#!/bin/bash

# Function to handle errors

handle_error() {

  echo "Error: $1"

  exit 1

}

# Get version from user

read -p "Enter version: " version

# Get commit hash from user

read -p "Enter commit hash: " commit_hash

# Check if image exists

if docker image inspect chat-app:$version >/dev/null 2>&1; then

  read -p "Image chat-app:$version already exists. Do you want to rebuild? [y/n]: " rebuild

  if [ "$rebuild" == "y" ]; then

    # Delete existing image

    docker image rm chat-app:$version || handle_error "Failed to delete existing image"

  else

    echo "Using existing image chat-app:$version"

    exit 0

  fi

fi

# Tag the commit

git tag "$version" "$commit_hash" || handle_error "Failed to tag the commit"

# Build the image

docker build -t chat-app:$version . || handle_error "Failed to build the image"

# Push the tag to GitHub repository

git push origin "$version" || handle_error "Failed to push to GitHub"

# Success message

echo "Deployment successful!"
