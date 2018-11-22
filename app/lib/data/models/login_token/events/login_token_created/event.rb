module SoT
  module LoginTokenCreatedV1Event
    NAME = 'login_token_created_v1'

    def self.build(login_token)
      payload = Serialize.new.call(login_token)
      Event.build(name: NAME, payload: payload, requester_id: login_token.user.id)
    end

    def self.handle(event, state)
      login_token_attrs = event.payload
      state.add_resource(:login_tokens, login_token_attrs)
    end
  end
end
