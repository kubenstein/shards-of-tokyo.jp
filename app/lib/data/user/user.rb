module SoT
  class User
    attr_reader :email, :id

    def initialize(id: nil, email:)
      @id = id || GenerateId.new.call
      @email = email
    end
  end
end
