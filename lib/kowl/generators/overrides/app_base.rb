# frozen_string_literal: true

require 'rails/generators'
require 'rails/generators/rails/app/app_generator'
require 'rails/generators/app_base'
require_relative('../../actions')

# https://github.com/rails/rails/blob/master/railties/lib/rails/generators/app_base.rb
module Kowl
  module Overrides
    class AppBase < Rails::Generators::AppBase
      # More stuff coming soon
    end
  end
end
