module SoT
  class UserRepository
    include Import[:state]
    include ResourceSavable

    def new_user(email:)
      user_attr = { id: GenerateId.new.call, email: email }
      User.new(user_attr).tap { |user|
        user.add_event(Event.for(EVENTS::USER_CREATED, user))
      }
    end

    def find_by(search_opts)
      attrs = state.get_resources(:users, search_opts)[0]
      return nil unless attrs
      User.new(attrs)
    end

    def find_me
      find_by(email: 'niewczas.jakub@gmail.com')
    end
  end
end
