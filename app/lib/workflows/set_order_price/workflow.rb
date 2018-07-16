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
        currency = params[:currency] || 'JPY'

        validation_results = Validator.new.call(params)
        if validation_results.valid?
          order = set_order_price(order_id, price, currency, requester)

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

      def set_order_price(order_id, price, currency, requester)
        order = order_repository.find(order_id)
        order.set_price(price, currency, requester_id: requester.id)
        order_repository.save(order)
      end
    end
  end
end
