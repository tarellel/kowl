# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Pages', type: :request do
  it 'visits welcome page' do
    get '/welcome'
    expect(response).to have_http_status(:success)
    expect(response.body).to include('Welcome')
  end
end
