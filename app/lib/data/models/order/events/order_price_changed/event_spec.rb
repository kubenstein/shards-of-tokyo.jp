describe SoT::OrderPriceChangedEvent do
  let(:state) { APP_COMPONENTS[:state] }
  let(:order_repo) { APP_COMPONENTS[:order_repository] }
  let(:user_repo) { APP_COMPONENTS[:user_repository] }
  let(:user) { user_repo.save(user_repo.new_user(email: 'test@test.pl')) }
  let(:order) { order_repo.save(order_repo.new_order(user: user)) }

  it 'creates proper order price changed event from altered order object' do
    order.set_price(Money.new(500, :jpy))
    event = subject.build(order, requester_id: 'price_changer_user')

    expect(event.name).to eq 'order_price_changed'
    expect(event.requester_id).to eq 'price_changer_user'
    expect(event.payload[:id]).to eq order.id
    expect(event.payload[:amount]).to eq 500
    expect(event.payload[:currency]).to eq 'JPY'
  end

  it 'handles the event by updating price of given order' do
    order.set_price(Money.new(500, :jpy))
    event = subject.build(order)

    expect {
      subject.handle(event, state)
    }.to change {
      state.get_resources(:orders, id: order.id)[0][:amount]
    }.to(500)
  end
end
