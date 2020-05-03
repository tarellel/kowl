# frozen_string_literal: true

# dsl matchers for controllers, models, and views
# Add shoulda test helpers: https://matchers.shoulda.io/
require 'shoulda'
Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :minitest
    with.library :rails
  end
end
