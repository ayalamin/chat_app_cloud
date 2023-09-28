#!/bin/bash

# Define your Artifact Registry repository information
HOSTNAME="me-west1-docker.pkg.dev"
PROJECT_ID="grunitech-mid-project"
REPO_NAME="ayala-chat-app-images"

# Get the desired version from the user
read -p "Enter the desired version/tag for the Docker image: " VERSION

# Check if the image exists locally
if docker images | grep -q "chat-app:${VERSION}"; then
  # Image already exists locally
  IMAGE_EXISTS=true
else
  # Image does not exist locally, so you can choose to build or pull it here
  # For example, you can build the image using a Dockerfile:
  docker build -t chat-app:${VERSION} .

  # Alternatively, you can pull the image from a registry if it's available:
  # docker pull registry.example.com/chat-app:${VERSION}

  IMAGE_EXISTS=false
fi

# Prompt the user to push the image to Artifact Registry
read -p "Do you want to push the image to Artifact Registry? (y/n): " PUSH_IMAGE

if [[ $PUSH_IMAGE == "y" ]]; then
  # Authenticate with the service account (replace KEY_FILE_PATH with your key file path)
  #gcloud auth activate-service-account artifact-admin-sa@grunitech-mid-project.iam.gserviceaccount.com --key-file=KEY_FILE_PATH
gcloud config set auth/impersonate_service_account artifact-admin-sa@grunitech-mid-project.iam.gserviceaccount.com

  # Configure Docker to authenticate with Artifact Registry
  gcloud auth configure-docker $HOSTNAME

  # Tag the Docker image with the specified version
  docker tag chat-app:${VERSION} $HOSTNAME/$PROJECT_ID/$REPO_NAME/chat-app:${VERSION}

  # Push the Docker image to Artifact Registry
  docker push $HOSTNAME/$PROJECT_ID/$REPO_NAME/chat-app:${VERSION}

  # Check if the push was successful
  if [[ $? -eq 0 ]]; then
    echo "Image successfully pushed to Artifact Registry."
  else
    echo "Error: Image push to Artifact Registry failed."
  fi
else
  echo "Image was not pushed to Artifact Registry."
fi



read c