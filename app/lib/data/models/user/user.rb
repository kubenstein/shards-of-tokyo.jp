module SoT
  class User
    include Eventable
    ME_EMAIL = 'niewczas.jakub@gmail.com'

    attr_reader :email, :id, :stripe_customer_id, :created_at

    def initialize(id:, email:, stripe_customer_id:, created_at:, **_)
      @id = id
      @email = email
      @stripe_customer_id = stripe_customer_id
      @created_at = created_at
    end

    def stripe_customer_id=(customer_id)
      @stripe_customer_id = customer_id
      add_event(UserStripeCustomerIdUpdatedEvent.build(self))
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