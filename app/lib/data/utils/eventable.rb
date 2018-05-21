module SoT
  module Eventable
    def add_event(event)
      (@_uncommited_events ||= []) << event
    end

    def events
      (@_uncommited_events ||= [])
    end

    def reset_events
      @_uncommited_events = []
    end
  end
end
