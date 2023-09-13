FROM jburel/omero-ssh-daemon-c7-docker:0.2.1

MAINTAINER ome-devel@lists.openmicroscopy.org.uk

ENV LANG en_US.UTF-8
ENV SLAVE_PARAMS "-labels slave"
ENV SLAVE_EXECUTORS "1"

RUN yum install -y git ca-certificates \
    && yum clean all


ARG JENKINS_SWARM_VERSION=${JENKINS_SWARM_VERSION:-3.29}


USER omero
RUN curl --create-dirs -sSLo /tmp/swarm-client-$JENKINS_SWARM_VERSION.jar https://repo.jenkins-ci.org/releases/org/jenkins-ci/plugins/swarm-client/$JENKINS_SWARM_VERSION/swarm-client-$JENKINS_SWARM_VERSION.jar

USER root

# Jenkins slave
ADD ./jenkins-slave.sh /tmp/jenkins-slave.sh
RUN chown omero:omero /tmp/jenkins-slave.sh
RUN chmod a+x /tmp/jenkins-slave.sh

# Change user id to fix permissions issues
ARG USER_ID=1000
RUN usermod -u $USER_ID omero

CMD ["/tmp/jenkins-slave.sh"]
