# rubocop:disable Style/BlockDelimiters, Metrics/BlockLength

require 'dry-container'
require 'require_all'
require './app/lib/auto_inject'

APP_COMPONENTS = Dry::Container.new.tap do |c|
  c.register(:bugsnag_api_key, memoize: true) { ENV['BUGSNAG_API_KEY'] }
  c.register(:session_secret, memoize: true) { ENV['SESSION_SECRET'] || 'session_secret' }
  c.register(:user_repository, memoize: true) { SoT::UserRepository.new }
  c.register(:order_repository, memoize: true) { SoT::OrderRepository.new }
  c.register(:login_token_repository, memoize: true) { SoT::LoginTokenRepository.new }
  c.register(:register_user_workflow, memoize: true) { SoT::RegisterUser::Workflow.new }
  c.register(:add_order_message_workflow, memoize: true) { SoT::AddOrderMessage::Workflow.new }
  c.register(:submit_new_order_workflow, memoize: true) { SoT::SubmitNewOrder::Workflow.new }
  c.register(:login_user_step1_send_token_workflow, memoize: true) { SoT::LoginUserStep1SendToken::Workflow.new }
  c.register(:login_user_step2_confirm_token_workflow, memoize: true) { SoT::LoginUserStep2ConfirmToken::Workflow.new }
  c.register(:login_user_step3_check_token_workflow, memoize: true) { SoT::LoginUserStep3CheckToken::Workflow.new }
  c.register(:logout_user_workflow, memoize: true) { SoT::LogoutUser::Workflow.new }
  c.register(:set_order_price_workflow, memoize: true) { SoT::SetOrderPrice::Workflow.new }
  c.register(:dotpay_step2_receive_payment_workflow, memoize: true) { SoT::DotpayStep2ReceivePayment::Workflow.new }
  c.register(:i18n, memoize: true) { SoT::I18nProvider.new }
  c.register(:event_store, memoize: true) {
    SoT::SqlEventStore.new(ENV['EVENTS_DATABASE_URL'] || ENV['JAWSDB_MARIA_URL'])
  }
  c.register(:state, memoize: true) {
    SoT::SqlState.new(ENV['DATABASE_URL'], c[:event_store], database_version: ENV['HEROKU_RELEASE_VERSION'] || 'v0')
  }

  if ENV['RACK_ENV'] == 'production'
    c.register(:logger, memoize: true) { Logger.new(STDOUT).tap { |logger| logger.level = Logger::INFO } }
    c.register(:mailer, memoize: true) {
      SoT::Mailer.new(
        server_base_url: ENV['SERVER_BASE_URL'],
        smtp_options: {
          domain: 'shards-of-tokyo.jp',
          address: 'smtp.sendgrid.net',
          port: 587,
          enable_starttls_auto: true,
          user_name: ENV['SENDGRID_USERNAME'],
          password: ENV['SENDGRID_PASSWORD'],
          authentication: :plain,
        },
      )
    }
    c.register(:dotpay_step1_generate_form_workflow, memoize: true) {
      SoT::DotpayStep1GenerateForm::Workflow.new(
        dotpay_id: ENV['DOTPAY_ID'],
        dotpay_pin: ENV['DOTPAY_PIN'],
        server_base_url: ENV['SERVER_BASE_URL'],
      )
    }
  else
    c.register(:logger, memoize: true) { Logger.new(STDOUT) }
    c.register(:mailer, memoize: true) { SoT::Mailer.new(server_base_url: ENV['SERVER_BASE_URL']) }
    c.register(:dotpay_step1_generate_form_workflow, memoize: true) {
      SoT::DotpayStep1GenerateForm::Workflow.new(
        env: :dev,
        dotpay_id: ENV['DOTPAY_ID'],
        dotpay_pin: ENV['DOTPAY_PIN'],
        server_base_url: ENV['SERVER_BASE_URL'],
      )
    }
  end
end

Import = AutoInject.new(APP_COMPONENTS)

require_all(
  ['./app/lib/setup/setup'] +
  Dir.glob('./app/lib/**/*.rb').reject { |fname| fname.include?('spec.rb') },
)
