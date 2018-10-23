module SoT
  module UserCreatedEvent
    NAME = 'user_created'

    def self.build(user)
      payload = Serialize.new.call(user)
      Event.build(name: NAME, payload: payload)
    end

    def self.handle(event, state)
      user = event.payload
      state.add_resource(:users, user)
    end
  end
end