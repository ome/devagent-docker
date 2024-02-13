FROM openmicroscopy/omero-ssh-daemon:0.2.0

MAINTAINER ome-devel@lists.openmicroscopy.org.uk

# Build args
ARG JAVAVER=${JAVAVER:-java-11-openjdk-devel}
ENV SLAVE_PARAMS "-labels slave"
ENV SLAVE_EXECUTORS "1"

RUN dnf install -y langpacks-en glibc-all-langpacks

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.en
ENV LC_ALL en_US.UTF-8

RUN dnf install -y git ca-certificates \
    && dnf clean all

RUN dnf install -y ${JAVAVER}
RUN dnf install -y unzip wget bc procps


ARG JENKINS_SWARM_VERSION=${JENKINS_SWARM_VERSION:-3.44}


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
