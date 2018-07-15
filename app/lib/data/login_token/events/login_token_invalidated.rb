module SoT
  module LoginTokenInvalidatedEvent
    NAME = 'login_token_invalidated'
    HANDLER_VERSION = 1

    def self.build(login_token)
      payload = { id: login_token.id }
      Event.build(name: NAME, handler_version: HANDLER_VERSION, payload: payload, requester_id: login_token.user.id)
    end

    def self.handle_v1(event, state)
      login_token_id = event.payload.id
      state.update_resource(:login_tokens, login_token_id, invalidated: true)
    end
  end
end
