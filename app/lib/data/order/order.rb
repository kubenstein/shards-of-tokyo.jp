module SoT
  class Order
    include Eventable

    attr_reader :id, :user, :price, :currency, :paid_at, :created_at, :messages, :payments

    def initialize(id:, user:, price:, currency:, paid_at:, created_at:, messages: [], payments: [], **_)
      @id = id
      @user_id = user.id
      @price = price
      @currency = currency
      @paid_at = paid_at
      @created_at = created_at
      @_user = user
      @_messages = messages
      @_payments = payments
    end

    def messages; @_messages end
    def user; @_user end
    def payments; @_payments end

    def add_message(text:, from_user:)
      message_attrs = {
        id: GenerateId.new.call,
        order: self,
        user: from_user,
        body: text,
        created_at: Time.now
      }
      Message.new(message_attrs).tap do |message|
        @_messages << message
        add_event(Event.for(Event::MESSAGE_CREATED, message))
      end
    end

    def price_set?
      !price.nil?
    end

    def set_price(price, currency)
      @price = price
      @currency = currency
      add_event(Event.for(Event::ORDER_PRICE_CHANGED, self))
    end

    def add_successful_payment(payment_id:, amount:, currency:)
      payment_attrs = {
        id: GenerateId.new.call,
        order: self,
        payment_id: payment_id,
        amount: amount,
        currency: currency,
        created_at: Time.now,
      }
      Payment.new(payment_attrs).tap do |payment|
        @_payments << payment
        add_event(Event.for(Event::PAYMENT_CREATED, payment))
      end
    end

    def add_failed_payment(payment_id:, amount:, currency:, error_message:)
      payment_attrs = {
        id: GenerateId.new.call,
        order: self,
        payment_id: payment_id,
        amount: amount,
        currency: currency,
        error: error_message,
        created_at: Time.now,
      }
      Payment.new(payment_attrs).tap do |payment|
        @_payments << payment
        add_event(Event.for(Event::PAYMENT_CREATED, payment))
      end
    end

    def request_text
      messages[0].body
    end
  end
end
