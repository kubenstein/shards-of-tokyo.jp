require 'stripe'

module SoT
  class StripeGateway
    prepend Import[
      :stripe_api_keys,
    ]

    def initialize(stripe_charge: Stripe::Charge, stripe_customer: Stripe::Customer)
      @stripe_charge = stripe_charge
      @stripe_customer = stripe_customer
    end

    def call(order_id:, payer_email:, payer_stripe_customer_id: nil, stripe_token:, amount:, currency:) # rubocop:disable Metrics/ParameterLists
      customer_id = create_or_retrieve_customer_id(stripe_token, payer_email, payer_stripe_customer_id)

      stripe_charge = @stripe_charge.create({
                                              amount: amount,
                                              description: "Shards of Tokyo payment for order: #{order_id}",
                                              currency: currency,
                                              customer: customer_id,
                                              metadata: { order_id: order_id },
                                            },
                                            api_key: stripe_api_keys[:secret_key])

      SuccessPayment.new(
        customer_id,
        stripe_charge[:id],
        stripe_charge[:amount],
        stripe_charge[:currency],
      )
    rescue Stripe::StripeError => e
      payment_id = begin
                     e.json_body[:error][:charge]
                   rescue StandardError
                     e.to_s
                   end
      message = begin
                  "#{e.json_body[:error][:code]} - #{e.json_body[:error][:message]}"
                rescue StandardError
                  e.to_s
                end
      FailedPayment.new(payment_id, amount, currency, message)
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

    def create_or_retrieve_customer_id(stripe_token, payer_email, payer_stripe_customer_id)
      return payer_stripe_customer_id if payer_stripe_customer_id

      stripe_customer = @stripe_customer.create({
                                                  email: payer_email,
                                                  source: stripe_token,
                                                },
                                                api_key: stripe_api_keys[:secret_key])
      stripe_customer.id
    end
  end
end
