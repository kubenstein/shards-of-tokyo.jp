module SoT
  Event::ORDER_CREATED = 'order_created'
  
  class OrderCreatedEventHandler
    def call(event, state)
      order = event.payload
      state.add_resource(:orders, order)
    end
  end
end
