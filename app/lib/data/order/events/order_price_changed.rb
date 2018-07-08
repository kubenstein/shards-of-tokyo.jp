module SoT
  module OrderPriceChangedEvent
    NAME = 'order_price_changed'

    def self.build(order)
      payload = { id: order.id, price: order.price, currency: order.currency }
      Event.new(name: NAME, payload: payload)
    end

    def self.handle(event, state)
      order_attrs = event.payload
      state.update_resource(:orders,
        order_attrs[:id],
        { price: order_attrs[:price], currency: order_attrs[:currency] }
      )
    end
  end
end
