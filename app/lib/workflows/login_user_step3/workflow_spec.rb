describe SoT::LoginUserStep3::Workflow do
  let(:lt_repo) { APP_COMPONENTS[:login_token_repository] }
  let(:user_repo) { APP_COMPONENTS[:user_repository] }
  let(:user) { user_repo.save(user_repo.new_user(email: 'user@test.pl')) }
  let(:login_token) { lt_repo.save(lt_repo.new_login_token(user, 'active_session_id')) }
  let(:login_token_active) do
    token = lt_repo.new_login_token(user, 'session_id')
    token.confirm!
    lt_repo.save(token)
  end

  it 'returns successful result if token is active' do
    result = subject.call(session_id: login_token_active.session_id)
    expect(result.success?).to eq true
    expect(result.user_email).to eq user.email
  end

  it 'returns unsuccessful result if there is no token with such an id' do
    result = subject.call(session_id: '404token')
    expect(result.success?).to eq false
    expect(result.token).to be_nil
  end

  it 'returns unsuccessful result if the token is not acitve' do
    result = subject.call(session_id: login_token.session_id)
    expect(result.success?).to eq false
    expect(result.user_email).to eq user.email
  end
end
