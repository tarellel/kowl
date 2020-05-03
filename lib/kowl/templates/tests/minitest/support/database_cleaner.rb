# frozen_string_literal: true

# https://github.com/DatabaseCleaner/database_cleaner
# https://medium.com/brief-stops/testing-with-rspec-factorygirl-faker-and-database-cleaner-651c71ca0688
# Flush the database during tests to keep test data from clustering or hitting other tests
require 'capybara/minitest'
require 'database_cleaner'

if defined?(DatabaseCleaner)
  DatabaseCleaner.clean_with :truncation
  DatabaseCleaner.strategy = :transaction

  class ActionDispatch::IntegrationTest
    include DatabaseCleanerSupport
  end

  class ActiveSupport::TestCase
    include DatabaseCleanerSupport
  end
end