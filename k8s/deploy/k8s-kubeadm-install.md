Install Kubernetes by kubeadm
===============================

## 1. Environment
- 3 Centos7 VM: kube1, kube2, kube3
- linux kernel version: 3.10.0
- kube1 as master, kube2 and kube3 as nodes
- kube1: 122.119
- kube2: 122.52
- kube3: 122.53

## 2. Install Components and Prerequisites
- This should be done on all nodes including master and node.

```
  cat <<EOF > /etc/yum.repos.d/kubernetes.repo
  [kubernetes]
  name=Kubernetes
  baseurl=http://yum.kubernetes.io/repos/kubernetes-el7-x86_64
  enabled=1
  gpgcheck=1
  repo_gpgcheck=1
  gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
         https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
  EOF
  setenforce 0
  # if error like package *.rpm is not signed
  # add --nogpgcheck when install kubelet, kubeadm, kubectl and kubernetes-cni
  yum install -y docker kubelet kubeadm kubectl kubernetes-cni
  systemctl enable docker && systemctl start docker
  systemctl enable kubelet && systemctl start kubelet
```

## 3. Initialize master
```
  kubeadm init
  # output:
  [kubeadm] WARNING: kubeadm is in alpha, please do not use it for production clusters.
  [preflight] Running pre-flight checks
  [init] Using Kubernetes version: v1.5.4
  [tokens] Generated token: "f0a13d.0c25278b054fd6c2"
  [certificates] Generated Certificate Authority key and certificate.
  [certificates] Generated API Server key and certificate
  [certificates] Generated Service Account signing keys
  [certificates] Created keys and certificates in "/etc/kubernetes/pki"
  [kubeconfig] Wrote KubeConfig file to disk: "/etc/kubernetes/kubelet.conf"
  [kubeconfig] Wrote KubeConfig file to disk: "/etc/kubernetes/admin.conf"
  [apiclient] Created API client, waiting for the control plane to become ready
  [apiclient] All control plane components are healthy after 43.784869 seconds
  [apiclient] Waiting for at least one node to register and become ready
  [apiclient] First node is ready after 4.002290 seconds
  [apiclient] Creating a test deployment
  [apiclient] Test deployment succeeded
  [token-discovery] Created the kube-discovery deployment, waiting for it to become ready
  [token-discovery] kube-discovery is ready after 14.502193 seconds
  [addons] Created essential addon: kube-proxy
  [addons] Created essential addon: kube-dns

  Your Kubernetes master has initialized successfully!

  You should now deploy a pod network to the cluster.
  Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
      http://kubernetes.io/docs/admin/addons/

  You can now join any number of machines by running the following on each node:

  kubeadm join --token=f0a13d.0c25278b054fd6c2 192.168.122.119
  # the above line is important and will be executed when adding nodes
```

- check status

  ```
  [centos@qiwei-kube1 ~]$ sudo kubectl get nodes
  NAME          STATUS         AGE
  qiwei-kube1   Ready,master   9m

  [centos@qiwei-kube1 ~]$ sudo kubectl get pods --all-namespaces
  NAMESPACE     NAME                                  READY     STATUS              RESTARTS   AGE
  kube-system   dummy-2088944543-llz3v                1/1       Running             0          9m
  kube-system   etcd-qiwei-kube1                      1/1       Running             0          8m
  kube-system   kube-apiserver-qiwei-kube1            1/1       Running             0          9m
  kube-system   kube-controller-manager-qiwei-kube1   1/1       Running             0          9m
  kube-system   kube-discovery-1769846148-k667b       1/1       Running             0          9m
  kube-system   kube-dns-2924299975-ckd5d             0/4       ContainerCreating   0          9m
  kube-system   kube-proxy-vcf7d                      1/1       Running             0          9m
  kube-system   kube-scheduler-qiwei-kube1            1/1       Running             0          8m

  # dns will be ready after setting up network
  ```

