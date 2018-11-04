#!/bin/bash

COMMANDS=$(cat <<'END_SCRIPT'
  cd /home/src ;
  npm i -g heroku ;
  apk add git openssl ;
  heroku login ;
  git push https://git.heroku.com/shards-of-tokyo-jp.git master
END_SCRIPT
)

docker run --rm -it -v "$PWD":/home/src/:ro node:10.10.0-alpine sh -c "$COMMANDS"
