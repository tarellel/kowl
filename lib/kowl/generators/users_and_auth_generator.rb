# frozen_string_literal: true

require 'rails/generators'
require_relative 'base'

module Kowl
  class UsersAndAuthGenerator < Kowl::Generators::Base
    hide!
    source_root File.expand_path(File.join('..', 'templates'), File.dirname(__FILE__))
    class_option :database, type: :string, aliases: '-d', default: 'sqlite3'
    class_option :encrypt, type: :boolean, default: false
    class_option :framework, type: :string, default: 'bootstrap'
    class_option :skip_javascript, type: :boolean, default: false
    class_option :skip_mailer, type: :boolean, default: false
    class_option :skip_pagination, type: :boolean, default: false
    class_option :skip_sidekiq, type: :boolean, default: false
    class_option :template_engine, type: :string, default: 'erb'

    # Run devise generators unless you don't want authentication allowed in the application
    def generate_devise
      # generate devise config
      generate('devise:install')

      # Generate devise users models
      generate('devise User role:integer')

      # Generate additional Devise security practices
      generate('devise_security:install')
      # Copy initializer for ensure a more secure devise application setup
      copy_file('config/initializers/devise-security.rb', 'config/initializers/devise-security.rb', force: true) unless options[:noauth]

      # Generate devise authentication log
      generate('authtrail:install')
    end

    # Generate Pundit policies for basic authentication policies
    def generate_and_copy_policies
      # Begin setting up pundit
      generate('pundit:install')
      # these are generated, so they'll also create tests policies
      generate('pundit:policy user')
      generate('pundit:policy login_activity')

      # Remove policies and replace with a base policy build
      remove_dir('app/policies')
      directory('app/policies', 'app/policies')
    end

    # Override user model with devise specific settings
    def overrider_devise_config
      template 'app/models/user.rb.tt', 'app/models/user.rb', force: true
    end

    # Update the devise migration to enable trackable and lockable attributes
    def adjust_devise_migration
      # Fetch the devise migration file
      Dir.glob('db/migrate/**_devise_create_users.rb').select { |e| update_devise_migration(e) }
    end

    # This is because we encrypt certain values being logged into the LoginActivity table
    #   No not all data is plain text readable in the database
    def replace_logins_activity_migration
      Dir.glob('db/migrate/**_create_login_activities.rb').select { |e| update_login_activities_migration(e) }
    end

    # Change devise lock_strategy
    def adjust_lock_stragety
      devise_initialzier = 'config/initializers/devise.rb'
      content = File.read(devise_initialzier).gsub(/\s?\#\s(config.lock_strategy = :failed_attempts)\n?/i, optimize_indentation('config.lock_strategy = :failed_attempts', 2))
      File.open(devise_initialzier, 'wb') { |file| file.write(content) }
    end

    # Update devise/User notificationss
    def adjust_devise_notifications
      inject_into_file('config/initializers/devise.rb', optimize_indentation("config.send_email_changed_notification = true\n", 2), after: "  # config.send_email_changed_notification = false\n")
      inject_into_file('config/initializers/devise.rb', optimize_indentation("config.send_password_change_notification = true\n", 2), after: "  # config.send_password_change_notification = false\n")
    end

    # Update devise initializer to be paranoid, to prevent credential stuffing with password resets
    def set_devise_as_paranoid
      # This displays the visitor with a confirmation even if the user does or doesn't exist
      gsub_file('config/initializers/devise.rb', '# config.paranoid = true', 'config.paranoid = true')
    end

    # Generate a model for monitoring user login activity
    def copy_login_activity_model
      template 'app/models/login_activity.rb.tt', 'app/models/login_activity.rb', force: true
    end

    # Generate and copy a Users controller
    def generate_users_controller
      generate('controller Users') # copied mainly for testing purposes
      copy_file 'app/controllers/users_controller.rb', 'app/controllers/users_controller.rb', force: true
    end

    # Generate administrate viewss
    def generate_dashboard_views_and_assets
      # The main reason these are generated, before copying over is some tests may rely on theses generators
      generate('administrate:views:index User --quiet')
      generate('administrate:views:edit User --quiet')
      generate('administrate:assets:stylesheets --quiet')
      generate('administrate:views:navigation --quiet')
    end

    # Copy over admin views and layouts
    def setup_user_dashboard_views
      remove_dir('app/views/admin')
      directory('app/views/admin/views', 'app/views/admin')
      template('app/views/admin/templates/navigation.erb.tt', 'app/views/admin/application/_navigation.html.erb')
    end

    # Copy over administrate SCSS stylesheet files
    def setup_dashboard_stylesheets
      copy_file('app/assets/stylesheets/administrate/application.scss', 'app/assets/stylesheets/administrate/application.scss', force: true)
    end

    # Add flattpickr to administrate for datetime picker fields
    def setup_dashbord_javascript
      return nil if options[:skip_javascript]

      # flatpicker is required for date/time selection components
      add_package('flatpickr')
    end

    private

    def update_devise_migration(migration_file)
      return false unless file_exists?(migration_file)

      # override migration file to enable :trackable && :lockable
      # copy_file 'db/migrations/devise.rb', migration_file, force: true
      template 'db/migrations/devise.rb.tt', migration_file, force: true
    end

    def update_login_activities_migration(migration_file)
      return false unless file_exists?(migration_file)

      # Override the default migration file to enable :trackable && :lockable
      # copy_file 'db/migrations/login_activities.rb', migration_file, force: true
      template 'db/migrations/login_activities.rb.tt', migration_file, force: true
    end
  end
end
