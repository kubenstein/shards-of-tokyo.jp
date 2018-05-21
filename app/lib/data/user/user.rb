module SoT
  class User
    include Eventable

    attr_reader :email, :id

    def initialize(id: nil, email:)
      @id = id || GenerateId.new.call
      @email = email

      add_event(Event.for(EVENTS::USER_CREATED, self)) unless id
    end
  end
end
