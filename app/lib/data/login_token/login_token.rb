module SoT
  class LoginToken
    include Eventable

    attr_reader :id, :session_id, :user_id, :invalidated, :used, :created_at

    def initialize(id:, session_id:, user_id:, invalidated:, used:, created_at:)
      @id = id
      @session_id = session_id
      @user_id = user_id
      @used = used
      @invalidated = invalidated
      @created_at = created_at
    end

    def invalidate!
      @invalidated = true
      add_event(Event.for(EVENTS::LOGIN_TOKEN_INVALIDATED, self))
    end
  end
end
