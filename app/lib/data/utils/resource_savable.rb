module SoT
  module ResourceSavable
    def save(obj)
      APP_DEPENDENCIES[:event_store].add_events(obj.events)
      obj.reset_events
      obj
    end

    def create(obj)
      save(obj)
    end
  end
end
