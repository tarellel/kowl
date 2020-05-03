# frozen_string_literal: true

# dsl matchers for controllers, models, and views
require 'shoulda'
Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
