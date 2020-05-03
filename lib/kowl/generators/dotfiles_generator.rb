# frozen_string_literal: true

require 'rails/generators'
require_relative 'base'

module Kowl
  class DotfilesGenerator < Kowl::Generators::Base
    hide!
    source_root File.expand_path(File.join('..', 'templates', 'dotfiles'), File.dirname(__FILE__))
    class_option :encrypt, type: :boolean
    class_option :template_engine, type: :string
    class_option :test_engine, type: :string
    class_option :database, type: :string
    class_option :mailer, type: :string
    class_option :skip_docker, type: :boolean, default: false
    class_option :skip_erd, type: :boolean, default: false
    class_option :skip_javascript, type: :boolean
    class_option :skip_mailer, type: :boolean
    class_option :skip_sidekiq, type: :boolean
    class_option :skip_pry, type: :boolean
    class_option :skip_tests, type: :boolean

    # Copy basic application linter dotfiles to the applications ROOT_PATH
    def copy_dotfiles
      files = %w[codeclimate.yml coffeelint.json coffeelintignore dockerignore editorconfig fasterer.yml foreman gitattributes mailmap nvmrc rspec scss-lint.yml simplecov slugignore yamllint]
      files.reject! { |e| e =~ /dockerignore/ } if options[:skip_docker]
      files.map { |dotfile| copy_file dotfile, ".#{dotfile}" }
    end

    # Copy JS dotfiles for linterers over the applications ROOT_PATH
    def copy_js_dotfiles
      return if options[:skip_javascript]

      js_files = %w[eslintignore eslintrc.js jsbeautifyrc jshintrc prettierignore prettierrc.js yarnclean]
      js_files.map { |dotfile| copy_file dotfile, ".#{dotfile}" }
    end

    # Setup Rubocop and ERD dotfiles for the application
    def setup_application_dotfiles
      files = %w[erdconfig rubocop.yml]
      files.reject! { |e| e =~ /erdconfig/ } if options[:skip_erd]
      files.map { |dotfile| template "#{dotfile}.tt", ".#{dotfile}" }
    end

    # Setup application dotfiles for the applications specific template_engine [Erb, Slim, HAML]
    def setup_linter_dotfiles
      copy_file "#{options[:template_engine]}-lint.yml", ".#{options[:template_engine]}-lint.yml"
    end

    # Generate a Brewfile for the application based on it's specific requirerments (for macOS)
    def setup_brewfile
      template 'Brewfile.tt', 'Brewfile'
    end

    # Generate an Aptfile for the application based on it's specific requirements (for Debian/Ubuntu)
    def setup_aptfile
      template 'Aptfile.tt', 'Aptfile'
    end

    # Setup .env file for the application, which makes it easier to use this config with docker-compose as well
    # Note: An .env file is setup instead of an .env.docker file because of the way env_file works with docker-compose
    # => At the moment, when running a build with docker-compose if an env_file is anything other than .env the variables won't be consumed by the container build process
    def setup_env_file
      %w[development staging production test].map { |env| template 'env.tt', ".env.#{env}", env: env }
      template 'env.tt', '.env', env: 'docker' unless options[:skip_docker]
    end

    # Generate a basic pry config file for the application
    def pryrc
      copy_file('pryrc', '.pryrc') unless options[:skip_pry]
    end
  end
end
