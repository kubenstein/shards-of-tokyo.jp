module SoT
  class LoginTokenRepository
    include Import[:state]
    include ResourceSavable

    def new_login_token(user, session_id)
      lt_attr = {
        id: GenerateId.new.call(length: 20),
        session_id: session_id,
        user: user,
        invalidated: false,
        confirmed: false,
        created_at: Time.now,
      }
      LoginToken.new(lt_attr).tap { |lt|
        lt.add_event(LoginTokenCreatedEvent.build(lt))
      }
    end

    def last
      attrs = state.get_resources(:login_tokens, {}, [:created_at, :desc], 1)[0]
      return nil unless attrs

      user_attrs = state.get_resources(:users, id: attrs[:user_id])[0]
      attrs[:user] = User.new(user_attrs)
      LoginToken.new(attrs)
    end

    def all
      find_all_by({})
    end

    def find(id)
      find_by(id: id)
    end

    def find_all_by(search_opts)
      tokens_attrs = state.get_resources(:login_tokens, search_opts)
      user_ids = tokens_attrs.map { |lta| lta[:user_id] }
      users_attrs = state.get_resources(:users, id: user_ids)

      # users
      users = users_attrs.map { |user_attrs| User.new(user_attrs) }

      # tokens
      tokens_attrs.map do |token_attrs|
        token_attrs[:user] = users.find { |u| u.id == token_attrs[:user_id] }
        LoginToken.new(token_attrs)
      end
    end

    def find_by(search_opts)
      find_all_by(search_opts)[0]
    end

    def find_valid(id)
      find_by(id: id, confirmed: false, invalidated: false)
    end
  end
end
