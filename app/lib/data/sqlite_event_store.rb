require 'sequel'
require 'json'

module SoT
  class SqliteEventStore
    def initialize(path_to_db)
      @connection = Sequel.connect("sqlite://#{path_to_db}")
      @subscribers = []
    end

    def add_event(event)
      @connection[:events].insert(name: event.name, requester_id: event.requester_id, payload: event.payload.to_json)
      @subscribers.each { |es| es.add_event(event) }
    end

    def fetch_all_events
      @connection[:events].all.map { |data|
        Event.new(data[:name], data[:requester_id], JSON.parse(data[:payload], symbolize_names: true))
      }
    end

    def add_subscriber(subscriber)
      @subscribers << subscriber
      fetch_all_events.each { |event| subscriber.add_event(event) }
      self
    end

    def self.configure(path_to_db)
      connection = Sequel.connect("sqlite://#{path_to_db}")
      connection.create_table(:events) do
        primary_key :id
        String :name
        String :requester_id
        Text :payload
      end
    end
  end
end
