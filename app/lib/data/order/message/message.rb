module SoT
  class Message
    attr_reader :id, :user, :order, :body, :created_at

    def initialize(id:, user:, order:, body:, created_at:, **_)
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

    def user
      @_user
    end

    def order
      @_order
    end
  end
end
