# frozen_string_literal: true

##################################################
# Helper methods used to assist through the template building
# => similar to the functions used in Rails::Generators::AppBase
##################################################

# Method required when processing the gemfile
#   - https://raw.githubusercontent.com/liukun-lk/rails_start_template/master/template.rb
#   - https://github.com/manuelvanrijn/rails-template/blob/master/template.rb
# @param name [String] Specific gem you are wanting to check the requirements for
def gemfile_requirement(name)
  @original_gemfile ||= IO.read('Gemfile')
  req = @original_gemfile[/gem\s+['"]#{name}['"]\s*(,[><~= \t\d\.\w'"]*)?.*$/, 1]
  req && req.tr("'", %(")).strip.sub(/^,\s*"/, ', "')
end

# Determine which gem will be used for the projects CSS framework
# @param css_framework [String] Which CSSFramework the developer wants to use with the application
# @return [String] The specific gem that will be used for the applications CSS framework
def template_engine_gem_str(css_framework = '')
  case css_framework.to_s
  when 'semantic'
    'semantic_ui'
  else
    'bootstrap'
  end
end

# https://github.com/rails/rails/blob/master/railties/lib/rails/generators/rails/app/templates/Gemfile.tt#L9
# Add a gem to the Gemfile
# @param gem [String] Specfic gem name that you want to add to the gemfile
# @return [String] Returns the gem entry for the gemfile
def gem_to_gemfile(gem)
  gem_str = <<~GEM
    #{gem.comment ? "# #{gem.comment}" : ''}
    #{(gem.commented_out ? '#' : '')}gem '#{gem.name}'#{gem_version_str(gem)}#{gem_options(gem)}
  GEM

  gem_str.strip
end

# If the gem requires a specific version, determine it
# @param gem [String] - To determine if the specified gems requires a specific version to run with the application
# @return [String] - If the gem require a specific version, it will return that version entry for the gemfile
def gem_version_str(gem)
  return '' unless gem.version

  # "#{gem.version ? ", '#{gem.version}'" : ''}"
  ", '#{gem.version}'"
end

# If the requested gem requires additional options (ie: require: false) return this
# @param gem [String] The specified gem you want to use
# @return [String] If the gem requires additional opotions in the gemfile, return these as a string
def gem_options(gem)
  return '' unless gem.options.any?

  options_str = gem.options.map { |k, v| "#{k}: #{v.inspect}" }.join(', ')
  ", #{options_str}" unless options_str.blank?
end

# Make a directory in the applications directory path
# @param dir [String] The name of the directory you want to create
def mk_appdir(dir)
  path = Rails.root.join(dir)
  FileUtils.mkdir(path) unless File.directory?(path)
end

# If you want all lines of the string to be indented a specific amount
# @param str [String] - The multiline string in which you want to indent
# @return [String] - An indented version of thee string that was passed to the function
def indent_all_lines(str, spaces = 2)
  return '' if str.nil? || str.blank?

  str.strip.split(/\n/).map { |line| optimize_indentation(line, spaces.to_i) }.join('')
end

# Used to add additional assets to be considered when compiling your assets
# @param str [String] Asset string file to add to the file, ie: `application-mailer.scss`
def add_to_assets(asset_str)
  append_to_file('config/initializers/assets.rb', "Rails.application.config.assets.precompile += %w( #{asset_str} )\n") unless asset_str.blank?
end

# Add a specific line to the config/routes.rb file
# @param route_str [String] The specific route you want to add to the applications route file
def add_to_routes(route_str = '')
  inject_into_file('config/routes.rb', optimize_indentation("#{route_str.strip}\n", 2), after: "\s# For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html\n")
end

##################################################
# Used to create highlights when running `kowl -h` (usage summary displayed by the binstub)
##################################################

# Highlight the specific string
# @param str [String] The string in which you wish to highlight
# @return [String] The specified string concatenated between terminal encoded character sequences
def highlight(str = '')
  return '' if str.blank?

  str = str.split('=')
  str.count > 1 ? "\e[32m#{str[0]}=\e[33m#{str[1]}\e[0m" : "\e[32m#{str[0]}\e[0m"
end

# Highlight the default values for specified flag
# @param str [String] The default values for the specified parameter
# @return [String] the specified text string surrounded by terminal string highlights
def dh(str = '')
  return '' if str.blank?

  str = str.split(': ')
  str.count > 1 ? "\e[36m#{str[0]}: \e[31m#{str[1]}\e[0m" : "\e[34m#{str[0]}\e[0m"
end

# Used to create and return the .env file database configuration for the specific environment
# @param database [String] the database adapater in which the application will be connecting to
# @param env [String] the environment which the env file is bring created for
# @return [String] a list of database parameters for the specific database connection
def dotfile_databases(database, env)
  return '' if database == 'sqlite3'

  db = { username: "DB_USER=appUser123\n",
         password: "DB_PASSWORD=App($)Password\n",
         sid: '',
         host: '' }

  case database
  when 'oracle'
    db = { username: "DB_USER=system\n",
           password: "DB_PASSWORD=oracle\n",
           sid: "DB_SID=xe\n" }
  when 'sqlserver'
    db[:username] = "DB_USER=SA\n"
    db[:password] = "DB_PASSWORD=yourStrong(!)Password\n"
  end
  db[:host] = "DB_HOST=localhost\n" unless env == 'docker'

  "#{db[:username]}#{db[:password]}#{db[:host]}#{db[:sid]}"
end
