# frozen_string_literal: true

require 'active_support'
require 'rails/generators/base'

# https://github.com/rails/rails/blob/66cabeda2c46c582d19738e1318be8d59584cc5b/railties/lib/rails/generators/actions.rb
# This class contains snips for dumping components into the applications Dockerfile and docker-compose files
module Kowl
  module Docker
    # Add the applications database commands to the Dockerfile
    # @param database [String] a string containing the containers database type
    # @return [String] the database commands you want to generate in the Dockerfile
    def dockerfile_migration_snip(database = '')
      return '' if database.blank?

      if database == 'sqlite3'
        ' && rails db:migrate db:seed'
      else
        <<~DB_MIGRATION_STR

          # Uncomment if you want to have your database setup when the container is running
          # => Note your database should generally be setup own it's own, but this can be used if running such as docker-compose
          # => where the database is another Docker container
          # RUN rails db:create db:migrate
          # RUN ["bin/rails", "db:seed"]
        DB_MIGRATION_STR
      end
    end

    # This is required, during built; because ENV variables are passed from the docker-compose file using env_file
    # These variables aren't picked up by the container unless they are specified as ARGS and ENV values in the dockerfile
    # they are assigned as args in case the user wwants to dynamically change the database credentials the container connects to.
    # @return [String] list of docker database arguements and env variables
    def dockerfile_database_args
      <<~DB_VARIABLES
        # Database Arguements passed when docker image is building
        ARG DB_HOST
        ARG DB_PASSWORD
        ARG DB_USER
        ENV DB_HOST=$DB_HOST \\
            DB_PASSWORD=$DB_PASSWORD \\
            DB_USER=$DB_USER
      DB_VARIABLES
    end

    # For generating the docker services depends_on tag for all services it requires in order to run
    # @param options [Hash] the specified options for the docker service your are including
    # @return [String] the depends_on string and the docker services required services (in order to run)
    def docker_depends_on(options = {})
      database = options.fetch(:database) { 'sqlite3' }
      skip_sidekiq = options.fetch(:skip_sidekiq) { false }
      indention = options.fetch(:indention) { 4 }
      requires_base = options.fetch(:requires_base) { false }
      spaces = options.fetch(:spaces) { 4 }
      return nil if requires_base == false && database == 'sqlite3' && skip_sidekiq

      base_str = (requires_base ? optimize_indentation("- base\n", indention) : '')
      db_str = optimize_indentation("- db\n", indention) unless database == 'sqlite3'
      redis_str = optimize_indentation("- redis\n", indention) unless skip_sidekiq
      spaces_str = (' ' * spaces)
      depends_on = <<~DEPENDS_ON
        #{spaces_str}depends_on:
        #{base_str}#{db_str}#{redis_str}
      DEPENDS_ON
      # Used to strip off additional trailing \n in cause both components aren't used
      depends_on.chomp
    end

    # Used to generate and return a string for adding a Redis docker service to the docker-compose file
    # @return [String] returns a string containg the entire redis service config for the docker-compose filee
    def docker_redis_service
      <<-REDIS_SERVICE
  redis:
    image: redis:alpine
    ports:
      - 6379:6379
    networks:
      - internal_network
    volumes:
      - redis:/data
    healthcheck:
      test: redis-cli ping
      interval: 1s
      timeout: 3s
      retries: 30
    sysctls:
      # https://github.com/docker-library/redis/issues/35
      net.core.somaxconn: '511'
      REDIS_SERVICE
    end

    # Generate and return the sidekiq service for the applicatio
    # @param database [String] a string containing the containers database type
    # @return [String] a string containing the sidekiq service for the docker-compose filee
    def docker_sidekiq_service(database = 'sqlite3')
      cmd_str = "#{docker_port_watcher(database, false)}rm -rf /app/.local >/dev/null 2>&1 &&\nbundle exec sidekiq"
      cmd_str = optimize_indentation(cmd_str, 13).strip

      <<-SIDEKIQ_SERVICE
  sidekiq:
    <<: *x-app_base
    image: #{app_name}_base:latest
    command: >
      sh -c "#{cmd_str}"
    depends_on:
      - base
      SIDEKIQ_SERVICE
    end

    # Generate a string containing the applications webpacker service (for recompiling new assets)
    # @param options [Hash] applications options for the application generator (ie: skip_javascript)
    # @return [String] a string containing the docker-compose webpacker entry
    def docker_webpacker_service(options)
      return '' if options[:skip_javascript]

      webpacker_str = <<-WEBPACKER
  webpacker:
    <<: *x-app_base
    image: #{app_name}_base:latest
    command: ./bin/webpack-dev-server
    ports:
      - '3035:3035'
    environment:
      WEBPACKER_DEV_SERVER_HOST: 0.0.0.0
    depends_on:
      - base
      WEBPACKER
      webpacker_str.chomp
    end

    # If a database is to be used (other than sqlite3) thiss creates the docker-compose service
    # @param database [String] the specific database the application will be running on
    # @return [String] returns a string containing the database service entry for the docker-compose file
    def docker_databases(database)
      return nil if database.blank? || database == 'sqlite3'

      case database.to_s
      when 'mysql'
        db_service = <<-DB_SERVICE
    # https://hub.docker.com/_/mysql
    image: mysql:latest
    container_name: mysql
    environment:
      - MYSQL_DATABASE=#{app_name}_development
      - MYSQL_USER=${DB_USER}
      - MYSQL_PASSWORD=${DB_PASSWORD}
      - MYSQL_RANDOM_ROOT_PASSWORD=true
    volumes:
      - mysqldata:/var/lib/mysql
    healthcheck:
      test: "/usr/bin/mysql --user=${DB_USER} --password=${DB_PASSWORD} --execute \\"SHOW DATABASES;\\""
      interval: 3s
      timeout: 45s
      retries: 10
    ports:
      - 3306:3306
        DB_SERVICE
      when 'oracle'
        db_service = <<-DB_SERVICE
    image: wnameless/oracle-xe-11g-r2
    environment:
      # Disable the disk asynch IO (improves performance)
      - ORACLE_DISABLE_ASYNCH_IO=true
      - ORACLE_ALLOW_REMOTE=true
    ports:
      - 1521:1521
        DB_SERVICE
      when 'postgresql'
        db_service = <<-DB_SERVICE
    # https://hub.docker.com/_/postgres
    image: postgres:12-alpine
    environment:
      - PSQL_HISTFILE=/root/log/.psql_history
      - POSTGRES_USER=${DB_USER}
      - POSTGRES_PASSWORD=${DB_PASSWORD}
      - POSTGRES_NON_DURABLE_SETTINGS=1
      # https://gilgamezh.me/en/posts/postgres-non-durable-options-docker-container/
    volumes:
      # - ./tmp/db:/var/lib/postgresql/data
      - postgresdata:/var/lib/postgresql/data
      - postgresconfig:/etc/postgresql
      - postgreslog:/var/log/postgresql
    healthcheck:
      test: ["CMD", "pg_isready", "-U", "${DB_USER}"]
      timeout: 45s
      interval: 5s
      retries: 10
    ports:
      - 5432:5432
        DB_SERVICE
      when 'sqlserver'
        db_service = <<-DB_SERVICE
    # https://hub.docker.com/_/microsoft-mssql-server
    image: mcr.microsoft.com/mssql/server:2017-latest
    environment:
      - ACCEPT_EULA=Y
      - SA_PASSWORD=${DB_PASSWORD}
    ports:
      - 1433:1433
        DB_SERVICE
      end

      db_str = <<-DOCKER_COMPOSE_DATABASE
  db:
    #{db_service.strip}
    env_file: .env
    stdin_open: true
    tty: true
    restart: always
    networks:
      - internal_network
      DOCKER_COMPOSE_DATABASE
      db_str
    end

    # Returns a command for the docker-compose app service
    # @param database [String] database to use for the application
    # @return [String] a bundle exec command for the docker-compose app service
    def docker_compose_database_string(database)
      case database.to_s
      when 'mysql', 'oracle', 'sqlite3'
        "bundle exec rails db:migrate db:seed >/dev/null 2>&1 &&\n"
      when 'sqlserver'
        "bundle exec rails db:setup >/dev/null 2>&1 &&\n"
      when 'postgresql'
        "bundle exec rails db:setup db:test:prepare db:seed >/dev/null 2>&1 &&\n"
      else
        ''
      end
    end

    # Generate the command for the application service in the applications docker-compose file
    # @param database [String] the specific database the application will be running on
    # @param skip_sidekiq [Boolean] if the application will skip using sidekiq
    # @return [String] the CMD entry for applications service entry in the docker-compose file
    def docker_app_command(database, skip_sidekiq = false)
      db_str = docker_compose_database_string(database)
      joined_cmd_str = "#{docker_port_watcher(database, skip_sidekiq)}#{db_str}".strip
      # This is used in case the app is generated with --database=sqlite && --skip_sidekiq
      # => Thus meaning it doesn't to wait on a database and redis to connect to container before running it
      joined_cmd_str = joined_cmd_str.blank? ? '' : joined_cmd_str

      cmd_str = <<~CMD_STR
        #{joined_cmd_str}
        rm -rf /app/tmp/pids/server.pid /app/.local >/dev/null 2>&1 &&
        bundle exec rails s -p 3000 -b 0.0.0.0
      CMD_STR
      optimize_indentation(cmd_str, 13).strip
    end

    # Create a CMD entry for services to watch before firing up the specific application
    # @param database [String] the specific database the application will be running on
    # @param skip_sidekiq [Boolean] if the application will skip using sidekiq
    # @return [String] a list of services and posts to watch before running the new command
    def docker_port_watcher(database, skip_sidekiq = false)
      return '' if database == 'sqlite3' && skip_sidekiq

      db_port = if database == 'mysql'
                  '3306'
                elsif database == 'oracle'
                  '1521'
                elsif database == 'postgresql'
                  '5432'
                elsif database == 'sqlserver'
                  '1433'
                else
                  ''
                end
      return '' if db_port.blank? && skip_sidekiq

      service_list = []
      service_list << "-wait tcp://db:#{db_port}" unless db_port.blank? || database == 'sqlite3'
      service_list << '-wait tcp://redis:6379' unless skip_sidekiq
      service_watcher_str = service_list.empty? ? '' : "dockerize #{service_list.join(' ')}"
      "#{service_watcher_str.strip} -timeout 60m &&\n"
    end

    # Create a list of variables and values for the docker-compose file depending on requirements
    # @param options [Hash] the generators options and flags for the application you are generating
    # @return [String] a string containing a list of variables for the docker-compose filee
    def docker_variables(options)
      vars_str = "BINDING: 0.0.0.0\n"
      vars_str += "COMPOSE_HTTP_TIMEOUT: 300\n"
      vars_str += "DB_HOST: db\n" unless options[:database] == 'sqlite3'
      vars_str += "RAILS_ENV: ${RAILS_ENV:-development}\n"
      vars_str += "REDIS_URL: redis://redis:6379/0\n" unless options[:skip_sidekiq]
      vars_str += "WEBPACKER_DEV_SERVER_HOST: webpacker\n" unless options[:skip_javascript]
      vars_str += "WEB_CONCURRENCY: 1\n"

      optimize_indentation(vars_str.strip, 4)
    end

    ##################################################
    # Docker-compose volumes
    ##################################################
    # Used when generating docker-compose to determine what volumes will be created for the application
    # @param options [Hash] the generators options and flags for the application you are generating
    # @return [String] a list of volumes for the apps docker-compose file depending on the apps requirements
    def docker_volumes(options)
      volume_str = <<~VOLUME_STR
        bundle:
        rails_cache:
        #{db_volumes(options[:database]).strip}
        #{js_volumes(options[:skip_javascript]).strip}
        #{redis_volumes(options[:skip_sidekiq]).strip}
      VOLUME_STR
      optimize_indentation(volume_str.squeeze("\n").strip, 2)
    end

    # List of JS volumes to use for the apps docker-compose filees
    # @return [String] a list of volumes for the apps node_modules and js builds
    def app_js_volumes
      <<~JS_VOLUMES
        - node_modules:/app/node_modules
        - packs:/app/public/packs
      JS_VOLUMES
    end

    # Generate a list of volumes to attach to the applications docker-compose service
    # @param skip_javascript [Boolean] to determine if dependencies need to be taken into account for
    # @param indention [Integer] number spaces to indent in the docker-compose.yml file
    # @return [String] a list of volumes for the application yaml file
    def app_volumes(skip_javascript = false, indention = 2)
      js_volumes_str = app_js_volumes unless skip_javascript
      volumes_str = <<~VOLUMES
        - .:/app:cached
        - bundle:/app/vendor/cache
        #{js_volumes_str}
        - rails_cache:/app/tmp/cache
      VOLUMES
      optimize_indentation(volumes_str.squeeze("\n").strip, indention)
    end

    # Return volumes for docker-compose database services
    # @param database [String] the applications required database adapter
    # @return [String] volumes for specific database containers
    def db_volumes(database)
      return '' unless %w[mysql postgresql].include?(database)

      case database
      when 'mysql'
        mysql_volumes
      when 'postgresql'
        postgresql_volumes
      else
        ''
      end
    end

    # Return a list of JS volumes for the application
    # @param skip_javascript [Boolean] if JS/node will be used with the application or not
    # @return [String] a list of js specific volumes for the application
    def js_volumes(skip_javascript = false)
      return '' if skip_javascript

      <<~JS_VOLUMES
        node_modules:
        packs:
      JS_VOLUMES
    end

    # Return a list of volumes for the mysql database service in the docker-compose.yml file
    # @return [String] an entry for the mysql volume name
    def mysql_volumes
      <<~DB_STR
        mysqldata:
      DB_STR
    end

    # Return a list of volume names for the postgresql database service in the docker-compose.yml file
    # @return [String] a list of volume names for the postgresql database
    def postgresql_volumes
      <<~DB_STR
        postgresconfig:
        postgresdata:
        postgreslog:
      DB_STR
    end

    # Return a volume name for the redis service in the docker-compose.yml file
    # @param skip_sidekiq [Boolean] a flag if the application will be using sidekiq or not
    # @return [String] the redis service volume
    def redis_volumes(skip_sidekiq = false)
      skip_sidekiq ? '' : 'redis:'
    end

    # Used to generate a dependencies list in the dockerfile based on the applications requirements
    # @param options [Hash] the applications specified options
    # @return [String] an apk string for installing dependencies in the dockerfile
    def alpine_docker_dependencies(options = {})
      # core dependencies
      dependencies = %w[brotli dumb-init git sqlite sqlite-dev tzdata vips vips-dev yarn]
      # optional dependencies
      dependencies << 'graphviz' unless options[:skip_erd]
      dependencies << 'libsodium-dev' if options[:encrypt]

      # database dependencies
      case options[:database]
      when 'mysql'
        dependencies << 'mysql-dev'
      when 'postgresql'
        dependencies << 'postgresql-dev'
      when 'sqlserver'
        dependencies << 'freetds-dev'
      end
      return '' if dependencies.empty?

      dep_str = "apk add #{dependencies.sort.join(' ')} >/dev/null 2>&1 && \\\n"
      optimize_indentation(dep_str, 4)
    end

    # Return a list of dependencies to inject into the applications Dockerfile (if they are using Debian)
    # @param options [Hash] a list of the applictions specific options to determine what all dependencies are required
    # @return [String] an `apt-get install` with a list of all the applications dependencies listed
    def debian_docker_dependencies(options = {})
      dependencies = %w[brotli curl git libjemalloc-dev libsqlite3-dev libvips sqlite3 wget]

      # optional dependencies
      dependencies << 'graphviz' unless options[:skip_erd]
      dependencies << 'libsodium23' if options[:encrypt]
      # database dependencies
      dependencies << debian_database_dependencies(options[:database]) if %w[mysql oracle postgresql sqlserver].include?(options[:database])
      return '' if dependencies.empty?

      dep_str = "apt-get install -qq --no-install-recommends #{dependencies.sort.join(' ')} 2>/dev/null && \\\n"
      optimize_indentation(dep_str, 4)
    end

    # Return a list of apt packages to install for Debian docker image
    # @param database [String] the applications specific database adapter that will be used
    # @return [String] a list of dependencies to install depending on the applications specific database
    def debian_database_dependencies(database)
      return '' if database.blank?

      case database
      when 'mysql'
        'mysql-client'
      when 'oracle'
        'alien libaio1'
      when 'postgresql'
        'postgresql-client libpq-dev'
      when 'sqlserver'
        'libpq-dev libc6-dev'
      end
    end
  end
end
