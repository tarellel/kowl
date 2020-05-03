# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  # The DEFAULT_EMAIL should be set in your .env file
  default from: ENV.fetch('DEFAULT_EMAIL'){ 'noreply@example.com' }
  layout 'mailer'
end