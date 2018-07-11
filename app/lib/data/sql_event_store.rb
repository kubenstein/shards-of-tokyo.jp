require 'sequel'
require 'json'

module SoT
  class SqlEventStore
    def initialize(connection_uri)
      @connection = Sequel.connect(connection_uri)
      @subscribers = []
    end

    def add_events(events)
      events.each { |event| add_event(event) }
    end

    def add_event(event)
      event_attrs = Serialize.new.call(event)
      @connection[:events].insert(event_attrs)
      @subscribers.each { |es| es.add_event(event) }
    end

    def fetch_events_from(event_id)
      from_event_id = (@connection[:events].first(id: event_id) || { _id: 0 })[:_id]

      @connection[:events].where { _id > from_event_id }.map { |data|
        data[:payload] = JSON.parse(data[:payload], symbolize_names: true)
        Event.new(data)
      }
    end

    def add_subscriber(subscriber, fetch_events_from:)
      @subscribers << subscriber
      fetch_events_from(fetch_events_from).each { |event| subscriber.add_event(event) }
      self
    end

    def self.configure(connection_uri)
      connection = Sequel.connect(connection_uri)
      connection.create_table(:events) do
        primary_key :_id
        String :id, index: true
        String :name
        String :handler_version
        String :requester_id
        Text :payload
        Time :created_at
      end
    end
  end
end
