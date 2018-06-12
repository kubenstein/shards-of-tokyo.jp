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

    def find(id)
      find_by(id: id)
    end

    def find_by(search_opts)
      attrs = state.get_resources(:login_tokens, search_opts)[0]
      return nil unless attrs
      LoginToken.new(attrs)
    end

    def find_valid(id)
      find_by(id: id, confirmed: false, invalidated: false)
    end
  end
end
