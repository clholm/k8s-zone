## creating user with cert authentication and k8s rbac

### step 1: generate keys and csr on macbook

```bash
# generate private key
openssl genrsa -out cholm.key 2048

# create certificate signing request (CSR)
openssl req -new -key cholm.key -out cholm.csr -subj "/CN=cholm/O=admin"
```

### step 2: scp csr to control plane node to sign

```bash
# copy csr to the control plane for signing
scp cholm.csr user@control-plane-node-ip:~/k8s/
```

### step 3: sign the cert from the control plane

```bash
# ssh to the control plane
ssh user@control-plane-node-ip

# sign the CSR with cluster's CA
openssl x509 -req -in cholm.csr -CA /etc/kubernetes/pki/ca.crt -CAkey /etc/kubernetes/pki/ca.key -CAcreateserial -out cholm.crt -days 365

# exit the control plane node
ctrl+D
# retrieve the cert from the macbook
scp user@control-plane-node-ip:~/k8s/cholm.crt .
```

step 4: configure kubectl context to use the cert on the macbook

```bash
# retrieve ca.crt from the control plane for config setup
scp user@control-plane-node-ip:/etc/kubernetes/pki/ca.crt .
# set up the cluster in kubeconfig
kubectl config set-cluster laptop-cluster --server=https://control-plane-ip:6443 --certificate-authority=ca.crt

# add user credentials
kubectl config set-credentials cholm --client-certificate=cholm.crt --client-key=cholm.key

# create and use context
kubectl config set-context cholm-laptop-cluster --cluster=laptop-cluster --user=cholm
kubectl config use-context cholm-laptop-cluster
```

### step 5 create rbac permissions on the control plane

for read-only access to certain resources:

```bash
# create a role with limited permissions
kubectl create role developer --verb=get,list,watch --resource=pods,deployments,services

# bind the role to your user
kubectl create rolebinding cholm-developer --role=developer --user=cholm
```

for cluster-admin privileges:

```bash
# access control-plane node
ssh user@control-plane-node-ip

# give user cluster-admin role
kubectl create clusterrolebinding cholm-cluster-admin --clusterrole=cluster-admin --user=cholm
```

## test the connection (from the macbook)

```bash
# verify access to cluster
kubectl get nodes
```

periodically rotate certificates for security (this configuration should not be used for production clusters)