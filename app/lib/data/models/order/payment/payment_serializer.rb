module SoT
  module PaymentSerializable
    def serialize
      PaymentSerializer.new.call(self)
    end
  end

  class PaymentSerializer
    def call(payment)
      DefaultSerializer.new.call(payment).tap do |hash|
        price = hash.delete(:price)

        if price
          hash[:amount] = price.cents
          hash[:currency] = price.currency.iso_code
        end
      end
    end
  end
end
