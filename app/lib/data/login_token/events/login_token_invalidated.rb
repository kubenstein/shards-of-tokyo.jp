module SoT
  Event::LOGIN_TOKEN_INVALIDATED = 'login_token_invalidated'
  
  class LoginTokenInvalidatedEventHandler
    def call(event, state)
      login_token = event.payload
      state.update_resource(:login_tokens, login_token[:id], invalidated: true)
    end
  end
end
