describe SoT::LoginTokenConfirmedEvent do
  let(:state) { APP_DEPENDENCIES[:state] }
  let(:lt_repo) { APP_DEPENDENCIES[:login_token_repository] }
  let(:user_repo) { APP_DEPENDENCIES[:user_repository] }

  let(:user) { user_repo.save(user_repo.new_user(email: 'test@test.pl')) }
  let(:login_token) { lt_repo.save(lt_repo.new_login_token(user, 'dummy_session_id')) }

  it 'creates proper token confirmed event from login_token object' do
    event = subject.build(login_token)

    expect(event.name).to eq 'login_token_confirmed'
    expect(event.requester_id).to eq user.id
    expect(event.payload[:id]).to eq login_token.id
  end

  it 'handles the event by marking given login token as confirmed' do
    event = subject.build(login_token)
    subject.handle(event, state)

    confirmed_login_token = lt_repo.find(login_token.id)
    expect(confirmed_login_token.confirmed).to eq true
  end
end
