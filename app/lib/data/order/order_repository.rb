module SoT
  class OrderRepository
    include Import[:state]
    include ResourceSavable

    def new_order(user:)
      order_attr = { id: GenerateId.new.call, user: user, created_at: Time.now, price: nil, paid_at: nil }
      Order.new(order_attr).tap { |order|
        order.add_event(Event.for(Event::ORDER_CREATED, order))
      }
    end

    def exists?(search_opts)
      !!state.get_resources(:orders, search_opts)[0]
    end

    def find(id)
      order_attr = state.get_resources(:orders, id: id)[0]
      messages_attr = state.get_resources(:messages, { order_id: id }, [:created_at, :asc])
      user_ids = messages_attr.map { |h| h[:user_id] } + [order_attr[:user_id]]
      users_attr = state.get_resources(:users, id: user_ids)

      # users
      users = users_attr.map { |user_attr| User.new(user_attr) }

      # order without messages
      order_attr[:user] = users.find { |u| u.id == order_attr[:user_id] }
      order = Order.new(order_attr)

      # messages
      messages = messages_attr.map { |message_attr|
        message_attr[:user] = users.find { |u| u.id == message_attr[:user_id] }
        message_attr[:order] = order
        Message.new(message_attr)
      }

      # adding messages to order
      order.instance_variable_set(:@_messages, messages)

      order
    end

    def for_user_newest_first(user_id)
      orders_attr = state.get_resources(:orders, { user_id: user_id }, [:created_at, :desc])
      order_ids = orders_attr.map { |h| h[:id] }
      messages_attr = state.get_resources(:messages, { order_id: order_ids }, [:created_at, :asc])
      user_ids = messages_attr.map { |h| h[:user_id] } + orders_attr.map { |h| h[:user_id] }
      users_attr = state.get_resources(:users, { id: user_ids })

      # users
      users = users_attr.map { |user_attr| User.new(user_attr) }

      orders = orders_attr.map { |order_attr|
        # orders without messages
        order_attr[:user] = users.find { |u| u.id == order_attr[:user_id] }
        order = Order.new(order_attr)

        # messages
        messages = messages_attr.each
          .select { |message_attr| message_attr[:order_id] == order.id }
          .map { |message_attr|
            message_attr[:user] = users.find { |u| u.id == message_attr[:user_id] }
            message_attr[:order] = order
            Message.new(message_attr)
          }

        # adding messages to order
        order.instance_variable_set(:@_messages, messages)

        order
      }

      orders
    end
  end
end
