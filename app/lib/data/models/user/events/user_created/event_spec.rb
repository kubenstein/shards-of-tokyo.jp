describe SoT::UserCreatedEvent do
  let(:state) { APP_COMPONENTS[:state] }
  let(:user) { APP_COMPONENTS[:user_repository].new_user(email: 'test@test.pl') }

  it 'creates proper user created event from user object' do
    event = subject.build(user)

    expect(event.name).to eq 'user_created'
    expect(event.requester_id).to eq 'system'
    expect(event.payload[:id]).to eq user.id
  end

  it 'handles the event by persisting given user data' do
    event = subject.build(user)

    expect {
      subject.handle(event, state)
    }.to change {
      state.get_resources(:users, id: user.id).count
    }.by(1)
  end
end
