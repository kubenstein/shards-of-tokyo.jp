#!/bin/bash

HEROKU_RELEASE_VERSION=dev \
EVENTS_DATABASE_URL='sqlite://./app/db/events.db' \
DATABASE_URL='sqlite://./app/db/state.db' \
STRIPE_API_SECRET_KEY='sk_test_z2aoTikjCm0urBhNoMEzhtZr' \
STRIPE_API_PUBLIC_KEY='pk_test_RbiERyephGoRFvc2q1nPrlKe' \
irb -r './app/lib/lib'
