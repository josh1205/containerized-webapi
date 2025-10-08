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
#   ./dev-env.sh start [--api_port_1 PORT] [--api_port_2 PORT] [--api_value_1 VALUE] [--api_value_2 VALUE] [--container_name NAME]
#   ./dev-env.sh stop
#   ./dev-env.sh restart [--api_port_1 PORT] [--api_port_2 PORT] [--api_value_1 VALUE] [--api_value_2 VALUE] [--container_name NAME]
#
# Examples:
#   ./dev-env.sh start --api_port_1 5000 --api_port_2 5001 --api_value_1 "Hello 1" --api_value_2 "Hello 2"
#   ./dev-env.sh stop
#   ./dev-env.sh restart
#===============================================================================

set -e

#################################################################################
# Function: usage
# Displays instructions on how to run the script.
##################################################################################
function usage() {
  echo "Usage: $0 {start|stop|restart} [--api_port_1 PORT] [--api_port_2 PORT] [--api_value_1 VALUE] [--api_value_2 VALUE] [--container_name NAME]"
  echo
  echo "Examples:"
  echo "  $0 start --api_port_1 5000 --api_port_2 5001 --api_value_1 'Hello 1' --api_value_2 'Hello 2'"
  echo "  $0 restart"
  echo "  $0 stop"
}

#################################################################################
# Function: stop
# Stops and removes any running containers for this app
###############################################################################
function stop() {
  # Grabbing container IDs and stopping/removing them by passing them to docker rm command if found
  docker ps --format '{{.Names}}' | grep "${CONTAINER_NAME}-" | xargs -r docker rm -f
  echo "Stopped and removed containers ${CONTAINER_NAME}-1 and ${CONTAINER_NAME}-2 if they were running."
}

#################################################################################
# Function: start
# Builds the Docker image and starts two containers with specified environment
# variables and host port mappings.
#################################################################################
function start() {
  echo "Building Docker image..."

  # Build docker image
  docker build -t $CONTAINER_NAME .

  echo "Running containers 1 and 2..."
  # Run container 1
  docker run -d \
    -e WEB_API_PORT=$WEB_API_PORT_1 \
    -e WEB_API_VALUE="$WEB_API_VALUE_1" \
    -p 8080:$WEB_API_PORT_1 \
    --name "${CONTAINER_NAME}-1" \
    $CONTAINER_NAME

  # Run container 2
  docker run -d \
    -e WEB_API_PORT=$WEB_API_PORT_2 \
    -e WEB_API_VALUE="$WEB_API_VALUE_2" \
    -p 8081:$WEB_API_PORT_2 \
    --name "${CONTAINER_NAME}-2" \
    $CONTAINER_NAME
}

##############################
# Main script execution
##############################

# Default configurations
CONTAINER_NAME="containerized-webapi"
WEB_API_PORT_1=5000
WEB_API_PORT_2=5000
WEB_API_VALUE_1="This is a fun project from Container 1"
WEB_API_VALUE_2="This is a fun project from Container 2"

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
    --api_port_1)
      WEB_API_PORT_1="$2"
      shift 2
      ;;
    --api_port_2)
      WEB_API_PORT_2="$2"
      shift 2
      ;;
    --api_value_1)
      WEB_API_VALUE_1="$2"
      shift 2
      ;;
    --api_value_2)
      WEB_API_VALUE_2="$2"
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

