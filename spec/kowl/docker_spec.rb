# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Kowl::Docker do
  before(:each) do
    # Include the Kowl::Docker module in a class in order to make it testible
    # => This is because it is also included into the Rails generator class
    class KowlClass
      include Kowl::Docker
    end
    @kowl = KowlClass.new
  end

  context 'Dockerfile migration' do
    describe 'no database' do
      it { expect(@kowl.dockerfile_migration_snip).to eq('') }
    end

    describe 'sqlite3' do
      it { expect(@kowl.dockerfile_migration_snip('sqlite3')).to eq(' && rails db:migrate db:seed') }
    end

    describe 'other database' do
      it { expect(@kowl.dockerfile_migration_snip('postgresql')).to include('# RUN ["bin/rails", "db:seed"]') }
    end
  end

  context 'dockerfile args' do
    it { expect(@kowl.dockerfile_database_args).to include('ARG DB_HOST') }
  end

  context 'docker database port' do
    it { expect(@kowl.docker_port_watcher('mysql', true)).to eq("dockerize -wait tcp://db:3306 -timeout 60m &&\n") }
    it { expect(@kowl.docker_port_watcher('mysql')).to eq("dockerize -wait tcp://db:3306 -wait tcp://redis:6379 -timeout 60m &&\n") }

    # to use sqlite and skip_sidekiq
    it { expect(@kowl.docker_port_watcher('sqlite3', true)).to eq('') }
    it { expect(@kowl.docker_port_watcher('sqlite3')).to eq("dockerize -wait tcp://redis:6379 -timeout 60m &&\n") }
  end

  context 'database volumes' do
    it { expect(@kowl.db_volumes('sqlite3')).to eq('') }
    it { expect(@kowl.db_volumes('postgresql')).to eq("postgresconfig:\npostgresdata:\npostgreslog:\n") }
  end

  context 'js volumes' do
    it { expect(@kowl.js_volumes(true)).to eq('') }
    it { expect(@kowl.js_volumes).to include('packs:') }
  end

  context 'redis volumes' do
    it { expect(@kowl.redis_volumes).to eq('redis:') }
    # with skip_sidekiq
    it { expect(@kowl.redis_volumes(true)).to eq('') }
  end
end
