# From Official jenkins docker image - https://github.com/jenkinsci/docker
FROM ubuntu:16.04

MAINTAINER John Paul Iglesia

ARG user=jenkins
ARG group=jenkins
ARG uid=1000
ARG gid=1000
ARG http_port=8080
ARG agent_port=50000
ARG JENKINS_HOME=/var/jenkins_home

ENV JENKINS_HOME $JENKINS_HOME
ENV JENKINS_SLAVE_AGENT_PORT 50000

# Install necessary packages
RUN apt-get update -q \
    && DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
      software-properties-common \
      sudo \
      wget \
      nano \
      git \
      curl \
      ssh \
      apt-transport-https \
      openjdk-8-jdk-headless && \
      rm -rf /tmp/* /var/tmp/*

# Jenkins is run with user `jenkins`, uid = 1001
# If you bind mount a volume from the host or a data container,
# ensure you use the same uid
RUN mkdir -p $JENKINS_HOME \
  && chown ${uid}:${gid} $JENKINS_HOME \
  && groupadd -g ${gid} ${group} \
  && useradd -d "$JENKINS_HOME" -u ${uid} -g ${gid} -m -s /bin/bash ${user}

# Jenkins home directory needs to be a persistent volume, so configuration and build history
# can be persisted and survive image upgrades
VOLUME $JENKINS_HOME

# `/usr/share/jenkins/ref/` contains all reference configuration we want
# to set on a fresh new installation. Use it to bundle additional plugins
# or config file with your custom jenkins Docker image.
RUN mkdir -p /usr/share/jenkins/ref/init.groovy.d
COPY assets/init.groovy /usr/share/jenkins/ref/init.groovy.d/tcp-slave-agent-port.groovy

# Install Jenkins LTS
RUN apt-get update -q
RUN wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | apt-key add -
RUN sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
RUN apt-get update -q && apt-get install -y jenkins

ENV JENKINS_UC https://updates.jenkins.io
RUN chown -R ${user} "$JENKINS_HOME" /usr/share/jenkins/ref

ENV COPY_REFERENCE_FILE_LOG $JENKINS_HOME/copy_reference_file.log

# for main web interface:
EXPOSE $http_port

# will be used by attached slave agents:
EXPOSE $agent_port

USER ${user}

COPY assets/jenkins-support /usr/local/bin/jenkins-support
COPY assets/jenkins.sh /usr/local/bin/jenkins.sh
ENTRYPOINT ["/usr/local/bin/jenkins.sh"]

# from a derived Dockerfile, can use `RUN plugins.sh active.txt` to setup /usr/share/jenkins/ref/plugins from a support bundle
COPY assets/plugins.sh /usr/local/bin/plugins.sh
COPY assets/install-plugins.sh /usr/local/bin/install-plugins.sh
