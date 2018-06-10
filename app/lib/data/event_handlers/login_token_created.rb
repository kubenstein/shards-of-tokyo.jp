module SoT
  class LoginTokenCreatedEventHandler
    def call(event, state)
      login_token = event.payload
      state.add_resource(:login_tokens, login_token)
    end
  end
end
