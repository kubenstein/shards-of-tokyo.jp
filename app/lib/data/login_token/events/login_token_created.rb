module SoT
  module LoginTokenCreatedEvent
    NAME = 'login_token_created'

    def self.build(login_token)
      payload = Serialize.new.call(login_token)
      Event.new(name: NAME, payload: payload)
    end

    def self.handle(event, state)
      login_token_attrs = event.payload
      state.add_resource(:login_tokens, login_token_attrs)
    end
  end
end
