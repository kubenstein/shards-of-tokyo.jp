module SoT
  module DotpayStep1GenerateForm
    class Validator
      include Import[
        :order_repository
      ]

      def call(params)
        order_id = params[:order_id]
        user = params[:user]
        return Results.new([:empty_user]) unless user
        return Results.new([:order_not_found]) unless order_repository.exists?(id: order_id, user_id: user.id)

        Results.new([])
      end

      class Results < Struct.new(:errors)
        def valid?
          errors.empty?
        end
      end
    end
  end
end
