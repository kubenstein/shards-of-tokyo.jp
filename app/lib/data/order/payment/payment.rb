module SoT
  class Payment
    attr_reader :id, :order, :amount, :currency, :created_at, :error

    def initialize(id:, order:, payment_id:, amount:, currency:, error: nil, created_at:, **_)
      @id = id
      @order_id = order.id
      @payment_id = payment_id
      @amount = amount
      @currency = currency
      @error = error
      @created_at = created_at
      @_order = order
    end

    def user
      order.user
    end

    def order
      @_order
    end

    def successful?
      error.nil?
    end
  end
end
