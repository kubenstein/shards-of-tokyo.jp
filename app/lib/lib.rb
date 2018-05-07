require 'dry-container'
require 'require_all'
require './app/lib/auto_inject'

dependencies = Dry::Container.new.tap do |c|
  c.register(:user_repository, -> { SoT::UserRepository.new })
  c.register(:message_repository, -> { SoT::MessageRepository.new })
  c.register(:registration_validator, -> { SoT::Registration::Validator.new })
  c.register(:registration_workflow, -> { SoT::Registration::NewUserWorkflow.new })

  if ENV['RACK_ENV'] == 'production'
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
    c.register(:mailer, -> { SoT::Mailer.new })
  end
end

Import = AutoInject.new(dependencies)

require_all './app/lib'
