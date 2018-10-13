describe SoT::LoginUserStep1SendToken::Workflow do
  let(:state) { APP_COMPONENTS[:state] }
  let(:user_repo) { APP_COMPONENTS[:user_repository] }
  let(:user) { user_repo.save(user_repo.new_user(email: 'user@test.pl')) }

  it 'adds new login token' do
    result = nil
    expect {
      result = subject.call(email: user.email, session_id: 'session_id')
    }.to change {
      state.get_resources(:login_tokens).count
    }.by(1)

    expect(result.success?).to be true
    expect(result.token).not_to be_nil
  end

  it 'sends info email to the user with the token' do
    result = nil
    expect {
      result = subject.call(email: user.email, session_id: 'session_id')
    }.to change {
      Mail::TestMailer
        .deliveries
        .select { |mail| mail.to.include?(user.email) }
        .count
    }.by(1)

    expect(Mail::TestMailer.deliveries.last.body.to_s).to include result.token.id
  end

  it 'returns successful result if all is good' do
    result = subject.call(email: user.email, session_id: 'session_id')
    expect(result.success?).to eq true
    expect(result.token.session_id).to eq 'session_id'
  end

  it 'returns unsuccessful result if there were some errors' do
    result = subject.call(email: '404email@test.pl', session_id: 'session_id')
    expect(result.success?).to eq false
    expect(result.errors).to eq [:email_not_found]
  end
end
