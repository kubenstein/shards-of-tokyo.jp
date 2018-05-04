module SoT
  class UserRepository
    def create_user(user)
      # persist... and return user with id
      User.new(email: user.email, id: Time.new.to_i)
    end
  end
end
