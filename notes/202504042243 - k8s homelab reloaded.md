I had to install a new OS (Linux Mint) on all of my laptops because the wireless driver broke on their Ubuntu installations.

https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/
installing version 1.32

1. disable swap by commenting out `/swapfile` in `/etc/fstab`
2. install `containerd`:
```
wget https://github.com/containerd/containerd/releases/download/v2.0.4/containerd-2.0.4-linux-amd64.tar.gz
tar -zxvf containerd-2.0.4-linux-amd64.tar.gz
cd ./bin
sudo mv * /usr/local/bin
cd ..
wget https://raw.githubusercontent.com/containerd/containerd/main/containerd.service
sudo mv containerd.service /usr/lib/systemd/system/
sudo systemctl daemon-reload
systemctl enable --now containerd
systemctl status containerd.service
```
3. install `runc`
```
wget https://github.com/opencontainers/runc/releases/download/v1.2.6/runc.amd64
sudo install -m 755 runc.amd64 /usr/local/sbin/runc
runc -v
```
4. install `cni-plugins`
```
wget https://github.com/containernetworking/plugins/releases/download/v1.6.2/cni-plugins-linux-amd64-v1.6.2.tgz
sudo mkdir -p /opt/cni/bin
sudo tar Cxzvf /opt/cni/bin cni-plugins-linux-amd64-v1.6.2.tgz
```
5. then I followed the instructions for installing the other components using the package manager
6.  https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/
```
sudo su
modprobe br_netfilter
echo 1 > /proc/sys/net/bridge/bridge-nf-call-iptables
echo 1 > /proc/sys/net/ipv4/ip_forward
```
 then
```
kubeadm init
```

7. https://docs.cilium.io/en/latest/gettingstarted/k8s-install-default/
```
CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)
CLI_ARCH=amd64
if [ "$(uname -m)" = "aarch64" ]; then CLI_ARCH=arm64; fi
curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
sha256sum --check cilium-linux-${CLI_ARCH}.tar.gz.sha256sum
sudo tar xzvfC cilium-linux-${CLI_ARCH}.tar.gz /usr/local/bin
rm cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
```

```
git clone git@github.com:cilium/cilium.git
cd cilium
cilium install --chart-directory ./install/kubernetes/cilium
cilium status --wait
```
8. Now join the worker nodes using the `kubeadm join`  command!