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

  sudo systemctl daemon-reload
  sudo systemctl enable etcd
  sudo systemctl start etcd

  # error:
  Job for etcd.service failed because a configured resource limit was exceeded. See "systemctl status etcd.service" and "journalctl -xe" for details.

  
```
