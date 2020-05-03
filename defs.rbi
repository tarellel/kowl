# typed: strong
# Used for fetching the GeoLite db from maxmind
class GeoDB
  GEOLITE_URL = T.let('http://geolite.maxmind.com/download/geoip/database/GeoLite2-City.tar.gz', T.untyped)

  # Begin creating folders and being downloadding the GeoLite db
  # 
  # _@param_ `path` — the applications relative path
  # 
  # _@return_ — if the GeoLite2 database was successfully downloaded and decompressed
  sig { params(path: String).returns(T::Boolean) }
  def self.perform(path); end

  # Download the file from the GEOLITE url
  # 
  # _@return_ — returns if the the file was succcessfully downloaded
  sig { returns(T::Boolean) }
  def self.download; end

  # Extract the GEOLIB tar.gz file into the application
  # 
  # _@return_ — if the file was sucessfully decompressed
  sig { returns(T::Boolean) }
  def self.extract; end

  # Uncompress the zipfile
  #  https://www.rubydoc.info/gems/folio/0.4.0/ZipUtils.ungzip
  # 
  # _@param_ `file` — the specific file path/name
  # 
  # _@param_ `options` — any specific options required for decompressing the file [:dryrun] || [:noop]
  # 
  # _@return_ — if the File was sucessfully decompressed
  sig { params(file: String, options: T::Hash[T.untyped, T.untyped]).returns(T::Boolean) }
  def self.unzip(file, options = {}); end

  # Untar the specified file
  # 
  # _@param_ `tarred_path` — the specific filename/path for the tar file
  # 
  # _@return_ — if the file was successfully decompressed
  sig { params(tarred_path: String).returns(T::Boolean) }
  def self.untar(tarred_path); end

  # The destination of where the tarfile is loaded
  # 
  # _@param_ `file` — the specific geolite database file locattion
  # 
  # _@return_ — to the GEOLIB database file
  sig { params(file: String).returns(String) }
  def self.db_destinsation(file); end
end

