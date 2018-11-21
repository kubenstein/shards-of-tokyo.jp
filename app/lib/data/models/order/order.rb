# Not sure yet how to have attr_reader with all fields as a form of documentation
# while still using @_field internally
# rubocop:disable Lint/DuplicateMethods

module SoT
  class Order
    include Eventable
    include ObjWithPriceSerializable

    attr_reader :id, :user, :price, :created_at, :messages, :payments

    def initialize(id:, user:, price:, created_at:, messages: [], payments: [], **_) # rubocop:disable Metrics/ParameterLists
      @id = id
      @user_id = user.id
      @price = price
      @created_at = created_at
      @_user = user
      @_messages = messages
      @_payments = payments
    end

    def price_set?
      !price.nil?
    end

    def paid?
      price_set? && amount_left_to_be_paid == 0
    end

    def amount_left_to_be_paid
      return Money.new(0, :usd) unless price_set?
      payments
        .select(&:successful?)
        .reduce(price) { |left, payment| left - payment.price }
    end

    def request_text
      messages[0]&.body || ''
    end

    def set_price(price, requester_id: nil)
      @price = price
      add_event(OrderPriceChangedEvent.build(self, requester_id: requester_id))
    end

    def add_message(text:, from_user:)
      message_attrs = {
        id: GenerateId.new.call,
        order: self,
        user: from_user,
        body: text,
        created_at: Time.now,
      }
      Message.new(message_attrs).tap do |message|
        @_messages << message
        add_event(MessageCreatedEvent.build(message))
      end
    end

    def add_successful_payment(payment_gateway:, payment_id:, price:)
      payment_attrs = {
        id: GenerateId.new.call,
        order: self,
        payment_id: payment_id,
        gateway: payment_gateway,
        price: price,
        created_at: Time.now,
      }
      Payment.new(payment_attrs).tap do |payment|
        @_payments << payment
        add_event(PaymentCreatedEvent.build(payment))
      end
    end

    def add_failed_payment(payment_gateway:, payment_id:, price:, error_message:)
      payment_attrs = {
        id: GenerateId.new.call,
        order: self,
        payment_id: payment_id,
        gateway: payment_gateway,
        price: price,
        error: error_message,
        created_at: Time.now,
      }
      Payment.new(payment_attrs).tap do |payment|
        @_payments << payment
        add_event(PaymentCreatedEvent.build(payment))
      end
    end

    def ==(other)
      id == other.id
    end

    # attr_reader boilerplate
    def messages
      @_messages
    end

    def user
      @_user
    end

    def payments
      @_payments
    end
  end
end
