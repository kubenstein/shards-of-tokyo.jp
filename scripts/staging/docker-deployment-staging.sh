#!/bin/bash

COMMANDS=$(cat <<'END_SCRIPT'
  cd /home/src ;
  npm i -g heroku ;
  apk add git openssl ;
  heroku login --interactive ;
  git push -f https://git.heroku.com/sot-stage.git master
END_SCRIPT
)

docker run --rm -it -v "$PWD":/home/src/:ro node:10.10.0-alpine sh -c "$COMMANDS"
