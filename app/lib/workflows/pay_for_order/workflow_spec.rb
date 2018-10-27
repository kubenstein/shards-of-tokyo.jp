describe SoT::PayForOrder::Workflow do
  let(:state) { APP_COMPONENTS[:state] }
  let(:user_repo) { APP_COMPONENTS[:user_repository] }
  let(:order_repo) { APP_COMPONENTS[:order_repository] }
  let(:user) { user_repo.save(user_repo.new_user(email: 'user@test.pl')) }
  let!(:order) { order_repo.save(order_repo.new_order(user: user, price: Money.new(100, :jpy))) }

  it 'pays the order' do
    expect_any_instance_of(SoT::StripeGateway).to receive(:call).and_return(
      SoT::StripeGateway::SuccessPayment.new('dummy_stripe_payment_id', 'dummy_stripe_payment_id', 100, :jpy),
    )

    subject.call(order_id: order.id, user: user, stripe_token: 'dummy_token')
  end

  it 'sends info email to me on successful payment' do
    expect_any_instance_of(SoT::StripeGateway).to receive(:call).and_return(
      SoT::StripeGateway::SuccessPayment.new('dummy_stripe_payment_id', 'dummy_stripe_payment_id', 100, :jpy),
    )

    subject.call(order_id: order.id, user: user, stripe_token: 'dummy_token')

    mail = Mail::TestMailer.deliveries.last
    expect(mail.to).to eq [SoT::User::ME_EMAIL]
    expect(mail.subject).to eq '[Shards of Tokyo] new payment!'
  end

  it 'sends info email to user on successful' do
    expect_any_instance_of(SoT::StripeGateway).to receive(:call).and_return(
      SoT::StripeGateway::SuccessPayment.new('dummy_stripe_payment_id', 'dummy_stripe_payment_id', 100, :jpy),
    )

    subject.call(order_id: order.id, user: user, stripe_token: 'dummy_token')

    mail = Mail::TestMailer.deliveries[-2]
    expect(mail.to).to eq ['user@test.pl']
    expect(mail.subject).to eq "[Shards of Tokyo] order #{order.id} payment!"
  end

  it 'doesnt send info email to user on fail, it still sends to me' do
    expect_any_instance_of(SoT::StripeGateway).to receive(:call).and_return(
      SoT::StripeGateway::FailedPayment.new('dummy_stripe_payment_id', 100, :jpy, 'error_message'),
    )

    expect {
      subject.call(order_id: order.id, user: user, stripe_token: 'dummy_token')
    }.to change {
      Mail::TestMailer.deliveries.count
    }.by(1)

    mail = Mail::TestMailer.deliveries[-1]
    expect(mail.to).to eq [SoT::User::ME_EMAIL]
    expect(mail.subject).to eq '[Shards of Tokyo] new payment!'
  end

  it 'returns successful result if all is good' do
    expect_any_instance_of(SoT::StripeGateway).to receive(:call).and_return(
      SoT::StripeGateway::SuccessPayment.new('dummy_stripe_payment_id', 'dummy_stripe_payment_id', 100, :jpy),
    )

    result = subject.call(order_id: order.id, user: user, stripe_token: 'dummy_token')
    expect(result.order_id).to eq order.id
    expect(result.success?).to eq true
  end

  it 'returns unsuccessful result if there are some errors' do
    result = subject.call(order_id: '404', user: user, stripe_token: 'dummy_token')
    expect(result.success?).to eq false
    expect(result.errors).to eq [:order_not_found]
  end

  it 'adds successful payment to an order on succesful pay' do
    expect_any_instance_of(SoT::StripeGateway).to receive(:call).and_return(
      SoT::StripeGateway::SuccessPayment.new('dummy_stripe_payment_id', 'dummy_stripe_payment_id', 100, :jpy),
    )

    subject.call(order_id: order.id, user: user, stripe_token: 'dummy_token')
    last_payment = state.get_resources(:payments, order_id: order.id)[0]

    expect(last_payment[:payment_id]).to eq 'dummy_stripe_payment_id'
    expect(last_payment[:amount]).to eq 100
    expect(last_payment[:currency]).to eq 'JPY'
    expect(last_payment[:error]).to eq nil
  end

  it 'adds failed payment to an order when something went wrong' do
    expect_any_instance_of(SoT::StripeGateway).to receive(:call).and_return(
      SoT::StripeGateway::FailedPayment.new('dummy_stripe_payment_id', 100, :jpy, 'error_message'),
    )

    subject.call(order_id: order.id, user: user, stripe_token: 'dummy_token')
    last_payment = state.get_resources(:payments, order_id: order.id)[0]

    expect(last_payment[:payment_id]).to eq 'dummy_stripe_payment_id'
    expect(last_payment[:amount]).to eq 100
    expect(last_payment[:currency]).to eq 'JPY'
    expect(last_payment[:error]).to eq 'error_message'
  end

  it 'adds successful payment message to an order on succesful pay' do
    expect_any_instance_of(SoT::StripeGateway).to receive(:call).and_return(
      SoT::StripeGateway::SuccessPayment.new('dummy_stripe_payment_id', 'dummy_stripe_payment_id', 100, :jpy),
    )

    subject.call(order_id: order.id, user: user, stripe_token: 'dummy_token')
    last_message = state.get_resources(:messages, order_id: order.id)[0]

    expect(last_message[:order_id]).to eq order.id
    expect(last_message[:body]).to include '¥100'
  end

  it 'adds failed payment message to an order when something went wrong' do
    expect_any_instance_of(SoT::StripeGateway).to receive(:call).and_return(
      SoT::StripeGateway::FailedPayment.new('dummy_stripe_payment_id', 100, :jpy, 'error_message'),
    )

    subject.call(order_id: order.id, user: user, stripe_token: 'dummy_token')
    last_message = state.get_resources(:messages, order_id: order.id)[0]

    expect(last_message[:order_id]).to eq order.id
    expect(last_message[:body]).to include 'error_message'
  end
end
