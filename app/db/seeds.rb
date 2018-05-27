require './app/lib/lib'

user_repo = APP_DEPENDENCIES[:user_repository]
order_repo = APP_DEPENDENCIES[:order_repository]

puts "create users..."
me = user_repo.new_user(email: 'niewczas.jakub@gmail.com')
jon = user_repo.new_user(email: 'snow.jon@gmail.com')
user_repo.create(me)
user_repo.create(jon)

puts "create orders..."
order = order_repo.new_order(user_id: jon.id)
order.add_message(text: 'Winter is coming.. Can I have a kotatsu please?')
order.add_message(text: 'Sure!', answer: true)
order_repo.create(order)
