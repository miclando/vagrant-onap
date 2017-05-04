#!/bin/bash

set -o xtrace

# DNS/GW IP address configuration
echo "nameserver 10.0.0.1" >> /etc/resolvconf/resolv.conf.d/head
resolvconf -u

# Store credentials in files
mkdir -p /opt/config
echo $nexus_docker_repo > /opt/config/nexus_docker_repo.txt
echo $nexus_username > /opt/config/nexus_username.txt
echo $nexus_password > /opt/config/nexus_password.txt
echo $openstack_username > /opt/config/openstack_username.txt
echo $openstack_tenant_id > /opt/config/tenant_id.txt
echo $dmaap_topic > /opt/config/dmaap_topic.txt
echo $docker_version > /opt/config/docker_version.txt

# Download dependencies
apt-get update -y
apt-get install -y software-properties-common
add-apt-repository -y ppa:openjdk-r/ppa
add-apt-repository -y ppa:andrei-pozolotin/maven3
apt-get update -y
apt-get install -y \
  apt-transport-https \
  ca-certificates \
  curl \
  openjdk-8-jdk \
  maven3 \
  git  
# Force Maven3 to use jdk8
apt-get purge openjdk-7-jdk -y

# Download and install docker-engine and docker-compose
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
apt-get update
apt-get install -y docker-ce
service docker start

if [ ! -d /opt/docker ]; then
  mkdir /opt/docker
  curl -L https://github.com/docker/compose/releases/download/1.12.0/docker-compose-`uname -s`-`uname -m` > /opt/docker/docker-compose
  chmod +x /opt/docker/docker-compose
fi