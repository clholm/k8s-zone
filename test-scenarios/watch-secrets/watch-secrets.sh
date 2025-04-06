#!/bin/bash

# colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # no Color

NAMESPACE="secrets-watch-demo"

echo -e "${BLUE}=== Starting Simple Secret Watch Demo ===${NC}"
echo "This script will watch for changes to secrets in the $NAMESPACE namespace"
echo

# Use kubectl watch with simpler output format
echo -e "${BLUE}Watching secrets in namespace: $NAMESPACE${NC}"
echo "Press Ctrl+C to exit the watch"
echo

# show initial state
echo -e "${YELLOW}Initial state of secrets:${NC}"
kubectl get secrets -n $NAMESPACE -o wide
echo

# watch for changes
echo -e "${BLUE}-------------"
echo -e "${YELLOW}Starting watch - you'll see updates here when secrets change:${NC}"
# add -o yaml to the line below if you want to see how --watch provides the ability
# to retrieve secret data
kubectl get secrets -n $NAMESPACE --watch