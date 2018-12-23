describe SoT::PaypalGateway do
  let(:logger) { APP_COMPONENTS[:logger] }
  subject {
    described_class.new(
      env: 'sandbox',
      client_id: 'Ae8y-aV7qaRi6XeLwdVUivsOQ-ZRJ3U05pRDtSzD62wibyOz_MvrxBhbI6Hx0c0FKorgYxOUqtIsSMTr',
      secret: 'EARm8oY3Lp2S8VlnNpDpacBwo3or_jmTtrgm33I05fBurFDDgerO8XSIaItNblK7jFzk9rm2GLJOgExr',
      logger: logger,
    )
  }

  it 'successfully make a purchase' do
    VCR.use_cassette('paypal_gateway_successful_purchase') do
      result = subject.call(
        payment_id: 'PAY-35V57137PS845305RLQQHFWY',
        payer_id: '8NSLQPB58XBSY',
      )
      expect(result.success?).to eq true
      expect(result.customer_id).to eq 'snow.jon@gmail.com 8NSLQPB58XBSY'
      expect(result.payment_id).to eq 'PAY-35V57137PS845305RLQQHFWY'
      expect(result.amount).to eq 4000 # $40.00 the ruby Money format is returned
      expect(result.currency).to eq 'USD'
    end
  end

  it 'returns failed result' do
    VCR.use_cassette('paypal_gateway_404_payment_id') do
      result = subject.call(
        payment_id: 'test_404_payment_id',
        payer_id: nil,
      )
      expect(result.success?).to eq false
      expect(result.payment_id).to eq 'test_404_payment_id'
      expect(result.amount).to eq 0
      expect(result.currency).to eq 'JPY'
      # rubocop:disable LineLength
      expect(result.error_message).to eq 'Failed.  Response code = 404.  Response message = Not Found.  Response debug ID = 4e7953e75043e, 4e7953e75043e.'
    end
  end
end
