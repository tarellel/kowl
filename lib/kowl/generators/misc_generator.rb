# frozen_string_literal: true

require 'rails/generators'
require_relative 'base'

module Kowl
  class MiscGenerator < Kowl::Generators::Base
    hide!
    source_root File.expand_path(File.join('..', 'templates'), File.dirname(__FILE__))

    # Create variables folders in the /apps path for services, workers, etc
    def create_app_folders
      folders = %w[serializers services workers]

      folders.each do |d|
        mk_appdir("app/#{d}")
      end
    end
  end
end
