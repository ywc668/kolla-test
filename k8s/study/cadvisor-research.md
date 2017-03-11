cAdvisor Research
====================

## 1. Basics
### 1.1 Introduction
- cAdvisor (Container Advisor) provides container users an understanding of the resource usage and performance characteristics of their running containers.
- It is a running daemon that collects, aggregates, processes, and exports information about running containers.
- Specifically, for each container it keeps resource isolation parameters, historical resource usage, histograms of complete historical resource usage and network statistics.

### 1.2 Run cAdvisor

```
  sudo docker run \
  --volume=/:/rootfs:ro \
  --volume=/var/run:/var/run:rw \
  --volume=/sys:/sys:ro \
  --volume=/var/lib/docker/:/var/lib/docker:ro \
  --publish=8080:8080 \
  --detach=true \
  --name=cadvisor \
  google/cadvisor:latest
```

#### 1.2.1 CentOS, Fedora, and RHEL
- Run the container with `--privileged=true` and `--volume=/cgroup:/cgroup:ro \` in order for cAdvisor to monitor Docker containers.
- RHEL and CentOS lock down their containers a bit more. cAdvisor needs access to the Docker daemon ghrough its socket requires `--privileged=true` in RHEL and CentOS.
- On some versions of RHEL and CentOS the cgroup hierarchies are mounted in /cgroup so run cAdvisor with an additional Docker option of `--volume=/cgroup:/cgroup:ro \`.


#### 1.2.2 Debian
- Debian disables the memory cgroup by default prevent cAdvisor to gather memory stats.
- Add `GRUB_CMDLINE_LINUX="cgroup_enable=memory"` to the file `/etc/default/grub`.


#### 1.2.3 Standalone running
- cAdvisor is a static Go binary with no external dependencies.
- Simply run: `$ sudo cadvisor`.
- Default listening port is 8080.

#### 1.2.4 Runtime Options
- How long of a history it stores can be configured with `--storage_duration` flag.
- Intervals
  ```
    --allow_dynamic_housekeeping=true: Whether to allow the housekeeping interval to be dynamic
    --global_housekeeping_interval=1m0s: Interval between global housekeepings
    --housekeeping_interval=1s: Interval between container housekeepings
  ```
- Housekeeping
  - Global housekeeping is a singular housekeeping done once in cAdvisor. This typically does detection of new containers.
  - Per-container housekeeping is run once on each container cAdvisor tracks. This typically gets container stats.
- Container Hints: `--container_hints="/etc/cadvisor/container_hints.json": location of the container hints file`
- HTTP
  ```
  --listen_ip="": IP to listen on, defaults to all IPs
  --port=8080: port to listen
  ```
- Debugging and Logging
  ```
  --log_cadvisor_usage=false: Whether to log the usage of the cAdvisor container
  --version=false: print cAdvisor version and exit
  --profiling=false: Enable profiling via web interface host:port/debug/pprof/
  ```

### 1.3 Building and Testing
- To build the cAdvisor binary and then build the Docker image: `$ ./deploy/build.sh`


## 2. API
- All endpoints are read only
- `http://<hostname>:<port>/api/<version>/<request>`
- Current version is v1.3, some function of v2.0 can be used

### 2.1 Version 1.0
- Container Info: `/api/v1.0/containers/<absolute container name>`
  - Absolute container name
  - List of subcontainers
  - ContainerSpec which describes the resource isolation enabled in the container
  - Detailed resource usage statistics of the container for the last N seconds(N is globally configurable in cAdvisor)
  - Histogram of resource usage from the creation of the container
- Machine Info: `/api/v1.0/machine`
  - Number of schedulable logical CPU cores
  - Memory capacity(in bytes)
  - Maximum supported CPU frequency (in kHz)
  - Available filesystems: major, minor numbers and capacity (in bytes)
  - Network devices: mac addresses, MTU, and speed(if available)
  - Machine topology: Nodes, cores, threads, per-nodememory, and caches

### 2.2 Version 1.1
- Subcontainer Info: `api/v1.1/subcontainers/<absolute container name>`

### 2.3 Version 1.2
- Docker Container Info: `/api/v1.2/docker/<Docker container name or blank for all Docker containers>`

### 2.4 Version 1.3
- Docker Container Event: `/api/v1.3/events/<absolute container name>`
- Query Parameters: https://github.com/google/cadvisor/blob/master/docs/api.md

### 2.5 Version 2.0
- Machine Info: `/api/v2.0/machine`
- Attributes: `/api/v2.0/attributes`
  - Hardware info same as machine Info
  - Software info include version of cAdvisor, kernel, docker and underlying OS
- Container stats: `/api/v2.0/stats/<container identifier>`
  - options: type, recursive, count
  - `/api/v2.0/containers/docker/2c4dee605d22`
  - `/api/v2.0/stats/2c4dee605d22?type=docker`
- Container summary: `/api/v2.0/summary/<container identifier>`
- Container Spec: `/api/v2.0/spec/<container identifier>`

## 3. Clients
- official go Clients
  ```
  import "github.com/google/cadvisor/client"

  client, err = client.NewClient("http://localhost:8080/")
  mInfo, err := client.MachineInfo()
  ```

## 4. Directory
```
--|api
   --|handler.go
   --|versions.go
   --|versions_test.go
--|build
--|cache
--|client
--|collector
--|container
--|deploy
--|devicemapper
   --|fake
      --|dmsetup_client_fake.go
   --|thin_pool_watcher_test.go
--|events
--|fs
--|Godeps
--|healthz
--|http
--|info
--|integration
--|machine
--|manager
--|metrics
--|pages
--|storage
   --|bigquery
      --|client
         --|example
            --|example.go
--|summary
--|utils
--|validate
--|vendor
--|version
--|cadvisor.go
--|cadvisor_test.go
--|storagedriver.go
```
