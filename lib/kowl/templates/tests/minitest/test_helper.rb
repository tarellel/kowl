# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
require 'minitest/reporters'
Minitest::Reporters.use!

# load test engines and set their configurations
Dir[Rails.root.join('test/support/**/*.rb')].each { |f| require f }

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Add more helper methods to be used by all tests here...
end
