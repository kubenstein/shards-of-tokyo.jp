module SoT
  class UserRepository
    include Import[:state]
    include ResourceSavable

    def new_user(email:)
      user_attr = {
        id: GenerateId.new.call,
        email: email,
        payment_gateway_customer_id: nil,
        created_at: Time.now,
      }

      User.new(user_attr).tap { |user|
        user.add_event(UserCreatedV1Event.build(user))
      }
    end

    def exists?(search_opts)
      !!state.get_resources(:users, search_opts)[0]
    end

    def find(id)
      find_by(id: id)
    end

    def find_by(search_opts)
      attrs = state.get_resources(:users, search_opts)[0]
      return nil unless attrs

      User.new(attrs)
    end

    def find_logged_in(session_id:)
      confirmend_token_attrs = state.get_resources(:login_tokens,
                                                   session_id: session_id, confirmed: true, invalidated: false)[0]
      return nil unless confirmend_token_attrs

      find(confirmend_token_attrs[:user_id])
    end

    def find_me
      find_by(email: User::ME_EMAIL)
    end
  end
end