## 4. Installing a pod network
  ```
  [centos@qiwei-kube1 ~]$ sudo kubectl apply -f https://git.io/weave-kube
  daemonset "weave-net" created

  [centos@qiwei-kube1 ~]$ sudo kubectl get pods --all-namespaces
  NAMESPACE     NAME                                  READY     STATUS    RESTARTS   AGE
  kube-system   dummy-2088944543-llz3v                1/1       Running   0          15m
  kube-system   etcd-qiwei-kube1                      1/1       Running   0          14m
  kube-system   kube-apiserver-qiwei-kube1            1/1       Running   0          15m
  kube-system   kube-controller-manager-qiwei-kube1   1/1       Running   0          15m
  kube-system   kube-discovery-1769846148-k667b       1/1       Running   0          15m
  kube-system   kube-dns-2924299975-ckd5d             4/4       Running   0          15m
  kube-system   kube-proxy-vcf7d                      1/1       Running   0          15m
  kube-system   kube-scheduler-qiwei-kube1            1/1       Running   0          14m
  kube-system   weave-net-6dgxr                       2/2       Running   0          1m
  ```

## 5. Add nodes
```
# ssh into the other 2 nodes: 122.52 and 122.53 and do this
[centos@qiwei-kube2 ~]$ sudo kubeadm join --token=f0a13d.0c25278b054fd6c2 192.168.122.119

[kubeadm] WARNING: kubeadm is in alpha, please do not use it for production clusters.
[preflight] Running pre-flight checks
[tokens] Validating provided token
[discovery] Created cluster info discovery client, requesting info from "http://192.168.122.119:9898/cluster-info/v1/?token-id=f0a13d"
[discovery] Cluster info object received, verifying signature using given token
[discovery] Cluster info signature and contents are valid, will use API endpoints [https://192.168.122.119:6443]
[bootstrap] Trying to connect to endpoint https://192.168.122.119:6443
[bootstrap] Detected server version: v1.5.4
[bootstrap] Successfully established connection with endpoint "https://192.168.122.119:6443"
[csr] Created API client to obtain unique certificate for this node, generating keys and certificate signing request
[csr] Received signed certificate from the API server:
Issuer: CN=kubernetes | Subject: CN=system:node:qiwei-kube2 | CA: false
Not before: 2017-03-11 00:51:00 +0000 UTC Not After: 2018-03-11 00:51:00 +0000 UTC
[csr] Generating kubelet configuration
[kubeconfig] Wrote KubeConfig file to disk: "/etc/kubernetes/kubelet.conf"

Node join complete:
* Certificate signing request sent to master and response
  received.
* Kubelet informed of new secure connection details.

Run 'kubectl get nodes' on the master to see this machine join.

# do the same thing on 122.53
# after check in master to see if adding nodes successfully
[centos@qiwei-kube1 ~]$ sudo kubectl get nodes
NAME          STATUS         AGE
qiwei-kube1   Ready,master   27m
qiwei-kube2   Ready          7m
qiwei-kube3   Ready          6s

[centos@qiwei-kube1 ~]$ sudo kubectl get pods --all-namespaces
NAMESPACE     NAME                                  READY     STATUS    RESTARTS   AGE
kube-system   dummy-2088944543-llz3v                1/1       Running   0          32m
kube-system   etcd-qiwei-kube1                      1/1       Running   0          31m
kube-system   kube-apiserver-qiwei-kube1            1/1       Running   0          32m
kube-system   kube-controller-manager-qiwei-kube1   1/1       Running   0          32m
kube-system   kube-discovery-1769846148-k667b       1/1       Running   0          32m
kube-system   kube-dns-2924299975-ckd5d             4/4       Running   0          32m
kube-system   kube-proxy-fsdr9                      1/1       Running   0          4m
kube-system   kube-proxy-vcf7d                      1/1       Running   0          32m
kube-system   kube-proxy-wh2w1                      1/1       Running   0          12m
kube-system   kube-scheduler-qiwei-kube1            1/1       Running   0          31m
kube-system   weave-net-6dgxr                       2/2       Running   0          18m
kube-system   weave-net-w56fw                       2/2       Running   1          4m
kube-system   weave-net-x4bqd                       2/2       Running   0          12m
```
