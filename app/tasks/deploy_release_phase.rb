require './app/lib/lib'

event_store = APP_COMPONENTS[:event_store]
event_store.configure unless event_store.configured?

state = APP_COMPONENTS[:state]
unless state.configured?
  state.configure
  state.connect_to_event_store
end
