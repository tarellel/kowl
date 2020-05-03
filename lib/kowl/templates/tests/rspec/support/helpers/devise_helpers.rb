# frozen_string_literal: true

require 'devise'
module DeviseHelpers
  # Used for accessing the action as an admin/superuser (a member of devgroup)
  def login_as_admin
    user = FactoryBot.create(:user, role: 'superuser')
    login_as(user)
  end
  # EXAMPLE: ----------------------------------------
  # describe 'GET #index' do
  #   it 'returns http success' do
  #     login_as_admin
  #     get :index
  #     expect(response).to have_http_status(:success)
  #   end
  # end

  def login_as_staff
    user = FactoryBot.create(:user, role: :staff)
    login_as(user)
  end

  # Used for hitting the user as a generic user
  def login_as_user
    user = FactoryBot.create(:user)
    login_as(user)
  end
  # EXAMPLE: ----------------------------------------
  # describe 'GET #index' do
  #   it 'returns http success' do
  #     login_as_user
  #     get :index
  #     expect(response).to have_http_status(:success)
  #   end
  # end

  # Used for simulating a login as the specified user
  def login_as(user)
    user = FactoryBot.create(:user) if user.nil?
    allow(controller).to receive(:authenticate_user!).and_return(true)
    allow(controller).to receive(:current_user).and_return(user)
  end
  # EXAMPLE: ----------------------------------------
  # This is also good to use if you need to add custom paramters to test against the user
  # before do
  #   @user = FactoryBot.create(:user, superuser: false, position: 'Nurse', )
  # end
  # describe 'GET #index' do
  #   it 'returns http success' do
  #     login_as @user
  #     get :welcome
  #     expect(response).to have_http_status(:success)
  #   end
  # end
end
