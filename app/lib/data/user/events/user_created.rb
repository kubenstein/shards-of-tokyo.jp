module SoT
  module UserCreatedEvent
    NAME = 'user_created'
    HANDLER_VERSION = 1

    def self.build(user)
      payload = Serialize.new.call(user)
      Event.build(name: NAME, handler_version: HANDLER_VERSION, payload: payload)
    end

    def self.handle(event, state)
      user = event.payload
      state.add_resource(:users, user)
    end
  end
end
