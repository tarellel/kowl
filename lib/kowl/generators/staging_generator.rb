# frozen_string_literal: true

require 'rails/generators'
require_relative 'base'

# This generator is used to create a staging environment
# => It generates a staging.rb file in the config/environments/ (uses the production environment as a base)
# => It adds a staging database to the bottom of your config/database.yml file (inherits from &default)
# https://api.rubyonrails.org/v5.2/classes/Rails/Generators/Base.html#method-c-base_root
module Kowl
  class StagingGenerator < Kowl::Generators::Base
    hide!
  end
end
