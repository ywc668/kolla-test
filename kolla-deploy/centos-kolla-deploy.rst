script for deploying kolla on centos

.. code-block:: bash

    #!/bin/bash
    
    # http://docs.openstack.org/developer/kolla/newton/quickstart.html
    
    set -x
    
    yum install -y epel-release
    yum install -y gcc
    yum install -y python-devel
    yum install -y python-pip
    yum install -y vim wget
    pip install -U pip
    
    curl -sSL https://get.docker.io | bash
    
    #cat <<"EOEF" > /etc/yum.repos.d/kubernetes.repo
    #[kubernetes]
    #name=Kubernetes
    #baseurl=http://yum.kubernetes.io/repos/kubernetes-el7-x86_64
    #enabled=1
    #gpgcheck=1
    #repo_gpgcheck=1
    #gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
    #       https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
    #EOEF
    
    #yum install -y docker
    #service docker start
    
    mkdir -p /etc/systemd/system/docker.service.d
    tee /etc/systemd/system/docker.service.d/kolla.conf <<-'EOF'
    [Service]
    MountFlags=shared
    EOF
    
    systemctl daemon-reload
    systemctl restart docker
    
    
    yum install -y python-docker-py
    
    # check if it is need to configure
    # # Edit /etc/rc.local to add:
    # mount --make-shared /run
    
    yum install -y ntp
    systemctl enable ntpd.service
    systemctl start ntpd.service
    
    systemctl stop libvirtd.service
    systemctl disable libvirtd.service
    
    yum install -y ansible
    
    pip install kolla
    
    cp -r /usr/share/kolla/etc_examples/kolla /etc/
    
    cat << EOF >> /etc/hosts
    192.168.122.14 centos-kolla
    192.168.122.14 centos-ansible
    EOF
    
    kolla-genpwd
    
    sed -i -e "s/^kolla_internal_vip_address.*/kolla_internal_vip_address: \"192.168.122.14\"/g" \
        -e "s/^#network_interface:.*/network_interface: \"eth0\"/g" \
        /etc/kolla/globals.yml
    
    date
    kolla-ansible prechecks
    date
    kolla-ansible pull
    date
    kolla-ansible deploy


errors

when doing $ sudo kolla-ansible prechecks

ansible report

