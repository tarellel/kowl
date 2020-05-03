# frozen_string_literal: true

require 'rails/generators'
require 'kowl/version'
require 'kowl/helpers'
require 'kowl/geodb' # Used for downloading and extracting GeoLiteDB

# https://www.rubydoc.info/gems/railties/5.0.0/index
# Default rails generator overriders
require 'kowl/generators/overrides/app_generator'

# Load the list of customized application generators
generators = %w[action admin assets config controller database decorators docker dotfiles libs mailer misc pages routes
                sidekiq staging test text_files users_and_auth uuid views_and_helpers]
generators.map { |file| require "kowl/generators/#{file}_generator" }

# For generating base template files, once the application has been build
require 'kowl/generators/overrides/app_builder'
