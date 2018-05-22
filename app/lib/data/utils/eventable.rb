module SoT
  module Eventable
    def add_event(event)
      (@_uncommited_events ||= []) << event
    end

    def add_events(events_or_eventable)
      events = if events_or_eventable.respond_to?(:events)
                 events_or_eventable.events
               else
                 events_or_eventable
               end
      (@_uncommited_events ||= []).concat(events)
    end

    def events
      (@_uncommited_events ||= [])
    end

    def reset_events
      @_uncommited_events = []
    end
  end
end
