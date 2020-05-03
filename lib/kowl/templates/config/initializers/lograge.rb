# frozen_string_literal: true

if defined?(Lograge)
  Rails.application.configure do
    config.lograge.enabled = true
  end
end
