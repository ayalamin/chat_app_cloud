#!/bin/bash

# Define the usage message
usage() {
  echo "Usage: $0 <-i|-d|-e|-de|-p|-in> [Version] [commit-hash]"
  echo "Options:"
  echo "  -i, --init <Version>                    Build chat-app image with the version provided and run the chat-app container with mounted volumes."
  echo "  -d, --delete <Version>                  Delete chat-app container and the specified chat-app image."
  echo "  -de, --deploy <Version> <commit-hash>   Build, tag, and push the chat-app image with the specified tag to Gitub and tag and push the commit hash"
  echo "  -p, --prune                             Prune all Docker resources."
  echo "  -in, --info                             Show all Doker resorces."
  exit 1
}

# Check for the correct number of arguments
if [ $# -lt 1 ] || [ $# -gt 3 ]; then
  usage
fi

# Directory where script files are located
SCRIPTS_DIR="scripts"

# Parse command line options
while [[ $# -gt 0 ]]; do
  case "$1" in
    -i|--init)
      if [ $# -lt 2 ]; then
        usage
      fi
      echo "Running init.sh with Version: $2"
      ./"$SCRIPTS_DIR"/init.sh "$2"
      shift 2
      ;;
    -d|--delete)
      if [ $# -lt 2 ]; then
        usage
      fi
      echo "Running delete.sh with Version: $2"
      ./"$SCRIPTS_DIR"/delete.sh "$2"
      shift 2
      ;;
    -de|--deploy)
      if [ $# -lt 3 ]; then
        usage
      fi
      echo "Running deploy.sh with Version: $2 and commit-hash: $3"
      ./"$SCRIPTS_DIR"/deploy.sh "$2" "$3"
      shift 3
      ;;
    -p|--prune)
      echo "Running prune.sh"
      ./"$SCRIPTS_DIR"/prune.sh
      shift
      ;;
    -in|--info)
      echo "Running info.sh"
      ./"$SCRIPTS_DIR"/info.sh
      shift
      ;;
    *)
      usage
      ;;
  esac
done
