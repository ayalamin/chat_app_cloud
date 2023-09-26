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
# Ask user if they want to push the image to Artifact Registry
read -p "Do you want to push the image to Artifact Registry? (y/n): " push_image

if [ "$push_image" == "y" ]; then
  # Authenticate with service account impersonation
  gcloud auth activate-service-account --key-file=/path/to/service-account-key.json --impersonate-service-account=artifact-admin-sa@grunitech-mid-project.iam.gserviceaccount.com

  # Push the image to Artifact Registry
  gcloud artifacts docker images push gcr.io/Grunitech Mid Project/chat_app_cloud:$version

  echo "Image pushed to Artifact Registry."
else
  echo "Skipping image push to Artifact Registry."
fi

echo "Deployment completed successfully." 