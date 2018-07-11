module SoT
  module UserCreatedEvent
    NAME = 'user_created'
    HANDLER_VERSION = 1

    def self.build(user, requester_id: nil)
      payload = Serialize.new.call(user)
      Event.build(name: NAME, handler_version: HANDLER_VERSION, payload: payload, requester_id: requester_id)
    end

    def self.handle_v1(event, state)
      user = event.payload
      state.add_resource(:users, user)
    end
  end
end
