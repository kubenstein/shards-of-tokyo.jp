module SoT
  class MemoryProxyEventStore
    def initialize
      @subscribers = []
    end

    def add_events(events)
      events.each { |event| add_event(event) }
    end

    def add_event(event)
      @subscribers.each { |es| es.add_event(event) }
    end

    def fetch_events_from(event_id)
      []
    end

    def add_subscriber(subscriber, fetch_events_from:)
      @subscribers << subscriber
      fetch_events_from(fetch_events_from).each { |event| subscriber.add_event(event) }
      self
    end
  end
end
