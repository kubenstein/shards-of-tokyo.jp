module SoT
  Event::LOGIN_TOKEN_CONFIRMED = 'login_token_confirmed'

  class LoginTokenConfirmedEventHandler
    def call(event, state)
      login_token = event.payload
      state.update_resource(:login_tokens, login_token[:id], confirmed: true)
    end
  end
end
