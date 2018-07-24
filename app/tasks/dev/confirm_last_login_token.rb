require './app/lib/lib'

repo = APP_DEPENDENCIES[:login_token_repository]

login_token = repo.last
login_token.confirm!
repo.save(login_token)
