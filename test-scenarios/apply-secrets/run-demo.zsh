#!/bin/zsh
# run-demo.zsh - deploy the apply secrets demo resources

set -e

echo "deploying secrets demo resources..."
kubectl apply -f demo.yaml

echo "\nwaiting for secrets to be created..."
kubectl wait --for=create secret/db-credentials -n apply-secrets-demo --timeout=30s
kubectl wait --for=create secret/api-key -n apply-secrets-demo --timeout=30s

echo "\ndemo resources deployed successfully!"