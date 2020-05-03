# frozen_string_literal: true

require 'rails/generators'
require_relative 'base'

module Kowl
  class ActionGenerator < Kowl::Generators::Base
    hide!
    source_root File.expand_path(File.join('..', 'templates'), File.dirname(__FILE__))
    class_option :database, type: :string, default: 'sqlite3'
    class_option :simpleform, type: :boolean, default: false
    class_option :skip_javascript, type: :boolean, default: false
    hide!

    # Because simpleform hasn't Actiontext input types yet, attribute type needs to be added in order for an input type to properly load
    # => https://github.com/plataformatec/simple_form/issues/1638
    def copy_simpleform_inputs
      return nil unless options[:simpleform]

      # If using simpleform tthis allows you to use rich_text_area input type (trix)
      # ie: `= f.rich_text_area :body`
      directory('app/inputs', 'app/inputs')
    end

    # Used to beign setting up action_text based on if options[:skip_javascript] is specified or not
    def setup_action_text
      # If javascript is being skipped, you'll only want to generate the migrations.
      # => But if you're skipping javascript, you'll need to add actiontext javascript components yourself
      if options[:skip_javascript]
        rake 'action_text:copy_migrations'
      else
        rake 'action_text:install'
      end
    end

    # Setup and create ActiveStorage migrations
    def setup_active_storage
      rake 'active_storage:install'
    end

    # Correct issue with application index if using Oracle for the applications database
    # This is because Oracle can only have an index of 30 characters long
    # So oracle is being used we need to correct the migrations to remove the indexes with huge names
    def correct_oracle_indexes
      return nil unless options[:database] == 'oracle'

      # Fix - index_active_storage_attachments_uniqueness
      Dir.glob('db/migrate/**_create_active_storage_tables.active_storage.rb').select do |migration_file|
        gsub_file migration_file, 't.index [ :record_type, :record_id, :name, :blob_id ], name: "index_active_storage_attachments_uniqueness", unique: true', 't.index [ :record_type, :record_id, :name, :blob_id ], name: "index_activestorage", unique: true'
      end
      Dir.glob('db/migrate/**_create_action_text_tables.action_text.rb').select do |migration_file|
        gsub_file migration_file, 't.index [ :record_type, :record_id, :name ], name: "index_action_text_rich_texts_uniqueness", unique: true', 't.index [ :record_type, :record_id, :name ], name: "index_actiontext", unique: true'
      end
    end

    # Correct issue with the applications index if using SQLserver for the application database
    # This is because the active_record migration flagges an error for foreign_key constraints for using blob_ids as the index
    def correct_sqlserver_indexes
      return nil unless options[:database] == 'sqlserver'

      Dir.glob('db/migrate/**_create_active_storage_tables.active_storage.rb').select do |migration_file|
        gsub_file migration_file, 't.foreign_key :active_storage_blobs, column: :blob_id', '# t.foreign_key :active_storage_blobs, column: :blob_id'
      end
    end

    # If using javascript this adds trix's import to the applications SCSS file
    def add_trix_stylesheets
      return '' if options[:skip_javascript]

      append_to_file('app/assets/stylesheets/application.scss', "\n@import 'trix/dist/trix';")
    end

    # Add default ActiveStorage FileType and FileSize limits for uploading through trix (this can easily be changed)
    #   Limit trix mimetyps to jpeg and png
    #   Limit max filesizes to 2MB
    def limit_file_upload_types
      return nil if options[:skip_javascript]

      trix_action_storage = <<~TRIX_STORAGE
        window.addEventListener('trix-file-accept', function(event) {
          const acceptedTypes = ['image/jpg', 'image/jpeg', 'image/png']
          const maxFileSize = (1024 * 1024) * 2 // 2MB
          // Limit trix file upload types to the mimetypes listed below
          if (!acceptedTypes.includes(event.file.type)) {
            event.preventDefault()
            alert('Only support attachment of jpeg or png files')
          }
          // Limit trix max filesize limits to 2MB
          if (event.file.size > maxFileSize) {
            event.preventDefault()
            alert('Only support of attachment files upto size 2MB!')
          }
        })
      TRIX_STORAGE
      append_to_file('app/javascript/packs/application.js', "\n\n#{trix_action_storage}")
    end

    # def update_migration_fields
    #   Dir.glob('db/migrate/**_create_action_text_tables.action_text.rb').select { |e| update_action_migration(e, 'db/migrations/create_action_text_tables.action_text.rb.tt') }
    #   Dir.glob('db/migrate/**_create_active_storage_tables.active_storage.rb').select { |e| update_action_migration(e, 'db/migrations/create_active_storage_tables.active_storage.rb.tt') }
    # end

    # private

    # def update_action_migration(migration_file, template_file)
    #   return nil if migration_file.blank? || template_file.blank?
    #   return false unless file_exists?(migration_file)
    #
    #   # override prexisting migration with template contents
    #   template template_file, migration_file, force: true
    # end
  end
end
