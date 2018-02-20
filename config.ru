require './app/app'

ENV['RACK_ENV'] ||= 'development'

use App
run Sinatra::Application
