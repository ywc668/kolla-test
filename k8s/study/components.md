k8s components
================


### 1. k8s master
- kube-api-server: only entrance for all operations, supporting RESTful API
- kube-controller-manager: manage all resources allocating and deploying
- kube-schedule: manage all pods' processess
- etcd: preserve all data about resource objects in k8s


### 2. k8s node
#### 2.1 mechanism
- responsible for the real work
- will be distributed some work load from master
- dynamically allocated
- node will register itself to master by default
- push mode to master to report system resources; heartbeat mode to report effectiveness

#### 2.2 components provided
- kubelet: `Pod`--container creation, setup, stop; communicate with `master`
- kube-proxy: communicate with kube `services` and load-balancer
- docker: docker engine, work on containers on this node


### 3. k8s pod
#### 3.1 mechanism
- has a Pause container as the basic
- can estimate status of a group of containers
- in a pod, the IP and volume of Pause is shared by other containers in the same pod --> simplify communication config and problems
- any two pods can communicate with each other by TCP/IP
- any one of the container in a pod got stopped, master will detect it and try to restart the whole pod
- a Pod IP and a container Port defines en Endpoint

#### 3.2 static pod
- data of `static` pod only saved in Node, and start and running on this Node

#### 3.3 allocate resources
- CPU: 100~300m = 0.1~0.3CPU is absolute value
- memory: in B
- Requests: minimum resouce should be provided
- Limits: maxmium allocation of this resource


### 4. k8s Label
#### 4.1 mechanism
- a label is a key=value pair
- defined under metadata in resource definition
- label can be attached to different resources, such as Node, Pod, Service, RC
- for one resource object, there can be unlimited number of labels
- one label can attach on unlimited number of resource objects\

#### 4.2 examples
- version labels --> release:stable, release:canary
- environment labels --> environment:dev, environment:qa, environment:production
- architecture labels --> tier:frontend, tier:backend, tier:middleware
- partition labels --> partition:customerA, partion:customerB
- QA labels --> track:daily, track:weekly
- cooperated with Label Selector

#### 4.3 Label Selector match
- Equality-based: name=, name!=
- Set-based: name in (), name not in ()
- different matchers can be implemented for an object all at once

#### 4.4 Application
- kube-controller monitoring number of pods
- kube-proxy automatically establish routing table from service to pod, to function load-balance
- kube-schedule dispatch pod orientedly


### 5. Replication Controller
- label selector to filtrate pods to make sure there are enough replicas
- create template for new pods when there are not enough replicas
- deleting rc won't influence on established pods
- capable for Rolling Update (to change image version in template)


### 6. Deployment
- compared RC: get to know Pod 'deployment' progress in real time
- Deployment object created --> Replica Set created and Pod created
- Deployment status --> if the 'deployment' completed
- Deployment update --> new pod
- Deployment unstable --> rolling to last version of Deployment
- apiVersion: extensions/v1beta1


### 7. Horizontal Pod Autoscaler(HPA)
- apiVersion: autoscaling/v1
- Depend on: CPUUtilizationPercentage and program meters such as TPS or QPS
- CPUUtilizationPercentage: algorithm average of all pods
- Dependency: Heapster


### 8. Service
#### 8.1 mechanism
- Cluster IP assigned for each service, won't change for whole life of the service
- kube-proxy: load-balancer between service and pods
- can define multi-ports for one service, if so, name must be defined for each port
- to expose service to external network, define nodePort
- to balance load of the nodePorts, a external load-balancer is required, can be hardware or software, such as HAProxy or Nginx. If cluster is on GCE, just define LoadBalancer instead of NodePort

#### 8.2 Service Discovery
- Add-On to introduce DNS system
- service name <--> DNS domain name

#### 8.3 How External system visit service
- Node IP: physical network
- Pod IP: distributed by docker0 bridge regulated IP range, virtual network in 2nd layer, real data stream going through physical network by Node IP
- Cluster IP:
  1. only attached with service, distributed by K8s
  2. couldn't by pinged
  3. can only work with servie port to perform as an endpoint, not exposed to external network by default
  4. communication rules inside k8s on Node IP, Pod IP and Cluster IP are defined and regulated by k8s and quite different than usual


### 9. Volume
#### 9.1 mechanism
- shared directory in a Pod that can be visited by multiple containers inside this Pod
- live with Pod, not containers
- support such as GlusterFS, Ceph, etc.

#### 9.2 Volume types
- emptyDir: temporary directory and can be shared by containers
- hostPath: mount on host, can persistent such as log files of containers, can be defined to /var/lib/docker on host for containers to grab data of docker
- gcePersistentDisk: Node must be GCE virtual machine and a PD must be created
- awsElasticBlockStore: Node must be AWS EC2 instance, can only be mounted by single EC2 instance, the EC2 instance must be in the same region and availability-zone with EBS volume

#### 9.3 Persistent Volume
- defined outside nodes and pods, but can be visited by any node
- PV accessModes: ReadWriteOnce, ReadOnlyMany, ReadWriteMany
- Pod need to define a PersistentVolumeClaim when applying for a PV
- PV state: Available, Bound, Released, Failed


### 10. Namespace
- defined under metadata in resource definition


### 11. Annotation
- similar as Label but not that strict and not defined under metadata and not used by Label Selector
- can record info as following
  - build, release, Docker images
  - logs, monitors, debugs, teams and members


### 12. Basic Commands

#### 12.1 get infos
- `kubectl get nodes`
- `kubectl get rc`
- `kubectl get svc`
- `kubectl get svc <service_name> -o yaml`
- `kubectl get pods`
- `kubectl get endpoints`
- `kubectl get namespaces`
- `kubectl get <resource_name> --namespace=<namespace_name>`

#### 12.2 dynamic scaling
- `kubectl scale rc <rc_name> --replica=<rc_replica_num>`

#### 12.3 create HPA
- `kubectl autoscal deployment <deployment_name> --cup-percent=<targetCPUUtilizationPercentage> --min=<min_replica_num> --max=<max_replica_num>`

#### 12.4 specific info -- verbose
- `kubectl describe deployments`
- `kubectl describe <resource_name>`

