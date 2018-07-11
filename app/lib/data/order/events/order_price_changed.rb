module SoT
  module OrderPriceChangedEvent
    NAME = 'order_price_changed'
    HANDLER_VERSION = 1

    def self.build(order, requester_id: nil)
      payload = { id: order.id, price: order.price, currency: order.currency }
      Event.build(name: NAME, handler_version: HANDLER_VERSION, payload: payload, requester_id: requester_id)
    end

    def self.handle_v1(event, state)
      order_attrs = event.payload
      state.update_resource(:orders,
        order_attrs[:id],
        { price: order_attrs[:price], currency: order_attrs[:currency] }
      )
    end
  end
end
