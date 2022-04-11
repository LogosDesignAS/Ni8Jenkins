# Ni8Jenkins - Container Work

This repository holds the dockerfile for setting up a docker container for building the Ni8 Platform.  
The docker container is a ssh-agent and Jenkins connects to the docker container, where runs the below Jenkinsfile to build
the Ni8 Platform.  
The Jenkinsfile also runs Static Code analysis, Unit Test and Smoketests. 

For now the Jenkinsfile only builds the Ni8 Platform without any tests.

Go to SVN and the JenkinsAgent repo to get information on configuration, build and deployment of the docker container.
