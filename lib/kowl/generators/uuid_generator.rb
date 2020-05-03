# frozen_string_literal: true

require 'rails/generators'
require_relative 'base'

# https://github.com/rails/rails/blob/master/guides/source/active_record_postgresql.md
# This generator sets postgres to use UUIDs at the primary keys for your objects
module Kowl
  class UuidGenerator < Kowl::Generators::Base
    hide!
    source_root File.expand_path(File.join('..', 'templates', 'db'), File.dirname(__FILE__))

    # Generate migration to add pgcrypto_extension to the database
    def generate_migration
      generate('migration enable_pgcrypto_extension')
    end

    # Update pgcrypto migration file to include enable tjhe pgcrypt extension for postgres
    def add_to_migration
      Dir.glob('db/migrate/**_enable_pgcrypto_extension.rb').select { |e| update_uuid_migration(e) }
    end

    private

    # Update the pgcrypto migration file
    # @param migration_file [String] - The specified migration file for enabling the extension ie: 1234567890_enable_pgcrypto_extension.rb
    def update_uuid_migration(migration_file)
      return false unless file_exists?(migration_file)

      uuid_migration_str = <<~UUID_STR
        if ActiveRecord::Base.connection.adapter_name.downcase.to_sym == :postgresql
          enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')
        end
      UUID_STR

      insert_into_file migration_file, optimize_indentation(uuid_migration_str, 4), after: /\s+\S+\schange\s?\n/
    end
  end
end
