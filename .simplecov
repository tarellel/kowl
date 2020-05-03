# frozen_string_literal: true

require 'simplecov'
SimpleCov.start('rails') do
  add_filter('/bin/')
  add_filter('/cache/')
  add_filter('/doc')
  add_filter('/docs/')
  add_filter('/lib/kowl/generators/')
  add_filter('/lib/kowl/templates/')
end
SimpleCov.minimum_coverage(75)
SimpleCov.use_merging(false)
