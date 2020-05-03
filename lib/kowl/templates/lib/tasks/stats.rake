# frozen_string_literal: true

# Modified from => https://github.com/rails/rails/blob/feb97dfabd027a73a41ca8bd2ab7c3196ab76d3d/railties/lib/rails/tasks/statistics.rake
# While global constants are bad, many 3rd party tools depend on this one (e.g
# rspec-rails & cucumber-rails). So a deprecation warning is needed if we want
# to remove it.
STATS_FOLDERS = [
  %w(Controllers        app/controllers),
  %w(Helpers            app/helpers),
  %w(Jobs               app/jobs),
  %w(Models             app/models),
  %w(Mailers            app/mailers),
  %w(Mailboxes          app/mailboxes),
  %w(Channels           app/channels),
  %w(JavaScripts        app/assets/javascripts),
  %w(Webpacker          app/javascript),
  %w(Dashboards         app/dashboards),
  %w(Fields             app/fields),
  %w(Inputs             app/inputs),
  %w(Policies           app/policies),
  %w(Services           app/services),
  %w(Workers            app/workers),
  %w(Libraries          lib/),
  %w(APIs               app/apis),
  %w(Controller\ tests  test/controllers),
  %w(Helper\ tests      test/helpers),
  %w(Model\ tests       test/models),
  %w(Mailer\ tests      test/mailers),
  %w(Mailbox\ tests     test/mailboxes),
  %w(Channel\ tests     test/channels),
  %w(Job\ tests         test/jobs),
  %w(Integration\ tests test/integration),
  %w(System\ tests      test/system),
].collect do |name, dir|
  [ name, "#{File.dirname(Rake.application.rakefile_location)}/#{dir}" ]
end.select { |name, dir| File.directory?(dir) }

desc 'Report code statistics (KLOCs, etc) from the application or engine'
task :more_stats do
  require 'rails/code_statistics'
  CodeStatistics.new(*STATS_FOLDERS).to_s
end
