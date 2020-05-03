# frozen_string_literal: true

require 'rails/generators'
require_relative 'base'

module Kowl
  class AdminGenerator < Kowl::Generators::Base
    hide!
    source_root File.expand_path(File.join('..', 'templates', 'app'), File.dirname(__FILE__))
    class_option :database, type: :string, default: 'sqlite3'
    class_option :skip_javascript, type: :boolean, default: false
    class_option :skip_turbolinks, type: :boolean, default: false
    class_option :uuid, type: :boolean, default: false

    # NOTE: In most of these I user the administrates native generator, before replacing them
    # that way if any tests are generates they will be available as well
    # This is skipped when using UUID's because by default the dashbooards try to us integers for ID's
    def generate_admin_dashboard
      generate('administrate:install') unless options[:uuid]
    end

    # Generate custom field attribute types to show a persons gravatar
    def generate_avatar_fields
      generate('administrate:field gravatar')
      remove_dir('app/fields')
      copy_file('app/fields/gravatar_field.rb', force: true)
    end

    # Generate support for the action_text field type to be supported with administrate
    def generate_action_text_fields
      generate('administrate:field rich_text_area')
      copy_file('app/fields/rich_text_area_field.rb', force: true)
    end

    # We copy dashboards over after the fields are generates.
    # Otherwise there will be an error about field types unknown (GravatarField)
    def copy_dashboards
      # Replace with dashboards showing less user data (this is because even admin and staff should be able to add, edit, or modify certain attributes)
      remove_dir('app/dashboards/')
      # This is because if UUID's are used the dashboards try to render them as integers.
      # Otherwise they'll be displayed as strings
      mk_dir('app/dashboards')
      %i[login_activity user rich_text_body].map { |dashboard| template "dashboards/#{dashboard}_dashboard.rb.tt", "app/dashboards/#{dashboard}_dashboard.rb" }
    end

    # this is to replace default generated gravatar views with ones that will actually show the user gravatars
    def replace_field_views
      remove_dir('app/views/fields')
      directory('views/fields', 'app/views/fields', force: true)
    end

    # This is because admin controllers should only be viewable if a user is a superuser or staff member
    def replace_admin_controllers
      remove_dir('app/controllers/admin')
      directory('controllers/admin', 'app/controllers/admin', force: true)
    end

    # Copy views for administrate dependant on if the app will use javascript or not
    def copy_admin_views
      if options[:skip_javascript]
        remove_file('app/views/admin/application/_javascript.html.erb')
      else
        copy_file('views/admin/views/application/_javascript.html.erb', 'app/views/admin/application/_javascript.html.erb')
      end
      template('views/layouts/admin.html.erb.tt', 'app/views/layouts/admin/application.html.erb')
    end

    # Unless javascript is skipped this adds the TRIX SCSS the to administrate stylesheets
    def add_trix_scss
      return nil if options[:skip_javascript]

      trix_import_str = <<~TRIX_SCSS
        // Used for creating ActionText content editors
        @import 'trix/dist/trix';
        // Used for date/time selection boxes in the admin interface
        @import 'flatpickr/dist/flatpickr.min';

        // We need to override trix.css’s image gallery styles to accommodate the
        // <action-text-attachment> element we wrap around attachments. Otherwise,
        // images in galleries will be squished by the max-width: 33%; rule.
        .trix-content {
          .attachment-gallery {
            >action-text-attachment,
            >.attachment {
              flex: 1 0 33%;
              padding: 0 0.5em;
              max-width: 33%;
            }
            &.attachment-gallery--2,
            &.attachment-gallery--4 {
              >action-text-attachment,
              >.attachment {
                flex-basis: 50%;
                max-width: 50%;
              }
            }
          }
          action-text-attachment {
            .attachment {
              padding: 0 !important;
              max-width: 100% !important;
            }
          }
        }
        .field-unit--rich-text-area-field {
          .field-unit__field {
            width: 80%;
          }
        }
      TRIX_SCSS
      append_to_file('app/assets/stylesheets/administrate/application.scss', trix_import_str)
    end
  end
end
