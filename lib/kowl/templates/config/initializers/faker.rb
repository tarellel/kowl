# frozen_string_literal: true

# Set locale as en-US for generating US styled addresses and phone numbers
if defined?(Faker)
  Faker::Config.locale = 'en-US'
end
