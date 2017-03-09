setup local registry and test
==================================

### 1. environment
environment centos7 vm on 192.168.108.2
```ssh centos@192.168.122.135```

### 2. install docker
```sudo curl -sSL https://get.docker.io | bash```

### 3. start docker
```
sudo systemctl daemon-reload
sudo systemctl restart docker
```

### 4. build local registry
```
sudo docker run -d -p 5000:5000 --restart=always --name registry registry:2
```

### 5. lookup if the registry is working well

```
	sudo docker ps -a
	output:
	CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                    NAMES
	627bf29f406b        registry:2          "/entrypoint.sh /e..."   23 hours ago        Up 6 hours          0.0.0.0:5000->5000/tcp   registry
```

### 6. test still on this localhost


	sudo docker pull ubuntu
	sudo docker tag ubuntu localhost:5000/ubuntu
	sudo docker pull localhost:5000/ubuntu
	output: 
	[centos@qiwei-kolla1 etc]$ sudo docker pull localhost:5000/ubuntu
	Using default tag: latest
	latest: Pulling from ubuntu
	Digest: sha256:6b079ae764a6affcb632231349d4a5e1b084bece8c46883c099863ee2aeb5cf8
	Status: Image is up to date for localhost:5000/ubuntu:latest
	
	sudo docker pull 192.168.122.135:5000/ubuntu
	output:
	[centos@qiwei-kolla1 etc]$ sudo docker pull 192.168.122.135:5000/ubuntu
	Using default tag: latest
	Error response from daemon: Get https://192.168.122.135:5000/v1/_ping: http: server gave HTTP response to HTTPS client


### 7. config and restart docker
in /etc/sysconfig/docker


	# /etc/sysconfig/docker
	
	# Modify these options if you want to change the way the docker daemon runs
	OPTIONS='--selinux-enabled --log-driver=journald --signature-verification=false'
	if [ -z "${DOCKER_CERT_PATH}" ]; then
	    DOCKER_CERT_PATH=/etc/docker
	fi
	
	# If you want to add your own registry to be used for docker search and docker
	# pull use the ADD_REGISTRY option to list a set of registries, each prepended
	# with --add-registry flag. The first registry added will be the first registry
	# searched.
	#ADD_REGISTRY='--add-registry registry.access.redhat.com'
	
	# If you want to block registries from being used, uncomment the BLOCK_REGISTRY
	# option and give it a set of registries, each prepended with --block-registry
	# flag. For example adding docker.io will stop users from downloading images
	# from docker.io
	# BLOCK_REGISTRY='--block-registry'
	
	# If you have a registry secured with https but do not have proper certs
	# distributed, you can tell docker to not look for full authorization by
	# adding the registry to the INSECURE_REGISTRY line and uncommenting it.
	INSECURE_REGISTRY='--insecure-registry 192.168.122.135:5000'
	
	# On an SELinux system, if you remove the --selinux-enabled option, you
	# also need to turn on the docker_transition_unconfined boolean.
	# setsebool -P docker_transition_unconfined 1
	
	# Location used for temporary files, such as those created by
	# docker load and build operations. Default is /var/lib/docker/tmp
	# Can be overriden by setting the following environment variable.
	# DOCKER_TMPDIR=/var/tmp
	
	# Controls the /etc/cron.daily/docker-logrotate cron job status.
	# To disable, uncomment the line below.
	# LOGROTATE=false
	#
	
	# docker-latest daemon can be used by starting the docker-latest unitfile.
	# To use docker-latest client, uncomment below lines
	#DOCKERBINARY=/usr/bin/docker-latest
	#DOCKER_CONTAINERD_BINARY=/usr/bin/docker-containerd-latest
	#DOCKER_CONTAINERD_SHIM_BINARY=/usr/bin/docker-containerd-shim-latest


still got the error

all the operations above is still on 122.135

### 8. config and restart docker again -- succeeded
- now switch to 192.168.122.52(if this works, 122.135 will certainly work as well)
- config docker
	```
		# write in docker config file
		echo 'INSECURE_REGISTRY="--insecure-registry 192.168.122.52:5000"' > \
		/etc/sysconfig/docker

		# direct docker config file to /etc/sysconfig/docker
		tee /etc/systemd/system/docker.service <<-'EOF'
		# centos
		[Service]
		MountFlags=shared
		EnvironmentFile=/etc/sysconfig/docker
		ExecStart=/usr/bin/docker daemon $INSECURE_REGISTRY
		EOF

		# reload daemon and restart docker
		systemctl daemon-reload
		systemctl restart docker

		# verify docker service
		ps aux | grep docker

		# pull image from local registry
		docker pull 192.168.122.135:5000/ubuntu
	```
