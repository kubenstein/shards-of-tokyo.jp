#!/bin/bash

HEROKU_RELEASE_VERSION=dev \
SERVER_BASE_URL='http://localhost:3000/' \
EVENTS_DATABASE_URL='sqlite://./app/db/events.db' \
DATABASE_URL='sqlite://./app/db/state.db' \
DOTPAY_ID='775643' \
DOTPAY_PIN='n7qmQIld75d09smyE7XZcIOPxiyOsdqN' \
irb -r './app/lib/lib'
