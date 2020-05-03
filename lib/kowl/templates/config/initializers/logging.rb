# frozen_string_literal: true

# https://api.rubyonrails.org/classes/ActiveSupport/Logger.html
unless Rails.env.test?
  ActiveRecord::Base.logger = ActiveSupport::Logger.new(STDOUT)
end
