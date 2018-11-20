module SoT
  class User
    include Eventable
    ME_EMAIL = 'niewczas.jakub@gmail.com'

    attr_reader :email, :id, :payment_gateway_customer_id, :created_at

    def initialize(id:, email:, payment_gateway_customer_id:, created_at:, **_)
      @id = id
      @email = email
      @payment_gateway_customer_id = payment_gateway_customer_id
      @created_at = created_at
    end

    def payment_gateway_customer_id=(customer_id)
      @payment_gateway_customer_id = customer_id
      add_event(UserPaymentGatewayCustomerIdUpdatedEvent.build(self))
    end

    def me?
      email == ME_EMAIL
    end

    def ==(other)
      other &&
        id == other.id &&
        email == other.email
    end
  end
end
