module SoT
  class Message
    attr_reader :id, :is_from_user, :order_id, :body, :created_at

    def initialize(id:, is_from_user:, order_id:, body:, created_at:)
      @id = id
      @is_from_user = is_from_user
      @order_id = order_id
      @body = body
      @created_at = created_at
    end

    def from_user?
      @is_from_user
    end
  end
end
