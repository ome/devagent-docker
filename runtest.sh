#!/bin/bash

set -e -u -x

PRIVILEGED=""
VOLUMES=""
# start docker container
if [[ "darwin" == "${OSTYPE//[0-9.]/}" ]]; then
    PRIVILEGED="--privileged"
fi

docker run -d $PRIVILEGED --name jenkins jenkins:1.651.1
docker inspect -f {{.State.Running}} jenkins

d=10
while ! docker logs jenkins 2>&1 | grep "Jenkins is fully up and running"
do sleep 10
  d=$[$d -1]
  if [ $d -lt 0 ]; then
    exit 1
  fi
done

JENKINS_ADDR=`docker inspect --format '{{ .NetworkSettings.IPAddress }}' jenkins`
JENKINS_PORT=50000
ENV="-e JENKINS_PORT_8080_TCP_ADDR=${JENKINS_ADDR} -e JENKINS_PORT_8080_TCP_PORT=${JENKINS_PORT}"
MYPATH=`pwd`
VOLUMES="-v $MYPATH:/home/omero"
make start PORTS=$PRIVILEGED ENV="$ENV" VOLUMES="$VOLUMES"

docker inspect -f {{.State.Running}} devslave

SLAVE_ADDR=`docker inspect --format '{{ .NetworkSettings.IPAddress }}' devslave`

d=10
while ! docker logs jenkins 2>&1 | grep "from /${SLAVE_ADDR}"
do sleep 10
  d=$[$d -1]
  if [ $d -lt 0 ]; then
    exit 1
  fi
done

# check permissions
docker exec -it devslave /bin/bash -c "sudo -u omero touch /home/omero/file"
if [ $(ls -ld file | awk '{print $3}') != $(whoami) ]; then
  exit 1
fi
ls -al file

docker logs jenkins

# CLEANUP
make stop
make rm
docker stop jenkins
docker rm jenkins