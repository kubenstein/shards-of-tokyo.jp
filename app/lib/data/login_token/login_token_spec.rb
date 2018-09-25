describe SoT::LoginToken do
  let(:lt_repo) { APP_DEPENDENCIES[:login_token_repository] }
  let(:user_repo) { APP_DEPENDENCIES[:user_repository] }

  let(:user) { user_repo.new_user(email: 'test@test.pl') }
  subject(:login_token) { lt_repo.new_login_token(user, 'dummy_session_id') }

  it 'can be invalidated' do
    subject.invalidate!

    last_event = subject.instance_variable_get(:@_uncommited_events).last
    expect(subject.invalidated).to eq true
    expect(last_event.name).to eq 'login_token_invalidated'
  end

  it 'can be confirmed' do
    subject.confirm!

    last_event = subject.instance_variable_get(:@_uncommited_events).last
    expect(subject.confirmed).to eq true
    expect(last_event.name).to eq 'login_token_confirmed'
  end

  it 'reports itself as active when it is confirmed and not invalidated' do
    expect(subject.active?).to eq false
    subject.confirm!
    expect(subject.active?).to eq true
    subject.invalidate!
    expect(subject.active?).to eq false
  end

  it 'returns user_email' do
    expect(subject.user_email).to eq subject.user.email
  end
end
