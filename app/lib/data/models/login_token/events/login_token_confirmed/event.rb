module SoT
  module LoginTokenConfirmedV1Event
    NAME = 'login_token_confirmed_v1'

    def self.build(login_token)
      payload = { id: login_token.id }
      Event.build(name: NAME, payload: payload, requester_id: login_token.user.id)
    end

    def self.handle(event, state)
      login_token_id = event.payload[:id]
      state.update_resource(:login_tokens, login_token_id, confirmed: true)
    end
  end
end
