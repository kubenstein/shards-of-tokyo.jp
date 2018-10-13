module SoT
  module OrderSerializable
    def serialize
      OrderSerializer.new.call(self)
    end
  end

  class OrderSerializer
    def call(order)
      DefaultSerializer.new.call(order).tap do |hash|
        price = hash.delete(:price)

        if price
          hash[:amount] = price.cents
          hash[:currency] = price.currency.iso_code
        end
      end
    end
  end
end
