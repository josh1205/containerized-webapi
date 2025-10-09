#!/bin/bash
#===============================================================================
# dev-env.sh
#
# This script manages the lifecycle of a containerized web API for development.
# It allows you to start, stop, or restart two containers with configurable
# environment variables and host ports. Default values are provided, but can be
# overridden via command line arguments.
#
# Usage:
#   ./dev-env.sh start [--api_port PORT] [--api_value VALUE] [--container_name NAME]
#   ./dev-env.sh stop
#   ./dev-env.sh restart [--api_port PORT] [--api_value VALUE] [--container_name NAME]
#
# Examples:
#   ./dev-env.sh start --api_port 5000 --api_value "Hello 1"
#   ./dev-env.sh stop
#   ./dev-env.sh restart
#===============================================================================

set -e

#################################################################################
# Function: usage
# Displays instructions on how to run the script.
##################################################################################
function usage() {
  echo "Usage: $0 {start|stop|restart} [--api_port PORT] [--api_value VALUE] [--container_name NAME]"
  echo
  echo "Examples:"
  echo "  $0 start --api_port 5000 --api_value 'Hello 1'"
  echo "  $0 restart"
  echo "  $0 stop"
}

#################################################################################
# Function: stop
# Stops and removes any running containers for this app
###############################################################################
function stop() {
  # Grabbing container IDs and stopping/removing them by passing them to docker rm command if found
  if docker ps --format '{{.Names}}' | grep "${CONTAINER_NAME}-" | xargs -r docker rm -f; then
    echo "Stopped and removed containers ${CONTAINER_NAME}-1 and ${CONTAINER_NAME}-2 if they were running."
  else
    echo "Error occurred while stopping/removing containers or no containers were running."
  fi
}

#################################################################################
# Function: start
# Builds the Docker image and starts two containers with specified environment
# variables and host port mappings.
#################################################################################
function start() {
  echo "Building Docker image..."

  # Build docker image
  docker build -t $CONTAINER_NAME:latest ..

  echo "Running containers 1 and 2..."
  # Run container 1
  docker run -d \
    -e WEB_API_PORT=$WEB_API_PORT \
    -e WEB_API_VALUE="$WEB_API_VALUE" \
    -p 8081:$WEB_API_PORT \
    --name "${CONTAINER_NAME}-1" \
    $CONTAINER_NAME

  # Run container 2
  docker run -d \
    -e WEB_API_PORT=$WEB_API_PORT \
    -e WEB_API_VALUE="$WEB_API_VALUE" \
    -p 8082:$WEB_API_PORT \
    --name "${CONTAINER_NAME}-2" \
    $CONTAINER_NAME
}

##############################
# Main script execution
##############################

# Default configurations
CONTAINER_NAME="containerized-webapi"
WEB_API_PORT=5001
WEB_API_VALUE="This is a fun project"

# First argument must be the command
if [[ $# -lt 1 ]]; then
  echo "Error: No command provided."
  usage
  exit 1
fi

COMMAND=$1
shift

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --api_port)
      WEB_API_PORT="$2"
      shift 2
      ;;
    --api_value)
      WEB_API_VALUE="$2"
      shift 2
      ;;
    --container_name)
      CONTAINER_NAME="$2"
      shift 2
      ;;
    *)
      echo "Unknown parameter or action: $1"
      usage
      exit 1
      ;;
  esac
done

# Handle commands
case $COMMAND in
  start)
    stop
    start
    ;;
  stop)
    stop
    ;;
  restart)
    # Same functionality as start but in case logic should be added in the future
    stop
    start
    ;;
  *)
    echo "Usage: $0 {start|stop|restart}"
    usage
    exit 1
    ;;
esac

