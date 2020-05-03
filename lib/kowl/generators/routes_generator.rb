# frozen_string_literal: true

require 'rails/generators'
require_relative 'base'

module Kowl
  class RoutesGenerator < Kowl::Generators::Base
    hide!
    source_root File.expand_path(File.join('..', 'templates', 'config'), File.dirname(__FILE__))
    class_option :database, type: :string, default: 'sqlite3'
    class_option :noauth, type: :boolean, default: false
    class_option :skip_mailer, type: :boolean, default: false
    class_option :skip_sidekiq, type: :boolean, default: false

    # Generate the applications routes.rb file based on the applications options
    def setup_routes
      template('routes.rb.tt', 'config/routes.rb', force: true)
    end
  end
end
