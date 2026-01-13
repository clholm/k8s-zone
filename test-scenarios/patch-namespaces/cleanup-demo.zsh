#!/bin/zsh
# cleanup-demo.zsh - remove the patch namespaces demo resources

set -e

SCRIPT_DIR="${0:A:h}"

echo "cleaning up patch namespaces demo resources..."
kubectl delete -f "$SCRIPT_DIR/demo.yaml" --ignore-not-found

echo "cleanup complete! 😌"
