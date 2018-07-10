module SoT
  module LoginTokenConfirmedEvent
    NAME = 'login_token_confirmed'
    VERSION = 1

    def self.build(login_token)
      payload = { id: login_token.id }
      Event.new(name: NAME, version: VERSION, payload: payload)
    end

    def self.handle(event, state)
      login_token_id = event.payload.id
      state.update_resource(:login_tokens, login_token_id, confirmed: true)
    end
  end
end
