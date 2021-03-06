#!/bin/bash
rm -rf app/db/*.db
(
export HEROKU_RELEASE_VERSION=dev
export EVENTS_DATABASE_URL='sqlite://./app/db/events.db'
export DATABASE_URL='sqlite://./app/db/state.db'

ruby ./app/tasks/deploy_release_phase.rb
ruby ./app/db/seeds.rb
)
