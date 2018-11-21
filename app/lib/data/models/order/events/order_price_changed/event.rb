module SoT
  module OrderPriceChangedV1Event
    NAME = 'order_price_changed_v1'

    def self.build(order, requester_id: nil)
      payload = Serialize.new.call(order).slice(:id, :amount, :currency)
      Event.build(name: NAME, payload: payload, requester_id: requester_id)
    end

    def self.handle(event, state)
      order_attrs = event.payload
      state.update_resource(:orders,
                            order_attrs[:id],
                            amount: order_attrs[:amount],
                            currency: order_attrs[:currency])
    end
  end
end
