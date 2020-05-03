# frozen_string_literal: true

# Disable papertrail logging when running tests
# https://github.com/paper-trail-gem/paper_trail#7b-rspec
require 'paper_trail/frameworks/rspec' if defined?(PaperTrail)
