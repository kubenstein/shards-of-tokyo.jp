describe SoT::AddOrderMessage::Workflow do
  let(:state) { APP_COMPONENTS[:state] }
  let(:order_repo) { APP_COMPONENTS[:order_repository] }
  let(:user_repo) { APP_COMPONENTS[:user_repository] }
  let(:me) { user_repo.save(user_repo.new_user(email: SoT::User::ME_EMAIL)) }
  let(:user) { user_repo.save(user_repo.new_user(email: 'user@test.pl')) }
  let(:order) { order_repo.save(order_repo.new_order(user: user, price: 100, currency: 'jpy')) }

  it 'adds message to an order' do
    result = nil
    expect {
      result = subject.call(user: user, order_id: order.id, text: 'message text')
    }.to change {
      state.get_resources(:messages).count
    }.by(1)

    expect(result.order_id).to eq order.id
  end

  it 'sends info email to me when user wrote' do
    expect {
      subject.call(user: user, order_id: order.id, text: 'message text')
    }.to change {
      Mail::TestMailer
        .deliveries
        .select { |mail| mail.to.include?(SoT::User::ME_EMAIL) }
        .count
    }.by(1)
  end

  it 'sends email to a user when I wrote' do
    expect {
      subject.call(user: me, order_id: order.id, text: 'message text')
    }.to change {
      Mail::TestMailer
        .deliveries
        .select { |mail| mail.to.include?('user@test.pl') }
        .count
    }.by(1)
  end

  it 'returns successful result if all is good' do
    result = subject.call(user: user, order_id: order.id, text: 'message text')
    expect(result.success?).to eq true
    expect(result.order_id).not_to be_nil
  end

  it 'returns unsuccessful result if there were some errors' do
    result = subject.call(user: user, order_id: order.id, text: nil)
    expect(result.success?).to eq false
    expect(result.errors).to eq [:empty_text]
  end
end
