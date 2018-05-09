require 'dry-container'
require 'require_all'
require './app/lib/auto_inject'

APP_DEPENDENCIES = Dry::Container.new.tap do |c|
  c.register(:session_secret, -> { ENV['SESSION_SECRET'] || 'session_secret' })
  c.register(:user_repository, -> { SoT::UserRepository.new })
  c.register(:message_repository, -> { SoT::MessageRepository.new })
  c.register(:registration_validator, -> { SoT::Registration::Validator.new })
  c.register(:registration_workflow, -> { SoT::Registration::NewUserWorkflow.new })

  if ENV['RACK_ENV'] == 'production'
    c.register(:event_store, -> { raise 'missing prod event_store!' })
    c.register(:state, -> {  raise 'missing prod state!' })
    c.register(:mailer, -> {
      SoT::Mailer.new(smtp_options: {
        domain: 'shards-of-tokyo.jp',
        address: 'smtp.sendgrid.net',
        port: 587,
        enable_starttls_auto: true,
        user_name: ENV['SENDGRID_USERNAME'],
        password: ENV['SENDGRID_PASSWORD'],
        authentication: :plain,
      })
    })
  else
    c.register(:event_store, -> { SoT::SqliteEventStore.new('./app/db/development.db') })
    c.register(:state, -> { SoT::MemoryState.new.tap { |state| c[:event_store].add_subscriber(state) } })
    c.register(:mailer, -> { SoT::Mailer.new })
  end
end

Import = AutoInject.new(APP_DEPENDENCIES)

require_all './app/lib'
