module SoT
  module ObjWithPriceSerializable
    def serialize
      ObjWithPriceSerializer.new.call(self)
    end
  end

  class ObjWithPriceSerializer
    def call(obj)
      DefaultSerializer.new.call(obj).tap do |hash|
        price = hash.delete(:price)

        if price
          hash[:amount] = price.cents
          hash[:currency] = price.currency.iso_code
        end
      end
    end
  end
end
