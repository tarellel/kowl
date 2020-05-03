# frozen_string_literal: true

require 'rails/generators'
require_relative 'base'

module Kowl
  class DecoratorsGenerator < Kowl::Generators::Base
    hide!
    class_option :noauth, type: :boolean, default: false

    # Generate a user decorator file for the applications users model
    def users_decorator
      generate('decorator user') unless options[:noauth]
    end
  end
end
