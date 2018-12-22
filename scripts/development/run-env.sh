#!/bin/bash
HEROKU_RELEASE_VERSION=dev \
EVENTS_DATABASE_URL='sqlite://./app/db/events.db' \
DATABASE_URL='sqlite://./app/db/state.db' \
PAYPAL_ENV='sandbox' \
PAYPAL_CLIENT_ID='Ae8y-aV7qaRi6XeLwdVUivsOQ-ZRJ3U05pRDtSzD62wibyOz_MvrxBhbI6Hx0c0FKorgYxOUqtIsSMTr' \
PAYPAL_SECRET='EARm8oY3Lp2S8VlnNpDpacBwo3or_jmTtrgm33I05fBurFDDgerO8XSIaItNblK7jFzk9rm2GLJOgExr' \
shotgun config.ru --port 3000 --host 0.0.0.0
