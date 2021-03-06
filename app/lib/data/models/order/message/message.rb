# Not sure yet how to have attr_reader with all fields as a form of documentation
# while still using @_field internally
# rubocop:disable Lint/DuplicateMethods

module SoT
  class Message
    attr_reader :id, :user, :order, :body, :created_at

    def initialize(id:, user:, order:, body:, created_at:, **_) # rubocop:disable Metrics/ParameterLists
      @id = id
      @user_id = user.id
      @order_id = order.id
      @body = body
      @created_at = created_at
      @_user = user
      @_order = order
    end

    def from_user?
      user.id == order.user.id
    end

    # attr_reader boilerplate
    def user
      @_user
    end

    def order
      @_order
    end
  end
end
