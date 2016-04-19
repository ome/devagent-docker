#!/bin/bash
# https://raw.githubusercontent.com/carlossg/jenkins-swarm-slave-docker/master/jenkins-slave.sh


# if `docker run` first argument start with `-` the user is passing jenkins swarm launcher arguments
if [[ $# -lt 1 ]] || [[ "$1" == "-"* ]]; then

  # jenkins swarm slave
  JAR=`ls -1 /home/omero/swarm-client-*.jar | tail -n 1`

  PARAMS=""
  if [ ! -z "$JENKINS_USERNAME" ]; then
    PARAMS="$PARAMS -username $JENKINS_USERNAME"
  fi
  if [ ! -z "$JENKINS_PASSWORD" ]; then
    PARAMS="$PARAMS -password $JENKINS_PASSWORD"
  fi

  # if -master is not provided and using --link jenkins:jenkins
  if [[ "$@" != *"-master "* ]] && [ ! -z "$JENKINS_PORT_8080_TCP_ADDR" ]; then
    PARAMS="$PARAMS -master http://$JENKINS_PORT_8080_TCP_ADDR:$JENKINS_PORT_8080_TCP_PORT"
  fi
  
  if [ ! -z "$JENKINS_MASTER" ]; then
    PARAMS="$PARAMS -master $JENKINS_MASTER"
  elif [ ! -z "$JENKINS_PORT_8080_TCP_ADDR" ]; then
    PARAMS="$PARAMS -master http://$JENKINS_PORT_8080_TCP_ADDR:$JENKINS_PORT_8080_TCP_PORT"
  else
    echo "You must specify JENKINS_MASTER=http://your.jenkins.host"
    exit 1
  fi
  
  if [ ! -z "$SLAVE_NAME" ]; then
      PARAMS="$PARAMS -name '$SLAVE_NAME'"
  fi
  if [ ! -z "$SLAVE_EXECUTORS" ]; then
      PARAMS="$PARAMS -executors '$SLAVE_EXECUTORS'"
  fi
  if [ ! -z "$SLAVE_LABELS" ]; then
      PARAMS="$PARAMS -labels '$SLAVE_LABELS'"
  fi
  if [ ! -z "$SLAVE_MODE" ]; then
      PARAMS="$PARAMS -mode '$SLAVE_MODE'"
  fi

  # if -master is not provided and using --link jenkins:jenkins
  if [ ! -z "$SLAVE_PARAMS" ]; then
    PARAMS="$PARAMS $SLAVE_PARAMS"
  fi

  echo Running java $JAVA_OPTS -jar $JAR -fsroot $HOME $PARAMS "$@"
  exec java $JAVA_OPTS -jar $JAR -fsroot $HOME $PARAMS "$@"
fi

# As argument is not jenkins, assume user want to run his own process, for sample a `bash` shell to explore this image
exec "$@"


