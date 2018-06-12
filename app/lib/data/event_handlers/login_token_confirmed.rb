module SoT
  class LoginTokenConfirmedEventHandler
    def call(event, state)
      login_token = event.payload
      state.update_resource(:login_tokens, login_token[:id], confirmed: true)
    end
  end
end
