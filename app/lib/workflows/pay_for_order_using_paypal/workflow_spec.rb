describe SoT::PayForOrderUsingPaypal::Workflow do
  let(:state) { APP_COMPONENTS[:state] }
  let(:user_repo) { APP_COMPONENTS[:user_repository] }
  let(:order_repo) { APP_COMPONENTS[:order_repository] }
  let(:user) { user_repo.save(user_repo.new_user(email: 'user@test.pl')) }
  let!(:order) { order_repo.save(order_repo.new_order(user: user, price: Money.new(100, :jpy))) }
  let(:paypal_authorize_data) do
    {
      paymentToken: 'EC-3Y9574956W5676349',
      orderID: 'EC-3Y9574956W5676349',
      payerID: '8NSLQPB58XBSY',
      paymentID: 'PAY-21T50538TK754445TLQPC3NI',
      intent: 'sale',
      returnUrl: 'https://www.sandbox.paypal.com/?paymentId=PAY-21T50538TK754445TLQPC3NI&token=EC-3Y9574956W5676349&PayerID=8NSLQPB58XBSY',
    }
  end

  subject {
    described_class.new(
      env: 'sandbox',
      client_id: 'dummy_client_id',
      secret: 'dummy_secret',
    )
  }

  it 'pays the order' do
    expect_any_instance_of(SoT::PaypalGateway).to receive(:call).and_return(
      SoT::PaypalGateway::SuccessPayment.new('dummy_paypal_customer_id', 'dummy_paypal_payment_id', 100, :jpy),
    )

    subject.call(order_id: order.id, user: user, paypal_authorize_data: paypal_authorize_data)
  end

  it 'sends info email to me on successful payment' do
    expect_any_instance_of(SoT::PaypalGateway).to receive(:call).and_return(
      SoT::PaypalGateway::SuccessPayment.new('dummy_paypal_customer_id', 'dummy_paypal_payment_id', 100, :jpy),
    )

    subject.call(order_id: order.id, user: user, paypal_authorize_data: paypal_authorize_data)

    mail = Mail::TestMailer.deliveries.last
    expect(mail.to).to eq [SoT::User::ME_EMAIL]
    expect(mail.subject).to eq '[Shards of Tokyo] new payment!'
  end

  it 'sends info email to user on successful' do
    expect_any_instance_of(SoT::PaypalGateway).to receive(:call).and_return(
      SoT::PaypalGateway::SuccessPayment.new('dummy_paypal_customer_id', 'dummy_paypal_payment_id', 100, :jpy),
    )

    subject.call(order_id: order.id, user: user, paypal_authorize_data: paypal_authorize_data)

    mail = Mail::TestMailer.deliveries[-2]
    expect(mail.to).to eq ['user@test.pl']
    expect(mail.subject).to eq "[Shards of Tokyo] order #{order.id} payment!"
  end

  it 'doesnt send info email to user on fail, it still sends to me' do
    expect_any_instance_of(SoT::PaypalGateway).to receive(:call).and_return(
      SoT::PaypalGateway::FailedPayment.new('dummy_paypal_payment_id', 100, :jpy, 'error_message'),
    )

    expect {
      subject.call(order_id: order.id, user: user, paypal_authorize_data: paypal_authorize_data)
    }.to change {
      Mail::TestMailer.deliveries.count
    }.by(1)

    mail = Mail::TestMailer.deliveries[-1]
    expect(mail.to).to eq [SoT::User::ME_EMAIL]
    expect(mail.subject).to eq '[Shards of Tokyo] new payment!'
  end

  it 'returns successful result if all is good' do
    expect_any_instance_of(SoT::PaypalGateway).to receive(:call).and_return(
      SoT::PaypalGateway::SuccessPayment.new('dummy_paypal_customer_id', 'dummy_paypal_payment_id', 100, :jpy),
    )

    result = subject.call(order_id: order.id, user: user, paypal_authorize_data: paypal_authorize_data)
    expect(result.order_id).to eq order.id
    expect(result.success?).to eq true
  end

  it 'returns unsuccessful result if there are some errors' do
    result = subject.call(order_id: '404', user: user, paypal_authorize_data: paypal_authorize_data)
    expect(result.success?).to eq false
    expect(result.errors).to eq [:order_not_found]
  end

  it 'adds successful payment to an order on succesful pay' do
    expect_any_instance_of(SoT::PaypalGateway).to receive(:call).and_return(
      SoT::PaypalGateway::SuccessPayment.new('dummy_paypal_customer_id', 'dummy_paypal_payment_id', 100, :jpy),
    )

    subject.call(order_id: order.id, user: user, paypal_authorize_data: paypal_authorize_data)
    last_payment = state.get_resources(:payments, order_id: order.id)[0]

    expect(last_payment[:payment_id]).to eq 'dummy_paypal_payment_id'
    expect(last_payment[:amount]).to eq 100
    expect(last_payment[:currency]).to eq 'JPY'
    expect(last_payment[:error]).to eq nil
  end

  it 'adds failed payment to an order when something went wrong' do
    expect_any_instance_of(SoT::PaypalGateway).to receive(:call).and_return(
      SoT::PaypalGateway::FailedPayment.new('dummy_paypal_payment_id', 100, :jpy, 'error_message'),
    )

    subject.call(order_id: order.id, user: user, paypal_authorize_data: paypal_authorize_data)
    last_payment = state.get_resources(:payments, order_id: order.id)[0]

    expect(last_payment[:payment_id]).to eq 'dummy_paypal_payment_id'
    expect(last_payment[:amount]).to eq 100
    expect(last_payment[:currency]).to eq 'JPY'
    expect(last_payment[:error]).to eq 'error_message'
  end

  it 'adds successful payment message to an order on succesful pay' do
    expect_any_instance_of(SoT::PaypalGateway).to receive(:call).and_return(
      SoT::PaypalGateway::SuccessPayment.new('dummy_paypal_customer_id', 'dummy_paypal_payment_id', 100, :jpy),
    )

    subject.call(order_id: order.id, user: user, paypal_authorize_data: paypal_authorize_data)
    last_message = state.get_resources(:messages, order_id: order.id)[0]

    expect(last_message[:order_id]).to eq order.id
    expect(last_message[:body]).to include '¥100'
  end

  it 'adds failed payment message to an order when something went wrong' do
    expect_any_instance_of(SoT::PaypalGateway).to receive(:call).and_return(
      SoT::PaypalGateway::FailedPayment.new('dummy_paypal_payment_id', 100, :jpy, 'error_message'),
    )

    subject.call(order_id: order.id, user: user, paypal_authorize_data: paypal_authorize_data)
    last_message = state.get_resources(:messages, order_id: order.id)[0]

    expect(last_message[:order_id]).to eq order.id
    expect(last_message[:body]).to include 'error_message'
  end
end
