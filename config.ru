require './app/web/server'

ENV['RACK_ENV'] ||= 'development'

use Bugsnag::Rack unless ENV['RACK_ENV'] == 'development'
run WebServer