.. code-block:: xml

    TASK [prechecks : Checking if 'MountFlags' for docker service is set to 'shared'] ***
    fatal: [localhost]: FAILED! => {"changed": false, "cmd": ["systemctl", "show", "docker"], "delta": "0:00:00.010178", "end": "2017-02-24 04:19:39.540979", "failed": true, "failed_when_result": true, "rc": 0, "start": "2017-02-24 04:19:39.530801", "stderr": "", "stdout": "Type=notify\nRestart=no\nNotifyAccess=main\nRestartUSec=100ms\nTimeoutStartUSec=0\nTimeoutStopUSec=1min 30s\nWatchdogUSec=0\nWatchdogTimestamp=Fri 2017-02-24 04:11:21 UTC\nWatchdogTimestampMonotonic=8499929456\nStartLimitInterval=10000000\nStartLimitBurst=5\nStartLimitAction=none\nFailureAction=none\nPermissionsStartOnly=no\nRootDirectoryStartOnly=no\nRemainAfterExit=no\nGuessMainPID=yes\nMainPID=16789\nControlPID=0\nFileDescriptorStoreMax=0\nStatusErrno=0\nResult=success\nExecMainStartTimestamp=Fri 2017-02-24 04:11:20 UTC\nExecMainStartTimestampMonotonic=8498636854\nExecMainExitTimestampMonotonic=0\nExecMainPID=16789\nExecMainCode=0\nExecMainStatus=0\nExecStart={ path=/usr/bin/dockerd ; argv[]=/usr/bin/dockerd ; ignore_errors=no ; start_time=[n/a] ; stop_time=[n/a] ; pid=0 ; code=(null) ; status=0/0 }\nExecReload={ path=/bin/kill ; argv[]=/bin/kill -s HUP $MAINPID ; ignore_errors=no ; start_time=[n/a] ; stop_time=[n/a] ; pid=0 ; code=(null) ; status=0/0 }\nSlice=system.slice\nControlGroup=/system.slice/docker.service\nMemoryCurrent=25190400\nDelegate=yes\nCPUAccounting=no\nCPUShares=18446744073709551615\nStartupCPUShares=18446744073709551615\nCPUQuotaPerSecUSec=infinity\nBlockIOAccounting=no\nBlockIOWeight=18446744073709551615\nStartupBlockIOWeight=18446744073709551615\nMemoryAccounting=no\nMemoryLimit=18446744073709551615\nDevicePolicy=auto\nUMask=0022\nLimitCPU=18446744073709551615\nLimitFSIZE=18446744073709551615\nLimitDATA=18446744073709551615\nLimitSTACK=18446744073709551615\nLimitCORE=18446744073709551615\nLimitRSS=18446744073709551615\nLimitNOFILE=18446744073709551615\nLimitAS=18446744073709551615\nLimitNPROC=18446744073709551615\nLimitMEMLOCK=65536\nLimitLOCKS=18446744073709551615\nLimitSIGPENDING=15010\nLimitMSGQUEUE=819200\nLimitNICE=0\nLimitRTPRIO=0\nLimitRTTIME=18446744073709551615\nOOMScoreAdjust=0\nNice=0\nIOScheduling=0\nCPUSchedulingPolicy=0\nCPUSchedulingPriority=0\nTimerSlackNSec=50000\nCPUSchedulingResetOnFork=no\nNonBlocking=no\nStandardInput=null\nStandardOutput=journal\nStandardError=inherit\nTTYReset=no\nTTYVHangup=no\nTTYVTDisallocate=no\nSyslogPriority=30\nSyslogLevelPrefix=yes\nSecureBits=0\nCapabilityBoundingSet=18446744073709551615\nMountFlags=0\nPrivateTmp=no\nPrivateNetwork=no\nPrivateDevices=no\nProtectHome=no\nProtectSystem=no\nSameProcessGroup=no\nIgnoreSIGPIPE=yes\nNoNewPrivileges=no\nSystemCallErrorNumber=0\nRuntimeDirectoryMode=0755\nKillMode=process\nKillSignal=15\nSendSIGKILL=yes\nSendSIGHUP=no\nId=docker.service\nNames=docker.service\nRequires=basic.target\nWants=system.slice\nConflicts=shutdown.target\nBefore=shutdown.target\nAfter=firewalld.service network.target system.slice basic.target systemd-journald.socket\nDocumentation=https://docs.docker.com\nDescription=Docker Application Container Engine\nLoadState=loaded\nActiveState=active\nSubState=running\nFragmentPath=/usr/lib/systemd/system/docker.service\nUnitFileState=disabled\nUnitFilePreset=disabled\nInactiveExitTimestamp=Fri 2017-02-24 04:11:20 UTC\nInactiveExitTimestampMonotonic=8498636911\nActiveEnterTimestamp=Fri 2017-02-24 04:11:21 UTC\nActiveEnterTimestampMonotonic=8499929509\nActiveExitTimestampMonotonic=0\nInactiveEnterTimestampMonotonic=0\nCanStart=yes\nCanStop=yes\nCanReload=yes\nCanIsolate=no\nStopWhenUnneeded=no\nRefuseManualStart=no\nRefuseManualStop=no\nAllowIsolate=no\nDefaultDependencies=yes\nOnFailureJobMode=replace\nIgnoreOnIsolate=no\nIgnoreOnSnapshot=no\nNeedDaemonReload=no\nJobTimeoutUSec=0\nJobTimeoutAction=none\nConditionResult=yes\nAssertResult=yes\nConditionTimestamp=Fri 2017-02-24 04:11:20 UTC\nConditionTimestampMonotonic=8498633839\nAssertTimestamp=Fri 2017-02-24 04:11:20 UTC\nAssertTimestampMonotonic=8498633840\nTransient=no", "stdout_lines": ["Type=notify", "Restart=no", "NotifyAccess=main", "RestartUSec=100ms", "TimeoutStartUSec=0", "TimeoutStopUSec=1min 30s", "WatchdogUSec=0", "WatchdogTimestamp=Fri 2017-02-24 04:11:21 UTC", "WatchdogTimestampMonotonic=8499929456", "StartLimitInterval=10000000", "StartLimitBurst=5", "StartLimitAction=none", "FailureAction=none", "PermissionsStartOnly=no", "RootDirectoryStartOnly=no", "RemainAfterExit=no", "GuessMainPID=yes", "MainPID=16789", "ControlPID=0", "FileDescriptorStoreMax=0", "StatusErrno=0", "Result=success", "ExecMainStartTimestamp=Fri 2017-02-24 04:11:20 UTC", "ExecMainStartTimestampMonotonic=8498636854", "ExecMainExitTimestampMonotonic=0", "ExecMainPID=16789", "ExecMainCode=0", "ExecMainStatus=0", "ExecStart={ path=/usr/bin/dockerd ; argv[]=/usr/bin/dockerd ; ignore_errors=no ; start_time=[n/a] ; stop_time=[n/a] ; pid=0 ; code=(null) ; status=0/0 }", "ExecReload={ path=/bin/kill ; argv[]=/bin/kill -s HUP $MAINPID ; ignore_errors=no ; start_time=[n/a] ; stop_time=[n/a] ; pid=0 ; code=(null) ; status=0/0 }", "Slice=system.slice", "ControlGroup=/system.slice/docker.service", "MemoryCurrent=25190400", "Delegate=yes", "CPUAccounting=no", "CPUShares=18446744073709551615", "StartupCPUShares=18446744073709551615", "CPUQuotaPerSecUSec=infinity", "BlockIOAccounting=no", "BlockIOWeight=18446744073709551615", "StartupBlockIOWeight=18446744073709551615", "MemoryAccounting=no", "MemoryLimit=18446744073709551615", "DevicePolicy=auto", "UMask=0022", "LimitCPU=18446744073709551615", "LimitFSIZE=18446744073709551615", "LimitDATA=18446744073709551615", "LimitSTACK=18446744073709551615", "LimitCORE=18446744073709551615", "LimitRSS=18446744073709551615", "LimitNOFILE=18446744073709551615", "LimitAS=18446744073709551615", "LimitNPROC=18446744073709551615", "LimitMEMLOCK=65536", "LimitLOCKS=18446744073709551615", "LimitSIGPENDING=15010", "LimitMSGQUEUE=819200", "LimitNICE=0", "LimitRTPRIO=0", "LimitRTTIME=18446744073709551615", "OOMScoreAdjust=0", "Nice=0", "IOScheduling=0", "CPUSchedulingPolicy=0", "CPUSchedulingPriority=0", "TimerSlackNSec=50000", "CPUSchedulingResetOnFork=no", "NonBlocking=no", "StandardInput=null", "StandardOutput=journal", "StandardError=inherit", "TTYReset=no", "TTYVHangup=no", "TTYVTDisallocate=no", "SyslogPriority=30", "SyslogLevelPrefix=yes", "SecureBits=0", "CapabilityBoundingSet=18446744073709551615", "MountFlags=0", "PrivateTmp=no", "PrivateNetwork=no", "PrivateDevices=no", "ProtectHome=no", "ProtectSystem=no", "SameProcessGroup=no", "IgnoreSIGPIPE=yes", "NoNewPrivileges=no", "SystemCallErrorNumber=0", "RuntimeDirectoryMode=0755", "KillMode=process", "KillSignal=15", "SendSIGKILL=yes", "SendSIGHUP=no", "Id=docker.service", "Names=docker.service", "Requires=basic.target", "Wants=system.slice", "Conflicts=shutdown.target", "Before=shutdown.target", "After=firewalld.service network.target system.slice basic.target systemd-journald.socket", "Documentation=https://docs.docker.com", "Description=Docker Application Container Engine", "LoadState=loaded", "ActiveState=active", "SubState=running", "FragmentPath=/usr/lib/systemd/system/docker.service", "UnitFileState=disabled", "UnitFilePreset=disabled", "InactiveExitTimestamp=Fri 2017-02-24 04:11:20 UTC", "InactiveExitTimestampMonotonic=8498636911", "ActiveEnterTimestamp=Fri 2017-02-24 04:11:21 UTC", "ActiveEnterTimestampMonotonic=8499929509", "ActiveExitTimestampMonotonic=0", "InactiveEnterTimestampMonotonic=0", "CanStart=yes", "CanStop=yes", "CanReload=yes", "CanIsolate=no", "StopWhenUnneeded=no", "RefuseManualStart=no", "RefuseManualStop=no", "AllowIsolate=no", "DefaultDependencies=yes", "OnFailureJobMode=replace", "IgnoreOnIsolate=no", "IgnoreOnSnapshot=no", "NeedDaemonReload=no", "JobTimeoutUSec=0", "JobTimeoutAction=none", "ConditionResult=yes", "AssertResult=yes", "ConditionTimestamp=Fri 2017-02-24 04:11:20 UTC", "ConditionTimestampMonotonic=8498633839", "AssertTimestamp=Fri 2017-02-24 04:11:20 UTC", "AssertTimestampMonotonic=8498633840", "Transient=no"], "warnings": []}
    
