module SoT
  Event::MESSAGE_CREATED = 'message_created'
  
  class MessageCreatedEventHandler
    def call(event, state)
      message = event.payload
      state.add_resource(:messages, message)
    end
  end
end
