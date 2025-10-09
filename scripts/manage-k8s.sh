#!/bin/bash
#===============================================================================
# manage-k8s.sh
#
# This script automates the management of the containerized web API application
# in a Kubernetes cluster. It provides options to deploy, update, or delete
# resources in the cluster.
#
# Usage:
#   ./manage-k8s.sh {deploy|scrap|upgrade}
# Examples:
#   ./manage-k8s.sh deploy
#   ./manage-k8s.sh scrap
#   ./manage-k8s.sh upgrade
#===============================================================================

set -e

function usage() {
  echo "Usage: $0 {deploy|scrap|upgrade}"
  echo
  echo "Examples:"
  echo "  $0 deploy"
  echo "  $0 scrap"
  echo "  $0 upgrade"
}

function deploy() {
  local -r action=${1:-"deploy"}

  echo "Applying Kubernetes manifests..."

  kubectl apply -f "$K8S_DIR"/namespace.yaml
  kubectl config set-context --current --namespace="$NAMESPACE"

  for file in "$K8S_DIR"/*.yaml; do
    # Skip namespace.yaml as it's already applied
    if [[ "$(basename "$file")" == "namespace.yaml" ]]; then
      continue
    fi

    echo "Applying $file..."
    kubectl apply -f "$file"
  done
  echo "Kubernetes manifests applied."

  if [[ "$action" == "upgrade" ]]; then
    echo "Waiting for deployment rollout to complete..."
    kubectl rollout restart deployment/"$DEPLOYMENT_NAME" -n "$NAMESPACE"
  fi

  kubectl get all -n "$NAMESPACE"
}

function scrap() {
    echo "Scrapping Kubernetes resources in namespace $NAMESPACE..."
    kubectl delete namespace "$NAMESPACE" || echo "Namespace $NAMESPACE does not exist or could not be deleted."
    echo "Scrapping completed."
}

##############################
# Main script execution
##############################
K8S_DIR="../k8s"
NAMESPACE="flask-app"
DEPLOYMENT_NAME="containerized-webapi-deployment"

# First argument must be the command
if [[ $# -lt 1 ]]; then
  echo "Error: No command provided."
  usage
  exit 1
fi

COMMAND=$1

# Handle commands
case $COMMAND in
  deploy)
    deploy
    ;;
  scrap)
    scrap
    ;;
  upgrade)
    deploy "upgrade"
    ;;
  *)
    echo "Usage: $0 {start|stop|restart}"
    usage
    exit 1
    ;;
esac