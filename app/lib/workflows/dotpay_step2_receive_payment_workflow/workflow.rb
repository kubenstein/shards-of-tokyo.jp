require 'monetize'

module SoT
  module DotpayStep2ReceivePayment
    class Workflow
      prepend Import[
        :order_repository,
        :user_repository,
        :i18n,
        :mailer,
      ]

      def initialize(dotpay_pin:)
        @dotpay_pin = dotpay_pin
      end

      def call(params)
        validation_result = Validator.new(dotpay_pin: @dotpay_pin).call(params)

        if validation_result.valid?
          order_id = params[:control]
          order = order_repository.find(order_id)

          if payment_successful?(params)
            add_successful_payment(order, params)
            add_successful_message(order, params)
            send_email_to_user(order)
            send_email_to_me(order)
            Results.new(order_id, [])
          else
            add_failed_payment(order, params)
            add_failed_message(order, params)
            send_email_to_me(order)
            Results.new(order.id, params)
          end
        else
          log_invalid_callback(params)
          send_email_to_me_about_failed_webhook(params)
          Results.new(order_id, validation_result.errors)
        end
      end

      class Results < Struct.new(:order_id, :errors)
        def success?
          errors.empty?
        end

        def web_response
          'OK'
        end
      end

      private

      def payment_successful?(params)
        params[:operation_type] == 'payment' &&
          params[:operation_status] == 'completed'
      end

      def add_successful_payment(order, params)
        order.add_successful_payment(
          payment_gateway: 'dotpay',
          payment_id: params[:operation_number],
          price: money_from(params),
        )
        order_repository.save(order)
      end

      def add_failed_payment(order, params)
        order.add_failed_payment(
          payment_gateway: 'dotpay',
          payment_id: params[:operation_number],
          price: order.amount_left_to_be_paid,
          error_message: "dotpay error, please check payment nr. #{params[:operation_number]}",
        )
        order_repository.save(order)
      end

      def add_successful_message(order, params)
        price = money_from(params)
        text = i18n.t('successful_payment_message', price: price.format, scope: [:dotpay_step_2_receive_payment])
        order.add_message(text: text, from_user: order.user)
        order_repository.save(order)
      end

      def add_failed_message(order, _params)
        text = i18n.t('failed_payment_message', scope: [:dotpay_step_2_receive_payment])
        order.add_message(text: text, from_user: order.user)
        order_repository.save(order)
      end

      def send_email_to_user(order)
        mailer.send_email_about_payment_to_user(order)
      end

      def send_email_to_me(order)
        mailer.send_email_about_payment_to_me(order)
      end

      def send_email_to_me_about_failed_webhook(params)
        mailer.send_email_about_webhook_failure_to_me(params)
      end

      def log_invalid_callback(params)
        Bugsnag.notify(params)
      end

      def money_from(params)
        Monetize.parse("#{params[:operation_original_currency]} #{params[:operation_original_amount]}")
      end
    end
  end
end
