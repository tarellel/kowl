# frozen_string_literal: true

require 'rails/generators'
require_relative 'base'

# Database configurations
# https://api.rubyonrails.org/v5.1/classes/ActiveRecord/ConnectionAdapters/ConnectionPool.html
# https://devcenter.heroku.com/articles/concurrency-and-database-connections
module Kowl
  class DatabaseGenerator < Kowl::Generators::Base
    hide!
    source_root File.expand_path(File.join('..', 'templates'), File.dirname(__FILE__))
    class_option :database, type: :string, aliases: '-d', default: 'sqlite3'
    class_option :noauth, type: :boolean, default: false
    class_option :uuid, type: :boolean, default: false

    # Used to generate the config for automatically generating annotated models
    def setup_annotate
      generate('annotate:install')
    end

    # If the application is using postgresql this will add pghero to the application
    def setup_pghero
      return unless options[:database] == 'postgresql'

      generate('pghero:config') # generate PGhero config
      generate('pghero:query_stats') # generate pghero stats migrations
      generate('pghero:space_stats')
      add_to_assets('pghero/application.js pghero/application.css')
    end

    # Copy a base seef file to the application with sample users
    def copy_seed_file
      template('db/seeds.rb.tt', 'db/seeds.rb', force: true)
    end

    # Add frozen_string_literal to application_record.rb
    def make_ar_immutable
      inject_into_file('app/models/application_record.rb', "# frozen_string_literal: true\n\n", before: "class ApplicationRecord < ActiveRecord::Base\n")
    end
  end
end
