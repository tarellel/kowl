# frozen_string_literal: true

if defined?(Devise)
  ###
  # For testing devise_cas
  # https://github.com/nbudin/devise_cas_authenticatable/wiki/Testing
  class ActionController::TestCase
    # include Devise::TestHelpers
    include Devise::Test::ControllerHelpers
  end

  class ActionDispatch::IntegrationTest
    include Warden::Test::Helpers
    Warden.test_mode!
  end
end
