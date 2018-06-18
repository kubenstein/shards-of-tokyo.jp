module SoT
  Event::ORDER_PRICE_CHANGED = 'order_price_changed'

  class OrderPriceChangedEventHandler
    def call(event, state)
      order = event.payload
      state.update_resource(:orders, order[:id], { price: order[:price] } )
    end
  end
end
