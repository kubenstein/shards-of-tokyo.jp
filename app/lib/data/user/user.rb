module SoT
  class User
    include Eventable

    attr_reader :email, :id, :stripe_customer_id

    def initialize(id:, email:, stripe_customer_id:, **_)
      @id = id
      @email = email
      @stripe_customer_id = stripe_customer_id
    end

    def stripe_customer_id=(customer_id)
      @stripe_customer_id = customer_id
      add_event(UserStripeCustomerIdUpdatedEvent.build(self))
    end
  end
end
