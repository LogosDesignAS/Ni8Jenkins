FROM ubuntu:20.04
RUN apt-get update && DEBIAN_FRONTEND=noninteractive && apt-get install -y tzdata && apt-get dist-upgrade -y
RUN apt-get install -y openssh-client

RUN apt-get install -y git vim cmake build-essential pkg-config automake make
RUN apt-get install -y cppcheck
RUN apt-get install -y curl wget cpio unzip rsync bc u-boot-tools

# Set user and ssh keys
ENV HOMEDIR /home/jenkins
RUN useradd -m jenkins
RUN mkdir -p ${HOMEDIR}/.ssh
RUN chown -R jenkins:jenkins ${HOMEDIR}/.ssh
RUN echo "Host *.bitbucket.org\n\tStrictHostKeyChecking no\n" >> ${HOMEDIR}/.ssh/config
USER jenkins

# Get buildroot
ENV	BUILDROOT_VERSION 2022.02
RUN	curl -sSL "https://buildroot.org/downloads/buildroot-${BUILDROOT_VERSION}.tar.gz" -o /tmp/buildroot-${BUILDROOT_VERSION}.tar.gz \
	&& mkdir -p /home/jenkins/git \
	&& tar -xzf /tmp/buildroot-${BUILDROOT_VERSION}.tar.gz -C ${HOMEDIR}/ \
	&& rm /tmp/buildroot-${BUILDROOT_VERSION}.tar.gz
	
# Set the working directory
WORKDIR ${HOMEDIR}
