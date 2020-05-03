# frozen_string_literal: true

require 'rails/generators'
require_relative 'base'

module Kowl
  class PagesGenerator < Kowl::Generators::Base
    hide!
    source_root File.expand_path(File.join('..', 'templates', 'app', 'views'), File.dirname(__FILE__))
    class_option :framework, type: :string, default: 'bootstrap', enum: %w[bootstrap semantic none]
    class_option :noauth, type: :boolean, default: false
    class_option :template_engine, type: :string, default: 'erb'

    # Generate a basic welcome page for the application
    def setup_welcome_page
      generate('controller Pages welcome --skip')

      # I don't want to skip or remove all tests created for pages, I just want to remove the generated controller test
      remove_file('spec/requests/pages_request_spec.rb')
    end

    def make_controller_immuatable
      inject_into_file 'app/controllers/pages_controller.rb', "# frozen_string_literal: true\n\n", before: "class PagesController < ApplicationController\n"
    end

    # Copy over a basic welcome page view dependant on the CSS framework and template engine specified for the application
    def copy_welcome_pages
      if %w[bootstrap semantic].include? options[:framework]
        copy_file "pages/welcome/#{options[:framework]}.html.#{options[:template_engine]}", "app/views/pages/welcome.html.#{options[:template_engine]}", force: true
      else
        copy_file "pages/welcome/default.html.#{options[:template_engine]}", "app/views/pages/welcome.html.#{options[:template_engine]}", force: true
      end
    end

    # Add a skip_before_action for the welcome page if authentication is being used with the application
    def disable_auth
      action_str = <<~STR
        # Allow pages to be displayed without requiring authentication
        skip_before_action :authenticate_user!

      STR

      inject_into_file 'app/controllers/pages_controller.rb', optimize_indentation(action_str, 2), after: "class PagesController < ApplicationController\n" unless options[:noauth]
    end
  end
end
