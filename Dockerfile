FROM openmicroscopy/omero-ssh-systemd
MAINTAINER ome-devel@lists.openmicroscopy.org.uk

ENV JENKINS_SWARM_VERSION 1.24
ENV LANG en_US.UTF-8
ARG JAVAVER=openjdk18

# To avoid error: sudo: sorry, you must have a tty to run sudo
RUN sed -i -e "s/Defaults    requiretty.*/ #Defaults    requiretty/g" /etc/sudoers

# Download and run omero-install. This section can be customized
# by running particular scripts from any omero-install install*.sh
# script.
ENV OMERO_INSTALL /tmp/omero-install/linux
#RUN git clone git://github.com/ome/omero-install /tmp/omero-install
RUN yum install -y git && \
    git clone -b java-parameters git://github.com/jburel/omero-install /tmp/omero-install && \
    source $OMERO_INSTALL/settings.env && \
    bash $OMERO_INSTALL/step01_centos7_init.sh && \
    bash $OMERO_INSTALL/step01_centos_java_deps.sh && \
    bash $OMERO_INSTALL/step01_centos7_deps.sh && \
    bash $OMERO_INSTALL/step02_all_setup.sh && \
    echo skip step3/pg since external and step4/omero and step5/nginx since run by job && \
    yum install -y http://download-aws.ej-technologies.com/exe4j/exe4j_linux_5_0_1.rpm

WORKDIR /tmp
RUN curl --create-dirs -sSLo /tmp/swarm-client-$JENKINS_SWARM_VERSION-jar-with-dependencies.jar \
    http://maven.jenkins-ci.org/content/repositories/releases/org/jenkins-ci/plugins/swarm-client/$JENKINS_SWARM_VERSION/swarm-client-$JENKINS_SWARM_VERSION-jar-with-dependencies.jar

COPY jenkins-slave.sh /tmp/jenkins-slave.sh
COPY jenkins.service /etc/systemd/system

RUN systemctl enable jenkins.service
