module SoT
  class LoginTokenRepository
    include Import[:state]
    include ResourceSavable

    def new_login_token(user_id, session_id)
      lt_attr = {
        id: GenerateId.new.call(length: 20),
        session_id: session_id,
        user_id: user_id,
        invalidated: false,
        confirmed: false,
        created_at: Time.now,
      }
      LoginToken.new(lt_attr).tap { |lt|
        lt.add_event(Event.for(EVENTS::LOGIN_TOKEN_CREATED, lt))
      }
    end
  end
end
