# frozen_string_literal: true

require 'fileutils'
require 'rails/generators'
require_relative '../actions'
require_relative '../docker'

# https://api.rubyonrails.org/v5.2/classes/Rails/Generators/Base.html
module Kowl
  module Generators
    class Base < Rails::Generators::Base
      include Kowl::Actions
      include Kowl::Docker
      hide!

      # Resolve to using the default Rails gem templates as a fallback in case source_path doesn't exist for generator
      # NOTE: Do no enable this, as it tends to overwrite the default rails gem past for pulling templates from (ie: database stuff)
      def self.default_source_root
        File.expand_path(File.join('..', 'templates'), __dir__)
      end

      # Used for setting RAILS default source_path
      # As well as adding the gems source_path to the generators
      # src: https://github.com/solidusio/solidus/blob/master/core/lib/generators/spree/dummy/dummy_generator.rb#L15
      def self.source_paths
        super
        paths = superclass.source_paths
        paths << File.expand_path(File.join('..', 'templates'), __dir__)
        paths.flatten.uniq
      end

      private

      # Return a cleaned up version of the name of the application being generated
      def app_name
        Rails.app_class.parent_name.demodulize.underscore.dasherize
      end
    end
  end
end
