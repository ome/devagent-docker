FROM openmicroscopy/omero-ssh-systemd

MAINTAINER ome-devel@lists.openmicroscopy.org.uk

ENV LANG en_US.UTF-8
ENV JENKINS_MODE exclusive

ENV SWARM_PARAMS "'-labels slave -executors 1'"

# To avoid error: sudo: sorry, you must have a tty to run sudo
RUN sed -i -e "s/Defaults    requiretty.*/ #Defaults    requiretty/g" /etc/sudoers

#RUN usermod -u $UID omero

WORKDIR /home/omero

RUN yum install -y initscripts \
    && yum clean all

RUN chmod a+X /home/omero

ARG JAVAVER=${JAVAVER:-openjdk18}
ARG EXE4J_VERSION=${EXE4J_VERSION:-5_1}
ARG JENKINS_SWARM_VERSION=${JENKINS_SWARM_VERSION:-2.0}

# Download and run omero-install.
ENV OMERO_INSTALL /tmp/omero-install/linux

RUN yum install -y git \
    && yum clean all

RUN git clone https://github.com/ome/omero-install.git /tmp/omero-install
RUN bash $OMERO_INSTALL/step01_centos7_init.sh
RUN bash $OMERO_INSTALL/step01_centos_java_deps.sh

RUN yum install -y http://download-keycdn.ej-technologies.com/exe4j/exe4j_linux_$EXE4J_VERSION.rpm \
    && yum clean all

USER omero
RUN curl --create-dirs -sSLo /tmp/swarm-client-$JENKINS_SWARM_VERSION-jar-with-dependencies.jar http://maven.jenkins-ci.org/content/repositories/releases/org/jenkins-ci/plugins/swarm-client/$JENKINS_SWARM_VERSION/swarm-client-$JENKINS_SWARM_VERSION-jar-with-dependencies.jar

USER root

ADD ./jenkins-slave.sh /tmp/jenkins-slave.sh
RUN chmod +x /tmp/jenkins-slave.sh
ADD ./jenkins.service /etc/systemd/system/jenkins.service
RUN systemctl enable jenkins.service
