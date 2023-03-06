# Ni8Jenkins - Container Work

This repository holds the dockerfile for setting up a docker container for building the Ni8 Platform.  
The docker container is a ssh-agent and Jenkins connects to the docker container, where runs the below Jenkinsfile to build
the Ni8 Platform.  
The Jenkinsfile also runs Static Code analysis, Unit Test and Smoketests. 

For now the Jenkinsfile only builds the Ni8 Platform without any tests.

Go to SVN and the JenkinsAgent repo to get information on configuration, build and deployment of the docker container.


To start the docker container: 

$ docker run --privileged  -it -d --rm --name=agent2 -p 2235:22 \
-e "JENKINS_AGENT_SSH_PUBKEY=`cat ~/.ssh/jenkins_agent_key.pub`" \
-v ~/.ssh:/home/jenkins/.ssh-ro:ro -v \
/srv/www/ni8/buildroot_report:/srv/www/ni8/buildroot_report registrydev.logos.dk/jenkinsagentni8 