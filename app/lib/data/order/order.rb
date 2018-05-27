module SoT
  class Order
    include Eventable

    attr_reader :id, :user_id, :messages

    def initialize(id:, user_id:, messages: [])
      @id = id
      @user_id = user_id
      @_messages = messages
    end

    def add_message(text:)
      Message.new(id: GenerateId.new.call, order_id: id, is_from_user: true, body: text).tap do |message|
        @_messages << message
        add_event(Event.for(EVENTS::MESSAGE_CREATED, message))
      end
    end

    def messages
      @_messages
    end
  end
end