# https://github.com/rails/rails/blob/66cabeda2c46c582d19738e1318be8d59584cc5b/railties/lib/rails/generators/actions.rb
module Kowl
  RAILS_VERSION = T.let('6.0.2.2', T.untyped)
  RUBY_VERSION = T.let('2.5', T.untyped)
  WEBPACKER_VERSION = T.let('5.0', T.untyped)
  VERSION = T.let('0.0.1', T.untyped)

  module Docker
    # Add the applications database commands to the Dockerfile
    # 
    # _@param_ `database` — a string containing the containers database type
    # 
    # _@return_ — the database commands you want to generate in the Dockerfile
    sig { params(database: String).returns(String) }
    def dockerfile_migration_snip(database = ''); end

    # This is required, during built; because ENV variables are passed from the docker-compose file using env_file
    # These variables aren't picked up by the container unless they are specified as ARGS and ENV values in the dockerfile
    # they are assigned as args in case the user wwants to dynamically change the database credentials the container connects to.
    # 
    # _@return_ — list of docker database arguements and env variables
    sig { returns(String) }
    def dockerfile_database_args; end

    # For generating the docker services depends_on tag for all services it requires in order to run
    # 
    # _@param_ `options` — the specified options for the docker service your are including
    # 
    # _@return_ — the depends_on string and the docker services required services (in order to run)
    sig { params(options: T::Hash[T.untyped, T.untyped]).returns(String) }
    def docker_depends_on(options = {}); end

    # Used to generate and return a string for adding a Redis docker service to the docker-compose file
    # 
    # _@return_ — returns a string containg the entire redis service config for the docker-compose filee
    sig { returns(String) }
    def docker_redis_service; end

    # Generate and return the sidekiq service for the applicatio
    # 
    # _@param_ `database` — a string containing the containers database type
    # 
    # _@return_ — a string containing the sidekiq service for the docker-compose filee
    sig { params(database: String).returns(String) }
    def docker_sidekiq_service(database = 'sqlite3'); end

    # Generate a string containing the applications webpacker service (for recompiling new assets)
    # 
    # _@param_ `options` — applications options for the application generator (ie: skip_javascript)
    # 
    # _@return_ — a string containing the docker-compose webpacker entry
    sig { params(options: T::Hash[T.untyped, T.untyped]).returns(String) }
    def docker_webpacker_service(options); end

    # If a database is to be used (other than sqlite3) thiss creates the docker-compose service
    # 
    # _@param_ `database` — the specific database the application will be running on
    # 
    # _@return_ — returns a string containing the database service entry for the docker-compose file
    sig { params(database: String).returns(String) }
    def docker_databases(database); end

    # Returns a command for the docker-compose app service
    # 
    # _@param_ `database` — database to use for the application
    # 
    # _@return_ — a bundle exec command for the docker-compose app service
    sig { params(database: String).returns(String) }
    def docker_compose_database_string(database); end

    # Generate the command for the application service in the applications docker-compose file
    # 
    # _@param_ `database` — the specific database the application will be running on
    # 
    # _@param_ `skip_sidekiq` — if the application will skip using sidekiq
    # 
    # _@return_ — the CMD entry for applications service entry in the docker-compose file
    sig { params(database: String, skip_sidekiq: T::Boolean).returns(String) }
    def docker_app_command(database, skip_sidekiq = false); end

    # Create a CMD entry for services to watch before firing up the specific application
    # 
    # _@param_ `database` — the specific database the application will be running on
    # 
    # _@param_ `skip_sidekiq` — if the application will skip using sidekiq
    # 
    # _@return_ — a list of services and posts to watch before running the new command
    sig { params(database: String, skip_sidekiq: T::Boolean).returns(String) }
    def docker_port_watcher(database, skip_sidekiq = false); end

    # Create a list of variables and values for the docker-compose file depending on requirements
    # 
    # _@param_ `options` — the generators options and flags for the application you are generating
    # 
    # _@return_ — a string containing a list of variables for the docker-compose filee
    sig { params(options: T::Hash[T.untyped, T.untyped]).returns(String) }
    def docker_variables(options); end

    # Docker-compose volumes
    # 
    # Used when generating docker-compose to determine what volumes will be created for the application
    # 
    # _@param_ `options` — the generators options and flags for the application you are generating
    # 
    # _@return_ — a list of volumes for the apps docker-compose file depending on the apps requirements
    sig { params(options: T::Hash[T.untyped, T.untyped]).returns(String) }
    def docker_volumes(options); end

    # List of JS volumes to use for the apps docker-compose filees
    # 
    # _@return_ — a list of volumes for the apps node_modules and js builds
    sig { returns(String) }
    def app_js_volumes; end

    # Generate a list of volumes to attach to the applications docker-compose service
    # 
    # _@param_ `skip_javascript` — to determine if dependencies need to be taken into account for
    # 
    # _@param_ `indention` — number spaces to indent in the docker-compose.yml file
    # 
    # _@return_ — a list of volumes for the application yaml file
    sig { params(skip_javascript: T::Boolean, indention: Integer).returns(String) }
    def app_volumes(skip_javascript = false, indention = 2); end

    # Return volumes for docker-compose database services
    # 
    # _@param_ `database` — the applications required database adapter
    # 
    # _@return_ — volumes for specific database containers
    sig { params(database: String).returns(String) }
    def db_volumes(database); end

    # Return a list of JS volumes for the application
    # 
    # _@param_ `skip_javascript` — if JS/node will be used with the application or not
    # 
    # _@return_ — a list of js specific volumes for the application
    sig { params(skip_javascript: T::Boolean).returns(String) }
    def js_volumes(skip_javascript = false); end

    # Return a list of volumes for the mysql database service in the docker-compose.yml file
    # 
    # _@return_ — an entry for the mysql volume name
    sig { returns(String) }
    def mysql_volumes; end

    # Return a list of volume names for the postgresql database service in the docker-compose.yml file
    # 
    # _@return_ — a list of volume names for the postgresql database
    sig { returns(String) }
    def postgresql_volumes; end

    # Return a volume name for the redis service in the docker-compose.yml file
    # 
    # _@param_ `skip_sidekiq` — a flag if the application will be using sidekiq or not
    # 
    # _@return_ — the redis service volume
    sig { params(skip_sidekiq: T::Boolean).returns(String) }
    def redis_volumes(skip_sidekiq = false); end

    # Used to generate a dependencies list in the dockerfile based on the applications requirements
    # 
    # _@param_ `options` — the applications specified options
    # 
    # _@return_ — an apk string for installing dependencies in the dockerfile
    sig { params(options: T::Hash[T.untyped, T.untyped]).returns(String) }
    def alpine_docker_dependencies(options = {}); end

    # Return a list of dependencies to inject into the applications Dockerfile (if they are using Debian)
    # 
    # _@param_ `options` — a list of the applictions specific options to determine what all dependencies are required
    # 
    # _@return_ — an `apt-get install` with a list of all the applications dependencies listed
    sig { params(options: T::Hash[T.untyped, T.untyped]).returns(String) }
    def debian_docker_dependencies(options = {}); end

    # Return a list of apt packages to install for Debian docker image
    # 
    # _@param_ `database` — the applications specific database adapter that will be used
    # 
    # _@return_ — a list of dependencies to install depending on the applications specific database
    sig { params(database: String).returns(String) }
    def debian_database_dependencies(database); end
  end

  module Actions
    # Used to call a rails system command
    # 
    # _@param_ `cmd` — The rails command that will be executed, ie: db:migrate
    # 
    # _@return_ — if the rails command was succcessfully executed or not
    sig { params(cmd: String).returns(T::Boolean) }
    def rails_cmd(cmd = ''); end

    # Used to install yarn package is NPM/Yarn is available
    # 
    # _@param_ `pkg` — The Yarn/npm package in which to install with the Rails Application
    # 
    # _@return_ — if the yarn package was successfully installed or not
    sig { params(pkg: String).returns(T::Boolean) }
    def add_package(pkg = ''); end

    # Append a string to the end of a specied file
    # 
    # _@param_ `file` — Filename to append the string to
    # 
    # _@param_ `str` — String to add to the specified file
    # 
    # _@return_ — if the string was appended to the file or not
    sig { params(file: String, str: String).returns(T::Boolean) }
    def append_to_file(file, str); end

    # Validate if a specified file exists
    # 
    # _@param_ `file` — Filename to validate against
    # 
    # _@return_ — Returns whether if the file exists or not
    sig { params(file: String).returns(T::Boolean) }
    def file_exists?(file); end

    # Dupliate a specified file (make a copy)
    # 
    # _@param_ `source` — The originating file in which you wish to duplicate
    # 
    # _@param_ `destination` — The destination of the file in which you are duplicating to
    # 
    # _@return_ — Returns nil if the source or destination where not specified. Otherwise if should return true/false if the file was actually duplicated
    sig { params(source: String, destination: String).returns(T.nilable(T::Boolean)) }
    def dup_file(source, destination); end

    # Create a specific directory
    # 
    # _@param_ `path` — The path in which you wish to create
    # 
    # _@return_ — if the filepath was created or not
    sig { params(path: String).returns(T::Boolean) }
    def mk_dir(path); end

    # Delete a specific directory path
    # src: https://github.com/solidusio/solidus/blob/master/core/lib/generators/spree/dummy/dummy_generator.rb#L128
    # 
    # _@param_ `path` — The specifc directory which you wish to remove
    # 
    # _@return_ — if the FileDir was removed or not
    sig { params(path: String).returns(T::Boolean) }
    def remove_dir(path); end

    # Delete a specific file from the projects directory structure
    # 
    # _@param_ `file` — The specific file in which you wish to delete
    # 
    # _@return_ — Returns nil if the filename is blank, otherwise it should return true/false if the file was properly removed
    sig { params(file: String).returns(T.nilable(T::Boolean)) }
    def remove_file(file); end

    # Move a file to a specified location
    # 
    # _@param_ `file` — The original file location in which you want to move the file from
    # 
    # _@param_ `destination` — The destintion location of where you would like to move this file to
    # 
    # _@return_ — Return nil if the file or destrination are blank. Otherwise it will return true/false if the file was successfully moved
    sig { params(file: String, destination: String).returns(T.nilable(T::Boolean)) }
    def move_file(file, destination); end

    # Used to remove a gem from the Gemfile and bundle installs afterwards
    # 
    # _@param_ `gem` — The Gem name which you would like to remove from the gemfile
    # 
    # _@return_ — Returns nil if the the method is called without a gem specified
    sig { params(gem: String).returns(T.nilable(T.any())) }
    def remove_gem(gem); end

    # Replace a matching string within a specific file
    # 
    # _@param_ `filename` — The file in which you would like to change it's contents
    # 
    # _@param_ `regex` — The regular expression you would like to run against the line of text within the file
    # 
    # _@param_ `replacement` — The string in which you would like to replace any matches against
    # 
    # _@return_ — if the string was successfully replaced in the specified file
    sig { params(filename: String, regex: String, replacement: String).returns(T::Boolean) }
    def replace_string_in_file(filename, regex, replacement = ''); end

    # Add config to the development environment
    # 
    # _@param_ `str` — A heredoc containing configuration changes for the development environment
    # 
    # _@return_ — if the string was successfully injected into the development config file
    sig { params(str: String).returns(T::Boolean) }
    def dev_config(str); end

    # Routes
    # 
    # Adds a development only route to access LetterOpener when developmenting the application
    # 
    # _@param_ `skip_mailer` — A flag to determine if you want to skip using a mailer
    # 
    # _@return_ — the LetterOpener mount path (unless you have specied to skip_mailer)
    sig { params(skip_mailer: T::Boolean).returns(String) }
    def mailer_route(skip_mailer); end

    # Add PgHero engine mount to the routes if the database iss postgresql
    # 
    # _@param_ `database` — A string containing the applications defined database adapater
    # 
    # _@return_ — the pghero dashboard mount path, if postgresql will be used
    sig { params(database: String).returns(String) }
    def database_route(database = 'sqlite3'); end

    # Unless specified the function will add a Sidekiq engine route to access in the routes
    # 
    # _@param_ `options` — A flag to determine if you would like the generators to skip adding sidekiq to the applicatiion
    # 
    # _@return_ — the sidekiq mount path
    sig { params(options: T::Hash[T.untyped, T.untyped]).returns(String) }
    def sidekiq_route(options); end

    # Unless all extensions are skipped [mailer && sidekiq], will will add their mounts depending on if the add requires auth or not
    # 
    # _@param_ `options` — The entire generators options passed to it
    # 
    # _@return_ — the applications extensions mount paths for routes file
    sig { params(options: T::Hash[T.untyped, T.untyped]).returns(String) }
    def add_extension_routes(options); end

    # Gemfile specific functions
    # 
    # Adds the specified mailer gem to the application
    # 
    # _@param_ `mailer` — Specfic mailer in which you would like to use
    # 
    # _@return_ — the applications mailer gem that will be added to the Gemfile
    sig { params(mailer: String).returns(String) }
    def mailer_gems(mailer = 'sparkpost'); end

    # Outputs a set of Gemfile entries for the application developer to use pry in the rails console
    # 
    # _@param_ `skip_pry` — if the developer wants to skip using pry with their application
    # 
    # _@return_ — return the string to be added to the applications Gemfile
    sig { params(skip_pry: T::Boolean).returns(T.nilable(String)) }
    def pry_gems(skip_pry = false); end

    # Determine which linter should be used for the aplication
    # 
    # _@param_ `engine` — The specified applications templating engine (erb, hal, or slim)
    # 
    # _@return_ — An gem line that will be added to the gemfile
    sig { params(engine: String).returns(String) }
    def template_linter_gems(engine); end

    # Determine which rubcop gem should be used (dependant on the requested test suite)
    # 
    # _@param_ `test_engine` — The specified application test suite requested
    # 
    # _@param_ `skip_tests` — if you would like skip using tests with the application
    # 
    # _@return_ — The gemfile rubocop gem entry based on the applications test suite
    sig { params(test_engine: String, skip_tests: T::Boolean).returns(String) }
    def robocop_test_engine(test_engine = '', skip_tests = false); end
  end
end
