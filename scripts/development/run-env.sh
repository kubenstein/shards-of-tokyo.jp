#!/bin/bash
HEROKU_RELEASE_VERSION=dev \
EVENTS_DATABASE_URL='sqlite://./app/db/events.db' \
DATABASE_URL='sqlite://./app/db/state.db' \
shotgun config.ru --port 3000 --host 0.0.0.0
