# frozen_string_literal: true

require 'rails/generators'
require_relative 'base'

module Kowl
  class ConfigGenerator < Kowl::Generators::Base
    hide!
    source_root File.expand_path(File.join('..', 'templates', 'config', 'initializers'), File.dirname(__FILE__))
    class_option :database, type: :string, default: 'sqlite3'
    class_option :encrypt, type: :boolean, default: false
    class_option :framework, type: :string, default: 'bootstrap', enum: %w[bootstrap semantic none]
    class_option :noauth, type: :boolean, default: false
    class_option :skip_docker, type: :boolean, default: false
    class_option :skip_erd, type: :boolean, default: false
    class_option :skip_pagination, type: :boolean, default: false
    class_option :skip_sidekiq, type: :boolean, default: false
    class_option :skip_tests, type: :boolean, default: false
    class_option :simpleform, type: :boolean, default: false
    class_option :template_engine, type: :string, default: 'erb', enum: %w[erb slim haml]
    class_option :test_engine, type: :string, default: 'rspec', enum: %w[minitest rspec none]
    class_option :uuid, type: :boolean, default: false

    # Generate simpleform config early, so rails generators don't output a ton of simpleform garbage everytime a generator is ran
    def setup_simpleform
      return unless options[:simpleform]

      case options[:framework]
      when 'bootstrap'
        generate 'simple_form:install', '--bootstrap', '--force'
      when 'semantic'
        copy_file 'simpleform/semantic.rb', 'config/initializers/simple_form.rb', force: true
      else
        generate 'simple_form:install', '--force'
      end
    end

    # Generate application initializer for devise
    def copy_devise_config
      # Encrypt devise passwords using Argon for better password security
      copy_file 'devise_argon2.rb', 'config/initializers/devise_argon2.rb' unless options[:noauth]
    end

    # Setup autoprefixer basic configuration
    def copy_autoprefixer
      copy_file '../autoprefixer.yml', 'config/autoprefixer.yml', force: true
    end

    # Generate application initializer for faker/applicatiton tests
    def copy_faker_config
      copy_file('faker.rb', 'config/initializers/faker.rb', force: true) unless options[:skip_tests]
    end

    # Generate application initializer for geocoder
    def copy_geocoder_config
      return nil if options[:noauth]

      copy_file('geocoder.rb', 'config/initializers/geocoder.rb')
      GeoDB.perform(Rails.root)
    end

    # Generate several application initializers to cleanup to make the application easier to manage
    def copy_initializers
      files = %w[bullet logging lograge oj sass]
      files.push('slim') if options['template_engine'] == 'slim'

      files.map { |file| copy_file "#{file}.rb", "config/initializers/#{file}.rb" }
    end

    # Generate initializers for rack_attack depending on the applications requirements (devise, sidekiq, etc)
    def copy_rack_attack
      # it's a template because it has routes that may not be used if --noauth is specified
      template('rack_attack.rb.tt', 'config/initializers/rack_attack.rb')
    end

    # Generatet initializer for pagy if pagination will be used in the application
    def copy_pagy_config
      template('pagy.rb.tt', 'config/initializers/pagy.rb', force: true) unless options[:skip_pagination]
    end

    # Generaet version file used for docker application versioning and deployment
    def create_version_file
      create_file('.version', '0.0.1')
    end

    # Setup Rack::Timeout using slowpoke, in order to kill slow requests
    def setup_slowpoke
      generate('slowpoke:install')
    end

    # This sets the production log_level to info, by default all environments have a log_level of debug.
    # And this can be dangerous when your application logs are collecting user params and showing Mailers within the logs
    # https://guides.rubyonrails.org/debugging_rails_applications.html#log-levels
    def set_production_loglevel
      inject_into_file('config/environments/production.rb', '  #   ', before: "  config.log_level = :debug\n")
      inject_into_file('config/environments/production.rb', "\n  config.log_level = :info\n", after: 'config.log_level = :debug')
    end

    # Generates additional config the appliations config/application.rb file based on the current options (test_engine, template_engine, etc.)
    def application_config
      # Moves generating of default stylesheets and set sthe default timezone
      # => add configuration to config/application.rb
      # => https://apidock.com/rails/Rails/Generators
      sidekiq_config = (options[:skip_sidekiq] ? '' : 'config.active_job.queue_adapter = :sidekiq')
      cache_storage_config = (options[:skip_sidekiq] ? 'config.cache_store = :mem_cache_store' : "config.cache_storage = :redis_cache_store, { driver: :hiredis, url: ENV.fetch('REDIS_URL'){ 'redis://localhost:6379/0' } }")
      app_config = <<-CONFIG
        # Set the applications timezone
        config.time_zone = 'UTC'
        config.active_record.default_timezone = :local
        #{sidekiq_config}
        #{cache_storage_config}

        #{options[:skip_docker] ? '' : "# If you change this to use imagemagick, you'll need to update your Dockerfile as well"}
        # => https://api.rubyonrails.org/classes/ActiveStorage/Variant.html
        config.active_storage.variant_processor = :vips
      CONFIG
      insert_into_file 'config/application.rb', optimize_indentation(app_config, 4), after: /\s?config.load_defaults\s(\d\S\d)\n/
    end

    # Generate initializer for the applications generator config
    def generate_generators_config
      template 'generators.rb.tt', 'config/initializers/generators.rb', force: true
    end

    # Generate initializer for application middleware
    def setup_middleware_config
      copy_file 'middleware.rb', 'config/initializers/middleware.rb', force: true
    end

    # Run the ERD generator, so the application will generate a new ERB when migrations are added/modified
    def setup_erd
      return nil if options[:skip_erd]

      generate('erd:install')
    end

    ##############################
    # Securtiy Config
    ##############################

    # If wanting to encrypt database attributes, generate lockbox initializer
    def copy_lockbox_config
      # Lockbox will be used to secure sensative data attributes throughout the application
      # => https://github.com/ankane/lockbox
      copy_file('lockbox.rb', 'config/initializers/lockbox.rb') if options[:encrypt]
    end

    # Generate a logstop application initializer
    # To filter out sensative parameteres before they are passed to the applications logs
    def copy_logstop_config
      copy_file 'logstop.rb', 'config/initializers/logstop.rb'
    end

    # Add additional parameters to be filtered from logs
    def add_filtered_parameters
      append_to_file('config/initializers/filter_parameter_logging.rb', 'Rails.application.config.filter_parameters += %i[email ip]')
    end

    # Setup a basic CORS policy for application JS interactions
    def setup_cors
      cors_str = <<~CORS
        Rails.application.config.content_security_policy do |policy|
          if Rails.env.development?
            policy.script_src :self, :https, :unsafe_eval

            policy.connect_src :self, :https, 'http://localhost:3000', 'ws://localhost:3000', 'http://localhost:3000', 'ws://localhost:3000'
          else
            policy.script_src :self, :https
          end
        end
      CORS
      append_to_file('config/initializers/content_security_policy.rb', cors_str)
    end
  end
end
