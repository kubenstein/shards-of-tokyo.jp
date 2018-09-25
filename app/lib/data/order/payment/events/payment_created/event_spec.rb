describe SoT::PaymentCreatedEvent do
  let(:state) { APP_DEPENDENCIES[:state] }
  let(:user_repo) { APP_DEPENDENCIES[:user_repository] }
  let(:order_repo) { APP_DEPENDENCIES[:order_repository] }

  let(:order) { order_repo.save(order_repo.new_order(user: user)) }
  let(:user) { user_repo.save(user_repo.new_user(email: 'test@test.pl')) }
  let(:payment) {
    SoT::Payment.new(
      id: 'id',
      order: order,
      payment_id: 'payment_id',
      amount: 100,
      currency: 'jpy',
      error: nil,
      created_at: Time.now,
    )
  }

  it 'creates proper payment created event from payment object' do
    event = subject.build(payment)

    expect(event.name).to eq 'payment_created'
    expect(event.requester_id).to eq user.id
    expect(event.payload[:id]).to eq payment.id
  end

  it 'handles the event by persisitng the payment' do
    event = subject.build(payment)

    expect {
      subject.handle(event, state)
    }.to change {
      state.get_resources(:payments).count
    }.by 1
  end
end
