Try Kubernetes
===============

- this is to start a hello world web app on one machine using kubernetes

## 1. Install Kubernetes
```
systemctl disable firewalld
systemctl stop firewalld

yum install -y etcd kubernetes
```

## 2. Config Kubernetes
```
# in /etc/sysconfig/docker
OPTIONS='--selinux-enabled=false --insecure-registry gcr.io'

# in /etc/kubernetes/apiserver
delete ServiceAccount from --admission_control

systemctl start etcd
systemctl start docker
systemctl start kube-apiserver
systemctl start kube-controller-manager
systemctl start kube-scheduler
systemctl start kubelet
systemctl start kube-proxy
```

## 3. Config and Start a mysql container
```
# create file mysql-rc.yaml to start a ResourceController
apiVersion: v1
kind: ReplicationController
metadata:
  name: mysql
spec:
  replicas: 1
  selector:
    app: mysql
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
      - name: mysql
        image: mysql
        ports:
        - containerPort: 3306
        env:
        - name: MYSQL_ROOT_PASSWORD
          value: "123456"

kubectl create -f mysql-rc.yaml

# create file mysql-svc.yaml to start a mysql service
mysql-svc.yaml
apiVersion: v1
kind: Service
metadata:
  name: mysql
spec:
  ports:
    - port: 3306
  selector:
    app: mysql

kubectl create -f mysql-svc.yaml
```

## 4. Config and Start a Tomcat Container
```
# create file myweb-rc.yaml to start a Tomcat ResourceController
apiVersion: v1
kind: ReplicationController
metadata:
  name: myweb
spec:
  replicas: 5
  selector:
    app: myweb
  template:
    metadata:
      labels:
        app: myweb
    spec:
      containers:
        - name: myweb
          image: kubeguide/tomcat-app:v1
          ports:
          - containerPort: 8080
          env:
          - name: MYSQL_SERVICE_HOST
            value: 'mysql'
          - name: MYSQL_SERVICE_PORT
            value: '3306'

kubectl create -f myweb-rc.yaml

# create file myseb-svc.yaml to start a Tomcat Service
apiVersion: v1
kind: Service
metadata:
  name: myweb
spec:
  type: NodePort
  ports:
    - port: 8080
      nodePort: 30001
  selector:
    app: myweb

kubectl create -f myweb-svc.yaml
```
