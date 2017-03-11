K8s Manully Installation
===========================


## 1. Environment
- 3 Centos7 VM: kube1, kube2, kube3
- linux kernel version: 3.10.0
- kube1 as master, kube2 and kube3 as nodes
- kube1: 122.54
- kube2: 122.52
- kube3: 122.53

## 2. master
### 2.1 etcd service
```
  sudo wget https://github.com/coreos/etcd/releases/download/v3.1.2/etcd-v3.1.2-linux-amd64.tar.gz

  sudo tar -zxf etcd-v3.1.2-linux-amd64.tar.gz
  sudo cp etc etcdctl /usr/bin

  # in /usr/lib/systemd/system/etcd.service
    [Unit]
    Description=Etcd Server
    After=network.target

    [Service]
    Type=simple
    WorkingDirectory=/var/lib/etcd/
    EnvironmentFile=/etc/etcd/etcd.conf
    ExecStart=/usr/bin/etcd

    [Install]
    WantedBy=multi-user.target

  # etcd service default listening port:
  # 127.0.0.1:2379

  # in /etc/etcd/etcd.conf
  # can just use default config from
  # https://github.com/coreos/etcd/blob/master/etcd.conf.yml.sample

  sudo systemctl daemon-reload
  sudo systemctl enable etcd
  sudo systemctl start etcd

  sudo etcdctl cluster-health
  # output: member 378f84a502d92f72 is healthy: got healthy result from http://localhost:2379
cluster is healthy
```

### 2.2 kube-apiserver service
```
  sudo wget https://github.com/kubernetes/kubernetes/releases/download/v1.5.4/kubernetes.tar.gz
  sudo tar -zxf kubernetes.tar.gz
  cd ~/kubernetes/cluster
  sudo ./get-kube-binaries.sh
  cd ~/kubernetes/server
  sudo tar -zxf kubernetes-server-linux-amd64.tar.gz
  cd ~/kubernetes/server/kubernetes/server/bin

  sudo cp kube-apiserver /usr/bin

  # in /usr/lib/systemd/system/kube-apiserver.service
    [Unit]
    Description=Kubernetes API Server
    Documentation=https://github.com/GoogleCloudPlatform/kubernetes
    After=etcd.service
    Wants=etcd.service

    [Service]
    EnvironmentFile=/etc/kubernetes/apiserver
    ExecStart=/usr/bin/kube-apiserver $KUBE_API_ARGS
    Restart=on-failure
    Type=notify
    LimitNOFILE=65536

    [Install]
    WantedBy=multi-user.target

  # in /etc/kubernetes/apiserver
    KUBE_API_ARGS="--etcd_servers=http://127.0.0.1:2379 --insecure-bind-address=0.0.0.0 --insecure-port=8080 --service-cluster-ip-range=169.169.0.0/16 --service-node-port-range=1-65535 --admission_control=NamespaceLifecycle,LimitRanger,SecurityContextDeny,ServiceAccount,ResourceQuota --logtostderr=false --log-dir=/var/log/kubernetes --v=2"
```

### 2.3 kube-controller-manager service
- kube-controller-manager service rely on kube-apiserver service

```
  cd ~/kubernetes/server/kubernetes/server/bin
  sudo cp kube-controller-manager /usr/bin

  # in /usr/lib/systemd/system/kube-controller-manager.service
    [Unit]
    Description=Kubernetes Controller Manager
    Documentation=https://github.com/GoogleCloudPlatform/kubernetes
    After=kube-apiserver.service
    Requires=kube-apiserver.service

    [Service]
    EnvironmentFile=/etc/kubernetes/controller-manager
    ExecStart=/usr/bin/kube-controller-manager $KUBE_CONTROLLER_MANAGER_ARGS
    Restart=on-failure
    Type=notify
    LimitNOFILE=65536

    [Install]
    WantedBy=multi-user.target

  # in /etc/kubernetes/controller-manager
    KUBE_CONTROLLER_MANAGER_ARGS="--master=http://192.168.122.54:8080 --logtostderr=false --log-dir=/var/log/kubernetes --v=2"
```

### 2.4 kube-scheduler service
- kube-scheduler service rely on kube-apiserver service

```
  cd ~/kubernetes/server/kubernetes/server/bin
  sudo cp kube-scheduler /usr/bin

  # in /usr/lib/systemd/system/kube-scheduler.service
    [Unit]
    Description=Kubernetes Scheduler
    Documentation=https://github.com/GoogleCloudPlatform/kubernetes
    After=kube-apiserver.service
    Requires=kube-apiserver.service

    [Service]
    EnvironmentFile=/etc/kubernetes/scheduler
    ExecStart=/usr/bin/kube-scheduler $KUBE_SCHEDULER_ARGS
    Restart=on-failure
    Type=notify
    LimitNOFILE=65536

    [Install]
    WantedBy=multi-user.target

  # in /etc/kubernetes/scheduler
    KUBE_SCHEDULER_ARGS="--master=http://192.168.122.54:8080 --logtostderr=false --log-dir=/var/log/kubernetes --v=2"
```

### 2.5 start service
```
  sudo systemctl daemon-reload
  sudo systemctl enable kube-apiserver.service
  sudo systemctl start kube-apiserver.service
  sudo systemctl enable kube-controller-manager.service
  sudo systemctl start kube-controller-manager.service

    Mar 10 19:18:40 qiwei-kube1 kube-controller-manager[24468]: E0310 19:18:40.360716   24468 controllermanager.go:305] Failed to start service controller: WARNING: no cloud provider provided, services of type LoadBalancer will fail.
    Mar 10 19:18:40 qiwei-kube1 kube-controller-manager[24468]: E0310 19:18:40.361519   24468 util.go:45] Metric for replenishment_controller already registered
    Mar 10 19:18:40 qiwei-kube1 kube-controller-manager[24468]: E0310 19:18:40.361547   24468 util.go:45] Metric for replenishment_controller already registered
    Mar 10 19:18:40 qiwei-kube1 kube-controller-manager[24468]: E0310 19:18:40.361556   24468 util.go:45] Metric for replenishment_controller already registered
    Mar 10 19:18:40 qiwei-kube1 kube-controller-manager[24468]: E0310 19:18:40.361569   24468 util.go:45] Metric for replenishment_controller already registered
    Mar 10 19:18:40 qiwei-kube1 kube-controller-manager[24468]: E0310 19:18:40.361577   24468 util.go:45] Metric for replenishment_controller already registered
    Mar 10 19:18:40 qiwei-kube1 kube-controller-manager[24468]: E0310 19:18:40.390091   24468 controllermanager.go:558] Failed to start certificate controller: open /etc/kubernetes/ca/ca.pem: no such file or directory

```
