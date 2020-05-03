# frozen_string_literal: true

require 'rails/generators'
require_relative 'base'

module Kowl
  class TestGenerator < Kowl::Generators::Base
    hide!
    source_root File.expand_path(File.join('..', 'templates', 'tests'), File.dirname(__FILE__))
    class_option :noauth, type: :boolean, default: false
    class_option :test_engine, type: :string, default: 'rspec'

    # Remove default generate4d test and spec files
    def remove_old_tests
      remove_dir('test')
      remove_dir('spec')
    end

    # If using minitest copy over a few basic tests and support files
    def copy_minitest_files
      directory('minitest', 'test') if options[:test_engine] == 'minitest'
    end

    # If using rspec copy over a few basic tests and support files
    def copy_rspec_files
      directory('rspec', 'spec') if options[:test_engine] == 'rspec'
    end

    # Copy over basic factory bot files
    def copy_factories
      directory 'factories', "#{(options[:test_engine] == 'rspec' ? 'spec' : 'test')}/factories", force: true
    end

    # If noauth is specified, remove the policies tests
    def remove_if_no_auth_required
      return unless options[:noauth]

      remove_dir('spec/policies') if options[:test_engine] == 'rspec'
      remove_dir('test/policies') if options[:test_engine] == 'minitest'
    end
  end
end
