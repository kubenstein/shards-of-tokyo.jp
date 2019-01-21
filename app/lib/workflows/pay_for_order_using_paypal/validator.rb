module SoT
  module PayForOrderUsingPaypal
    class Validator
      include Import[
        :order_repository
      ]

      def call(params)
        paypal_authorize_data = params[:paypal_authorize_data]
        order_id = params[:order_id]
        user = params[:user]

        return Results.new([:paypal_authorize_data_invalid]) unless paypal_authorize_data_valid?(paypal_authorize_data)
        return Results.new([:user_not_found]) unless user
        return Results.new([:order_not_found]) unless order_exists?(order_id, user.id)

        Results.new([])
      end

      class Results < Struct.new(:errors)
        def valid?
          errors.empty?
        end
      end

      private

      def order_exists?(order_id, user_id)
        order_repository.exists?(id: order_id, user_id: user_id)
      end

      def paypal_authorize_data_valid?(data)
        return false unless data.is_a?(Hash)
        return false if data[:payerID].to_s.empty?
        return false if data[:paymentID].to_s.empty?
        true
      end
    end
  end
end
