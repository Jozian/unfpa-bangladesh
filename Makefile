.PHONY: all base-build base-build-no-cache base-push build build-no-cache down deps-down prod-down network phony-explicit shell up deps-up prod-up

ORGANIZATION = jozian
TAG=$(shell date +%Y%m%d)
CLIENT_NAME = primero
DOCKER_COMPOSE_ARGS =
NETWORK_NAME = primero
NETWORK_ID = $(shell docker network ls -qf name=${NETWORK_NAME})
SRCROOT=$(shell pwd)

# Variables for build
OS_NAME=$(shell uname)
UID=$(shell id -u)
GID=$(shell id -g)
GIT_COMMIT_HASH=$(shell git rev-parse HEAD)
BUILD_ARGS=

BACKBURNER_IMAGE = backburner
BASE_IMAGE = primero-base
BEANSTALKD_IMAGE = beanstalkd
COUCHDB_IMAGE = couchdb
COUCH_WATCHER_IMAGE = couchwatcher
SCHEDULER_IMAGE = scheduler

ifneq (${OS_NAME}, Darwin)
	BUILD_ARGS+= --build-arg UID=${UID} --build-arg GID=${GID}
endif

backburner-build: network
	@docker-compose build --pull ${BUILD_ARGS} ${BACKBURNER_IMAGE}
	@docker-compose run --rm ${BACKBURNER_IMAGE}

backburner-build-no-cache: network
	@docker-compose build --pull --no-cache ${BUILD_ARGS} ${BACKBURNER_IMAGE}
	@docker-compose run --rm ${BACKBURNER_IMAGE}

backburner-push:
	@docker push ${ORGANIZATION}/${BACKBURNER_IMAGE}
	@docker tag ${ORGANIZATION}/${BACKBURNER_IMAGE} ${ORGANIZATION}/${BACKBURNER_IMAGE}:${TAG}
	@docker push ${ORGANIZATION}/${BACKBURNER_IMAGE}:${TAG}

backburner-shell:
	@docker-compose exec ${BACKBURNER_IMAGE} bash

backburner-up: network
	@docker-compose up ${BACKBURNER_IMAGE}

beanstalkd-build:
	@docker build --tag ${ORGANIZATION}/${BEANSTALKD_IMAGE} -f docker/beanstalkd/Dockerfile ./docker/beanstalkd/

beanstalkd-build-no-cache:
	@docker build --pull --no-cache --tag ${ORGANIZATION}/${BEANSTALKD_IMAGE} -f docker/beanstalkd/Dockerfile ./docker/beanstalkd/

beanstalkd-push:
	@docker push ${ORGANIZATION}/${BEANSTALKD_IMAGE}
	@docker tag ${ORGANIZATION}/${BEANSTALKD_IMAGE} ${ORGANIZATION}/${BEANSTALKD_IMAGE}:${TAG}
	@docker push ${ORGANIZATION}/${BEANSTALKD_IMAGE}:${TAG}

base-build:
	@docker build --tag ${ORGANIZATION}/${BASE_IMAGE} -f Dockerfile.base .

base-build-no-cache:
	@docker build --pull --no-cache --tag ${ORGANIZATION}/${BASE_IMAGE} -f Dockerfile.base .

base-push:
	@docker push ${ORGANIZATION}/${BASE_IMAGE}
	@docker tag ${ORGANIZATION}/${BASE_IMAGE} ${ORGANIZATION}/${BASE_IMAGE}:${TAG}
	@docker push ${ORGANIZATION}/${BASE_IMAGE}:${TAG}

build: network
	@docker-compose build --pull ${BUILD_ARGS}
	@docker-compose run --rm ${CLIENT_NAME}

build-no-cache: network
	@docker-compose build --pull --no-cache ${BUILD_ARGS}
	@docker-compose run --rm ${CLIENT_NAME}

couchdb-build:
	@docker build --tag ${ORGANIZATION}/${COUCHDB_IMAGE} -f docker/db/Dockerfile ./docker/db/

couchdb-build-no-cache:
	@docker build --pull --no-cache --tag ${ORGANIZATION}/${COUCHDB_IMAGE} -f docker/db/Dockerfile ./docker/db/

couchdb-push:
	@docker push ${ORGANIZATION}/${COUCHDB_IMAGE}
	@docker tag ${ORGANIZATION}/${COUCHDB_IMAGE} ${ORGANIZATION}/${COUCHDB_IMAGE}:${TAG}
	@docker push ${ORGANIZATION}/${COUCHDB_IMAGE}:${TAG}

couchwatcher-build: network
	@docker-compose build --pull ${BUILD_ARGS} ${COUCH_WATCHER_IMAGE}
	@docker-compose run --rm ${COUCH_WATCHER_IMAGE}

couchwatcher-build-no-cache: network
	@docker-compose build --pull --no-cache ${BUILD_ARGS} ${COUCH_WATCHER_IMAGE}
	@docker-compose run --rm ${COUCH_WATCHER_IMAGE}

couchwatcher-push:
	@docker push ${ORGANIZATION}/${COUCH_WATCHER_IMAGE}
	@docker tag ${ORGANIZATION}/${COUCH_WATCHER_IMAGE} ${ORGANIZATION}/${COUCH_WATCHER_IMAGE}:${TAG}
	@docker push ${ORGANIZATION}/${COUCH_WATCHER_IMAGE}:${TAG}

couchwatcher-shell:
	@docker-compose exec ${COUCH_WATCHER_IMAGE} bash

couchwatcher-up: network
	@docker-compose up ${COUCH_WATCHER_IMAGE}

deps-down: network
	@docker-compose --file ./docker-compose.development.deps.yml down

deps-up: network
	@docker-compose --file ./docker-compose.development.deps.yml up

down:
	@docker-compose down

network:
	@if [ -n "${NETWORK_ID}" ]; then \
		echo "The ${NETWORK_NAME} network already exists. Skipping..."; \
	else \
		docker network create -d bridge ${NETWORK_NAME}; \
	fi

scheduler-build: network
	@docker-compose build --pull ${BUILD_ARGS} ${SCHEDULER_IMAGE}
	@docker-compose run --rm ${SCHEDULER_IMAGE}

scheduler-build-no-cache: network
	@docker-compose build --pull --no-cache ${BUILD_ARGS} ${SCHEDULER_IMAGE}
	@docker-compose run --rm ${SCHEDULER_IMAGE}

scheduler-push:
	@docker push ${ORGANIZATION}/${SCHEDULER_IMAGE}
	@docker tag ${ORGANIZATION}/${SCHEDULER_IMAGE} ${ORGANIZATION}/${SCHEDULER_IMAGE}:${TAG}
	@docker push ${ORGANIZATION}/${SCHEDULER_IMAGE}:${TAG}

scheduler-shell:
	@docker-compose exec ${SCHEDULER_IMAGE} bash

scheduler-up: network
	@docker-compose up ${SCHEDULER_IMAGE}

shell:
	@docker-compose exec ${CLIENT_NAME} bash

up: network
	@docker-compose up ${CLIENT_NAME}

prod-down: network
	@docker-compose --file ./docker-compose.production.yml down

prod-up: network
	@docker-compose --file ./docker-compose.production.yml up
