# frozen_string_literal: true

# circleci/ruby:2.6-noderequire 'rails/generators'
# https://circleci.com/docs/2.0/custom-images/
require_relative 'base'

module Kowl
  class CircleciGenerator < Kowl::Generators::Base
    hide!
  end
end
