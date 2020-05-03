# frozen_string_literal: true

require 'database_cleaner'
# https://gist.github.com/lujanfernaud/67644f8ea4263f4e638be1090ec85580
module DatabaseCleanerSupport
  def before_setup
    super
    DatabaseCleaner.start
  end

  def after_teardown
    DatabaseCleaner.clean
    super
  end
end