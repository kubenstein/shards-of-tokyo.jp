describe SoT::UserStripeCustomerIdUpdatedEvent do
  let(:state) { APP_COMPONENTS[:state] }
  let(:repo) { APP_COMPONENTS[:user_repository] }

  let(:user) { repo.save(repo.new_user(email: 'test@test.pl')) }

  it 'creates proper stripe id update event from user object' do
    user.stripe_customer_id = 'new_stripe_customer_id'
    event = subject.build(user)

    expect(event.name).to eq 'user_stripe_customer_id_updated'
    expect(event.requester_id).to eq user.id
    expect(event.payload[:id]).to eq user.id
    expect(event.payload[:stripe_customer_id]).to eq 'new_stripe_customer_id'
  end

  it 'handles the event by updating stripe customer id for a given user' do
    user.stripe_customer_id = 'new_stripe_customer_id'
    event = subject.build(user)

    expect {
      subject.handle(event, state)
    }.to change {
      state.get_resources(:users, id: user.id)[0][:stripe_customer_id]
    }.from(nil).to('new_stripe_customer_id')
  end
end
