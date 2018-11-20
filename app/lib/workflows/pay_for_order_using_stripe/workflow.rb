module SoT
  module PayForOrderUsingSripe
    class Workflow
      prepend Import[
        :order_repository,
        :user_repository,
        :i18n,
        :mailer,
      ]

      attr_reader :stripe_public_key

      def initialize(stripe_secret_key:, stripe_public_key:)
        @stripe_public_key = stripe_public_key
        @stripe_gateway = StripeGateway.new(stripe_secret_key: stripe_secret_key)
      end

      def call(params)
        user = params[:user] # rubocop:disable Lint/UselessAssignment
        order_id = params[:order_id]
        stripe_token = params[:stripe_token]

        validation_result = Validator.new.call(params)
        if validation_result.valid?
          order = order_repository.find(order_id)
          payment_result = pay(order: order, stripe_token: stripe_token)

          if payment_result.success?
            add_successful_payment(order, payment_result)
            save_stripe_customer_id_if_needed(order, payment_result)
            add_successful_message(order, payment_result)
            send_email_to_user(order)
            send_email_to_me(order)
            Results.new(order.id, [])
          else
            add_failed_payment(order, payment_result)
            add_failed_message(order, payment_result)
            send_email_to_me(order)
            Results.new(order.id, [payment_result.error_message])
          end
        else
          Results.new(order_id, validation_result.errors)
        end
      end

      class Results < Struct.new(:order_id, :errors)
        def success?
          errors.empty?
        end
      end

      private

      def pay(order:, stripe_token:)
        @stripe_gateway.call(
          amount: order.amount_left_to_be_paid.fractional,
          currency: order.amount_left_to_be_paid.currency.iso_code,
          order_id: order.id,
          payer_email: order.user.email,
          payer_stripe_customer_id: order.user.payment_gateway_customer_id,
          stripe_token: stripe_token,
        )
      end

      def add_successful_payment(order, payment_result)
        order.add_successful_payment(
          payment_gateway: 'stripe',
          payment_id: payment_result.payment_id,
          price: Money.new(payment_result.amount, payment_result.currency),
        )
        order_repository.save(order)
      end

      def add_failed_payment(order, payment_result)
        order.add_failed_payment(
          payment_gateway: 'stripe',
          payment_id: payment_result.payment_id,
          price: order.amount_left_to_be_paid,
          error_message: payment_result.error_message,
        )
        order_repository.save(order)
      end

      def save_stripe_customer_id_if_needed(order, payment_result)
        user = order.user
        return if user.payment_gateway_customer_id

        user.payment_gateway_customer_id = payment_result.customer_id
        user_repository.save(user)
      end

      def send_email_to_user(order)
        mailer.send_email_about_payment_to_user(order)
      end

      def send_email_to_me(order)
        mailer.send_email_about_payment_to_me(order)
      end

      def add_successful_message(order, payment_result)
        price = Money.new(payment_result.amount, payment_result.currency)
        text = i18n.t('successful_payment_message', price: price.format, scope: [:pay_for_order_workflow])
        order.add_message(text: text, from_user: order.user)
        order_repository.save(order)
      end

      def add_failed_message(order, payment_result)
        text = i18n.t(
          'failed_payment_message',
          error_message: payment_result.error_message,
          scope: [:pay_for_order_workflow],
        )
        order.add_message(text: text, from_user: order.user)
        order_repository.save(order)
      end
    end
  end
end
