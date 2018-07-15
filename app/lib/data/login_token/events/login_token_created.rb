module SoT
  module LoginTokenCreatedEvent
    NAME = 'login_token_created'
    HANDLER_VERSION = 1

    def self.build(login_token)
      payload = Serialize.new.call(login_token)
      Event.build(name: NAME, handler_version: HANDLER_VERSION, payload: payload, requester_id: login_token.user.id)
    end

    def self.handle_v1(event, state)
      login_token_attrs = event.payload
      state.add_resource(:login_tokens, login_token_attrs)
    end
  end
end
