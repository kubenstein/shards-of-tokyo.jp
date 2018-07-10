module SoT
  module UserCreatedEvent
    NAME = 'user_created'
    VERSION = 1

    def self.build(user)
      payload = Serialize.new.call(user)
      Event.new(name: NAME, version: VERSION, payload: payload)
    end

    def self.handle(event, state)
      user = event.payload
      state.add_resource(:users, user)
    end
  end
end
