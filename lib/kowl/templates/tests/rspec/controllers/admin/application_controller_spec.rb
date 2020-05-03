# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::ApplicationController, type: :controller do
  describe 'Require authentication' do
    context 'when requesting /admin/*' do
      it { is_expected.to use_before_action(:authenticate_user!) }
      it { is_expected.to use_before_action(:ensure_admin!) }
    end
  end
end
