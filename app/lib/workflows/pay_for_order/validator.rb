module SoT
  module PayForOrder
    class Validator
      include Import[
        :order_repository
      ]

      def call(params)
        stripe_token = params[:stripe_token]
        order_id = params[:order_id]
        user = params[:user]

        return Results.new([:stripe_token_not_found]) unless stripe_token
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
    end
  end
end
