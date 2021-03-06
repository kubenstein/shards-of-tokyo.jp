module SoT
  module OrderCreatedV1Event
    NAME = 'order_created_v1'

    def self.build(order)
      payload = Serialize.new.call(order)
      Event.build(name: NAME, payload: payload, requester_id: order.user.id)
    end

    def self.handle(event, state)
      order_attrs = event.payload
      state.add_resource(:orders, order_attrs)
    end
  end
end
