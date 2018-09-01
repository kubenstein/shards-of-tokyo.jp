require './app/web/server'

ENV['RACK_ENV'] ||= 'development'

use Bugsnag::Rack
use WebServer
run Sinatra::Application
