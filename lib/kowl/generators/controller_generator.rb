# frozen_string_literal: true

require 'rails/generators'
require_relative 'base'

module Kowl
  class ControllerGenerator < Kowl::Generators::Base
    hide!
    source_root File.expand_path(File.join('..', 'templates', 'app', 'controllers'), File.dirname(__FILE__))
    class_option :noauth, type: :boolean, default: false

    # Add application_controller callbacks depending on if the application requires user auth or not
    def app_controller_auth
      if options[:noauth]
        app_str = <<~APP
          protect_from_forgery with: :exception
          include ErrorHandlers     # Application fallbacks
          helper :all
        APP
        inject_into_file 'app/controllers/application_controller.rb', optimize_indentation(app_str, 2), after: "class ApplicationController < ActionController::Base\n"
        copy_file('concerns/noauth/error_handlers.rb', 'app/controllers/concerns/error_handlers.rb')
      else
        app_str = <<~APP
          protect_from_forgery with: :exception
          before_action :authenticate_user!
          impersonates :user

          include Authentication    # Devise/Authentication stuff
          include Authorization     # To determine if a user is authorized to do a specific action
          include ErrorHandlers     # Application fallbacks
          helper :all
        APP

        inject_into_file 'app/controllers/application_controller.rb', optimize_indentation(app_str, 2), after: "class ApplicationController < ActionController::Base\n"
        directory 'concerns/auth', 'app/controllers/concerns', force: true
      end
    end

    def make_controller_immuatable
      inject_into_file 'app/controllers/application_controller.rb', "# frozen_string_literal: true\n\n", before: "class ApplicationController < ActionController::Base\n"
    end

    # This allows the application to dynamically assign the mail delivery host when running in development and staging
    def set_default_url_options
      mailer_str = <<~MAILER_STR
        before_action :mailer_set_url_options unless Rails.env.production?

        private

        def mailer_set_url_options
          ActionMailer::Base.default_url_options[:host] = request.host_with_port
        end
      MAILER_STR
      inject_into_file 'app/controllers/application_controller.rb', optimize_indentation(mailer_str, 2), after: "helper :all\n"
    end

    # Enable additional flash_types to the application_controller
    def enable_additional_flash_types
      flash_str = "add_flash_types :success, :error # Enable additional flash types across the application\n"

      inject_into_file 'app/controllers/application_controller.rb', optimize_indentation(flash_str, 2), after: "class ApplicationController < ActionController::Base\n"
    end
  end
end
