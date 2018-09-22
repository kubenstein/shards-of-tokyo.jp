RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
  config.shared_context_metadata_behavior = :apply_to_host_groups
end

require 'dry-container'
require 'require_all'
require './app/lib/auto_inject'

APP_DEPENDENCIES = Dry::Container.new.tap do |c|
end

Import = AutoInject.new(APP_DEPENDENCIES)

require_all(
  Dir.glob('./app/lib/**/*.rb').reject { |fname| fname.include?('lib.rb') || fname.include?('spec.rb') },
)
