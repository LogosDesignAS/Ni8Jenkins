# Ni8Jenkins - Container Work

This repository holds the dockerfile for setting up a docker container for building the Ni8 Platform.  
The docker container is a ssh-agent and Jenkins connects to the docker container, where runs the below Jenkinsfile to build
the Ni8 Platform.  
The Jenkinsfile also runs Static Code analysis, Unit Test and Smoketests. 

For now the Jenkinsfile only builds the Ni8 Platform without any tests.
```bash
# Build our own image with C++ tools, needed tools for building buildroot and is based
# upon official Jenkins SSH-Agent Debian image. note: this needs the setup_sshd.sh file
# to be in the current directory
$ docker build -t logospaymentsolutions/jenkinsagentni8:agent2  .
 
# Launch container from image, make sure that everything works, from controller you
# should be able to schedule and execute jobs on 'Agent 2'. This needs to be run on the 
# builderbob(172.16.1.126) server, which has the needed SSH keys, otherwise one need to 
# add system ssh keys for accessing bitbucket read only.
$ docker run --privileged  -it -d --restart unless-stopped --name=agent2 -p 2235:22 \
-e "JENKINS_AGENT_SSH_PUBKEY=`cat ~/.ssh/jenkins_agent_key.pub`" \
-v ~/.ssh:/home/jenkins/.ssh-ro:ro -v \
/srv/www/ni8/buildroot_report:/srv/www/ni8/buildroot_report -v \
/opt/ni8-build-artifacts:/opt/ni8-build-artifacts -v \
/srv/www/ni8/sdk:/srv/www/ni8/sdk logospaymentsolutions/jenkinsagentni8:agent2 
 
 
# If you for some reason needs shell access.
# Make sure container is up and running
$ docker ps
CONTAINER ID   IMAGE                      COMMAND        CREATED          STATUS          PORTS                                   NAMES
6748e9f4d8d0   registrydev.logos.dk/jenkinsagentni8   "setup-sshd"   19 minutes ago   Up 19 minutes   0.0.0.0:2235->22/tcp, :::2235->22/tcp   agent2
 
$ docker exec -it agent2 bash
 
# Deploy to our own registry.
$ docker push logospaymentsolutions/jenkinsagentni8:agent2 
```
