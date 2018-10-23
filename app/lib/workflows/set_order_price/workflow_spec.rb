describe SoT::SetOrderPrice::Workflow do
  let(:user_repo) { APP_COMPONENTS[:user_repository] }
  let(:order_repo) { APP_COMPONENTS[:order_repository] }
  let(:user) { user_repo.save(user_repo.new_user(email: 'test@test.pl')) }
  let!(:order) { order_repo.save(order_repo.new_order(user: user)) }

  it 'sets price of an order' do
    expect {
      subject.call(order_id: order.id, requester: user, price: Money.new(100, :usd))
    }.to change {
      order_repo.find(order.id).price
    }.to(Money.new(100, :usd))
  end

  it 'returns successful result if all is good' do
    result = subject.call(order_id: order.id, requester: user, price: Money.new(100, :usd))
    expect(result.order).to eq order
    expect(result.success?).to eq true
  end

  it 'returns unsuccessful result if there are some errors' do
    result = subject.call(order_id: '404', requester: user, price: Money.new(100, :usd))
    expect(result.success?).to eq false
    expect(result.errors).to eq [:order_not_found]
  end
end
