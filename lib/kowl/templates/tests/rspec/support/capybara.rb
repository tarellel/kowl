# frozen_string_literal: true

require 'capybara/rails'
require 'capybara/rspec'
require 'webdrivers'

# default capybara/selenium configuration
# https://github.com/itmammoth/capybara-bootstrap/blob/master/scrape.rb
# https://thoughtbot.com/blog/headless-feature-specs-with-chrome
# run as headless mode with set window size
Capybara.register_driver :headless_chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new(
    # Additional stuff is disabled to reduce the amount of memory required to execute the tests
    # no-sandbox is required to get it to run in docker
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
# https://gitlab.com/gitlab-org/gitlab-ce/blob/master/spec/support/capybara.rb
RSpec.configure do |config|
  # capybara/rspec already calls Capybara.reset_sessions! in an `after` hook,
  # but `block_and_wait_for_requests_complete` is called before it so by
  # calling it explicitly here, we prevent any new requests from being fired
  config.after(:each, :js) do
    # Clear sessions to remove logged in user from Capybara webdriver session
    Capybara.reset_sessions!
    block_and_wait_for_requests_complete
  end
end
