module SoT
  class User
    attr_reader :email, :id

    def initialize(id: nil, email:)
      @id = id
      @email = email
    end
  end
end
