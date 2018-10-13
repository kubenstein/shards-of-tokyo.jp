describe SoT::LoginUserStep2::Workflow do
  let(:state) { APP_COMPONENTS[:state] }
  let(:lt_repo) { APP_COMPONENTS[:login_token_repository] }
  let(:user_repo) { APP_COMPONENTS[:user_repository] }
  let(:user) { user_repo.save(user_repo.new_user(email: 'user@test.pl')) }
  let!(:login_token) { lt_repo.save(lt_repo.new_login_token(user, 'session_id')) }

  it 'confirms a login token' do
    result = nil
    expect {
      result = subject.call(token_id: login_token.id)
    }.to change {
      state.get_resources(:login_tokens, id: login_token.id)[0][:confirmed]
    }.from(false).to(true)

    expect(result.success?).to be true
    expect(result.token).not_to be_nil
  end

  it 'returns successful result if all is good' do
    result = subject.call(token_id: login_token.id)
    expect(result.success?).to eq true
    expect(result.token.session_id).to eq 'session_id'
  end

  it 'returns unsuccessful result if there were some errors' do
    result = subject.call(token_id: '404token')
    expect(result.success?).to eq false
    expect(result.errors).to eq [:token_not_found]
  end
end
