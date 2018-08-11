module SoT
  module Eventable
    def add_event(event)
      (@_uncommited_events ||= []) << event
    end

    def add_events(events)
      (@_uncommited_events ||= []).concat(events)
    end

    def events
      (@_uncommited_events ||= []) # rubocop:disable Naming/MemoizedInstanceVariableName
    end

    def reset_events
      @_uncommited_events = []
    end
  end
end
