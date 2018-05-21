module SoT
  class UserRepository
    include Import[:state]
    include ResourceCreatable

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
