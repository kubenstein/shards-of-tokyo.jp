module SoT
  module OrderCreatedEvent
    NAME = 'order_created'
    HANDLER_VERSION = 1

    def self.build(order)
      payload = Serialize.new.call(order)
      Event.build(name: NAME, handler_version: HANDLER_VERSION, payload: payload)
    end

    def self.handle_v1(event, state)
      order_attrs = event.payload
      state.add_resource(:orders, order_attrs)
    end
  end
end
