module SoT
  module OrderCreatedEvent
    NAME = 'order_created'

    def self.build(order)
      payload = Serialize.new.call(order)
      Event.new(name: NAME, payload: payload)
    end

    def self.handle(event, state)
      order_attrs = event.payload
      state.add_resource(:orders, order_attrs)
    end
  end
end
