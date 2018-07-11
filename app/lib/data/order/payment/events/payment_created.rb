module SoT
  module PaymentCreatedEvent
    NAME = 'payment_created'
    HANDLER_VERSION = 1

    def self.build(payment, requester_id: nil)
      payload = Serialize.new.call(payment)
      Event.build(name: NAME, handler_version: HANDLER_VERSION, payload: payload, requester_id: requester_id)
    end

    def self.handle_v1(event, state)
      payment_attrs = event.payload
      state.add_resource(:payments, payment_attrs)
    end
  end
end
