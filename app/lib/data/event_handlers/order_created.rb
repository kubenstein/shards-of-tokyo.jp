module SoT
  class OrderCreatedEventHandler
    def call(event, state)
      order = event.payload
      state.add_resource(:orders, order)
    end
  end
end
