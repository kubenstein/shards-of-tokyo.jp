describe SoT::LogoutUser::Workflow do
  let(:user_repo) { APP_COMPONENTS[:user_repository] }
  let(:lt_repo) { APP_COMPONENTS[:login_token_repository] }
  let(:user) { user_repo.save(user_repo.new_user(email: 'test@test.pl')) }
  let(:session_id) { 'session_id' }
  let!(:lt_token) do
    lt_repo.new_login_token(user, session_id).tap do |lt|
      lt.confirm!
      lt_repo.save(lt)
    end
  end

  it 'logouts logged user' do
    expect {
      subject.call(session_id: session_id)
    }.to change {
      user_repo.find_logged_in(session_id: session_id)
    }.from(user).to(nil)

    user_login_token = lt_repo.find(lt_token.id)
    expect(user_login_token.invalidated).to eq true
  end

  it 'returns successful result' do
    result = subject.call(session_id: session_id)
    expect(result.success?).to eq true
  end

  it 'invalidates all tokens for this session' do
    lt_repo.save(lt_repo.new_login_token(user, session_id))
    lt_repo.save(lt_repo.new_login_token(user, session_id))
    lt_repo.save(lt_repo.new_login_token(user, session_id))

    expect {
      subject.call(session_id: session_id)
    }.to change {
      lt_repo.find_all_by(session_id: session_id, invalidated: false).count
    }.from(4).to(0)
  end
end
