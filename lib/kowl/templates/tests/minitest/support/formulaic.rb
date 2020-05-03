# frozen_string_literal: true

if defined?(Formulaic)
  class ActionDispatch::IntegrationTest
    include Capybara::DSL
    include Formulaic::Dsl
  end
end