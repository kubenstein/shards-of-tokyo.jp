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

    def for_user_newest_first(user_id)
      orders_attr = state.get_resources(:orders, { user_id: user_id }, [:id, :desc])
      order_ids = orders_attr.map { |h| h[:id] }
      messages_attr = state.get_resources(:messages, { order_id: order_ids }, [:id, :desc])

      orders_attr.map { |order_attr|
        order_attr[:messages] = messages_attr
                                  .select { |message_attr| message_attr[:order_id] == order_attr[:id] }
                                  .map { |message_attr| Message.new(message_attr) }
        Order.new(order_attr)
      }
    end
  end
end
