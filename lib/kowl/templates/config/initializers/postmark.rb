# frozen_string_literal: true

if Rails.env.production?
  Rails.application.config do |c|
    config.action_mailer.delivery_method = :postmark
    config.action_mailer.postmark_settings = { api_token: ENV['POSTMARK_API_TOKEN'] }
  end
end