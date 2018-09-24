# Not sure yet how to have attr_reader with all fields as a form of documentation
# while still using @_field internally
# rubocop:disable Lint/DuplicateMethods

module SoT
  class LoginToken
    include Eventable

    attr_reader :id, :session_id, :user, :invalidated, :confirmed, :created_at

    def initialize(id:, session_id:, user:, invalidated:, confirmed:, created_at:, **_) # rubocop:disable Metrics/ParameterLists
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
      add_event(LoginTokenInvalidatedEvent.build(self))
    end

    def confirm!
      @confirmed = true
      add_event(LoginTokenConfirmedEvent.build(self))
    end

    def active?
      confirmed && !invalidated
    end

    def user_email
      user.email
    end

    # attr_reader boilerplate
    def user
      @_user
    end
  end
end
