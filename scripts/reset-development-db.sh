#!/bin/bash
rm app/db/development.db
ruby -r './app/lib/lib' -e "SoT::SqliteEventStore.configure('./app/db/development.db')"
ruby ./app/db/seeds.rb
