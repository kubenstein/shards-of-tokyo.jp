require 'dry-container'
require 'require_all'
require './app/lib/auto_inject'

dependencies = Dry::Container.new.tap do |c|
  c.register(:user_repository, -> { SoT::UserRepository.new })
  c.register(:message_repository, -> { SoT::MessageRepository.new })
  c.register(:registration_validator, -> { SoT::Registration::Validator.new })
  c.register(:registration_workflow, -> { SoT::Registration::NewUserWorkflow.new })
  c.register(:mailer, -> { SoT::Mailer.new })
end

Import = AutoInject.new(dependencies)

require_all './app/lib'
