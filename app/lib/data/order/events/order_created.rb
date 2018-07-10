module SoT
  module OrderCreatedEvent
    NAME = 'order_created'
    VERSION = 1

    def self.build(order)
      payload = Serialize.new.call(order)
      Event.build(name: NAME, version: VERSION, payload: payload)
    end

    def self.handle(event, state)
      order_attrs = event.payload
      state.add_resource(:orders, order_attrs)
    end
  end
end
