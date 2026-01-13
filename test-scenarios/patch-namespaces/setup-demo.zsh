#!/bin/zsh
# setup-demo.zsh - deploy the patch namespaces demo resources

set -e

SCRIPT_DIR="${0:A:h}"

echo "deploying patch namespaces demo resources..."
kubectl apply -f "$SCRIPT_DIR/demo.yaml"

echo "\nwaiting for service account to be created..."
kubectl wait --for=create serviceaccount/namespace-patcher -n patch-namespaces-demo --timeout=30s

echo "\ninitial namespace labels:"
kubectl get namespace patch-namespaces-demo --show-labels

echo "\ndemo resources deployed successfully!"
