require 'sequel'

module SoT
  class SqlState
    prepend Import[:logger]

    def initialize(connection_uri, event_store, database_version: '')
      @connection = Sequel.connect(connection_uri, logger: logger)
      @connection.sql_log_level = :debug

      @event_store = event_store
      @database_version = database_version

      connect_to_event_store if configured?
    end

    def connect_to_event_store
      @event_store.add_subscriber(self, fetch_events_from: last_event_id)
    end

    def disconnect_from_event_store
      @event_store.remove_subscriber(self)
    end

    def add_event(event)
      ApplyEvent.new.call(event, self)
      save_last_event_id(event)
    end

    def get_resources(type, search_opts = {}, order_by = [:id, :asc], limit = nil)
      results = table(type).where(search_opts)
      results = order_by[1] == :asc ? results.order(order_by[0]) : results.reverse(order_by[0])
      results = results.limit(limit) if limit
      results.all
    end

    def add_resource(type, data)
      table(type).insert(data)
    end

    def remove_resource(type, search_opts)
      table(type).where(search_opts).delete
    end

    def update_resource(type, id, data)
      table(type).where(id: id).update(data)
    end

    def last_event_id
      table(:system).first(key: 'last_event_id')[:value]
    end

    def remove_old_dbs
      @connection.tables
                 .reject { |table_name| table_name.to_s.start_with?("#{@database_version}_") }
                 .each { |table_name|
        puts "dropping table #{table_name}"
        @connection.drop_table(table_name)
      }
    end

    def configured?
      @connection.table_exists?("#{@database_version}_system")
    end

    def configure # rubocop:disable Metrics/MethodLength
      @connection.create_table("#{@database_version}_users") do
        String :id, primary_key: true
        String :email
        String :stripe_customer_id
        Time :created_at
      end

      @connection.create_table("#{@database_version}_messages") do
        String :id, primary_key: true
        String :order_id
        String :user_id
        Text :body
        Time :created_at
      end

      @connection.create_table("#{@database_version}_orders") do
        String :id, primary_key: true
        String :user_id
        Bignum :price
        String :currency
        Time :created_at
      end

      @connection.create_table("#{@database_version}_login_tokens") do
        String :id, primary_key: true
        String :user_id
        String :session_id
        Bool :invalidated
        Bool :confirmed
        Time :created_at
      end

      @connection.create_table("#{@database_version}_payments") do
        String :id, primary_key: true
        String :order_id
        String :payment_id
        Bignum :amount
        String :currency
        String :error
        Time :created_at
      end

      @connection.create_table("#{@database_version}_system") do
        String :key, primary_key: true
        String :value
      end
      @connection[:"#{@database_version}_system"].insert(key: 'last_event_id', value: nil)
    end

    private

    def save_last_event_id(event)
      table(:system).where(key: 'last_event_id').update(value: event.id)
    end

    def table(name)
      @connection[:"#{@database_version}_#{name}"]
    end
  end
end
