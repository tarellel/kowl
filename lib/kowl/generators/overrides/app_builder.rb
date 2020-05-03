# frozen_string_literal: true

# https://www.rubydoc.info/gems/railties/5.0.0/Rails/AppBuilder
# https://github.com/rails/rails/blob/b2eb1d1c55a59fee1e6c4cba7030d8ceb524267c/railties/lib/rails/generators/rails/app/app_generator.rb#L45
# https://api.rubyonrails.org/v5.1/classes/Rails/AppBuilder.html
module Kowl
  module Overrides
    class AppBuilder < Rails::AppBuilder
      # Override the applications .gitignore file with a more rails specific one
      def gitignore
        copy_file 'dotfiles/gitignore', '.gitignore', force: true
      end

      # Override the rails applications README with a new one (displaying application specific information in the readme)
      def readme
        template 'README.md.erb', 'README.md'
        # This is here, because if --skip_tests is added, it skips running the gitignore function
        # => since all projects have a readme this should just overwrite the gitignore file
        copy_file 'dotfiles/gitignore', '.gitignore', force: true
      end

      # Generate procfile for anyone who uses foreman to run their rails application, sidekiq, and various other services at once
      def procfile
        # Generate base Procfile
        template 'dotfiles/Procfile.tt', 'Procfile'
        # Generate Procfile running foreman in development
        template 'dotfiles/Procfile.tt', 'Procfile.dev', env: 'development'
      end

      # Regenerate the applications spring based binstubs
      def setup_spring
        bundle_command 'exec spring binstub --all'
      end

      # Replace the applications Gemfile with gems that are made to get you started faster
      def replace_gemfile
        # Gemfile template needs to be 'Gemfile.erb' otherwise it attempts to fetch Gemfile template from the Rails gem
        # https://github.com/rails/rails/blob/master/railties/lib/rails/generators/rails/app/templates/Gemfile.tt#L9
        template 'Gemfile.erb', 'Gemfile', force: true
      end

      # Override the default generated database.yml file
      def database_yml
        # Application will be defaulted to using sqlite3, until ready
        # => Application will also have a database[database].yml file to replace and run once the application is read
        template 'config/db/sqlite3.yml', 'config/database.yml', force: true

        # The directory config/databases/** is already used by Rails. We don't want to override this, because it won't pull from the gems template files, because they already exist in the rails gem
        # /Users/username/.rvm/gems/ruby-2.6.2/gems/railties-6.0.0/lib/rails/generators/rails/app/templates/config/databases
        if %w[mysql oracle postgresql sqlite3 sqlserver].include? options[:database]
          template "config/db/#{options[:database]}.yml", "config/database[#{options[:database]}].yml" unless options[:database] == 'sqlite3'
        else
          template "config/databases/#{options[:database]}.yml", "config/database[#{options[:database]}].yml"
        end
      end
    end
  end
end
