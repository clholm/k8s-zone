#!/bin/zsh
# run-demo.zsh - test patching namespace labels with only patch permission (no get)

set -e

echo "getting token for label-patcher service account..."
TOKEN="$(kubectl create token namespace-patcher -n patch-namespaces-demo)"

echo "getting api server address..."
APISERVER="$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')"

echo "\nattempting to patch namespace labels (changing environment: staging -> production)..."
echo "using only PATCH permission (no GET)...\n"

RESPONSE=$(curl -sk -X PATCH "$APISERVER/api/v1/namespaces/patch-namespaces-demo" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/strategic-merge-patch+json" \
  -d '{"metadata":{"labels":{"environment":"production"}}}' \
  -w "\n%{http_code}" 2>&1)

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')

echo "response body:"
echo "$BODY" | jq . 2>/dev/null || echo "$BODY"

echo "\nhttp status code: $HTTP_CODE"

echo "\nnamespace labels after patch attempt:"
kubectl get namespace patch-namespaces-demo --show-labels
