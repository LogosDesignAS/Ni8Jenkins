# The MIT License
#
#  Copyright (c) 2015, CloudBees, Inc.
#
#  Permission is hereby granted, free of charge, to any person obtaining a copy
#  of this software and associated documentation files (the "Software"), to deal
#  in the Software without restriction, including without limitation the rights
#  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#  copies of the Software, and to permit persons to whom the Software is
#  furnished to do so, subject to the following conditions:
#
#  The above copyright notice and this permission notice shall be included in
#  all copies or substantial portions of the Software.
#
#  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#  THE SOFTWARE.

# Modified by Logos Payment Solution 2022

FROM eclipse-temurin:11.0.13_8-jdk-focal AS jre-build

# Generate smaller java runtime without unneeded files
# for now we include the full module path to maintain compatibility
# while still saving space
RUN jlink \
         --add-modules ALL-MODULE-PATH \
         --no-man-pages \
         --compress=2 \
         --output /javaruntime

FROM debian:bullseye-20211011

ARG user=jenkins
ARG group=jenkins
ARG uid=1000
ARG gid=1000
ARG JENKINS_AGENT_HOME=/home/${user}

ENV JENKINS_AGENT_HOME ${JENKINS_AGENT_HOME}

# Create User
RUN groupadd -g ${gid} ${group} \
 && useradd -d "${JENKINS_AGENT_HOME}" -u "${uid}" -g "${gid}" -m -s /bin/bash "${user}"

# setup SSH server
RUN apt-get update \
    && apt-get install --no-install-recommends -y openssh-server \
    && rm -rf /var/lib/apt/lists/*
RUN sed -i /etc/ssh/sshd_config \
        -e 's/#PermitRootLogin.*/PermitRootLogin no/' \
        -e 's/#RSAAuthentication.*/RSAAuthentication yes/'  \
        -e 's/#PasswordAuthentication.*/PasswordAuthentication no/' \
        -e 's/#SyslogFacility.*/SyslogFacility AUTH/' \
        -e 's/#LogLevel.*/LogLevel INFO/' && \
    mkdir /var/run/sshd

#VOLUME "${JENKINS_AGENT_HOME}" "/tmp" "/run" "/var/run"
WORKDIR "${JENKINS_AGENT_HOME}"

ENV LANG C.UTF-8

ENV JAVA_HOME=/opt/java/openjdk
ENV PATH "${JAVA_HOME}/bin:${PATH}"
COPY --from=jre-build /javaruntime $JAVA_HOME

RUN echo "PATH=${PATH}" >> /etc/environment
COPY setup-sshd.sh /usr/local/bin/setup-sshd.sh
COPY setup-sshd.sh ${JENKINS_AGENT_HOME}/setup-sshd.sh

##############################################################################
# 			Logos Payment Solutions Additions			#
##############################################################################

RUN /bin/bash -c "chmod 0700 /usr/local/bin/setup-sshd.sh"
RUN /bin/bash -c "chmod 0700  $JENKINS_AGENT_HOME/setup-sshd.sh"
RUN /bin/bash -c "chown -R jenkins:jenkins /usr/local/bin/setup-sshd.sh"
RUN /bin/bash -c "chown -R jenkins:jenkins  $JENKINS_AGENT_HOME/setup-sshd.sh"

RUN apt-get update && apt-get dist-upgrade -y
RUN apt-get install -y git vim cmake build-essential pkg-config automake make
RUN apt-get install -y cppcheck
RUN apt-get install -y curl wget cpio unzip rsync bc u-boot-tools ssh
RUN apt-get install -y file 
RUN apt-get install --reinstall -y coreutils
RUN apt-get install -y apt-utils

# Create environment for home directory
ENV HOMEDIR /home/jenkins

# Set the working directory
WORKDIR ${HOMEDIR}
ENV HOME ${HOMEDIR}

RUN /bin/bash -c "mkdir -p ${HOMEDIR}/.ssh" && ls -la ${HOMEDIR}
RUN /bin/bash -c "chmod 0700 ${HOMEDIR}/.ssh"
RUN /bin/bash -c "chown -R jenkins:jenkins ${HOMEDIR}/.ssh"
RUN /bin/bash -c "chmod 0700 ${HOMEDIR}/.ssh"
RUN echo "Host *.bitbucket.org\n\tStrictHostKeyChecking no\n" >> ${HOMEDIR}/.ssh/config
# Add bitbucket to the known host
RUN /bin/bash -c "ssh-keyscan bitbucket.org >> ${HOMEDIR}/.ssh/known_hosts"

# Get buildroot
ENV	BUILDROOT_VERSION 2022.02
RUN	curl -sSL "https://buildroot.org/downloads/buildroot-${BUILDROOT_VERSION}.tar.gz" -o /tmp/buildroot-${BUILDROOT_VERSION}.tar.gz \
	&& mkdir -p ${HOMEDIR}/git \
	&& tar -xzf /tmp/buildroot-${BUILDROOT_VERSION}.tar.gz -C ${HOMEDIR} \
	&& rm /tmp/buildroot-${BUILDROOT_VERSION}.tar.gz

##############################################################################
# 		End of Logos Payment Solutions Additions			#
##############################################################################


EXPOSE 22

ENTRYPOINT $JENKINS_AGENT_HOME/setup-sshd.sh

LABEL \
    org.opencontainers.image.vendor="Jenkins project" \
    org.opencontainers.image.title="Official Jenkins SSH Agent Docker image" \
    org.opencontainers.image.description="A Jenkins agent image which allows using SSH to establish the connection" \
    org.opencontainers.image.url="https://www.jenkins.io/" \
    org.opencontainers.image.source="https://github.com/jenkinsci/docker-ssh-agent" \
    org.opencontainers.image.licenses="MIT"
