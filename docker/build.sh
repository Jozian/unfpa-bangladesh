#!/bin/bash

set -euox pipefail

BUILD_NGINX="docker build -f nginx/Dockerfile . -t nginx:prim-latest"
BUILD_BEANSTALK="docker build -f beanstalkd/Dockerfile . -t beanstalkd:prim-latest"
BUILD_SOLR="docker build -f solr/Dockerfile ../ -t solr:prim-latest"
BUILD_APP="docker build -f application/Dockerfile ../ -t application:prim-latest"
BUILD_DEV="docker build -f development/Dockerfile ../ -t development:prim-latest"
BUILD_POSTGRES="docker build -f postgres/Dockerfile . -t postgres:prim-latest"

# if no params are set then set $1 to all
if [ $# -eq 0 ];
then
  printf "Building all\\n"
  set -- "all"
fi

# this could use getopts for building multiple containers
case $1 in
  nginx)
    eval "$BUILD_NGINX"
    ;;
  beanstalk)
    eval "$BUILD_BEANSTALK"
    ;;
  solr)
    eval "$BUILD_SOLR"
    ;;
  app)
    eval "$BUILD_APP"
    ;;
  postgres)
    eval "$BUILD_POSTGRES"
    ;;
  all)
    eval "$BUILD_APP"
    eval "$BUILD_DEV"
    eval "$BUILD_SOLR"
    eval "$BUILD_BEANSTALK"
    eval "$BUILD_NGINX"
    eval "$BUILD_POSTGRES"
    ;;
  prod)
    eval "$BUILD_APP"
    eval "$BUILD_SOLR"
    eval "$BUILD_BEANSTALK"
    eval "$BUILD_NGINX"
    eval "$BUILD_POSTGRES"
    ;;
  dev)
    eval "$BUILD_DEV"
    eval "$BUILD_SOLR"
    eval "$BUILD_BEANSTALK"
    eval "$BUILD_NGINX"
    eval "$BUILD_POSTGRES"
    ;;
esac
