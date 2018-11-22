describe SoT::OrderCreatedV1Event do
  let(:state) { APP_COMPONENTS[:state] }
  let(:order_repo) { APP_COMPONENTS[:order_repository] }
  let(:user_repo) { APP_COMPONENTS[:user_repository] }
  let(:user) { user_repo.save(user_repo.new_user(email: 'test@test.pl')) }
  let(:order) { order_repo.new_order(user: user) }

  it 'creates proper order created event from order object' do
    event = subject.build(order)

    expect(event.name).to eq 'order_created_v1'
    expect(event.requester_id).to eq user.id
    expect(event.payload[:id]).to eq order.id
  end

  it 'handles the event by adding order to the state' do
    event = subject.build(order)

    expect {
      subject.handle(event, state)
    }.to change {
      state.get_resources(:orders).count
    }.by(1)
  end
end
