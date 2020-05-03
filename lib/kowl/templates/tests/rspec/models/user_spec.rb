# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    context 'with email' do
      it { is_expected.to validate_presence_of(:email) }
      it { is_expected.to validate_length_of(:email).is_at_least(5).is_at_most(255) }
      # it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
    end

    context 'with roles' do
      it { is_expected.to define_enum_for(:role).with(described_class.roles.keys) }
    end

    context 'with associations' do
      it { is_expected.to have_many(:login_activities).order(created_at: :desc) }
    end
  end
end