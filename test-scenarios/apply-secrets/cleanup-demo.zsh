#!/bin/zsh
# cleanup-demo.zsh - remove the apply secrets demo resources

set -e

echo "cleaning up secrets demo resources..."
kubectl delete -f demo.yaml --ignore-not-found

echo "cleanup complete! 😌"