# frozen_string_literal: true

if defined?(Formulaic)
  require 'formulaic'
  RSpec.configure do |config|
    config.include Formulaic::Dsl, type: :feature
  end
end
