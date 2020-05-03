source "https://rubygems.org"

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

# Specify your gem's dependencies in kowl.gemspec
gemspec

group :developmentt do
  gem 'rubocop', require: false
  gem 'rubocop-performance'
  gem 'rubocop-rspec'
  gem 'sorbet'
end

group :test do
  gem 'fuubar'
  gem 'rspec'
  gem 'simplecov', require: false
end

gem 'guard'
gem 'guard-rspec'
gem 'guard-rubocop'
gem 'guard-yard'