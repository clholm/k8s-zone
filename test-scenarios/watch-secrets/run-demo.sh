#!/bin/bash

# colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # no Color

echo -e "${BLUE}=== Secret Watch Demo Setup ===${NC}"

# create namespace
echo -e "${YELLOW}Creating namespace...${NC}"
kubectl apply -f namespace.yaml
echo

# create initial secrets
echo -e "${YELLOW}Creating initial secrets...${NC}"
kubectl apply -f initial-secrets.yaml
echo

# display the created secrets
echo -e "${YELLOW}Initial secrets created:${NC}"
kubectl get secrets -n secrets-watch-demo
echo

# create test pod
echo -e "${YELLOW}Creating test pod...${NC}"
kubectl apply -f test-pod.yaml
echo

# wait for pod to be ready
echo -e "${YELLOW}Waiting for pod to be ready...${NC}"
kubectl wait --for=condition=Ready pod/secrets-test-pod -n secrets-watch-demo --timeout=60s
echo

# show pod logs
echo -e "${YELLOW}Pod logs showing mounted secrets:${NC}"
kubectl logs secrets-test-pod -n secrets-watch-demo
echo

# create deployment, service, and configmap
echo -e "${YELLOW}Creating deployment, service, and configmap...${NC}"
kubectl apply -f deployment.yaml
echo

# wait for deployment to be ready
echo -e "${YELLOW}Waiting for deployment to be ready...${NC}"
kubectl wait --for=condition=Available deployment/app-deployment -n secrets-watch-demo --timeout=60s
echo

# show deployed resources
echo -e "${YELLOW}Deployed resources:${NC}"
kubectl get all -n secrets-watch-demo
echo

echo -e "${GREEN}Demo setup complete!${NC}"
echo
echo -e "${BLUE}Next steps:${NC}"
echo "1. In another terminal, run: ./watch-secrets.sh"
echo "2. After starting the watch, run: kubectl apply -f updated-secrets.yaml"
echo "3. Observe how the watch detects and displays the changes"
echo "4. When finished, run: ./cleanup.sh"
echo
echo -e "${YELLOW}To see the pod logs continuously:${NC}"
echo "kubectl logs -f secrets-test-pod -n secrets-watch-demo"