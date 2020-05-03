# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kowl/version'

Gem::Specification.new do |s|
  s.name          = 'kowl'
  s.version       = Kowl::VERSION
  s.authors       = ['Brandon Hicks']
  s.email         = ['tarellel@gmail.com']
  s.summary       = %q{A rails application generator to get you out the door and started without wasting hours to get started.}
  s.description   = %q{Used to generate a Rails application following a basic setup of best practices, guidelines, and basic setup; to get your Rails application started with a bang. }
  s.homepage      = 'https://github.com/tarellel/kowl'
  s.license       = 'MIT'

  s.required_ruby_version = ">= #{Kowl::RUBY_VERSION}"
  s.files         = Dir.glob("{bin,lib}/**/*")
  s.executables   = ['kowl']
  s.extra_rdoc_files = %w[README.md LICENSE]
  s.require_paths = ['lib']
  s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.metadata = {
    "bug_tracker_uri" => "https://github.com/tarellel/kowl/issues",
    "changelog_uri" => "https://github.com/tarellel/kowl/blob/master/CHANGELOG.md",
    "source_code_uri" => "https://github.com/tarellel/kowl"
  }

  # Bundler version required by Rails -> https://rubygems.org/gems/rails/versions/6.0.2.1/dependencies
  s.add_dependency 'bundler', '>= 1.0', '< 3.0'
  s.add_dependency 'rack', '~> 2.2'
  s.add_dependency 'rails', "~> #{Kowl::RAILS_VERSION}"
  s.add_dependency 'sqlite3', '~> 1.4'
  s.add_dependency 'webpacker', "~> #{Kowl::WEBPACKER_VERSION}"

  if RUBY_VERSION >= '2.7'
    s.add_dependency 'e2mmap', '~> 0.1'
    s.add_dependency 'thwait', '~> 0.1'
  end

  s.add_development_dependency 'rspec', '~> 3.9.0'
  s.add_development_dependency 'yard', '~> 0.9.24'
end
