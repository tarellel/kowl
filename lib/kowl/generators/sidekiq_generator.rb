# frozen_string_literal: true

require 'rails/generators'
require_relative 'base'

module Kowl
  class SidekiqGenerator < Kowl::Generators::Base
    hide!
    source_root File.expand_path(File.join('..', 'templates'), File.dirname(__FILE__))
    class_option :database, type: :string, default: 'sqlite3'
    class_option :noauth, type: :boolean, default: false

    # Copy over a basic sidekiq config and sidekiq initializer
    def copy_config
      template 'config/sidekiq.yml.tt', 'config/sidekiq.yml'
      copy_file 'config/initializers/sidekiq.rb', 'config/initializers/sidekiq.rb'
    end

    # Setup pghero scheduled job, if application will be running with postgresql
    def pghero_worker
      copy_file('app/workers/scheduler/pghero_scheduler.rb', 'app/workers/scheduler/pghero_scheduler.rb') if options[:database] == 'postgresql'
    end

    # Setup the application to use redis as a cache_store
    def set_redis_as_cache_storage
      # https://blog.appsignal.com/2018/04/17/rails-built-in-cache-stores.html
      # https://www.engineyard.com/blog/rails-5-2-redis-cache-store
      # config.cache_storage = :redis_cache_store, { driver: :hiredis } # , url: "redis://redis:6379/0" }
    end
  end
end
