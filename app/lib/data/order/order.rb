module SoT
  class Order
    include Eventable

    attr_reader :id, :user_id

    def initialize(id: nil, user_id:)
      @id = id || GenerateId.new.call
      @user_id = user_id

      add_event(Event.for(EVENTS::ORDER_CREATED, self)) unless id
    end

    def add_message(from_user_id: user_id, text:)
      message = Message.new(order_id: id, from_user_id: from_user_id, body: text)
      add_events(message)
    end
  end
end
