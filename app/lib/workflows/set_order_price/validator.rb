module SoT
  module SetOrderPrice
    class Validator
      include Import[
        :order_repository
      ]

      def call(params)
        price = params[:price]
        order_id = params[:order_id]

        return Results.new([:price_negative]) if price < 0
        return Results.new([:order_not_found]) unless order_exists?(order_id)

        Results.new([])
      end

      class Results < Struct.new(:errors)
        def valid?
          errors.empty?
        end
      end

      private

      def order_exists?(order_id)
        order_repository.exists?(id: order_id)
      end
    end
  end
end
