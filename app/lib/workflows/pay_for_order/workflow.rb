require 'stripe'

module SoT
  module PayForOrder
    class Workflow
      include Import[
        :order_repository,
        :user_repository,
        :mailer,
      ]

      def call(params)
        user = params[:user] # rubocop:disable Lint/UselessAssignment
        order_id = params[:order_id]
        stripe_token = params[:stripe_token]

        validation_results = Validator.new.call(params)
        if validation_results.valid?
          order = order_repository.find(order_id)
          result = pay(order: order, stripe_token: stripe_token)
          send_email_to_user(order) if result.success?
          send_email_to_me(order)
          result
        else
          Results.new(order_id, validation_results.errors)
        end
      end

      class Results < Struct.new(:order_id, :errors)
        def success?
          errors.empty?
        end
      end

      private

      def pay(order:, stripe_token:)
        payment_result = StripeGateway.new.call(
          amount: order.amount_left_to_be_paid,
          currency: order.currency,
          order_id: order.id,
          payer_email: order.user.email,
          payer_stripe_customer_id: order.user.stripe_customer_id,
          stripe_token: stripe_token,
        )

        if payment_result.success?
          add_successful_payment(order, payment_result)
          save_stripe_customer_id_if_needed(order, payment_result)
          Results.new(order.id, [])
        else
          add_failed_payment(order, payment_result)
          Results.new(order.id, [payment_result.error_message])
        end
      end

      def add_successful_payment(order, payment_result)
        order.add_successful_payment(
          payment_id: payment_result.payment_id,
          amount: payment_result.amount,
          currency: payment_result.currency,
        )
        order_repository.save(order)
      end

      def add_failed_payment(order, payment_result)
        order.add_failed_payment(
          payment_id: payment_result.payment_id,
          amount: order.amount_left_to_be_paid,
          currency: order.currency,
          error_message: payment_result.error_message,
        )
        order_repository.save(order)
      end

      def save_stripe_customer_id_if_needed(order, payment_result)
        user = order.user
        return if user.stripe_customer_id

        user.stripe_customer_id = payment_result.customer_id
        user_repository.save(user)
      end

      def send_email_to_user(order)
        mailer.send_email_about_payment_to_user(order)
      end

      def send_email_to_me(order)
        mailer.send_email_about_payment_to_me(order)
      end
    end
  end
end
