module SoT
  class MessageRepository
    include Import[
      :event_store
    ]

    def create_message(message:, requester_id:)
      message_with_id = CloneWithId.new.call(message)
      payload = Serialize.new.call(message_with_id)
      event = Event.new(EVENTS::MESSAGE_CREATED, requester_id, payload)
      event_store.add_event(event)
      message_with_id
    end
  end
end
