require 'dry-container'
require 'require_all'
require './app/lib/auto_inject'

APP_DEPENDENCIES = Dry::Container.new.tap do |c|
  c.register(:stripe_api_keys, memoize: true) {{
    secret_key: ENV['STRIPE_API_SECRET_KEY'] || 'sk_test_z2aoTikjCm0urBhNoMEzhtZr',
    public_key: ENV['STRIPE_API_PUBLIC_KEY'] || 'pk_test_RbiERyephGoRFvc2q1nPrlKe',
  }}
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

  if ENV['RACK_ENV'] == 'production'
    c.register(:event_store, memoize: true) { SoT::SqlEventStore.new(ENV['DATABASE_URL']) }
    c.register(:state, memoize: true) { SoT::SqlState.new(ENV['DATABASE_URL'], c[:event_store], database_version: ENV['HEROKU_RELEASE_VERSION']) }
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
    c.register(:event_store, memoize: true) { SoT::SqlEventStore.new('sqlite://./app/db/events.db') }
    c.register(:state, memoize: true) { SoT::SqlState.new('sqlite://./app/db/state.db', c[:event_store], database_version: 'dev') }
    c.register(:mailer, memoize: true) { SoT::Mailer.new }
  end
end

Import = AutoInject.new(APP_DEPENDENCIES)

require_all './app/lib'
