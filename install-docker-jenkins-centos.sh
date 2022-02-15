#!/bin/bash
# this script will first install Docker in CentOS and then start a Jenkins container
# this script is designed for any remote/cloud host
# please make sure user has sudo privilege 

# uninstall old version of Docker
sudo yum remove docker \
                docker-client \
                docker-client-latest \
                docker-common \
                docker-latest \
                docker-latest-logrotate \
                docker-logrotate \
                docker-engine

# install Docker
sudo yum update
sudo yum install -y yum-utils

sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install docker-ce docker-ce-cli containerd.io
sudo systemctl start docker
sudo chmod 666 /var/run/docker.sock

# run jenkins -- will check if Dockerfile.jenkins-docker existed, if not it will run the offical jenkins image
sudo mkdir -p /var/jenkins_home
sudo chown -R 1000:1000 /var/jenkins_home/

if [ -f Dockerfile.jenkins-docker ]
  then echo "Dockerfile.jenkins-docker exists, building now"
  docker build -t jenkins-docker -f Dockerfile.jenkins-docker .
  echo "jenkins-docker image build completed, going to run the container"
  docker run --name jenkins -d -v /var/jenkins_home:/var/jenkins_home -v /var/run/docker.sock:/var/run/docker.sock -p 8080:8080 -p 50000:50000 jenkins-docker
else
  echo "No Dockfile found, running offical jenkins container"
  docker run --name jenkins -d -v /var/jenkins_home:/var/jenkins_home -p 8080:8080 -p 50000:50000 jenkins/jenkins:lts-jdk11
fi

# show endpoint
echo 'Jenkins installed'
echo "In your local machine, please edit /etc/hosts and then add new host -- $(tput bold)$(curl -s ifconfig.co) hostname"
echo 'You should now be able to access Jenkins at: http://hostname:8080'
echo "Type $(tput bold)docker ps $(tput sgr0)in terminal to check if Jenkins container is running"
