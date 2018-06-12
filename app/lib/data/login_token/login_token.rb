module SoT
  class LoginToken
    include Eventable

    attr_reader :id, :session_id, :user, :invalidated, :confirmed, :created_at

    def initialize(id:, session_id:, user:, invalidated:, confirmed:, created_at:, **_)
      @id = id
      @session_id = session_id
      @user_id = user.id
      @confirmed = confirmed
      @invalidated = invalidated
      @created_at = created_at
      @_user = user
    end

    def invalidate!
      @invalidated = true
      add_event(Event.for(EVENTS::LOGIN_TOKEN_INVALIDATED, self))
    end

    def confirm!
      @confirmed = true
      add_event(Event.for(EVENTS::LOGIN_TOKEN_CONFIRMED, self))
    end

    def confirmed?
      confirmed && !invalidated
    end

    def user
      @_user
    end

    def user_email
      user.email
    end
  end
end
