module SoT
  module SetOrderPrice
    class Workflow
      include Import[
        :order_repository
      ]

      def call(params)
        requester = params[:requester]
        price = params[:price]
        order_id = params[:order_id]

        validation_result = Validator.new.call(params)
        if validation_result.valid?
          order = set_order_price(order_id, price, requester)

          Results.new(order, [])
        else
          Results.new(order, validation_result.errors)
        end
      end

      class Results < Struct.new(:order, :errors)
        def success?
          errors.empty?
        end
      end

      private

      def set_order_price(order_id, price, requester)
        order_repository.find(order_id).tap do |order|
          order.set_price(price, requester_id: requester.id)
          order_repository.save(order)
        end
      end
    end
  end
end
