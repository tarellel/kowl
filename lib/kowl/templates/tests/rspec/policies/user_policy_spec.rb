# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserPolicy, type: :policy do
  subject { described_class.new(member, user) }

  let(:user) { FactoryBot.create(:user) }

  context 'when user' do
    let(:member) { FactoryBot.create(:user) }

    it { is_expected.to forbid_actions(%i[index show destroy impersonate]) }
    it { is_expected.to forbid_new_and_create_actions }
    it { is_expected.to forbid_edit_and_update_actions }
  end

  context 'when staff' do
    let(:member) { FactoryBot.create(:user, role: 'staff') }

    it { is_expected.to forbid_actions(%i[index destroy impersonate]) }
    it { is_expected.to permit_action(:show) }
    it { is_expected.to forbid_new_and_create_actions }
    it { is_expected.to permit_edit_and_update_actions }
  end

  context 'when superuser' do
    let(:member) { FactoryBot.create(:user, role: 'superuser') }

    it { is_expected.to permit_actions(%i[index show destroy impersonate]) }
    it { is_expected.to forbid_new_and_create_actions }
    it { is_expected.to permit_edit_and_update_actions }
  end

  permissions :update? do
    let(:staff) { FactoryBot.create(:user, role: 'staff') }
    let(:superuser) { FactoryBot.create(:user, role: 'superuser') }

    it 'when staff and updating users' do
      expect(described_class).to permit(staff, user)
    end

    it 'when staff and updating superusers' do
      expect(described_class).not_to permit(staff, superuser)
    end
  end

  permissions :show? do
    let(:staff) { FactoryBot.create(:user, role: 'staff') }
    let(:superuser) { FactoryBot.create(:user, role: 'superuser') }

    it "staff can't view superuser" do
      expect(described_class).not_to permit(staff, superuser)
    end
  end
end
