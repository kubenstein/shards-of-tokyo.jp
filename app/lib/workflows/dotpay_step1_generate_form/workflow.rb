module SoT
  module DotpayStep1GenerateForm
    class Workflow
      prepend Import[
        :order_repository,
        :i18n,
      ]

      def initialize(dotpay_id:, dotpay_pin:, server_base_url:, env: nil)
        @dotpay_id = dotpay_id
        @dotpay_pin = dotpay_pin
        @server_base_url = server_base_url
        @env = env
      end

      def call(params)
        order_id = params[:order_id]
        user = params[:user] # rubocop:disable Lint/UselessAssignment

        validation_result = Validator.new.call(params)
        if validation_result.valid?
          Results.new(dotpay_api_url, dotpay_params(order_id), [])
        else
          Results.new(dotpay_api_url, [], validation_result.errors)
        end
      end

      class Results < Struct.new(:url, :params, :errors)
        def success?
          errors.empty?
        end

        def method
          'post'
        end
      end

      private

      def dotpay_api_url
        @env == :dev ? 'https://ssl.dotpay.pl/test_payment/' : 'https://ssl.dotpay.pl/t2/'
      end

      def dotpay_params(order_id)
        order = order_repository.find(order_id)
        price = order.amount_left_to_be_paid
        return_url = "#{@server_base_url}orders/#{order_id}/pay/result_user_callback"

        params = { # order matters here
          api_version: @env,
          lang: 'en',
          id: @dotpay_id,
          amount: price.format(symbol: nil, separator: '.'),
          currency: price.currency.to_s,
          description: i18n.t('transaction_description', order_id: order.id, scope: [:dotpay_step1_generate_form]),
          control: order.id,
          channel_groups: 'K',
          url: return_url,
          type: 0,
          email: order.user.email,
          ignore_last_payment_channel: '1',
        }
        params[:chk] = Digest::SHA256.hexdigest(@dotpay_pin + params.values.join)
        params
      end
    end
  end
end
