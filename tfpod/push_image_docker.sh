#!/bin/bash

docker build . -t $1
docker tag $1 docker.io/kcyu2014/tensorflow:$1
docker push docker.io/kcyu2014/tensorflow:$1
