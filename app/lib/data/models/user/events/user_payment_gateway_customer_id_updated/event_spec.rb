describe SoT::UserPaymentGatewayCustomerIdUpdatedEvent do
  let(:state) { APP_COMPONENTS[:state] }
  let(:repo) { APP_COMPONENTS[:user_repository] }

  let(:user) { repo.save(repo.new_user(email: 'test@test.pl')) }

  it 'creates proper stripe id update event from user object' do
    user.payment_gateway_customer_id = 'new_payment_gateway_customer_id'
    event = subject.build(user)

    expect(event.name).to eq 'user_payment_gateway_customer_id_updated'
    expect(event.requester_id).to eq user.id
    expect(event.payload[:id]).to eq user.id
    expect(event.payload[:payment_gateway_customer_id]).to eq 'new_payment_gateway_customer_id'
  end

  it 'handles the event by updating stripe customer id for a given user' do
    user.payment_gateway_customer_id = 'new_payment_gateway_customer_id'
    event = subject.build(user)

    expect {
      subject.handle(event, state)
    }.to change {
      state.get_resources(:users, id: user.id)[0][:payment_gateway_customer_id]
    }.from(nil).to('new_payment_gateway_customer_id')
  end
end
