# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PagesController, type: :controller do
  describe 'GET #welcome' do
    subject { get :welcome }
    it { expect(response).to have_http_status(:success) }
  end
end
