NS = openmicroscopy
VERSION ?= local

REPO = devslave-c7
NAME = devslave

build:
	docker build $(BUILDARGS) -t $(NS)/$(REPO):$(VERSION) .

shell:
	docker run --rm --name $(NAME) -i -t $(PORTS) $(VOLUMES) $(ENV) $(NS)/$(REPO):$(VERSION) /bin/bash

run:
	docker run --rm --name $(NAME) $(PORTS) $(VOLUMES) $(ENV) $(NS)/$(REPO):$(VERSION)

start:
	docker run -d --name $(NAME) $(PORTS) $(VOLUMES) $(ENV) $(NS)/$(REPO):$(VERSION)

stop:
	docker stop $(NAME)

rm:
	docker rm $(NAME)

default: build

.PHONY: build push shell run start stop rm release