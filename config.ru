require './app/web/server'

ENV['RACK_ENV'] ||= 'development'

use WebServer
run Sinatra::Application
