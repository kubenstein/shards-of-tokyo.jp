describe SoT::Message do
  let(:user_repo) { APP_DEPENDENCIES[:user_repository] }
  let(:order_repo) { APP_DEPENDENCIES[:order_repository] }

  let(:order) { order_repo.save(order_repo.new_order(user: user)) }
  let(:user) { user_repo.save(user_repo.new_user(email: 'test@test.pl')) }
  let(:other_user) { user_repo.save(user_repo.new_user(email: 'test2@test.pl')) }

  it 'returns if its from owner of the order or if its an answer' do
    message_order_owner = SoT::Message.new(id: 'id', user: user, order: order, body: 'message', created_at: Time.now)
    message_answer = SoT::Message.new(id: 'id', user: other_user, order: order, body: 'answer', created_at: Time.now)

    expect(message_order_owner.from_user?).to eq true
    expect(message_answer.from_user?).to eq false
  end
end
