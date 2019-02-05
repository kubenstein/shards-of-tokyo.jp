require './app/lib/lib'

user_repo = APP_COMPONENTS[:user_repository]

puts 'create me user...'
user_repo.create(
  user_repo.new_user(email: SoT::User::ME_EMAIL),
)
