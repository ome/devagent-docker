#!/bin/bash

set -e -u -x

PRIVILIGED=""
VOLUMES=""
# start docker container
if [[ "darwin" == "${OSTYPE//[0-9.]/}" ]]; then
    PRIVILIGED="--privileged"
fi

docker run -d $PRIVILIGED --name jenkins jenkins
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
if [[ "darwin" != "${OSTYPE//[0-9.]/}" ]]; then
  VOLUMES="-v /home/travis/build/openmicroscopy/devslave-c7-docker/testperm:/home/omero/testperm"
fi
make start PORTS=$PRIVILIGED ENV="$ENV" VOLUMES=$VOLUMES

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

docker exec -it devslave /bin/bash -c "su - omero -c \"mkdir -p /home/omero/testperm; echo 'this is test' > /home/omero/testperm/file \""
docker exec -it devslave /bin/bash -c "cat /home/omero/testperm/file"

docker logs jenkins

# CLEANUP
make stop
make rm
docker stop jenkins
docker rm jenkins