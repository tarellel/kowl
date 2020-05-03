# frozen_string_literal: true

# Used for Integration Testing (clearing sessions after test runs)
# https://stackoverflow.com/questions/7779963/integration-test-with-rspec-and-devise-sign-in-env
RSpec.configure do |config|
  config.include Warden::Test::Helpers
end
Warden.test_mode!
