module SoT
  module UserPaymentGatewayCustomerIdUpdatedV1Event
    NAME = 'user_payment_gateway_customer_id_updated_v1'

    def self.build(user)
      payload = { id: user.id, payment_gateway_customer_id: user.payment_gateway_customer_id }
      Event.build(name: NAME, payload: payload, requester_id: user.id)
    end

    def self.handle(event, state)
      user_id = event.payload[:id]
      payment_gateway_customer_id = event.payload[:payment_gateway_customer_id]
      state.update_resource(:users, user_id, payment_gateway_customer_id: payment_gateway_customer_id)
    end
  end
end
