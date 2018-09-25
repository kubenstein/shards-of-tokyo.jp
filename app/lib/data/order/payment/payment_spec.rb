describe SoT::Payment do
  let(:user_repo) { APP_DEPENDENCIES[:user_repository] }
  let(:order_repo) { APP_DEPENDENCIES[:order_repository] }

  let(:order) { order_repo.save(order_repo.new_order(user: user)) }
  let(:user) { user_repo.save(user_repo.new_user(email: 'test@test.pl')) }

  it 'returns if its successful or not' do
    successful_payment = SoT::Payment.new(
      id: 'id',
      order: order,
      payment_id: 'payment_id',
      amount: 100,
      currency: 'jpy',
      error: nil,
      created_at: Time.now,
    )

    failed_payment = SoT::Payment.new(
      id: 'id',
      order: order,
      payment_id: 'payment_id',
      amount: 100,
      currency: 'jpy',
      error: 'error_message',
      created_at: Time.now,
    )

    expect(successful_payment.successful?).to eq true
    expect(failed_payment.successful?).to eq false
  end
end