solution verified

.. code-block:: bash

    [centos@qiwei-kolla ~]$ cd /etc/systemd/system/docker.service.d
    [centos@qiwei-kolla ~]$ touch docker.conf
    
    [Service]
    MountFlags=shared
    
    [centos@qiwei-kolla ~]$ sudo systemctl daemon-reload
    [centos@qiwei-kolla ~]$ sudo systemctl restart docker

when deploy

.. code-block:: xml

    TASK [common : Starting heka container] ****************************************
    fatal: [localhost]: FAILED! => {"changed": true, "failed": true, "msg": "'Traceback (most recent call last):\\n  File \"/tmp/ansible_acbLh2/ansible_module_kolla_docker.py\", line 742, in main\\n    result = bool(getattr(dw, module.params.get(\\'action\\'))())\\n  File \"/tmp/ansible_acbLh2/ansible_module_kolla_docker.py\", line 567, in start_container\\n    self.create_container()\\n  File \"/tmp/ansible_acbLh2/ansible_module_kolla_docker.py\", line 555, in create_container\\n    self.dc.create_container(**options)\\n  File \"/usr/lib/python2.7/site-packages/docker/api/container.py\", line 119, in create_container\\n    return self.create_container_from_config(config, name)\\n  File \"/usr/lib/python2.7/site-packages/docker/api/container.py\", line 130, in create_container_from_config\\n    return self._result(res, True)\\n  File \"/usr/lib/python2.7/site-packages/docker/client.py\", line 150, in _result\\n    self._raise_for_status(response)\\n  File \"/usr/lib/python2.7/site-packages/docker/client.py\", line 146, in _raise_for_status\\n    raise errors.APIError(e, response, explanation=explanation)\\nAPIError: 500 Server Error: Internal Server Error (\"{\"message\":\"maximum retry count cannot be used with restart policy \\'unless-stopped\\'\"}\")\\n'"}
    
