# frozen_string_literal: true

# Used to generate a test coverage report
require 'simplecov'
SimpleCov.start do
  # Excluded, because in order to test it. It would have to a set of login requests
  add_filter 'app/controllers/users_controller.rb'
end
