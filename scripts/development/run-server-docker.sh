#!/bin/bash
docker run -it --rm \
           -p 3000:3000 \
           -w /usr/src/app \
           -v gems:/usr/local/bundle -v "$PWD":/usr/src/app \
           ruby:2.3.1 \
           ${1:-'./scripts/development/run-server.sh'}
