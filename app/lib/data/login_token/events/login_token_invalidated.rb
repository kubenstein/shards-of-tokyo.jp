module SoT
  module LoginTokenInvalidatedEvent
    NAME = 'login_token_invalidated'

    def self.build(login_token)
      payload = { id: login_token.id }
      Event.new(name: NAME, payload: payload)
    end

    def self.handle(event, state)
      login_token_id = event.payload.id
      state.update_resource(:login_tokens, login_token_id, invalidated: true)
    end
  end
end
