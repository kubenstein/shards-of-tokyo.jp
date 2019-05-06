describe SoT::RegisterUser::Workflow do
  let(:state) { APP_COMPONENTS[:state] }
  let(:order_repo) { APP_COMPONENTS[:order_repository] }
  let(:lt_repo) { APP_COMPONENTS[:login_token_repository] }

  it 'creates a user' do
    result = nil
    expect {
      result = subject.call(email: 'test1@test.pl', session_id: 'session_id')
    }.to change {
      state.get_resources(:users).count
    }.by(1)

    expect(result.user.email).to eq 'test1@test.pl'
  end

  it 'sends info email to me' do
    expect {
      subject.call(email: 'test2@test.pl', session_id: 'session_id')
    }.to change {
      Mail::TestMailer
        .deliveries
        .select { |mail| mail.to.include?(SoT::User::ME_EMAIL) }
        .count
    }.by(1)
  end

  it 'sends info email to me with an info when given' do
    subject.call(email: 'test3@test.pl', session_id: 'session_id', info: 'registration message')
    expect(Mail::TestMailer.deliveries.last.body.to_s).to include 'registration message'
  end

  it 'sends email to a user' do
    expect {
      subject.call(email: 'test4@test.pl', session_id: 'session_id')
    }.to change {
      Mail::TestMailer
        .deliveries
        .select { |mail| mail.to.include?('test4@test.pl') }
        .count
    }.by(1)
  end

  it 'doesnt allow creating multiple users with same email' do
    result_first = subject.call(email: 'same@test.pl', session_id: 'session_id')
    result_second = subject.call(email: 'same@test.pl', session_id: 'session_id')

    expect(result_first.success?).to be true
    expect(result_second.success?).to be false
    expect(result_second.errors).to eq [:email_taken]
  end

  it 'creates login token during the process' do
    result = nil
    expect {
      result = subject.call(email: 'test_token@test.pl', session_id: 'session_id')
    }.to change {
      state.get_resources(:login_tokens).count
    }.by(1)

    user = result.user
    login_token = lt_repo.find_by(user_id: user.id)
    expect(login_token.confirmed).to eq false
  end

  it 'creates a initial order if info param is provided' do
    result = nil
    expect {
      result = subject.call(
        email: 'test_info@test.pl',
        session_id: 'session_id',
        info: 'initial order message',
      )
    }.to change {
      state.get_resources(:orders).count
    }.by(1)

    user = result.user
    order = order_repo.for_user_newest_first(user_id: user.id).last
    expect(order).not_to be_nil
    expect(order.request_text).to eq 'initial order message'
  end

  it 'returns successful result if all is good' do
    result = subject.call(email: 'test_result@test.pl', session_id: 'session_id')
    expect(result.success?).to eq true
    expect(result.user).not_to be_nil
  end

  it 'returns unsuccessful result if there were some errors' do
    result = subject.call(email: '404', session_id: 'session_id')
    expect(result.success?).to eq false
    expect(result.errors).to eq [:email_invalid]
  end
end
