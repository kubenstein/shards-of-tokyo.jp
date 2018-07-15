require 'sequel'

module SoT
  class SqlState
    def initialize(connection_uri, event_store)
      @connection = Sequel.connect(connection_uri)
      @event_store = event_store
      connect_to_event_store
    end

    def add_event(event)
      ApplyEvent.new.call(event, self)
      save_last_event_id(event)
    end

    def get_resources(type, search_opts = {}, order_by = [:id, :asc])
      results = @connection[type].where(search_opts)
      results = (order_by[1] == :asc) ? results.order(order_by[0]) : results.reverse(order_by[0])
      results.all
    end

    def add_resource(type, data)
      @connection[type].insert(data)
    end

    def remove_resource(type, search_opts)
      @connection[type].where(search_opts).delete
    end

    def update_resource(type, id, data)
      @connection[type].where(id: id).update(data)
    end

    def last_event_id
      @connection[:system].first(key: 'last_event_id')[:value]
    end

    def reinitialize!
      disconnect_from_event_store
      @connection.drop_table(:users)
      @connection.drop_table(:messages)
      @connection.drop_table(:orders)
      @connection.drop_table(:login_tokens)
      @connection.drop_table(:payments)
      @connection.drop_table(:system)
      self.class.configure(@connection.uri)
      connect_to_event_store
      self
    end

    private

    def save_last_event_id(event)
      @connection[:system].where(key: 'last_event_id').update(value: event.id)
    end

    def connect_to_event_store
      @event_store.add_subscriber(self, fetch_events_from: last_event_id)
    end

    def disconnect_from_event_store
      @event_store.remove_subscriber(self)
    end

    def self.configure(connection_uri)
      connection = Sequel.connect(connection_uri)
      connection.create_table(:users) do
        String :id, primary_key: true
        String :email
        String :stripe_customer_id
      end

      connection.create_table(:messages) do
        String :id, primary_key: true
        String :order_id
        String :user_id
        Text :body
        Time :created_at
      end

      connection.create_table(:orders) do
        String :id, primary_key: true
        String :user_id
        Bignum :price
        String :currency
        Time :created_at
      end

      connection.create_table(:login_tokens) do
        String :id, primary_key: true
        String :user_id
        String :session_id
        Bool :invalidated
        Bool :confirmed
        Time :created_at
      end

      connection.create_table(:payments) do
        String :id, primary_key: true
        String :order_id
        String :payment_id
        Bignum :amount
        String :currency
        String :error
        Time :created_at
      end

      connection.create_table(:system) do
        String :key, primary_key: true
        String :value
      end
      connection[:system].insert(key: 'last_event_id', value: nil)
    end
  end
end
