describe SoT::LoginTokenRepository do
  let(:state) { APP_COMPONENTS[:state] }
  let(:user_repo) { APP_COMPONENTS[:user_repository] }
  let(:user) { user_repo.save(user_repo.new_user(email: 'test@test.pl')) }

  it 'creates new login token' do
    login_token = subject.new_login_token(user, 'dummy_session_id')

    expect(login_token.user).to eq user
    expect(login_token.invalidated).to eq false
    expect(login_token.confirmed).to eq false

    last_event = login_token.instance_variable_get(:@_uncommited_events).last
    expect(last_event.name).to eq 'login_token_created_v1'
  end

  it 'saves login tokens' do
    login_token = subject.new_login_token(user, 'dummy_session_id')

    expect {
      subject.save(login_token)
    }.to change { subject.all.count }.by 1
  end

  describe 'finders' do
    let(:login_token1) { subject.save(subject.new_login_token(user, 'login_token1')) }
    let(:login_token2) { subject.save(subject.new_login_token(user, 'login_token2')) }
    let(:login_token3) { subject.save(subject.new_login_token(user, 'login_token3')) }

    before(:each) do
      state.reset!
    end

    it 'returns last token' do
      tokens = [login_token1, login_token2]
      expect(subject.last).to eq tokens.last
    end

    it 'returns all tokens in desc order' do
      tokens = [login_token1, login_token2]
      expect(subject.all).to eq tokens
    end

    it 'can find a token' do
      login_token1
      login_token2
      expect(subject.find(login_token1.id)).to eq login_token1
    end

    it 'can search a token by criteria' do
      token_id = login_token1.id
      session_id = login_token2.session_id
      expect(subject.find_by(id: token_id)).to eq login_token1
      expect(subject.find_by(session_id: session_id)).to eq login_token2
    end

    it 'can search all tokens by criteria' do
      token_id = login_token1.id
      session_id = login_token2.session_id
      expect(subject.find_all_by(id: token_id)).to eq [login_token1]
      expect(subject.find_all_by(session_id: session_id)).to eq [login_token2]
      expect(subject.find_all_by(confirmed: true)).to eq []
      expect(subject.find_all_by(confirmed: false)).to eq [login_token1, login_token2]
    end

    it 'can find valid token (not yet confirmed and not yet invalidated)' do
      login_token1.confirm!
      login_token2.invalidate!
      login_token3
      subject.save(login_token1)
      subject.save(login_token2)

      expect(subject.find_valid(login_token1.id)).to eq nil
      expect(subject.find_valid(login_token2.id)).to eq nil
      expect(subject.find_valid(login_token3.id)).not_to eq nil
    end
  end
end
