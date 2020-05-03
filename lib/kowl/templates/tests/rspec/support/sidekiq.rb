# frozen_string_literal: true

if defined?(Sidekiq)
  RSpec::Sidekiq.configure do |config|
    config.warn_when_jobs_not_processed_by_sidekiq = false
  end

  Sidekiq::Testing.inline!
  # Sidekiq::Logging.logger = nil
end