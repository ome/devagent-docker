OMERO systemd Jenkins master and slave CI template
=========================================

Docker image for OMERO devspace.

###  Docker

1. Build container:

        make build

2. To run container

        cd slave

    - Unix:

            make run

    - OSX:

            make run_osx

The compose creates fully working Jenkins CI master and slave with full `sudo` rights. Jenkins swarm plugin is automatically started via systemd. Test Jenkins nodes via http://$(docker-machine ip dev):8080/
