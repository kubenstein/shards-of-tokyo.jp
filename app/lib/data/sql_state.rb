require 'sequel'

module SoT
  class SqlState
    def initialize(connection_uri)
      @connection = Sequel.connect(connection_uri)
    end

    def add_event(event)
      handler_name = ['SoT::', event.name.split('_').map(&:capitalize).join, 'EventHandler'].join
      if Object.const_defined?(handler_name)
        handler_class = Object.const_get(handler_name)
        handler_class.new.call(event, self)
      end
      save_last_event_id(event)
    end

    def get_resources(type, search_opts = {})
      @connection[type].where(search_opts).all
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

    def clear_state!
      @connection[:users].delete
      @connection[:messages].delete
      @connection[:orders].delete
      self
    end

    private

    def save_last_event_id(event)
      @connection[:system].where(key: 'last_event_id').update(value: event.id)
    end

    def self.configure(connection_uri)
      connection = Sequel.connect(connection_uri)
      connection.create_table(:users) do
        String :id, primary_key: true
        String :email
      end

      connection.create_table(:messages) do
        String :id, primary_key: true
        String :from_user_id
        String :order_id
        Text :body
      end

      connection.create_table(:orders) do
        String :id, primary_key: true
        String :user_id
      end

      connection.create_table(:system) do
        String :key, primary_key: true
        String :value
      end
      connection[:system].insert(key: 'last_event_id', value: nil)
    end
  end
end
