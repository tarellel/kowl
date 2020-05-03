# frozen_string_literal: true

require 'rails/generators'
require_relative 'base'

module Kowl
  class DockerGenerator < Kowl::Generators::Base
    hide!
    source_root File.expand_path(File.join('..', 'templates', 'docker'), File.dirname(__FILE__))
    class_option :encrypt, type: :boolean, default: false
    class_option :database, type: :string, default: 'sqlite3'
    class_option :docker_distro, type: :string, default: 'alpine'
    class_option :skip_erd, type: :boolean, default: false
    class_option :skip_javascript, type: :boolean, default: false
    class_option :skip_sidekiq, type: :boolean, default: false

    # Generate the applications Dockerfile depending on the the specified distro
    def setup_dockerfile
      if options[:docker_distro] == 'debian' || options[:database] == 'oracle'
        # This is here because Debian is very compatible with most Ruby/Rails gems
        # => The Oracle InstantClient does have a number of issues when trying to build with Alpine
        template 'Dockerfile.debian.tt', 'Dockerfile'
      else
        template 'Dockerfile.alpine.tt', 'Dockerfile'
      end
    end

    # Generate an applications docker-compose.yml file based on all it's specified requirements
    def setup_docker_compose
      template 'docker-compose.yml.tt', 'docker-compose.yml'
    end

    # If one of the specified databases are being used, generate a specific Dockerfile to generate the required tables
    def setup_database_dockerfile
      return nil unless options[:database] == 'mysql'

      template 'mysql/Dockerfile.tt', 'docker/Dockerfile'
    end
  end
end
