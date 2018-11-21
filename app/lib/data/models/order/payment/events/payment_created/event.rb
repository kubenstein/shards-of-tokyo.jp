module SoT
  module PaymentCreatedV1Event
    NAME = 'payment_created_v1'

    def self.build(payment)
      payload = Serialize.new.call(payment)
      Event.build(name: NAME, payload: payload, requester_id: payment.user.id)
    end

    def self.handle(event, state)
      payment_attrs = event.payload
      state.add_resource(:payments, payment_attrs)
    end
  end
end
