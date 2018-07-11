module SoT
  module PaymentCreatedEvent
    NAME = 'payment_created'
    HANDLER_VERSION = 1

    def self.build(payment)
      payload = Serialize.new.call(payment)
      Event.build(name: NAME, handler_version: HANDLER_VERSION, payload: payload)
    end

    def self.handle(event, state)
      payment_attrs = event.payload
      state.add_resource(:payments, payment_attrs)
    end
  end
end
