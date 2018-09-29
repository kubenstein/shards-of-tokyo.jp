describe SoT::MessageCreatedEvent do
  let(:state) { APP_DEPENDENCIES[:state] }
  let(:user_repo) { APP_DEPENDENCIES[:user_repository] }
  let(:order_repo) { APP_DEPENDENCIES[:order_repository] }

  let(:order) { order_repo.save(order_repo.new_order(user: user)) }
  let(:user) { user_repo.save(user_repo.new_user(email: 'test@test.pl')) }
  let(:message) { SoT::Message.new(id: 'id', user: user, order: order, body: 'message', created_at: Time.now) }

  it 'creates proper message created event from message object' do
    event = subject.build(message)

    expect(event.name).to eq 'message_created'
    expect(event.requester_id).to eq user.id
    expect(event.payload[:id]).to eq message.id
  end

  it 'handles the event by persisitng the message' do
    event = subject.build(message)

    expect {
      subject.handle(event, state)
    }.to change {
      state.get_resources(:messages).count
    }.by 1
  end
end
