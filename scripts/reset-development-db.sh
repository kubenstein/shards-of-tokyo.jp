#!/bin/bash
rm app/db/*.db
ruby -r './app/lib/lib' -e "SoT::SqlEventStore.configure('sqlite://./app/db/events.db')"
ruby -r './app/lib/lib' -e "SoT::SqlState.configure('sqlite://./app/db/state.db', database_version: 'dev')"
ruby ./app/db/seeds.rb
