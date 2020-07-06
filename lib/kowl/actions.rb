# frozen_string_literal: true

require 'fileutils'
require 'active_support'
require 'rails/generators/base'

# https://github.com/rails/rails/blob/66cabeda2c46c582d19738e1318be8d59584cc5b/railties/lib/rails/generators/actions.rb
module Kowl
  module Actions
    # Used to call a rails system command
    # @param cmd [String] The rails command that will be executed, ie: db:migrate
    # @return [Boolean] if the rails command was succcessfully executed or not
    def rails_cmd(cmd = '')
      return nil if cmd.blank?

      system("bin/rails #{cmd}")
    end

    # Used to install yarn package is NPM/Yarn is available
    # @param pkg [String] The Yarn/npm package in which to install with the Rails Application
    # @return [Boolean] if the yarn package was successfully installed or not
    def add_package(pkg = '')
      return false if pkg.blank?

      system("bin/yarn add #{pkg}")
    end

    # Append a string to the end of a specied file
    # @param file [String] Filename to append the string to
    # @param str [String] String to add to the specified file
    # @return [Boolean] if the string was appended to the file or not
    def append_to_file(file, str)
      File.open(file, 'a+') { |f| f << str }
    end

    # Validate if a specified file exists
    # @param file [String] Filename to validate against
    # @return [Boolean] Returns whether if the file exists or not
    def file_exists?(file)
      File.file? file
    end

    # Dupliate a specified file (make a copy)
    # @param source [String] The originating file in which you wish to duplicate
    # @param destination [String] The destination of the file in which you are duplicating to
    # @return [Boolean, nil] Returns nil if the source or destination where not specified. Otherwise if should return true/false if the file was actually duplicated
    def dup_file(source, destination)
      return nil if source.blank? || destination.blank?

      FileUtils.cp(source, destination) if file_exists?(source)
    end

    # Create a specific directory
    # @param path [String] The path in which you wish to create
    # @return [Boolean] if the filepath was created or not
    def mk_dir(path)
      FileUtils.mkdir_p(path) unless File.directory?(path)
    end

    # Delete a specific directory path
    # src: https://github.com/solidusio/solidus/blob/master/core/lib/generators/spree/dummy/dummy_generator.rb#L128
    # @param path [String] The specifc directory which you wish to remove
    # @return [Boolean] if the FileDir was removed or not
    def remove_dir(path)
      FileUtils.remove_dir(path) if File.directory?(path)
    end

    # Delete a specific file from the projects directory structure
    # @param file [String] The specific file in which you wish to delete
    # @return [Boolean, nil] Returns nil if the filename is blank, otherwise it should return true/false if the file was properly removed
    def remove_file(file)
      return nil if file.blank?

      FileUtils.rm(file, force: true) if file_exists?(file)
    end

    # Move a file to a specified location
    # @param file [String] The original file location in which you want to move the file from
    # @param destination [String] The destintion location of where you would like to move this file to
    # @return [Boolean, nil] Return nil if the file or destrination are blank. Otherwise it will return true/false if the file was successfully moved
    def move_file(file, destination)
      return nil if file.blank? || destination.blank?

      FileUtils.mv(file, destination, force: true) if file_exists?(file)
    end

    # Used to remove a gem from the Gemfile and bundle installs afterwards
    # @param gem [String] The Gem name which you would like to remove from the gemfile
    # @return [nil] Returns nil if the the method is called without a gem specified
    def remove_gem(gem)
      return nil if gem.blank?

      # Used to match if the user used double & single quotes ("|') around the gem and a variable amount of space
      # used to match the following string variations
      # gem 'puma'
      # gem "puma"
      # gem "puma", '~> 3.7'
      # gem 'puma', github: 'puma/puma'
      replace_string_in_file('Gemfile', "^[\s]?gem\s?[\'\"](#{gem})[\'\"](.+?)*[\s]?", '')
      # Because we're removing a gem from the gemfile we need to bundle again
      run 'bundle install --quiet'
    end

    # Replace a matching string within a specific file
    # @param filename [String] The file in which you would like to change it's contents
    # @param regex [String] The regular expression you would like to run against the line of text within the file
    # @param replacement [String] The string in which you would like to replace any matches against
    # @return [Boolean] if the string was successfully replaced in the specified file
    def replace_string_in_file(filename, regex, replacement = '')
      content = File.read(filename).gsub(/#{regex}$/i, replacement)
      File.open(filename, 'wb') { |file| file.write(content) }
    end

    ##################################################
    # Template Stuff
    ##################################################

    # Add config to the development environment
    # @param str [String] A heredoc containing configuration changes for the development environment
    # @return [Boolean] if the string was successfully injected into the development config file
    def dev_config(str)
      inject_into_file('config/environments/development.rb', optimize_indentation(str, 2), after: "config.assets.quiet = true\n")
    end

    ##################################################
    # Routes
    ##################################################
    # Adds a development only route to access LetterOpener when developmenting the application
    # @param skip_mailer [Boolean] A flag to determine if you want to skip using a mailer
    # @return [String] the LetterOpener mount path (unless you have specied to skip_mailer)
    def mailer_route(skip_mailer)
      return '' if skip_mailer

      "  mount LetterOpenerWeb::Engine, at: \"/letter_opener\" if Rails.env.development?\n"
    end

    # Add PgHero engine mount to the routes if the database iss postgresql
    # @param database [String] A string containing the applications defined database adapter
    # @return [String] the pghero dashboard mount path, if postgresql will be used
    def database_route(database = 'sqlite3')
      return '' unless database.to_s == 'postgresql'

      "  mount PgHero::Engine, at: \"pghero\"\n"
    end

    # Unless specified the function will add a Sidekiq engine route to access in the routes
    # @param options [Hash] A flag to determine if you would like the generators to skip adding sidekiq to the applicatiion
    # @return [String] the sidekiq mount path
    def sidekiq_route(options)
      return '' if options[:skip_sidekiq]

      "  mount Sidekiq::Web => '/sidekiq'\n"
    end

    #  Unless all extensions are skipped [mailer && sidekiq], will will add their mounts depending on if the add requires auth or not
    # @param options [Hash] The entire generators options passed to it
    # @return [String] the applications extensions mount paths for routes file
    def add_extension_routes(options)
      ext_routes = "#{database_route(options[:database])}#{mailer_route(options[:skip_mailer])}#{sidekiq_route(options)}"
      routes_str = if options[:noauth]
                     <<~ROUTES
                       # If authentication has not been used; only allow this routes to be used in development to prevent authorized access
                       if Rails.env.development?
                         #{ext_routes.squeeze("\n").strip}
                       end
                     ROUTES
                   else
                     <<~ROUTES
                       # Require the person hitting this page ot be an application admin
                       authenticate :user, -> (user) { user.admin? } do
                         #{ext_routes.squeeze("\n").strip}
                       end
                     ROUTES
                   end
      optimize_indentation(routes_str, 2)
    end

    ##################################################
    # Gemfile specific functions
    ##################################################
    # Adds the specified mailer gem to the application
    # @param mailer [String] Specfic mailer in which you would like to use
    # @return [String] the applications mailer gem that will be added to the Gemfile
    def mailer_gems(mailer = 'sparkpost')
      if mailer.to_s == 'postmark'
        "gem 'postmark-rails'"
      else
        "gem 'sparkpost_rails'"
      end
    end

    # Outputs a set of Gemfile entries for the application developer to use pry in the rails console
    # @param skip_pry [Boolean] if the developer wants to skip using pry with their application
    # @return [nil, String] return the string to be added to the applications Gemfile
    def pry_gems(skip_pry = false)
      return nil if skip_pry

      gems = <<~PRY
        # Pry to cleanup the rails console
        gem 'pry', '0.12.2'
        gem 'pry-rails'               # pry console output
        gem 'spirit_hands'            # A combination of pry, awesome_print, hirb, and numerous other console extensions
      PRY
      optimize_indentation(gems, 2)
    end

    # Determine which linter should be used for the aplication
    # @param engine [String] The specified applications templating engine (erb, hal, or slim)
    # @return [String] An gem line that will be added to the gemfile
    def template_linter_gems(engine)
      return '' if engine.blank?

      case engine.to_s
      when 'haml'
        "gem 'haml_lint'#{gemfile_requirement('haml_lint')}, require: false"
      when 'slim'
        "gem 'slim_lint'#{gemfile_requirement('slim_lint')}, require: false"
      else
        "gem 'erb_lint', github: 'Shopify/erb-lint', require: false"
      end
    end

    # Determine which rubcop gem should be used (dependant on the requested test suite)
    # @param test_engine [String] The specified application test suite requested
    # @param skip_tests [Boolean] if you would like skip using tests with the application
    # @return [String] The gemfile rubocop gem entry based on the applications test suite
    def robocop_test_engine(test_engine = '', skip_tests = false)
      return '' if test_engine.blank? || skip_tests

      case test_engine.to_s
      when 'minitest'
        "gem 'rubocop-minitest', require: false"
      when 'rspec'
        "gem 'rubocop-rspec', require: false"
      else
        ''
      end
    end
  end
end
