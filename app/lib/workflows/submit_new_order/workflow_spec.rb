describe SoT::SubmitNewOrder::Workflow do
  let(:state) { APP_COMPONENTS[:state] }
  let(:user_repo) { APP_COMPONENTS[:user_repository] }
  let(:user) { user_repo.save(user_repo.new_user(email: 'test@test.pl')) }

  it 'creates an order for user' do
    result = nil
    expect {
      result = subject.call(user: user, text: 'order_message')
    }.to change {
      state.get_resources(:orders).count
    }.by(1)

    expect(result.order.user).to eq user
  end

  it 'sends info email to me' do
    expect {
      subject.call(user: user, text: 'order_message')
    }.to change {
      Mail::TestMailer.deliveries.count
    }.by(1)

    mail = Mail::TestMailer.deliveries.last
    expect(mail.to).to eq [SoT::User::ME_EMAIL]
  end

  it 'returns successful result if all is good' do
    result = subject.call(user: user, text: 'order_message')
    expect(result.success?).to eq true
    expect(result.order).not_to be_nil
  end

  it 'returns unsuccessful result if there were some errors' do
    result = subject.call(user: nil)
    expect(result.success?).to eq false
    expect(result.errors).to eq [:empty_text, :user_not_found]
  end
end
