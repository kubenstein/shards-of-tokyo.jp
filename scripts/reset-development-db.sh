#!/bin/bash
rm app/db/*.db

HEROKU_RELEASE_VERSION=dev \
CLEARDB_DATABASE_URL='sqlite://./app/db/events.db' \
DATABASE_URL='sqlite://./app/db/state.db' \
ruby ./app/tasks/deploy_release_phase.rb

ruby ./app/db/seeds.rb
