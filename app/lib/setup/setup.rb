require 'bugsnag'
require 'money'
require './app/lib/setup/polyfills'

Bugsnag.configure do |config|
  config.api_key = APP_COMPONENTS[:bugsnag_api_key]
end

Money.locale_backend = :i18n

I18n.config.available_locales = :en
