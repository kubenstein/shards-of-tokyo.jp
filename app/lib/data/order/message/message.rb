module SoT
  class Message
    attr_reader :id, :is_from_user, :order_id, :body

    def initialize(id:, is_from_user:, order_id:, body:)
      @id = id
      @is_from_user = is_from_user
      @order_id = order_id
      @body = body
    end

    def from_user?
      @is_from_user
    end
  end
end
