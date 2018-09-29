describe SoT::UserRepository do
  let(:state) { APP_DEPENDENCIES[:state] }

  it 'creates new user' do
    user = subject.new_user(email: 'test@test.pl')

    expect(user.email).to eq 'test@test.pl'

    last_event = user.instance_variable_get(:@_uncommited_events).last
    expect(last_event.name).to eq 'user_created'
  end

  it 'saves users' do
    user = subject.new_user(email: 'test@test.pl')

    expect {
      subject.save(user)
    }.to change { subject.find(user.id) }.from(nil).to(user)
  end

  describe 'finders' do
    let(:lt_repo) { APP_DEPENDENCIES[:login_token_repository] }
    let(:user1) { subject.save(subject.new_user(email: 'user1@test.pl')) }
    let(:user2) { subject.save(subject.new_user(email: 'user2@test.pl')) }
    let(:user3) { subject.save(subject.new_user(email: 'niewczas.jakub@gmail.com')) }

    before(:each) do
      state.reset!
    end

    it 'checkes existance' do
      user1
      expect(subject.exists?(email: '404')).to eq false
      expect(subject.exists?(email: 'user1@test.pl')).to eq true
    end

    it 'can find a user' do
      user1
      user2
      expect(subject.find(user1.id)).to eq user1
    end

    it 'can search a user by criteria' do
      email = user1.email
      id = user2.id
      expect(subject.find_by(email: email)).to eq user1
      expect(subject.find_by(id: id)).to eq user2
    end

    it 'can find "me" user' do
      user1
      user2
      user3
      expect(subject.find_me).to eq user3
    end

    it 'can find logged in user' do
      token = lt_repo.save(lt_repo.new_login_token(user1, 'dummy_session_id'))

      expect(subject.find_logged_in(session_id: token.session_id)).to eq nil
      token.confirm!
      lt_repo.save(token)
      expect(subject.find_logged_in(session_id: token.session_id)).to eq user1
    end
  end
end
