describe SoT::StripeGateway do
  let(:stripe_charge) do
    double(
      Stripe::Charge,
      create: {
        id: 'test_charge_id',
        amount: 'test_returned_amount',
        currency: 'test_returned_currency',
      },
    )
  end

  let(:failing_stripe_charge) do
    double(Stripe::Charge).tap do |d|
      error = { error: { charge: 'test_failed_payment_id', code: 'test_err_code', message: 'test_err_message' } }
      allow(d).to receive(:create).and_raise(Stripe::StripeError.new(json_body: error))
    end
  end

  let(:stripe_customer) do
    double(
      Stripe::Customer,
      create: double(Stripe::Customer, id: 'test_new_stripe_customer_id'),
    )
  end

  subject {
    described_class.new(
      stripe_charge: stripe_charge,
      stripe_customer: stripe_customer,
      stripe_secret_key: 'dummy_secret_key',
    )
  }

  it 'calls stripe api properly during pay - payer_stripe_customer_id is known' do
    expect(stripe_charge).to receive(:create).with({
                                                     amount: 100,
                                                     description: 'Shards of Tokyo payment for order: orderID',
                                                     currency: :jpy,
                                                     customer: 'stripe_customer_id',
                                                     metadata: { order_id: 'orderID' },
                                                   },
                                                   api_key: 'dummy_secret_key')
    subject.call(
      stripe_token: 'stripeToken',
      order_id: 'orderID',
      payer_email: 'test@test.pl',
      amount: 100,
      currency: :jpy,
      payer_stripe_customer_id: 'stripe_customer_id',
    )
  end

  it 'calls stripe api properly during pay - payer_stripe_customer_id is yet unknown' do
    expect(stripe_customer).to receive(:create).with({
                                                       email: 'test@test.pl',
                                                       source: 'stripeToken',
                                                     },
                                                     api_key: 'dummy_secret_key')

    result = subject.call(
      stripe_token: 'stripeToken',
      order_id: 'orderID',
      payer_email: 'test@test.pl',
      amount: 100,
      currency: :jpy,
    )
    expect(result.customer_id).to eq 'test_new_stripe_customer_id'
  end

  it 'returns successful result' do
    result = subject.call(
      stripe_token: 'stripeToken',
      order_id: 'orderID',
      payer_email: 'test@test.pl',
      amount: 100,
      currency: :jpy,
      payer_stripe_customer_id: 'stripe_customer_id',
    )
    expect(result.success?).to eq true
    expect(result.customer_id).to eq 'stripe_customer_id'
    expect(result.payment_id).to eq 'test_charge_id'
    expect(result.amount).to eq 'test_returned_amount'
    expect(result.currency).to eq 'test_returned_currency'
  end

  it 'returns failed result' do
    gateway = described_class.new(
      stripe_secret_key: 'dummy_secret_key',
      stripe_charge: failing_stripe_charge,
      stripe_customer: stripe_customer,
    )

    result = gateway.call(
      stripe_token: 'stripeToken',
      order_id: 'orderID',
      payer_email: 'test@test.pl',
      amount: 100,
      currency: :jpy,
      payer_stripe_customer_id: 'stripe_customer_id',
    )
    expect(result.success?).to eq false
    expect(result.payment_id).to eq 'test_failed_payment_id'
    expect(result.amount).to eq 100
    expect(result.currency).to eq :jpy
    expect(result.error_message).to eq 'test_err_code - test_err_message'
  end
end
