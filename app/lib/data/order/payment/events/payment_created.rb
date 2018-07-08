module SoT
  module PaymentCreatedEvent
    NAME = 'payment_created'

    def self.build(payment)
      payload = Serialize.new.call(payment)
      Event.new(name: NAME, payload: payload)
    end

    def self.handle(event, state)
      payment_attrs = event.payload
      state.add_resource(:payments, payment_attrs)
    end
  end
end
