# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'VERSIONS' do
  context 'ensure versions defined' do
    describe 'Kowl version defined' do
      it { expect(::Kowl::VERSION).to be_truthy }
    end

    describe 'ruby_version defined' do
      it { expect(::Kowl::RUBY_VERSION).to be_truthy }
    end

    describe 'rails version defined' do
      it { expect(::Kowl::RAILS_VERSION).to be_truthy }
    end

    describe 'webpacker version defined' do
      it { expect(::Kowl::WEBPACKER_VERSION).to be_truthy }
    end
  end
end
