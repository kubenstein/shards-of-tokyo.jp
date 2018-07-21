require './app/lib/lib'

state = APP_DEPENDENCIES[:state]
state.remove_old_dbs
