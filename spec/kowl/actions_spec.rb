# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Kowl::Docker do
  before(:each) do
    # Include the Kowl::Docker module in a class in order to make it testible
    # => This is because it is also included into the Rails generator class
    class KowlClass
      include Kowl::Actions
    end
    @kowl = KowlClass.new
  end

  context 'database route (pghero)' do
    it { expect(@kowl.database_route).to eq('') }
    it { expect(@kowl.database_route('mysql')).to eq('') }
    it { expect(@kowl.database_route('postgresql')).to eq("  mount PgHero::Engine, at: \"pghero\"\n") }
  end

  context 'mailers' do
    it { expect(@kowl.mailer_gems('postmark')).to eq("gem 'postmark-rails'") }
    it { expect(@kowl.mailer_gems).to eq("gem 'sparkpost_rails'") }
  end

  context 'pry_gems' do
    it { expect(@kowl.pry_gems(true)).to eq(nil) }
  end

  context 'robocop test engine' do
    it { expect(@kowl.robocop_test_engine).to eq('') }
    it { expect(@kowl.robocop_test_engine('minitest')).to include('minitest') }
    it { expect(@kowl.robocop_test_engine('rspec')).to include('rspec') }
  end
end