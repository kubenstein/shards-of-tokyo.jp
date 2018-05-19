require 'sequel'

module SoT
  class SqlState
    def initialize(connection_uri)
      @connection = Sequel.connect(connection_uri)
    end

    def add_event(event)
      handler_name = ['SoT::', event.name.split('_').map(&:capitalize).join, 'EventHandler'].join
      return unless Object.const_defined?(handler_name)

      handler_class = Object.const_get(handler_name)
      handler_class.new.call(event, self)
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

    def clear_state!
      @connection[:users].delete
      @connection[:messages].delete
      self
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
        String :to_user_id
        Text :body
      end
    end
  end
end
