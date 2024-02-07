OMERO systemd Jenkins agent
===========================

Docker Jenkins agent image for OMERO devspace.

###  Docker

1. Build container:

        make

    with args

        make BUILDARGS="--build-arg USER_ID=$UID"

    all available build-arg:

        USER_ID
        JAVAVER
        EXE4J_VERSION
        JENKINS_SWARM_VERSION

2. To run container

    UNIX:

        make start ENV="-e JENKINS_PORT_8080_TCP_ADDR=$JENKINS_ADDR -e JENKINS_PORT_8080_TCP_PORT=$JENKINS_PORT"

    OSX:

        make start PORTS="--privileged" ENV="-e JENKINS_PORT_8080_TCP_ADDR=$JENKINS_ADDR -e JENKINS_PORT_8080_TCP_PORT=$JENKINS_PORT"

The compose creates fully working Jenkins CI master and agent with full `sudo` rights. Jenkins swarm plugin is automatically started via systemd.
