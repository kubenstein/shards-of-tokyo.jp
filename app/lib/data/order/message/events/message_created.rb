module SoT
  module MessageCreatedEvent
    NAME = 'message_created'
    HANDLER_VERSION = 1

    def self.build(message)
      payload = Serialize.new.call(message)
      Event.build(name: NAME, handler_version: HANDLER_VERSION, payload: payload)
    end

    def self.handle(event, state)
      message_attrs = event.payload
      state.add_resource(:messages, message_attrs)
    end
  end
end
