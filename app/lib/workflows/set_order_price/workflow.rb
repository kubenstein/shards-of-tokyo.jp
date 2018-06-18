module SoT
  module SetOrderPrice
    class Workflow
      include Import[
        :order_repository
      ]

      def call(params)
        price = params[:price]
        order_id = params[:order_id]

        validation_results = Validator.new.call(params)
        if validation_results.valid?
          order = set_order_price(order_id, price)

          Results.new(order, [])
        else
          Results.new(order, validation_results.errors)
        end
      end

      class Results < Struct.new(:order, :errors)
        def success?
          errors.empty?
        end
      end

      private

      def set_order_price(order_id, price)
        order = order_repository.find(order_id)
        order.set_price(price)
        order_repository.save(order)
      end
    end
  end
end
