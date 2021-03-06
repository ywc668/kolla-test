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
