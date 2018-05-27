module SoT
  class Order
    include Eventable

    attr_reader :id, :user_id, :messages

    def initialize(id:, user_id:, messages: [])
      @id = id
      @user_id = user_id
      @_messages = messages
    end

    def add_message(text:, answer: false)
      message_attrs = {
        id: GenerateId.new.call,
        order_id: id,
        is_from_user: !answer,
        body: text,
      }
      Message.new(message_attrs).tap do |message|
        @_messages << message
        add_event(Event.for(EVENTS::MESSAGE_CREATED, message))
      end
    end

    def messages
      @_messages
    end
  end
end
