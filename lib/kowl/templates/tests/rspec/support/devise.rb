# frozen_string_literal: true

# https://github.com/plataformatec/devise/wiki/How-To:-Test-controllers-with-Rails-(and-RSpec)
# https://github.com/plataformatec/devise/wiki/How-To:-sign-in-and-out-a-user-in-Request-type-specs-(specs-tagged-with-type:-:request)
# https://github.com/wardencommunity/warden/wiki/Testing
if defined?(Devise)
  require 'devise'
  # To enable usage of devise test function login_as
  RSpec.configure do |config|
    # For Devise > 4.1.1
    config.include Devise::Test::ControllerHelpers, type: :controller
    config.include Devise::Test::ControllerHelpers, type: :view
    # Use the following instead if you are on Devise <= 4.1.1
    # config.include Devise::TestHelpers, :type => :controller

    # Integration tests
    # config.include Devise::Test::IntegrationHelpers, type: :feature
    # config.include Devise::Test::IntegrationHelpers, type: :request
    config.include Devise::Test::IntegrationHelpers
  end
end
