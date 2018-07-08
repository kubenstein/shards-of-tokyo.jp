module SoT
  module MessageCreatedEvent
    NAME = 'message_created'

    def self.build(message)
      payload = Serialize.new.call(message)
      Event.new(name: NAME, payload: payload)
    end

    def self.handle(event, state)
      message_attrs = event.payload
      state.add_resource(:messages, message_attrs)
    end
  end
end
