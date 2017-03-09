script for deploying kolla on centos

.. code-block:: bash

    #### install python ####
    $ apt-get install gcc python-pip python-dev
    $ apt-get update
    $ pip install -U pip
    
    #### install and config docker ####
    $ curl -sSL https://get.docker.io | bash
    
    $ mkdir -p /etc/systemd/system/docker.service.d
    $ tee /etc/systemd/system/docker.service.d/kolla.conf <<-'EOF'
    > [Service]
    > MountFlags=shared
    > EOF
    
    #### for Ubuntu 14.04 which uses upstart and other non-systemd distros ####
    $ mount --make-shared /run
    # Edit /etc/rc.local to add:
    mount --make-shared /run
    
    $ restart docker
    $ pip install -U docker-py
    
    $ apt-get install ntp
    
    $ service libvirt-bin stop
    $ update-rc.d libvirt-bin disable
    
    #### install ansible ####
    $ pip install -U ansible
    # if dependency error, do below first
    $ apt-get install build-essential autoconf libtool pkg-config python-opengl python-imaging python-pyrex python-pyside.qtopengl idle-python2.7 qt4-dev-tools qt4-designer libqtgui4 libqtcore4 libqt4-xml libqt4-test libqt4-script libqt4-network libqt4-dbus python-qt4 python-qt4-gl libgle3 python-dev libssl-dev
    $ easy_install greenlet
    $ easy_install gevent
    
    #### install kolla ####
    $ pip install kolla
    # if dependency error, do below fist
    $ apt-get install libffi-dev libssl-dev
    $ pip install pyopenssl ndg-httpsclient pyasn1
    
    $ cp -r /usr/local/share/kolla/etc_examples/kolla /etc/
    
    #### install python clients ####
    $ apt-get install python-dev libffi-dev libssl-dev gcc
    $ pip install -U python-openstackclient python-neutronclient python-novaclient 
    
    #### deploy ####
    $ kolla-genpwd
    $ cat << EOF >> /etc/hosts
    > 127.0.1.1 ubuntu-kolla
    > 127.0.1.1 ubuntu-ansible
    > EOF
    $ sed -i -e "s/^kolla_internal_vip_address.*/kolla_internal_vip_address: \"192.168.252.160\"/g" \
    > -e "s/^#network_interface:.*/network_interface: \"wlan0\"/g" \
    > /etc/kolla/globals.yml


erros

when doing $ kolla-ansible prechecks

.. code-block:: xml

    TASK [prechecks : fail] ********************************************************
    failed: [localhost] (item={u'_ansible_parsed': True, u'changed': False, u'stdout': u'127.0.1.1       STREAM qiwei-X9SRL-F\n127.0.1.1       DGRAM  \n127.0.1.1       RAW    ', u'_ansible_no_log': False, u'stdout_lines': [u'127.0.1.1       STREAM qiwei-X9SRL-F', u'127.0.1.1       DGRAM  ', u'127.0.1.1       RAW    '], u'warnings': [], u'_ansible_item_result': True, u'start': u'2017-02-23 18:01:01.650790', u'delta': u'0:00:00.001345', u'cmd': [u'getent', u'ahostsv4', u'qiwei-X9SRL-F'], u'item': u'localhost', u'rc': 0, u'invocation': {u'module_name': u'command', u'module_args': {u'warn': True, u'executable': None, u'_uses_shell': False, u'_raw_params': u'getent ahostsv4 qiwei-X9SRL-F', u'removes': None, u'creates': None, u'chdir': None}}, u'end': u'2017-02-23 18:01:01.652135', u'stderr': u''}) => {"failed": true, "item": {"changed": false, "cmd": ["getent", "ahostsv4", "qiwei-X9SRL-F"], "delta": "0:00:00.001345", "end": "2017-02-23 18:01:01.652135", "invocation": {"module_args": {"_raw_params": "getent ahostsv4 qiwei-X9SRL-F", "_uses_shell": false, "chdir": null, "creates": null, "executable": null, "removes": null, "warn": true}, "module_name": "command"}, "item": "localhost", "rc": 0, "start": "2017-02-23 18:01:01.650790", "stderr": "", "stdout": "127.0.1.1       STREAM qiwei-X9SRL-F\n127.0.1.1       DGRAM  \n127.0.1.1       RAW    ", "stdout_lines": ["127.0.1.1       STREAM qiwei-X9SRL-F", "127.0.1.1       DGRAM  ", "127.0.1.1       RAW    "], "warnings": []}, "msg": "Hostname has to resolve to IP address of api_interface"}
    