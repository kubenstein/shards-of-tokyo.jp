module SoT
  class MessageCreatedEventHandler
    def call(event, state)
      message = event.payload
      state.add_resource(:messages, message)
    end
  end
end
