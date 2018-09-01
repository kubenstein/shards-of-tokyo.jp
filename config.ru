require './app/web/server'

ENV['RACK_ENV'] ||= 'development'

use Bugsnag::Rack
run WebServer
