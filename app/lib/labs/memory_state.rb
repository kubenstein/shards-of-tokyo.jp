module SoT
  class MemoryState
    def initialize
      @data = {}
    end

    def add_event(event)
      handler_name = ['SoT::', event.name.split('_').map(&:capitalize).join, 'EventHandler'].join
      return unless Object.const_defined?(handler_name)

      handler_class = Object.const_get(handler_name)
      handler_class.new.call(event, self)
    end

    def get_resources(type, search_opts = {})
      (@data[type] ||= []).select { |item|
        search_opts.to_a.all? { |condition| item[condition[0]] == condition[1] }
      }
    end

    # only for eventHandlers

    def add_resource(type, data)
      (@data[type] ||= []) << data
    end

    def remove_resource(type, search_opts)
      (@data[type] ||= []).reject! { |item|
        search_opts.to_a.all? { |condition| item[condition[0]] == condition[1] }
      }
    end

    def update_resource(type, id, data)
      remove_resource(type, id: id)
      add_resource(type, data)
    end
  end
end
