OMERO systemd Jenkins master and slave CI template
=========================================

Docker image for OMERO devspace.

###  Docker

1. Build container:

        make

    with args

        make BUILDARGS="--build-arg JAVAVER=$JAVAVER --build-arg EXE4J_VERSION=$EXE4J_VERSION --build-arg JENKINS_SWARM_VERSION=$JENKINS_SWARM_VERSION"
2. To run container

        make start VOLUME="-v /sys/fs/cgroup:/sys/fs/cgroup:ro -v /run"

    NOTE: if you are using docker-machine use --privileged

The compose creates fully working Jenkins CI master and slave with full `sudo` rights. Jenkins swarm plugin is automatically started via systemd. Test Jenkins nodes via http://$(docker-machine ip dev):8080/
