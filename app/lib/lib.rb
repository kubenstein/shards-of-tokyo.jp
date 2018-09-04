# rubocop:disable Style/BlockDelimiters, Metrics/BlockLength

require 'bugsnag'
require 'dry-container'
require 'require_all'
require './app/lib/auto_inject'

APP_DEPENDENCIES = Dry::Container.new.tap do |c|
  c.register(:stripe_api_keys, memoize: true) do
    {
      secret_key: ENV['STRIPE_API_SECRET_KEY'],
      public_key: ENV['STRIPE_API_PUBLIC_KEY'],
    }
  end
  c.register(:bugsnag_api_key, memoize: true) { ENV['BUGSNAG_API_KEY'] }
  c.register(:session_secret, memoize: true) { ENV['SESSION_SECRET'] || 'session_secret' }
  c.register(:user_repository, memoize: true) { SoT::UserRepository.new }
  c.register(:order_repository, memoize: true) { SoT::OrderRepository.new }
  c.register(:login_token_repository, memoize: true) { SoT::LoginTokenRepository.new }
  c.register(:register_user_workflow, memoize: true) { SoT::RegisterUser::Workflow.new }
  c.register(:add_order_message_workflow, memoize: true) { SoT::AddOrderMessage::Workflow.new }
  c.register(:submit_new_order_workflow, memoize: true) { SoT::SubmitNewOrder::Workflow.new }
  c.register(:login_user_step1_workflow, memoize: true) { SoT::LoginUserStep1::Workflow.new }
  c.register(:login_user_step2_workflow, memoize: true) { SoT::LoginUserStep2::Workflow.new }
  c.register(:login_user_step3_workflow, memoize: true) { SoT::LoginUserStep3::Workflow.new }
  c.register(:logout_user_workflow, memoize: true) { SoT::LogoutUser::Workflow.new }
  c.register(:set_order_price_workflow, memoize: true) { SoT::SetOrderPrice::Workflow.new }
  c.register(:pay_for_order_workflow, memoize: true) { SoT::PayForOrder::Workflow.new }
  c.register(:i18n, memoize: true) { SoT::I18nProvider.new }
  c.register(:event_store, memoize: true) { SoT::SqlEventStore.new(ENV['EVENTS_DATABASE_URL']) }
  c.register(:state, memoize: true) {
    SoT::SqlState.new(ENV['DATABASE_URL'], c[:event_store], database_version: ENV['HEROKU_RELEASE_VERSION'] || 'v0')
  }

  if ENV['RACK_ENV'] == 'production'
    c.register(:logger, memoize: true) { Logger.new(STDOUT).tap { |logger| logger.level = Logger::INFO } }
    c.register(:mailer, memoize: true) {
      SoT::Mailer.new(smtp_options: {
                        domain: 'shards-of-tokyo.jp',
                        address: 'smtp.sendgrid.net',
                        port: 587,
                        enable_starttls_auto: true,
                        user_name: ENV['SENDGRID_USERNAME'],
                        password: ENV['SENDGRID_PASSWORD'],
                        authentication: :plain,
                      })
    }
  else
    c.register(:logger, memoize: true) { Logger.new(STDOUT) }
    c.register(:mailer, memoize: true) { SoT::Mailer.new }
  end
end

Import = AutoInject.new(APP_DEPENDENCIES)

Bugsnag.configure { |config| config.api_key = APP_DEPENDENCIES[:bugsnag_api_key] }

require_all './app/lib'
