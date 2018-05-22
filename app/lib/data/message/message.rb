module SoT
  class Message
    include Eventable

    attr_reader :id, :from_user_id, :order_id, :body

    def initialize(id: nil, from_user_id:, order_id:, body:)
      @id = id || GenerateId.new.call
      @from_user_id = from_user_id
      @order_id = order_id
      @body = body

      add_event(Event.for(EVENTS::MESSAGE_CREATED, self)) unless id
    end
  end
end
