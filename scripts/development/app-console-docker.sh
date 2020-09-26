#!/bin/bash
docker run -it --rm \
           -w /usr/src/app \
           -v gems:/usr/local/bundle -v "$PWD":/usr/src/app \
           ruby:2.3.1 \
           ${1:-'./scripts/development/app-console.sh'}
