# Not sure yet how to have attr_reader with all fields as a form of documentation
# while still using @_field internally
# rubocop:disable Lint/DuplicateMethods

module SoT
  class Payment
    attr_reader :id, :order, :amount, :currency, :created_at, :error, :payment_id

    def initialize(id:, order:, payment_id:, amount:, currency:, error: nil, created_at:, **_) # rubocop:disable Metrics/ParameterLists
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
