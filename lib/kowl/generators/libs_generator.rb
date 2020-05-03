# frozen_string_literal: true

require 'rails/generators'
require_relative 'base'

module Kowl
  class LibsGenerator < Kowl::Generators::Base
    hide!
    source_root File.expand_path(File.join('..', 'templates', 'lib', 'tasks'), File.dirname(__FILE__))
    class_option :simpleform, type: :boolean, default: false
    class_option :skip_javascript, type: :boolean, default: false
    hide!

    # Generate a Rake file for viewing additional Rails applications stats
    def stats_task
      copy_file 'stats.rake', 'lib/tasks/stats.rake', force: true
    end
  end
end
