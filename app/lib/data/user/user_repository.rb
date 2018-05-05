module SoT
  class UserRepository
    def create_user(user)
      # persist... and return user with id
      User.new(email: user.email, id: Time.new.to_i)
    end

    def find(id)
      # retrive...
      User.new(email: 'dummy@dummy.pl', id: Time.new.to_i)
    end

    def find_me
      # retrive...
      User.new(email: 'niewczas.jakub@gmail.com', id: Time.new.to_i)
    end
  end
end
