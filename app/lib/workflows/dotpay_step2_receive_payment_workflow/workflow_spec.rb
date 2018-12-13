describe SoT::DotpayStep2ReceivePayment::Workflow do
  let(:state) { APP_COMPONENTS[:state] }
  let(:user_repo) { APP_COMPONENTS[:user_repository] }
  let(:order_repo) { APP_COMPONENTS[:order_repository] }
  let(:user) { user_repo.save(user_repo.new_user(email: 'user@test.pl')) }
  subject { described_class.new(dotpay_pin: 'n7qmQIld75d09smyE7XZcIOPxiyOsdqN') }

  before(:each) do
    allow_any_instance_of(SoT::GenerateId).to receive(:call).and_return('f24c167db9')
    order_repo.save(order_repo.new_order(user: user, price: Monetize.parse('USD 40.00')))
  end

  after(:each) do
    state.reset!
  end

  describe 'on success' do
    let(:webhook_params) {
      {
        operation_status: 'completed',
        operation_currency: 'PLN',
        email: 'niewczas.jakub@gmail.com',
        p_email: 'niewczas.jakub@gmail.com',
        operation_amount: '146.27',
        p_info: 'Test User (niewczas.jakub@gmail.com)',
        description: 'SHARDS OF TOKYO PAYMENT FOR ORDER: f24c167db9',
        operation_original_currency: 'USD',
        signature: '63fcc8857abddc76d28c8135d02366cbe4b05097aa5cab9f4fe858d031c49969',
        operation_datetime: '2018-12-12 15:55:46',
        id: '775643',
        operation_number: 'M9945-83051',
        operation_type: 'payment',
        channel: '248',
        operation_original_amount: '40.00',
        control: 'f24c167db9',
      }
    }
    let(:params) { webhook_params.tap { |p| p[:ip] = '195.150.9.37' } }

    it 'handles webhook from dotpay' do
      result = subject.call(params)

      expect(result.success?).to eq true
      expect(result.order_id).to eq 'f24c167db9'
    end

    it 'adds success payment' do
      expect {
        subject.call(params)
      }.to change {
        state.get_resources(:payments).count
      }.by(1)

      order = order_repo.find('f24c167db9')
      payment = order.payments.first

      expect(payment.successful?).to eq true
      expect(payment.payment_id).to eq 'M9945-83051'
      expect(payment.price).to eq Monetize.parse('USD 40.00')
    end

    it 'adds success message' do
      expect {
        subject.call(params)
      }.to change {
        state.get_resources(:messages).count
      }.by(1)

      order = order_repo.find('f24c167db9')
      expect(order.messages.first.body).to eq 'PAYMENT NOTIFICATION: succesfully paid $40.00. Thank you!'
    end

    it 'sends email to a user' do
      expect {
        subject.call(params)
      }.to change {
        Mail::TestMailer
          .deliveries
          .select { |mail| mail.to.include?('user@test.pl') }
          .count
      }.by(1)
    end

    it 'sends email to me' do
      expect {
        subject.call(params)
      }.to change {
        Mail::TestMailer
          .deliveries
          .select { |mail| mail.to.include?(SoT::User::ME_EMAIL) }
          .count
      }.by(1)
    end
  end

  describe 'on fail' do
    let(:webhook_params) {
      {
        id: '775643',
        operation_number: 'M9912-67696',
        operation_type: 'payment',
        operation_status: 'rejected',
        operation_amount: '3.66',
        operation_currency: 'PLN',
        operation_original_amount: '40.00',
        operation_original_currency: 'USD',
        operation_datetime: '2018-12-13 15:19:28',
        control: 'f24c167db9',
        description: 'SHARDS OF TOKYO PAYMENT FOR ORDER%3A f24c167db9',
        email: 'niewczas.jakub@gmail.com',
        p_info: 'Test User (niewczas.jakub@gmail.com)',
        p_email: 'niewczas.jakub@gmail.com',
        channel: '248',
        signature: '4f56a33b0f181cdd3a80b621da4c4ff911492f60f2ee27b999c95a4feb700db1',
      }
    }
    let(:params) { webhook_params.tap { |p| p[:ip] = '195.150.9.37' } }

    it 'handles webhook from dotpay' do
      result = subject.call(params)

      expect(result.success?).to eq false
      expect(result.order_id).to eq 'f24c167db9'
    end

    it 'adds failed payment' do
      expect {
        subject.call(params)
      }.to change {
        state.get_resources(:payments).count
      }.by(1)

      order = order_repo.find('f24c167db9')
      payment = order.payments.first
      expect(payment.successful?).to eq false
      expect(payment.payment_id).to eq 'M9912-67696'
      expect(payment.price).to eq Monetize.parse('USD 40.00')
    end

    it 'adds failed message' do
      expect {
        subject.call(params)
      }.to change {
        state.get_resources(:messages).count
      }.by(1)

      order = order_repo.find('f24c167db9')
      expect(order.messages.first.body).to eq 'PAYMENT NOTIFICATION: error while paying.'
    end

    it 'sends email to me' do
      expect {
        subject.call(params)
      }.to change {
        Mail::TestMailer
          .deliveries
          .select { |mail| mail.to.include?(SoT::User::ME_EMAIL) }
          .count
      }.by(1)
    end
  end

  describe 'on unexpected things' do
    let(:webhook_params) {
      {
        random_unexpected_things: 'goof',
      }
    }
    let(:params) { webhook_params.tap { |p| p[:ip] = '195.150.9.37' } }

    it 'handles webhook from dotpay' do
      result = subject.call(params)

      expect(result.success?).to eq false
    end

    it 'sends email to me' do
      expect {
        subject.call(params)
      }.to change {
        Mail::TestMailer
          .deliveries
          .select { |mail| mail.to.include?(SoT::User::ME_EMAIL) }
          .count
      }.by(1)
    end
  end
end
