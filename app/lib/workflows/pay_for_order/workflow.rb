require 'stripe'

module SoT
  module PayForOrder
    class Workflow
      include Import[
        :order_repository,
      ]

      def call(params)
        user = params[:user]
        order_id = params[:order_id]
        stripe_token = params[:stripe_token]

        validation_results = Validator.new.call(params)
        if validation_results.valid?
          results = pay(order_id: order_id, stripe_token: stripe_token)
          results
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

      def pay(order_id:, stripe_token:)
      end
    end
  end
end
