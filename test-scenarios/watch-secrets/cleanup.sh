#!/bin/bash

# colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # no Color

echo -e "${BLUE}=== Secret Watch Demo Cleanup ===${NC}"

# delete deployment, service, and configmap
echo -e "${YELLOW}Deleting deployment, service, and configmap...${NC}"
kubectl delete -f deployment.yaml --ignore-not-found
echo

# delete test pod
echo -e "${YELLOW}Deleting test pod...${NC}"
kubectl delete -f test-pods.yaml --ignore-not-found
echo

# delete secrets
echo -e "${YELLOW}Deleting secrets...${NC}"
kubectl delete -f initial-secrets.yaml --ignore-not-found
kubectl delete -f updated-secrets.yaml --ignore-not-found
echo

# delete namespace (this will delete all resources in the namespace)
echo -e "${YELLOW}Deleting namespace...${NC}"
kubectl delete -f namespace.yaml --ignore-not-found
echo

# verify all resources are gone
echo -e "${YELLOW}Verifying all resources are removed:${NC}"
kubectl get all,secrets -n secrets-watch-demo 2>/dev/null || echo -e "${GREEN}Namespace and all resources successfully removed.${NC}"

echo -e "${GREEN}Cleanup complete!${NC}"