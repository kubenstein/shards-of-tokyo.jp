module SoT
  class MessageRepository
    include Import[
      :event_store
    ]

    def create_message(message:, requester_id:)
      payload = Serialize.new.call(message)
      event = Event.new(EVENTS::MESSAGE_CREATED, requester_id, payload)
      event_store.add_event(event)
      message
    end
  end
end