solution verified

https://review.openstack.org/#/c/423122/1/ansible/library/kolla_docker.py

each time of deployment failure, clean hosts and containers and retry

.. code-block:: bash

    $ cd /usr/share/kolla/tools
    $ ./cleanup-host
    $ ./cleanup-containers
    

error when installing python-neutronclient

.. code-block:: python

    Exception:
    Traceback (most recent call last):
      File "/usr/lib/python2.7/site-packages/pip/basecommand.py", line 215, in main
        status = self.run(options, args)
      File "/usr/lib/python2.7/site-packages/pip/commands/install.py", line 342, in run
        prefix=options.prefix_path,
      File "/usr/lib/python2.7/site-packages/pip/req/req_set.py", line 784, in install
        **kwargs
      File "/usr/lib/python2.7/site-packages/pip/req/req_install.py", line 851, in install
        self.move_wheel_files(self.source_dir, root=root, prefix=prefix)
      File "/usr/lib/python2.7/site-packages/pip/req/req_install.py", line 1064, in move_wheel_files
        isolated=self.isolated,
      File "/usr/lib/python2.7/site-packages/pip/wheel.py", line 247, in move_wheel_files
        prefix=prefix,
      File "/usr/lib/python2.7/site-packages/pip/locations.py", line 140, in distutils_scheme
        d = Distribution(dist_args)
      File "/usr/lib/python2.7/site-packages/setuptools/dist.py", line 320, in __init__
        _Distribution.__init__(self, attrs)
      File "/usr/lib64/python2.7/distutils/dist.py", line 287, in __init__
        self.finalize_options()
      File "/usr/lib/python2.7/site-packages/setuptools/dist.py", line 386, in finalize_options
        ep.require(installer=self.fetch_build_egg)
      File "/usr/lib/python2.7/site-packages/pkg_resources/__init__.py", line 2324, in require
        items = working_set.resolve(reqs, env, installer, extras=self.extras)
      File "/usr/lib/python2.7/site-packages/pkg_resources/__init__.py", line 862, in resolve
        new_requirements = dist.requires(req.extras)[::-1]
      File "/usr/lib/python2.7/site-packages/pkg_resources/__init__.py", line 2568, in requires
        dm = self._dep_map
      File "/usr/lib/python2.7/site-packages/pkg_resources/__init__.py", line 2815, in _dep_map
        self.__dep_map = self._compute_dependencies()
      File "/usr/lib/python2.7/site-packages/pkg_resources/__init__.py", line 2824, in _compute_dependencies
        for req in self._parsed_pkg_info.get_all('Requires-Dist') or []:
      File "/usr/lib/python2.7/site-packages/pkg_resources/__init__.py", line 2806, in _parsed_pkg_info
        metadata = self.get_metadata(self.PKG_INFO)
      File "/usr/lib/python2.7/site-packages/pkg_resources/__init__.py", line 1468, in get_metadata
        value = self._get(self._fn(self.egg_info, name))
      File "/usr/lib/python2.7/site-packages/pkg_resources/__init__.py", line 1577, in _get
        with open(path, 'rb') as stream:
    IOError: [Errno 2] No such file or directory: '/usr/lib/python2.7/site-packages/appdirs-1.4.1.dist-info/METADATA'
    
solution verified

.. code-block:: bash

    $ pip install -U setuptools
    
