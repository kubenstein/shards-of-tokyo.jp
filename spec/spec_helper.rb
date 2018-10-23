# rubocop:disable Style/BlockDelimiters

require 'dry-container'
require 'require_all'
require './app/lib/auto_inject'

APP_COMPONENTS = Dry::Container.new.tap do |c|
  c.register(:stripe_api_keys, memoize: true) do
    {
      secret_key: 'dummy_secret_key',
      public_key: 'dummy_public_key',
    }
  end
  c.register(:logger, memoize: true) { Logger.new(IO::NULL) }
  c.register(:user_repository, memoize: true) { SoT::UserRepository.new }
  c.register(:order_repository, memoize: true) { SoT::OrderRepository.new }
  c.register(:login_token_repository, memoize: true) { SoT::LoginTokenRepository.new }
  c.register(:mailer, memoize: true) { SoT::Mailer.new }
  c.register(:i18n, memoize: true) { SoT::I18nProvider.new }
  c.register(:event_store, memoize: true) {
    SoT::SqlEventStore.new('sqlite:/').tap(&:configure)
  }
  c.register(:state, memoize: true) {
    SoT::SqlState.new('sqlite:/', c[:event_store], database_version: 1).tap(&:configure).tap(&:connect_to_event_store)
  }
end

Import = AutoInject.new(APP_COMPONENTS)

require_all(
  Dir.glob('./app/lib/**/*.rb').reject { |fname|
    fname.include?('lib.rb') || # dont load original lib with dep definitions
    fname.include?('spec.rb')
  },
)

# monkey patches

state = APP_COMPONENTS[:state]
def state.reset!
  @database_version += 1
  configure
end

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.before(:context) do
    state.reset!
  end
end