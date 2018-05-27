module SoT
  class User
    include Eventable

    attr_reader :email, :id

    def initialize(id:, email:)
      @id = id
      @email = email
    end
  end
end
