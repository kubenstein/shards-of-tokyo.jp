module SoT
  module DotpayStep2ReceivePayment
    class Validator
      prepend Import[
        :order_repository
      ]

      def initialize(dotpay_pin:)
        @dotpay_pin = dotpay_pin
      end

      def call(params)
        [
          :control,
          :operation_type,
          :operation_status,
          :operation_number,
          :operation_original_amount,
          :operation_original_currency,
        ].each do |param|
          return Results.new(["invalid_params_#{param}".to_sym]) if params[param].to_s.empty?
        end

        return Results.new([:unsupported_ip]) unless request_from_approved_ip?(params)
        return Results.new([:order_not_found]) unless order_repository.exists?(id: params[:control])
        return Results.new([:amount_doesnt_match]) unless amount_matches?(params)
        return Results.new([:signature_doesnt_match]) unless signature_matches?(params)

        Results.new([])
      end

      class Results < Struct.new(:errors)
        def valid?
          errors.empty?
        end
      end

      private

      def request_from_approved_ip?(params)
        params[:ip] == '195.150.9.37'
      end

      def amount_matches?(params)
        amount = order_repository
                 .find(params[:control])
                 .amount_left_to_be_paid

        amount.format(symbol: '') == params[:operation_original_amount] &&
          amount.currency.iso_code == params[:operation_original_currency]
      end

      def signature_matches?(params) # rubocop:disable Metrics/MethodLength
        values = [
          @dotpay_pin,
          params[:id],
          params[:operation_number],
          params[:operation_type],
          params[:operation_status],
          params[:operation_amount],
          params[:operation_currency],
          params[:operation_withdrawal_amount],
          params[:operation_commission_amount],
          params[:is_completed],
          params[:operation_original_amount],
          params[:operation_original_currency],
          params[:operation_datetime],
          params[:operation_related_number],
          params[:control],
          params[:description],
          params[:email],
          params[:p_info],
          params[:p_email],
          params[:credit_card_issuer_identification_number],
          params[:credit_card_masked_number],
          params[:credit_card_expiration_year],
          params[:credit_card_expiration_month],
          params[:credit_card_brand_codename],
          params[:credit_card_brand_code],
          params[:credit_card_id],
          params[:channel],
          params[:channel_country],
          params[:geoip_country],
        ].join

        params[:signature] == Digest::SHA256.hexdigest(values)
      end
    end
  end
end
