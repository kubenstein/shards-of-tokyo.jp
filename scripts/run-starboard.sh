. ~/.nvm/nvm.sh
nvm use v7.2.0

REMOTE_NAME=${REMOTE_NAME:-dropbox}

LOCAL_REPO_DIR='./tmp/starboard/' \
SYNCING_INTERVAL=60 \
REPO_URL=$(git remote show $REMOTE_NAME | grep 'Fetch URL' | cut -d' ' -f5) \
starboard
