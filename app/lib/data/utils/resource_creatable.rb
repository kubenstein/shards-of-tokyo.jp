module SoT
  module ResourceCreatable
    def create(obj)
      APP_DEPENDENCIES[:event_store].add_events(obj.events)
      obj.reset_events
      obj
    end
  end
end
