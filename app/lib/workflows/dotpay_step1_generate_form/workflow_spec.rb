describe SoT::DotpayStep1GenerateForm::Workflow do
  let(:state) { APP_COMPONENTS[:state] }
  let(:user_repo) { APP_COMPONENTS[:user_repository] }
  let(:order_repo) { APP_COMPONENTS[:order_repository] }
  let(:user) { user_repo.save(user_repo.new_user(email: 'user@test.pl')) }
  let(:other_user) { user_repo.save(user_repo.new_user(email: 'user2@test.pl')) }
  let(:order) { order_repo.save(order_repo.new_order(user: user, price: Money.new(100, :jpy))) }

  subject {
    described_class.new(
      dotpay_id: 'dummy_id',
      dotpay_pin: 'dummy_pin',
      server_base_url: 'http://test.pl/',
    )
  }

  it 'generates form data object' do
    allow_any_instance_of(SoT::GenerateId).to receive(:call).and_return('123456')
    result = subject.call(order_id: order.id, user: user)

    expect(result.success?).to eq true
    expect(result.method).to eq 'post'
    expect(result.url).to eq 'https://ssl.dotpay.pl/t2/'
    expect(result.errors).to eq []
    expect(result.params).to eq(
      amount: '100',
      api_version: nil,
      channel_groups: 'K',
      chk: '943c4d4b6cdcf9c6e7f351e0d36aae61adbd93744149eb94d403ad60da24e11f',
      control: '123456',
      currency: 'JPY',
      description: 'SHARDS OF TOKYO PAYMENT FOR ORDER: 123456',
      email: 'user@test.pl',
      id: 'dummy_id',
      ignore_last_payment_channel: '1',
      lang: 'en',
      type: 0,
      url: 'http://test.pl/orders/123456/pay/result_user_callback',
    )
  end

  it 'returns error when there is no order' do
    result = subject.call(order_id: '404', user: user)

    expect(result.success?).to eq false
    expect(result.errors).to eq [:order_not_found]
  end

  it 'returns error when order belongs to other user' do
    result = subject.call(order_id: order.id, user: other_user)

    expect(result.success?).to eq false
    expect(result.errors).to eq [:order_not_found]
  end
end
