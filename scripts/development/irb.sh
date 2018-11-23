#!/bin/bash

HEROKU_RELEASE_VERSION=dev \
EVENTS_DATABASE_URL='sqlite://./app/db/events.db' \
DATABASE_URL='sqlite://./app/db/state.db' \
irb -r './app/lib/lib'
