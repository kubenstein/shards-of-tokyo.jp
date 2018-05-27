module SoT
  class OrderRepository
    include Import[:state]
    include ResourceSavable

    def new_order(user_id:)
      order_attr = { id: GenerateId.new.call, user_id: user_id }
      Order.new(order_attr).tap { |order|
        order.add_event(Event.for(EVENTS::ORDER_CREATED, order))
      }
    end
  end
end
