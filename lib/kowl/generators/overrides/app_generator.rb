# frozen_string_literal: true

require 'rails/generators'
require 'rails/generators/rails/app/app_generator'
require_relative('../../actions')
require_relative('../../docker')
# https://github.com/rails/rails/blob/master/railties/lib/rails/generators/rails/app/app_generator.rb
# https://apidock.com/rails/Rails/Generators/AppGenerator
# https://www.rubydoc.info/gems/railties/5.0.0/Rails/Generators/AppGenerator#finish_template-instance_method
# https://doc.bccnsoft.com/docs/rails_3_2_22_api/classes/Rails/Generators/AppBase.html
# https://github.com/rails/rails/blob/master/guides/source/generators.md
# List of default rails options -> https://github.com/rails/rails/blob/master/railties/lib/rails/generators/app_base.rb#L27
module Kowl
  module Overrides
    class AppGenerator < Rails::Generators::AppGenerator
      include Kowl::Actions
      include Kowl::Docker
      hide!
      desc 'A gem for generating Rails applications and still be a step ahead'
      ##################################################
      # Options that accept parameters
      ##################################################
      class_option :database,           type: :string, aliases: '-d', default: 'sqlite3',
                                        desc: "Preconfigure for selected database (options: #{DATABASES.join('/')})"

      class_option :framework,          type: :string, default: 'bootstrap', enum: %w[bootstrap semantic none],
                                        desc: 'Generate the application using a specific CSS Framework'

      class_option :git_repo,           type: :string, default: '',
                                        desc: 'The remote git repo in which you would like to associate with.'

      class_option :mailer,             type: :string, default: 'sparkpost', enum: %w[postmark sparkpost],
                                        desc: "Which transactional mailer you'd prefer your application to use."

      class_option :template_engine,    type: :string, default: 'erb', enum: %w[erb slim haml],
                                        desc: 'The template_engine to use for generating the applications views (Erb, Slim, HAML)'

      class_option :test_engine,        type: :string, default: 'rspec', enum: %w[minitest rspec none],
                                        desc: 'Which test framework would you like to use with the application'

      ##################################################
      # Options that are boolean and true if the flag is used
      ##################################################
      class_option :docker_distro,      type: :string, default: 'alpine', enum: %w[alpine debian],
                                        desc: 'Specify if you want your Docker base image to use Alpine or Debian'

      class_option :encrypt,            type: :boolean, default: false,
                                        desc: 'Do you want user attribues encrypted? (For GDPR compliance, but breaks LIKE queries)'

      class_option :noauth,             type: :boolean, default: false,
                                        desc: 'Skip adding Devise authentication to the application'

      class_option :simpleform,         type: :boolean, default: false,
                                        desc: 'Do you want your application to use simpleform to generate forms'

      class_option :skip_docker,        type: :boolean, default: false,
                                        desc: 'Skip adding basic Dockerfiles to the application'

      class_option :skip_erd,           type: :boolean, default: false,
                                        desc: 'Skip adding the ERD components to the application'

      class_option :skip_git,           type: :boolean, default: false, aliases: '-G',
                                        desc: 'Skip commiting the project to a git repo'

      class_option :skip_javascript,    type: :boolean, default: false,
                                        desc: 'Skip adding javascript assets to the template'

      class_option :skip_mailer,        type: :boolean, default: false,
                                        desc: 'Skip setting up rails SMTP mailer'

      class_option :skip_pagination,    type: :boolean, default: false,
                                        desc: 'Do you want to application to skip adding pagination to the views?'

      class_option :skip_pry,           type: :boolean, default: false,
                                        desc: 'Do you want your application to skip pass on using pry for the rails console?'

      class_option :skip_sidekiq,       type: :boolean, default: false,
                                        desc: 'Skip adding sidekiq to the rails application'

      class_option :skip_spring,        type: :boolean, default: false,
                                        desc: 'Do you want to skip'

      # Skipping tests is a dangerous behavior to practice
      class_option :skip_tests,         type: :boolean, default: false, aliases: '-T',
                                        desc: 'Determine if you would like to skip building tets for the application'

      class_option :skip_turbolinks,    type: :boolean, default: false,
                                        desc: 'Determine if you want to skip having turbolinks included in your application'

      # You'll want to set this as true, that way Oracle and/or SQLserver gems can be added to the gemfile
      # Otherwise you'll get exceptione errors from Psych and Rails causing `rails new` to fail
      class_option :skip_webpack_install, type: :boolean, default: true

      class_option :uuid,               type: :boolean, default: false,
                                        desc: 'If database is set as PostgreSQL and UUID is enabled, all primary keys will be generated as UUIDs'

      # If the person wants to use webpack in their application (vuew, react etc)
      WEBPACKS = %w[react vue angular elm stimulus].freeze
      class_option :webpack,            type: :string, default: nil, aliases: '-W',
                                        desc: "Preconfigure for app-like JavaScript with Webpack (options: #{WEBPACKS.join('/')})"

      ### RAILS OVERRIDES
      # Used to overwrite the the default rails behavior of bundling as soon as an application is generated
      # => Otherwise the application generator will also do a bundle install after a custom Gemfile has been generated
      class_option :skip_bundle,        type: :boolean, aliases: '-B', default: true,
                                        desc: "Don't set as true, this is a RAILS override to prevent extra bundle installs"

      # Used with Rails5 template, or if javascript isn
      # def finish_template
      #   invoke :kowl_run_generators
      #   # used to bundle install or run various bundle commands through the template
      #   super
      # end

      # Used with Rails6 v6, because this has the application generate.
      # => We want it after the applicaton config and assets are generated, otherwise it generates a large number of errors
      def run_after_bundle_callbacks
        super
        invoke :kowl_generators unless options[:skip_javascript]
      end

      ############################################################
      # Custom generator actions for processing of the template
      ############################################################

      # Begin calling all the Kowl application generators to override the default rails application based on the options supplied
      def kowl_generators
        build :replace_gemfile
        build :procfile
        bundle_command 'install --jobs=4 --retry=3 --quiet'
        bundle_command 'exec spring stop' unless options[:skip_spring]
        invoke :install_webpack_assets
        invoke :setup_staging # Ran afterwards webpack is setup for oracle, because it also createas a staging webpacker file

        generate("kowl:config --database=#{options[:database]} --encrypt=#{options[:encrypt]} --framework=#{options[:framework]} --noauth=#{options[:noauth]} --skip_docker=#{options[:skip_docker]} --skip_erd=#{options[:skip_erd]} --skip_pagination=#{options[:skip_pagination]} --skip_sidekiq=#{options[:skip_sidekiq]} --skip_tests=#{options[:skip_tests]} --template_engine=#{options[:template_engine]} --simpleform=#{options[:simpleform]} --test_engine=#{options[:test_engine]} --uuid=#{options[:uuid]}")
        generate('kowl:uuid') if options[:database] == 'postgresql' && options[:uuid]
        generate("kowl:dotfiles --database=#{options[:database]} --encrypt=#{options[:encrypt]} --skip_docker=#{options[:skip_docker]} --skip_erd=#{options[:skip_erd]} --skip_javascript=#{options[:skip_javascript]} --skip_mailer=#{options[:skip_mailer]} --skip_pry=#{options[:skip_pry]} --skip_sidekiq=#{options[:skip_sidekiq]} --skip_tests=#{options[:skip_tests]} --test_engine=#{options[:test_engine]} --template_engine=#{options[:template_engine]} ")
        generate("kowl:assets --framework=#{options[:framework]} --noauth=#{options[:noauth]} --skip_javascript=#{options[:skip_javascript]} --skip_mailer=#{options[:skip_mailer]} --skip_turbolinks=#{options[:skip_turbolinks]}")
        generate("kowl:views_and_helpers --framework=#{options[:framework]} --noauth=#{options[:noauth]} --simpleform=#{options[:simpleform]} --skip_javascript=#{options[:skip_javascript]} --skip_pagination=#{options[:skip_pagination]} --skip_turbolinks=#{options[:skip_turbolinks]} --template_engine=#{options[:template_engine]}")
        generate("kowl:users_and_auth --database=#{options[:database]} --encrypt=#{options[:encrypt]} --framework=#{options[:framework]} --skip_javascript=#{options[:skip_javascript]} --skip_mailer=#{options[:skip_mailer]} --skip_pagination=#{options[:skip_pagination]}  --skip_sidekiq=#{options[:skip_sidekiq]} --template_engine=#{options[:template_engine]}") unless options[:noauth]
        # tests are generated after users, because devise migrations tries to create empty minitest and rspec migration tests
        generate("kowl:test --noauth=#{options[:noauth]} --test_engine=#{options[:test_engine]}") unless options[:test_engine] == :none || options[:skip_tests]
        generate('kowl:staging') unless options[:database] == 'sqlite3'
        generate("kowl:controller --noauth=#{options[:noauth]}")
        generate("kowl:database --database=#{options[:database]} --noauth=#{options[:noauth]}")
        generate("kowl:action --database=#{options[:database]} --simpleform=#{options[:simpleform]} --skip_javascript=#{options[:skip_javascript]}")
        generate("kowl:mailer --noauth=#{options[:noauth]} --mailer=#{options[:mailer]}") unless options[:skip_mailer]
        generate("kowl:sidekiq --database=#{options[:database]} --noauth=#{options[:noauth]}") unless options[:skip_sidekiq]
        generate('kowl:misc') # Generator misc application directores such as serializers, services, workers, etc.
        generate("kowl:decorators --noauth=#{options[:noauth]}")
        generate("kowl:text_files --framework=#{options[:framework]} --noauth=#{options[:noauth]}")
        generate("kowl:pages --framework=#{options[:framework]} --noauth=#{options[:noauth]} --template_engine=#{options[:template_engine]}") # Generate welcome pages and routes for the application
        generate("kowl:routes --database=#{options[:database]} --noauth=#{options[:noauth]} --skip_mailer=#{options[:skip_mailer]} --skip_sidekiq=#{options[:skip_sidekiq]}")
        generate('kowl:libs')

        # Generate admin dashboard if user authentication is enabled
        generate("kowl:docker --database=#{options[:database]} --docker_distro=#{options[:docker_distro]} --encrypt=#{options[:encrypt]} --skip_erd=#{options[:skip_erd]} --skip_javascript=#{options[:skip_javascript]} --skip_sidekiq=#{options[:skip_sidekiq]}") unless options[:skip_docker]

        rake 'db:migrate' unless (options[:database] == 'postgresql' && options[:uuid]) || options[:noauth]
        generate("kowl:admin --database=#{options[:database]} --skip_javascript=#{options[:skip_javascript]} --skip_turbolinks=#{options[:skip_turbolinks]} --uuid=#{options[:uuid]} ") unless options[:noauth]
        invoke :add_uuids_to_migrations if options[:database] == 'postgresql' && options[:uuid]
        invoke :remove_sqlite_yaml unless options[:database] == 'sqlite3'
        invoke :setup_spring unless options[:skip_spring]

        # Remove the kowl gem, it is initially required to run the rails generators
        # => Removing the gem removes the generators from application
        remove_gem('kowl')

        # This should be ran last, thus there will only be 1 commit when application is started
        # This is a method tather than a generate, because generations can't be called after the gem has been removed
        invoke :initial_commit unless options[:skip_git]
      end

      # Setup a staging envirnment for application config and webpacker
      def setup_staging
        template 'config/environments/production.rb.tt', 'config/environments/staging.rb'
        # Enable displaying error messages in staging
        replace_string_in_file('config/environments/staging.rb',
                               '^[\s]*?(config.consider_all_requests_local)[\s]*= false[\s]?$',
                               '  config.consider_all_requests_local       = true')
        # create a webpacker staging environment
        return if options[:skip_javascript]

        dup_file('config/webpack/production.js', 'config/webpack/staging.js')
        webpacker_str = <<~STAGING
          staging:
            <<: *default
            # Production depends on precompilation of packs prior to booting for performance.
            compile: false
            # Extract and emit a css file
            extract_css: true
            # Cache manifest.json for performance
            cache_manifest: true
        STAGING
        append_to_file('config/webpacker.yml', "\n#{webpacker_str}")
      end

      # Create a git initial commit
      def initial_commit
        git :init
        git add: '.'
        git commit: "-aqm 'Initial Commit' --quiet"
      end

      # If UUIDs are to be used, add id: :uuid to all migrations
      def add_uuids_to_migrations
        return nil unless options[:database] == 'postgresql' && options[:uuid]

        Dir.foreach('db/migrate/') do |migration|
          next if %w[. ..].include?(migration) || migration.match(/_enable_pgcrypto_extension.rb$/)

          inject_into_file("db/migrate/#{migration}", ', id: :uuid', after: /create_table \:[a-z\_]+/)
        end
      end

      # While generating the application the config/database.yml is defaulted to using sqlite3.
      #  This is because we can't run migrations, and various tasks without a valid database.yml
      #  but this file should be remove and replace with the config/database[#{database_type}].yml file once the application is ready
      def remove_sqlite_yaml
        return nil if options[:database] == 'sqlite3'

        db_file = "config/database[#{options[:database]}].yml"
        remove_file('config/database.yml')
        move_file(db_file, 'config/database.yml')
      end

      # Setup spring for the application unless specified otherwise
      def setup_spring
        say 'Springifying binstubs'
        build :setup_spring unless options[:skip_spring]
      end

      # Rails6 has issues when genereting a new app using Oracle/sqlserver right away,
      # this ensures webpack is installed if it previously failed because of the missing ruby-oci8/sqlserver gems
      # In addition his also prevents a Psych error as the application is generated
      def install_webpack_assets
        rails_command('webpacker:install') unless options[:skip_javascript]
      end

      protected

      def get_builder_class
        AppBuilder
      end
    end
  end
end
