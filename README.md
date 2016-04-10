OMERO systemd Jenkins slave
===========================

Docker Jenkins slave image for OMERO devspace.

###  Docker

1. Build container:

        make

    with args

        make BUILDARGS="--build-arg JAVAVER=$JAVAVER --build-arg EXE4J_VERSION=$EXE4J_VERSION --build-arg JENKINS_SWARM_VERSION=$JENKINS_SWARM_VERSION"

2. To run container

    UNIX:

        make start ENV="-e JENKINS_PORT_8080_TCP_ADDR=$JENKINS_ADDR -e JENKINS_PORT_8080_TCP_PORT=$JENKINS_PORT" VOLUME="-v /sys/fs/cgroup:/sys/fs/cgroup:ro -v /run"

    OSX:

        make start PORTS="--privileged" ENV="-e JENKINS_PORT_8080_TCP_ADDR=$JENKINS_ADDR -e JENKINS_PORT_8080_TCP_PORT=$JENKINS_PORT"

The compose creates fully working Jenkins CI master and slave with full `sudo` rights. Jenkins swarm plugin is automatically started via systemd.
