describe SoT::OrderRepository do
  let(:user_repo) { APP_DEPENDENCIES[:user_repository] }
  let(:user) { user_repo.save(user_repo.new_user(email: 'test@test.pl')) }

  it 'creates new order' do
    order = subject.new_order(user: user)

    expect(order.user).to eq user
    expect(order.price).to eq nil
    expect(order.currency).to eq nil

    last_event = order.instance_variable_get(:@_uncommited_events).last
    expect(last_event.name).to eq 'order_created'
  end

  it 'saves order' do
    order = subject.new_order(user: user)

    expect {
      subject.save(order)
    }.to change { subject.find(order.id) }.from(nil).to(order)
  end

  it 'checks if an order exists' do
    order = subject.save(subject.new_order(user: user))

    expect(subject.exists?(id: order.id)).to eq true
    expect(subject.exists?(id: '404')).to eq false
  end

  describe 'finders' do
    let(:other_user) { user_repo.save(user_repo.new_user(email: 'test2@test.pl')) }
    let(:order1) { subject.save(subject.new_order(user: user)) }
    let(:order2) { subject.save(subject.new_order(user: user)) }
    let(:other_user_order) { subject.save(subject.new_order(user: other_user)) }

    before(:each) do
      APP_DEPENDENCIES[:state].reset!
    end

    it 'finds an order' do
      order1
      order2
      expect(subject.find(order1.id)).to eq order1
    end

    it 'finds an order (and order has payments and messages fully populated)' do
      order1.add_message(text: 'message1', from_user: user)
      order1.add_message(text: 'message2', from_user: user)
      order1.add_successful_payment(payment_id: 'payment_id1', amount: 100, currency: 'usd')
      subject.save(order1)

      found_order = subject.find(order1.id)
      expect(found_order.id).to eq order1.id
      expect(found_order.messages.count).to eq 2
      expect(found_order.messages[0].body).to eq 'message1'
      expect(found_order.payments.count).to eq 1
      expect(found_order.payments[0].payment_id).to eq 'payment_id1'
    end

    it 'finds orders for a user sorted by creatin date first (and orders have payments and messages fully populated)' do
      other_user_order
      order1

      order2.add_message(text: 'message1', from_user: user)
      order2.add_message(text: 'message2', from_user: user)
      order2.add_successful_payment(payment_id: 'payment_id1', amount: 100, currency: 'usd')
      subject.save(order2)

      found_orders = subject.for_user_newest_first(user.id)
      newest_order = found_orders[0]

      expect(found_orders.count).to eq 2
      expect(newest_order.id).to eq order2.id
      expect(newest_order.messages.count).to eq 2
      expect(newest_order.messages[0].body).to eq 'message1'
      expect(newest_order.payments.count).to eq 1
      expect(newest_order.payments[0].payment_id).to eq 'payment_id1'
    end
  end
end
