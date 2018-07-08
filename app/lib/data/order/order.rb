module SoT
  class Order
    include Eventable

    attr_reader :id, :user, :price, :currency, :created_at, :messages, :payments

    def initialize(id:, user:, price:, currency:, created_at:, messages: [], payments: [], **_)
      @id = id
      @user_id = user.id
      @price = price
      @currency = currency
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
        add_event(MessageCreatedEvent.build(message))
      end
    end

    def price_set?
      !price.nil?
    end

    def paid?
      price_set? && amount_left_to_be_paid == 0
    end

    def set_price(price, currency)
      @price = price
      @currency = currency
      add_event(OrderPriceChangedEvent.build(self))
    end

    def amount_left_to_be_paid
      (price || 0) - payments.select(&:successful?).reduce(0) { |total, payment| total + payment.amount }
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
        add_event(PaymentCreatedEvent.build(payment))
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
        add_event(PaymentCreatedEvent.build(payment))
      end
    end

    def request_text
      messages[0].body
    end
  end
end
