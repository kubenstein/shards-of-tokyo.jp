# Not sure yet how to have attr_reader with all fields as a form of documentation
# while still using @_field internally
# rubocop:disable Lint/DuplicateMethods

module SoT
  class Payment
    include ObjWithPriceSerializable

    attr_reader :id, :order, :price, :created_at, :error, :payment_id, :gateway

    def initialize(id:, order:, payment_id:, price:, gateway:, error: nil, created_at:, **_) # rubocop:disable Metrics/ParameterLists
      @id = id
      @order_id = order.id
      @payment_id = payment_id
      @price = price
      @gateway = gateway
      @error = error
      @created_at = created_at
      @_order = order
    end

    def successful?
      error.nil?
    end

    def user
      order.user
    end

    # attr_reader boilerplate
    def order
      @_order
    end
  end
end
