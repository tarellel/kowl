# frozen_string_literal: true

require 'capybara/rails'
require 'capybara/minitest'
require 'webdrivers'
# Integration testing

# default capybara/selenium configuration
# https://github.com/itmammoth/capybara-bootstrap/blob/master/scrape.rb
# https://thoughtbot.com/blog/headless-feature-specs-with-chrome
# run as headless mode with set window size
Capybara.register_driver :headless_chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new(
    args: %w[headless disable-extensions disable-gpu disable-infobars disable-translate no-sandbox window-size=1280,800]
  )
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

Capybara.javascript_driver = :headless_chrome
Capybara.configure do |config|
  config.default_max_wait_time = 5 # seconds
  config.default_driver = :headless_chrome
end

# used for Integration Testing
class ActionDispatch::IntegrationTest
  # Make the Capybara DSL available in all integration tests
  include Capybara::DSL
  # Make `assert_*` methods behave like Minitest assertions
  include Capybara::Minitest::Assertions

  # Reset sessions and driver between tests
  # Use super wherever this method is redefined in your individual test classes
  def teardown
    Capybara.reset_sessions!
    Capybara.use_default_driver
  end
end
