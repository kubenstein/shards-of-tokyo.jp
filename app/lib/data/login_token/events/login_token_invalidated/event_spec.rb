describe SoT::LoginTokenInvalidatedEvent do
  let(:state) { APP_DEPENDENCIES[:state] }
  let(:lt_repo) { APP_DEPENDENCIES[:login_token_repository] }
  let(:user_repo) { APP_DEPENDENCIES[:user_repository] }

  let(:user) { user_repo.save(user_repo.new_user(email: 'test@test.pl')) }
  let(:login_token) { lt_repo.save(lt_repo.new_login_token(user, 'dummy_session_id')) }

  it 'creates proper token invalidated event from login_token object' do
    event = subject.build(login_token)

    expect(event.name).to eq 'login_token_invalidated'
    expect(event.requester_id).to eq user.id
    expect(event.payload[:id]).to eq login_token.id
  end

  it 'handles the event by marking given login token as invalidated' do
    event = subject.build(login_token)
    subject.handle(event, state)

    invalidated_login_token = lt_repo.find(login_token.id)
    expect(invalidated_login_token.invalidated).to eq true
  end
end
