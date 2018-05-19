require './app/lib/lib'

me = SoT::User.new(email: 'niewczas.jakub@gmail.com')
APP_DEPENDENCIES[:user_repository].create_user(user: me, requester_id: 'system@shards-of-tokyo.jp')
