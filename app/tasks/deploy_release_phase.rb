require './app/lib/lib'

event_store = APP_DEPENDENCIES[:event_store]
unless event_store.configured?
  event_store.configure
end

state = APP_DEPENDENCIES[:state]
unless state.configured?
  state.configure
  state.connect_to_event_store
end
