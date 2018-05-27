require './app/lib/lib'

user_repo = APP_DEPENDENCIES[:user_repository]

me = user_repo.new_user(email: 'niewczas.jakub@gmail.com')
user_repo.create(me)
