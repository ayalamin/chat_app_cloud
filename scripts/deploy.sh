#!/bin/bash

# Function to handle errors

handle_error() {
  echo "Error: $1"
  exit 1
}

version=$1
commit_hash=$2


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

git tag "$version" "$commit_hash" || handle_error "Failed to tag the commit"

docker build -t chat-app:$version . || handle_error "Failed to build the image"

git push origin "$version" || handle_error "Failed to push to GitHub"

# Ask user if they want to push the image to Artifact Registry
read -p "Do you want to push the image to Artifact Registry? (y/n): " push_image

if [ "$push_image" == "y" ]; then

# Authenticate with service account impersonation
# gcloud auth activate-service-account --key-file=path/to/artifact-admin-sa-key.json --impersonate-service-account=artifact-admin-sa@grunitech-mid-project.iam.gserviceaccount.com



gcloud config set auth/impersonate_service_account artifact-admin-sa@grunitech-mid-project.iam.gserviceaccount.com
gcloud auth configure-docker me-west1-docker.pkg.dev

docker tag chat-app:$version me-west1-docker.pkg.dev/grunitech-mid-project/ayala-chat-app-images/chat-app:$version
docker push me-west1-docker.pkg.dev/grunitech-mid-project/ayala-chat-app-images/chat-app:$version


  # echo "Image pushed to Artifact Registry."
else
  echo "Skipping image push to Artifact Registry."
fi

