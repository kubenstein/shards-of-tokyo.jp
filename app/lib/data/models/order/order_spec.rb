describe SoT::Order do
  let(:order_repo) { APP_COMPONENTS[:order_repository] }
  let(:user_repo) { APP_COMPONENTS[:user_repository] }

  let(:user) { user_repo.new_user(email: 'test@test.pl') }
  subject { order_repo.new_order(user: user) }

  it 'reports if the price was set' do
    expect(subject.price_set?).to eq false
    subject.set_price(Money.new(100, :usd))
    expect(subject.price_set?).to eq true
  end

  it 'reports if the order was fully paid' do
    # no price set
    expect(subject.paid?).to eq false

    # price set but not paid
    subject.set_price(Money.new(100, :usd))
    expect(subject.paid?).to eq false

    # paid but not enought
    subject.add_successful_payment(payment_id: 'payment_id1', price: Money.new(40, :usd))
    expect(subject.paid?).to eq false

    # paid
    subject.add_successful_payment(payment_id: 'payment_id2', price: Money.new(60, :usd))
    expect(subject.paid?).to eq true
  end

  it 'knows the amount_left_to_be_paid' do
    expect(subject.amount_left_to_be_paid).to eq Money.new(0, :usd)

    subject.set_price(Money.new(100, :usd))
    expect(subject.amount_left_to_be_paid).to eq Money.new(100, :usd)

    subject.add_successful_payment(payment_id: 'payment_id1', price: Money.new(40, :usd))
    expect(subject.amount_left_to_be_paid).to eq Money.new(60, :usd)

    subject.add_successful_payment(payment_id: 'payment_id2', price: Money.new(60, :usd))
    expect(subject.amount_left_to_be_paid).to eq Money.new(0, :usd)
  end

  it 'displays first message as a request text' do
    expect(subject.request_text).to eq ''

    subject.add_message(text: 'first message', from_user: user)
    expect(subject.request_text).to eq 'first message'

    subject.add_message(text: 'first message', from_user: user)
    expect(subject.request_text).to eq 'first message'

    subject.add_message(text: 'second message', from_user: user)
    expect(subject.request_text).to eq 'first message'
  end

  it 'stores successful payment' do
    subject.add_successful_payment(payment_id: 'payment_id', price: Money.new(60, :usd))

    last_event = subject.instance_variable_get(:@_uncommited_events).last
    expect(last_event.name).to eq 'payment_created'
    expect(last_event.payload[:error]).to eq nil
  end

  it 'stores failed payment' do
    subject.add_failed_payment(payment_id: 'payment_id', price: Money.new(60, :usd), error_message: 'error XYZ')

    last_event = subject.instance_variable_get(:@_uncommited_events).last
    expect(last_event.name).to eq 'payment_created'
    expect(last_event.payload[:error]).to eq 'error XYZ'
  end
end
