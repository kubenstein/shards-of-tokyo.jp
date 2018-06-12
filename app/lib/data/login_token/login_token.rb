module SoT
  class LoginToken
    include Eventable

    attr_reader :id, :session_id, :user_id, :invalidated, :confirmed, :created_at

    def initialize(id:, session_id:, user_id:, invalidated:, confirmed:, created_at:)
      @id = id
      @session_id = session_id
      @user_id = user_id
      @confirmed = confirmed
      @invalidated = invalidated
      @created_at = created_at
    end

    def invalidate!
      @invalidated = true
      add_event(Event.for(EVENTS::LOGIN_TOKEN_INVALIDATED, self))
    end

    def confirm!
      @confirmed = true
      add_event(Event.for(EVENTS::LOGIN_TOKEN_CONFIRMED, self))
    end
  end
end
