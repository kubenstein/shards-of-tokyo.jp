require 'paypal-sdk-rest'

module SoT
  class PaypalGateway
    def initialize(env:, client_id:, secret:, logger: nil)
      # global setting but I dont know how to set it per request
      PayPal::SDK.configure(
        mode: env === 'production' ? 'live' : 'sandbox',
        client_id: client_id,
        client_secret: secret,
        ssl_options: {},
      )
      PayPal::SDK.logger = logger
    end

    def call(payment_id:, payer_id:)
      payment = PayPal::SDK::REST::Payment.find(payment_id)
      if payment.execute(payer_id: payer_id)
        SuccessPayment.new(
          customer_id(payment),
          payment_id,
          amount(payment),
          currency(payment),
        )
      else
        FailedPayment.new(
          payment_id,
          amount(payment),
          currency(payment),
          payment.error.inspect,
        )
      end
    rescue StandardError => e
      Bugsnag.notify(e)
      FailedPayment.new(
        payment_id,
        0,
        'JPY',
        e.to_s,
      )
    end

    class SuccessPayment < Struct.new(:customer_id, :payment_id, :amount, :currency)
      def success?
        true
      end
    end

    class FailedPayment < Struct.new(:payment_id, :amount, :currency, :error_message)
      def success?
        false
      end
    end

    private

    def customer_id(payment)
      "#{payment.payer.payer_info.email} #{payment.payer.payer_info.payer_id}"
    end

    def amount(payment)
      money(payment).fractional
    end

    def currency(payment)
      money(payment).currency.iso_code
    end

    def money(payment)
      amount = payment.transactions[0].amount
      Monetize.parse("#{amount.total} #{amount.currency}")
    end
  end
end
