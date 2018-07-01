module SoT
  Event::PAYMENT_CREATED = 'payment_created'

  class PaymentCreatedEventHandler
    def call(event, state)
      payment = event.payload
      state.add_resource(:payments, payment)
    end
  end
end
