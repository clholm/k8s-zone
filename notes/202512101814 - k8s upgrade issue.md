# k8s node upgrade issue - stubborn static pod

**problem:**

When running `kubeadm upgrade apply v1.X.X`, the upgrade was getting stuck waiting for the kubelet to restart static pods (specifically `kube-apiserver`, in this instance), even though the manifest files were updated with the new version. The kubelet persistently recreated pods with the old version.

In this case, the kubelet would read the correct v1.33.5 manifest but somehow still create v1.32.3 pods.

**root cause:**

The kubelet was getting confused by:

1. **backup manifest files** in `/etc/kubernetes/manifests/` and `/etc/kubernetes/` with old versions

It also may have been getting confused by:

2. **cached pod state** in `/var/lib/kubelet/pods/`
3. **mirror pod objects in etcd** that persisted the old spec with the old version

**NOTE:** During my debugging, I tried **step 1** below last. My issue probably would've resolved if I had just attempted **step 1** first.

**solution:**
### step 1: remove conflicting backup files (try this first!)

```bash
# move any backup manifest files out of the way
sudo mv /etc/kubernetes/manifests/*.backup /tmp/ 2>/dev/null || true
sudo mv /etc/kubernetes/*.backup /tmp/ 2>/dev/null || true
```

**if step 1 doesn't work, proceed to step 2**
### step 2: clear kubelet state

```bash
# stop kubelet
sudo systemctl stop kubelet

# remove any running containers for the static pod
sudo crictl rm -f $(sudo crictl ps -a --name kube-apiserver -q) 2>/dev/null || true

# clear kubelet's pod cache
sudo rm -rf /var/lib/kubelet/pods/*
```

### step 3: verify and refresh manifest

```bash
# verify the manifest has the correct version
sudo cat /etc/kubernetes/manifests/kube-apiserver.yaml | grep "image:"

# temporarily remove the manifest
sudo mv /etc/kubernetes/manifests/kube-apiserver.yaml /tmp/kube-apiserver-temp.yaml

# move it back immediately (this forces a fresh read)
sudo mv /tmp/kube-apiserver-temp.yaml /etc/kubernetes/manifests/kube-apiserver.yaml
```

### step 4: delete mirror pod from etcd (if needed)

```bash
# delete the stale mirror pod object from etcd
kubectl exec -n kube-system etcd-<node-name> -- sh -c \
  "ETCDCTL_API=3 etcdctl \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  del /registry/pods/kube-system/kube-apiserver-<node-name>"
```

### step 5: restart kubelet

```bash
# start kubelet
sudo systemctl start kubelet

# wait for the pod to recreate (30-60 seconds)
sleep 40

# verify the version
kubectl get pod kube-apiserver-<node-name> -n kube-system -o yaml | grep "image:"
```

## complete workflow for future upgrades

(LLM-generated)

```bash
#!/bin/bash
NODE_NAME="your-node-name"

# 1. move backup files
sudo mv /etc/kubernetes/manifests/*.backup /tmp/ 2>/dev/null || true
sudo mv /etc/kubernetes/*.backup /tmp/ 2>/dev/null || true

# 2. stop kubelet and clear state
sudo systemctl stop kubelet
sudo crictl rm -f $(sudo crictl ps -a --name kube-apiserver -q) 2>/dev/null || true
sudo rm -rf /var/lib/kubelet/pods/*

# 3. delete etcd mirror pod
kubectl exec -n kube-system etcd-${NODE_NAME} -- sh -c \
  "ETCDCTL_API=3 etcdctl \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  del /registry/pods/kube-system/kube-apiserver-${NODE_NAME}"

# 4. refresh manifest
sudo mv /etc/kubernetes/manifests/kube-apiserver.yaml /tmp/kube-apiserver-temp.yaml
sudo mv /tmp/kube-apiserver-temp.yaml /etc/kubernetes/manifests/kube-apiserver.yaml

# 5. start kubelet
sudo systemctl start kubelet

# 6. wait and verify the version
sleep 40
kubectl get pod kube-apiserver-${NODE_NAME} -n kube-system -o yaml | grep "image:"
```
