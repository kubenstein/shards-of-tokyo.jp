module SoT
  module UserStripeCustomerIdUpdatedEvent
    NAME = 'user_stripe_customer_id_updated'

    def self.build(user)
      payload = { id: user.id, stripe_customer_id: user.stripe_customer_id }
      Event.build(name: NAME, payload: payload, requester_id: user.id)
    end

    def self.handle(event, state)
      user_id = event.payload[:id]
      stripe_customer_id = event.payload[:stripe_customer_id]
      state.update_resource(:users, user_id, stripe_customer_id: stripe_customer_id)
    end
  end
end
