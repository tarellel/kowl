# frozen_string_literal: true

require 'rails/generators'
require_relative 'base'

# Used to generate various markdown textfiles such as README and changelog
module Kowl
  class TextFilesGenerator < Kowl::Generators::Base
    hide!
    source_root File.expand_path(File.join('..', 'templates', 'text_files'), File.dirname(__FILE__))
    class_option :framework, type: :string, default: 'bootstrap'
    class_option :noauth, type: :boolean, default: false

    # Generate a changelog file for project developers
    def changelog
      # Add a changelog file to the project
      template 'CHANGELOG.md.tt', 'CHANGELOG.md'
    end

    # Generarte numerous project markdown files
    def copy_markdown_files
      %w[AUTHORS.md CODE_OF_CONDUCT.md TODO.md].map { |f| copy_file(f, f) }
    end

    # Generate a project version file
    def version
      copy_file('VERSION', 'VERSION')
    end

    # Generate a security.txt file for application security contact information
    def copy_securitytxt
      copy_file('security.txt', 'public/.well-known/security.txt')
    end

    # Generate human.txt and robots.txt files for human readable project information
    def public_txt_files
      template 'humans.txt.tt', 'public/humans.txt'
      template 'robots.txt.tt', 'public/robots.txt', force: true
    end
  end
end
