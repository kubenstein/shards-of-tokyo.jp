module SoT
  module MessageCreatedEvent
    NAME = 'message_created'
    HANDLER_VERSION = 1

    def self.build(message)
      payload = Serialize.new.call(message)
      Event.build(name: NAME, handler_version: HANDLER_VERSION, payload: payload, requester_id: message.user.id)
    end

    def self.handle_v1(event, state)
      message_attrs = event.payload
      state.add_resource(:messages, message_attrs)
    end
  end
end
