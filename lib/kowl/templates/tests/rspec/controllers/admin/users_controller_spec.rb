# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::UsersController, type: :controller do
  describe 'When user' do
    before { login_as_user }

    it 'GET index' do
      get :index
      expect(response).to be_redirect
    end
  end
end
