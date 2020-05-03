# frozen_string_literal: true

require 'rails/generators'
require_relative 'base'

# This class is for setting up the bootstrap mailer when using bootstrap framework and devise
module Kowl
  class MailerGenerator < Kowl::Generators::Base
    hide!
    source_root File.expand_path(File.join('..', 'templates'), File.dirname(__FILE__))
    class_option :encrypt, type: :boolean, default: false
    class_option :mailer, type: :string, default: 'sparkpost', enum: %w[postmark sparkpost]
    class_option :noauth, type: :boolean, default: false

    # Add DeviseMailer layout view, to cleanup devise emails
    def copy_mailer_layouts
      copy_file('app/views/layouts/devise_mailer.html.erb', 'app/views/layouts/devise_mailer.html.erb') unless options[:noauth]
    end

    # Override the applications default application_mailer file with some basic config
    def override_application_mailer
      copy_file 'app/mailers/application_mailer.rb', 'app/mailers/application_mailer.rb', force: true
    end

    # Add a devise mailer layout the application if devise is to be used
    def copy_devise_mailer_config
      copy_file('app/mailers/devise_mailer.rb', 'app/mailers/devise_mailer.rb') unless options[:noauth]
    end

    # Add the applications assets that need to be compiled for the mailer
    def add_mailer_assets
      copy_file('app/assets/stylesheets/bootstrap/application-mailer.scss')
      add_to_assets('application-mailer.scss')
    end

    # Setup letter_opener config and initializer to catch emails in development
    def setup_letter_opener
      smtp_config = <<~LETTER_OPENER
        # Specify if you you have a preference which method you want SMTP responses to be handled in dev
        # config.action_mailer.delivery_method = :letter_opener
        config.action_mailer.delivery_method = :letter_opener_web
        config.action_mailer.perform_deliveries = true
        config.action_mailer.raise_delivery_errors = false
      LETTER_OPENER
      dev_config(smtp_config)
      copy_file('config/initializers/letter_opener.rb', 'config/initializers/letter_opener.rb')
    end

    # Setup a mailer initializer for production, based on the application config
    def setup_production_mailer
      if options[:mailer] == 'postmark'
        copy_file('config/initializers/postmark.rb', 'config/initializers/postmark.rb', force: true)
      else
        copy_file('config/initializers/sparkpost.rb', 'config/initializers/sparkpost.rb', force: true)
      end
    end
  end
end
